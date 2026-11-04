/// Sistem durumları (E1 sessiz saat, E2 süre doldu, E6 bugünün işi bitti)
/// ve oturum başlatma kapısı.
library;

import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../data/models.dart';
import '../theme.dart';
import '../widgets/dk_icon.dart';
import '../widgets/hand.dart';
import '../widgets/kit.dart';
import '../widgets/mascot.dart';
import 'parent_gate.dart';
import 'session_screen.dart';

enum SystemKind { quiet, timeUp, doneToday, nothing, error }

/// Oturumu açar; sessiz saat ya da süre dolduysa önce ilgili ekranı gösterir.
Future<void> openSession(
  BuildContext context, {
  required Subject subject,
  String? focusOutcome,
  bool reviewOnly = false,
  bool extraPractice = false,
  bool checkDoneToday = false,
}) async {
  final app = AppScope.read(context);
  final nav = Navigator.of(context);
  hideDkToast();
  SessionScreen session() => SessionScreen(
        subject: subject,
        focusOutcome: focusOutcome,
        reviewOnly: reviewOnly,
        extraPractice: extraPractice,
      );
  switch (app.startBlock()) {
    case StartBlock.quiet:
      await nav.push(MaterialPageRoute<void>(
          builder: (_) =>
              SystemScreen(kind: SystemKind.quiet, onOverride: session)));
      return;
    case StartBlock.timeUp:
      await nav.push(MaterialPageRoute<void>(
          builder: (_) => const SystemScreen(kind: SystemKind.timeUp)));
      return;
    case StartBlock.none:
      break;
  }
  if (checkDoneToday &&
      app.studiedToday &&
      await app.dueCount(subject) == 0 &&
      !(app.progress?.startedOutcomes.contains(focusOutcome) ?? false)) {
    await nav.push(MaterialPageRoute<void>(
        builder: (_) => SystemScreen(
              kind: SystemKind.doneToday,
              onExtra: () =>
                  SessionScreen(subject: subject, extraPractice: true),
            )));
    return;
  }
  await nav.push(MaterialPageRoute<void>(builder: (_) => session()));
}

class SystemScreen extends StatelessWidget {
  const SystemScreen({
    super.key,
    required this.kind,
    this.onOverride,
    this.onExtra,
    this.message,
  });

  final SystemKind kind;

  /// Sessiz saatte veli izniyle açılacak oturum.
  final Widget Function()? onOverride;

  /// "Bugünlük bu kadar" ekranında ekstra tekrar oturumu.
  final Widget Function()? onExtra;

  /// [SystemKind.nothing] ve [SystemKind.error] için metin.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final night = kind == SystemKind.quiet;
    final (
      MascotMood mood,
      String alt,
      String kicker,
      String title,
      String text
    ) = switch (kind) {
      SystemKind.quiet => (
          MascotMood.sleepy,
          'Anka uyuyor',
          'SESSİZ SAAT',
          'Anka uyuyor. Sabah görüşürüz!',
          'Uyku vakti. Yarın yeni bir yaprak seni bekliyor.',
        ),
      SystemKind.timeUp => (
          MascotMood.celebrate,
          'Anka mutlu',
          'BUGÜNLÜK SÜRE BİTTİ',
          'Bugünlük süremiz bitti. Yarın devam!',
          'Bugün ${app.settings.dailyLimitMinutes} dakika çalıştın. Şimdi gözlerini dinlendirme zamanı.',
        ),
      SystemKind.doneToday => (
          MascotMood.celebrate,
          'Anka kutluyor',
          'TÜM TEKRARLAR TAMAM',
          'Bugünlük bu kadar!',
          'Bugünkü tekrarları bitirdin. İstersen birkaç eski konuyu daha tazeleyebilirsin.',
        ),
      SystemKind.nothing => (
          MascotMood.normal,
          'Anka',
          'ŞİMDİLİK BOŞ',
          'Şu an yapılacak bir şey yok',
          message ?? 'Yeni konular öğrendikçe tekrarlar burada birikir.',
        ),
      SystemKind.error => (
          MascotMood.think,
          'Anka düşünüyor',
          'BİR AKSİLİK OLDU',
          'Bu ders şu an açılamadı',
          message ??
              'Başka bir dersle devam edebilirsin. Sorun sürerse bir büyüğüne haber ver.',
        ),
    };
    return Scaffold(
      backgroundColor: night ? K.night : K.bg,
      body: SafeArea(
        child: ChildTextScale(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 72,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ListenButton(onListen: () => app.say(title)),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Claude Design G31–G33: kemerli sahne, kilim
                          SizedBox(
                            height: 230,
                            width: double.infinity,
                            child: HandBox(
                              style: HandStyle(
                                  radii: const HandRadii(
                                      [120, 120, 14, 14], [96, 96, 14, 14]),
                                  fill: night ? const Color(0xFF2A3B55) : K.kagit3,
                                  border: night ? K.kagit3 : K.murekkep),
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                              child: Column(children: [
                                const Spacer(),
                                Mascot(mood: mood, size: 170, label: alt),
                                night ? const Kilim.lacivert() : const Kilim(),
                              ]),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(kicker,
                              style: T.kicker.copyWith(
                                  color: night ? K.nightKick : K.label)),
                          const SizedBox(height: 18),
                          Text(title,
                              style: T.big.copyWith(
                                  color: night ? K.kagit3 : K.lacivert)),
                          const SizedBox(height: 18),
                          Text(text,
                              style: T.body.copyWith(
                                  color: night ? K.nightSoft : K.ink2)),
                        ],
                      ),
                    ),
                  ),
                ),
                if (kind == SystemKind.doneToday && onExtra != null) ...[
                  ChunkyButton(
                    key: const Key('extra-review'),
                    label: 'Ekstra tekrar',
                    kind: BtnKind.secondary,
                    onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(builder: (_) => onExtra!())),
                  ),
                  const SizedBox(height: 7),
                ],
                ChunkyButton(
                  key: const Key('system-ok'),
                  label: 'Tamam',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                if (kind == SystemKind.quiet && onOverride != null)
                  TextBtn(
                    key: const Key('gate-override'),
                    label: 'Veli izniyle aç',
                    upper: false,
                    icon: DkIcons.lock,
                    fontSize: 15,
                    color: K.nightKick,
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      if (await showParentGate(context)) {
                        nav.pushReplacement(MaterialPageRoute<void>(
                            builder: (_) => onOverride!()));
                      }
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
