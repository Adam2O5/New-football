import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/engine/match_engine.dart';
import 'package:new_football/data/save_repository.dart';

void main() {
  late Directory tempDir;
  late ProviderContainer container;
  late GameController controller;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('nf_task6_');
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
        saveName: 'Task 6',
        playerTeamId: 'team_europe_0',
        seed: 7,
      ),
    );
  });

  tearDown(() async {
    container.dispose();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  Future<void> setDate(int week, int day, {int? hour}) async {
    await controller.updateLeague(
      (league) => league.copyWith(
        currentWeek: week,
        currentDay: day,
        currentHour: hour,
        hourlyPlayerOfferUsed: false,
        hourlyStaffOfferUsed: false,
      ),
      autosave: false,
    );
  }

  test('currentHour round-trips in the versioned save model', () {
    final save = controller.save!;
    final hourly = save.copyWith(
      leagueState: save.leagueState.copyWith(currentHour: 7),
    );
    final restored = GameSave.fromJson(
      jsonDecode(jsonEncode(hourly.toJson())) as Map<String, dynamic>,
    );

    expect(restored.leagueState.currentHour, 7);
    expect(SaveSchema.currentVersion, 7);
  });

  test('hourly mode is limited to extensions and FA phase I', () async {
    await setDate(46, 1);
    expect(controller.save!.leagueState.currentHour, isNull);

    await setDate(46, 2);
    expect(controller.save!.leagueState.currentHour, isNull);
    await controller.advanceOneHour();
    expect(controller.save!.leagueState.currentHour, 2);

    await setDate(47, 7, hour: 10);
    await controller.advanceOneHour();
    expect(controller.save!.leagueState.currentWeek, 48);
    expect(controller.save!.leagueState.currentDay, 1);
    expect(controller.save!.leagueState.currentHour, isNull);
  });

  test('ten hourly clicks advance exactly one calendar day', () async {
    await setDate(46, 2, hour: 1);

    for (var i = 0; i < 10; i++) {
      final result = await controller.advanceOneHour();
      expect(result, isNotNull);
    }

    final league = controller.save!.leagueState;
    expect(league.currentWeek, 46);
    expect(league.currentDay, 3);
    expect(league.currentHour, 1);
    expect(league.hourlyPlayerOfferUsed, isFalse);
    expect(league.hourlyStaffOfferUsed, isFalse);
  });

  test('an unused hourly slot is discarded on direct day transition', () async {
    await setDate(46, 2, hour: 1);
    await controller.advanceOneHour();
    expect(controller.save!.leagueState.currentHour, 2);

    await controller.advanceOneDay();
    final league = controller.save!.leagueState;
    expect(league.currentWeek, 46);
    expect(league.currentDay, 3);
    expect(league.currentHour, 1);
    expect(league.hourlyPlayerOfferUsed, isFalse);
    expect(league.hourlyStaffOfferUsed, isFalse);
  });

  test('match result is stamped for the next day', () async {
    final league = controller.save!.leagueState;
    final match = league.currentSeason.schedule.first;
    final home = league.teamById(match.homeTeamId)!;
    final away = league.teamById(match.awayTeamId)!;
    final result = const MatchEngine().simulateFull(
      home: home,
      away: away,
      rngSeed: 7,
    );
    final next = DaySimulator().applyPlayerMatchResult(league, match, result);
    final message = next.inbox.messages.firstWhere(
      (item) => item.type == MessageType.matchResult,
    );

    expect(next.currentWeek, 1);
    expect(next.currentDay, 2);
    expect(message.week, 1);
    expect(message.day, 2);
  });

  test('an urgent message blocks both day and hour transitions', () async {
    await controller.updateLeague(
      (league) => league.copyWith(
        inbox: league.inbox.addMessage(
          GameMessage(
            id: 'task6-urgent',
            type: MessageType.tradeWindowEvent,
            priority: MessagePriority.urgent,
            seasonYear: league.currentSeason.year,
            week: league.currentWeek,
            titleKey: 'urgent',
            bodyKey: 'urgent',
          ),
        ),
      ),
      autosave: false,
    );

    await setDate(46, 2, hour: 1);
    final before = controller.save!.leagueState;
    expect(await controller.advanceOneDay(), isNull);
    expect(await controller.advanceOneHour(), isNull);
    final after = controller.save!.leagueState;
    expect(after.currentWeek, before.currentWeek);
    expect(after.currentDay, before.currentDay);
    expect(after.currentHour, before.currentHour);
  });
}
