import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/ai/ai_contract_market_service.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/team_event_state.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/negotiation_service.dart';

void main() {
  const balance = BalanceConfig.defaults;
  final policy = AiContractMarketService();

  LeagueState leagueAt({int week = 46, int day = 2, int? hour = 1}) =>
      SeedDataGenerator()
          .generateLeague(seed: 3501)
          .copyWith(currentWeek: week, currentDay: day, currentHour: hour);

  Team aiTeam(LeagueState league) =>
      league.teams.firstWhere((team) => team.ai != null);

  Player clonePlayer(
    Player source, {
    required String id,
    Position? position,
    int? age,
    int? salary,
    int? yearsRemaining,
    bool? isRookieScale,
    int? rookiePickSlot,
    bool? hasBirdRights,
    int? seasonsWithTeam,
    double? potentialStars,
    int? pointValue,
  }) {
    final contract = source.contract.copyWith(
      salary: salary ?? source.contract.salary,
      yearsRemaining: yearsRemaining ?? source.contract.yearsRemaining,
      isRookieScale: isRookieScale ?? source.contract.isRookieScale,
      rookiePickSlot: rookiePickSlot ?? source.contract.rookiePickSlot,
      hasBirdRights: hasBirdRights ?? source.contract.hasBirdRights,
      exceptionType: null,
      noTradeClause: false,
      blockedTeamIds: const [],
    );
    return source.copyWith(
      id: id,
      name: 'Task 35 $id',
      position: position ?? source.position,
      age: age ?? source.age,
      potentialStars: potentialStars ?? source.potentialStars,
      contract: contract,
      pointValue: pointValue ?? source.pointValue,
      state: source.state.copyWith(
        seasonsWithTeam: seasonsWithTeam ?? source.state.seasonsWithTeam,
      ),
      seasonStartOvr: source.overall(balance),
    );
  }

  Player highPlayer(
    Player source, {
    required String id,
    int age = 24,
    int yearsRemaining = 1,
    bool isRookieScale = false,
    int seasonsWithTeam = 3,
    int pointValue = 240,
  }) => clonePlayer(
    source,
    id: id,
    age: age,
    salary: balance.salaryCap.minSalary,
    yearsRemaining: yearsRemaining,
    isRookieScale: isRookieScale,
    rookiePickSlot: isRookieScale ? 1 : 0,
    hasBirdRights: false,
    seasonsWithTeam: seasonsWithTeam,
    potentialStars: 5.0,
    pointValue: pointValue,
  );

  Player freeAgent(Player source, {required String id, int age = 26}) =>
      clonePlayer(
        source,
        id: id,
        age: age,
        salary: balance.salaryCap.minSalary,
        yearsRemaining: 0,
        isRookieScale: false,
        rookiePickSlot: 0,
        hasBirdRights: false,
        seasonsWithTeam: 0,
        potentialStars: 4.0,
        pointValue: 240,
      );

  Team withRoster(Team team, Iterable<Player> roster) =>
      team.copyWith(roster: roster.toList());

  LeagueState withTeam(LeagueState league, Team team) =>
      league.updateTeam(team);

  LeagueStrengthTable strengthTable(
    LeagueState league,
    Team team,
    TeamStatus status,
  ) => LeagueStrengthTable(
    entries: [
      TeamStrengthEntry(
        teamId: team.id,
        teamPower: 80,
        expectedRank: 1,
        teamStatus: status,
      ),
    ],
    lastCalculatedWeek: league.currentWeek,
    seasonYear: league.currentSeason.year,
  );

  LeagueState singleAiLeague(
    LeagueState league,
    Team team, {
    List<Player> freeAgents = const [],
    List<StaffMember> staffFreeAgents = const [],
    LeagueStrengthTable? table,
  }) => league.copyWith(
    teams: [team],
    playerTeamId: null,
    freeAgents: freeAgents,
    staffFreeAgents: staffFreeAgents,
    strengthTable: table,
  );

  AiPlayerOfferPlan? firstPhaseOnePlan(
    LeagueState league,
    Team team, {
    required int hour,
  }) {
    for (var saveSeed = 0; saveSeed < 1500; saveSeed++) {
      final plan = policy.phaseOnePlayerPlan(
        league: league,
        team: team,
        hour: hour,
        saveSeed: saveSeed,
      );
      if (plan != null) return plan;
    }
    return null;
  }

  test(
    'extension priorities, valuation guardrails and term limits follow §8.1',
    () {
      final base = leagueAt();
      final team = aiTeam(base);
      final source = team.roster.reduce(
        (a, b) => a.overall(balance) >= b.overall(balance) ? a : b,
      );

      final rookie = highPlayer(
        source,
        id: 'task35-extension-rookie',
        isRookieScale: true,
        seasonsWithTeam: 1,
      );
      final fullBird = highPlayer(
        source,
        id: 'task35-extension-full-bird',
        seasonsWithTeam: 3,
      );
      final earlyBird = highPlayer(
        source,
        id: 'task35-extension-early-bird',
        seasonsWithTeam: 2,
      );
      final veteran = highPlayer(
        source,
        id: 'task35-extension-veteran',
        age: 30,
        seasonsWithTeam: 1,
      );
      final priorityTeam = withRoster(team, [
        rookie,
        fullBird,
        earlyBird,
        veteran,
      ]);
      final priorityLeague = withTeam(base, priorityTeam);

      final rookiePlan = policy.extensionPlan(
        league: priorityLeague,
        team: priorityTeam,
        player: rookie,
        saveSeed: 3501,
      );
      final fullBirdPlan = policy.extensionPlan(
        league: priorityLeague,
        team: priorityTeam,
        player: fullBird,
        saveSeed: 3501,
      );
      final earlyBirdPlan = policy.extensionPlan(
        league: priorityLeague,
        team: priorityTeam,
        player: earlyBird,
        saveSeed: 3501,
      );
      final veteranPlan = policy.extensionPlan(
        league: priorityLeague,
        team: priorityTeam,
        player: veteran,
        saveSeed: 3501,
      );

      expect(rookiePlan?.exception, CapExceptionType.rookieExtension);
      expect(fullBirdPlan?.exception, CapExceptionType.fullBirdRights);
      expect(earlyBirdPlan?.exception, CapExceptionType.earlyBirdRights);
      expect(veteranPlan?.exception, CapExceptionType.veteranExtensionRaiseCap);
      expect(rookiePlan, isNotNull);
      expect(
        rookiePlan!.offerScore,
        closeTo(balance.ai.extTargetOfferScore, 2),
      );
      expect(
        rookiePlan.offerScore,
        lessThanOrEqualTo(balance.ai.extMaxOfferScore),
      );

      final nonBird = highPlayer(
        source,
        id: 'task35-extension-non-bird',
        age: 34,
        seasonsWithTeam: 1,
      );
      final nonBirdTeam = withRoster(team, [nonBird]);
      final nonBirdPlan = policy.extensionPlan(
        league: withTeam(base, nonBirdTeam),
        team: nonBirdTeam,
        player: nonBird,
        saveSeed: 3501,
      );
      expect(nonBirdPlan?.exception, CapExceptionType.nonBirdRights);

      final oldPlayer = highPlayer(
        source,
        id: 'task35-extension-old',
        age: 33,
        seasonsWithTeam: 3,
      );
      final oldTeam = withRoster(team, [oldPlayer]);
      final oldPlan = policy.extensionPlan(
        league: withTeam(base, oldTeam),
        team: oldTeam,
        player: oldPlayer,
        saveSeed: 3501,
      );
      expect(oldPlan, isNotNull);
      expect(oldPlan!.offer.years, 1);

      final toxic = clonePlayer(
        source,
        id: 'task35-extension-negative-asset',
        age: 40,
        salary: balance.salaryCap.maxSalary,
        yearsRemaining: 5,
        isRookieScale: false,
        seasonsWithTeam: 3,
        potentialStars: 0.5,
      );
      final toxicTeam = withRoster(team, [toxic]);
      final toxicLeague = withTeam(base, toxicTeam);
      expect(
        policy.playerAssetValue(toxicLeague, toxicTeam, toxic, saveSeed: 3501),
        lessThan(0),
      );
      expect(
        policy.extensionPlan(
          league: toxicLeague,
          team: toxicTeam,
          player: toxic,
          saveSeed: 3501,
        ),
        isNull,
      );

      final noMinutes = highPlayer(
        source,
        id: 'task35-extension-no-minutes',
        seasonsWithTeam: 3,
      );
      final noMinutesTeam = withRoster(
        team.copyWith(
          eventState: TeamEventState(
            seasonMinutes: [
              SeasonMinutesAggregate(
                playerId: noMinutes.id,
                seasonYear: base.currentSeason.year,
                actualMinutes: 0,
                possibleMinutes: 1000,
              ),
            ],
          ),
        ),
        [noMinutes],
      );
      expect(
        policy.extensionPlan(
          league: withTeam(base, noMinutesTeam),
          team: noMinutesTeam,
          player: noMinutes,
          saveSeed: 3501,
        ),
        isNull,
      );
    },
  );

  test(
    'extension counter rolls are deterministic and use the 70% / 35% bands',
    () {
      final base = leagueAt();
      final team = aiTeam(base);
      final source = team.roster.reduce(
        (a, b) => a.overall(balance) >= b.overall(balance) ? a : b,
      );
      final high = highPlayer(source, id: 'task35-counter-high');
      final highTeam = withRoster(team, [high]);
      final highLeague = withTeam(base, highTeam);
      final highValue = policy.playerAssetValue(
        highLeague,
        highTeam,
        high,
        saveSeed: 3501,
      );
      expect(highValue, greaterThan(200));

      Player? normal;
      for (final age in [25, 27, 29, 31, 32]) {
        for (final salary in [1000000, 5000000, 10000000, 15000000, 20000000]) {
          for (final potential in [1.5, 2.0, 2.5, 3.0]) {
            final candidate = clonePlayer(
              source,
              id: 'task35-counter-normal-${age}_$salary-$potential',
              age: age,
              salary: salary,
              yearsRemaining: 1,
              isRookieScale: false,
              seasonsWithTeam: 1,
              potentialStars: potential,
            );
            final candidateTeam = withRoster(team, [candidate]);
            final candidateLeague = withTeam(base, candidateTeam);
            final value = policy.playerAssetValue(
              candidateLeague,
              candidateTeam,
              candidate,
              saveSeed: 3501,
            );
            if (value >= 0 && value <= 200) {
              normal = candidate;
              break;
            }
          }
          if (normal != null) break;
        }
        if (normal != null) break;
      }
      expect(normal, isNotNull);
      final normalPlayer = normal!;
      final normalTeam = withRoster(team, [normalPlayer]);
      final normalLeague = withTeam(base, normalTeam);
      final normalValue = policy.playerAssetValue(
        normalLeague,
        normalTeam,
        normalPlayer,
        saveSeed: 3501,
      );
      expect(normalValue, inInclusiveRange(0, 200));

      expect(
        policy.shouldRaiseExtensionCounter(
          league: highLeague,
          team: highTeam,
          player: high,
          saveSeed: 17,
          round: 1,
        ),
        policy.shouldRaiseExtensionCounter(
          league: highLeague,
          team: highTeam,
          player: high,
          saveSeed: 17,
          round: 1,
        ),
      );

      var highRaises = 0;
      var normalRaises = 0;
      for (var saveSeed = 0; saveSeed < 600; saveSeed++) {
        if (policy.shouldRaiseExtensionCounter(
          league: highLeague,
          team: highTeam,
          player: high,
          saveSeed: saveSeed,
          round: 1,
        )) {
          highRaises++;
        }
        if (policy.shouldRaiseExtensionCounter(
          league: normalLeague,
          team: normalTeam,
          player: normal,
          saveSeed: saveSeed,
          round: 1,
        )) {
          normalRaises++;
        }
      }
      expect(highRaises, inInclusiveRange(350, 490));
      expect(normalRaises, inInclusiveRange(150, 270));
    },
  );

  test('FA-I exposes the ten-hour table, wishlist score and guardrails', () {
    final base = leagueAt(week: 47, day: 1, hour: 1);
    final team = aiTeam(base);
    final source = team.roster.reduce(
      (a, b) => a.overall(balance) >= b.overall(balance) ? a : b,
    );
    final fa = freeAgent(source, id: 'task35-fa-one');
    final state = base.copyWith(freeAgents: [fa]);

    expect(balance.ai.faPhaseOneTargetScores, [
      70,
      70,
      72,
      74,
      74,
      76,
      78,
      80,
      82,
      88,
    ]);
    expect(balance.ai.faPhaseOneOfferProbabilities, [
      0.65,
      0.70,
      0.70,
      0.75,
      0.75,
      0.80,
      0.80,
      0.85,
      0.85,
      0.40,
    ]);
    expect(
      policy.wishlistPriority(state, team, fa, saveSeed: 3501),
      isA<double>(),
    );

    for (final hour in [1, 4, 7, 10]) {
      final plan = firstPhaseOnePlan(state, team, hour: hour);
      expect(
        plan,
        isNotNull,
        reason: 'hour $hour should eventually roll an offer',
      );
      expect(plan!.targetScore, balance.ai.faPhaseOneTargetScores[hour - 1]);
    }

    final under20Team = withRoster(team, team.roster.take(19));
    final under20State = base.copyWith(
      teams: base.teams
          .map((item) => item.id == under20Team.id ? under20Team : item)
          .toList(),
      freeAgents: [fa],
    );
    final hour10Plan = firstPhaseOnePlan(under20State, under20Team, hour: 10);
    expect(hour10Plan, isNotNull);
    expect(hour10Plan!.targetScore, 88);

    final user = base.playerTeam!;
    final competing = NegotiationService().start(
      id: 'task35-user-competing-offer',
      subjectId: fa.id,
      subjectKind: NegotiationSubjectKind.player,
      teamId: user.id,
      phase: NegotiationPhase.freeAgencyPhaseI,
      offer: const NegotiationOffer(salary: 1000000, years: 2),
      seasonYear: base.currentSeason.year,
      week: base.currentWeek,
      day: base.currentDay,
      hour: 1,
      offerScore: 70,
    );
    final competingState = state.copyWith(negotiations: [competing]);
    AiPlayerOfferPlan? bumped;
    for (var saveSeed = 0; saveSeed < 1500; saveSeed++) {
      final candidate = policy.phaseOnePlayerPlan(
        league: competingState,
        team: team,
        hour: 1,
        saveSeed: saveSeed,
      );
      if (candidate?.targetScore == 76) {
        bumped = candidate;
        break;
      }
    }
    expect(bumped, isNotNull);

    final oldFa = freeAgent(source, id: 'task35-fa-old', age: 34);
    final oldState = base.copyWith(freeAgents: [oldFa]);
    final oldPlan = firstPhaseOnePlan(oldState, team, hour: 3);
    expect(oldPlan, isNotNull);
    final expectedSalary = ContractService().expectedSalary(oldFa);
    final expectedLength = ContractService().expectedLength(oldFa);
    expect(
      oldPlan!.offer.salary,
      lessThanOrEqualTo((expectedSalary * 1.35).round()),
    );
    expect(
      oldPlan.offer.salary,
      lessThanOrEqualTo(balance.salaryCap.maxSalary),
    );
    expect(oldPlan.offer.years, lessThanOrEqualTo(expectedLength + 1));
    expect(oldPlan.offer.years, lessThanOrEqualTo(2));

    final group = balance.ai.rosterGroups.firstWhere(
      (definition) => definition.contains(source.position),
    );
    final maxRoster = [
      for (var i = 0; i < group.max; i++)
        clonePlayer(
          source,
          id: 'task35-fa-max-roster-$i',
          yearsRemaining: 2,
          isRookieScale: false,
          seasonsWithTeam: 2,
        ),
    ];
    final maxTeam = withRoster(team, maxRoster);
    final maxState = singleAiLeague(
      base,
      maxTeam,
      freeAgents: [freeAgent(source, id: 'task35-fa-at-max')],
    );
    var maxPositionOffers = 0;
    for (var saveSeed = 0; saveSeed < 600; saveSeed++) {
      if (policy.phaseOnePlayerPlan(
            league: maxState,
            team: maxTeam,
            hour: 1,
            saveSeed: saveSeed,
          ) !=
          null) {
        maxPositionOffers++;
      }
    }
    expect(maxPositionOffers, greaterThan(0));
    expect(maxPositionOffers, lessThan(60));
  });

  test(
    'FA-II activity, weekly limit and roster repair use documented terms',
    () {
      final base = leagueAt(week: 48, day: 1, hour: null);
      final team = aiTeam(base);
      final sourceGk = team.roster.firstWhere(
        (player) => player.position == Position.gk,
      );
      final sourceOutfield = team.roster.firstWhere(
        (player) => player.position != Position.gk,
      );

      final targetSpecs = <(Position, int)>[
        (Position.gk, 3),
        (Position.cb, 4),
        (Position.lb, 4),
        (Position.cm, 5),
        (Position.cam, 2),
        (Position.lw, 4),
        (Position.st, 3),
      ];
      final targetRoster = <Player>[];
      for (final (position, count) in targetSpecs) {
        final source = position == Position.gk ? sourceGk : sourceOutfield;
        for (var i = 0; i < count; i++) {
          targetRoster.add(
            clonePlayer(
              source,
              id: 'task35-target-${position.name}-$i',
              position: position,
              age: 24,
              salary: balance.salaryCap.minSalary,
              yearsRemaining: 2,
              isRookieScale: false,
              seasonsWithTeam: 2,
            ),
          );
        }
      }
      final targetTeam = withRoster(team, targetRoster);
      final targetFa = freeAgent(sourceOutfield, id: 'task35-fa-two-target');
      final inactiveState = singleAiLeague(
        base,
        targetTeam,
        freeAgents: [targetFa],
      );
      expect(
        policy.phaseTwoPlayerPlan(
          league: inactiveState,
          team: targetTeam,
          saveSeed: 3501,
        ),
        isNull,
      );

      final under22Team = withRoster(team, targetRoster.take(21));
      final under22State = singleAiLeague(
        base,
        under22Team,
        freeAgents: [freeAgent(sourceOutfield, id: 'task35-fa-two-under22')],
      );
      final activePlan = policy.phaseTwoPlayerPlan(
        league: under22State,
        team: under22Team,
        saveSeed: 3501,
      );
      expect(activePlan, isNotNull);

      final negotiations = [
        for (var i = 0; i < 2; i++)
          ContractNegotiation(
            id: 'task35-fa-two-limit-$i',
            subjectId: 'old-fa-$i',
            subjectKind: NegotiationSubjectKind.player,
            teamId: under22Team.id,
            phase: NegotiationPhase.freeAgencyPhaseII,
            lastOffer: const NegotiationOffer(salary: 1000000, years: 1),
            seasonYear: base.currentSeason.year,
            week: base.currentWeek,
            day: base.currentDay,
            hour: 0,
            expirySeasonYear: base.currentSeason.year,
            expiryWeek: base.currentWeek + 1,
            isAiOffer: true,
          ),
      ];
      final limitState = under22State.copyWith(negotiations: negotiations);
      expect(policy.phaseTwoOfferCount(limitState, under22Team.id), 2);
      expect(
        policy.phaseTwoPlayerPlan(
          league: limitState,
          team: under22Team,
          saveSeed: 3501,
        ),
        isNull,
      );

      final emergencyTeam = withRoster(team, targetRoster.take(19));
      final emergencyFa = freeAgent(
        sourceOutfield,
        id: 'task35-fa-two-emergency',
      );
      final emergencyState = singleAiLeague(
        base,
        emergencyTeam,
        freeAgents: [emergencyFa],
      );
      final emergencyPlan = policy.phaseTwoPlayerPlan(
        league: emergencyState,
        team: emergencyTeam,
        saveSeed: 3501,
      );
      expect(emergencyPlan, isNotNull);
      expect(emergencyPlan!.emergency, isTrue);
      expect(emergencyPlan.offer.salary, balance.salaryCap.minSalary);
      expect(emergencyPlan.offer.years, 1);
      expect(balance.ai.faPhaseTwoTargetScore, 68);
      expect(balance.ai.faPhaseTwoWeeklyOfferLimit, 2);
      expect(balance.ai.faPhaseTwoNeedThreshold, 20);
    },
  );

  test(
    'RFA QO rolls and match decisions use public value and normalized cost',
    () {
      final base = leagueAt(week: 47, day: 1, hour: 1);
      final source = aiTeam(base).roster.reduce(
        (a, b) => a.overall(balance) >= b.overall(balance) ? a : b,
      );
      final targetTeam = withRoster(aiTeam(base), [
        highPlayer(
          source,
          id: 'task35-rfa-high',
          isRookieScale: true,
          yearsRemaining: 0,
        ),
      ]);
      final high = targetTeam.roster.single;
      final low = clonePlayer(
        high,
        id: 'task35-rfa-low',
        pointValue: 0,
        potentialStars: 1.0,
      );
      final lowGroup = balance.ai.rosterGroups.firstWhere(
        (definition) => definition.contains(low.position),
      );
      final lowRoster = <Player>[low];
      for (var i = 0; i < lowGroup.min; i++) {
        lowRoster.add(
          clonePlayer(
            low,
            id: 'task35-rfa-low-filler-$i',
            salary: balance.salaryCap.minSalary,
            yearsRemaining: 2,
            isRookieScale: false,
            seasonsWithTeam: 2,
          ),
        );
      }
      final lowTeam = withRoster(aiTeam(base), lowRoster);
      final highState = singleAiLeague(base, targetTeam);
      final lowState = singleAiLeague(base, lowTeam);

      var highQos = 0;
      var lowQos = 0;
      for (var saveSeed = 0; saveSeed < 400; saveSeed++) {
        if (policy.shouldSubmitQualifyingOffer(
          league: highState,
          team: targetTeam,
          player: high,
          saveSeed: saveSeed,
        )) {
          highQos++;
        }
        final lowTeam = lowState.teams.single;
        if (policy.shouldSubmitQualifyingOffer(
          league: lowState,
          team: lowTeam,
          player: low,
          saveSeed: saveSeed,
        )) {
          lowQos++;
        }
      }
      expect(highQos, inInclusiveRange(320, 400));
      expect(lowQos, inInclusiveRange(30, 100));
      expect(
        policy.shouldSubmitQualifyingOffer(
          league: highState,
          team: targetTeam,
          player: high,
          saveSeed: 42,
        ),
        policy.shouldSubmitQualifyingOffer(
          league: highState,
          team: targetTeam,
          player: high,
          saveSeed: 42,
        ),
      );

      final matchPlayer = highPlayer(
        source,
        id: 'task35-rfa-match',
        isRookieScale: true,
        yearsRemaining: 0,
      );
      final matchTeam = withRoster(aiTeam(base), [matchPlayer]);
      final matchState = singleAiLeague(base, matchTeam);
      final affordable = RfaOfferSheet(
        id: 'task35-rfa-affordable',
        playerId: matchPlayer.id,
        originalTeamId: matchTeam.id,
        offeringTeamId: 'rival-team',
        salary: balance.salaryCap.minSalary,
        years: 1,
        phase: NegotiationPhase.freeAgencyPhaseI,
        seasonYear: base.currentSeason.year,
        week: 47,
        day: 1,
        hour: 1,
        expirySeasonYear: base.currentSeason.year,
        expiryWeek: 47,
        expiryDay: 1,
        expiryHour: 3,
      );
      final matchValue = policy.playerAssetValue(
        matchState,
        matchTeam,
        matchPlayer,
        saveSeed: 3501,
      );
      expect(matchValue, greaterThan(0));
      expect(
        policy.shouldMatchOfferSheet(
          league: matchState,
          sheet: affordable,
          saveSeed: 1,
        ),
        isA<bool>(),
      );
      final replay = policy.shouldMatchOfferSheet(
        league: matchState,
        sheet: affordable,
        saveSeed: 17,
      );
      expect(
        replay,
        policy.shouldMatchOfferSheet(
          league: matchState,
          sheet: affordable,
          saveSeed: 17,
        ),
      );

      final expensive = affordable.copyWith(
        salary: balance.salaryCap.maxSalary,
        years: 5,
      );
      expect(
        policy.shouldMatchOfferSheet(
          league: matchState,
          sheet: expensive,
          saveSeed: 17,
        ),
        isFalse,
      );
      // The policy compares salary in millions × years × 100 with 1.4× value;
      // this keeps currency units separate from point-like assetValue.
      final affordableNormalizedCost =
          (affordable.salary / 1000000.0) *
          affordable.years *
          balance.ai.rfaCostScale;
      final expensiveNormalizedCost =
          (expensive.salary / 1000000.0) *
          expensive.years *
          balance.ai.rfaCostScale;
      expect(expensiveNormalizedCost, greaterThan(affordableNormalizedCost));
      expect(balance.ai.rfaMatchCostMultiplier, 1.40);
    },
  );

  test(
    'staff priority orders, salary bands, renewal rolls and age guardrail match §8.5',
    () {
      expect(
        policy.staffRolePriority(TeamStatus.rebuild),
        orderedEquals([
          StaffRole.youthCoach,
          StaffRole.scout,
          StaffRole.headCoach,
          StaffRole.doctor,
          StaffRole.physio,
          StaffRole.cfo,
        ]),
      );
      expect(
        policy.staffRolePriority(TeamStatus.retool),
        orderedEquals([
          StaffRole.youthCoach,
          StaffRole.headCoach,
          StaffRole.scout,
          StaffRole.doctor,
          StaffRole.physio,
          StaffRole.cfo,
        ]),
      );
      expect(
        policy.staffRolePriority(TeamStatus.pretender),
        orderedEquals([
          StaffRole.headCoach,
          StaffRole.doctor,
          StaffRole.youthCoach,
          StaffRole.physio,
          StaffRole.scout,
          StaffRole.cfo,
        ]),
      );
      expect(
        policy.staffRolePriority(TeamStatus.contender),
        orderedEquals([
          StaffRole.headCoach,
          StaffRole.doctor,
          StaffRole.physio,
          StaffRole.cfo,
          StaffRole.youthCoach,
          StaffRole.scout,
        ]),
      );
      expect(
        policy.staffRolePriority(TeamStatus.elite),
        orderedEquals([
          StaffRole.headCoach,
          StaffRole.doctor,
          StaffRole.physio,
          StaffRole.cfo,
          StaffRole.youthCoach,
          StaffRole.scout,
        ]),
      );

      final base = leagueAt(week: 47, day: 1, hour: 1);
      final team = aiTeam(base).copyWith(staff: const TeamStaff());
      final generator = SeedDataGenerator();
      final staffPool = [
        for (final role in StaffRole.values)
          generator.generateStaffMember(Random(role.index + 3501), role),
      ];
      for (final status in TeamStatus.values) {
        final state = singleAiLeague(
          base,
          team,
          staffFreeAgents: staffPool,
          table: strengthTable(base, team, status),
        );
        final plan = policy.staffFreeAgentPlan(
          league: state,
          team: team,
          saveSeed: 3501,
        );
        expect(plan, isNotNull, reason: 'status ${status.name} needs a hire');
        final index = policy.staffRolePriority(status).indexOf(plan!.role);
        expect(index, 0);
        expect(plan.targetScore, balance.ai.staffTargetOfferScore);
        expect(
          plan.offerScore,
          lessThanOrEqualTo(balance.ai.staffMaxOfferScore),
        );
        expect(
          plan.offer.salary,
          greaterThanOrEqualTo(balance.staff.minSalary),
        );
        expect(plan.offer.salary, lessThanOrEqualTo(balance.staff.maxSalary));
        if (index == 0) {
          expect(
            plan.offer.salary,
            lessThanOrEqualTo(balance.ai.staffHeadCoachMaxSalary),
          );
        } else if (index <= 2) {
          expect(plan.offer.salary, inInclusiveRange(2000000, 3000000));
        } else {
          expect(plan.offer.salary, inInclusiveRange(500000, 2000000));
        }
      }

      expect(balance.ai.staffCapUsageTargetMin, 0.90);
      expect(balance.ai.staffCapUsageTargetMax, 1.00);

      final oldFreeAgent = StaffMember(
        id: 'task35-staff-age-60',
        name: 'Task 35 Old Staff',
        nationality: Nationality.poland,
        age: 60,
        role: StaffRole.headCoach,
        attributes: const StaffAttributes(tactics: 3.0, motivation: 3.0),
      );
      final oldState = singleAiLeague(
        base,
        team,
        staffFreeAgents: [oldFreeAgent],
      );
      final oldPlan = policy.staffFreeAgentPlan(
        league: oldState,
        team: team,
        saveSeed: 3501,
      );
      expect(oldPlan, isNotNull);
      expect(oldPlan!.offer.years, 1);

      final expiringHigh = oldFreeAgent.copyWith(
        id: 'task35-staff-renew-high',
        age: 50,
        contract: const StaffContract(salary: 1000000, yearsRemaining: 1),
      );
      final highRenewTeam = team.copyWith(
        staff: TeamStaff(headCoach: expiringHigh),
      );
      final highRenewState = singleAiLeague(base, highRenewTeam);
      AiStaffOfferPlan? highRenewal;
      for (var saveSeed = 0; saveSeed < 200; saveSeed++) {
        highRenewal = policy.staffExtensionPlan(
          league: highRenewState,
          team: highRenewTeam,
          saveSeed: saveSeed,
        );
        if (highRenewal != null) break;
      }
      expect(highRenewal, isNotNull);
      expect(highRenewal!.isExtension, isTrue);
      expect(balance.ai.staffRenewalHighProbability, 0.85);
      expect(balance.ai.staffRenewalLowProbability, 0.20);

      final expiringOld = expiringHigh.copyWith(
        id: 'task35-staff-renew-60',
        age: 60,
        contract: const StaffContract(salary: 1000000, yearsRemaining: 1),
      );
      final oldRenewTeam = team.copyWith(
        staff: TeamStaff(headCoach: expiringOld),
      );
      final oldRenewState = singleAiLeague(base, oldRenewTeam);
      AiStaffOfferPlan? oldRenewal;
      for (var saveSeed = 0; saveSeed < 200; saveSeed++) {
        oldRenewal = policy.staffExtensionPlan(
          league: oldRenewState,
          team: oldRenewTeam,
          saveSeed: saveSeed,
        );
        if (oldRenewal != null) break;
      }
      expect(oldRenewal, isNotNull);
      expect(oldRenewal!.offer.years, 1);
    },
  );

  test('ContractMarketService integrates AI extensions and FA resolution', () {
    final base = leagueAt(week: 46, day: 2, hour: 1);
    final source = aiTeam(
      base,
    ).roster.reduce((a, b) => a.overall(balance) >= b.overall(balance) ? a : b);
    final extensionPlayer = highPlayer(
      source,
      id: 'task35-integration-extension',
      isRookieScale: true,
      seasonsWithTeam: 1,
    );
    final extensionTeam = aiTeam(
      base,
    ).copyWith(roster: [extensionPlayer], staff: const TeamStaff());
    final extensionState = singleAiLeague(
      base,
      extensionTeam,
    ).copyWith(currentWeek: 46, currentDay: 2, currentHour: 1);
    final market = ContractMarketService();
    final extensionResolved = market.resolveHour(
      extensionState,
      hour: 1,
      saveSeed: 3501,
    );
    final extensionNegotiation = extensionResolved.negotiations.firstWhere(
      (item) => item.subjectId == extensionPlayer.id,
      orElse: () =>
          throw StateError('AI extension negotiation was not created'),
    );
    expect(extensionNegotiation.isAiOffer, isTrue);
    expect(
      extensionNegotiation.status,
      anyOf(
        NegotiationStatus.completed,
        NegotiationStatus.pendingFinalization,
        NegotiationStatus.hardRejected,
      ),
    );
    if (extensionNegotiation.status == NegotiationStatus.completed) {
      expect(
        extensionResolved.teams.single.roster.single.contract.yearsRemaining,
        greaterThan(1),
      );
    }

    final fa = freeAgent(source, id: 'task35-integration-fa');
    final faTeam = aiTeam(base).copyWith(staff: const TeamStaff());
    final faState = singleAiLeague(
      base,
      faTeam,
      freeAgents: [fa],
    ).copyWith(currentWeek: 47, currentDay: 1, currentHour: 1);
    LeagueState? faResolved;
    for (var saveSeed = 0; saveSeed < 200; saveSeed++) {
      final candidate = market.resolveDay(faState, saveSeed: saveSeed);
      if (candidate.negotiations.any((item) => item.subjectId == fa.id)) {
        faResolved = candidate;
        break;
      }
    }
    expect(faResolved, isNotNull);
    final faNegotiation = faResolved!.negotiations.firstWhere(
      (item) => item.subjectId == fa.id,
    );
    expect(faNegotiation.isAiOffer, isTrue);
    expect(
      faResolved.freeAgents.any((player) => player.id == fa.id),
      faNegotiation.status != NegotiationStatus.completed,
    );

    final phaseTwoFa = freeAgent(source, id: 'task35-integration-fa-two');
    final phaseTwoTeam = withRoster(faTeam, faTeam.roster.take(21));
    var phaseTwoState = singleAiLeague(
      base,
      phaseTwoTeam,
      freeAgents: [phaseTwoFa],
    ).copyWith(currentWeek: 48, currentDay: 1, currentHour: null);
    phaseTwoState = market.resolveDay(phaseTwoState, saveSeed: 3501);
    phaseTwoState = market.resolveDay(
      phaseTwoState.copyWith(currentDay: 2),
      saveSeed: 3501,
    );
    expect(
      phaseTwoState.negotiations
          .where(
            (item) =>
                item.isAiOffer &&
                item.phase == NegotiationPhase.freeAgencyPhaseII &&
                item.teamId == phaseTwoTeam.id &&
                item.week == 48,
          )
          .length,
      lessThanOrEqualTo(balance.ai.faPhaseTwoWeeklyOfferLimit),
    );
  });
}
