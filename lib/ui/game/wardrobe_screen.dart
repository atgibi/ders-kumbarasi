/// Giysi dolabı: kurtarılan bölgelerden gelen eşyaları kahramana takma ve
/// yol arkadaşının büyümesini görme yeri.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../game/item_art.g.dart';
import '../../game/items.dart';
import '../../game/world.dart';
import '../theme.dart';
import '../widgets/dk_icon.dart';
import '../widgets/kit.dart';
import 'game_theme.dart';
import 'hero_figure.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  Future<HeroStage>? _stage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppScope.read(context).markItemsSeen();
    });
  }

  Future<void> _tap(ItemDef item, bool open) async {
    final app = AppScope.read(context);
    if (!open) {
      app.say('Bu eşya bir bölgeyi daha kurtarınca açılacak.');
      return;
    }
    final wasOn = app.game.equip[item.slot.name] == item.id;
    if (!await app.wearItem(item)) return;
    app.say(wasOn ? '${item.name} çıkarıldı.' : '${item.name}. ${item.note}');
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    _stage ??= app.heroStage();
    final g = app.game;
    final hero = g.hero;
    final banners = g.banners.length;
    final comp = companionStage(banners);
    final next = companionNext(banners);
    final pathDef = hero?.heroPath;
    final open = unlockedItems(g).length;

    return Scaffold(
      backgroundColor: G.paper,
      body: SafeArea(
        child: ChildTextScale(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 4),
              child: Row(children: [
                CircleBtn(
                  key: const Key('wardrobe-back'),
                  icon: DkIcons.left,
                  label: 'Geri',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 10),
                const Expanded(child: Text('Giysi Dolabı', style: G.title)),
                Text('$open / ${items.length}', style: G.sub),
              ]),
            ),
            Expanded(
              child: ListView(
                key: const Key('wardrobe-list'),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  if (hero != null)
                    Parchment(
                      color: Colors.white,
                      child: Column(children: [
                        FutureBuilder<HeroStage>(
                          future: _stage,
                          builder: (context, snap) => HeroFigure(
                              look: hero,
                              stage: snap.data ?? HeroStage.cirak,
                              size: 170),
                        ),
                        const SizedBox(height: 6),
                        if (pathDef != null)
                          Text('${pathDef.companion} · ${comp.label}',
                              key: const Key('companion-stage'), style: G.sub),
                        Text(
                          next == null
                              ? 'Yol arkadaşın tamamen büyüdü!'
                              : '${next - banners} bölge daha kurtarınca büyüyecek.',
                          textAlign: TextAlign.center,
                          style: G.soft,
                        ),
                      ]),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    open == 0
                        ? 'İlk bölgeyi kurtarınca ilk eşyan gelir.'
                        : 'Kurtardığın her bölge yeni bir eşya getirir. '
                            'Takmak ya da çıkarmak için dokun.',
                    style: G.soft,
                  ),
                  for (final slot in ItemSlot.values) ...[
                    const SizedBox(height: 14),
                    Text(slot.label.toUpperCase(), style: G.kicker),
                    const SizedBox(height: 6),
                    LayoutBuilder(builder: (context, box) {
                      final w = (box.maxWidth - 24) / 4;
                      return Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final item in items)
                          if (item.slot == slot)
                            _ItemTile(
                              key: Key('item-${item.id}'),
                              item: item,
                              size: w,
                              open: isUnlocked(g, item),
                              worn: g.equip[slot.name] == item.id,
                              onTap: () => _tap(item, isUnlocked(g, item)),
                            ),
                      ]);
                    }),
                  ],
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    super.key,
    required this.item,
    required this.size,
    required this.open,
    required this.worn,
    required this.onTap,
  });
  final ItemDef item;
  final double size;
  final bool open;
  final bool worn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final svg = itemThumbSvg(item);
    return Pressable(
      label: open
          ? '${item.name}${worn ? ', takılı' : ''}'
          : 'Kilitli eşya. Bir bölge kurtarınca açılır.',
      selected: worn,
      onTap: onTap,
      builder: (context, down) => SizedBox(
        width: size,
        child: Column(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: size,
            height: size,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: !open
                  ? const Color(0xFFDDE3EA)
                  : (worn ? const Color(0xFFFFF1CC) : Colors.white),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: worn ? G.saffron : G.ink, width: worn ? 3.5 : 2),
              boxShadow: down
                  ? null
                  : const [
                      BoxShadow(color: Color(0x332B2320), offset: Offset(2, 3))
                    ],
            ),
            child: open
                ? SvgPicture.string(svg)
                : const Center(
                    child: Text('?',
                        style: TextStyle(
                            fontFamily: K.display,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: G.fog))),
          ),
          const SizedBox(height: 3),
          Text(open ? item.name : 'Kilitli',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                  fontFamily: K.display,
                  fontSize: 12,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: K.murekkep)),
        ]),
      ),
    );
  }
}

/// Eşyanın tek başına küçük resmi (dolap ve düello ödülü).
String itemThumbSvg(ItemDef item) {
  final art = itemArt[item.id] ?? '';
  final box = itemBox[item.id] ?? '0 0 208 228';
  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="$box">'
      '<g stroke="#2B2320" stroke-width="2.4" stroke-linecap="round" '
      'stroke-linejoin="round">$art</g></svg>';
}
