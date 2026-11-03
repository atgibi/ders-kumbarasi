/// Bilgelik Diyarı: krallıklar, bölgeler, kahraman yolları, bekçiler, yapılar.
///
/// Oyun verisi sabittir; çocuğun ilerlemesi [GameState]'te tutulur. Her ödül
/// öğrenmeden türetilir (bkz. proje belgesi "Oyun döngüsü ve ekonomi").
library;

import 'dart:ui' show Color;

import '../data/models.dart';

/// Ücretsiz sürümde her krallığın açık bölge sayısı ("ilk 3 bölüm").
const int freeRegionsPerKingdom = 3;

/// Krallık malzemesi (Flutter'ın Material sınıfıyla karışmasın diye Supply).
enum Supply {
  demir('demir', 'Demir', '⛏️'),
  kereste('kereste', 'Kereste', '🪵'),
  ekmek('ekmek', 'Ekmek', '🍞'),
  kristal('kristal', 'Kristal', '💎'),
  kumas('kumas', 'Kumaş', '🧵');

  const Supply(this.id, this.label, this.emoji);
  final String id;
  final String label;
  final String emoji;
}

/// Ana kaynak: doğru cevaplardan gelen ışık.
const String lightEmoji = '✨';
const String bannerEmoji = '🚩';
const String starEmoji = '⭐';

class Kingdom {
  const Kingdom({
    required this.subject,
    required this.name,
    required this.people,
    required this.leader,
    required this.value,
    required this.material,
    required this.emoji,
    required this.color,
    required this.ink,
    required this.signature,
  });

  final Subject subject;
  final String name;
  final String people;
  final String leader;
  final String value;
  final Supply material;
  final String emoji;
  final Color color;
  final Color ink;
  final String signature;

  static Kingdom of(Subject s) => switch (s) {
        Subject.matematik => demirdag,
        Subject.turkce => sozorman,
        Subject.hayatBilgisi => ocakvadi,
        Subject.fenBilimleri => isikkaya,
        Subject.sosyalBilgiler => kervanova,
      };
}

const demirdag = Kingdom(
  subject: Subject.matematik,
  name: 'Demirdağ',
  people: 'Taşyumruk cüceleri',
  leader: 'Usta Çark',
  value: 'Sabır ve düzen',
  material: Supply.demir,
  emoji: '⛰️',
  color: Color(0xFFA8552B),
  ink: Color(0xFF6B3216),
  signature: 'Sayı Saat Kulesi',
);
const sozorman = Kingdom(
  subject: Subject.turkce,
  name: 'Sözorman',
  people: 'Ağaç Ozanları',
  leader: 'Ozan Yaprak',
  value: 'Dürüstlük',
  material: Supply.kereste,
  emoji: '🌳',
  color: Color(0xFF5E7A3A),
  ink: Color(0xFF34481C),
  signature: 'Masal Kitaplığı',
);
const ocakvadi = Kingdom(
  subject: Subject.hayatBilgisi,
  name: 'Ocakvadi',
  people: 'Bostancıklar',
  leader: 'Nine Pelin',
  value: 'Paylaşma',
  material: Supply.ekmek,
  emoji: '🏡',
  color: Color(0xFFB9862A),
  ink: Color(0xFF654510),
  signature: 'Komşu Meydanı',
);
const isikkaya = Kingdom(
  subject: Subject.fenBilimleri,
  name: 'Işıkkaya',
  people: 'Çarkçılar',
  leader: 'Mucit Doküm',
  value: 'Merak',
  material: Supply.kristal,
  emoji: '🔭',
  color: Color(0xFF6E5A9C),
  ink: Color(0xFF3F2F66),
  signature: 'Gökbilim Kulesi',
);
const kervanova = Kingdom(
  subject: Subject.sosyalBilgiler,
  name: 'Kervanova',
  people: 'Kervancılar',
  leader: 'Kervanbaşı Elif',
  value: 'Adalet',
  material: Supply.kumas,
  emoji: '🐫',
  color: Color(0xFF2E7D8A),
  ink: Color(0xFF14505A),
  signature: 'Kervansaray',
);

/// Bir krallık bölgesi: bir ünite/tema (Türkçe'de beceri alanı).
class RegionDef {
  const RegionDef({
    required this.subject,
    required this.grade,
    required this.index,
    required this.outcomes,
  });

  final Subject subject;
  final int grade;

  /// Krallık içindeki sıra (0'dan).
  final int index;
  final List<Outcome> outcomes;

  String get key => regionKey(subject, grade, index);
  bool get premium => index >= freeRegionsPerKingdom;
  Guardian get guardian => guardianFor(subject, index);
}

String regionKey(Subject s, int grade, int index) => '${s.id}-$grade-$index';

