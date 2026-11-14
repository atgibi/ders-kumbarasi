/// Süreklilik: kasaba istek panosu, haftalık sefer ve mektuplar.
///
/// Hepsi öğrenmeden beslenir: istekler oturum, doğru cevap, yeni konu ve
/// tekrar sayılarıyla dolar. Ceza yoktur; kaçırılan gün hiçbir şey eksiltmez.
library;

import 'dart:math';

import 'turkish.dart';
import 'world.dart';

enum QuestKind {
  session('s'),
  correct('c'),
  newTopic('n'),
  review('r');

  const QuestKind(this.id);
  final String id;

  static QuestKind fromId(String id) =>
      values.firstWhere((k) => k.id == id, orElse: () => session);
}

/// Kasaba halkı: istekleri getirenler.
class Townsfolk {
  const Townsfolk(this.name, this.emoji, [this.art]);
  final String name;
  final String emoji;

  /// Tasarımda çizimi varsa varlık yolu.
  final String? art;
}

const townsfolk = [
  Townsfolk('Fırıncı Hasan', '🧑‍🍳', 'assets/onder/hasan.svg'),
  Townsfolk('Postacı Lale', '📮'),
  Townsfolk('Bahçıvan Ömer', '🧑‍🌾'),
  Townsfolk('Kütüphaneci Nur', '📚'),
  Townsfolk('Demirci Ayşe', '⚒️'),
  Townsfolk('Çoban Mert', '🐑'),
];

/// Panodaki bir istek. Kalıcı biçimi kısa bir listedir.
class Quest {
  const Quest(this.kind, this.target, this.folk, this.supply);

  final QuestKind kind;
  final int target;

  /// [townsfolk] sırası.
  final int folk;
  final Supply supply;

  Townsfolk get who => townsfolk[folk.clamp(0, townsfolk.length - 1)];

  /// Ödül: hedefe göre ışık ve malzeme.
  int get light => switch (kind) {
        QuestKind.session => 3,
        QuestKind.correct => 5,
        QuestKind.newTopic => 6,
        QuestKind.review => 5,
      };
  int get qty => kind == QuestKind.session ? 1 : 2;

  String get task => switch (kind) {
        QuestKind.session =>
          target == 1 ? 'Bugün bir bölgede çalış.' : 'Bugün $target kez çalış.',
        QuestKind.correct => '$target soruyu doğru çöz.',
        QuestKind.newTopic => 'Yeni bir konu öğren.',
        QuestKind.review => 'Gök Adaları\'nda $target kart tekrar et.',
      };

  /// Kasabalının ağzından istek.
  String get plea => switch (kind) {
        QuestKind.session => 'Yolun açık olsun! Dönüşte uğrar mısın?',
        QuestKind.correct => 'Hesabım karıştı, doğru cevaplara ihtiyacım var.',
        QuestKind.newTopic => 'Yeni bir şey öğrenirsen bana da anlatır mısın?',
        QuestKind.review => 'Adalardaki bilgiler unutulmasın, bakar mısın?',
      };

  List<Object> toJson() => [kind.id, target, folk, supply.id];

  static Quest? fromJson(Object? j) {
    if (j is! List || j.length < 4) return null;
    return Quest(
      QuestKind.fromId('${j[0]}'),
      (j[1] as num).toInt(),
      (j[2] as num).toInt(),
      Supply.values
          .firstWhere((s) => s.id == '${j[3]}', orElse: () => Supply.demir),
    );
  }
}

int _seed(String s) {
  var h = 17;
  for (final c in s.codeUnits) {
    h = (h * 31 + c) & 0x3fffffff;
  }
  return h;
}

/// Günün üç isteği. Aynı gün ve çocuk için hep aynıdır. [reviewReady] doğruysa
/// (bekleyen en az 5 tekrar kartı varsa) üçüncü istek tekrar olabilir;
/// yoksa yeni konu ya da ikinci oturum istenir.
List<Quest> makeDailyQuests(String day, String seed,
    {required bool reviewReady, required bool newTopicReady}) {
  final r = Random(_seed('$day|$seed'));
  final folk = List.generate(townsfolk.length, (i) => i)..shuffle(r);
  Supply sup() => Supply.values[r.nextInt(Supply.values.length)];
  final third = <(QuestKind, int)>[
    if (reviewReady) (QuestKind.review, 5),
    if (newTopicReady) (QuestKind.newTopic, 1),
    (QuestKind.session, 2),
  ];
  final t = third[r.nextInt(third.length)];
  return [
    Quest(QuestKind.session, 1, folk[0], sup()),
    Quest(QuestKind.correct, const [8, 10, 12][r.nextInt(3)], folk[1], sup()),
    Quest(t.$1, t.$2, folk[2], sup()),
  ];
}

/// Günün pano durumu.
class DailyBoard {
  DailyBoard(this.day, this.quests,
      {Map<String, int>? counts, Set<int>? claimed})
      : counts = counts ?? {},
        claimed = claimed ?? {};

