import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../core/srs/leitner.dart';
import '../../data/models.dart';
import '../theme.dart';
import '../widgets/dk_icon.dart';
import '../widgets/emoji_text.dart';
import '../widgets/kit.dart';
import '../widgets/mascot.dart';
import 'system_screens.dart';

/// Ders simgesi ve renkleri (ders seçici ve üst çubuk).
(DkIcons, Color, Color) subjectStyle(Subject s) => switch (s) {
      Subject.turkce => (DkIcons.book, K.againBg, K.againInk),
      Subject.matematik => (DkIcons.blocks, K.peach, K.peachInk),
      Subject.hayatBilgisi => (DkIcons.house, K.goodBg, K.goodInk),
      Subject.fenBilimleri => (DkIcons.search, K.family, K.familyInk),
      Subject.sosyalBilgiler => (DkIcons.globe, K.rewardChip, K.rewardChipInk),
    };

/// Yol düğümünün durumu.
enum NodeState { gold, started, current, locked, soon }

class PathNode {
  const PathNode({
    required this.outcome,
    required this.state,
    required this.label,
    required this.ratio,
    required this.due,
    required this.firstPage,
  });
  final Outcome outcome;
  final NodeState state;

  /// Çocuk dostu başlık (konu anlatımının adı); yoksa programdaki ifade.
  final String label;

  /// Kalıcı öğrenilen kart oranı (başlandı halkası).
  final double ratio;

  /// Tekrar zamanı gelmiş kartı var.
  final bool due;

  /// "Konuyu dinle" için anlatımın ilk sayfası.
  final String? firstPage;

  bool get open => state != NodeState.locked && state != NodeState.soon;
}

class PathSection {
  const PathSection(this.title, this.subtitle, this.nodes, this.index);
  final String title;
  final String subtitle;
  final List<PathNode> nodes;
  final int index;
  Color get color => K.units[index % K.units.length];
  Color get shade => K.unitShades[index % K.unitShades.length];
}

/// Bir ders için ünite ünite ilerleyen yolu hesaplar.
Future<List<PathSection>> buildPath(AppState app, Subject subject) async {
  final child = app.active!;
  final progress = app.progress!;
  final outcomes = await app.content.outcomesFor(subject, child.grade);
  final pack = await app.content.contentFor(subject, child.grade);
  final now = app.clock();

  var currentFound = false;
  final nodes = <PathNode>[];
  for (final o in outcomes) {
    final cards = pack[o.code]?.cards ?? const <CardDef>[];
    final states = [
      for (final c in cards) progress.cards[c.id] ?? CardState.fresh(c.id, now)
    ];
    final NodeState st;
    if (cards.isEmpty) {
      st = NodeState.soon;
    } else if (progress.startedOutcomes.contains(o.code)) {
      st = outcomeMastery(states) == MasteryLevel.sufficient
          ? NodeState.gold
          : NodeState.started;
    } else if (!currentFound) {
      st = NodeState.current;
      currentFound = true;
    } else {
      st = NodeState.locked;
    }
    final lessons = pack[o.code]?.lessons ?? const <Lesson>[];
    nodes.add(PathNode(
      outcome: o,
      state: st,
      label: lessons.isNotEmpty ? lessons.first.title : o.title,
      ratio: states.isEmpty
          ? 0
          : states.where((s) => s.isMastered).length / states.length,
      due: states.any((s) => !s.isNew && s.isDue(now)),
      firstPage: lessons.isNotEmpty && lessons.first.pages.isNotEmpty
          ? lessons.first.pages.first.spoken
          : null,
    ));
  }

  // Gruplama: Türkçe beceri alanına, diğer dersler üniteye göre
  final sections = <PathSection>[];
  String keyOf(Outcome o) => o.unit?.toString() ?? o.area ?? '';
  var i = 0, n = 0;
  while (i < nodes.length) {
    final k = keyOf(nodes[i].outcome);
    final group = <PathNode>[];
    while (i < nodes.length && keyOf(nodes[i].outcome) == k) {
      group.add(nodes[i++]);
    }
    final o = group.first.outcome;
    final String title, subtitle;
    if (o.unit != null) {
      title =
          subject == Subject.matematik ? 'TEMA ${o.unit}' : 'ÜNİTE ${o.unit}';
      subtitle =
          await app.content.unitName(subject, child.grade, o.unit!) ?? '';
    } else {
      title = 'BÖLÜM ${n + 1}';
      subtitle = o.area ?? '';
    }
    sections.add(PathSection(title, subtitle, group, n));
    n++;
  }
  return sections;
}

