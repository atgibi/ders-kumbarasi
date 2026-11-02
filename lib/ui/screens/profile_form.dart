import 'package:flutter/material.dart';

import '../theme.dart';

class ProfileFormResult {
  const ProfileFormResult(this.nickname, this.grade, this.avatar);
  final String nickname;
  final int grade;
  final String avatar;
}

/// Çocuk profili formu: takma ad, sınıf, avatar. Gerçek ad istenmez.
class ProfileForm extends StatefulWidget {
  const ProfileForm({
    super.key,
    required this.onSubmit,
    this.initialName = '',
    this.initialGrade = 1,
    this.initialAvatar,
    this.submitLabel = 'Kaydet',
  });

  final void Function(ProfileFormResult) onSubmit;
  final String initialName;
  final int initialGrade;
  final String? initialAvatar;
  final String submitLabel;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late final TextEditingController _name =
      TextEditingController(text: widget.initialName);
  late int _grade = widget.initialGrade;
  late String _avatar = widget.initialAvatar ?? Kumbara.avatars.first;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _valid => _name.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('nickname'),
          controller: _name,
          maxLength: 16,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Takma ad',
            helperText: 'Gerçek ad gerekmez; çocuğun seveceği bir ad yeterli.',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        Text('Sınıf', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: [
            for (var g = 1; g <= 4; g++)
              ButtonSegment(value: g, label: Text('$g. sınıf')),
          ],
          selected: {_grade},
          onSelectionChanged: (s) => setState(() => _grade = s.first),
        ),
        const SizedBox(height: 16),
        Text('Avatar', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in Kumbara.avatars)
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _avatar = a),
                child: Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: a == _avatar
                        ? Kumbara.primary.withValues(alpha: 0.3)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: a == _avatar ? Kumbara.primary : Colors.black12,
                      width: a == _avatar ? 3 : 1,
                    ),
                  ),
                  child: Text(a, style: const TextStyle(fontSize: 34)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton(
          key: const Key('profile-submit'),
          onPressed: _valid
              ? () => widget.onSubmit(
                  ProfileFormResult(_name.text.trim(), _grade, _avatar))
              : null,
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}
