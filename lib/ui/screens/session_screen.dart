import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/session_controller.dart';
import '../../app/speaker.dart';
import '../../data/models.dart';
import '../theme.dart';
import '../widgets/dk_icon.dart';
import '../widgets/emoji_text.dart';
import '../widgets/kit.dart';
import '../widgets/mascot.dart';
import '../widgets/visual_view.dart';
import 'system_screens.dart';

const _okTitles = ['Harika!', 'Tam isabet!', 'Dikkatle düşündün!'];
const _okBodies = ['Dikkatle çalıştın.', 'Adım adım düşündün.', 'Güzel çalıştın.'];

enum _Phase { loading, empty, error, run, summary, streak }

/// Çalışma oturumu (C1–C12): konu anlatımı, sorular, etkinlik, özet, seri.
class SessionScreen extends StatefulWidget {
  const SessionScreen({
    super.key,
    required this.subject,
    this.focusOutcome,
    this.reviewOnly = false,
    this.extraPractice = false,
  });

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
      final c = await SessionController.build(
        repo: app.content,
        subject: widget.subject,
        grade: app.active!.grade,
        progress: app.progress!,
        clock: app.clock,
        focusOutcome: widget.focusOutcome,
        reviewOnly: widget.reviewOnly,
        extraPractice: widget.extraPractice,
      );
      final pack = await app.content.contentFor(widget.subject, app.active!.grade);
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

