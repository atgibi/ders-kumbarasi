/// Sesli okuma. Önce uygulamaya gömülü, önceden seslendirilmiş kayıtları
/// (assets/audio) çalar; kayıt yoksa (ör. her seferinde farklı sayılarla üretilen
/// sorular) cihazın Türkçe metin okuma motoruna düşer. Cihazda Türkçe ses de
/// yoksa sessiz kalır; uygulama sessiz de çalışır.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

abstract class Speaker {
  Future<void> speak(String text);
  Future<void> stop();
  bool get available;
}

class NoopSpeaker implements Speaker {
  final List<String> spoken = [];
  @override
  Future<void> speak(String text) async => spoken.add(text);
  @override
  Future<void> stop() async {}
  @override
  bool get available => false;
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
  Future<void> speak(String text) async {
    await _init();
    if (!_available) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
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
  Future<void> speak(String text) async {
    final id = speechId(text);
    if ((await _manifest()).contains(id)) {
      try {
        await _tts.stop();
        await _player.stop();
        await _player.play(AssetSource('audio/$id.mp3'));
        return;
      } on Object {
        // kayıt çalınamazsa cihaz sesine düş
      }
    }
    await _player.stop().catchError((_) {});
    await _tts.speak(text);
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
