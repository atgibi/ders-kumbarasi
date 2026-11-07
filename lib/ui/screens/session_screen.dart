import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../app/session_controller.dart';
import '../../app/speaker.dart';
import '../../data/models.dart';
import '../../data/progress_store.dart';
import '../../game/items.dart';
import '../../game/quests.dart';
import '../../game/turkish.dart';
import '../../game/world.dart';
import '../game/duel_widgets.dart';
import '../game/game_theme.dart';
import '../game/hero_figure.dart';
import '../game/year_end.dart';
import '../theme.dart';
import '../widgets/dk_icon.dart';
import '../widgets/emoji_text.dart';
import '../widgets/hand.dart';
import '../widgets/ikon.dart';
import '../widgets/kit.dart';
import '../widgets/mascot.dart';
import '../widgets/visual_view.dart';
import 'question_kinds.dart';
import 'system_screens.dart';

const _okTitles = ['Harika!', 'Tam isabet!', 'Dikkatle düşündün!'];
const _okBodies = [
  'Dikkatle çalıştın.',
  'Adım adım düşündün.',
  'Güzel çalıştın.'
];

enum _Phase { loading, empty, error, run, summary, streak, duelWin, finaleWin }

/// Çalışma oturumu (C1–C12): konu anlatımı, sorular, etkinlik, özet, seri.
class SessionScreen extends StatefulWidget {
  const SessionScreen({
    super.key,
    required this.subject,
    this.focusOutcome,
    this.reviewOnly = false,
    this.extraPractice = false,
    this.duel,
    this.finale = false,
  });

  /// Yıl sonu düellosu (Karabulut): bu dersin başlanmış tüm konularından.
  final bool finale;

  /// Verilirse bekçi düellosu: bu bölgenin çıktılarından karma sorular.
  final RegionDef? duel;

  final Subject subject;
  final String? focusOutcome;
  final bool reviewOnly;
  final bool extraPractice;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  SessionController? _c;
  _Phase _phase = _Phase.loading;
  bool _limitWarned = false;
  int _praise = 0;
  final Map<String, String> _lessonTitles = {};
  Speaker? _speaker;

