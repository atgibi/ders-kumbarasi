import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ders_kumbarasi/app/app_state.dart';
import 'package:ders_kumbarasi/app/speaker.dart';
import 'package:ders_kumbarasi/data/content_repository.dart';
import 'package:ders_kumbarasi/data/progress_store.dart';
import 'package:ders_kumbarasi/main.dart';

/// Widget testlerinde gerçek dosya G/Ç'si sahte zamanlayıcıyla çakışır;
/// içerik dosyaları önceden belleğe okunur.
final Map<String, String> _assets = {
  for (final f in [
    File(ContentRepository.outcomesAsset),
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
  testWidgets('ilk kurulum -> profil -> 1. sınıf matematik oturumu sonuna kadar', (t) async {
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
    expect(t.widget<FilledButton>(next).onPressed, isNull);
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

    expect(find.text('Merhaba Elif!'), findsOneWidget);
    expect(find.byKey(const Key('subject-matematik')), findsOneWidget);
    expect(find.byKey(const Key('subject-fen_bilimleri')), findsNothing, reason: '1. sınıfta Fen yok');

    await t.tap(find.byKey(const Key('subject-matematik')));
    await settle(t);

    // Konu anlatımı sayfaları
    var guard = 0;
    while (find.byKey(const Key('lesson-next')).evaluate().isNotEmpty && guard++ < 10) {
      await t.tap(find.byKey(const Key('lesson-next')));
      await t.pumpAndSettle();
    }

    // Sorular: her zaman ilk seçeneği seç, devam et
    guard = 0;
    while (find.byKey(const Key('option-0')).evaluate().isNotEmpty && guard++ < 30) {
      await t.ensureVisible(find.byKey(const Key('option-0')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('option-0')));
      await t.pump();
      await t.tap(find.byKey(const Key('next')));
      await settle(t);
    }
    expect(find.text('Bugünlük bu kadar!'), findsOneWidget);

    await t.tap(find.byKey(const Key('summary-done')));
    await settle(t);
    expect(find.text('Merhaba Elif!'), findsOneWidget);

    // İlerleme cihaza kaydedildi
    final saved = storage.files.keys.where((k) => k.startsWith('progress_')).toList();
    expect(saved, hasLength(1));
    expect(storage.files[saved.single], contains('MAT.1.1.1#'));
  });

  testWidgets('veli kapısı yanlış cevapta açılmaz', (t) async {
    final storage = MemoryStorage();
    final store = ProgressStore(storage);
    await store.saveProfiles(const [ChildProfile(id: 'a', nickname: 'Can', grade: 3, avatar: '🐶')]);
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

  testWidgets('sessiz saatlerde çalışma ekranı kapalı', (t) async {
    final storage = MemoryStorage();
    final store = ProgressStore(storage);
    await store.saveProfiles(const [ChildProfile(id: 'a', nickname: 'Can', grade: 3, avatar: '🐶')]);
    final state = makeState(storage, at: DateTime(2026, 11, 2, 22, 30));
    await t.pumpWidget(DersKumbarasiApp(state: state));
    await settle(t);
    await t.tap(find.text('Can'));
    await settle(t);
    expect(find.textContaining('dinlenme zamanı'), findsOneWidget);
    expect(find.byKey(const Key('subject-matematik')), findsNothing);
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
