/// İçerikteki görsel tanımlarını çizer (resim dosyası gerekmez).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../theme.dart';
import 'emoji_text.dart';
import 'kit.dart';

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
                child: EmojiImage(e, size: size),
              ),
              if (crossed.contains(i))
                Text('✕',
                    style: TextStyle(
                        fontSize: size * 0.9,
                        color: K.again,
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
          children: [
            Expanded(
                child: DashedBox(
                    minHeight: 120,
                    child: Center(
                        child: _emojis(_s('emoji'), _i('a'), size: 34)))),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('ve',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: K.inkSoft)),
            ),
            Expanded(
                child: DashedBox(
                    minHeight: 120,
                    child: Center(
                        child: _emojis(_s('emoji'), _i('b'), size: 34)))),
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
                  border: Border.all(color: K.primary, width: 2),
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
                  color: K.primary,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: K.ink.withValues(alpha: 0.4)),
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
                      color: K.good,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ],
        ),
      'number_line' => _NumberLine(
          from: _i('from'),
          to: _i('to'),
          mark: visual.params['mark'] as num?,
          missing: visual.params['missing'] as num?,
        ),
      'number_highlight' =>
        _NumberHighlight(number: '${visual.params['number']}', pos: _i('pos')),
      'row' => Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e
                in (visual.params['items'] as List<Object?>? ?? const []))
              _RowItem('$e'),
          ],
        ),
      'compare_groups' => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: DashedBox(
                    minHeight: 120,
                    child:
                        Center(child: _emojis(_s('ea'), _i('a'), size: 34)))),
            const SizedBox(width: 10),
            Expanded(
                child: DashedBox(
                    minHeight: 120,
                    child:
                        Center(child: _emojis(_s('eb'), _i('b'), size: 34)))),
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
                          EmojiImage('${row['emoji']}', size: 28),
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
      'clock' => SizedBox(
          width: 170,
          height: 170,
          child: CustomPaint(painter: _ClockPainter(_i('h'), _i('m'))),
        ),
      'fraction' => SizedBox(
          width: 140,
          height: 140,
          child:
              CustomPaint(painter: _FractionPainter(_i('parts'), _i('shaded'))),
        ),
      'angle' => SizedBox(
          width: 200,
          height: 130,
          child: CustomPaint(painter: _AnglePainter(_i('deg'))),
        ),
      'area' => _AreaGrid(w: _i('w'), h: _i('h')),
      'emoji' => _BigEmoji(_s('emoji')),
      'text' => EmojiText(
          _s('text', ''),
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 40, fontWeight: FontWeight.w900, color: K.ink),
        ),
      _ => const SizedBox.shrink(),
    };
    return Semantics(
      image: true,
      label: describe(),
      child: ExcludeSemantics(
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8), child: child),
      ),
    );
  }

  /// Ekran okuyucu için görselin açıklaması.
  String describe() {
    String n(int k, String what) => '$k $what';
    return switch (visual.kind) {
      'objects' => n(_i('count'), 'nesne'),
      'objects2' => 'Solda ${_i('a')}, sağda ${_i('b')} nesne',
      'objects_crossed' =>
        '${_i('total')} nesne, ${_i('crossed')} tanesinin üstü çizili',
      'groups' => '${_i('groups')} grup, her grupta ${_i('each')} nesne',
      'blocks' => '${_i('tens')} onluk, ${_i('ones')} birlik blok',
      'compare_groups' => 'Bir grupta ${_i('a')}, diğerinde ${_i('b')} nesne',
      'clock' => 'Analog saat',
      'fraction' => '${_i('parts')} eş parçadan ${_i('shaded')} tanesi boyalı',
      'angle' => 'Bir açı',
      'area' => '${_i('w')} çarpı ${_i('h')} birim kare',
      'tally' => n(_i('count'), 'çetele çizgisi'),
      'money' => 'Para',
      'shapes' => 'Geometrik şekiller',
      'text' => _s('text', ''),
      'number_line' => '${_i('from')} ile ${_i('to')} arası sayı doğrusu'
          '${visual.params['mark'] != null ? ', ${visual.params['mark']} işaretli' : ''}'
          '${visual.params['missing'] != null ? ', bir sayı eksik' : ''}',
      _ => 'Resim',
    };
  }
}

/// Sayı doğrusu: kutucuklar, işaretli sayı safran, eksik sayı "?".
class _NumberLine extends StatelessWidget {
  const _NumberLine(
      {required this.from, required this.to, this.mark, this.missing});
  final int from;
  final int to;
  final num? mark;
  final num? missing;

  @override
  Widget build(BuildContext context) {
    final cells = [for (var i = from; i <= to; i++) i];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 6,
      children: [
        for (final v in cells)
          Container(
            width: 36,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: v == mark
                  ? K.reward
                  : v == missing
                      ? K.againBg
                      : K.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: v == mark ? K.rewardShade : K.line, width: 2),
            ),
            child: Text(v == missing ? '?' : '$v',
                style: const TextStyle(
                    fontSize: 19, fontWeight: FontWeight.w900, color: K.ink)),
          ),
      ],
    );
  }
}

class _RowItem extends StatelessWidget {
  const _RowItem(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final isEmoji = emojiAsset(text) != null ||
        text.runes.every((r) => r > 0x2000) && text.isNotEmpty;
    if (isEmoji && text.characters.length <= 3) {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        for (final g in text.characters) EmojiImage(g, size: 42),
      ]);
    }
    return Container(
      constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: text == '?' ? K.tint : K.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: text == '?' ? K.primary : K.line,
            width: text == '?' ? 3 : 2),
      ),
      child: EmojiText(text == '?' ? '' : text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 28, fontWeight: FontWeight.w900, color: K.ink)),
    );
  }
}

