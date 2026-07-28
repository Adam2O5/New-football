import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/data/save_repository.dart';

void main() {
  late Directory tempDir;
  late ProviderContainer container;
  late GameController controller;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('nf_sim_until_');
    container = ProviderContainer(
      overrides: [
        saveRepositoryProvider.overrideWithValue(
          SaveRepository(overrideDirectory: tempDir),
        ),
      ],
    );
    controller = container.read(gameControllerProvider.notifier);
    await controller.createNewGame(
      const NewGameRequest(
        saveName: 'SimUntil',
        playerTeamId: 'team_east_0',
        seed: 7,
      ),
    );
  });

  tearDown(() async {
    container.dispose();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('simulateUntilNextMatch stops on the player\'s first fixture', () async {
    final result = await controller.simulateUntilNextMatch();
    expect(result.stopReason, SimulationStopReason.playerMatch);
    expect(result.lastResult?.playerMatch, isNotNull);
    expect(result.daysSimulated, greaterThan(0));
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
    await controller.updateLeague(
      (l) => l.copyWith(playerTeamId: null),
      autosave: false,
    );
    // The trade deadline (week 23) still raises an urgent calendar
    // message, which always pauses the batch — acknowledge it and resume.
    var result = await controller.simulateUntilPhaseEnd(SeasonPhase.regular);
    var guard = 0;
    while (result.stopReason == SimulationStopReason.urgent && guard < 5) {
      for (final m in controller.save!.leagueState.inbox.pendingUrgent) {
        await controller.markMessageRead(m.id);
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
    // Inject a minimal draft state where it's the player team's turn —
    // GameController must not simulate past this without a pick.
    await controller.updateLeague(
      (l) => l.copyWith(
        currentSeason: l.currentSeason.copyWith(
          draftState: DraftState(
            year: l.currentSeason.year,
            order: [
              const DraftPick(round: 1, pickNumber: 1, teamId: 'team_east_0'),
            ],
            draftClass: DraftClass(year: l.currentSeason.year),
          ),
        ),
      ),
      autosave: false,
    );
    final result = await controller.simulateToDate(48, 1);
    expect(result.stopReason, SimulationStopReason.event);
    expect(result.eventId, 'draft');
    expect(result.daysSimulated, 0);
  });
}
