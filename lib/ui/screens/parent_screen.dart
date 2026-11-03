/// Veli alanı (D2–D8): panel, çocuk raporu, çıktı detayı, ayarlar,
/// profiller, veri/gizlilik/hakkında.
library;

import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../core/srs/leitner.dart';
import '../../data/models.dart';
import '../../data/progress_store.dart';
import '../theme.dart';
import '../widgets/avatar.dart';
import '../widgets/dk_icon.dart';
import '../widgets/emoji_text.dart';
import '../widgets/kit.dart';
import 'data_screen.dart';
import 'onboarding_screen.dart';
import 'profile_form.dart';
import 'profile_picker_screen.dart';

const levelText = {
  MasteryLevel.notStarted: 'Başlanmadı',
  MasteryLevel.beginning: 'Başlangıç',
  MasteryLevel.developing: 'Gelişiyor',
  MasteryLevel.sufficient: 'Yeterli',
};

/// Düzey çipi: renk + çubuk sayısı + metin (renk tek başına bilgi taşımaz).
class LevelChip extends StatelessWidget {
  const LevelChip(this.level, {super.key, this.fontSize = 13});
  final MasteryLevel level;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, int bars) = switch (level) {
      MasteryLevel.notStarted => (K.stone, K.ink2, 0),
      MasteryLevel.beginning => (
          const Color(0xFFFBEBD0),
          const Color(0xFF6B4300),
          1
        ),
      MasteryLevel.developing => (K.againBg, K.againInk, 2),
      MasteryLevel.sufficient => (K.goodBg, K.goodInk, 3),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 1; i <= 3; i++)
          Container(
            width: 6,
            height: 10,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
                color: i <= bars ? fg : K.locked,
                borderRadius: BorderRadius.circular(2)),
          ),
        const SizedBox(width: 4),
        Text(levelText[level]!,
            style: TextStyle(
                fontSize: fontSize, fontWeight: FontWeight.w800, color: fg)),
      ]),
    );
  }
}

/// Bir çocuğun veli alanında gösterilen bilgileri.
class _KidData {
  _KidData(this.profile, this.progress, this.rows);
  final ChildProfile profile;
  final ChildProgress progress;

  /// (ders, çıktı, çocuk dostu ad, düzey)
  final List<(Subject, Outcome, String, MasteryLevel)> rows;
}

Future<_KidData> _loadKid(AppState app, ChildProfile p) async {
  final progress = app.active?.id == p.id && app.progress != null
      ? app.progress!
      : await app.store.loadProgress(p.id);
  final rows = <(Subject, Outcome, String, MasteryLevel)>[];
  for (final s in Subject.forGrade(p.grade)) {
    final m = await app.masteryMap(p, progress, s);
    for (final e in m.entries) {
      rows.add((s, e.key, await app.outcomeLabel(e.key), e.value));
    }
  }
  return _KidData(p, progress, rows);
}

