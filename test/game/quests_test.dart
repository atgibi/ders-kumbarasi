import 'package:ders_kumbarasi/game/game_state.dart';
import 'package:ders_kumbarasi/game/quests.dart';
import 'package:ders_kumbarasi/game/world.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('günün istekleri aynı gün ve çocuk için sabittir', () {
    final a = makeDailyQuests('2026-11-04', 'c1',
        reviewReady: true, newTopicReady: true);
    final b = makeDailyQuests('2026-11-04', 'c1',
        reviewReady: true, newTopicReady: true);
    expect([for (final q in a) q.toJson()], [for (final q in b) q.toJson()]);
    expect(a, hasLength(3));
    expect(a.first.kind, QuestKind.session);
    expect(a[1].kind, QuestKind.correct);
    // Üç ayrı kasabalı
    expect({for (final q in a) q.folk}, hasLength(3));
  });

  test('tekrar ve yeni konu yoksa üçüncü istek yapılabilir kalır', () {
    for (var d = 1; d <= 28; d++) {
      final qs = makeDailyQuests(
          '2026-11-${d.toString().padLeft(2, '0')}', 'c1',
          reviewReady: false, newTopicReady: false);
      expect(qs[2].kind, QuestKind.session);
      expect(qs[2].target, 2);
    }
  });

  test('pano ilerler, ödül bir kez alınır', () {
    final b = DailyBoard('2026-11-04', [
      const Quest(QuestKind.session, 1, 0, Supply.demir),
      const Quest(QuestKind.correct, 10, 1, Supply.kristal),
      const Quest(QuestKind.review, 5, 2, Supply.ekmek),
    ]);
    expect(b.canClaim(0), isFalse);
    b.add(QuestKind.session, 1);
    b.add(QuestKind.correct, 7);
    expect(b.canClaim(0), isTrue);
    expect(b.progressOf(b.quests[1]), 7);
    expect(b.canClaim(1), isFalse);
    b.add(QuestKind.correct, 6);
    expect(b.progressOf(b.quests[1]), 10, reason: 'hedefte durur');
    b.claimed.add(0);
    expect(b.canClaim(0), isFalse);

    final back = DailyBoard.fromJson(b.toJson())!;
    expect(back.day, b.day);
    expect(back.counts, b.counts);
    expect(back.claimed, {0});
    expect(back.quests[2].supply, Supply.ekmek);
    expect(back.quests[2].kind, QuestKind.review);
  });

  test('haftalık sefer dört farklı günde tamamlanır', () {
    final t = WeeklyTrip('2026-11-02');
    t.days.addAll(['2026-11-02', '2026-11-02', '2026-11-03', '2026-11-05']);
    expect(t.done, isFalse);
    t.days.add('2026-11-06');
    expect(t.canClaim, isTrue);
    t.claimed = true;
    expect(t.canClaim, isFalse);
    final back = WeeklyTrip.fromJson(t.toJson())!;
    expect(back.days, hasLength(4));
    expect(back.claimed, isTrue);
    expect(allKingdoms, contains(back.leaderKingdom));
  });

  test('mektuplar oyun durumuyla saklanır ve bir kez gelir', () {
    final g = GameState(hero: const HeroLook(girl: true, path: 0));
    expect(g.addLetter(welcomeLetter('Elif', '2026-11-04')), isTrue);
    expect(g.addLetter(welcomeLetter('Elif', '2026-11-05')), isFalse);
    g.addLetter(
        guardianLetter(guardians.first, 'matematik-1-0', 'Elif', '2026-11-04'));
    g.addLetter(leaderLetter(demirdag, '2026-11-02', 'Elif', 4, '2026-11-06'));
    expect(g.unreadLetters, 3);
    g.letters.first.read = true;
    g.board = DailyBoard('2026-11-04', [
      const Quest(QuestKind.newTopic, 1, 3, Supply.kumas),
    ])
      ..add(QuestKind.newTopic, 1);
    g.trip = WeeklyTrip('2026-11-02', days: {'2026-11-04'});

    final back = GameState.fromJson(g.toJson());
    expect(back.letters, hasLength(3));
    expect(back.unreadLetters, 2);
    expect(back.letters[2].text, contains("Demirdağ'da"));
    expect(back.letters[2].from, 'Usta Çark');
    expect(back.board!.canClaim(0), isTrue);
    expect(back.trip!.days, {'2026-11-04'});
  });

  test('Karabulut ile barışılan krallıklar kaydedilir', () {
    final g = GameState()..finale.addAll(['matematik', 'turkce']);
    expect(GameState.fromJson(g.toJson()).finale, {'matematik', 'turkce'});
  });

  test('eski kayıtlarda pano ve mektup yoksa boş başlar', () {
    final g = GameState.fromJson({'sup': {}, 'book': []});
    expect(g.board, isNull);
    expect(g.trip, isNull);
    expect(g.letters, isEmpty);
    expect(g.finale, isEmpty);
  });
}
