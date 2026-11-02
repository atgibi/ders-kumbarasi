/// Mobil (iOS/Android) için dosya tabanlı depolama.
library;

import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'progress_store.dart';

Future<Storage> createPlatformStorage() async =>
    FileStorage(await getApplicationSupportDirectory());

class FileStorage implements Storage {
  FileStorage(this.dir);
  final Directory dir;

  File _f(String name) => File('${dir.path}/$name');

  @override
  Future<String?> read(String name) async {
    final f = _f(name);
    if (!await f.exists()) return null;
    return f.readAsString();
  }

  /// Atomik yazma: önce geçici dosyaya yaz, sonra yerine taşı. Yazma
  /// sırasında uygulama kapanırsa eski kayıt bozulmaz.
  @override
  Future<void> write(String name, String content) async {
    await dir.create(recursive: true);
    final tmp = _f('$name.tmp');
    await tmp.writeAsString(content, flush: true);
    await tmp.rename(_f(name).path);
  }

  @override
  Future<void> delete(String name) async {
    final f = _f(name);
    if (await f.exists()) await f.delete();
  }
}
