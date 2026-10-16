import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/screens/shell_screen.dart';
import 'package:new_football/app/screens/squad_screen.dart';
import 'package:new_football/app/screens/standings_screen.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/game_fixtures.dart';
import 'support/memory_save_repository.dart';

void main() {
  testWidgets('calendar date updates do not rebuild unchanged squad/table', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = MemorySaveRepository(saveForLeague(seededLeague()));
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        saveRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(gameControllerProvider.notifier);
    await controller.loadGame(repository.game.meta.id);
    await tester.binding.setSurfaceSize(const Size(1400, 1500));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ShellScreen(initialTab: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Establish the controller's lineup/contract normalization before measuring
    // updates whose only semantic change is the date.
    await controller.updateLeague((league) => league);
    await tester.pumpAndSettle();
    final squadElement = tester.element(
      find.byType(SquadScreen, skipOffstage: false),
    );
    final standingsElement = tester.element(
      find.byType(StandingsScreen, skipOffstage: false),
    );
    final builds = <String, int>{};
    final previous = debugOnRebuildDirtyWidget;
    debugOnRebuildDirtyWidget = (element, builtOnce) {
      previous?.call(element, builtOnce);
      final name = element.widget.runtimeType.toString();
      builds.update(name, (n) => n + 1, ifAbsent: () => 1);
    };
    addTearDown(() => debugOnRebuildDirtyWidget = previous);
    final clock = Stopwatch()..start();
    for (var day = 2; day <= 6; day++) {
      await controller.updateLeague(
        (league) => league.copyWith(currentDay: day),
      );
      await tester.pump();
    }
    clock.stop();
    debugPrint(
      jsonEncode({
        'scenario': 'five date-only updates, calendar visible',
        'mode': 'widget test / debug; elapsed includes controller and pump',
        'elapsed_us': clock.elapsedMicroseconds,
        'home_builds': builds['HomeScreen'] ?? 0,
        'squad_builds': builds['SquadScreen'] ?? 0,
        'standings_builds': builds['StandingsScreen'] ?? 0,
        'regular_table_builds': builds['_RegularSeasonTab'] ?? 0,
      }),
    );
    if (!const bool.fromEnvironment('STAGE_SIX_BASELINE')) {
      expect(builds['SquadScreen'] ?? 0, 0);
      expect(builds['StandingsScreen'] ?? 0, 0);
      expect(builds['_RegularSeasonTab'] ?? 0, 0);
    }
    // Value equality must also suppress a fresh, equal worker result.
    builds.clear();
    await controller.updateLeague(
      (league) => MessageService().send(
        league,
        type: MessageType.contractSigned,
        args: {
          'subjectName': 'Fixture',
          'playerName': 'Fixture',
          'teamName': league.playerTeam!.name,
          'salary': 100000,
          'years': 1,
        },
        payload: {
          'playerId': league.playerTeam!.roster.first.id,
          'teamId': league.playerTeamId,
        },
      ),
    );
    await tester.pump();
    expect(builds['SquadScreen'] ?? 0, 0);
    expect(builds['StandingsScreen'] ?? 0, 0);
    builds.clear();
    await controller.updateLeague(
      (league) => league.copyWith(
        currentSeason: league.currentSeason.copyWith(staffGrowthDone: true),
      ),
    );
    await tester.pump();
    expect(builds['StandingsScreen'] ?? 0, 0);
    builds.clear();
    await controller.updateLeague(
      (league) => LeagueState.fromJson(
        jsonDecode(jsonEncode(league.toJson())) as Map<String, dynamic>,
      ),
    );
    await tester.pump();
    expect(builds['SquadScreen'] ?? 0, 0);
    expect(builds['StandingsScreen'] ?? 0, 0);

    container.read(shellTabIndexProvider.notifier).state = 2;
    await tester.pumpAndSettle();
    final squadTabs = find.descendant(
      of: find.byType(SquadScreen),
      matching: find.byType(TabBar),
    );
    final squadController = tester.widget<TabBar>(squadTabs).controller!;
    squadController.index = 1;
    await tester.pumpAndSettle();
    container.read(shellTabIndexProvider.notifier).state = 1;
    await tester.pumpAndSettle();
    // A hidden squad still refreshes when its data actually changes.
    builds.clear();
    await controller.updateLeague(
      (league) =>
          league.updateTeam(league.playerTeam!.copyWith(name: 'Updated club')),
    );
    await tester.pump();
    expect(builds['SquadScreen'], greaterThan(0));
    expect(builds['StandingsScreen'], greaterThan(0));
    container.read(shellTabIndexProvider.notifier).state = 2;
    await tester.pumpAndSettle();
    expect(squadController.index, 1);
    expect(tester.element(find.byType(SquadScreen)), same(squadElement));
    container.read(shellTabIndexProvider.notifier).state = 3;
    await tester.pumpAndSettle();
    expect(
      tester.element(find.byType(StandingsScreen)),
      same(standingsElement),
    );
    expect(find.text('Updated club'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
