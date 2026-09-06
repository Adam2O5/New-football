@Tags(['slow'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/simulation_worker.dart';

/// Covers the isolate boundary itself: the app runs day advancement through
/// [IsolateSimulationRunner], while every other test uses the inline runner.
/// What can only break here is the transport — an unsendable payload, a lost
/// reply, or a worker that answers from the wrong cached state.
void main() {
  // Day simulation in an unoptimized test VM costs seconds per day, and these
  // tests deliberately run the real pipeline on both sides of the port.
  const generous = Timeout(Duration(minutes: 5));

  late GameSave game;

  setUp(() {
    game = GameFactory().create(
      const NewGameRequest(
        saveName: 'WorkerTransport',
        playerTeamId: 'team_europe_0',
        seed: 77,
      ),
    );
  });

  test('advances the calendar across the isolate boundary', () async {
    final runner = IsolateSimulationRunner();
    addTearDown(runner.dispose);

    var league = game.leagueState;
    final startWeek = league.currentWeek;
    final startDay = league.currentDay;

    for (var i = 0; i < 3; i++) {
      final step = await runner.advanceDay(
        league,
        saveSeed: game.saveSeed,
        blockOnPendingUrgent: false,
      );
      expect(step.result, isNotNull);
      league = step.league;
    }

    expect(
      league.currentWeek != startWeek || league.currentDay != startDay,
      isTrue,
      reason: 'three days should move the calendar',
    );
  }, timeout: generous);

  test('a cached step and a fully sent step produce the same day', () async {
    final runner = IsolateSimulationRunner();
    addTearDown(runner.dispose);

    // The reply carries the same state the worker kept, so continuing from it
    // sends no league at all and the worker resumes from its own copy.
    final first = await runner.advanceDay(
      game.leagueState,
      saveSeed: game.saveSeed,
      blockOnPendingUrgent: false,
    );
    final cached = await runner.advanceDay(
      first.league,
      saveSeed: game.saveSeed,
      blockOnPendingUrgent: false,
    );

    // A different instance of the same state defeats the identity check, so
    // this step travels in full. Both paths must reach the same day.
    final resent = await runner.advanceDay(
      first.league.copyWith(),
      saveSeed: game.saveSeed,
      blockOnPendingUrgent: false,
    );

    expect(resent.league.currentWeek, cached.league.currentWeek);
    expect(resent.league.currentDay, cached.league.currentDay);
    expect(resent.result?.stopReason, cached.result?.stopReason);
  }, timeout: generous);

  test('reaches the same date as the inline runner', () async {
    final isolated = IsolateSimulationRunner();
    addTearDown(isolated.dispose);
    final inline = InlineSimulationRunner();

    var viaWorker = game.leagueState;
    var viaInline = game.leagueState;
    for (var i = 0; i < 3; i++) {
      viaWorker = (await isolated.advanceDay(
        viaWorker,
        saveSeed: game.saveSeed,
        blockOnPendingUrgent: false,
      )).league;
      viaInline = (await inline.advanceDay(
        viaInline,
        saveSeed: game.saveSeed,
        blockOnPendingUrgent: false,
      )).league;
    }

    // Message ids come from a random UUID, so the two states are never deeply
    // equal. The seeded domain outcome is what has to match.
    expect(viaWorker.currentWeek, viaInline.currentWeek);
    expect(viaWorker.currentDay, viaInline.currentDay);
    expect(
      viaWorker.currentSeason.schedule
          .where((match) => match.result != null)
          .length,
      viaInline.currentSeason.schedule
          .where((match) => match.result != null)
          .length,
    );
  }, timeout: generous);

  test('rejects work after dispose', () async {
    final runner = IsolateSimulationRunner();
    await runner.advanceDay(
      game.leagueState,
      saveSeed: game.saveSeed,
      blockOnPendingUrgent: false,
    );
    runner.dispose();

    await expectLater(
      runner.advanceDay(
        game.leagueState,
        saveSeed: game.saveSeed,
        blockOnPendingUrgent: false,
      ),
      throwsA(isA<SimulationWorkerException>()),
    );
  }, timeout: generous);
}
