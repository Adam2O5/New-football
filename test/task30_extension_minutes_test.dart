import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/balance/events_balance.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/field_player_attributes.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/team_event_state.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/negotiation_service.dart';
import 'package:new_football/core/services/team_event_service.dart';

void main() {
  final baseLeague = SeedDataGenerator().generateLeague(year: 2026, seed: 3001);
  final sourcePlayer = baseLeague.teams.first.roster.firstWhere(
    (player) => player.position != Position.gk,
  );

  Player fixturePlayer(
    String id, {
    required int currentOvr,
    double? seasonStartOvr,
    Injury? injury,
    int suspensionGamesRemaining = 0,
  }) {
    final attributes = FieldPlayerAttributes(
      pace: currentOvr,
      shooting: currentOvr,
      passing: currentOvr,
      dribbling: currentOvr,
      defending: currentOvr,
      physicality: currentOvr,
    );
    return sourcePlayer.copyWith(
      id: id,
      name: id,
      attributes: PlayerAttributes.outfield(stats: attributes),
      seasonStartOvr: seasonStartOvr ?? currentOvr.toDouble(),
      contract: sourcePlayer.contract.copyWith(yearsRemaining: 1),
      state: sourcePlayer.state.copyWith(
        injury: injury,
        suspensionGamesRemaining: suspensionGamesRemaining,
      ),
    );
  }

  Team fixtureTeam(
    Player player, {
    TeamEventState eventState = const TeamEventState(),
  }) {
    final baseTeam = baseLeague.teams.first;
    return baseTeam.copyWith(
      roster: [player],
      lineupPlayerIds: [player.id],
      benchPlayerIds: const [],
      eventState: eventState,
      finance: baseTeam.finance.copyWith(totalPayroll: player.contract.salary),
    );
  }

  LeagueState fixtureLeague({
    required Team home,
    required Team away,
    int week = 10,
    int day = 1,
    int? hour = 1,
  }) {
    return baseLeague.copyWith(
      teams: [home, away],
      playerTeamId: home.id,
      currentWeek: week,
      currentDay: day,
      currentHour: hour,
      inbox: const Inbox(),
    );
  }

  MatchResult matchResult(
    Team home,
    Team away, {
    required List<PlayerMatchStats> playerStats,
    bool isWalkover = false,
  }) {
    return MatchResult(
      homeTeamId: home.id,
      awayTeamId: away.id,
      homeGoals: 1,
      awayGoals: 0,
      homeStats: TeamMatchStats(teamId: home.id),
      awayStats: TeamMatchStats(teamId: away.id),
      playerStats: playerStats,
      isWalkover: isWalkover,
    );
  }

  BalanceConfig noRandomTeamEventsBalance() => BalanceConfig(
    events: const EventsBalance(
      minutesRequestChance: 0,
      minutesRequestAmbitiousChance: 0,
      transferRequestIChance: 0,
      transferRequestIIChanceAfterBrokenPromise: 0,
    ),
  );

  Team teamWithMinutes(
    Player player, {
    required int actualMinutes,
    required int possibleMinutes,
  }) => fixtureTeam(
    player,
    eventState: TeamEventState(
      seasonMinutes: [
        SeasonMinutesAggregate(
          playerId: player.id,
          seasonYear: 2026,
          actualMinutes: actualMinutes,
          possibleMinutes: possibleMinutes,
        ),
      ],
    ),
  );

  test('OVR boundary bands use the documented required shares', () {
    const bands = <(int, double)>[
      (87, 0.65),
      (80, 0.50),
      (75, 0.35),
      (70, 0.20),
    ];
    final service = ContractService();

    for (final (ovr, requiredShare) in bands) {
      final player = fixturePlayer('band-$ovr', currentOvr: ovr);
      final exact = service.assessExtensionMinutes(
        team: teamWithMinutes(
          player,
          actualMinutes: (requiredShare * 1000).round(),
          possibleMinutes: 1000,
        ),
        player: player,
      );
      final under = service.assessExtensionMinutes(
        team: teamWithMinutes(
          player,
          actualMinutes: (requiredShare * 1000).round() - 1,
          possibleMinutes: 1000,
        ),
        player: player,
      );

      expect(exact.effectiveOvr, closeTo(ovr, 0.000001));
      expect(exact.requiredMinutesShare, requiredShare);
      expect(exact.ruleActive, isTrue);
      expect(exact.meetsRequirement, isTrue);
      expect(exact.shouldHardReject, isFalse);
      expect(under.shouldHardReject, isTrue);
    }

    final inactivePlayer = fixturePlayer('band-69', currentOvr: 69);
    final inactive = service.assessExtensionMinutes(
      team: teamWithMinutes(
        inactivePlayer,
        actualMinutes: 0,
        possibleMinutes: 1000,
      ),
      player: inactivePlayer,
    );
    expect(inactive.requiredMinutesShare, isNull);
    expect(inactive.ruleActive, isFalse);
    expect(inactive.shouldHardReject, isFalse);
  });

  test('effective OVR is the mean of raw season-start and current OVR', () {
    final player = fixturePlayer(
      'raw-ovr-average',
      currentOvr: 90,
      seasonStartOvr: 80.25,
    );
    final assessment = ContractService().assessExtensionMinutes(
      team: teamWithMinutes(player, actualMinutes: 499, possibleMinutes: 1000),
      player: player,
    );

    expect(assessment.currentOvr, closeTo(90, 0.000001));
    expect(assessment.seasonStartOvr, closeTo(80.25, 0.000001));
    expect(assessment.effectiveOvr, closeTo(85.125, 0.000001));
    expect(assessment.requiredMinutesShare, 0.50);
    expect(assessment.shouldHardReject, isTrue);

    final meets = ContractService().assessExtensionMinutes(
      team: teamWithMinutes(player, actualMinutes: 500, possibleMinutes: 1000),
      player: player,
    );
    expect(meets.actualMinutesShare, 0.5);
    expect(meets.shouldHardReject, isFalse);
  });

  test('minute rule is inactive below the 1000-minute minimum sample', () {
    final player = fixturePlayer('minimum-sample', currentOvr: 87);
    final assessment = ContractService().assessExtensionMinutes(
      team: teamWithMinutes(player, actualMinutes: 0, possibleMinutes: 999),
      player: player,
    );

    expect(assessment.sampleSufficient, isFalse);
    expect(assessment.ruleActive, isFalse);
    expect(assessment.meetsRequirement, isTrue);
    expect(assessment.shouldHardReject, isFalse);
  });

  test('season aggregate spans regular season and postseason matches', () {
    final player = fixturePlayer('season-span-player', currentOvr: 87);
    final awayPlayer = fixturePlayer('season-span-away', currentOvr: 65);
    final home = fixtureTeam(player);
    final away = baseLeague.teams[1].copyWith(
      roster: [awayPlayer],
      lineupPlayerIds: [awayPlayer.id],
      benchPlayerIds: const [],
      finance: baseLeague.teams[1].finance.copyWith(
        totalPayroll: awayPlayer.contract.salary,
      ),
    );
    final service = TeamEventService(balance: noRandomTeamEventsBalance());
    var league = fixtureLeague(home: home, away: away, week: 10);

    league = service.afterMatch(
      league,
      matchResult(
        home,
        away,
        playerStats: [PlayerMatchStats(playerId: player.id, minutes: 90)],
      ),
    );
    league = league.copyWith(currentWeek: 33);
    league = service.afterMatch(
      league,
      matchResult(
        home,
        away,
        playerStats: [PlayerMatchStats(playerId: player.id, minutes: 60)],
      ),
    );

    final updated = league.playerTeam!;
    final aggregate = updated.eventState.seasonMinutesFor(player.id);
    expect(aggregate, isNotNull);
    expect(aggregate!.actualMinutes, 150);
    expect(aggregate.possibleMinutes, 180);
    // The event history is still a six-week window, so the regular-season
    // row is evicted when the postseason week is recorded.
    expect(updated.eventState.minutesHistory, hasLength(1));
    expect(updated.eventState.minutesHistory.map((entry) => entry.week), [33]);
  });

  test('injury and suspension contribute zero possible minutes', () {
    final injured = fixturePlayer(
      'injured-player',
      currentOvr: 87,
      injury: const Injury(
        id: 'test-injury',
        group: InjuryGroup.headFace,
        type: InjuryType.minor,
        daysTotal: 5,
        daysRemaining: 5,
      ),
    );
    final suspended = fixturePlayer(
      'suspended-player',
      currentOvr: 87,
      suspensionGamesRemaining: 2,
    );
    final away = fixturePlayer('unavailable-away', currentOvr: 65);
    final home = baseLeague.teams.first.copyWith(
      roster: [injured, suspended],
      lineupPlayerIds: [injured.id, suspended.id],
      benchPlayerIds: const [],
    );
    final awayTeam = baseLeague.teams[1].copyWith(
      roster: [away],
      lineupPlayerIds: [away.id],
      benchPlayerIds: const [],
    );
    final league = fixtureLeague(home: home, away: awayTeam);
    final recorded = TeamEventService(balance: noRandomTeamEventsBalance())
        .recordMatchMinutes(
          league,
          matchResult(
            home,
            awayTeam,
            playerStats: [
              PlayerMatchStats(playerId: injured.id),
              PlayerMatchStats(playerId: suspended.id),
            ],
          ),
        );

    final aggregates = recorded.playerTeam!.eventState.seasonMinutes;
    expect(
      aggregates
          .firstWhere((entry) => entry.playerId == injured.id)
          .possibleMinutes,
      0,
    );
    expect(
      aggregates
          .firstWhere((entry) => entry.playerId == suspended.id)
          .possibleMinutes,
      0,
    );
  });

  test('walkovers do not add history or season minutes', () {
    final player = fixturePlayer('walkover-player', currentOvr: 87);
    final away = fixturePlayer('walkover-away', currentOvr: 65);
    final home = fixtureTeam(player);
    final awayTeam = baseLeague.teams[1].copyWith(
      roster: [away],
      lineupPlayerIds: [away.id],
      benchPlayerIds: const [],
    );
    final league = fixtureLeague(home: home, away: awayTeam);
    final result = TeamEventService(balance: noRandomTeamEventsBalance())
        .afterMatch(
          league,
          matchResult(
            home,
            awayTeam,
            playerStats: [PlayerMatchStats(playerId: player.id, minutes: 90)],
            isWalkover: true,
          ),
        );

    expect(result, league);
    expect(result.playerTeam!.eventState.minutesHistory, isEmpty);
    expect(result.playerTeam!.eventState.seasonMinutes, isEmpty);
  });

  test('season aggregate retains six-week history separately and resets', () {
    var state = const TeamEventState();
    for (var week = 1; week <= 8; week++) {
      state = state.recordMinutes(
        [
          MinutesHistoryEntry(
            playerId: 'rolling-player',
            seasonYear: 2026,
            week: week,
            minutes: week,
            possibleMinutes: 90,
          ),
        ],
        currentSeasonYear: 2026,
        currentWeek: week,
      );
    }

    expect(state.minutesHistory.map((entry) => entry.week), [3, 4, 5, 6, 7, 8]);
    expect(state.seasonMinutes.single.actualMinutes, 36);
    expect(state.seasonMinutes.single.possibleMinutes, 720);

    final restored = TeamEventState.fromJson(
      jsonDecode(jsonEncode(state.toJson())) as Map<String, dynamic>,
    );
    expect(restored, state);

    final reset = state.resetForSeason();
    expect(reset.minutesHistory, isEmpty);
    expect(reset.seasonMinutes, isEmpty);
  });

  test(
    'failed extension minutes assessment hard-rejects and blocks for 30 days',
    () {
      final player = fixturePlayer('extension-minute-reject', currentOvr: 87);
      final team = teamWithMinutes(
        player,
        actualMinutes: 0,
        possibleMinutes: 1000,
      );
      final away = baseLeague.teams[1];
      final league = fixtureLeague(
        home: team,
        away: away,
        week: 46,
        day: 2,
        hour: 1,
      );
      final result = ContractMarketService().submitPlayerOffer(
        league: league,
        playerId: player.id,
        offer: ContractOffer(salary: player.contract.salary, years: 1),
        saveSeed: 3001,
      );

      expect(result, isNotNull);
      expect(result!.reaction, ContractReaction.hardReject);
      final negotiation = result.league.negotiations.single;
      expect(negotiation.status, NegotiationStatus.hardRejected);
      expect(result.league.negotiationBlocks, hasLength(1));
      expect(result.league.negotiationBlocks.single.untilSeasonYear, 2026);
      expect(result.league.negotiationBlocks.single.untilWeek, 50);
      expect(result.league.negotiationBlocks.single.untilDay, 4);
      expect(
        NegotiationService().isBlocked(
          league: result.league,
          subjectId: player.id,
          subjectKind: NegotiationSubjectKind.player,
          teamId: team.id,
          seasonYear: 2026,
          week: 46,
          day: 2,
          hour: 1,
        ),
        isTrue,
      );

      final message = result.league.inbox.messages.single;
      expect(message.type, MessageType.contractOfferResponse);
      expect(message.kind, 'hardReject');
      expect(
        message.payload['reasonCode'],
        'extension_minutes_below_threshold',
      );
      expect(message.payload['actualMinutes'], 0);
      expect(message.payload['possibleMinutes'], 1000);
      expect(message.payload['actualMinutesShare'], 0.0);
      expect(message.payload['requiredMinutesShare'], 0.65);
      expect(message.payload['effectiveOvr'], 87.0);
    },
  );
}
