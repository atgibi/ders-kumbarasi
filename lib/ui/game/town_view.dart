/// İzometrik kasaba: kurulan yapılar ızgarada görünür, seviyeyle büyür.
/// Bir yapıya dokunup "Taşı" denirse boş karelerden birine taşınır.
/// Köylüler yolda yürür, ocaktan duman çıkar (hareketi azaltta durur).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../game/town_layout.dart';
import '../../game/world.dart';
import '../theme.dart';
import '../widgets/kit.dart';
import 'game_theme.dart';
import 'town_art.g.dart';

/// Kare yarı genişliği ve yarı yüksekliği (mantıksal piksel, ölçeklenmeden).
const double _hw = 32, _hh = 16;

/// Uzun yapılar için üstte bırakılan boşluk.
const double _top = 92;

const double _canvasW = townSize * 2 * _hw;
const double _canvasH = _top + townSize * 2 * _hh + 12;

Offset _tileOrigin(Spot s) =>
    Offset(_canvasW / 2 + (s.x - s.y) * _hw - _hw, _top + (s.x + s.y) * _hh);

/// Yerel konumdan ızgara karesi (zemin düzleminde).
Spot _spotAt(Offset p) {
  final dx = (p.dx - _canvasW / 2) / _hw;
  final dy = (p.dy - _top) / _hh;
  return Spot(((dy + dx) / 2).floor(), ((dy - dx) / 2).floor());
}

class TownView extends StatefulWidget {
  const TownView({super.key});

  @override
  State<TownView> createState() => _TownViewState();
}

class _TownViewState extends State<TownView>
    with SingleTickerProviderStateMixin {
  /// Köylü yürüyüşü ve duman için tek saat (hareketi azaltta durur).
  late final AnimationController _clock = AnimationController(
      vsync: this, duration: const Duration(seconds: 40));

  String? _selected;
  bool _moving = false;

  /// Son çizimdeki seviyeler: yükselen yapı bir kez zıplar.
  Map<String, int>? _seen;
  final Set<String> _pop = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _clock.stop();
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  void _tap(Offset p, TownLayout layout, Map<String, int> built) {
    if (_moving && _selected != null) {
      final to = _spotAt(p);
      if (layout.isFree(to)) {
        final id = _selected!;
        AppScope.read(context).moveBuilding(id, to).then((ok) {
          if (!mounted) return;
          setState(() {
            _moving = false;
            if (ok) _pop.add(id);
          });
        });
      } else {
        setState(() => _moving = false);
      }
      return;
    }
    // Öndeki yapılar önce: yapının gövdesine dokunulduysa onu seç.
    final ids = built.keys.where((id) => layout.spotOf(id) != null).toList()
      ..sort((a, b) => layout.spotOf(b)!.depth - layout.spotOf(a)!.depth);
    for (final id in ids) {
      final o = _tileOrigin(layout.spotOf(id)!);
      final r = Rect.fromLTWH(o.dx + 8, o.dy + 16 - 70, 2 * _hw - 16, 86);
      if (r.contains(p)) {
        setState(() => _selected = _selected == id ? null : id);
        return;
      }
    }
    setState(() => _selected = null);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final g = app.game;
    final layout = app.townLayout();
    final built = {
      for (final e in g.built.entries)
        if (e.value > 0) e.key: e.value
    };
    final seen = _seen;
    if (seen != null) {
      for (final e in built.entries) {
        if ((seen[e.key] ?? 0) < e.value) _pop.add(e.key);
      }
    }
    _seen = Map.of(built);
    final motion = !reduceMotion(context);

    final cells = [
      for (var y = 0; y < townSize; y++)
        for (var x = 0; x < townSize; x++) Spot(x, y)
    ]..sort((a, b) => a.depth != b.depth ? a.depth - b.depth : a.x - b.x);

    final ground = <Widget>[
      for (final s in cells)
        _at(
            _tileOrigin(s),
            2 * _hw,
            40,
            _art(roadSpots.contains(s)
                ? 'tile_road'
                : (_moving && layout.isFree(s) ? 'tile_pick' : 'tile_grass'))),
    ];

    final things = <Widget>[];
    for (final s in cells) {
      final id = layout.buildingAt(s);
      final o = _tileOrigin(s);
      if (id != null && built.containsKey(id)) {
        final lv = built[id]!.clamp(1, BuildingDef.maxLevel);
        Widget w = _art('${id}_$lv');
        if (_pop.remove(id) && motion) {
          w = TweenAnimationBuilder<double>(
            key: ValueKey('pop-$id-$lv'),
            tween: Tween(begin: .55, end: 1),
            duration: const Duration(milliseconds: 650),
            curve: Curves.elasticOut,
            builder: (context, v, child) => Transform.scale(
                scale: v, alignment: Alignment.bottomCenter, child: child),
            child: w,
          );
        }
        if (_selected == id) {
          w = DecoratedBox(
            decoration: const BoxDecoration(
              boxShadow: [BoxShadow(color: Color(0x66E3A535), blurRadius: 18)],
            ),
            child: w,
          );
        }
        things.add(_at(o.translate(0, _hh - 80), 2 * _hw, 96, w,
            key: Key('town-building-$id')));
        if (id == 'ocak' && motion) {
          things.add(_Smoke(clock: _clock, at: o.translate(_hw - 10, -54)));
        }
      } else if (treeSpots.containsKey(s) && id == null) {
        things.add(_at(o.translate(_hw / 2, _hh - 42), _hw, 48,
            _art('tree_${treeSpots[s]}')));
      }
    }

    final villagers = math.min(4, (built.length + 1) ~/ 2);
    final walkers = <Widget>[
      for (var i = 0; i < villagers; i++)
        _Villager(clock: _clock, index: i, motion: motion),
    ];

    final sel = _selected;
    final selDef = sel == null ? null : buildingById(sel);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: built.isEmpty
              ? 'Kasaban henüz boş. Aşağıdan ilk yapını kur.'
              : 'Kasaban: ${built.length} yapı. '
                  '${[
                  for (final e in built.entries)
                    '${buildingById(e.key).name} ${e.value}. seviye'
                ].join(', ')}.',
          child: AspectRatio(
            aspectRatio: _canvasW / _canvasH,
            child: FittedBox(
              child: SizedBox(
                key: const Key('town-view'),
                width: _canvasW,
                height: _canvasH,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (d) => _tap(d.localPosition, layout, built),
                  child: Stack(clipBehavior: Clip.none, children: [
                    ...ground,
                    ...things,
                    ...walkers,
                    if (built.isEmpty)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: _top - 40,
                        child: Text('Kasaban seni bekliyor',
                            textAlign: TextAlign.center,
                            style: G.hand.copyWith(fontSize: 20)),
                      ),
                  ]),
                ),
              ),
            ),
          ),
        ),
        if (selDef != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(children: [
              Expanded(
                child: Text(
                  _moving
                      ? '${selDef.name}: sarı çizgili boş bir kareye dokun.'
                      : '${selDef.name} · Seviye ${built[sel] ?? 0}',
                  style: G.sub,
                ),
              ),
              SizedBox(
                width: 120,
                child: ChunkyButton(
                  key: const Key('town-move'),
                  label: _moving ? 'Vazgeç' : 'Taşı',
                  height: 44,
                  kind: BtnKind.secondary,
                  onPressed: () => setState(() => _moving = !_moving),
                ),
              ),
            ]),
          ),
      ],
    );
  }
}