  final String day;
  final List<Quest> quests;

  /// QuestKind.id -> bugünkü sayı.
  final Map<String, int> counts;
  final Set<int> claimed;

  int progressOf(Quest q) => min(counts[q.kind.id] ?? 0, q.target);
  bool isDone(int i) => progressOf(quests[i]) >= quests[i].target;
  bool canClaim(int i) => isDone(i) && !claimed.contains(i);

  void add(QuestKind k, int n) {
    if (n <= 0) return;
    counts[k.id] = (counts[k.id] ?? 0) + n;
  }

  Map<String, Object?> toJson() => {
        'd': day,
        'q': [for (final q in quests) q.toJson()],
        'c': counts,
        'k': claimed.toList()..sort(),
      };

  static DailyBoard? fromJson(Object? j) {
    if (j is! Map || j['d'] == null) return null;
    final qs = [
      for (final q in (j['q'] as List? ?? const [])) Quest.fromJson(q),
    ].whereType<Quest>().toList();
    if (qs.isEmpty) return null;
    return DailyBoard(
      '${j['d']}',
      qs,
      counts:
          (j['c'] as Map?)?.map((k, v) => MapEntry('$k', (v as num).toInt())),
      claimed: {...?(j['k'] as List?)?.map((e) => (e as num).toInt())},
    );
  }
}

/// Haftalık sefer: haftada [weeklyGoalDays] farklı gün çalışmak.
const int weeklyGoalDays = 4;

class WeeklyTrip {
  WeeklyTrip(this.week, {Set<String>? days, this.claimed = false})
      : days = days ?? {};

  /// Haftanın pazartesisinin gün anahtarı.
  final String week;
  final Set<String> days;
  bool claimed;

  bool get done => days.length >= weeklyGoalDays;
  bool get canClaim => done && !claimed;

  Map<String, Object?> toJson() =>
      {'w': week, 'd': days.toList()..sort(), 'k': claimed};

  static WeeklyTrip? fromJson(Object? j) {
    if (j is! Map || j['w'] == null) return null;
    return WeeklyTrip('${j['w']}',
        days: {...?(j['d'] as List?)?.map((e) => '$e')},
        claimed: j['k'] == true);
  }

  /// Seferin önderi: hafta anahtarından sırayla krallıklar.
  Kingdom get leaderKingdom => allKingdoms[_seed(week) % allKingdoms.length];
}

/// Kasabaya gelen mektup.
class Letter {
  Letter(this.id, this.from, this.emoji, this.text, this.day,
      {this.read = false});

  final String id;
  final String from;
  final String emoji;
  final String text;
  final String day;
  bool read;

  List<Object> toJson() => [id, from, emoji, text, day, read ? 1 : 0];

  static Letter? fromJson(Object? j) {
    if (j is! List || j.length < 6) return null;
    return Letter('${j[0]}', '${j[1]}', '${j[2]}', '${j[3]}', '${j[4]}',
        read: j[5] == 1);
  }
}

/// Bekçinin kurtarıldıktan sonra yazdığı mektup.
Letter guardianLetter(Guardian g, String regionKey, String hero, String day) =>
    Letter(
      'g:$regionKey',
      g.name,
      g.emoji,
      'Sevgili $hero,\n\n${g.thanks} Kasabanda bana bir köşe ayırdığın için '
          'çok mutluyum. Bir sonraki bölgede de sis var; orada da seni '
          'bekleyen biri olabilir. Ben buradan sana el sallayacağım!\n\n'
          'Sevgiyle,\n${g.name}',
      day,
    );

/// Haftalık sefer tamamlanınca krallık önderinin mektubu.
Letter leaderLetter(
        Kingdom k, String week, String hero, int days, String day) =>
    Letter(
      'w:$week',
      k.leader,
      k.emoji,
      'Sevgili $hero,\n\nBu hafta $days gün yola çıktın. ${k.people} '
          'senin sebatını konuşuyor! ${locative(k.name)} bir söz vardır: '
          '“${k.value}.” Sen bu sözün hakkını verdin.\n\n'
          'Gelecek haftanın seferinde görüşmek üzere,\n${k.leader}',
      day,
    );

/// Kahraman oluşturulunca Anka'nın hoş geldin mektubu.
Letter welcomeLetter(String hero, String day) => Letter(
      'hos-geldin',
      'Anka',
      '🔥',
      'Sevgili $hero,\n\nBilgelik Diyarı\'na hoş geldin! Krallıkları sis '
          'kapladı; her öğrendiğin konu sisi biraz dağıtacak. Kasabadaki '
          'istek panosuna her gün bak: komşuların sana iş bırakır. Haftada '
          '$weeklyGoalDays gün yola çıkarsan bir önder sana mektup yazar.\n\n'
          'Yolun açık olsun,\nAnka',
      day,
    );
