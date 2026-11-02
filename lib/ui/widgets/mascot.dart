import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme.dart';

enum MascotMood { normal, celebrate, think }

/// Fındık: uygulamanın özgün sincap maskotu.
class Mascot extends StatelessWidget {
  const Mascot({super.key, this.mood = MascotMood.normal, this.size = 120});
  final MascotMood mood;
  final double size;

  static String asset(MascotMood m) => switch (m) {
        MascotMood.normal => 'assets/mascot/findik.svg',
        MascotMood.celebrate => 'assets/mascot/findik_kutlama.svg',
        MascotMood.think => 'assets/mascot/findik_dusunen.svg',
      };

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        asset(mood),
        width: size,
        height: size * 260 / 240,
        semanticsLabel: 'Fındık',
      );
}

/// Maskot ve yanında konuşma balonu.
class MascotSays extends StatelessWidget {
  const MascotSays({
    super.key,
    required this.text,
    this.mood = MascotMood.normal,
    this.size = 96,
    this.onTap,
  });

  final String text;
  final MascotMood mood;
  final double size;

  /// Balona dokunulunca (ör. sesli dinle).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Mascot(mood: mood, size: size),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Kumbara.line, width: 2),
              ),
              child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ),
        ),
      ],
    );
  }
}
