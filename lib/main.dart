import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/router.dart';
import 'package:new_football/app/theme/app_theme.dart';
import 'package:new_football/core/services/simulation_worker.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SaveRepository.initializeCoordinator();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        // Day simulation is the app's only long CPU burst. Off the UI isolate
        // it cannot trigger "application not responding".
        simulationRunnerProvider.overrideWith((ref) {
          final runner = IsolateSimulationRunner();
          ref.onDispose(runner.dispose);
          return runner;
        }),
      ],
      child: const NewFootballApp(),
    ),
  );
}

class NewFootballApp extends ConsumerStatefulWidget {
  const NewFootballApp({super.key});

  @override
  ConsumerState<NewFootballApp> createState() => _NewFootballAppState();
}

class _NewFootballAppState extends ConsumerState<NewFootballApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Autosave publishes state first and writes in the background, so a save
    // can still be in flight when Android backgrounds or kills the process.
    _lifecycle = AppLifecycleListener(
      onPause: _flushPendingSave,
      onDetach: _flushPendingSave,
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _flushPendingSave() async {
    try {
      await ref.read(gameControllerProvider.notifier).flushPendingSave();
    } catch (error, stackTrace) {
      // The controller keeps the failure until a successful retry. Lifecycle
      // callbacks have no screen on which to present a retry action.
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          context: ErrorDescription(
            'while saving the active career on app lifecycle change',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      locale: locale,
      supportedLocales: supportedAppLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
