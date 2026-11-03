/// Bölge ekranı: bölgenin konuları (yol düğümleri) ve bekçi düellosu.
library;

import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../game/world.dart';
import '../screens/path_screen.dart';
import '../screens/session_screen.dart';
import '../screens/system_screens.dart';
import '../theme.dart';
import '../widgets/dk_icon.dart';
import '../widgets/emoji_text.dart';
import '../widgets/kit.dart';
import 'game_theme.dart';

class RegionScreen extends StatelessWidget {
  const RegionScreen({super.key, required this.region});
  final RegionDef region;

  /// İçeriği hazır bütün konulara başlandı mı (düello açılır)?
  Future<bool> _ready(AppState app) async {
    final pack = await app.content.contentFor(region.subject, region.grade);
    final ready = region.outcomes
        .where((o) => pack[o.code]?.cards.isNotEmpty ?? false)
        .toList();
    return ready.isNotEmpty &&
        ready.every((o) => app.progress!.startedOutcomes.contains(o.code));
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final k = Kingdom.of(region.subject);
    final p = app.progress!;
    return Scaffold(
      backgroundColor: G.paper,
      body: SafeArea(
        child: ChildTextScale(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 4),
              child: Row(children: [
                CircleBtn(
                  key: const Key('region-back'),
                  icon: DkIcons.left,
                  label: 'Haritaya dön',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(k.name.toUpperCase(),
                          style: G.kicker.copyWith(color: k.ink)),
                      Text(regionTitle(k, region.index), style: G.title),
                    ],
                  ),
                ),
              ]),
            ),
            Expanded(
              child: PathScreen(
                subject: region.subject,
                region: region.index,
                footer: FutureBuilder<bool>(
                  future: _ready(app),
                  builder: (context, snap) => _DuelCard(
                    region: region,
                    ready: snap.data ?? false,
                    freed: p.game.banners.contains(region.key),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _DuelCard extends StatelessWidget {
  const _DuelCard(
      {required this.region, required this.ready, required this.freed});
  final RegionDef region;
  final bool ready;
  final bool freed;

  Future<void> _start(BuildContext context) async {
    final app = AppScope.read(context);
    final nav = Navigator.of(context);
    switch (app.startBlock()) {
      case StartBlock.quiet:
        await nav.push(MaterialPageRoute<void>(
            builder: (_) => const SystemScreen(kind: SystemKind.quiet)));
        return;
      case StartBlock.timeUp:
        await nav.push(MaterialPageRoute<void>(
            builder: (_) => const SystemScreen(kind: SystemKind.timeUp)));
        return;
      case StartBlock.none:
        await nav.push(MaterialPageRoute<void>(
            builder: (_) =>
                SessionScreen(subject: region.subject, duel: region)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = region.guardian;
    final String text;
    if (freed) {
      text = '${g.name} kurtarıldı ve kasabanda yaşıyor. İstersen yeniden düello yap, konuları tekrar et.';
    } else if (ready) {
      text = '${g.name} geçidi kapatıyor. Her doğru cevap sis zırhından bir parça düşürür!';
    } else {
      text = 'Bölgenin bütün konularına başlayınca ${g.name} ile düello yapabilirsin.';
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Parchment(
        color: ready || freed ? Colors.white : G.paper2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Opacity(
                  opacity: ready || freed ? 1 : 0.4,
                  child: EmojiImage(g.emoji, size: 52)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('BEKÇİ DÜELLOSU', style: G.kicker),
                    Text(g.name, style: G.sub),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Text(text, style: G.body),
            if (ready || freed) ...[
              const SizedBox(height: 12),
              ChunkyButton(
                key: const Key('duel-start'),
                label: freed ? 'Yeniden düello' : 'Düelloya başla',
                kind: freed ? BtnKind.secondary : BtnKind.primary,
                onPressed: () => _start(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
