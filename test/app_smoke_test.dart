import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ders_kumbarasi/app/app_state.dart';
import 'package:ders_kumbarasi/app/speaker.dart';
import 'package:ders_kumbarasi/data/content_repository.dart';
import 'package:ders_kumbarasi/data/progress_store.dart';
import 'package:ders_kumbarasi/main.dart';
import 'package:ders_kumbarasi/ui/widgets/chunky_button.dart';

/// Widget testlerinde gerçek dosya G/Ç'si sahte zamanlayıcıyla çakışır;
/// içerik dosyaları önceden belleğe okunur.
final Map<String, String> _assets = {
  for (final f in [
    File(ContentRepository.outcomesAsset),
    File(ContentRepository.unitsAsset),
    ...Directory('assets/content').listSync().whereType<File>(),
  ])
    f.path.replaceAll(r'\\', '/'): f.readAsStringSync(),
};

Future<String> _load(String path) {
  final s = _assets[path];
  return s == null
      ? Future.error(FileSystemException('yok', path))
      : Future.value(s);
}

AppState makeState(MemoryStorage storage, {DateTime? at}) => AppState(
      store: ProgressStore(storage),
      content: ContentRepository(_load),
      speaker: NoopSpeaker(),
      clock: () => at ?? DateTime(2026, 11, 2, 17),
    );

Future<void> settle(WidgetTester t) => t.pumpAndSettle();

