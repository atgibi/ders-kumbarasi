/// Cihazda ilerleme ve profil kaydı. Sunucu yok; tüm veri bu cihazda kalır.
library;

import 'dart:convert';

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

  /// Avatar sırası ('0'..'11'). Eski sürümlerin emoji avatarları da okunur.
  final String avatar;

  /// 12 hayvan avatarından hangisi (eski emoji kayıtları sabit bir sıraya düşer).
  int get avatarIndex {
    final i = int.tryParse(avatar);
    if (i != null) return i.clamp(0, avatarCount - 1);
    return avatar.runes.fold<int>(0, (a, b) => a + b) % avatarCount;
  }

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

const int avatarCount = 12;

/// Bir sorunun son denemesi (veli raporu, "Son denemeler").
class Attempt {
  const Attempt(this.day, this.prompt, this.result);

  /// 'YYYY-MM-DD'
  final String day;

  /// Sorunun kısa metni.
  final String prompt;

  /// first: ilk denemede doğru, hint: ipucuyla doğru, slow: doğru ama yavaş,
  /// retry: bir kez daha soruldu.
  final String result;

  List<Object?> toJson() => [day, prompt, result];

  static Attempt? fromJson(Object? j) {
    if (j is! List || j.length < 3) return null;
    return Attempt('${j[0]}', '${j[1]}', '${j[2]}');
  }
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
    Map<String, List<int>>? dailyAnswers,
    Map<String, List<Attempt>>? attempts,
  })  : cards = cards ?? {},
        startedOutcomes = startedOutcomes ?? {},
        dailyMinutes = dailyMinutes ?? {},
        dailyAnswers = dailyAnswers ?? {},
        attempts = attempts ?? {};

  /// 'YYYY-MM-DD' -> [cevaplanan, ilk denemede doğru].
  final Map<String, List<int>> dailyAnswers;

  /// Çıktı kodu -> son denemeler (en yenisi başta, en fazla 5).
  final Map<String, List<Attempt>> attempts;

  void addAttempt(String outcome, Attempt a) {
    final list = attempts.putIfAbsent(outcome, () => []);
    list.insert(0, a);
    if (list.length > 5) list.removeRange(5, list.length);
  }

  void countAnswer(String day, {required bool firstTry}) {
    final d = dailyAnswers.putIfAbsent(day, () => [0, 0]);
    d[0]++;
    if (firstTry) d[1]++;
  }

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
        'answers': dailyAnswers,
        'attempts': {
          for (final e in attempts.entries)
            e.key: [for (final a in e.value) a.toJson()],
        },
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
      dailyAnswers: (j['answers'] as Map<String, Object?>? ?? const {}).map(
          (k, v) => MapEntry(
              k, [for (final x in (v! as List<Object?>)) (x! as num).toInt()])),
      attempts: (j['attempts'] as Map<String, Object?>? ?? const {})
          .map((k, v) => MapEntry(k, [
                for (final x in (v! as List<Object?>))
                  if (Attempt.fromJson(x) case final a?) a
              ])),
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

/// Kayıt okunurken ne oldu (veli paneli uyarısı için).
enum LoadIssue { none, recoveredFromBackup, unreadable }

class ProgressStore {
  ProgressStore(this.storage);
  final Storage storage;

  static const _profilesFile = 'profiles.json';
  static const _settingsFile = 'settings.json';
  String _progressFile(String id) => 'progress_$id.json';

  /// Son okumada sorun çıktıysa (ör. dosya bozuk) burada görünür.
  LoadIssue lastIssue = LoadIssue.none;

  /// Okunamayan bir kayıt varsa, üzerine yazmadan önce kenara alınır.
  final Set<String> _quarantine = {};

  /// JSON'u çözer; bozuksa yedekten dener. İkisi de bozuksa null.
  Future<T?> _readJson<T>(String name, T Function(Object? json) parse) async {
    final s = await storage.read(name);
    if (s == null) return null;
    try {
      return parse(jsonDecode(s));
    } on Object {
      final bak = await storage.read('$name.bak');
      if (bak != null) {
        try {
          final v = parse(jsonDecode(bak));
          lastIssue = LoadIssue.recoveredFromBackup;
          return v;
        } on Object {
          // yedek de bozuk
        }
      }
      lastIssue = LoadIssue.unreadable;
      _quarantine.add(name);
      return null;
    }
  }

