@Tags(['long', 'slow', 'integration'])
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/data/save_repository.dart';

void main() {
  setUp(() {
    // ignore: avoid_print
    print(
      'manual long: season_progression_long.dart seed=7 (individual batch parameters below) starting; external budget and logs supplied by scripts/test.ps1',
    );
  });

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
  }, timeout: const Timeout(Duration(minutes: 3)));
}