/// Bir bölgedeki en fazla çıktı sayısı: büyük üniteler 2–3 haftalık
/// bölümlere bölünür (her bölümün sonunda bir bekçi).
const int maxOutcomesPerRegion = 3;

/// Çıktıları bölgelere ayırır: önce ünite (Türkçe'de beceri alanı), sonra
/// her ünite en fazla [maxOutcomesPerRegion] çıktılık dengeli bölümlere.
List<RegionDef> regionsOf(Subject s, int grade, List<Outcome> outcomes) {
  String keyOf(Outcome o) => o.unit?.toString() ?? o.area ?? '';
  final out = <RegionDef>[];
  var i = 0;
  while (i < outcomes.length) {
    final k = keyOf(outcomes[i]);
    final group = <Outcome>[];
    while (i < outcomes.length && keyOf(outcomes[i]) == k) {
      group.add(outcomes[i++]);
    }
    final parts = (group.length + maxOutcomesPerRegion - 1) ~/ maxOutcomesPerRegion;
    var start = 0;
    for (var p = 0; p < parts; p++) {
      final size = group.length ~/ parts + (p < group.length % parts ? 1 : 0);
      out.add(RegionDef(
          subject: s,
          grade: grade,
          index: out.length,
          outcomes: group.sublist(start, start + size)));
      start += size;
    }
  }
  return out;
}

/// Bölgenin hikâyedeki adı (ünite adı yanında görünür).
String regionTitle(Kingdom k, int index) {
  const names = {
    Subject.matematik: [
      'Dişli Geçidi', 'Örs Köyü', 'Saat Avlusu', 'Maden Ağzı', 'Çark Köprüsü',
      'Demir Pazarı', 'Terazi Kapısı', 'Kule Eteği', 'Kristal Tünel', 'Zirve Ocağı',
    ],
    Subject.turkce: [
      'Yaprak Kapısı', 'Hece Deresi', 'Masal Korusu', 'Söz Köprüsü', 'Kalem Ağacı',
      'Ozan Meydanı', 'Mektup Yolu', 'Kitap Tepesi',
    ],
    Subject.hayatBilgisi: [
      'Ocak Başı', 'Komşu Sokağı', 'Bostan Kapısı', 'Pazar Yeri', 'Değirmen Yolu',
      'Çeşme Başı', 'Hasat Tarlası', 'Sofra Tepesi',
    ],
    Subject.fenBilimleri: [
      'Kristal Kapı', 'Rüzgâr Değirmeni', 'Gözlem Taşı', 'Işık Mağarası',
      'Mıknatıs Tepesi', 'Ses Vadisi', 'Gölge Bahçesi', 'Yıldız Kulesi',
    ],
    Subject.sosyalBilgiler: [
      'Han Kapısı', 'Harita Odası', 'Liman Yolu', 'Pazar Köprüsü', 'Yol Taşı',
      'Kervan Yurdu', 'Bayrak Tepesi', 'Meclis Avlusu',
    ],
  };
  final list = names[k.subject]!;
  return index < list.length ? list[index] : '${k.name} ${index + 1}. Bölge';
}

Guardian guardianFor(Subject s, int index) =>
    guardians[(index + s.index * 3) % guardians.length];

/// Bölge anahtarından bekçi ('matematik-1-2').
Guardian guardianForKey(String key) {
  final parts = key.split('-');
  try {
    return guardianFor(Subject.fromId(parts.first),
        parts.length >= 3 ? int.tryParse(parts[2]) ?? 0 : 0);
  } on ArgumentError {
    return guardians.first;
  }
}

/// Sisin bekçisi: ünite sonunda düelloyla kurtarılır.
class Guardian {
  const Guardian(this.id, this.name, this.emoji, this.thanks);
  final String id;
  final String name;
  final String emoji;
  final String thanks;
}

const guardians = [
  Guardian('golem', 'Taş Golem', '🪨',
      'Teşekkür ederim! Sisin içinde ne kadar yalnızdım.'),
  Guardian('sarmasik', 'Diken Sarmaşık', '🌵',
      'Dikenlerim döküldü, artık çiçek açabilirim!'),
  Guardian('ejder', 'Şaşkın Ejder Yavrusu', '🐉',
      'Annemi bulmama yardım ettin. Seni hiç unutmayacağım!'),
  Guardian('tepegoz', 'Sakar Tepegöz', '👁️',
      'Tek gözümle her şeyi bulanık görüyordum. Şimdi her yer pırıl pırıl!'),
  Guardian('ayi', 'Buz Ayısı', '🐻‍❄️',
      'Sis kalkınca içim ısındı. Kasabana gelebilir miyim?'),
  Guardian('kirpi', 'Dikenli Kirpi', '🦔',
      'Artık kimseye diken göstermeyeceğim. Söz!'),
  Guardian('hayalet', 'Kumaş Hayalet', '👻',
      'Meğer ben bir perdeymişim! Kasabanda pencereni süslerim.'),
  Guardian('baykus', 'Uykucu Baykuş', '🦉',
      'Uyandım! Geceleri kasabanı ben beklerim.'),
];