  /// Düelloda düşen zırh parçası (her doğru cevap bir parça).
  int _duelHits = 0;
  int _duelPieces = 0;
  bool _duelGift = false;
  ItemDef? _duelItem;
  String? _notebookLine;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _speaker = AppScope.read(context).speaker;
  }

  @override
  void dispose() {
    _speaker?.stop();
    hideDkToast();
    super.dispose();
  }

  Future<void> _load() async {
    final app = AppScope.read(context);
    try {
      final duel = widget.duel;
      final c = duel != null || widget.finale
          ? await SessionController.duel(
              repo: app.content,
              subject: widget.subject,
              grade: app.active!.grade,
              progress: app.progress!,
              outcomeCodes: duel != null
                  ? [for (final o in duel.outcomes) o.code]
                  : await app.finaleOutcomes(widget.subject),
              count: duel != null ? 8 : 12,
              clock: app.clock,
            )
          : await SessionController.build(
              repo: app.content,
              subject: widget.subject,
              grade: app.active!.grade,
              progress: app.progress!,
              clock: app.clock,
              focusOutcome: widget.focusOutcome,
              reviewOnly: widget.reviewOnly,
              extraPractice: widget.extraPractice,
              locked: await app.lockedOutcomes(widget.subject),
            );
      _duelPieces = c.steps.length;
      final pack =
          await app.content.contentFor(widget.subject, app.active!.grade);
      for (final e in pack.entries) {
        if (e.value.lessons.isNotEmpty) {
          _lessonTitles[e.key] = e.value.lessons.first.title;
        }
      }
      if (!mounted) return;
      setState(() {
        _c = c;
        _phase = c.steps.isEmpty ? _Phase.empty : _Phase.run;
      });
    } on Object catch (e, st) {
      debugPrint('Oturum açılamadı: $e\n$st');
      if (mounted) setState(() => _phase = _Phase.error);
    }
  }

  void _say(String text, {bool slow = false}) =>
      AppScope.read(context).say(text, slow: slow);

  /// Günlük süre doluyorsa oturum kısalır (yarıda kesilmez).
  void _checkLimit() {
    final app = AppScope.read(context);
    final c = _c!;
    if (_limitWarned) return;
    final spent = app.clock().difference(c.startedAt).inSeconds / 60;
    if (app.minutesToday() + spent >= app.settings.dailyLimitMinutes &&
        c.remainingQuestions > 2) {
      _limitWarned = true;
      c.limitRemaining(2);
      showDkToast(context, DkIcons.hourglass,
          'Süremiz doluyor. 2 soru daha, sonra dinlenme zamanı.');
    }
  }

  Future<void> _advance(VoidCallback step, {bool retryNote = false}) async {
    step();
    final c = _c!;
    final app = AppScope.read(context);
    if (c.isDone) {
      c.finish();
      await app.recordSession(
          correct: c.summary.correct,
          newTopics: c.summary.newOutcomes.length,
          reviewed: widget.reviewOnly ? c.summary.answered : 0);
      if (!mounted) return;
      if (widget.finale) {
        _winFinale(app);
        await app.saveProgress();
        if (!mounted) return;
        setState(() => _phase = _Phase.finaleWin);
        _say('Karabulut barıştı!');
        return;
      }
      if (widget.duel != null) {
        _winDuel(app, c);
        await app.saveProgress();
        if (!mounted) return;
        setState(() => _phase = _Phase.duelWin);
        _say('${widget.duel!.guardian.name} kurtuldu! '
            '${widget.duel!.guardian.thanks}'
            '${_duelItem == null ? '' : ' Yeni eşya kazandın: ${_duelItem!.name}.'}');
        return;
      }
      _writeNotebook(app, c);
      await app.saveProgress();
      if (!mounted) return;
      setState(() => _phase = _Phase.summary);
      _say('Bugün çok çalıştın!');
      return;
    }
    await app.saveProgress();
    if (!mounted) return;
    _checkLimit();
    setState(() {});
    if (retryNote && !_limitWarned) {
      showDkToast(
          context, DkIcons.again, 'Bunu birazdan bir kez daha soracağız.');
    }
  }

  /// Karabulut düellosu bitti: bu krallıkta barışıldı. Dördü bitince Efsane.
  void _winFinale(AppState app) {
    final g = app.progress!.game;
    final k = Kingdom.of(widget.subject);
    final first = g.finale.add(widget.subject.id);
    if (!first) return;
    app.progress!.nuts += 20;
    g.addPage(
        dayKey(app.clock()),
        '${_heroName(app)}, ${locative(k.name)} Karabulut ile yüzleşti. '
        'Küs bulut barıştı ve filizlere yağmur yağdırdı.');
    if (app.finaleDone) {
      g.addPage(dayKey(app.clock()),
          '${_heroName(app)} dört krallıkta da Karabulut ile barıştı ve Efsane oldu.');
    }
  }

  /// Düello bitti: zafer her zaman gelir; %80 ve üstü ilk denemede doğruysa
  /// bekçi ek bir hediye bırakır.
  void _winDuel(AppState app, SessionController c) {
    final r = widget.duel!;
    final g = app.progress!.game;
    final pct = c.summary.answered == 0
        ? 0
        : (100 * c.summary.correct / c.summary.answered).round();
    final first = !g.banners.contains(r.key);
    g.banners.add(r.key);
    if (first) g.rescued.add(r.key);
    g.duelBest[r.key] = math.max(g.duelBest[r.key] ?? 0, pct);
    // Her ilk kurtarış sıradaki eşyayı açar (bkz. items.dart)
    _duelItem = first && g.banners.length <= items.length
        ? items[g.banners.length - 1]
        : null;
    if (first) {
      g.addSupply(Kingdom.of(r.subject).material, 5);
      g.addLetter(guardianLetter(
          r.guardian, r.key, _heroName(app), dayKey(app.clock())));
    }
    _duelGift = pct >= 80;
    if (_duelGift) app.progress!.nuts += 10;
    final k = Kingdom.of(r.subject);
    g.addPage(
        dayKey(app.clock()),
        '${_heroName(app)}, ${locative(k.name)} ${regionTitle(k, r.index)} '
        'bölgesine sancağını dikti. ${r.guardian.name} sisten kurtuldu.');
  }

  String _heroName(AppState app) =>
      app.progress?.game.hero?.name ?? app.active?.nickname ?? 'Kahraman';

  void _writeNotebook(AppState app, SessionController c) {
    final k = Kingdom.of(widget.subject);
    final titles = [
      for (final code in c.summary.newOutcomes) _lessonTitles[code] ?? code
    ];
    final String line;
    if (titles.isNotEmpty) {
      line = '${_heroName(app)} bugün ${locative(k.name)} '
          '"${titles.join('", "')}" konusunu öğrendi.';
    } else if (c.summary.answered > 0) {
      line = '${_heroName(app)} bugün ${locative(k.name)} '
          '${c.summary.correct} soruyu doğru çözdü, sisi biraz daha dağıttı.';
    } else {
      return;
    }
    _notebookLine = line;
    app.progress!.game.addPage(dayKey(app.clock()), line);
  }

  void _summaryDone() {
    if (_c!.summary.streakGrew) {
      setState(() => _phase = _Phase.streak);
      _say(
          '${AppScope.read(context).progress!.streakDays} gündür birlikteyiz!');
    } else {
      _end();
    }
  }

  void _end() {
    final app = AppScope.read(context);
    if (app.overDailyLimit) {
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
          builder: (_) => const SystemScreen(kind: SystemKind.timeUp)));
    } else {
      Navigator.of(context).pop();
    }
  }

  /// Yarıda bırakılırsa çözülenler kaydedilir.
  Future<void> _leave() async {
    final c = _c;
    final app = AppScope.read(context);
    if (c != null &&
        _phase == _Phase.run &&
        (c.summary.answered > 0 || c.summary.activities > 0)) {
      c.finish();
    }
    await app.saveProgress();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmExit() async {
    if (_phase == _Phase.summary) {
      _summaryDone();
      return;
    }
    if (_phase == _Phase.streak ||
        _phase == _Phase.duelWin ||
        _phase == _Phase.finaleWin) {
      _end();
      return;
    }
    if (_phase != _Phase.run) {
      await _leave();
      return;
    }
    hideDkToast();
    final app = AppScope.read(context);
    await app.saveProgress();
    if (!mounted) return;
    final leave = await showDkSheet<bool>(
      context,
      builder: (ctx) => Column(
        key: const Key('exit-sheet'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(children: [
            Mascot(mood: MascotMood.think, size: 84),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                  'Şimdiye kadar yaptıkların kaydedildi. Çıkmak istiyor musun?',
                  style: TextStyle(
                      fontSize: 24,
                      height: 30 / 24,
                      fontWeight: FontWeight.w900,
                      color: K.ink)),
            ),
          ]),
          const SizedBox(height: 14),
          ChunkyButton(
              key: const Key('keep-going'),
              label: 'Devam et',
              onPressed: () => Navigator.pop(ctx, false)),
          TextBtn(
              key: const Key('leave'),
              label: 'Çık',
              onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (leave == true) await _leave();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    final Widget body;
    switch (_phase) {
      case _Phase.loading:
        body = const SizedBox.shrink();
      case _Phase.error:
        return const SystemScreen(kind: SystemKind.error);
      case _Phase.empty:
        return SystemScreen(
          kind: SystemKind.nothing,
          message: widget.reviewOnly || widget.extraPractice
              ? 'Şu an tekrar edecek bir şey yok. Yarın yine bak!'
              : 'Bu ders için içerik hazırlanıyor. Şimdilik başka bir derse ne dersin?',
        );
      case _Phase.summary:
        body = _SummaryView(
          controller: c!,
          lessonTitles: _lessonTitles,
          notebookLine: _notebookLine,
          onDone: _summaryDone,
          onSay: _say,
        );
      case _Phase.duelWin:
        body = DuelWinView(
          region: widget.duel!,
          gift: _duelGift,
          newItem: _duelItem,
          onDone: _end,
          onSay: _say,
        );
      case _Phase.finaleWin:
        body = FinaleWinView(
          subject: widget.subject,
          legend: AppScope.read(context).finaleDone,
          onDone: _end,
          onSay: _say,
        );
      case _Phase.streak:
        body = _StreakView(onDone: _end, onSay: _say);
      case _Phase.run:
        final step = c!.current;
        body = Column(
          children: [
            _TopBar(
              progress: c.progressRatio,
              onClose: _confirmExit,
              color: Kingdom.of(widget.subject).color,
            ),
            if (widget.duel != null)
              DuelHeader(
                guardian: widget.duel!.guardian,
                pieces: _duelPieces,
                fallen: math.min(_duelHits, _duelPieces),
                kingdom: Kingdom.of(widget.subject),
              ),
            if (widget.finale)
              KarabulutHeader(
                pieces: _duelPieces,
                fallen: math.min(_duelHits, _duelPieces),
                kingdom: Kingdom.of(widget.subject),
              ),
            Expanded(
              child: step.kind == StepKind.lesson
                  ? _LessonView(
                      key: ValueKey('L${c.index}'),
                      lesson: step.lesson!,
                      onSay: _say,
                      onDone: () => _advance(c.completeLesson),
                    )
                  : step.question!.activity
                      ? _ActivityView(
                          key: ValueKey('A${c.index}'),
                          question: step.question!,
                          onSay: _say,
                          onDone: () {
                            c.completeActivity();
                            AppScope.read(context).saveProgress();
                          },
                          onNext: () => _advance(c.next),
                          onSkip: () => _advance(c.skip),
                        )
                      : _QuestionView(
                          key: ValueKey('Q${c.index}'),
                          step: step,
                          scene: widget.duel == null && !widget.finale,
                          phaseLabel: widget.finale
                              ? 'YIL SONU'
                              : widget.extraPractice
                                  ? 'EKSTRA TEKRAR'
                                  : switch (step.phase) {
                                      StepPhase.warmup => 'ISINMA',
                                      StepPhase.practice ||
                                      StepPhase.newTopic =>
                                        'YENİ KONU',
                                      StepPhase.review => 'TEKRAR',
                                      StepPhase.retry => 'BİR KEZ DAHA',
                                    },
                          praise: _praise,
                          onSay: _say,
                          onAnswer: (i, elapsed, hint) {
                            final r =
                                c.answer(i, elapsed: elapsed, usedHint: hint);
                            _praise = (_praise + 1) % 3;
                            if (r.correct &&
                                (widget.duel != null || widget.finale)) {
                              setState(() => _duelHits++);
                            }
                            AppScope.read(context).saveProgress();
                            return r;
                          },
                          onNext: (wasWrong) => _advance(c.next,
                              retryNote:
                                  wasWrong && step.phase != StepPhase.retry),
                        ),
            ),
          ],
        );
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        backgroundColor: K.bg,
        // kâğıt dokusu: çok hafif lif gürültüsü (Claude Design › doku)
        body: Stack(children: [
          SafeArea(child: ChildTextScale(child: body)),
          const Positioned.fill(child: PaperGrain()),
        ]),
      ),
    );
  }
}

/// C1 Oturum üstü (Claude Design 12): haritaya dönüş mührü ve sis çubuğu.
class _TopBar extends StatelessWidget {
  const _TopBar(
      {required this.progress, required this.onClose, this.color = K.ahsap});
  final double progress;
  final VoidCallback onClose;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 68,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Row(children: [
            Pressable(
              key: const Key('session-close'),
              onTap: onClose,
              label: 'Ara ver, haritaya dön',
              excludeChildSemantics: true,
              focusRadius: 28,
              builder: (context, down) => SizedBox(
                width: 56,
                height: 56,
                child: CustomPaint(
                  painter: HandPainter(HandStyle.muhur
                      .copyWith(fill: down ? K.kagit2 : K.kagit3)),
                  child: const Center(child: IkonView(Ikon.harita, size: 28)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: DkProgressBar(value: progress, color: color)),
          ]),
        ),
      );
}

/// Üst satır: kısa etiket + (ipucu) + dinle.
class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.label, required this.trailing});
  final Widget label;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Row(children: [
          Expanded(child: label),
          for (final w in trailing) ...[const SizedBox(width: 10), w],
        ]),
      );
}