/// D2 Veli paneli.
class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  int _kid = 0;
  Future<_KidData>? _f;
  String _key = '';

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    if (app.profiles.isEmpty) {
      return const SizedBox.shrink();
    }
    if (_kid >= app.profiles.length) _kid = 0;
    if (_f == null) {
      final i = app.profiles.indexWhere((p) => p.id == app.active?.id);
      if (i >= 0) _kid = i;
    }
    final profile = app.profiles[_kid];
    final key = '${profile.id}|${profile.grade}|${app.profiles.length}';
    if (_f == null || key != _key) {
      _key = key;
      _f = _loadKid(app, profile);
    }
    return Scaffold(
      backgroundColor: K.bgParent,
      body: SafeArea(
        child: Column(children: [
          ParentHeader(
            title: 'Veli paneli',
            trailing: Pressable(
              key: const Key('to-child'),
              onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
              label: 'Çocuk alanına dön',
              excludeChildSemantics: true,
              builder: (context, down) => Container(
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: down ? K.bgParent : K.card,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: K.line, width: 2),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  DkIcon(DkIcons.logout, size: 18, color: K.ink),
                  SizedBox(width: 6),
                  Text('Çocuk alanı',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: K.ink)),
                ]),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    for (var i = 0; i < app.profiles.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      _KidTab(
                        profile: app.profiles[i],
                        selected: i == _kid,
                        onTap: () => setState(() {
                          _kid = i;
                          _f = null;
                        }),
                      ),
                    ],
                  ]),
                ),
                const SizedBox(height: 16),
                if (app.loadIssue != LoadIssue.none || app.saveFailed) ...[
                  _StorageNotice(app: app),
                  const SizedBox(height: 16),
                ],
                FutureBuilder<_KidData>(
                  future: _f,
                  builder: (context, snap) {
                    final d = snap.data;
                    if (d == null) return const SizedBox(height: 120);
                    return _Overview(data: d);
                  },
                ),
                const SizedBox(height: 16),
                ListBox(children: [
                  NavRow(
                    key: const Key('nav-report'),
                    icon: DkIcons.chart,
                    title: 'Çocuk raporu',
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) => ReportScreen(profile: profile))),
                  ),
                  NavRow(
                    key: const Key('nav-settings'),
                    icon: DkIcons.sliders,
                    title: 'Ayarlar',
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) => const SettingsScreen())),
                  ),
                  NavRow(
                    key: const Key('nav-profiles'),
                    icon: DkIcons.users,
                    title: 'Çocuk profilleri',
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) => const ProfilesScreen())),
                  ),
                  NavRow(
                    key: const Key('nav-data'),
                    icon: DkIcons.shield,
                    title: 'Veri, gizlilik ve hakkında',
                    last: true,
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) => const DataScreen())),
                  ),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _StorageNotice extends StatelessWidget {
  const _StorageNotice({required this.app});
  final AppState app;

  @override
  Widget build(BuildContext context) {
    final text = app.saveFailed
        ? 'Son çalışma cihaza kaydedilemedi. Cihazda yer açmayı deneyin; '
            'sorun sürerse Veri bölümünden yedek alın.'
        : app.loadIssue == LoadIssue.recoveredFromBackup
            ? 'Bir kayıt dosyası bozulmuştu; bir önceki kayıttan geri yüklendi. '
                'Son oturumdaki birkaç cevap eksik olabilir.'
            : 'Bir kayıt dosyası okunamadı. Dosya silinmedi, kenara alındı; '
                'yedeğiniz varsa Veri bölümünden geri yükleyebilirsiniz.';
    return DkCard(
      color: K.againBg,
      borderColor: K.againLine,
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const DkIcon(DkIcons.info, size: 24, color: K.againInk),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: T.pBody.copyWith(color: K.againInk))),
      ]),
    );
  }
}

class _KidTab extends StatelessWidget {
  const _KidTab(
      {required this.profile, required this.selected, required this.onTap});
  final ChildProfile profile;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
        onTap: onTap,
        selected: selected,
        label: '${profile.nickname}, ${profile.grade}. sınıf',
        excludeChildSemantics: true,
        builder: (context, down) => Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.only(left: 6, right: 14),
          decoration: BoxDecoration(
            color: selected ? K.card : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? K.ink : K.line, width: 2),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Avatar(index: profile.avatarIndex, size: 34),
            const SizedBox(width: 8),
            Text(profile.nickname, style: T.pStrong),
            const SizedBox(width: 6),
            Text('${profile.grade}. sınıf',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: K.inkSoft)),
          ]),
        ),
      );
}

