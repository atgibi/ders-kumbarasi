/// Bekçi düellosu (Claude Design E18–E23): sisli sahne, zırh göstergesi,
/// zırhlı bekçi ve zafer ekranı.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../game/items.dart';
import '../../game/world.dart';
import '../theme.dart';
import '../widgets/emoji_text.dart';
import '../widgets/hand.dart';
import '../widgets/ikon.dart';
import '../widgets/kit.dart';
import '../widgets/mascot.dart';
import 'game_theme.dart';
import 'guardian_svg.dart';
import 'hero_figure.dart';
import 'wardrobe_screen.dart';

/// Bekçinin çizimi; tasarımda çizimi olmayanlar için emoji.
class GuardianFigure extends StatelessWidget {
  const GuardianFigure({
    super.key,
    required this.guardian,
    this.size = 160,
    this.armored = false,
    this.remaining = 8,
  });
  final Guardian guardian;
  final double size;
  final bool armored;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    final label = armored
        ? '${guardian.name}, sisten zırhlı, $remaining parça duruyor'
        : '${guardian.name}, kurtarılmış';
    if (!drawnGuardians.contains(guardian.id)) {
      return Semantics(
        image: true,
        label: label,
        child: ExcludeSemantics(
          child: Opacity(
            opacity: armored ? .5 + .5 * (1 - remaining / 8) : 1,
            child: EmojiImage(guardian.emoji, size: size * .6),
          ),
        ),
      );
    }
    final golem = guardian.id == 'golem';
    return Semantics(
      image: true,
      label: label,
      child: ExcludeSemantics(
        child: SvgPicture.string(
          guardianSvg(guardian.id, armored: armored, remaining: remaining),
          width: size,
          height: size * (golem ? 272 / 252 : 232 / 212),
        ),
      ),
    );
  }
}

/// Zırh göstergesi: 8 kalkan; düşenler kesik çizgili.
class ArmorStrip extends StatelessWidget {
  const ArmorStrip({super.key, required this.pieces, required this.left});
  final int pieces;
  final int left;

  @override
  Widget build(BuildContext context) => HandBox(
        style: HandStyle.el.copyWith(fill: K.kagit3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [
          const Text('Zırh',
              style: TextStyle(
                  fontFamily: K.display,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: K.murekkep)),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(spacing: 4, runSpacing: 4, children: [
              for (var i = 0; i < pieces; i++)
                SvgPicture.string(
                  '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 26">'
                  '<path d="M2 3H18V14C18 20 13 24 10 25C7 24 2 20 2 14Z" '
                  'fill="${i < left ? '#9AA6B2' : 'none'}" '
                  'stroke="${i < left ? '#2B2320' : '#8C8178'}" stroke-width="2" '
                  '${i < left ? '' : 'stroke-dasharray="3 3"'}/></svg>',
                  width: 18,
                  height: 24,
                ),
            ]),
          ),
          Text(left == 0 ? 'Zırh düştü!' : '$left / $pieces',
              style: const TextStyle(
                  fontFamily: K.display,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: K.lacivert)),
        ]),
      );
}

/// Düello sahnesinin zemini: gök, iki yanda kaya, ortada dişli kapı, sis.
class _DuelBackdrop extends CustomPainter {
  _DuelBackdrop({required this.victory, required this.kingdom});
  final bool victory;
  final Kingdom kingdom;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final gok = victory ? const Color(0xFFCFE0E6) : const Color(0xFFD8DCDF);
    final kaya =
        victory ? kingdom.color.withValues(alpha: .8) : const Color(0xFFA39A8A);
    final zemin = victory ? const Color(0xFF5E7A3A) : const Color(0xFFB9B2A2);
    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeJoin = StrokeJoin.round
      ..color = K.murekkep;
    canvas.drawRect(Offset.zero & size, Paint()..color = gok);
    canvas.drawCircle(Offset(w / 2, h * .55), h * .5,
        Paint()..color = victory ? K.safran : const Color(0xFFB7C0C9));
    final sol = Path()
      ..moveTo(-10, h * .25)
      ..lineTo(w * .15, h * .15)
      ..lineTo(w * .28, h * .35)
      ..lineTo(w * .3, h)
      ..lineTo(-10, h)
      ..close();
    final sag = Path()
      ..moveTo(w + 10, h * .22)
      ..lineTo(w * .85, h * .12)
      ..lineTo(w * .72, h * .38)
      ..lineTo(w * .69, h)
      ..lineTo(w + 10, h)
      ..close();
    for (final p in [sol, sag]) {
      canvas.drawPath(p, Paint()..color = kaya);
      canvas.drawPath(p, ink);
    }
    final yer = Path()
      ..moveTo(-10, h * .88)
      ..quadraticBezierTo(w / 2, h * .8, w + 10, h * .88)
      ..lineTo(w + 10, h)
      ..lineTo(-10, h)
      ..close();
    canvas.drawPath(yer, Paint()..color = zemin);
    canvas.drawPath(yer, ink);
    if (!victory) {
      final sis = Path()
        ..moveTo(-30, h * .1)
        ..cubicTo(w * .1, 0, w * .3, h * .2, w * .5, h * .12)
        ..cubicTo(w * .7, h * .04, w * .85, h * .2, w + 30, h * .12)
        ..lineTo(w + 30, h * .4)
        ..cubicTo(w * .8, h * .34, w * .6, h * .46, w * .45, h * .38)
        ..cubicTo(w * .3, h * .32, w * .1, h * .44, -30, h * .38)
        ..close();
      canvas.drawPath(sis, Paint()..color = const Color(0xB3C9D1D9));
    } else {
      // çiçekler
      for (final x in [w * .05, w * .12, w * .86, w * .94]) {
        canvas.drawCircle(Offset(x, h * .86), 4, Paint()..color = K.safran);
        canvas.drawCircle(
            Offset(x, h * .86),
            4,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4
              ..color = K.murekkep);
      }
    }
  }

  @override
  bool shouldRepaint(_DuelBackdrop old) =>
      old.victory != victory || old.kingdom != kingdom;
}

