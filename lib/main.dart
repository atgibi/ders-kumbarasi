import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app_state.dart';
import 'app/speaker.dart';
import 'data/content_repository.dart';
import 'data/progress_store.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/profile_picker_screen.dart';
import 'ui/screens/shell_screen.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationSupportDirectory();
  final state = AppState(
    store: ProgressStore(FileStorage(dir)),
    content: ContentRepository(rootBundle.loadString),
    speaker: TtsSpeaker(),
  );
  runApp(DersKumbarasiApp(state: state));
}

class DersKumbarasiApp extends StatefulWidget {
  const DersKumbarasiApp({super.key, required this.state});
  final AppState state;

  @override
  State<DersKumbarasiApp> createState() => _DersKumbarasiAppState();
}

class _DersKumbarasiAppState extends State<DersKumbarasiApp> {
  @override
  void initState() {
    super.initState();
    widget.state.load();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: widget.state,
      child: MaterialApp(
        title: 'Ders Kumbarası',
        debugShowCheckedModeBanner: false,
        theme: Kumbara.theme(),
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
    if (!app.loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (app.profiles.isEmpty) return const OnboardingScreen();
    if (app.active == null) return const ProfilePickerScreen();
    return const ShellScreen();
  }
}
