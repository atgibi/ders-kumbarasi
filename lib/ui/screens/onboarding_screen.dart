import 'package:flutter/material.dart';

import '../theme.dart';
import 'profile_form.dart';

/// İlk kurulum (veli için): uygulamanın ne yaptığını ve veriyi nasıl
/// sakladığını sade dille anlatır, ardından ilk çocuk profilini oluşturur.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _accepted = false;
  bool _showForm = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: _showForm
                  ? [
                      Text('Çocuğunuzun profili', style: t.headlineMedium),
                      const SizedBox(height: 16),
                      ProfileForm(
                        submitLabel: 'Başlayalım',
                        onSubmit: (r) => AppScope.read(context)
                            .addChild(r.nickname, r.grade, r.avatar),
                      ),
                    ]
                  : [
                      const Center(
                          child: Text('🐷🪙', style: TextStyle(fontSize: 72))),
                      const SizedBox(height: 8),
                      Center(
                          child:
                              Text('Ders Kumbarası', style: t.headlineMedium)),
                      const SizedBox(height: 16),
                      Text(
                        'Her gün 10–15 dakika: kısa bir konu anlatımı, birkaç soru ve '
                        'unutulmaya başlayan konuların tam zamanında tekrarı. İçerikler '
                        'Türkiye Yüzyılı Maarif Modeli öğretim programlarına göre hazırlanır.',
                        style: t.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      const _Fact('📱',
                          'Tüm veriler yalnızca bu cihazda tutulur. Hesap, e-posta veya telefon numarası istenmez.'),
                      const _Fact('🚫',
                          'Reklam yok, uygulama içi satın alma yok, çocuklar arası mesajlaşma yok.'),
                      const _Fact('⏱️',
                          'Günlük süre sınırı ve sessiz saatler veli panelinden ayarlanır (varsayılan 20 dakika, 21:00–07:00 kapalı).'),
                      const _Fact('🧑‍🧒',
                          'Veli paneline yalnızca yetişkinlerin çözebileceği bir soruyla girilir.'),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        key: const Key('accept'),
                        value: _accepted,
                        onChanged: (v) =>
                            setState(() => _accepted = v ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                            'Bu cihazı kullanacak çocuğun velisiyim; yukarıdaki bilgileri okudum.'),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        key: const Key('onboarding-next'),
                        onPressed: _accepted
                            ? () => setState(() => _showForm = true)
                            : null,
                        child: const Text('Devam'),
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.icon, this.text);
  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
                child:
                    Text(text, style: Theme.of(context).textTheme.bodyMedium)),
          ],
        ),
      );
}
