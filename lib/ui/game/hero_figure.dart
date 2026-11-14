/// Kahraman figürü: tasarımdaki el çizimi kahraman (bkz. hero_svg.dart).
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../game/game_state.dart';
import '../../game/item_art.g.dart';
import '../../game/items.dart';
import '../../game/world.dart';
import '../theme.dart';
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
    this.gear,
  });

  final HeroLook look;
  final HeroStage stage;

  /// Genişlik; yükseklik 1,1 katı.
  final double size;
  final bool showCompanion;

  /// Kutlama pozu (kol havada, gülen yüz).
  final bool cheer;
  final String? semanticLabel;

  /// Takılacak eşyalar ve yol arkadaşı aşaması. Verilmezse etkin çocuğun
  /// oyun durumundan okunur (giysi dolabında önizleme için verilir).
  final HeroGear? gear;

  @override
  Widget build(BuildContext context) {
    final path = look.heroPath;
    final game = context
        .dependOnInheritedWidgetOfExactType<AppScope>()
        ?.notifier
        ?.progress
        ?.game;
    final g = gear ?? (game == null ? HeroGear.none : HeroGear.of(game));
    return Semantics(
      image: true,
      label: semanticLabel ??
          '${look.girl ? 'Kız' : 'Erkek'} kahraman, ${path.name} yolu, '
              '${stage.label}${look.chair ? ', tekerlekli sandalyede' : ''}',
      child: ExcludeSemantics(
        child: SvgPicture.string(
          heroSvg(look,
              stage: stage,
              cheer: cheer,
              companion: showCompanion,
              back: [
                for (final i in g.items)
                  if (itemBack.contains(i.id)) itemArt[i.id] ?? ''
              ],
              front: [
                for (final i in g.items)
                  if (!itemBack.contains(i.id)) itemArt[i.id] ?? ''
              ],
              companionScale: g.companion.scale,
              companionGrown: g.companion == CompanionStage.yetiskin),
          width: size,
          height: size * 228 / 208,
        ),
      ),
    );
  }
}

/// Kahramanın üstündekiler: takılı eşyalar ve yol arkadaşının aşaması.
class HeroGear {
  const HeroGear(this.items, this.companion);
  final List<ItemDef> items;
  final CompanionStage companion;

  static const none = HeroGear([], CompanionStage.yetiskin);

  factory HeroGear.of(GameState g) =>
      HeroGear(equippedItems(g), companionStage(g.banners.length));
}
