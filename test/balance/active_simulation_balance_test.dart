import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/balance/rivalry_catalog.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/random/match_random.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/season_service.dart';
import 'package:new_football/core/simulation/duel_resolver.dart';
import 'package:new_football/core/simulation/effective_attributes.dart';
import 'package:new_football/core/simulation/goalkeeper_resolver.dart';
import 'package:new_football/core/simulation/match_context_effects.dart';
import 'package:new_football/core/simulation/match_context_factory.dart';
import 'package:new_football/core/simulation/match_engine.dart';
import 'package:new_football/core/simulation/sequence_chain_resolver.dart';
import 'package:new_football/core/simulation/sequence_resolver.dart';
import 'package:new_football/core/simulation/set_piece_resolver.dart';
import 'package:new_football/core/simulation/shot_models.dart';
import 'package:new_football/core/simulation/shot_resolver.dart';
import 'package:new_football/core/simulation/team_shape.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

void main() {
  final league = SeedDataGenerator().generateLeague(seed: 42);
  final home = league.teams.first;
  final away = league.teams[1];
  final outfield = home.roster.firstWhere((p) => p.position != Position.gk);
  const quiet = BalanceConfig(
    matchday: MatchdayBalance(sequenceBase: 0, injuryBase: 0),
  );

  test(
    'catalog contains exactly the approved 23 pairs and resolves both orders',
    () {
      const expected = {
        'team_europe_0|team_europe_8',
        'team_europe_10|team_europe_9',
        'team_europe_11|team_europe_3',
        'team_europe_11|team_europe_4',
        'team_europe_12|team_europe_13',
        'team_europe_12|team_europe_14',
        'team_europe_13|team_europe_14',
        'team_europe_1|team_europe_2',
        'team_europe_3|team_europe_4',
        'team_europe_5|team_europe_6',
        'team_europe_5|team_europe_7',
        'team_europe_6|team_europe_7',
        'team_restOfTheWorld_15|team_restOfTheWorld_16',
        'team_restOfTheWorld_15|team_restOfTheWorld_17',
        'team_restOfTheWorld_16|team_restOfTheWorld_17',
        'team_restOfTheWorld_18|team_restOfTheWorld_23',
        'team_restOfTheWorld_19|team_restOfTheWorld_22',
        'team_restOfTheWorld_20|team_restOfTheWorld_21',
        'team_restOfTheWorld_21|team_restOfTheWorld_26',
        'team_restOfTheWorld_24|team_restOfTheWorld_25',
        'team_restOfTheWorld_27|team_restOfTheWorld_28',
        'team_restOfTheWorld_27|team_restOfTheWorld_29',
        'team_restOfTheWorld_28|team_restOfTheWorld_29',
      };
      expect(rivalryCatalog, expected);
      const factory = MatchContextFactory();
      for (final key in expected) {
        final ids = key.split('|');
        final first = league.teamById(ids.first)!;
        final second = league.teamById(ids.last)!;
        expect(factory.isDerby(first, second), isTrue, reason: key);
        expect(factory.isDerby(second, first), isTrue, reason: key);
      }
      expect(factory.isDerby(home, home), isFalse);
      expect(factory.isDerby(home, away), isFalse);
      expect(factory.isDerby(home, league.teams[2]), isFalse);
      expect(
        const MatchContextFactory(
          rivalryKeys: {},
        ).isDerby(home, league.teams[8]),
        isFalse,
      );
    },
  );

  test(
    'configured cross-conference derby reaches factories, orchestrators and provider',
    () {
      final cross = league.teams.firstWhere(
        (t) => t.conference != home.conference,
      );
      final key = MatchContextFactory.rivalryKey(home.id, cross.id);
      final balance = BalanceConfig(
        matchday: MatchdayBalance(rivalryKeys: {key}),
      );
      final factory = MatchContextFactory(balance: balance);
      final context = factory.createForTeams(
        home: home,
        away: cross,
        seasonYear: 2026,
        matchId: 'cross',
        saveSeed: 42,
      );
      expect(context.isDerby, isTrue);
      expect(factory.isDerby(cross, home), isTrue);
      expect(
        DaySimulator(balance: balance).contextFactory.isDerby(home, cross),
        isTrue,
      );
      expect(
        SeasonService(balance: balance).contextFactory.isDerby(home, cross),
        isTrue,
      );
      final container = ProviderContainer(
        overrides: [balanceProvider.overrideWithValue(balance)],
      );
      addTearDown(container.dispose);
      expect(
        container.read(matchContextFactoryProvider).isDerby(home, cross),
        isTrue,
      );
      final plain = const MatchContextFactory(rivalryKeys: {}).createForTeams(
        home: home,
        away: cross,
        seasonYear: 2026,
        matchId: 'cross',
        saveSeed: 42,
      );
      expect(context.crowdIntensity, plain.crowdIntensity + 20);
      expect(context.weather, plain.weather);
      expect(context.temperatureC, plain.temperatureC);
      expect(context.refereeStrictness, plain.refereeStrictness);
    },
  );

  test(
    'weather, temperature, referee, crowd and home advantage use configured context',
    () {
      const balance = BalanceConfig(
        matchday: MatchdayBalance(
          rivalryKeys: {},
          weatherBaseWeights: {Weather.snow: 1},
          weatherSeasons: [],
          temperatureMin: -10,
          temperatureMax: 0,
          temperatureRandomRange: 1,
          refereeRandomMin: 1.4,
          refereeRandomSpan: 0,
          refereeMin: 1,
          refereeMax: 2,
          crowdBase: 17,
          crowdFormWeight: 0,
          stakeCrowdBonuses: {MatchStake.leagueFinal: 10},
          homeAdvantage: 0.2,
          crowdInitialMomentumDivisor: 3,
        ),
      );
      const factory = MatchContextFactory(balance: balance);
      final context = factory.createForTeams(
        home: home,
        away: away,
        seasonYear: 2026,
        matchId: 'weather',
        saveSeed: 42,
        stake: MatchStake.leagueFinal,
      );
      expect(factory.calendar.balance, same(balance));
      expect(context.weather, Weather.snow);
      expect(context.temperatureC, -10);
      expect(context.refereeStrictness, 1.4);
      expect(context.crowdIntensity, 27);
      expect(context.homeAdvantage, 0.2);
      final engine = SimulationMatchEngine(balance: balance);
      expect(
        engine.start(home: home, away: away).state.context.homeAdvantage,
        0.2,
      );
      expect(
        engine.start(home: home, away: away, context: context).state.momentum,
        9,
      );
      expect(
        engine
            .start(
              home: home,
              away: away,
              context: const MatchContext(homeAdvantage: 0.03),
            )
            .state
            .context
            .homeAdvantage,
        0.03,
      );
    },
  );

  test(
    'seasonal profile adjusts weights and temperature without changing draw order',
    () {
      const balance = BalanceConfig(
        matchday: MatchdayBalance(
          weatherBaseWeights: {Weather.clear: 1, Weather.snow: 1},
          temperatureMin: -10,
          temperatureMax: 30,
          temperatureRandomRange: 1,
          weatherSeasons: [
            WeatherSeasonProfile(
              firstWeek: 2,
              lastWeek: 2,
              temperatureBias: 7,
              deltas: {Weather.clear: -1},
              minimums: {Weather.clear: 0},
            ),
          ],
        ),
      );
      const factory = MatchContextFactory(balance: balance);
      final context = factory.createForTeams(
        home: home,
        away: away,
        seasonYear: 2026,
        matchId: 'season',
        saveSeed: 42,
        week: 2,
      );
      final outside = factory.createForTeams(
        home: home,
        away: away,
        seasonYear: 2026,
        matchId: 'season',
        saveSeed: 42,
        week: 3,
      );
      expect(context.weather, Weather.snow);
      expect(context.temperatureC, -3);
      expect(outside.temperatureC, -10);
      expect(context.refereeStrictness, outside.refereeStrictness);
    },
  );

  test(
    'SFG uses five attackers, four outfield defenders and one GK in real shot quality',
    () {
      const configured = MatchdayBalance(
        aerialBase: 180,
        aerialSlope: 1,
        aerialClampMin: 0,
        aerialClampMax: 300,
        aerialEdgeClamp: 100,
      );
      final attack = [
        for (var i = 0; i < 5; i++)
          outfield.copyWith(id: 'attack$i', heightCm: i == 4 ? 150 : 190),
      ];
      final gk = away.roster
          .firstWhere((p) => p.position == Position.gk)
          .copyWith(id: 'gk', heightCm: 180);
      final defense = [
        gk,
        for (var i = 0; i < 4; i++)
          outfield.copyWith(id: 'defense$i', heightCm: i == 3 ? 200 : 180),
      ];
      SetPieceResolution run(
        BalanceConfig balance, {
        bool incomplete = false,
      }) => SetPieceResolver(balance: balance).resolve(
        type: SetPieceType.corner,
        attackingLineup: incomplete ? [attack.first] : attack,
        defendingLineup: incomplete ? [gk] : defense,
        attackingAttributes: {},
        defendingAttributes: {},
        attackingTactics: const TacticsSetup(),
        context: const MatchContext(),
        random: MatchRandom(42),
      );
      final actual = run(const BalanceConfig(matchday: configured));
      expect(actual.aerialEdge, -2);
      expect(BalanceConfig.defaults.player.tallestOutfieldSampleSize, 5);
      expect(
        home.averageTallestOutfieldHeightCm(
          onPitch: [...attack, gk.copyWith(heightCm: 300)],
        ),
        182,
      );
      expect(
        run(
          const BalanceConfig(matchday: configured),
          incomplete: true,
        ).aerialEdge,
        10,
      );
      const previous = BalanceConfig(
        matchday: MatchdayBalance(
          aerialBase: 180,
          aerialSlope: 1,
          aerialClampMin: 0,
          aerialClampMax: 300,
          aerialEdgeClamp: 100,
          sfgAttackingPlayers: 4,
          sfgDefendingOutfieldPlayers: 3,
        ),
      );
      final old = run(previous);
      expect(old.aerialEdge, 5);
      expect(actual.shot.xg, lessThan(old.shot.xg));
    },
  );

  test(
    'logistic base changes the contest while preserving RNG consumption',
    () {
      const balance = BalanceConfig(
        matchday: MatchdayBalance(
          duelSigma: 0,
          duelDispersion: 10,
          duelLogisticBase: 2,
        ),
      );
      final random = MatchRandom(42);
      final actual = const DuelResolver(
        balance: balance,
      ).contest(attackerRating: 80, defenderRating: 70, random: random);
      final reference = MatchRandom(42);
      const DuelResolver(
        balance: BalanceConfig(
          matchday: MatchdayBalance(duelSigma: 0, duelDispersion: 10),
        ),
      ).contest(attackerRating: 80, defenderRating: 70, random: reference);
      expect(actual.attackerProbability, closeTo(2 / 3, 1e-12));
      expect(random.cursor, reference.cursor);
    },
  );

  test(
    'role, matchup, synergy and staff shape tables reach the calculator',
    () {
      final player = outfield.copyWith(
        state: outfield.state.copyWith(role: const AssignedRole.cm()),
      );
      const tactics = TacticsBalance(
        roleShapeDeltas: {CmRole.standard: ShapeDelta(mid: 20)},
        formationShapeMatchups: [],
        familyShapeMatchups: [],
        settingMatchupDeltas: {'deepVsFast': ShapeDelta(def: 7)},
        roleSynergyDeltas: {},
      );
      const balance = BalanceConfig(
        tactics: tactics,
        staff: StaffBalance(missingHeadCoachShapeBoost: -2),
      );
      const ours = TacticsSetup(defensiveLine: DefensiveLine.deep);
      const theirs = TacticsSetup(tempo: Tempo.fast);
      final withRole = const TeamShapeCalculator(
        balance: balance,
      ).calculate(tactics: ours, opponentTactics: theirs, lineup: [player]);
      final withoutRole = const TeamShapeCalculator(
        balance: balance,
      ).calculate(tactics: ours, opponentTactics: theirs);
      expect(withRole.mid - withoutRole.mid, 20);
      final withoutSynergy = const TeamShapeCalculator(
        balance: BalanceConfig(
          tactics: TacticsBalance(
            roleShapeDeltas: {},
            formationShapeMatchups: [],
            familyShapeMatchups: [],
            settingMatchupDeltas: {},
            roleSynergyDeltas: {},
          ),
          staff: StaffBalance(missingHeadCoachShapeBoost: -2),
        ),
      ).calculate(tactics: ours, opponentTactics: theirs);
      expect(withoutRole.def - withoutSynergy.def, 7);
      expect(
        TeamShapeCalculator.headCoachTacticsBoost(null, balance.staff),
        -2,
      );
    },
  );

  test(
    'effective bounds, mismatch and unit weights affect active runtime attributes',
    () {
      const balance = BalanceConfig(
        matchday: MatchdayBalance(
          roleFitBonus: 100,
          unitDefDefendingWeight: 0,
          unitDefPhysicalityWeight: 0,
          unitDefPaceWeight: 0,
          unitDefPassingWeight: 0,
        ),
      );
      final team = home.copyWith(
        roster: [
          for (final p in home.roster)
            p.copyWith(state: p.state.copyWith(role: p.optimalRole)),
        ],
      );
      final live = SimulationMatchEngine(
        balance: balance,
      ).start(home: team, away: away);
      expect(live.homeUnitRatings!.defRating, 0);
      for (final values in live.homeEffectiveAttributes.values) {
        expect(
          values.values.values,
          everyElement(inInclusiveRange(30.0, 120.0)),
        );
      }
      expect(
        live.homeEffectiveAttributes.values.any(
          (p) => p.values.values.contains(120.0),
        ),
        isTrue,
      );
      expect(
        EffectiveAttributeCalculator.positionMultiplier(
          outfield,
          assignedPosition: Position.gk,
          balance: const BalanceConfig(
            matchday: MatchdayBalance(roleMismatchMultiplier: 0.4),
          ),
        ),
        0.4,
      );
    },
  );

  SequenceContext sequenceContext(SimulationLiveMatch live) => SequenceContext(
    attackingTactics: live.state.homeTactics,
    defendingTactics: live.state.awayTactics,
    attackingLineup: live.state.homeLineup,
    defendingLineup: live.state.awayLineup,
    attackingEffectiveAttributes: live.homeEffectiveAttributes,
    defendingEffectiveAttributes: live.awayEffectiveAttributes,
    attackingRatings: live.homeUnitRatings!,
    defendingRatings: live.awayUnitRatings!,
    weather: Weather.clear,
    attackingAssignedPositions: live.homeAssignedPositions,
    defendingAssignedPositions: live.awayAssignedPositions,
  );

  test(
    'sequence selection and stage profiles use independent configured weights',
    () {
      const stage = SequenceStageProfile(
        attackerPositions: {Position.cm},
        defenderPositions: {Position.cb},
        attackerWeights: {EffectiveAttribute.passing: 1},
        defenderWeights: {EffectiveAttribute.pace: 1},
      );
      const balance = BalanceConfig(
        matchday: MatchdayBalance(
          sequenceConditionBonus: 0,
          sequenceStrongConditionBonus: 0,
          sequenceTypeBaseWeights: {
            'centralBuildUp': 1,
            'wingPlay': 0,
            'crossFromWide': 0,
            'throughBall': 0,
            'individualDribble': 0,
            'counterAttack': 0,
            'longBall': 0,
            'setPiece': 0,
          },
          sequenceAttackerProfiles: {
            SequenceType.centralBuildUp: {EffectiveAttribute.shooting: 1},
          },
          sequenceDefenderProfiles: {
            SequenceType.centralBuildUp: {EffectiveAttribute.defending: 1},
          },
          sequenceStages: {
            SequenceType.centralBuildUp: [stage],
          },
        ),
      );
      final live = SimulationMatchEngine(
        balance: balance,
      ).start(home: home, away: away);
      final context = sequenceContext(live);
      final selection = const SequenceSelector(
        balance: balance,
      ).select(context: context, random: MatchRandom(42));
      expect(selection.type, SequenceType.centralBuildUp);
      expect(selection.attackerAttributeWeights, {
        EffectiveAttribute.shooting: 1,
      });
      final chain = const SequenceChainResolver(balance: balance).resolve(
        selection: selection,
        context: context,
        random: MatchRandom(42),
      );
      expect(chain.duels, hasLength(1));
      expect(chain.duels.single.attackerWeights, {
        EffectiveAttribute.passing: 1,
      });
      expect(chain.duels.single.defenderWeights, {EffectiveAttribute.pace: 1});
    },
  );

  test('sequence unit thresholds change the real type weights', () {
    final live = SimulationMatchEngine(
      balance: quiet,
    ).start(home: home, away: away);
    final context = sequenceContext(live);
    const high = SequenceSelector(
      balance: BalanceConfig(
        matchday: MatchdayBalance(sequenceHighUnitThreshold: 0),
      ),
    );
    const low = SequenceSelector(
      balance: BalanceConfig(
        matchday: MatchdayBalance(sequenceHighUnitThreshold: 1000),
      ),
    );
    expect(
      high.weightsFor(context)[SequenceType.centralBuildUp]! -
          low.weightsFor(context)[SequenceType.centralBuildUp]!,
      4,
    );
  });

  test(
    'high-line through-ball stage reads the configured defender profile',
    () {
      const balance = BalanceConfig(
        matchday: MatchdayBalance(
          throughBallHighLineDefenderWeights: {EffectiveAttribute.defending: 1},
        ),
      );
      final live = SimulationMatchEngine(balance: balance).start(
        home: home,
        away: away.copyWith(
          tactics: away.tactics.copyWith(defensiveLine: DefensiveLine.high),
        ),
      );
      final context = sequenceContext(live);
      final selection = SequenceSelection(
        type: SequenceType.throughBall,
        attacker: live.state.homeLineup.first,
        defender: live.state.awayLineup.first,
        attackerWeight: 1,
        defenderWeight: 1,
        attackerAttributeWeights: {},
        defenderAttributeWeights: {},
      );
      final chain = const SequenceChainResolver(balance: balance).resolve(
        selection: selection,
        context: context,
        random: MatchRandom(42),
      );
      expect(chain.duels, hasLength(2));
      expect(chain.duels[1].defenderWeights, {EffectiveAttribute.defending: 1});
    },
  );

  test('shot and fallback goalkeeper limits read their configured owners', () {
    const balance = BalanceConfig(
      matchday: MatchdayBalance(
        shotXgMin: 0.1,
        shotXgMax: 0.1,
        goalProbabilityMin: 0.2,
        goalProbabilityMax: 0.2,
        fallbackGkPhysicalityWeight: 1,
        fallbackGkSpeedWeight: 0,
        fallbackGkDefendingWeight: 0,
        noGkRatingMultiplier: 1,
      ),
    );
    final defense = away.startingEleven
        .where((p) => p.position != Position.gk)
        .toList();
    final goalkeeper = const GoalkeeperResolver(balance: balance).resolve(
      shotKind: SequenceShotKind.box,
      defendingLineup: defense,
      effectiveAttributes: {},
      weather: Weather.clear,
    );
    final highestPhysicality = defense
        .map(
          (p) => p.attributes.map(
            outfield: (a) => a.stats.physicality.toDouble(),
            goalkeeper: (_) => 0.0,
          ),
        )
        .reduce(math.max);
    expect(goalkeeper.gkRating, highestPhysicality);
    final shot = const ShotResolver(balance: balance).resolve(
      sequenceType: SequenceType.centralBuildUp,
      shotKind: SequenceShotKind.box,
      shooter: outfield,
      defendingLineup: defense,
      context: const MatchContext(),
      random: MatchRandom(42),
      useSequenceGate: false,
      allowRebound: false,
    );
    expect(shot.xg, 0.1);
    expect(shot.goalProbability, 0.2);
  });

  test(
    'rating base, clean-sheet eligibility and unrated appearances remain separate',
    () {
      const balance = BalanceConfig(
        matchday: MatchdayBalance(
          sequenceBase: 0,
          injuryBase: 0,
          ratingBase: 8,
          ratingUnrated: 5,
          ratingCleanSheet: 0,
          cleanSheetMinutes: 91,
        ),
      );
      final engine = SimulationMatchEngine(balance: balance);
      final live = engine.start(home: home, away: away);
      engine.runUntil(live, 90);
      final result = engine.toMatchResult(live: live, home: home, away: away);
      expect(
        result.playerStats.where((p) => p.minutes == 90).map((p) => p.rating),
        everyElement(8),
      );
      expect(
        result.playerStats.where((p) => p.minutes == 0).map((p) => p.rating),
        everyElement(5),
      );
      expect(result.playerStats.every((p) => !p.cleanSheet), isTrue);
    },
  );

  test('momentum cutoff and score reaction minute affect the active match', () {
    const balance = BalanceConfig(
      matchday: MatchdayBalance(
        sequenceBase: 0,
        injuryBase: 0,
        momentumCutoff: 1,
        scoreReactionMinute: 10,
      ),
    );
    final engine = SimulationMatchEngine(balance: balance);
    final live = engine.start(
      home: home,
      away: away,
      context: const MatchContext(crowdIntensity: 4),
    );
    expect(live.state.momentum, 0.5);
    engine.simulateMinute(live);
    expect(live.state.momentum, 0);
    expect(
      ScoreStateModifiers.forTeam(
        minute: 9,
        homeGoals: 0,
        awayGoals: 1,
        homeSide: true,
        balance: balance.matchday,
      ).automatic,
      isFalse,
    );
    expect(
      ScoreStateModifiers.forTeam(
        minute: 10,
        homeGoals: 0,
        awayGoals: 1,
        homeSide: true,
        balance: balance.matchday,
      ).automatic,
      isTrue,
    );
    final unchanged = SimulationMatchEngine(balance: quiet).start(
      home: home,
      away: away,
      context: const MatchContext(crowdIntensity: 4),
    );
    SimulationMatchEngine(balance: quiet).simulateMinute(unchanged);
    expect(unchanged.state.momentum, 0.48);
  });
}
