import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/ai/ai_matchday_service.dart';
import 'package:new_football/core/ai/ai_trade_service.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_event_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/team_event_state.dart';
import 'package:new_football/core/services/player_event_service.dart';
import 'package:new_football/core/services/team_event_service.dart';

void main() {
  final seeded = SeedDataGenerator(
    random: null,
  ).generateLeague(year: 2026, playerTeamId: 'team_europe_0', seed: 3721);
  final aiSource = seeded.teams.firstWhere(
    (team) => team.id == 'team_europe_1',
  );

  Player playerFrom(
    Player source,
    String id, {
    int age = 24,
    PlayerPersonality personality = PlayerPersonality.balanced,
    double potentialStars = 4.0,
    int seasonsWithTeam = 0,
    int determination = 7,
    int lastDevelopmentOvrDelta = 1,
    double form = 6.0,
    PlayerEventState eventState = const PlayerEventState(),
    Injury? injury,
    int yearsRemaining = 3,
    int pointValue = 200,
  }) {
    return source.copyWith(
      id: id,
      name: id,
      age: age,
      personality: personality,
      potentialStars: potentialStars,
      pointValue: pointValue,
      contract: source.contract.copyWith(
        salary: 1000000,
        yearsRemaining: yearsRemaining,
        isRookieScale: false,
        noTradeClause: false,
        blockedTeamIds: const [],
      ),
      hidden: source.hidden.copyWith(determination: determination),
      state: source.state.copyWith(
        form: form,
        injury: injury,
        seasonsWithTeam: seasonsWithTeam,
        lastDevelopmentOvrDelta: lastDevelopmentOvrDelta,
        eventState: eventState,
        suspensionGamesRemaining: 0,
      ),
    );
  }

  Team teamWith(
    List<Player> roster, {
    List<String>? lineupPlayerIds,
    TeamEventState eventState = const TeamEventState(),
    int atmosphere = 50,
    double chemistry = 50,
    List<int> recentMatchResults = const [],
  }) {
    final lineup =
        lineupPlayerIds ?? roster.take(11).map((player) => player.id).toList();
    return aiSource
        .copyWith(
          roster: roster,
          lineupPlayerIds: lineup,
          benchPlayerIds: roster
              .where((player) => !lineup.contains(player.id))
              .take(7)
              .map((player) => player.id)
              .toList(),
          eventState: eventState,
          atmosphere: atmosphere,
          chemistry: chemistry,
          recentMatchResults: recentMatchResults,
        )
        .updatePayroll();
  }

  List<ConferenceStandings> bottomHalfStandings(String teamId) => [
    for (final conference in seeded.currentSeason.standings)
      conference.copyWith(
        standings: [
          for (final standing in conference.standings)
            standing.teamId == teamId
                ? standing.copyWith(wins: 0, losses: 10)
                : standing.copyWith(wins: 10, losses: 0),
        ],
      ),
  ];

  LeagueState playerEventStateFor(Team team, {List<Team>? additionalTeams}) {
    final replacements = <String, Team>{team.id: team};
    if (additionalTeams != null) {
      for (final replacement in additionalTeams) {
        replacements[replacement.id] = replacement;
      }
    }
    return seeded.copyWith(
      teams: seeded.teams
          .map((candidate) => replacements[candidate.id] ?? candidate)
          .toList(),
      playerTeamId: 'team_europe_0',
      currentWeek: 1,
      currentDay: 1,
      currentSeason: seeded.currentSeason.copyWith(
        phase: SeasonPhase.regular,
        standings: bottomHalfStandings(team.id),
      ),
      inbox: const Inbox(),
    );
  }

  EventsBalance playerBalance({
    double breakthroughChance = 0,
    double coldStreakChance = 0,
    double injuryComplicationChance = 0,
    double veteranMotivationChance = 0,
    double extraTrainingChance = 0,
    double personalProblemsChance = 0,
    double personalSupportChance = 0,
    double aiPlateauAcceptChance = 1,
    double aiColdStreakAcceptChance = 1,
    double aiInjuryComplicationCautiousChance = 1,
    double aiVeteranMentorChance = 1,
    double aiExtraTrainingAcceptChance = 1,
    double aiPersonalSupportAcceptChance = 1,
  }) => EventsBalance(
    breakthroughChance: breakthroughChance,
    coldStreakChance: coldStreakChance,
    majorInjuryComplicationChance: injuryComplicationChance,
    veteranMotivationChance: veteranMotivationChance,
    extraTrainingChance: extraTrainingChance,
    personalProblemsChance: personalProblemsChance,
    professionalPersonalProblemsChance: 0,
    personalSupportChance: personalSupportChance,
    lateBloomerChance: 0,
    recurringInjuryChance: 0,
    aiPlateauAcceptChance: aiPlateauAcceptChance,
    aiColdStreakAcceptChance: aiColdStreakAcceptChance,
    aiInjuryComplicationCautiousChance: aiInjuryComplicationCautiousChance,
    aiVeteranMentorChance: aiVeteranMentorChance,
    aiExtraTrainingAcceptChance: aiExtraTrainingAcceptChance,
    aiPersonalSupportAcceptChance: aiPersonalSupportAcceptChance,
  );

  test('AI resolves all six player decision events synchronously', () {
    final source = aiSource.roster.firstWhere(
      (player) => player.position != Position.gk,
    );
    final plateauEvents = PlayerEventService(
      balance: BalanceConfig(events: playerBalance()),
    );
    final coldEvents = PlayerEventService(
      balance: BalanceConfig(events: playerBalance(coldStreakChance: 1)),
    );
    final injuryEvents = PlayerEventService(
      balance: BalanceConfig(
        events: playerBalance(injuryComplicationChance: 1),
      ),
    );
    final veteranEvents = PlayerEventService(
      balance: BalanceConfig(events: playerBalance(veteranMotivationChance: 1)),
    );
    final trainingEvents = PlayerEventService(
      balance: BalanceConfig(events: playerBalance(extraTrainingChance: 1)),
    );
    final supportEvents = PlayerEventService(
      balance: BalanceConfig(events: playerBalance(personalSupportChance: 1)),
    );

    final plateau = plateauEvents.weeklyTick(
      playerEventStateFor(
        teamWith([
          playerFrom(
            source,
            'ai-plateau',
            lastDevelopmentOvrDelta: 0,
            eventState: const PlayerEventState(counters: {'plateauWeeks': 7}),
          ),
        ]),
      ),
      saveSeed: 3722,
    );
    expect(
      plateau
          .teamById(aiSource.id)!
          .roster
          .single
          .state
          .eventState
          .modifierValue('growthRate'),
      0.15,
    );

    final cold = coldEvents.weeklyTick(
      playerEventStateFor(
        teamWith([
          playerFrom(
            source,
            'ai-cold',
            form: 3,
            eventState: const PlayerEventState(counters: {'lowFormWeeks': 2}),
          ),
        ]),
      ),
      saveSeed: 3723,
    );
    expect(
      cold
          .teamById(aiSource.id)!
          .roster
          .single
          .state
          .eventState
          .hasModifier('startingElevenRequired'),
      isTrue,
    );

    final previousMajor = Injury(
      id: 'ai-recovery-major',
      group: InjuryGroup.knees,
      type: InjuryType.major,
      daysTotal: 70,
      daysRemaining: 0,
    );
    final injury = injuryEvents.weeklyTick(
      playerEventStateFor(
        teamWith([
          playerFrom(
            source,
            'ai-injury-complication',
            eventState: PlayerEventState(
              lastMajorInjury: previousMajor,
              majorInjuryActiveLastTick: true,
            ),
          ),
        ]),
      ),
      saveSeed: 3724,
    );
    final injuryPlayer = injury.teamById(aiSource.id)!.roster.single;
    expect(injuryPlayer.state.injury?.type, InjuryType.major);
    expect(
      injuryPlayer.state.eventState.isOnCooldown('injuryComplication'),
      isTrue,
    );

    final veteran = veteranEvents.weeklyTick(
      playerEventStateFor(
        teamWith(
          [
            playerFrom(
              source,
              'ai-veteran',
              age: 34,
              seasonsWithTeam: 4,
              determination: 8,
            ),
            playerFrom(source, 'ai-mentee', age: 22),
          ],
          lineupPlayerIds: const ['ai-veteran', 'ai-mentee'],
        ),
      ),
      saveSeed: 3725,
    );
    expect(
      veteran
          .teamById(aiSource.id)!
          .roster
          .firstWhere((player) => player.id == 'ai-mentee')
          .state
          .eventState
          .modifierValue('growthRate'),
      0.1,
    );

    final training = trainingEvents.weeklyTick(
      playerEventStateFor(
        teamWith([
          playerFrom(source, 'ai-extra-training', determination: 8, form: 7),
        ]),
      ),
      saveSeed: 3726,
    );
    final trainingPlayer = training.teamById(aiSource.id)!.roster.single;
    expect(trainingPlayer.state.eventState.modifierValue('growthRate'), 0.2);
    expect(
      trainingPlayer.state.eventState.modifierValue('weeklyStaminaPenalty'),
      -5,
    );

    final personalSupportState = const PlayerEventState(
      modifiers: [
        TimedModifier(type: 'personalProblems', value: 1, weeksRemaining: 3),
        TimedModifier(
          type: 'personalProblemsGrowth',
          value: -0.15,
          weeksRemaining: 3,
        ),
      ],
      personalProblemsFollowUpPending: true,
    );
    final support = supportEvents.weeklyTick(
      playerEventStateFor(
        teamWith([
          playerFrom(
            source,
            'ai-personal-support',
            eventState: personalSupportState,
          ),
        ]),
      ),
      saveSeed: 3727,
    );
    final supportPlayer = support.teamById(aiSource.id)!.roster.single;
    expect(
      supportPlayer.state.eventState
          .modifierOf('personalProblems')
          ?.weeksRemaining,
      1,
    );
    expect(
      supportPlayer.state.eventState.personalProblemsFollowUpPending,
      isFalse,
    );
    expect(support.inbox.messages, isEmpty);
  });

  EventsBalance teamBalance({
    double minutesChance = 0,
    double transferChance = 0,
    double conflictChance = 0,
    double leaderChance = 0,
    double criticismChance = 0,
  }) => EventsBalance(
    minutesRequestChance: minutesChance,
    minutesRequestAmbitiousChance: minutesChance,
    transferRequestIChance: transferChance,
    lockerRoomConflictChance: conflictChance,
    leaderSupportChance: leaderChance,
    publicCriticismChance: criticismChance,
    transferRequestIIChanceAfterBrokenPromise: 0,
    aiMoreMinutesTopFourteenAcceptChance: 1,
    aiMoreMinutesDepthAcceptChance: 1,
    aiTransferRequestAcceptChance: 1,
    aiTransferRequestOtherAcceptChance: 1,
    aiTransferRequestIIAcceptChance: 1,
    aiDressingRoomInterveneChance: 1,
    aiPublicCriticismPunishChance: 1,
    aiPublicCriticismResponseCutoff: 1,
  );

  LeagueState teamEventStateFor(
    Team team, {
    int week = 1,
    int day = 1,
    LeagueStrengthTable? strengthTable,
  }) {
    return seeded.copyWith(
      teams: seeded.teams
          .map((candidate) => candidate.id == team.id ? team : candidate)
          .toList(),
      playerTeamId: 'team_europe_0',
      currentWeek: week,
      currentDay: day,
      currentSeason: seeded.currentSeason.copyWith(
        phase: SeasonPhase.regular,
        standings: bottomHalfStandings(team.id),
      ),
      strengthTable: strengthTable,
      inbox: const Inbox(),
    );
  }

  MatchResult matchFor(
    Team home,
    Team away, {
    Map<String, int> minutes = const {},
  }) => MatchResult(
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
          minutes: minutes[player.id] ?? 90,
        ),
    ],
  );

  LeagueStrengthTable strengthFor(String teamId) => LeagueStrengthTable(
    entries: [
      TeamStrengthEntry(
        teamId: teamId,
        teamPower: 70,
        expectedRank: 5,
        teamStatus: TeamStatus.contender,
      ),
    ],
    lastCalculatedWeek: 44,
    seasonYear: 2026,
  );

  test(
    'AI promise acceptance adds the score bonus and expires after four ticks',
    () {
      final source = aiSource.roster.firstWhere(
        (player) => player.position != Position.gk,
      );
      final candidate = playerFrom(
        source,
        'ai-promise-player',
        age: 22,
        potentialStars: 5,
      );
      final starter = playerFrom(source, 'ai-promise-starter', age: 29);
      final team = teamWith(
        [candidate, starter],
        lineupPlayerIds: [starter.id],
      );
      final state = teamEventStateFor(team);
      final service = TeamEventService(
        balance: BalanceConfig(events: teamBalance(minutesChance: 1)),
      );

      var accepted = service.afterMatch(
        state,
        matchFor(
          team,
          seeded.teams[2],
          minutes: {candidate.id: 0, starter.id: 90},
        ),
        saveSeed: 3728,
      );
      final promisedTeam = accepted.teamById(team.id)!;
      final promised = promisedTeam.roster.firstWhere(
        (player) => player.id == candidate.id,
      );
      expect(promisedTeam.eventState.promises.single.playerId, candidate.id);
      expect(
        promised.state.eventState.modifierValue('promiseMatchScoreBonus'),
        0.08,
      );

      final baseScore = AiMatchdayService().playerMatchScore(
        promised.copyWith(
          state: promised.state.copyWith(
            eventState: promised.state.eventState.clearModifier(
              'promiseMatchScoreBonus',
            ),
          ),
        ),
        promised.position,
      );
      final promisedScore = AiMatchdayService().playerMatchScore(
        promised,
        promised.position,
      );
      expect(promisedScore / baseScore, closeTo(1.08, 1e-9));

      final playerEvents = PlayerEventService(
        balance: BalanceConfig(events: playerBalance()),
      );
      for (var index = 0; index < 4; index++) {
        accepted = accepted.copyWith(currentWeek: accepted.currentWeek + 1);
        accepted = playerEvents.weeklyTick(accepted, saveSeed: 3728);
      }
      final expiredPlayer = accepted
          .teamById(team.id)!
          .roster
          .firstWhere((player) => player.id == candidate.id);
      expect(
        expiredPlayer.state.eventState.hasModifier('promiseMatchScoreBonus'),
        isFalse,
      );
    },
  );

  test(
    'AI transfer acceptance stores ×3 appetite, −8 surplus and cleans it up',
    () {
      final source = aiSource.roster.firstWhere(
        (player) => player.position != Position.gk,
      );
      final player = playerFrom(source, 'ai-transfer-player', pointValue: 500);
      final team = teamWith(
        [player],
        atmosphere: 20,
        eventState: const TeamEventState(lowAtmosphereWeeks: 4),
      );
      final service = TeamEventService(
        balance: BalanceConfig(events: teamBalance(transferChance: 1)),
      );

      var state = service.afterMatch(
        teamEventStateFor(team),
        matchFor(team, seeded.teams[2]),
        saveSeed: 3729,
      );
      final acceptedTeam = state.teamById(team.id)!;
      expect(
        acceptedTeam.eventState.modifierValue('tradeAppetite:${player.id}'),
        2.0,
      );
      expect(
        acceptedTeam.eventState.modifierValue('tradeSurplusPct:${player.id}'),
        -8.0,
      );
      final appetite = AiTradeService().tradeAppetiteForPlayer(
        league: state,
        team: acceptedTeam,
        playerId: player.id,
      );
      expect(appetite, greaterThanOrEqualTo(0.0));
      expect(appetite, lessThanOrEqualTo(1.0));

      for (var index = 1; index <= 5; index++) {
        state = state.copyWith(currentWeek: index + 1);
        state = service.weeklyTick(state, saveSeed: 3729);
      }
      final cleaned = state.teamById(team.id)!;
      expect(cleaned.eventState.transferSituations, isEmpty);
      expect(
        cleaned.eventState.hasModifier('tradeAppetite:${player.id}'),
        isFalse,
      );
      expect(
        cleaned.eventState.hasModifier('tradeSurplusPct:${player.id}'),
        isFalse,
      );
      expect(cleaned.eventState.pointValueMultiplierFor(player.id), 1.0);
    },
  );

  test(
    'AI resolves transfer II and degrades an expired contract to declineToExtend',
    () {
      final source = aiSource.roster.firstWhere(
        (player) => player.position != Position.gk,
      );
      final player = playerFrom(source, 'ai-transfer-ii', yearsRemaining: 3);
      final table = strengthFor(aiSource.id);
      final service = TeamEventService(
        balance: BalanceConfig(events: teamBalance()),
      );

      final accepted = service.afterPlayoffs(
        teamEventStateFor(teamWith([player]), strengthTable: table),
        saveSeed: 3730,
      );
      final acceptedTeam = accepted.teamById(aiSource.id)!;
      expect(
        acceptedTeam.eventState.transferSituationFor(player.id),
        isNotNull,
      );
      expect(
        acceptedTeam.eventState.modifierValue('tradeAppetite:${player.id}'),
        2.0,
      );

      final ufa = playerFrom(source, 'ai-decline-to-extend', yearsRemaining: 1);
      final declined = service.afterPlayoffs(
        teamEventStateFor(teamWith([ufa]), strengthTable: table),
        saveSeed: 3731,
      );
      final declinedTeam = declined.teamById(aiSource.id)!;
      expect(
        declinedTeam.eventState.hasSeasonFlag(
          'declineToExtend:${ufa.id}',
          2026,
        ),
        isTrue,
      );
      expect(declinedTeam.eventState.transferSituations, isEmpty);
      expect(declined.inbox.messages, isEmpty);
    },
  );

  test(
    'AI resolves conflict, public criticism and automatic leader support',
    () {
      final temperamentalA = playerFrom(
        aiSource.roster.first,
        'ai-conflict-a',
        personality: PlayerPersonality.temperamental,
      );
      final temperamentalB = playerFrom(
        aiSource.roster[1],
        'ai-conflict-b',
        personality: PlayerPersonality.temperamental,
      );
      final conflictTeam = teamWith(
        [temperamentalA, temperamentalB],
        lineupPlayerIds: [temperamentalA.id, temperamentalB.id],
        atmosphere: 30,
      );
      final conflictService = TeamEventService(
        balance: BalanceConfig(events: teamBalance(conflictChance: 1)),
      );
      final conflict = conflictService.weeklyTick(
        teamEventStateFor(conflictTeam),
        saveSeed: 3732,
      );
      final resolvedConflict = conflict.teamById(conflictTeam.id)!;
      expect(
        resolvedConflict.eventState.isOnCooldown('dressingRoomConflict'),
        isTrue,
      );

      final critic = playerFrom(aiSource.roster[2], 'ai-critic', age: 28);
      final criticismTeam = teamWith([critic], atmosphere: 20);
      final criticismService = TeamEventService(
        balance: BalanceConfig(events: teamBalance(criticismChance: 1)),
      );
      final criticism = criticismService.weeklyTick(
        teamEventStateFor(criticismTeam),
        saveSeed: 3733,
      );
      final resolvedCriticism = criticism.teamById(criticismTeam.id)!;
      expect(resolvedCriticism.atmosphere, 18);
      expect(resolvedCriticism.eventState.publicCriticismRollMultiplier, 0.5);

      final leader = playerFrom(
        aiSource.roster[3],
        'ai-leader',
        personality: PlayerPersonality.leader,
      );
      final leaderTeam = teamWith(
        [leader],
        recentMatchResults: const [1, 1, 1],
        atmosphere: 50,
        chemistry: 50,
      );
      final leaderService = TeamEventService(
        balance: BalanceConfig(events: teamBalance(leaderChance: 1)),
      );
      final supported = leaderService.weeklyTick(
        teamEventStateFor(leaderTeam),
        saveSeed: 3734,
      );
      final supportedTeam = supported.teamById(leaderTeam.id)!;
      expect(supportedTeam.atmosphere, 54);
      expect(supportedTeam.chemistry, 51);
      expect(supported.inbox.messages, isEmpty);
    },
  );

  test(
    'AI settles a broken promise without creating a human inbox decision',
    () {
      final player = playerFrom(aiSource.roster.first, 'ai-broken-promise');
      final promise = TeamPromise(
        id: 'task37-broken-promise',
        playerId: player.id,
        kind: 'moreMinutesRequest',
        createdSeasonYear: 2026,
        createdWeek: 1,
        weeksElapsed: 3,
        durationWeeks: 4,
        requiredMinutesShare: 0.4,
      );
      final history = [
        for (var week = 2; week <= 5; week++)
          MinutesHistoryEntry(
            playerId: player.id,
            seasonYear: 2026,
            week: week,
            minutes: 0,
            possibleMinutes: 90,
          ),
      ];
      final team = teamWith(
        [player],
        atmosphere: 50,
        eventState: TeamEventState(
          promises: [promise],
          minutesHistory: history,
        ),
      );
      final state = teamEventStateFor(team, week: 5);
      final service = TeamEventService(
        balance: BalanceConfig(events: teamBalance()),
      );

      final resolved = service.weeklyTick(state, saveSeed: 3735);
      final resolvedTeam = resolved.teamById(team.id)!;

      expect(resolvedTeam.eventState.promises, isEmpty);
      expect(resolvedTeam.atmosphere, 38);
      expect(resolved.inbox.messages, isEmpty);
    },
  );
}