  void _summaryDone() {
    if (_c!.summary.streakGrew) {
      setState(() => _phase = _Phase.streak);
      _say('${AppScope.read(context).progress!.streakDays} gündür birlikteyiz!');
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
    if (_phase == _Phase.streak) {
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
          Row(children: const [
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
          onDone: _summaryDone,
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
                          phaseLabel: widget.extraPractice
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
                            AppScope.read(context).saveProgress();
                            return r;
                          },
                          onNext: (wasWrong) => _advance(c.next,
                              retryNote: wasWrong &&
                                  step.phase != StepPhase.retry),
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
        body: SafeArea(child: ChildTextScale(child: body)),
      ),
    );
  }
}

/// C1 Oturum üstü: kapat, ilerleme, fındık. Başka hiçbir şey.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.progress, required this.onClose});
  final double progress;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final nuts = AppScope.of(context).progress?.nuts ?? 0;
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, right: 16),
        child: Row(children: [
          Pressable(
            key: const Key('session-close'),
            onTap: onClose,
            label: 'Oturumdan çık',
            excludeChildSemantics: true,
            focusRadius: 32,
            builder: (context, down) => const SizedBox(
              width: 64,
              height: 64,
              child: Center(
                  child: DkIcon(DkIcons.x,
                      size: 30, color: K.inkSoft, stroke: 3)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: DkProgressBar(value: progress)),
          const SizedBox(width: 6),
          Semantics(
            label: '$nuts fındık',
            child: ExcludeSemantics(
              child: Row(children: [
                const DkIcon(DkIcons.nut, size: 28),
                const SizedBox(width: 4),
                Text('$nuts',
                    style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: K.nutInk)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
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
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: K.line, width: 2))),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            children: [
              _StepHeader(
                label: Text('YENİ KONU · ${_page + 1}/${pages.length}',
                    style: T.kicker),
                trailing: [
                  ListenSplit(
                      onListen: (slow) =>
                          widget.onSay(page.spoken, slow: slow)),
                ],
              ),
              const SizedBox(height: 14),
              EmojiText(widget.lesson.title, style: T.title),
              const SizedBox(height: 14),
              DkCard(
                radius: K.rLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (page.visual != null) ...[
                      Container(
                        constraints: const BoxConstraints(minHeight: 150),
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: K.tint,
                            borderRadius: BorderRadius.circular(K.rMd)),
                        child: VisualView(page.visual!),
                      ),
                      const SizedBox(height: 16),
                    ],
                    EmojiText(page.text,
                        style: const TextStyle(
                            fontSize: 21,
                            height: 28 / 21,
                            fontWeight: FontWeight.w700,
                            color: K.ink)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 10),
          child: Center(child: Dots(count: pages.length, index: _page)),
        ),
        _Footer(
          child: Row(children: [
            if (_page > 0) ...[
              SizedBox(
                width: 72,
                child: ChunkyButton(
                  key: const Key('lesson-back'),
                  label: '',
                  semanticsLabel: 'Geri',
                  icon: DkIcons.left,
                  kind: BtnKind.secondary,
                  onPressed: () => _go(_page - 1),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ChunkyButton(
                key: const Key('lesson-next'),
                label: last ? 'Hadi deneyelim!' : 'İleri',
                onPressed: last ? widget.onDone : () => _go(_page + 1),
              ),
            ),
          ]),
        ),
      ],
    );
  }
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
  });

  final SessionStep step;
  final String phaseLabel;
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

  Question get q => widget.step.question!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onSay(q.spoken));
  }

  void _check() {
    final i = _selected;
    if (i == null || _result != null || _busy) return;
    _busy = true; // çift dokunma koruması
    _watch.stop();
    final r = widget.onAnswer(i, _watch.elapsed, _hint);
    setState(() => _result = r);
    widget.onSay(r.correct
        ? _okTitles[widget.praise]
        : 'Doğrusu: ${q.answer}. ${q.explanation ?? ''}');
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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
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
                  style: T.question
                      .copyWith(fontSize: hasPassage ? 21 : 24)),
              if (_hint && r == null) ...[
                const SizedBox(height: 16),
                _HintBox(text: q.hint!),
              ],
              if (q.visual != null) ...[
                const SizedBox(height: 16),
                VisualView(q.visual!),
              ],
              const SizedBox(height: 16),
              Semantics(
                container: true,
                label: 'Seçenekler',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < q.options.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      _OptionCard(
                        key: Key('option-$i'),
                        label: q.options[i],
                        state: r == null
                            ? (i == _selected ? _Opt.selected : _Opt.idle)
                            : i == q.answerIndex
                                ? _Opt.right
                                : i == _selected
                                    ? _Opt.chosenWrong
                                    : _Opt.dim,
                        onTap: r == null
                            ? () {
                                setState(() => _selected = i);
                              }
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (r == null)
          _Footer(
            child: ChunkyButton(
              key: const Key('check'),
              label: 'Kontrol et',
              kind: BtnKind.good,
              onPressed: _selected != null ? _check : null,
            ),
          )
        else
          FeedbackBand(
            correct: r.correct,
            title: r.correct
                ? _okTitles[widget.praise]
                : 'Doğrusu: ${q.answer}',
            body: r.correct ? _okBodies[widget.praise] : q.explanation,
            onNext: () => widget.onNext(!r.correct),
          ),
      ],
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

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color border) = switch (state) {
      _Opt.idle || _Opt.dim => (K.card, K.line),
      _Opt.selected => (K.againBg, K.again),
      _Opt.right => (K.goodBg, K.good),
      _Opt.chosenWrong => (K.againBg, K.again),
    };
    final short = label.characters.length <= 3;
    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      constraints: const BoxConstraints(minHeight: 72),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(K.rMd),
        border: Border(
          top: BorderSide(color: border, width: 2),
          left: BorderSide(color: border, width: 2),
          right: BorderSide(color: border, width: 2),
          bottom: BorderSide(color: border, width: 5),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(K.rMd - 2),
        child: CustomPaint(
          painter: state == _Opt.chosenWrong ? _StripePainter() : null,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 44, vertical: 12),
                child: Center(
                  widthFactor: 1,
                  child: EmojiText(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: short ? 30 : 21,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: K.ink,
                    ),
                  ),
                ),
              ),
              if (state == _Opt.right || state == _Opt.chosenWrong)
                Positioned(
                  right: 10,
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: state == _Opt.right ? K.goodShadow : K.againStrong,
                      shape: BoxShape.circle,
                    ),
                    child: DkIcon(
                        state == _Opt.right ? DkIcons.check : DkIcons.again,
                        size: state == _Opt.right ? 17 : 16,
                        color: Colors.white,
                        stroke: state == _Opt.right ? 3.5 : 3),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (state == _Opt.dim) card = Opacity(opacity: .5, child: card);
    if (state == _Opt.right && !reduceMotion(context)) {
      card = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        builder: (context, v, child) => Transform.scale(
            scale: 1 + .06 * math.sin(v * math.pi), child: child),
        child: card,
      );
    }
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
      builder: (context, down) => card,
    );
  }
}

