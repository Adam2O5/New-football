@Tags(['property'])
library;

import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/models/calendar_simulation_feedback.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/services/calendar_simulation_pacer.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/data/save_repository.dart';

void main() {
  // **Validates: Requirements 2.1, 2.2, 2.3, 2.5**
  test(
    'seeded calendar batches preserve ordered, complete day feedback',
    () async {
      for (final batchCase in _generatedBatchCases()) {
        final container = _newContainer(_gameFor(batchCase));
        final controller = container.read(gameControllerProvider.notifier);
        final beforeResultIds = _resultIds(controller.save!);
        final feedback = <CalendarDaySimulationFeedback>[];
        final waits = <Duration>[];

        try {
          final result = await controller.simulateToDate(
            batchCase.targetWeek,
            batchCase.targetDay,
            observer: feedback.add,
            pacer: _fakePacer(waits),
          );
          final save = controller.save!;

          final identities = feedback.map((event) => event.identityKey).toSet();
          expect(
            identities,
            hasLength(feedback.length),
            reason: '${batchCase.description}: duplicate run/sequence/date',
          );
          expect(
            feedback.map((event) => event.sequence),
            [for (var index = 0; index < feedback.length; index++) index],
            reason: '${batchCase.description}: sequence is not monotonic',
          );
          expect(
            feedback.map((event) => event.runId).toSet(),
            hasLength(feedback.isEmpty ? 0 : 1),
            reason: '${batchCase.description}: feedback crossed run boundaries',
          );

          final dateOrdinals = feedback
              .map((event) => _dateOrdinal(event.week, event.day))
              .toList();
          expect(
            dateOrdinals,
            orderedEquals(dateOrdinals),
            reason: '${batchCase.description}: completed dates are not ordered',
          );
          for (var index = 1; index < dateOrdinals.length; index++) {
            expect(
              dateOrdinals[index],
              greaterThan(dateOrdinals[index - 1]),
              reason: '${batchCase.description}: a day was emitted twice',
            );
          }
          for (final event in feedback) {
            expect(
              _dateOrdinal(event.week, event.day),
              lessThanOrEqualTo(
                _dateOrdinal(batchCase.targetWeek, batchCase.targetDay),
              ),
              reason: '${batchCase.description}: feedback overshot the target',
            );
            _expectPersistedRowsForDay(
              event,
              save,
              beforeResultIds,
              batchCase.description,
            );
          }

          final persistedNewResults = save.leagueState.currentSeason.schedule
              .where(
                (match) =>
                    match.result != null && !beforeResultIds.contains(match.id),
              )
              .toList();
          final feedbackIds = feedback
              .expand((event) => event.results)
              .map((row) => row.matchId)
              .toList();
          expect(
            feedbackIds,
            orderedEquals(persistedNewResults.map((match) => match.id)),
            reason:
                '${batchCase.description}: feedback does not match persisted '
                'ScheduledMatch.result rows',
          );
          expect(
            feedback.length,
            result.daysSimulated,
            reason: '${batchCase.description}: one observer event per day',
          );
          expect(
            waits.length,
            feedback.length,
            reason: '${batchCase.description}: one pacing cycle per day',
          );
          expect(
            _dateOrdinal(
              save.leagueState.currentWeek,
              save.leagueState.currentDay,
            ),
            lessThanOrEqualTo(
              _dateOrdinal(batchCase.targetWeek, batchCase.targetDay),
            ),
            reason: '${batchCase.description}: final date overshot the target',
          );
          expect(
            result.stopReason,
            anyOf(
              SimulationStopReason.reachedTarget,
              SimulationStopReason.urgent,
            ),
            reason: '${batchCase.description}: unexpected stop path',
          );
          if (result.stopReason == SimulationStopReason.reachedTarget) {
            expect(
              (save.leagueState.currentWeek, save.leagueState.currentDay),
              (batchCase.targetWeek, batchCase.targetDay),
              reason: '${batchCase.description}: reachedTarget stopped early',
            );
          }
        } finally {
          container.dispose();
        }
      }
    },
  );

  // **Validates: Requirements 2.2, 2.3**
  test('seeded 0..N result distributions keep one ordered row per result', () {
    final distributions = _generatedResultDistributions();
    expect(distributions.map((item) => item.results.length), contains(0));
    expect(
      distributions.map((item) => item.results.length),
      contains(isNot(lessThan(3))),
    );

    for (final distribution in distributions) {
      final feedback = CalendarDaySimulationFeedback(
        runId: 91,
        sequence: distribution.day,
        week: 4,
        day: distribution.day,
        results: distribution.results,
      );
      final ids = feedback.results.map((row) => row.identityKey).toSet();
      final positions = feedback.results
          .map((row) => row.schedulePosition)
          .toList();
      final expectedPositions = [...positions]..sort();

      expect(
        ids,
        hasLength(feedback.results.length),
        reason: 'day ${distribution.day}: a result was aggregated twice',
      );
      expect(
        positions,
        orderedEquals(expectedPositions),
        reason: 'day ${distribution.day}: schedule order was not stable',
      );
      expect(
        feedback.results,
        orderedEquals(distribution.results),
        reason: 'day ${distribution.day}: aggregation changed row order',
      );
      expect(
        feedback.results.length,
        distribution.results.length,
        reason: 'day ${distribution.day}: one row is required per result',
      );

      final autoRows = feedback.results
          .where((row) => row.matchId.startsWith('auto-player-'))
          .toList();
      expect(
        autoRows,
        hasLength(distribution.results.length >= 3 ? 1 : 0),
        reason: 'day ${distribution.day}: auto-player result cardinality',
      );
      if (autoRows.isNotEmpty) {
        expect(
          autoRows.single.schedulePosition,
          distribution.results.length - 1,
        );
      }
    }
  });

  // **Validates: Requirements 2.4, 2.5**
  test(
    'seeded cancellation modes never start the next day and resume at save date',
    () async {
      for (final mode in _CancellationMode.values) {
        final batchCase = _CancellationCase(
          mode: mode,
          seed: 7,
          startWeek: 1,
          startDay: 1,
          targetWeek: 1,
          targetDay: 4,
        );
        final container = ProviderContainer(
          overrides: [
            saveRepositoryProvider.overrideWithValue(_NoopSaveRepository()),
            gameControllerProvider.overrideWith((ref) {
              final overrideController = _CancellationController(ref, mode);
              overrideController.state = AsyncValue.data(_gameFor(batchCase));
              return overrideController;
            }),
          ],
        );
        final controller =
            container.read(gameControllerProvider.notifier)
                as _CancellationController;
        final feedback = <CalendarDaySimulationFeedback>[];
        final waits = <Duration>[];

        try {
          final pacer = _fakePacer(
            waits,
            onDelay: mode == _CancellationMode.duringPacing
                ? () => controller.cancelSimulation()
                : null,
          );
          final result = await controller.simulateToDate(
            batchCase.targetWeek,
            batchCase.targetDay,
            observer: feedback.add,
            pacer: pacer,
          );
          final persistedAtStop = controller.save!.leagueState;
          final persistedOrdinal = _dateOrdinal(
            persistedAtStop.currentWeek,
            persistedAtStop.currentDay,
          );

          expect(
            result.stopReason,
            SimulationStopReason.cancelled,
            reason: '${mode.name}: cancellation did not stop the batch',
          );
          expect(
            controller.startedDaySteps,
            lessThanOrEqualTo(1),
            reason: '${mode.name}: a next day started after cancellation',
          );
          expect(
            feedback.length,
            result.daysSimulated,
            reason: '${mode.name}: feedback/day count diverged',
          );
          expect(
            _dateOrdinal(
              persistedAtStop.currentWeek,
              persistedAtStop.currentDay,
            ),
            lessThanOrEqualTo(
              _dateOrdinal(batchCase.targetWeek, batchCase.targetDay),
            ),
            reason: '${mode.name}: cancellation overshot target',
          );

          if (persistedOrdinal <
              _dateOrdinal(batchCase.targetWeek, batchCase.targetDay)) {
            final resumedFeedback = <CalendarDaySimulationFeedback>[];
            final resumed = await controller.simulateToDate(
              batchCase.targetWeek,
              batchCase.targetDay,
              observer: resumedFeedback.add,
              pacer: _fakePacer(<Duration>[]),
            );

            expect(
              resumedFeedback,
              isNotEmpty,
              reason: '${mode.name}: resume emitted no remaining day',
            );
            expect(
              _dateOrdinal(
                resumedFeedback.first.week,
                resumedFeedback.first.day,
              ),
              persistedOrdinal,
              reason: '${mode.name}: resume did not use persisted date',
            );
            if (feedback.isNotEmpty) {
              expect(
                resumedFeedback.first.runId,
                greaterThan(feedback.first.runId),
                reason: '${mode.name}: resume reused the previous run id',
              );
            }
            expect(
              _dateOrdinal(
                controller.save!.leagueState.currentWeek,
                controller.save!.leagueState.currentDay,
              ),
              lessThanOrEqualTo(
                _dateOrdinal(batchCase.targetWeek, batchCase.targetDay),
              ),
              reason: '${mode.name}: resumed batch overshot target',
            );
            expect(resumed.stopReason, SimulationStopReason.reachedTarget);
          }
        } finally {
          container.dispose();
        }
      }
    },
  );

  // **Validates: Requirements 3.1, 3.2, 3.3, 3.4**
  test(
    'seeded preservation baselines keep domain, result, stop, and navigation snapshots',
    () async {
      final baselineNoResult = await _runCalendarBaseline(
        withPresentation: false,
      );
      final presentationNoResult = await _runCalendarBaseline(
        withPresentation: true,
      );
      _expectSameOutcome(
        baselineNoResult,
        presentationNoResult,
        'calendar no-result day',
      );
      expect(presentationNoResult.feedback, hasLength(1));
      expect(presentationNoResult.feedback.single.results, isEmpty);

      final eventBaseline = await _runEventBaseline();
      final eventRepeat = await _runEventBaseline();
      _expectSameOutcome(eventBaseline, eventRepeat, 'simulateToEvent');

      final dayBaseline = await _runAdvanceDayBaseline();
      final dayRepeat = await _runAdvanceDayBaseline();
      _expectSameOutcome(dayBaseline, dayRepeat, 'advanceOneDay');
    },
  );
}

