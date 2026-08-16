import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/injury_catalog.dart';
import 'package:new_football/core/engine/match_engine.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/development_service.dart';
import 'package:new_football/core/services/injury_service.dart';

void main() {
  const injuryService = InjuryService();

  test('catalogue contains 26 entries in the five required groups', () {
    expect(InjuryCatalog.definitions, hasLength(26));
    expect(
      InjuryCatalog.definitions.map((definition) => definition.group).toSet(),
      hasLength(5),
    );
    expect(
      InjuryCatalog.definitions.map((definition) => definition.id).toSet(),
      hasLength(26),
    );
    expect(InjuryCatalog.totalWeight, greaterThan(0));
    for (final definition in InjuryCatalog.definitions) {
      expect(definition.minDays, lessThanOrEqualTo(definition.maxDays));
      expect(definition.weight, greaterThan(0));
    }
  });

  test('weighted catalogue sampling follows normalized weights', () {
    const rolls = 100000;
    final random = Random(10);
    final counts = <String, int>{};
    for (var i = 0; i < rolls; i++) {
      final definition = injuryService.pickDefinition(random);
      counts[definition.id] = (counts[definition.id] ?? 0) + 1;
    }

    for (final definition in InjuryCatalog.definitions) {
      final observed = (counts[definition.id] ?? 0) / rolls;
      final expected = definition.weight / InjuryCatalog.totalWeight;
      expect((observed - expected).abs(), lessThan(0.003));
    }
  });

  test('doctor care multiplier uses missing-staff and five-star endpoints', () {
    final fiveStar = StaffMember(
      id: 'doctor-5',
      name: 'Doctor',
      nationality: Nationality.poland,
      age: 40,
      role: StaffRole.doctor,
      attributes: const StaffAttributes(prevention: 5, care: 5),
    );
    expect(injuryService.doctorCareMult(null), closeTo(1.05, 0.0001));
    expect(injuryService.doctorCareMult(fiveStar), closeTo(0.87, 0.0001));
    expect(injuryService.doctorPreventionMult(fiveStar), closeTo(0.87, 0.0001));
  });

  test('diagnosed duration stays in the catalogue range with neutral care', () {
    final random = Random(11);
    for (var i = 0; i < 1000; i++) {
      final diagnosis = injuryService.diagnose(
        random: random,
        doctorCareMultiplier: 1.0,
      );
      expect(
        diagnosis.injury.daysTotal,
        inInclusiveRange(
          diagnosis.definition.minDays,
          diagnosis.definition.maxDays,
        ),
      );
      expect(diagnosis.injury.daysRemaining, diagnosis.injury.daysTotal);
    }
  });

  test(
    'major injuries lose potential in approximately ten percent of cases',
    () {
      final random = Random(12);
      var majorCount = 0;
      var lossCount = 0;
      for (var i = 0; i < 100000; i++) {
        final diagnosis = injuryService.diagnose(
          random: random,
          doctorCareMultiplier: 1.0,
        );
        if (diagnosis.injury.type != InjuryType.major) continue;
        majorCount++;
        if (diagnosis.potentialLoss) lossCount++;
      }
      expect(majorCount, greaterThan(10000));
      expect(lossCount / majorCount, closeTo(0.10, 0.015));

      final player = SeedDataGenerator(
        random: null,
      ).generateLeague(year: 2026, seed: 12).teams.first.roster.first;
      final major = InjuryCatalog.definitions.firstWhere(
        (definition) => definition.type == InjuryType.major,
      );
      final forcedLoss = InjuryDiagnosis(
        definition: major,
        injury: Injury(
          id: major.id,
          group: major.group,
          type: major.type,
          daysTotal: 30,
          daysRemaining: 30,
        ),
        potentialLoss: true,
      );
      final reduced = injuryService.applyPotentialLoss(player, forcedLoss);
      expect(reduced.potentialStars, max(0.5, player.potentialStars - 0.5));
      expect(reduced.pointValue, reduced.computePointValue());
      final clamped = injuryService.applyPotentialLoss(
        player.copyWith(potentialStars: 0.5),
        forcedLoss,
      );
      expect(clamped.potentialStars, 0.5);
    },
  );

  test('minor injuries never lower potential', () {
    final definition = InjuryCatalog.definitions.firstWhere(
      (item) => item.type == InjuryType.minor,
    );
    final diagnosis = InjuryDiagnosis(
      definition: definition,
      injury: Injury(
        id: definition.id,
        group: definition.group,
        type: definition.type,
        daysTotal: 7,
        daysRemaining: 7,
      ),
      potentialLoss: false,
    );
    final player = SeedDataGenerator(
      random: null,
    ).generateLeague(year: 2026, seed: 13).teams.first.roster.first;
    expect(injuryService.applyPotentialLoss(player, diagnosis), player);
  });

  test('active injury blocks positive growth but preserves decline', () {
    final player = SeedDataGenerator(random: null)
        .generateLeague(year: 2026, seed: 14)
        .teams
        .first
        .roster
        .first
        .copyWith(age: 20);
    final injury = Injury(
      id: 'ankle_sprain',
      group: InjuryGroup.anklesFeet,
      type: InjuryType.minor,
      daysTotal: 10,
      daysRemaining: 10,
    );
    final development = DevelopmentService(random: Random(1));
    final positive = player.copyWith(
      hidden: player.hidden.copyWith(growthRate: 1.0),
      state: player.state.copyWith(injury: injury),
    );
    final positiveResult = development.developPlayer(positive);
    expect(
      positiveResult.hidden.overallProgress,
      positive.hidden.overallProgress,
    );

    final negative = player.copyWith(
      age: 40,
      hidden: player.hidden.copyWith(growthRate: -3.0),
      state: player.state.copyWith(injury: injury),
    );
    final negativeResult = development.developPlayer(negative);
    expect(
      negativeResult.hidden.overallProgress,
      lessThan(negative.hidden.overallProgress),
    );
  });

  test('injured players are excluded from XI and explicit bench', () {
    final team = SeedDataGenerator(
      random: null,
    ).generateLeague(year: 2026, seed: 15).teams.first;
    final injured = team.roster.first;
    final injury = Injury(
      id: 'foot_contusion',
      group: InjuryGroup.anklesFeet,
      type: InjuryType.minor,
      daysTotal: 3,
      daysRemaining: 3,
    );
    final unavailable = injured.copyWith(
      state: injured.state.copyWith(injury: injury),
    );
    final ids = team.roster.take(11).map((player) => player.id).toList();
    final matchTeam = team.copyWith(
      roster: [
        unavailable,
        ...team.roster.where((player) => player.id != injured.id),
      ],
      lineupPlayerIds: ids,
      benchPlayerIds: [
        injured.id,
        ...team.roster.skip(11).take(2).map((p) => p.id),
      ],
    );
    expect(matchTeam.startingEleven, isNot(contains(unavailable)));

    final live = const MatchEngine().start(
      home: matchTeam,
      away: team,
      rngSeed: 15,
    );
    expect(live.state.homeBench, isNot(contains(unavailable)));
  });

  test('structural match injury and Injury serialization round-trip', () {
    final injury = Injury(
      id: 'acl_tear',
      group: InjuryGroup.knees,
      type: InjuryType.major,
      daysTotal: 200,
      daysRemaining: 200,
    );
    final result = MatchResult(
      homeTeamId: 'home',
      awayTeamId: 'away',
      homeGoals: 1,
      awayGoals: 0,
      homeStats: const TeamMatchStats(teamId: 'home'),
      awayStats: const TeamMatchStats(teamId: 'away'),
      injuries: [
        MatchInjury(
          teamId: 'home',
          playerId: 'player-1',
          injury: injury,
          playerInStartingXi: true,
          potentialLoss: true,
        ),
      ],
    );
    final decoded = MatchResult.fromJson(
      jsonDecode(jsonEncode(result.toJson())) as Map<String, dynamic>,
    );
    expect(decoded.injuries.single.injury, injury);
    expect(decoded.injuries.single.potentialLoss, isTrue);
    expect(
      Injury.fromJson(
        jsonDecode(jsonEncode(injury.toJson())) as Map<String, dynamic>,
      ),
      injury,
    );
  });

  test('save schema rejects versions other than current version', () {
    expect(SaveSchema.currentVersion, 8);
    final meta = GameSaveMeta(
      id: 'save',
      name: 'Save',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      seasonYear: 2026,
      phase: SeasonPhase.regular,
      schemaVersion: SaveSchema.currentVersion,
    );
    expect(
      meta.compatibilityWith(SaveSchema.currentVersion),
      SaveCompatibility.compatible,
    );
    expect(meta.compatibilityWith(7), SaveCompatibility.newer);
    expect(
      meta.copyWith(schemaVersion: 7).compatibilityWith(8),
      SaveCompatibility.older,
    );
  });
}
