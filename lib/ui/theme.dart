import 'package:flutter/material.dart';

import '../app/app_state.dart';

/// Tasarım token'ları (Tasarım Sistemi: 01 Renk, 02 Tipografi, 04 Boşluk).
/// Turuncu ve yeşil düğmelerde metin koyu (#2B2A33): beyaz yazı bu renklerde
/// 2,6:1 ve 2,9:1 kontrastta kalıyor. Mavi düğme #2E62A6 üzerinde beyaz.
class K {
  // Birincil
  static const primary = Color(0xFF8A5A2E);
  static const primaryShadow = Color(0xFF5E3A1B);
  static const label = Color(0xFFB8432F); // kremde küçük etiket, 5,6:1
  static const tint = Color(0xFFFBF5E8);
  static const peach = Color(0xFFEADBC0);
  static const peachInk = Color(0xFF5A4B42);

  // Doğru
  static const good = Color(0xFF2F7A5B);
  static const goodShadow = Color(0xFF1B4A36);
  static const goodBg = Color(0xFFE1EBDA);
  static const goodInk = Color(0xFF26664B);
  static const leafInk = Color(0xFF2F7A5B);

  // Tekrar (yanlışta kırmızı yok)
  static const again = Color(0xFF1F4E79);
  static const againStrong = Color(0xFF1F4E79);
  static const againShadow = Color(0xFF12304D);
  static const againBg = Color(0xFFE3EAF0);
  static const againInk = Color(0xFF1F4E79);
  static const againLine = Color(0xFFC9D1D9);
  static const againStripe = Color(0xFFDDE3EA);

  // Zemin ve çizgi
  static const bg = Color(0xFFF4EAD5);
  static const bgParent = Color(0xFFF7F1E6);
  static const card = Color(0xFFFBF5E8);
  static const line = Color(0xFFDCCFB8);
  static const lineSoft = Color(0xFFEFE4CE);
  static const dashed = Color(0xFFB9AC94);
  static const locked = Color(0xFFE7E2D7);
  static const lockedShade = Color(0xFF8C8178);
  static const stone = Color(0xFFDDD5C4);
  static const closeBg = Color(0xFFEADBC0);
  static const toggleOff = Color(0xFFCFC4B0);
  static const keyShadow = Color(0xFFB3A892);

  // Metin
  static const ink = Color(0xFF2B2320);
  static const ink2 = Color(0xFF5A4B42);
  static const inkSoft = Color(0xFF5A4B42);
  static const inkMuted = Color(0xFF5F554D);

  // Ödül
  static const reward = Color(0xFFE3A535);
  static const rewardShade = Color(0xFFB07F1E);
  static const rewardBg = Color(0xFFF6E7C1);
  static const rewardLine = Color(0xFFE3C77A);
  static const rewardInk = Color(0xFF4A3A00);
  static const rewardChip = Color(0xFFF2D492);
  static const rewardChipInk = Color(0xFF5E4500);
  static const hintShadow = Color(0xFFE9D488);
  static const hintInk = Color(0xFF6B4E00);

  // Işık (eski adıyla nut)
  static const nut = Color(0xFF8A5A2E);
  static const nutInk = Color(0xFF5E3A1B);

  // Aile etkinliği
  static const family = Color(0xFFEEDDF4);
  static const familyInk = Color(0xFF5B2F70);
  static const familyBg = Color(0xFFF4EAF8);
  static const familyIcon = Color(0xFF7D3C98);
  static const homeTip = Color(0xFF6E3A87);

  // Gece (sessiz saat)
  static const night = Color(0xFF1F2A3A);
  static const nightKick = Color(0xFFC9D3E6);
  static const nightSoft = Color(0xFFDCE3F0);

  // Dal (seri)
  static const branch = Color(0xFF8A5A2E);

  /// Ünite renkleri, yolda sırayla.
  static const units = [
    Color(0xFFA8552B),
    Color(0xFF5E7A3A),
    Color(0xFFD9A441),
    Color(0xFF6E5A9C),
    Color(0xFF2E7D8A),
    Color(0xFF1F4E79),
    Color(0xFFB8432F),
    Color(0xFF2F7A5B),
    Color(0xFF8A5A2E),
  ];
  static const unitShades = [
    Color(0xFF6B3216),
    Color(0xFF3E5226),
    Color(0xFF9A7124),
    Color(0xFF4A3C6B),
    Color(0xFF1C545D),
    Color(0xFF12304D),
    Color(0xFF7E2B1D),
    Color(0xFF1B4A36),
    Color(0xFF5E3A1B),
  ];

  // Köşe yuvarlama
  static const rSm = 10.0;
  static const rMd = 16.0;
  static const rLg = 22.0;

  /// Gövde: Andika (çocukların okuması için tasarlanmış harfler).
  static const font = 'Andika';

  /// Başlık ve sayılar: Fraunces (yumuşak, hafif oynak serif).
  static const display = 'Fraunces';

  /// El yazısı notlar ve mektuplar: Shantell Sans.
  static const hand = 'Shantell';

  // Tasarım belirteçleri (Claude Design: kâğıt, mürekkep, kök boya)
  static const kagit = Color(0xFFF4EAD5);
  static const kagit2 = Color(0xFFEADBC0);
  static const kagit3 = Color(0xFFFBF5E8);
  static const murekkep = Color(0xFF2B2320);
  static const murekkep2 = Color(0xFF5A4B42);
  static const kok = Color(0xFFB8432F);
  static const kokKoyu = Color(0xFF9E3624);
  static const lacivert = Color(0xFF1F4E79);
  static const zumrut = Color(0xFF2F7A5B);
  static const zumrutKoyu = Color(0xFF26664B);
  static const safran = Color(0xFFE3A535);
  static const sis = Color(0xFF9AA6B2);
  static const sis2 = Color(0xFFC9D1D9);
  static const ahsap = Color(0xFF8A5A2E);
  static const ahsap2 = Color(0xFF5E3A1B);
  static const tas = Color(0xFFDDD5C4);
  static const tas2 = Color(0xFFB3A892);

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
        selectionColor: Color(0x55E3A535),
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
        overlayColor: Color(0x22E3A535),
        trackHeight: 6,
      ),
    );
  }
}

/// Metin stilleri (Tipografi ölçeği).
class T {
  static const _f = K.font;
  static const title = TextStyle(
      fontFamily: K.display,
      fontSize: 28,
      height: 34 / 28,
      fontWeight: FontWeight.w800,
      color: K.ink);
  static const hero = TextStyle(
      fontFamily: K.display,
      fontSize: 34,
      height: 40 / 34,
      fontWeight: FontWeight.w800,
      color: K.ink);
  static const big = TextStyle(
      fontFamily: K.display,
      fontSize: 30,
      height: 36 / 30,
      fontWeight: FontWeight.w800,
      color: K.ink);
  static const question = TextStyle(
      fontFamily: K.display,
      fontSize: 24,
      height: 1.25,
      fontWeight: FontWeight.w800,
      color: K.ink);
  static const sub = TextStyle(
      fontFamily: K.display,
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
      fontFamily: K.display,
      fontSize: 21,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
      color: K.ink);

  // Veli alanı
  static const pTitle = TextStyle(
      fontFamily: K.display,
      fontSize: 21,
      fontWeight: FontWeight.w600,
      color: K.ink);
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
