import 'package:flutter/material.dart';

import '../../app/session_controller.dart';
import '../../app/speaker.dart';
import '../../data/models.dart';
import '../theme.dart';
import '../widgets/chunky_button.dart';
import '../widgets/mascot.dart';
import '../widgets/visual_view.dart';

/// Çalışma oturumu: konu anlatımı -> seç, KONTROL ET -> geri bildirim -> DEVAM.
class SessionScreen extends StatefulWidget {
  const SessionScreen({
    super.key,
    required this.subject,
    this.focusOutcome,
    this.reviewOnly = false,
  });

  final Subject subject;
  final String? focusOutcome;
  final bool reviewOnly;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  SessionController? _c;
  Object? _error;
  bool _finished = false;
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
      );
      if (mounted) setState(() => _c = c);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _say(String text) {
    final app = AppScope.read(context);
    if (app.settings.soundOn) app.speaker.speak(text);
  }

  Future<void> _advance(VoidCallback step) async {
    step();
    if (_c!.isDone) {
      _c!.finish();
      await AppScope.read(context).saveProgress();
      if (mounted) setState(() => _finished = true);
      _say('Harika! Bugünlük bu kadar.');
    } else {
      setState(() {});
    }
  }

  /// Oturum yarıda bırakılırsa çözülenler kaydedilir.
  Future<void> _exit() async {
    final c = _c;
    if (c != null && !_finished && c.summary.answered > 0) {
      c.finish();
      await AppScope.read(context).saveProgress();
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmExit() async {
    final c = _c;
    if (c == null || _finished || c.steps.isEmpty) {
      await _exit();
      return;
    }
    final leave = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Mascot(mood: MascotMood.think, size: 90),
            const SizedBox(height: 8),
            Text('Bırakmak istediğine emin misin?',
                style: Theme.of(ctx).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            const Text('Şimdiye kadar çözdüklerin kaydedilecek.',
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ChunkyButton(
              key: const Key('keep-going'),
              label: 'Devam et',
              onPressed: () => Navigator.pop(ctx, false),
            ),
            const SizedBox(height: 10),
            TextButton(
              key: const Key('leave'),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Çık',
                  style: TextStyle(fontSize: 18, color: Kumbara.inkSoft)),
            ),
          ],
        ),
      ),
    );
    if (leave == true) await _exit();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    Widget body;
    if (_error != null) {
      body = _Message(MascotMood.think,
          'İçerik açılamadı. Lütfen uygulamayı yeniden başlat.\n($_error)');
    } else if (c == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (c.steps.isEmpty) {
      body = _Message(
        MascotMood.normal,
        widget.reviewOnly
            ? 'Şu an tekrar edecek bir şey yok. Yarın yine bak!'
            : 'Bu ders için içerik hazırlanıyor. Şimdilik başka bir derse ne dersin?',
      );
    } else if (_finished) {
      body = _Summary(controller: c, onDone: () => Navigator.of(context).pop());
    } else {
      final step = c.current;
      body = step.kind == StepKind.lesson
          ? _LessonView(
              key: ValueKey('L${c.index}'),
              lesson: step.lesson!,
              onSay: _say,
              onDone: () => _advance(c.completeLesson),
            )
          : _QuestionView(
              key: ValueKey('Q${c.index}'),
              step: step,
              onSay: _say,
              onAnswer: (i, elapsed, hint) =>
                  c.answer(i, elapsed: elapsed, usedHint: hint),
              onNext: () => _advance(c.next),
            );
    }

    final showBar = c != null && !_finished && c.steps.isNotEmpty;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 4,
          title: Row(
            children: [
              IconButton(
                key: const Key('session-close'),
                icon: const Icon(Icons.close_rounded,
                    size: 30, color: Kumbara.inkSoft),
                tooltip: 'Çık',
                onPressed: _confirmExit,
              ),
              if (showBar)
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: c.progressRatio),
                    duration: const Duration(milliseconds: 350),
                    builder: (context, v, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: v,
                        minHeight: 16,
                        backgroundColor: Kumbara.line,
                        color: Kumbara.good,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 16),
            ],
          ),
        ),
        body: SafeArea(child: body),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.mood, this.text);
  final MascotMood mood;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Mascot(mood: mood, size: 140),
              const SizedBox(height: 16),
              Text(text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              ChunkyButton(
                  label: 'Geri dön',
                  onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      );
}

