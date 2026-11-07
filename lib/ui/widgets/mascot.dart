import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme.dart';

enum MascotMood { normal, celebrate, think, sleepy, teach }

/// Anka: Bilgelik Diyarı'nın rehberi, bilge ve biraz komik yaşlı kuş
/// (Zümrüdüanka'dan esinli). Hiçbir ifadede üzgün değil.
class Mascot extends StatelessWidget {
  const Mascot(
      {super.key, this.mood = MascotMood.normal, this.size = 120, this.label});
  final MascotMood mood;

  /// Genişlik (çizim kare).
  final double size;

  /// Ekran okuyucu açıklaması; verilmezse süs sayılır ve okunmaz.
  final String? label;

  static String asset(MascotMood m) => switch (m) {
        MascotMood.normal => 'assets/mascot/anka.svg',
        MascotMood.celebrate => 'assets/mascot/anka_kutlama.svg',
        MascotMood.think => 'assets/mascot/anka_dusunen.svg',
        MascotMood.sleepy => 'assets/mascot/anka_uykulu.svg',
        MascotMood.teach => 'assets/mascot/anka_ogreten.svg',
      };

  @override
  Widget build(BuildContext context) {
    final img = SvgPicture.asset(
      asset(mood),
      width: size,
      height: size,
      excludeFromSemantics: label == null,
      semanticsLabel: label,
    );
    final w = label == null ? ExcludeSemantics(child: img) : img;
    // Claude Design › Hareket: Anka yavaşça nefes alır (hareketi azaltta yok)
    return reduceMotion(context) ? w : _Breathe(child: w);
  }
}

class _Breathe extends StatefulWidget {
  const _Breathe({required this.child});
  final Widget child;

  @override
  State<_Breathe> createState() => _BreatheState();
}

class _BreatheState extends State<_Breathe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 3200))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Transform.translate(
            offset: Offset(0, -3 * math.sin(_c.value * math.pi)), child: child),
        child: widget.child,
      );
}

/// Claude Design › Hareket: sancak rüzgârda dalgalanır (hareketi azaltta
/// durur). Alt kenar (direk dibi) sabit kalır.
class Waving extends StatelessWidget {
  const Waving({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      reduceMotion(context) ? child : _Wave(child: child);
}

class _Wave extends StatefulWidget {
  const _Wave({required this.child});
  final Widget child;

  @override
  State<_Wave> createState() => _WaveState();
}

class _WaveState extends State<_Wave> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Transform(
          alignment: Alignment.bottomLeft,
          transform: Matrix4.skewY(0.05 * math.sin(_c.value * 2 * math.pi)),
          child: child,
        ),
        child: widget.child,
      );
}
