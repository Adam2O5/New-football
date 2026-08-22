@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/finance_screen.dart';
import 'package:new_football/app/screens/home_screen.dart';
import 'package:new_football/app/screens/shell_screen.dart';
import 'package:new_football/app/screens/squad_screen.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
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

  testWidgets('SquadScreen pokazuje roster, filtry i zakładkę taktyki', (
    tester,
  ) async {
    final game = _game(seed: 4004);
    final firstPlayer = game.leagueState.playerTeam!.roster.first;
    await tester.pumpWidget(_app(const SquadScreen(), game));
    await tester.pumpAndSettle();

    expect(find.text('Filtry składu'), findsOneWidget);
    expect(find.text('Wyczyść filtry'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, firstPlayer.name);
    await tester.pump();
    await _dragToBottom(
      tester,
      find.byKey(const ValueKey('squad-roster-scroll')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PlayerListTile), findsOneWidget);

    await tester.tap(find.text('Taktyka').first);
    await tester.pumpAndSettle();
    expect(find.byType(DropdownButtonFormField<Formation>), findsOneWidget);
    expect(find.text('Zmiany zapisują się automatycznie'), findsOneWidget);
  });

  testWidgets('zmiana dropdownu taktyki zapisuje się automatycznie', (
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

    await tester.tap(find.text('Taktyka').first);
    await tester.pumpAndSettle();
    final dropdownFinder = find.byType(DropdownButtonFormField<Formation>);
    final dropdown = tester.widget<DropdownButtonFormField<Formation>>(
      dropdownFinder,
    );
    final changedFormation = Formation.values.firstWhere(
      (value) => value != dropdown.initialValue,
    );

    expect(dropdown.onChanged, isNotNull);
    dropdown.onChanged!(changedFormation);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    await _dragToBottom(
      tester,
      find.byKey(const ValueKey('squad-tactics-scroll')),
    );
    await tester.pumpAndSettle();

    expect(
      controller.save!.leagueState.playerTeam!.tactics.formation,
      changedFormation,
    );
    expect(find.text('Taktyka zapisana automatycznie'), findsOneWidget);
    expect(find.text('Zapisz taktykę'), findsNothing);
  });

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
