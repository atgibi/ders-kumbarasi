import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/avatar.dart';
import '../widgets/dk_icon.dart';
import '../widgets/kit.dart';
import 'parent_gate.dart';
import 'profile_form.dart';

/// B1 Profil seçici: "Kim çalışacak?"
class ProfilePickerScreen extends StatelessWidget {
  const ProfilePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      backgroundColor: K.bg,
      body: SafeArea(
        child: ChildTextScale(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              SizedBox(
                height: 72,
                child: Row(children: [
                  const Expanded(child: Text('Kim çalışacak?', style: T.title)),
                  ListenButton(onListen: () => app.say('Kim çalışacak?')),
                ]),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(builder: (context, box) {
                final cols = box.maxWidth > 560 ? 3 : 2;
                final w = (box.maxWidth - 14 * (cols - 1)) / cols;
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (final p in app.profiles)
                      SizedBox(
                        width: w,
                        child: Pressable(
                          key: Key('kid-${p.id}'),
                          onTap: () => app.selectChild(p),
                          label: '${p.nickname}, ${p.grade}. sınıf',
                          excludeChildSemantics: true,
                          builder: (context, down) => Padding(
                            padding: EdgeInsets.only(
                                top: down ? 5 : 0, bottom: down ? 0 : 5),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 200),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: K.card,
                                borderRadius: BorderRadius.circular(K.rLg),
                                border: Border.all(color: K.line, width: 2),
                                boxShadow: down
                                    ? null
                                    : const [
                                        BoxShadow(
                                            color: K.line, offset: Offset(0, 5))
                                      ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Avatar(index: p.avatarIndex, size: 96),
                                  const SizedBox(height: 10),
                                  Text(p.nickname,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          color: K.ink)),
                                  const SizedBox(height: 4),
                                  Text('${p.grade}. sınıf',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: K.inkSoft)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (app.profiles.length < 6)
                      SizedBox(
                        width: w,
                        child: Pressable(
                          key: const Key('add-child'),
                          onTap: () => addChildFlow(context),
                          label: 'Çocuk ekle, veli izniyle',
                          excludeChildSemantics: true,
                          builder: (context, down) => DashedBox(
                            color: const Color(0xFFCFC6B9),
                            fill: down ? K.closeBg : K.bg,
                            radius: K.rLg,
                            minHeight: 200,
                            padding: const EdgeInsets.all(16),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: K.stone,
                                  child: DkIcon(DkIcons.plus,
                                      size: 30, color: K.inkSoft),
                                ),
                                SizedBox(height: 10),
                                Text('Çocuk ekle',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: K.inkSoft)),
                                SizedBox(height: 4),
                                Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 4,
                                    children: [
                                      DkIcon(DkIcons.lock,
                                          size: 14, color: K.inkSoft),
                                      Text('Veli izniyle',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: K.inkSoft)),
                                    ]),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/// Veli kapısı + çocuk profili formu.
Future<void> addChildFlow(BuildContext context, {bool gate = true}) async {
  final app = AppScope.read(context);
  final nav = Navigator.of(context);
  if (gate && !await showParentGate(context)) return;
  await nav.push(MaterialPageRoute<void>(
    builder: (ctx) => ProfileFormScreen(
      kicker: 'YENİ ÇOCUK',
      title: 'Çocuğunuzu tanıyalım',
      submitLabel: 'Kaydet',
      onBack: () => Navigator.of(ctx).pop(),
      onSubmit: (r) async {
        await app.addChild(r.nickname, r.grade, r.avatar);
        if (ctx.mounted) Navigator.of(ctx).pop();
      },
    ),
  ));
}
