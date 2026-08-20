import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/models/calendar_simulation_feedback.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/services/calendar_simulation_pacer.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/data/save_repository.dart';

int _firstRegularMatchDay() {
  const calendar = CalendarService();
  for (final day in [3, 4, 6, 7]) {
    if (calendar.isActualMatchDay(1, day)) return day;
  }
  throw StateError('No regular-season match day found for week 1');
}

Map<String, Object?> _stableDomainSnapshot(GameSave save) {
  final league = save.leagueState;
  return {
    'saveSeed': save.saveSeed,
    'schemaVersion': save.schemaVersion,
    'metaId': save.meta.id,
    'metaName': save.meta.name,
    'playerTeamId': league.playerTeamId,
    'scheduleIdentity': [
      for (final match in league.currentSeason.schedule)
        '${match.id}|${match.homeTeamId}|${match.awayTeamId}|${match.round}',
    ],
    'teamIdentity': [
      for (final team in league.teams)
        '${team.id}|${team.name}|${team.roster.map((player) => player.id).join(',')}',
    ],
    'standingConferences': league.currentSeason.standings
        .map((conference) => conference.conference.name)
        .toList(),
    'inboxIds': league.inbox.messages.map((message) => message.id).toList(),
  };
}

CalendarSimulationPacer _fakePacer(
  List<Duration> waits, {
  void Function()? onDelay,
}) {
  var elapsed = Duration.zero;
  return CalendarSimulationPacer(
    elapsedSource: () => elapsed,
    delay: (duration) async {
      waits.add(duration);
      onDelay?.call();
      elapsed += duration;
    },
  );
}

