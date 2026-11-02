/// Web için tarayıcı depolaması (yalnızca bu tarayıcıda kalır).
library;

import 'package:shared_preferences/shared_preferences.dart';

import 'progress_store.dart';

Future<Storage> createPlatformStorage() async =>
    PrefsStorage(await SharedPreferences.getInstance());

class PrefsStorage implements Storage {
  PrefsStorage(this.prefs);
  final SharedPreferences prefs;
  static const _prefix = 'dk_';

  @override
  Future<String?> read(String name) async => prefs.getString('$_prefix$name');

  @override
  Future<void> write(String name, String content) async {
    await prefs.setString('$_prefix$name', content);
  }

  @override
  Future<void> delete(String name) async {
    await prefs.remove('$_prefix$name');
  }
}
