import 'package:flutter/material.dart';

import '../../core/srs/leitner.dart';
import '../../data/models.dart';
import '../../data/progress_store.dart';
import '../theme.dart';
import 'profile_form.dart';

/// Veli paneli: çocukların çıktı bazlı gelişimi, ayarlar, veri silme.
class ParentScreen extends StatelessWidget {
  const ParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = app.settings;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Veli paneli')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Çocuklar', style: t.titleLarge),
          for (final p in app.profiles)
            Card(
              child: ListTile(
                leading: Text(p.avatar, style: const TextStyle(fontSize: 32)),
                title: Text(p.nickname),
                subtitle: Text('${p.grade}. sınıf'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => ChildReportScreen(profile: p))),
              ),
            ),
          if (app.profiles.length < 4)
            TextButton.icon(
              key: const Key('add-child'),
              icon: const Icon(Icons.add),
              label: const Text('Çocuk ekle'),
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Çocuk ekle')),
                  body: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Builder(
                        builder: (ctx) => ProfileForm(onSubmit: (r) async {
                          await app.addChild(r.nickname, r.grade, r.avatar);
                          if (ctx.mounted) Navigator.of(ctx).pop();
                        }),
                      ),
                    ],
                  ),
                ),
              )),
            ),
          const Divider(height: 32),
          Text('Süre ve saatler', style: t.titleLarge),
          ListTile(
            title: const Text('Günlük süre sınırı'),
            subtitle: Text('${s.dailyLimitMinutes} dakika'),
          ),
          Slider(
            value: s.dailyLimitMinutes.toDouble(),
            min: 10,
            max: 60,
            divisions: 10,
            label: '${s.dailyLimitMinutes} dk',
            onChanged: (v) =>
                app.updateSettings(s.copyWith(dailyLimitMinutes: v.round())),
          ),
          SwitchListTile(
            title: const Text('Sessiz saatler (21:00–07:00)'),
            subtitle: const Text('Bu saatlerde çalışma ekranı kapalıdır.'),
            value: s.quietStartHour != s.quietEndHour,
            onChanged: (on) => app.updateSettings(on
                ? s.copyWith(quietStartHour: 21, quietEndHour: 7)
                : s.copyWith(quietStartHour: 0, quietEndHour: 0)),
          ),
          SwitchListTile(
            title: const Text('Sesli okuma'),
            subtitle: Text(app.speaker.available
                ? 'Yönergeler cihazın Türkçe sesiyle okunur.'
                : 'Bu cihazda Türkçe ses bulunamadı ya da henüz denenmedi. '
                    'Cihaz ayarlarından Türkçe metin okuma sesi yüklenebilir.'),
            value: s.soundOn,
            onChanged: (v) => app.updateSettings(s.copyWith(soundOn: v)),
          ),
          const Divider(height: 32),
          Text('Gizlilik', style: t.titleLarge),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Ders Kumbarası hiçbir veriyi internete göndermez. Takma ad, sınıf ve '
              'çalışma kayıtları yalnızca bu cihazda saklanır. Uygulama silindiğinde '
              'tüm veriler de silinir.',
            ),
          ),
          OutlinedButton.icon(
            key: const Key('delete-all'),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Tüm verileri sil'),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Tüm veriler silinsin mi?'),
                  content: const Text(
                      'Bütün çocuk profilleri ve ilerleme kayıtları kalıcı olarak silinir.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Vazgeç')),
                    FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Sil')),
                  ],
                ),
              );
              if (ok == true) {
                await app.deleteAll();
                if (context.mounted) {
                  Navigator.of(context).popUntil((r) => r.isFirst);
                }
              }
            },
          ),
          const SizedBox(height: 24),
          Text(
            'İçerikler T.C. Millî Eğitim Bakanlığı Türkiye Yüzyılı Maarif Modeli öğretim '
            'programlarındaki öğrenme çıktılarına göre hazırlanmıştır. Uygulama MEB ile '
            'bağlantılı değildir.',
            style: t.bodySmall,
          ),
        ],
      ),
    );
  }
}

const _levelText = {
  MasteryLevel.notStarted: 'Başlanmadı',
  MasteryLevel.beginning: 'Başlangıç',
  MasteryLevel.developing: 'Gelişiyor',
  MasteryLevel.sufficient: 'Yeterli',
};

