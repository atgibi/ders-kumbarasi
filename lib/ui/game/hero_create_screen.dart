/// Kahraman oluşturma: kız/erkek → yol → görünüm.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../game/game_state.dart';
import '../../game/world.dart';
import '../theme.dart';
import '../widgets/emoji_text.dart';
import '../widgets/hand.dart';
import '../widgets/ikon.dart';
import '../widgets/kit.dart';
import '../widgets/mascot.dart';
import 'game_theme.dart';
import 'hero_figure.dart';
import 'hero_svg.dart';

class HeroCreateScreen extends StatefulWidget {
  const HeroCreateScreen(
      {super.key, required this.onDone, this.initial, this.onSave});

  /// Kahraman kaydedildikten sonra çağrılır.
  final void Function(BuildContext context) onDone;

  /// Kaydı başka biri yapacaksa (ilk açılışta profil + kahraman birlikte).
  final Future<void> Function(HeroLook look)? onSave;
  final HeroLook? initial;

  @override
  State<HeroCreateScreen> createState() => _HeroCreateScreenState();
}

class _HeroCreateScreenState extends State<HeroCreateScreen> {
  late HeroLook _look =
      widget.initial ?? const HeroLook(girl: true, path: 0, hair: 4);
  int _step = 0; // 0 kız/erkek, 1 yol, 2 görünüm
  bool _busy = false;

