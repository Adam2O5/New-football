import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/balance/injury_catalog.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/cohesion_service.dart';
import 'package:new_football/core/services/development_service.dart';
import 'package:new_football/core/services/discipline_service.dart';
import 'package:new_football/core/services/injury_service.dart';
import 'package:new_football/core/services/match_post_match_service.dart';
import 'package:new_football/core/services/team_management_service.dart';
import 'package:new_football/core/simulation/effective_attributes.dart';
import 'package:new_football/core/simulation/match_engine.dart';
import 'package:new_football/core/simulation/match_incident_resolver.dart';

void main() {
  final league = SeedDataGenerator().generateLeague(seed: 42);
  final team = league.teams.first;
  final source = team.roster.first;
  test(
    'active chemistry and atmosphere tables reach attribute calculation and weekly drift',
    () {
      const balance = BalanceConfig(
        chemistry: ChemistryBalance(
          chemistryBands: [(100, 1.1)],
          atmosphereBands: [(100, 1.2)],
          atmosphereChemistryDrift: [(100, 5)],
          positiveEventBands: [(100, 1.4)],
          negativeEventBands: [(100, 1.6)],
        ),
        matchday: MatchdayBalance(
          effectiveAttributeMin: 0,
          effectiveAttributeMax: 10000,
        ),
      );
      const neutral = BalanceConfig(
        chemistry: ChemistryBalance(
          chemistryBands: [(100, 1)],
          atmosphereBands: [(100, 1)],
        ),
        matchday: MatchdayBalance(
          effectiveAttributeMin: 0,
          effectiveAttributeMax: 10000,
        ),
      );
      final player = team.roster.firstWhere((p) => p.position != Position.gk);
      final values = <Map<EffectiveAttribute, double>>[];
      for (final config in [neutral, balance]) {
        values.add(
          EffectiveAttributeCalculator(balance: config)
              .calculate(
                player: player,
                context: const MatchContext(),
                chemistry: 50,
                atmosphere: 50,
                cohesionMultiplier: 1,
                isHome: true,
              )
              .values,
        );
      }
      for (final attribute in values.first.keys) {
        expect(
          values.last[attribute],
          closeTo(values.first[attribute]! * 1.32, 1e-9),
        );
      }
      final update = const TeamManagementService(balance: balance).updateWeekly(
        team: team,
        seasonYear: 2026,
        week: 1,
        expectedRank: 15,
        currentRank: 15,
      );
      expect(update.chemistryDelta, 5);
      expect(TeamManagementService.positiveEventMultiplier(50, balance), 1.4);
      expect(TeamManagementService.negativeEventMultiplier(50, balance), 1.6);
      expect(TeamManagementService.chemistryMultiplier(29), 0.95);
      expect(TeamManagementService.chemistryMultiplier(30), 0.98);
      expect(TeamManagementService.chemistryMultiplier(50), 1);
      expect(TeamManagementService.chemistryMultiplier(70), 1.02);
      expect(TeamManagementService.chemistryMultiplier(85), 1.05);
    },
  );
  MatchResult result({
    List<MatchDiscipline> disciplines = const [],
    String? inspired,
  }) => MatchResult(
    homeTeamId: team.id,
    awayTeamId: league.teams[1].id,
    homeGoals: 0,
    awayGoals: 0,
    homeStats: TeamMatchStats(teamId: team.id),
    awayStats: TeamMatchStats(teamId: league.teams[1].id),
    disciplines: disciplines,
    inspiredPerformancePlayerId: inspired,
  );

  test(
    'one minutes coefficient feeds post-match cache and weekly recomputation',
    () {
      const balance = BalanceConfig(
        development: DevelopmentBalance(minutesGrowthRate: 0.02),
      );
      final player = source.copyWith(
        age: 20,
        personality: PlayerPersonality.balanced,
        state: source.state.copyWith(form: 6, minutesThisWeek: 0),
        hidden: source.hidden.copyWith(growthRate: -1, overallProgress: 0),
      );
      final service = DevelopmentService(balance: balance);
      final base = service.calculateGrowthRate(player, atmosphere: 50);
      final postMatch = applyMatchPlayerEffects(
        player: player,
        teamId: team.id,
        result: result(),
        seasonYear: 2026,
        balance: balance,
        stats: PlayerMatchStats(playerId: player.id, minutes: 30, rating: 6),
      );
      expect(postMatch.hidden.growthRate, closeTo(-0.4, 1e-9));
      final weekly = service
          .developPlayerWithContext(postMatch, atmosphere: 50)
          .player;
      expect(weekly.hidden.growthRate, closeTo(base + 0.6, 1e-9));
      expect(weekly.state.minutesThisWeek, 0);
    },
  );

  test(
    'development tables, threshold and separate reset values reach the player',
    () {
      const balance = BalanceConfig(
        development: DevelopmentBalance(
          ageBonuses: [0.25],
          staffDevelopmentBonuses: [(0, 0), (5, 0)],
          determinationGrowthRates: [1],
          constDev: 10,
          progressThreshold: 10,
          progressResetAfterGrowth: 2,
          progressResetAfterDecline: 7,
          progressAtCeiling: 8,
        ),
      );
      final service = DevelopmentService(balance: balance);
      final player = source.copyWith(
        personality: PlayerPersonality.balanced,
        state: source.state.copyWith(form: 6, minutesThisWeek: 0),
        hidden: source.hidden.copyWith(
          overallProgress: 0,
          developmentCeilingStars: 5,
        ),
      );
      final grown = service
          .developPlayerWithContext(player, atmosphere: 50)
          .player;
      expect(grown.hidden.growthRate, 1.25);
      expect(grown.hidden.overallProgress, 2);
      expect(grown.state.lastDevelopmentOvrDelta, 1);
      final ceiling = service
          .developPlayerWithContext(
            player.copyWith(
              hidden: player.hidden.copyWith(developmentCeilingStars: 0.5),
            ),
            atmosphere: 50,
          )
          .player;
      expect(ceiling.hidden.overallProgress, 8);
      const declining = BalanceConfig(
        development: DevelopmentBalance(
          ageBonuses: [-2],
          staffDevelopmentBonuses: [(0, 0), (5, 0)],
          determinationGrowthRates: [1],
          progressResetAfterDecline: 7,
        ),
      );
      expect(
        DevelopmentService(balance: declining)
            .developPlayerWithContext(player, atmosphere: 50)
            .player
            .hidden
            .overallProgress,
        7,
      );
    },
  );

  test(
    'form table, neutral point and loss multiplier are independent of initial form',
    () {
      const balance = BalanceConfig(
        player: PlayerBalance(
          noAppearanceNeutralForm: 7,
          noAppearanceFormDrift: 0.4,
          matchFormChanges: [(7, 0.5)],
          matchFormBelowThresholdDelta: -0.5,
          temperamentalFormLossMultiplier: 2,
        ),
      );
      final player = source.copyWith(
        personality: PlayerPersonality.temperamental,
        state: source.state.copyWith(form: 6),
      );
      expect(
        player
            .withMatchForm(
              minutesPlayed: 0,
              rating: 0,
              lost: false,
              balance: balance,
            )
            .state
            .form,
        6.4,
      );
      expect(
        player
            .withMatchForm(
              minutesPlayed: 30,
              rating: 7,
              lost: false,
              balance: balance,
            )
            .state
            .form,
        6.5,
      );
      expect(
        player
            .withMatchForm(
              minutesPlayed: 30,
              rating: 6,
              lost: true,
              balance: balance,
            )
            .state
            .form,
        5,
      );
      expect(const PlayerState().form, 5);
    },
  );

  test(
    'diagnosis APIs share configured cap, medical effects and RNG ordering',
    () {
      const balance = BalanceConfig(
        player: PlayerBalance(
          injuryDaysClampMax: 2,
          medicalStaffMultiplierBase: 1.2,
          medicalStaffMultiplierPerStar: 0.1,
        ),
      );
      const doctor = StaffMember(
        id: 'doctor',
        name: 'Doctor',
        nationality: Nationality.poland,
        age: 40,
        role: StaffRole.doctor,
        attributes: StaffAttributes(care: 4, prevention: 4),
      );
      const service = InjuryService(balance: balance);
      expect(service.doctorCareMult(doctor), closeTo(0.8, 1e-9));
      final direct = Random(42), callbacks = Random(42);
      for (var i = 0; i < 100; i++) {
        final a = service.diagnose(random: direct, doctor: doctor);
        final b = service.diagnoseWithCallbacks(
          nextDouble: callbacks.nextDouble,
          nextInt: callbacks.nextInt,
          doctor: doctor,
        );
        expect(a.injury, b.injury);
        expect(a.potentialLoss, b.potentialLoss);
        expect(a.injury.daysTotal, inInclusiveRange(0, 2));
      }
      final injured = source.copyWith(
        state: source.state.copyWith(
          injury: const Injury(
            id: 'acl_tear',
            group: InjuryGroup.knees,
            type: InjuryType.major,
            daysTotal: 800,
            daysRemaining: 800,
          ),
        ),
      );
      expect(injured.recoverBetweenMatches().state.injury!.daysRemaining, 365);
      expect(
        injured.recoverBetweenMatches(balance).state.injury!.daysRemaining,
        2,
      );
      expect(
        const InjuryService()
            .diagnoseWithCallbacks(
              nextDouble: () => 0,
              nextInt: (max) => max - 1,
              doctorCareMultiplier: 100,
            )
            .injury
            .daysTotal,
        365,
      );
    },
  );

  test(
    'active resolver receives injury config and potential-loss values reach match persistence',
    () {
      const balance = BalanceConfig(
        player: PlayerBalance(injuryPotentialLoss: 0.25, injuryDaysClampMax: 2),
        events: EventsBalance(majorInjuryPotentialLossChance: 1),
      );
      const resolver = MatchIncidentResolver(balance: balance);
      var weightBefore = 0.0;
      final definition = InjuryCatalog.definitions.firstWhere((d) {
        if (d.type == InjuryType.major) return true;
        weightBefore += d.weight;
        return false;
      });
      final majorRoll =
          (weightBefore + definition.weight / 2) / InjuryCatalog.totalWeight;
      var calls = 0;
      final diagnosis = resolver.injuryService.diagnoseWithCallbacks(
        nextDouble: () => calls++ == 0 ? majorRoll : 0,
        nextInt: (_) => 0,
        doctorCareMultiplier: 1,
      );
      expect(diagnosis.potentialLoss, isTrue);
      expect(diagnosis.injury.daysTotal, 2);
      final player = source.copyWith(
        potentialStars: 4,
        hidden: source.hidden.copyWith(developmentCeilingStars: 4.5),
      );
      expect(
        resolver.injuryService
            .applyPotentialLoss(player, diagnosis)
            .potentialStars,
        3.75,
      );
      final persisted = applyMatchPlayerEffects(
        player: player,
        teamId: team.id,
        result: result(),
        seasonYear: 2026,
        balance: balance,
        matchInjury: MatchInjury(
          teamId: team.id,
          playerId: player.id,
          injury: diagnosis.injury,
          playerInStartingXi: true,
          potentialLoss: true,
        ),
      );
      expect(persisted.potentialStars, 3.75);
      expect(persisted.hidden.developmentCeilingStars, 4.25);
    },
  );

  test(
    'discipline uses configured thresholds and a shared red-severity table',
    () {
      const balance = BalanceConfig(
        player: PlayerBalance(
          regularYellowThreshold: 1,
          playoffYellowThreshold: 2,
          yellowSuspensionGames: 2,
          directRedSeverityThresholds: [(1, 2)],
        ),
      );
      const service = DisciplineService(balance: balance);
      final card = MatchDiscipline(
        teamId: team.id,
        playerId: source.id,
        yellowCardsInMatch: 1,
      );
      final regular = service.applyToTeam(
        team: team,
        result: result(disciplines: [card]),
        phase: SeasonPhase.regular,
      );
      expect(regular.team.roster.first.state.suspensionGamesRemaining, 2);
      final playoff = service.applyToTeam(
        team: team,
        result: result(disciplines: [card]),
        phase: SeasonPhase.playoff,
      );
      expect(playoff.team.roster.first.state.suspensionGamesRemaining, 0);
      expect(DisciplineService.rollDirectRedSeverity(Random(42), balance), 2);
      expect(MatchIncidentResolver.directRedSeverityFromRoll(0.1, balance), 2);
      expect(MatchIncidentResolver.directRedSeverityFromRoll(0.60), 2);
      expect(MatchIncidentResolver.directRedSeverityFromRoll(0.90), 3);
    },
  );

  test('cohesion config reaches service, bootstrap and active match state', () {
    const balance = BalanceConfig(
      chemistry: ChemistryBalance(
        cohesionBase: 40,
        cohesionCorrectPosition: 1,
        cohesionForeignPosition: -2,
        cohesionOptimalRole: 3,
        cohesionMultipliers: [(100, 1.2)],
        headCoachMotivationMultipliers: [(5, 1.1)],
      ),
    );
    const service = CohesionService(balance: balance);
    final natural = source.copyWith(
      position: Position.cm,
      optimalRole: const AssignedRole.cm(),
      state: source.state.copyWith(role: const AssignedRole.cm()),
    );
    expect(service.computeCohesion([natural]), 44);
    expect(service.computeCohesion([]), 40);
    const coach = StaffMember(
      id: 'coach',
      name: 'Coach',
      nationality: Nationality.poland,
      age: 40,
      role: StaffRole.headCoach,
      attributes: StaffAttributes(motivation: 4),
    );
    expect(service.cohesionMult(50, headCoach: coach), closeTo(1.32, 1e-9));
    final live = SimulationMatchEngine(
      balance: balance,
    ).start(home: team, away: league.teams[1], rngSeed: 42);
    expect(live.runtime.homeSnapshot!.cohesionMultiplier, 1.2);
    final expected =
        40 +
        live.state.homeLineup.length +
        live.state.homeLineup
                .where((p) => p.state.role == p.optimalRole)
                .length *
            3;
    expect(live.homeCohesionScore, expected - live.homeAdaptationPenalty);
  });

  test('inspiring-performance bonuses use their event configuration', () {
    const balance = BalanceConfig(
      events: EventsBalance(
        inspiringPerformanceFormBonus: 0.5,
        inspiringPerformanceProgressBonus: 2,
      ),
    );
    final player = source.copyWith(
      state: source.state.copyWith(form: 6),
      hidden: source.hidden.copyWith(overallProgress: 10),
    );
    final updated = applyMatchPlayerEffects(
      player: player,
      teamId: team.id,
      result: result(inspired: player.id),
      seasonYear: 2026,
      balance: balance,
    );
    expect(updated.state.form, 6.5);
    expect(updated.hidden.overallProgress, 12);
  });
}