/// Yanlış seçilen seçeneğin 135° çizgili zemini (renk tek başına bilgi taşımaz).
class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = K.againStripe;
    final d = size.width + size.height;
    for (var x = -size.height; x < d; x += 20) {
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + 10, 0)
        ..lineTo(x + 10 - size.height, size.height)
        ..lineTo(x - size.height, size.height)
        ..close();
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) => false;
}

/// C7 Geri bildirim bandı: alttan kayar. Doğru: yeşil, kutlayan Fındık.
/// Tekrar: mavi, düşünen Fındık, "Doğrusu: …" ve ANLADIM.
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
    final fg = correct ? K.goodInk : K.againInk;
    final band = Container(
      key: Key(correct ? 'band-ok' : 'band-again'),
      color: correct ? K.goodBg : K.againBg,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            liveRegion: true,
            child: Row(children: [
              Mascot(
                  mood: correct ? MascotMood.celebrate : MascotMood.think,
                  size: 64),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: correct ? K.goodShadow : K.againStrong,
                            shape: BoxShape.circle),
                        child: DkIcon(
                            correct ? DkIcons.check : DkIcons.again,
                            size: 16,
                            color: Colors.white,
                            stroke: 3.5),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: EmojiText(title,
                            style: TextStyle(
                                fontSize: 24,
                                height: 30 / 24,
                                fontWeight: FontWeight.w900,
                                color: fg)),
                      ),
                    ]),
                    if (body != null && body!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      EmojiText(body!,
                          style: TextStyle(
                              fontSize: 17, height: 24 / 17, color: fg)),
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
            kind: correct ? BtnKind.good : BtnKind.again,
            onPressed: onNext,
          ),
        ],
      ),
    );
    if (reduceMotion(context)) return band;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      builder: (context, v, child) => FractionalTranslation(
          translation: Offset(0, v), child: child),
      child: band,
    );
  }
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
  });
  final SessionController controller;
  final Map<String, String> lessonTitles;
  final VoidCallback onDone;
  final void Function(String, {bool slow}) onSay;

  @override
  Widget build(BuildContext context) {
    final s = controller.summary;
    final streak = AppScope.of(context).progress?.streakDays ?? 0;
    final tiles = [
      (DkIcons.check, '${s.correct}', 'doğru cevap', K.goodBg, K.goodInk),
      (DkIcons.clock, '${s.minutes} dk', 'çalıştın', K.againBg, K.againInk),
      (DkIcons.nut, '+${s.nutsEarned}', 'fındık', K.peach, K.peachInk),
      (DkIcons.leaf, '$streak gün', 'birlikteyiz', K.goodBg, K.goodInk),
    ];
    final newTitles = [
      for (final code in s.newOutcomes) lessonTitles[code] ?? code,
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 72,
            child: Align(
              alignment: Alignment.centerRight,
              child: ListenButton(onListen: () => onSay('Bugün çok çalıştın!')),
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Pop(
                        child: const Mascot(
                            mood: MascotMood.celebrate,
                            size: 150,
                            label: 'Fındık kutluyor')),
                    const SizedBox(height: 16),
                    const Text('Bugün çok çalıştın!', style: T.big),
                    const SizedBox(height: 16),
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
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: t.$4,
                                          borderRadius:
                                              BorderRadius.circular(K.rSm)),
                                      child: DkIcon(t.$1,
                                          size: 22, color: t.$5),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(t.$2,
                                        style: const TextStyle(
                                            fontSize: 26,
                                            height: 32 / 26,
                                            fontWeight: FontWeight.w900,
                                            color: K.ink)),
                                    Text(t.$3,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: K.inkSoft)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                    if (newTitles.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      DkCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        color: K.rewardBg,
                        borderColor: K.rewardLine,
                        child: Row(children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                color: K.reward, shape: BoxShape.circle),
                            child: const DkIcon(DkIcons.star,
                                size: 22, color: K.ink),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: EmojiText(
                                'Yeni konu kumbarada: ${newTitles.join(', ')}',
                                style: const TextStyle(
                                    fontSize: 17,
                                    height: 23 / 17,
                                    fontWeight: FontWeight.w800,
                                    color: K.rewardInk)),
                          ),
                        ]),
                      ),
                    ],
                    if (s.retried > 0) ...[
                      const SizedBox(height: 12),
                      const Text(
                          'Zorlandığın soruları yakında yine soracağım.',
                          style: T.help),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ChunkyButton(
              key: const Key('summary-done'), label: 'Tamam', onPressed: onDone),
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
            child: Center(
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
