/// Kahramanın geçici çizimi: kod ile çizilir (son çizimler gelene kadar).
/// Ten, saç, yol rengi, aşama (pelerin, omuzluk, altın kenar) yansır.
library;

import 'package:flutter/material.dart';

import '../../game/game_state.dart';
import '../../game/world.dart';
import '../widgets/emoji_text.dart';

const _ink = Color(0xFF2B2320);

class HeroFigure extends StatelessWidget {
  const HeroFigure({
    super.key,
    required this.look,
    this.stage = HeroStage.cirak,
    this.size = 160,
    this.showCompanion = true,
    this.semanticLabel,
  });

  final HeroLook look;
  final HeroStage stage;
  final double size;
  final bool showCompanion;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final path = look.heroPath;
    final fig = SizedBox(
      width: size,
      height: size * 1.25,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _HeroPainter(look, stage)),
          ),
          Positioned(
            right: size * 0.02,
            top: size * 0.62,
            child: EmojiImage(path.toolEmoji, size: size * 0.24),
          ),
          if (showCompanion)
            Positioned(
              left: -size * 0.04,
              bottom: 0,
              child: EmojiImage(path.companionEmoji, size: size * 0.28),
            ),
        ],
      ),
    );
    return Semantics(
      image: true,
      label: semanticLabel ??
          '${look.girl ? 'Kız' : 'Erkek'} ${path.name}, ${stage.label}',
      child: ExcludeSemantics(child: fig),
    );
  }
}

class _HeroPainter extends CustomPainter {
  _HeroPainter(this.look, this.stage);
  final HeroLook look;
  final HeroStage stage;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final skin = skinTones[look.skin];
    final hair = hairColors[look.hairColor];
    final tunic = look.heroPath.color;
    final line = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.022
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    Paint fill(Color c) => Paint()..color = c;

    final cx = w * 0.5;
    final headR = w * 0.17;
    final headC = Offset(cx, h * 0.24);

    // Pelerin (Yolcu ve üstü)
    if (stage.index >= HeroStage.yolcu.index) {
      final cape = Path()
        ..moveTo(cx - w * 0.2, h * 0.42)
        ..quadraticBezierTo(cx - w * 0.34, h * 0.7, cx - w * 0.26, h * 0.86)
        ..lineTo(cx + w * 0.26, h * 0.86)
        ..quadraticBezierTo(cx + w * 0.34, h * 0.7, cx + w * 0.2, h * 0.42)
        ..close();
      canvas.drawPath(cape, fill(const Color(0xFF1F4E79)));
      canvas.drawPath(cape, line);
    }

