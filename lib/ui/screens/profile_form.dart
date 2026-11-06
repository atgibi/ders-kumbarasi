import 'package:flutter/material.dart';

import '../../data/progress_store.dart';
import '../theme.dart';
import '../widgets/avatar.dart';
import '../widgets/dk_icon.dart';
import '../widgets/kit.dart';

class ProfileFormResult {
  const ProfileFormResult(this.nickname, this.grade, this.avatar);
  final String nickname;
  final int grade;

  /// Avatar sırası ('0'..'11').
  final String avatar;
}

/// A3 Çocuk profili: ad ya da takma ad, sınıf, avatar. Soyad, fotoğraf,
/// e-posta istenmez.
class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({
    super.key,
    required this.onSubmit,
    required this.onBack,
    this.kicker = 'VELİ DOLDURUR · 1/3',
    this.title = 'Çocuğunuzu tanıyalım',
    this.submitLabel = 'Devam',
    this.initialName = '',
    this.initialGrade = 1,
    this.initialAvatar = 0,
  });

  final Future<void> Function(ProfileFormResult) onSubmit;
  final VoidCallback onBack;
  final String kicker;
  final String title;
  final String submitLabel;
  final String initialName;
  final int initialGrade;
  final int initialAvatar;

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  late final TextEditingController _name =
      TextEditingController(text: widget.initialName);
  late int _grade = widget.initialGrade;
  late int _avatar = widget.initialAvatar;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _valid => _name.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_valid || _busy) return;
    setState(() => _busy = true);
    try {
      await widget
          .onSubmit(ProfileFormResult(_name.text.trim(), _grade, '$_avatar'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      onPressed: widget.onBack),
                  const SizedBox(width: 12),
                  Expanded(child: Text(widget.kicker, style: T.kicker)),
                ]),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                children: [
                  Text(widget.title, style: T.title),
                  const SizedBox(height: 22),
                  const Text('Ad ya da takma ad', style: T.strong),
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('nickname'),
                    controller: _name,
                    maxLength: 24,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _submit(),
                    style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: K.ink),
                    decoration: InputDecoration(
                      hintText: 'ör. Elif',
                      hintStyle: const TextStyle(
                          color: K.inkSoft, fontWeight: FontWeight.w600),
                      counterText: '',
                      filled: true,
                      fillColor: K.card,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(K.rMd),
                        borderSide: const BorderSide(color: K.line, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(K.rMd),
                        borderSide:
                            const BorderSide(color: K.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                      'Yalnızca ilk ad yeterli. Soyad, fotoğraf ya da e-posta istemiyoruz.',
                      style: T.help),
                  const SizedBox(height: 22),
                  const Text('Sınıf', style: T.strong),
                  const Text('Bunu bir büyüğünle birlikte seç.',
                      style: TextStyle(
                          fontFamily: K.hand, fontSize: 16, color: K.inkSoft)),
                  const SizedBox(height: 8),
                  Row(children: [
                    for (var g = 1; g <= 4; g++) ...[
                      if (g > 1) const SizedBox(width: 10),
                      Expanded(
                        child: Pressable(
                          key: Key('grade-$g'),
                          onTap: () => setState(() => _grade = g),
                          selected: _grade == g,
                          label: '$g. sınıf',
                          excludeChildSemantics: true,
                          focusRadius: K.rMd,
                          builder: (context, down) => _GradeSeal(
                              grade: g, selected: _grade == g),
                        ),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 22),
                  const Text('Avatar', style: T.strong),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: .78,
                    children: [
                      for (var i = 0; i < avatarCount; i++)
                        Pressable(
                          key: Key('avatar-$i'),
                          onTap: () => setState(() => _avatar = i),
                          selected: _avatar == i,
                          label: avatarNames[i],
                          excludeChildSemantics: true,
                          focusRadius: 32,
                          builder: (context, down) => Column(
                            children: [
                              Avatar(
                                  index: i,
                                  size: 64,
                                  ring: _avatar == i ? 4 : 0),
                              const SizedBox(height: 4),
                              Text(avatarNames[i],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: K.inkSoft)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: K.line, width: 2))),
              child: ChunkyButton(
                key: const Key('profile-submit'),
                label: widget.submitLabel,
                onPressed: _valid && !_busy ? _submit : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Claude Design A07: sınıf düğmeleri renkli mühürler; seçilende zümrüt
/// halka ve tik.
class _GradeSeal extends StatelessWidget {
  const _GradeSeal({required this.grade, required this.selected});
  final int grade;
  final bool selected;

  static const _colors = [
    Color(0xFF9E3624),
    Color(0xFF1F4E79),
    Color(0xFF26664B),
    Color(0xFF7A5418),
  ];
  static const _tilt = [-0.07, 0.05, 0.035, -0.05];

  @override
  Widget build(BuildContext context) {
    const paper = Color(0xFFFBF5E8);
    return SizedBox(
      height: 84,
      child: Center(
        child: Transform.rotate(
          angle: _tilt[grade - 1],
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: _colors[grade - 1],
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: selected
                            ? const Color(0xFF26664B)
                            : const Color(0xFF2B2320),
                        width: selected ? 5 : 2.5),
                    boxShadow: const [
                      BoxShadow(color: Color(0xFF2B2320), offset: Offset(2, 3))
                    ],
                  ),
                  child: FittedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('$grade',
                            style: const TextStyle(
                                fontFamily: K.display,
                                fontSize: 34,
                                height: 1,
                                fontWeight: FontWeight.w900,
                                color: paper)),
                        const Text('sınıf',
                            style: TextStyle(
                                fontFamily: K.display,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: paper)),
                      ]),
                    ),
                  ),
                ),
              ),
              if (selected)
                Positioned(
                  right: -6,
                  top: -4,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                        color: Color(0xFF26664B), shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 18, color: paper),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
