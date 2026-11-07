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
import 'package:new_football/core/models/team_event_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/services/team_event_service.dart';

void main() {
  final league = SeedDataGenerator().generateLeague(seed: 42);
  final sourceTeam = league.teams.first;
  final source = sourceTeam.roster.firstWhere((p) => p.position != Position.gk);
  Player player(
    String id, {
    int ovr = 70,
    int age = 25,
    double potential = 4,
    PlayerPersonality personality = PlayerPersonality.balanced,
  }) => source.copyWith(
    id: id,
    age: age,
    personality: personality,
    potentialStars: potential,
    contract: source.contract.copyWith(yearsRemaining: 3),
    attributes: PlayerAttributes.outfield(
      stats: FieldPlayerAttributes(
        pace: ovr,
        shooting: ovr,
        passing: ovr,
        dribbling: ovr,
        defending: ovr,
        physicality: ovr,
      ),
    ),
    state: source.state.copyWith(injury: null, suspensionGamesRemaining: 0),
  );
  LeagueState input(
    List<Player> roster, {
    int atmosphere = 50,
    TeamEventState events = const TeamEventState(),
  }) => league.copyWith(
    teams: [
      sourceTeam.copyWith(
        roster: roster,
        atmosphere: atmosphere,
        chemistry: 50,
        ai: null,
        eventState: events,
        lineupPlayerIds: roster.map((p) => p.id).toList(),
      ),
    ],
    playerTeamId: sourceTeam.id,
    inbox: const Inbox(),
  );
  GameMessage decision(String kind, String id) => GameMessage(
    id: 'decision',
    type: MessageType.teamEvent,
    kind: kind,
    seasonYear: 2026,
    week: 1,
    titleKey: '',
    bodyKey: '',
    payload: {'teamId': sourceTeam.id, 'playerId': id},
  );

  const effects = BalanceConfig(
    events: EventsBalance(
      moreMinutesAcceptAtmosphere: -1,
      moreMinutesDeclineAtmosphere: -2,
      moreMinutesPersonalityPenalty: 4,
      moreMinutesPromiseWeeks: 2,
      moreMinutesPromiseShare: 0.6,
      transferAcceptAtmosphere: 2,
      transferPointValueMultiplier: 0.8,
      transferDeclineEffect: (-4, -3),
      conflictIgnoreEffect: (-5, -4),
      criticismPunishEffect: (-6, -5),
      criticismResponseEffect: (-3, -2),
      criticismIgnoreEffect: (-2, -1),
      conflictNegativeEventBonus: 0.4,
      dressingRoomConflictCooldownWeeks: 3,
      promiseFulfilledAtmosphere: 2,
      promiseBrokenAtmosphere: -4,
      promiseBrokenPersonalityPenalty: 1,
      transferRequestIIChanceAfterBrokenPromise: 0,
      transferSituationWeeks: 1,
      transferExpiredEffect: (-5, -2),
    ),
  );

  test(
    'more-minutes decisions use independent effects and configured promise values',
    () {
      final p = player('p', personality: PlayerPersonality.ambitious);
      final state = input([p]);
      final service = TeamEventService(balance: effects);
      final accepted = service
          .resolveDecision(
            state,
            decision('moreMinutesRequest', p.id),
            'accept',
          )
          .playerTeam!;
      expect(accepted.atmosphere, 49);
      expect(accepted.eventState.promises.single.durationWeeks, 2);
      expect(accepted.eventState.promises.single.requiredMinutesShare, 0.6);
      final declined = service
          .resolveDecision(
            state,
            decision('moreMinutesRequest', p.id),
            'decline',
          )
          .playerTeam!;
      expect(declined.atmosphere, 44);
    },
  );

  for (final (kind, option, atmosphere, chemistry) in [
    ('transferRequestI', 'decline', 46, 47.0),
    ('dressingRoomConflict', 'ignore', 45, 46.0),
    ('publicCriticism', 'punish', 44, 45.0),
    ('publicCriticism', 'response', 47, 48.0),
    ('publicCriticism', 'ignore', 48, 49.0),
  ]) {
    test(
      '$kind/$option reads the configured atmosphere and chemistry effects',
      () {
        final p = player('p');
        final updated = TeamEventService(
          balance: effects,
        ).resolveDecision(input([p]), decision(kind, p.id), option).playerTeam!;
        expect(updated.atmosphere, atmosphere);
        expect(updated.chemistry, chemistry);
        if (kind == 'dressingRoomConflict') {
          expect(
            updated.eventState.modifierValue('negativeEventMultiplier'),
            0.4,
          );
          expect(updated.eventState.cooldowns[kind], 3);
        }
      },
    );
  }

  for (final success in [true, false]) {
    test(
      'conflict intervention ${success ? 'success' : 'failure'} uses configured chance and effects',
      () {
        final balance = BalanceConfig(
          events: EventsBalance(
            conflictInterveneSuccessChance: success ? 1 : 0,
            conflictSuccessEffect: (6, 3),
            conflictFailureEffect: (-4, -3),
            conflictNegativeEventBonus: 0.3,
          ),
        );
        final p = player('p');
        final updated = TeamEventService(balance: balance)
            .resolveDecision(
              input([p]),
              decision('dressingRoomConflict', p.id),
              'intervene',
            )
            .playerTeam!;
        expect(updated.atmosphere, success ? 56 : 46);
        expect(updated.chemistry, success ? 53 : 47);
        expect(
          updated.eventState.modifierValue('negativeEventMultiplier'),
          success ? 0 : 0.3,
        );
      },
    );
  }

  for (final fulfilled in [true, false]) {
    test(
      'promise settlement ${fulfilled ? 'fulfilled' : 'broken'} uses configured consequences',
      () {
        final p = player('p', personality: PlayerPersonality.ambitious);
        final service = TeamEventService(balance: effects);
        final accepted = service.resolveDecision(
          input([p]),
          decision('moreMinutesRequest', p.id),
          'accept',
        );
        final team = accepted.playerTeam!;
        final observed = accepted
            .updateTeam(
              team.copyWith(
                eventState: team.eventState.copyWith(
                  promises: [
                    team.eventState.promises.single.copyWith(weeksElapsed: 1),
                  ],
                  minutesHistory: [
                    for (final week in [2, 3])
                      MinutesHistoryEntry(
                        playerId: p.id,
                        seasonYear: 2026,
                        week: week,
                        minutes: fulfilled ? 60 : 0,
                      ),
                  ],
                ),
              ),
            )
            .copyWith(currentWeek: 4);
        final updated = service.weeklyTick(observed, saveSeed: 42).playerTeam!;
        expect(updated.eventState.promises, isEmpty);
        expect(updated.atmosphere, fulfilled ? 51 : 44);
      },
    );
  }

  test(
    'accepted transfer uses configured value reduction and expiry consequences',
    () {
      final p = player('p');
      final service = TeamEventService(balance: effects);
      final accepted = service.resolveDecision(
        input([p]),
        decision('transferRequestI', p.id),
        'accept',
      );
      expect(
        accepted.playerTeam!.eventState.pointValueMultiplierFor(p.id),
        0.8,
      );
      expect(
        accepted
            .playerTeam!
            .eventState
            .transferSituations
            .single
            .weeksRemaining,
        1,
      );
      final expired = service
          .weeklyTick(accepted.copyWith(currentWeek: 3), saveSeed: 42)
          .playerTeam!;
      expect(expired.atmosphere, 47);
      expect(expired.chemistry, 48);
      expect(expired.eventState.transferSituations, isEmpty);
      expect(expired.eventState.pointValueMultiplierFor(p.id), 1);
    },
  );

  test(
    'minutes window is configurable across seasons and preserves seasonal aggregates',
    () {
      const balance = BalanceConfig(
        events: EventsBalance(minutesHistoryWeeks: 3),
      );
      final rows = [
        for (final week in [50, 51, 52])
          MinutesHistoryEntry(
            playerId: 'p',
            seasonYear: 2026,
            week: week,
            minutes: 20,
          ),
        const MinutesHistoryEntry(
          playerId: 'p',
          seasonYear: 2027,
          week: 1,
          minutes: 30,
        ),
      ];
      final state = const TeamEventState().recordMinutes(
        rows,
        currentSeasonYear: 2027,
        currentWeek: 1,
        balance: balance,
      );
      expect(state.minutesHistory.map((r) => r.week), [51, 52, 1]);
      expect(state.seasonMinutes.single.actualMinutes, 30);
      expect(
        TeamEventState.fromJson(
          jsonDecode(jsonEncode(state.toJson())) as Map<String, dynamic>,
        ),
        state,
      );
    },
  );

  test(
    'state multiplier bounds read injected balance and retain default API behavior',
    () {
      const balance = BalanceConfig(
        events: EventsBalance(
          negativeEventMultiplierMin: 0.8,
          negativeEventMultiplierMax: 1.1,
          pointValueMultiplierMin: 0.7,
          pointValueMultiplierMax: 0.9,
        ),
      );
      final state = const TeamEventState().addModifier(
        type: 'negativeEventMultiplier',
        value: 0.8,
        weeks: 2,
      );
      expect(state.negativeEventMultiplier, 1.8);
      expect(state.negativeEventMultiplierFor(balance), 1.1);
      expect(
        state
            .withPointValueMultiplier('p', 0.2, balance)
            .pointValueMultiplierFor('p'),
        0.7,
      );
      expect(
        state
            .withPointValueMultiplier('p', 0.95, balance)
            .pointValueMultiplierFor('p'),
        0.9,
      );
      expect(
        const TeamPromise(
          id: 'p',
          playerId: 'p',
          kind: 'minutes',
          createdSeasonYear: 2026,
          createdWeek: 1,
        ).durationWeeks,
        4,
      );
      expect(
        const MinutesHistoryEntry(
          playerId: 'p',
          seasonYear: 2026,
          week: 1,
        ).possibleMinutes,
        90,
      );
    },
  );

  test(
    'public criticism respects candidate count and exclusive age cutoff',
    () {
      final young = player('young', ovr: 90, age: 35),
          old = player('old', ovr: 70, age: 40);
      final state = input([young, old], atmosphere: 20);
      for (final count in [1, 2]) {
        final balance = BalanceConfig(
          events: EventsBalance(
            publicCriticismChance: 1,
            publicCriticismCandidates: count,
            publicCriticismAgeMinExclusive: 35,
          ),
        );
        final updated = TeamEventService(
          balance: balance,
        ).weeklyTick(state, saveSeed: 42);
        final messages = updated.inbox.messages.where(
          (m) => m.kind == 'publicCriticism',
        );
        expect(messages, hasLength(count == 1 ? 0 : 1));
        if (count == 2) expect(messages.single.payload['playerId'], old.id);
      }
    },
  );

  test('more-minutes eligibility reads its young age and configured XI', () {
    final starter = player('starter', ovr: 90, age: 30, potential: 3);
    final candidate = player('candidate', ovr: 60, age: 25, potential: 5);
    final state = input([starter, candidate]);
    final result = MatchResult(
      homeTeamId: sourceTeam.id,
      awayTeamId: 'away',
      homeGoals: 0,
      awayGoals: 0,
      homeStats: TeamMatchStats(teamId: sourceTeam.id),
      awayStats: const TeamMatchStats(teamId: 'away'),
      playerStats: [PlayerMatchStats(playerId: starter.id, minutes: 90)],
    );
    for (final maxAge in [24, 26]) {
      final balance = BalanceConfig(
        roster: const RosterBalance(startingXi: 1),
        events: EventsBalance(
          moreMinutesYoungAgeMax: maxAge,
          minutesRequestChance: 1,
          minutesRequestAmbitiousChance: 1,
          transferRequestIChance: 0,
          moreMinutesCooldownWeeks: 3,
        ),
      );
      final updated = TeamEventService(
        balance: balance,
      ).afterMatch(state, result, saveSeed: 42);
      final messages = updated.inbox.messages.where(
        (m) => m.kind == 'moreMinutesRequest',
      );
      expect(messages, hasLength(maxAge == 24 ? 0 : 1));
      if (maxAge == 26) {
        expect(messages.single.payload['playerId'], candidate.id);
        expect(
          updated.playerTeam!.eventState.cooldowns['moreMinutesRequest'],
          3,
        );
      }
    }
  });

  test(
    'post-playoff requests use configured status threshold and candidate pool',
    () {
      final loyal = player(
        'loyal',
        ovr: 90,
        personality: PlayerPersonality.loyal,
      );
      final candidate = player('candidate', ovr: 70);
      final state = input([loyal, candidate]).copyWith(
        strengthTable: LeagueStrengthTable(
          entries: [
            TeamStrengthEntry(
              teamId: sourceTeam.id,
              teamPower: 80,
              expectedRank: 30,
              teamStatus: TeamStatus.rebuild,
            ),
          ],
          lastCalculatedWeek: 44,
        ),
      );
      for (final count in [1, 2]) {
        final balance = BalanceConfig(
          events: EventsBalance(
            postPlayoffCandidates: count,
            postPlayoffExpectedRounds: const {TeamStatus.rebuild: 1},
            transferPointValueMultiplier: 0.75,
          ),
        );
        final updated = TeamEventService(
          balance: balance,
        ).afterPlayoffs(state, saveSeed: 42);
        final messages = updated.inbox.messages.where(
          (m) => m.kind == 'transferRequestII',
        );
        expect(messages, hasLength(count == 1 ? 0 : 1));
        if (count == 2) {
          expect(messages.single.payload['playerId'], candidate.id);
          expect(
            updated.playerTeam!.eventState.pointValueMultiplierFor(
              candidate.id,
            ),
            0.75,
          );
        }
      }
    },
  );

  test(
    'AI more-minutes choice reads configured priority pool rather than a fixed top fourteen',
    () {
      final starter = player('starter', ovr: 90, age: 30, potential: 3);
      final candidate = player('candidate', ovr: 60, age: 25, potential: 5);
      final state = input([
        starter,
        candidate,
      ]).copyWith(playerTeamId: 'another-club');
      final result = MatchResult(
        homeTeamId: sourceTeam.id,
        awayTeamId: 'away',
        homeGoals: 0,
        awayGoals: 0,
        homeStats: TeamMatchStats(teamId: sourceTeam.id),
        awayStats: const TeamMatchStats(teamId: 'away'),
        playerStats: [PlayerMatchStats(playerId: starter.id, minutes: 90)],
      );
      for (final count in [1, 2]) {
        final balance = BalanceConfig(
          events: EventsBalance(
            aiMoreMinutesPriorityPlayers: count,
            aiMoreMinutesTopFourteenAcceptChance: 1,
            aiMoreMinutesDepthAcceptChance: 0,
            minutesRequestChance: 1,
            transferRequestIChance: 0,
          ),
        );
        final updated = TeamEventService(
          balance: balance,
        ).afterMatch(state, result, saveSeed: 42);
        expect(
          updated.teams.single.eventState.promises,
          hasLength(count == 1 ? 0 : 1),
        );
      }
    },
  );

  test('transfer eligibility reads configured league value share', () {
    final loyal = player(
      'loyal',
      personality: PlayerPersonality.loyal,
    ).copyWith(pointValue: 100);
    final valuable = player('valuable').copyWith(pointValue: 90);
    final depth = player('depth').copyWith(pointValue: 10);
    final state = input([loyal, valuable, depth]);
    final result = MatchResult(
      homeTeamId: sourceTeam.id,
      awayTeamId: 'away',
      homeGoals: 0,
      awayGoals: 0,
      homeStats: TeamMatchStats(teamId: sourceTeam.id),
      awayStats: const TeamMatchStats(teamId: 'away'),
    );
    for (final share in [0.2, 0.7]) {
      final balance = BalanceConfig(
        events: EventsBalance(
          transferValueTopShare: share,
          transferRequestIChance: 1,
          minutesRequestChance: 0,
          minutesRequestAmbitiousChance: 0,
        ),
      );
      final updated = TeamEventService(
        balance: balance,
      ).afterMatch(state, result, saveSeed: 42);
      final messages = updated.inbox.messages.where(
        (m) => m.kind == 'transferRequestI',
      );
      expect(messages, hasLength(share == 0.2 ? 0 : 1));
      if (share == 0.7) {
        expect(messages.single.payload['playerId'], valuable.id);
      }
    }
  });
}
