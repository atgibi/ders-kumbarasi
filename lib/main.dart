import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/app_state.dart';
import 'app/speaker.dart';
import 'data/content_repository.dart';
import 'data/progress_store.dart';
import 'data/web_storage.dart' if (dart.library.io) 'data/file_storage.dart';
import 'demo.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/profile_picker_screen.dart';
import 'ui/screens/shell_screen.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Telefonlarda dikey; tablet düzeni de dikeyde tasarlandı.
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  _registerLicenses();
  // Beklenmeyen hatalar çocuğa teknik metin olarak gösterilmez
  ErrorWidget.builder = (details) {
    if (kDebugMode) return ErrorWidget(details.exception);
    return const ColoredBox(color: K.bg);
  };
  final state = AppState(
    store: ProgressStore(await createPlatformStorage()),
    content: ContentRepository(rootBundle.loadString),
    speaker: HybridSpeaker(),
  );
  await applyDemo(state);
  runApp(DersKumbarasiApp(state: state));
}

class DersKumbarasiApp extends StatefulWidget {
  const DersKumbarasiApp({super.key, required this.state});
  final AppState state;

  @override
  State<DersKumbarasiApp> createState() => _DersKumbarasiAppState();
}

class _DersKumbarasiAppState extends State<DersKumbarasiApp> {
  final _nav = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    widget.state.load().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final nav = _nav.currentState;
        if (nav != null) openDemoSession(nav);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: widget.state,
      child: MaterialApp(
        navigatorKey: _nav,
        title: 'Ders Kumbarası',
        debugShowCheckedModeBanner: false,
        theme: K.theme(),
        locale: const Locale('tr', 'TR'),
        supportedLocales: const [Locale('tr', 'TR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    if (!app.loaded) return const Scaffold(backgroundColor: K.bg);
    if (app.profiles.isEmpty) return const OnboardingScreen();
    if (app.active == null) return const ProfilePickerScreen();
    return const ShellScreen();
  }
}

void _registerLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(
        const ['Nunito'], await rootBundle.loadString('assets/fonts/OFL.txt'));
    yield LicenseEntryWithLineBreaks(const ['Twemoji'],
        await rootBundle.loadString('assets/emoji/LICENSE.txt'));
    yield const LicenseEntryWithLineBreaks([
      'Lucide'
    ], 'ISC License\n\nCopyright (c) for portions of Lucide are held by Cole Bemis 2013-2022 as part of Feather (MIT). All other copyright (c) for Lucide are held by Lucide Contributors 2022.\n\nPermission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.\n\nTHE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.');
  });
}
