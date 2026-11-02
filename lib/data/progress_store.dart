/// Cihazda ilerleme ve profil kaydı. Sunucu yok; tüm veri bu cihazda kalır.
library;

import 'dart:convert';
import 'dart:io';

import '../core/srs/leitner.dart';

class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.nickname,
    required this.grade,
    required this.avatar,
  });

  final String id;
  final String nickname;
  final int grade;
  final String avatar;

  ChildProfile copyWith({String? nickname, int? grade, String? avatar}) =>
      ChildProfile(
        id: id,
        nickname: nickname ?? this.nickname,
        grade: grade ?? this.grade,
        avatar: avatar ?? this.avatar,
      );

  Map<String, Object?> toJson() =>
      {'id': id, 'n': nickname, 'g': grade, 'a': avatar};

  factory ChildProfile.fromJson(Map<String, Object?> j) => ChildProfile(
        id: j['id']! as String,
        nickname: j['n']! as String,
        grade: (j['g']! as num).toInt(),
        avatar: j['a']! as String,
      );
}

/// Bir çocuğun tüm öğrenme durumu.
class ChildProgress {
  ChildProgress({
    Map<String, CardState>? cards,
    Set<String>? startedOutcomes,
    Map<String, int>? dailyMinutes,
    this.streakDays = 0,
    this.nuts = 0,
    this.lastSessionDay,
    this.restDaysUsedThisWeek = 0,
    this.restWeek,
  })  : cards = cards ?? {},
        startedOutcomes = startedOutcomes ?? {},
        dailyMinutes = dailyMinutes ?? {};

  final Map<String, CardState> cards;

  /// Konu anlatımı görülmüş (tekrar döngüsüne girmiş) çıktılar.
  final Set<String> startedOutcomes;

  /// 'YYYY-MM-DD' -> o gün çalışılan dakika.
  final Map<String, int> dailyMinutes;

  int streakDays;

  /// Toplanan fındık (doğru cevap ve tamamlanan oturum ödülü).
  int nuts;
  String? lastSessionDay;
  int restDaysUsedThisWeek;
  String? restWeek;

  Map<String, Object?> toJson() => {
        'v': 1,
        'cards': [for (final c in cards.values) c.toJson()],
        'started': startedOutcomes.toList()..sort(),
        'minutes': dailyMinutes,
        'streak': streakDays,
        'nuts': nuts,
        'last': lastSessionDay,
        'rest': restDaysUsedThisWeek,
        'restWeek': restWeek,
      };

  factory ChildProgress.fromJson(Map<String, Object?> j) {
    final cards = <String, CardState>{};
    for (final c in (j['cards'] as List<Object?>? ?? const [])) {
      final s = CardState.fromJson(c! as Map<String, Object?>);
      cards[s.cardId] = s;
    }
    return ChildProgress(
      cards: cards,
      startedOutcomes:
          (j['started'] as List<Object?>? ?? const []).cast<String>().toSet(),
      dailyMinutes: (j['minutes'] as Map<String, Object?>? ?? const {})
          .map((k, v) => MapEntry(k, (v! as num).toInt())),
      streakDays: (j['streak'] as num?)?.toInt() ?? 0,
      nuts: (j['nuts'] as num?)?.toInt() ?? 0,
      lastSessionDay: j['last'] as String?,
      restDaysUsedThisWeek: (j['rest'] as num?)?.toInt() ?? 0,
      restWeek: j['restWeek'] as String?,
    );
  }
}

String dayKey(DateTime t) {
  final d = dayStart(t);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}

/// ISO haftası anahtarı (dinlenme günü hakkı haftalık sıfırlanır).
String weekKey(DateTime t) {
  final d = dayStart(t);
  final monday = DateTime(d.year, d.month, d.day - (d.weekday - 1));
  String two(int n) => n.toString().padLeft(2, '0');
  return '${monday.year}-${two(monday.month)}-${two(monday.day)}';
}

