/// Claude Design A08 İlk görev: sisli sınır köyü, sönmüş ocak, tepede küs
/// Karabulut. Anka ilk işi anlatır; düğme ilk dersi açar.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../game/hero_figure.dart';
import '../game/karabulut_svg.dart';
import '../game/year_end.dart';
import '../theme.dart';
import '../widgets/ikon.dart';
import '../widgets/kit.dart';
import '../widgets/mascot.dart';
import 'session_screen.dart';

class FirstQuestScreen extends StatelessWidget {
  const FirstQuestScreen({super.key, required this.subject, this.focusOutcome});
  final Subject subject;
  final String? focusOutcome;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final hero = app.progress?.game.hero;
    final topic = switch (subject) {
      Subject.matematik => 'sayı bilgisine',
      Subject.turkce => 'okuma yazma bilgisine',
      Subject.hayatBilgisi => 'çevremizi tanımaya',
      _ => '${subject.label} bilgisine',
    };
    final line = 'İlk işimiz köyün ateşini yakmak. '
        'Bunun için biraz $topic ihtiyacımız var.';
    return Scaffold(
      backgroundColor: const Color(0xFFE6E2D6),
      body: Stack(children: [
        const Positioned.fill(child: CustomPaint(painter: _VillagePainter())),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: Stack(clipBehavior: Clip.none, children: [
                  SpeechBubble(
                    child: Text.rich(
                      TextSpan(children: [
                        const TextSpan(
                            text: 'İlk işimiz köyün ateşini yakmak.\n'),
                        const TextSpan(text: 'Bunun için biraz '),
                        TextSpan(
                            text: topic,
                            style: const TextStyle(
                                color: Color(0xFF1F4E79),
                                fontWeight: FontWeight.w800)),
                        const TextSpan(text: ' ihtiyacımız var.'),
                      ]),
                      style: const TextStyle(fontSize: 21, height: 1.4),
                    ),
                  ),
                  Positioned(
                    right: -6,
                    top: -14,
                    child: ListenButton(
                        size: 52, iconSize: 24, onListen: () => app.say(line)),
                  ),
                ]),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) => Stack(children: [
                    Positioned(
                      left: 4,
                      top: c.maxHeight * 0.02,
                      child: const ExcludeSemantics(
                          child: KarabulutFigure(
                              hal: KarabulutHal.kus, size: 100, ground: false)),
                    ),
                    if (hero != null)
                      Positioned(
                        left: -6,
                        bottom: 70,
                        child: HeroFigure(
                            look: hero,
                            size: math.min(170, c.maxHeight * 0.42),
                            showCompanion: false),
                      ),
                    Positioned(
                      right: -6,
                      bottom: 90,
                      child: Mascot(
                          mood: MascotMood.teach,
                          size: math.min(180, c.maxHeight * 0.4),
                          label: 'Anka anlatıyor'),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 6,
                      child: Transform.rotate(
                        angle: -0.035,
                        child: const DkCard(
                          padding: EdgeInsets.fromLTRB(12, 8, 14, 10),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            IkonView(Ikon.mesale, size: 38),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('İLK GÖREV',
                                    style: TextStyle(
                                        fontFamily: K.display,
                                        fontSize: 13,
                                        letterSpacing: 0.8,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF9E3624))),
                                Text('Köyün ateşini yak',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: ChunkyButton(
                  key: const Key('first-quest-go'),
                  label: 'Ateşi yakalım',
                  kind: BtnKind.kok,
                  onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                          builder: (_) => SessionScreen(
                              subject: subject, focusOutcome: focusOutcome))),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

/// Gri dağlar, sisli köy evleri, sönmüş ocak.
class _VillagePainter extends CustomPainter {
  const _VillagePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 390, sy = size.height / 844;
    canvas.save();
    canvas.scale(sx, sy);
    final ink = Paint()
      ..color = const Color(0xFF5A4B42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;
    final mount = Path()
      ..moveTo(-10, 330)
      ..lineTo(60, 250)
      ..lineTo(120, 330)
      ..moveTo(90, 330)
      ..lineTo(170, 220)
      ..lineTo(250, 330)
      ..moveTo(230, 330)
      ..lineTo(320, 240)
      ..lineTo(410, 330);
    canvas.drawPath(mount, Paint()..color = const Color(0xFFC9D1D9));
    canvas.drawPath(mount, ink..color = const Color(0xFF9AA6B2));
    canvas.drawRect(const Rect.fromLTRB(-10, 330, 400, 844),
        Paint()..color = const Color(0xFFDCD6C6));
    ink.color = const Color(0xFF5A4B42);
    const houses = [
      [24.0, 420.0, 52.0, 40.0],
      [92.0, 400.0, 46.0, 36.0],
      [252.0, 404.0, 54.0, 42.0],
      [322.0, 424.0, 48.0, 38.0],
      [160.0, 380.0, 40.0, 30.0],
    ];
    for (final h in houses) {
      final x = h[0], y = h[1], w = h[2], hh = h[3];
      final body = Rect.fromLTWH(x, y, w, hh);
      canvas.drawRect(body, Paint()..color = const Color(0xFFB9C1C9));
      canvas.drawRect(body, ink);
      final roof = Path()
        ..moveTo(x - 6, y)
        ..lineTo(x + w / 2, y - hh * 0.7)
        ..lineTo(x + w + 6, y)
        ..close();
      canvas.drawPath(roof, Paint()..color = const Color(0xFF9AA6B2));
      canvas.drawPath(roof, ink);
      final door = Path()
        ..moveTo(x + w / 2 - 6, y + hh)
        ..lineTo(x + w / 2 - 6, y + hh - 14)
        ..quadraticBezierTo(x + w / 2, y + hh - 21, x + w / 2 + 6, y + hh - 14)
        ..lineTo(x + w / 2 + 6, y + hh);
      canvas.drawPath(door, ink);
    }
    // Sis bandı
    final fog = Path()
      ..moveTo(-30, 300)
      ..cubicTo(40, 270, 100, 320, 180, 290)
      ..cubicTo(250, 264, 320, 310, 420, 280)
      ..lineTo(420, 470)
      ..cubicTo(340, 450, 280, 490, 200, 470)
      ..cubicTo(120, 450, 60, 486, -30, 466)
      ..close();
    canvas.drawPath(fog, Paint()..color = const Color(0xB3C9D1D9));
    // Meydan ve sönmüş ocak
    final ground = Path()
      ..moveTo(-10, 600)
      ..cubicTo(80, 570, 300, 572, 400, 596)
      ..lineTo(400, 844)
      ..lineTo(-10, 844)
      ..close();
    canvas.drawPath(ground, Paint()..color = const Color(0xFFE4D3B2));
    final dark = Paint()
      ..color = const Color(0xFF2B2320)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawOval(Rect.fromCenter(center: const Offset(196, 604), width: 124, height: 36),
        Paint()..color = const Color(0xFF978E7E));
    for (var i = 0; i < 9; i++) {
      final a = i / 9 * math.pi * 2;
      final c = Offset(196 + math.cos(a) * 58, 606 + math.sin(a) * 16);
      final r = Rect.fromCenter(center: c, width: 18, height: 16);
      canvas.drawOval(r, Paint()..color = const Color(0xFFB3A892));
      canvas.drawOval(r, dark..strokeWidth = 2);
    }
    final logs = Paint()
      ..color = const Color(0xFF8A5A2E)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(160, 600), const Offset(230, 588), logs);
    canvas.drawLine(const Offset(166, 590), const Offset(228, 604), logs);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
