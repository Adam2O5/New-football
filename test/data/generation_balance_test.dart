import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/field_player_attributes.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/models/prospect.dart';
import 'package:new_football/core/models/scouting.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/prospect_service.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/scouting_service.dart';
import 'package:new_football/core/simulation/effective_attributes.dart';

class _RecordingRandom implements Random {
  _RecordingRandom(int seed) : _source = Random(seed);
  final Random _source;
  final calls = <String>[];
  @override
  int nextInt(int max) {
    calls.add('int:$max');
    return _source.nextInt(max);
  }

  @override
  double nextDouble() {
    calls.add('double');
    return _source.nextDouble();
  }

  @override
  bool nextBool() {
    calls.add('bool');
    return _source.nextBool();
  }
}

List<int> _attributes(PlayerAttributes attributes) => attributes.map(
  outfield: (a) => [
    a.stats.pace,
    a.stats.shooting,
    a.stats.passing,
    a.stats.dribbling,
    a.stats.defending,
    a.stats.physicality,
  ],
  goalkeeper: (a) => [
    a.stats.diving,
    a.stats.handling,
    a.stats.kicking,
    a.stats.reflexes,
    a.stats.speed,
    a.stats.positioning,
  ],
);

void main() {
  test(
    'roster offsets, potential table and initial finances reach new games',
    () {
      final balance = BalanceConfig(
        seed: SeedBalance(
          rosterProfiles: [
            for (final p in SeedBalance.defaultRosterProfiles) (70, p.$2, p.$3),
          ],
          attributeOffsets: {
            for (final key in SeedBalance.defaultAttributeOffsets.keys)
              key: (0, 0),
          },
          gkAttributeOffsetMin: 0,
          gkAttributeOffsetMax: 0,
          potentialProfiles: const [
            (100, [(100, 3.5, 3.5)]),
          ],
          staffAgeMin: 44,
          staffAgeMax: 44,
          initialStaff: [for (var i = 0; i < 6; i++) (2.5, 1, 777000)],
        ),
        salaryCap: const SalaryCapBalance(
          salaryCap: 500000000,
          firstApron: 550000000,
          secondApron: 600000000,
          midLevelException: 15000000,
        ),
        cash: const ClubCashBalance(startingCash: 123000000),
      );
      final game = GameFactory(balance: balance).create(
        const NewGameRequest(
          saveName: 'generation balance',
          playerTeamId: 'team_europe_0',
          seed: 42,
        ),
      );
      for (final team in game.leagueState.teams) {
        for (final p in team.roster) {
          expect(_attributes(p.attributes), everyElement(70));
          expect(p.potentialStars, 3.5);
        }
        expect(team.finance.salaryCap, 500000000);
        expect(team.finance.firstApron, 550000000);
        expect(team.finance.secondApron, 600000000);
        expect(team.finance.midLevelExceptionAmount, 15000000);
        expect(team.finance.cashBalance, 123000000);
        for (final member in team.staff.members) {
          expect(member.age, 44);
          expect(member.contract!.salary, 777000);
        }
      }
    },
  );

  test(
    'generated squads, free agents and draft grades use the approved scale',
    () {
      for (final seed in [0, 42, 1313]) {
        final generator = SeedDataGenerator();
        final league = generator.generateLeague(seed: seed);
        expect(league.teams, hasLength(30));
        for (final team in league.teams) {
          expect(team.roster, hasLength(26));
          for (final player in team.roster) {
            expect(
              _attributes(player.attributes),
              everyElement(inInclusiveRange(50, 99)),
            );
          }
        }
        for (final player in generator.generateFreeAgentPlayers(
          rng: Random(seed),
        )) {
          expect(
            _attributes(player.attributes),
            everyElement(inInclusiveRange(50, 99)),
          );
        }
        for (final prospect
            in league.currentSeason.draftState!.draftClass.prospects) {
          expect(
            _attributes(prospect.attributes),
            everyElement(inInclusiveRange(50, 99)),
          );
          expect(prospect.scoutGrade, inInclusiveRange(50, 99));
          expect(prospect.combineScore, inInclusiveRange(50, 99));
        }
      }
    },
  );

  test(
    'attribute clamping does not add RNG calls or change unrelated draws',
    () {
      final oldRandom = _RecordingRandom(42), newRandom = _RecordingRandom(42);
      final old = SeedDataGenerator(
        balance: const BalanceConfig(player: PlayerBalance(attributeMin: 1)),
      ).generateFreeAgentPlayers(rng: oldRandom);
      final current = SeedDataGenerator().generateFreeAgentPlayers(
        rng: newRandom,
      );
      expect(newRandom.calls, oldRandom.calls);
      for (var i = 0; i < old.length; i++) {
        expect(current[i].id, old[i].id);
        expect(current[i].name, old[i].name);
        expect(current[i].age, old[i].age);
        expect(current[i].personality, old[i].personality);
        expect(current[i].hidden, old[i].hidden);
        expect(current[i].state, old[i].state);
      }
    },
  );

  test(
    'configured free-agent generation reaches every initial-state consumer',
    () {
      const balance = BalanceConfig(
        player: PlayerBalance(initialStamina: 77, traitMin: 4, traitMax: 4),
        development: DevelopmentBalance(
          determinationOutcomeTable: [(100, 0)],
          exceedSmallOffsetChance: 1,
          exceedSmallOffset: 0.25,
        ),
        seed: SeedBalance(
          freeAgentCountMin: 2,
          freeAgentCountMax: 2,
          freeAgentOvrMin: 80,
          freeAgentOvrMax: 80,
          freeAgentAgeMin: 24,
          freeAgentAgeMax: 24,
          freeAgentPotentialMin: 3,
          freeAgentPotentialMax: 3,
          playerFormMin: 7,
          playerFormMax: 7,
          youngProgressMin: 55,
          youngProgressMax: 55,
          defaultHeightRange: (188, 188),
          heightRanges: {},
        ),
      );
      final players = SeedDataGenerator(
        balance: balance,
      ).generateFreeAgentPlayers(rng: Random(12));
      expect(players, hasLength(2));
      for (final p in players) {
        expect(p.age, 24);
        expect(p.heightCm, 188);
        expect(p.potentialStars, 3);
        expect(p.state.stamina, 77);
        expect(p.state.form, 7);
        expect(p.hidden.overallProgress, 55);
        expect(p.hidden.determination, 4);
        expect(p.hidden.injuryProne, 4);
        expect(p.hidden.developmentOutcome, DevelopmentOutcome.exceed);
        expect(p.hidden.developmentCeilingStars, 3.25);
      }
    },
  );

  test(
    'draft profiles, next-season generation, scouting and conversion use overrides',
    () {
      const balance = BalanceConfig(
        player: PlayerBalance(
          attributeMin: 75,
          attributeMax: 76,
          initialStamina: 77,
        ),
        draft: DraftBalance(
          classSize: 2,
          prospectAgeMin: 19,
          prospectAgeMax: 19,
        ),
        seed: SeedBalance(
          draftProfiles: [(2, 70, 70, 3.0, 3.0)],
          scoutGradeOffsetMin: -100,
          scoutGradeOffsetMax: -100,
          combineOffsetMin: 100,
          combineOffsetMax: 100,
          prospectFormMin: 4,
          prospectFormMax: 4,
          prospectProgressMin: 61,
          prospectProgressMax: 61,
        ),
      );
      final draft = ProspectService(
        balance: balance,
      ).generateNextDraftClass(currentYear: 2028, seed: 42);
      expect(draft.year, 2029);
      expect(draft.draftClass.prospects, hasLength(2));
      for (final p in draft.draftClass.prospects) {
        expect(p.age, 19);
        expect(
          _attributes(p.attributes),
          everyElement(inInclusiveRange(75, 76)),
        );
        expect(p.scoutGrade, 75);
        expect(p.combineScore, 76);
        final player = p.toPlayer(
          contract: const Contract(salary: 1000000, yearsRemaining: 1),
          rng: Random(10),
          balance: balance,
        );
        expect(player.state.form, 4);
        expect(player.state.stamina, 77);
        expect(player.hidden.overallProgress, 61);
      }
      final scouting = TeamScouting(
        knowledge: [
          for (final p in draft.draftClass.prospects)
            ScoutingKnowledge(prospectId: p.id),
        ],
      );
      final reported = ScoutingService(
        balance: balance,
      ).runEarlyMock(scouting, draft.draftClass.prospects, 0, seed: 42);
      for (final knowledge in reported.knowledge) {
        expect(knowledge.estimatedOvrMin, inInclusiveRange(75, 76));
        expect(knowledge.estimatedOvrMax, inInclusiveRange(75, 76));
      }
    },
  );

  test(
    'staff generation, including the initial factory staff, uses the seed group',
    () {
      const balance = BalanceConfig(
        seed: SeedBalance(
          staffAgeMin: 44,
          staffAgeMax: 44,
          staffStarWeights: [(2.5, 1.0)],
        ),
      );
      final generator = SeedDataGenerator(balance: balance);
      final staff = generator.generateStaffPool(6, random: Random(42));
      for (final member in staff) {
        expect(member.age, 44);
        expect(member.overall, 2.5);
      }
      final initial = generator.generateStaffMemberAtStars(
        Random(42),
        StaffRole.headCoach,
        3,
      );
      expect(initial.age, 44);
      expect(initial.overall, 3);
    },
  );

  test(
    'a roster-size mismatch fails instead of truncating profiles or slots',
    () {
      expect(
        () => SeedDataGenerator(
          balance: const BalanceConfig(roster: RosterBalance(seedSize: 25)),
        ).generateLeague(seed: 42),
        throwsStateError,
      );
      expect(BalanceConfig.defaults.roster.seedSize, 26);
      expect(BalanceConfig.defaults.ai.rosterTargetTotal, 26);
    },
  );

  test(
    'single and batched effective attributes respect their separate scale',
    () {
      final source = SeedDataGenerator()
          .generateLeague(seed: 42)
          .teams
          .first
          .roster
          .firstWhere((p) => p.position != Position.gk);
      Player withStats(String id, int value) => source.copyWith(
        id: id,
        personality: PlayerPersonality.balanced,
        attributes: PlayerAttributes.outfield(
          stats: FieldPlayerAttributes(
            pace: value,
            shooting: value,
            passing: value,
            dribbling: value,
            defending: value,
            physicality: value,
          ),
        ),
      );
      final low = withStats('low', 1), high = withStats('high', 500);
      for (final bounds in [(30.0, 120.0), (75.0, 76.0)]) {
        final calculator = EffectiveAttributeCalculator(
          balance: BalanceConfig(
            matchday: MatchdayBalance(
              effectiveAttributeMin: bounds.$1,
              effectiveAttributeMax: bounds.$2,
            ),
          ),
        );
        final single = calculator.calculate(
          player: low,
          context: const MatchContext(),
          chemistry: 50,
          atmosphere: 50,
          cohesionMultiplier: 1,
          isHome: true,
        );
        final batch = calculator.calculateLineup(
          lineup: [low, high],
          context: const MatchContext(),
          chemistry: 50,
          atmosphere: 50,
          cohesionMultiplier: 1,
          isHome: true,
        );
        expect(single.values.values, everyElement(bounds.$1));
        expect(batch[low.id]!.values.values, everyElement(bounds.$1));
        expect(batch[high.id]!.values.values, everyElement(bounds.$2));
      }
    },
  );
}