class _BatchCase {
  const _BatchCase({
    required this.seed,
    required this.startWeek,
    required this.startDay,
    required this.targetWeek,
    required this.targetDay,
    required this.withPlayer,
    required this.description,
  });

  final int seed;
  final int startWeek;
  final int startDay;
  final int targetWeek;
  final int targetDay;
  final bool withPlayer;
  final String description;
}

List<_BatchCase> _generatedBatchCases() {
  final random = _SeededGenerator(0x3a9f_21d7);
  const starts = <(int, int)>[(1, 1), (1, 2), (1, 3), (1, 5), (2, 1)];
  const seeds = [7, 17, 29, 41, 53];
  final cases = <_BatchCase>[];

  for (var index = 0; index < 5; index++) {
    final start =
        starts[(index + random.nextInt(starts.length)) % starts.length];
    final distance = 1 + random.nextInt(4);
    final target = _advance(start, distance);
    final selectedSeed =
        seeds[(index + random.nextInt(seeds.length)) % seeds.length];
    cases.add(
      _BatchCase(
        seed: selectedSeed,
        startWeek: start.$1,
        startDay: start.$2,
        targetWeek: target.$1,
        targetDay: target.$2,
        withPlayer: false,
        description:
            'seed=$selectedSeed start=W${start.$1}D${start.$2} '
            'target=W${target.$1}D${target.$2}',
      ),
    );
  }

  final matchDay = matchDaysForWeek(1).midweekDay;
  final target = const CalendarService().advanceDay(1, matchDay);
  cases.add(
    _BatchCase(
      seed: 7,
      startWeek: 1,
      startDay: 1,
      targetWeek: target.$1,
      targetDay: target.$2,
      withPlayer: true,
      description:
          'seed=7 start=W1D1 target=W${target.$1}D${target.$2} '
          'with AI and auto-player match',
    ),
  );
  return cases;
}

