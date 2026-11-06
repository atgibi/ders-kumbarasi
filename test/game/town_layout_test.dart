import 'package:flutter_test/flutter_test.dart';

import 'package:ders_kumbarasi/game/game_state.dart';
import 'package:ders_kumbarasi/game/town_layout.dart';
import 'package:ders_kumbarasi/game/world.dart';
import 'package:ders_kumbarasi/ui/game/town_art.g.dart';

void main() {
  test('her yapının varsayılan yeri ızgarada, yolda değil ve benzersiz', () {
    final seen = <Spot>{};
    for (final b in buildings) {
      final s = defaultSpotOf(b);
      expect(s, isNotNull, reason: b.id);
      expect(s!.inside, isTrue, reason: b.id);
      expect(roadSpots.contains(s), isFalse, reason: b.id);
      expect(seen.add(s), isTrue, reason: b.id);
    }
  });

  test('eski kayıt: kurulmuş yapılar varsayılan yerlerine konur', () {
    final g = GameState.fromJson({
      'built': {'ev': 2, 'cesme': 1},
    });
    expect(g.spots, isEmpty);
    final l = g.layout;
    expect(l.ensure(g.built.keys), isTrue);
    expect(g.spots, {'ev': '1,1', 'cesme': '3,3'});
    expect(l.ensure(g.built.keys), isFalse);
  });

  test('yer bilgisi JSON ile gidip gelir', () {
    final g = GameState(built: {'ev': 1}, spots: {'ev': '5,4'});
    final back = GameState.fromJson(g.toJson());
    expect(back.spots, {'ev': '5,4'});
    expect(back.layout.spotOf('ev'), const Spot(5, 4));
  });

  test('bozuk ya da çakışan yerler düzeltilir', () {
    final l = TownLayout({'ev': '9,9', 'han': '2,0', 'firin': '1,1'});
    l.ensure(['ev', 'han', 'firin']);
    final spots = {
      for (final id in ['ev', 'han', 'firin']) l.spotOf(id)
    };
    expect(spots, hasLength(3));
    for (final s in spots) {
      expect(s, isNotNull);
      expect(roadSpots.contains(s), isFalse);
    }
  });

  test('taşıma yalnızca boş kareye olur', () {
    final l = TownLayout({'ev': '1,1', 'han': '3,4'});
    expect(l.move('ev', const Spot(3, 4)), isFalse, reason: 'dolu');
    expect(l.move('ev', const Spot(2, 3)), isFalse, reason: 'yol');
    expect(l.move('ev', const Spot(6, 0)), isFalse, reason: 'dışarıda');
    expect(l.move('ev', const Spot(0, 3)), isTrue);
    expect(l.spotOf('ev'), const Spot(0, 3));
    expect(l.isFree(const Spot(1, 1)), isTrue);
  });

  test('her yapının üç seviyesinin çizimi var', () {
    for (final b in buildings) {
      for (var lv = 1; lv <= BuildingDef.maxLevel; lv++) {
        expect(townArt['${b.id}_$lv'], startsWith('<svg'), reason: b.id);
      }
    }
    for (final k in ['tile_grass', 'tile_road', 'tile_pick', 'smoke']) {
      expect(townArt[k], isNotNull, reason: k);
    }
  });
}