/// Kahramanın yolu: yalnızca görünüm ve kutlama hareketi; hiçbiri güçlü değil.
class HeroPath {
  const HeroPath(this.id, this.name, this.tool, this.toolEmoji, this.companion,
      this.companionEmoji, this.trait, this.color);
  final String id;
  final String name;
  final String tool;
  final String toolEmoji;
  final String companion;
  final String companionEmoji;
  final String trait;
  final Color color;
}

const heroPaths = [
  HeroPath('sovalye', 'Şövalye', 'Kalkan ve sancak', '🛡️', 'Küçük at', '🐴',
      'Cesur ve korumacı', Color(0xFFB8432F)),
  HeroPath('okcu', 'Okçu', 'Işık okları', '🏹', 'Tilki', '🦊',
      'Dikkatli ve isabetli', Color(0xFF2F7A5B)),
  HeroPath('bilge', 'Bilge', 'Asa ve kitap', '📖', 'Baykuş', '🦉',
      'Meraklı ve sakin', Color(0xFF1F4E79)),
  HeroPath('kasif', 'Kaşif', 'Pusula ve harita', '🧭', 'Dağ keçisi', '🐐',
      'Maceraperest', Color(0xFFA8552B)),
  HeroPath('usta', 'Usta', 'Çekiç ve cetvel', '🔨', 'Kunduz', '🦫',
      'Yaratıcı ve inşacı', Color(0xFF6E5A9C)),
  HeroPath('ozan', 'Ozan', 'Saz', '🪕', 'Serçe', '🐦',
      'Neşeli ve anlatıcı', Color(0xFFB9862A)),
];

const skinTones = [
  Color(0xFFF6D7BF),
  Color(0xFFEBC09E),
  Color(0xFFD49E78),
  Color(0xFFB57E57),
  Color(0xFF8C5A3C),
  Color(0xFF5E3B27),
];

const hairColors = [
  Color(0xFF2B2320),
  Color(0xFF5A3A22),
  Color(0xFF8C5A2B),
  Color(0xFFC99A4B),
  Color(0xFFB8432F),
  Color(0xFF7E7A74),
];

/// Kahramanın gelişim aşaması.
enum HeroStage {
  cirak('Çırak'),
  yolcu('Yolcu'),
  muhafiz('Muhafız'),
  kahraman('Kahraman'),
  efsane('Efsane');

  const HeroStage(this.label);
  final String label;
}

/// Kasaba yapısı. Her seviyenin maliyeti seviyeyle büyür.
class BuildingDef {
  const BuildingDef(this.id, this.name, this.emoji, this.light, this.materials,
      this.note);
  final String id;
  final String name;
  final String emoji;

  /// 1. seviye ışık maliyeti.
  final int light;

  /// 1. seviye malzeme maliyeti.
  final Map<Supply, int> materials;
  final String note;

  static const maxLevel = 3;

  int lightCost(int toLevel) => light * toLevel;
  Map<Supply, int> materialCost(int toLevel) =>
      {for (final e in materials.entries) e.key: e.value * toLevel};
}

const buildings = [
  BuildingDef('ev', 'Kahramanın Evi', '🏠', 15, {Supply.demir: 2},
      'Kasabanın ilk yapısı.'),
  BuildingDef('ocak', 'Kasaba Ocağı', '🔥', 20, {Supply.demir: 3},
      'Ateşi yanınca köylüler gelir.'),
  BuildingDef('firin', 'Fırın', '🍞', 30, {Supply.demir: 2, Supply.ekmek: 3},
      'Fırıncı Hasan Usta burada çalışır.'),
  BuildingDef('demirhane', 'Demirhane', '⚒️', 35, {Supply.demir: 5},
      'Taşyumruk cüceleri ziyarete gelir.'),
  BuildingDef('kitaplik', 'Kitaplık', '📚', 35,
      {Supply.kereste: 4, Supply.demir: 1}, 'Ozanlar masal okur.'),
  BuildingDef('cesme', 'Çeşme', '⛲', 25, {Supply.demir: 2, Supply.kereste: 2},
      'Kurtarılan bekçiler burada dinlenir.'),
  BuildingDef('bahce', 'Bostan', '🌻', 25, {Supply.ekmek: 2, Supply.kereste: 2},
      'Bostancıklar sebze yetiştirir.'),
  BuildingDef('gozlemevi', 'Gözlemevi', '🔭', 45,
      {Supply.kristal: 4, Supply.demir: 2}, 'Geceleri yıldızları sayarsın.'),
  BuildingDef('han', 'Han', '🏨', 45, {Supply.kumas: 4, Supply.kereste: 2},
      'Kervancılar konaklar.'),
];
