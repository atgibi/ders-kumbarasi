/// Veli alanı: abonelik (yalnızca veli kapısının arkasında).
///
/// Mağaza satın alma bağlantısı (App Store / Google Play + RevenueCat) henüz
/// kurulmadı; bu ekran fiyatı ve koşulları dürüstçe gösterir, satın alma
/// düğmesi bağlantı kurulana kadar pasiftir.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../game/world.dart';
import '../theme.dart';
import '../widgets/dk_icon.dart';
import '../widgets/kit.dart';

const subscriptionPrice = '149,99 TL';
const trialDays = 3;

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = app.settings;
    Widget bullet(String t) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: DkIcon(DkIcons.check, size: 20, color: K.goodInk),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(t, style: T.pBody)),
          ]),
        );
    return Scaffold(
      backgroundColor: K.bgParent,
      body: SafeArea(
        child: Column(children: [
          ParentHeader(
              title: 'Abonelik', onBack: () => Navigator.of(context).pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DkCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          s.premium
                              ? 'Diyarın tamamı açık'
                              : 'Diyarın tamamını açın',
                          style: T.pTitle),
                      const SizedBox(height: 8),
                      const Text(
                          'Ücretsiz sürümde her krallığın ilk $freeRegionsPerKingdom bölümü açıktır. Abonelikle:',
                          style: T.pBodySoft),
                      const SizedBox(height: 10),
                      bullet(
                          'Tüm krallıkların bütün bölümleri ve bekçi düelloları'),
                      bullet('Tüm sınıfların soruları ve konu anlatımları'),
                      bullet('Yıl boyunca gelen yeni maceralar ve şenlikler'),
                      const SizedBox(height: 4),
                      const Text(
                          'Abonelik bitse de hiçbir şey silinmez: kahraman, kasaba ve ilerleme kalır; tekrar motoru ücretsiz çalışmaya devam eder. Abonelik oyunda ışık, malzeme ya da hız satmaz.',
                          style: T.pBodySoft),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const DkCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                          '$trialDays gün ücretsiz, sonra $subscriptionPrice / ay',
                          style: T.pStrong),
                      SizedBox(height: 6),
                      Text(
                          'Abonelik deneme süresi bitince her ay kendiliğinden yenilenir. App Store ya da Google Play abonelik ayarlarından istediğiniz zaman iptal edebilirsiniz; iptal, o ayın sonunda geçerli olur.',
                          style: T.pSmall),
                      SizedBox(height: 12),
                      ChunkyButton(
                        key: Key('subscribe'),
                        label: '$trialDays günü ücretsiz başlat',
                        onPressed: null,
                      ),
                      SizedBox(height: 8),
                      Text(
                          'Mağaza bağlantısı henüz kurulmadı; satın alma uygulama mağazaya çıkmadan önce açılacak.',
                          style: T.pSmall),
                      TextBtn(
                        label: 'Satın alımları geri yükle',
                        onPressed: null,
                      ),
                    ],
                  ),
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 12),
                  ListBox(children: [
                    ToggleRow(
                      key: const Key('dev-premium'),
                      boxed: false,
                      parent: true,
                      title: 'Geliştirici: tüm bölgeleri aç',
                      subtitle: 'Yalnızca geliştirme sürümünde görünür',
                      value: s.premium,
                      onChanged: (v) =>
                          app.updateSettings(s.copyWith(premium: v)),
                    ),
                  ]),
                ],
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