class _BigEmoji extends StatelessWidget {
  const _BigEmoji(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        children: [for (final g in text.characters) EmojiImage(g, size: 88)],
      );
}

class _NumberHighlight extends StatelessWidget {
  const _NumberHighlight({required this.number, required this.pos});
  final String number;
  final int pos;

  @override
  Widget build(BuildContext context) {
    // Milyonluk sayılar telefona sığmıyordu: gerekirse küçülür
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < number.length; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: number.length - 1 - i == pos
                  ? K.primary.withValues(alpha: 0.35)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: K.ink.withValues(alpha: 0.2)),
            ),
            child: Text(number[i],
                style:
                    const TextStyle(fontSize: 40, fontWeight: FontWeight.w800)),
          ),
      ],
    ),
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
    'besgen': Color(0xFF9B59B6),
    'altigen': Color(0xFF16A2B8),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = (_colors[shape] ?? Colors.grey).withValues(alpha: 0.85);
    final stroke = Paint()
      ..color = K.ink
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
      case 'besgen' || 'altigen':
        final n = shape == 'besgen' ? 5 : 6;
        final c = Offset(w / 2, h / 2);
        final rad = w / 2 - 5;
        path = Path();
        for (var i = 0; i < n; i++) {
          final a = -math.pi / 2 + i * 2 * math.pi / n;
          final pt = c + Offset(math.cos(a), math.sin(a)) * rad;
          i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
        }
        path.close();
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
          border: Border.all(color: K.ink.withValues(alpha: 0.5), width: 2),
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
        border: Border.all(color: K.ink.withValues(alpha: 0.5), width: 2),
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
      ..color = K.ink
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
              child: x == start[0] && y == start[1]
                  ? EmojiImage(startEmoji, size: 26)
                  : x == target[0] && y == target[1]
                      ? EmojiImage(targetEmoji, size: 26)
                      : null,
            ),
      ],
    );
  }
}

/// Akrep ve yelkovanlı analog saat.
class _ClockPainter extends CustomPainter {
  _ClockPainter(this.h, this.m);
  final int h;
  final int m;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 4;
    canvas.drawCircle(c, r, Paint()..color = Colors.white);
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..color = K.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5);
    for (var i = 1; i <= 12; i++) {
      final a = i * math.pi / 6 - math.pi / 2;
      final tp = TextPainter(
        text: TextSpan(
            text: '$i',
            style: const TextStyle(
                color: K.ink, fontSize: 17, fontWeight: FontWeight.w800)),
        textDirection: TextDirection.ltr,
      )..layout();
      final pos = c + Offset(math.cos(a), math.sin(a)) * (r - 18);
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }
    void hand(double angle, double len, double w, Color col) {
      final a = angle - math.pi / 2;
      canvas.drawLine(
        c,
        c + Offset(math.cos(a), math.sin(a)) * len,
        Paint()
          ..color = col
          ..strokeWidth = w
          ..strokeCap = StrokeCap.round,
      );
    }

    // Akrep (kısa, kalın): saat + dakikaya göre ilerler
    hand(((h % 12) + m / 60) * math.pi / 6, r * 0.5, 8, K.ink);
    // Yelkovan (uzun, ince)
    hand(m * math.pi / 30, r * 0.78, 5, K.primary);
    canvas.drawCircle(c, 6, Paint()..color = K.ink);
  }

  @override
  bool shouldRepaint(_ClockPainter old) => old.h != h || old.m != m;
}

/// Bütün, yarım, çeyrek: daire dilimleri.
class _FractionPainter extends CustomPainter {
  _FractionPainter(this.parts, this.shaded);
  final int parts;
  final int shaded;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final n = parts < 1 ? 1 : parts;
    final sweep = 2 * math.pi / n;
    for (var i = 0; i < n; i++) {
      final paint = Paint()..color = i < shaded ? K.primary : Colors.white;
      canvas.drawArc(
          rect.deflate(3), -math.pi / 2 + i * sweep, sweep, true, paint);
      canvas.drawArc(
          rect.deflate(3),
          -math.pi / 2 + i * sweep,
          sweep,
          true,
          Paint()
            ..color = K.ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3);
    }
  }

  @override
  bool shouldRepaint(_FractionPainter old) =>
      old.parts != parts || old.shaded != shaded;
}

class _AnglePainter extends CustomPainter {
  _AnglePainter(this.deg);
  final int deg;

  @override
  void paint(Canvas canvas, Size size) {
    final o = Offset(size.width * 0.35, size.height - 12);
    final len = size.height - 24;
    final line = Paint()
      ..color = K.ink
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final a = -deg * math.pi / 180;
    canvas
      ..drawLine(o, o + Offset(len * 1.2, 0), line)
      ..drawLine(o, o + Offset(math.cos(a), math.sin(a)) * len, line);
    final arc = Paint()
      ..color = K.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    if (deg == 90) {
      canvas.drawRect(Rect.fromLTWH(o.dx, o.dy - 24, 24, 24), arc);
    } else {
      canvas.drawArc(Rect.fromCircle(center: o, radius: 30), 0, a, false, arc);
    }
  }

  @override
  bool shouldRepaint(_AnglePainter old) => old.deg != deg;
}

class _AreaGrid extends StatelessWidget {
  const _AreaGrid({required this.w, required this.h});
  final int w;
  final int h;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var y = 0; y < h; y++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var x = 0; x < w; x++)
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: K.primary.withValues(alpha: 0.35),
                    border: Border.all(color: K.ink.withValues(alpha: 0.6)),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
