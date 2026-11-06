/// Yıl sonu düellosu: Karabulut. Kahraman aşamasına gelen çocuk her
/// krallıkta Karabulut'la bir kez yüzleşir; o krallıkta başladığı tüm
/// konulardan karma sorular gelir. Dört krallıkta da barışınca kahraman
/// Efsane olur.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/models.dart';
import '../../game/game_state.dart';
import '../../game/turkish.dart';
import '../../game/world.dart';
import '../screens/session_screen.dart';
import '../theme.dart';
import '../widgets/ikon.dart';
import '../widgets/kit.dart';
import 'game_theme.dart';
import 'hero_figure.dart';
import 'karabulut_svg.dart';

class KarabulutFigure extends StatelessWidget {
  const KarabulutFigure({
    super.key,
    this.hal = KarabulutHal.kus,
    this.size = 160,
    this.fog = 1,
    this.ground = true,
  });
  final KarabulutHal hal;
  final double size;
  final double fog;
  final bool ground;

  @override
  Widget build(BuildContext context) => SvgPicture.string(
        karabulutSvg(hal, fog: fog, ground: ground),
        width: size,
        height: size * 200 / 240,
      );
}

/// Kahraman sekmesindeki yıl sonu kartı.
class YearEndCard extends StatelessWidget {
  const YearEndCard({super.key, required this.stage});
  final HeroStage stage;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final grade = app.active?.grade ?? 1;
    final done = app.progress?.game.finale ?? const <String>{};
    final open = stage.index >= HeroStage.kahraman.index;
    final legend = stage == HeroStage.efsane;
    return DkCard(
      key: const Key('year-end'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            KarabulutFigure(
              hal: legend ? KarabulutHal.dost : KarabulutHal.kus,
              size: 96,
              ground: false,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('YIL SONU', style: G.kicker),
                  const Text('Karabulut', style: G.title),
                  Text(
                    legend
                        ? 'Karabulut artık dostun. Filizlere yağmur yağdırıyor.'
                        : open
                            ? 'Küs bulut dev, krallıkların üstüne sis savuruyor. '
                                'Her krallıkta onunla bir kez yüzleş.'
                            : 'Kahraman olunca Karabulut seni bekliyor. '
                                '${nextStageHint(stage)}',
                    style: G.soft,
                  ),
                ],
              ),
            ),
          ]),
          if (open) ...[
            const SizedBox(height: 12),
            for (final s in Subject.forGrade(grade))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _KingdomRow(subject: s, done: done.contains(s.id)),
              ),
          ],
        ],
      ),
    );
  }
}

class _KingdomRow extends StatelessWidget {
  const _KingdomRow({required this.subject, required this.done});
  final Subject subject;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final k = Kingdom.of(subject);
    return Row(children: [
      Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(color: k.color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(k.name,
            style: G.body.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ),
      if (done)
        Row(mainAxisSize: MainAxisSize.min, children: [
          const IkonView(Ikon.sancak, size: 24),
          const SizedBox(width: 4),
          Text('Barıştınız', style: G.hand.copyWith(color: G.emerald)),
        ])
      else
        SizedBox(
          width: 130,
          child: ChunkyButton(
            key: Key('finale-${subject.id}'),
            label: 'Yüzleş',
            kind: BtnKind.primary,
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => SessionScreen(subject: subject, finale: true))),
          ),
        ),
    ]);
  }
}

/// Düello sırasında üstte: sis bulutları her doğru cevapta incelir.
class KarabulutHeader extends StatelessWidget {
  const KarabulutHeader({
    super.key,
    required this.pieces,
    required this.fallen,
    required this.kingdom,
  });
  final int pieces;
  final int fallen;
  final Kingdom kingdom;