class _Overview extends StatelessWidget {
  const _Overview({required this.data});
  final _KidData data;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final (days, minutes, firstPct) = app.weekStats(data.progress);
    final started = data.rows
        .where((r) => data.progress.startedOutcomes.contains(r.$2.code))
        .toList();
    final support = started
        .where((r) =>
            r.$4 == MasteryLevel.beginning || r.$4 == MasteryLevel.developing)
        .toList()
      ..sort((a, b) => a.$4.index.compareTo(b.$4.index));
    final strong =
        started.where((r) => r.$4 == MasteryLevel.sufficient).toList();
    final name = data.profile.nickname;

    if (minutes == 0 && started.isEmpty) {
      return DkCard(
        key: const Key('parent-empty'),
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DkIcon(DkIcons.calendar, size: 32, color: K.inkSoft),
            const SizedBox(height: 10),
            Text('$name bu hafta henüz çalışmadı',
                style: const TextStyle(
                    fontSize: 19, fontWeight: FontWeight.w800, color: K.ink)),
            const SizedBox(height: 10),
            const Text(
                'İlk oturumdan sonra burada haftalık özet ve konu durumları görünecek. Günlük 10 dakika yeterli.',
                style: T.pBodySoft),
          ],
        ),
      );
    }

    Widget section(
            String title,
            List<(Subject, Outcome, String, MasteryLevel)> rows,
            String empty) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: T.pSection),
            const SizedBox(height: 8),
            if (rows.isEmpty)
              DkCard(child: Text(empty, style: T.pBodySoft))
            else
              ListBox(children: [
                for (var i = 0; i < rows.length && i < 3; i++)
                  NavRow(
                    title: rows[i].$3,
                    subtitle: '${rows[i].$1.label} · ${rows[i].$2.code}',
                    trailing: LevelChip(rows[i].$4),
                    last: i == rows.length - 1 || i == 2,
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) => OutcomeScreen(
                                profile: data.profile,
                                outcome: rows[i].$2,
                                label: rows[i].$3,
                                level: rows[i].$4))),
                  ),
              ]),
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('BU HAFTA', style: T.pSection),
        const SizedBox(height: 8),
        IntrinsicHeight(
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final (v, l) in [
            ('$days gün', 'çalıştı'),
            ('$minutes dk', 'toplam süre'),
            (firstPct < 0 ? '–' : '%$firstPct', 'ilk denemede doğru'),
          ]) ...[
            if (l != 'çalıştı') const SizedBox(width: 8),
            Expanded(
              child: DkCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: K.ink)),
                    const SizedBox(height: 2),
                    Text(l, style: T.pSmall),
                  ],
                ),
              ),
            ),
          ],
        ])),
        const SizedBox(height: 16),
        section('DESTEKLENMESİ GEREKEN', support,
            'Şu an desteğe ihtiyaç duyduğu bir konu görünmüyor.'),
        const SizedBox(height: 16),
        section('GÜÇLÜ OLDUĞU', strong,
            'Konular tekrarlarla güçlendikçe burada görünecek.'),
      ],
    );
  }
}

/// Haftalık dakika grafiği (7 çubuk).
class WeekBars extends StatelessWidget {
  const WeekBars({super.key, required this.days, this.height = 96});
  final List<WeekDay> days;
  final double height;

