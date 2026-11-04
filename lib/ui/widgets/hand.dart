/// El çizimi yüzeyler (Claude Design "Bilgelik Diyarı" bd.css karşılığı).
///
/// Tasarımda kenarlar SVG gürültü filtresiyle titretilir; burada aynı etkiyi
/// kenar yolunu düzgün, tohumlu bir dalgayla oynatarak veriyoruz. Yazı ve
/// içerik titremez, yalnızca kenar ve dolgu.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme.dart';

/// CSS'teki "a b c d / e f g h" köşe yarıçapları (sol üst, sağ üst, sağ alt,
/// sol alt; önce yatay sonra dikey).
class HandRadii {
  const HandRadii(this.h, this.v);
  final List<double> h;
  final List<double> v;

  static const el = HandRadii([16, 24, 14, 26], [24, 14, 26, 16]);
  static const kart = HandRadii([4, 10, 3, 12], [10, 3, 12, 4]);
  static const tabela = HandRadii([9, 15, 8, 17], [15, 8, 17, 9]);
  static const parsomen = HandRadii([6, 14, 5, 12], [12, 5, 14, 6]);
  static const levha = HandRadii([16, 9, 19, 7], [9, 17, 7, 15]);
  static const balon = HandRadii([26, 20, 28, 16], [20, 26, 16, 28]);
  static const tas = HandRadii([14, 8, 17, 6], [8, 15, 6, 13]);
  static const secim = HandRadii([12, 16, 10, 18], [12, 16, 10, 18]);

  /// Mühür: neredeyse yuvarlak, hafif yamuk (47% 53% 51% 49% / 53% 47% 52% 48%).
  static HandRadii blob(Size s) => HandRadii(
        [s.width * .47, s.width * .53, s.width * .51, s.width * .49],
        [s.height * .53, s.height * .47, s.height * .52, s.height * .48],
      );
}

/// Kenarı hafifçe titreyen yol.
Path handPath(Rect r, HandRadii radii,
    {int seed = 4, double wobble = 1.1, double step = 6}) {
  double c(double v, double max) => math.min(v, max);
  final hw = r.width / 2, hh = r.height / 2;
  final rr = RRect.fromRectAndCorners(
    r,
    topLeft: Radius.elliptical(c(radii.h[0], hw), c(radii.v[0], hh)),
    topRight: Radius.elliptical(c(radii.h[1], hw), c(radii.v[1], hh)),
    bottomRight: Radius.elliptical(c(radii.h[2], hw), c(radii.v[2], hh)),
    bottomLeft: Radius.elliptical(c(radii.h[3], hw), c(radii.v[3], hh)),
  );
  final base = Path()..addRRect(rr);
  if (wobble <= 0) return base;
  final rnd = math.Random(seed);
  final p1 = rnd.nextDouble() * 6.28, p2 = rnd.nextDouble() * 6.28;
  final p3 = rnd.nextDouble() * 6.28;
  final out = Path();
  for (final m in base.computeMetrics()) {
    final n = math.max(12, (m.length / step).round());
    for (var i = 0; i <= n; i++) {
      final d = m.length * i / n;
      final t = m.getTangentForOffset(d % m.length)!;
      final k = d / 23.0;
      final off = wobble *
          (.55 * math.sin(k + p1) +
              .3 * math.sin(k * 2.3 + p2) +
              .15 * math.sin(k * 5.1 + p3));
      final nrm = Offset(-t.vector.dy, t.vector.dx);
      final pt = t.position + nrm * off;
      if (i == 0) {
        out.moveTo(pt.dx, pt.dy);
      } else {
        out.lineTo(pt.dx, pt.dy);
      }
    }
    out.close();
  }
  return out;
}

/// Yüzey dokusu.
enum HandFill { duz, ahsap, tas, sisli }

/// Bir el çizimi yüzeyin görünümü.
class HandStyle {
  const HandStyle({
    this.radii = HandRadii.el,
    this.fill = K.kagit2,
    this.texture = HandFill.duz,
    this.border = K.murekkep,
    this.borderWidth = 2.5,
    this.shadows = const [],
    this.seed = 4,
    this.blob = false,
  });

  final HandRadii radii;
  final Color fill;
  final HandFill texture;
  final Color border;
  final double borderWidth;

  /// Düz (bulanıksız) gölgeler: (aşağı kayma, renk), içten dışa.
  final List<(double, Color)> shadows;
  final int seed;

  /// Mühür biçimi (yarıçaplar boyuta göre).
  final bool blob;

