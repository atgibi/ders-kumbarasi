import 'package:flutter/material.dart';

import '../../core/srs/leitner.dart';
import '../../data/models.dart';
import '../theme.dart';
import '../widgets/chunky_button.dart';
import '../widgets/mascot.dart';
import 'parent_gate.dart';
import 'parent_screen.dart';
import 'path_screen.dart';
import 'session_screen.dart';

/// Çocuğun ana kabuğu: Yol, Tekrar, Profil sekmeleri.
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final p = app.progress!;
    return PopScope(
      // Android geri tuşu: önce Yol sekmesine döner
      canPop: _tab == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _tab != 0) setState(() => _tab = 0);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 12,
          title: Row(
            children: [
              if (_tab == 0)
                const _SubjectPicker()
              else
                Text(['Yol', 'Tekrar', 'Profil'][_tab]),
              const Spacer(),
              _Stat(
                  key: const Key('streak'),
                  icon: '🔥',
                  value: p.streakDays,
                  color: const Color(0xFFE8892F)),
              const SizedBox(width: 12),
              _Stat(
                  key: const Key('nuts'),
                  icon: '🌰',
                  value: p.nuts,
                  color: Kumbara.nut),
            ],
          ),
        ),
        body: SafeArea(
          child: IndexedStack(
            index: _tab,
            children: const [PathScreen(), _ReviewTab(), _ProfileTab()],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(
                key: Key('tab-path'),
                icon: Icon(Icons.home_rounded, size: 30),
                label: 'Yol'),
            NavigationDestination(
                key: Key('tab-review'),
                icon: Icon(Icons.replay_rounded, size: 30),
                label: 'Tekrar'),
            NavigationDestination(
                key: Key('tab-profile'),
                icon: Icon(Icons.person_rounded, size: 30),
                label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(
      {super.key,
      required this.icon,
      required this.value,
      required this.color});
  final String icon;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 4),
          Text('$value',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w900, fontSize: 18)),
        ],
      );
}

class _SubjectPicker extends StatelessWidget {
  const _SubjectPicker();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final subjects = Subject.forGrade(app.active!.grade);
    final current = app.subject!;
    return PopupMenuButton<Subject>(
      key: const Key('subject-picker'),
      tooltip: 'Ders seç',
      onSelected: app.selectSubject,
      itemBuilder: (_) => [
        for (final s in subjects)
          PopupMenuItem(
            key: Key('pick-${s.id}'),
            value: s,
            child: Text('${s.icon}  ${s.label}',
                style: const TextStyle(fontSize: 18)),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Kumbara.line, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(current.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 6),
            Text(current.label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const Icon(Icons.arrow_drop_down_rounded),
          ],
        ),
      ),
    );
  }
}

class _ReviewTab extends StatelessWidget {
  const _ReviewTab();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final subjects = Subject.forGrade(app.active!.grade);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const MascotSays(
          text:
              'Unutmaya başladığın konuları tam zamanında tekrar edelim. Böylece bilgiler kumbarada kalıcı olur!',
        ),
        const SizedBox(height: 12),
        for (final s in subjects)
          FutureBuilder<int>(
            future: app.dueCount(s),
            builder: (context, snap) {
              final n = snap.data ?? 0;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(s.icon, style: const TextStyle(fontSize: 34)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.label,
                                style: Theme.of(context).textTheme.titleLarge),
                            Text(n == 0
                                ? 'Şimdilik tekrar yok'
                                : '$n kart tekrar bekliyor'),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: ChunkyButton(
                          key: Key('review-${s.id}'),
                          label: 'Tekrar',
                          height: 44,
                          onPressed: n == 0
                              ? null
                              : () async {
                                  if (app.overDailyLimit ||
                                      app.settings.isQuietTime(app.clock())) {
                                    await showRestDialog(context,
                                        quiet: app.settings
                                            .isQuietTime(app.clock()));
                                    return;
                                  }
                                  await Navigator.of(context)
                                      .push(MaterialPageRoute<void>(
                                    builder: (_) => SessionScreen(
                                        subject: s, reviewOnly: true),
                                  ));
                                },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = app.active!;
    final p = app.progress!;
    final t = Theme.of(context).textTheme;
    final learned =
        p.cards.values.where((s) => s.box >= masteredFromBox).length;
    Widget stat(String icon, String value, String label) => Expanded(
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Kumbara.line, width: 2),
            ),
            child: Column(children: [
              Text(icon, style: const TextStyle(fontSize: 26)),
              Text(value, style: t.titleLarge),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Kumbara.inkSoft)),
            ]),
          ),
        );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: Text(c.avatar, style: const TextStyle(fontSize: 80))),
        Center(child: Text(c.nickname, style: t.headlineMedium)),
        Center(
            child: Text('${c.grade}. sınıf',
                style: const TextStyle(color: Kumbara.inkSoft, fontSize: 16))),
        const SizedBox(height: 16),
        Row(children: [
          stat('🔥', '${p.streakDays}', 'günlük seri'),
          stat('🌰', '${p.nuts}', 'fındık'),
          stat('⭐', '$learned', 'kalıcı bilgi'),
        ]),
        const SizedBox(height: 24),
        ChunkyButton(
          key: const Key('switch-profile'),
          label: 'Profil değiştir',
          color: Colors.white,
          shadow: Kumbara.line,
          textColor: Kumbara.ink,
          onPressed: app.signOutChild,
        ),
        const SizedBox(height: 12),
        ChunkyButton(
          key: const Key('parent-entry-profile'),
          label: 'Veli paneli',
          color: Colors.white,
          shadow: Kumbara.line,
          textColor: Kumbara.ink,
          onPressed: () async {
            if (await showParentGate(context) && context.mounted) {
              await Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => const ParentScreen()));
            }
          },
        ),
      ],
    );
  }
}