/// Alt düğme alanı (üstte 2 px çizgi).
class _Footer extends StatelessWidget {
  const _Footer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
        child: child,
      );
}

// ---------------------------------------------------------------- C2 Anlatım

class _LessonView extends StatefulWidget {
  const _LessonView(
      {super.key,
      required this.lesson,
      required this.onSay,
      required this.onDone});
  final Lesson lesson;
  final void Function(String, {bool slow}) onSay;
  final VoidCallback onDone;

  @override
  State<_LessonView> createState() => _LessonViewState();
}

class _LessonViewState extends State<_LessonView> {
  int _page = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onSay(widget.lesson.pages.first.spoken));
  }

  void _go(int p) {
    setState(() => _page = p);
    widget.onSay(widget.lesson.pages[p].spoken);
  }

  @override
  Widget build(BuildContext context) {
    final pages = widget.lesson.pages;
    final page = pages[_page];
    final last = _page == pages.length - 1;
    // Claude Design 17: konu kitapçığı. Sayfa noktaları, cetvel çerçeveli
    // kâğıt, altta geri/ileri.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 2, 20, 6),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('KONU ANLATIMI',
                      style: TextStyle(
                          fontFamily: K.display,
                          fontSize: 13,
                          letterSpacing: .8,
                          fontWeight: FontWeight.w700,
                          color: K.kokKoyu)),
                  EmojiText(widget.lesson.title,
                      style: const TextStyle(
                          fontFamily: K.display,
                          fontSize: 20,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                          color: K.murekkep)),
                ],
              ),
            ),
            ListenSplit(
                onListen: (slow) => widget.onSay(page.spoken, slow: slow)),
          ]),
        ),
        Semantics(
          label: 'Sayfa ${_page + 1} / ${pages.length}',
          child: ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pages.length; i++)
                  Container(
                    width: i == _page ? 30 : 12,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: i <= _page ? K.safran : K.kagit3,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: K.murekkep, width: 2),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: HandBox(
              style: HandStyle.kart,
              child: CustomPaint(
                foregroundPainter: _RulerFrame(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (page.visual != null) ...[
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 150),
                          child: Center(child: VisualView(page.visual!)),
                        ),
                        const SizedBox(height: 16),
                      ],
                      EmojiText(page.text,
                          style: const TextStyle(
                              fontSize: 21, height: 1.4, color: K.murekkep)),
                      if (last) ...[
                        const SizedBox(height: 14),
                        Row(children: [
                          const Mascot(mood: MascotMood.teach, size: 64),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Şimdi sen dene!',
                                style: G.hand
                                    .copyWith(fontSize: 19, color: K.lacivert)),
                          ),
                        ]),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _Footer(
          child: Row(children: [
            if (_page > 0) ...[
              Pressable(
                key: const Key('lesson-back'),
                label: 'Geri',
                excludeChildSemantics: true,
                onTap: () => _go(_page - 1),
                builder: (context, down) => SizedBox(
                  width: 60,
                  height: 60,
                  child: CustomPaint(
                    painter: HandPainter(HandStyle.muhur
                        .copyWith(fill: down ? K.kagit2 : K.kagit3)),
                    child: const Center(child: IkonView(Ikon.geri, size: 28)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ChunkyButton(
                key: const Key('lesson-next'),
                label: last ? 'Hadi deneyelim!' : 'İleri',
                kind: last ? BtnKind.good : BtnKind.primary,
                onPressed: last ? widget.onDone : () => _go(_page + 1),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

/// Kitapçık sayfasının cetvel çerçevesi: mürekkep, safran, mürekkep ve
/// lacivert iç çizgiler.
class _RulerFrame extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    void line(double inset, double w, Color c) => canvas.drawRect(
        (Offset.zero & size).deflate(inset),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w
          ..color = c);
    line(7, 2, K.murekkep);
    line(9.5, 3, K.safran);
    line(11.8, 1.5, K.murekkep);
    line(16, 1.5, K.lacivert);
  }

  @override
  bool shouldRepaint(_RulerFrame old) => false;
}

// ----------------------------------------------------------- C3–C7 Soru

enum _Opt { idle, selected, right, chosenWrong, dim }

class _QuestionView extends StatefulWidget {
  const _QuestionView({
    super.key,
    required this.step,
    required this.phaseLabel,
    required this.praise,
    required this.onSay,
    required this.onAnswer,
    required this.onNext,
    this.scene = true,
  });

  final SessionStep step;
  final String phaseLabel;

  /// Kahraman ve Anka sahnesi (düelloda sahne üstte, burada gösterilmez).
  final bool scene;
  final int praise;
  final void Function(String, {bool slow}) onSay;
  final AnswerResult Function(int index, Duration elapsed, bool usedHint)
      onAnswer;
  final void Function(bool wasWrong) onNext;

  @override
  State<_QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<_QuestionView> {
  final _watch = Stopwatch()..start();
  int? _selected;
  AnswerResult? _result;
  bool _hint = false;
  bool _busy = false;

  /// Çoktan seçmeli dışı türlerde: cevap hazırsa doğru mu (hazır değilse null).
  bool? _ready;

  Question get q => widget.step.question!;
  bool get _choice => q.kind == QKind.choice;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onSay(q.spoken));
  }

  void _check() {
    final i = _choice
        ? _selected
        : _ready == null
            ? null
            : (_ready! ? q.answerIndex : -1);
    if (i == null || _result != null || _busy) return;
    _busy = true; // çift dokunma koruması
    _watch.stop();
    final r = widget.onAnswer(i, _watch.elapsed, _hint);
    setState(() => _result = r);
    if (r.correct) {
      widget.onSay(_okTitles[widget.praise]);
    } else {
      // Parça parça: her parçanın kayıtlı sesi varsa doğal sesle okunur
      AppScope.read(context)
          .sayAll(['Doğrusu:', q.answerText, q.explainFor(i) ?? '']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    final hasPassage = q.prompt.contains('\n\n');
    final passage =
        hasPassage ? q.prompt.substring(0, q.prompt.lastIndexOf('\n\n')) : null;
    final prompt = hasPassage
        ? q.prompt.substring(q.prompt.lastIndexOf('\n\n') + 2)
        : q.prompt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StepHeader(
                  label: Text(widget.phaseLabel, style: T.kicker),
                  trailing: [
                    if (q.hint != null && r == null && !_hint)
                      _HintButton(onTap: () {
                        setState(() => _hint = true);
                        widget.onSay(q.hint!);
                      }),
                    ListenSplit(
                        onListen: (slow) => widget.onSay(q.spoken, slow: slow)),
                  ],
                ),
                const SizedBox(height: 16),
                if (passage != null) ...[
                  _Passage(text: passage),
                  const SizedBox(height: 16),
                ],
                EmojiText(prompt,
                    style: T.question.copyWith(
                        fontFamily: K.font,
                        fontWeight: FontWeight.w700,
                        height: 1.28,
                        fontSize: hasPassage ? 22 : 27)),
                if (_hint && r == null) ...[
                  const SizedBox(height: 16),
                  _HintBox(text: q.hint!),
                ],
                if (q.visual != null) ...[
                  const SizedBox(height: 16),
                  VisualView(q.visual!),
                ],
                const SizedBox(height: 16),
                if (widget.scene && (q.visual != null || passage == null)) ...[
                  const SizedBox(height: 4),
                  _Scene(result: r),
                ],
                const SizedBox(height: 14),
                if (!_choice)
                  KindView(
                    key: ValueKey('kind-${q.prompt}'),
                    question: q,
                    locked: r != null,
                    onChanged: (v) => setState(() => _ready = v),
                  )
                else
                  Semantics(
                    container: true,
                    label: 'Seçenekler',
                    child: LayoutBuilder(builder: (context, box) {
                      _Opt stateOf(int i) => r == null
                          ? (i == _selected ? _Opt.selected : _Opt.idle)
                          : i == q.answerIndex
                              ? _Opt.right
                              : i == _selected
                                  ? _Opt.chosenWrong
                                  : _Opt.dim;
                      Widget opt(int i) => _OptionCard(
                            key: Key('option-$i'),
                            label: q.options[i],
                            state: stateOf(i),
                            onTap: r == null
                                ? () {
                                    setState(() => _selected = i);
                                    // Okumayı yeni öğrenenler için şık okunur
                                    widget.onSay(q.options[i]);
                                  }
                                : null,
                          );
                      // Kısa seçenekler (sayı, hece) iki sütunda taş levha
                      final grid = q.options.length >= 2 &&
                          q.options.every((o) => o.characters.length <= 4);
                      if (grid) {
                        final w = (box.maxWidth - 14) / 2;
                        return Wrap(
                          spacing: 14,
                          runSpacing: 18,
                          children: [
                            for (var i = 0; i < q.options.length; i++)
                              SizedBox(width: w, child: opt(i)),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < q.options.length; i++) ...[
                            if (i > 0) const SizedBox(height: 16),
                            opt(i),
                          ],
                        ],
                      );
                    }),
                  ),
              ],
            ),
          ),
        ),
        if (r == null)
          _Footer(
            child: ChunkyButton(
              key: const Key('check'),
              label: 'Kontrol et',
              kind: BtnKind.good,
              onPressed: (_choice ? _selected != null : _ready != null)
                  ? _check
                  : null,
            ),
          )
        else
          FeedbackBand(
            correct: r.correct,
            title: r.correct
                ? _okTitles[widget.praise]
                : 'Doğrusu: ${q.answerText}',
            body: r.correct
                ? _okBodies[widget.praise]
                : q.explainFor(_selected ?? -1),
            onNext: () => widget.onNext(!r.correct),
          ),
      ],
    );
  }
}

/// Sorunun sahnesi: solda kahraman, sağda Anka (Claude Design 12).
class _Scene extends StatelessWidget {
  const _Scene({required this.result});
  final AnswerResult? result;

  @override
  Widget build(BuildContext context) {
    final hero = AppScope.of(context).progress?.game.hero;
    final r = result;
    return SizedBox(
      height: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (hero != null)
            HeroFigure(
                look: hero,
                size: 80,
                showCompanion: false,
                cheer: r?.correct == true),
          const Spacer(),
          Mascot(
            size: 92,
            mood: r == null
                ? MascotMood.normal
                : r.correct
                    ? MascotMood.celebrate
                    : MascotMood.teach,
          ),
        ],
      ),
    );
  }
}

