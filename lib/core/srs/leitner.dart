/// Çocuklara uyarlanmış 7 kutulu Leitner aralıklı tekrar motoru.
///
/// Kurallar (proje planı 4.3):
/// - Doğru ve hızlı  -> bir kutu yukarı.
/// - Doğru ama yavaş / ipucuyla -> aynı kutuda kalır, aralık yeniden başlar.
/// - Yanlış -> kutu 1'e düşer (0'a değil) ve aynı oturumda tekrar sorulur.
library;

/// Bir cevabın motor açısından sonucu.
enum ReviewOutcome { correctFast, correctSlow, wrong }

/// Kutu numarasına göre bir sonraki tekrara kadar geçecek gün sayısı.
/// Kutu 0: aynı oturum (0 gün). Kutu 6: dönem sonu kontrolü (90 gün).
const List<int> boxIntervalsDays = [0, 1, 3, 7, 16, 35, 90];

const int minBox = 0;
const int maxBox = 6;

/// Bu kutu ve üstündeki kartlar "öğrenilmiş" sayılır (çıktı yeterliliği için).
const int masteredFromBox = 4;

/// Bir çıktının "yeterli" sayılması için öğrenilmiş kart oranı.
const double outcomeMasteryRatio = 0.8;

class CardState {
  const CardState({
    required this.cardId,
    required this.box,
    required this.due,
    this.lastReviewed,
    this.reviews = 0,
    this.lapses = 0,
  });

  /// Hiç görülmemiş yeni kart: kutu 0, hemen vadesi gelmiş.
  factory CardState.fresh(String cardId, DateTime now) =>
      CardState(cardId: cardId, box: 0, due: now);

  final String cardId;
  final int box;
  final DateTime due;
  final DateTime? lastReviewed;
  final int reviews;
  final int lapses;

  bool get isNew => reviews == 0;
  bool get isMastered => box >= masteredFromBox;

  bool isDue(DateTime now) => !due.isAfter(now);

  CardState copyWith({
    int? box,
    DateTime? due,
    DateTime? lastReviewed,
    int? reviews,
    int? lapses,
  }) =>
      CardState(
        cardId: cardId,
        box: box ?? this.box,
        due: due ?? this.due,
        lastReviewed: lastReviewed ?? this.lastReviewed,
        reviews: reviews ?? this.reviews,
        lapses: lapses ?? this.lapses,
      );

  Map<String, Object?> toJson() => {
        'id': cardId,
        'b': box,
        'd': due.toIso8601String(),
        if (lastReviewed != null) 'l': lastReviewed!.toIso8601String(),
        'r': reviews,
        'x': lapses,
      };

  factory CardState.fromJson(Map<String, Object?> j) => CardState(
        cardId: j['id']! as String,
        box: (j['b']! as num).toInt(),
        due: DateTime.parse(j['d']! as String),
        lastReviewed: j['l'] == null ? null : DateTime.parse(j['l']! as String),
        reviews: (j['r'] as num?)?.toInt() ?? 0,
        lapses: (j['x'] as num?)?.toInt() ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      other is CardState &&
      other.cardId == cardId &&
      other.box == box &&
      other.due == due &&
      other.lastReviewed == lastReviewed &&
      other.reviews == reviews &&
      other.lapses == lapses;

  @override
  int get hashCode =>
      Object.hash(cardId, box, due, lastReviewed, reviews, lapses);

  @override
  String toString() =>
      'CardState($cardId, box=$box, due=$due, reviews=$reviews, lapses=$lapses)';
}

/// Günün başlangıcı (yerel saat, 04:00). Gece geç saatte çalışan çocuk için
/// "yarın" sabah 4'te başlar; böylece 23:30'da çözülen kart 00:10'da tekrar
/// vadesi gelmiş görünmez.
DateTime dayStart(DateTime t) {
  final shifted = t.subtract(const Duration(hours: 4));
  return DateTime(shifted.year, shifted.month, shifted.day, 4);
}

/// Bir kutu için vade tarihini hesaplar. Gün aralıkları günün başlangıcına
/// göre sayılır; kutu 0 aynı an (aynı oturum) demektir.
DateTime dueFor(int box, DateTime now) {
  final days = boxIntervalsDays[box];
  if (days == 0) return now;
  final start = dayStart(now);
  return DateTime(start.year, start.month, start.day + days, 4);
}

/// Bir cevabı uygular ve yeni durumu döndürür. Saf fonksiyon.
CardState review(CardState s, ReviewOutcome outcome, DateTime now) {
  switch (outcome) {
    case ReviewOutcome.correctFast:
      final nb = (s.box + 1).clamp(minBox, maxBox);
      return s.copyWith(
        box: nb,
        due: dueFor(nb, now),
        lastReviewed: now,
        reviews: s.reviews + 1,
      );
    case ReviewOutcome.correctSlow:
      // Yeni kart yavaş doğru: kutu 1'e çıkar ama hızlanmaz.
      final nb = s.box == 0 ? 1 : s.box;
      return s.copyWith(
        box: nb,
        due: dueFor(nb, now),
        lastReviewed: now,
        reviews: s.reviews + 1,
      );
    case ReviewOutcome.wrong:
      // Kutu 1'e düşer ama vadesi "şimdi": oturum sonunda tekrar sorulur.
      return s.copyWith(
        box: s.box == 0 ? 0 : 1,
        due: now,
        lastReviewed: now,
        reviews: s.reviews + 1,
        lapses: s.reviews == 0 ? s.lapses : s.lapses + 1,
      );
  }
}

/// Bir cevabı süre ve ipucu bilgisinden sınıflandırır.
ReviewOutcome classify({
  required bool correct,
  required Duration elapsed,
  required Duration fastThreshold,
  bool usedHint = false,
}) {
  if (!correct) return ReviewOutcome.wrong;
  if (usedHint || elapsed > fastThreshold) return ReviewOutcome.correctSlow;
  return ReviewOutcome.correctFast;
}

/// Öğrenme çıktısı düzeyi (veli raporu dili; not/puan yok).
enum MasteryLevel { notStarted, beginning, developing, sufficient }

MasteryLevel outcomeMastery(Iterable<CardState> cards) {
  final list = cards.toList();
  if (list.isEmpty || list.every((c) => c.isNew)) {
    return MasteryLevel.notStarted;
  }
  final mastered = list.where((c) => c.isMastered).length;
  if (mastered / list.length >= outcomeMasteryRatio) {
    return MasteryLevel.sufficient;
  }
  final progressing = list.where((c) => c.box >= 2).length;
  if (progressing / list.length >= 0.5) return MasteryLevel.developing;
  return MasteryLevel.beginning;
}
