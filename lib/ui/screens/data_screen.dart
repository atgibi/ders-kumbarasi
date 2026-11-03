/// D7 Veri ve gizlilik, D8 Hakkında, gizlilik politikası.
library;

import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/version.dart';
import '../theme.dart';
import '../widgets/dk_icon.dart';
import '../widgets/kit.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  int _delStep = 0;
  String? _note;
  bool _noteOk = true;
  bool _busy = false;

  void _say(String text, {bool ok = true}) => setState(() {
        _note = text;
        _noteOk = ok;
      });

  Future<void> _backup() async {
    if (_busy) return;
    final app = AppScope.read(context);
    if (kIsWeb) {
      _say(
          'Yedekleme web sürümünde yok; telefon ya da tablet uygulamasını kullanın.',
          ok: false);
      return;
    }
    final box = context.findRenderObject() as RenderBox?;
    final origin =
        box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    setState(() => _busy = true);
    try {
      final json = await app.store.exportAll();
      final now = app.clock();
      String two(int n) => n.toString().padLeft(2, '0');
      final name =
          'ders-kumbarasi-yedek-${now.year}${two(now.month)}${two(now.day)}.json';
      await Share.shareXFiles(
        [
          XFile.fromData(utf8.encode(json),
              name: name, mimeType: 'application/json')
        ],
        fileNameOverrides: [name],
        subject: 'Ders Kumbarası yedeği',
        sharePositionOrigin: origin,
      );
      _say(
          'Yedek dosyası hazırlandı. Güvenli bir yere (ör. Dosyalar, Drive) kaydedin.');
    } on Object catch (e) {
      debugPrint('Yedekleme: $e');
      _say('Yedek hazırlanamadı. Lütfen tekrar deneyin.', ok: false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    if (_busy) return;
    final app = AppScope.read(context);
    setState(() => _busy = true);
    try {
      final file = await openFile(acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Ders Kumbarası yedeği',
          extensions: ['json'],
          mimeTypes: ['application/json', 'text/plain'],
          uniformTypeIdentifiers: ['public.json', 'public.text'],
        ),
      ]);
      if (file == null) return;
      final content = await file.readAsString();
      if (!mounted) return;
      final ok = await showDkSheet<bool>(
        context,
        builder: (ctx) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Yedek geri yüklensin mi?',
                style: TextStyle(
                    fontSize: 21, fontWeight: FontWeight.w900, color: K.ink)),
            const SizedBox(height: 8),
            const Text(
                'Bu cihazdaki tüm profiller ve ilerleme, yedekteki bilgilerle değiştirilir.',
                style: T.pBody),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: ChunkyButton(
                      label: 'Vazgeç',
                      kind: BtnKind.secondary,
                      onPressed: () => Navigator.pop(ctx, false))),
              const SizedBox(width: 10),
              Expanded(
                  child: ChunkyButton(
                      label: 'Geri yükle',
                      onPressed: () => Navigator.pop(ctx, true))),
            ]),
          ],
        ),
      );
      if (ok != true) return;
      final n = await app.importBackup(content);
      _say('Yedek geri yüklendi: $n çocuk profili.');
    } on FormatException catch (e) {
      _say(e.message, ok: false);
    } on Object catch (e) {
      debugPrint('Geri yükleme: $e');
      _say('Dosya açılamadı. Lütfen tekrar deneyin.', ok: false);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Scaffold(
      backgroundColor: K.bgParent,
      body: SafeArea(
        child: Column(children: [
          ParentHeader(
              title: 'Veri ve gizlilik',
              onBack: () => Navigator.of(context).pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                    'Ders Kumbarası hiçbir veriyi internete göndermez. Takma ad, sınıf ve çalışma kayıtları yalnızca bu cihazda saklanır.',
                    style: T.pBody),
                const SizedBox(height: 14),
                ListBox(children: [
                  NavRow(
                      key: const Key('backup'),
                      icon: DkIcons.download,
                      title: 'Yedekle (dosyaya kaydet)',
                      chevron: false,
                      onTap: _busy ? null : _backup),
                  NavRow(
                      key: const Key('restore'),
                      icon: DkIcons.upload,
                      title: 'Yedekten geri yükle',
                      chevron: false,
                      onTap: _busy ? null : _restore),
                  NavRow(
                      key: const Key('privacy'),
                      icon: DkIcons.file,
                      title: 'Gizlilik politikası ve KVKK aydınlatma metni',
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                              builder: (_) => const PrivacyScreen()))),
                  NavRow(
                      key: const Key('licenses'),
                      icon: DkIcons.info,
                      title: 'Açık kaynak lisansları',
                      last: true,
                      onTap: () => showLicensePage(
                          context: context,
                          applicationName: 'Ders Kumbarası',
                          applicationVersion: appVersion)),
                ]),
                if (_note != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    key: const Key('data-note'),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                        color: _noteOk ? K.goodBg : K.againBg,
                        borderRadius: BorderRadius.circular(14)),
                    child: Text(_note!,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _noteOk ? K.goodInk : K.againInk)),
                  ),
                ],
                const SizedBox(height: 14),
                if (_delStep == 0)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Pressable(
                      key: const Key('delete-all'),
                      onTap: () => setState(() => _delStep = 1),
                      label: 'Tüm verileri sil',
                      excludeChildSemantics: true,
                      focusRadius: 14,
                      builder: (context, down) => Container(
                        constraints: const BoxConstraints(minHeight: 52),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: down ? K.bgParent : K.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: K.ink, width: 2),
                        ),
                        child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DkIcon(DkIcons.trash, size: 20, color: K.ink),
                              SizedBox(width: 10),
                              Text('Tüm verileri sil',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: K.ink)),
                            ]),
                      ),
                    ),
                  )
                else
                  DkCard(
                    borderColor: K.ink,
                    borderWidth: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Tüm veriler silinsin mi?',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: K.ink)),
                        const SizedBox(height: 10),
                        const Text(
                            'Bütün çocuk profilleri ve ilerleme kayıtları kalıcı olarak silinir. Önce yedek almanızı öneririz.',
                            style: T.pBody),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: _SmallBtn(
                                label: 'Vazgeç',
                                onTap: () => setState(() => _delStep = 0)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SmallBtn(
                              key: const Key('confirm-delete-all'),
                              label: 'Evet, sil',
                              dark: true,
                              onTap: () async {
                                final nav = Navigator.of(context);
                                await app.deleteAll();
                                nav.popUntil((r) => r.isFirst);
                              },
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: K.line, width: 2))),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6),
                      Text('HAKKINDA', style: T.pSection),
                      SizedBox(height: 6),
                      Text(
                          'Sürüm $appVersion · İçerikler T.C. Millî Eğitim Bakanlığı Türkiye Yüzyılı Maarif Modeli öğretim programlarındaki öğrenme çıktılarına göre hazırlanmıştır. Uygulama MEB ile bağlantılı değildir.',
                          style: TextStyle(
                              fontSize: 15, height: 21 / 15, color: K.ink)),
                      SizedBox(height: 8),
                      Text(
                          'Yazı tipi: Nunito (SIL Open Font License). Emoji görselleri: Twemoji, CC-BY 4.0. Simgeler: Lucide (ISC).',
                          style: T.pSmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _SmallBtn extends StatelessWidget {
  const _SmallBtn(
      {super.key, required this.label, required this.onTap, this.dark = false});
  final String label;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) => Pressable(
        onTap: onTap,
        label: label,
        excludeChildSemantics: true,
        focusRadius: 12,
        builder: (context, down) => Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: dark ? K.ink : K.card,
            borderRadius: BorderRadius.circular(12),
            border: dark ? null : Border.all(color: K.line, width: 2),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: dark ? Colors.white : K.ink)),
        ),
      );
}

