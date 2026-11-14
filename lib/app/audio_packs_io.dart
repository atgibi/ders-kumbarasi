/// iOS/Android: sınıf ses paketini indirir, açar ve cihazda saklar.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'audio_packs.dart';

AudioPacks createAudioPacks() => FileAudioPacks();

class FileAudioPacks implements AudioPacks {
  FileAudioPacks(
      {Future<Directory> Function()? root,
      this.base = audioPackBase,
      Future<bool> Function()? unmetered})
      : _rootOf = root ?? getApplicationSupportDirectory,
        _unmetered = unmetered ?? _onWifi;

  final Future<Directory> Function() _rootOf;
  final String base;
  final Future<bool> Function() _unmetered;
  final Set<int> _busy = {};
  Map<String, String>? _index;
  final ValueNotifier<AudioDownload?> _downloading = ValueNotifier(null);

  @override
  ValueListenable<AudioDownload?> get downloading => _downloading;

  /// Wi-Fi ya da kablolu bağlantı var mı (mobil veri değil)?
  static Future<bool> _onWifi() async {
    final r = await Connectivity().checkConnectivity();
    return r.contains(ConnectivityResult.wifi) ||
        r.contains(ConnectivityResult.ethernet);
  }

  Future<Directory> _root() async => Directory('${(await _rootOf()).path}/ses');

  @override
  Future<void> ensure(int grade,
      {bool wifiOnly = false, bool force = false}) async {
    if (!_busy.add(grade)) return;
    try {
      final root = await _root();
      final dir = Directory('${root.path}/$grade');
      final mark = File('${dir.path}/surum.txt');
      final listJson = await _get('$base/ses.json');
      final info = (jsonDecode(utf8.decode(listJson)) as Map)['grades'];
      if (info is! Map) return;
      final g = info['$grade'];
      if (g is! Map) return;
      final version = '${g['version']}';
      if (!force &&
          await mark.exists() &&
          (await mark.readAsString()).trim() == version) {
        return;
      }
      if (wifiOnly && !await _unmetered()) return; // mobil veride bekle
      _downloading.value = AudioDownload(grade, 0);
      final bytes = await _get('$base/${g['file']}', grade: grade);
      if (bytes.length != (g['bytes'] as num?)?.toInt()) return; // yarım indi
      final fresh = Directory('${root.path}/$grade.yeni');
      if (await fresh.exists()) await fresh.delete(recursive: true);
      await fresh.create(recursive: true);
      final n = await _unpack(bytes, fresh);
      if (n == 0) return;
      await File('${fresh.path}/surum.txt').writeAsString(version);
      if (await dir.exists()) await dir.delete(recursive: true);
      await fresh.rename(dir.path);
      _index = null; // yeniden taransın
    } on Object {
      // internet yok ya da sunucu cevap vermedi: cihaz sesi yeterli
    } finally {
      _busy.remove(grade);
      if (_downloading.value?.grade == grade) _downloading.value = null;
    }
  }

  @override
  Future<AudioPackStatus> status(int grade) async {
    try {
      final dir = Directory('${(await _root()).path}/$grade');
      if (!await File('${dir.path}/surum.txt').exists()) {
        return AudioPackStatus.none;
      }
      var n = 0, size = 0;
      await for (final e in dir.list()) {
        if (e is File && e.path.endsWith('.mp3')) {
          n++;
          size += await e.length();
        }
      }
      return AudioPackStatus(installed: true, count: n, bytes: size);
    } on Object {
      return AudioPackStatus.none;
    }
  }

  @override
  Future<void> keepOnly(Set<int> grades) async {
    try {
      final root = await _root();
      if (!await root.exists()) return;
      await for (final e in root.list()) {
        final name = e.uri.pathSegments.where((x) => x.isNotEmpty).last;
        final g = int.tryParse(name);
        if (e is Directory && g != null && !grades.contains(g)) {
          await e.delete(recursive: true);
          _index = null;
        }
      }
    } on Object {
      // silinemezse yer kaplamaya devam eder, zararı yok
    }
  }

  @override
  Future<String?> pathFor(String id) async {
    var idx = _index;
    if (idx == null) {
      idx = {};
      try {
        final root = await _root();
        if (await root.exists()) {
          await for (final e in root.list(recursive: true)) {
            if (e is File && e.path.endsWith('.mp3')) {
              final name = e.uri.pathSegments.last;
              idx[name.substring(0, name.length - 4)] = e.path;
            }
          }
        }
      } on Object {
        // okunamazsa kayıt yok sayılır
      }
      _index = idx;
    }
    return idx[id];
  }

  Future<Uint8List> _get(String url, {int? grade}) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final req = await client.getUrl(Uri.parse(url));
      final res = await req.close().timeout(const Duration(seconds: 30));
      if (res.statusCode != 200) {
        throw HttpException('HTTP ${res.statusCode}', uri: Uri.parse(url));
      }
      final b = BytesBuilder(copy: false);
      final total = res.contentLength;
      await for (final chunk in res.timeout(const Duration(seconds: 60))) {
        b.add(chunk);
        if (grade != null) {
          _downloading.value =
              AudioDownload(grade, total > 0 ? b.length / total : null);
        }
      }
      return b.takeBytes();
    } finally {
      client.close(force: true);
    }
  }
}

/// 'DKSES1' + sayı + (16 haneli kimlik + uzunluk + MP3) kayıtlarını açar.
/// Yazılan kayıt sayısını döner; biçim bozuksa 0.
Future<int> _unpack(Uint8List bytes, Directory into) async {
  const magic = 'DKSES1';
  if (bytes.length < 10 || ascii.decode(bytes.sublist(0, 6)) != magic) return 0;
  final view = ByteData.sublistView(bytes);
  final count = view.getUint32(6);
  var off = 10;
  for (var i = 0; i < count; i++) {
    if (off + 20 > bytes.length) return 0;
    final id = ascii.decode(bytes.sublist(off, off + 16));
    final len = view.getUint32(off + 16);
    off += 20;
    if (off + len > bytes.length) return 0;
    await File('${into.path}/$id.mp3')
        .writeAsBytes(Uint8List.sublistView(bytes, off, off + len));
    off += len;
  }
  return count;
}

/// Testler için: paket açıcı.
Future<int> unpackAudioForTest(Uint8List bytes, Directory into) =>
    _unpack(bytes, into);
