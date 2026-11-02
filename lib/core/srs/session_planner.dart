/// Günlük oturum planlayıcısı (proje planı 4.2).
///
/// Oturum: ısınma (kolay tekrar) -> yeni konu + uygulama -> tekrar -> kapanış.
/// Vadesi geçmiş kart sayısı [backlogLimit]'i aşarsa o gün yeni konu verilmez.
library;

import 'dart:math';

import 'leitner.dart';

class NewOutcomeCandidate {
  const NewOutcomeCandidate({required this.outcomeId, required this.cardIds});
  final String outcomeId;
  final List<String> cardIds;
}

class SessionPlan {
  const SessionPlan({
    required this.warmup,
    required this.newOutcomeId,
    required this.practice,
    required this.review,
    required this.isReviewDay,
  });

  final List<String> warmup;
  final String? newOutcomeId;
  final List<String> practice;
  final List<String> review;

  /// Birikmiş tekrar yüzünden yeni konu verilmeyen gün.
  final bool isReviewDay;

  int get totalCards => warmup.length + practice.length + review.length;
  bool get isEmpty => totalCards == 0 && newOutcomeId == null;
}

class SessionConfig {
  const SessionConfig({
    this.warmupCount = 3,
    this.practiceCount = 6,
    this.maxReview = 10,
    this.backlogLimit = 20,
  });

  final int warmupCount;
  final int practiceCount;
  final int maxReview;
  final int backlogLimit;
}

SessionPlan planSession({
  required Iterable<CardState> states,
  required NewOutcomeCandidate? nextNew,
  required DateTime now,
  SessionConfig config = const SessionConfig(),
  Random? random,
}) {
  final rnd = random ?? Random();

  // Vadesi gelmiş, daha önce görülmüş kartlar (yeni kartlar planlayıcıya
  // nextNew ile gelir).
  final due = states.where((s) => !s.isNew && s.isDue(now)).toList()
    ..sort((a, b) {
      final c = a.due.compareTo(b.due); // en çok gecikmiş önce
      return c != 0 ? c : a.cardId.compareTo(b.cardId);
    });

  final isReviewDay = due.length > config.backlogLimit;

  // Isınma: vadesi gelenler arasından en yüksek kutudakiler (en kolaylar).
  final byEase = [...due]..sort((a, b) {
      final c = b.box.compareTo(a.box);
      return c != 0 ? c : a.due.compareTo(b.due);
    });
  final warmup = byEase.take(config.warmupCount).map((s) => s.cardId).toList();
  final warmupSet = warmup.toSet();

  // Tekrar: kalan vadesi gelmiş kartlar, en çok gecikmiş önce; yeni konu
  // olmayan günde tekrar kotası, yeni konu payı kadar genişler.
  final reviewQuota =
      isReviewDay ? config.maxReview + config.practiceCount : config.maxReview;
  final review = due
      .where((s) => !warmupSet.contains(s.cardId))
      .take(reviewQuota)
      .map((s) => s.cardId)
      .toList()
    ..shuffle(rnd); // karışık sıralama (interleaving)

  String? newOutcomeId;
  var practice = <String>[];
  if (!isReviewDay && nextNew != null && nextNew.cardIds.isNotEmpty) {
    newOutcomeId = nextNew.outcomeId;
    practice = nextNew.cardIds.take(config.practiceCount).toList();
  }

  return SessionPlan(
    warmup: warmup,
    newOutcomeId: newOutcomeId,
    practice: practice,
    review: review,
    isReviewDay: isReviewDay,
  );
}
