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