  String get _line => switch (_step) {
        0 =>
          'Diyarı bir sis kapladı. Bana yardım edecek kahraman sen misin? Önce seç: kız mı, erkek mi?',
        1 =>
          'Her kahramanın bir yolu ve bir yol arkadaşı var. Hiçbiri diğerinden güçlü değil. Hangisi sana benziyor?',
        _ => 'Şimdi kahramanını kendine benzet.',
      };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _say());
  }

  void _say() => AppScope.read(context).say(_line);

  void _go(int s) {
    setState(() => _step = s);
    _say();
  }

  Future<void> _finish() async {
    if (_busy) return;
    setState(() => _busy = true);
    final save = widget.onSave;
    if (save != null) {
      await save(_look);
    } else {
      await AppScope.read(context).saveHero(_look);
    }
    if (mounted) widget.onDone(context);
  }

  @override
  Widget build(BuildContext context) {
    final body = switch (_step) {
      0 => _gender(),
      1 => _paths(),
      _ => _appearance(),
    };
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _step > 0) _go(_step - 1);
      },
      child: Scaffold(
        backgroundColor: G.paper,
        body: SafeArea(
          child: ChildTextScale(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Mascot(size: 72, mood: MascotMood.normal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SpeechBubble(
                          tailLeft: 20,
                          child: Text(_line, style: G.body),
                        ),
                      ),
                      const SizedBox(width: 4),
                      ListenButton(onListen: _say),
                    ],
                  ),
                ),
                Expanded(child: body),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gender() {
    Widget card(bool girl) {
      final look = _look.copyWith(girl: girl, hair: girl ? 4 : 0);
      return Expanded(
        child: Pressable(
          key: Key(girl ? 'hero-girl' : 'hero-boy'),
          label: girl ? 'Kız kahraman' : 'Erkek kahraman',
          onTap: () {
            setState(() => _look = look);
            _go(1);
          },
          builder: (context, down) => Parchment(
            color: down ? G.paper2 : Colors.white,
            child: Column(children: [
              HeroFigure(look: look, size: 120, showCompanion: false),
              const SizedBox(height: 10),
              Text(girl ? 'Kız' : 'Erkek', style: G.title),
            ]),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('KAHRAMANINI SEÇ', style: G.kicker),
          const SizedBox(height: 12),
          Row(children: [card(true), const SizedBox(width: 14), card(false)]),
        ],
      ),
    );
  }

  Widget _paths() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                const Text('YOLUNU SEÇ', style: G.kicker),
                const SizedBox(height: 10),
                for (var i = 0; i < heroPaths.length; i++) ...[
                  _PathCard(
                    key: Key('hero-path-$i'),
                    path: heroPaths[i],
                    look: _look.copyWith(path: i),
                    selected: _look.path == i,
                    onTap: () =>
                        setState(() => _look = _look.copyWith(path: i)),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: ChunkyButton(
              key: const Key('hero-next'),
              label: '${_look.heroPath.name} olacağım',
              onPressed: () => _go(2),
            ),
          ),
        ],
      );

  int _tab = 1; // 0 ten, 1 saç biçimi, 2 saç rengi, 3 aksesuar, 4 sandalye

  /// Claude Design › 5 · Görünüm: solda kahraman, ortada seçenekler,
  /// sağda mühür sekmeler.
  Widget _appearance() {
    const tabs = [
      (
        'ten',
        'Ten rengi',
        'M16 5A11 11 0 1 1 15.9 5Z',
        '#E3AC82',
        'M12 15v1M20 15v1M12 21q4 3 8 0'
      ),
      (
        'sac',
        'Saç biçimi',
        'M5 18C4 4 28 4 27 18C24 11 8 11 5 18Z',
        '#3B2418',
        'M16 9A9 9 0 1 1 15.9 9Z'
      ),
      (
        'renk',
        'Saç rengi',
        'M16 4C21 11 24 15 24 19A8 8 0 0 1 8 19C8 15 11 11 16 4Z',
        '#8A4B2A',
        'M13 18q0 3 3 4'
      ),
      (
        'aks',
        'Gözlük, şapka, başörtüsü',
        'M4 12Q16 4 28 12Z',
        '#1F4E79',
        'M11 21A4.5 4.5 0 1 1 10.9 21M25 21A4.5 4.5 0 1 1 24.9 21M15 21q2 -2 4 0M4 12Q16 4 28 12'
      ),
      (
        'sandalye',
        'Tekerlekli sandalye',
        'M10 6A3 3 0 1 1 9.9 6Z',
        '#E3AC82',
        'M10 10V19H19L23 26M13 19A7 7 0 1 0 19 25M10 14H17'
      ),
    ];

    Widget ring(bool on, Widget child,
            {BorderRadius? radius, BoxShape shape = BoxShape.rectangle}) =>
        Container(
          decoration: BoxDecoration(
            shape: shape,
            borderRadius: shape == BoxShape.circle ? null : radius,
            border: Border.all(color: K.murekkep, width: 2.5),
            boxShadow: on
                ? const [BoxShadow(color: K.zumrutKoyu, spreadRadius: 5)]
                : null,
          ),
          child: child,
        );

    Widget swatch(
            String key, String label, bool on, Color color, VoidCallback pick,
            {bool round = true}) =>
        Pressable(
          key: Key(key),
          label: label,
          selected: on,
          onTap: () => setState(pick),
          builder: (context, down) => ring(
            on,
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                shape: round ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: round ? null : BorderRadius.circular(12),
              ),
            ),
            shape: round ? BoxShape.circle : BoxShape.rectangle,
            radius: BorderRadius.circular(14),
          ),
        );

    Widget choice(String key, String label, bool on, VoidCallback pick) =>
        Pressable(
          key: Key(key),
          label: label,
          selected: on,
          onTap: () => setState(pick),
          builder: (context, down) => ring(
            on,
            Container(
              constraints: const BoxConstraints(minHeight: 60),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: down ? K.kagit2 : K.kagit3,
              child: Text(label, style: G.body.copyWith(fontSize: 16)),
            ),
            radius: BorderRadius.circular(12),
          ),
        );

    Widget grid(List<Widget> items) => Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items,
        );

    final panel = switch (_tab) {
      0 => grid([
          for (var i = 0; i < skinTones.length; i++)
            swatch('skin-$i', skinNames[i], _look.skin == i, skinTones[i],
                () => _look = _look.copyWith(skin: i)),
        ]),
      1 => grid([
          for (var i = 0; i < hairStyles.length; i++)
            Pressable(
              key: Key('hair-$i'),
              label: 'Saç: ${hairStyles[i].$1}',
              selected: _look.hair == i,
              onTap: () => setState(() => _look = _look.copyWith(hair: i)),
              builder: (context, down) => ring(
                _look.hair == i,
                Container(
                  width: 52,
                  height: 52,
                  color: _look.hair == i ? const Color(0xFFF2D492) : K.kagit3,
                  child: SvgPicture.string(
                      hairChipSvg(i, _look.skin, _look.hairColor)),
                ),
                radius: BorderRadius.circular(12),
              ),
            ),
        ]),
      2 => grid([
          for (var i = 0; i < hairColors.length; i++)
            swatch(
                'haircolor-$i',
                'Saç rengi: ${hairColorNames[i]}',
                _look.hairColor == i,
                hairColors[i],
                () => _look = _look.copyWith(hairColor: i)),
        ]),
      3 => Column(children: [
          for (var i = 0; i < accessoryNames.length; i++) ...[
            choice('acc-$i', accessoryNames[i], _look.accessory == i,
                () => _look = _look.copyWith(accessory: i)),
            const SizedBox(height: 12),
          ],
        ]),
      _ => Column(children: [
          choice('chair-0', 'Ayakta', !_look.chair,
              () => _look = _look.copyWith(chair: false)),
          const SizedBox(height: 12),
          choice('chair-1', 'Tekerlekli sandalye', _look.chair,
              () => _look = _look.copyWith(chair: true)),
        ]),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Text('Nasıl görünsün?', style: G.title),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: HandBox(
                    style: HandStyle.el.copyWith(fill: K.kagit3),
                    padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
                    child: Column(children: [
                      const Spacer(),
                      HeroFigure(look: _look, size: 150, showCompanion: false),
                      const Kilim(),
                    ]),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 128,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(6),
                    child: Semantics(
                      container: true,
                      label: tabs[_tab].$2,
                      child: panel,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Column(children: [
                  for (var i = 0; i < tabs.length; i++) ...[
                    Pressable(
                      key: Key('look-tab-${tabs[i].$1}'),
                      label: tabs[i].$2,
                      selected: _tab == i,
                      onTap: () => setState(() => _tab = i),
                      builder: (context, down) => SizedBox(
                        width: 58,
                        height: 58,
                        child: CustomPaint(
                          painter: HandPainter(HandStyle.muhur
                              .copyWith(fill: _tab == i ? K.safran : K.kagit3)),
                          child: Center(
                            child: SvgPicture.string(
                              '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" fill="none" stroke="#2B2320" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">'
                              '<path d="${tabs[i].$3}" fill="${tabs[i].$4}"/><path d="${tabs[i].$5}"/></svg>',
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ]),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(children: [
            Expanded(
              child: Transform.rotate(
                angle: -.035,
                child: const Text('İstediğin zaman değiştirebilirsin.',
                    style: G.hand),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 164,
              child: ChunkyButton(
                key: const Key('hero-done'),
                label: 'Tamam',
                onPressed: _busy ? null : _finish,
              ),
            ),
          ]),
        ),
      ],
    );
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({
    super.key,
    required this.path,
    required this.look,
    required this.selected,
    required this.onTap,
  });
  final HeroPath path;
  final HeroLook look;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
        label: '${path.name}. ${path.trait}. Yol arkadaşı: ${path.companion}',
        selected: selected,
        onTap: onTap,
        builder: (context, down) => HandBox(
          style: HandStyle.kart.copyWith(
              fill: selected ? K.kagit3 : (down ? K.kagit2 : K.kagit),
              border: selected ? path.color : K.murekkep,
              borderWidth: selected ? 4 : 2.5,
              shadows: selected ? [(4, path.color)] : const []),
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            HeroFigure(look: look, size: 70),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(path.name, style: G.sub.copyWith(color: path.color)),
                  const SizedBox(height: 2),
                  Text(path.trait, style: G.body),
                  const SizedBox(height: 4),
                  EmojiText(
                      '${path.toolEmoji} ${path.tool} · ${path.companionEmoji} ${path.companion}',
                      style: G.soft),
                ],
              ),
            ),
            if (selected)
              SizedBox(
                width: 40,
                height: 40,
                child: CustomPaint(
                  painter:
                      HandPainter(HandStyle.muhur.copyWith(fill: K.zumrutKoyu)),
                  child: const Center(
                      child: IkonView(Ikon.tik, size: 22, light: true)),
                ),
              ),
          ]),
        ),
      );
}
