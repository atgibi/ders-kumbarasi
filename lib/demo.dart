/// Yalnızca web derlemesinde, adres çubuğunda `?demo=...` verilirse örnek bir
/// profil hazırlar (tanıtım ve ekran görüntüsü için). Mobil uygulamada etkisi yoktur.
///
/// - `onboarding` : ilk açılış
/// - `picker`     : iki çocuklu profil seçici
/// - `path`       : birkaç konusu bitmiş örnek profil, krallık haritası
/// - `hero`       : kahraman oluşturma
/// - `region`     : bir bölgenin konuları ve bekçi kartı
/// - `duel`       : bekçi düellosu
/// - `lesson`     : sıradaki konunun anlatımı
/// - `question`   : bitmiş bir konunun alıştırma sorusu
/// - `parent`     : veli paneli (kapı atlanır)
/// - `quiet` / `timeup` / `done` : sistem ekranları
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'app/app_state.dart';
import 'core/srs/leitner.dart';
import 'data/models.dart';
import 'data/progress_store.dart';
import 'game/game_state.dart';
import 'game/world.dart';
import 'ui/game/region_screen.dart';
import 'ui/game/wardrobe_screen.dart';
import 'ui/screens/parent_screen.dart';
import 'ui/screens/session_screen.dart';
import 'ui/screens/system_screens.dart';

String? get demoMode => kIsWeb ? Uri.base.queryParameters['demo'] : null;

Future<void> applyDemo(AppState state) async {
  final demo = demoMode;
  if (demo == null) return;
  // Otomatik ekran görüntüsü aracı düğmeleri erişilebilirlik ağacından bulur
  SemanticsBinding.instance.ensureSemantics();
  await state.load();
  await state.deleteAll();
  if (demo == 'onboarding') return;
  await state.updateSettings(state.settings.copyWith(onboarded: true));
  final elif = await state.addChild('Elif', 1, '1');
  final kerem = await state.addChild('Kerem', 4, '3');
  if (demo == 'picker') return;
  await state.selectChild(elif);
  state.selectSubject(Subject.matematik);
  final p = state.progress!;
  final now = state.clock();
  const done = {'MAT.1.1.1': 4, 'MAT.1.1.2': 4, 'MAT.1.1.3': 2, 'MAT.1.1.4': 1};
  final pack = await state.content.contentFor(Subject.matematik, 1);
  for (final e in done.entries) {
    p.startedOutcomes.add(e.key);
    var i = 0;
    for (final c in pack[e.key]?.cards ?? const <CardDef>[]) {
      p.cards[c.id] = CardState(
        cardId: c.id,
        box: e.value,
        // Bazı kartların tekrar zamanı gelmiş olsun
        due: now.add(Duration(days: i++ % 3 == 0 ? -1 : 2)),
        reviews: 4,
      );
    }
    p.addAttempt(e.key, Attempt(dayKey(now), 'Hangi grup daha çok?', 'first'));
  }
  final week = state.week();
  final minutes = [12, 15, 0, 9, 16, 0, 0];
  for (var i = 0; i < 7; i++) {
    if (week[i].isFuture || week[i].isToday) continue;
    final d = now.subtract(Duration(days: now.weekday - 1 - i));
    if (minutes[i] > 0) {
      p.dailyMinutes[dayKey(d)] = minutes[i];
      p.dailyAnswers[dayKey(d)] = [10, 8];
    }
  }
  p.streakDays = 5;
  p.nuts = 128;
  if (demo != 'hero') {
    final g = p.game
      ..hero =
          const HeroLook(girl: true, path: 1, skin: 2, hair: 2, hairColor: 1)
      ..addSupply(Supply.demir, 9)
      ..addSupply(Supply.ekmek, 2)
      ..built['ev'] = 1
      ..built['ocak'] = 1
      ..banners.add('matematik-1-0')
      ..rescued.add('matematik-1-0');
    g.addPage(dayKey(now.subtract(const Duration(days: 3))),
        "Elif bugün Demirdağ'da \"Sayılar ve rakamlar\" konusunu öğrendi.");
    g.addPage(dayKey(now.subtract(const Duration(days: 1))),
        "Elif, Demirdağ'da Dişli Geçidi bölgesine sancağını dikti. Taş Golem sisten kurtuldu.");
    // Efsane demosu: Karabulut tüm krallıklarda barışmış.
    if (demo == 'legend') {
      g.finale.addAll([for (final s in Subject.forGrade(1)) s.id]);
    }
    // Giysi dolabı demosu: beş bölge kurtarılmış, birkaç eşya takılı.
    if (demo == 'wardrobe') {
      g.banners.addAll([
        'matematik-1-1',
        'turkce-1-0',
        'turkce-1-1',
        'hayat_bilgisi-1-0',
      ]);
      g.equip.addAll({
        'bas': 'cicek_taci',
        'sirt': 'canta',
        'el': 'fener',
        'rozet': 'rozet_yildiz',
      });
    }
    // Kasaba demosu: farklı seviyelerde yapılarla dolu izometrik kasaba.
    if (demo == 'town') {
      g.built.addAll({
        'ev': 3,
        'ocak': 2,
        'firin': 2,
        'demirhane': 1,
        'kitaplik': 3,
        'cesme': 3,
        'bahce': 2,
        'gozlemevi': 3,
        'han': 2,
      });
    }
  }
  await state.saveProgress();
  // Kerem: henüz çalışmadı (veli panelinde boş durum)
  await state.store.saveProgress(kerem.id, ChildProgress());
  await prepareDemoRegions(state);
}

List<Outcome> _regionOutcomes = const [];
List<Outcome> _duelOutcomes = const [];

/// Bölge/düello demoları için çıktıları önceden yükler.
Future<void> prepareDemoRegions(AppState state) async {
  if (demoMode != 'region' && demoMode != 'duel') return;
  final rs = await state.regions(Subject.matematik, 1);
  _duelOutcomes = rs[0].outcomes;
  _regionOutcomes = rs[1].outcomes;
}

/// Uygulama açıldıktan sonra demo ekranını açar.
void openDemoSession(NavigatorState nav) {
  final demo = demoMode;
  final Widget? page = switch (demo) {
    'lesson' => const SessionScreen(
        subject: Subject.matematik, focusOutcome: 'MAT.1.1.5'),
    'question' => const SessionScreen(
        subject: Subject.matematik, focusOutcome: 'MAT.1.1.2'),
    'parent' => const ParentScreen(),
    'region' => RegionScreen(
        region: RegionDef(
            subject: Subject.matematik,
            grade: 1,
            index: 1,
            outcomes: _regionOutcomes)),
    'duel' => SessionScreen(
        subject: Subject.matematik,
        duel: RegionDef(
            subject: Subject.matematik,
            grade: 1,
            index: 0,
            outcomes: _duelOutcomes)),
    'finale' => const SessionScreen(subject: Subject.matematik, finale: true),
    'wardrobe' => const WardrobeScreen(),
    'quiet' => const SystemScreen(kind: SystemKind.quiet),
    'timeup' => const SystemScreen(kind: SystemKind.timeUp),
    'done' => const SystemScreen(kind: SystemKind.doneToday),
    _ => null,
  };
  if (page != null) nav.push(MaterialPageRoute<void>(builder: (_) => page));
}
