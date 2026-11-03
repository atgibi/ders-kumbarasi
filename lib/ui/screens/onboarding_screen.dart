import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../data/models.dart';
import '../theme.dart';
import '../widgets/dk_icon.dart';
import '../widgets/kit.dart';
import '../widgets/mascot.dart';
import 'profile_form.dart';
import 'session_screen.dart';

/// İlk açılış (A1–A6). Veli doldurur; çocuk profili en sonda kaydedilir.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0; // 0 A1, 1 A2, 2 A3, 3 A4, 4 A5, 5 A6
  int _how = 0;
  ProfileFormResult? _profile;
  late AppSettings _settings = AppScope.read(context).settings;
  bool _busy = false;

  void _go(int s) => setState(() => _step = s);

  Future<void> _finish() async {
    if (_busy) return;
    setState(() => _busy = true);
    final app = AppScope.read(context);
    final nav = Navigator.of(context);
    final r = _profile!;
    await app.updateSettings(_settings.copyWith(onboarded: true));
    final child = await app.addChild(r.nickname, r.grade, r.avatar);
    await app.selectChild(child);
    // İlk ders: sıradaki ilk konu (anlatım + kısa alıştırma)
    final subject = app.subject ?? Subject.forGrade(r.grade).first;
    final outcomes = await app.content.outcomesFor(subject, r.grade);
    final pack = await app.content.contentFor(subject, r.grade);
    final first = outcomes
        .where((o) => pack[o.code]?.cards.isNotEmpty ?? false)
        .map((o) => o.code)
        .firstOrNull;
    nav.push(MaterialPageRoute<void>(
        builder: (_) => SessionScreen(subject: subject, focusOutcome: first)));
  }

  @override
  Widget build(BuildContext context) {
    final body = switch (_step) {
      0 => _welcome(),
      1 => _howItWorks(),
      2 => ProfileFormScreen(
          initialName: _profile?.nickname ?? '',
          initialGrade: _profile?.grade ?? 1,
          initialAvatar: int.tryParse(_profile?.avatar ?? '') ?? 0,
          onBack: () => _go(1),
          onSubmit: (r) async {
            _profile = r;
            _go(3);
          },
        ),
      3 => _settingsStep(),
      4 => _privacy(),
      _ => _ready(),
    };
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step > 0) _go(_step - 1);
      },
      child: ChildTextScale(
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: reduceMotion(context) ? 0 : 250),
          child: KeyedSubtree(key: ValueKey(_step), child: body),
        ),
      ),
    );
  }

  Widget _page({required List<Widget> children, Widget? bottom}) => Scaffold(
        backgroundColor: K.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...children,
                if (bottom != null) bottom,
              ],
            ),
          ),
        ),
      );

  Widget _welcome() => _page(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Mascot(size: 190, label: 'Fındık'),
                    SizedBox(height: 18),
                    Text('DERS KUMBARASI', style: T.kicker),
                    SizedBox(height: 18),
                    Text('Her gün 10 dakika, kalıcı öğrenme', style: T.hero),
                    SizedBox(height: 18),
                    Text(
                        '1–4. sınıf için kısa konu anlatımları ve akıllı tekrar.',
                        style: T.bodySoft),
                  ],
                ),
              ),
            ),
          ),
        ],
        bottom: ChunkyButton(
            key: const Key('onboarding-start'),
            label: 'Başla',
            onPressed: () => _go(1)),
      );

  static const _cards = [
    (
      DkIcons.book,
      'Kısa konu anlatımı',
      'Her konu 2–4 sayfalık resimli bir anlatımla başlar. Fındık her sayfayı sesli okur.',
      K.peach,
      K.label
    ),
    (
      DkIcons.check,
      'Alıştırma',
      'Ardından birkaç kısa soru gelir. Yanlış cevap ceza değildir; doğrusu hemen gösterilir.',
      K.goodBg,
      K.goodInk
    ),
    (
      DkIcons.again,
      'Akıllı tekrar',
      'Unutulmaya başlayan konular tam zamanında geri gelir. Böylece bilgi kumbarada kalır.',
      K.againBg,
      K.againInk
    ),
  ];

  Widget _howItWorks() {
    final c = _cards[_how];
    return _page(
      children: [
        SizedBox(
          height: 64,
          child: Row(children: [
            CircleBtn(
                key: const Key('back'),
                icon: DkIcons.left,
                label: 'Geri',
                onPressed: () => _how > 0 ? setState(() => _how--) : _go(0)),
            const Spacer(),
            TextBtn(
                key: const Key('skip'),
                label: 'Atla',
                color: K.inkSoft,
                fontSize: 16,
                onPressed: () => _go(2)),
          ]),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 260,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: c.$4, borderRadius: BorderRadius.circular(K.rLg)),
                  child: DkIcon(c.$1, size: 96, color: c.$5, stroke: 2),
                ),
                const SizedBox(height: 18),
                Text('${_how + 1} / 3', style: T.kicker),
                const SizedBox(height: 18),
                Text(c.$2, style: T.title),
                const SizedBox(height: 18),
                Text(c.$3, style: T.body.copyWith(color: K.ink2)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Dots(count: 3, index: _how),
        const SizedBox(height: 20),
      ],
      bottom: ChunkyButton(
        key: const Key('onboarding-next'),
        label: 'İleri',
        onPressed: () => _how < 2 ? setState(() => _how++) : _go(2),
      ),
    );
  }

  Widget _formPage(
      {required String kicker,
      required VoidCallback onBack,
      required List<Widget> children,
      required Widget button}) {
    return Scaffold(
      backgroundColor: K.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  CircleBtn(
                      key: const Key('back'),
                      icon: DkIcons.left,
                      label: 'Geri',
                      onPressed: onBack),
                  const SizedBox(width: 12),
                  Text(kicker, style: T.kicker),
                ]),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                children: children,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: K.line, width: 2))),
              child: button,
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsStep() => _formPage(
        kicker: 'VELİ DOLDURUR · 2/3',
        onBack: () => _go(2),
        children: [
          const Text('Süre ve saatler', style: T.title),
          const SizedBox(height: 16),
          Text('Bunları daha sonra veli alanından değiştirebilirsiniz.',
              style: T.strong.copyWith(
                  fontWeight: FontWeight.w400, color: K.ink2, height: 24 / 17)),
          const SizedBox(height: 16),
          DailyLimitCard(
            value: _settings.dailyLimitMinutes,
            onChanged: (v) => setState(
                () => _settings = _settings.copyWith(dailyLimitMinutes: v)),
            help:
                'Süre dolarsa oturum yarıda kesilmez; bitince dinlenme ekranı gelir.',
          ),
          const SizedBox(height: 16),
          ToggleRow(
            key: const Key('quiet-toggle'),
            icon: DkIcons.moon,
            title: 'Sessiz saatler',
            subtitle: '21.00–07.00 arası çalışma kapalı',
            value: _settings.quietEnabled,
            onChanged: (v) =>
                setState(() => _settings = _settings.withQuiet(v)),
          ),
          const SizedBox(height: 16),
          ToggleRow(
            key: const Key('sound-toggle'),
            icon: DkIcons.volume,
            title: 'Ses ve sesli okuma',
            subtitle: 'Kapalıyken her şey görsel olarak da anlaşılır',
            value: _settings.soundOn,
            onChanged: (v) =>
                setState(() => _settings = _settings.copyWith(soundOn: v)),
          ),
        ],
        button: ChunkyButton(
            key: const Key('settings-next'),
            label: 'Devam',
            onPressed: () => _go(4)),
      );

  static const _privacyItems = [
    (
      DkIcons.shield,
      'Veriler bu cihazda kalır',
      'Hiçbir bilgi internete gönderilmez. Uygulama silinince kayıtlar da silinir.'
    ),
    (
      DkIcons.x,
      'Reklam ve satın alma yok',
      'Çocuğunuz hiçbir reklam, ödeme ya da dış bağlantı görmez.'
    ),
    (
      DkIcons.user,
      'Hesap gerekmez',
      'E-posta, telefon ya da fotoğraf istemiyoruz. İlk ad ve sınıf yeterli.'
    ),
  ];

  Widget _privacy() => _formPage(
        kicker: 'VELİ DOLDURUR · 3/3',
        onBack: () => _go(3),
        children: [
          const Text('Verileriniz cihazda kalır', style: T.title),
          const SizedBox(height: 20),
          for (final p in _privacyItems) ...[
            DkCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: K.goodBg,
                        borderRadius: BorderRadius.circular(14)),
                    child: DkIcon(p.$1, size: 26, color: K.goodInk),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.$2,
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: K.ink)),
                        const SizedBox(height: 2),
                        Text(p.$3, style: T.pBodySoft),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ],
        button: ChunkyButton(
            key: const Key('privacy-ok'),
            label: 'Anladım',
            onPressed: () => _go(5)),
      );

  Widget _ready() {
    final name = _profile?.nickname ?? '';
    final app = AppScope.read(context);
    return _page(
      children: [
        SizedBox(
          height: 72,
          child: Align(
            alignment: Alignment.centerRight,
            child: ListenButton(onListen: () => app.say('Hazır mısın, $name?')),
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: SpeechBubble(
                        child: Text('Hazır mısın, $name?', style: T.title)),
                  ),
                  const SizedBox(height: 32),
                  const Mascot(
                      mood: MascotMood.celebrate,
                      size: 220,
                      label: 'Fındık sevinçle bekliyor'),
                ],
              ),
            ),
          ),
        ),
      ],
      bottom: ChunkyButton(
          key: const Key('first-lesson'),
          label: 'İlk dersim',
          onPressed: _busy ? null : _finish),
    );
  }
}

/// Günlük süre kaydırıcısı (A4 ve D5).
class DailyLimitCard extends StatelessWidget {
  const DailyLimitCard(
      {super.key,
      required this.value,
      required this.onChanged,
      required this.help,
      this.parent = false});
  final int value;
  final ValueChanged<int> onChanged;
  final String help;
  final bool parent;

  @override
  Widget build(BuildContext context) => DkCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                    child: Text('Günlük süre',
                        style: parent ? T.pStrong : T.strong)),
                Text('$value dk',
                    style: TextStyle(
                        fontSize: parent ? 19 : 21,
                        fontWeight: FontWeight.w900,
                        color: K.ink)),
              ],
            ),
            Slider(
              key: const Key('daily-slider'),
              value: value.toDouble().clamp(5, 60),
              min: 5,
              max: 60,
              divisions: 11,
              label: '$value dk',
              semanticFormatterCallback: (v) => '${v.round()} dakika',
              onChanged: (v) => onChanged(v.round()),
            ),
            Text(help, style: parent ? T.pSmall : T.help),
          ],
        ),
      );
}