class _HintButton extends StatelessWidget {
  const _HintButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
        key: const Key('hint'),
        onTap: onTap,
        label: 'İpucu',
        excludeChildSemantics: true,
        focusRadius: 32,
        builder: (context, down) => Padding(
          padding: EdgeInsets.only(top: down ? 4 : 0, bottom: down ? 0 : 4),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: K.rewardChip,
              borderRadius: BorderRadius.circular(999),
              boxShadow: down
                  ? null
                  : const [
                      BoxShadow(color: K.hintShadow, offset: Offset(0, 4))
                    ],
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              DkIcon(DkIcons.bulb, size: 24, color: K.hintInk),
              SizedBox(width: 6),
              Text('İPUCU',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .6,
                      color: K.hintInk)),
            ]),
          ),
        ),
      );
}

class _HintBox extends StatelessWidget {
  const _HintBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 250),
        builder: (context, v, child) => Opacity(opacity: v, child: child),
        child: DkCard(
          key: const Key('hint-box'),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          color: K.rewardBg,
          borderColor: K.rewardLine,
          child: Row(children: [
            const Mascot(mood: MascotMood.think, size: 50),
            const SizedBox(width: 10),
            Expanded(
              child: EmojiText(text,
                  style: const TextStyle(
                      fontSize: 17,
                      height: 24 / 17,
                      fontWeight: FontWeight.w700,
                      color: K.rewardInk)),
            ),
          ]),
        ),
      );
}