void main() {
  late Directory tempDir;
  late ProviderContainer container;
  late GameController controller;
  late _TracingGameController tracedController;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('nf_sim_until_');
    final monotonicClock = Stopwatch()..start();
    container = ProviderContainer(
      overrides: [
        saveRepositoryProvider.overrideWithValue(
          SaveRepository(overrideDirectory: tempDir),
        ),
        gameControllerProvider.overrideWith((ref) {
          tracedController = _TracingGameController(ref, monotonicClock);
          return tracedController;
        }),
      ],
    );
    controller = container.read(gameControllerProvider.notifier);
    await controller.createNewGame(
      const NewGameRequest(
        saveName: 'SimUntil',
        playerTeamId: 'team_europe_0',
        seed: 7,
      ),
    );
    expect(
      controller.save,
      isNotNull,
      reason: 'createNewGame failed: ${controller.state.error}',
    );
  });

  tearDown(() async {
    container.dispose();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('simulateToDate stops exactly at the target date', () async {
    final result = await controller.simulateToDate(1, 2);
    final league = controller.save!.leagueState;
    expect(league.currentWeek, 1);
    expect(league.currentDay, 2);
    // Week 1 day 1->2 has no fixtures (matches play Wed/Sat), so no pause.
    expect(result.stopReason, SimulationStopReason.reachedTarget);
    expect(result.daysSimulated, 1);
  });

  test('simulateUntilPhaseEnd(regular) reaches the start of play-in when there '
      'is no player team to pause on', () async {
    // Remove the player team so DaySimulator never pauses for a match.
    // Start on the deadline day to keep this calendar-stop test fast while
    // still exercising the urgent-message/resume path.
    await controller.updateLeague(
      (l) => l.copyWith(
        playerTeamId: null,
        currentWeek: 23,
        currentDay: 1,
        currentSeason: l.currentSeason.copyWith(phase: SeasonPhase.regular),
      ),
      autosave: false,
    );
    // The trade deadline (week 23) still raises an urgent calendar
    // message, which always pauses the batch — acknowledge it and resume.
    var result = await controller.simulateUntilPhaseEnd(SeasonPhase.regular);
    var guard = 0;
    while (result.stopReason == SimulationStopReason.urgent && guard < 5) {
      for (final m in controller.save!.leagueState.inbox.pendingUrgent) {
        await controller.acknowledgeMessage(m.id);
      }
      result = await controller.simulateUntilPhaseEnd(SeasonPhase.regular);
      guard++;
    }
    final league = controller.save!.leagueState;
    // Week 29 is the last regular-season match week; week 30 is the
    // break week before play-in (still `SeasonPhase.regular` per
    // CalendarService.phaseForWeek, but with no fixtures left to play).
    expect(league.currentWeek, 30);
    expect(league.currentDay, 1);
    expect(result.stopReason, SimulationStopReason.reachedTarget);
  });

  test('cancelSimulation stops the batch after the current day', () async {
    await controller.updateLeague(
      (l) => l.copyWith(playerTeamId: null),
      autosave: false,
    );
    final future = controller.simulateUntilPhaseEnd(SeasonPhase.regular);
    // By the time this call returns, the loop is already suspended at its
    // first `await advanceOneDay()` — cancelling now is picked up on the
    // next loop check, deterministically stopping after exactly one day.
    controller.cancelSimulation();
    final result = await future;
    expect(result.stopReason, SimulationStopReason.cancelled);
    expect(result.daysSimulated, 1);
  });

  test('draft pick pending stops the batch for the player\'s turn', () async {
    // Postaw kalendarz dokładnie na dniu draftu (poniedziałek tyg. 46 —
    // `game_calendar.md`) i wstrzyknij minimalny draftState, w którym pick
    // nr 1 należy do drużyny gracza. GameController nie może przesymulować
    // tego dnia bez wyboru — batch musi stanąć na `event`/`draft` zanim
    // upłynie choć jeden dzień.
    const draftWeek = 46;
    await controller.updateLeague(
      (l) => l.copyWith(
        currentWeek: draftWeek,
        currentDay: 1,
        currentSeason: l.currentSeason.copyWith(
          draftState: DraftState(
            year: l.currentSeason.year,
            order: [
              const DraftPick(
                id: 'draft_pick_1',
                year: 2027,
                round: 1,
                pickNumber: 1,
                teamId: 'team_europe_0',
                originalTeamId: 'team_europe_0',
              ),
            ],
            draftClass: DraftClass(year: l.currentSeason.year),
          ),
        ),
      ),
      autosave: false,
    );
    final feedback = <CalendarDaySimulationFeedback>[];
    final result = await controller.simulateToDate(
      48,
      1,
      observer: feedback.add,
    );
    expect(result.stopReason, SimulationStopReason.event);
    expect(result.eventId, CalendarEventId.draft);
    expect(result.daysSimulated, 0);
    expect(feedback, isEmpty);
  });

  test(
    'scout report stops fast-forward before player Combine selection',
    () async {
      await controller.updateLeague(
        (l) => l.copyWith(
          currentWeek: 45,
          currentDay: 1,
          currentSeason: l.currentSeason.copyWith(
            draftState: DraftState(
              year: l.currentSeason.year + 1,
              draftClass: DraftClass(year: l.currentSeason.year + 1),
            ),
            scoutReportDone: false,
            combineDone: false,
          ),
        ),
        autosave: false,
      );

      final feedback = <CalendarDaySimulationFeedback>[];
      final result = await controller.simulateToDate(
        46,
        1,
        observer: feedback.add,
      );

      expect(result.stopReason, SimulationStopReason.event);
      expect(result.eventId, CalendarEventId.scoutReport);
      expect(result.daysSimulated, 0);
      expect(feedback, isEmpty);
      expect(controller.save!.leagueState.currentWeek, 45);
      expect(
        controller.save!.leagueState.currentSeason.scoutReportDone,
        isFalse,
      );
    },
  );

  test(
    'simulateToDate preserves the seeded domain baseline while resolving one round',
    () async {
      // Remove the player fixture for this domain snapshot so the baseline is
      // an ordinary all-AI round with no interactive/urgent stop reason.
      await controller.updateLeague(
        (league) => league.copyWith(playerTeamId: null),
        autosave: false,
      );
      final beforeSave = controller.save!;
      final before = _stableDomainSnapshot(beforeSave);
      final matchDay = _firstRegularMatchDay();
      final target = const CalendarService().advanceDay(1, matchDay);

      final result = await controller.simulateToDate(target.$1, target.$2);
      final afterSave = controller.save!;
      final after = _stableDomainSnapshot(afterSave);
      final resolved = afterSave.leagueState.currentSeason.schedule
          .where((match) => match.result != null)
          .toList();
      final standingsGames = afterSave.leagueState.currentSeason.standings
          .expand((conference) => conference.standings)
          .fold<int>(0, (sum, standing) => sum + standing.gamesPlayed);
      final standingsCountedResults = resolved
          .where((match) => match.result!.status != MatchStatus.dsq)
          .length;

      // Baseline observed on F: seed 7 resolves the first 15-match round,
      // advances exactly to the day after that round, and leaves all
      // schedule/team identities intact. Result effects are intentionally
      // asserted through persisted schedule/standings rather than UI state.
      expect(result.stopReason, SimulationStopReason.reachedTarget);
      expect(result.daysSimulated, matchDay);
      expect(afterSave.leagueState.currentWeek, target.$1);
      expect(afterSave.leagueState.currentDay, target.$2);
      expect(resolved, hasLength(15));
      expect(standingsGames, standingsCountedResults * 2);

      expect(after['saveSeed'], before['saveSeed']);
      expect(after['schemaVersion'], before['schemaVersion']);
      expect(after['metaId'], before['metaId']);
      expect(after['metaName'], before['metaName']);
      expect(after['playerTeamId'], before['playerTeamId']);
      expect(after['scheduleIdentity'], before['scheduleIdentity']);
      expect(after['teamIdentity'], before['teamIdentity']);
      expect(after['standingConferences'], before['standingConferences']);
      expect(
        List<String>.from(after['inboxIds']! as List),
        containsAll(List<String>.from(before['inboxIds']! as List)),
      );
    },
  );

  test(
    'simulateToEvent preserves the non-calendar stop before the player match',
    () async {
      final matchDay = _firstRegularMatchDay();
      final slot = const CalendarService().regularSeasonSlotForDay(matchDay)!;
      final round = scheduleRoundForWeekSlot(1, slot);
      final expectedFixture = controller
          .save!
          .leagueState
          .currentSeason
          .schedule
          .firstWhere(
            (match) =>
                match.round == round &&
                (match.homeTeamId == 'team_europe_0' ||
                    match.awayTeamId == 'team_europe_0'),
          );

      final result = await controller.simulateToEvent();
      final league = controller.save!.leagueState;
      final persistedPlayerFixture = league.currentSeason.schedule.firstWhere(
        (match) => match.id == expectedFixture.id,
      );

      expect(result.stopReason, SimulationStopReason.playerMatch);
      expect(result.daysSimulated, matchDay);
      expect(league.currentWeek, 1);
      expect(league.currentDay, matchDay);
      expect(result.lastResult, isNotNull);
      expect(result.lastResult!.playerMatch!.id, expectedFixture.id);
      expect(result.lastResult!.simulatedResults, isNotEmpty);
      expect(persistedPlayerFixture.result, isNull);
    },
  );

  test('advanceOneDay preserves the no-result day baseline', () async {
    final result = await controller.advanceOneDay();
    final league = controller.save!.leagueState;

    expect(result, isNotNull);
    expect(result!.playerMatch, isNull);
    expect(result.simulatedResults, isEmpty);
    expect(league.currentWeek, 1);
    expect(league.currentDay, 2);
    expect(
      league.currentSeason.schedule.where((match) => match.result != null),
      isEmpty,
    );
  });

  test('simulateToDate does not advance for current or past targets', () async {
    await controller.updateLeague(
      (league) => league.copyWith(currentWeek: 1, currentDay: 2),
      autosave: false,
    );

    final current = await controller.simulateToDate(1, 2);
    expect(current.stopReason, SimulationStopReason.reachedTarget);
    expect(current.daysSimulated, 0);
    expect(controller.save!.leagueState.currentDay, 2);

    final past = await controller.simulateToDate(1, 1);
    expect(past.stopReason, SimulationStopReason.reachedTarget);
    expect(past.daysSimulated, 0);
    expect(controller.save!.leagueState.currentDay, 2);
  });

  test('simulateToDate preserves the no-save stop reason', () async {
    controller.state = const AsyncValue.data(null);
    final feedback = <CalendarDaySimulationFeedback>[];

    final result = await controller.simulateToDate(
      1,
      2,
      observer: feedback.add,
    );

    expect(result.stopReason, SimulationStopReason.noSave);
    expect(result.daysSimulated, 0);
    expect(result.lastResult, isNull);
    expect(feedback, isEmpty);
  });

  test(
    'calendar observer emits one event per committed day, including empty days',
    () async {
      await controller.updateLeague(
        (league) => league.copyWith(playerTeamId: null),
        autosave: false,
      );
      final matchDay = matchDaysForWeek(1).midweekDay;
      final target = const CalendarService().advanceDay(1, matchDay);
      final feedback = <CalendarDaySimulationFeedback>[];
      final waits = <Duration>[];

      final result = await controller.simulateToDate(
        target.$1,
        target.$2,
        observer: feedback.add,
        pacer: _fakePacer(waits),
      );

      expect(result.stopReason, SimulationStopReason.reachedTarget);
      expect(feedback, hasLength(result.daysSimulated));
      expect(feedback.map((item) => item.sequence), [
        for (var index = 0; index < feedback.length; index++) index,
      ]);
      expect(feedback.map((item) => '${item.week}:${item.day}'), [
        for (var day = 1; day <= matchDay; day++) '1:$day',
      ]);
      expect(
        feedback.any((item) => item.results.isEmpty),
        isTrue,
        reason: 'A completed no-result day must still clear stale feedback.',
      );
      expect(
        feedback.any((item) => item.results.isNotEmpty),
        isTrue,
        reason: 'The seeded fixture must emit the completed match day.',
      );
      expect(waits, hasLength(feedback.length));
      expect(waits, everyElement(const Duration(milliseconds: 500)));
    },
  );

  test(
    'calendar observer emits only at the hourly end-of-day boundary',
    () async {
      await controller.updateLeague(
        (league) => league.copyWith(
          playerTeamId: null,
          currentWeek: 46,
          currentDay: 2,
          currentHour: 1,
          hourlyPlayerOfferUsed: false,
          hourlyStaffOfferUsed: false,
        ),
        autosave: false,
      );
      final feedback = <CalendarDaySimulationFeedback>[];

      final result = await controller.simulateToDate(
        46,
        3,
        observer: feedback.add,
        pacer: _fakePacer(<Duration>[]),
      );

      expect(result.stopReason, SimulationStopReason.reachedTarget);
      expect(result.daysSimulated, 1);
      expect(feedback, hasLength(1));
      expect(feedback.single.week, 46);
      expect(feedback.single.day, 2);
      expect(controller.save!.leagueState.currentWeek, 46);
      expect(controller.save!.leagueState.currentDay, 3);
      expect(controller.save!.leagueState.currentHour, 1);
    },
  );

  test(
    'calendar cancellation after a completed day stops before the next day',
    () async {
      await controller.updateLeague(
        (league) => league.copyWith(playerTeamId: null),
        autosave: false,
      );
      final matchDay = matchDaysForWeek(1).midweekDay;
      final target = const CalendarService().advanceDay(1, matchDay);
      final feedback = <CalendarDaySimulationFeedback>[];
      final waits = <Duration>[];

      final result = await controller.simulateToDate(
        target.$1,
        target.$2,
        observer: (event) {
          feedback.add(event);
          if (feedback.length == 1) controller.cancelSimulation();
        },
        pacer: _fakePacer(waits),
      );

      expect(result.stopReason, SimulationStopReason.cancelled);
      expect(result.daysSimulated, 1);
      expect(feedback, hasLength(1));
      expect(feedback.single.week, 1);
      expect(feedback.single.day, 1);
      expect(controller.save!.leagueState.currentWeek, 1);
      expect(controller.save!.leagueState.currentDay, 2);
      expect(waits, [const Duration(milliseconds: 500)]);
    },
  );

  test(
    'calendar cancellation during pacing stops before starting the next day',
    () async {
      await controller.updateLeague(
        (league) => league.copyWith(playerTeamId: null),
        autosave: false,
      );
      final matchDay = matchDaysForWeek(1).midweekDay;
      final target = const CalendarService().advanceDay(1, matchDay);
      final feedback = <CalendarDaySimulationFeedback>[];
      final waits = <Duration>[];
      var pacingStarted = false;

      final result = await controller.simulateToDate(
        target.$1,
        target.$2,
        observer: feedback.add,
        pacer: _fakePacer(
          waits,
          onDelay: () {
            pacingStarted = true;
            controller.cancelSimulation();
          },
        ),
      );

      expect(pacingStarted, isTrue);
      expect(result.stopReason, SimulationStopReason.cancelled);
      expect(result.daysSimulated, 1);
      expect(feedback, hasLength(1));
      expect(feedback.single.completedDateKey, '1:1');
      expect(controller.save!.leagueState.currentWeek, 1);
      expect(controller.save!.leagueState.currentDay, 2);
      expect(waits, [const Duration(milliseconds: 500)]);
    },
  );

  test(
    'a replacement calendar session cannot reset the old cancellation token',
    () async {
      await controller.updateLeague(
        (league) => league.copyWith(playerTeamId: null),
        autosave: false,
      );
      final matchDay = matchDaysForWeek(1).midweekDay;
      final target = const CalendarService().advanceDay(1, matchDay);
      final oldFeedback = <CalendarDaySimulationFeedback>[];
      final oldWaits = <Duration>[];
      final oldObserved = Completer<void>();
      final releaseOldPacing = Completer<void>();
      final oldPacer = CalendarSimulationPacer(
        elapsedSource: () => Duration.zero,
        delay: (duration) {
          oldWaits.add(duration);
          return releaseOldPacing.future;
        },
      );

      final oldFuture = controller.simulateToDate(
        target.$1,
        target.$2,
        observer: (event) {
          oldFeedback.add(event);
          if (!oldObserved.isCompleted) oldObserved.complete();
        },
        pacer: oldPacer,
      );
      await oldObserved.future;
      for (var attempt = 0; attempt < 5 && oldWaits.isEmpty; attempt++) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(oldWaits, [const Duration(milliseconds: 500)]);

      final newFeedback = <CalendarDaySimulationFeedback>[];
      final newResult = await controller.simulateToDate(
        target.$1,
        target.$2,
        observer: newFeedback.add,
        pacer: _fakePacer(<Duration>[]),
      );

      expect(newResult.stopReason, SimulationStopReason.reachedTarget);
      expect(newFeedback, isNotEmpty);
      expect(newFeedback.first.completedDateKey, '1:2');
      expect(
        newFeedback.map((event) => event.completedDateKey),
        isNot(contains('1:1')),
      );

      releaseOldPacing.complete();
      final oldResult = await oldFuture;
      expect(oldResult.stopReason, SimulationStopReason.cancelled);
      expect(oldResult.daysSimulated, 1);
      expect(oldFeedback, hasLength(1));
      expect(oldFeedback.single.completedDateKey, '1:1');
    },
  );

  test(
    'calendar feedback merges AI and auto-player results in schedule order',
    () async {
      final matchDay = matchDaysForWeek(1).midweekDay;
      final target = const CalendarService().advanceDay(1, matchDay);
      final feedback = <CalendarDaySimulationFeedback>[];

      final result = await controller.simulateToDate(
        target.$1,
        target.$2,
        observer: feedback.add,
        pacer: _fakePacer(<Duration>[]),
      );
      final round = scheduleRoundForWeekSlot(1, 0);
      final persisted = controller.save!.leagueState.currentSeason.schedule
          .where((match) => match.round == round && match.result != null)
          .toList();
      final dayFeedback = feedback.firstWhere(
        (event) => event.week == 1 && event.day == matchDay,
      );
      final lastResult = result.lastResult;

      expect(
        result.stopReason,
        anyOf(SimulationStopReason.reachedTarget, SimulationStopReason.urgent),
      );
      expect(persisted, hasLength(15));
      expect(dayFeedback.results, hasLength(persisted.length));
      expect(lastResult, isNotNull);
      expect(
        dayFeedback.results.map((row) => row.matchId).toList(),
        persisted.map((match) => match.id).toList(),
      );
      expect(
        dayFeedback.results.map((row) => row.matchId).toSet(),
        hasLength(dayFeedback.results.length),
      );
      for (final row in dayFeedback.results) {
        final persistedMatch = persisted.firstWhere(
          (match) => match.id == row.matchId,
        );
        final persistedResult = persistedMatch.result;
        expect(persistedResult, isNotNull);
        expect(row.homeGoals, persistedResult!.homeGoals);
        expect(row.awayGoals, persistedResult.awayGoals);
        final home = controller.save!.leagueState.teamById(row.homeTeamId);
        final away = controller.save!.leagueState.teamById(row.awayTeamId);
        expect(home, isNotNull);
        expect(away, isNotNull);
        expect(row.homeTeamName, home!.name);
        expect(row.awayTeamName, away!.name);
      }

      final lastResultRows = lastResult!.simulatedResults
          .map(
            (match) =>
                '${match.homeTeamId}->${match.awayTeamId}:'
                '${match.homeGoals}-${match.awayGoals}',
          )
          .toList();
      final feedbackRows = dayFeedback.results
          .map(
            (row) =>
                '${row.homeTeamId}->${row.awayTeamId}:'
                '${row.homeGoals}-${row.awayGoals}',
          )
          .toList();
      expect(lastResult.simulatedResults, hasLength(persisted.length));
      expect(lastResultRows, feedbackRows);
    },
  );

  test(
    'pending urgent stop does not publish an incomplete calendar day',
    () async {
      await controller.updateLeague(
        (league) => league.copyWith(
          inbox: league.inbox.addMessage(
            GameMessage(
              id: 'task38-pending-urgent',
              type: MessageType.tradeWindowEvent,
              priority: MessagePriority.urgent,
              seasonYear: league.currentSeason.year,
              week: league.currentWeek,
              day: league.currentDay,
              titleKey: 'task38.urgent.title',
              bodyKey: 'task38.urgent.body',
            ),
          ),
        ),
        autosave: false,
      );
      final feedback = <CalendarDaySimulationFeedback>[];

      final result = await controller.simulateToDate(
        1,
        2,
        observer: feedback.add,
      );

      expect(result.stopReason, SimulationStopReason.urgent);
      expect(result.daysSimulated, 0);
      expect(feedback, isEmpty);
      expect(controller.save!.leagueState.currentWeek, 1);
      expect(controller.save!.leagueState.currentDay, 1);
    },
  );

  test(
    'player auto-simulation failure stops without publishing an incomplete day',
    () async {
      final matchDay = matchDaysForWeek(1).midweekDay;
      final round = scheduleRoundForWeekSlot(1, 0);
      final save = controller.save!;
      final playerId = save.leagueState.playerTeamId!;
      final playerFixture = save.leagueState.currentSeason.schedule.firstWhere(
        (match) =>
            match.round == round &&
            (match.homeTeamId == playerId || match.awayTeamId == playerId),
      );
      final brokenFixture = playerFixture.homeTeamId == playerId
          ? playerFixture.copyWith(awayTeamId: 'missing-auto-team')
          : playerFixture.copyWith(homeTeamId: 'missing-auto-team');
      await controller.updateLeague(
        (league) => league.copyWith(
          currentWeek: 1,
          currentDay: matchDay,
          currentSeason: league.currentSeason.copyWith(
            schedule: [
              for (final match in league.currentSeason.schedule)
                if (match.id != brokenFixture.id) brokenFixture else match,
            ],
          ),
        ),
        autosave: false,
      );
      final feedback = <CalendarDaySimulationFeedback>[];
      final target = const CalendarService().advanceDay(1, matchDay);

      final result = await controller.simulateToDate(
        target.$1,
        target.$2,
        observer: feedback.add,
      );

      expect(result.stopReason, SimulationStopReason.playerMatch);
      expect(result.daysSimulated, 0);
      expect(result.lastResult, isNotNull);
      expect(feedback, isEmpty);
      expect(controller.save!.leagueState.currentWeek, 1);
      expect(controller.save!.leagueState.currentDay, matchDay);
    },
  );

  // **Validates: Requirements 1.1**
  test(
    'pre-fix exploration records an inter-day cadence counterexample',
    () async {
      final seed = controller.save!.saveSeed;
      final matchDay = matchDaysForWeek(1).midweekDay;
      final target = matchDay < 7 ? (1, matchDay + 1) : (2, 1);

      final result = await controller.simulateToDate(target.$1, target.$2);
      final steps = tracedController.steps;
      final gaps = [
        for (var i = 1; i < steps.length; i++)
          steps[i].startedAt - steps[i - 1].completedAt,
      ];
      final gapMilliseconds = gaps.map((gap) => gap.inMilliseconds).toList();

      expect(
        result.daysSimulated,
        greaterThanOrEqualTo(2),
        reason:
            'Fixture must complete at least two days before checking cadence. '
            'trace=${_traceDescription(steps)}',
      );
      expect(
        gaps,
        isNotEmpty,
        reason:
            'No adjacent completed-day trace was captured: '
            '${_traceDescription(steps)}',
      );
      expect(
        gaps.every(
          (gap) =>
              gap >= const Duration(milliseconds: 450) &&
              gap <= const Duration(milliseconds: 600),
        ),
        isTrue,
        reason:
            'Pre-fix cadence counterexample: seed=$seed target=W${target.$1} '
            'D${target.$2}, completedDays=${result.daysSimulated}, '
            'gapsMs=$gapMilliseconds, trace=${_traceDescription(steps)}',
      );
    },
  );

  // **Validates: Requirements 1.2, 1.3**
  test(
    'pre-fix exploration requires complete schedule-ordered lastResult rows',
    () async {
      final seed = controller.save!.saveSeed;
      final matchDay = matchDaysForWeek(1).midweekDay;
      final target = matchDay < 7 ? (1, matchDay + 1) : (2, 1);
      final round = scheduleRoundForWeekSlot(1, 0);

      final result = await controller.simulateToDate(target.$1, target.$2);
      final persisted = controller.save!.leagueState.currentSeason.schedule
          .where((match) => match.round == round && match.result != null)
          .toList();
      final feedbackRows = result.lastResult?.simulatedResults ?? const [];
      final persistedPairs = persisted
          .map((match) => '${match.homeTeamId}->${match.awayTeamId}')
          .toList();
      final feedbackPairs = feedbackRows
          .map((match) => '${match.homeTeamId}->${match.awayTeamId}')
          .toList();

      expect(
        persisted.length,
        greaterThanOrEqualTo(3),
        reason:
            'Fixture must contain several persisted round-$round results. '
            'persisted=$persistedPairs',
      );
      expect(
        result.lastResult,
        isNotNull,
        reason:
            'Batch result did not expose lastResult for '
            'seed=$seed target=W${target.$1} D${target.$2}.',
      );
      expect(
        feedbackRows.length,
        persisted.length,
        reason:
            'Pre-fix feedback counterexample: seed=$seed target=W${target.$1} '
            'D${target.$2}; persistedCount=${persisted.length}, '
            'lastResultCount=${feedbackRows.length}, '
            'persisted=$persistedPairs, lastResult=$feedbackPairs',
      );
      expect(
        feedbackPairs,
        persistedPairs,
        reason:
            'Pre-fix feedback order counterexample: persisted=$persistedPairs, '
            'lastResult=$feedbackPairs',
      );
    },
  );
}

class _StepTrace {
  const _StepTrace({
    required this.startWeek,
    required this.startDay,
    required this.startedAt,
    required this.completedAt,
    required this.endWeek,
    required this.endDay,
  });

  final int startWeek;
  final int startDay;
  final Duration startedAt;
  final Duration completedAt;
  final int? endWeek;
  final int? endDay;
}

class _TracingGameController extends GameController {
  _TracingGameController(super.ref, this.clock);

  final Stopwatch clock;
  final steps = <_StepTrace>[];

  @override
  Future<DaySimulationResult?> advanceOneDay({
    bool resolveContractMarket = true,
  }) async {
    final before = save?.leagueState;
    final startedAt = clock.elapsed;
    final result = await super.advanceOneDay(
      resolveContractMarket: resolveContractMarket,
    );
    final after = save?.leagueState;
    steps.add(
      _StepTrace(
        startWeek: before?.currentWeek ?? -1,
        startDay: before?.currentDay ?? -1,
        startedAt: startedAt,
        completedAt: clock.elapsed,
        endWeek: after?.currentWeek,
        endDay: after?.currentDay,
      ),
    );
    return result;
  }
}

String _traceDescription(List<_StepTrace> steps) => [
  for (final step in steps)
    'W${step.startWeek}D${step.startDay}->W${step.endWeek}D${step.endDay}'
        '(${step.startedAt.inMilliseconds}-${step.completedAt.inMilliseconds}ms)',
].join(', ');
