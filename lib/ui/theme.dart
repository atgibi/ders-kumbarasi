import 'package:flutter/material.dart';

import '../app/app_state.dart';

/// Tasarım token'ları (Tasarım Sistemi: 01 Renk, 02 Tipografi, 04 Boşluk).
/// Turuncu ve yeşil düğmelerde metin koyu (#2B2A33): beyaz yazı bu renklerde
/// 2,6:1 ve 2,9:1 kontrastta kalıyor. Mavi düğme #2E62A6 üzerinde beyaz.
class K {
  // Birincil
  static const primary = Color(0xFFE8892F);
  static const primaryShadow = Color(0xFFB8692B);
  static const label = Color(0xFF95521A); // kremde küçük etiket, 5,6:1
  static const tint = Color(0xFFFFF1E1);
  static const peach = Color(0xFFFBE3CB);
  static const peachInk = Color(0xFF7A3F0E);

  // Doğru
  static const good = Color(0xFF3BAA5C);
  static const goodShadow = Color(0xFF2B8446);
  static const goodBg = Color(0xFFDDF4E2);
  static const goodInk = Color(0xFF1F6B37);
  static const leafInk = Color(0xFF23743C);

  // Tekrar (yanlışta kırmızı yok)
  static const again = Color(0xFF3F7FD0);
  static const againStrong = Color(0xFF2E62A6);
  static const againShadow = Color(0xFF1F4A80);
  static const againBg = Color(0xFFDDE9FA);
  static const againInk = Color(0xFF234C82);
  static const againLine = Color(0xFFB9CFEE);
  static const againStripe = Color(0xFFCBDDF5);

  // Zemin ve çizgi
  static const bg = Color(0xFFFFF9F1);
  static const bgParent = Color(0xFFF6F3EE);
  static const card = Color(0xFFFFFFFF);
  static const line = Color(0xFFE6DED3);
  static const lineSoft = Color(0xFFF1EBE3);
  static const dashed = Color(0xFFD8CDBE);
  static const locked = Color(0xFFD9D4CC);
  static const lockedShade = Color(0xFFBDB7AE);
  static const stone = Color(0xFFEFEBE5);
  static const closeBg = Color(0xFFF3EEE7);
  static const toggleOff = Color(0xFFCFC6B9);
  static const keyShadow = Color(0xFFE0D8CC);

  // Metin
  static const ink = Color(0xFF2B2A33);
  static const ink2 = Color(0xFF4A4952);
  static const inkSoft = Color(0xFF6B6A75);
  static const inkMuted = Color(0xFF5E5D66);

  // Ödül
  static const reward = Color(0xFFF2C94C);
  static const rewardShade = Color(0xFFC9A227);
  static const rewardBg = Color(0xFFFFF6D9);
  static const rewardLine = Color(0xFFEBD58A);
  static const rewardInk = Color(0xFF4A3A00);
  static const rewardChip = Color(0xFFFBEFC6);
  static const rewardChipInk = Color(0xFF5E4500);
  static const hintShadow = Color(0xFFE9D488);
  static const hintInk = Color(0xFF6B4E00);

  // Işık (eski adıyla nut)
  static const nut = Color(0xFF8A5326);
  static const nutInk = Color(0xFF6E3F17);

  // Aile etkinliği
  static const family = Color(0xFFEEDDF4);
  static const familyInk = Color(0xFF5B2F70);
  static const familyBg = Color(0xFFF4EAF8);
  static const familyIcon = Color(0xFF7D3C98);
  static const homeTip = Color(0xFF6E3A87);

  // Gece (sessiz saat)
  static const night = Color(0xFF22304A);
  static const nightKick = Color(0xFFC9D3E6);
  static const nightSoft = Color(0xFFDCE3F0);

  // Dal (seri)
  static const branch = Color(0xFFA9794A);