/// B2 Yol (ana sayfa): bugün kartı + ünite ünite zikzak düğümler.
class PathScreen extends StatefulWidget {
  const PathScreen({super.key});

  @override
  State<PathScreen> createState() => _PathScreenState();
}

class _PathScreenState extends State<PathScreen> {
  final _currentKey = GlobalKey();
  Future<(List<PathSection>, int)>? _future;
  String _forKey = '';

  Future<(List<PathSection>, int)> _build(AppState app) async {
    final sections = await buildPath(app, app.subject!);
    final due = await app.dueCount(app.subject!);
    return (sections, due);
  }

  void _refreshIfNeeded(AppState app) {
    final p = app.progress;
    final key = '${app.active?.id}|${app.subject}|${p?.startedOutcomes.length}|'
        '${p?.cards.length}|${p?.lastSessionDay}|${p?.nuts}';
    if (_future == null || key != _forKey) {
      final first = _future == null ||
          !_forKey.startsWith('${app.active?.id}|${app.subject}|');
      _forKey = key;
      _future = _build(app);
      if (first) {
        _future!.then((_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final ctx = _currentKey.currentContext;
            if (ctx != null && mounted) {
              Scrollable.ensureVisible(ctx,
                  alignment: 0.4,
                  duration:
                      Duration(milliseconds: reduceMotion(context) ? 0 : 300));
            }
          });
        });
      }
    }
  }

  Future<void> _open(PathSection section, PathNode node) async {
    final app = AppScope.read(context);
    switch (node.state) {
      case NodeState.locked:
        showDkToast(context, DkIcons.lock,
            'Önce sıradaki konuyu bitirelim. Sonra burası açılır.');
        return;
      case NodeState.soon:
        showDkToast(
            context, DkIcons.hourglass, 'Bu konu hazırlanıyor. Çok yakında!');
        return;
      case NodeState.current:
      case NodeState.started:
      case NodeState.gold:
        break;
    }
    hideDkToast();
    final start = await showDkSheet<bool>(
      context,
      builder: (ctx) => _NodeSheet(
        section: section,
        node: node,
        onListen: () => app.say([
          node.label,
          if (node.firstPage != null) node.firstPage!
        ].join('. ')),
      ),
    );
    if (start == true && mounted) {
      await openSession(context,
          subject: app.subject!,
          focusOutcome: node.outcome.code,
          checkDoneToday: node.state == NodeState.current);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    _refreshIfNeeded(app);
    return FutureBuilder<(List<PathSection>, int)>(
      future: _future,
      builder: (context, snap) {
        if (snap.hasError) {
          return const _PathProblem();
        }
        final data = snap.data;
        if (data == null) return const SizedBox.shrink();
        final (sections, due) = data;
        var idx = 0;
        final hasCurrent = sections
            .any((s) => s.nodes.any((n) => n.state == NodeState.current));
        return ListView(
          key: const Key('path-list'),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _TodayCard(
              due: due,
              newTopic: hasCurrent,
              done: app.studiedToday && due == 0,
            ),
            for (final s in sections) ...[
              _UnitBanner(section: s),
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Column(children: [
                  for (final node in s.nodes)
                    _NodeItem(
                      key: node.state == NodeState.current ? _currentKey : null,
                      node: node,
                      section: s,
                      dx: const <double>[
                        0,
                        56,
                        84,
                        56,
                        0,
                        -56,
                        -84,
                        -56
                      ][idx++ % 8],
                      onTap: () => _open(s, node),
                    ),
                ]),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _PathProblem extends StatelessWidget {
  const _PathProblem();

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Mascot(mood: MascotMood.think, size: 140),
            SizedBox(height: 16),
            Text('Bu ders şu an açılamadı. Başka bir ders seçebilirsin.',
                textAlign: TextAlign.center, style: T.sub),
          ]),
        ),
      );
}

class _TodayCard extends StatelessWidget {
  const _TodayCard(
      {required this.due, required this.newTopic, required this.done});
  final int due;
  final bool newTopic;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final String text;
    if (done) {
      text = 'Bugünlük bu kadar! Yarın görüşürüz.';
    } else if (due > 0 && newTopic) {
      text = '$due tekrar + 1 yeni konu';
    } else if (due > 0) {
      text = '$due tekrar';
    } else if (newTopic) {
      text = '1 yeni konu';
    } else {
      text = 'Tüm konular kumbarada!';
    }
    final spoken = done
        ? 'Bugünlük bu kadar! Yarın görüşürüz.'
        : 'Bugün ${text.replaceAll('+', 've')} var.';
    return DkCard(
      key: const Key('today-card'),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.fromLTRB(10, 14, 14, 14),
      radius: K.rLg,
      child: Row(children: [
        Mascot(mood: done ? MascotMood.celebrate : MascotMood.normal, size: 58),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('BUGÜN', style: T.kickerSm),
              const SizedBox(height: 2),
              Text(text,
                  style: const TextStyle(
                      fontSize: 19,
                      height: 24 / 19,
                      fontWeight: FontWeight.w800,
                      color: K.ink)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        ListenButton(onListen: () => app.say(spoken), iconSize: 28),
      ]),
    );
  }
}

class _UnitBanner extends StatelessWidget {
  const _UnitBanner({required this.section});
  final PathSection section;

  @override
  Widget build(BuildContext context) {
    final started = section.nodes
        .where((n) => n.state == NodeState.started || n.state == NodeState.gold)
        .length;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 22, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: section.color,
        borderRadius: BorderRadius.circular(K.rLg),
        boxShadow: [
          BoxShadow(color: section.shade, offset: const Offset(0, 5))
        ],
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Pill(section.title,
                  bg: Colors.white,
                  fg: K.ink,
                  fontSize: 13,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3)),
              if (section.subtitle.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(section.subtitle,
                    style: const TextStyle(
                        fontSize: 21,
                        height: 26 / 21,
                        fontWeight: FontWeight.w800,
                        color: K.ink)),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        Semantics(
          label: '${section.nodes.length} konudan $started konuya başlandı',
          child: ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Text('$started/${section.nodes.length}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900, color: K.ink)),
            ),
          ),
        ),
      ]),
    );
  }
}

