import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/engine/match_engine.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/field_player_attributes.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/simulation/effective_attributes.dart';
import 'package:new_football/core/simulation/team_shape.dart';
import 'package:new_football/core/simulation/unit_ratings.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

void main() {
  final league = SeedDataGenerator().generateLeague(year: 2026, seed: 1616);
  final home = league.teams.first;
  final away = league.teams[1];
  final sourcePlayer = home.roster.firstWhere(
    (player) => player.position != Position.gk,
  );

  Player playerWithFixedProfile({
    double form = 5,
    int stamina = 100,
    PlayerPersonality personality = PlayerPersonality.balanced,
  }) => sourcePlayer.copyWith(
    attributes: const PlayerAttributes.outfield(
      stats: FieldPlayerAttributes(
        pace: 85,
        shooting: 85,
        passing: 85,
        dribbling: 85,
        defending: 85,
        physicality: 85,
      ),
    ),
    personality: personality,
    state: sourcePlayer.state.copyWith(
      form: form,
      stamina: stamina,
      role: const AssignedRole.gk(),
    ),
  );

  group('Task 16 — TeamShape', () {
    test('tactical multiplier follows baseline 55 and weight 0.0025', () {
      const high = TeamShape(def: 75, mid: 75, atk: 75);
      const low = TeamShape(def: 35, mid: 35, atk: 35);

      expect(high.tacticalMult(ShapeAxis.def), closeTo(1.05, 1e-12));
      expect(low.tacticalMult(ShapeAxis.atk), closeTo(0.95, 1e-12));
    });

    test('formation and settings deltas are applied exactly', () {
      const calculator = TeamShapeCalculator();
      final shape = calculator.calculate(
        tactics: const TacticsSetup(
          formation: Formation.f4141,
          tempo: Tempo.fast,
          attackWidth: AttackWidth.balanced,
          defensiveLine: DefensiveLine.normal,
          pressing: PressingIntensity.medium,
        ),
        opponentTactics: const TacticsSetup(formation: Formation.f343),
      );

      // f4141 (62, 74, 42) + fast (-3, -2, +6) + balanced width (0, +1, 0)
      // + f4141-vs-f343 (-1, +2, +1) + no-HC boost (-5, -5, -5).
      expect(shape.def, closeTo(53, 1e-12));
      expect(shape.mid, closeTo(70, 1e-12));
      expect(shape.atk, closeTo(44, 1e-12));
    });

    test('role deltas are applied independently of the base formation', () {
      const calculator = TeamShapeCalculator();
      const tactics = const TacticsSetup(
        formation: Formation.f433,
        tempo: Tempo.balanced,
        attackWidth: AttackWidth.balanced,
        defensiveLine: DefensiveLine.normal,
        pressing: PressingIntensity.medium,
      );
      final withoutRole = calculator.calculate(
        tactics: tactics,
        opponentTactics: tactics,
      );
      final withRole = calculator.calculate(
        tactics: tactics,
        opponentTactics: tactics,
        lineup: [
          sourcePlayer.copyWith(
            state: sourcePlayer.state.copyWith(
              role: AssignedRole.cb(role: CbRole.noNonsenseCentreBack),
            ),
          ),
        ],
      );

      expect(withRole.def - withoutRole.def, closeTo(3, 1e-12));
      expect(withRole.mid - withoutRole.mid, closeTo(-3, 1e-12));
      expect(withRole.atk - withoutRole.atk, closeTo(0, 1e-12));
    });
  });

  group('Task 16 — effAttr', () {
    test('85 OVR, form 2 and stamina 30 produces about 58.65', () {
      final player = playerWithFixedProfile(form: 2, stamina: 30);
      final result = const EffectiveAttributeCalculator().calculate(
        player: player,
        context: const MatchContext(),
        chemistry: 50,
        atmosphere: 50,
        cohesionMultiplier: 1,
        isHome: true,
        assignedPosition: sourcePlayer.position,
      );

      for (final attribute in EffectiveAttribute.values) {
        expect(result[attribute], closeTo(58.65, 1e-9));
      }
    });

    test('leader multiplier is present once even with two leaders', () {
      final first = playerWithFixedProfile(
        personality: PlayerPersonality.leader,
      );
      final second = first.copyWith(id: '${first.id}-second');
      final result = const EffectiveAttributeCalculator().calculate(
        player: first,
        context: const MatchContext(),
        chemistry: 50,
        atmosphere: 50,
        cohesionMultiplier: 1,
        isHome: true,
        lineup: [first, second],
        assignedPosition: sourcePlayer.position,
      );

      expect(result.multipliers.leaderMult, closeTo(1.02, 1e-12));
      expect(result.multipliers.leaderMult, isNot(closeTo(1.02 * 1.02, 1e-12)));
    });

    test('weather, crowd and match-in-week affect context per attribute', () {
      const calculator = EffectiveAttributeCalculator();
      expect(
        calculator.contextMultiplier(
          attribute: EffectiveAttribute.passing,
          context: const MatchContext(weather: Weather.heavyRain),
          isHome: true,
        ),
        closeTo(0.90, 1e-12),
      );
      expect(
        calculator.contextMultiplier(
          attribute: EffectiveAttribute.pace,
          context: const MatchContext(weather: Weather.snow),
          isHome: true,
        ),
        closeTo(0.90, 1e-12),
      );

      final homeValue = calculator.contextMultiplier(
        attribute: EffectiveAttribute.shooting,
        context: const MatchContext(crowdIntensity: 100, homeMatchInWeek: 2),
        isHome: true,
      );
      final awayValue = calculator.contextMultiplier(
        attribute: EffectiveAttribute.shooting,
        context: const MatchContext(crowdIntensity: 100, awayMatchInWeek: 3),
        isHome: false,
      );
      expect(homeValue, closeTo(1.04 * 0.98, 1e-12));
      expect(awayValue, closeTo((1 - 100 / 4000) * 0.96, 1e-12));
    });

    test('personality helpers expose the documented runtime effects', () {
      const calculator = EffectiveAttributeCalculator();
      final temperamental = playerWithFixedProfile(
        personality: PlayerPersonality.temperamental,
      );
      final professional = playerWithFixedProfile(
        personality: PlayerPersonality.professional,
      );
      final loyal = playerWithFixedProfile(
        personality: PlayerPersonality.loyal,
      );
      final ambitious = playerWithFixedProfile(
        personality: PlayerPersonality.ambitious,
      );

      expect(calculator.cardProneMultiplier(temperamental), 1.35);
      expect(calculator.injuryMultiplier(professional), 0.80);
      expect(calculator.momentumForPlayer(loyal, -1), -0.8);
      expect(calculator.clutchBonus(ambitious), 0.03);
    });
  });

  group('Task 16 — runtime integration', () {
    test('start exposes ratings and a stamina tick refreshes them', () {
      const engine = MatchEngine();
      final target = home.startingEleven.firstWhere(
        (candidate) => candidate.position != Position.gk,
      );
      final fatiguedHome = home.copyWith(
        roster: [
          for (final candidate in home.roster)
            candidate.id == target.id
                ? candidate.copyWith(
                    state: candidate.state.copyWith(stamina: 40),
                  )
                : candidate,
        ],
      );
      final live = engine.start(home: fatiguedHome, away: away, rngSeed: 1616);
      final player = live.state.homeLineup.firstWhere(
        (candidate) => candidate.id == target.id,
      );
      final beforeStamina = live.staminaRemaining[player.id]!;
      final before = live.homeEffectiveAttributes[player.id]!;

      expect(live.homeTeamShape, isNotNull);
      expect(live.awayTeamShape, isNotNull);
      expect(live.homeUnitRatings, isNotNull);
      expect(live.awayUnitRatings, isNotNull);
      expect(live.homeEffectiveAttributes, contains(player.id));

      engine.simulateMinute(live);

      final after = live.homeEffectiveAttributes[player.id];
      expect(live.staminaRemaining[player.id], lessThan(beforeStamina));
      expect(after, isNotNull);
      expect(
        after!.multipliers.staminaMult,
        lessThan(before.multipliers.staminaMult),
      );
    });

    test('substitution and tactics changes refresh unit diagnostics', () {
      const engine = MatchEngine();
      final live = engine.start(home: home, away: away, rngSeed: 1617);
      final outgoing = live.state.homeLineup.first;
      final incoming = live.state.homeBench.first;
      final initialShape = live.homeTeamShape!;
      final initialAtk = live.homeUnitRatings!.atkRating;

      expect(
        engine.applySubstitution(
          live: live,
          homeSide: true,
          playerOutId: outgoing.id,
          playerInId: incoming.id,
        ),
        isTrue,
      );
      expect(live.homeEffectiveAttributes, contains(incoming.id));
      expect(live.homeEffectiveAttributes, isNot(contains(outgoing.id)));

      engine.updateTactics(
        live: live,
        homeSide: true,
        tactics: const TacticsSetup(formation: Formation.f424),
      );
      expect(live.homeTeamShape, isNot(equals(initialShape)));
      expect(live.homeUnitRatings!.atkRating, isNot(closeTo(initialAtk, 1e-9)));
    });

    test(
      'UnitRatingCalculator applies the injected balance to tacticalMult',
      () {
        const calculator = UnitRatingCalculator(
          balance: BalanceConfig(matchday: MatchdayBalance(shapeWeight: 0.01)),
        );
        final player = playerWithFixedProfile(
          form: 6,
        ).copyWith(position: Position.st);
        final effective = const EffectiveAttributeCalculator().calculate(
          player: player,
          context: const MatchContext(),
          chemistry: 50,
          atmosphere: 50,
          cohesionMultiplier: 1,
          isHome: true,
          assignedPosition: Position.st,
        );
        final baseAttributes = {player.id: effective};
        final ratings = calculator.calculate(
          lineup: [player],
          effectiveAttributes: baseAttributes,
          shape: const TeamShape(def: 55, mid: 55, atk: 75),
        );

        // A lone natural outfielder is a supporting member in the M/A units;
        // the custom weight must still make atk tacticalMult equal 1.20.
        expect(ratings.atkRating, greaterThan(0));
        expect(ratings.atkRating, closeTo(85 * 1.20, 1e-9));
      },
    );
  });
}