final class _ResultDistribution {
  const _ResultDistribution({required this.day, required this.results});

  final int day;
  final List<CalendarMatchFeedback> results;
}

List<_ResultDistribution> _generatedResultDistributions() {
  final random = _SeededGenerator(0x6d2f_90a1);
  final distributions = <_ResultDistribution>[];
  for (var day = 1; day <= 7; day++) {
    final count = day == 1
        ? 0
        : day == 2
        ? 5
        : random.nextInt(6); // Includes 0 and exercises 0..5 rows.
    final rows = <CalendarMatchFeedback>[];
    for (var index = 0; index < count; index++) {
      final isAutoPlayer = count >= 3 && index == count - 1;
      rows.add(
        CalendarMatchFeedback(
          matchId: isAutoPlayer ? 'auto-player-$day' : 'ai-$day-$index',
          homeTeamId: 'home-$day-$index',
          homeTeamName: isAutoPlayer ? 'Player Home' : 'AI Home $index',
          awayTeamId: 'away-$day-$index',
          awayTeamName: isAutoPlayer ? 'Player Away' : 'AI Away $index',
          homeGoals: (day + index) % 5,
          awayGoals: (day + index + 2) % 5,
          schedulePosition: index,
        ),
      );
    }
    distributions.add(_ResultDistribution(day: day, results: rows));
  }
  return distributions;
}

