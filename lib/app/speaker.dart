/// Sesli okuma (cihazın Türkçe metin okuma motoru). Cihazda Türkçe ses
/// yoksa sessizce devre dışı kalır; uygulama sesli okuma olmadan da çalışır.
library;

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
