import 'package:flutter_test/flutter_test.dart';

import 'package:ders_kumbarasi/core/srs/leitner.dart';

void main() {
  final t0 = DateTime(2026, 11, 2, 18, 0); // Pazartesi 18:00

  group('dayStart / dueFor', () {
    test('gün başlangıcı sabah 4', () {
      expect(dayStart(DateTime(2026, 11, 2, 18)), DateTime(2026, 11, 2, 4));
      // Gece 02:00 hâlâ önceki güne sayılır
      expect(dayStart(DateTime(2026, 11, 3, 2)), DateTime(2026, 11, 2, 4));
      expect(dayStart(DateTime(2026, 11, 3, 4)), DateTime(2026, 11, 3, 4));
    });

    test('kutu aralıkları', () {
      expect(dueFor(0, t0), t0);
      expect(dueFor(1, t0), DateTime(2026, 11, 3, 4));
      expect(dueFor(2, t0), DateTime(2026, 11, 5, 4));
      expect(dueFor(3, t0), DateTime(2026, 11, 9, 4));
      expect(dueFor(4, t0), DateTime(2026, 11, 18, 4));
      expect(dueFor(5, t0), DateTime(2026, 12, 7, 4));
      expect(dueFor(6, t0), DateTime(2027, 1, 31, 4));
    });

    test('gece 00:30 hâlâ önceki güne sayılır: kutu 1 vadesi sabah 04:00', () {
      final late = DateTime(2026, 11, 3, 0, 30); // pazartesi gecesi
      expect(dueFor(1, late), DateTime(2026, 11, 3, 4));
    });

    test('ay ve yıl geçişleri', () {
      expect(dueFor(5, DateTime(2026, 12, 20, 10)), DateTime(2027, 1, 24, 4));
    });
  });

  group('review', () {
    test('yeni kart hızlı doğru -> kutu 1, yarın', () {
      final s = review(CardState.fresh('c', t0), ReviewOutcome.correctFast, t0);
      expect(s.box, 1);
      expect(s.due, DateTime(2026, 11, 3, 4));
      expect(s.reviews, 1);
      expect(s.lapses, 0);
      expect(s.lastReviewed, t0);
    });

    test('hızlı doğru her seferinde bir kutu çıkar, 6da durur', () {
      var s = CardState.fresh('c', t0);
      for (var i = 0; i < 10; i++) {
        s = review(s, ReviewOutcome.correctFast, t0);
      }
      expect(s.box, maxBox);
      expect(s.reviews, 10);
    });

    test('yavaş doğru kutuyu değiştirmez (yeni kart hariç)', () {
      final base = CardState(cardId: 'c', box: 3, due: t0, reviews: 4);
      final s = review(base, ReviewOutcome.correctSlow, t0);
      expect(s.box, 3);
      expect(s.due, dueFor(3, t0));
      final fresh = review(CardState.fresh('c', t0), ReviewOutcome.correctSlow, t0);
      expect(fresh.box, 1);
    });

    test('yanlış -> kutu 1 ve hemen vadesi gelir, unutma sayılır', () {
      final base = CardState(cardId: 'c', box: 5, due: t0, reviews: 7);
      final s = review(base, ReviewOutcome.wrong, t0);
      expect(s.box, 1);
      expect(s.due, t0);
      expect(s.isDue(t0), isTrue);
      expect(s.lapses, 1);
    });

    test('yeni kartta ilk yanlış unutma sayılmaz, kutu 0da kalır', () {
      final s = review(CardState.fresh('c', t0), ReviewOutcome.wrong, t0);
      expect(s.box, 0);
      expect(s.lapses, 0);
    });
  });

  group('classify', () {
    const fast = Duration(seconds: 10);
    test('yanlış', () {
      expect(
        classify(correct: false, elapsed: Duration.zero, fastThreshold: fast),
        ReviewOutcome.wrong,
      );
    });
    test('hızlı', () {
      expect(
        classify(correct: true, elapsed: const Duration(seconds: 4), fastThreshold: fast),
        ReviewOutcome.correctFast,
      );
    });
    test('yavaş veya ipuçlu', () {
      expect(
        classify(correct: true, elapsed: const Duration(seconds: 30), fastThreshold: fast),
        ReviewOutcome.correctSlow,
      );
      expect(
        classify(
          correct: true,
          elapsed: const Duration(seconds: 2),
          fastThreshold: fast,
          usedHint: true,
        ),
        ReviewOutcome.correctSlow,
      );
    });
  });

  group('JSON', () {
    test('gidiş-dönüş', () {
      final s = CardState(
        cardId: 'MAT.1.1.1#3',
        box: 4,
        due: DateTime(2026, 11, 18, 4),
        lastReviewed: t0,
        reviews: 9,
        lapses: 2,
      );
      expect(CardState.fromJson(s.toJson()), s);
      final fresh = CardState.fresh('x', t0);
      expect(CardState.fromJson(fresh.toJson()), fresh);
    });
  });

  group('outcomeMastery', () {
    CardState c(int box, {int reviews = 3}) =>
        CardState(cardId: 'c$box$reviews', box: box, due: t0, reviews: reviews);

    test('hiç başlanmamış', () {
      expect(outcomeMastery([]), MasteryLevel.notStarted);
      expect(outcomeMastery([c(0, reviews: 0)]), MasteryLevel.notStarted);
    });
    test('yeterli: %80 kutu 4+', () {
      expect(outcomeMastery([c(4), c(5), c(6), c(4), c(1)]), MasteryLevel.sufficient);
    });
    test('gelişiyor: yarısı kutu 2+', () {
      expect(outcomeMastery([c(2), c(3), c(1), c(0)]), MasteryLevel.developing);
    });
    test('başlangıç', () {
      expect(outcomeMastery([c(1), c(1), c(0), c(2)]), MasteryLevel.beginning);
    });
  });
}