/// Gizlilik politikası ve KVKK aydınlatma metni (uygulama içinde, çevrimdışı).
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: K.bgParent,
      body: SafeArea(
        child: Column(children: [
          ParentHeader(
              title: 'Gizlilik ve KVKK',
              onBack: () => Navigator.of(context).pop()),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final (h, b) in privacySections) ...[
                  Text(h,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: K.ink)),
                  const SizedBox(height: 6),
                  Text(b, style: T.pBody),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

/// Gizlilik metni. web/gizlilik.html ile aynı içerik (mağaza bağlantısı).
const privacySections = [
  (
    'Özet',
    'Ders Kumbarası, 1–4. sınıf öğrencileri için hazırlanmış, çevrimdışı çalışan bir tekrar ve konu anlatımı uygulamasıdır. Uygulama hiçbir kişisel veriyi internete göndermez, reklam göstermez, uygulama içi satın alma içermez ve hesap açmayı gerektirmez.'
  ),
  (
    'Hangi bilgiler tutulur?',
    'Veli tarafından girilen çocuğun adı ya da takma adı, sınıfı ve seçilen hayvan avatarı; çalışma kayıtları (hangi konulara başlandığı, soru tekrar takvimi, günlük çalışma süresi, son denemelerin özeti, toplanan fındık sayısı); uygulama ayarları (günlük süre, sessiz saatler, ses, hareket ve yazı boyutu tercihleri). Soyad, fotoğraf, e-posta, telefon numarası, konum, cihaz kimliği gibi bilgiler istenmez ve toplanmaz.'
  ),
  (
    'Bilgiler nerede saklanır?',
    'Tüm bilgiler yalnızca bu cihazda, uygulamanın kendi depolama alanında saklanır. Uygulamanın bir sunucusu yoktur; bilgiler geliştiriciye ya da üçüncü kişilere aktarılmaz. Analitik, çökme raporu ya da reklam kütüphanesi kullanılmaz.'
  ),
  (
    'Sesli okuma',
    'Sesli okuma, uygulamayla birlikte gelen ses kayıtlarıyla ya da cihazın kendi metin okuma motoruyla yapılır. Metinler uygulama tarafından herhangi bir sunucuya gönderilmez. Cihazınızın metin okuma motorunun çalışma şekli, cihaz üreticisinin politikasına tabidir.'
  ),
  (
    'Yedekleme',
    'Veli alanındaki "Yedekle" seçeneği, tüm kayıtları tek bir dosyaya yazar ve paylaşma ekranını açar. Bu dosyanın nereye kaydedileceğine veli karar verir. Uygulama dosyayı kendiliğinden hiçbir yere göndermez.'
  ),
  (
    'Silme ve saklama süresi',
    'Bilgiler, veli silene ya da uygulama cihazdan kaldırılana kadar saklanır. Veli alanındaki "Tüm verileri sil" seçeneği tüm profilleri ve kayıtları kalıcı olarak siler; tek bir çocuğun kayıtları "Çocuk profilleri" bölümünden silinebilir.'
  ),
  (
    'KVKK aydınlatma metni',
    '6698 sayılı Kişisel Verilerin Korunması Kanunu kapsamında: Uygulamaya girilen bilgiler yalnızca uygulamanın çalışması (kişiye uygun tekrar takvimi ve veli raporu) amacıyla, veli tarafından cihaza girilmesiyle ve yalnızca cihazda işlenir. Bilgiler herhangi bir alıcı grubuna aktarılmaz. Veriler cihazda kaldığı için ilgili kişi hakları (bilgiye erişim, düzeltme, silme) doğrudan uygulama içindeki veli alanından kullanılabilir. Sorularınız için uygulama mağazası sayfasındaki geliştirici iletişim adresine yazabilirsiniz.'
  ),
  (
    'Çocukların güvenliği',
    'Uygulamada reklam, dış bağlantı, sohbet, sosyal paylaşım ve sıralama tablosu yoktur. Ayarlar, veri işlemleri ve bu metin gibi yetişkinlere yönelik bölümler bir veli kapısının (çarpma sorusu) arkasındadır.'
  ),
  (
    'Değişiklikler',
    'Bu metin değişirse güncel hali uygulamanın yeni sürümünde ve mağaza sayfasındaki gizlilik bağlantısında yayımlanır.'
  ),
];