class _Passage extends StatelessWidget {
  const _Passage({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => DkCard(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: 200 * MediaQuery.textScalerOf(context).scale(1)),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  DkIcon(DkIcons.book, size: 18, color: K.againStrong),
                  SizedBox(width: 6),
                  Text('OKU',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .6,
                          color: K.againStrong)),
                ]),
                const SizedBox(height: 8),
                EmojiText(text,
                    style: const TextStyle(
                        fontSize: 19, height: 27 / 19, color: K.ink)),
              ],
            ),
          ),
        ),
      );
}

class _OptionCard extends StatelessWidget {
  const _OptionCard(
      {super.key,
      required this.label,
      required this.state,
      required this.onTap});
  final String label;
  final _Opt state;
  final VoidCallback? onTap;

  /// Taş levha (Claude Design › Cevap levhası): doğruda zümrüt kenar ve
  /// mühür, yanlışta sis grisi ve çizgili doku, kırmızı yok.
  static HandStyle styleFor(_Opt s) => switch (s) {
        _Opt.idle || _Opt.dim => HandStyle.levha,
        _Opt.selected =>
          HandStyle.levha.copyWith(border: K.lacivert, borderWidth: 4.5),
        _Opt.right => HandStyle.levha.copyWith(
            fill: K.goodBg,
            texture: HandFill.duz,
            border: K.zumrutKoyu,
            borderWidth: 5,
            shadows: const [(4, Color(0xFF9FBFA8)), (7, K.zumrutKoyu)]),
        _Opt.chosenWrong => HandStyle.levha.copyWith(
            fill: K.sis2,
            texture: HandFill.sisli,
            border: K.murekkep2,
            shadows: const [(4, K.sis), (7, K.murekkep2)]),
      };

