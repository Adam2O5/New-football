@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/finance_screen.dart';
import 'package:new_football/app/screens/home_screen.dart';
import 'package:new_football/app/screens/player_detail_screen.dart';
import 'package:new_football/app/screens/shell_screen.dart';
import 'package:new_football/app/screens/squad_screen.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/app/widgets/tactics/pitch_field.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/app/widgets/tactics/role_picker_sheet.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('FinanceScreen pokazuje dashboard capu, aprony i akcje', (
    tester,
  ) async {
    final game = _game(seed: 4001);
    await tester.pumpWidget(_app(const FinanceScreen(), game));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold));
    final snapshot = SalaryCapService().snapshot(game.leagueState.playerTeam!);
    expect(find.text('Salary cap i payroll'), findsOneWidget);
    expect(find.text('Aprony'), findsOneWidget);
    expect(find.text(formatMoney(context, snapshot.payroll)), findsOneWidget);
    expect(find.text(formatMoney(context, snapshot.cap)), findsOneWidget);
    await _dragToBottom(tester, find.byKey(const ValueKey('finance-scroll')));
    await tester.pumpAndSettle();
    expect(find.text('Gotówka klubu'), findsOneWidget);
    expect(find.text('Kondycja finansowa'), findsOneWidget);
    expect(find.text('Wymiany (trade)'), findsOneWidget);
    expect(find.text('Kontrakty / przedłużenia'), findsOneWidget);
    expect(find.text('Sztab'), findsOneWidget);
  });

  testWidgets('FinanceScreen pokazuje ostrzeżenie po przekroczeniu capu', (
    tester,
  ) async {
    final game = _game(seed: 4002);
    final league = game.leagueState;
    final team = league.playerTeam!;
    final baseSnapshot = SalaryCapService().snapshot(team);
    final overCapSalary =
        team.roster.first.contract.salary +
        baseSnapshot.cap -
        baseSnapshot.payroll +
        1;
    final expensivePlayer = team.roster.first.copyWith(
      contract: team.roster.first.contract.copyWith(salary: overCapSalary),
    );
    final overCapTeam = team.copyWith(
      roster: [expensivePlayer, ...team.roster.skip(1)],
    );
    final overCapLeague = league.copyWith(
      teams: [
        for (final candidate in league.teams)
          candidate.id == team.id ? overCapTeam : candidate,
      ],
    );
    final overCapGame = game.copyWith(leagueState: overCapLeague);

    await tester.pumpWidget(_app(const FinanceScreen(), overCapGame));
    await tester.pumpAndSettle();

    expect(find.text('Powyżej capu'), findsOneWidget);
    await _dragToBottom(tester, find.byKey(const ValueKey('finance-scroll')));
    await tester.pumpAndSettle();
    expect(find.text('Payroll przekracza salary cap'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
  });

  testWidgets('HomeScreen pokazuje nagłówek, kalendarz i kontekstową akcję', (
    tester,
  ) async {
    final game = _game(seed: 4003);
    await tester.pumpWidget(_app(const HomeScreen(), game));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-dashboard-header')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-next-seven-days')), findsOneWidget);
    expect(find.text(game.leagueState.playerTeam!.name), findsOneWidget);
    expect(find.text('Najbliższe 7 dni'), findsOneWidget);
    expect(find.text('Bilans drużyny'), findsOneWidget);
    expect(find.text('Najbliższa akcja'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets(
    'SquadScreen pokazuje pełny roster bez filtrów i zakładkę taktyki',
    (tester) async {
      final game = _game(seed: 4004);
      final team = game.leagueState.playerTeam!;
      await tester.pumpWidget(_app(const SquadScreen(), game));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(SquadScreen)),
      )!;
      expect(find.text(l10n.squad_filters), findsNothing);
      expect(find.text(l10n.squad_clearFilters), findsNothing);
      expect(find.text(l10n.squad_search), findsNothing);
      expect(find.byType(TextField), findsNothing);

      expect(
        find.byKey(const ValueKey('squad-size-indicator')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('squad-pitch-field')), findsOneWidget);
      expect(find.byKey(const ValueKey('squad-roster-list')), findsOneWidget);
      expect(find.byType(PlayerListTile), findsNWidgets(team.roster.length));
      for (final player in team.roster) {
        expect(
          find.byKey(ValueKey('squad-player-row-${player.id}')),
          findsOneWidget,
        );
      }

      await tester.tap(find.text(l10n.squad_tacticsTitle).first);
      await tester.pumpAndSettle();
      expect(find.byType(DropdownButtonFormField<Formation>), findsOneWidget);
      expect(find.text(l10n.tactics_autosaveHint), findsOneWidget);
    },
  );

  testWidgets('zmiany wszystkich ustawien taktyki zapisują się automatycznie', (
    tester,
  ) async {
    final game = _game(seed: 4005);
    late GameController controller;
    await tester.pumpWidget(
      _appWithOverrides(
        const SquadScreen(),
        game,
        onController: (value) => controller = value,
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(SquadScreen)))!;
    await tester.tap(find.text(l10n.squad_tacticsTitle).first);
    await tester.pumpAndSettle();

    final formationFinder = find.byType(DropdownButtonFormField<Formation>);
    final tempoFinder = find.byType(DropdownButtonFormField<Tempo>);
    final pressingFinder = find.byType(
      DropdownButtonFormField<PressingIntensity>,
    );
    final lineFinder = find.byType(DropdownButtonFormField<DefensiveLine>);
    final widthFinder = find.byType(DropdownButtonFormField<AttackWidth>);
    expect(formationFinder, findsOneWidget);
    expect(tempoFinder, findsOneWidget);
    expect(pressingFinder, findsOneWidget);
    expect(lineFinder, findsOneWidget);
    expect(widthFinder, findsOneWidget);

    final formation = tester.widget<DropdownButtonFormField<Formation>>(
      formationFinder,
    );
    final tempo = tester.widget<DropdownButtonFormField<Tempo>>(tempoFinder);
    final pressing = tester.widget<DropdownButtonFormField<PressingIntensity>>(
      pressingFinder,
    );
    final line = tester.widget<DropdownButtonFormField<DefensiveLine>>(
      lineFinder,
    );
    final width = tester.widget<DropdownButtonFormField<AttackWidth>>(
      widthFinder,
    );
    final changedFormation = Formation.values.firstWhere(
      (value) => value != formation.initialValue,
    );
    final changedTempo = Tempo.values.firstWhere(
      (value) => value != tempo.initialValue,
    );
    final changedPressing = PressingIntensity.values.firstWhere(
      (value) => value != pressing.initialValue,
    );
    final changedLine = DefensiveLine.values.firstWhere(
      (value) => value != line.initialValue,
    );
    final changedWidth = AttackWidth.values.firstWhere(
      (value) => value != width.initialValue,
    );

    formation.onChanged!(changedFormation);
    tempo.onChanged!(changedTempo);
    pressing.onChanged!(changedPressing);
    line.onChanged!(changedLine);
    width.onChanged!(changedWidth);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    var persisted = controller.save!.leagueState.playerTeam!.tactics;
    expect(persisted.formation, changedFormation);
    expect(persisted.tempo, changedTempo);
    expect(persisted.pressing, changedPressing);
    expect(persisted.defensiveLine, changedLine);
    expect(persisted.attackWidth, changedWidth);
    expect(find.text(l10n.tactics_autosaved), findsOneWidget);

    await tester.tap(find.text(l10n.squad_rosterTitle).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.squad_tacticsTitle).first);
    await tester.pumpAndSettle();

    persisted = controller.save!.leagueState.playerTeam!.tactics;
    expect(persisted.formation, changedFormation);
    expect(persisted.tempo, changedTempo);
    expect(persisted.pressing, changedPressing);
    expect(persisted.defensiveLine, changedLine);
    expect(persisted.attackWidth, changedWidth);
    expect(
      tester
          .widget<DropdownButtonFormField<Formation>>(formationFinder)
          .initialValue,
      changedFormation,
    );
    expect(
      tester.widget<DropdownButtonFormField<Tempo>>(tempoFinder).initialValue,
      changedTempo,
    );
    expect(
      tester
          .widget<DropdownButtonFormField<PressingIntensity>>(pressingFinder)
          .initialValue,
      changedPressing,
    );
    expect(
      tester
          .widget<DropdownButtonFormField<DefensiveLine>>(lineFinder)
          .initialValue,
      changedLine,
    );
    expect(
      tester
          .widget<DropdownButtonFormField<AttackWidth>>(widthFinder)
          .initialValue,
      changedWidth,
    );
    expect(find.text(l10n.tactics_autosaved), findsOneWidget);
  });

  testWidgets(
    'Tactics_Tab zachowuje domyślne znaczniki, role picker i profil long-press',
    (tester) async {
      final game = _game(seed: 4007);
      final team = game.leagueState.playerTeam!;
      final tacticsPlayer = team.roster.firstWhere(
        (player) =>
            team.lineupPlayerIds.contains(player.id) &&
            (player.state.injury?.daysRemaining ?? 0) <= 0 &&
            player.state.suspensionGamesRemaining == 0,
      );
      final router = GoRouter(
        initialLocation: '/squad',
        routes: [
          GoRoute(
            path: '/squad',
            builder: (context, state) => const Scaffold(body: SquadScreen()),
          ),
          GoRoute(
            path: '/game/player/:id',
            builder: (context, state) =>
                PlayerDetailScreen(playerId: state.pathParameters['id']!),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(_routerApp(router, game));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(SquadScreen)),
      )!;
      await tester.tap(find.text(l10n.squad_tacticsTitle).first);
      await tester.pumpAndSettle();

      final tacticsPitchFinder = find.descendant(
        of: find.byKey(const ValueKey('squad-tactics-scroll')),
        matching: find.byType(PitchField),
      );
      expect(tacticsPitchFinder, findsOneWidget);
      final tacticsPitch = tester.widget<PitchField>(tacticsPitchFinder);
      expect(tacticsPitch.markerStyleBuilder, isNull);
      expect(
        find.bySemanticsLabel(
          l10n.squad_playerMarkerSemantics(
            tacticsPlayer.name,
            tacticsPlayer.position.code,
            '',
          ),
        ),
        findsNothing,
      );

      final tacticsMarker = find.descendant(
        of: tacticsPitchFinder,
        matching: find.text(tacticsPlayer.name),
      );
      expect(tacticsMarker, findsOneWidget);
      final tacticsAvatar = tester.widget<CircleAvatar>(
        find
            .descendant(
              of: tacticsPitchFinder,
              matching: find.byType(CircleAvatar),
            )
            .first,
      );
      expect(tacticsAvatar.backgroundColor, Colors.white);

      await tester.tap(tacticsMarker);
      await tester.pumpAndSettle();
      expect(find.byType(RolePickerSheet), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(RolePickerSheet),
          matching: find.text(tacticsPlayer.name),
        ),
        findsOneWidget,
      );
      Navigator.of(tester.element(find.byType(RolePickerSheet))).pop();
      await tester.pumpAndSettle();

      await tester.longPress(tacticsMarker);
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/game/player/${tacticsPlayer.id}');
      expect(find.byType(PlayerDetailScreen), findsOneWidget);
    },
  );

  testWidgets('Shell pokazuje akcje ustawień i zapisu w AppBarze', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const ShellScreen(), _game(seed: 4006)));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Ustawienia'), findsOneWidget);
    expect(find.byTooltip('Zapisz'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.save_outlined), findsOneWidget);
  });
}

