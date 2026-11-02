import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../theme.dart';
import 'session_screen.dart';

/// Çocuğun ana ekranı: selam, seri, sınıfına ait dersler.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final child = app.active!;
    final progress = app.progress!;
    final t = Theme.of(context).textTheme;
    final now = app.clock();
    final quiet = app.settings.isQuietTime(now);
    final over = app.overDailyLimit;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          key: const Key('switch-profile'),
          tooltip: 'Profil değiştir',
          icon: const Icon(Icons.people_alt_rounded, size: 32),
          onPressed: app.signOutChild,
        ),
        actions: [
          IconButton(
            tooltip: app.settings.soundOn ? 'Sesi kapat' : 'Sesi aç',
            icon: Icon(
                app.settings.soundOn
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                size: 32),
            onPressed: () => app.updateSettings(
                app.settings.copyWith(soundOn: !app.settings.soundOn)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Row(
              children: [
                Text(child.avatar, style: const TextStyle(fontSize: 56)),
                const SizedBox(width: 12),
                Expanded(
                    child: Text('Merhaba ${child.nickname}!',
                        style: t.headlineMedium)),
              ],
            ),
            const SizedBox(height: 8),
            if (progress.streakDays > 0)
              Text(
                  '🔥 ${progress.streakDays} gündür kumbarana bilgi atıyorsun!',
                  style: t.bodyLarge),
            const SizedBox(height: 16),
            if (quiet || over)
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    quiet
                        ? '🌙 Şimdi dinlenme zamanı. Yarın görüşürüz!'
                        : '🌟 Bugünlük harika çalıştın! Gözlerini dinlendirme zamanı.',
                    style: t.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else ...[
              Text('Bugün hangi dersi çalışalım?', style: t.titleLarge),
              const SizedBox(height: 12),
              for (final s in Subject.forGrade(child.grade))
                _SubjectTile(subject: s),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({required this.subject});
  final Subject subject;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          key: Key('subject-${subject.id}'),
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => SessionScreen(subject: subject),
            ));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Text(subject.icon, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(subject.label,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                FutureBuilder<int>(
                  future: app.dueCount(subject),
                  builder: (context, snap) {
                    final n = snap.data ?? 0;
                    if (n == 0) {
                      return const Icon(Icons.play_circle_fill_rounded,
                          size: 40, color: Kumbara.primary);
                    }
                    return Chip(
                      label: Text('$n tekrar'),
                      backgroundColor: Kumbara.primary.withValues(alpha: 0.25),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