Widget _art(String key) => SvgPicture.string(townArt[key]!, fit: BoxFit.fill);

Widget _at(Offset o, double w, double h, Widget child, {Key? key}) =>
    Positioned(
        key: key,
        left: o.dx,
        top: o.dy,
        width: w,
        height: h,
        child: IgnorePointer(child: child));

/// Ocaktan yükselen duman.
class _Smoke extends StatelessWidget {
  const _Smoke({required this.clock, required this.at});
  final AnimationController clock;
  final Offset at;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: clock,
        builder: (context, _) {
          final t = (clock.value * 20) % 1; // 2 saniyelik döngü
          return Positioned(
            left: at.dx + 3 * math.sin(t * 2 * math.pi),
            top: at.dy - 10 * t,
            width: 20,
            height: 30,
            child: IgnorePointer(
              child: Opacity(opacity: 1 - t, child: _art('smoke')),
            ),
          );
        },
      );
}

/// Yolun iki kolunda gidip gelen köylü.
class _Villager extends StatelessWidget {
  const _Villager(
      {required this.clock, required this.index, required this.motion});
  final AnimationController clock;
  final int index;
  final bool motion;

  /// Köylünün yürüdüğü yol: kollar sırayla (dikey, yatay).
  List<Spot> get _path => index.isEven
      ? [for (var i = 0; i < townSize; i++) Spot(2, i)]
      : [for (var i = 0; i < townSize; i++) Spot(i, 2)];

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: clock,
        builder: (context, _) {
          final path = _path;
          // 0..1 ileri, 1..2 geri; her köylü farklı hız ve başlangıçla
          final speed = 4 + index;
          final raw = motion ? (clock.value * speed + index * .37) % 2 : .4;
          final u = raw < 1 ? raw : 2 - raw;
          final pos = u * (path.length - 1);
          final i = pos.floor().clamp(0, path.length - 2);
          final f = pos - i;
          final a = _tileOrigin(path[i]), b = _tileOrigin(path[i + 1]);
          final p = Offset.lerp(a, b, f)!;
          final step = motion && ((pos * 4).floor().isEven);
          return Positioned(
            left: p.dx + _hw - 9,
            top: p.dy + _hh - 26,
            width: 18,
            height: 27,
            child: IgnorePointer(
              child: Transform.flip(
                flipX: raw >= 1,
                child: _art('villager_${index % 4}_${step ? 1 : 0}'),
              ),
            ),
          );
        },
      );
}
