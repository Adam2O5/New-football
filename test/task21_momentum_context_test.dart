import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/random/match_random.dart';
import 'package:new_football/core/simulation/goalkeeper_resolver.dart';
import 'package:new_football/core/simulation/match_context_effects.dart';
import 'package:new_football/core/simulation/match_context_factory.dart';
import 'package:new_football/core/simulation/match_engine.dart';
import 'package:new_football/core/simulation/sequence_resolver.dart';
import 'package:new_football/core/simulation/set_piece_resolver.dart';
import 'package:new_football/core/simulation/shot_models.dart';
import 'package:new_football/core/simulation/shot_resolver.dart';

void main() {
  final league = SeedDataGenerator().generateLeague(year: 2026, seed: 2121);
  final home = league.teams[0];
  final away = league.teams[1];

  MatchContext context({
    int seed = 2121,
    Weather weather = Weather.clear,
    MatchStake stake = MatchStake.regular,
    bool derby = false,
    int crowd = 0,
    int temperature = 20,
  }) => MatchContext(
    homeTeamId: home.id,
    awayTeamId: away.id,
    weather: weather,
    temperatureC: temperature,
    isDerby: derby,
    stake: stake,
    crowdIntensity: crowd,
    seed: seed,
  );

  BalanceConfig quietBalance({
    double sequenceBase = 0.0,
    double sequenceToShot = 0.0,
    double injuryBase = 0.0,
    double foulBase = 0.0,
    double yellowFromFoul = 0.0,
    double redDirect = 0.0,
    Map<String, double>? sequenceBaseXg,
  }) => BalanceConfig(
    matchday: MatchdayBalance(
      sequenceBase: sequenceBase,
      sequenceToShot: sequenceToShot,
      injuryBase: injuryBase,
      foulBase: foulBase,
      yellowFromFoul: yellowFromFoul,
      redDirect: redDirect,
      sequenceBaseXg:
          sequenceBaseXg ??
          const <String, double>{
            'centralBuildUp': 0.01,
            'wingPlay': 0.01,
            'crossFromWide': 0.01,
            'throughBall': 0.01,
            'individualDribble': 0.01,
            'counterAttack': 0.01,
            'longBall': 0.01,
            'setPiece': 0.01,
          },
    ),
  );

  Map<String, double> highChanceXg() => const <String, double>{
    'centralBuildUp': 0.90,
    'wingPlay': 0.90,
    'crossFromWide': 0.90,
    'throughBall': 0.90,
    'individualDribble': 0.90,
    'counterAttack': 0.90,
    'longBall': 0.90,
    'setPiece': 0.10,
  };

  double traceMomentumDelta(SimulationMinuteTrace trace) {
    var delta = 0.0;
    for (final sequence in trace.sequences) {
      final shot = sequence.shot;
      if (shot == null || !shot.isShot) continue;
      if (shot.isGoal) {
        delta += sequence.attackingHome ? 25.0 : -25.0;
      } else if (shot.xg > 0.4) {
        delta += sequence.attackingHome ? 8.0 : -8.0;
      }
    }
    return delta;
  }

  SequenceContext sequenceContextFor(
    SimulationLiveMatch live, {
    required Weather weather,
    double longBallWeightMultiplier = 1.0,
  }) => SequenceContext(
    attackingTactics: live.state.homeTactics,
    defendingTactics: live.state.awayTactics,
    attackingLineup: live.state.homeLineup,
    defendingLineup: live.state.awayLineup,
    attackingEffectiveAttributes: live.homeEffectiveAttributes,
    defendingEffectiveAttributes: live.awayEffectiveAttributes,
    attackingRatings: live.homeUnitRatings!,
    defendingRatings: live.awayUnitRatings!,
    weather: weather,
    longBallWeightMultiplier: longBallWeightMultiplier,
  );

  group('Task 21 — momentum i score-state', () {
    test('momentum zanika ×0,96 i pozostaje w MatchState legacy runtime', () {
      final balance = quietBalance();
      final engine = SimulationMatchEngine(balance: balance);
      final live = engine.start(
        home: home,
        away: away,
        context: context(),
        rngSeed: 2122,
      );
      live.legacyMatch.state = live.state.copyWith(momentum: 50.0);

      final trace = engine.simulateMinute(live);

      expect(live.state.momentum, closeTo(48.0, 1e-12));
      expect(live.legacyMatch.state.momentum, closeTo(48.0, 1e-12));
      expect(trace.momentum, closeTo(48.0, 1e-12));
    });

    test(
      'score-state działa od 65. minuty i blokuje się po ręcznej taktyce',
      () {
        const balance = MatchdayBalance();

        final before = ScoreStateModifiers.forTeam(
          minute: 64,
          homeGoals: 0,
          awayGoals: 1,
          homeSide: true,
          balance: balance,
        );
        final trailingOne = ScoreStateModifiers.forTeam(
          minute: 65,
          homeGoals: 0,
          awayGoals: 1,
          homeSide: true,
          balance: balance,
        );
        final trailingTwo = ScoreStateModifiers.forTeam(
          minute: 65,
          homeGoals: 0,
          awayGoals: 2,
          homeSide: true,
          balance: balance,
        );
        final leadingOne = ScoreStateModifiers.forTeam(
          minute: 65,
          homeGoals: 1,
          awayGoals: 0,
          homeSide: true,
          balance: balance,
        );
        final leadingTwo = ScoreStateModifiers.forTeam(
          minute: 65,
          homeGoals: 2,
          awayGoals: 0,
          homeSide: true,
          balance: balance,
        );
        final manual = ScoreStateModifiers.forTeam(
          minute: 66,
          homeGoals: 0,
          awayGoals: 2,
          homeSide: true,
          balance: balance,
          manualTacticsAfter65: true,
        );

        expect(before.automatic, isFalse);
        expect(trailingOne.attackDelta, 6);
        expect(trailingOne.defenseDelta, -5);
        expect(trailingOne.lambdaMultiplier, 1.10);
        expect(trailingTwo.attackDelta, 10);
        expect(trailingTwo.defenseDelta, -9);
        expect(trailingTwo.lambdaMultiplier, 1.18);
        expect(trailingTwo.longBallWeightMultiplier, 1.60);
        expect(leadingOne.attackDelta, -4);
        expect(leadingOne.defenseDelta, 5);
        expect(leadingOne.lambdaMultiplier, 0.94);
        expect(leadingTwo.attackDelta, -6);
        expect(leadingTwo.defenseDelta, 7);
        expect(leadingTwo.lambdaMultiplier, 0.88);
        expect(manual.automatic, isFalse);
        expect(manual.attackDelta, 0);
        expect(manual.defenseDelta, 0);
        expect(manual.lambdaMultiplier, 1.0);
        expect(manual.longBallWeightMultiplier, 1.0);
      },
    );

    test('ręczna zmiana po 65. minucie wyłącza automatyczny score-state', () {
      final balance = quietBalance();
      final engine = SimulationMatchEngine(balance: balance);
      final live = engine.start(
        home: home,
        away: away,
        context: context(),
        rngSeed: 2123,
      );
      live.legacyMatch.state = live.state.copyWith(minute: 65, awayGoals: 2);
      final tactics = live.state.homeTactics.copyWith(tempo: Tempo.fast);

      expect(
        engine.updateTactics(live: live, homeSide: true, tactics: tactics),
        isTrue,
      );
      final trace = engine.simulateMinute(live);

      expect(live.homeManualTacticsAfter65, isTrue);
      expect(trace.minute, 66);
      expect(trace.homeScoreState.automatic, isFalse);
      expect(trace.homeScoreState.attackDelta, 0);
    });

    test('gol i zmarnowana duża sytuacja zapisują właściwe delty momentum', () {
      final balance = quietBalance(
        sequenceBase: 1.15,
        sequenceToShot: 1.0,
        sequenceBaseXg: highChanceXg(),
      );
      final engine = SimulationMatchEngine(balance: balance);
      SimulationLiveMatch? goalLive;
      SimulationMinuteTrace? goalTrace;

      for (var seed = 1; seed <= 500 && goalLive == null; seed++) {
        final live = engine.start(
          home: home,
          away: away,
          context: context(seed: seed),
          rngSeed: seed,
        );
        final trace = engine.simulateMinute(live);
        if (trace.sequences.any((sequence) => sequence.shot?.isGoal == true)) {
          goalLive = live;
          goalTrace = trace;
        }
      }

      if (goalLive == null || goalTrace == null) {
        fail('Nie znaleziono deterministycznego gola w próbie Task 21.');
      }
      final expected = traceMomentumDelta(goalTrace);
      expect(goalLive.state.momentum, closeTo(expected, 1e-9));
      expect(
        goalLive.events.any((event) => event.type == MatchEventType.goal),
        isTrue,
      );
    });

    test('czerwona kartka daje −20 ukaranej stronie', () {
      final balance = quietBalance(
        sequenceBase: 100.0,
        foulBase: 1.0,
        redDirect: 1.0,
        sequenceToShot: 0.0,
      );
      final engine = SimulationMatchEngine(balance: balance);
      SimulationLiveMatch? redLive;

      for (var seed = 1; seed <= 200 && redLive == null; seed++) {
        final live = engine.start(
          home: home,
          away: away,
          context: context(seed: seed),
          rngSeed: seed,
        );
        engine.simulateMinute(live);
        if (live.events.any((event) => event.type == MatchEventType.redCard)) {
          redLive = live;
        }
      }

      if (redLive == null) {
        fail('Nie znaleziono deterministycznej czerwonej kartki.');
      }
      final expected = redLive.events
          .where((event) => event.type == MatchEventType.redCard)
          .fold<double>(
            0.0,
            (sum, event) => sum + (event.teamId == home.id ? -20.0 : 20.0),
          );
      expect(redLive.state.momentum, closeTo(expected, 1e-9));
    });

    test('kontuzja key playera daje −8 dla jego zespołu', () {
      final originalKey = home.startingEleven.reduce(
        (best, candidate) =>
            candidate.overall() > best.overall() ? candidate : best,
      );
      final homeRoster = [
        for (final player in home.roster)
          player.copyWith(
            hidden: player.hidden.copyWith(
              injuryProne: player.id == originalKey.id ? 10 : 1,
            ),
          ),
      ];
      final awayRoster = [
        for (final player in away.roster)
          player.copyWith(hidden: player.hidden.copyWith(injuryProne: 1)),
      ];
      final testHome = home.copyWith(roster: homeRoster);
      final testAway = away.copyWith(roster: awayRoster);
      final injuryProne = <int, double>{
        for (var value = 1; value <= 10; value++)
          value: value == 10 ? 1.0 : 0.0,
      };
      final balance = BalanceConfig(
        matchday: MatchdayBalance(
          sequenceBase: 0.0,
          injuryBase: 100.0,
          foulBase: 0.0,
          injuryProneMultipliers: injuryProne,
        ),
      );
      final engine = SimulationMatchEngine(balance: balance);
      final live = engine.start(
        home: testHome,
        away: testAway,
        context: context(),
        rngSeed: 2124,
      );
      final key = live.legacyMatch.homeStartingLineup.reduce(
        (best, candidate) =>
            candidate.overall() > best.overall() ? candidate : best,
      );

      engine.simulateMinute(live);

      expect(live.injuries.any((injury) => injury.playerId == key.id), isTrue);
      expect(live.state.momentum, closeTo(-8.0, 1e-9));
    });
  });

  group('Task 21 — karny i kontekst', () {
    test('SetPieceResolution zapisuje scoredPenalty i missedPenalty', () {
      const saved = ShotResolution(
        isShot: true,
        xg: 0.76,
        goalProbability: 0.50,
        outcome: ShotOutcome.saved,
        shooterId: 'penalty-taker',
        goalkeeperId: 'goalkeeper',
        goalkeeperRating: 70.0,
        handlingErrorProbability: 0.0,
        reboundAttempted: false,
        reboundGoal: false,
        reboundXg: 0.0,
        cornerAwarded: false,
      );
      const scored = ShotResolution(
        isShot: true,
        xg: 0.76,
        goalProbability: 0.90,
        outcome: ShotOutcome.goal,
        shooterId: 'penalty-taker',
        goalkeeperId: 'goalkeeper',
        goalkeeperRating: 70.0,
        handlingErrorProbability: 0.0,
        reboundAttempted: false,
        reboundGoal: false,
        reboundXg: 0.0,
        cornerAwarded: false,
      );
      const savedResolution = SetPieceResolution(
        type: SetPieceType.penalty,
        shooterId: 'penalty-taker',
        sfgMultiplier: 1.0,
        aerialEdge: 0.0,
        shot: saved,
        penaltyDuel: null,
      );
      const scoredResolution = SetPieceResolution(
        type: SetPieceType.penalty,
        shooterId: 'penalty-taker',
        sfgMultiplier: 1.0,
        aerialEdge: 0.0,
        shot: scored,
        penaltyDuel: null,
      );
      final engine = SimulationMatchEngine(balance: quietBalance());
      final savedLive = engine.start(
        home: home,
        away: away,
        context: context(),
        rngSeed: 2125,
      );
      savedLive.recordSetPieceResolution(
        resolution: savedResolution,
        attackingHome: true,
        minute: 12,
      );

      expect(savedLive.state.momentum, closeTo(-18.0, 1e-9));
      expect(savedLive.homeShots, 1);
      expect(savedLive.events.single.type, MatchEventType.missedPenalty);
      expect(savedLive.events.single.minute, 12);

      final scoredLive = engine.start(
        home: home,
        away: away,
        context: context(),
        rngSeed: 2126,
      );
      scoredLive.recordSetPieceResolution(
        resolution: scoredResolution,
        attackingHome: false,
        minute: 13,
      );

      expect(scoredLive.state.awayGoals, 1);
      expect(scoredLive.state.momentum, closeTo(-25.0, 1e-9));
      expect(scoredLive.events.single.type, MatchEventType.scoredPenalty);
    });

    test('pogoda udostępnia sześć efektów, w tym heavyRain GK error i xG', () {
      const balance = MatchdayBalance();
      final heavyRain = MatchContextEffects.weather(Weather.heavyRain, balance);
      expect(heavyRain.passingMultiplier, 0.90);
      expect(heavyRain.paceMultiplier, 0.94);
      expect(heavyRain.goalkeeperErrorMultiplier, 1.60);
      expect(heavyRain.staminaMultiplier, 1.08);
      expect(heavyRain.injuryMultiplier, 1.15);
      expect(heavyRain.xgMultiplier, 1.05);

      final clearLive = SimulationMatchEngine().start(
        home: home,
        away: away,
        context: context(weather: Weather.clear),
        rngSeed: 2127,
      );
      final rainLive = SimulationMatchEngine().start(
        home: home,
        away: away,
        context: context(weather: Weather.heavyRain),
        rngSeed: 2127,
      );
      final shooter = clearLive.state.homeLineup.firstWhere(
        (player) => player.position != Position.gk,
      );
      final clearShot = ShotResolver().resolve(
        sequenceType: SequenceType.centralBuildUp,
        shotKind: SequenceShotKind.box,
        shooter: shooter,
        defendingLineup: clearLive.state.awayLineup,
        context: clearLive.state.context,
        random: MatchRandom(2128),
        shooterAttributes: clearLive.homeEffectiveAttributes,
        defendingAttributes: clearLive.awayEffectiveAttributes,
        useSequenceGate: false,
        baseXgOverride: 0.20,
      );
      final rainShot = ShotResolver().resolve(
        sequenceType: SequenceType.centralBuildUp,
        shotKind: SequenceShotKind.box,
        shooter: shooter,
        defendingLineup: rainLive.state.awayLineup,
        context: rainLive.state.context,
        random: MatchRandom(2128),
        shooterAttributes: rainLive.homeEffectiveAttributes,
        defendingAttributes: rainLive.awayEffectiveAttributes,
        useSequenceGate: false,
        baseXgOverride: 0.20,
      );
      expect(rainShot.xg / clearShot.xg, closeTo(1.05, 1e-9));

      final clearGoalkeeper = GoalkeeperResolver().resolve(
        shotKind: SequenceShotKind.box,
        defendingLineup: clearLive.state.awayLineup,
        effectiveAttributes: clearLive.awayEffectiveAttributes,
        weather: Weather.clear,
      );
      final rainGoalkeeper = GoalkeeperResolver().resolve(
        shotKind: SequenceShotKind.box,
        defendingLineup: rainLive.state.awayLineup,
        effectiveAttributes: rainLive.awayEffectiveAttributes,
        weather: Weather.heavyRain,
      );
      expect(
        rainGoalkeeper.handlingErrorProbability /
            clearGoalkeeper.handlingErrorProbability,
        closeTo(1.60, 1e-9),
      );
    });

    test('wind zwiększa wagę longBall, a temperatura stosuje wzór stamina', () {
      const balance = BalanceConfig(
        matchday: MatchdayBalance(
          sequenceConditionBonus: 0.0,
          sequenceStrongConditionBonus: 0.0,
        ),
      );
      final engine = SimulationMatchEngine(balance: balance);
      final live = engine.start(
        home: home,
        away: away,
        context: context(weather: Weather.wind),
        rngSeed: 2129,
      );
      final selector = SequenceSelector(balance: balance);
      final clearWeights = selector.weightsFor(
        sequenceContextFor(live, weather: Weather.clear),
      );
      final windWeights = selector.weightsFor(
        sequenceContextFor(live, weather: Weather.wind),
      );

      expect(
        windWeights[SequenceType.longBall]! /
            clearWeights[SequenceType.longBall]!,
        closeTo(1.40, 1e-9),
      );
      expect(
        balance.matchday.temperatureStaminaMultiplier(34),
        closeTo(1.12, 1e-12),
      );
      expect(
        balance.matchday.temperatureStaminaMultiplier(-4),
        closeTo(1.064, 1e-12),
      );
    });

    test('derby, crowd i stake wpływają na kontekst oraz lambdę', () {
      final sameConferenceAway = league.teams.firstWhere(
        (team) => team.conference == home.conference && team.id != home.id,
      );
      final contextHome = home.copyWith(recentMatchResults: const []);
      final rivalry = MatchContextFactory.rivalryKey(
        contextHome.id,
        sameConferenceAway.id,
      );
      final factory = MatchContextFactory(rivalryKeys: {rivalry});
      final regular = factory.createForTeams(
        home: contextHome,
        away: sameConferenceAway,
        seasonYear: 2026,
        matchId: 'task21-regular',
        saveSeed: 2121,
        stake: MatchStake.regular,
      );
      final playIn = factory.createForTeams(
        home: contextHome,
        away: sameConferenceAway,
        seasonYear: 2026,
        matchId: 'task21-playin',
        saveSeed: 2121,
        stake: MatchStake.playIn,
      );

      expect(regular.isDerby, isTrue);
      expect(regular.crowdIntensity, 80);
      expect(playIn.crowdIntensity, 90);
      expect(MatchdayBalance().crowdHomeMultiplier(80), closeTo(1.032, 1e-12));
      expect(MatchdayBalance().crowdAwayMultiplier(80), closeTo(0.98, 1e-12));

      final regularLive = SimulationMatchEngine(balance: quietBalance()).start(
        home: home,
        away: away,
        context: context(crowd: 80),
        rngSeed: 2130,
      );
      expect(regularLive.state.momentum, closeTo(10.0, 1e-12));

      final lambdaBalance = quietBalance(sequenceBase: 1.15);
      final regularEngine = SimulationMatchEngine(balance: lambdaBalance);
      final regularMatch = regularEngine.start(
        home: home,
        away: away,
        context: context(seed: 2131, stake: MatchStake.regular),
        rngSeed: 2131,
      );
      final eliminationMatch = regularEngine.start(
        home: home,
        away: away,
        context: context(seed: 2131, stake: MatchStake.playoffElimination),
        rngSeed: 2131,
      );
      final derbyMatch = regularEngine.start(
        home: home,
        away: away,
        context: context(seed: 2131, derby: true),
        rngSeed: 2131,
      );
      final regularTrace = regularEngine.simulateMinute(regularMatch);
      final eliminationTrace = regularEngine.simulateMinute(eliminationMatch);
      final derbyTrace = regularEngine.simulateMinute(derbyMatch);

      expect(
        eliminationTrace.homeSequenceLambda / regularTrace.homeSequenceLambda,
        closeTo(0.95, 1e-12),
      );
      expect(
        derbyTrace.homeSequenceLambda / regularTrace.homeSequenceLambda,
        closeTo(1.05, 1e-12),
      );
    });
  });

  group('Task 21 — doliczony czas', () {
    test(
      'stoppage ma zakres 1–8, a pierwsza połowa używa floor(stoppage/3)',
      () {
        const balance = MatchdayBalance();
        expect(
          balance.stoppageMinutes(
            goals: 0,
            cards: 0,
            injuries: 0,
            substitutions: 0,
            randomUnit: 0.0,
          ),
          1,
        );
        expect(
          balance.stoppageMinutes(
            goals: 20,
            cards: 20,
            injuries: 20,
            substitutions: 20,
            randomUnit: 1.0,
          ),
          8,
        );

        final balanceConfig = quietBalance();
        final engine = SimulationMatchEngine(balance: balanceConfig);
        final first = engine.simulateFull(
          home: home,
          away: away,
          context: context(seed: 2132),
          rngSeed: 2132,
          includeStoppageTime: true,
        );
        final second = engine.simulateFull(
          home: home,
          away: away,
          context: context(seed: 2132),
          rngSeed: 2132,
          includeStoppageTime: true,
        );

        expect(first.firstHalfStoppageTime, 0);
        expect(first.secondHalfStoppageTime, inInclusiveRange(1, 8));
        expect(first.stoppageTime, first.secondHalfStoppageTime);
        expect(first.matchEndMinute, 90 + first.secondHalfStoppageTime);
        expect(first.finalState.minute, first.matchEndMinute);
        expect(first.traceSignature, second.traceSignature);
        expect(first.matchEndMinute, second.matchEndMinute);
      },
    );
  });
}
