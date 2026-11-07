import 'package:flutter_test/flutter_test.dart';

import 'package:ders_kumbarasi/game/game_state.dart';
import 'package:ders_kumbarasi/game/item_art.g.dart';
import 'package:ders_kumbarasi/game/items.dart';

GameState withBanners(int n) =>
    GameState(banners: {for (var i = 0; i < n; i++) 'matematik-1-$i'});

void main() {
  test('her eşyanın çizimi ve dolap kutusu var, kimlikler benzersiz', () {
    final ids = items.map((i) => i.id).toSet();
    expect(ids, hasLength(items.length));
    for (final i in items) {
      expect(itemArt[i.id], isNotNull, reason: i.id);
      expect(itemBox[i.id], isNotNull, reason: i.id);
    }
    for (final s in ItemSlot.values) {
      expect(items.where((i) => i.slot == s), isNotEmpty, reason: s.name);
    }
  });

  test('her kurtarılan bölge bir eşya açar', () {
    expect(unlockedItems(withBanners(0)), isEmpty);
    expect(unlockedItems(withBanners(1)).single.id, 'atki');
    expect(unlockedItems(withBanners(5)), hasLength(5));
    expect(unlockedItems(withBanners(99)), hasLength(items.length));
  });

  test('takma ve çıkarma; kilitli eşya takılmaz', () {
    final g = withBanners(2);
    final atki = itemById('atki')!;
    final tac = itemById('tac')!;
    expect(toggleItem(g, tac), isFalse);
    expect(toggleItem(g, atki), isTrue);
    expect(equippedItems(g).map((i) => i.id), ['atki']);
    expect(toggleItem(g, atki), isTrue);
    expect(equippedItems(g), isEmpty);
  });

  test('aynı yuvaya ikinci eşya öncekinin yerine geçer', () {
    final g = withBanners(items.length);
    toggleItem(g, itemById('atki')!);
    toggleItem(g, itemById('madalyon')!);
    toggleItem(g, itemById('tac')!);
    expect(equippedItems(g).map((i) => i.id).toSet(), {'madalyon', 'tac'});
  });

  test('takılı eşyalar ve görülen sayısı kayda yazılır', () {
    final g = withBanners(3)..itemsSeen = 2;
    toggleItem(g, itemById('cicek_taci')!);
    final back = GameState.fromJson(g.toJson());
    expect(back.equip, {'bas': 'cicek_taci'});
    expect(back.itemsSeen, 2);
    expect(newItemCount(back), 1);
  });

  test('yol arkadaşı üç aşamada büyür', () {
    expect(companionStage(0), CompanionStage.yavru);
    expect(companionStage(3), CompanionStage.genc);
    expect(companionStage(7), CompanionStage.yetiskin);
    expect(companionNext(0), 3);
    expect(companionNext(4), 7);
    expect(companionNext(9), isNull);
    expect(CompanionStage.yavru.scale, lessThan(CompanionStage.genc.scale));
  });
}
