import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/goalkeeper_attributes.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/random/match_random.dart';
import 'package:new_football/core/simulation/duel_resolver.dart';
import 'package:new_football/core/simulation/effective_attributes.dart';
import 'package:new_football/core/simulation/goalkeeper_resolver.dart';
import 'package:new_football/core/simulation/match_engine.dart';
import 'package:new_football/core/simulation/sequence_chain_resolver.dart';
import 'package:new_football/core/simulation/sequence_resolver.dart';
import 'package:new_football/core/simulation/set_piece_resolver.dart';
import 'package:new_football/core/simulation/shot_models.dart';
import 'package:new_football/core/simulation/shot_resolver.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

void main() {
  final league = SeedDataGenerator().generateLeague(year: 2026, seed: 1818);
  final home = league.teams[0];
  final away = league.teams[1];

  group('Task 18 — chain profiles and aerial model', () {
    test('aerialFactor follows the documented clamp and slope', () {
      final balance = BalanceConfig.defaults.matchday;

      expect(balance.aerialFactor(168), closeTo(45.6, 0.001));
      expect(balance.aerialFactor(175), closeTo(54.0, 0.001));
      expect(balance.aerialFactor(180), closeTo(60.0, 0.001));
      expect(balance.aerialFactor(190), closeTo(72.0, 0.001));
      expect(balance.aerialFactor(200), closeTo(84.0, 0.001));
      expect(balance.aerialFactor(120), 35.0);
      expect(balance.aerialFactor(240), 85.0);
    });

    test(
      'an 18 cm aerial edge is close to the documented 54.5% upset rate',
      () {
        final random = MatchRandom(1819);
        const resolver = DuelResolver();
        final aerialDelta =
            (BalanceConfig.defaults.matchday.aerialFactor(198) -
                BalanceConfig.defaults.matchday.aerialFactor(180)) *
            BalanceConfig.defaults.matchday.aerialDuelWeight;
        var wins = 0;
        const samples = 12000;
        for (var index = 0; index < samples; index++) {
          final duel = resolver.contest(
            attackerRating: 70 + aerialDelta,
            defenderRating: 70,
            random: random,
          );
          if (duel.attackerWon == true) wins++;
        }

        expect(wins / samples, closeTo(0.545, 0.035));
      },
    );

    test('throughBall high line adds the documented pace weight', () {
      final engine = SimulationMatchEngine();
      final live = engine.start(home: home, away: away, rngSeed: 1820);
      final attacker = live.state.homeLineup.firstWhere(
        (player) => player.position != Position.gk,
      );
      final defender = live.state.awayLineup.firstWhere(
        (player) => player.position != Position.gk,
      );
      final context = SequenceContext(
        attackingTactics: live.state.homeTactics,
        defendingTactics: live.state.awayTactics.copyWith(
          defensiveLine: DefensiveLine.high,
        ),
        attackingLineup: live.state.homeLineup,
        defendingLineup: live.state.awayLineup,
        attackingEffectiveAttributes: live.homeEffectiveAttributes,
        defendingEffectiveAttributes: live.awayEffectiveAttributes,
        attackingRatings: live.homeUnitRatings!,
        defendingRatings: live.awayUnitRatings!,
        weather: Weather.clear,
      );
      final selection = SequenceSelection(
        type: SequenceType.throughBall,
        attacker: attacker,
        defender: defender,
        attackerWeight: 1,
        defenderWeight: 1,
        attackerAttributeWeights: const {},
        defenderAttributeWeights: const {},
      );
      final resolution = const SequenceChainResolver().resolve(
        selection: selection,
        context: context,
        random: MatchRandom(1821),
      );

      expect(resolution.duels, hasLength(2));
      expect(
        resolution.duels[1].defenderWeights[EffectiveAttribute.pace],
        0.65,
      );
      expect(
        resolution.duels[1].defenderWeights[EffectiveAttribute.defending],
        0.45,
      );
    });
  });

  group('Task 18 — shot and goalkeeper pipeline', () {
    test('shot xG applies baseXg and shooterFactor before the GK factor', () {
      final shooter = home.startingEleven.firstWhere(
        (player) => player.position != Position.gk,
      );
      final shooting = shooter.attributes.map(
        outfield: (attributes) => attributes.stats.shooting.toDouble(),
        goalkeeper: (attributes) => attributes.stats.overall,
      );
      final shot = const ShotResolver().resolve(
        sequenceType: SequenceType.centralBuildUp,
        shotKind: SequenceShotKind.box,
        shooter: shooter,
        defendingLineup: away.startingEleven,
        context: const MatchContext(seed: 1822),
        random: MatchRandom(1823),
        useSequenceGate: false,
        baseXgOverride: 0.115,
      );
      final expected = (0.115 * (1 + (shooting - 70) / 180.0))
          .clamp(0.01, 0.95)
          .toDouble();

      expect(shot.isShot, isTrue);
      expect(shot.xg, closeTo(expected, 1e-9));
      expect(shot.goalProbability, inInclusiveRange(0.005, 0.97));
    });

    test(
      'all five GK profiles and weather handling multipliers are exposed',
      () {
        final goalkeeper = away.startingEleven.firstWhere(
          (player) => player.position == Position.gk,
        );
        final lineup = [goalkeeper];
        const resolver = GoalkeeperResolver();
        final profiles = <SequenceShotKind>[
          SequenceShotKind.distance,
          SequenceShotKind.box,
          SequenceShotKind.header,
          SequenceShotKind.oneOnOne,
          SequenceShotKind.penalty,
        ];

        for (final profile in profiles) {
          final clear = resolver.resolve(
            shotKind: profile,
            defendingLineup: lineup,
            weather: Weather.clear,
          );
          final rain = resolver.resolve(
            shotKind: profile,
            defendingLineup: lineup,
            weather: Weather.heavyRain,
          );
          expect(clear.goalkeeperId, goalkeeper.id);
          expect(
            clear.profileWeights.values.reduce((a, b) => a + b),
            closeTo(1, 1e-9),
          );
          expect(
            rain.handlingErrorProbability,
            greaterThan(clear.handlingErrorProbability),
          );
        }
        expect(
          BalanceConfig.defaults.matchday.weatherHandlingMultiplier(
            Weather.heavyRain,
          ),
          1.60,
        );
      },
    );

    test('missing GK uses the documented fallback and remains playable', () {
      final noGoalkeeper = away.startingEleven
          .where((player) => player.position != Position.gk)
          .toList(growable: false);
      final shooter = home.startingEleven.firstWhere(
        (player) => player.position != Position.gk,
      );
      final result = const ShotResolver().resolve(
        sequenceType: SequenceType.centralBuildUp,
        shotKind: SequenceShotKind.box,
        shooter: shooter,
        defendingLineup: noGoalkeeper,
        context: const MatchContext(seed: 1824),
        random: MatchRandom(1825),
        useSequenceGate: false,
      );

      expect(result.goalkeeperId, isNull);
      expect(result.goalkeeperRating, inInclusiveRange(0, 100));
      expect(result.isShot, isTrue);
    });
  });

  group('Task 18 — SFG and integrated simulation', () {
    test(
      'SFG uses setting multiplier, aerial edge and penalty clutch duel',
      () {
        const tactics = TacticsSetup(
          cornersAttack: 50,
          freeKicks: 50,
          penalties: 50,
        );
        final live = SimulationMatchEngine().start(
          home: home,
          away: away,
          context: const MatchContext(stake: MatchStake.leagueFinal),
          rngSeed: 1826,
        );
        final result = const SetPieceResolver().resolve(
          type: SetPieceType.penalty,
          attackingLineup: live.state.homeLineup,
          defendingLineup: live.state.awayLineup,
          attackingAttributes: live.homeEffectiveAttributes,
          defendingAttributes: live.awayEffectiveAttributes,
          attackingTactics: tactics,
          context: live.state.context,
          random: MatchRandom(1827),
        );

        expect(result.sfgMultiplier, 1.0);
        expect(result.aerialEdge, inInclusiveRange(-25, 25));
        expect(result.penaltyDuel, isNotNull);
        expect(result.shot.xg, greaterThan(0.5));
        expect(
          BalanceConfig.defaults.matchday.clutchBonus(
            determination: 8,
            stake: MatchStake.leagueFinal,
            ambitious: true,
          ),
          closeTo((8 - 5.5) * 1.2 * 1.6 * 1.03, 1e-9),
        );
      },
    );

    test(
      'full Task 18 simulation is deterministic and exposes shots/goals/xG',
      () {
        final engine = SimulationMatchEngine();
        const context = MatchContext(seed: 1828);
        final first = engine.simulateFull(
          home: home,
          away: away,
          context: context,
          rngSeed: 1,
        );
        final second = engine.simulateFull(
          home: home,
          away: away,
          context: context,
          rngSeed: 1,
        );
        final traces = first.minuteTraces
            .expand((minute) => minute.sequences)
            .toList(growable: false);
        final tracedShots = traces.fold<int>(
          0,
          (sum, trace) =>
              sum +
              (trace.shot?.isShot == true ? 1 : 0) +
              (trace.shot?.reboundAttempted == true ? 1 : 0),
        );
        final tracedGoals = traces.where((trace) => trace.isGoal).length;

        expect(first.traceSignature, second.traceSignature);
        expect(first.finalState.minute, 90);
        expect(first.homeGoals, first.finalState.homeGoals);
        expect(first.awayGoals, first.finalState.awayGoals);
        expect(first.homeShots + first.awayShots, greaterThan(0));
        expect(first.homeShots + first.awayShots, tracedShots);
        expect(first.totalGoals, tracedGoals);
        expect(first.homeXg + first.awayXg, greaterThan(0));
        expect(
          traces.any((trace) => trace.chain != null && trace.duels.length >= 1),
          isTrue,
        );
        expect(traces.every((trace) => trace.duels.length <= 2), isTrue);
      },
    );
  });
}
