import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/field_player_attributes.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/team_event_state.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/core/services/team_event_service.dart';

void main() {
  final baseLeague = SeedDataGenerator(
    random: null,
  ).generateLeague(year: 2026, seed: 2626);
  final sourcePlayer = baseLeague.teams.first.roster.firstWhere(
    (player) => player.position != Position.gk,
  );

  Player fixturePlayer(
    String id, {
    int age = 24,
    double potentialStars = 4.0,
    PlayerPersonality personality = PlayerPersonality.balanced,
    int yearsRemaining = 3,
    int? pointValue,
  }) {
    return sourcePlayer.copyWith(
      id: id,
      name: id,
      age: age,
      personality: personality,
      potentialStars: potentialStars,
      attributes: const PlayerAttributes.outfield(
        stats: FieldPlayerAttributes(
          pace: 70,
          shooting: 70,
          passing: 70,
          dribbling: 70,
          defending: 70,
          physicality: 70,
        ),
      ),
      contract: sourcePlayer.contract.copyWith(yearsRemaining: yearsRemaining),
      pointValue: pointValue ?? sourcePlayer.computePointValue(),
      state: sourcePlayer.state.copyWith(
        injury: null,
        suspensionGamesRemaining: 0,
        minutesThisWeek: 0,
      ),
    );
  }

  Team fixtureTeam(
    String id,
    List<Player> roster, {
    TeamEventState eventState = const TeamEventState(),
    int atmosphere = 50,
    double chemistry = 50,
    List<int> recentMatchResults = const [],
    List<String>? lineupPlayerIds,
  }) {
    return baseLeague.teams.first.copyWith(
      id: id,
      name: id,
      roster: roster,
      lineupPlayerIds:
          lineupPlayerIds ?? [for (final player in roster) player.id],
      benchPlayerIds: const [],
      eventState: eventState,
      atmosphere: atmosphere,
      chemistry: chemistry,
      recentMatchResults: recentMatchResults,
    );
  }

  LeagueState fixtureLeague(
    List<Team> teams, {
    int week = 1,
    int day = 1,
    LeagueStrengthTable? strengthTable,
  }) {
    final playerTeamId = teams.isEmpty ? null : teams.first.id;
    return baseLeague.copyWith(
      teams: teams,
      playerTeamId: playerTeamId,
      currentWeek: week,
      currentDay: day,
      currentSeason: baseLeague.currentSeason.copyWith(
        schedule: const [],
        playoffBrackets: const [],
      ),
      inbox: const Inbox(),
      strengthTable: strengthTable,
    );
  }

  BalanceConfig eventBalance({
    double minutesChance = 0,
    double minutesAmbitiousChance = 0,
    double transferChance = 0,
    double conflictChance = 0,
    double leaderChance = 0,
    double criticismChance = 0,
    double brokenPromiseTransferChance = 0,
  }) {
    return BalanceConfig(
      events: EventsBalance(
        minutesRequestChance: minutesChance,
        minutesRequestAmbitiousChance: minutesAmbitiousChance,
        transferRequestIChance: transferChance,
        lockerRoomConflictChance: conflictChance,
        leaderSupportChance: leaderChance,
        publicCriticismChance: criticismChance,
        transferRequestIIChanceAfterBrokenPromise: brokenPromiseTransferChance,
      ),
    );
  }

  MatchResult matchFor(
    Team home,
    Team away, {
    required String underplayedPlayerId,
    int underplayedMinutes = 0,
  }) {
    return MatchResult(
      homeTeamId: home.id,
      awayTeamId: away.id,
      homeGoals: 1,
      awayGoals: 0,
      homeStats: TeamMatchStats(teamId: home.id),
      awayStats: TeamMatchStats(teamId: away.id),
      playerStats: [
        for (final player in home.roster)
          PlayerMatchStats(
            playerId: player.id,
            minutes: player.id == underplayedPlayerId ? underplayedMinutes : 90,
          ),
      ],
    );
  }

  GameMessage messageOf(LeagueState league, String kind) =>
      league.inbox.messages.lastWhere((message) => message.kind == kind);

  LeagueState sendDecision(
    LeagueState league,
    String kind, {
    String? playerId,
    List<String> temperamentalPlayerIds = const [],
  }) {
    return MessageService().send(
      league,
      type: MessageType.teamEvent,
      kind: kind,
      payload: {
        'teamId': league.playerTeamId,
        if (playerId != null) 'playerId': playerId,
        if (temperamentalPlayerIds.isNotEmpty)
          'temperamentalPlayerIds': temperamentalPlayerIds,
      },
    );
  }

  LeagueState resolveMessage(
    TeamEventService service,
    LeagueState league,
    String optionId,
  ) {
    final message = league.inbox.messages.last;
    return MessageService().resolveDecision(
      league,
      message.id,
      optionId,
      onDecision: (state, item, option) =>
          service.resolveDecision(state, item, option),
    );
  }

  test('accepting more minutes tracks and penalizes a broken promise', () {
    final candidate = fixturePlayer(
      'promise-player',
      age: 22,
      potentialStars: 5.0,
      personality: PlayerPersonality.temperamental,
    );
    final starter = fixturePlayer(
      'promise-starter',
      age: 29,
      potentialStars: 3.0,
    );
    final home = fixtureTeam(
      'promise-home',
      [candidate, starter],
      lineupPlayerIds: [starter.id],
    );
    final away = fixtureTeam('promise-away', [fixturePlayer('away-player')]);
    final league = fixtureLeague([home, away]);
    final service = TeamEventService(balance: eventBalance(minutesChance: 1));

    final pending = service.afterMatch(
      league,
      matchFor(home, away, underplayedPlayerId: candidate.id),
      saveSeed: 26,
    );
    final request = messageOf(pending, 'moreMinutesRequest');
    expect(request.decision!.options.map((option) => option.id), [
      'accept',
      'decline',
    ]);

    final accepted = MessageService().resolveDecision(
      pending,
      request.id,
      'accept',
      onDecision: (state, message, option) =>
          service.resolveDecision(state, message, option),
    );
    final acceptedTeam = accepted.playerTeam!;
    expect(acceptedTeam.atmosphere, 47);
    expect(acceptedTeam.eventState.promises.single.playerId, candidate.id);

    final promise = acceptedTeam.eventState.promises.single.copyWith(
      weeksElapsed: 3,
    );
    final history = [
      for (var week = 1; week <= 5; week++)
        MinutesHistoryEntry(
          playerId: candidate.id,
          seasonYear: 2026,
          week: week,
          minutes: 0,
          possibleMinutes: 90,
        ),
    ];
    final tracked = accepted.copyWith(
      currentWeek: 5,
      teams: [
        acceptedTeam.copyWith(
          eventState: acceptedTeam.eventState.copyWith(
            promises: [promise],
            minutesHistory: history,
          ),
        ),
        accepted.teams[1],
      ],
    );
    final resolved = service.weeklyTick(tracked, saveSeed: 26);
    final resolvedTeam = resolved.playerTeam!;

    expect(resolvedTeam.atmosphere, 32);
    expect(resolvedTeam.eventState.promises, isEmpty);
    final broken = resolved.inbox.messages.lastWhere(
      (message) => message.kind == 'promiseBroken',
    );
    expect(broken.priority, MessagePriority.urgent);
    expect(broken.payload['playerId'], candidate.id);
  });

  test('loyal players never receive a transfer request', () {
    final loyal = fixturePlayer(
      'loyal-player',
      personality: PlayerPersonality.loyal,
      pointValue: 1000,
    );
    final home = fixtureTeam(
      'loyal-home',
      [loyal],
      atmosphere: 20,
      eventState: const TeamEventState(lowAtmosphereWeeks: 4),
    );
    final away = fixtureTeam('loyal-away', [fixturePlayer('loyal-away')]);
    final league = fixtureLeague([home, away], week: 2, day: 3);
    final service = TeamEventService(balance: eventBalance(transferChance: 1));

    final result = service.afterMatch(
      league,
      matchFor(home, away, underplayedPlayerId: loyal.id),
      saveSeed: 26,
    );

    expect(
      result.inbox.messages.where(
        (message) =>
            message.kind == 'transferRequestI' ||
            message.kind == 'transferRequestII',
      ),
      isEmpty,
    );
    expect(result.playerTeam!.eventState.transferSituations, isEmpty);
  });

  test('accepted transfer expires with penalties and restores point value', () {
    final player = fixturePlayer('transfer-player', pointValue: 800);
    final home = fixtureTeam('transfer-home', [player]);
    final away = fixtureTeam('transfer-away', [fixturePlayer('transfer-away')]);
    final league = fixtureLeague([home, away], week: 2, day: 1);
    final service = TeamEventService(balance: eventBalance());
    final pending = sendDecision(
      league,
      'transferRequestI',
      playerId: player.id,
    );

    final accepted = resolveMessage(service, pending, 'accept');
    final acceptedTeam = accepted.playerTeam!;
    expect(acceptedTeam.atmosphere, 53);
    expect(
      acceptedTeam.eventState.pointValueMultiplierFor(player.id),
      closeTo(0.9, 0.000001),
    );

    final expiring = accepted.copyWith(
      currentWeek: 2,
      teams: [
        acceptedTeam.copyWith(
          eventState: acceptedTeam.eventState.copyWith(
            transferSituations: [
              acceptedTeam.eventState.transferSituations.single.copyWith(
                weeksRemaining: 1,
              ),
            ],
          ),
        ),
        accepted.teams[1],
      ],
    );
    final resolved = service.weeklyTick(expiring);
    final resolvedTeam = resolved.playerTeam!;

    expect(resolvedTeam.atmosphere, 38);
    expect(resolvedTeam.chemistry, 46);
    expect(resolvedTeam.eventState.transferSituations, isEmpty);
    expect(resolvedTeam.eventState.pointValueMultiplierFor(player.id), 1.0);
  });

  test(
    'leader support applies its automatic atmosphere and chemistry bonus',
    () {
      final leader = fixturePlayer(
        'leader-player',
        personality: PlayerPersonality.leader,
      );
      final home = fixtureTeam(
        'leader-home',
        [leader],
        recentMatchResults: [1, 1, 1],
      );
      final away = fixtureTeam('leader-away', [fixturePlayer('leader-away')]);
      final service = TeamEventService(balance: eventBalance(leaderChance: 1));

      final result = service.weeklyTick(fixtureLeague([home, away]));
      final updated = result.playerTeam!;

      expect(updated.atmosphere, 54);
      expect(updated.chemistry, 51);
      expect(
        result.inbox.messages.any((m) => m.kind == 'leaderSupport'),
        isTrue,
      );
    },
  );

  test(
    'public criticism punishment and conflict ignore use dedicated options',
    () {
      final critic = fixturePlayer('critic-player', age: 28);
      final conflictA = fixturePlayer(
        'conflict-a',
        personality: PlayerPersonality.temperamental,
      );
      final conflictB = fixturePlayer(
        'conflict-b',
        personality: PlayerPersonality.temperamental,
      );
      final criticTeam = fixtureTeam('critic-home', [critic]);
      final criticLeague = fixtureLeague([criticTeam]);
      final service = TeamEventService(balance: eventBalance());
      final criticism = sendDecision(
        criticLeague,
        'publicCriticism',
        playerId: critic.id,
      );
      final punished = resolveMessage(service, criticism, 'punish');
      final punishedTeam = punished.playerTeam!;

      expect(punishedTeam.atmosphere, 48);
      expect(punishedTeam.chemistry, 48);
      expect(punishedTeam.eventState.publicCriticismRollMultiplier, 0.5);
      expect(
        criticism.inbox.messages.single.decision!.options.map((o) => o.id),
        ['response', 'punish', 'ignore'],
      );

      final conflictTeam = fixtureTeam(
        'conflict-home',
        [conflictA, conflictB],
        atmosphere: 40,
        lineupPlayerIds: [conflictA.id, conflictB.id],
      );
      final conflictLeague = fixtureLeague([conflictTeam]);
      final conflictMessage = sendDecision(
        conflictLeague,
        'dressingRoomConflict',
        temperamentalPlayerIds: [conflictA.id, conflictB.id],
      );
      final ignored = resolveMessage(service, conflictMessage, 'ignore');
      final ignoredTeam = ignored.playerTeam!;

      expect(ignoredTeam.atmosphere, 37);
      expect(ignoredTeam.chemistry, 48);
      expect(
        ignoredTeam.eventState.modifierValue('negativeEventMultiplier'),
        closeTo(0.2, 0.000001),
      );
      expect(
        ignored.inbox.messages
            .lastWhere((message) => message.kind == 'dressingRoomConflict')
            .decision!
            .defaultOnExpiry,
        'ignore',
      );
    },
  );

  test(
    'transfer II uses the current strength table and degrades to no extension',
    () {
      final table = LeagueStrengthTable(
        entries: [
          TeamStrengthEntry(
            teamId: 'postseason-home',
            teamPower: 75,
            expectedRank: 5,
            teamStatus: TeamStatus.contender,
          ),
        ],
        lastCalculatedWeek: 44,
        seasonYear: 2026,
      );
      final player = fixturePlayer('postseason-player', yearsRemaining: 3);
      final team = fixtureTeam('postseason-home', [player]);
      final service = TeamEventService(balance: eventBalance());
      final pending = service.afterPlayoffs(
        fixtureLeague([team], week: 44, strengthTable: table),
        saveSeed: 26,
      );

      expect(
        messageOf(pending, 'transferRequestII').payload['playerId'],
        player.id,
      );
      expect(
        pending.playerTeam!.eventState.pointValueMultiplierFor(player.id),
        closeTo(0.9, 0.000001),
      );

      final ufa = fixturePlayer('ufa-player', yearsRemaining: 1);
      final ufaTeam = fixtureTeam('postseason-home', [ufa]);
      final noExtension = service.afterPlayoffs(
        fixtureLeague([ufaTeam], week: 44, strengthTable: table),
        saveSeed: 26,
      );

      expect(
        messageOf(noExtension, 'declineToExtend').payload['playerId'],
        ufa.id,
      );
      expect(
        noExtension.inbox.messages.where((m) => m.kind == 'transferRequestII'),
        isEmpty,
      );
    },
  );

  test(
    'TeamEventState round-trips promises, transfers, history and modifiers',
    () {
      const state = TeamEventState(
        promises: [
          TeamPromise(
            id: 'promise-1',
            playerId: 'player-1',
            kind: 'moreMinutesRequest',
            createdSeasonYear: 2026,
            createdWeek: 3,
            weeksElapsed: 2,
          ),
        ],
        transferSituations: [
          TeamTransferSituation(
            id: 'transfer-1',
            playerId: 'player-1',
            kind: 'transferRequestI',
            createdSeasonYear: 2026,
            createdWeek: 4,
            weeksRemaining: 2,
          ),
        ],
        minutesHistory: [
          MinutesHistoryEntry(
            playerId: 'player-1',
            seasonYear: 2026,
            week: 4,
            minutes: 36,
            possibleMinutes: 90,
          ),
        ],
        modifiers: [
          TeamTimedModifier(
            type: 'negativeEventMultiplier',
            value: 0.2,
            weeksRemaining: 2,
          ),
        ],
        cooldowns: {'leaderSupport': 3},
        seasonFlags: {'transferRequestII': 2026},
        pointValueMultipliers: {'player-1': 0.9},
        publicCriticismRollMultiplier: 1.5,
        lowAtmosphereWeeks: 4,
      );

      final restored = TeamEventState.fromJson(
        jsonDecode(jsonEncode(state.toJson())) as Map<String, dynamic>,
      );

      expect(restored, state);
      expect(restored.promiseFor('player-1')?.weeksElapsed, 2);
      expect(restored.pointValueMultiplierFor('player-1'), 0.9);
      expect(restored.hasModifier('negativeEventMultiplier'), isTrue);
    },
  );
}
