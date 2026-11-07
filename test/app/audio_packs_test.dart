import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:ders_kumbarasi/app/audio_packs_io.dart';

/// tools/audio/speech.py pack ile aynı biçim.
Uint8List packOf(Map<String, List<int>> files) {
  final b = BytesBuilder()
    ..add(ascii.encode('DKSES1'))
    ..add((ByteData(4)..setUint32(0, files.length)).buffer.asUint8List());
  for (final e in files.entries) {
    b
      ..add(ascii.encode(e.key))
      ..add((ByteData(4)..setUint32(0, e.value.length)).buffer.asUint8List())
      ..add(e.value);
  }
  return b.takeBytes();
}

void main() {
  late Directory tmp;
  setUp(() async => tmp = await Directory.systemTemp.createTemp('ses'));
  tearDown(() async => tmp.delete(recursive: true));

  test('paket açılır; bozuk paket hiçbir şey yazmaz', () async {
    final out = await Directory('${tmp.path}/a').create();
    final n = await unpackAudioForTest(
        packOf({
          '0123456789abcdef': [1, 2, 3],
          'fedcba9876543210': [4]
        }),
        out);
    expect(n, 2);
    expect(await File('${out.path}/0123456789abcdef.mp3').readAsBytes(),
        [1, 2, 3]);
    final bad = await Directory('${tmp.path}/b').create();
    expect(await unpackAudioForTest(Uint8List.fromList([1, 2, 3]), bad), 0);
  });

  test('sınıf paketi indirilir, bir kez iner, sürüm değişince yenilenir',
      () async {
    var bin = packOf({
      '0123456789abcdef': [9, 9]
    });
    var version = 'v1';
    var downloads = 0;
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) async {
      if (req.uri.path.endsWith('ses.json')) {
        req.response.write(jsonEncode({
          'format': 1,
          'grades': {
            '2': {'file': 'ses-2.bin', 'bytes': bin.length, 'version': version}
          }
        }));
      } else if (req.uri.path.endsWith('ses-2.bin')) {
        downloads++;
        req.response.add(bin);
      } else {
        req.response.statusCode = 404;
      }
      await req.response.close();
    });
    final packs = FileAudioPacks(
        root: () async => tmp, base: 'http://127.0.0.1:${server.port}');

    expect(await packs.pathFor('0123456789abcdef'), isNull);
    await packs.ensure(2);
    expect(await packs.pathFor('0123456789abcdef'), isNotNull);
    await packs.ensure(2);
    expect(downloads, 1, reason: 'aynı sürüm yeniden inmez');

    bin = packOf({
      'fedcba9876543210': [7]
    });
    version = 'v2';
    await packs.ensure(2);
    expect(downloads, 2);
    expect(await packs.pathFor('fedcba9876543210'), isNotNull);
    expect(await packs.pathFor('0123456789abcdef'), isNull,
        reason: 'eski paket silinir');

    // Sunucu yoksa sessizce vazgeçer, eldeki kayıtlar kalır
    await server.close(force: true);
    await packs.ensure(2);
    expect(await packs.pathFor('fedcba9876543210'), isNotNull);
  });
}
