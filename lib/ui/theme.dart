import 'package:flutter/material.dart';

import '../app/app_state.dart';

class Kumbara {
  static const primary = Color(0xFFF2A93B); // kumbara turuncusu
  static const ink = Color(0xFF2B2A33);
  static const good = Color(0xFF2E9E6B);
  static const soft = Color(0xFFFFF6E8);
  static const tryAgain = Color(0xFF4A7BD0); // yanlışta kırmızı yok

  static const avatars = ['🦊', '🐱', '🐶', '🐼', '🐸', '🦁', '🐰', '🐢', '🦉', '🐬'];

  static ThemeData theme() {
    final scheme = ColorScheme.fromSeed(seedColor: primary, surface: soft);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: soft,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: ink),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ink),
        bodyLarge: TextStyle(fontSize: 20, color: ink, height: 1.35),
        bodyMedium: TextStyle(fontSize: 16, color: ink),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 64), // çocuk için büyük dokunma alanı
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}

/// AppState'i ağaç boyunca taşır ve değişince yeniden çizer.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
