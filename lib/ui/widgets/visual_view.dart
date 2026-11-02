/// İçerikteki görsel tanımlarını çizer (resim dosyası gerekmez).
library;

import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../theme.dart';

class VisualView extends StatelessWidget {
  const VisualView(this.visual, {super.key});
  final Visual visual;

  int _i(String k) => (visual.params[k] as num?)?.toInt() ?? 0;
  String _s(String k, [String d = '⭐']) => visual.params[k] as String? ?? d;

  Widget _emojis(String e, int n,
      {double size = 40, Set<int> crossed = const {}}) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 0; i < n; i++)
          Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: crossed.contains(i) ? 0.35 : 1,
                child: Text(e, style: TextStyle(fontSize: size)),
              ),
              if (crossed.contains(i))
                Text('✕',
                    style: TextStyle(
                        fontSize: size * 0.9,
                        color: Kumbara.tryAgain,
                        fontWeight: FontWeight.w900)),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = switch (visual.kind) {
      'objects' =>
        _emojis(_s('emoji'), _i('count'), size: _i('count') > 12 ? 30 : 40),
      'objects2' => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: _emojis(_s('emoji'), _i('a'), size: 32)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('+',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800)),
            ),
            Flexible(child: _emojis(_s('emoji'), _i('b'), size: 32)),
          ],
        ),
      'objects_crossed' => _emojis(_s('emoji'), _i('total'),
            size: 34,
            crossed: {
              for (var i = _i('total') - _i('crossed'); i < _i('total'); i++) i
            }),
      'groups' => Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var g = 0; g < _i('groups'); g++)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  border: Border.all(color: Kumbara.primary, width: 2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 110),
                  child: _emojis(_s('emoji'), _i('each'), size: 22),
                ),
              ),
          ],
        ),
      'blocks' => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var t = 0; t < _i('tens'); t++)
              Container(
                margin: const EdgeInsets.only(right: 4),
                width: 14,
                height: 140,
                decoration: BoxDecoration(
                  color: Kumbara.primary,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: Kumbara.ink.withValues(alpha: 0.4)),
                ),
              ),
            const SizedBox(width: 14),
            Wrap(
              direction: Axis.vertical,
              spacing: 4,
              runSpacing: 4,
              children: [
                for (var o = 0; o < _i('ones'); o++)
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Kumbara.good,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ],
        ),
      'number_highlight' =>
        _NumberHighlight(number: '${visual.params['number']}', pos: _i('pos')),
      'row' => Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            for (final e
                in (visual.params['items'] as List<Object?>? ?? const []))
              Text('$e', style: const TextStyle(fontSize: 42)),
          ],
        ),
      'compare_groups' => Column(
          children: [
            _emojis(_s('ea'), _i('a'), size: 34),
            const Divider(height: 20),
            _emojis(_s('eb'), _i('b'), size: 34),
          ],
        ),
      'shapes' => Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final sh
                in (visual.params['items'] as List<Object?>? ?? const []))
              SizedBox(
                width: 84,
                height: 84,
                child: CustomPaint(painter: _ShapePainter('$sh')),
              ),
          ],
        ),
      'money' => Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final v
                in (visual.params['values'] as List<Object?>? ?? const []))
              _Money((v! as num).toInt()),
          ],
        ),
      'pictograph' => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final row
                in (visual.params['rows'] as List<Object?>? ?? const []))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text('${(row! as Map)['label']}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                    Expanded(
                      child: Wrap(spacing: 4, children: [
                        for (var i = 0;
                            i < ((row as Map)['count'] as num).toInt();
                            i++)
                          Text('${row['emoji']}',
                              style: const TextStyle(fontSize: 28)),
                      ]),
                    ),
                  ],
                ),
              ),
          ],
        ),
      'tally' => SizedBox(
          height: 70,
          width: 40.0 * ((_i('count') / 5).ceil()) + 20,
          child: CustomPaint(painter: _TallyPainter(_i('count'))),
        ),
      'grid' => ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: AspectRatio(
            aspectRatio: 1,
            child: _Grid(
              size: _i('size') == 0 ? 5 : _i('size'),
              start: (visual.params['start'] as List<Object?>?)?.cast<num>() ??
                  const [0, 0],
              target:
                  (visual.params['target'] as List<Object?>?)?.cast<num>() ??
                      const [4, 4],
              startEmoji: _s('start_emoji', '🐱'),
              targetEmoji: _s('target_emoji', '🥣'),
            ),
          ),
        ),
      'emoji' => Text(_s('emoji'), style: const TextStyle(fontSize: 96)),
      'text' => Text(
          _s('text', ''),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
        ),
      _ => const SizedBox.shrink(),
    };
    return Semantics(
      label: 'resim',
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8), child: child),
    );
  }
}

