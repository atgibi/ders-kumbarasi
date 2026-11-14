/// Kasaba ızgarası: yapıların izometrik zemindeki yerleri.
///
/// Yerler [GameState.spots] içinde "x,y" kimliğiyle saklanır. Eski kayıtlarda
/// yer bilgisi yoktur; kurulmuş yapılar ilk açılışta varsayılan yerlerine
/// konur (bkz. [TownLayout.ensure]).
library;

import 'world.dart';

/// Izgara boyutu (kare).
const townSize = 6;

/// Bir ızgara karesi.
class Spot {
  const Spot(this.x, this.y);
  final int x;
  final int y;

  bool get inside => x >= 0 && y >= 0 && x < townSize && y < townSize;

  /// Çizim sırası: arkadakiler önce.
  int get depth => x + y;

  String get key => '$x,$y';

  static Spot? parse(Object? v) {
    if (v is! String) return null;
    final p = v.split(',');
    if (p.length != 2) return null;
    final x = int.tryParse(p[0]), y = int.tryParse(p[1]);
    if (x == null || y == null) return null;
    final s = Spot(x, y);
    return s.inside ? s : null;
  }

  @override
  bool operator ==(Object other) =>
      other is Spot && other.x == x && other.y == y;

  @override
  int get hashCode => x * 31 + y;

  @override
  String toString() => key;
}

/// Meydanı çevreleyen varsayılan yerler: uzun yapılar arkada, alçaklar önde.
const _defaults = <String, Spot>{
  'ev': Spot(1, 1),
  'ocak': Spot(0, 3),
  'firin': Spot(3, 1),
  'demirhane': Spot(4, 1),
  'kitaplik': Spot(1, 3),
  'cesme': Spot(3, 3),
  'bahce': Spot(0, 4),
  'gozlemevi': Spot(4, 0),
  'han': Spot(3, 4),
};

/// Kasabayı ortadan kesen iki yol (x = 2 ve y = 2): buraya yapı konmaz,
/// köylüler burada yürür.
final Set<Spot> roadSpots = {
  for (var i = 0; i < townSize; i++) Spot(2, i),
  for (var i = 0; i < townSize; i++) Spot(i, 2),
};

/// Süs ağaçları: üzerine yapı konursa ağaç çizilmez.
final Map<Spot, int> treeSpots = {
  const Spot(0, 0): 1,
  const Spot(5, 0): 0,
  const Spot(5, 5): 1,
  const Spot(0, 5): 0,
  const Spot(5, 3): 0,
};

class TownLayout {
  TownLayout(this.spots);

  /// Yapı kimliği -> "x,y".
  final Map<String, String> spots;

  Spot? spotOf(String id) => Spot.parse(spots[id]);

  /// O karedeki yapı (yoksa null).
  String? buildingAt(Spot s) {
    for (final e in spots.entries) {
      if (e.value == s.key) return e.key;
    }
    return null;
  }

  bool isFree(Spot s) =>
      s.inside && !roadSpots.contains(s) && buildingAt(s) == null;

  /// Kurulmuş ama yeri olmayan yapılara yer verir; geçersiz yerleri düzeltir.
  /// Bir şey değiştiyse true döner.
  bool ensure(Iterable<String> builtIds) {
    var changed = false;
    // Geçersiz ya da çakışan kayıtları at.
    final seen = <String>{};
    for (final id in spots.keys.toList()) {
      final s = Spot.parse(spots[id]);
      if (s == null || roadSpots.contains(s) || !seen.add(s.key)) {
        spots.remove(id);
        changed = true;
      }
    }
    for (final id in builtIds) {
      if (spotOf(id) != null) continue;
      final s = _firstFree(_defaults[id]);
      if (s == null) continue;
      spots[id] = s.key;
      changed = true;
    }
    return changed;
  }

  /// Yapıyı boş bir kareye taşır.
  bool move(String id, Spot to) {
    if (!isFree(to)) return false;
    spots[id] = to.key;
    return true;
  }

  Spot? _firstFree(Spot? preferred) {
    if (preferred != null && isFree(preferred)) return preferred;
    for (var d = 0; d < townSize * 2; d++) {
      for (var y = 0; y < townSize; y++) {
        for (var x = 0; x < townSize; x++) {
          final s = Spot(x, y);
          if (s.depth == d && isFree(s)) return s;
        }
      }
    }
    return null;
  }
}

/// Bir yapının varsayılan yeri (test ve tanıtım için).
Spot? defaultSpotOf(BuildingDef b) => _defaults[b.id];
