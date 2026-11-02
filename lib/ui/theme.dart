import 'package:flutter/material.dart';

import '../app/app_state.dart';

class Kumbara {
  static const primary = Color(0xFFE8892F); // Fındık turuncusu
  static const primaryDark = Color(0xFFB8692B);
  static const ink = Color(0xFF2B2A33);
  static const inkSoft = Color(0xFF6B6A75);
  static const good = Color(0xFF3BAA5C);
  static const goodDark = Color(0xFF2B8446);
  static const goodBg = Color(0xFFDDF4E2);
  static const tryAgain = Color(0xFF3F7FD0); // yanlışta kırmızı yok
  static const tryAgainDark = Color(0xFF2E62A6);
  static const tryAgainBg = Color(0xFFDDE9FA);
  static const soft = Color(0xFFFFF9F1);
  static const line = Color(0xFFE6DED3);
  static const locked = Color(0xFFD9D4CC);
  static const nut = Color(0xFF8A5326);

  static const avatars = ['🦊', '🐱', '🐶', '🐼', '🐸', '🦁', '🐰', '🐢', '🦉', '🐬'];

  /// Ders renkleri (yol ekranındaki ünite bantları).
  static const unitColors = [
    Color(0xFFE8892F),
    Color(0xFF3F7FD0),
    Color(0xFF3BAA5C),
    Color(0xFF9B59B6),
    Color(0xFFE5A50A),
    Color(0xFF16A2B8),
    Color(0xFFD9534F),
    Color(0xFF6D8B3A),
    Color(0xFF8E6C4A),
  ];

  static ThemeData theme() {
    final scheme = ColorScheme.fromSeed(seedColor: primary, surface: soft);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: soft,
      appBarTheme: const AppBarTheme(backgroundColor: soft, surfaceTintColor: Colors.transparent),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: ink),
        titleLarge: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: ink),
        bodyLarge: TextStyle(fontSize: 19, color: ink, height: 1.35),
        bodyMedium: TextStyle(fontSize: 16, color: ink),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 56),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

/// Türkçe büyük harf: i -> İ, ı -> I (Dart'ın toUpperCase'i dile duyarsız).
String trUpper(String s) =>
    s.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();

/// AppState'i ağaç boyunca taşır ve değişince yeniden çizer.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