const _levelColor = {
  MasteryLevel.notStarted: Colors.black26,
  MasteryLevel.beginning: Color(0xFFE8B04A),
  MasteryLevel.developing: Color(0xFF4A7BD0),
  MasteryLevel.sufficient: Color(0xFF2E9E6B),
};

/// Bir çocuğun ders ve öğrenme çıktısı bazında gelişimi (not/puan yok).
class ChildReportScreen extends StatefulWidget {
  const ChildReportScreen({super.key, required this.profile});
  final ChildProfile profile;

  @override
  State<ChildReportScreen> createState() => _ChildReportScreenState();
}

class _ChildReportScreenState extends State<ChildReportScreen> {
  ChildProgress? _progress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final p =
          await AppScope.read(context).store.loadProgress(widget.profile.id);
      if (mounted) setState(() => _progress = p);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final p = widget.profile;
    final progress = _progress;
    return Scaffold(
      appBar: AppBar(
        title: Text('${p.avatar} ${p.nickname}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'edit') {
                await Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (ctx) => Scaffold(
                    appBar: AppBar(title: const Text('Profili düzenle')),
                    body:
                        ListView(padding: const EdgeInsets.all(16), children: [
                      ProfileForm(
                        initialName: p.nickname,
                        initialGrade: p.grade,
                        initialAvatar: p.avatar,
                        onSubmit: (r) async {
                          await app.updateChild(p.copyWith(
                              nickname: r.nickname,
                              grade: r.grade,
                              avatar: r.avatar));
                          if (ctx.mounted) Navigator.of(ctx).pop();
                        },
                      ),
                    ]),
                  ),
                ));
                if (context.mounted) Navigator.of(context).pop();
              } else if (v == 'delete') {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('${p.nickname} silinsin mi?'),
                    content: const Text(
                        'Profil ve tüm ilerleme kayıtları kalıcı olarak silinir.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Vazgeç')),
                      FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Sil')),
                    ],
                  ),
                );
                if (ok == true) {
                  await app.deleteChild(p.id);
                  if (context.mounted) Navigator.of(context).pop();
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Profili düzenle')),
              PopupMenuItem(value: 'delete', child: Text('Profili sil')),
            ],
          ),
        ],
      ),
      body: progress == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Stats(progress: progress),
                const SizedBox(height: 8),
                const Text(
                    'Her öğrenme çıktısı dört düzeyle gösterilir: başlanmadı, '
                    'başlangıç, gelişiyor, yeterli. Bu bir not değildir.'),
                const SizedBox(height: 8),
                for (final s in Subject.forGrade(p.grade))
                  FutureBuilder<Map<Outcome, MasteryLevel>>(
                    future: app.masteryMap(p, progress, s),
                    builder: (context, snap) {
                      final m = snap.data;
                      if (m == null) return const SizedBox(height: 48);
                      final done = m.values
                          .where((l) => l == MasteryLevel.sufficient)
                          .length;
                      return Card(
                        child: ExpansionTile(
                          leading: Text(s.icon,
                              style: const TextStyle(fontSize: 28)),
                          title: Text(s.label),
                          subtitle: Text('$done / ${m.length} çıktı yeterli'),
                          children: [
                            for (final e in m.entries)
                              ListTile(
                                dense: true,
                                leading: Icon(Icons.circle,
                                    size: 14, color: _levelColor[e.value]),
                                title: Text(e.key.title),
                                subtitle: Text(
                                    '${e.key.code} · ${_levelText[e.value]}'),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.progress});
  final ChildProgress progress;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    var week = 0;
    for (var i = 0; i < 7; i++) {
      week +=
          progress.dailyMinutes[dayKey(now.subtract(Duration(days: i)))] ?? 0;
    }
    final learned = progress.cards.values.where((c) => c.isMastered).length;
    Widget box(String v, String l) => Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                Text(v, style: Theme.of(context).textTheme.titleLarge),
                Text(l, textAlign: TextAlign.center),
              ]),
            ),
          ),
        );
    return Row(children: [
      box('$week dk', 'son 7 gün'),
      box('${progress.streakDays}', 'günlük seri'),
      box('$learned', 'kalıcı öğrenilen kart'),
    ]);
  }
}
