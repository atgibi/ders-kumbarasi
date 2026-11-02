import 'package:flutter/material.dart';

import '../../app/session_controller.dart';
import '../../app/speaker.dart';
import '../../data/models.dart';
import '../theme.dart';
import '../widgets/visual_view.dart';

/// Bir dersin günlük oturumu: ısınma -> konu anlatımı -> uygulama -> tekrar.
class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key, required this.subject});
  final Subject subject;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  SessionController? _c;
  Object? _error;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
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
      );
      if (!mounted) return;
      setState(() => _c = c);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _say(String text) {
    final app = AppScope.read(context);
    if (app.settings.soundOn) app.speaker.speak(text);
  }

  Future<void> _finish() async {
    final app = AppScope.read(context);
    final c = _c!;
    c.finish();
    await app.saveProgress();
    if (mounted) setState(() => _finished = true);
  }

  Future<void> _advance(VoidCallback step) async {
    step();
    if (_c!.isDone) {
      await _finish();
    } else {
      setState(() {});
    }
  }

  Speaker? _speaker;

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

  @override
  Widget build(BuildContext context) {
    final c = _c;
    Widget body;
    if (_error != null) {
      body = _Message('😕',
          'İçerik açılamadı. Lütfen uygulamayı yeniden başlatın.\n($_error)');
    } else if (c == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (c.steps.isEmpty) {
      body = const _Message('🧰',
          'Bu ders için yeni içerik hazırlanıyor. Şimdilik başka bir derse ne dersin?');
    } else if (_finished) {
      body = _Summary(controller: c);
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('${widget.subject.icon} ${widget.subject.label}'),
        leading: IconButton(
          key: const Key('session-close'),
          icon: const Icon(Icons.close_rounded, size: 32),
          tooltip: 'Çık',
          onPressed: () async {
            if (c != null && !_finished && c.summary.answered > 0) {
              c.finish();
              await AppScope.read(context).saveProgress();
            }
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
        bottom: c == null || _finished
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                        value: c.progressRatio, minHeight: 10),
                  ),
                ),
              ),
      ),
      body: SafeArea(child: body),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.icon, this.text);
  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              Text(text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Geri dön'),
              ),
            ],
          ),
        ),
      );
}