  @override
  Widget build(BuildContext context) {
    final short = label.characters.length <= 3;
    final wrong = state == _Opt.chosenWrong;
    Widget face(bool down) => HandBox(
          style: styleFor(state),
          pressed: down || state == _Opt.selected,
          constraints: const BoxConstraints(minHeight: 84),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: Center(
            heightFactor: 1,
            child: EmojiText(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: K.display,
                fontSize: short ? 40 : 22,
                height: 1.15,
                fontWeight: FontWeight.w700,
                color: wrong ? K.murekkep2 : K.ink,
              ),
            ),
          ),
        );
    Widget card(bool down) => Stack(
          fit: StackFit.passthrough,
          clipBehavior: Clip.none,
          children: [
            face(down),
            if (state == _Opt.right || wrong)
              Positioned(
                right: -6,
                top: -10,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CustomPaint(
                    painter: HandPainter(HandStyle.muhur.copyWith(
                        fill: state == _Opt.right ? K.zumrutKoyu : K.sis)),
                    child: Center(
                      child: state == _Opt.right
                          ? const IkonView(Ikon.tik, size: 22, light: true)
                          : const DkIcon(DkIcons.again,
                              size: 18, color: K.murekkep, stroke: 3),
                    ),
                  ),
                ),
              ),
          ],
        );
    final motion = !reduceMotion(context);
    return Pressable(
      onTap: onTap,
      selected: state == _Opt.selected,
      label: switch (state) {
        _Opt.right => '$label, doğru cevap',
        _Opt.chosenWrong => '$label, seçtiğin',
        _ => label,
      },
      excludeChildSemantics: true,
      focusRadius: K.rMd,
      builder: (context, down) {
        var c = card(down);
        if (state == _Opt.dim) c = Opacity(opacity: .5, child: c);
        if (state == _Opt.right && motion) {
          c = TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            builder: (context, v, child) => Transform.scale(
                scale: 1 + .06 * math.sin(v * math.pi), child: child),
            child: c,
          );
        }
        if (wrong && motion) {
          // salla: .45 sn, sönerek
          c = TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 450),
            builder: (context, v, child) => Transform.translate(
                offset: Offset(7 * (1 - v) * math.sin(v * math.pi * 4), 0),
                child: child),
            child: c,
          );
        }
        return c;
      },
    );
  }
}

/// C7 Geri bildirim bandı: alttan kayar. Doğru: yeşil, kutlayan Anka.
/// Tekrar: mavi, düşünen Anka, "Doğrusu: …" ve ANLADIM.
class FeedbackBand extends StatelessWidget {
  const FeedbackBand({
    super.key,
    required this.correct,
    required this.title,
    required this.onNext,
    this.body,
  });

  final bool correct;
  final String title;
  final String? body;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final fg = correct ? K.zumrutKoyu : K.lacivert;
    // Claude Design 13/14: yırtık kenarlı kâğıt; doğruda kutlayan, yanlışta
    // anlatan Anka. Kırmızı yok.
    final band = Stack(
      key: Key(correct ? 'band-ok' : 'band-again'),
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: -12,
          height: 24,
          child: CustomPaint(painter: _TornEdgePainter()),
        ),
        Container(
          color: K.kagit3,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                liveRegion: true,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Mascot(
                          mood:
                              correct ? MascotMood.celebrate : MascotMood.teach,
                          size: 68),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            EmojiText(title,
                                style: TextStyle(
                                    fontFamily: K.display,
                                    fontSize: 25,
                                    height: 30 / 25,
                                    fontWeight: FontWeight.w800,
                                    color: fg)),
                            if (body != null && body!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              EmojiText(body!,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      height: 1.38,
                                      color: K.murekkep)),
                            ],
                          ],
                        ),
                      ),
                    ]),
              ),
              const SizedBox(height: 14),
              ChunkyButton(
                key: const Key('next'),
                label: correct ? 'Devam' : 'Anladım',
                kind: correct ? BtnKind.good : BtnKind.primary,
                onPressed: onNext,
              ),
            ],
          ),
        ),
      ],
    );
    if (reduceMotion(context)) return band;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      builder: (context, v, child) =>
          FractionalTranslation(translation: Offset(0, v), child: child),
      child: band,
    );
  }
}

/// Kâğıdın yırtık üst kenarı.
class _TornEdgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const pts = [
      12,
      8,
      14,
      7,
      12,
      6,
      11,
      7,
      12,
      6,
      12,
      6,
      11,
      7,
      13,
      8,
      12,
      6,
      11,
      7,
      13,
      8,
      12,
      6,
      11,
      7,
      13,
      8,
      12,
      6,
      11,
      7,
      13,
      9
    ];
    final w = size.width;
    final step = w / (pts.length - 1);
    final p = Path()..moveTo(0, size.height);
    for (var i = 0; i < pts.length; i++) {
      p.lineTo(i * step, pts[i].toDouble());
    }
    p
      ..lineTo(w, size.height)
      ..close();
    canvas.drawPath(p, Paint()..color = K.kagit3);
    final edge = Path()..moveTo(0, pts.first.toDouble());
    for (var i = 1; i < pts.length; i++) {
      edge.lineTo(i * step, pts[i].toDouble());
    }
    canvas.drawPath(
        edge,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeJoin = StrokeJoin.round
          ..color = K.murekkep);
  }

  @override
  bool shouldRepaint(_TornEdgePainter old) => false;
}