  @override
  Widget build(BuildContext context) {
    final maxM =
        days.fold<int>(16, (m, d) => d.minutes > m ? d.minutes : m).toDouble();
    return Semantics(
      label: 'Günlük çalışma dakikaları: ${[
        for (final d in days) '${d.label} ${d.minutes}'
      ].join(', ')}',
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final d in days)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(d.minutes > 0 ? '${d.minutes}' : '–',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: K.ink2)),
                        const SizedBox(height: 4),
                        Container(
                          height: (d.minutes / maxM * (height - 44))
                              .clamp(4, height - 44),
                          decoration: BoxDecoration(
                            color: d.minutes > 0 ? K.again : K.line,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(5),
                                bottom: Radius.circular(2)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(d.label,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: d.isToday
                                    ? FontWeight.w900
                                    : FontWeight.w400,
                                color: K.inkSoft)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// D3 Çocuk raporu.
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key, required this.profile});
  final ChildProfile profile;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Future<_KidData>? _f;
  late Subject _subject = Subject.forGrade(widget.profile.grade).firstWhere(
      (s) => s == AppScope.read(context).subject,
      orElse: () => Subject.forGrade(widget.profile.grade).first);
  MasteryLevel? _filter;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    _f ??= _loadKid(app, widget.profile);
    return Scaffold(
      backgroundColor: K.bgParent,
      body: SafeArea(
        child: Column(children: [
          ParentHeader(
            title: '${widget.profile.nickname} · ${_subject.label}',
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: FutureBuilder<_KidData>(
              future: _f,
              builder: (context, snap) {
                final d = snap.data;
                if (d == null) return const SizedBox.shrink();
                final week = app.week(d.progress);
                final total = week.fold<int>(0, (s, x) => s + x.minutes);
                final rows = d.rows
                    .where((r) => r.$1 == _subject)
                    .where((r) => _filter == null || r.$4 == _filter)
                    .toList();
                Widget chip(String t, bool sel, VoidCallback onTap, Key key) =>
                    Pressable(
                      key: key,
                      onTap: onTap,
                      selected: sel,
                      label: t,
                      excludeChildSemantics: true,
                      builder: (context, down) => Container(
                        constraints: const BoxConstraints(minHeight: 44),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: sel ? K.ink : K.card,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: K.ink, width: 2),
                        ),
                        child: Text(t,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: sel ? Colors.white : K.ink)),
                      ),
                    );
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    DkCard(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(children: [
                            const Expanded(
                                child:
                                    Text('Haftalık dakika', style: T.pStrong)),
                            Text('Toplam $total dk', style: T.pSmall),
                          ]),
                          const SizedBox(height: 10),
                          WeekBars(days: week),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                        'Her öğrenme çıktısı dört düzeyle gösterilir. Bu bir not değildir.',
                        style: T.pSmall),
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        for (final s
                            in Subject.forGrade(widget.profile.grade)) ...[
                          chip(
                              s.label,
                              s == _subject,
                              () => setState(() => _subject = s),
                              Key('report-subject-${s.id}')),
                          const SizedBox(width: 8),
                        ],
                      ]),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        chip(
                            'Tümü',
                            _filter == null,
                            () => setState(() => _filter = null),
                            const Key('filter-all')),
                        for (final l in MasteryLevel.values) ...[
                          const SizedBox(width: 8),
                          chip(
                              levelText[l]!,
                              _filter == l,
                              () => setState(() => _filter = l),
                              Key('filter-${l.name}')),
                        ],
                      ]),
                    ),
                    const SizedBox(height: 14),
                    ListBox(children: [
                      if (rows.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child:
                              Text('Bu düzeyde konu yok.', style: T.pBodySoft),
                        ),
                      for (var i = 0; i < rows.length; i++)
                        NavRow(
                          title: rows[i].$3,
                          subtitle: rows[i].$2.code,
                          trailing: LevelChip(rows[i].$4),
                          chevron: false,
                          last: i == rows.length - 1,
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => OutcomeScreen(
                                      profile: widget.profile,
                                      outcome: rows[i].$2,
                                      label: rows[i].$3,
                                      level: rows[i].$4))),
                        ),
                    ]),
                  ],
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

/// D4 Çıktı detayı.
class OutcomeScreen extends StatefulWidget {
  const OutcomeScreen({
    super.key,
    required this.profile,
    required this.outcome,
    required this.label,
    required this.level,
  });
  final ChildProfile profile;
  final Outcome outcome;
  final String label;
  final MasteryLevel level;

  @override
  State<OutcomeScreen> createState() => _OutcomeScreenState();
}

class _OutcomeScreenState extends State<OutcomeScreen> {
  Future<(List<Attempt>, String)>? _f;

