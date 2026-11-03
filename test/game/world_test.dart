import 'package:flutter_test/flutter_test.dart';

import 'package:ders_kumbarasi/data/models.dart';
import 'package:ders_kumbarasi/data/progress_store.dart';
import 'package:ders_kumbarasi/game/game_state.dart';
import 'package:ders_kumbarasi/game/turkish.dart';
import 'package:ders_kumbarasi/game/world.dart';

Outcome o(String code, int unit) => Outcome(
    code: code,
    subject: Subject.matematik,
    grade: 1,
    title: code,
    processSteps: const [],
    unit: unit);

void main() {
  test('üniteler en fazla 3 çıktılık dengeli bölgelere ayrılır', () {
    final list = [
      for (var i = 0; i < 9; i++) o('A$i', 1),
      for (var i = 0; i < 4; i++) o('B$i', 2),
      for (var i = 0; i < 5; i++) o('C$i', 3),
      o('D0', 4),
    ];
    final r = regionsOf(Subject.matematik, 1, list);
    expect([for (final x in r) x.outcomes.length], [3, 3, 3, 2, 2, 3, 2, 1]);
    expect([for (final x in r) x.index], [0, 1, 2, 3, 4, 5, 6, 7]);
    expect(r[2].premium, isFalse);
    expect(r[3].premium, isTrue);
    expect(r.first.key, 'matematik-1-0');
    expect(guardianForKey(r[4].key).id, r[4].guardian.id);
  });

  test('bulunma eki', () {
    expect(locative('Demirdağ'), "Demirdağ'da");
    expect(locative('Ocakvadi'), "Ocakvadi'de");
    expect(locative('Işıkkaya'), "Işıkkaya'da");
    expect(locative('Sözorman'), "Sözorman'da");
  });

  test('oyun durumu kaydedilip geri okunur', () {
    final p = ChildProgress(nuts: 40);
    p.game
      ..hero = const HeroLook(girl: true, path: 3, skin: 2, hair: 4, hairColor: 1)
      ..addSupply(Supply.demir, 7)
      ..built['ev'] = 2
      ..banners.add('matematik-1-0')
      ..rescued.add('matematik-1-0')
      ..duelBest['matematik-1-0'] = 88
      ..addPage('2026-11-03', 'Defne bugün sayı saydı.');
    final back = ChildProgress.fromJson(p.toJson());
    final g = back.game;
    expect(g.hero!.girl, isTrue);
    expect(g.hero!.path, 3);
    expect(g.hero!.hair, 4);
    expect(g.supply(Supply.demir), 7);
    expect(g.built['ev'], 2);
    expect(g.banners, {'matematik-1-0'});
    expect(g.duelBest['matematik-1-0'], 88);
    expect(g.notebook.single.text, 'Defne bugün sayı saydı.');
    expect(back.nuts, 40);
  });

  test('eski kayıt (oyunsuz) sorunsuz açılır', () {
    final back = ChildProgress.fromJson({'v': 1, 'nuts': 3});
    expect(back.game.hero, isNull);
    expect(back.game.supplies, isEmpty);
  });

  test('aşamalar', () {
    expect(stageFor(started: 0, banners: 0, mastered: 0), HeroStage.cirak);
    expect(stageFor(started: 10, banners: 0, mastered: 0), HeroStage.yolcu);
    expect(stageFor(started: 12, banners: 2, mastered: 3), HeroStage.muhafiz);
    expect(stageFor(started: 30, banners: 4, mastered: 25), HeroStage.kahraman);
  });

  test('yapı maliyeti seviyeyle büyür', () {
    final ev = buildings.first;
    expect(ev.lightCost(1), 15);
    expect(ev.lightCost(2), 30);
    expect(ev.materialCost(3)[Supply.demir], 6);
  });
}