// --------------------------------------------------------- C8 Etkinlik

class _ActivityView extends StatefulWidget {
  const _ActivityView({
    super.key,
    required this.question,
    required this.onSay,
    required this.onDone,
    required this.onNext,
    required this.onSkip,
  });

  final Question question;
  final void Function(String, {bool slow}) onSay;
  final VoidCallback onDone;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<_ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<_ActivityView> {
  bool _done = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.onSay(widget.question.spoken));
  }

  /// Etkinlik metni birden çok cümleyse adımlara bölünür.
  List<String> get _steps {
    final parts = widget.question.prompt
        .split(RegExp(r'(?<=[.!?])\s+(?=[A-ZÇĞİÖŞÜ0-9])'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.length >= 3 ? parts.sublist(1) : const [];
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final steps = _steps;
    final title = steps.isEmpty
        ? q.prompt
        : q.prompt
            .split(RegExp(r'(?<=[.!?])\s+(?=[A-ZÇĞİÖŞÜ0-9])'))
            .first
            .trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            children: [
              _StepHeader(
                label: const Align(
                  alignment: Alignment.centerLeft,
                  child: Pill('AİLENLE YAP',
                      bg: K.family,
                      fg: K.familyInk,
                      fontSize: 14,
                      icon: DkIcons.family,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                ),
                trailing: [
                  ListenButton(onListen: () => widget.onSay(q.spoken)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: q.visual == null ? 140 : null,
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: K.familyBg,
                    borderRadius: BorderRadius.circular(K.rLg)),
                child: q.visual == null
                    ? const DkIcon(DkIcons.family,
                        size: 80, color: K.familyIcon, stroke: 1.6)
                    : VisualView(q.visual!),
              ),
              const SizedBox(height: 16),
              EmojiText(title,
                  style: const TextStyle(
                      fontSize: 24,
                      height: 30 / 24,
                      fontWeight: FontWeight.w800,
                      color: K.ink)),
              for (var i = 0; i < steps.length; i++) ...[
                const SizedBox(height: 16),
                DkCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: K.family, shape: BoxShape.circle),
                      child: Text('${i + 1}',
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: K.familyInk)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: EmojiText(steps[i],
                          style: const TextStyle(
                              fontSize: 18,
                              height: 24 / 18,
                              fontWeight: FontWeight.w700,
                              color: K.ink)),
                    ),
                  ]),
                ),
              ],
              const SizedBox(height: 16),
              const Text('Bu kart puanlanmaz.', style: T.help),
            ],
          ),
        ),
        if (!_done)
          _Footer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ChunkyButton(
                  key: const Key('activity-done'),
                  label: 'Yaptık',
                  kind: BtnKind.good,
                  onPressed: () {
                    widget.onDone();
                    setState(() => _done = true);
                    widget.onSay('Harika! Birlikte yaptınız.');
                  },
                ),
                TextBtn(
                  key: const Key('activity-skip'),
                  label: 'Şimdi değil',
                  onPressed: widget.onSkip,
                ),
              ],
            ),
          )
        else
          FeedbackBand(
              correct: true,
              title: 'Harika! Birlikte yaptınız.',
              onNext: widget.onNext),
      ],
    );
  }
}

// ------------------------------------------------------------ C11 Özet

class _SummaryView extends StatelessWidget {
  const _SummaryView({
    required this.controller,
    required this.lessonTitles,
    required this.onDone,
    required this.onSay,
    this.notebookLine,
  });
  final SessionController controller;
  final Map<String, String> lessonTitles;
  final String? notebookLine;
  final VoidCallback onDone;
  final void Function(String, {bool slow}) onSay;

  @override
  Widget build(BuildContext context) {
    final s = controller.summary;
    final app = AppScope.of(context);
    final streak = app.progress?.streakDays ?? 0;
    final hero = app.progress?.game.hero;
    final supply = Kingdom.of(controller.subject).material;
    final tiles = [
      (Ikon.tik, '${s.correct}', 'doğru cevap'),
      (Ikon.isik, '+${s.nutsEarned}', 'ışık'),
      (ikonOf(supply), '+${s.suppliesEarned}', supply.label.toLowerCase()),
      (Ikon.mesale, '$streak gün', 'meşalen yanıyor'),
    ];
    final newTitles = [
      for (final code in s.newOutcomes) lessonTitles[code] ?? code,
    ];
    // Claude Design 22: kemerli zafer sahnesi, el çizimi ödüller, defter notu
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 64,
            child: Align(
              alignment: Alignment.centerRight,
              child: ListenButton(onListen: () => onSay('Bugün çok çalıştın!')),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Pop(
                    child: SizedBox(
                      height: 220,
                      child: HandBox(
                        style: const HandStyle(
                            radii:
                                HandRadii([120, 120, 14, 14], [96, 96, 14, 14]),
                            fill: K.kagit3),
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.elliptical(108, 86)),
                          child: ColoredBox(
                            color: const Color(0xFFE3E6D3),
                            child: Stack(children: [
                              const Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Kilim.zumrut()),
                              if (hero != null)
                                Positioned(
                                  left: 24,
                                  bottom: 10,
                                  child: HeroFigure(
                                      look: hero, size: 150, cheer: true),
                                ),
                              const Positioned(
                                right: 12,
                                bottom: 14,
                                child: Mascot(
                                    mood: MascotMood.celebrate,
                                    size: 110,
                                    label: 'Anka kutluyor'),
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Bugün çok çalıştın!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: K.display,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: K.lacivert)),
                  const SizedBox(height: 14),
                  LayoutBuilder(builder: (context, box) {
                    final w = (box.maxWidth - 10) / 2;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final t in tiles)
                          SizedBox(
                            width: w,
                            child: DkCard(
                              padding: const EdgeInsets.all(12),
                              child: Row(children: [
                                IkonView(t.$1, size: 34),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(t.$2,
                                          style: const TextStyle(
                                              fontFamily: K.display,
                                              fontSize: 24,
                                              height: 1.1,
                                              fontWeight: FontWeight.w800,
                                              color: K.murekkep)),
                                      Text(t.$3,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: K.murekkep2)),
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                          ),
                      ],
                    );
                  }),
                  if (newTitles.isNotEmpty || notebookLine != null) ...[
                    const SizedBox(height: 14),
                    Transform.rotate(
                      angle: -.015,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        decoration: BoxDecoration(
                          color: K.kagit3,
                          border: Border.all(color: K.murekkep, width: 2),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x592B2320), offset: Offset(3, 4))
                          ],
                        ),
                        child: Row(children: [
                          const IkonView(Ikon.defter, size: 34),
                          const SizedBox(width: 10),
                          Expanded(
                            child: EmojiText(
                                notebookLine ??
                                    'Yeni konu: ${newTitles.join(', ')}',
                                style: G.hand
                                    .copyWith(fontSize: 17, color: K.murekkep)),
                          ),
                        ]),
                      ),
                    ),
                  ],
                  if (s.retried > 0) ...[
                    const SizedBox(height: 12),
                    const Text('Zorlandığın soruları yakında yine soracağım.',
                        style: T.help),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ChunkyButton(
              key: const Key('summary-done'),
              label: 'Tamam',
              kind: BtnKind.kok,
              onPressed: onDone),
        ],
      ),
    );
  }
}

