/// Çocuğun oyun durumu: kahraman, malzemeler, yapılar, sancaklar, defter.
///
/// [ChildProgress] içinde saklanır; böylece yedekleme ve geri yükleme oyunu
/// da kapsar. Işık, eski sürümlerin "fındık" sayacıdır ([ChildProgress.nuts]).
library;

import 'quests.dart';
import 'world.dart';

class HeroLook {
  const HeroLook({
    required this.girl,
    required this.path,
    this.skin = 1,
    this.hair = 0,
    this.hairColor = 1,
    this.accessory = 0,
    this.chair = false,
    this.name,
  });

  final bool girl;

  /// [heroPaths] sırası.
  final int path;
  final int skin;

  /// Saç biçimi (tasarımdaki 12 biçim; bkz. hero_svg.dart hairStyles).
  final int hair;
  final int hairColor;

  /// 0 yok, 1 gözlük, 2 şapka, 3 başörtüsü.
  final int accessory;

  /// Tekerlekli sandalye.
  final bool chair;

  /// Kahramana çocuğun verdiği ayrı ad (yoksa takma ad kullanılır).
  final String? name;

  HeroPath get heroPath => heroPaths[path.clamp(0, heroPaths.length - 1)];

  HeroLook copyWith({
    bool? girl,
    int? path,
    int? skin,
    int? hair,
    int? hairColor,
    int? accessory,
    bool? chair,
  }) =>
      HeroLook(
        girl: girl ?? this.girl,
        path: path ?? this.path,
        skin: skin ?? this.skin,
        hair: hair ?? this.hair,
        hairColor: hairColor ?? this.hairColor,
        accessory: accessory ?? this.accessory,
        chair: chair ?? this.chair,
        name: name,
      );

  Map<String, Object?> toJson() => {
        'v': 2,
        'g': girl ? 'k' : 'e',
        'p': path,
        's': skin,
        'h': hair,
        'hc': hairColor,
        if (accessory != 0) 'a': accessory,
        if (chair) 'ts': 1,
        if (name != null) 'n': name,
      };

  static HeroLook? fromJson(Object? j) {
    if (j is! Map) return null;
    int n(String k, int d) => (j[k] as num?)?.toInt() ?? d;
    var hair = n('h', 0), hc = n('hc', 1), acc = n('a', 0);
    if (j['v'] != 2) {
      // İlk sürüm: 6 saç (kısa, uzun, örgü, kıvırcık, başörtüsü, şapka) ve
      // 6 saç rengi. Tasarımdaki karşılıklarına taşınır.
      final old = hair;
      hair = const [0, 7, 4, 2, 0, 0][old.clamp(0, 5)];
      if (old == 4) acc = 3;
      if (old == 5) acc = 2;
      hc = const [0, 1, 3, 6, 4, 7][hc.clamp(0, 5)];
    }
    return HeroLook(
      girl: j['g'] == 'k',
      path: n('p', 0).clamp(0, heroPaths.length - 1),
      skin: n('s', 1).clamp(0, skinTones.length - 1),
      hair: hair.clamp(0, 11),
      hairColor: hc.clamp(0, hairColors.length - 1),
      accessory: acc.clamp(0, 3),
      chair: j['ts'] == 1,
      name: j['n'] as String?,
    );
  }
}

/// Kahraman Defteri'nin bir sayfası.
class NotebookPage {
  const NotebookPage(this.day, this.text);
  final String day;
  final String text;

  List<String> toJson() => [day, text];
}

class GameState {
  GameState({
    this.hero,
    Map<String, int>? supplies,
    Map<String, int>? built,
    Set<String>? banners,
    Map<String, int>? duelBest,
    List<String>? rescued,
    List<NotebookPage>? notebook,
    this.board,
    this.trip,
    List<Letter>? letters,
  })  : supplies = supplies ?? {},
        letters = letters ?? [],
        built = built ?? {},
        banners = banners ?? {},
        duelBest = duelBest ?? {},
        rescued = rescued ?? [],
        notebook = notebook ?? [];

  HeroLook? hero;

