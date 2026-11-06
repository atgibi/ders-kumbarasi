/// Kahraman eşyaları ve yol arkadaşının büyümesi.
///
/// Her kurtarılan bölge bir eşya açar (sırayla [items]). Çocuk açılan
/// eşyaları giysi dolabında yuvalara takar; takılanlar kahraman çiziminde
/// görünür. Yol arkadaşı kurtarılan bölge sayısıyla üç aşamada büyür.
library;

import 'game_state.dart';

enum ItemSlot {
  bas('Baş'),
  sirt('Sırt'),
  el('El'),
  boyun('Boyun'),
  rozet('Rozet');

  const ItemSlot(this.label);
  final String label;
}

class ItemDef {
  const ItemDef(this.id, this.name, this.slot, this.note);
  final String id;
  final String name;
  final ItemSlot slot;
  final String note;
}

/// Açılma sırası: yuvalar dönüşümlü, böylece ilk bölgelerde her yuvaya
/// bir eşya gelir.
const items = [
  ItemDef(
      'atki', 'Kırmızı Atkı', ItemSlot.boyun, 'Soğuk dağ yollarında ısıtır.'),
  ItemDef('rozet_yildiz', 'Yıldız Rozeti', ItemSlot.rozet,
      'İlk kurtardığın bölgeyi hatırlatır.'),
  ItemDef('cicek_taci', 'Çiçek Tacı', ItemSlot.bas,
      'Bostancıklar senin için ördü.'),
  ItemDef('fener', 'Yol Feneri', ItemSlot.el, 'Sisin içinde yolu gösterir.'),
  ItemDef('canta', 'Gezgin Çantası', ItemSlot.sirt,
      'İçinde harita, kalem ve bir dilim ekmek var.'),
  ItemDef('madalyon', 'Altın Madalyon', ItemSlot.boyun,
      'Taşyumruk cüceleri dövdü.'),
  ItemDef('rozet_yaprak', 'Yaprak Rozeti', ItemSlot.rozet,
      'Ormanı koruyanlara verilir.'),
  ItemDef('bere', 'Tüylü Bere', ItemSlot.bas, 'Ozanların sevdiği bere.'),
  ItemDef('cicek', 'Çiçek Demeti', ItemSlot.el, 'Kurtardığın köylülerden.'),
  ItemDef('kanat', 'Kâğıt Kanatlar', ItemSlot.sirt,
      'Uçamazsın ama çok hafif hissettirir.'),
  ItemDef('kolye', 'Mavi Boncuk', ItemSlot.boyun, 'Uğur getirdiğine inanılır.'),
  ItemDef('rozet_ay', 'Ay Rozeti', ItemSlot.rozet,
      'Gözlemevinde gece nöbeti tutanlara.'),
  ItemDef('kitap', 'Yıldızlı Kitap', ItemSlot.el, 'Bütün masalları biliyor.'),
  ItemDef('yildiz_pelerin', 'Yıldızlı Pelerin', ItemSlot.sirt,
      'Gece göğünden dikildi.'),
  ItemDef(
      'tac', 'Bilge Tacı', ItemSlot.bas, 'Krallıkların hepsinde tanınırsın.'),
];

ItemDef? itemById(String id) {
  for (final i in items) {
    if (i.id == id) return i;
  }
  return null;
}

/// Açılmış eşyalar: kurtarılan her bölge için bir eşya.
List<ItemDef> unlockedItems(GameState g) =>
    items.take(g.banners.length.clamp(0, items.length)).toList();

bool isUnlocked(GameState g, ItemDef item) =>
    items.indexOf(item) < g.banners.length;

/// Bir sonraki eşyaya kaç bölge kaldığı (hepsi açıksa 0).
int regionsToNextItem(GameState g) => g.banners.length >= items.length ? 0 : 1;

/// Takılı eşyalar (yalnızca açılmış olanlar).
List<ItemDef> equippedItems(GameState g) => [
      for (final s in ItemSlot.values)
        if (g.equip[s.name] case final id?)
          if (itemById(id) case final item?)
            if (item.slot == s && isUnlocked(g, item)) item,
    ];

/// Eşyayı takar; takılıysa çıkarır. Açılmamış eşya takılmaz.
bool toggleItem(GameState g, ItemDef item) {
  if (!isUnlocked(g, item)) return false;
  if (g.equip[item.slot.name] == item.id) {
    g.equip.remove(item.slot.name);
  } else {
    g.equip[item.slot.name] = item.id;
  }
  return true;
}

/// Henüz görülmemiş (dolapta yeni) eşya sayısı.
int newItemCount(GameState g) =>
    (unlockedItems(g).length - g.itemsSeen).clamp(0, items.length);

/// Yol arkadaşının aşaması.
enum CompanionStage {
  yavru('Yavru', .72),
  genc('Genç', .86),
  yetiskin('Yetişkin', 1);

  const CompanionStage(this.label, this.scale);
  final String label;
  final double scale;
}

CompanionStage companionStage(int banners) => banners >= 7
    ? CompanionStage.yetiskin
    : (banners >= 3 ? CompanionStage.genc : CompanionStage.yavru);

/// Bir sonraki aşama için gereken kurtarılmış bölge sayısı (son aşamada null).
int? companionNext(int banners) => banners >= 7 ? null : (banners >= 3 ? 7 : 3);
