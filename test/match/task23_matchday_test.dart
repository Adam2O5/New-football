@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/matchday_screen.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/simulation/match_engine.dart';
import 'package:new_football/core/simulation/matchday_runtime.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

void main() {
  test('obserwacja i simulate-to-end zachowują ten sam wynik', () {
    final league = SeedDataGenerator().generateLeague(year: 2026, seed: 2301);
    final home = league.teams[0];
    final away = league.teams[1];
    const context = MatchContext(
      homeTeamId: 'task23-home',
      awayTeamId: 'task23-away',
      seed: 2301,
    );
    final engine = SimulationMatchEngine();

    final observedLive = engine.start(
      home: home,
      away: away,
      context: context,
      rngSeed: context.seed,
    );
    while (!observedLive.isFinished) {
      engine.simulateMinute(observedLive);
    }
    final observed = engine.toMatchResult(
      live: observedLive,
      home: home,
      away: away,
    );
    final headless = engine.simulateFullMatch(
      home: home,
      away: away,
      context: context,
      rngSeed: context.seed,
    );

    expect(observed, headless);
  });

  test('zmiana i blokada formacji korzystają z result API runtime', () {
    final league = SeedDataGenerator().generateLeague(year: 2026, seed: 2302);
    final home = league.teams[0];
    final away = league.teams[1];
    final engine = SimulationMatchEngine();
    final live = engine.start(home: home, away: away, rngSeed: 2302);
    final outgoing = live.state.homeLineup.first;
    final incoming = live.state.homeBench.first;

    final substitution = engine.applySubstitutionResult(
      live: live,
      homeSide: true,
      playerOutId: outgoing.id,
      playerInId: incoming.id,
    );
    expect(substitution.accepted, isTrue);
    expect(live.state.homeLineup, contains(incoming));
    expect(live.state.homeBench, contains(outgoing));

    final changedFormation = Formation.values.firstWhere(
      (formation) => formation != live.state.homeTactics.formation,
    );
    final rejected = engine.updateTacticsResult(
      live: live,
      homeSide: true,
      tactics: live.state.homeTactics.copyWith(formation: changedFormation),
    );
    expect(rejected.accepted, isFalse);
    expect(
      rejected.failure,
      SimulationActionFailure.formationChangeOutsideHalfTime,
    );

    live.legacyMatch.state = live.state.copyWith(minute: 45);
    final acceptedAtHalfTime = engine.updateTacticsResult(
      live: live,
      homeSide: true,
      tactics: live.state.homeTactics.copyWith(formation: changedFormation),
    );
    expect(acceptedAtHalfTime.accepted, isTrue);
    expect(live.state.homeTactics.formation, changedFormation);
  });

  testWidgets('ekran pokazuje zegar, pauzę, prędkości i blokadę formacji', (
    tester,
  ) async {
    final game = GameFactory().create(
      const NewGameRequest(
        saveName: 'Task 23 UI',
        playerTeamId: 'team_europe_0',
        seed: 2303,
      ),
    );
    final playerTeamId = game.leagueState.playerTeamId;
    final match = game.leagueState.currentSeason.schedule.firstWhere(
      (item) =>
          item.homeTeamId == playerTeamId || item.awayTeamId == playerTeamId,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameControllerProvider.overrideWith((ref) {
            final controller = GameController(ref);
            controller.state = AsyncValue.data(game);
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
          home: MatchdayScreen(match: match),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('matchday-clock')), findsOneWidget);
    expect(find.text('Wznów'), findsOneWidget);
    expect(find.text('×1'), findsOneWidget);
    expect(find.text('×2'), findsOneWidget);
    expect(find.text('×4'), findsOneWidget);

    await tester.tap(find.text('Wznów'));
    await tester.pump(const Duration(milliseconds: 400));
    final runningMinute = tester
        .widget<Text>(find.byKey(const ValueKey('matchday-clock')))
        .data;
    expect(runningMinute, isNot("0'"));

    await tester.tap(find.text('Pauza'));
    await tester.pump(const Duration(milliseconds: 700));
    final pausedMinute = tester
        .widget<Text>(find.byKey(const ValueKey('matchday-clock')))
        .data;
    expect(pausedMinute, runningMinute);

    await tester.tap(find.text('Taktyka meczowa'));
    await tester.pumpAndSettle();
    expect(
      find.text('Formację można zmienić tylko w przerwie'),
      findsOneWidget,
    );
    final formation = tester.widget<DropdownButtonFormField<Formation>>(
      find.byType(DropdownButtonFormField<Formation>),
    );
    expect(formation.onChanged, isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
