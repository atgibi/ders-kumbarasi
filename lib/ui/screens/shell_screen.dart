import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../core/srs/leitner.dart';
import '../../data/models.dart';
import '../theme.dart';
import '../widgets/avatar.dart';
import '../widgets/dk_icon.dart';
import '../widgets/emoji_text.dart';
import '../widgets/kit.dart';
import '../widgets/mascot.dart';
import 'parent_gate.dart';
import 'parent_screen.dart';
import 'path_screen.dart';
import 'system_screens.dart';

/// Çocuğun ana kabuğu: Yol, Tekrar, Profil sekmeleri.
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _tab = 0;
  Future<int>? _dueFuture;
  String _dueKey = '';

  Future<int> _totalDue() async {
    final list = await AppScope.read(context).dueBySubject();
    return list.fold<int>(0, (s, e) => s + e.$2);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final p = app.progress!;
    final key = '${app.active?.id}|${p.cards.length}|${p.lastSessionDay}|'
        '${p.nuts}|${app.clock().hour}';
    if (_dueFuture == null || key != _dueKey) {
      _dueKey = key;
      _dueFuture = _totalDue();
    }
    return PopScope(
      // Android geri tuşu: önce Yol sekmesine döner
      canPop: _tab == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _tab != 0) setState(() => _tab = 0);
      },
      child: Scaffold(
        backgroundColor: K.bg,
        body: SafeArea(
          bottom: false,
          child: ChildTextScale(
            child: Column(children: [
              _TopBar(tab: _tab),
              if (app.saveFailed) const _SaveWarning(),
              Expanded(
                child: IndexedStack(
                  index: _tab,
                  children: [
                    const PathScreen(),
                    _ReviewTab(active: _tab == 1),
                    const _ProfileTab(),
                  ],
                ),
              ),
            ]),
          ),
        ),
        bottomNavigationBar: FutureBuilder<int>(
          future: _dueFuture,
          builder: (context, snap) => _TabBar(
            index: _tab,
            badge: snap.data ?? 0,
            onTap: (i) {
              hideDkToast();
              setState(() => _tab = i);
            },
          ),
        ),
      ),
    );
  }
}

class _SaveWarning extends StatelessWidget {
  const _SaveWarning();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: K.againBg,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: const Row(children: [
          DkIcon(DkIcons.info, size: 22, color: K.againInk),
          SizedBox(width: 10),
          Expanded(
            child: Text(
                'Çalışmanı kaydedemedim. Bir büyüğüne haber ver: Veli alanında açıklama var.',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: K.againInk)),
          ),
        ]),
      );
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.tab});
  final int tab;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final p = app.progress!;
    final subject = app.subject!;
    final (icon, tint, ink) = subjectStyle(subject);
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: K.line, width: 2))),
      child: Row(children: [
        if (tab == 0)
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Pressable(
                key: const Key('subject-picker'),
                onTap: () => showSubjectSheet(context),
                label: 'Ders seç: ${subject.label}',
                excludeChildSemantics: true,
                focusRadius: K.rMd,
                builder: (context, down) => Container(
                  constraints: const BoxConstraints(minHeight: 52),
                  padding: const EdgeInsets.only(left: 6, right: 10),
                  decoration: BoxDecoration(
                    color: K.card,
                    borderRadius: BorderRadius.circular(K.rMd),
                    border: Border.all(color: K.line, width: 2),
                    boxShadow: down
                        ? null
                        : const [
                            BoxShadow(color: K.line, offset: Offset(0, 3))
                          ],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: tint, borderRadius: BorderRadius.circular(12)),
                      child: DkIcon(icon, size: 22, color: ink),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(subject.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: K.ink)),
                    ),
                    const SizedBox(width: 4),
                    const DkIcon(DkIcons.down, size: 20, color: K.inkSoft),
                  ]),
                ),
              ),
            ),
          )
        else ...[
          Text(tab == 1 ? 'Tekrar' : 'Profil',
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w900, color: K.ink)),
          const Spacer(),
        ],
        _Counter(
          key: const Key('streak'),
          icon: DkIcons.leaf,
          color: K.leafInk,
          value: p.streakDays,
          spoken: '${p.streakDays} gündür birlikteyiz',
        ),
        _Counter(
          key: const Key('nuts'),
          icon: DkIcons.nut,
          color: K.nutInk,
          value: p.nuts,
          spoken: '${p.nuts} fındık',
        ),
      ]),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    required this.spoken,
  });
  final DkIcons icon;
  final Color color;
  final int value;
  final String spoken;

  @override
  Widget build(BuildContext context) => Pressable(
        onTap: () => AppScope.read(context).say(spoken),
        label: spoken,
        excludeChildSemantics: true,
        focusRadius: 12,
        builder: (context, down) => Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            DkIcon(icon, size: icon == DkIcons.nut ? 28 : 26, color: color),
            const SizedBox(width: 4),
            Text('$value',
                style: TextStyle(
                    fontSize: 19, fontWeight: FontWeight.w900, color: color)),
          ]),
        ),
      );
}

