import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:ders_kumbarasi/core/srs/leitner.dart';
import 'package:ders_kumbarasi/core/srs/session_planner.dart';

void main() {
  final now = DateTime(2026, 11, 2, 18);

  CardState seen(String id, int box, {int daysOverdue = 0}) => CardState(
        cardId: id,
        box: box,
        due: now.subtract(Duration(days: daysOverdue)),
        reviews: 2,
      );

  const newOutcome = NewOutcomeCandidate(
    outcomeId: 'MAT.1.1.2',
    cardIds: ['n1', 'n2', 'n3', 'n4', 'n5', 'n6', 'n7', 'n8'],
  );

  test('ilk gün: tekrar yok, yeni konu var', () {
    final p = planSession(states: const [], nextNew: newOutcome, now: now);
    expect(p.warmup, isEmpty);
    expect(p.review, isEmpty);
    expect(p.newOutcomeId, 'MAT.1.1.2');
    expect(p.practice, ['n1', 'n2', 'n3', 'n4', 'n5', 'n6']);
    expect(p.isReviewDay, isFalse);
  });

  test('ısınma en yüksek kutulardan, tekrar kalanlardan; çakışma yok', () {
    final states = [
      seen('a', 1, daysOverdue: 3),
      seen('b', 5),
      seen('c', 4),
      seen('d', 2, daysOverdue: 1),
      seen('e', 3),
      seen('f', 1),
    ];
    final p = planSession(
      states: states,
      nextNew: newOutcome,
      now: now,
      random: Random(1),
    );
    expect(p.warmup, ['b', 'c', 'e']);
    expect(p.review.toSet(), {'a', 'd', 'f'});
    expect(p.warmup.toSet().intersection(p.review.toSet()), isEmpty);
  });

  test('vadesi gelmemiş ve hiç görülmemiş kartlar plana girmez', () {
    final states = [
      CardState(
          cardId: 'future',
          box: 3,
          due: now.add(const Duration(days: 2)),
          reviews: 3),
      CardState.fresh('never', now),
    ];
    final p = planSession(states: states, nextNew: null, now: now);
    expect(p.isEmpty, isTrue);
  });

  test('birikmiş tekrar > 20: yeni konu yok, tekrar kotası genişler', () {
    final states = [
      for (var i = 0; i < 30; i++) seen('k$i', 2, daysOverdue: i)
    ];
    final p = planSession(states: states, nextNew: newOutcome, now: now);
    expect(p.isReviewDay, isTrue);
    expect(p.newOutcomeId, isNull);
    expect(p.practice, isEmpty);
    expect(p.warmup.length, 3);
    expect(p.review.length, 16);
  });

  test('tekrar en çok gecikmiş kartları seçer', () {
    final states = [
      for (var i = 0; i < 15; i++) seen('k$i', 1, daysOverdue: i)
    ];
    final p = planSession(
      states: states,
      nextNew: null,
      now: now,
      config: const SessionConfig(warmupCount: 0, maxReview: 5),
    );
    expect(p.review.toSet(), {'k14', 'k13', 'k12', 'k11', 'k10'});
  });
}