  @override
  Widget build(BuildContext context) {
    final hero = AppScope.of(context).progress?.game.hero;
    final fog = pieces == 0 ? 0.0 : 1 - fallen / pieces;
    return Semantics(
      key: const Key('finale-header'),
      liveRegion: true,
      label: 'Karabulut: $pieces sis bulutundan $fallen tanesi dağıldı',
      child: ExcludeSemantics(
        child: SizedBox(
          height: 160,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color.lerp(G.fogLight, G.paper, 1 - fog),
            ),
            child: Stack(children: [
              Positioned(
                right: 10,
                bottom: 4,
                child: KarabulutFigure(fog: fog, size: 170, ground: false),
              ),
              if (hero != null)
                Positioned(
                  left: 12,
                  bottom: 4,
                  child: HeroFigure(look: hero, size: 92, showCompanion: false),
                ),
              Positioned(
                left: 14,
                top: 8,
                child: Text('${pieces - fallen} sis bulutu kaldı',
                    style: G.hand.copyWith(color: kingdom.color)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Düello bitti: Karabulut barışır, o krallıkta yağmur yağdırır.
class FinaleWinView extends StatelessWidget {
  const FinaleWinView({
    super.key,
    required this.subject,
    required this.legend,
    required this.onDone,
    required this.onSay,
  });
  final Subject subject;
  final bool legend;
  final VoidCallback onDone;
  final void Function(String, {bool slow}) onSay;

  @override
  Widget build(BuildContext context) {
    final k = Kingdom.of(subject);
    final game = AppScope.of(context).progress?.game;
    final hero = game?.hero;
    final line = legend
        ? 'Karabulut dört krallıkta da barıştı. Artık sen bir Efsanesin!'
        : 'Karabulut ${k.name} üstündeki sisi topladı ve filizlere yağmur '
            'yağdırmaya başladı.';
    return ColoredBox(
      color: G.paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(children: [
              Expanded(
                  child: Text(legend ? 'Efsane oldun!' : 'Karabulut barıştı!',
                      style: G.title)),
              ListenButton(
                  size: 56, iconSize: 26, onListen: () => onSay(line)),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                    child: SpeechBubble(
                      tailLeft: 220,
                      fill: const Color(0xFFE3EAF0),
                      child: const Text(
                          'Beni hatırladınız. Ben de yağmuru hatırladım!',
                          style: const TextStyle(fontSize: 18, height: 1.35)),
                    ),
                  ),
                  SizedBox(
                    height: 220,
                    child: Stack(children: [
                      const Positioned(
                        right: 6,
                        bottom: 0,
                        child: KarabulutFigure(
                            hal: KarabulutHal.yagmur, size: 230),
                      ),
                      if (hero != null)
                        Positioned(
                          left: 4,
                          bottom: 0,
                          child: HeroFigure(
                              look: hero,
                              size: 120,
                              cheer: true,
                              stage: legend ? HeroStage.efsane : HeroStage.kahraman),
                        ),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                    child: DkCard(
                      key: const Key('year-summary'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${genitive(AppScope.of(context).heroName)} yılı',
                                style: G.sub.copyWith(color: G.indigo)),
                          const SizedBox(height: 6),
                          Row(children: [
                            const IkonView(Ikon.sancak, size: 26),
                            const SizedBox(width: 8),
                            Text('${game?.banners.length ?? 0} sancak dikildi',
                                style: G.body
                                    .copyWith(fontWeight: FontWeight.w700)),
                          ]),
                          const SizedBox(height: 4),
                          Row(children: [
                            const IkonView(Ikon.kalkan, size: 26),
                            const SizedBox(width: 8),
                            Text(
                                '${game?.rescued.length ?? 0} bekçi dost oldu',
                                style: G.body
                                    .copyWith(fontWeight: FontWeight.w700)),
                          ]),
                          const SizedBox(height: 8),
                          Text(line, style: G.soft),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            child: ChunkyButton(
              key: const Key('finale-done'),
              label: 'Deftere yaz',
              kind: BtnKind.kok,
              onPressed: onDone,
            ),
          ),
        ],
      ),
    );
  }
}
