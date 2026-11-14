/// El çizimi simge seti (Claude Design › Bileşenler › Simge).
/// SVG'ler tools/design/ikon.py ile üretilir.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../game/world.dart';

enum Ikon {
  isik,
  demir,
  kereste,
  ekmek,
  kristal,
  kumas,
  yildiz,
  sancak,
  tuy,
  mesale,
  dinle,
  yavas,
  kilit,
  kapi,
  anahtar,
  ayar,
  defter,
  harita,
  kasaba,
  kalkan,
  geri,
  ileri,
  tik,
  kapat,
  cadir,
  saat,
  nota,
  ses,
}

class IkonView extends StatelessWidget {
  const IkonView(this.ikon, {super.key, this.size = 32, this.light = false});
  final Ikon ikon;
  final double size;

  /// Kâğıt rengi çizgi (koyu zemin üstü).
  final bool light;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SvgPicture.asset(
          'assets/ikon/${ikon.name}${light ? '_k' : ''}.svg',
          width: size,
          height: size,
        ),
      );
}

/// Krallık malzemesinin simgesi.
Ikon ikonOf(Supply s) => Ikon.values.byName(s.id);

/// Krallık önderinin çizimi (Claude Design › Krallık önderleri).
String leaderAsset(Kingdom k, {bool wave = false}) => switch (k.name) {
      'Demirdağ' =>
        wave ? 'assets/onder/cark_selam.svg' : 'assets/onder/cark.svg',
      'Sözorman' => 'assets/onder/yaprak.svg',
      'Ocakvadi' => 'assets/onder/pelin.svg',
      'Işıkkaya' => 'assets/onder/dokum.svg',
      _ => 'assets/onder/elif.svg',
    };

class LeaderFigure extends StatelessWidget {
  const LeaderFigure(
      {super.key, required this.kingdom, this.size = 80, this.wave = false});
  final Kingdom kingdom;
  final double size;
  final bool wave;

  @override
  Widget build(BuildContext context) => Semantics(
        image: true,
        label: kingdom.leader,
        child: ExcludeSemantics(
          child: SvgPicture.asset(leaderAsset(kingdom, wave: wave),
              width: size, height: size * 208 / 168),
        ),
      );
}