final class _CancellationCase extends _BatchCase {
  _CancellationCase({
    required this.mode,
    required super.seed,
    required super.startWeek,
    required super.startDay,
    required super.targetWeek,
    required super.targetDay,
  }) : super(withPlayer: false, description: 'cancellation ${mode.name}');

  final _CancellationMode mode;
}

enum _CancellationMode { beforeStep, afterStep, duringPacing }

final class _CancellationController extends GameController {
  _CancellationController(super.ref, this.mode);

  final _CancellationMode mode;
  var startedDaySteps = 0;

  @override
  Future<DaySimulationResult?> advanceOneDay({
    bool resolveContractMarket = true,
  }) async {
    startedDaySteps++;
    if (mode == _CancellationMode.beforeStep && startedDaySteps == 1) {
      cancelSimulation();
    }
    final result = await super.advanceOneDay(
      resolveContractMarket: resolveContractMarket,
    );
    if (mode == _CancellationMode.afterStep && startedDaySteps == 1) {
      cancelSimulation();
    }
    return result;
  }
}

final class _SeededGenerator {
  _SeededGenerator(this._state);

  int _state;

  int nextInt(int upperBound) {
    _state = (_state * 1_664_525 + 1_013_904_223) & 0x7fffffff;
    return _state % upperBound;
  }
}

final class _PreservationOutcome {
  const _PreservationOutcome({
    required this.domainSnapshot,
    required this.resultSnapshot,
    required this.stopSnapshot,
    required this.navigationSnapshot,
    required this.feedback,
  });

  final String domainSnapshot;
  final String resultSnapshot;
  final String stopSnapshot;
  final String navigationSnapshot;
  final List<CalendarDaySimulationFeedback> feedback;
}

Future<_PreservationOutcome> _runCalendarBaseline({
  required bool withPresentation,
}) async {
  final batchCase = const _BatchCase(
    seed: 7,
    startWeek: 1,
    startDay: 1,
    targetWeek: 1,
    targetDay: 2,
    withPlayer: false,
    description: 'calendar no-result preservation',
  );
  final container = _newContainer(_gameFor(batchCase));
  final controller = container.read(gameControllerProvider.notifier);
  final feedback = <CalendarDaySimulationFeedback>[];
  try {
    final result = withPresentation
        ? await controller.simulateToDate(
            batchCase.targetWeek,
            batchCase.targetDay,
            observer: feedback.add,
            pacer: _fakePacer(<Duration>[]),
          )
        : await controller.simulateToDate(
            batchCase.targetWeek,
            batchCase.targetDay,
          );
    return _batchOutcome(controller.save!, result, feedback);
  } finally {
    container.dispose();
  }
}

