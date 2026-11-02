import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/mascot.dart';
import 'parent_gate.dart';
import 'parent_screen.dart';

/// "Kim çalışacak?" ekranı: şifresiz, avatarla giriş.
class ProfilePickerScreen extends StatelessWidget {
  const ProfilePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          TextButton.icon(
            key: const Key('parent-entry'),
            onPressed: () async {
              if (await showParentGate(context) && context.mounted) {
                await Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => const ParentScreen()));
              }
            },
            icon: const Icon(Icons.lock_rounded),
            label: const Text('Veli'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text('Kim çalışacak?',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    for (final p in app.profiles)
                      InkWell(
                        key: Key('profile-${p.id}'),
                        borderRadius: BorderRadius.circular(28),
                        onTap: () => app.selectChild(p),
                        child: Container(
                          width: 150,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border:
                                Border.all(color: Kumbara.primary, width: 3),
                          ),
                          child: Column(
                            children: [
                              Text(p.avatar,
                                  style: const TextStyle(fontSize: 64)),
                              const SizedBox(height: 8),
                              Text(p.nickname,
                                  style: Theme.of(context).textTheme.titleLarge,
                                  overflow: TextOverflow.ellipsis),
                              Text('${p.grade}. sınıf'),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
