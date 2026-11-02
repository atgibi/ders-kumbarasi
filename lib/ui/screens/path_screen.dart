import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../core/srs/leitner.dart';
import '../../data/models.dart';
import '../theme.dart';
import 'session_screen.dart';

enum NodeState { done, current, locked, soon }

class PathNode {
  const PathNode(this.outcome, this.state, this.level);
  final Outcome outcome;
  final NodeState state;
  final MasteryLevel level;
}

class PathSection {
  const PathSection(this.title, this.subtitle, this.nodes);
  final String title;
  final String subtitle;
  final List<PathNode> nodes;
}

/// Bir ders için ünite ünite ilerleyen yolu hesaplar.
Future<List<PathSection>> buildPath(AppState app, Subject subject) async {
  final child = app.active!;
  final progress = app.progress!;
  final outcomes = await app.content.outcomesFor(subject, child.grade);
  final pack = await app.content.contentFor(subject, child.grade);
  final mastery = await app.masteryMap(child, progress, subject);

  var currentFound = false;
  final nodes = <PathNode>[];
  for (final o in outcomes) {
    final hasContent = (pack[o.code]?.cards.isNotEmpty ?? false);
    final NodeState st;
    if (!hasContent) {
      st = NodeState.soon;
    } else if (progress.startedOutcomes.contains(o.code)) {
      st = NodeState.done;
    } else if (!currentFound) {
      st = NodeState.current;
      currentFound = true;
    } else {
      st = NodeState.locked;
    }
    nodes.add(PathNode(o, st, mastery[o] ?? MasteryLevel.notStarted));
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
    n++;
    final o = group.first.outcome;
    final String title, subtitle;
    if (o.unit != null) {
      title = subject == Subject.matematik ? 'Tema ${o.unit}' : 'Ünite ${o.unit}';
      subtitle = await app.content.unitName(subject, child.grade, o.unit!) ?? '';
    } else {
      title = 'Bölüm $n';
      subtitle = o.area ?? '';
    }
    sections.add(PathSection(title, subtitle, group));
  }
  return sections;
}

class PathScreen extends StatefulWidget {
  const PathScreen({super.key});

  @override
  State<PathScreen> createState() => _PathScreenState();
}

class _PathScreenState extends State<PathScreen> {
  final _currentKey = GlobalKey();
  Future<List<PathSection>>? _future;
  Subject? _forSubject;
  int _forStarted = -1;

  void _refreshIfNeeded(AppState app) {
    final started = app.progress?.startedOutcomes.length ?? 0;
    if (_future == null || _forSubject != app.subject || _forStarted != started) {
      _forSubject = app.subject;
      _forStarted = started;
      _future = buildPath(app, app.subject!);
      _future!.then((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = _currentKey.currentContext;
          if (ctx != null && mounted) {
            Scrollable.ensureVisible(ctx, alignment: 0.4, duration: const Duration(milliseconds: 300));
          }
        });
      });
    }
  }

  Future<void> _open(PathNode node) async {
    final app = AppScope.read(context);
    switch (node.state) {
      case NodeState.locked:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Önce sıradaki konuyu bitir, sonra burası açılacak.')));
        return;
      case NodeState.soon:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Bu konu hazırlanıyor. Çok yakında!')));
        return;
      case NodeState.current:
      case NodeState.done:
        if (app.overDailyLimit || app.settings.isQuietTime(app.clock())) {
          await showRestDialog(context, quiet: app.settings.isQuietTime(app.clock()));
          return;
        }
        await Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => SessionScreen(subject: app.subject!, focusOutcome: node.outcome.code),
        ));
        if (mounted) setState(() => _future = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    _refreshIfNeeded(app);
    return FutureBuilder<List<PathSection>>(
      future: _future,
      builder: (context, snap) {
        final sections = snap.data;
        if (sections == null) return const Center(child: CircularProgressIndicator());
        var idx = 0;
        return ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            for (var s = 0; s < sections.length; s++) ...[
              _UnitBanner(section: sections[s], color: Kumbara.unitColors[s % Kumbara.unitColors.length]),
              const SizedBox(height: 12),
              for (final node in sections[s].nodes)
                _NodeRow(
                  key: node.state == NodeState.current ? _currentKey : null,
                  node: node,
                  index: idx++,
                  color: Kumbara.unitColors[s % Kumbara.unitColors.length],
                  onTap: () => _open(node),
                ),
              const SizedBox(height: 20),
            ],
          ],
        );
      },
    );
  }
}