  HandStyle copyWith({
    Color? fill,
    Color? border,
    double? borderWidth,
    List<(double, Color)>? shadows,
    HandFill? texture,
  }) =>
      HandStyle(
        radii: radii,
        fill: fill ?? this.fill,
        texture: texture ?? this.texture,
        border: border ?? this.border,
        borderWidth: borderWidth ?? this.borderWidth,
        shadows: shadows ?? this.shadows,
        seed: seed,
        blob: blob,
      );

  // Tasarımdaki hazır yüzeyler
  static const el = HandStyle();
  static const kart = HandStyle(radii: HandRadii.kart, fill: K.kagit3);
  static const parsomen = HandStyle(
      radii: HandRadii.parsomen,
      fill: K.kagit3,
      shadows: [(3, Color(0x592B2320))],
      seed: 7);
  static const tabela = HandStyle(
      radii: HandRadii.tabela,
      fill: K.ahsap,
      texture: HandFill.ahsap,
      borderWidth: 3,
      shadows: [(5, K.ahsap2)],
      seed: 11);
  static const levha = HandStyle(
      radii: HandRadii.levha,
      fill: K.tas,
      texture: HandFill.tas,
      borderWidth: 3,
      shadows: [(4, K.tas2), (7, K.murekkep)],
      seed: 5);
  static const balon = HandStyle(radii: HandRadii.balon, fill: K.kagit3);
  static const tas = HandStyle(
      radii: HandRadii.tas,
      fill: K.tas,
      texture: HandFill.tas,
      borderWidth: 3,
      shadows: [(4, K.tas2), (6, K.murekkep)]);
  static const muhur = HandStyle(blob: true, fill: K.lacivert, seed: 9);
}

class HandPainter extends CustomPainter {
  HandPainter(this.style, {this.pressed = 0});
  final HandStyle style;

  /// 0..1: basılıyken gölge kısalır.
  final double pressed;

  @override
  void paint(Canvas canvas, Size size) {
    final s = style;
    final inset = s.borderWidth / 2;
    final rect = (Offset.zero & size).deflate(inset);
    final radii = s.blob ? HandRadii.blob(rect.size) : s.radii;
    final path = handPath(rect, radii,
        seed: s.seed, wobble: s.blob ? 1.4 : 1.1, step: s.blob ? 4 : 6);
    for (final (dy, c) in s.shadows.reversed) {
      final y = dy * (1 - pressed * .75);
      canvas.drawPath(path.shift(Offset(0, y)), Paint()..color = c);
    }
    canvas.drawPath(path, Paint()..color = s.fill);
    if (s.texture != HandFill.duz) {
      canvas.save();
      canvas.clipPath(path);
      _texture(canvas, rect, s.texture);
      canvas.restore();
    }
    if (s.blob) {
      // mühür: içte ince açık halka
      final ring = rect.deflate(5.5);
      canvas.drawPath(
          handPath(ring, HandRadii.blob(ring.size), seed: s.seed + 1, wobble: 1),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..color = const Color(0x99FBF5E8));
    }
    if (s.borderWidth > 0) {
      canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = s.borderWidth
            ..strokeJoin = StrokeJoin.round
            ..color = s.border);
    }
  }

  void _texture(Canvas canvas, Rect r, HandFill t) {
    switch (t) {
      case HandFill.ahsap:
        // repeating-linear-gradient(177deg, …): hafif eğik tahta damarları
        const bands = [
          (6.0, Color(0xFF8A5A2E)),
          (2.0, Color(0xFF80522A)),
          (7.0, Color(0xFF916136)),
          (1.0, Color(0xFF7A4D27)),
        ];
        canvas.save();
        canvas.translate(r.center.dx, r.center.dy);
        canvas.rotate(-3 * math.pi / 180);
        final w = r.width * 1.2, h = r.height * 1.4;
        var y = -h / 2;
        var i = 0;
        while (y < h / 2) {
          final (bh, c) = bands[i % bands.length];
          canvas.drawRect(
              Rect.fromLTWH(-w / 2, y, w, bh), Paint()..color = c);
          y += bh;
          i++;
        }
        canvas.restore();
      case HandFill.tas:
        final dark = Paint()..color = const Color(0x172B2320);
        final light = Paint()..color = const Color(0x66FFFFFF);
        for (var x = r.left; x < r.right; x += 11) {
          for (var y = r.top; y < r.bottom; y += 13) {
            canvas.drawCircle(Offset(x + 2.2, y + 3.9), 1.3, dark);
          }
        }
        for (var x = r.left; x < r.right; x += 17) {
          for (var y = r.top; y < r.bottom; y += 15) {
            canvas.drawCircle(Offset(x + 10.2, y + 10.5), 1.3, light);
          }
        }
      case HandFill.sisli:
        canvas.save();
        canvas.translate(r.left, r.top);
        canvas.rotate(28 * math.pi / 180);
        final a = Paint()..color = const Color(0xE6C9D1D9);
        final b = Paint()..color = const Color(0xE6B8C2CC);
        final span = r.width + r.height;
        for (var x = -span; x < span; x += 9) {
          canvas.drawRect(Rect.fromLTWH(x, -span, 7, span * 2), a);
          canvas.drawRect(Rect.fromLTWH(x + 7, -span, 2, span * 2), b);
        }
        canvas.restore();
      case HandFill.duz:
        break;
    }
  }

  @override
  bool shouldRepaint(HandPainter old) =>
      old.style != style || old.pressed != pressed;
}

