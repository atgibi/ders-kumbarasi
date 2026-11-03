/// Diyar haritası: krallık seçici, kaynak şeridi, bölge bölge sisli yol.
library;

import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../core/srs/leitner.dart';
import '../../data/models.dart';
import '../../game/world.dart';
import '../theme.dart';
import '../widgets/dk_icon.dart';
import '../widgets/emoji_text.dart';
import '../widgets/kit.dart';
import '../widgets/mascot.dart';
import 'game_theme.dart';
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
    final ready =
        r.outcomes.where((o) => pack[o.code]?.cards.isNotEmpty ?? false).toList();
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
      .where((r) => r.state == RegionState.waking || r.state == RegionState.next)
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
  const KingdomMapTab({super.key});

  @override
  State<KingdomMapTab> createState() => _KingdomMapTabState();
}

class _KingdomMapTabState extends State<KingdomMapTab> {
  Future<List<RegionView>>? _future;
  String _key = '';

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
          return ListView(
            key: const Key('map-list'),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const _KingdomPicker(),
              const SupplyStrip(),
              if (regions != null) ...[
                _KingdomHeader(kingdom: k, line: ankaLine(k, regions)),
                for (var i = 0; i < regions.length; i++)
                  _RegionNode(
                    key: Key('region-$i'),
                    view: regions[i],
                    kingdom: k,
                    dx: const <double>[0, 70, 0, -70][i % 4],
                    last: i == regions.length - 1,
                  ),
              ],
            ],
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
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: sel ? k.color : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: sel ? G.ink : G.paper2, width: 2),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      EmojiImage(k.emoji, size: 22),
                      const SizedBox(width: 6),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(k.name,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: sel ? Colors.white : G.ink)),
                          Text(s.label,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: sel ? Colors.white : G.inkSoft)),
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

/// Işık ve malzemeler.
class SupplyStrip extends StatelessWidget {
  const SupplyStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final g = app.progress!.game;
    final items = [
      ('ışık', null, app.light),
      for (final m in Supply.values)
        if (g.supply(m) > 0 || m == Kingdom.of(app.subject!).material)
          (m.label.toLowerCase(), m.emoji, g.supply(m)),
      ('sancak', bannerEmoji, g.banners.length),
    ];
    return Semantics(
      container: true,
      label: [for (final i in items) '${i.$3} ${i.$1}'].join(', '),
      child: ExcludeSemantics(
        child: Container(
          key: const Key('supply-strip'),
          margin: const EdgeInsets.fromLTRB(12, 2, 12, 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: G.paper2,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Wrap(spacing: 14, runSpacing: 4, children: [
            for (final i in items)
              Row(mainAxisSize: MainAxisSize.min, children: [
                if (i.$2 == null)
                  const DkIcon(DkIcons.nut, size: 20)
                else
                  EmojiImage(i.$2!, size: 20),
                const SizedBox(width: 4),
                Text('${i.$3}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w900, color: G.ink)),
              ]),
          ]),
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
          Text(kingdom.name.toUpperCase(),
              style: G.kicker.copyWith(color: kingdom.ink)),
          Text('${kingdom.people} · ${kingdom.value}', style: G.soft),
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
              ListenButton(size: 52, iconSize: 24, onListen: () => app.say(line)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RegionNode extends StatelessWidget {
  const _RegionNode({
    super.key,
    required this.view,
    required this.kingdom,
    required this.dx,
    required this.last,
  });
  final RegionView view;
  final Kingdom kingdom;
  final double dx;
  final bool last;

  String get _status => switch (view.state) {
        RegionState.fog => 'Sisli',
        RegionState.next => 'Keşfe hazır',
        RegionState.waking => 'Canlanıyor · ${view.started}/${view.total}',
        RegionState.guardian => 'Bekçi seni bekliyor',
        RegionState.freed => 'Kurtarıldı',
        RegionState.glowing => 'Işıl ışıl',
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
    final colored = st == RegionState.freed ||
        st == RegionState.glowing ||
        st == RegionState.waking ||
        st == RegionState.guardian;
    final fogged = st == RegionState.fog || st == RegionState.locked;
    final title = regionTitle(kingdom, view.def.index);
    final emoji = switch (st) {
      RegionState.freed || RegionState.glowing => bannerEmoji,
      RegionState.guardian => view.def.guardian.emoji,
      RegionState.locked => '🚪',
      _ => kingdom.emoji,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(children: [
        Transform.translate(
          offset: Offset(dx, 0),
          child: Pressable(
            label: '$title, ${view.unitName}. $_status',
            onTap: () => _open(context),
            builder: (context, down) => Column(children: [
              Container(
                width: 104,
                height: 104,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colored
                      ? kingdom.color
                      : st == RegionState.next
                          ? Colors.white
                          : G.fogLight,
                  border: Border.all(
                      color: st == RegionState.glowing ? G.gold : G.ink,
                      width: st == RegionState.glowing ? 6 : 3),
                  boxShadow: [
                    if (st == RegionState.next || st == RegionState.guardian)
                      const BoxShadow(color: G.saffron, blurRadius: 18, spreadRadius: 4),
                    if (st == RegionState.glowing)
                      const BoxShadow(color: G.gold, blurRadius: 22, spreadRadius: 6),
                  ],
                ),
                child: Stack(alignment: Alignment.center, children: [
                  Opacity(
                      opacity: fogged ? 0.45 : 1,
                      child: EmojiImage(emoji, size: 52)),
                  if (fogged)
                    const Positioned(
                        bottom: 10, child: EmojiImage('☁️', size: 40)),
                  if (view.due && !fogged)
                    const Positioned(
                        top: 4, right: 4, child: EmojiImage('🌫️', size: 26)),
                ]),
              ),
              const SizedBox(height: 6),
              Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: fogged ? G.inkSoft : G.ink)),
              if (view.unitName.isNotEmpty)
                SizedBox(
                  width: 220,
                  child: Text(view.unitName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: G.soft),
                ),
              Text(_status,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: st == RegionState.guardian ? G.madder : G.indigo)),
            ]),
          ),
        ),
        if (!last)
          SizedBox(
            height: 34,
            child: CustomPaint(
              size: const Size(200, 34),
              painter: _TrailPainter(dx, const <double>[0, 70, 0, -70]
                  [(view.def.index + 1) % 4]),
            ),
          ),
      ]),
    );
  }
}

/// Bölgeler arası kesik çizgili yol.
class _TrailPainter extends CustomPainter {
  _TrailPainter(this.from, this.to);
  final double from, to;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = G.inkSoft
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final a = Offset(size.width / 2 + from, 0);
    final b = Offset(size.width / 2 + to, size.height);
    const n = 6;
    for (var i = 0; i < n; i += 2) {
      canvas.drawLine(Offset.lerp(a, b, i / n)!, Offset.lerp(a, b, (i + 1) / n)!, p);
    }
  }

  @override
  bool shouldRepaint(_TrailPainter old) => old.from != from || old.to != to;
}
