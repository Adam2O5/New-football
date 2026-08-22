import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/utils/staff_presentation.dart';
import 'package:new_football/core/ai/ai_draft_service.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/development_snapshot.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/scouting.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/cohesion_service.dart';
import 'package:new_football/core/services/development_service.dart';
import 'package:new_football/core/services/injury_service.dart';
import 'package:new_football/core/services/scouting_service.dart';
import 'package:new_football/core/services/season_service.dart';
import 'package:new_football/core/services/staff_service.dart';
import 'package:new_football/core/simulation/team_shape.dart';

import '../helpers/staff_role_ratings_test_helpers.dart';

/// Preservation tests for concrete StaffAttributes consumers.
///
/// These assertions intentionally call the gameplay/domain services instead of
/// checking only RawOverall. They protect the distinction between an
/// attribute's concrete effect and its role rating, including the presentation
/// layer's half-star projection.
void main() {
  group('StaffAttributes concrete-effect preservation', () {
    test(
      'head coach Tactics and Motivation remain separate concrete effects',
      () {
        final lowTactics = staffMemberFor(
          StaffRole.headCoach,
          relevantValues: const [1.0, 3.0],
          irrelevantValue: 5.0,
          id: 'preserve-head-low-tactics',
        );
        final highTactics = lowTactics.copyWith(
          attributes: lowTactics.attributes.copyWith(tactics: 5.0),
        );
        final legacyOnly = lowTactics.copyWith(
          attributes: lowTactics.attributes.copyWith(development: 0.0),
        );

        expect(
          TeamShapeCalculator.headCoachTacticsBoost(highTactics),
          greaterThan(TeamShapeCalculator.headCoachTacticsBoost(lowTactics)),
          reason: 'TeamShape must still consume head-coach Tactics',
        );
        expect(
          TeamShapeCalculator.headCoachTacticsBoost(legacyOnly),
          TeamShapeCalculator.headCoachTacticsBoost(lowTactics),
          reason: 'legacy headCoach Development must not affect TeamShape',
        );

        final lowMotivation = staffMemberFor(
          StaffRole.headCoach,
          relevantValues: const [3.0, 0.5],
          irrelevantValue: 5.0,
          id: 'preserve-head-low-motivation',
        );
        final highMotivation = lowMotivation.copyWith(
          attributes: lowMotivation.attributes.copyWith(motivation: 4.5),
        );
        final tacticsOnlyMutation = lowMotivation.copyWith(
          attributes: lowMotivation.attributes.copyWith(tactics: 5.0),
        );
        const cohesion = CohesionService();

        expect(
          cohesion.cohesionMult(81, headCoach: highMotivation),
          greaterThan(cohesion.cohesionMult(81, headCoach: lowMotivation)),
          reason: 'Cohesion must still consume head-coach Motivation',
        );
        expect(
          cohesion.cohesionMult(81, headCoach: tacticsOnlyMutation),
          cohesion.cohesionMult(81, headCoach: lowMotivation),
          reason: 'Cohesion must not consume head-coach Tactics as Motivation',
        );
      },
    );

    test(
      'youth coach Development and Mentoring drive growth, not legacy headCoach Development',
      () {
        final source = SeedDataGenerator(
          random: null,
        ).generateLeague(year: 2026, seed: 10201).teams.first;
        final sourcePlayer = source.roster.first;
        final player = sourcePlayer.copyWith(
          age: 20,
          hidden: sourcePlayer.hidden.copyWith(determination: 10),
          state: sourcePlayer.state.copyWith(
            form: 6.0,
            minutesThisWeek: 30,
            injury: null,
          ),
        );
        final headCoach = staffMemberFor(
          StaffRole.headCoach,
          attributes: const StaffAttributes(
            tactics: 3.0,
            motivation: 3.0,
            development: 0.0,
          ),
          id: 'preserve-growth-head',
        );
        final legacyHeadCoach = headCoach.copyWith(
          attributes: headCoach.attributes.copyWith(development: 5.0),
        );
        final youthLow = staffMemberFor(
          StaffRole.youthCoach,
          relevantValues: const [2.0, 0.0],
          irrelevantValue: 5.0,
          id: 'preserve-growth-youth-low',
        );
        final youthHighDevelopment = youthLow.copyWith(
          attributes: youthLow.attributes.copyWith(development: 5.0),
        );
        final youthHighMentoring = youthLow.copyWith(
          attributes: youthLow.attributes.copyWith(mentoring: 5.0),
        );
        final irrelevantYouthMutation = youthLow.copyWith(
          attributes: youthLow.attributes.copyWith(tactics: 0.0),
        );

        Team withStaff(StaffMember head, StaffMember youth) => source.copyWith(
          roster: [player],
          staff: source.staff.copyWith(headCoach: head, youthCoach: youth),
        );

        final service = DevelopmentService();
        final low = service
            .developTeamWithReport(withStaff(headCoach, youthLow))
            .changes
            .single
            .growthRate;
        final highDevelopment = service
            .developTeamWithReport(withStaff(headCoach, youthHighDevelopment))
            .changes
            .single
            .growthRate;
        final highMentoring = service
            .developTeamWithReport(withStaff(headCoach, youthHighMentoring))
            .changes
            .single
            .growthRate;
        final legacy = service
            .developTeamWithReport(withStaff(legacyHeadCoach, youthLow))
            .changes
            .single
            .growthRate;
        final irrelevant = service
            .developTeamWithReport(
              withStaff(headCoach, irrelevantYouthMutation),
            )
            .changes
            .single
            .growthRate;

        expect(
          highDevelopment,
          greaterThan(low),
          reason: 'Development coach Development must raise player growth',
        );
        expect(
          highMentoring,
          greaterThan(low),
          reason: 'young-player growth must still use Mentoring',
        );
        expect(
          legacy,
          low,
          reason: 'legacy headCoach Development must be inert for growth',
        );
        expect(
          irrelevant,
          low,
          reason: 'youth coach irrelevant fields must not affect growth',
        );
      },
    );

    test(
      'staff development snapshot keeps canonical current values and deltas',
      () {
        const previousHead = StaffAttributes(
          tactics: 3.0,
          motivation: 2.5,
          development: 0.0,
        );
        const currentHead = StaffAttributes(
          tactics: 3.0,
          motivation: 2.5,
          development: 5.0,
        );
        final headSnapshot = StaffDevelopmentSnapshot.forSlot(
          StaffRole.headCoach,
          staffMemberFor(
            StaffRole.headCoach,
            attributes: currentHead,
            previousAttributes: previousHead,
          ),
        );

        expect(headSnapshot.attributeNames, const ['tactics', 'motivation']);
        expect(headSnapshot.currentValues, const [3.0, 2.5]);
        expect(headSnapshot.deltas, const [0.0, 0.0]);

        const previousScout = StaffAttributes(coverage: 2.5, evaluation: 3.0);
        const currentScout = StaffAttributes(coverage: 4.0, evaluation: 3.0);
        final scoutSnapshot = StaffDevelopmentSnapshot.forSlot(
          StaffRole.scout,
          staffMemberFor(
            StaffRole.scout,
            attributes: currentScout,
            previousAttributes: previousScout,
          ),
        );
        expect(scoutSnapshot.attributeNames, const ['coverage', 'evaluation']);
        expect(scoutSnapshot.currentValues, const [4.0, 3.0]);
        expect(scoutSnapshot.deltas, const [1.5, 0.0]);

        final empty = StaffDevelopmentSnapshot.forSlot(StaffRole.physio, null);
        expect(empty.isEmptySlot, isTrue);
        expect(empty.currentValues, const [0.0, 0.0]);
        expect(empty.deltas, everyElement(isNull));
      },
    );

    test('seasonal staff growth changes only fields canonical for each role', () {
      for (final role in StaffRole.values) {
        final attributes = role == StaffRole.headCoach
            ? uniformStaffAttributes(2.0).copyWith(development: 5.0)
            : uniformStaffAttributes(2.0);
        final member = staffMemberFor(
          role,
          attributes: attributes,
          age: 35,
          id: 'preserve-growth-${role.name}',
        );
        final team = staffFixtureTeam(
          id: 'preserve-growth-team-${role.name}',
          staff: teamStaffOf({role: member}),
        );

        var observedGrowth = false;
        for (var seed = 0; seed < 500 && !observedGrowth; seed++) {
          final state = staffFixtureLeague(
            teams: [team],
            playerTeamId: team.id,
          );
          final result = StaffService(
            random: Random(seed),
          ).growthAndRetireTick(state);
          final updated = result
              .teamById(team.id)!
              .staff
              .canonicalMember(role)!;
          final changed = staffAttributeNames
              .where(
                (name) =>
                    staffAttributeByName(updated.attributes, name) !=
                    staffAttributeByName(member.attributes, name),
              )
              .toList(growable: false);
          if (changed.isEmpty) continue;

          observedGrowth = true;
          expect(
            changed,
            everyElement(isIn(relevantStaffAttributeNames(role))),
            reason: '${role.name} growth changed an attribute outside its role',
          );
          if (role == StaffRole.headCoach) {
            expect(
              updated.attributes.development,
              member.attributes.development,
              reason:
                  'headCoach seasonal growth must leave legacy Development inert',
            );
          }
        }

        expect(
          observedGrowth,
          isTrue,
          reason: 'seeded age-35 growth never occurred for ${role.name}',
        );
      }
    });

    test(
      'scouting Coverage controls capacity while Evaluation controls tier progress',
      () {
        final ids = List<String>.generate(40, (index) => 'prospect-$index');
        final service = ScoutingService();
        final lowCoverage = service.setWatchlist(
          const TeamScouting(),
          ids,
          coverageStars: 0.0,
        );
        final highCoverage = service.setWatchlist(
          const TeamScouting(),
          ids,
          coverageStars: 5.0,
        );
        expect(lowCoverage.watchlistProspectIds.length, 4);
        expect(highCoverage.watchlistProspectIds.length, 34);

        final base = const TeamScouting(
          watchlistProspectIds: ['p1'],
          knowledge: [ScoutingKnowledge(prospectId: 'p1')],
        );
        final seed = _seedBetweenScoutingChances();
        final lowEvaluation = ScoutingService(
          random: Random(seed),
        ).tickKnowledge(base, 0.0);
        final highEvaluation = ScoutingService(
          random: Random(seed),
        ).tickKnowledge(base, 5.0);

        expect(
          lowEvaluation.forProspect('p1')!.tier,
          ScoutingTier.tier1,
          reason: 'low Evaluation should not use the high-Evaluation chance',
        );
        expect(
          highEvaluation.forProspect('p1')!.tier,
          ScoutingTier.tier2,
          reason: 'Evaluation must still drive scouting tier progress',
        );
      },
    );

    test(
      'AI draft watchlist remains Coverage-driven and ignores Evaluation',
      () {
        final generator = SeedDataGenerator(random: null);
        final league = generator.generateLeague(seed: 10204);
        final aiTeam = league.teams.firstWhere((team) => team.ai != null);
        final draftClass = generator.generateDraftClass(
          year: league.currentSeason.year + 1,
          prospectCount: 40,
        );

        Team withScout(double coverage, double evaluation) => aiTeam.copyWith(
          staff: aiTeam.staff.copyWith(
            scout: staffMemberFor(
              StaffRole.scout,
              relevantValues: [coverage, evaluation],
              id: 'preserve-ai-draft-scout',
            ),
          ),
        );
        final policy = AiDraftService();
        final lowCoverage = policy.assignWatchlist(
          team: withScout(0.0, 0.0),
          draftClass: draftClass,
          league: league,
          saveSeed: 10204,
          seasonYear: league.currentSeason.year,
        );
        final highCoverage = policy.assignWatchlist(
          team: withScout(5.0, 0.0),
          draftClass: draftClass,
          league: league,
          saveSeed: 10204,
          seasonYear: league.currentSeason.year,
        );
        final highCoverageHighEvaluation = policy.assignWatchlist(
          team: withScout(5.0, 5.0),
          draftClass: draftClass,
          league: league,
          saveSeed: 10204,
          seasonYear: league.currentSeason.year,
        );

        expect(
          highCoverage.watchlistProspectIds.length,
          greaterThan(lowCoverage.watchlistProspectIds.length),
          reason: 'AI draft capacity must still come from scout Coverage',
        );
        expect(
          highCoverageHighEvaluation.watchlistProspectIds,
          highCoverage.watchlistProspectIds,
          reason: 'AI watchlist assignment must not use scout Evaluation',
        );
      },
    );

    test('SeasonService forwards scout Coverage to the AI scouting plan', () {
      final generator = SeedDataGenerator(random: null);
      final baseLeague = generator.generateLeague(seed: 10205);
      final aiTeam = baseLeague.teams.firstWhere((team) => team.ai != null);
      final draftClass = generator.generateDraftClass(
        year: baseLeague.currentSeason.year + 1,
        prospectCount: 40,
      );
      final draftState = DraftState(
        year: draftClass.year,
        draftClass: draftClass,
      );

      Team withCoverage(double coverage) => aiTeam.copyWith(
        scouting: const TeamScouting(),
        staff: aiTeam.staff.copyWith(
          scout: staffMemberFor(
            StaffRole.scout,
            relevantValues: [coverage, 0.0],
            id: 'preserve-season-scout',
          ),
        ),
      );
      LeagueState withTeam(Team team) => baseLeague.copyWith(
        teams: [
          for (final candidate in baseLeague.teams)
            candidate.id == team.id ? team : candidate,
        ],
        currentSeason: baseLeague.currentSeason.copyWith(
          draftState: draftState,
        ),
      );

      final low = SeasonService().runScoutReport(
        withTeam(withCoverage(0.0)),
        saveSeed: 10205,
      );
      final high = SeasonService().runScoutReport(
        withTeam(withCoverage(5.0)),
        saveSeed: 10205,
      );

      final lowScouting = low.teamById(aiTeam.id)!.scouting;
      final highScouting = high.teamById(aiTeam.id)!.scouting;
      expect(
        highScouting.watchlistProspectIds.length,
        greaterThan(lowScouting.watchlistProspectIds.length),
        reason: 'SeasonService must pass scout Coverage to AI planning',
      );
    });

    test(
      'physio and doctor effects consume their own relevant fields only',
      () {
        final physioBase = staffMemberFor(
          StaffRole.physio,
          relevantValues: const [0.0, 0.0],
          irrelevantValue: 5.0,
          id: 'preserve-physio-base',
        );
        final rehab = physioBase.copyWith(
          attributes: physioBase.attributes.copyWith(rehabilitation: 5.0),
        );
        final regeneration = physioBase.copyWith(
          attributes: physioBase.attributes.copyWith(regenaration: 5.0),
        );
        final physioIrrelevant = physioBase.copyWith(
          attributes: physioBase.attributes.copyWith(care: 0.0),
        );
        const injury = InjuryService();

        expect(
          injury.physioRehabMult(rehab),
          lessThan(injury.physioRehabMult(physioBase)),
        );
        expect(
          injury.physioRehabMult(regeneration),
          lessThan(injury.physioRehabMult(physioBase)),
        );
        expect(
          injury.physioRehabMult(physioIrrelevant),
          injury.physioRehabMult(physioBase),
          reason: 'physio must not consume doctor Care',
        );

        final doctorBase = staffMemberFor(
          StaffRole.doctor,
          relevantValues: const [0.0, 0.0],
          irrelevantValue: 5.0,
          id: 'preserve-doctor-base',
        );
        final prevention = doctorBase.copyWith(
          attributes: doctorBase.attributes.copyWith(prevention: 5.0),
        );
        final care = doctorBase.copyWith(
          attributes: doctorBase.attributes.copyWith(care: 5.0),
        );
        final careOnlyMutation = doctorBase.copyWith(
          attributes: doctorBase.attributes.copyWith(care: 5.0),
        );
        final preventionOnlyMutation = doctorBase.copyWith(
          attributes: doctorBase.attributes.copyWith(prevention: 5.0),
        );

        expect(
          injury.doctorPreventionMult(prevention),
          lessThan(injury.doctorPreventionMult(doctorBase)),
        );
        expect(
          injury.doctorCareMult(care),
          lessThan(injury.doctorCareMult(doctorBase)),
        );
        expect(
          injury.doctorPreventionMult(careOnlyMutation),
          injury.doctorPreventionMult(doctorBase),
          reason: 'doctor Prevention effect must ignore Care',
        );
        expect(
          injury.doctorCareMult(preventionOnlyMutation),
          injury.doctorCareMult(doctorBase),
          reason: 'doctor Care effect must ignore Prevention',
        );
      },
    );

    test(
      'CFO Negotiation drives discount and staff demand independently of other fields',
      () {
        final low = staffCfoMember(negotiation: 1.0, irrelevantValue: 5.0);
        final high = staffCfoMember(negotiation: 5.0, irrelevantValue: 0.0);
        final irrelevantMutation = low.copyWith(
          attributes: withIrrelevantStaffAttribute(
            low.attributes,
            StaffRole.cfo,
            value: 0.0,
          ),
        );
        final service = StaffService();

        expect(low.overall, 1.0);
        expect(high.overall, 5.0);
        expect(
          service.cfoDiscount(cfo: high),
          greaterThan(service.cfoDiscount(cfo: low)),
          reason: 'CFO discount must use Negotiation',
        );
        expect(
          service.staffWant(high),
          greaterThan(service.staffWant(low)),
          reason: 'CFO contract demand must use role-specific quality',
        );
        expect(
          service.staffWant(irrelevantMutation),
          service.staffWant(low),
          reason: 'CFO irrelevant attributes must not change demand',
        );
      },
    );

    test(
      'RawOverall remains the domain input when presentation rounds to half stars',
      () {
        final member = staffMemberFor(
          StaffRole.headCoach,
          relevantValues: const [3.25, 3.25],
          id: 'preserve-raw-display',
          age: 45,
        );
        final view = StaffPresentation.viewForMember(member).rating!;
        final service = StaffService();
        final balance = BalanceConfig.defaults;

        expect(view.rawOverall, 3.25);
        expect(view.displayedRating, 3.5);
        expect(service.staffWant(member), 65.0);
        expect(
          service.staffWant(member),
          isNot(view.displayedRating * 20.0),
          reason: 'DisplayedRating must not become staff quality input',
        );
        expect(
          service.marketSalary(member),
          balance.staff.salaryFor(StaffRole.headCoach, 3.25),
        );
        expect(
          service.expectedLength(member),
          3,
          reason: 'raw want 65 belongs to the middle length band, not 70',
        );
      },
    );
  });
}

int _seedBetweenScoutingChances() {
  for (var seed = 0; seed < 10000; seed++) {
    final roll = Random(seed).nextDouble();
    if (roll >= 0.15 && roll < 0.60) return seed;
  }
  throw StateError('Could not find deterministic scouting threshold seed');
}