  Future<(List<Attempt>, String)> _load() async {
    final app = AppScope.read(context);
    final progress = app.active?.id == widget.profile.id && app.progress != null
        ? app.progress!
        : await app.store.loadProgress(widget.profile.id);
    final pack = await app.content
        .contentFor(widget.outcome.subject, widget.outcome.grade);
    final acts = [
      for (final c in pack[widget.outcome.code]?.cards ?? const <CardDef>[])
        if (c.fixed?.activity ?? false) c.fixed!.prompt,
    ];
    final tip = acts.isNotEmpty
        ? acts.first
        : switch (widget.outcome.subject) {
            Subject.matematik =>
              'Günlük hayattan sayma, karşılaştırma ve ölçme fırsatları yaratın: alışverişte, mutfakta, merdivende.',
            Subject.turkce =>
              'Birlikte kısa bir hikâye okuyun; ardından ne olduğunu çocuğunuzun kendi cümleleriyle anlatmasını isteyin.',
            Subject.hayatBilgisi =>
              'Bu konuyu evdeki günlük işlerle ilişkilendirin ve çocuğunuzun fikrini sorun.',
            Subject.fenBilimleri =>
              'Evde güvenli, küçük bir gözlem yapın; ne gördüğünü çizmesini ya da anlatmasını isteyin.',
            Subject.sosyalBilgiler =>
              'Konuyu aile büyüklerinin anılarıyla ya da yakın çevrenizle ilişkilendirerek konuşun.',
          };
    return (progress.attempts[widget.outcome.code] ?? const <Attempt>[], tip);
  }

  String _day(String key) {
    final app = AppScope.read(context);
    final today = dayKey(app.clock());
    final yesterday = dayKey(app.clock().subtract(const Duration(days: 1)));
    if (key == today) return 'Bugün';
    if (key == yesterday) return 'Dün';
    final d = DateTime.tryParse(key);
    if (d == null) return key;
    if (app.clock().difference(d).inDays < 7) {
      return const [
        'Pazartesi',
        'Salı',
        'Çarşamba',
        'Perşembe',
        'Cuma',
        'Cumartesi',
        'Pazar'
      ][d.weekday - 1];
    }
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
  }

  static const _result = {
    'first': 'İlk denemede doğru',
    'slow': 'Doğru (biraz düşünerek)',
    'hint': 'İpucuyla doğru',
    'retry': 'Bir kez daha soruldu',
  };

  @override
  Widget build(BuildContext context) {
    _f ??= _load();
    return Scaffold(
      backgroundColor: K.bgParent,
      body: SafeArea(
        child: Column(children: [
          ParentHeader(
              title: widget.outcome.code,
              onBack: () => Navigator.of(context).pop()),
          Expanded(
            child: FutureBuilder<(List<Attempt>, String)>(
              future: _f,
              builder: (context, snap) {
                final d = snap.data;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    EmojiText(widget.label,
                        style: const TextStyle(
                            fontSize: 26,
                            height: 32 / 26,
                            fontWeight: FontWeight.w900,
                            color: K.ink)),
                    const SizedBox(height: 8),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: LevelChip(widget.level, fontSize: 14)),
                    const SizedBox(height: 12),
                    Text('Programdaki ifade: ${widget.outcome.title}',
                        style: T.pSmall),
                    const SizedBox(height: 16),
                    const Text('SON DENEMELER', style: T.pSection),
                    const SizedBox(height: 8),
                    ListBox(children: [
                      if (d == null || d.$1.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Henüz deneme yok.', style: T.pBodySoft),
                        )
                      else
                        for (var i = 0; i < d.$1.length; i++)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              border: i == d.$1.length - 1
                                  ? null
                                  : const Border(
                                      bottom: BorderSide(
                                          color: K.lineSoft, width: 2)),
                            ),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 84,
                                    child: Text(_day(d.$1[i].day),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: K.ink2)),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        EmojiText('“${d.$1[i].prompt}”',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: K.ink)),
                                        const SizedBox(height: 2),
                                        Text(
                                            _result[d.$1[i].result] ??
                                                d.$1[i].result,
                                            style: T.pSmall),
                                      ],
                                    ),
                                  ),
                                ]),
                          ),
                    ]),
                    const SizedBox(height: 16),
                    DkCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const DkIcon(DkIcons.house,
                              size: 24, color: K.homeTip),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Evde deneyin', style: T.pStrong),
                                const SizedBox(height: 4),
                                EmojiText(d?.$2 ?? '', style: T.pBody),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