/// Yol düğümü (88 halka + 68 yüz, 6 px blok gölge).
class PathNodeView extends StatelessWidget {
  const PathNodeView(
      {super.key,
      required this.node,
      required this.color,
      required this.shade});
  final PathNode node;
  final Color color;
  final Color shade;

  @override
  Widget build(BuildContext context) {
    final (Color face, Color sh, DkIcons icon, Color ic) = switch (node.state) {
      NodeState.gold => (K.reward, K.rewardShade, DkIcons.star, K.ink),
      NodeState.started => (color, shade, DkIcons.check, K.ink),
      NodeState.current => (color, shade, DkIcons.play, K.ink),
      NodeState.locked => (K.locked, K.lockedShade, DkIcons.lock, K.inkMuted),
      NodeState.soon => (K.stone, K.locked, DkIcons.clock, K.inkMuted),
    };
    return SizedBox(
      width: 88,
      height: 96,
      child: Stack(children: [
        if (node.state == NodeState.gold)
          Container(
              width: 88,
              height: 88,
              decoration:
                  const BoxDecoration(color: K.reward, shape: BoxShape.circle))
        else if (node.state == NodeState.started)
          SizedBox(
            width: 88,
            height: 88,
            child: CustomPaint(
                painter: _RingPainter(color, node.ratio.clamp(.12, .95))),
          ),
        Positioned(
          left: 6,
          top: 6,
          child: Container(
              width: 76,
              height: 76,
              decoration:
                  const BoxDecoration(color: K.bg, shape: BoxShape.circle)),
        ),
        Positioned(
          left: 10,
          top: 10,
          child: Opacity(
            opacity: node.state == NodeState.soon ? .7 : 1,
            child: Container(
              width: 68,
              height: 68,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: face,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: sh, offset: const Offset(0, 6))],
              ),
              child: DkIcon(icon, size: 32, color: ic),
            ),
          ),
        ),
        if (node.due)
          Positioned(
            right: 0,
            top: 2,
            child: Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: K.primary,
                shape: BoxShape.circle,
                border: Border.all(color: K.bg, width: 3),
              ),
              child: const DkIcon(DkIcons.again,
                  size: 12, color: K.ink, stroke: 3.5),
            ),
          ),
      ]),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.color, this.ratio);
  final Color color;
  final double ratio;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawOval(r, Paint()..color = K.line);
    canvas.drawArc(r, -1.5708, ratio * 6.28318, true, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.color != color || old.ratio != ratio;
}