class _NumberHighlight extends StatelessWidget {
  const _NumberHighlight({required this.number, required this.pos});
  final String number;
  final int pos;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < number.length; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: number.length - 1 - i == pos
                  ? Kumbara.primary.withValues(alpha: 0.35)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Kumbara.ink.withValues(alpha: 0.2)),
            ),
            child: Text(number[i],
                style:
                    const TextStyle(fontSize: 40, fontWeight: FontWeight.w800)),
          ),
      ],
    );
  }
}

class _ShapePainter extends CustomPainter {
  _ShapePainter(this.shape);
  final String shape;

  static const _colors = {
    'ucgen': Color(0xFFE8794A),
    'kare': Color(0xFF4A7BD0),
    'dikdortgen': Color(0xFF2E9E6B),
    'daire': Color(0xFFF2A93B),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = (_colors[shape] ?? Colors.grey).withValues(alpha: 0.85);
    final stroke = Paint()
      ..color = Kumbara.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final w = size.width, h = size.height;
    final Path path;
    switch (shape) {
      case 'ucgen':
        path = Path()
          ..moveTo(w / 2, 4)
          ..lineTo(w - 4, h - 4)
          ..lineTo(4, h - 4)
          ..close();
      case 'kare':
        path = Path()..addRect(Rect.fromLTWH(8, 8, w - 16, h - 16));
      case 'dikdortgen':
        path = Path()..addRect(Rect.fromLTWH(2, h * 0.25, w - 4, h * 0.5));
      case 'daire':
        path = Path()..addOval(Rect.fromLTWH(6, 6, w - 12, h - 12));
      default:
        return;
    }
    canvas
      ..drawPath(path, fill)
      ..drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_ShapePainter old) => old.shape != shape;
}

/// Genel para çizimi: gerçek banknot tasarımı kopyalanmaz.
class _Money extends StatelessWidget {
  const _Money(this.value);
  final int value;

  static const _noteColors = {
    5: Color(0xFFB38BD6),
    10: Color(0xFFE57373),
    20: Color(0xFF66BB6A),
    50: Color(0xFFFFB74D),
    100: Color(0xFF64B5F6),
    200: Color(0xFFF48FB1),
  };

  @override
  Widget build(BuildContext context) {
    if (value == 1) {
      return Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE0C068),
          border:
              Border.all(color: Kumbara.ink.withValues(alpha: 0.5), width: 2),
        ),
        child: const Text('1 TL',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      );
    }
    return Container(
      width: 120,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _noteColors[value] ?? Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Kumbara.ink.withValues(alpha: 0.5), width: 2),
      ),
      child: Text('$value TL',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
    );
  }
}

class _TallyPainter extends CustomPainter {
  _TallyPainter(this.count);
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Kumbara.ink
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const top = 8.0, bottom = 62.0, gap = 7.0;
    var x = 10.0;
    for (var i = 0; i < count; i++) {
      final inGroup = i % 5;
      if (inGroup < 4) {
        final lx = x + inGroup * gap;
        canvas.drawLine(Offset(lx, top), Offset(lx, bottom), p);
      } else {
        canvas.drawLine(
            Offset(x - 4, bottom - 6), Offset(x + 3 * gap + 4, top + 6), p);
        x += 40;
      }
    }
  }

  @override
  bool shouldRepaint(_TallyPainter old) => old.count != count;
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.size,
    required this.start,
    required this.target,
    required this.startEmoji,
    required this.targetEmoji,
  });
  final int size;
  final List<num> start;
  final List<num> target;
  final String startEmoji;
  final String targetEmoji;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: size,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var y = 0; y < size; y++)
          for (var x = 0; x < size; x++)
            Container(
              margin: const EdgeInsets.all(1),
              alignment: Alignment.center,
              color: Colors.white,
              child: Text(
                x == start[0] && y == start[1]
                    ? startEmoji
                    : x == target[0] && y == target[1]
                        ? targetEmoji
                        : '',
                style: const TextStyle(fontSize: 26),
              ),
            ),
      ],
    );
  }
}