class _TabBar extends StatelessWidget {
  const _TabBar(
      {required this.index, required this.badge, required this.onTap});
  final int index;
  final int badge;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const tabs = [
      ('tab-path', 'Yol', DkIcons.map),
      ('tab-review', 'Tekrar', DkIcons.again),
      ('tab-profile', 'Profil', DkIcons.user),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: K.card,
        border: Border(top: BorderSide(color: K.line, width: 2)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: SafeArea(
        top: false,
        child: Row(children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: Pressable(
                key: Key(tabs[i].$1),
                onTap: () => onTap(i),
                selected: index == i,
                label: i == 1 && badge > 0
                    ? '${tabs[i].$2}, $badge tekrar bekliyor'
                    : tabs[i].$2,
                excludeChildSemantics: true,
                focusRadius: 17,
                builder: (context, down) {
                  final sel = index == i;
                  final fg = sel ? K.peachInk : K.inkSoft;
                  return SizedBox(
                    height: 64,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 34,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: sel ? K.peach : Colors.transparent,
                                  borderRadius: BorderRadius.circular(17)),
                              child: DkIcon(tabs[i].$3, size: 26, color: fg),
                            ),
                            const SizedBox(height: 3),
                            Text(tabs[i].$2,
                                textScaler: TextScaler.noScaling,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        sel ? FontWeight.w900 : FontWeight.w700,
                                    color: fg)),
                          ],
                        ),
                        if (i == 1 && badge > 0)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Transform.translate(
                                offset: const Offset(26, 0),
                                child: Container(
                                  constraints: const BoxConstraints(
                                      minWidth: 24, minHeight: 24),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: K.primary,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: Text(badge > 99 ? '99+' : '$badge',
                                      textAlign: TextAlign.center,
                                      textScaler: TextScaler.noScaling,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: K.ink)),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ]),
      ),
    );
  }
}

/// B5 Tekrar sekmesi.
class _ReviewTab extends StatefulWidget {
  const _ReviewTab({required this.active});
  final bool active;

  @override
  State<_ReviewTab> createState() => _ReviewTabState();
}

class _ReviewData {
  const _ReviewData(this.due, this.subject, this.tomorrow, this.strengths);
  final int due;
  final Subject? subject;
  final int tomorrow;
  final List<(String, int)> strengths;
}

class _ReviewTabState extends State<_ReviewTab> {
  Future<_ReviewData>? _f;
  String _key = '';