Future<void> showRestDialog(BuildContext context, {required bool quiet}) => showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(
          quiet
              ? 'Şimdi dinlenme zamanı. Yarın görüşürüz! 🌙'
              : 'Bugünlük harika çalıştın! Gözlerini dinlendirme zamanı. 🌟',
          style: Theme.of(ctx).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tamam'))],
      ),
    );

class _UnitBanner extends StatelessWidget {
  const _UnitBanner({required this.section, required this.color});
  final PathSection section;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final done = section.nodes.where((n) => n.state == NodeState.done).length;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trUpper(section.title),
                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 2),
                Text(section.subtitle,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
              ],
            ),
          ),
          Text('$done/${section.nodes.length}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
        ],
      ),
    );
  }
}

class _NodeRow extends StatefulWidget {
  const _NodeRow({super.key, required this.node, required this.index, required this.color, required this.onTap});
  final PathNode node;
  final int index;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_NodeRow> createState() => _NodeRowState();
}

class _NodeRowState extends State<_NodeRow> with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  static const _offsets = [0.0, 50.0, 80.0, 50.0, 0.0, -50.0, -80.0, -50.0];

  @override
  void initState() {
    super.initState();
    if (widget.node.state == NodeState.current) _bounce.repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.node;
    final (Color face, Color shade, Widget icon) = switch (n.state) {
      NodeState.done => (
          n.level == MasteryLevel.sufficient ? const Color(0xFFF2C94C) : widget.color,
          n.level == MasteryLevel.sufficient ? const Color(0xFFC9A227) : Color.lerp(widget.color, Colors.black, 0.25)!,
          Icon(n.level == MasteryLevel.sufficient ? Icons.star_rounded : Icons.check_rounded,
              color: Colors.white, size: 38),
        ),
      NodeState.current => (
          widget.color,
          Color.lerp(widget.color, Colors.black, 0.25)!,
          const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 44),
        ),
      NodeState.locked => (Kumbara.locked, const Color(0xFFBDB7AE), const Icon(Icons.lock_rounded, color: Colors.white, size: 30)),
      NodeState.soon => (Kumbara.locked, const Color(0xFFBDB7AE), const Icon(Icons.hourglass_empty_rounded, color: Colors.white, size: 30)),
    };
    final dx = _offsets[widget.index % _offsets.length];
    final node = GestureDetector(
      key: Key('node-${n.outcome.code}'),
      onTap: widget.onTap,
      child: SizedBox(
        width: 76,
        height: 72,
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Container(height: 64, decoration: BoxDecoration(color: shade, shape: BoxShape.circle)),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: face, shape: BoxShape.circle),
                child: icon,
              ),
            ),
          ],
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Transform.translate(
        offset: Offset(dx, 0),
        child: Column(
          children: [
            if (n.state == NodeState.current)
              AnimatedBuilder(
                animation: _bounce,
                builder: (context, child) =>
                    Transform.translate(offset: Offset(0, -4 * _bounce.value), child: child),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Kumbara.line, width: 2),
                  ),
                  child: Text('BAŞLA',
                      style: TextStyle(color: widget.color, fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              ),
            node,
            SizedBox(
              width: 220,
              child: Text(
                n.outcome.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: n.state == NodeState.locked || n.state == NodeState.soon ? Kumbara.inkSoft : Kumbara.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
