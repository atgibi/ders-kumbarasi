/// iOS/Android: flutter_local_notifications ile tek seferlik hatırlatma.
library;

import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'reminder.dart';

Reminder createReminder() => LocalReminder();

class LocalReminder implements Reminder {
  final FlutterLocalNotificationsPlugin _p = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  static const _id = 1;

  Future<void> _init() async {
    if (_ready) return;
    _ready = true;
    await _p.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ));
  }

  @override
  Future<bool> requestPermission() async {
    try {
      await _init();
      if (Platform.isAndroid) {
        return await _p
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>()
                ?.requestNotificationsPermission() ??
            false;
      }
      if (Platform.isIOS) {
        return await _p
                .resolvePlatformSpecificImplementation<
                    IOSFlutterLocalNotificationsPlugin>()
                ?.requestPermissions(alert: true, sound: true) ??
            false;
      }
    } on Object {
      return false;
    }
    return false;
  }

  @override
  Future<void> schedule(DateTime at, String title, String body) async {
    try {
      await _init();
      await _p.cancel(_id);
      // Saat dilimi veritabanı gerekmesin diye UTC'ye çevrilir (Türkiye'de
      // yaz saati yok; yurt dışında yaz saati değişiminde 1 saat kayabilir).
      await _p.zonedSchedule(
        _id,
        title,
        body,
        tz.TZDateTime.from(at.toUtc(), tz.UTC),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'hatirlatma',
            'Günlük hatırlatma',
            channelDescription: 'Velinin açtığı günlük çalışma hatırlatması',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } on Object {
      // bildirim kurulamazsa uygulama yine çalışır
    }
  }

  @override
  Future<void> cancel() async {
    try {
      await _init();
      await _p.cancel(_id);
    } on Object {
      // yok say
    }
  }
}
