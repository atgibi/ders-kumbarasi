/// Yalnızca web derlemesinde, adres çubuğunda `?demo=...` verilirse örnek bir
/// profil hazırlar (tanıtım ve ekran görüntüsü için). Mobil uygulamada etkisi yoktur.
///
/// - `?demo=onboarding` : ilk kurulum ekranı
/// - `?demo=path`       : birkaç konusu bitmiş örnek profil, yol ekranı
/// - `?demo=lesson`     : sıradaki konunun anlatımı
/// - `?demo=question`   : bitmiş bir konunun alıştırma sorusu
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'app/app_state.dart';
import 'core/srs/leitner.dart';
import 'data/models.dart';
import 'ui/screens/session_screen.dart';

String? get demoMode => kIsWeb ? Uri.base.queryParameters['demo'] : null;

Future<void> applyDemo(AppState state) async {
  final demo = demoMode;
  if (demo == null) return;
  // Otomatik ekran görüntüsü aracı düğmeleri erişilebilirlik ağacından bulur
  SemanticsBinding.instance.ensureSemantics();
  await state.load();
  await state.deleteAll();
  if (demo == 'onboarding') return;
  await state.addChild('Elif', 1, '🦊');
  await state.selectChild(state.profiles.first);
  final p = state.progress!;
  final now = state.clock();
  const done = ['MAT.1.1.1', 'MAT.1.1.2', 'MAT.1.1.3'];
  final pack = await state.content.contentFor(Subject.matematik, 1);
  for (final code in done) {
    p.startedOutcomes.add(code);
    for (final c in pack[code]?.cards ?? const <CardDef>[]) {
      p.cards[c.id] = CardState(
        cardId: c.id,
        box: code == 'MAT.1.1.1' ? 4 : 2,
        due: now.add(const Duration(days: 2)),
        reviews: 4,
      );
    }
  }
  p.streakDays = 4;
  p.nuts = 87;
  await state.saveProgress();
}

/// Uygulama açıldıktan sonra demo oturumunu başlatır.
void openDemoSession(NavigatorState nav) {
  final demo = demoMode;
  if (demo != 'lesson' && demo != 'question') return;
  nav.push(MaterialPageRoute<void>(
    builder: (_) => SessionScreen(
      subject: Subject.matematik,
      focusOutcome: demo == 'lesson' ? 'MAT.1.1.4' : 'MAT.1.1.2',
    ),
  ));
}
