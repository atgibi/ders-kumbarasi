/// Diyar haritası: krallık seçici, kaynak şeridi, bölge bölge sisli yol.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/app_state.dart';
import '../../core/srs/leitner.dart';
import '../../data/models.dart';
import '../../game/turkish.dart';
import '../../game/world.dart';
import '../theme.dart';
import '../widgets/dk_icon.dart';
import '../widgets/emoji_text.dart';
import '../widgets/hand.dart';
import '../widgets/ikon.dart';
import '../widgets/kit.dart';
import '../widgets/mascot.dart';
import 'duel_widgets.dart';
import 'game_theme.dart';
import 'hero_figure.dart';
import 'region_screen.dart';

enum RegionState {
  /// Sisli: henüz sırası gelmedi.
  fog,

  /// Sıradaki bölge: parlıyor, keşfe hazır.
  next,

  /// Canlanıyor: konulara başlandı.
  waking,

  /// Tüm konulara başlandı: bekçi düelloya hazır.
  guardian,

  /// Kurtarıldı: sancak dikildi.
  freed,

  /// Tüm konular "yeterli": altın ışık.
  glowing,

  /// Abonelikle açılan bölge.
  locked,

  /// İçeriği hazırlanıyor.
  soon,
}

class RegionView {
  const RegionView({
    required this.def,
    required this.unitName,
    required this.state,
    required this.started,
    required this.total,
    required this.mastered,
    required this.due,
  });
  final RegionDef def;
  final String unitName;
  final RegionState state;
  final int started;
  final int total;
  final int mastered;
  final bool due;
}

Future<List<RegionView>> buildRegionViews(AppState app, Subject s) async {
  final child = app.active!;
  final p = app.progress!;
  final pack = await app.content.contentFor(s, child.grade);
  final now = app.clock();
  final out = <RegionView>[];
  var nextGiven = false;
  for (final r in await app.regions(s)) {
    final ready = r.outcomes
        .where((o) => pack[o.code]?.cards.isNotEmpty ?? false)
        .toList();
    var started = 0, mastered = 0;
    var due = false;
    for (final o in ready) {
      if (!p.startedOutcomes.contains(o.code)) continue;
      started++;
      final states = [
        for (final c in pack[o.code]!.cards)
          p.cards[c.id] ?? CardState.fresh(c.id, now)
      ];
      if (outcomeMastery(states) == MasteryLevel.sufficient) mastered++;
      if (states.any((c) => !c.isNew && c.isDue(now))) due = true;
    }
    final RegionState st;
    if (ready.isEmpty) {
      st = RegionState.soon;
    } else if (app.regionLocked(r)) {
      st = RegionState.locked;
    } else if (p.game.banners.contains(r.key)) {
      st = mastered == ready.length ? RegionState.glowing : RegionState.freed;
    } else if (started == ready.length) {
      st = RegionState.guardian;
      nextGiven = true;
    } else if (started > 0) {
      st = RegionState.waking;
      nextGiven = true;
    } else if (!nextGiven) {
      st = RegionState.next;
      nextGiven = true;
    } else {
      st = RegionState.fog;
    }
    final unit = r.outcomes.first.unit;
    out.add(RegionView(
      def: r,
      unitName: unit != null
          ? await app.content.unitName(s, child.grade, unit) ?? ''
          : r.outcomes.first.area ?? '',
      state: st,
      started: started,
      total: ready.length,
      mastered: mastered,
      due: due,
    ));
  }
  return out;
}