  /// Ünite renkleri, yolda sırayla.
  static const units = [
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
  static const unitShades = [
    Color(0xFFB8692B),
    Color(0xFF2E62A6),
    Color(0xFF2B8446),
    Color(0xFF7A4291),
    Color(0xFFB07F06),
    Color(0xFF117C8D),
    Color(0xFFA83F3C),
    Color(0xFF526A2B),
    Color(0xFF6B5237),
  ];

  // Köşe yuvarlama
  static const rSm = 10.0;
  static const rMd = 16.0;
  static const rLg = 22.0;

  static const font = 'Nunito';

  static ThemeData theme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      surface: bg,
      onSurface: ink,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: font,
      scaffoldBackgroundColor: bg,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: ink,
        selectionColor: Color(0x55E8892F),
        selectionHandleColor: primary,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
            fontSize: 28, height: 34 / 28, fontWeight: FontWeight.w900),
        titleLarge: TextStyle(
            fontSize: 21, height: 28 / 21, fontWeight: FontWeight.w800),
        bodyLarge: TextStyle(fontSize: 19, height: 26 / 19),
        bodyMedium: TextStyle(fontSize: 16, height: 22 / 16),
      ).apply(bodyColor: ink, displayColor: ink, fontFamily: font),
      sliderTheme: const SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: line,
        thumbColor: primary,
        overlayColor: Color(0x22E8892F),
        trackHeight: 6,
      ),
    );
  }
}

/// Metin stilleri (Tipografi ölçeği).
class T {
  static const _f = K.font;
  static const title = TextStyle(
      fontFamily: _f,
      fontSize: 28,
      height: 34 / 28,
      fontWeight: FontWeight.w900,
      color: K.ink);
  static const hero = TextStyle(
      fontFamily: _f,
      fontSize: 34,
      height: 40 / 34,
      fontWeight: FontWeight.w900,
      color: K.ink);
  static const big = TextStyle(
      fontFamily: _f,
      fontSize: 30,
      height: 36 / 30,
      fontWeight: FontWeight.w900,
      color: K.ink);
  static const question = TextStyle(
      fontFamily: _f,
      fontSize: 24,
      height: 1.25,
      fontWeight: FontWeight.w800,
      color: K.ink);
  static const sub = TextStyle(
      fontFamily: _f,
      fontSize: 21,
      height: 28 / 21,
      fontWeight: FontWeight.w800,
      color: K.ink);
  static const body =
      TextStyle(fontFamily: _f, fontSize: 19, height: 26 / 19, color: K.ink);
  static const bodySoft = TextStyle(
      fontFamily: _f, fontSize: 19, height: 26 / 19, color: K.inkSoft);
  static const strong = TextStyle(
      fontFamily: _f, fontSize: 17, fontWeight: FontWeight.w800, color: K.ink);
  static const help = TextStyle(
      fontFamily: _f, fontSize: 15, height: 20 / 15, color: K.inkSoft);
  static const kicker = TextStyle(
      fontFamily: _f,
      fontSize: 15,
      height: 20 / 15,
      fontWeight: FontWeight.w900,
      letterSpacing: .6,
      color: K.label);
  static const kickerSm = TextStyle(
      fontFamily: _f,
      fontSize: 13,
      fontWeight: FontWeight.w900,
      letterSpacing: .6,
      color: K.label);
  static const button = TextStyle(
      fontFamily: _f,
      fontSize: 18,
      fontWeight: FontWeight.w900,
      letterSpacing: .8,
      color: K.ink);

  // Veli alanı
  static const pTitle = TextStyle(
      fontFamily: _f, fontSize: 21, fontWeight: FontWeight.w800, color: K.ink);
  static const pBody =
      TextStyle(fontFamily: _f, fontSize: 16, height: 22 / 16, color: K.ink);
  static const pBodySoft =
      TextStyle(fontFamily: _f, fontSize: 16, height: 22 / 16, color: K.ink2);
  static const pStrong = TextStyle(
      fontFamily: _f, fontSize: 16, fontWeight: FontWeight.w800, color: K.ink);
  static const pSmall =
      TextStyle(fontFamily: _f, fontSize: 14, height: 18 / 14, color: K.ink2);
  static const pSection = TextStyle(
      fontFamily: _f,
      fontSize: 14,
      fontWeight: FontWeight.w800,
      letterSpacing: .4,
      color: K.inkSoft);
  static const code = TextStyle(
      fontFamily: _f,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: .3,
      color: K.inkSoft);
}

/// Türkçe büyük harf: i -> İ, ı -> I (Dart'ın toUpperCase'i dile duyarsız).
String trUpper(String s) =>
    s.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();

/// Türkçe küçük harf: İ -> i, I -> ı.
String trLower(String s) =>
    s.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();

/// AppState'i ağaç boyunca taşır ve değişince yeniden çizer.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

/// Hareketi azalt: cihaz ayarı ya da veli ayarı.
bool reduceMotion(BuildContext context) =>
    MediaQuery.of(context).disableAnimations ||
    (context
            .getInheritedWidgetOfExactType<AppScope>()
            ?.notifier
            ?.settings
            .reduceMotion ??
        false);
