/// Kahraman oluşturma: kız/erkek → yol → görünüm.
library;

import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../game/game_state.dart';
import '../../game/world.dart';
import '../theme.dart';
import '../widgets/emoji_text.dart';
import '../widgets/kit.dart';
import '../widgets/mascot.dart';
import 'game_theme.dart';
import 'hero_figure.dart';

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
      widget.initial ?? const HeroLook(girl: true, path: 0, hair: 1);
  int _step = 0; // 0 kız/erkek, 1 yol, 2 görünüm
  bool _busy = false;

  String get _line => switch (_step) {
        0 => 'Diyarı bir sis kapladı. Bana yardım edecek kahraman sen misin? Önce seç: kız mı, erkek mi?',
        1 => 'Her kahramanın bir yolu ve bir yol arkadaşı var. Hiçbiri diğerinden güçlü değil. Hangisi sana benziyor?',
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
      final look = _look.copyWith(girl: girl, hair: girl ? 1 : 0);
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
                    onTap: () => setState(() => _look = _look.copyWith(path: i)),
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

  Widget _appearance() {
    Widget row(String title, int count, int selected, Widget Function(int) item,
            void Function(int) pick, String key) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: G.sub),
            const SizedBox(height: 8),
            Wrap(spacing: 10, runSpacing: 10, children: [
              for (var i = 0; i < count; i++)
                Pressable(
                  key: Key('$key-$i'),
                  label: '$title ${i + 1}',
                  selected: i == selected,
                  onTap: () => setState(() => pick(i)),
                  builder: (context, down) => Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: i == selected ? G.madder : G.paper2,
                          width: i == selected ? 4 : 2),
                    ),
                    child: item(i),
                  ),
                ),
            ]),
            const SizedBox(height: 18),
          ],
        );

    const hairNames = ['Kısa', 'Uzun', 'Örgü', 'Kıvırcık', 'Başörtüsü', 'Şapka'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              Center(child: HeroFigure(look: _look, size: 150)),
              const SizedBox(height: 12),
              row('Ten rengi', skinTones.length, _look.skin,
                  (i) => CircleAvatar(radius: 20, backgroundColor: skinTones[i]),
                  (i) => _look = _look.copyWith(skin: i), 'skin'),
              row(
                  'Saç',
                  hairNames.length,
                  _look.hair,
                  (i) => Text(hairNames[i],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w800, color: G.ink)),
                  (i) => _look = _look.copyWith(hair: i),
                  'hair'),
              row('Saç rengi', hairColors.length, _look.hairColor,
                  (i) => CircleAvatar(radius: 20, backgroundColor: hairColors[i]),
                  (i) => _look = _look.copyWith(hairColor: i), 'haircolor'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: ChunkyButton(
            key: const Key('hero-done'),
            label: 'Maceraya başla',
            onPressed: _busy ? null : _finish,
          ),
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
        builder: (context, down) => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : G.paper,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: selected ? path.color : G.paper2, width: selected ? 4 : 2),
          ),
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
                  EmojiText('${path.toolEmoji} ${path.tool} · ${path.companionEmoji} ${path.companion}',
                      style: G.soft),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: K.good, size: 30),
          ]),
        ),
      );
}