/// D5 Ayarlar.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = app.settings;
    return Scaffold(
      backgroundColor: K.bgParent,
      body: SafeArea(
        child: Column(children: [
          ParentHeader(
              title: 'Ayarlar', onBack: () => Navigator.of(context).pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DailyLimitCard(
                  parent: true,
                  value: s.dailyLimitMinutes,
                  onChanged: (v) =>
                      app.updateSettings(s.copyWith(dailyLimitMinutes: v)),
                  help:
                      'Süre dolmadan 2 soru önce çocuğa yumuşak bir uyarı gösterilir.',
                ),
                const SizedBox(height: 12),
                ListBox(children: [
                  ToggleRow(
                    key: const Key('set-quiet'),
                    boxed: false,
                    parent: true,
                    title: 'Sessiz saatler',
                    subtitle: '21.00–07.00 arası çalışma kapalı',
                    value: s.quietEnabled,
                    onChanged: (v) => app.updateSettings(s.withQuiet(v)),
                  ),
                  const Divider(height: 2, thickness: 2, color: K.lineSoft),
                  ToggleRow(
                    key: const Key('set-sound'),
                    boxed: false,
                    parent: true,
                    title: 'Ses ve sesli okuma',
                    subtitle: app.speaker.available || !s.soundOn
                        ? 'Yönergeler sıcak, yavaş bir sesle okunur'
                        : 'Bu cihazda Türkçe ses bulunamadı. Cihaz ayarlarından Türkçe metin okuma sesi yüklenebilir.',
                    value: s.soundOn,
                    onChanged: (v) =>
                        app.updateSettings(s.copyWith(soundOn: v)),
                  ),
                  const Divider(height: 2, thickness: 2, color: K.lineSoft),
                  ToggleRow(
                    key: const Key('set-reduce'),
                    boxed: false,
                    parent: true,
                    title: 'Hareketi azalt',
                    subtitle: 'Zıplama ve konfeti durur; geçişler solar',
                    value: s.reduceMotion,
                    onChanged: (v) =>
                        app.updateSettings(s.copyWith(reduceMotion: v)),
                  ),
                ]),
                const SizedBox(height: 12),
                DkCard(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Yazı boyutu', style: T.pStrong),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: K.ink, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Row(children: [
                          for (final (i, t) in const [
                            (0, 'Normal'),
                            (1, 'Büyük'),
                            (2, 'En büyük')
                          ])
                            Expanded(
                              child: Pressable(
                                key: Key('text-size-$i'),
                                onTap: () =>
                                    app.updateSettings(s.copyWith(textSize: i)),
                                selected: s.textSize == i,
                                label: t,
                                excludeChildSemantics: true,
                                focusRadius: 8,
                                builder: (context, down) => Container(
                                  height: 44,
                                  alignment: Alignment.center,
                                  color: s.textSize == i ? K.ink : K.card,
                                  child: Text(t,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: s.textSize == i
                                              ? Colors.white
                                              : K.ink)),
                                ),
                              ),
                            ),
                        ]),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: K.bg,
                            borderRadius: BorderRadius.circular(12)),
                        child: Text('Hangisi “on iki” sayısıdır?',
                            textScaler: TextScaler.linear(s.textScale),
                            style: const TextStyle(
                                fontSize: 19,
                                height: 1.35,
                                fontWeight: FontWeight.w800,
                                color: K.ink)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

/// D6 Profil yönetimi: düzenle (sınıf atlatma dahil), sil, ekle.
class ProfilesScreen extends StatelessWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      backgroundColor: K.bgParent,
      body: SafeArea(
        child: Column(children: [
          ParentHeader(
              title: 'Çocuk profilleri',
              onBack: () => Navigator.of(context).pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                    'Yeni eğitim yılında sınıfı buradan değiştirin. Önceki sınıfın tekrarları kaybolmaz.',
                    style: T.pSmall),
                const SizedBox(height: 12),
                ListBox(children: [
                  for (var i = 0; i < app.profiles.length; i++)
                    _ProfileRow(
                        profile: app.profiles[i],
                        last: i == app.profiles.length - 1),
                ]),
                const SizedBox(height: 16),
                if (app.profiles.length < 6)
                  ChunkyButton(
                    key: const Key('profiles-add'),
                    label: 'Çocuk ekle',
                    kind: BtnKind.secondary,
                    icon: DkIcons.plus,
                    onPressed: () => addChildFlow(context, gate: false),
                  ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.profile, required this.last});
  final ChildProfile profile;
  final bool last;

  Future<void> _edit(BuildContext context) async {
    final app = AppScope.read(context);
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (ctx) => ProfileFormScreen(
        kicker: 'PROFİLİ DÜZENLE',
        title: profile.nickname,
        submitLabel: 'Kaydet',
        initialName: profile.nickname,
        initialGrade: profile.grade,
        initialAvatar: profile.avatarIndex,
        onBack: () => Navigator.of(ctx).pop(),
        onSubmit: (r) async {
          await app.updateChild(profile.copyWith(
              nickname: r.nickname, grade: r.grade, avatar: r.avatar));
          if (ctx.mounted) Navigator.of(ctx).pop();
        },
      ),
    ));
  }

  Future<void> _delete(BuildContext context) async {
    final app = AppScope.read(context);
    final ok = await showDkSheet<bool>(
      context,
      builder: (ctx) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${profile.nickname} silinsin mi?',
              style: const TextStyle(
                  fontSize: 21, fontWeight: FontWeight.w900, color: K.ink)),
          const SizedBox(height: 8),
          const Text(
              'Profil ve tüm ilerleme kayıtları kalıcı olarak silinir. Önce yedek almanızı öneririz.',
              style: T.pBody),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: ChunkyButton(
                    label: 'Vazgeç',
                    kind: BtnKind.secondary,
                    onPressed: () => Navigator.pop(ctx, false))),
            const SizedBox(width: 10),
            Expanded(
              child: ChunkyButton(
                  key: const Key('confirm-delete-child'),
                  label: 'Evet, sil',
                  kind: BtnKind.again,
                  onPressed: () => Navigator.pop(ctx, true)),
            ),
          ]),
        ],
      ),
    );
    if (ok == true) {
      await app.deleteChild(profile.id);
      if (context.mounted && app.profiles.isEmpty) {
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: K.lineSoft, width: 2)),
        ),
        child: Row(children: [
          Avatar(index: profile.avatarIndex, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.nickname, style: T.pStrong),
                Text('${profile.grade}. sınıf', style: T.pSmall),
              ],
            ),
          ),
          CircleBtn(
              key: Key('edit-${profile.id}'),
              icon: DkIcons.pencil,
              label: '${profile.nickname} profilini düzenle',
              iconSize: 20,
              onPressed: () => _edit(context)),
          const SizedBox(width: 8),
          CircleBtn(
              key: Key('delete-${profile.id}'),
              icon: DkIcons.trash,
              label: '${profile.nickname} profilini sil',
              iconSize: 20,
              onPressed: () => _delete(context)),
        ]),
      );
}