  /// Malzeme kimliği -> adet.
  final Map<String, int> supplies;

  /// Yapı kimliği -> seviye (1..3).
  final Map<String, int> built;

  /// Kurtarılan bölgeler (bölge anahtarları).
  final Set<String> banners;

  /// Bölge -> düelloda ilk denemede doğru yüzdesi (en iyisi).
  final Map<String, int> duelBest;

  /// Kurtarılan bekçiler (bölge anahtarı, kurtarılma sırasıyla).
  final List<String> rescued;
  final List<NotebookPage> notebook;

  /// Günün istek panosu (gün değişince yenilenir).
  DailyBoard? board;

  /// Bu haftanın seferi.
  WeeklyTrip? trip;

  /// Gelen mektuplar (en yenisi sonda).
  final List<Letter> letters;

  int get unreadLetters => letters.where((l) => !l.read).length;

  /// Aynı kimlikli mektup bir kez gelir.
  bool addLetter(Letter l) {
    if (letters.any((x) => x.id == l.id)) return false;
    letters.add(l);
    if (letters.length > 200) letters.removeRange(0, letters.length - 200);
    return true;
  }

  int supply(Supply s) => supplies[s.id] ?? 0;
  void addSupply(Supply s, int n) => supplies[s.id] = (supplies[s.id] ?? 0) + n;

  int levelOf(BuildingDef b) => built[b.id] ?? 0;

  void addPage(String day, String text) {
    notebook.add(NotebookPage(day, text));
    if (notebook.length > 400) notebook.removeRange(0, notebook.length - 400);
  }

  Map<String, Object?> toJson() => {
        if (hero != null) 'hero': hero!.toJson(),
        'sup': supplies,
        'built': built,
        'ban': banners.toList()..sort(),
        'duel': duelBest,
        'res': rescued,
        'book': [for (final p in notebook) p.toJson()],
        if (board != null) 'board': board!.toJson(),
        if (trip != null) 'trip': trip!.toJson(),
        'mail': [for (final l in letters) l.toJson()],
      };

  factory GameState.fromJson(Object? raw) {
    if (raw is! Map) return GameState();
    Map<String, int> ints(Object? m) => m is Map
        ? {for (final e in m.entries) '${e.key}': (e.value as num).toInt()}
        : {};
    return GameState(
      hero: HeroLook.fromJson(raw['hero']),
      supplies: ints(raw['sup']),
      built: ints(raw['built']),
      banners: {...?(raw['ban'] as List?)?.map((e) => '$e')},
      duelBest: ints(raw['duel']),
      rescued: [...?(raw['res'] as List?)?.map((e) => '$e')],
      notebook: [
        for (final p in (raw['book'] as List? ?? const []))
          if (p is List && p.length >= 2) NotebookPage('${p[0]}', '${p[1]}'),
      ],
      board: DailyBoard.fromJson(raw['board']),
      trip: WeeklyTrip.fromJson(raw['trip']),
      letters: [
        for (final l in (raw['mail'] as List? ?? const [])) Letter.fromJson(l),
      ].whereType<Letter>().toList(),
    );
  }
}

/// Aşama: başlanan çıktı, kurtarılan bölge ve "yeterli" çıktı sayısından.
HeroStage stageFor(
    {required int started, required int banners, required int mastered}) {
  if (mastered >= 25) return HeroStage.kahraman;
  if (banners >= 2) return HeroStage.muhafiz;
  if (started >= 10) return HeroStage.yolcu;
  return HeroStage.cirak;
}

/// Bir sonraki aşamanın koşulu (çocuğa gösterilir).
String nextStageHint(HeroStage s) => switch (s) {
      HeroStage.cirak => '10 konuya başla, Yolcu ol.',
      HeroStage.yolcu => '2 bölgeyi kurtar, Muhafız ol.',
      HeroStage.muhafiz => '25 konuyu iyice öğren, Kahraman ol.',
      HeroStage.kahraman => 'Yıl sonu düellosunu kazan, Efsane ol.',
      HeroStage.efsane => 'Sen bir efsanesin!',
    };
