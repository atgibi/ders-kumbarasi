/// Uygulama durumu: profiller, seçili çocuk, ayarlar. Sunucu yok.
library;

import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/srs/leitner.dart';
import '../data/content_repository.dart';
import '../data/models.dart';
import '../data/progress_store.dart';
import 'speaker.dart';

class AppSettings {
  const AppSettings({
    this.dailyLimitMinutes = 20,
    this.quietStartHour = 21,
    this.quietEndHour = 7,
    this.soundOn = true,
    this.onboarded = false,
  });

  final int dailyLimitMinutes;
  final int quietStartHour;
  final int quietEndHour;
  final bool soundOn;
  final bool onboarded;

  AppSettings copyWith({
    int? dailyLimitMinutes,
    int? quietStartHour,
    int? quietEndHour,
    bool? soundOn,
    bool? onboarded,
  }) =>
      AppSettings(
        dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
        quietStartHour: quietStartHour ?? this.quietStartHour,
        quietEndHour: quietEndHour ?? this.quietEndHour,
        soundOn: soundOn ?? this.soundOn,
        onboarded: onboarded ?? this.onboarded,
      );

  Map<String, Object?> toJson() => {
        'limit': dailyLimitMinutes,
        'qs': quietStartHour,
        'qe': quietEndHour,
        'sound': soundOn,
        'onboarded': onboarded,
      };

  factory AppSettings.fromJson(Map<String, Object?> j) => AppSettings(
        dailyLimitMinutes: (j['limit'] as num?)?.toInt() ?? 20,
        quietStartHour: (j['qs'] as num?)?.toInt() ?? 21,
        quietEndHour: (j['qe'] as num?)?.toInt() ?? 7,
        soundOn: j['sound'] as bool? ?? true,
        onboarded: j['onboarded'] as bool? ?? false,
      );

  /// Sessiz saatlerde mi? (ör. 21:00–07:00)
  bool isQuietTime(DateTime now) {
    if (quietStartHour == quietEndHour) return false;
    final h = now.hour;
    return quietStartHour > quietEndHour
        ? (h >= quietStartHour || h < quietEndHour)
        : (h >= quietStartHour && h < quietEndHour);
  }
}

class AppState extends ChangeNotifier {
  AppState({
    required this.store,
    required this.content,
    required this.speaker,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  final ProgressStore store;
  final ContentRepository content;
  final Speaker speaker;
  final DateTime Function() clock;

  bool loaded = false;
  List<ChildProfile> profiles = [];
  AppSettings settings = const AppSettings();
  ChildProfile? active;
  ChildProgress? progress;

  /// Yol ekranında seçili ders (çocuk değişince sıfırlanır).
  Subject? subject;

  void selectSubject(Subject s) {
    subject = s;
    notifyListeners();
  }

  Future<void> load() async {
    profiles = await store.loadProfiles();
    settings = AppSettings.fromJson(await store.loadSettings());
    loaded = true;
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings s) async {
    settings = s;
    await store.saveSettings(s.toJson());
    notifyListeners();
  }

  Future<ChildProfile> addChild(
      String nickname, int grade, String avatar) async {
    final id = '${clock().microsecondsSinceEpoch}${Random().nextInt(1 << 16)}';
    final p = ChildProfile(
        id: id, nickname: nickname.trim(), grade: grade, avatar: avatar);
    profiles = [...profiles, p];
    await store.saveProfiles(profiles);
    if (!settings.onboarded) {
      await updateSettings(settings.copyWith(onboarded: true));
    }
    notifyListeners();
    return p;
  }

  Future<void> updateChild(ChildProfile p) async {
    profiles = [for (final x in profiles) x.id == p.id ? p : x];
    await store.saveProfiles(profiles);
    if (active?.id == p.id) {
      active = p;
      if (!Subject.forGrade(p.grade).contains(subject)) {
        subject = Subject.forGrade(p.grade).first;
      }
    }
    notifyListeners();
  }

  Future<void> deleteChild(String id) async {
    await store.deleteChild(id);
    profiles = profiles.where((p) => p.id != id).toList();
    if (active?.id == id) {
      active = null;
      progress = null;
    }
    notifyListeners();
  }

  Future<void> deleteAll() async {
    await store.deleteAll();
    profiles = [];
    active = null;
    progress = null;
    settings = const AppSettings();
    notifyListeners();
  }

  Future<void> selectChild(ChildProfile p) async {
    active = p;
    subject = Subject.forGrade(p.grade).first;
    progress = await store.loadProgress(p.id);
    notifyListeners();
  }

  void signOutChild() {
    active = null;
    progress = null;
    subject = null;
    notifyListeners();
  }

  Future<void> saveProgress() async {
    final a = active, p = progress;
    if (a == null || p == null) return;
    await store.saveProgress(a.id, p);
    notifyListeners();
  }

  int minutesToday() => progress?.dailyMinutes[dayKey(clock())] ?? 0;

  bool get overDailyLimit => minutesToday() >= settings.dailyLimitMinutes;

  /// Bir ders için vadesi gelmiş tekrar sayısı (ana ekrandaki rozet).
  Future<int> dueCount(Subject s) async {
    final a = active, p = progress;
    if (a == null || p == null) return 0;
    final codes =
        (await content.outcomesFor(s, a.grade)).map((o) => o.code).toSet();
    final now = clock();
    return p.cards.values
        .where((c) => !c.isNew && c.isDue(now))
        .where((c) => codes.contains(c.cardId.split('#').first))
        .length;
  }

  /// Çıktı bazlı gelişim (veli paneli).
  Future<Map<Outcome, MasteryLevel>> masteryMap(
      ChildProfile child, ChildProgress progress, Subject s) async {
    final outcomes = await content.outcomesFor(s, child.grade);
    final pack = await content.contentFor(s, child.grade);
    return {
      for (final o in outcomes)
        o: outcomeMastery([
          for (final c in pack[o.code]?.cards ?? const <CardDef>[])
            progress.cards[c.id] ?? CardState.fresh(c.id, clock()),
        ]),
    };
  }
}
