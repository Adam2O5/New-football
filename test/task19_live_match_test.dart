import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/simulation/match_engine.dart';
import 'package:new_football/core/simulation/unit_ratings.dart';

void main() {
  final league = SeedDataGenerator().generateLeague(year: 2026, seed: 1919);
  final home = league.teams[0];
  final away = league.teams[1];

  SimulationLiveMatch startMatch() => const SimulationMatchEngine().start(
    home: home,
    away: away,
    rngSeed: 1919,
  );

  void setMinute(SimulationLiveMatch live, int minute) {
    live.legacyMatch.state = live.state.copyWith(minute: minute);
  }

  double unitRatingForPosition(UnitRatings ratings, Position position) {
    if ({
      Position.cb,
      Position.lb,
      Position.rb,
      Position.lwb,
      Position.rwb,
      Position.cdm,
    }.contains(position)) {
      return ratings.defRating;
    }
    if ({
      Position.cm,
      Position.cam,
      Position.lw,
      Position.rw,
    }.contains(position)) {
      return ratings.midRating;
    }
    return ratings.atkRating;
  }

  test(
    'substitute keeps current stamina, slot position and does not roll RNG',
    () {
      final engine = const SimulationMatchEngine();
      final live = startMatch();
      final outgoing = live.state.homeLineup.firstWhere(
        (player) => player.position != Position.gk,
      );
      final incoming = live.state.homeBench.firstWhere(
        (player) => player.position != Position.gk,
      );
      final slot = live.homeAssignedPositions[outgoing.id]!;
      live.legacyMatch.staminaRemaining[incoming.id] = 37;
      final cursorBefore = live.random.cursor;

      expect(
        engine.applySubstitution(
          live: live,
          homeSide: true,
          playerOutId: outgoing.id,
          playerInId: incoming.id,
          atHalfTime: false,
        ),
        isTrue,
      );

      expect(live.random.cursor, cursorBefore);
      expect(live.homeSubsUsed, 1);
      expect(live.homeSubWindows, 1);
      expect(live.homeAssignedPositions[incoming.id], slot);
      expect(live.homeAssignedPositions, isNot(contains(outgoing.id)));
      expect(live.legacyMatch.staminaRemaining[incoming.id], 37);
      expect(live.homeEffectiveAttributes, contains(incoming.id));
      expect(live.homeUnitRatings!.defensivePlayerIds, contains(incoming.id));

      engine.simulateMinute(live);
      expect(live.legacyMatch.staminaRemaining[incoming.id], lessThan(37));
      expect(
        live.homeEffectiveAttributes[incoming.id]!.multipliers.staminaMult,
        lessThan(1.0),
      );
    },
  );

  test(
    'five substitutions and three windows are enforced, with one window per stoppage',
    () {
      final engine = const SimulationMatchEngine();
      final live = startMatch();
      final outgoingIds = live.state.homeLineup
          .take(5)
          .map((player) => player.id)
          .toList(growable: false);
      final incomingIds = live.state.homeBench
          .take(6)
          .map((player) => player.id)
          .toList(growable: false);

      expect(
        engine.applySubstitution(
          live: live,
          homeSide: true,
          playerOutId: outgoingIds[0],
          playerInId: incomingIds[0],
          atHalfTime: false,
          windowId: 'stoppage-a',
        ),
        isTrue,
      );
      expect(
        engine.applySubstitution(
          live: live,
          homeSide: true,
          playerOutId: outgoingIds[1],
          playerInId: incomingIds[1],
          atHalfTime: false,
          windowId: 'stoppage-a',
        ),
        isTrue,
      );
      expect(live.homeSubWindows, 1);

      expect(
        engine.applySubstitution(
          live: live,
          homeSide: true,
          playerOutId: outgoingIds[2],
          playerInId: incomingIds[2],
          atHalfTime: false,
          windowId: 'stoppage-b',
        ),
        isTrue,
      );
      expect(
        engine.applySubstitution(
          live: live,
          homeSide: true,
          playerOutId: outgoingIds[3],
          playerInId: incomingIds[3],
          atHalfTime: false,
          windowId: 'stoppage-c',
        ),
        isTrue,
      );
      expect(live.homeSubWindows, 3);
      expect(
        engine.applySubstitution(
          live: live,
          homeSide: true,
          playerOutId: outgoingIds[4],
          playerInId: incomingIds[4],
          atHalfTime: false,
          windowId: 'stoppage-d',
        ),
        isFalse,
      );

      final maxed = startMatch();
      final maxOut = maxed.state.homeLineup.take(6).toList(growable: false);
      final maxIn = maxed.state.homeBench.take(6).toList(growable: false);
      for (var index = 0; index < 5; index++) {
        expect(
          engine.applySubstitution(
            live: maxed,
            homeSide: true,
            playerOutId: maxOut[index].id,
            playerInId: maxIn[index].id,
            atHalfTime: false,
            windowId: 'same-stoppage',
          ),
          isTrue,
        );
      }
      expect(maxed.homeSubsUsed, 5);
      expect(
        engine.applySubstitution(
          live: maxed,
          homeSide: true,
          playerOutId: maxOut[5].id,
          playerInId: maxIn[5].id,
          atHalfTime: false,
          windowId: 'same-stoppage',
        ),
        isFalse,
      );
    },
  );

  test('half-time changes do not consume ordinary windows', () {
    final engine = const SimulationMatchEngine();
    final live = startMatch();
    setMinute(live, 45);
    final outgoing = live.state.homeLineup.take(2).toList(growable: false);
    final incoming = live.state.homeBench.take(2).toList(growable: false);

    expect(
      engine.applySubstitution(
        live: live,
        homeSide: true,
        playerOutId: outgoing[0].id,
        playerInId: incoming[0].id,
        atHalfTime: true,
      ),
      isTrue,
    );
    expect(
      engine.applySubstitution(
        live: live,
        homeSide: true,
        playerOutId: outgoing[1].id,
        playerInId: incoming[1].id,
        atHalfTime: true,
      ),
      isTrue,
    );
    expect(live.homeSubsUsed, 2);
    expect(live.homeSubWindows, 0);
  });

  test(
    'tactical correction is temporary and formation changes require half-time',
    () {
      final engine = const SimulationMatchEngine();
      final live = startMatch();
      final baseline = live.homeCohesionMultiplier;
      final corrected = live.state.homeTactics.copyWith(tempo: Tempo.fast);

      expect(
        engine.updateTactics(
          live: live,
          homeSide: true,
          tactics: corrected,
          atHalfTime: false,
        ),
        isTrue,
      );
      expect(live.homeTacticalPenaltyRemaining, 10);
      expect(live.homeCohesionMultiplier, closeTo(baseline - 0.02, 1e-9));

      setMinute(live, 9);
      expect(live.homeTacticalPenaltyActive, isTrue);
      setMinute(live, 10);
      expect(live.homeTacticalPenaltyActive, isFalse);
      expect(live.homeCohesionMultiplier, closeTo(baseline, 1e-9));

      final formationLive = startMatch();
      final originalFormation = formationLive.state.homeTactics.formation;
      final newFormation = originalFormation == Formation.f424
          ? Formation.f433
          : Formation.f424;
      final rejected = formationLive.state.homeTactics.copyWith(
        formation: newFormation,
      );
      expect(
        engine.updateTactics(
          live: formationLive,
          homeSide: true,
          tactics: rejected,
          atHalfTime: false,
        ),
        isFalse,
      );
      expect(formationLive.state.homeTactics.formation, originalFormation);

      setMinute(formationLive, 45);
      expect(
        engine.updateTactics(
          live: formationLive,
          homeSide: true,
          tactics: rejected,
          atHalfTime: true,
        ),
        isTrue,
      );
      expect(formationLive.state.homeTactics.formation, newFormation);
      expect(formationLive.homeTacticalPenaltyActive, isFalse);
      expect(formationLive.homeAssignedPositions, hasLength(11));
    },
  );

  test(
    'adaptation uses chemistryAppearances and decays linearly before five matches',
    () {
      final incoming = home.roster.firstWhere(
        (player) => !home.startingEleven
            .map((starter) => starter.id)
            .contains(player.id),
      );
      final appearances = {
        for (final player in home.roster) player.id: 5,
        incoming.id: 0,
      };
      final adaptedHome = home.copyWith(chemistryAppearances: appearances);
      final live = const SimulationMatchEngine().start(
        home: adaptedHome,
        away: away,
        rngSeed: 1920,
      );
      final outgoing = live.state.homeLineup.first;
      final before = live.homeAdaptationPenalty;

      expect(before, 0.0);
      expect(
        live.applySubstitution(
          homeSide: true,
          playerOutId: outgoing.id,
          playerInId: incoming.id,
          atHalfTime: false,
        ),
        isTrue,
      );
      expect(live.homeAdaptationPenalty, closeTo(1.0, 1e-9));

      final balance = BalanceConfig.defaults.matchday;
      expect(balance.adaptationPenaltyForAppearances(0), 1.0);
      expect(balance.adaptationPenaltyForAppearances(1), closeTo(0.8, 1e-9));
      expect(balance.adaptationPenaltyForAppearances(2), closeTo(0.6, 1e-9));
      expect(balance.adaptationPenaltyForAppearances(3), closeTo(0.4, 1e-9));
      expect(balance.adaptationPenaltyForAppearances(4), closeTo(0.2, 1e-9));
      expect(balance.adaptationPenaltyForAppearances(5), 0.0);
    },
  );

  test(
    'major injury path forces a bench substitution and records no replacement',
    () {
      final engine = const SimulationMatchEngine();
      final live = startMatch();
      final outgoing = live.state.homeLineup.first;
      live.legacyMatch.state = live.state.copyWith(
        homeLineup: [
          for (final player in live.state.homeLineup)
            player.id == outgoing.id
                ? player.copyWith(
                    state: player.state.copyWith(suspensionGamesRemaining: 1),
                  )
                : player,
        ],
      );
      live.legacyMatch.homeSubWindows = 3;

      expect(
        engine.applyMajorInjurySubstitution(
          live: live,
          homeSide: true,
          playerOutId: outgoing.id,
          atHalfTime: false,
        ),
        isTrue,
      );
      expect(live.homeSubsUsed, 1);
      expect(live.homeSubWindows, 3);
      expect(live.homeUnreplacedMajorInjuryIds, isEmpty);

      final noBench = startMatch();
      final noBenchOutgoing = noBench.state.homeLineup.first;
      noBench.legacyMatch.state = noBench.state.copyWith(homeBench: const []);
      expect(
        engine.applyMajorInjurySubstitution(
          live: noBench,
          homeSide: true,
          playerOutId: noBenchOutgoing.id,
          atHalfTime: false,
        ),
        isFalse,
      );
      expect(
        noBench.homeUnreplacedMajorInjuryIds,
        contains(noBenchOutgoing.id),
      );
    },
  );

  test('same seed and same Task 19 commands preserve deterministic trace', () {
    final engine = const SimulationMatchEngine();
    final first = startMatch();
    final second = startMatch();
    final firstOut = first.state.homeLineup.first.id;
    final firstIn = first.state.homeBench.first.id;
    final secondOut = second.state.homeLineup.first.id;
    final secondIn = second.state.homeBench.first.id;
    final firstCursor = first.random.cursor;
    final secondCursor = second.random.cursor;

    expect(
      engine.applySubstitution(
        live: first,
        homeSide: true,
        playerOutId: firstOut,
        playerInId: firstIn,
        atHalfTime: false,
      ),
      isTrue,
    );
    expect(
      engine.applySubstitution(
        live: second,
        homeSide: true,
        playerOutId: secondOut,
        playerInId: secondIn,
        atHalfTime: false,
      ),
      isTrue,
    );
    final firstTactics = first.state.homeTactics.copyWith(
      pressing: PressingIntensity.high,
    );
    final secondTactics = second.state.homeTactics.copyWith(
      pressing: PressingIntensity.high,
    );
    expect(
      engine.updateTactics(
        live: first,
        homeSide: true,
        tactics: firstTactics,
        atHalfTime: false,
      ),
      isTrue,
    );
    expect(
      engine.updateTactics(
        live: second,
        homeSide: true,
        tactics: secondTactics,
        atHalfTime: false,
      ),
      isTrue,
    );

    expect(first.random.cursor, firstCursor);
    expect(second.random.cursor, secondCursor);
    engine.runUntil(first, 20);
    engine.runUntil(second, 20);
    expect(first.toResult().traceSignature, second.toResult().traceSignature);
  });

  test(
    'foreign-position substitute changes the runtime assignment, not natural position',
    () {
      final live = startMatch();
      final outgoing = live.state.homeLineup.firstWhere(
        (player) => player.position == Position.st,
      );
      final incoming = live.state.homeBench.firstWhere(
        (player) =>
            player.position != Position.st && player.position != Position.gk,
      );
      final slot = live.homeAssignedPositions[outgoing.id]!;

      expect(
        live.applySubstitution(
          homeSide: true,
          playerOutId: outgoing.id,
          playerInId: incoming.id,
          atHalfTime: false,
        ),
        isTrue,
      );
      expect(live.homeAssignedPositions[incoming.id], slot);
      expect(
        live.homeEffectiveAttributes[incoming.id]!.multipliers.positionMult,
        0.90,
      );
      expect(
        unitRatingForPosition(live.homeUnitRatings!, slot),
        greaterThan(0),
      );
    },
  );
}
