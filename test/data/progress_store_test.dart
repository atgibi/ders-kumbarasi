import 'package:flutter_test/flutter_test.dart';

import 'package:ders_kumbarasi/core/srs/leitner.dart';
import 'package:ders_kumbarasi/data/progress_store.dart';

void main() {
  group('ProgressStore', () {
    test('profil ve ilerleme kaydedilip geri okunur', () async {
      final store = ProgressStore(MemoryStorage());
      expect(await store.loadProfiles(), isEmpty);
      const elif = ChildProfile(id: 'p1', nickname: 'Elif', grade: 2, avatar: '🦊');
      await store.saveProfiles([elif]);
      final loaded = await store.loadProfiles();
      expect(loaded.single.nickname, 'Elif');
      expect(loaded.single.grade, 2);

      final now = DateTime(2026, 11, 2, 18);
      final p = ChildProgress()
        ..cards['MAT.2.1.1#1'] =
            review(CardState.fresh('MAT.2.1.1#1', now), ReviewOutcome.correctFast, now)
        ..startedOutcomes.add('MAT.2.1.1')
        ..dailyMinutes['2026-11-02'] = 12;
      await store.saveProgress('p1', p);
      final back = await store.loadProgress('p1');
      expect(back.cards['MAT.2.1.1#1']!.box, 1);
      expect(back.startedOutcomes, {'MAT.2.1.1'});
      expect(back.dailyMinutes['2026-11-02'], 12);
    });

    test('bozuk kayıt uygulamayı çökertmez', () async {
      final s = MemoryStorage()..files['progress_p1.json'] = '{bozuk';
      final store = ProgressStore(s);
      final p = await store.loadProgress('p1');
      expect(p.cards, isEmpty);
    });

    test('çocuk silinince ilerlemesi de silinir', () async {
      final s = MemoryStorage();
      final store = ProgressStore(s);
      await store.saveProfiles(const [
        ChildProfile(id: 'a', nickname: 'A', grade: 1, avatar: '🐱'),
        ChildProfile(id: 'b', nickname: 'B', grade: 3, avatar: '🐶'),
      ]);
      await store.saveProgress('a', ChildProgress());
      await store.deleteChild('a');
      expect(s.files.containsKey('progress_a.json'), isFalse);
      expect((await store.loadProfiles()).map((p) => p.id), ['b']);
      await store.deleteAll();
      expect(s.files, isEmpty);
    });
  });

  group('seri (streak)', () {
    test('ardışık günler seriyi artırır, aynı gün iki kez sayılmaz', () {
      final p = ChildProgress();
      recordSessionDay(p, DateTime(2026, 11, 2, 18));
      recordSessionDay(p, DateTime(2026, 11, 2, 20));
      expect(p.streakDays, 1);
      recordSessionDay(p, DateTime(2026, 11, 3, 18));
      expect(p.streakDays, 2);
    });

    test('haftada 2 gün atlama hakkı seriyi korur', () {
      final p = ChildProgress();
      recordSessionDay(p, DateTime(2026, 11, 2, 18)); // Pzt
      recordSessionDay(p, DateTime(2026, 11, 5, 18)); // Per (2 gün atlandı)
      expect(p.streakDays, 2);
      expect(p.restDaysUsedThisWeek, 2);
      recordSessionDay(p, DateTime(2026, 11, 7, 18)); // Cmt (1 gün daha)
      expect(p.streakDays, 1, reason: 'hak bitti, seri yeniden başlar');
    });

    test('yeni hafta dinlenme hakkını yeniler', () {
      final p = ChildProgress();
      recordSessionDay(p, DateTime(2026, 11, 5, 18)); // Per
      recordSessionDay(p, DateTime(2026, 11, 8, 18)); // Paz (2 gün atlandı)
      expect(p.restDaysUsedThisWeek, 2);
      recordSessionDay(p, DateTime(2026, 11, 10, 18)); // Sal, yeni hafta, 1 gün
      expect(p.streakDays, 3);
      expect(p.restDaysUsedThisWeek, 1);
    });

    test('gece 01:00 hâlâ önceki gün sayılır', () {
      expect(dayKey(DateTime(2026, 11, 3, 1)), '2026-11-02');
      expect(dayKey(DateTime(2026, 11, 3, 5)), '2026-11-03');
    });
  });
}
