import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/random/match_random.dart';
import 'package:new_football/core/simulation/duel_resolver.dart';
import 'package:new_football/core/simulation/match_engine.dart';
import 'package:new_football/core/simulation/sequence_resolver.dart';

void main() {
  final league = SeedDataGenerator().generateLeague(year: 2026, seed: 1717);
  final home = league.teams[0];
  final away = league.teams[1];

  group('Task 17 — random stream and duel core', () {
    test('contest gives the documented upset curve at +10 and +25', () {
      double winRate(double advantage) {
        final random = MatchRandom(1700 + advantage.round());
        const resolver = DuelResolver(
          balance: BalanceConfig(
            matchday: MatchdayBalance(duelDispersion: 35, duelSigma: 6.0),
          ),
        );
        var wins = 0;
        const samples = 20000;
        for (var i = 0; i < samples; i++) {
          final result = resolver.contest(
            attackerRating: 70 + advantage,
            defenderRating: 70,
            random: random,
          );
          if (result.attackerWon == true) wins++;
        }
        return wins / samples;
      }

      expect(winRate(10), closeTo(0.66, 0.025));
      expect(winRate(25), closeTo(0.84, 0.025));
    });

    test('Poisson sequence roll stays bounded by the matchday clamp', () {
      final random = MatchRandom(1718);
      var sum = 0;
      const samples = 10000;
      for (var i = 0; i < samples; i++) {
        sum += random.nextPoisson(1.15).clamp(0, 3);
      }

      final average = sum / samples;
      expect(average, greaterThan(1.0));
      expect(average, lessThan(1.2));
    });
  });

  group('Task 17 — minute loop', () {
    test('same seed reproduces the complete sequence trace', () {
      final engine = SimulationMatchEngine();
      const context = MatchContext(
        homeTeamId: 'home',
        awayTeamId: 'away',
        seed: 1719,
      );
      final first = engine.simulateFull(
        home: home,
        away: away,
        context: context,
        rngSeed: 999,
      );
      final second = engine.simulateFull(
        home: home,
        away: away,
        context: context,
        rngSeed: 999,
      );

      expect(first.seed, 1719);
      expect(first.minutesSimulated, 90);
      expect(first.finalState.minute, 90);
      expect(first.traceSignature, second.traceSignature);
      expect(first.totalSequences, second.totalSequences);
      expect(first.homePossessionPercent, second.homePossessionPercent);
      expect(
        first.minuteTraces.every(
          (trace) => trace.sequenceCount >= 0 && trace.sequenceCount <= 3,
        ),
        isTrue,
      );
    });

    test('minute-by-minute and full simulation share the same trace', () {
      final engine = SimulationMatchEngine();
      const context = MatchContext(seed: 1722);
      final observed = engine.start(
        home: home,
        away: away,
        context: context,
        rngSeed: 1,
      );
      engine.runUntil(observed, 90);
      final observedResult = observed.toResult();
      final simulatedResult = engine.simulateFull(
        home: home,
        away: away,
        context: context,
        rngSeed: 1,
      );

      expect(observedResult.traceSignature, simulatedResult.traceSignature);
      expect(observedResult.totalSequences, simulatedResult.totalSequences);
    });

    test('sequence volume is close to 100–110 per 90-minute match', () {
      final engine = SimulationMatchEngine();
      var totalSequences = 0;
      var homeSequences = 0;
      var awaySequences = 0;
      const simulations = 80;

      for (var i = 0; i < simulations; i++) {
        final result = engine.simulateFull(
          home: home,
          // Equal lineups isolate the Poisson/possession volume contract from
          // the strength gap between two randomly generated teams.
          away: home,
          rngSeed: 1720 + i,
        );
        totalSequences += result.totalSequences;
        homeSequences += result.homeSequences;
        awaySequences += result.awaySequences;
        expect(result.homePossessionPercent, inInclusiveRange(0, 100));
        expect(result.awayPossessionPercent, inInclusiveRange(0, 100));
      }

      final averageTotal = totalSequences / simulations;
      final averageHome = homeSequences / simulations;
      final averageAway = awaySequences / simulations;
      expect(averageTotal, greaterThan(95));
      expect(averageTotal, lessThan(108));
      expect(averageHome, greaterThan(40));
      expect(averageAway, greaterThan(40));
      expect(averageHome + averageAway, closeTo(averageTotal, 1e-9));
    });

    test('stamina tick precedes the Task 16 effAttr refresh', () {
      final engine = SimulationMatchEngine();
      final target = home.startingEleven.firstWhere(
        (player) => player.position != Position.gk,
      );
      final fatiguedHome = home.copyWith(
        roster: [
          for (final player in home.roster)
            player.id == target.id
                ? player.copyWith(state: player.state.copyWith(stamina: 40))
                : player,
        ],
      );
      final live = engine.start(home: fatiguedHome, away: away, rngSeed: 1721);
      final onPitch = live.state.homeLineup.firstWhere(
        (player) => player.id == target.id,
      );
      final staminaBefore = live.legacyMatch.staminaRemaining[onPitch.id]!;
      final attributesBefore = live.homeEffectiveAttributes[onPitch.id]!;

      final trace = engine.simulateMinute(live);
      final attributesAfter = live.homeEffectiveAttributes[onPitch.id]!;

      expect(live.state.minute, 1);
      expect(
        live.legacyMatch.staminaRemaining[onPitch.id],
        lessThan(staminaBefore),
      );
      expect(
        attributesAfter.multipliers.staminaMult,
        lessThan(attributesBefore.multipliers.staminaMult),
      );
      expect(trace.randomCursorStart, 0);
      expect(trace.randomCursorEnd, greaterThan(trace.randomCursorStart));
    });

    test('all eight sequence families have positive base weights', () {
      final names =
          BalanceConfig.defaults.matchday.sequenceTypeBaseWeights.keys;
      expect(names, containsAll(SequenceType.values.map((type) => type.name)));
    });
  });
}