/// Bir kez büyüyüp küçülen giriş (hareket azaltmada yok).
class _Pop extends StatelessWidget {
  const _Pop({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      builder: (context, v, c) => Transform.scale(
          alignment: Alignment.bottomLeft,
          scale: 1 + .06 * math.sin(v * math.pi),
          child: c),
      child: child,
    );
  }
}

// ------------------------------------------------------------ C12 Seri

class _StreakView extends StatelessWidget {
  const _StreakView({required this.onDone, required this.onSay});
  final VoidCallback onDone;
  final void Function(String, {bool slow}) onSay;

  @override
  Widget build(BuildContext context) {
    final p = AppScope.of(context).progress!;
    final rest = math.max(0, 2 - p.restDaysUsedThisWeek);
    final title = '${p.streakDays} gündür birlikteyiz!';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 72,
            child: Align(
              alignment: Alignment.centerRight,
              child: ListenButton(onListen: () => onSay(title)),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      image: true,
                      label: '${math.min(p.streakDays, 6)} yapraklı bir dal',
                      child: AspectRatio(
                        aspectRatio: 350 / 210,
                        child: _Branch(
                            leaves: math.min(p.streakDays, 6),
                            animate: !reduceMotion(context)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text('DALINA YENİ BİR YAPRAK ÇIKTI', style: T.kicker),
                    const SizedBox(height: 18),
                    Text(title, style: T.hero),
                    const SizedBox(height: 18),
                    Text(
                        rest > 0
                            ? 'Bu hafta $rest dinlenme günün var. Dinlenince yaprakların solmaz.'
                            : 'Bu haftanın dinlenme günlerini kullandın. Yarın görüşmek üzere!',
                        style: T.body.copyWith(color: K.ink2)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ChunkyButton(
              key: const Key('streak-done'), label: 'Tamam', onPressed: onDone),
        ],
      ),
    );
  }
}

class _Branch extends StatelessWidget {
  const _Branch({required this.leaves, required this.animate});
  final int leaves;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    if (!animate) {
      return CustomPaint(painter: _BranchPainter(leaves, 1));
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1100),
      builder: (context, v, _) {
        // 200 ms gecikme, sonra yaylı büyüme
        final t = ((v * 1100 - 200) / 900).clamp(0.0, 1.0);
        return CustomPaint(
            painter: _BranchPainter(leaves, Curves.easeOutBack.transform(t)));
      },
    );
  }
}

class _BranchPainter extends CustomPainter {
  _BranchPainter(this.leaves, this.grow);
  final int leaves;
  final double grow;

  static const _spots = [
    (52.0, 142.0, -120.0),
    (92.0, 138.0, 70.0),
    (140.0, 124.0, -110.0),
    (190.0, 108.0, 65.0),
    (240.0, 90.0, -100.0),
    (292.0, 70.0, 60.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 350, size.height / 210);
    final branch = Path()
      ..moveTo(8, 150)
      ..cubicTo(90, 140, 150, 120, 220, 96)
      ..cubicTo(290, 72, 320, 60, 344, 40);
    canvas.drawPath(
        branch,
        Paint()
          ..color = K.branch
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round);
    final n = leaves.clamp(1, 6);
    for (var i = 0; i < n; i++) {
      final isNew = i == n - 1;
      final (x, y, deg) = _spots[i];
      final len = isNew ? 54.0 : 44.0;
      final w = isNew ? 20.0 : 16.0;
      final leaf = Path()
        ..moveTo(0, 0)
        ..cubicTo(len * .23, -w, len * .77, -w, len, 0)
        ..cubicTo(len * .77, w, len * .23, w, 0, 0)
        ..close();
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(deg * math.pi / 180);
      if (isNew) canvas.scale(grow.clamp(0.0, 1.2));
      canvas.drawPath(
          leaf,
          Paint()
            ..color = isNew
                ? const Color(0xFF7BCB8F)
                : (i.isEven ? K.good : K.goodShadow));
      if (isNew) {
        canvas.drawPath(
            leaf,
            Paint()
              ..color = K.goodShadow
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BranchPainter old) =>
      old.leaves != leaves || old.grow != grow;
}