    // Bacaklar
    final legPaint = fill(look.girl ? skin : const Color(0xFF5A3A22));
    for (final dx in [-0.08, 0.08]) {
      final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(cx + w * dx - w * 0.045, h * 0.72, w * 0.09, h * 0.16),
          Radius.circular(w * 0.03));
      canvas.drawRRect(r, legPaint);
      canvas.drawRRect(r, line);
      // çizme
      final boot = RRect.fromRectAndRadius(
          Rect.fromLTWH(cx + w * dx - w * 0.06, h * 0.84, w * 0.12, h * 0.07),
          Radius.circular(w * 0.03));
      canvas.drawRRect(boot, fill(const Color(0xFF4A2E1C)));
      canvas.drawRRect(boot, line);
    }

    // Gövde: kız için etekli, erkek için düz tunik
    final body = Path()
      ..moveTo(cx - w * 0.15, h * 0.4)
      ..quadraticBezierTo(cx, h * 0.37, cx + w * 0.15, h * 0.4)
      ..lineTo(cx + (look.girl ? w * 0.24 : w * 0.18), h * 0.76)
      ..quadraticBezierTo(cx, h * 0.79, cx - (look.girl ? w * 0.24 : w * 0.18), h * 0.76)
      ..close();
    canvas.drawPath(body, fill(tunic));
    canvas.drawPath(body, line);

    // Kilim kenar (Kahraman ve üstünde altın)
    final trim = Paint()
      ..color = stage.index >= HeroStage.kahraman.index
          ? const Color(0xFFE3A535)
          : const Color(0xFFF4EAD5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02
      ..strokeJoin = StrokeJoin.round;
    final zig = Path();
    final y0 = h * 0.72;
    final x0 = cx - (look.girl ? w * 0.2 : w * 0.15);
    final x1 = cx + (look.girl ? w * 0.2 : w * 0.15);
    zig.moveTo(x0, y0);
    var up = true;
    for (var x = x0; x < x1; x += w * 0.04) {
      zig.lineTo(x + w * 0.02, y0 + (up ? -h * 0.018 : 0));
      up = !up;
    }
    canvas.drawPath(zig, trim);
    // Kemer
    canvas.drawLine(Offset(cx - w * 0.16, h * 0.56), Offset(cx + w * 0.16, h * 0.56),
        Paint()
          ..color = const Color(0xFF4A2E1C)
          ..strokeWidth = w * 0.035);
    canvas.drawCircle(Offset(cx, h * 0.56), w * 0.028, fill(const Color(0xFFE3A535)));

    // Omuzluk (Muhafız ve üstü)
    if (stage.index >= HeroStage.muhafiz.index) {
      for (final s in [-1.0, 1.0]) {
        final pad = Path()
          ..addOval(Rect.fromCenter(
              center: Offset(cx + s * w * 0.15, h * 0.42),
              width: w * 0.14,
              height: h * 0.06));
        canvas.drawPath(pad, fill(const Color(0xFF9AA6B2)));
        canvas.drawPath(pad, line);
      }
    }

    // Kollar
    for (final s in [-1.0, 1.0]) {
      final arm = Path()
        ..moveTo(cx + s * w * 0.14, h * 0.42)
        ..quadraticBezierTo(cx + s * w * 0.26, h * 0.5, cx + s * w * 0.25, h * 0.62);
      canvas.drawPath(
          arm,
          Paint()
            ..color = tunic
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.08
            ..strokeCap = StrokeCap.round);
      canvas.drawCircle(Offset(cx + s * w * 0.25, h * 0.63), w * 0.04, fill(skin));
      canvas.drawCircle(Offset(cx + s * w * 0.25, h * 0.63), w * 0.04, line);
    }

    // Boyun ve baş
    canvas.drawRect(
        Rect.fromCenter(center: Offset(cx, h * 0.37), width: w * 0.08, height: h * 0.05),
        fill(skin));

    // Saçın arkası (uzun, örgü)
    final hairP = fill(hair);
    if (look.hair == 1) {
      final back = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, h * 0.3), width: headR * 2.3, height: h * 0.26),
          Radius.circular(headR));
      canvas.drawRRect(back, hairP);
      canvas.drawRRect(back, line);
    } else if (look.hair == 2) {
      for (final s in [-1.0, 1.0]) {
        final braid = Path()
          ..moveTo(cx + s * headR * 0.9, h * 0.26)
          ..quadraticBezierTo(cx + s * headR * 1.4, h * 0.36, cx + s * headR * 1.1, h * 0.46);
        canvas.drawPath(
            braid,
            Paint()
              ..color = hair
              ..style = PaintingStyle.stroke
              ..strokeWidth = w * 0.06
              ..strokeCap = StrokeCap.round);
      }
    }
    if (look.hair == 4) {
      // Başörtüsü
      final scarf = Path()
        ..addOval(Rect.fromCenter(
            center: headC.translate(0, h * 0.01), width: headR * 2.5, height: headR * 2.6));
      canvas.drawPath(scarf, fill(const Color(0xFF2F7A5B)));
      canvas.drawPath(scarf, line);
    }

    canvas.drawCircle(headC, headR, fill(skin));
    canvas.drawCircle(headC, headR, line);

    // Saç üstü
    switch (look.hair) {
      case 4:
        final band = Path()
          ..addArc(Rect.fromCircle(center: headC, radius: headR * 1.02), 3.3, 2.8);
        canvas.drawPath(
            band,
            Paint()
              ..color = const Color(0xFF2F7A5B)
              ..style = PaintingStyle.stroke
              ..strokeWidth = headR * 0.35);
      case 5:
        // Şapka (yol renginde, tüylü)
        final hat = Path()
          ..moveTo(cx - headR * 1.25, h * 0.2)
          ..quadraticBezierTo(cx, h * 0.04, cx + headR * 1.25, h * 0.2)
          ..close();
        canvas.drawPath(hat, fill(tunic));
        canvas.drawPath(hat, line);
        final feather = Path()
          ..moveTo(cx + headR * 0.6, h * 0.13)
          ..quadraticBezierTo(cx + headR * 1.6, h * 0.02, cx + headR * 1.5, h * 0.12);
        canvas.drawPath(
            feather,
            Paint()
              ..color = const Color(0xFFE3A535)
              ..style = PaintingStyle.stroke
              ..strokeWidth = w * 0.03
              ..strokeCap = StrokeCap.round);
      case 3:
        for (var i = 0; i < 7; i++) {
          final a = 3.3 + i * 0.47;
          canvas.drawCircle(
              headC + Offset.fromDirection(a, headR * 0.92), headR * 0.32, hairP);
        }
      default:
        final cap = Path()
          ..addArc(Rect.fromCircle(center: headC, radius: headR * 1.04), 3.2, 3.0)
          ..close();
        canvas.drawPath(cap, hairP);
        canvas.drawPath(cap, line);
        // kakül
        final fringe = Path()
          ..moveTo(cx - headR * 0.9, headC.dy - headR * 0.25)
          ..quadraticBezierTo(cx - headR * 0.2, headC.dy - headR * 0.05,
              cx + headR * 0.4, headC.dy - headR * 0.45)
          ..quadraticBezierTo(cx + headR * 0.7, headC.dy - headR * 0.2,
              cx + headR * 0.95, headC.dy - headR * 0.25);
        canvas.drawPath(fringe, hairP);
    }

    // Yüz
    final eyeY = headC.dy + headR * 0.12;
    canvas.drawCircle(Offset(cx - headR * 0.38, eyeY), headR * 0.11, fill(_ink));
    canvas.drawCircle(Offset(cx + headR * 0.38, eyeY), headR * 0.11, fill(_ink));
    canvas.drawCircle(Offset(cx - headR * 0.6, eyeY + headR * 0.3), headR * 0.14,
        fill(const Color(0x55B8432F)));
    canvas.drawCircle(Offset(cx + headR * 0.6, eyeY + headR * 0.3), headR * 0.14,
        fill(const Color(0x55B8432F)));
    final smile = Path()
      ..moveTo(cx - headR * 0.25, eyeY + headR * 0.38)
      ..quadraticBezierTo(cx, eyeY + headR * 0.58, cx + headR * 0.25, eyeY + headR * 0.38);
    canvas.drawPath(
        smile,
        Paint()
          ..color = _ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.016
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_HeroPainter old) =>
      old.look.toJson().toString() != look.toJson().toString() ||
      old.stage != stage;
}