/// Seri kuralı: haftada 2 dinlenme günü hakkı; seri kırılınca ceza yok,
/// yalnızca sıfırdan başlar (proje planı 7.3).
void recordSessionDay(ChildProgress p, DateTime now,
    {int restDaysPerWeek = 2}) {
  final today = dayKey(now);
  if (p.lastSessionDay == today) return;
  final wk = weekKey(now);
  if (p.restWeek != wk) {
    p.restWeek = wk;
    p.restDaysUsedThisWeek = 0;
  }
  if (p.lastSessionDay == null) {
    p.streakDays = 1;
  } else {
    final last = DateTime.parse('${p.lastSessionDay}T04:00:00');
    final todayStart = dayStart(now);
    final gap = DateTime(todayStart.year, todayStart.month, todayStart.day)
            .difference(DateTime(last.year, last.month, last.day))
            .inDays -
        1; // atlanan gün sayısı
    if (gap <= 0) {
      p.streakDays += 1;
    } else if (p.restDaysUsedThisWeek + gap <= restDaysPerWeek) {
      p.restDaysUsedThisWeek += gap;
      p.streakDays += 1;
    } else {
      p.streakDays = 1;
    }
  }
  p.lastSessionDay = today;
}

/// Depolama soyutlaması: testlerde bellek içi, uygulamada dosya.
abstract class Storage {
  Future<String?> read(String name);
  Future<void> write(String name, String content);
  Future<void> delete(String name);
}

class MemoryStorage implements Storage {
  final Map<String, String> files = {};
  @override
  Future<String?> read(String name) async => files[name];
  @override
  Future<void> write(String name, String content) async =>
      files[name] = content;
  @override
  Future<void> delete(String name) async => files.remove(name);
}

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

class ProgressStore {
  ProgressStore(this.storage);
  final Storage storage;

  static const _profilesFile = 'profiles.json';
  String _progressFile(String id) => 'progress_$id.json';

  Future<List<ChildProfile>> loadProfiles() async {
    final s = await storage.read(_profilesFile);
    if (s == null) return [];
    try {
      final list = jsonDecode(s) as List<Object?>;
      return list
          .map((e) => ChildProfile.fromJson(e! as Map<String, Object?>))
          .toList();
    } on FormatException {
      return [];
    }
  }

  Future<void> saveProfiles(List<ChildProfile> profiles) => storage.write(
      _profilesFile, jsonEncode([for (final p in profiles) p.toJson()]));

  Future<ChildProgress> loadProgress(String childId) async {
    final s = await storage.read(_progressFile(childId));
    if (s == null) return ChildProgress();
    try {
      return ChildProgress.fromJson(jsonDecode(s) as Map<String, Object?>);
    } on FormatException {
      // Bozuk kayıt: çocuğu engellemek yerine boş başlat.
      return ChildProgress();
    }
  }

  Future<void> saveProgress(String childId, ChildProgress p) =>
      storage.write(_progressFile(childId), jsonEncode(p.toJson()));

  /// Profil ve tüm ilerlemeyi siler (veli "verileri sil").
  Future<void> deleteChild(String childId) async {
    await storage.delete(_progressFile(childId));
    final profiles = await loadProfiles();
    await saveProfiles(profiles.where((p) => p.id != childId).toList());
  }

  Future<void> deleteAll() async {
    for (final p in await loadProfiles()) {
      await storage.delete(_progressFile(p.id));
    }
    await storage.delete(_profilesFile);
    await storage.delete('settings.json');
  }

  Future<Map<String, Object?>> loadSettings() async {
    final s = await storage.read('settings.json');
    if (s == null) return {};
    try {
      return jsonDecode(s) as Map<String, Object?>;
    } on FormatException {
      return {};
    }
  }

  Future<void> saveSettings(Map<String, Object?> settings) =>
      storage.write('settings.json', jsonEncode(settings));
}
