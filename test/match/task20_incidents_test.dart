import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/balance/injury_catalog.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/simulation/match_engine.dart';
import 'package:new_football/core/simulation/match_incident_resolver.dart';
import 'package:new_football/core/simulation/unit_ratings.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

void main() {
  final league = SeedDataGenerator().generateLeague(year: 2026, seed: 2020);
  final home = league.teams[0];
  final away = league.teams[1];
  final context = MatchContext(
    homeTeamId: home.id,
    awayTeamId: away.id,
    seed: 2020,
  );

  Player sampleOutfield() => home.startingEleven.firstWhere(
    (player) => player.position != Position.gk,
  );

  BalanceConfig incidentBalance({
    double sequenceBase = 100.0,
    double foulBase = 0.0,
    double yellowFromFoul = 0.0,
    double redDirect = 0.0,
    double injuryBase = 0.0,
  }) => BalanceConfig(
    matchday: MatchdayBalance(
      sequenceBase: sequenceBase,
      foulBase: foulBase,
      yellowFromFoul: yellowFromFoul,
      redDirect: redDirect,
      injuryBase: injuryBase,
    ),
  );

  SimulationLiveMatch startMatch(BalanceConfig balance, {int seed = 2020}) =>
      SimulationMatchEngine(balance: balance).start(
        home: home,
        away: away,
        context: context.copyWith(seed: seed),
        rngSeed: seed,
      );

  void advanceUntil(
    SimulationLiveMatch live,
    SimulationMatchEngine engine,
    bool Function() condition, {
    int maxMinute = 20,
  }) {
    while (!condition() && live.state.minute < maxMinute) {
      engine.simulateMinute(live);
    }
  }

  group('Task 20 — faule i kartki', () {
    test('foulProbability stosuje pressing, physGap, derby i cardProne', () {
      const resolver = MatchIncidentResolver();
      final defender = sampleOutfield().copyWith(
        personality: PlayerPersonality.temperamental,
      );
      final tactics = const TacticsSetup(
        pressing: PressingIntensity.gegenpressing,
      );
      final matchContext = context.copyWith(
        isDerby: true,
        refereeStrictness: 1.10,
      );

      final probability = resolver.foulProbability(
        attackerPace: 60,
        defenderPhysicality: 75,
        defender: defender,
        defendingTactics: tactics,
        context: matchContext,
      );
      final expected =
          BalanceConfig.defaults.matchday.foulBase *
          1.30 *
          (1.0 + (75 - 60) / 300.0) *
          1.35 *
          1.15 *
          1.10;

      expect(probability, closeTo(expected, 1e-12));
      expect(
        resolver.foulProbability(
          attackerPace: 60,
          defenderPhysicality: 75,
          defender: defender,
          defendingTactics: const TacticsSetup(pressing: PressingIntensity.low),
          context: context,
        ),
        lessThan(probability),
      );
      expect(
        BalanceConfig.defaults.matchday.foulPressingMultiplier(
              PressingIntensity.gegenpressing,
            ) /
            BalanceConfig.defaults.matchday.foulPressingMultiplier(
              PressingIntensity.low,
            ),
        closeTo(1.30 / 0.85, 1e-12),
      );
    });

    test('żółta, druga żółta, direct red i severity mają osobne rolle', () {
      const resolver = MatchIncidentResolver();
      final defender = sampleOutfield().copyWith(
        personality: PlayerPersonality.temperamental,
      );

      final secondYellow = resolver.rollCard(
        defender: defender,
        context: context,
        oneOnOne: false,
        existingYellowCards: 1,
        nextDouble: () => 0.0,
      );
      expect(secondYellow.yellow, isTrue);
      expect(secondYellow.secondYellow, isTrue);
      expect(secondYellow.directRed, isFalse);
      expect(secondYellow.red, isTrue);

      final directRolls = <double>[1.0, 0.0, 0.91];
      final direct = resolver.rollCard(
        defender: defender,
        context: context,
        oneOnOne: true,
        existingYellowCards: 0,
        nextDouble: () => directRolls.removeAt(0),
      );
      expect(direct.yellow, isFalse);
      expect(direct.directRed, isTrue);
      expect(
        direct.directRedProbability,
        closeTo(BalanceConfig.defaults.matchday.redDirect * 2.0, 1e-12),
      );
      expect(direct.directRedSeverity, 3);
      expect(MatchIncidentResolver.directRedSeverityFromRoll(0.59), 1);
      expect(MatchIncidentResolver.directRedSeverityFromRoll(0.60), 2);
      expect(MatchIncidentResolver.directRedSeverityFromRoll(0.90), 3);
    });

    test('MatchEventType.foul zachowuje się w JSON mapowaniu zdarzenia', () {
      const event = MatchEvent(
        type: MatchEventType.foul,
        minute: 17,
        teamId: 'team-a',
        playerId: 'player-a',
        description: 'Faul testowy',
      );

      final decoded = MatchEvent.fromJson(event.toJson());
      expect(decoded.type, MatchEventType.foul);
      expect(decoded.minute, 17);
      expect(decoded.playerId, 'player-a');
    });
  });

  group('Task 20 — kontuzje', () {
    test(
      'formuła kontuzji uwzględnia injuryProne, stamina, intensity, weather i duel',
      () {
        const resolver = MatchIncidentResolver();
        final player = sampleOutfield().copyWith(
          personality: PlayerPersonality.professional,
          hidden: sampleOutfield().hidden.copyWith(injuryProne: 10),
        );
        final lowProne = player.copyWith(
          hidden: player.hidden.copyWith(injuryProne: 1),
        );
        const tactics = TacticsSetup(
          tempo: Tempo.fast,
          pressing: PressingIntensity.gegenpressing,
        );
        final matchContext = context.copyWith(weather: Weather.snow);
        final noDuel = resolver.injuryProbability(
          player: player,
          stamina: 40,
          tactics: tactics,
          context: matchContext,
          duelInvolved: false,
        );
        final duel = resolver.injuryProbability(
          player: player,
          stamina: 40,
          tactics: tactics,
          context: matchContext,
          duelInvolved: true,
        );
        final lowProneProbability = resolver.injuryProbability(
          player: lowProne,
          stamina: 40,
          tactics: tactics,
          context: matchContext,
          duelInvolved: false,
        );
        final balance = BalanceConfig.defaults;
        final expected =
            balance.matchday.injuryBase *
            balance.matchday.injuryProneMultiplier(10) *
            balance.player.injuryRiskMult(40) *
            1.05 *
            1.05 *
            balance.matchday.injuryProfessional *
            (1.15 * 1.20) *
            balance.matchday.weatherInjuryMultiplier(Weather.snow);

        expect(noDuel, closeTo(expected, 1e-12));
        expect(duel / noDuel, closeTo(2.5, 1e-12));
        expect(noDuel / lowProneProbability, closeTo(4.0, 1e-12));
        expect(balance.matchday.injuryProneMultiplier(1), closeTo(0.50, 1e-12));
        expect(
          balance.matchday.injuryProneMultiplier(10),
          closeTo(2.00, 1e-12),
        );
      },
    );

    test('rollInjury korzysta z katalogu Task 10 i callbacków jednego RNG', () {
      const resolver = MatchIncidentResolver();
      final player = sampleOutfield();
      final rolls = <double>[0.0, 0.0];
      final decision = resolver.rollInjury(
        player: player,
        stamina: 100,
        tactics: const TacticsSetup(),
        context: context,
        duelInvolved: false,
        nextDouble: () => rolls.removeAt(0),
        nextInt: (_) => 0,
      );

      expect(decision.occurred, isTrue);
      expect(decision.diagnosis, isNotNull);
      expect(decision.injury, isNotNull);
      expect(
        InjuryCatalog.definitions.map((definition) => definition.id),
        contains(decision.injury!.id),
      );
      expect(decision.injury!.daysRemaining, greaterThanOrEqualTo(0));
    });
  });

  group('Task 20 — osłabienie', () {
    test('ratingi jednostek i stamina stosują mnożniki dla 10 i 9 graczy', () {
      final engine = SimulationMatchEngine();
      final live = engine.start(
        home: home,
        away: away,
        context: context,
        rngSeed: 2021,
      );
      final lineup = List<Player>.from(live.state.homeLineup);
      final attributes = live.homeEffectiveAttributes;
      final shape = live.homeTeamShape!;
      final assignments = live.homeAssignedPositions;
      const calculator = UnitRatingCalculator();
      final full = calculator.calculate(
        lineup: lineup,
        effectiveAttributes: attributes,
        shape: shape,
        assignedPositions: assignments,
        applyShortHanded: true,
      );
      final goalkeeper = lineup.firstWhere(
        (player) => player.position == Position.gk,
      );
      final tenLineup = lineup
          .where((player) => player.id != goalkeeper.id)
          .toList(growable: false);
      final ten = calculator.calculate(
        lineup: tenLineup,
        effectiveAttributes: attributes,
        shape: shape,
        assignedPositions: assignments,
        applyShortHanded: true,
      );
      final defensivePositions = {
        Position.cb,
        Position.lb,
        Position.rb,
        Position.lwb,
        Position.rwb,
        Position.cdm,
      };
      final attackingPositions = {
        Position.st,
        Position.lw,
        Position.rw,
        Position.cam,
      };
      final defensivePlayer = tenLineup.firstWhere(
        (player) => defensivePositions.contains(
          assignments[player.id] ?? player.position,
        ),
      );
      final attackingPlayer = tenLineup.firstWhere(
        (player) => attackingPositions.contains(
          assignments[player.id] ?? player.position,
        ),
      );
      final nineForAttack = tenLineup
          .where((player) => player.id != defensivePlayer.id)
          .toList(growable: false);
      final nineForDefense = tenLineup
          .where((player) => player.id != attackingPlayer.id)
          .toList(growable: false);
      final nineAttack = calculator.calculate(
        lineup: nineForAttack,
        effectiveAttributes: attributes,
        shape: shape,
        assignedPositions: assignments,
        applyShortHanded: true,
      );
      final nineDefense = calculator.calculate(
        lineup: nineForDefense,
        effectiveAttributes: attributes,
        shape: shape,
        assignedPositions: assignments,
        applyShortHanded: true,
      );

      expect(full.defRating, greaterThan(0));
      expect(full.atkRating, greaterThan(0));
      expect(ten.defRating, closeTo(full.defRating * 0.92, 1e-9));
      expect(ten.atkRating, closeTo(full.atkRating * 0.86, 1e-9));
      expect(nineDefense.defRating, closeTo(full.defRating * 0.80, 1e-9));
      expect(nineAttack.atkRating, closeTo(full.atkRating * 0.70, 1e-9));

      double staminaLoss({required int players, required int seed}) {
        final match = engine.start(
          home: home,
          away: away,
          context: context,
          rngSeed: seed,
        );
        final target = match.state.homeLineup.firstWhere(
          (player) => player.position != Position.gk,
        );
        final fullLineup = List<Player>.from(match.state.homeLineup);
        final reduced = fullLineup
            .where((player) => player.position != Position.gk)
            .take(players == 10 ? 10 : 9)
            .toList(growable: false);
        final measuredLineup = players == 11 ? fullLineup : reduced;
        final before = match.legacyMatch.staminaRemaining[target.id]!;
        match.legacyMatch.recordMinute(
          lineup: measuredLineup,
          homeSide: true,
          applyShortHanded: true,
        );
        return before - match.legacyMatch.staminaRemaining[target.id]!;
      }

      final fullLoss = staminaLoss(players: 11, seed: 2022);
      final tenLoss = staminaLoss(players: 10, seed: 2022);
      final nineLoss = staminaLoss(players: 9, seed: 2022);
      expect(tenLoss / fullLoss, closeTo(1.12, 1e-9));
      expect(nineLoss / fullLoss, closeTo(1.20, 1e-9));
    });
  });

  group('Task 20 — runtime incydentów i rekonfiguracja', () {
    test('faul aktualizuje event, MatchDiscipline i TeamMatchStats.fouls', () {
      final balance = incidentBalance(foulBase: 10.0, yellowFromFoul: 1.0);
      final engine = SimulationMatchEngine(balance: balance);
      final live = startMatch(balance, seed: 2023);
      advanceUntil(
        live,
        engine,
        () => live.events.any((event) => event.type == MatchEventType.foul),
      );

      final result = live.toResult();
      expect(
        live.events.where((event) => event.type == MatchEventType.foul),
        isNotEmpty,
      );
      expect(live.homeFouls + live.awayFouls, greaterThan(0));
      expect(live.disciplines, isNotEmpty);
      expect(
        live.disciplines.any((discipline) => discipline.yellowCardsInMatch > 0),
        isTrue,
      );
      expect(result.homeStats.fouls, live.homeFouls);
      expect(result.awayStats.fouls, live.awayFouls);
      expect(
        result.homeStats.yellowCards + result.awayStats.yellowCards,
        greaterThan(0),
      );
    });

    test('kontuzja generuje MatchInjury/event i wymusza zmianę z ławki', () {
      final balance = incidentBalance(injuryBase: 1.0);
      final engine = SimulationMatchEngine(balance: balance);
      final live = startMatch(balance, seed: 2024);
      engine.simulateMinute(live);

      expect(live.injuries, isNotEmpty);
      expect(
        live.events.where(
          (event) =>
              event.type == MatchEventType.minorInjury ||
              event.type == MatchEventType.majorInjury,
        ),
        isNotEmpty,
      );
      expect(
        InjuryCatalog.definitions.map((definition) => definition.id),
        contains(live.injuries.first.injury.id),
      );
      expect(
        live.events.where((event) => event.type == MatchEventType.substitution),
        isNotEmpty,
      );
    });

    test(
      'direct red usuwa zawodnika, zapisuje severity i rekonfiguruje XI',
      () {
        final balance = incidentBalance(foulBase: 10.0, redDirect: 10.0);
        final engine = SimulationMatchEngine(balance: balance);
        final live = startMatch(balance, seed: 2025);
        advanceUntil(
          live,
          engine,
          () =>
              live.events.any((event) => event.type == MatchEventType.redCard),
        );

        final redEvent = live.events.firstWhere(
          (event) => event.type == MatchEventType.redCard,
        );
        final redPlayerId = redEvent.playerId!;
        final discipline = live.disciplines.firstWhere(
          (item) => item.playerId == redPlayerId,
        );
        final isHome = redEvent.teamId == live.homeTeamId;
        final lineup = isHome ? live.state.homeLineup : live.state.awayLineup;
        final assignments = isHome
            ? live.homeAssignedPositions
            : live.awayAssignedPositions;

        expect(discipline.redCardKind, RedCardKind.direct);
        expect(discipline.directRedSeverity, inInclusiveRange(1, 3));
        expect(live.state.sentOffPlayerIds, contains(redPlayerId));
        expect(lineup.map((player) => player.id), isNot(contains(redPlayerId)));
        expect(
          assignments.keys,
          containsAll(lineup.map((player) => player.id)),
        );
        expect(assignments, isNot(contains(redPlayerId)));
        expect(isHome ? live.homeUnitRatings : live.awayUnitRatings, isNotNull);
      },
    );

    test(
      'wymuszona zmiana i brak ławki usuwają kontuzjowanego oraz synchronizują GK',
      () {
        final engine = SimulationMatchEngine();
        final live = engine.start(
          home: home,
          away: away,
          context: context,
          rngSeed: 2026,
        );
        final outgoing = live.state.homeLineup.firstWhere(
          (player) => player.position != Position.gk,
        );
        final incoming = live.state.homeBench.firstWhere(
          (player) => player.position != Position.gk,
        );
        expect(
          engine.applyInjurySubstitution(
            live: live,
            homeSide: true,
            playerOutId: outgoing.id,
            playerInId: incoming.id,
            injuryType: InjuryType.minor,
          ),
          isTrue,
        );
        expect(live.state.homeLineup, contains(incoming));
        expect(live.state.homeLineup, isNot(contains(outgoing)));
        expect(live.homeUnreplacedInjuryIds, isEmpty);

        final noBench = engine.start(
          home: home,
          away: away,
          context: context.copyWith(seed: 2027),
          rngSeed: 2027,
        );
        final goalkeeper = noBench.state.homeLineup.firstWhere(
          (player) => player.position == Position.gk,
        );
        noBench.legacyMatch.state = noBench.state.copyWith(homeBench: const []);
        expect(
          engine.applyInjurySubstitution(
            live: noBench,
            homeSide: true,
            playerOutId: goalkeeper.id,
            injuryType: InjuryType.major,
          ),
          isFalse,
        );
        expect(noBench.homeUnreplacedInjuryIds, contains(goalkeeper.id));
        expect(noBench.state.homeLineup, isNot(contains(goalkeeper)));
        expect(noBench.homeNoGkPenalty, isTrue);
        expect(noBench.legacyMatch.homeNoGkPenalty, isTrue);
        expect(noBench.toResult().homeNoGkPenalty, isTrue);
      },
    );
  });
}