  /// Önce eski sürüm yedeğe alınır, sonra yeni içerik atomik yazılır.
  /// Okunamamış bir dosyanın üzerine yazılmadan önce kopyası saklanır.
  Future<void> _writeJson(String name, Object json) async {
    final old = await storage.read(name);
    if (old != null) {
      if (_quarantine.remove(name)) {
        await storage.write('$name.bozuk', old);
      } else {
        await storage.write('$name.bak', old);
      }
    }
    await storage.write(name, jsonEncode(json));
  }

  Future<List<ChildProfile>> loadProfiles() async =>
      await _readJson(
          _profilesFile,
          (j) => (j! as List<Object?>)
              .map((e) => ChildProfile.fromJson(e! as Map<String, Object?>))
              .toList()) ??
      [];

  Future<void> saveProfiles(List<ChildProfile> profiles) =>
      _writeJson(_profilesFile, [for (final p in profiles) p.toJson()]);

  Future<ChildProgress> loadProgress(String childId) async =>
      await _readJson(_progressFile(childId),
          (j) => ChildProgress.fromJson(j! as Map<String, Object?>)) ??
      ChildProgress();

  Future<void> saveProgress(String childId, ChildProgress p) =>
      _writeJson(_progressFile(childId), p.toJson());

  Future<void> _deleteWithBackups(String name) async {
    await storage.delete(name);
    await storage.delete('$name.bak');
    await storage.delete('$name.bozuk');
  }

  /// Profil ve tüm ilerlemeyi siler (veli "verileri sil").
  Future<void> deleteChild(String childId) async {
    await _deleteWithBackups(_progressFile(childId));
    final profiles = await loadProfiles();
    await saveProfiles(profiles.where((p) => p.id != childId).toList());
  }

  Future<void> deleteAll() async {
    for (final p in await loadProfiles()) {
      await _deleteWithBackups(_progressFile(p.id));
    }
    await _deleteWithBackups(_profilesFile);
    await _deleteWithBackups(_settingsFile);
    _quarantine.clear();
    lastIssue = LoadIssue.none;
  }

  Future<Map<String, Object?>> loadSettings() async =>
      await _readJson(_settingsFile, (j) => j! as Map<String, Object?>) ?? {};

  Future<void> saveSettings(Map<String, Object?> settings) =>
      _writeJson(_settingsFile, settings);

  /// Tüm verilerin tek dosyalık yedeği (veli: Yedekle).
  Future<String> exportAll() async {
    final profiles = await loadProfiles();
    return const JsonEncoder.withIndent(' ').convert({
      'uygulama': backupAppId,
      'surum': 1,
      'tarih': DateTime.now().toIso8601String(),
      'ayarlar': await loadSettings(),
      'profiller': [for (final p in profiles) p.toJson()],
      'ilerleme': {
        for (final p in profiles) p.id: (await loadProgress(p.id)).toJson(),
      },
    });
  }

  /// Yedekten geri yükler. Dosya geçersizse hiçbir şey değişmez ve
  /// [FormatException] fırlatılır.
  Future<int> importAll(String content) async {
    final Map<String, Object?> j;
    try {
      j = jsonDecode(content) as Map<String, Object?>;
    } on Object {
      throw const FormatException('Bu dosya bir Ders Kumbarası yedeği değil.');
    }
    if (j['uygulama'] != backupAppId) {
      throw const FormatException('Bu dosya bir Ders Kumbarası yedeği değil.');
    }
    final List<ChildProfile> profiles;
    final Map<String, ChildProgress> progress;
    try {
      profiles = [
        for (final e in j['profiller']! as List<Object?>)
          ChildProfile.fromJson(e! as Map<String, Object?>)
      ];
      final raw = j['ilerleme'] as Map<String, Object?>? ?? const {};
      progress = {
        for (final p in profiles)
          p.id: raw[p.id] == null
              ? ChildProgress()
              : ChildProgress.fromJson(raw[p.id]! as Map<String, Object?>),
      };
    } on Object {
      throw const FormatException('Yedek dosyası okunamadı (bozuk olabilir).');
    }
    await deleteAll();
    final settings = j['ayarlar'];
    if (settings is Map<String, Object?>) await saveSettings(settings);
    await saveProfiles(profiles);
    for (final e in progress.entries) {
      await saveProgress(e.key, e.value);
    }
    return profiles.length;
  }
}

const backupAppId = 'ders-kumbarasi';
