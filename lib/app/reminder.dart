/// Günlük hatırlatma bildirimi. Veli açarsa kurulur; çocuk o gün çalıştıysa
/// ertesi güne kayar. Tekrarlayan değil tek seferlik: uygulama günlerce
/// açılmazsa yalnızca bir hatırlatma gelir.
library;

import 'reminder_web.dart' if (dart.library.io) 'reminder_io.dart' as impl;

abstract class Reminder {
  /// Bildirim izni ister (Android 13+, iOS). İzin verildiyse true.
  Future<bool> requestPermission();

  /// Önceki hatırlatmayı siler ve [at] zamanına yenisini kurar.
  Future<void> schedule(DateTime at, String title, String body);

  Future<void> cancel();
}

/// Bildirim kurmayan hatırlatıcı (testler ve web).
class NoopReminder implements Reminder {
  DateTime? scheduled;
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> schedule(DateTime at, String title, String body) async =>
      scheduled = at;
  @override
  Future<void> cancel() async => scheduled = null;
}

Reminder createReminder() => impl.createReminder();
