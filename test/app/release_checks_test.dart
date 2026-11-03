import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ders_kumbarasi/app/speaker.dart';
import 'package:ders_kumbarasi/app/version.dart';
import 'package:ders_kumbarasi/ui/widgets/emoji_names.g.dart';
import 'package:ders_kumbarasi/ui/widgets/emoji_text.dart';

void main() {
  test('uygulama içindeki sürüm pubspec ile aynı', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final m = RegExp(r'^version:\s*([0-9.]+)\+', multiLine: true)
        .firstMatch(pubspec);
    expect(m, isNotNull);
    expect(appVersion, m![1]);
  });

  test('içerikteki her emojinin uygulamayla gelen görseli var', () {
    final missing = <String>{};
    for (final f in Directory('assets/content').listSync().whereType<File>()) {
      for (final g in f.readAsStringSync().characters) {
        final cp = g.runes.first;
        final pictographic = (cp >= 0x1F000 && cp <= 0x1FAFF) ||
            (cp >= 0x2600 && cp <= 0x27BF && g.runes.contains(0xFE0F));
        if (pictographic && emojiAsset(g) == null) missing.add(g);
      }
    }
    expect(missing, isEmpty,
        reason: 'python3 tools/emoji/fetch.py ile indirilmeli');
    for (final n in twemojiNames) {
      expect(File('assets/emoji/$n.svg').existsSync(), isTrue, reason: n);
    }
  });

  test('sesli okunacak metin emoji ve işaretlerden arınır', () {
    expect(speakable('Kaç 🍎 var?  Ali ___ gitti.\n\nSoru → ⭐⭐'),
        'Kaç var? Ali ... gitti. Soru');
    expect(speakable('🐢🐇'), '');
    expect(speechId(speakable('Harika! 🎉')), speechId('Harika!'));
  });
}