  Future<_ReviewData> _load() async {
    final app = AppScope.read(context);
    final bySubject = await app.dueBySubject();
    final due = bySubject.fold<int>(0, (s, e) => s + e.$2);
    final now = app.clock();
    final tomorrowEnd = dayStart(now).add(const Duration(days: 1));
    final tomorrow = app.progress!.cards.values
        .where((c) =>
            !c.isNew && c.due.isAfter(now) && !c.due.isAfter(tomorrowEnd))
        .length;
    final subject = app.subject!;
    final m = await app.masteryMap(app.active!, app.progress!, subject);
    final strengths = <(String, int)>[];
    for (final e in m.entries) {
      if (!app.progress!.startedOutcomes.contains(e.key.code)) continue;
      final lv = switch (e.value) {
        MasteryLevel.sufficient => 2,
        MasteryLevel.developing => 1,
        _ => 0,
      };
      strengths.add((await app.outcomeLabel(e.key), lv));
    }
    return _ReviewData(due, due > 0 ? bySubject.first.$1 : null, tomorrow,
        strengths.reversed.toList());
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final p = app.progress!;
    final key =
        '${app.active?.id}|${app.subject}|${p.cards.length}|${p.lastSessionDay}|${p.nuts}|${widget.active}';
    if (_f == null || key != _key) {
      _key = key;
      _f = _load();
    }
    return FutureBuilder<_ReviewData>(
      future: _f,
      builder: (context, snap) {
        final d = snap.data;
        if (d == null) return const SizedBox.shrink();
        final has = d.due > 0;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DkCard(
              key: const Key('review-card'),
              radius: K.rLg,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(has ? 'BEKLEYEN TEKRAR' : 'YARIN',
                              style: T.kickerSm),
                          const SizedBox(height: 2),
                          Text('${has ? d.due : d.tomorrow}',
                              style: const TextStyle(
                                  fontSize: 64,
                                  height: 68 / 64,
                                  fontWeight: FontWeight.w900,
                                  color: K.ink)),
                          Text(
                              has
                                  ? 'kart seni bekliyor.'
                                  : d.tomorrow > 0
                                      ? 'kart seni bekliyor. Bugünkü tekrarlar bitti.'
                                      : 'Şimdilik tekrar yok. Yeni konular öğrendikçe burada birikir.',
                              style: const TextStyle(
                                  fontSize: 19,
                                  height: 24 / 19,
                                  fontWeight: FontWeight.w700,
                                  color: K.ink2)),
                        ],
                      ),
                    ),
                    const Mascot(size: 96),
                  ]),
                  if (has) ...[
                    const SizedBox(height: 14),
                    ChunkyButton(
                      key: const Key('review-start'),
                      label: 'Tekrar yap',
                      onPressed: () {
                        if (d.subject != null) app.selectSubject(d.subject!);
                        openSession(context,
                            subject: d.subject!, reviewOnly: true);
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Güçlenen konular', style: T.sub),
            const SizedBox(height: 12),
            if (d.strengths.isEmpty)
              const Text(
                  'Konulara başladıkça burada tohumdan ağaca büyüyecekler.',
                  style: T.help),
            for (final s in d.strengths) ...[
              _StrengthRow(title: s.$1, level: s.$2),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _StrengthRow extends StatelessWidget {
  const _StrengthRow({required this.title, required this.level});
  final String title;
  final int level;

  @override
  Widget build(BuildContext context) {
    const names = ['tohum', 'fidan', 'ağaç'];
    const icons = [DkIcons.seed, DkIcons.sprout, DkIcons.tree];
    return Semantics(
      label: '$title: ${names[level]}',
      child: ExcludeSemantics(
        child: DkCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          radius: 18,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(children: [
              Expanded(
                child: EmojiText(title,
                    style: const TextStyle(
                        fontSize: 18,
                        height: 23 / 18,
                        fontWeight: FontWeight.w800,
                        color: K.ink)),
              ),
              const SizedBox(width: 8),
              for (var j = 0; j < 3; j++)
                Container(
                  width: 34,
                  height: 34,
                  margin: const EdgeInsets.only(left: 2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: j <= level ? K.goodBg : K.closeBg,
                      borderRadius: BorderRadius.circular(K.rSm)),
                  child: DkIcon(icons[j],
                      size: 20, color: j <= level ? K.goodInk : K.lockedShade),
                ),
              SizedBox(
                width: 52,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(names[level],
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: K.leafInk)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// B6 Profil sekmesi.
class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  Future<int>? _stars;
  String _key = '';

  Future<int> _countStars() async {
    final app = AppScope.read(context);
    var n = 0;
    for (final s in Subject.forGrade(app.active!.grade)) {
      final m = await app.masteryMap(app.active!, app.progress!, s);
      n += m.values.where((l) => l == MasteryLevel.sufficient).length;
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = app.active!;
    final p = app.progress!;
    final key = '${c.id}|${p.cards.length}|${p.lastSessionDay}|${p.nuts}';
    if (_stars == null || key != _key) {
      _key = key;
      _stars = _countStars();
    }
    Widget stat(DkIcons icon, Color color, String value, String label) =>
        Expanded(
          child: DkCard(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DkIcon(icon, size: 28, color: color),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: K.ink)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 14,
                        height: 18 / 14,
                        fontWeight: FontWeight.w700,
                        color: K.inkSoft)),
              ],
            ),
          ),
        );
    final week = app.week();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      children: [
        Row(children: [
          Avatar(index: c.avatarIndex, size: 88),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.nickname, style: T.title),
                Text('${c.grade}. sınıf',
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: K.inkSoft)),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 18),
        FutureBuilder<int>(
          future: _stars,
          builder: (context, snap) => IntrinsicHeight(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                stat(DkIcons.leaf, K.leafInk, '${p.streakDays}',
                    'gündür birlikte'),
                const SizedBox(width: 10),
                stat(DkIcons.nut, K.nut, '${p.nuts}', 'fındık'),
                const SizedBox(width: 10),
                stat(DkIcons.star, K.rewardShade, '${snap.data ?? 0}',
                    'yıldızlı konu'),
              ])),
        ),
        const SizedBox(height: 18),
        DkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Bu hafta',
                  style: TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w800, color: K.ink)),
              const SizedBox(height: 12),
              Row(children: [
                for (final d in week) Expanded(child: _DayDot(day: d)),
              ]),
              const SizedBox(height: 12),
              const Text(
                  'Ay simgeli günler dinlenme günü. Haftada 2 gün dinlenmek de öğrenmenin parçası.',
                  style: T.help),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ChunkyButton(
          key: const Key('switch-profile'),
          label: 'Profil değiştir',
          kind: BtnKind.secondary,
          onPressed: app.signOutChild,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextBtn(
            key: const Key('parent-entry'),
            label: 'Veli alanı',
            icon: DkIcons.lock,
            color: K.inkSoft,
            fontSize: 15,
            onPressed: () => openParentArea(context),
          ),
        ),
      ],
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.day});
  final WeekDay day;

  @override
  Widget build(BuildContext context) {
    final studied = day.minutes > 0;
    final isToday = day.isToday;
    final future = day.isFuture;
    final (Color bg, Color fg, DkIcons? icon, String sem) = studied
        ? (K.goodShadow, Colors.white, DkIcons.check, 'çalıştı')
        : isToday
            ? (Colors.white, K.label, DkIcons.play, 'bugün')
            : future
                ? (K.closeBg, K.inkSoft, null, 'henüz gelmedi')
                : (K.stone, K.inkMuted, DkIcons.moon, 'dinlenme');
    return Semantics(
      label: '${day.label}: $sem',
      child: ExcludeSemantics(
        child: Column(children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: isToday && !studied
                  ? Border.all(color: K.primary, width: 3)
                  : null,
            ),
            child: icon == null
                ? null
                : DkIcon(icon, size: 18, color: fg, stroke: 3),
          ),
          const SizedBox(height: 6),
          Text(day.label,
              textScaler: TextScaler.noScaling,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: K.inkSoft)),
        ]),
      ),
    );
  }
}

/// Veli kapısından geçip veli paneline girer.
Future<void> openParentArea(BuildContext context) async {
  final nav = Navigator.of(context);
  if (await showParentGate(context)) {
    await nav
        .push(MaterialPageRoute<void>(builder: (_) => const ParentScreen()));
  }
}