/// Anka'nın bugünkü cümlesi.
String ankaLine(Kingdom k, List<RegionView> regions) {
  final g = regions.where((r) => r.state == RegionState.guardian).firstOrNull;
  if (g != null) {
    return '${g.def.guardian.name} ${regionTitle(k, g.def.index)} geçidini kapatıyor. Düelloya hazırsın!';
  }
  final w = regions
      .where(
          (r) => r.state == RegionState.waking || r.state == RegionState.next)
      .firstOrNull;
  if (w != null) {
    return '${regionTitle(k, w.def.index)} sisin altında. ${k.leader} yardımını bekliyor!';
  }
  if (regions.any((r) => r.due)) {
    return 'Kurtardığın yerlerde ince bir sis var. Tekrar et, ışığı koru.';
  }
  if (regions.any((r) => r.state == RegionState.locked)) {
    return 'Açık yolların hepsini kurtardın! Kalan yollar henüz açılmadı.';
  }
  return 'Bu krallığın bütün bölgeleri ışıl ışıl!';
}

class KingdomMapTab extends StatefulWidget {
  const KingdomMapTab({super.key, this.header});

  /// Krallık seçicinin altına gelen ek (Gök Adaları girişi).
  final Widget? header;

  @override
  State<KingdomMapTab> createState() => _KingdomMapTabState();
}

class _KingdomMapTabState extends State<KingdomMapTab> {
  Future<List<RegionView>>? _future;
  String _key = '';

  /// Bugünkü bölge: harita açılınca ona kaydırılır (yol aşağıdan tırmanır).
  final _currentKey = GlobalKey();
  String _scrolledFor = '';

