import 'package:flutter_test/flutter_test.dart';

import 'package:ders_kumbarasi/core/srs/leitner.dart';
import 'package:ders_kumbarasi/data/progress_store.dart';

void main() {
  group('ProgressStore', () {
    test('profil ve ilerleme kaydedilip geri okunur', () async {
      final store = ProgressStore(MemoryStorage());
      expect(await store.loadProfiles(), isEmpty);
      const elif =
          ChildProfile(id: 'p1', nickname: 'Elif', grade: 2, avatar: '🦊');
      await store.saveProfiles([elif]);
      final loaded = await store.loadProfiles();
      expect(loaded.single.nickname, 'Elif');
      expect(loaded.single.grade, 2);

      final now = DateTime(2026, 11, 2, 18);
      final p = ChildProgress()
        ..cards['MAT.2.1.1#1'] = review(
            CardState.fresh('MAT.2.1.1#1', now), ReviewOutcome.correctFast, now)
        ..startedOutcomes.add('MAT.2.1.1')
        ..dailyMinutes['2026-11-02'] = 12;
      await store.saveProgress('p1', p);
      final back = await store.loadProgress('p1');
      expect(back.cards['MAT.2.1.1#1']!.box, 1);
      expect(back.startedOutcomes, {'MAT.2.1.1'});
      expect(back.dailyMinutes['2026-11-02'], 12);
    });

    test('bozuk kayıt uygulamayı çökertmez ve üzerine yazılmadan saklanır',
        () async {
      final s = MemoryStorage()..files['progress_p1.json'] = '{bozuk';
      final store = ProgressStore(s);
      final p = await store.loadProgress('p1');
      expect(p.cards, isEmpty);
      expect(store.lastIssue, LoadIssue.unreadable);
      await store.saveProgress('p1', p..nuts = 3);
      expect(s.files['progress_p1.json.bozuk'], '{bozuk');
      expect((await store.loadProgress('p1')).nuts, 3);
    });

    test('bozuk kayıt bir önceki sürümden (yedek) kurtarılır', () async {
      final s = MemoryStorage();
      final store = ProgressStore(s);
      await store.saveProgress('p1', ChildProgress(nuts: 5));
      await store.saveProgress('p1', ChildProgress(nuts: 9));
      expect(s.files.containsKey('progress_p1.json.bak'), isTrue);
      s.files['progress_p1.json'] = '{"cards": [yarım';
      final back = await ProgressStore(s).loadProgress('p1');
      expect(back.nuts, 5);
    });

    test('dışa aktarma ve geri yükleme aynı veriyi verir', () async {
      final a = MemoryStorage();
      final store = ProgressStore(a);
      const kid = ChildProfile(id: 'k', nickname: 'Ada', grade: 2, avatar: '4');
      await store.saveProfiles([kid]);
      final now = DateTime(2026, 11, 2, 18);
      final p = ChildProgress(nuts: 12)
        ..startedOutcomes.add('MAT.2.1.1')
        ..countAnswer('2026-11-02', firstTry: true)
        ..addAttempt('MAT.2.1.1', const Attempt('2026-11-02', 'Kaç?', 'first'))
        ..cards['MAT.2.1.1#ab'] = review(CardState.fresh('MAT.2.1.1#ab', now),
            ReviewOutcome.correctFast, now);
      await store.saveProgress('k', p);
      await store.saveSettings({'limit': 30});
      final json = await store.exportAll();

      final b = ProgressStore(MemoryStorage());
      expect(await b.importAll(json), 1);
      expect((await b.loadProfiles()).single.nickname, 'Ada');
      final q = await b.loadProgress('k');
      expect(q.nuts, 12);
      expect(q.dailyAnswers['2026-11-02'], [1, 1]);
      expect(q.attempts['MAT.2.1.1']!.single.result, 'first');
      expect(q.cards['MAT.2.1.1#ab']!.box, 1);
      expect((await b.loadSettings())['limit'], 30);
    });

    test('geçersiz yedek dosyası hiçbir şeyi değiştirmez', () async {
      final s = MemoryStorage();
      final store = ProgressStore(s);
      await store.saveProfiles(
          const [ChildProfile(id: 'x', nickname: 'X', grade: 1, avatar: '0')]);
      await expectLater(
          store.importAll('{"uygulama":"baska"}'), throwsFormatException);
      await expectLater(store.importAll('bozuk'), throwsFormatException);
      expect((await store.loadProfiles()).single.id, 'x');
    });

    test('eski emoji avatarlar bir hayvan avatarına düşer', () {
      const p = ChildProfile(id: 'a', nickname: 'A', grade: 1, avatar: '🦊');
      expect(p.avatarIndex, inInclusiveRange(0, avatarCount - 1));
      const q = ChildProfile(id: 'a', nickname: 'A', grade: 1, avatar: '7');
      expect(q.avatarIndex, 7);
    });

    test('son denemeler en fazla 5 tane tutulur, en yenisi başta', () {
      final p = ChildProgress();
      for (var i = 0; i < 7; i++) {
        p.addAttempt('X', Attempt('2026-11-0$i', 'S$i', 'first'));
      }
      expect(p.attempts['X']!.length, 5);
      expect(p.attempts['X']!.first.prompt, 'S6');
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
      expect(s.files, isEmpty, reason: 'yedek dosyaları da silinir');
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
