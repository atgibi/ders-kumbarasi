/// Kahraman figürü: tasarımdaki el çizimi kahraman (bkz. hero_svg.dart).
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../game/game_state.dart';
import '../../game/world.dart';
import 'hero_svg.dart';

class HeroFigure extends StatelessWidget {
  const HeroFigure({
    super.key,
    required this.look,
    this.stage = HeroStage.cirak,
    this.size = 160,
    this.showCompanion = true,
    this.cheer = false,
    this.semanticLabel,
  });

  final HeroLook look;
  final HeroStage stage;

  /// Genişlik; yükseklik 1,1 katı.
  final double size;
  final bool showCompanion;

  /// Kutlama pozu (kol havada, gülen yüz).
  final bool cheer;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final path = look.heroPath;
    return Semantics(
      image: true,
      label: semanticLabel ??
          '${look.girl ? 'Kız' : 'Erkek'} kahraman, ${path.name} yolu, '
              '${stage.label}${look.chair ? ', tekerlekli sandalyede' : ''}',
      child: ExcludeSemantics(
        child: SvgPicture.string(
          heroSvg(look, stage: stage, cheer: cheer, companion: showCompanion),
          width: size,
          height: size * 228 / 208,
        ),
      ),
    );
  }
}