/// El çizimi kutu: dolgu, doku, düz gölge ve titrek kenar.
class HandBox extends StatelessWidget {
  const HandBox({
    super.key,
    required this.child,
    this.style = HandStyle.el,
    this.padding = EdgeInsets.zero,
    this.pressed = false,
    this.constraints,
  });

  final Widget child;
  final HandStyle style;
  final EdgeInsetsGeometry padding;
  final bool pressed;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    final depth = style.shadows.isEmpty ? 0.0 : style.shadows.last.$1;
    final drop = pressed ? depth * .6 : 0.0;
    Widget box = CustomPaint(
      painter: HandPainter(style, pressed: pressed ? 1 : 0),
      child: Padding(padding: padding, child: child),
    );
    if (constraints != null) {
      box = ConstrainedBox(constraints: constraints!, child: box);
    }
    return Padding(
      padding: EdgeInsets.only(top: drop, bottom: depth - drop),
      child: box,
    );
  }
}

/// Kilim şeridi (yöresel desen): kök/safran, lacivert ya da zümrüt.
class Kilim extends StatelessWidget {
  const Kilim(
      {super.key, this.k1 = K.kok, this.k2 = K.safran, this.height = 16});
  const Kilim.lacivert({super.key, this.height = 16})
      : k1 = K.lacivert,
        k2 = K.kagit2;
  const Kilim.zumrut({super.key, this.height = 16})
      : k1 = K.zumrut,
        k2 = K.kagit2;
  final Color k1;
  final Color k2;
  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(painter: _KilimPainter(k1, k2)),
        ),
      );
}

class _KilimPainter extends CustomPainter {
  _KilimPainter(this.k1, this.k2);
  final Color k1;
  final Color k2;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = k2);
    final p = Paint()..color = k1;
    // baklava dizisi
    for (var x = -h; x < size.width + h; x += h) {
      final path = Path()
        ..moveTo(x, h / 2)
        ..lineTo(x + h / 2, 0)
        ..lineTo(x + h, h / 2)
        ..lineTo(x + h / 2, h)
        ..close();
      canvas.drawPath(path, p);
      canvas.drawCircle(
          Offset(x + h / 2, h / 2), h * .12, Paint()..color = k2);
    }
    final line = Paint()
      ..color = K.murekkep
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(0, 1), Offset(size.width, 1), line);
    canvas.drawLine(Offset(0, h - 1), Offset(size.width, h - 1), line);
  }

  @override
  bool shouldRepaint(_KilimPainter old) => old.k1 != k1 || old.k2 != k2;
}

/// Kâğıt dokusu: ekranın üstüne binen çok hafif lif gürültüsü.
class PaperGrain extends StatelessWidget {
  const PaperGrain({super.key});

  @override
  Widget build(BuildContext context) => const IgnorePointer(
        child: ExcludeSemantics(
          child: SizedBox.expand(child: CustomPaint(painter: _GrainPainter())),
        ),
      );
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(17);
    final pts = <Offset>[];
    final n = (size.width * size.height / 90).round().clamp(0, 20000);
    for (var i = 0; i < n; i++) {
      pts.add(Offset(rnd.nextDouble() * size.width,
          rnd.nextDouble() * size.height));
    }
    canvas.drawPoints(
        ui.PointMode.points,
        pts,
        Paint()
          ..color = const Color(0x142B2320)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_GrainPainter old) => false;
}
