import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ders_kumbarasi/app/app_state.dart';
import 'package:ders_kumbarasi/app/speaker.dart';
import 'package:ders_kumbarasi/data/content_repository.dart';
import 'package:ders_kumbarasi/data/models.dart';
import 'package:ders_kumbarasi/data/progress_store.dart';
import 'package:ders_kumbarasi/game/game_state.dart';
import 'package:ders_kumbarasi/game/world.dart';
import 'package:ders_kumbarasi/main.dart';

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

/// Sürekli animasyonları kapatır ("hareketi azalt").
void reduceMotion(WidgetTester t) {
  t.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

void phone(WidgetTester t) {
  t.view.physicalSize = const Size(1170, 2532);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
}

Future<void> tapKey(WidgetTester t, String key) async {
  final f = find.byKey(Key(key));
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  await t.tap(f);
  await t.pumpAndSettle();
}

/// Kasaba listesinde aşağı kaydırıp dokunur (liste tembel kurulur).
Future<void> tapTown(WidgetTester t, String key) async {
  final f = find.byKey(Key(key));
  await t.scrollUntilVisible(f, 150,
      scrollable: find
          .descendant(
              of: find.byKey(const Key('town-list')),
              matching: find.byType(Scrollable))
          .first);
  await t.pumpAndSettle();
  await t.tap(f);
  await t.pumpAndSettle();
}

/// Kahramanı hazır bir çocuk (kahraman oluşturma ekranı atlanır).
Future<void> seedHero(ProgressStore store, String id) => store.saveProgress(id,
    ChildProgress(game: GameState(hero: const HeroLook(girl: false, path: 1))));

/// Haritadaki bölgeye kaydırıp dokunur (liste tembel kurulur).
Future<void> tapRegion(WidgetTester t, int i) async {
  final f = find.byKey(Key('region-$i'));
  await t.drag(find.byKey(const Key('map-list')), const Offset(0, 4000));
  await t.pumpAndSettle();
  await t.scrollUntilVisible(f, 200,
      scrollable: find
          .descendant(
              of: find.byKey(const Key('map-list')),
              matching: find.byType(Scrollable))
          .first);
  await t.pumpAndSettle();
  await t.tap(f);
  await t.pumpAndSettle();
}

bool has(String key) => find.byKey(Key(key)).evaluate().isNotEmpty;

/// Oturumu sonuna kadar götürür (anlatım, soru, etkinlik).
Future<void> playSession(WidgetTester t) async {
  var guard = 0;
  while (guard++ < 80) {
    if (has('lesson-next')) {
      await tapKey(t, 'lesson-next');
    } else if (has('option-0')) {
      // Seçmeden KONTROL ET pasif
      expect(find.byKey(const Key('band-ok')), findsNothing);
      await tapKey(t, 'option-0');
      await tapKey(t, 'check');
      expect(has('next'), isTrue);
      await tapKey(t, 'next');
    } else if (has('activity-done')) {
      await tapKey(t, 'activity-done');
      await tapKey(t, 'next');
    } else {
      break;
    }
  }
  await t.pumpAndSettle(const Duration(seconds: 3)); // bilgi notları kapansın
}

void main() {
  testWidgets('ilk açılış (A1–A6) -> ilk ders -> özet -> seri -> yol',
      (t) async {
    reduceMotion(t);
    phone(t);
    final storage = MemoryStorage();
    final state = makeState(storage);
    await t.pumpWidget(DersKumbarasiApp(state: state));
    await settle(t);

    expect(find.text('Her gün 10 dakika, kalıcı öğrenme'), findsOneWidget);
    await tapKey(t, 'onboarding-start');
    for (var i = 0; i < 3; i++) {
      await tapKey(t, 'onboarding-next');
    }
    // A3: ad girilmeden devam edilemez
    expect(find.text('Çocuğunuzu tanıyalım'), findsOneWidget);
    await t.enterText(find.byKey(const Key('nickname')), 'Elif');
    await t.pump();
    await tapKey(t, 'grade-1');
    await tapKey(t, 'avatar-3');
    await tapKey(t, 'profile-submit');
    expect(find.text('Süre ve saatler'), findsOneWidget);
    await tapKey(t, 'settings-next');
    expect(find.text('Verileriniz cihazda kalır'), findsOneWidget);
    await tapKey(t, 'privacy-ok');
    expect(find.text('Hazır mısın, Elif?'), findsOneWidget);
    await tapKey(t, 'first-lesson');

    // Kahraman: kız → yol → görünüm
    await tapKey(t, 'hero-girl');
    await tapKey(t, 'hero-path-2');
    await tapKey(t, 'hero-next');
    await tapKey(t, 'look-tab-ten');
    await tapKey(t, 'skin-3');
    await tapKey(t, 'hero-done');

    await playSession(t);
    expect(find.text('Bugün çok çalıştın!'), findsOneWidget);
    await tapKey(t, 'summary-done');
    // İlk oturum: seri 1 gün
    expect(find.text('1 gündür birlikteyiz!'), findsOneWidget);
    await tapKey(t, 'streak-done');

    // Harita, kahraman, kazanılanlar, defter
    expect(has('map-list'), isTrue);
    expect(has('anka-line'), isTrue);
    expect(state.progress!.startedOutcomes, isNotEmpty);
    expect(state.progress!.nuts, greaterThan(0));
    expect(state.profiles.single.avatar, '3');
    final hero = state.progress!.game.hero!;
    expect(hero.girl, isTrue);
    expect(hero.path, 2);
    expect(hero.skin, 3);
    expect(state.progress!.game.notebook, isNotEmpty);
    expect(state.progress!.game.supplies.values.fold<int>(0, (a, b) => a + b),
        greaterThan(0));

    await tapKey(t, 'tab-town');
    expect(has('town-list'), isTrue);
    // İstek panosu ve sefer: biten oturum sayıldı, ödül elle alınır
    expect(has('quest-board'), isTrue);
    final g = state.progress!.game;
    expect(g.board!.counts['s'], 1);
    expect(g.trip!.days, hasLength(1));
    final light0 = state.progress!.nuts;
    await tapTown(t, 'quest-claim-0');
    expect(state.progress!.nuts, light0 + g.board!.quests[0].light);
    expect(g.board!.claimed, {0});
    // Anka'nın hoş geldin mektubu
    expect(g.unreadLetters, 1);
    await tapTown(t, 'mail-open');
    expect(find.text('Anka'), findsWidgets);
    await tapKey(t, 'letter-0');
    expect(g.unreadLetters, 0);
    expect(find.textContaining("Bilgelik Diyarı'na hoş geldin"), findsOneWidget);
    await tapKey(t, 'letter-back');
    await tapKey(t, 'mail-back');
    await tapTown(t, 'notebook-open');
    expect(find.text('Kahraman Defteri'), findsOneWidget);
    expect(find.textContaining('Elif bugün'), findsWidgets);
    await tapKey(t, 'notebook-back');
    // İlk yapı: ışık ve demirle hemen kurulur
    final before = state.progress!.nuts;
    if (state.canBuild(buildings.first)) {
      await tapTown(t, 'build-ev');
      expect(state.progress!.game.built['ev'], 1);
      expect(state.progress!.nuts, lessThan(before));
    }

    await tapKey(t, 'tab-review');
    expect(has('review-card'), isTrue);
    await tapKey(t, 'tab-profile');
    expect(find.text('Elif'), findsWidgets);
    expect(find.text('1. sınıf'), findsOneWidget);
    await tapKey(t, 'tab-map');

    // İlerleme cihaza kaydedildi (yedek dosyasıyla)
    final saved = storage.files.keys
        .where((k) => k.startsWith('progress_') && k.endsWith('.json'))
        .toList();
    expect(saved, hasLength(1));
    expect(storage.files[saved.single], contains('#'));
    expect(storage.files[saved.single], contains('"hero"'));
  });

  testWidgets('kilitli düğüm not gösterir; oturumdan çıkış onay ister',
      (t) async {
    reduceMotion(t);
    phone(t);
    final storage = MemoryStorage();
    await ProgressStore(storage).saveProfiles(
        const [ChildProfile(id: 'a', nickname: 'Can', grade: 1, avatar: '2')]);
    await seedHero(ProgressStore(storage), 'a');
    final state = makeState(storage);
    await t.pumpWidget(DersKumbarasiApp(state: state));
    await settle(t);
    expect(find.text('Kim çalışacak?'), findsOneWidget);
    await tapKey(t, 'kid-a');
    await tapKey(t, 'kingdom-matematik');

    // Sisli bölge açılmaz; ilk bölge açılır
    await tapRegion(t, 1);
    expect(find.textContaining('Sis burada çok yoğun'), findsOneWidget);
    await t.pumpAndSettle(const Duration(seconds: 3));
    await tapRegion(t, 0);

    await tapKey(t, 'node-MAT.1.1.2');
    expect(
        find.textContaining('Önce sıradaki konuyu bitirelim'), findsOneWidget);
    await t.pumpAndSettle(const Duration(seconds: 3));

    await tapKey(t, 'node-MAT.1.1.1');
    expect(has('node-sheet'), isTrue);
    await tapKey(t, 'node-start');
    expect(has('lesson-next'), isTrue);

    await tapKey(t, 'session-close');
    expect(
        find.text(
            'Şimdiye kadar yaptıkların kaydedildi. Çıkmak istiyor musun?'),
        findsOneWidget);
    await tapKey(t, 'keep-going');
    expect(has('lesson-next'), isTrue);

    await tapKey(t, 'session-close');
    await tapKey(t, 'leave');
    expect(has('path-list'), isTrue);
    await tapKey(t, 'region-back');
    expect(has('map-list'), isTrue);
  });

  testWidgets('ücretsiz sürümde 4. bölge kilitli; düello sancak diker',
      (t) async {
    reduceMotion(t);
    phone(t);
    final storage = MemoryStorage();
    final store = ProgressStore(storage);
    await store.saveProfiles(
        const [ChildProfile(id: 'a', nickname: 'Can', grade: 1, avatar: '2')]);
    // İlk bölgenin bütün konularına başlanmış bir çocuk
    final probe = makeState(storage);
    await probe.load();
    final regions = await probe.content.outcomesFor(Subject.matematik, 1);
    final firstUnit = regions.first.unit;
    await store.saveProgress(
        'a',
        ChildProgress(
          startedOutcomes: {
            for (final o in regions)
              if (o.unit == firstUnit) o.code
          },
          game: GameState(hero: const HeroLook(girl: true, path: 0)),
        ));
    final state = makeState(storage);
    await t.pumpWidget(DersKumbarasiApp(state: state));
    await settle(t);
    await tapKey(t, 'kid-a');
    await tapKey(t, 'kingdom-matematik');

    final locked = await state.lockedOutcomes(Subject.matematik);
    expect(locked, isNotEmpty);
    final rs = await state.regions(Subject.matematik);
    expect(locked, containsAll(rs[3].outcomes.map((o) => o.code)));
    expect(locked.intersection(rs[2].outcomes.map((o) => o.code).toSet()),
        isEmpty);
    await tapRegion(t, 3);
    expect(find.textContaining('Bir büyüğüne sorabilirsin'), findsOneWidget);
    await t.pumpAndSettle(const Duration(seconds: 3));

    await tapRegion(t, 0);
    await tapKey(t, 'duel-start');
    expect(has('duel-header'), isTrue);
    await playSession(t);
    expect(has('duel-done'), isTrue);
    expect(state.progress!.game.banners, contains('matematik-1-0'));
    expect(state.progress!.game.rescued, hasLength(1));
    await tapKey(t, 'duel-done');
    expect(has('path-list'), isTrue);
  });

  testWidgets('veli kapısı: yanlış cevapta açılmaz, doğruda açılır', (t) async {
    reduceMotion(t);
    phone(t);
    final storage = MemoryStorage();
    final store = ProgressStore(storage);
    await store.saveProfiles(
        const [ChildProfile(id: 'a', nickname: 'Can', grade: 3, avatar: '🐶')]);
    await seedHero(store, 'a');
    await store.saveSettings(const AppSettings(onboarded: true).toJson());
    final state = makeState(storage);
    await t.pumpWidget(DersKumbarasiApp(state: state));
    await settle(t);
    await tapKey(t, 'kid-a');
    await tapKey(t, 'tab-profile');
    await tapKey(t, 'parent-entry');

    await tapKey(t, 'gate-key-1');
    await tapKey(t, 'gate-key-ok');
    expect(find.text('Veli paneli'), findsNothing);
    expect(
        find.text('Bu cevap değil. 2 deneme hakkınız kaldı.'), findsOneWidget);

    final q = t.widget<Text>(find.byKey(const Key('gate-question'))).data!;
    final m = RegExp(r'(\d+) × (\d+)').firstMatch(q)!;
    final answer = int.parse(m[1]!) * int.parse(m[2]!);
    for (final d in '$answer'.split('')) {
      await tapKey(t, 'gate-key-$d');
    }
    await tapKey(t, 'gate-key-ok');
    expect(find.text('Veli paneli'), findsOneWidget);
    expect(has('parent-empty'), isTrue);

    await tapKey(t, 'nav-settings');
    expect(find.text('Yazı boyutu'), findsOneWidget);
    await tapKey(t, 'text-size-1');
    expect(state.settings.textSize, 1);
    await tapKey(t, 'back');
    await tapKey(t, 'to-child');
    expect(has('tab-profile'), isTrue);
  });

  testWidgets('sessiz saatlerde oturum açılmaz', (t) async {
    reduceMotion(t);
    phone(t);
    final storage = MemoryStorage();
    final store = ProgressStore(storage);
    await store.saveProfiles(
        const [ChildProfile(id: 'a', nickname: 'Can', grade: 1, avatar: '0')]);
    await seedHero(store, 'a');
    final state = makeState(storage, at: DateTime(2026, 11, 2, 22, 30));
    await t.pumpWidget(DersKumbarasiApp(state: state));
    await settle(t);
    await tapKey(t, 'kid-a');
    await tapKey(t, 'kingdom-matematik');
    await tapRegion(t, 0);
    await tapKey(t, 'node-MAT.1.1.1');
    await tapKey(t, 'node-start');
    expect(find.text('Anka uyuyor. Sabah görüşürüz!'), findsOneWidget);
    expect(has('lesson-next'), isFalse);
    await tapKey(t, 'system-ok');
    expect(has('path-list'), isTrue);
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