Future<_PreservationOutcome> _runEventBaseline() async {
  final batchCase = const _BatchCase(
    seed: 7,
    startWeek: 1,
    startDay: 1,
    targetWeek: 1,
    targetDay: 1,
    withPlayer: true,
    description: 'simulateToEvent preservation',
  );
  final container = _newContainer(_gameFor(batchCase));
  final controller = container.read(gameControllerProvider.notifier);
  try {
    final result = await controller.simulateToEvent();
    return _batchOutcome(controller.save!, result, const []);
  } finally {
    container.dispose();
  }
}

Future<_PreservationOutcome> _runAdvanceDayBaseline() async {
  final batchCase = const _BatchCase(
    seed: 17,
    startWeek: 1,
    startDay: 1,
    targetWeek: 1,
    targetDay: 1,
    withPlayer: false,
    description: 'advanceOneDay preservation',
  );
  final container = _newContainer(_gameFor(batchCase));
  final controller = container.read(gameControllerProvider.notifier);
  try {
    final result = await controller.advanceOneDay();
    final resultSnapshot = _matchResultSnapshot(result?.simulatedResults);
    return _PreservationOutcome(
      domainSnapshot: _domainSnapshot(controller.save!),
      resultSnapshot: resultSnapshot,
      stopSnapshot: result == null ? 'none' : 'advanced',
      navigationSnapshot: result?.playerMatch == null ? 'none' : 'match',
      feedback: const [],
    );
  } finally {
    container.dispose();
  }
}

_PreservationOutcome _batchOutcome(
  GameSave save,
  BatchSimulationResult result,
  List<CalendarDaySimulationFeedback> feedback,
) {
  return _PreservationOutcome(
    domainSnapshot: _domainSnapshot(save),
    resultSnapshot: _matchResultSnapshot(result.lastResult?.simulatedResults),
    stopSnapshot: '${result.stopReason.name}:${result.daysSimulated}',
    navigationSnapshot: _navigationSnapshot(result),
    feedback: feedback,
  );
}

void _expectSameOutcome(
  _PreservationOutcome expected,
  _PreservationOutcome actual,
  String label,
) {
  expect(
    actual.domainSnapshot,
    expected.domainSnapshot,
    reason: '$label domain',
  );
  expect(
    actual.resultSnapshot,
    expected.resultSnapshot,
    reason: '$label result',
  );
  expect(actual.stopSnapshot, expected.stopSnapshot, reason: '$label stop');
  expect(
    actual.navigationSnapshot,
    expected.navigationSnapshot,
    reason: '$label navigation',
  );
}

String _navigationSnapshot(BatchSimulationResult result) {
  if (result.lastResult?.playerMatch != null) return 'match';
  return switch (result.stopReason) {
    SimulationStopReason.urgent => 'inbox',
    SimulationStopReason.event => 'event:${result.eventId?.name}',
    _ => 'calendar-stop',
  };
}

String _domainSnapshot(GameSave save) {
  // LeagueState has no wall-clock metadata. Deliberately omit GameSave.meta so
  // DateTime.now() in updateLeague cannot make a deterministic property flaky.
  // The factory also seeds a future draft class as generated presentation data;
  // it is unrelated to these regular-season preservation baselines and is not
  // stable across independently constructed fixtures.
  final snapshot = Map<String, dynamic>.from(
    jsonDecode(jsonEncode(save.leagueState.toJson())) as Map,
  );
  final currentSeason = Map<String, dynamic>.from(
    snapshot['currentSeason'] as Map,
  )..remove('nextDraftState');
  snapshot['currentSeason'] = currentSeason;

  // Message UUIDs are generated independently by each seeded fixture. Keep
  // every inbox field and message order, but replace only those identities
  // with stable bucket positions so inbox behavior remains covered. Inbox is
  // a root field of this serialized league snapshot, alongside currentWeek
  // and currentDay; it is not nested inside currentSeason.
  final inbox = Map<String, dynamic>.from(snapshot['inbox'] as Map);
  for (final bucket in const ['messages', 'scheduled', 'archive']) {
    final rawMessages = inbox[bucket];
    if (rawMessages is! List) continue;
    inbox[bucket] = [
      for (var index = 0; index < rawMessages.length; index++)
        () {
          final message = Map<String, dynamic>.from(rawMessages[index] as Map);
          message['id'] = '$bucket:$index';
          return message;
        }(),
    ];
  }
  snapshot['inbox'] = inbox;

  return jsonEncode(<String, Object?>{
    'seed': save.saveSeed,
    'schema': save.schemaVersion,
    'league': snapshot,
  });
}

