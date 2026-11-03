/// Çocuğun oyun durumu: kahraman, malzemeler, yapılar, sancaklar, defter.
///
/// [ChildProgress] içinde saklanır; böylece yedekleme ve geri yükleme oyunu
/// da kapsar. Işık, eski sürümlerin "fındık" sayacıdır ([ChildProgress.nuts]).
library;

import 'world.dart';

class HeroLook {
  const HeroLook({
    required this.girl,
    required this.path,
    this.skin = 1,
    this.hair = 0,
    this.hairColor = 0,
    this.name,
  });

  final bool girl;

  /// [heroPaths] sırası.
  final int path;
  final int skin;

  /// Saç biçimi (0 kısa, 1 uzun, 2 örgü, 3 kıvırcık, 4 başörtüsü, 5 şapka).
  final int hair;
  final int hairColor;

  /// Kahramana çocuğun verdiği ayrı ad (yoksa takma ad kullanılır).
  final String? name;

  HeroPath get heroPath => heroPaths[path.clamp(0, heroPaths.length - 1)];

  HeroLook copyWith({
    bool? girl,
    int? path,
    int? skin,
    int? hair,
    int? hairColor,
  }) =>
      HeroLook(
        girl: girl ?? this.girl,
        path: path ?? this.path,
        skin: skin ?? this.skin,
        hair: hair ?? this.hair,
        hairColor: hairColor ?? this.hairColor,
        name: name,
      );

  Map<String, Object?> toJson() => {
        'g': girl ? 'k' : 'e',
        'p': path,
        's': skin,
        'h': hair,
        'hc': hairColor,
        if (name != null) 'n': name,
      };

  static HeroLook? fromJson(Object? j) {
    if (j is! Map) return null;
    int n(String k, int d) => (j[k] as num?)?.toInt() ?? d;
    return HeroLook(
      girl: j['g'] == 'k',
      path: n('p', 0).clamp(0, heroPaths.length - 1),
      skin: n('s', 1).clamp(0, skinTones.length - 1),
      hair: n('h', 0).clamp(0, 5),
      hairColor: n('hc', 0).clamp(0, hairColors.length - 1),
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
  })  : supplies = supplies ?? {},
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