class _ListenButton extends StatelessWidget {
  const _ListenButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton.filledTonal(
        key: const Key('listen'),
        iconSize: 32,
        tooltip: 'Dinle',
        onPressed: onTap,
        icon: const Icon(Icons.hearing_rounded),
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
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                  child:
                      Text('📚 ${widget.lesson.title}', style: t.titleLarge)),
              _ListenButton(onTap: () => widget.onSay(page.spoken)),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (page.visual != null) VisualView(page.visual!),
                  const SizedBox(height: 12),
                  Text(page.text,
                      style: t.bodyLarge, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          Row(
            children: [
              if (_page > 0)
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(64, 64)),
                    onPressed: () => _go(_page - 1),
                    child: const Text('Geri', style: TextStyle(fontSize: 20)),
                  ),
                ),
              if (_page > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  key: const Key('lesson-next'),
                  onPressed: last ? widget.onDone : () => _go(_page + 1),
                  child: Text(last ? 'Hadi deneyelim!' : 'İleri'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${_page + 1} / ${widget.lesson.pages.length}',
              textAlign: TextAlign.center),
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
  int? _chosen;
  AnswerResult? _result;
  bool _hint = false;

  Question get q => widget.step.question!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onSay(q.spoken));
  }

  void _choose(int i) {
    if (_result != null) return;
    _watch.stop();
    final r = widget.onAnswer(i, _watch.elapsed, _hint);
    setState(() {
      _chosen = i;
      _result = r;
    });
    widget.onSay(r.correct
        ? 'Aferin!'
        : 'Bir daha bakalım. Doğru cevap ${q.answer}. ${q.explanation ?? ''}');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final r = _result;
    final phaseLabel = switch (widget.step.phase) {
      StepPhase.warmup => 'Isınma',
      StepPhase.practice => 'Yeni konu',
      StepPhase.review => 'Tekrar',
      StepPhase.retry => 'Bir kez daha',
      StepPhase.newTopic => 'Yeni konu',
    };
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Chip(label: Text(phaseLabel)),
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
                  icon: const Text('💡', style: TextStyle(fontSize: 22)),
                  label: const Text('İpucu'),
                ),
              _ListenButton(onTap: () => widget.onSay(q.spoken)),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  if (q.visual != null) VisualView(q.visual!),
                  const SizedBox(height: 8),
                  Text(q.prompt,
                      style: t.headlineMedium, textAlign: TextAlign.center),
                  if (_hint && r == null) ...[
                    const SizedBox(height: 8),
                    Text('💡 ${q.hint}',
                        style: t.bodyLarge, textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (var i = 0; i < q.options.length; i++)
                        _OptionButton(
                          key: Key('option-$i'),
                          label: q.options[i],
                          state: r == null
                              ? _OptState.idle
                              : i == q.answerIndex
                                  ? _OptState.right
                                  : i == _chosen
                                      ? _OptState.chosenWrong
                                      : _OptState.dim,
                          onTap: () => _choose(i),
                        ),
                    ],
                  ),
                  if (r != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      r.correct
                          ? '🎉 Aferin!'
                          : '🤔 Bir daha bakalım: doğru cevap ${q.answer}.',
                      style: t.titleLarge?.copyWith(
                          color: r.correct ? Kumbara.good : Kumbara.tryAgain),
                      textAlign: TextAlign.center,
                    ),
                    if (!r.correct && q.explanation != null) ...[
                      const SizedBox(height: 8),
                      Text(q.explanation!,
                          style: t.bodyLarge, textAlign: TextAlign.center),
                    ],
                  ],
                ],
              ),
            ),
          ),
          if (r != null)
            FilledButton(
              key: const Key('next'),
              onPressed: widget.onNext,
              child: const Text('Devam'),
            ),
        ],
      ),
    );
  }
}

enum _OptState { idle, right, chosenWrong, dim }

class _OptionButton extends StatelessWidget {
  const _OptionButton(
      {super.key,
      required this.label,
      required this.state,
      required this.onTap});
  final String label;
  final _OptState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, border) = switch (state) {
      _OptState.idle => (Colors.white, Kumbara.primary),
      _OptState.right => (Kumbara.good.withValues(alpha: 0.18), Kumbara.good),
      _OptState.chosenWrong => (
          Kumbara.tryAgain.withValues(alpha: 0.12),
          Kumbara.tryAgain
        ),
      _OptState.dim => (Colors.white, Colors.black12),
    };
    final isEmoji = label.runes.length <= 2 &&
        !RegExp(r'[0-9A-Za-zÇĞİÖŞÜçğıöşü]').hasMatch(label);
    return SizedBox(
      width: label.length > 12 ? 300 : 140,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: state == _OptState.idle ? onTap : null,
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border, width: 3),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: isEmoji ? 40 : 26,
                  fontWeight: FontWeight.w800,
                  color: Kumbara.ink),
            ),
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.controller});
  final SessionController controller;

  @override
  Widget build(BuildContext context) {
    final s = controller.summary;
    final t = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐷🪙', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 12),
            Text('Bugünlük bu kadar!', style: t.headlineMedium),
            const SizedBox(height: 12),
            Text('${s.answered} sorudan ${s.correct} tanesini doğru yaptın.',
                style: t.bodyLarge, textAlign: TextAlign.center),
            if (s.newOutcomes.isNotEmpty)
              Text('Kumbarana ${s.newOutcomes.length} yeni konu attın.',
                  style: t.bodyLarge, textAlign: TextAlign.center),
            if (s.retried > 0)
              Text('Zorlandığın ${s.retried} soruyu yakında yine soracağım.',
                  style: t.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: 28),
            FilledButton(
              key: const Key('summary-done'),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ana sayfa'),
            ),
          ],
        ),
      ),
    );
  }
}
