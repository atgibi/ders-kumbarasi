/// Sınıf ses paketleri: ders sesleri uygulamaya gömülmez, çocuğun sınıfının
/// paketi GitHub Releases'tan bir kez indirilir ve cihazda saklanır
/// (bkz. tools/audio/speech.py pack). İnternet yoksa ya da indirme yarıda
/// kalırsa hiçbir şey bozulmaz; o sırada cihazın kendi sesi okur.
library;

import 'audio_packs_web.dart' if (dart.library.io) 'audio_packs_io.dart'
    as impl;

/// Paketlerin adresi. CDN'e geçilirse yalnızca bu satır değişir.
const audioPackBase =
    'https://github.com/atgibi/ders-kumbarasi/releases/download/ses';

abstract class AudioPacks {
  /// Bu sınıfın paketi cihazda yoksa ya da eskiyse indirir. Hata olursa
  /// sessizce vazgeçer (bir sonraki açılışta yeniden dener).
  Future<void> ensure(int grade);

  /// Kimliği verilen kaydın cihazdaki dosya yolu (yoksa null).
  Future<String?> pathFor(String id);
}

/// İndirme yapmayan paket deposu (testler ve web).
class NoAudioPacks implements AudioPacks {
  const NoAudioPacks();
  @override
  Future<void> ensure(int grade) async {}
  @override
  Future<String?> pathFor(String id) async => null;
}

AudioPacks createAudioPacks() => impl.createAudioPacks();