/// Düello üstü: zırh göstergesi ve sisli sahnede zırhlı bekçi. Her doğru
/// cevapta bir parça düşer; yanlışta parça yerinde kalır, can kaybı yok.
class DuelHeader extends StatelessWidget {
  const DuelHeader({
    super.key,
    required this.guardian,
    required this.pieces,
    required this.fallen,
    this.kingdom,
  });
  final Guardian guardian;
  final int pieces;
  final int fallen;
  final Kingdom? kingdom;

  @override
  Widget build(BuildContext context) {
    final left = pieces - fallen;
    final hero = AppScope.of(context).progress?.game.hero;
    return Semantics(
      key: const Key('duel-header'),
      liveRegion: true,
      label: '${guardian.name}: $pieces zırh parçasından $fallen tanesi düştü',
      child: ExcludeSemantics(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: ArmorStrip(pieces: pieces, left: left),
          ),
          SizedBox(
            height: 170,
            child: CustomPaint(
              painter:
                  _DuelBackdrop(victory: false, kingdom: kingdom ?? demirdag),
              child: Stack(children: [
                Positioned(
                  right: 24,
                  bottom: 0,
                  child: GuardianFigure(
                      guardian: guardian,
                      size: 140,
                      armored: true,
                      remaining: left),
                ),
                if (hero != null)
                  Positioned(
                    left: 12,
                    bottom: 2,
                    child:
                        HeroFigure(look: hero, size: 92, showCompanion: false),
                  ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Zafer: bekçi sevimli hâline döner, kahraman sevinir, sancak dikilir.
class DuelWinView extends StatelessWidget {
  const DuelWinView({
    super.key,
    required this.region,
    required this.gift,
    required this.onDone,
    required this.onSay,
    this.newItem,
  });
  final RegionDef region;
  final bool gift;

  /// Bu bölgeyle açılan eşya (ilk kurtarışta).
  final ItemDef? newItem;
  final VoidCallback onDone;
  final void Function(String, {bool slow}) onSay;

  @override
  Widget build(BuildContext context) {
    final g = region.guardian;
    final k = Kingdom.of(region.subject);
    final title = regionTitle(k, region.index);
    final hero = AppScope.of(context).progress?.game.hero;
    return ColoredBox(
      color: G.paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(children: [
              Expanded(child: Text('$title açıldı!', style: G.title)),
              ListenButton(
                  size: 56,
                  iconSize: 26,
                  onListen: () => onSay('${g.name} kurtuldu! ${g.thanks}')),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                    child: SpeechBubble(
                      tailLeft: 220,
                      fill: const Color(0xFFE3EAF0),
                      child: Text(g.thanks,
                          style: const TextStyle(fontSize: 18, height: 1.35)),
                    ),
                  ),
                  SizedBox(
                    height: 230,
                    child: CustomPaint(
                      painter: _DuelBackdrop(victory: true, kingdom: k),
                      child: Stack(children: [
                        Positioned(
                          right: 18,
                          bottom: 0,
                          child: GuardianFigure(guardian: g, size: 150),
                        ),
                        if (hero != null)
                          Positioned(
                            left: 4,
                            bottom: 0,
                            child:
                                HeroFigure(look: hero, size: 130, cheer: true),
                          ),
                        const Positioned(
                          left: 140,
                          bottom: 14,
                          child: Waving(child: IkonView(Ikon.sancak, size: 72)),
                        ),
                      ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                    child: DkCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const IkonView(Ikon.sancak, size: 30),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('$title açıldı. Bölge renkleniyor.',
                                  style: const TextStyle(
                                      fontSize: 17, height: 1.3)),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          Row(children: [
                            IkonView(ikonOf(k.material), size: 26),
                            const SizedBox(width: 6),
                            Text('+5 ${k.material.label.toLowerCase()}',
                                style: G.sub),
                            if (gift) ...[
                              const SizedBox(width: 16),
                              const IkonView(Ikon.isik, size: 26),
                              const SizedBox(width: 6),
                              const Text('+10 ışık', style: G.sub),
                            ],
                          ]),
                          if (gift) ...[
                            const SizedBox(height: 6),
                            Text('${g.name} sana bir hediye bıraktı!',
                                style: G.hand.copyWith(color: G.emerald)),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (newItem != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
                      child: DkCard(
                        key: const Key('duel-item'),
                        child: Row(children: [
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: SvgPicture.string(itemThumbSvg(newItem!)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Yeni eşya: ${newItem!.name}',
                                    style: G.sub),
                                const Text('Giysi dolabında seni bekliyor.',
                                    style: G.soft),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ),
                  if (!gift)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
                      child: Text(
                          'Bu bölgenin konularını biraz daha tekrar edelim, ışığın daha da parlasın.',
                          style: G.hand.copyWith(fontSize: 16)),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
                    child: Text(
                        '${g.name} kasabana taşınıyor ve sana bir mektup yazdı.',
                        style: G.soft),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            child: ChunkyButton(
              key: const Key('duel-done'),
              label: 'Sancağı dik',
              kind: BtnKind.kok,
              onPressed: onDone,
            ),
          ),
        ],
      ),
    );
  }
}