String _matchResultSnapshot(List<MatchResult>? results) {
  if (results == null || results.isEmpty) return '';
  return results
      .map(
        (result) =>
            '${result.homeTeamId}->${result.awayTeamId}:'
            '${result.homeGoals}-${result.awayGoals}:'
            '${result.status.name}:${result.reasonCode}',
      )
      .join('|');
}

Set<String> _resultIds(GameSave save) => save.leagueState.currentSeason.schedule
    .where((match) => match.result != null)
    .map((match) => match.id)
    .toSet();

void _expectPersistedRowsForDay(
  CalendarDaySimulationFeedback event,
  GameSave save,
  Set<String> beforeResultIds,
  String description,
) {
  final expected = _scheduledMatchesForDate(save, event.week, event.day)
      .where(
        (match) => match.result != null && !beforeResultIds.contains(match.id),
      )
      .toList();
  expect(
    event.results.map((row) => row.matchId),
    orderedEquals(expected.map((match) => match.id)),
    reason: '$description: wrong rows for W${event.week}D${event.day}',
  );
  for (var index = 0; index < event.results.length; index++) {
    final row = event.results[index];
    final scheduled = expected[index];
    final persisted = scheduled.result!;
    final home = save.leagueState.teamById(scheduled.homeTeamId)!;
    final away = save.leagueState.teamById(scheduled.awayTeamId)!;
    expect(row.matchId, scheduled.id, reason: '$description: match identity');
    expect(
      row.schedulePosition,
      index,
      reason: '$description: schedule position',
    );
    expect(row.homeTeamId, persisted.homeTeamId);
    expect(row.awayTeamId, persisted.awayTeamId);
    expect(row.homeTeamName, home.name);
    expect(row.awayTeamName, away.name);
    expect(row.homeGoals, persisted.homeGoals);
    expect(row.awayGoals, persisted.awayGoals);
    expect(row.status, persisted.status.name);
    expect(row.reasonCode, persisted.reasonCode);
  }
}

List<ScheduledMatch> _scheduledMatchesForDate(
  GameSave save,
  int week,
  int day,
) {
  final calendar = const CalendarService();
  final slot = calendar.regularSeasonSlotForDay(day);
  if (slot == null || !calendar.isActualMatchDay(week, day)) return const [];
  final round = scheduleRoundForWeekSlot(week, slot);
  return save.leagueState.currentSeason.schedule
      .where((match) => match.round == round)
      .toList();
}

ProviderContainer _newContainer(GameSave game) {
  return ProviderContainer(
    overrides: [
      saveRepositoryProvider.overrideWithValue(_NoopSaveRepository()),
      gameControllerProvider.overrideWith((ref) {
        final controller = GameController(ref);
        controller.state = AsyncValue.data(game);
        return controller;
      }),
    ],
  );
}

GameSave _gameFor(_BatchCase batchCase) {
  final game =
      GameFactory(
        seedGenerator: SeedDataGenerator(random: Random(batchCase.seed)),
      ).create(
        NewGameRequest(
          saveName: 'Calendar property ${batchCase.seed}',
          playerTeamId: 'team_europe_0',
          seed: batchCase.seed,
        ),
      );
  return game.copyWith(
    leagueState: game.leagueState.copyWith(
      currentWeek: batchCase.startWeek,
      currentDay: batchCase.startDay,
      currentHour: null,
      playerTeamId: batchCase.withPlayer ? 'team_europe_0' : null,
    ),
  );
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

(int, int) _advance((int, int) start, int distance) {
  var date = start;
  for (var index = 0; index < distance; index++) {
    date = const CalendarService().advanceDay(date.$1, date.$2);
  }
  return date;
}

int _dateOrdinal(int week, int day) => week * 8 + day;

final class _NoopSaveRepository extends SaveRepository {
  @override
  Future<void> save(GameSave gameSave) async {}
}
