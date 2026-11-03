/// Oyun ekranlarının kâğıt-mürekkep paleti (Claude Design tasarımı gelene
/// kadar geçici; renkler tasarım brifindeki paletle aynı).
library;

import 'package:flutter/material.dart';

class G {
  static const paper = Color(0xFFF4EAD5);
  static const paper2 = Color(0xFFEADBC0);
  static const ink = Color(0xFF2B2320);
  static const inkSoft = Color(0xFF5C4E44);
  static const madder = Color(0xFFB8432F);
  static const indigo = Color(0xFF1F4E79);
  static const emerald = Color(0xFF2F7A5B);
  static const saffron = Color(0xFFE3A535);
  static const fog = Color(0xFF9AA6B2);
  static const fogLight = Color(0xFFC9D1D9);
  static const gold = Color(0xFFE8B84A);

  static const title = TextStyle(
      fontSize: 26, height: 32 / 26, fontWeight: FontWeight.w900, color: ink);
  static const sub = TextStyle(
      fontSize: 19, height: 25 / 19, fontWeight: FontWeight.w800, color: ink);
  static const body = TextStyle(fontSize: 17, height: 24 / 17, color: ink);
  static const soft = TextStyle(fontSize: 15, height: 21 / 15, color: inkSoft);
  static const kicker = TextStyle(
      fontSize: 13,
      letterSpacing: 1.2,
      fontWeight: FontWeight.w900,
      color: madder);
}

/// Parşömen yüzey: hafif koyu kenarlı kâğıt.
class Parchment extends StatelessWidget {
  const Parchment({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = G.paper,
    this.border = G.ink,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color border;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: border, width: 2.5),
          boxShadow: const [
            BoxShadow(color: Color(0x332B2320), offset: Offset(3, 4)),
          ],
        ),
        child: child,
      );
}
