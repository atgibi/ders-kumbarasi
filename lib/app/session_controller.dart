/// Bir çalışma oturumunu yürütür: planı soru/anlatım adımlarına çevirir,
/// cevapları tekrar motoruna işler, yanlışları oturum sonunda yeniden sorar.
library;

import 'dart:math';

import '../core/srs/leitner.dart';
import '../core/srs/session_planner.dart';
import '../data/content_repository.dart';
import '../data/generators.dart';
import '../data/models.dart';
import '../data/progress_store.dart';

enum StepKind { lesson, question }

enum StepPhase { warmup, newTopic, practice, review, retry }

class SessionStep {
  SessionStep.lesson(this.lesson, this.phase)
      : kind = StepKind.lesson,
        card = null,
        question = null;

  SessionStep.question(this.card, this.question, this.phase)
      : kind = StepKind.question,
        lesson = null;

  final StepKind kind;
  final StepPhase phase;
  final Lesson? lesson;
  final CardDef? card;
  final Question? question;
}

class AnswerResult {
  const AnswerResult({required this.correct, required this.outcome});
  final bool correct;
  final ReviewOutcome outcome;
}

class SessionSummary {
  int answered = 0;
  int correct = 0;
  int retried = 0;
  final Set<String> newOutcomes = {};
}

class SessionController {
  SessionController._({
    required this.subject,
    required this.progress,
    required this.steps,
    required this.random,
    required this.clock,
    required this.plan,
  }) : startedAt = clock();

  final Subject subject;
  final ChildProgress progress;
  final List<SessionStep> steps;
  final Random random;
  final DateTime Function() clock;
  final SessionPlan plan;
  final DateTime startedAt;
  final SessionSummary summary = SessionSummary();
  final Set<String> _retried = {};
  int index = 0;

  bool get isDone => index >= steps.length;
  SessionStep get current => steps[index];
  double get progressRatio => steps.isEmpty ? 1 : index / steps.length;

  /// Oturumu kurar. İçeriği olmayan ders/sınıf için boş oturum döner.
  static Future<SessionController> build({
    required ContentRepository repo,
    required Subject subject,
    required int grade,
    required ChildProgress progress,
    DateTime Function()? clock,
    Random? random,
    SessionConfig config = const SessionConfig(),
  }) async {
    final now = (clock ?? DateTime.now)();
    final rnd = random ?? Random();
    final outcomes = await repo.outcomesFor(subject, grade);
    final pack = await repo.contentFor(subject, grade);

    final cardById = <String, CardDef>{
      for (final oc in pack.values)
        for (final c in oc.cards) c.id: c,
    };

    // Bu derse ait, daha önce görülmüş kart durumları
    final states = progress.cards.values
        .where((s) => cardById.containsKey(s.cardId))
        .toList();

    // Sıradaki yeni çıktı: program sırasında, içeriği olan ve başlanmamış ilk çıktı
    NewOutcomeCandidate? nextNew;
    for (final o in outcomes) {
      final oc = pack[o.code];
      if (oc == null || oc.cards.isEmpty) continue;
      if (progress.startedOutcomes.contains(o.code)) continue;
      nextNew = NewOutcomeCandidate(
        outcomeId: o.code,
        cardIds: [for (final c in oc.cards) c.id],
      );
      break;
    }

    final plan = planSession(
      states: states,
      nextNew: nextNew,
      now: now,
      config: config,
      random: rnd,
    );

    SessionStep q(String id, StepPhase phase) {
      final c = cardById[id]!;
      return SessionStep.question(c, generate(c, rnd), phase);
    }

    final steps = <SessionStep>[
      for (final id in plan.warmup) q(id, StepPhase.warmup),
      if (plan.newOutcomeId != null)
        for (final l in pack[plan.newOutcomeId]!.lessons)
          SessionStep.lesson(l, StepPhase.newTopic),
      for (final id in plan.practice) q(id, StepPhase.practice),
      for (final id in plan.review) q(id, StepPhase.review),
    ];

    return SessionController._(
      subject: subject,
      progress: progress,
      steps: steps,
      random: rnd,
      clock: clock ?? DateTime.now,
      plan: plan,
    );
  }

  /// Konu anlatımı adımını tamamlar.
  void completeLesson() {
    assert(current.kind == StepKind.lesson);
    final code = plan.newOutcomeId;
    if (code != null) {
      progress.startedOutcomes.add(code);
      summary.newOutcomes.add(code);
    }
    index++;
  }

  /// Soruyu cevaplar ve durumu günceller. Sonraki adıma geçmek için [next].
  AnswerResult answer(int optionIndex,
      {required Duration elapsed, bool usedHint = false}) {
    final step = current;
    assert(step.kind == StepKind.question);
    final card = step.card!;
    final correct = optionIndex == step.question!.answerIndex;
    final outcome = classify(
      correct: correct,
      elapsed: elapsed,
      fastThreshold: Duration(seconds: card.fastSeconds),
      usedHint: usedHint,
    );
    final now = clock();

    // Oturum içi yeniden sormada tekrar motoru ikinci kez cezalandırmaz/ödüllendirmez
    if (step.phase != StepPhase.retry) {
      final prev = progress.cards[card.id] ?? CardState.fresh(card.id, now);
      progress.cards[card.id] = review(prev, outcome, now);
      summary.answered++;
      if (correct) summary.correct++;
    }
    if (step.phase == StepPhase.practice && plan.newOutcomeId != null) {
      // Konu anlatımı olmayan çıktılarda da çıktı başlatılmış sayılır
      progress.startedOutcomes.add(plan.newOutcomeId!);
      summary.newOutcomes.add(plan.newOutcomeId!);
    }

    // Yanlış cevaplanan kart oturum sonunda farklı bir varyantla bir kez daha
    if (!correct && !_retried.contains(card.id)) {
      _retried.add(card.id);
      summary.retried++;
      steps.add(SessionStep.question(card, generate(card, random), StepPhase.retry));
    }
    return AnswerResult(correct: correct, outcome: outcome);
  }

  void next() => index++;

  /// Oturumu kapatır: süre ve seri kaydı.
  void finish() {
    final now = clock();
    final minutes = max(1, (now.difference(startedAt).inSeconds / 60).ceil());
    final key = dayKey(now);
    progress.dailyMinutes[key] = (progress.dailyMinutes[key] ?? 0) + minutes;
    if (summary.answered > 0) recordSessionDay(progress, now);
  }
}
