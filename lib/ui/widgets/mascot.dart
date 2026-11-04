import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    return label == null ? ExcludeSemantics(child: img) : img;
  }
}
