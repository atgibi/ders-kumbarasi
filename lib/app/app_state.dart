/// Uygulama durumu: profiller, seçili çocuk, ayarlar. Sunucu yok.
library;

import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/srs/leitner.dart';
import '../data/content_repository.dart';
import '../data/models.dart';
import '../data/progress_store.dart';
import '../game/game_state.dart';
import '../game/quests.dart';
import '../game/world.dart';
import 'speaker.dart';

class AppSettings {
  const AppSettings({
    this.dailyLimitMinutes = 20,
    this.quietStartHour = 21,
    this.quietEndHour = 7,
    this.soundOn = true,
    this.onboarded = false,
    this.reduceMotion = false,
    this.textSize = 0,
    this.premium = false,
  });

  final int dailyLimitMinutes;
  final int quietStartHour;
  final int quietEndHour;
  final bool soundOn;
  final bool onboarded;

  /// Zıplama ve konfeti durur; geçişler solar.
  final bool reduceMotion;

  /// 0 normal, 1 büyük, 2 en büyük (çocuk alanındaki yazılar).
  final int textSize;

  /// Abonelik etkin mi (tüm krallık bölgeleri açık). Mağaza bağlantısı
  /// kurulana kadar yalnızca geliştirme sürümünde açılabilir.
  final bool premium;

  bool get quietEnabled => quietStartHour != quietEndHour;

  /// Çocuk alanında yazı büyütme katsayısı.
  double get textScale => const [1.0, 1.25, 1.55][textSize.clamp(0, 2)];

  AppSettings copyWith({
    int? dailyLimitMinutes,
    int? quietStartHour,
    int? quietEndHour,
    bool? soundOn,
    bool? onboarded,
    bool? reduceMotion,
    int? textSize,
    bool? premium,
  }) =>
      AppSettings(
        dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
        quietStartHour: quietStartHour ?? this.quietStartHour,
        quietEndHour: quietEndHour ?? this.quietEndHour,
        soundOn: soundOn ?? this.soundOn,
        onboarded: onboarded ?? this.onboarded,
        reduceMotion: reduceMotion ?? this.reduceMotion,
        textSize: textSize ?? this.textSize,
        premium: premium ?? this.premium,
      );

  AppSettings withQuiet(bool on) => on
      ? copyWith(quietStartHour: 21, quietEndHour: 7)
      : copyWith(quietStartHour: 0, quietEndHour: 0);

  Map<String, Object?> toJson() => {
        'limit': dailyLimitMinutes,
        'qs': quietStartHour,
        'qe': quietEndHour,
        'sound': soundOn,
        'onboarded': onboarded,
        'reduce': reduceMotion,
        'text': textSize,
        'premium': premium,
      };

  factory AppSettings.fromJson(Map<String, Object?> j) => AppSettings(
        dailyLimitMinutes: (j['limit'] as num?)?.toInt() ?? 20,
        quietStartHour: (j['qs'] as num?)?.toInt() ?? 21,
        quietEndHour: (j['qe'] as num?)?.toInt() ?? 7,
        soundOn: j['sound'] as bool? ?? true,
        onboarded: j['onboarded'] as bool? ?? false,
        reduceMotion: j['reduce'] as bool? ?? false,
        textSize: (j['text'] as num?)?.toInt() ?? 0,
        premium: j['premium'] as bool? ?? false,
      );

  /// Sessiz saatlerde mi? (ör. 21:00–07:00)
  bool isQuietTime(DateTime now) {
    if (!quietEnabled) return false;
    final h = now.hour;
    return quietStartHour > quietEndHour
        ? (h >= quietStartHour || h < quietEndHour)
        : (h >= quietStartHour && h < quietEndHour);
  }
}

/// Oturum başlatılabilir mi?
enum StartBlock { none, quiet, timeUp }

/// Haftanın bir günü (Profil sekmesi ve veli grafiği).
class WeekDay {
  const WeekDay(this.label, this.minutes, this.isToday, this.isFuture);
  final String label;
  final int minutes;
  final bool isToday;
  final bool isFuture;
}

const weekDayLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

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

  /// Son kayıt denemesi başarısız olduysa (ör. depolama dolu).
  bool saveFailed = false;

  /// Bir kayıt okunamadı ya da yedekten kurtarıldı (veli paneli bilgisi).
  LoadIssue loadIssue = LoadIssue.none;

  /// Yol ekranında seçili ders (çocuk değişince sıfırlanır).
  Subject? subject;

  void selectSubject(Subject s) {
    subject = s;
    notifyListeners();
  }

  void _noteIssue() {
    if (store.lastIssue != LoadIssue.none) loadIssue = store.lastIssue;
  }

  Future<void> load() async {
    profiles = await store.loadProfiles();
    _noteIssue();
    settings = AppSettings.fromJson(await store.loadSettings());
    _noteIssue();
    loaded = true;
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings s) async {
    settings = s;
    notifyListeners();
    await _guard(() => store.saveSettings(s.toJson()));
  }

  Future<void> _guard(Future<void> Function() write) async {
    try {
      await write();
      if (saveFailed) {
        saveFailed = false;
        notifyListeners();
      }
    } on Object {
      saveFailed = true;
      notifyListeners();
    }
  }

  /// Sesli okuma (ayar kapalıysa sessiz).
  void say(String text, {bool slow = false}) {
    if (settings.soundOn && text.trim().isNotEmpty) {
      speaker.speak(text, slow: slow);
    }
  }

  Future<ChildProfile> addChild(
      String nickname, int grade, String avatar) async {
    final id = '${clock().microsecondsSinceEpoch}${Random().nextInt(1 << 16)}';
    final p = ChildProfile(
        id: id, nickname: nickname.trim(), grade: grade, avatar: avatar);
    profiles = [...profiles, p];
    await _guard(() => store.saveProfiles(profiles));
    notifyListeners();
    return p;
  }

  /// İlk açılış: profil ve kahraman birlikte kaydedilir (kahramansız bir
  /// an olmasın diye ilerleme dosyası profil listesinden önce yazılır).
  Future<ChildProfile> addChildWithHero(
      String nickname, int grade, String avatar, HeroLook hero) async {
    final id = '${clock().microsecondsSinceEpoch}${Random().nextInt(1 << 16)}';
    await _guard(() =>
        store.saveProgress(
            id,
            ChildProgress(
                game: GameState(hero: hero)
                  ..addLetter(welcomeLetter(
                      hero.name ?? nickname.trim(), dayKey(clock()))))));
    final p = ChildProfile(
        id: id, nickname: nickname.trim(), grade: grade, avatar: avatar);
    profiles = [...profiles, p];
    await _guard(() => store.saveProfiles(profiles));
    notifyListeners();
    return p;
  }

  Future<void> completeOnboarding() =>
      updateSettings(settings.copyWith(onboarded: true));

  Future<void> updateChild(ChildProfile p) async {
    profiles = [for (final x in profiles) x.id == p.id ? p : x];
    await _guard(() => store.saveProfiles(profiles));
    if (active?.id == p.id) {
      active = p;
      if (!Subject.forGrade(p.grade).contains(subject)) {
        subject = await _defaultSubject(p.grade);
      }
    }
    notifyListeners();
  }

  Future<void> deleteChild(String id) async {
    await _guard(() => store.deleteChild(id));
    profiles = profiles.where((p) => p.id != id).toList();
    if (active?.id == id) {
      active = null;
      progress = null;
    }
    notifyListeners();
  }

  Future<void> deleteAll() async {
    await _guard(store.deleteAll);
    profiles = [];
    active = null;
    progress = null;
    subject = null;
    settings = const AppSettings();
    loadIssue = LoadIssue.none;
    notifyListeners();
  }

  /// Yedekten geri yükleme sonrası her şeyi yeniden okur.
  Future<int> importBackup(String content) async {
    final n = await store.importAll(content);
    active = null;
    progress = null;
    subject = null;
    await load();
    return n;
  }

  Future<void> selectChild(ChildProfile p) async {
    active = p;
    subject = await _defaultSubject(p.grade);
    progress = await store.loadProgress(p.id);
    _noteIssue();
    notifyListeners();
  }

  /// İçeriği hazır olan ilk ders; hiçbiri hazır değilse ilk ders.
  Future<Subject> _defaultSubject(int grade) async {
    final subjects = Subject.forGrade(grade);
    for (final s in subjects) {
      if ((await content.contentFor(s, grade)).isNotEmpty) return s;
    }
    return subjects.first;
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
    await _guard(() => store.saveProgress(a.id, p));
    notifyListeners();
  }

  int minutesToday([ChildProgress? p]) =>
      (p ?? progress)?.dailyMinutes[dayKey(clock())] ?? 0;

  bool get overDailyLimit => minutesToday() >= settings.dailyLimitMinutes;

  /// Bugün en az bir oturum tamamlandı mı?
  bool get studiedToday => progress?.lastSessionDay == dayKey(clock());

  StartBlock startBlock() {
    if (settings.isQuietTime(clock())) return StartBlock.quiet;
    if (overDailyLimit) return StartBlock.timeUp;
    return StartBlock.none;
  }

  /// Bu haftanın günleri (Pazartesi başlar).
  List<WeekDay> week([ChildProgress? p]) {
    final pr = p ?? progress;
    final today = dayStart(clock());
    final monday = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: today.weekday - 1));
    return [
      for (var i = 0; i < 7; i++)
        () {
          final d = DateTime(monday.year, monday.month, monday.day + i, 12);
          final key = dayKey(d);
          final todayKey = dayKey(clock());
          return WeekDay(
            weekDayLabels[i],
            pr?.dailyMinutes[key] ?? 0,
            key == todayKey,
            key.compareTo(todayKey) > 0,
          );
        }(),
    ];
  }

  /// Bu hafta: [çalışılan gün, toplam dakika, ilk denemede doğru yüzdesi (yoksa -1)].
  (int, int, int) weekStats(ChildProgress p) {
    final days = week(p);
    final today = dayStart(clock());
    final monday = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: today.weekday - 1));
    var answered = 0, first = 0;
    for (var i = 0; i < 7; i++) {
      final key =
          dayKey(DateTime(monday.year, monday.month, monday.day + i, 12));
      final a = p.dailyAnswers[key];
      if (a != null && a.length >= 2) {
        answered += a[0];
        first += a[1];
      }
    }
    return (
      days.where((d) => d.minutes > 0).length,
      days.fold<int>(0, (s, d) => s + d.minutes),
      answered == 0 ? -1 : (100 * first / answered).round(),
    );
  }

  /// Bir ders için vadesi gelmiş tekrar sayısı.
  Future<int> dueCount(Subject s,
      {ChildProfile? child, ChildProgress? p}) async {
    final a = child ?? active, pr = p ?? progress;
    if (a == null || pr == null) return 0;
    final codes =
        (await content.outcomesFor(s, a.grade)).map((o) => o.code).toSet();
    final now = clock();
    return pr.cards.values
        .where((c) => !c.isNew && c.isDue(now))
        .where((c) => codes.contains(c.cardId.split('#').first))
        .length;
  }

  /// Çocuğun tüm derslerinde bekleyen tekrar; en çok bekleyen ders önde.
  Future<List<(Subject, int)>> dueBySubject() async {
    final a = active;
    if (a == null) return const [];
    final list = [
      for (final s in Subject.forGrade(a.grade)) (s, await dueCount(s)),
    ]..sort((x, y) => y.$2.compareTo(x.$2));
    return list;
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

  /// Çocuk dostu konu adı: konu anlatımının başlığı, yoksa programdaki ifade.
  Future<String> outcomeLabel(Outcome o) async {
    final pack = await content.contentFor(o.subject, o.grade);
    final lessons = pack[o.code]?.lessons ?? const <Lesson>[];
    return lessons.isNotEmpty ? lessons.first.title : o.title;
  }

  // ---------------------------------------------------------------- Oyun

  GameState get game => progress!.game;

  /// Işık: ana kaynak.
  int get light => progress?.nuts ?? 0;

  Future<void> saveHero(HeroLook hero) async {
    progress!.game.hero = hero;
    progress!.game.addLetter(welcomeLetter(
        hero.name ?? active?.nickname ?? 'Kahraman', dayKey(clock())));
    await saveProgress();
  }

  // ------------------------------------------------- Süreklilik (pano, sefer)

  String get heroName =>
      progress?.game.hero?.name ?? active?.nickname ?? 'Kahraman';

  /// Haftanın pazartesisinin gün anahtarı.
  String weekKey(DateTime t) {
    final d = dayStart(t);
    return dayKey(DateTime(d.year, d.month, d.day - (d.weekday - 1), 12));
  }

  /// Şu an bekleyen (daha önce görülmüş) tekrar kartı sayısı.
  int get dueNowRough {
    final now = clock();
    return progress?.cards.values
            .where((c) => !c.isNew && !c.due.isAfter(now))
            .length ??
        0;
  }

  /// Açılabilecek yeni konu var mı (abonelik kilidi dahil)?
  Future<bool> _hasNewTopic() async {
    final a = active, p = progress;
    if (a == null || p == null) return false;
    for (final s in Subject.forGrade(a.grade)) {
      final locked = await lockedOutcomes(s);
      final all = await content.outcomesFor(s, a.grade);
      if (all.any((o) =>
          !p.startedOutcomes.contains(o.code) && !locked.contains(o.code))) {
        return true;
      }
    }
    return false;
  }

  /// Bugünün istek panosu; gün değiştiyse yenisini kurar.
  Future<DailyBoard> todayBoard({bool save = true}) async {
    final g = game;
    final today = dayKey(clock());
    final b = g.board;
    if (b != null && b.day == today) return b;
    g.board = DailyBoard(
        today,
        makeDailyQuests(today, active!.id,
            reviewReady: dueNowRough >= 5,
            newTopicReady: await _hasNewTopic()));
    if (save) await saveProgress();
    return g.board!;
  }

  /// Bu haftanın seferi; hafta değiştiyse yenisini başlatır.
  WeeklyTrip thisTrip() {
    final g = game;
    final wk = weekKey(clock());
    if (g.trip?.week != wk) g.trip = WeeklyTrip(wk);
    return g.trip!;
  }

  /// Oturum bitince pano ve sefer ilerler. Kaydetmez; çağıran kaydeder.
  Future<void> recordSession(
      {required int correct,
      required int newTopics,
      required int reviewed}) async {
    if (progress == null || active == null) return;
    final b = await todayBoard(save: false);
    b.add(QuestKind.session, 1);
    b.add(QuestKind.correct, correct);
    b.add(QuestKind.newTopic, newTopics);
    b.add(QuestKind.review, reviewed);
    thisTrip().days.add(dayKey(clock()));
  }

  /// Tamamlanan isteğin ödülünü alır.
  Future<bool> claimQuest(int i) async {
    final b = await todayBoard();
    if (i < 0 || i >= b.quests.length || !b.canClaim(i)) return false;
    final q = b.quests[i];
    b.claimed.add(i);
    progress!.nuts += q.light;
    game.addSupply(q.supply, q.qty);
    game.addPage(dayKey(clock()),
        '$heroName, ${q.who.name} için bir iş gördü: ${q.task}');
    await saveProgress();
    return true;
  }

  /// Haftalık seferin ödülü: ışık, her krallıktan malzeme ve önderin mektubu.
  Future<bool> claimTrip() async {
    final t = thisTrip();
    if (!t.canClaim) return false;
    t.claimed = true;
    progress!.nuts += 15;
    for (final s in Supply.values) {
      game.addSupply(s, 2);
    }
    final today = dayKey(clock());
    game.addLetter(
        leaderLetter(t.leaderKingdom, t.week, heroName, t.days.length, today));
    game.addPage(today, '$heroName haftalık seferini tamamladı.');
    await saveProgress();
    return true;
  }

  Future<void> readLetter(Letter l) async {
    if (l.read) return;
    l.read = true;
    await saveProgress();
  }

  /// Ders/sınıf için krallık bölgeleri.
  Future<List<RegionDef>> regions(Subject s, [int? grade]) async {
    final g = grade ?? active!.grade;
    return regionsOf(s, g, await content.outcomesFor(s, g));
  }

  /// Bölge abonelik kilidinde mi?
  bool regionLocked(RegionDef r) => r.premium && !settings.premium;

  /// Abonelik olmadan yeni konusu açılmayan çıktılar.
  Future<Set<String>> lockedOutcomes(Subject s) async {
    if (settings.premium) return const {};
    return {
      for (final r in await regions(s))
        if (regionLocked(r)) ...r.outcomes.map((o) => o.code),
    };
  }

  /// "Yeterli" düzeydeki çıktı sayısı (tüm dersler).
  Future<int> masteredCount() async {
    final a = active, p = progress;
    if (a == null || p == null) return 0;
    var n = 0;
    for (final s in Subject.forGrade(a.grade)) {
      final m = await masteryMap(a, p, s);
      n += m.entries
          .where((e) =>
              p.startedOutcomes.contains(e.key.code) &&
              e.value == MasteryLevel.sufficient)
          .length;
    }
    return n;
  }

  Future<HeroStage> heroStage() async => stageFor(
        started: progress?.startedOutcomes.length ?? 0,
        banners: progress?.game.banners.length ?? 0,
        mastered: await masteredCount(),
      );

  /// Yapı kurulabilir/yükseltilebilir mi?
  bool canBuild(BuildingDef b) {
    final p = progress;
    if (p == null) return false;
    final next = p.game.levelOf(b) + 1;
    if (next > BuildingDef.maxLevel) return false;
    if (p.nuts < b.lightCost(next)) return false;
    return b
        .materialCost(next)
        .entries
        .every((e) => p.game.supply(e.key) >= e.value);
  }

  /// Yapıyı kurar ya da bir seviye yükseltir. Bekleme süresi yok.
  Future<bool> build(BuildingDef b) async {
    if (!canBuild(b)) return false;
    final p = progress!;
    final next = p.game.levelOf(b) + 1;
    p.nuts -= b.lightCost(next);
    for (final e in b.materialCost(next).entries) {
      p.game.addSupply(e.key, -e.value);
    }
    p.game.built[b.id] = next;
    await saveProgress();
    return true;
  }
}