class _LessonView extends StatefulWidget {
  const _LessonView(
      {super.key,
      required this.lesson,
      required this.onSay,
      required this.onDone});
  final Lesson lesson;
  final void Function(String) onSay;
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
    final page = widget.lesson.pages[_page];
    final last = _page == widget.lesson.pages.length - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('YENİ KONU · ${widget.lesson.title}',
              style: const TextStyle(
                  color: Kumbara.primaryDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 15)),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  MascotSays(
                      text: page.text, onTap: () => widget.onSay(page.spoken)),
                  if (page.visual != null) ...[
                    const SizedBox(height: 8),
                    VisualView(page.visual!),
                  ],
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.lesson.pages.length; i++)
                Container(
                  margin: const EdgeInsets.all(4),
                  width: i == _page ? 22 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: i == _page ? Kumbara.primary : Kumbara.line,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_page > 0) ...[
                SizedBox(
                  width: 72,
                  child: ChunkyButton(
                    label: '←',
                    color: Colors.white,
                    shadow: Kumbara.line,
                    textColor: Kumbara.ink,
                    onPressed: () => _go(_page - 1),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ChunkyButton(
                  key: const Key('lesson-next'),
                  label: last ? 'Hadi deneyelim' : 'Devam',
                  onPressed: last ? widget.onDone : () => _go(_page + 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestionView extends StatefulWidget {
  const _QuestionView({
    super.key,
    required this.step,
    required this.onSay,
    required this.onAnswer,
    required this.onNext,
  });

  final SessionStep step;
  final void Function(String) onSay;
  final AnswerResult Function(int index, Duration elapsed, bool usedHint)
      onAnswer;
  final VoidCallback onNext;

  @override
  State<_QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<_QuestionView> {
  final _watch = Stopwatch()..start();
  int? _selected;
  AnswerResult? _result;
  bool _hint = false;

  Question get q => widget.step.question!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onSay(q.spoken));
  }

  void _check() {
    final i = _selected;
    if (i == null || _result != null) return;
    _watch.stop();
    final r = widget.onAnswer(i, _watch.elapsed, _hint);
    setState(() => _result = r);
    widget.onSay(r.correct
        ? 'Harika!'
        : 'Doğru cevap: ${q.answer}. ${q.explanation ?? ''}');
  }

  Widget _activity(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final r = _result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Text('VELİYLE BİRLİKTE',
                        style: TextStyle(color: Kumbara.primaryDark, fontWeight: FontWeight.w900, fontSize: 15)),
                    const Spacer(),
                    IconButton.filledTonal(
                      key: const Key('listen'),
                      tooltip: 'Dinle',
                      onPressed: () => widget.onSay(q.spoken),
                      icon: const Icon(Icons.volume_up_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('👨‍👩‍👧', style: TextStyle(fontSize: 56), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                MascotSays(text: q.prompt, onTap: () => widget.onSay(q.spoken)),
                if (q.visual != null) VisualView(q.visual!),
              ],
            ),
          ),
        ),
        if (r == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ChunkyButton(
                  key: const Key('activity-done'),
                  label: 'Yaptık',
                  color: Kumbara.good,
                  shadow: Kumbara.goodDark,
                  onPressed: () {
                    _watch.stop();
                    setState(() => _result = widget.onAnswer(0, Duration.zero, false));
                    widget.onSay('Harika! Birlikte yaptınız.');
                  },
                ),
                TextButton(
                  key: const Key('activity-skip'),
                  onPressed: widget.onSkip,
                  child: Text('Şimdi değil', style: t.bodyLarge?.copyWith(color: Kumbara.inkSoft)),
                ),
              ],
            ),
          )
        else
          _FeedbackBar(
            result: r,
            answer: '',
            explanation: null,
            canCheck: false,
            onCheck: () {},
            onNext: widget.onNext,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (q.activity) return _activity(context);
    final t = Theme.of(context).textTheme;
    final r = _result;
    final label = switch (widget.step.phase) {
      StepPhase.warmup => 'ISINMA',
      StepPhase.practice || StepPhase.newTopic => 'YENİ KONU',
      StepPhase.review => 'TEKRAR',
      StepPhase.retry => 'BİR KEZ DAHA',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: Kumbara.primaryDark,
                            fontWeight: FontWeight.w900,
                            fontSize: 15)),
                    const Spacer(),
                    if (q.hint != null && r == null)
                      TextButton.icon(
                        key: const Key('hint'),
                        onPressed: _hint
                            ? null
                            : () {
                                setState(() => _hint = true);
                                widget.onSay(q.hint!);
                              },
                        icon: const Text('💡', style: TextStyle(fontSize: 20)),
                        label: const Text('İpucu'),
                      ),
                    IconButton.filledTonal(
                      key: const Key('listen'),
                      tooltip: 'Dinle',
                      onPressed: () => widget.onSay(q.spoken),
                      icon: const Icon(Icons.volume_up_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(q.prompt, style: t.headlineMedium),
                if (_hint && r == null) ...[
                  const SizedBox(height: 8),
                  Text('💡 ${q.hint}',
                      style: t.bodyLarge?.copyWith(color: Kumbara.inkSoft)),
                ],
                if (q.visual != null) ...[
                  const SizedBox(height: 12),
                  VisualView(q.visual!),
                ],
                const SizedBox(height: 16),
                for (var i = 0; i < q.options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _OptionCard(
                      key: Key('option-$i'),
                      label: q.options[i],
                      state: r == null
                          ? (i == _selected
                              ? _OptState.selected
                              : _OptState.idle)
                          : i == q.answerIndex
                              ? _OptState.right
                              : i == _selected
                                  ? _OptState.chosenWrong
                                  : _OptState.dim,
                      onTap: r == null
                          ? () => setState(() => _selected = i)
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        ),
        _FeedbackBar(
          result: r,
          answer: q.answer,
          explanation: q.explanation,
          canCheck: _selected != null,
          onCheck: _check,
          onNext: widget.onNext,
        ),
      ],
    );
  }
}

/// Alt bant: KONTROL ET; cevaptan sonra yeşil/mavi geri bildirim + DEVAM.
class _FeedbackBar extends StatelessWidget {
  const _FeedbackBar({
    required this.result,
    required this.answer,
    required this.explanation,
    required this.canCheck,
    required this.onCheck,
    required this.onNext,
  });

  final AnswerResult? result;
  final String answer;
  final String? explanation;
  final bool canCheck;
  final VoidCallback onCheck;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final r = result;
    if (r == null) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Kumbara.line, width: 2))),
        child: ChunkyButton(
          key: const Key('check'),
          label: 'Kontrol et',
          color: Kumbara.good,
          shadow: Kumbara.goodDark,
          onPressed: canCheck ? onCheck : null,
        ),
      );
    }
    final ok = r.correct;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: ok ? Kumbara.goodBg : Kumbara.tryAgainBg,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Mascot(
                  mood: ok ? MascotMood.celebrate : MascotMood.think, size: 56),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ok ? 'Harika!' : 'Doğru cevap: $answer',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: ok ? Kumbara.goodDark : Kumbara.tryAgainDark,
                      ),
                    ),
                    if (!ok && explanation != null)
                      Text(explanation!,
                          style: const TextStyle(
                              fontSize: 16, color: Kumbara.tryAgainDark)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ChunkyButton(
            key: const Key('next'),
            label: 'Devam',
            color: ok ? Kumbara.good : Kumbara.tryAgain,
            shadow: ok ? Kumbara.goodDark : Kumbara.tryAgainDark,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

enum _OptState { idle, selected, right, chosenWrong, dim }

class _OptionCard extends StatelessWidget {
  const _OptionCard(
      {super.key,
      required this.label,
      required this.state,
      required this.onTap});
  final String label;
  final _OptState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color border) = switch (state) {
      _OptState.idle => (Colors.white, Kumbara.line),
      _OptState.selected => (const Color(0xFFFFEFD9), Kumbara.primary),
      _OptState.right => (Kumbara.goodBg, Kumbara.good),
      _OptState.chosenWrong => (Kumbara.tryAgainBg, Kumbara.tryAgain),
      _OptState.dim => (Colors.white, Kumbara.line),
    };
    final emojiOnly = label.runes.length <= 3 &&
        !RegExp(r'[0-9A-Za-zÇĞİÖŞÜçğıöşü]').hasMatch(label);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        constraints: const BoxConstraints(minHeight: 64),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            top: BorderSide(color: border, width: 2),
            left: BorderSide(color: border, width: 2),
            right: BorderSide(color: border, width: 2),
            bottom: BorderSide(color: border, width: 5),
          ),
        ),
        child: Opacity(
          opacity: state == _OptState.dim ? 0.5 : 1,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: emojiOnly ? 36 : 22,
              fontWeight: FontWeight.w800,
              color: Kumbara.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.controller, required this.onDone});
  final SessionController controller;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final s = controller.summary;
    final t = Theme.of(context).textTheme;
    final pct = s.answered == 0 ? 0 : (100 * s.correct / s.answered).round();
    Widget box(String title, String value, Color color) => Expanded(
          child: Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(trUpper(title),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13)),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(3, 0, 3, 3),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13)),
                  child: Text(value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w900,
                          fontSize: 22)),
                ),
              ],
            ),
          ),
        );
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Spacer(),
          const Mascot(mood: MascotMood.celebrate, size: 170),
          const SizedBox(height: 12),
          Text('Bugünlük bu kadar!', style: t.headlineMedium),
          if (s.newOutcomes.isNotEmpty)
            Text('Kumbarana yeni bir konu attın.',
                style: t.bodyLarge, textAlign: TextAlign.center),
          if (s.retried > 0)
            Text('Zorlandığın soruları yakında yine soracağım.',
                style: t.bodyLarge?.copyWith(color: Kumbara.inkSoft),
                textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Row(children: [
            box('Fındık', '+${s.nutsEarned} 🌰', Kumbara.nut),
            box('Doğruluk', '%$pct', Kumbara.good),
          ]),
          const Spacer(),
          ChunkyButton(
              key: const Key('summary-done'),
              label: 'Devam',
              onPressed: onDone),
        ],
      ),
    );
  }
}
