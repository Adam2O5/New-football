import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/injury_service.dart';
import 'package:new_football/core/simulation/match_engine.dart';
import 'package:new_football/core/simulation/matchday_runtime.dart';

void main() {
  final league = SeedDataGenerator().generateLeague(seed: 42);
  final home = league.teams[0];
  final away = league.teams[1];
  const quiet = BalanceConfig(
    matchday: MatchdayBalance(sequenceBase: 0, injuryBase: 0),
  );

  test(
    'bootstrap freezes squads, staff, context and initial player accounting',
    () {
      final player = home.startingEleven.first;
      final live = SimulationMatchEngine().start(
        home: home,
        away: away,
        context: const MatchContext(seed: 1919, crowdIntensity: 40),
        rngSeed: 42,
        homeAssignedPositions: {player.id: Position.cm},
      );
      final runtime = live.runtime;
      expect(live.seed, 1919);
      expect(live.state.rngSeed, 1919);
      expect(live.state.context.homeTeamId, home.id);
      expect(live.state.context.awayTeamId, away.id);
      expect(live.state.momentum, 5);
      expect(live.random.cursor, 0);
      expect(runtime.homeStartingLineup, home.startingEleven);
      expect(runtime.homeSnapshot!.startingXi, home.startingEleven);
      expect(runtime.homeSnapshot!.staff, home.staff);
      expect(runtime.homeChemistry, home.chemistry);
      expect(runtime.homeAtmosphere, home.atmosphere);
      expect(
        runtime.homeDoctorCareMult,
        const InjuryService().doctorCareMult(home.staff.doctor),
      );
      expect(live.homeAssignedPositions[player.id], Position.cm);
      expect(
        live.homeEffectiveAttributes.keys,
        containsAll(home.startingEleven.map((p) => p.id)),
      );
      expect(live.homeUnitRatings, isNotNull);
      expect(
        runtime.playersById.length,
        live.state.homeLineup.length +
            live.state.awayLineup.length +
            live.state.homeBench.length +
            live.state.awayBench.length,
      );
      for (final p in runtime.playersById.values) {
        expect(runtime.minutesPlayed[p.id], 0);
        expect(runtime.staminaRemaining[p.id], p.state.stamina.toDouble());
        expect(
          runtime.teamByPlayerId[p.id],
          home.roster.any((candidate) => candidate.id == p.id)
              ? home.id
              : away.id,
        );
      }
      expect(() => runtime.homeStartingLineup.clear(), throwsUnsupportedError);
    },
  );

  for (final bothInvalid in [false, true]) {
    test(
      'administrative ${bothInvalid ? 'DSQ' : 'walkover'} skips the simulation and preserves snapshots',
      () {
        final engine = SimulationMatchEngine();
        final invalidHome = home.copyWith(
          roster: home.roster.take(19).toList(),
        );
        final actualAway = bothInvalid
            ? away.copyWith(roster: away.roster.take(19).toList())
            : away;
        final live = engine.start(
          home: invalidHome,
          away: actualAway,
          rngSeed: 42,
        );
        expect(live.isFinished, isTrue);
        engine.runUntil(live, 90);
        expect(live.random.cursor, 0);
        expect(live.minuteTraces, isEmpty);
        expect(live.runtime.minutesPlayed.values.every((v) => v == 0), isTrue);
        final result = engine.toMatchResult(
          live: live,
          home: invalidHome,
          away: actualAway,
        );
        expect(
          result.status,
          bothInvalid ? MatchStatus.dsq : MatchStatus.walkover,
        );
        expect(result.homeGoals, 0);
        expect(result.awayGoals, bothInvalid ? 0 : 3);
        expect(result.homeSnapshot.startingXi, live.state.homeLineup);
        expect(result.homeStats.shots, 0);
        expect(result.events, isEmpty);
        expect(
          MatchResult.fromJson(
            jsonDecode(jsonEncode(result.toJson())) as Map<String, dynamic>,
          ),
          result,
        );
      },
    );
  }

  test('no goalkeeper and a short bench remain playable warnings', () {
    final outfield = home.roster
        .where((p) => p.position != Position.gk)
        .take(11)
        .toList();
    final selected = outfield.map((p) => p.id).toSet();
    final bench = home.roster
        .where((p) => !selected.contains(p.id))
        .take(2)
        .toList();
    final team = home.copyWith(
      lineupPlayerIds: selected.toList(),
      benchPlayerIds: bench.map((p) => p.id).toList(),
    );
    final engine = SimulationMatchEngine(balance: quiet);
    final live = engine.start(home: team, away: away, rngSeed: 42);
    expect(live.isFinished, isFalse);
    expect(live.homeNoGkPenalty, isTrue);
    expect(live.state.homeBench, hasLength(2));
    engine.simulateMinute(live);
    final result = engine.toMatchResult(live: live, home: team, away: away);
    expect(result.status, MatchStatus.played);
    expect(result.noGkPenaltyTeamIds, contains(home.id));
    expect(result.homeGoals, 0);
    expect(result.awayGoals, 0);
    final gk = live.state.homeBench.firstWhere(
      (p) => p.position == Position.gk,
    );
    expect(
      engine.applySubstitution(
        live: live,
        homeSide: true,
        playerOutId: outfield.first.id,
        playerInId: gk.id,
      ),
      isTrue,
    );
    expect(live.homeNoGkPenalty, isFalse);
    expect(live.runtime.homeNoGkPenalty, isFalse);
  });

  test(
    'a half-time substitute keeps stamina, slot and real minutes through result serialization',
    () {
      final engine = SimulationMatchEngine(balance: quiet);
      final live = engine.start(home: home, away: away, rngSeed: 1919);
      engine.runUntil(live, 45);
      expect(live.isHalfTime, isTrue);
      final snapshot = live.runtime.homeSnapshot!;
      final outgoing = live.state.homeLineup.firstWhere(
        (p) => p.position != Position.gk,
      );
      final incoming = live.state.homeBench.firstWhere(
        (p) => p.position != Position.gk,
      );
      final slot = live.homeAssignedPositions[outgoing.id];
      final outgoingStamina = live.currentStamina(outgoing.id);
      live.runtime.staminaRemaining[incoming.id] = 37;
      final cursor = live.random.cursor;
      expect(
        engine.applySubstitution(
          live: live,
          homeSide: true,
          playerOutId: outgoing.id,
          playerInId: incoming.id,
          atHalfTime: true,
        ),
        isTrue,
      );
      expect(live.random.cursor, cursor);
      expect(live.homeSubsUsed, 1);
      expect(live.homeSubWindows, 0);
      expect(live.currentStamina(incoming.id), 37);
      expect(live.homeAssignedPositions[incoming.id], slot);
      expect(live.homeEffectiveAttributes, contains(incoming.id));
      expect(live.homeEffectiveAttributes, isNot(contains(outgoing.id)));
      engine.runUntil(live, 90);
      expect(live.runtime.minutesPlayed[outgoing.id], 45);
      expect(live.runtime.minutesPlayed[incoming.id], 45);
      expect(live.currentStamina(outgoing.id), outgoingStamina);
      expect(live.currentStamina(incoming.id), lessThan(37));
      expect(live.runtime.homeSnapshot, snapshot);
      expect(live.runtime.homeStartingLineup, contains(outgoing));
      final result = engine.toMatchResult(live: live, home: home, away: away);
      expect(result.homeLineup, snapshot.startingXi);
      expect(result.homeSnapshot, snapshot);
      expect(
        result.playerStats.firstWhere((p) => p.playerId == incoming.id).minutes,
        45,
      );
      expect(
        result.playerStats.firstWhere((p) => p.playerId == outgoing.id).minutes,
        45,
      );
      expect(result.homeStats.shots, 0);
      expect(result.awayStats.shots, 0);
      expect(result.homeStats.xg, 0);
      expect(
        result.events.where((e) => e.type == MatchEventType.substitution),
        hasLength(1),
      );
      expect(live.minuteTraces, hasLength(90));
      expect(live.isFinished, isTrue);
      expect(
        MatchResult.fromJson(
          jsonDecode(jsonEncode(result.toJson())) as Map<String, dynamic>,
        ),
        result,
      );
      expect(
        MatchState.fromJson(
          jsonDecode(jsonEncode(live.state.toJson())) as Map<String, dynamic>,
        ),
        live.state,
      );
      final cursorAtEnd = live.random.cursor;
      engine.simulateMinute(live);
      expect(live.state.minute, 90);
      expect(live.random.cursor, cursorAtEnd);
    },
  );

  test(
    'substitutions share stoppage windows, enforce both limits and forbid reentry',
    () {
      final engine = SimulationMatchEngine(balance: quiet);
      final live = engine.start(home: home, away: away, rngSeed: 1919);
      final outgoing = [...live.state.homeLineup];
      final incoming = [...live.state.homeBench];
      bool change(int i, String window) => engine.applySubstitution(
        live: live,
        homeSide: true,
        playerOutId: outgoing[i].id,
        playerInId: incoming[i].id,
        atHalfTime: false,
        windowId: window,
      );
      expect(change(0, 'a'), isTrue);
      expect(change(1, 'a'), isTrue);
      expect(live.homeSubWindows, 1);
      expect(change(2, 'b'), isTrue);
      expect(change(3, 'c'), isTrue);
      expect(change(4, 'd'), isFalse);
      expect(
        live.lastAction!.failure,
        SimulationActionFailure.substitutionWindowsLimit,
      );
      expect(change(4, 'c'), isTrue);
      expect(live.homeSubsUsed, 5);
      expect(change(5, 'c'), isFalse);
      expect(
        live.lastAction!.failure,
        SimulationActionFailure.substitutionsLimit,
      );
      expect(live.random.cursor, 0);
      final another = engine.start(home: home, away: away, rngSeed: 1919);
      expect(
        engine.applySubstitution(
          live: another,
          homeSide: true,
          playerOutId: outgoing[0].id,
          playerInId: incoming[0].id,
        ),
        isTrue,
      );
      expect(
        engine.applySubstitution(
          live: another,
          homeSide: true,
          playerOutId: incoming[0].id,
          playerInId: outgoing[0].id,
        ),
        isFalse,
      );
      expect(
        another.lastAction!.failure,
        SimulationActionFailure.playerCannotReenter,
      );
    },
  );

  test(
    'tactical changes update runtime ratings and preserve the pre-match snapshot',
    () {
      final engine = SimulationMatchEngine(balance: quiet);
      final live = engine.start(home: home, away: away, rngSeed: 1919);
      final snapshot = live.runtime.homeSnapshot!;
      final formation = live.state.homeTactics.formation == Formation.f424
          ? Formation.f433
          : Formation.f424;
      final tactics = live.state.homeTactics.copyWith(
        formation: formation,
        tempo: Tempo.fast,
      );
      expect(
        engine.updateTactics(
          live: live,
          homeSide: true,
          tactics: tactics,
          atHalfTime: false,
        ),
        isFalse,
      );
      engine.runUntil(live, 45);
      expect(live.isHalfTime, isTrue);
      final cursor = live.random.cursor;
      expect(
        engine.updateTactics(
          live: live,
          homeSide: true,
          tactics: tactics,
          atHalfTime: true,
        ),
        isTrue,
      );
      expect(live.random.cursor, cursor);
      expect(live.state.homeTactics, tactics);
      expect(live.homeAssignedPositions, hasLength(11));
      expect(live.homeUnitRatings, isNotNull);
      expect(live.runtime.homeSnapshot, snapshot);
      expect(live.runtime.homeSnapshot!.tactics, home.tactics);
    },
  );

  test(
    'active fouls and dismissals reach discipline, squads and the assembled result',
    () {
      const balance = BalanceConfig(
        matchday: MatchdayBalance(
          injuryBase: 0,
          foulBase: 100,
          yellowFromFoul: 100,
          redDirect: 0,
        ),
      );
      final engine = SimulationMatchEngine(balance: balance);
      final live = engine.start(home: home, away: away, rngSeed: 2020);
      while (live.state.sentOffPlayerIds.isEmpty && live.state.minute < 30) {
        engine.simulateMinute(live);
      }
      expect(live.state.sentOffPlayerIds, isNotEmpty);
      final result = engine.toMatchResult(live: live, home: home, away: away);
      expect(result.disciplines, isNotEmpty);
      expect(
        result.events.where((e) => e.type == MatchEventType.redCard),
        isNotEmpty,
      );
      for (final id in live.state.sentOffPlayerIds) {
        expect(
          [
            ...live.state.homeLineup,
            ...live.state.awayLineup,
          ].any((p) => p.id == id),
          isFalse,
        );
        expect(
          result.disciplines.any(
            (d) => d.playerId == id && d.redCardKind != RedCardKind.none,
          ),
          isTrue,
        );
        expect(live.runtime.playersById, contains(id));
      }
    },
  );

  test(
    'active injuries retain diagnosis, staff snapshot and the injured player in result accounting',
    () {
      const balance = BalanceConfig(
        matchday: MatchdayBalance(injuryBase: 100, sequenceBase: 0),
      );
      final engine = SimulationMatchEngine(balance: balance);
      final live = engine.start(home: home, away: away, rngSeed: 2020);
      engine.simulateMinute(live);
      expect(live.injuries, isNotEmpty);
      final result = engine.toMatchResult(live: live, home: home, away: away);
      expect(result.injuries, live.injuries);
      expect(
        result.events.any(
          (e) =>
              e.type == MatchEventType.minorInjury ||
              e.type == MatchEventType.majorInjury,
        ),
        isTrue,
      );
      for (final injury in result.injuries) {
        expect(live.runtime.playersById, contains(injury.playerId));
        expect(live.state.injuriesThisMatch, contains(injury.playerId));
        expect(
          result.playerStats.any(
            (p) => p.playerId == injury.playerId && p.minutes == 1,
          ),
          isTrue,
        );
      }
      expect(result.homeSnapshot.staff, home.staff);
      expect(
        MatchResult.fromJson(
          jsonDecode(jsonEncode(result.toJson())) as Map<String, dynamic>,
        ),
        result,
      );
    },
  );

  for (final seed in [42, 1919, 2020]) {
    test(
      'full and stepped simulation produce identical results and RNG for seed $seed',
      () {
        final fullEngine = SimulationMatchEngine();
        final full = fullEngine.start(home: home, away: away, rngSeed: seed);
        fullEngine.runUntil(full, 90);
        final steppedEngine = SimulationMatchEngine();
        final stepped = steppedEngine.start(
          home: home,
          away: away,
          rngSeed: seed,
        );
        for (var minute = 0; minute < 90; minute++) {
          steppedEngine.simulateMinute(stepped);
        }
        expect(
          stepped.toResult().traceSignature,
          full.toResult().traceSignature,
        );
        expect(stepped.random.cursor, full.random.cursor);
        expect(stepped.runtime.minutesPlayed, full.runtime.minutesPlayed);
        expect(stepped.runtime.staminaRemaining, full.runtime.staminaRemaining);
        expect(
          steppedEngine.toMatchResult(live: stepped, home: home, away: away),
          fullEngine.toMatchResult(live: full, home: home, away: away),
        );
      },
    );
  }
}