String nodeStatusText(NodeState s) => switch (s) {
      NodeState.gold => 'yıldızlı',
      NodeState.started => 'başladın',
      NodeState.current => 'sıradaki',
      NodeState.locked => 'kilitli',
      NodeState.soon => 'yakında',
    };

class _NodeItem extends StatefulWidget {
  const _NodeItem({
    super.key,
    required this.node,
    required this.section,
    required this.dx,
    required this.onTap,
  });
  final PathNode node;
  final PathSection section;
  final double dx;
  final VoidCallback onTap;

  @override
  State<_NodeItem> createState() => _NodeItemState();
}

class _NodeItemState extends State<_NodeItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_NodeItem old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.node.state == NodeState.current && !reduceMotion(context)) {
      if (!_bounce.isAnimating) _bounce.repeat(reverse: true);
    } else {
      _bounce.stop();
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.node;
    final dim = n.state == NodeState.locked || n.state == NodeState.soon;
    final width = MediaQuery.sizeOf(context).width;
    final dx = widget.dx * (width < 360 ? .7 : 1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Transform.translate(
        offset: Offset(dx, 0),
        child: Column(children: [
          if (n.state == NodeState.current)
            AnimatedBuilder(
              animation: _bounce,
              builder: (context, child) => Transform.translate(
                  offset:
                      Offset(0, -6 * Curves.easeInOut.transform(_bounce.value)),
                  child: child),
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: K.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: K.line, width: 2),
                ),
                child: const ExcludeSemantics(
                  child: Text('BAŞLA',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .6,
                          color: K.ink)),
                ),
              ),
            ),
          Pressable(
            key: Key('node-${n.outcome.code}'),
            onTap: widget.onTap,
            label: '${n.label}, ${nodeStatusText(n.state)}'
                '${n.due ? ', tekrar zamanı' : ''}',
            excludeChildSemantics: true,
            focusRadius: 44,
            builder: (context, down) => Transform.translate(
              offset: Offset(0, down ? 3 : 0),
              child: PathNodeView(
                  node: n,
                  color: widget.section.color,
                  shade: widget.section.shade),
            ),
          ),
          const SizedBox(height: 4),
          ExcludeSemantics(
            child: SizedBox(
              width: 200,
              child: EmojiText(
                n.label,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 20 / 15,
                  fontWeight: FontWeight.w800,
                  color: dim ? K.inkSoft : K.ink,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

/// B3 Düğüm detayı.
class _NodeSheet extends StatelessWidget {
  const _NodeSheet(
      {required this.section, required this.node, required this.onListen});
  final PathSection section;
  final PathNode node;
  final VoidCallback onListen;

  @override
  Widget build(BuildContext context) {
    final (DkIcons icon, String status) = switch (node.state) {
      NodeState.gold => (DkIcons.star, 'Yıldızlı konu. Tekrarla güçlü tut.'),
      NodeState.started => (DkIcons.check, 'Başladın. Biraz daha çalışalım.'),
      _ => (DkIcons.play, 'Sıradaki yeni konu'),
    };
    return Column(
      key: const Key('node-sheet'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Pill(section.title,
                    bg: section.color,
                    fg: K.ink,
                    fontSize: 13,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3)),
                const SizedBox(height: 6),
                EmojiText(node.label, style: T.title),
                const SizedBox(height: 6),
                Row(children: [
                  DkIcon(icon, size: 20, color: K.ink2),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(status,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: K.ink2)),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CircleBtn.close(onPressed: () => Navigator.pop(context, false)),
        ]),
        const SizedBox(height: 14),
        ChunkyButton(
          key: const Key('node-start'),
          label: node.state == NodeState.current ? 'Başla' : 'Tekrar et',
          onPressed: () => Navigator.pop(context, true),
        ),
        const SizedBox(height: 9),
        ChunkyButton(
          key: const Key('node-listen'),
          label: 'Konuyu dinle',
          kind: BtnKind.secondary,
          icon: DkIcons.volume,
          iconColor: K.againStrong,
          onPressed: onListen,
        ),
      ],
    );
  }
}

/// B4 Ders seçici.
Future<void> showSubjectSheet(BuildContext context) async {
  final app = AppScope.read(context);
  final child = app.active!;
  final subjects = Subject.forGrade(child.grade);
  final info = <Subject, (int, int, int)>{};
  for (final s in subjects) {
    final pack = await app.content.contentFor(s, child.grade);
    final outcomes = await app.content.outcomesFor(s, child.grade);
    final m = await app.masteryMap(child, app.progress!, s);
    info[s] = (
      pack.length,
      outcomes
          .where((o) => app.progress!.startedOutcomes.contains(o.code))
          .length,
      m.values.where((l) => l == MasteryLevel.sufficient).length,
    );
    if (outcomes.isEmpty) info[s] = (0, 0, 0);
  }
  if (!context.mounted) return;
  await showDkSheet<void>(
    context,
    builder: (ctx) => Column(
      key: const Key('subject-sheet'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          const Expanded(
              child: Text('Hangi ders?',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: K.ink))),
          CircleBtn.close(onPressed: () => Navigator.pop(ctx)),
        ]),
        const SizedBox(height: 10),
        for (final s in subjects) ...[
          _SubjectRow(
            subject: s,
            selected: s == app.subject,
            withContent: info[s]!.$1,
            started: info[s]!.$2,
            starred: info[s]!.$3,
            onTap: info[s]!.$1 == 0
                ? null
                : () {
                    app.selectSubject(s);
                    Navigator.pop(ctx);
                  },
          ),
          const SizedBox(height: 10),
        ],
      ],
    ),
  );
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({
    required this.subject,
    required this.selected,
    required this.withContent,
    required this.started,
    required this.starred,
    required this.onTap,
  });
  final Subject subject;
  final bool selected;
  final int withContent;
  final int started;
  final int starred;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, tint, ink) = subjectStyle(subject);
    final note = withContent == 0
        ? 'Yakında'
        : starred > 0
            ? '$starred konu yıldızlı'
            : started > 0
                ? '$started konuya başladın'
                : 'Henüz başlamadın';
    final ratio = withContent == 0 ? 0.0 : started / withContent;
    return Pressable(
      key: Key('pick-${subject.id}'),
      onTap: onTap,
      selected: selected,
      label: '${subject.label}, $note',
      excludeChildSemantics: true,
      focusRadius: 18,
      builder: (context, down) => Opacity(
        opacity: withContent == 0 ? .5 : 1,
        child: Container(
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: down ? K.bg : K.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: selected ? K.primary : K.line, width: selected ? 3 : 2),
          ),
          child: Row(children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: tint, borderRadius: BorderRadius.circular(16)),
              child: DkIcon(icon, size: 28, color: ink),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject.label,
                      style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: K.ink)),
                  const SizedBox(height: 2),
                  Text(note,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: K.inkSoft)),
                ],
              ),
            ),
            SizedBox(
              width: 44,
              height: 44,
              child: Stack(alignment: Alignment.center, children: [
                CustomPaint(
                    size: const Size(44, 44),
                    painter: _RingPainter(ink, ratio)),
                Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
