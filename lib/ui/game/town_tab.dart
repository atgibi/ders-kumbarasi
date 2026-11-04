/// Kasaba: kahraman, kurtarılan bekçiler, yapılar ve Kahraman Defteri.
library;

import 'package:flutter/material.dart';

import '../../game/game_state.dart';
import '../../game/world.dart';
import '../theme.dart';
import '../widgets/dk_icon.dart';
import '../widgets/emoji_text.dart';
import '../widgets/kit.dart';
import 'board_widgets.dart';
import 'duel_widgets.dart';
import 'game_theme.dart';
import 'hero_figure.dart';
import 'kingdom_map.dart';

class TownTab extends StatefulWidget {
  const TownTab({super.key});

  @override
  State<TownTab> createState() => _TownTabState();
}

class _TownTabState extends State<TownTab> {
  Future<HeroStage>? _stage;
  String _key = '';

  Future<void> _build(BuildContext context, BuildingDef b) async {
    final app = AppScope.read(context);
    final level = app.game.levelOf(b) + 1;
    if (!await app.build(b)) return;
    if (!context.mounted) return;
    final text = level == 1
        ? '${b.name} yükseldi! ${b.note}'
        : '${b.name} $level. seviyeye çıktı!';
    app.say(text);
    showDkToast(context, DkIcons.star, text);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final p = app.progress!;
    final g = p.game;
    final key =
        '${p.startedOutcomes.length}|${g.banners.length}|${p.cards.length}';
    if (_stage == null || key != _key) {
      _key = key;
      _stage = app.heroStage();
    }
    final hero = g.hero;
    final rescued = [for (final k in g.rescued) guardianForKey(k)];
    return ColoredBox(
      color: G.paper,
      child: ListView(
        key: const Key('town-list'),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        children: [
          const SupplyStrip(),
          if (hero != null)
            FutureBuilder<HeroStage>(
              future: _stage,
              builder: (context, snap) {
                final st = snap.data ?? HeroStage.cirak;
                return Parchment(
                  color: Colors.white,
                  child: Row(children: [
                    HeroFigure(look: hero, stage: st, size: 96),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(hero.name ?? app.active!.nickname,
                              style: G.title),
                          Text('${hero.heroPath.name} · ${st.label}',
                              style:
                                  G.sub.copyWith(color: hero.heroPath.color)),
                          const SizedBox(height: 4),
                          Text(nextStageHint(st), style: G.soft),
                        ],
                      ),
                    ),
                  ]),
                );
              },
            ),
          const SizedBox(height: 16),
          const QuestBoard(),
          const SizedBox(height: 8),
          const WeeklyTripCard(),
          const SizedBox(height: 20),
          const Row(children: [
            Expanded(child: Text('KASABAN', style: G.kicker)),
            MailboxButton(),
          ]),
          const SizedBox(height: 8),
          if (rescued.isNotEmpty) ...[
            const Text('Kurtardığın bekçiler kasabanda yaşıyor:',
                style: G.soft),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final r in rescued)
                Tooltip(message: r.name, child: GuardianFigure(guardian: r, size: 64)),
            ]),
            const SizedBox(height: 14),
          ],
          for (final b in buildings) ...[
            _BuildingRow(
              key: Key('building-${b.id}'),
              def: b,
              level: g.levelOf(b),
              canBuild: app.canBuild(b),
              light: app.light,
              game: g,
              onBuild: () => _build(context, b),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 6),
          const Text(
              'Yapılar ışık ve krallık malzemesiyle hemen yükselir. Malzemeyi ders çalışarak kazanırsın; satın alınmaz.',
              style: G.soft),
        ],
      ),
    );
  }
}

class _BuildingRow extends StatelessWidget {
  const _BuildingRow({
    super.key,
    required this.def,
    required this.level,
    required this.canBuild,
    required this.light,
    required this.game,
    required this.onBuild,
  });
  final BuildingDef def;
  final int level;
  final bool canBuild;
  final int light;
  final GameState game;
  final VoidCallback onBuild;