Future<void> _dragToBottom(WidgetTester tester, Finder list) async {
  for (var i = 0; i < 8; i++) {
    await tester.drag(list, const Offset(0, -500));
    await tester.pump();
  }
}

GameSave _game({required int seed}) {
  return GameFactory().create(
    NewGameRequest(
      saveName: 'Task 40 UI',
      playerTeamId: 'team_europe_0',
      seed: seed,
    ),
  );
}

class _NoopSaveRepository extends SaveRepository {
  @override
  Future<void> save(GameSave gameSave) async {}
}

Widget _routerApp(GoRouter router, GameSave game) {
  return ProviderScope(
    overrides: [
      saveRepositoryProvider.overrideWithValue(_NoopSaveRepository()),
      gameControllerProvider.overrideWith((ref) {
        final controller = GameController(ref);
        controller.state = AsyncValue.data(game);
        return controller;
      }),
    ],
    child: MaterialApp.router(
      locale: const Locale('pl'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

Widget _app(Widget screen, GameSave game) {
  return _appWithOverrides(screen, game);
}

Widget _appWithOverrides(
  Widget screen,
  GameSave game, {
  void Function(GameController controller)? onController,
}) {
  return ProviderScope(
    overrides: [
      saveRepositoryProvider.overrideWithValue(_NoopSaveRepository()),
      gameControllerProvider.overrideWith((ref) {
        final controller = GameController(ref);
        controller.state = AsyncValue.data(game);
        onController?.call(controller);
        return controller;
      }),
    ],
    child: MaterialApp(
      locale: const Locale('pl'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: screen,
    ),
  );
}