  void _scrollToCurrent(String subjectKey) {
    if (_scrolledFor == subjectKey) return;
    _scrolledFor = subjectKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = _currentKey.currentContext;
      if (c != null && c.mounted) {
        Scrollable.ensureVisible(c, alignment: .6);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final p = app.progress!;
    final subject = app.subject!;
    final key = '${app.active?.id}|$subject|${p.startedOutcomes.length}|'
        '${p.cards.length}|${p.game.banners.length}|${p.lastSessionDay}|'
        '${app.settings.premium}|${p.nuts}';
    if (_future == null || key != _key) {
      _key = key;
      _future = buildRegionViews(app, subject);
    }
    final k = Kingdom.of(subject);
    return ColoredBox(
      color: G.paper,
      child: FutureBuilder<List<RegionView>>(
        future: _future,
        builder: (context, snap) {
          final regions = snap.data;
          if (regions != null) _scrollToCurrent('${app.active?.id}|$subject');
          // tek sütun: başlık ve tuval hep kurulu (bugünkü bölgeye kaydırılır)
          return SingleChildScrollView(
            key: const Key('map-list'),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _KingdomPicker(),
                const SupplyStrip(),
                if (regions != null) ...[
                  _KingdomHeader(kingdom: k, line: ankaLine(k, regions)),
                  _MapCanvas(
                      regions: regions, kingdom: k, currentKey: _currentKey),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _KingdomPicker extends StatelessWidget {
  const _KingdomPicker();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final subjects = Subject.forGrade(app.active!.grade);
    return SizedBox(
      height: 64,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
        children: [
          for (final s in subjects)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Pressable(
                key: Key('kingdom-${s.id}'),
                label: '${Kingdom.of(s).name}, ${s.label}',
                selected: s == app.subject,
                onTap: () => app.selectSubject(s),
                builder: (context, down) {
                  final k = Kingdom.of(s);
                  final sel = s == app.subject;
                  return HandBox(
                    style: HandStyle.parsomen.copyWith(
                        fill: sel ? k.color : (down ? K.kagit2 : K.kagit3),
                        shadows: sel ? const [(3, K.murekkep)] : null),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      EmojiImage(k.emoji, size: 22),
                      const SizedBox(width: 6),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(k.name,
                              style: TextStyle(
                                  fontFamily: K.display,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: sel ? K.kagit3 : G.ink)),
                          Text(s.label,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: sel ? K.kagit3 : G.inkSoft)),
                        ],
                      ),
                    ]),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class SupplyStrip extends StatelessWidget {
  const SupplyStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final g = app.progress!.game;
    final items = <(String, Ikon, int)>[
      ('ışık', Ikon.isik, app.light),
      for (final m in Supply.values)
        if (g.supply(m) > 0 || m == Kingdom.of(app.subject!).material)
          (m.label.toLowerCase(), ikonOf(m), g.supply(m)),
      ('sancak', Ikon.sancak, g.banners.length),
    ];
    // Claude Design › Kaynak şeridi: kâğıt üstünde el çizimi simgeler.
    return Semantics(
      container: true,
      label: [for (final i in items) '${i.$3} ${i.$1}'].join(', '),
      child: ExcludeSemantics(
        child: Padding(
          key: const Key('supply-strip'),
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
          child: HandBox(
            style: HandStyle.el.copyWith(fill: K.kagit3),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 10,
              runSpacing: 4,
              children: [
                for (final i in items)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    IkonView(i.$2, size: i.$2 == Ikon.isik ? 24 : 22),
                    const SizedBox(width: 3),
                    Text('${i.$3}',
                        style: TextStyle(
                            fontFamily: K.display,
                            fontSize: i.$2 == Ikon.isik ? 18 : 17,
                            fontWeight: i.$2 == Ikon.isik
                                ? FontWeight.w800
                                : FontWeight.w700,
                            color: G.ink)),
                  ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KingdomHeader extends StatelessWidget {
  const _KingdomHeader({required this.kingdom, required this.line});
  final Kingdom kingdom;
  final String line;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.read(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(trUpper(kingdom.name),
              style: TextStyle(
                  fontFamily: K.display,
                  fontSize: 34,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .7,
                  color: kingdom.ink,
                  shadows: const [
                    Shadow(color: K.murekkep, offset: Offset(2, 2))
                  ])),
          const SizedBox(height: 2),
          Text(
              '${kingdom.subject.label} · ${genitive(kingdom.leader)} krallığı',
              style: const TextStyle(fontSize: 14, color: K.murekkep2)),
          const SizedBox(height: 8),
          const Kilim(height: 12),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Mascot(size: 60),
              const SizedBox(width: 6),
              Expanded(
                child: SpeechBubble(
                  tailLeft: 16,
                  child: Text(line, key: const Key('anka-line'), style: G.body),
                ),
              ),
              const SizedBox(width: 4),
              ListenButton(
                  size: 52, iconSize: 24, onListen: () => app.say(line)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Krallık haritası (Claude Design 10): aşağıdan yukarı tırmanan yol,
/// zikzak bölge düğümleri, sis ve kahraman.
class _MapCanvas extends StatelessWidget {
  const _MapCanvas(
      {required this.regions, required this.kingdom, required this.currentKey});
  final List<RegionView> regions;
  final Kingdom kingdom;
  final GlobalKey currentKey;

  static const step = 92.0;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final hero = app.progress?.game.hero;
    final n = regions.length;
    final h = n * step + 70;
    final current = regions.indexWhere((r) =>
        r.state == RegionState.waking ||
        r.state == RegionState.guardian ||
        r.state == RegionState.next);
    final firstFog = regions.indexWhere(
        (r) => r.state == RegionState.fog || r.state == RegionState.soon);
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth;
      // düğüm merkezleri: alttan üste, sol-sağ
      Offset at(int i) =>
          Offset(i.isEven ? w * .36 : w * .64, h - 52 - i * step);
      return SizedBox(
        height: h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _MapPainter(
                  points: [for (var i = 0; i < n; i++) at(i)],
                  kingdom: kingdom,
                  fogFrom: firstFog < 0 ? null : at(firstFog).dy + 46,
                ),
              ),
            ),
            if (n > 0)
              Positioned(
                left: 0,
                top: at(current >= 0 ? current : 0).dy - 60,
                child: SizedBox(key: currentKey, width: 1, height: 120),
              ),
            for (var i = 0; i < n; i++) ...[
              Positioned(
                left: at(i).dx - 46,
                top: at(i).dy - 51,
                child: _RegionNode(
                    key: Key('region-$i'),
                    view: regions[i],
                    kingdom: kingdom,
                    no: i + 1),
              ),
              Positioned(
                left: i.isEven ? 6 : at(i).dx + 50,
                width: i.isEven ? at(i).dx - 56 : w - at(i).dx - 56,
                top: at(i).dy - 30,
                child: IgnorePointer(
                  child: ExcludeSemantics(
                    child: _NodeLabel(
                        view: regions[i], kingdom: kingdom, right: i.isEven),
                  ),
                ),
              ),
            ],
            if (hero != null && current >= 0)
              Positioned(
                left: at(current).dx + (current.isEven ? 40 : -92),
                top: at(current).dy - 74,
                child: IgnorePointer(
                  child: HeroFigure(look: hero, size: 52, showCompanion: false),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter(
      {required this.points, required this.kingdom, required this.fogFrom});
  final List<Offset> points;
  final Kingdom kingdom;

  /// Bu yükseklikten yukarısı sisli.
  final double? fogFrom;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // krallık rengiyle yan dağlar
    final dag = Paint()..color = kingdom.color.withValues(alpha: .55);
    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round
      ..color = K.murekkep;
    for (var y = 120.0; y < h; y += 220) {
      for (final (x0, s) in [(-20.0, 1.0), (w - 70, -1.0)]) {
        final m = Path()
          ..moveTo(x0, y + 120)
          ..lineTo(x0 + 50 + 10 * s, y)
          ..lineTo(x0 + 100, y + 120)
          ..close();
        canvas.drawPath(m, dag);
        canvas.drawPath(m, ink);
      }
    }
    if (points.isEmpty) return;
    // yol: aşağıdan ilk düğüme, sonra zikzak
    final p = Path()..moveTo(w / 2, h);
    var prev = Offset(w / 2, h);
    for (final q in points) {
      final my = (prev.dy + q.dy) / 2;
      p.cubicTo(prev.dx, my, q.dx, my, q.dx, q.dy);
      prev = q;
    }
    canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 19
          ..strokeCap = StrokeCap.round
          ..color = K.murekkep);
    canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 13
          ..strokeCap = StrokeCap.round
          ..color = K.kagit);
    final dash = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = kingdom.ink;
    for (final m in p.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 15) {
        canvas.drawPath(m.extractPath(d, math.min(d + 7, m.length)), dash);
      }
    }
    // sis
    final f = fogFrom;
    if (f != null) {
      final edge = Path()..moveTo(-10, f);
      for (var x = -10.0; x < w + 30; x += 40) {
        edge.quadraticBezierTo(
            x + 20, f + 14, x + 40, f + ((x ~/ 40).isEven ? -6 : 8));
      }
      edge
        ..lineTo(w + 10, -10)
        ..lineTo(-10, -10)
        ..close();
      canvas.drawPath(edge, Paint()..color = const Color(0xD9C9D1D9));
      canvas.save();
      canvas.clipPath(edge);
      final tul = Paint()
        ..color = const Color(0x999AA6B2)
        ..strokeWidth = .9;
      for (var t = -h; t < w + h; t += 9) {
        canvas.drawLine(
            Offset(t, f + 20), Offset(t + (f + 30) * .53, -10), tul);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.points != points || old.kingdom != kingdom || old.fogFrom != fogFrom;
}

class _NodeLabel extends StatelessWidget {
  const _NodeLabel(
      {required this.view, required this.kingdom, required this.right});
  final RegionView view;
  final Kingdom kingdom;
  final bool right;

  @override
  Widget build(BuildContext context) {
    final fog = view.state == RegionState.fog ||
        view.state == RegionState.soon ||
        view.state == RegionState.locked;
    final color = fog ? const Color(0xFF3D4650) : G.ink;
    return Column(
      crossAxisAlignment:
          right ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(regionTitle(kingdom, view.def.index),
            textAlign: right ? TextAlign.right : TextAlign.left,
            style: TextStyle(
                fontFamily: K.display,
                fontSize: 15,
                height: 1.1,
                fontWeight: FontWeight.w800,
                color: color)),
        if (view.unitName.isNotEmpty)
          Text(view.unitName,
              textAlign: right ? TextAlign.right : TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.5, height: 1.2, color: color)),
        if (view.state == RegionState.guardian) ...[
          const SizedBox(height: 4),
          HandBox(
            style: HandStyle.parsomen
                .copyWith(fill: K.kokKoyu, shadows: const [(3, K.murekkep)]),
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 5),
            child: const Text('Düelloya hazırsın!',
                style: TextStyle(
                    fontFamily: K.display,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: K.kagit3)),
          ),
        ],
      ],
    );
  }
}

/// Bölge düğümü (Claude Design › Bölge düğümü): beş hâl.
String regionNodeSvg(RegionState st, Color kingdomColor) {
  String hx(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  final renk = hx(kingdomColor);
  final hal = switch (st) {
    RegionState.glowing => 'parliyor',
    RegionState.freed => 'kurtarildi',
    RegionState.waking || RegionState.guardian => 'canlaniyor',
    RegionState.next || RegionState.locked => 'kesfedildi',
    RegionState.fog || RegionState.soon => 'sisli',
  };
  final zemin = const {
        'parliyor': '#E3A535',
        'kesfedildi': '#EADBC0',
        'sisli': '#9AA6B2',
      }[hal] ??
      renk;
  final halka = const {
        'kurtarildi': '#2F7A5B',
        'parliyor': '#FBF5E8',
        'canlaniyor': '#E3A535',
        'sisli': '#C9D1D9',
      }[hal] ??
      renk;
  final b = StringBuffer(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120">'
      '<ellipse cx="60" cy="98" rx="30" ry="5" fill="#2B2320" opacity="0.14"/>');
  if (hal == 'parliyor') {
    b.write('<path d="');
    for (var i = 0; i < 18; i++) {
      final a = i / 18 * math.pi * 2;
      final r2 = i.isOdd ? 41 : 50;
      b.write(
          'M${(60 + math.cos(a) * 33).toStringAsFixed(1)} ${(66 + math.sin(a) * 33).toStringAsFixed(1)}'
          'L${(60 + math.cos(a) * r2).toStringAsFixed(1)} ${(66 + math.sin(a) * r2).toStringAsFixed(1)}');
    }
    b.write('" stroke="#E3A535" stroke-width="3" stroke-linecap="round"/>');
  }
  if (hal == 'sisli') {
    b.write(
        '<path d="M18 74C8 60 20 42 34 46C38 30 60 26 70 38C84 30 102 40 98 56C112 62 108 84 94 86C86 98 64 98 56 92C42 98 22 90 18 74Z" fill="#C9D1D9" fill-opacity="0.85"/>');
  }
  b.write(
      '<g stroke="#2B2320" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round">'
      '<circle cx="60" cy="66" r="27" fill="$zemin"/>');
  if (hal == 'canlaniyor') {
    b.write('<path d="M60 39A27 27 0 0 1 60 93Z" fill="#C9D1D9" stroke="none"/>'
        '<path d="M60 39V93" stroke-width="1.4" stroke-dasharray="3 3"/>');
  }
  if (hal == 'kesfedildi') {
    b.write(
        '<path d="M70 42C86 46 92 60 86 76C96 70 100 52 90 42C84 36 76 38 70 42Z" fill="#C9D1D9" stroke="#9AA6B2" stroke-width="1.6"/>');
  }
  b.write(
      '<circle cx="60" cy="66" r="21" fill="none" stroke="$halka" stroke-width="3"/>'
      '<circle cx="60" cy="66" r="27" fill="none"/>');
  if (hal == 'kurtarildi') {
    b.write('<path d="M80 50V12" stroke="#5E3A1B" stroke-width="3.4"/>'
        '<path d="M82 13H104L98 21L104 29H82Z" fill="#B8432F"/><circle cx="80" cy="10" r="2.6" fill="#E3A535"/>');
  }
  if (hal == 'parliyor') {
    b.write(
        '<path d="M46 38V30H52V34H57V30H63V34H68V30H74V38Z" fill="#EADBC0"/><path d="M54 38v-3h4v3" fill="none" stroke-width="1.4"/>');
  }
  if (hal == 'canlaniyor') {
    b.write(
        '<circle cx="26" cy="54" r="5" fill="#E3A535"/><circle cx="30" cy="84" r="5" fill="#E3A535"/>'
        '<circle cx="94" cy="52" r="5" fill="#C9D1D9"/><circle cx="92" cy="84" r="5" fill="#C9D1D9"/>');
  }
  if (st == RegionState.locked) {
    b.write(
        '<g transform="translate(78 74)"><path d="M2 24V10A9 9 0 0 1 20 10V24Z" fill="#8A5A2E"/>'
        '<path d="M8 4V24M14 4V24M2 13H20" fill="none" stroke-width="1.4"/><circle cx="16" cy="17" r="1.4" fill="#2B2320"/>'
        '<path d="M-1 24H23" stroke-width="2.4"/></g>');
  }
  b.write('</g></svg>');
  return b.toString();
}

class _RegionNode extends StatelessWidget {
  const _RegionNode({
    super.key,
    required this.view,
    required this.kingdom,
    required this.no,
  });
  final RegionView view;
  final Kingdom kingdom;
  final int no;

  String get _status => switch (view.state) {
        RegionState.fog => 'Sisli',
        RegionState.next => 'Keşfe hazır',
        RegionState.waking => 'Canlanıyor · ${view.started}/${view.total}',
        RegionState.guardian => 'Bekçi seni bekliyor',
        RegionState.freed => 'Kurtarıldı',
        RegionState.glowing => 'Parlıyor',
        RegionState.locked => 'Bu yol henüz açılmadı',
        RegionState.soon => 'Hazırlanıyor',
      };

  Future<void> _open(BuildContext context) async {
    final app = AppScope.read(context);
    switch (view.state) {
      case RegionState.locked:
        app.say('Bu yol henüz açılmadı. Bir büyüğüne sorabilirsin.');
        showDkToast(context, DkIcons.lock,
            'Bu yol henüz açılmadı. Bir büyüğüne sorabilirsin.');
        return;
      case RegionState.fog:
        showDkToast(context, DkIcons.lock,
            'Sis burada çok yoğun. Önce parlayan bölgeyi kurtaralım.');
        return;
      case RegionState.soon:
        showDkToast(context, DkIcons.hourglass, 'Bu bölge hazırlanıyor.');
        return;
      default:
        hideDkToast();
        await Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => RegionScreen(region: view.def)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = view.state;
    final title = regionTitle(kingdom, view.def.index);
    final light = st == RegionState.freed;
    return Pressable(
      label: 'Bölge $no, $title, ${view.unitName}. $_status',
      onTap: () => _open(context),
      focusRadius: 46,
      builder: (context, down) => Transform.scale(
        scale: down ? .95 : 1,
        child: SizedBox(
          width: 92,
          height: 92,
          child: Stack(alignment: Alignment.center, children: [
            SvgPicture.string(regionNodeSvg(st, kingdom.color),
                width: 92, height: 92),
            Positioned(
              top: 34,
              child: Text('$no',
                  style: TextStyle(
                      fontFamily: K.display,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: light ? K.kagit3 : K.murekkep)),
            ),
            if (st == RegionState.guardian)
              Positioned(
                  left: 0,
                  top: 6,
                  child: GuardianFigure(
                      guardian: view.def.guardian, size: 38, armored: true)),
            if (view.due && st != RegionState.fog && st != RegionState.locked)
              const Positioned(
                  right: 0, bottom: 4, child: IkonView(Ikon.mesale, size: 26)),
          ]),
        ),
      ),
    );
  }
}