  @override
  Widget build(BuildContext context) {
    final maxed = level >= BuildingDef.maxLevel;
    final next = level + 1;
    final cost = maxed
        ? ''
        : [
            '${def.lightCost(next)} ışık',
            for (final e in def.materialCost(next).entries)
              '${e.value} ${e.key.label.toLowerCase()}',
          ].join(' · ');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: level > 0 ? Colors.white : G.paper,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: level > 0 ? G.ink : G.paper2, width: 2),
      ),
      child: Row(children: [
        Opacity(
            opacity: level > 0 ? 1 : 0.5,
            child: EmojiImage(def.emoji, size: 44)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(level > 0 ? '${def.name} · Seviye $level' : def.name,
                  style: G.sub),
              Text(maxed ? 'En yüksek seviyede!' : cost, style: G.soft),
            ],
          ),
        ),
        if (!maxed)
          SizedBox(
            width: 136,
            child: ChunkyButton(
              key: Key('build-${def.id}'),
              label: level == 0 ? 'Kur' : 'Yükselt',
              height: 48,
              kind: canBuild ? BtnKind.good : BtnKind.secondary,
              semanticsLabel:
                  '${def.name}: ${level == 0 ? 'kur' : 'yükselt'}, $cost',
              onPressed: canBuild ? onBuild : null,
            ),
          ),
      ]),
    );
  }
}

/// Kahraman Defteri: her oturumun bir sayfası; yıl sonunda çocuğun masalı.
class NotebookScreen extends StatelessWidget {
  const NotebookScreen({super.key, this.asTab = false});

  /// Alt sekmede: geri düğmesi ve iskele yok.
  final bool asTab;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final pages = app.game.notebook.reversed.toList();
    final hero = app.game.hero;
    // Claude Design 23: defter; kırmızı cilt kenarı, çizgili sayfa, el yazısı
    final list = pages.isEmpty
        ? ListView(padding: const EdgeInsets.all(24), children: [
            if (hero != null)
              Center(child: HeroFigure(look: hero, size: 140)),
            const SizedBox(height: 12),
            Text('Defterin henüz boş. İlk maceran bittiğinde buraya yazılacak.',
                textAlign: TextAlign.center,
                style: G.hand.copyWith(fontSize: 18)),
          ])
        : ListView.separated(
            key: const Key('notebook-list'),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            itemCount: pages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final pg = pages[i];
              return Pressable(
                label: pg.text,
                onTap: () => app.say(pg.text),
                builder: (context, down) => Container(
                  decoration: BoxDecoration(
                    color: down ? K.kagit2 : K.kagit3,
                    border: Border.all(color: K.murekkep, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Color(0x402B2320), offset: Offset(3, 4))
                    ],
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(width: 10, color: K.kok),
                          Container(width: 2, color: K.murekkep),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_date(pg.day),
                                      style: const TextStyle(
                                          fontFamily: K.display,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: K.kokKoyu)),
                                  const SizedBox(height: 2),
                                  Text(pg.text,
                                      style: G.hand.copyWith(
                                          fontSize: 18,
                                          height: 1.45,
                                          color: K.murekkep)),
                                ],
                              ),
                            ),
                          ),
                        ]),
                  ),
                ),
              );
            },
          );
    if (asTab) return ColoredBox(color: G.paper, child: list);
    return Scaffold(
      backgroundColor: G.paper,
      body: SafeArea(
        child: ChildTextScale(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 4),
              child: Row(children: [
                CircleBtn(
                  key: const Key('notebook-back'),
                  icon: DkIcons.left,
                  label: 'Geri',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 10),
                const Expanded(child: Text('Kahraman Defteri', style: G.title)),
              ]),
            ),
            Expanded(child: list),
          ]),
        ),
      ),
    );
  }

  static String _date(String day) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    final p = day.split('-');
    if (p.length != 3) return day;
    final m = int.tryParse(p[1]) ?? 1;
    return '${int.tryParse(p[2]) ?? p[2]} ${months[(m - 1).clamp(0, 11)]}';
  }
}