void main() {
  testWidgets(
      'ilk kurulum -> profil -> 1. sınıf matematik oturumu sonuna kadar',
      (t) async {
    t.view.physicalSize = const Size(1080, 2200);
    t.view.devicePixelRatio = 2.6;
    addTearDown(t.view.reset);

    final storage = MemoryStorage();
    final state = makeState(storage);
    await t.pumpWidget(DersKumbarasiApp(state: state));
    await settle(t);

    // İlk kurulum: onay kutusu işaretlenmeden devam edilemez
    expect(find.text('Ders Kumbarası'), findsOneWidget);
    final next = find.byKey(const Key('onboarding-next'));
    await t.scrollUntilVisible(next, 200);
    expect(t.widget<ChunkyButton>(next).onPressed, isNull);
    await t.tap(find.byKey(const Key('accept')));
    await t.pump();
    await t.tap(next);
    await t.pumpAndSettle();

    await t.enterText(find.byKey(const Key('nickname')), 'Elif');
    await t.pump();
    await t.tap(find.byKey(const Key('profile-submit')));
    await settle(t);

    // Profil seçimi
    expect(find.text('Kim çalışacak?'), findsOneWidget);
    await t.tap(find.text('Elif'));
    await settle(t);

    // Yol ekranı: ilk konu açık, ikincisi kilitli
    expect(find.byKey(const Key('tab-path')), findsOneWidget);
    expect(find.text('BAŞLA'), findsOneWidget);
    await t.tap(find.byKey(const Key('node-MAT.1.1.2')));
    await t.pump();
    expect(find.textContaining('Önce sıradaki konuyu bitir'), findsOneWidget);
    await t.pumpAndSettle(const Duration(seconds: 5));

    await t.tap(find.byKey(const Key('node-MAT.1.1.1')));
    await settle(t);

    // Konu anlatımı sayfaları
    var guard = 0;
    while (find.byKey(const Key('lesson-next')).evaluate().isNotEmpty &&
        guard++ < 10) {
      await t.tap(find.byKey(const Key('lesson-next')));
      await t.pumpAndSettle();
    }

    // Sorular: seçmeden KONTROL ET pasif; ilk seçeneği seç, kontrol et, devam et
    guard = 0;
    while (find.byKey(const Key('option-0')).evaluate().isNotEmpty &&
        guard++ < 30) {
      await t.ensureVisible(find.byKey(const Key('option-0')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('option-0')));
      await t.pump();
      await t.tap(find.byKey(const Key('check')));
      await t.pumpAndSettle();
      expect(find.byKey(const Key('next')), findsOneWidget);
      await t.tap(find.byKey(const Key('next')));
      await settle(t);
    }
    expect(find.text('Bugünlük bu kadar!'), findsOneWidget);
    expect(find.textContaining('🌰'), findsWidgets);

    await t.tap(find.byKey(const Key('summary-done')));
    await settle(t);

    // Yola dönüldü: ilk konu tamam, sıradaki konu başlatılabilir
    expect(find.text('BAŞLA'), findsOneWidget);
    expect(state.progress!.startedOutcomes, contains('MAT.1.1.1'));
    expect(state.progress!.nuts, greaterThan(0));

    // Sekmeler: Tekrar ve Profil
    await t.tap(find.byKey(const Key('tab-review')));
    await settle(t);
    expect(find.textContaining('tam zamanında tekrar'), findsOneWidget);
    await t.tap(find.byKey(const Key('tab-profile')));
    await settle(t);
    expect(find.text('Elif'), findsWidgets);

    // İlerleme cihaza kaydedildi
    final saved =
        storage.files.keys.where((k) => k.startsWith('progress_')).toList();
    expect(saved, hasLength(1));
    expect(storage.files[saved.single], contains('MAT.1.1.1#'));
  });

  testWidgets('oturumdan çıkış onay ister; vazgeçince oturum sürer', (t) async {
    t.view.physicalSize = const Size(1080, 2200);
    t.view.devicePixelRatio = 2.6;
    addTearDown(t.view.reset);
    final storage = MemoryStorage();
    await ProgressStore(storage).saveProfiles(
        const [ChildProfile(id: 'a', nickname: 'Can', grade: 1, avatar: '🐶')]);
    final state = makeState(storage);
    await t.pumpWidget(DersKumbarasiApp(state: state));
    await settle(t);
    await t.tap(find.text('Can'));
    await settle(t);
    await t.tap(find.byKey(const Key('node-MAT.1.1.1')));
    await settle(t);
    expect(find.byKey(const Key('lesson-next')), findsOneWidget);

    await t.tap(find.byKey(const Key('session-close')));
    await t.pumpAndSettle();
    expect(find.text('Bırakmak istediğine emin misin?'), findsOneWidget);
    await t.tap(find.byKey(const Key('keep-going')));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('lesson-next')), findsOneWidget);

    await t.tap(find.byKey(const Key('session-close')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('leave')));
    await settle(t);
    expect(find.text('BAŞLA'), findsOneWidget);
  });

  testWidgets('veli kapısı yanlış cevapta açılmaz', (t) async {
    final storage = MemoryStorage();
    final store = ProgressStore(storage);
    await store.saveProfiles(
        const [ChildProfile(id: 'a', nickname: 'Can', grade: 3, avatar: '🐶')]);
    await store.saveSettings(const AppSettings(onboarded: true).toJson());
    final state = makeState(storage);
    await t.pumpWidget(DersKumbarasiApp(state: state));
    await settle(t);

    await t.tap(find.byKey(const Key('parent-entry')));
    await t.pumpAndSettle();
    await t.enterText(find.byKey(const Key('gate-answer')), '1');
    await t.tap(find.byKey(const Key('gate-ok')));
    await t.pumpAndSettle();
    expect(find.text('Veli paneli'), findsNothing);
    expect(find.text('Cevap doğru değil.'), findsOneWidget);
  });

  testWidgets('sessiz saatlerde oturum açılmaz', (t) async {
    final storage = MemoryStorage();
    final store = ProgressStore(storage);
    await store.saveProfiles(
        const [ChildProfile(id: 'a', nickname: 'Can', grade: 1, avatar: '🐶')]);
    final state = makeState(storage, at: DateTime(2026, 11, 2, 22, 30));
    await t.pumpWidget(DersKumbarasiApp(state: state));
    await settle(t);
    await t.tap(find.text('Can'));
    await settle(t);
    await t.tap(find.byKey(const Key('node-MAT.1.1.1')));
    await t.pumpAndSettle();
    expect(find.textContaining('dinlenme zamanı'), findsOneWidget);
    expect(find.byKey(const Key('lesson-next')), findsNothing);
  });

  test('sessiz saat hesabı', () {
    const s = AppSettings();
    expect(s.isQuietTime(DateTime(2026, 1, 1, 21)), isTrue);
    expect(s.isQuietTime(DateTime(2026, 1, 1, 6, 59)), isTrue);
    expect(s.isQuietTime(DateTime(2026, 1, 1, 7)), isFalse);
    expect(s.isQuietTime(DateTime(2026, 1, 1, 15)), isFalse);
    const off = AppSettings(quietStartHour: 0, quietEndHour: 0);
    expect(off.isQuietTime(DateTime(2026, 1, 1, 23)), isFalse);
  });
}
