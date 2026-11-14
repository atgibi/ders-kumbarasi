/// Sınıf ses paketleri: ders sesleri uygulamaya gömülmez, çocuğun sınıfının
/// paketi GitHub Releases'tan bir kez indirilir ve cihazda saklanır
/// (bkz. tools/audio/speech.py pack). İnternet yoksa ya da indirme yarıda
/// kalırsa hiçbir şey bozulmaz; o sırada cihazın kendi sesi okur.
library;

import 'package:flutter/foundation.dart';

import 'audio_packs_web.dart' if (dart.library.io) 'audio_packs_io.dart'
    as impl;

/// Paketlerin adresi. CDN'e geçilirse yalnızca bu satır değişir.
const audioPackBase =
    'https://github.com/atgibi/ders-kumbarasi/releases/download/ses';

/// Bir sınıf paketinin cihazdaki durumu.
class AudioPackStatus {
  const AudioPackStatus(
      {required this.installed, this.count = 0, this.bytes = 0});
  final bool installed;
  final int count;
  final int bytes;

  static const none = AudioPackStatus(installed: false);
}

/// Süren indirme: hangi sınıf, ne kadarı indi (0..1, bilinmiyorsa null).
class AudioDownload {
  const AudioDownload(this.grade, this.fraction);
  final int grade;
  final double? fraction;
}

abstract class AudioPacks {
  /// Bu sınıfın paketi cihazda yoksa ya da eskiyse indirir. Hata olursa
  /// sessizce vazgeçer (bir sonraki açılışta yeniden dener).
  ///
  /// [wifiOnly]: mobil veride indirme yapılmaz. [force]: aynı sürüm
  /// yüklü olsa da yeniden indirir.
  Future<void> ensure(int grade, {bool wifiOnly = false, bool force = false});

  /// Kimliği verilen kaydın cihazdaki dosya yolu (yoksa null).
  Future<String?> pathFor(String id);

  /// Cihazdaki paketin durumu.
  Future<AudioPackStatus> status(int grade);

  /// Verilen sınıflar dışındaki paketleri siler (yer açmak için).
  Future<void> keepOnly(Set<int> grades);

  /// Süren indirme (yoksa null).
  ValueListenable<AudioDownload?> get downloading;
}

/// İndirme yapmayan paket deposu (testler ve web).
class NoAudioPacks implements AudioPacks {
  NoAudioPacks();
  final ValueNotifier<AudioDownload?> _d = ValueNotifier(null);
  @override
  Future<void> ensure(int grade,
      {bool wifiOnly = false, bool force = false}) async {}
  @override
  Future<String?> pathFor(String id) async => null;
  @override
  Future<AudioPackStatus> status(int grade) async => AudioPackStatus.none;
  @override
  Future<void> keepOnly(Set<int> grades) async {}
  @override
  ValueListenable<AudioDownload?> get downloading => _d;
}

AudioPacks createAudioPacks() => impl.createAudioPacks();
