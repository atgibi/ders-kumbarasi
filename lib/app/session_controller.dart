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
import '../game/world.dart';

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

/// Doğru cevap başına ve oturum sonunda kazanılan ışık.
const int nutsPerCorrect = 1;
const int nutsSessionBonus = 5;

class SessionSummary {
  int answered = 0;
  int correct = 0;
  int retried = 0;
  int nutsEarned = 0;
  int activities = 0;
  int minutes = 0;

  /// Bu oturumda kazanılan krallık malzemesi.
  int suppliesEarned = 0;

  /// Bu oturumda seri bir gün arttı mı (C12 seri kutlaması).
  bool streakGrew = false;
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
    this.altLessons = const [],
  }) : startedAt = clock();

  /// Yeni konunun "farklı yoldan" anlatımları: alıştırmada ilk yanlışta
  /// bir kez araya girer.
  final List<Lesson> altLessons;
  bool _altShown = false;

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
  double _maxRatio = 0;
  bool finished = false;

  bool get isDone => index >= steps.length;
  SessionStep get current => steps[index];

  /// İlerleme çubuğu: yeniden sorulan kart sona eklense de geri gitmez.
  double get progressRatio {
    final r = steps.isEmpty ? 1.0 : index / steps.length;
    if (r > _maxRatio) _maxRatio = r;
    return _maxRatio;
  }

  /// Kalan soru sayısı (süre sınırı uyarısı için).
  int get remainingQuestions => index >= steps.length
      ? 0
      : steps.sublist(index).where((s) => s.kind == StepKind.question).length;

  /// Günlük süre doluyor: şu anki adımdan sonra en fazla [n] soru kalsın.
  /// Oturum yarıda kesilmez; kısalır.
  void limitRemaining(int n) {
    var kept = 0;
    var cut = steps.length;
    for (var i = index + 1; i < steps.length; i++) {
      if (steps[i].kind == StepKind.question) {
        if (kept == n) {
          cut = i;
          break;
        }
        kept++;
      } else {
        cut = i; // yarıda konu anlatımına başlanmaz
        break;
      }
    }
    if (cut < steps.length) steps.removeRange(cut, steps.length);
  }

  /// Oturumu kurar. İçeriği olmayan ders/sınıf için boş oturum döner.
  ///
  /// - [focusOutcome] verilirse: başlanmamışsa o çıktının konu anlatımı ve
  ///   uygulaması (kısa ısınmayla); başlanmışsa o çıktının alıştırması.
  /// - [reviewOnly]: yalnızca vadesi gelen tekrarlar, yeni konu yok.
  static Future<SessionController> build({
    required ContentRepository repo,
    required Subject subject,
    required int grade,
    required ChildProgress progress,
    DateTime Function()? clock,
    Random? random,
    SessionConfig config = const SessionConfig(),
    String? focusOutcome,
    bool reviewOnly = false,
    bool extraPractice = false,
    Set<String> locked = const {},
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

    SessionStep q(String id, StepPhase phase) {
      final c = cardById[id]!;
      return SessionStep.question(c, generate(c, rnd), phase);
    }

    // Başlanmış bir çıktının alıştırması (ya da bugünkü işler bitince ekstra
    // tekrar): en zayıf kartlardan 8 tane
    if (extraPractice ||
        (focusOutcome != null &&
            progress.startedOutcomes.contains(focusOutcome))) {
      final source = extraPractice
          ? [
              for (final code in progress.startedOutcomes)
                ...?pack[code]?.cards,
            ]
          : [...?pack[focusOutcome]?.cards];
      final cards = source.where((c) => !(c.fixed?.activity ?? false)).toList()
        ..sort((a, b) {
          final sa = progress.cards[a.id], sb = progress.cards[b.id];
          final c = (sa?.box ?? -1).compareTo(sb?.box ?? -1);
          if (c != 0) return c;
          final l = a.level.compareTo(b.level);
          return l != 0 ? l : a.id.compareTo(b.id);
        });
      final ids = cards.take(8).map((c) => c.id).toList()..shuffle(rnd);
      final plan = SessionPlan(
          warmup: const [],
          newOutcomeId: null,
          practice: const [],
          review: ids,
          isReviewDay: false);
      return SessionController._(
        subject: subject,
        progress: progress,
        steps: [for (final id in ids) q(id, StepPhase.review)],
        random: rnd,
        clock: clock ?? DateTime.now,
        plan: plan,
      );
    }

    // Sıradaki yeni çıktı: istenen çıktı ya da program sırasında içeriği olan
    // ve başlanmamış ilk çıktı
    NewOutcomeCandidate? nextNew;
    for (final o in outcomes) {
      if (reviewOnly) break;
      if (focusOutcome != null && o.code != focusOutcome) continue;
      final oc = pack[o.code];
      if (oc == null || oc.cards.isEmpty) continue;
      if (progress.startedOutcomes.contains(o.code)) continue;
      if (locked.contains(o.code)) continue; // abonelikle açılan bölge
      nextNew = NewOutcomeCandidate(
        outcomeId: o.code,
        // Kolaydan zora: ilk alıştırmada önce kolay sorular gelir
        cardIds: [
          for (final c in ([...oc.cards]
            ..sort((a, b) => a.level.compareTo(b.level))))
            c.id
        ],
      );
      break;
    }

    final plan = planSession(
      states: states,
      nextNew: nextNew,
      now: now,
      config: focusOutcome != null
          // Yeni konu dersinde kısa ısınma, az tekrar
          ? SessionConfig(
              warmupCount: 2,
              practiceCount: config.practiceCount,
              maxReview: 2,
              backlogLimit: 1 << 30,
            )
          : reviewOnly
              ? SessionConfig(
                  warmupCount: config.warmupCount,
                  practiceCount: 0,
                  maxReview: 15,
                  backlogLimit: config.backlogLimit,
                )
              : config,
      random: rnd,
    );

    final steps = <SessionStep>[
      for (final id in plan.warmup) q(id, StepPhase.warmup),
      if (plan.newOutcomeId != null)
        for (final l in pack[plan.newOutcomeId]!.lessons)
          if (!l.alt) SessionStep.lesson(l, StepPhase.newTopic),
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
      altLessons: plan.newOutcomeId == null
          ? const []
          : [
              for (final l in pack[plan.newOutcomeId]!.lessons)
                if (l.alt) l
            ],
    );
  }

  /// Bekçi düellosu: bölgenin çıktılarından karma [count] soru. En zayıf
  /// kartlar önce; her çıktıdan sırayla seçilir. Cevaplar tekrar motoruna
  /// tekrar olarak işlenir.
  static Future<SessionController> duel({
    required ContentRepository repo,
    required Subject subject,
    required int grade,
    required ChildProgress progress,
    required List<String> outcomeCodes,
    int count = 8,
    DateTime Function()? clock,
    Random? random,
  }) async {
    final rnd = random ?? Random();
    final pack = await repo.contentFor(subject, grade);
    final pools = <List<CardDef>>[
      for (final code in outcomeCodes)
        ([...?pack[code]?.cards]
          ..removeWhere((c) => c.fixed?.activity ?? false)
          ..shuffle(rnd)
          ..sort((a, b) => (progress.cards[a.id]?.box ?? -1)
              .compareTo(progress.cards[b.id]?.box ?? -1)))
    ]..removeWhere((p) => p.isEmpty);
    final picked = <CardDef>[];
    var round = 0;
    while (picked.length < count && pools.any((p) => p.length > round)) {
      for (final p in pools) {
        if (picked.length >= count) break;
        if (p.length > round) picked.add(p[round]);
      }
      round++;
    }
    picked.shuffle(rnd);
    final ids = [for (final c in picked) c.id];
    return SessionController._(
      subject: subject,
      progress: progress,
      steps: [
        for (final c in picked)
          SessionStep.question(c, generate(c, rnd), StepPhase.review)
      ],
      random: rnd,
      clock: clock ?? DateTime.now,
      plan: SessionPlan(
          warmup: const [],
          newOutcomeId: null,
          practice: const [],
          review: ids,
          isReviewDay: false),
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
      if (correct) {
        summary.correct++;
        summary.nutsEarned += nutsPerCorrect;
        progress.nuts += nutsPerCorrect;
      }
      final day = dayKey(now);
      progress.countAnswer(day, firstTry: correct && !usedHint);
      progress.addAttempt(
        card.outcomeCode,
        Attempt(
          day,
          _short(step.question!.prompt),
          !correct
              ? 'retry'
              : usedHint
                  ? 'hint'
                  : outcome == ReviewOutcome.correctFast
                      ? 'first'
                      : 'slow',
        ),
      );
    }
    if (step.phase == StepPhase.practice && plan.newOutcomeId != null) {
      // Konu anlatımı olmayan çıktılarda da çıktı başlatılmış sayılır
      progress.startedOutcomes.add(plan.newOutcomeId!);
      summary.newOutcomes.add(plan.newOutcomeId!);
    }

    // Yeni konunun alıştırmasında ilk yanlış: konu farklı yoldan bir kez daha
    if (!correct &&
        step.phase == StepPhase.practice &&
        !_altShown &&
        altLessons.isNotEmpty) {
      _altShown = true;
      steps.insert(
          index + 1, SessionStep.lesson(altLessons.first, StepPhase.newTopic));
    }

    // Yanlış cevaplanan kart oturum sonunda farklı bir varyantla bir kez daha
    if (!correct && !_retried.contains(card.id)) {
      _retried.add(card.id);
      summary.retried++;
      steps.add(
          SessionStep.question(card, generate(card, random), StepPhase.retry));
    }
    return AnswerResult(correct: correct, outcome: outcome);
  }

  /// Veliyle etkinlik yapıldı ("Yaptık"). Puanlanmaz: doğru/yanlış sayısına
  /// girmez; kart tekrar takvimine "yapıldı" olarak işlenir.
  void completeActivity() {
    final step = current;
    final card = step.card!;
    final now = clock();
    final prev = progress.cards[card.id] ?? CardState.fresh(card.id, now);
    progress.cards[card.id] = review(prev, ReviewOutcome.correctFast, now);
    summary.activities++;
    if (step.phase == StepPhase.practice && plan.newOutcomeId != null) {
      progress.startedOutcomes.add(plan.newOutcomeId!);
      summary.newOutcomes.add(plan.newOutcomeId!);
    }
  }

  void next() => index++;

  /// Etkinliği şimdi yapmadan geç: kayıt değişmez.
  void skip() => index++;

  static String _short(String prompt) {
    final p = prompt.contains('\n\n')
        ? prompt.substring(prompt.lastIndexOf('\n\n') + 2)
        : prompt;
    final t = p.replaceAll(RegExp(r'\s+'), ' ').trim();
    return t.length <= 60 ? t : '${t.substring(0, 57)}…';
  }

  /// Oturumu kapatır: süre ve seri kaydı.
  void finish() {
    if (finished) return;
    finished = true;
    final now = clock();
    final minutes = max(1, (now.difference(startedAt).inSeconds / 60).ceil());
    final key = dayKey(now);
    progress.dailyMinutes[key] = (progress.dailyMinutes[key] ?? 0) + minutes;
    summary.minutes = minutes;
    if (summary.answered > 0 || summary.activities > 0) {
      final before = progress.lastSessionDay;
      recordSessionDay(progress, now);
      summary.streakGrew = before != progress.lastSessionDay;
      summary.nutsEarned += nutsSessionBonus;
      progress.nuts += nutsSessionBonus;
      // Krallık malzemesi: her 3 doğruya 1 (en az 1), her yeni konuya 2
      final earned =
          max(1, summary.correct ~/ 3) + 2 * summary.newOutcomes.length;
      summary.suppliesEarned = earned;
      progress.game.addSupply(Kingdom.of(subject).material, earned);
    }
  }
}
