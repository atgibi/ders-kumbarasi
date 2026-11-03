/// Sesli okuma. Önce uygulamaya gömülü, önceden seslendirilmiş kayıtları
/// (assets/audio) çalar; kayıt yoksa (ör. her seferinde farklı sayılarla üretilen
/// sorular) cihazın Türkçe metin okuma motoruna düşer. Cihazda Türkçe ses de
/// yoksa sessiz kalır; uygulama sessiz de çalışır.
library;

import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

abstract class Speaker {
  /// [slow]: kaplumbağa düğmesi, daha yavaş okuma.
  Future<void> speak(String text, {bool slow = false});
  Future<void> stop();
  bool get available;

  /// Cihazda kullanılabilir bir Türkçe ses (ya da kayıt) var mı? Gerekirse
  /// metin okuma motorunu yoklar.
  Future<bool> checkAvailable();
}

class NoopSpeaker implements Speaker {
  final List<String> spoken = [];
  @override
  Future<void> speak(String text, {bool slow = false}) async =>
      spoken.add(speakable(text));
  @override
  Future<void> stop() async {}
  @override
  bool get available => false;
  @override
  Future<bool> checkAvailable() async => false;
}

const _symbolRanges = [
  [0x200D, 0x200D],
  [0x2190, 0x21FF],
  [0x2300, 0x23FF],
  [0x25A0, 0x25FF],
  [0x2600, 0x27BF],
  [0x2900, 0x297F],
  [0x2B00, 0x2BFF],
  [0xFE00, 0xFE0F],
  [0x1F000, 0x1FAFF],
  [0xE0000, 0xE007F],
];

bool _isSymbol(int cp) {
  for (final r in _symbolRanges) {
    if (cp >= r[0] && cp <= r[1]) return true;
  }
  return false;
}

/// Sesli okunacak metin: emoji ve işaretler atılır, boşluk çizgileri
/// duraklamaya çevrilir (tools/audio/speech.py ile aynı kural).
String speakable(String text) {
  final b = StringBuffer();
  for (final cp in text.runes) {
    if (_isSymbol(cp)) {
      b.write(' ');
    } else {
      b.writeCharCode(cp);
    }
  }
  return b
      .toString()
      .replaceAll(RegExp(r'_{2,}'), ' ... ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

int _fnv32(Uint8List data, int offset) {
  var h = offset;
  for (final b in data) {
    h ^= b;
    // h * 16777619 mod 2^32, web'de de taşmadan: 16777619 = 2^24 + 403
    h = (((h << 24) & 0xFFFFFFFF) + h * 403) & 0xFFFFFFFF;
  }
  return h;
}

/// tools/audio/speech.py ile aynı kimlik: iki 32 bitlik FNV-1a.
String speechId(String text) {
  final data = Uint8List.fromList(utf8.encode(text.trim()));
  String hex(int v) => v.toRadixString(16).padLeft(8, '0');
  return '${hex(_fnv32(data, 0x811C9DC5))}${hex(_fnv32(data, 0x01000193))}';
}

class TtsSpeaker implements Speaker {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;
  bool _available = false;

  @override
  bool get available => _available;

  @override
  Future<bool> checkAvailable() async {
    await _init();
    return _available;
  }

  Future<void> _init() async {
    if (_ready) return;
    _ready = true;
    try {
      final ok = await _tts.isLanguageAvailable('tr-TR');
      _available = ok == true || ok == 1;
      if (_available) {
        await _tts.setLanguage('tr-TR');
        await _tts.setSpeechRate(0.45); // çocuklar için yavaş
        await _tts.setPitch(1.05);
        await _tts.awaitSpeakCompletion(false);
      }
    } on Object {
      _available = false;
    }
  }

  @override
  Future<void> speak(String text, {bool slow = false}) async {
    await _init();
    if (!_available) return;
    final t = speakable(text);
    if (t.isEmpty) return;
    try {
      await _tts.stop();
      await _tts.setSpeechRate(slow ? 0.3 : 0.45);
      await _tts.speak(t);
    } on Object {
      // sesli okuma hatası uygulamayı durdurmamalı
    }
  }

  @override
  Future<void> stop() async {
    if (!_available) return;
    try {
      await _tts.stop();
    } on Object {
      // yok say
    }
  }
}

/// Kayıtlı ses + cihaz sesi yedeği.
class HybridSpeaker implements Speaker {
  HybridSpeaker({TtsSpeaker? fallback}) : _tts = fallback ?? TtsSpeaker();

  final TtsSpeaker _tts;
  final AudioPlayer _player = AudioPlayer();
  Set<String>? _recorded;

  Future<Set<String>> _manifest() async {
    if (_recorded != null) return _recorded!;
    try {
      final raw = await rootBundle.loadString('assets/audio/manifest.json');
      _recorded = (jsonDecode(raw) as List<Object?>).cast<String>().toSet();
    } on Object {
      _recorded = {};
    }
    return _recorded!;
  }

  @override
  bool get available => (_recorded?.isNotEmpty ?? false) || _tts.available;

  @override
  Future<bool> checkAvailable() async =>
      (await _manifest()).isNotEmpty || await _tts.checkAvailable();

  @override
  Future<void> speak(String text, {bool slow = false}) async {
    final t = speakable(text);
    if (t.isEmpty) return;
    final id = speechId(t);
    if ((await _manifest()).contains(id)) {
      try {
        await _tts.stop();
        await _player.stop();
        await _player.setPlaybackRate(slow ? 0.75 : 1.0);
        await _player.play(AssetSource('audio/$id.mp3'));
        return;
      } on Object {
        // kayıt çalınamazsa cihaz sesine düş
      }
    }
    try {
      await _player.stop();
    } on Object {
      // yok say
    }
    await _tts.speak(t, slow: slow);
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
    } on Object {
      // yok say
    }
    await _tts.stop();
  }
}
