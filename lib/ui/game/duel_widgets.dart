/// Bekçi düellosu: zırh göstergesi ve zafer ekranı.
library;

import 'package:flutter/material.dart';

import '../../game/world.dart';
import '../theme.dart';
import '../widgets/emoji_text.dart';
import '../widgets/kit.dart';
import '../widgets/mascot.dart';
import 'game_theme.dart';

/// Üstte bekçi ve sis zırhı parçaları. Her doğru cevapta bir parça düşer;
/// yanlışta parça yerinde kalır ("henüz düşmedi"), can kaybı yok.
class DuelHeader extends StatelessWidget {
  const DuelHeader({
    super.key,
    required this.guardian,
    required this.pieces,
    required this.fallen,
  });
  final Guardian guardian;
  final int pieces;
  final int fallen;

  @override
  Widget build(BuildContext context) {
    final left = pieces - fallen;
    return Semantics(
      key: const Key('duel-header'),
      liveRegion: true,
      label: '${guardian.name}: $pieces zırh parçasından $fallen tanesi düştü',
      child: ExcludeSemantics(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Color.lerp(
                G.fogLight, G.paper, fallen / (pieces == 0 ? 1 : pieces)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: G.ink, width: 2),
          ),
          child: Row(children: [
            Opacity(
              opacity: 0.45 + 0.55 * (fallen / (pieces == 0 ? 1 : pieces)),
              child: EmojiImage(guardian.emoji, size: 44),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(guardian.name,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: G.ink)),
                  const SizedBox(height: 4),
                  Wrap(spacing: 4, runSpacing: 4, children: [
                    for (var i = 0; i < pieces; i++)
                      AnimatedContainer(
                        duration: Duration(
                            milliseconds: reduceMotion(context) ? 0 : 400),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: i < left ? G.fog : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: i < left ? G.ink : G.fogLight, width: 2),
                        ),
                      ),
                  ]),
                ],
              ),
            ),
            Text(left == 0 ? 'Zırh düştü!' : '$left parça',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: G.indigo)),
          ]),
        ),
      ),
    );
  }
}

/// Zafer: bekçi sevimli haline döner, sancak dikilir.
class DuelWinView extends StatelessWidget {
  const DuelWinView({
    super.key,
    required this.region,
    required this.gift,
    required this.onDone,
    required this.onSay,
  });
  final RegionDef region;
  final bool gift;
  final VoidCallback onDone;
  final void Function(String, {bool slow}) onSay;

  @override
  Widget build(BuildContext context) {
    final g = region.guardian;
    final k = Kingdom.of(region.subject);
    final title = regionTitle(k, region.index);
    return ColoredBox(
      color: G.paper,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ListenButton(
                  onListen: () => onSay('${g.name} kurtuldu! ${g.thanks}')),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ZAFER', style: G.kicker),
                    const SizedBox(height: 6),
                    Text('$title kurtuldu!', style: G.title),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        EmojiImage(g.emoji, size: 96),
                        const SizedBox(width: 12),
                        const EmojiImage(bannerEmoji, size: 72),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Parchment(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g.name, style: G.sub),
                          const SizedBox(height: 4),
                          Text('“${g.thanks}”', style: G.body),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    EmojiText(
                        '$bannerEmoji Sancağın dikildi · ${k.material.emoji} +5 ${k.material.label.toLowerCase()}',
                        style: G.sub),
                    if (gift) ...[
                      const SizedBox(height: 8),
                      EmojiText(
                          '🎁 ${g.name} sana bir hediye bıraktı: $lightEmoji +10 ışık',
                          style: G.sub.copyWith(color: G.emerald)),
                    ] else ...[
                      const SizedBox(height: 10),
                      const Row(children: [
                        Mascot(mood: MascotMood.think, size: 56),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                              'Bu bölgenin konularını biraz daha tekrar edelim, ışığın daha da parlasın.',
                              style: G.body),
                        ),
                      ]),
                    ],
                    const SizedBox(height: 8),
                    Text(
                        '${g.name} kasabana taşınıyor. Onu Kasaba sekmesinde görebilirsin.',
                        style: G.soft),
                  ],
                ),
              ),
            ),
            ChunkyButton(
              key: const Key('duel-done'),
              label: 'Sancağı dik',
              kind: BtnKind.good,
              onPressed: onDone,
            ),
          ],
        ),
      ),
    );
  }
}
