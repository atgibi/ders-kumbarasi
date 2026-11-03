import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum MascotMood { normal, celebrate, think, sleepy }

/// Fındık: uygulamanın özgün sincap maskotu. Hiçbir ifadede üzgün değil.
class Mascot extends StatelessWidget {
  const Mascot(
      {super.key, this.mood = MascotMood.normal, this.size = 120, this.label});
  final MascotMood mood;

  /// Genişlik (yükseklik 240:260 oranında).
  final double size;

  /// Ekran okuyucu açıklaması; verilmezse süs sayılır ve okunmaz.
  final String? label;

  static String asset(MascotMood m) => switch (m) {
        MascotMood.normal => 'assets/mascot/findik.svg',
        MascotMood.celebrate => 'assets/mascot/findik_kutlama.svg',
        MascotMood.think => 'assets/mascot/findik_dusunen.svg',
        MascotMood.sleepy => 'assets/mascot/findik_uykulu.svg',
      };

  @override
  Widget build(BuildContext context) {
    final img = SvgPicture.asset(
      asset(mood),
      width: size,
      height: size * 260 / 240,
      excludeFromSemantics: label == null,
      semanticsLabel: label,
    );
    return label == null ? ExcludeSemantics(child: img) : img;
  }
}
