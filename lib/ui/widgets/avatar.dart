import 'package:flutter/material.dart';

import '../../data/progress_store.dart';

/// 12 hayvan avatarı (şimdilik baş harfli renkli daire; çizimler eklenince
/// yalnızca bu dosya değişir).
const avatarNames = [
  'Kirpi',
  'Tilki',
  'Kedi',
  'Köpek',
  'Panda',
  'Kurbağa',
  'Aslan',
  'Tavşan',
  'Kaplumbağa',
  'Ayı',
  'Yunus',
  'Sincap',
];

const _avatarColors = [
  (Color(0xFFFBE3CB), Color(0xFF7A3F0E)),
  (Color(0xFFDDE9FA), Color(0xFF234C82)),
  (Color(0xFFDDF4E2), Color(0xFF1F6B37)),
  (Color(0xFFEEDDF4), Color(0xFF5B2F70)),
  (Color(0xFFFBEFC6), Color(0xFF5E4500)),
  (Color(0xFFD5F0F4), Color(0xFF0B5966)),
];

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.index, this.size = 64, this.ring = 0});
  final int index;
  final double size;

  /// Seçili halka kalınlığı (turuncu).
  final double ring;

  static int of(ChildProfile p) => p.avatarIndex;

  @override
  Widget build(BuildContext context) {
    final i = index.clamp(0, avatarNames.length - 1);
    final (bg, fg) = _avatarColors[i % _avatarColors.length];
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: ring > 0
              ? [BoxShadow(color: const Color(0xFFE8892F), spreadRadius: ring)]
              : null,
        ),
        child: Text(
          avatarNames[i].characters.first,
          textScaler: TextScaler.noScaling,
          style: TextStyle(
              fontSize: size * .375, fontWeight: FontWeight.w900, color: fg),
        ),
      ),
    );
  }
}
