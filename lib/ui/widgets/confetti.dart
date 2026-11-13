/// Kutlama konfetisi: ekranın üstünden bir kez yağar (yaklaşık 2,6 sn).
/// "Hareketi azalt" açıkken hiç çizilmez.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

class Confetti extends StatefulWidget {
  const Confetti({super.key, this.count = 90});
  final int count;

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _Piece {
  _Piece(math.Random r)
      : x = r.nextDouble(),
        delay = r.nextDouble() * .35,
        speed = .75 + r.nextDouble() * .6,
        sway = (r.nextDouble() - .5) * .22,
        phase = r.nextDouble() * 6.28,
        spin = 2 + r.nextDouble() * 6,
        size = 7 + r.nextDouble() * 7,
        round = r.nextInt(4) == 0,
        color = _colors[r.nextInt(_colors.length)];
  final double x, delay, speed, sway, phase, spin, size;
  final bool round;
  final Color color;

  static const _colors = [
    Color(0xFFE3A535),
    Color(0xFFB8432F),
    Color(0xFF1F4E79),
    Color(0xFF2F7A5B),
    Color(0xFF6E5A9C),
    Color(0xFFE8B84A),
  ];
}

class _ConfettiState extends State<Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2600));
  late final List<_Piece> _pieces = [
    for (var i = 0, r = math.Random(7); i < widget.count; i++) _Piece(r)
  ];
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started && !reduceMotion(context)) {
      _started = true;
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return const SizedBox.shrink();
    return IgnorePointer(
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(_pieces, _c.value),
          ),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t);
  final List<_Piece> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final paint = Paint();
    for (final p in pieces) {
      final u = (t - p.delay) / (1 - p.delay);
      if (u <= 0) continue;
      final y = -20 + (size.height + 60) * u * p.speed;
      if (y > size.height + 20) continue;
      final x =
          (p.x + p.sway * math.sin(p.phase + u * 6)) * size.width;
      // sona doğru solar
      paint.color = p.color.withValues(alpha: u > .75 ? (1 - u) * 4 : 1);
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(p.phase + u * p.spin);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size / 2.4, paint);
      } else {
        // dönerken incelen kâğıt şerit
        final w = p.size * (.35 + .65 * math.cos(u * p.spin * 2).abs());
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: Offset.zero, width: w, height: p.size * .55),
                const Radius.circular(1.5)),
            paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
