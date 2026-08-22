@Tags(['property', 'integration', 'slow'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/ai/team_ai_service.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/season_service.dart';
import 'package:new_football/core/services/trade_service.dart';
import 'package:new_football/core/simulation/match_engine.dart';
import 'package:new_football/core/simulation/pre_match_validator.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/data/save_repository.dart';

/// Returns the exact roster multiset required by the slots of [formation] and
/// the four independent GK/CB/CM/ST additions.
Map<Position, int> expectedPositionCounts(Formation formation) {
  final counts = <Position, int>{
    for (final position in Position.values) position: 0,
  };

  for (final slot in FormationLayout.of(formation).slots) {
    counts[slot.position] = counts[slot.position]! + 2;
  }

  for (final extraPosition in <Position>[
    Position.gk,
    Position.cb,
    Position.cm,
    Position.st,
  ]) {
    counts[extraPosition] = counts[extraPosition]! + 1;
  }

  return counts;
}

void main() {
  test(
    'explores the initial roster/formation/XI bug on a bounded seed sweep',
    () {
      // This is the first reproducible counterexample found on the unchanged
      // implementation. Keeping it first makes the failure independently
      // reproducible while the remaining range protects the exploration from
      // depending on one accidental seed.
      const pinnedCounterexampleSeed = 1;
      final seeds = <int>[
        pinnedCounterexampleSeed,
        ...List<int>.generate(255, (index) => index + 2),
      ];

      _Counterexample? firstCounterexample;
      for (final seed in seeds) {
        final save = GameFactory().create(
          NewGameRequest(
            saveName: 'initial-roster-exploration-$seed',
            playerTeamId: 'team_europe_0',
            seed: seed,
          ),
        );

        // Evaluate every team in the generated league before retaining only
        // the first diagnostic. The bug is not limited to the player team.
        final violations = <String>[];
        for (final team in save.leagueState.teams) {
          final diagnostic = _bugConditionDiagnostic(team, seed);
          if (diagnostic != null) violations.add(diagnostic);
        }

        if (violations.isNotEmpty) {
          firstCounterexample = _Counterexample(
            seed: seed,
            violatingTeamCount: violations.length,
            firstDiagnostic: violations.first,
          );
          break;
        }
      }

      // This assertion intentionally fails on the pre-fix implementation.
      // The failure reason retains the seed, team, active formation, position
      // counts, and first slot mismatch needed to reproduce the defect.
      expect(
        firstCounterexample,
        isNull,
        reason: firstCounterexample == null
            ? 'No bug-condition counterexample found in the bounded seed '
                  'sweep ${seeds.first}..${seeds.last}; the fixed behavior '
                  'would make this exploration pass.'
            : 'Expected exploration failure on unchanged production code. '
                  'Pinned reproduction seed: $pinnedCounterexampleSeed. '
                  'First counterexample: '
                  '${firstCounterexample.toDiagnosticString()}',
      );
    },
  );

  _registerPreservationTests();
  _registerPostFixTests();
  _registerIntegrationTests();
}

void _registerPreservationTests() {
  const preservationSeeds = <int>[17, 42, 77, 1234];

  test(
    'preserves the seeded initial projection for repeated identical requests',
    () {
      for (final seed in preservationSeeds) {
        final request = NewGameRequest(
          saveName: 'initial-roster-preservation-$seed',
          playerTeamId: 'team_europe_0',
          seed: seed,
        );
        final first = GameFactory().create(request);
        final second = GameFactory().create(request);

        // This intentionally compares only the seeded initial-world contract:
        // UUIDs, timestamps, staff, and draft-class data are out of scope.
        expect(
          _initialProjection(first),
          _initialProjection(second),
          reason: 'seed=$seed repeated initial projection differs',
        );
      }
    },
  );

  test(
    'preserves roster bookkeeping limits and membership across explicit seeds',
    () {
      const balance = BalanceConfig.defaults;
      for (final seed in preservationSeeds) {
        final save = GameFactory().create(
          NewGameRequest(
            saveName: 'initial-roster-bookkeeping-$seed',
            playerTeamId: 'team_europe_0',
            seed: seed,
          ),
        );

        for (final team in save.leagueState.teams) {
          final rosterIds = team.roster.map((player) => player.id).toList();
          final rosterById = {
            for (final player in team.roster) player.id: player,
          };
          final lineupIds = team.lineupPlayerIds;
          final benchIds = team.benchPlayerIds;
          final lineupSet = lineupIds.toSet();
          final benchSet = benchIds.toSet();

          expect(
            team.roster.length,
            inInclusiveRange(balance.roster.minSize, balance.roster.maxSize),
            reason: 'seed=$seed team=${team.id} roster length',
          );
          expect(
            rosterIds.toSet().length,
            rosterIds.length,
            reason: 'seed=$seed team=${team.id} roster IDs',
          );
          expect(
            lineupIds.length,
            balance.roster.startingXi,
            reason: 'seed=$seed team=${team.id} XI length',
          );
          expect(
            lineupSet.length,
            lineupIds.length,
            reason: 'seed=$seed team=${team.id} XI IDs',
          );
          expect(
            lineupIds.every((id) => rosterById[id]?.isAvailable == true),
            isTrue,
            reason: 'seed=$seed team=${team.id} XI availability/membership',
          );
          expect(
            benchIds.length,
            lessThanOrEqualTo(balance.roster.benchSize),
            reason: 'seed=$seed team=${team.id} bench limit',
          );
          expect(
            benchSet.length,
            benchIds.length,
            reason: 'seed=$seed team=${team.id} bench IDs',
          );
          expect(
            benchIds.every((id) => rosterById.containsKey(id)),
            isTrue,
            reason: 'seed=$seed team=${team.id} bench membership',
          );
          expect(
            lineupSet.intersection(benchSet),
            isEmpty,
            reason: 'seed=$seed team=${team.id} XI/bench overlap',
          );
        }
      }
    },
  );

  test(
    'preserves the existing save round-trip contract without metadata fields',
    () async {
      const seed = 808;
      final game = GameFactory().create(
        const NewGameRequest(
          saveName: 'initial-roster-round-trip',
          playerTeamId: 'team_europe_0',
          seed: seed,
        ),
      );
      final tempDir = await Directory.systemTemp.createTemp(
        'initial_roster_preservation_',
      );

      try {
        final repository = SaveRepository(overrideDirectory: tempDir);
        await repository.save(game);
        final loaded = await repository.load(game.meta.id);

        expect(loaded.saveSeed, game.saveSeed);
        expect(loaded.schemaVersion, game.schemaVersion);
        expect(loaded.meta.schemaVersion, game.meta.schemaVersion);
        expect(_initialProjection(loaded), _initialProjection(game));
        for (final originalTeam in game.leagueState.teams) {
          final restoredTeam = loaded.leagueState.teamById(originalTeam.id)!;
          expect(
            restoredTeam.tactics.formation,
            originalTeam.tactics.formation,
          );
          expect(
            restoredTeam.roster.map(_playerProjection).toList(),
            originalTeam.roster.map(_playerProjection).toList(),
          );
          expect(restoredTeam.lineupPlayerIds, originalTeam.lineupPlayerIds);
          expect(restoredTeam.benchPlayerIds, originalTeam.benchPlayerIds);
        }
      } finally {
        if (await tempDir.exists()) await tempDir.delete(recursive: true);
      }
    },
  );

  test(
    'preserves manual formation, lineup, and tactics serialization boundaries',
    () {
      final game = GameFactory().create(
        const NewGameRequest(
          saveName: 'initial-roster-manual-boundary',
          playerTeamId: 'team_europe_0',
          seed: 909,
        ),
      );
      final originalTeam = game.leagueState.playerTeam!;
      final alternateFormation = Formation.values.firstWhere(
        (formation) => formation != originalTeam.tactics.formation,
      );
      final manualLineup = [...originalTeam.lineupPlayerIds];
      final firstLineupId = manualLineup.removeAt(0);
      manualLineup.insert(1, firstLineupId);
      final manualTeam = originalTeam.copyWith(
        tactics: originalTeam.tactics.copyWith(
          formation: alternateFormation,
          tempo: Tempo.fast,
          attackWidth: AttackWidth.wide,
        ),
        lineupPlayerIds: manualLineup,
        benchPlayerIds: originalTeam.benchPlayerIds.reversed.toList(),
      );
      final manualSave = game.copyWith(
        leagueState: game.leagueState.updateTeam(manualTeam),
      );
      final restored = GameSave.fromJson(
        jsonDecode(jsonEncode(manualSave.toJson())) as Map<String, dynamic>,
      );
      final restoredTeam = restored.leagueState.teamById(originalTeam.id)!;

      // This is deliberately a model/serialization contract check only. It
      // does not impose the new initial-roster slot invariant on later manual
      // formation or lineup changes.
      expect(restoredTeam.tactics, manualTeam.tactics);
      expect(restoredTeam.lineupPlayerIds, manualTeam.lineupPlayerIds);
      expect(restoredTeam.benchPlayerIds, manualTeam.benchPlayerIds);
      expect(_teamProjection(restoredTeam), _teamProjection(manualTeam));
    },
  );

  test(
    'preserves draft, free-agent, and trade service boundaries after creation',
    () {
      const seed = 1001;
      final game = GameFactory().create(
        const NewGameRequest(
          saveName: 'initial-roster-service-boundaries',
          playerTeamId: 'team_europe_0',
          seed: seed,
        ),
      );
      final league = game.leagueState;
      final season = SeasonService();

      // Existing draft contract: a non-player league can run the normal
      // lottery and finish all 90 picks, exposing the undrafted FA cohort.
      var draftLeague = league.copyWith(playerTeamId: null);
      draftLeague = season.runLottery(draftLeague);
      draftLeague = season.advanceDraft(draftLeague, saveSeed: seed);
      expect(draftLeague.currentSeason.draftState?.completedPicks.length, 90);
      expect(draftLeague.freeAgents.length, 30);

      // Existing free-agent contract: expiring a roster player removes it
      // from the club and exposes the same player in the FA pool.
      final sourceTeam = league.teams.first;
      final expiringPlayer = sourceTeam.roster.first;
      final expiredTeam = sourceTeam.copyWith(
        roster: [
          expiringPlayer.copyWith(
            contract: expiringPlayer.contract.copyWith(yearsRemaining: 0),
          ),
          ...sourceTeam.roster.skip(1),
        ],
      );
      final expiredLeague = season.expireContracts(
        league.updateTeam(expiredTeam),
      );
      expect(
        expiredLeague
            .teamById(sourceTeam.id)!
            .roster
            .any((player) => player.id == expiringPlayer.id),
        isFalse,
      );
      expect(
        expiredLeague.freeAgents.any(
          (player) => player.id == expiringPlayer.id,
        ),
        isTrue,
      );

      // Existing trade contract: a valid proposal can be submitted through
      // the normal validator and rejected without moving either roster.
      final targetTeam = league.teams[1];
      final proposal = TradeProposal(
        teamAId: sourceTeam.id,
        teamBId: targetTeam.id,
        assetsFromA: [TradeAsset.player(sourceTeam.roster.first.id)],
        assetsFromB: [TradeAsset.player(targetTeam.roster.first.id)],
      );
      final beforeTrade = _rosterIdsProjection(league);
      final trade = TradeService().submitLeague(
        league,
        proposal,
        aiAccepted: false,
        emitMessages: false,
        enforceWindow: false,
      );
      expect(trade.validation.ok, isTrue);
      expect(trade.executed, isFalse);
      expect(trade.outcome, 'rejected');
      expect(_rosterIdsProjection(trade.league), beforeTrade);
    },
  );
}

void _registerPostFixTests() {
  const invariantSeeds = <int>[0, 1, 2, 7, 17, 42, 77, 1234, 2026];

  test(
    'post-fix initial teams satisfy the formation roster and lineup contract',
    () {
      for (final seed in invariantSeeds) {
        final save = GameFactory().create(
          NewGameRequest(
            saveName: 'initial-roster-post-fix-$seed',
            playerTeamId: 'team_europe_0',
            seed: seed,
          ),
        );

        expect(
          save.leagueState.teams.length,
          30,
          reason: 'seed=$seed generated league size',
        );
        for (final team in save.leagueState.teams) {
          _expectInitialTeamInvariant(team, seed);
        }
      }
    },
  );

  test('bounded seeded coverage observes every current formation', () {
    const maxSeedExclusive = 64;
    final observed = <Formation, List<int>>{};

    for (var seed = 0; seed < maxSeedExclusive; seed++) {
      final league = SeedDataGenerator().generateLeague(
        playerTeamId: 'team_europe_0',
        seed: seed,
      );
      for (final team in league.teams) {
        observed.putIfAbsent(team.tactics.formation, () => []).add(seed);
      }
    }

    final missing = Formation.values
        .where((formation) => !observed.containsKey(formation))
        .map((formation) => formation.name)
        .toList();
    expect(
      missing,
      isEmpty,
      reason:
          'seed range 0..${maxSeedExclusive - 1} did not observe '
          'formations=$missing; observed=${observed.keys.map((f) => f.name).toList()}',
    );
    expect(
      observed.length,
      Formation.values.length,
      reason: 'coverage must track all current Formation.values',
    );
  });

  test(
    'seeded formation frequencies stay within documented finite-sample tolerance',
    () {
      const maxSeedExclusive = 64;
      final counts = <Formation, int>{
        for (final formation in Formation.values) formation: 0,
      };
      var sampleSize = 0;

      for (var seed = 0; seed < maxSeedExclusive; seed++) {
        final league = SeedDataGenerator().generateLeague(seed: seed);
        for (final team in league.teams) {
          counts[team.tactics.formation] = counts[team.tactics.formation]! + 1;
          sampleSize++;
        }
      }

      // A finite random sample is not expected to give exact equality. The
      // documented reproducible check allows ±40% around N/21 for N=30*64.
      final expected = sampleSize / Formation.values.length;
      final tolerance = expected * 0.40;
      final lowerBound = (expected - tolerance).floor();
      final upperBound = (expected + tolerance).ceil();
      for (final formation in Formation.values) {
        expect(
          counts[formation],
          inInclusiveRange(lowerBound, upperBound),
          reason:
              'formation=${formation.name} N=$sampleSize expected=$expected '
              'tolerance=±$tolerance seedRange=0..${maxSeedExclusive - 1} '
              'counts=$counts',
        );
      }
    },
  );

  test('keeps the fixed _generatePlayer field fixture', () {
    const seed = 24680;
    final save = GameFactory().create(
      const NewGameRequest(
        saveName: 'initial-roster-player-fixture',
        playerTeamId: 'team_europe_0',
        seed: seed,
      ),
    );
    final player = save.leagueState.teams.first.roster.first;

    // Filled with the observed deterministic projection after the fixture
    // was captured. It deliberately covers every _generatePlayer field that
    // is outside the formation/slot-selection change.
    expect(
      _projectionJson(_playerProjection(player)),
      '{"age":19,"attributes":{"stats":{"diving":72,"handling":65,"kicking":59,"reflexes":68,"speed":64,"positioning":63},"type":"goalkeeper"},"contract":{"blockedTeamIds":[],"exceptionType":null,"hasBirdRights":true,"isRookieScale":false,"noTradeClause":false,"rookiePickSlot":0,"salary":9656403,"yearsRemaining":4},"heightCm":196,"hidden":{"determination":3,"developmentCeilingStars":0.5,"developmentOutcome":"under","growthRate":0.8,"injuryProne":7,"overallProgress":50.0},"id":"team_europe_0_player_0","name":"Bin Yang","nationality":"china","optimalRole":{"role":"standard","type":"gk"},"personality":"leader","pointValue":-229,"position":"gk","potentialStars":1.5,"seasonStartOvr":65.16666666666667,"state":{"eventState":{"modifiers":[],"cooldowns":{},"counters":{},"lateBloomerTriggered":false,"lastMajorInjury":null,"majorInjuryActiveLastTick":false,"weeksSinceMajorInjury":0,"personalProblemsFollowUpPending":false},"form":2.0,"injury":null,"lastDevelopmentOvrDelta":0,"lastDevelopmentProgressDelta":0.0,"minutesThisWeek":0,"playoffYellowCards":0,"regularSeasonYellowCards":0,"role":{"role":"standard","type":"gk"},"seasonsWithTeam":4,"stamina":93,"suspensionGamesRemaining":0}}',
    );
  });

  test('TeamAiService assigns an exact player to every formation slot', () {
    final save = GameFactory().create(
      const NewGameRequest(
        saveName: 'initial-roster-ai-slot-test',
        playerTeamId: 'team_europe_0',
        seed: 13579,
      ),
    );
    final team = save.leagueState.teams.first;
    final selected = TeamAiService().autoSelectLineup(team);
    final playersById = {for (final player in team.roster) player.id: player};
    final slots = FormationLayout.of(team.tactics.formation).slots;

    expect(selected.lineupPlayerIds.length, slots.length);
    for (var index = 0; index < slots.length; index++) {
      final player = playersById[selected.lineupPlayerIds[index]];
      expect(
        player,
        isNotNull,
        reason: 'team=${team.id} slot=$index selected lineup ID',
      );
      expect(
        player!.position,
        slots[index].position,
        reason:
            'team=${team.id} slot=$index expected='
            '${slots[index].position.code} actual=${player.position.code}',
      );
    }
  });

  test('TeamAiService resolves equal overall values by Player.id', () {
    final save = GameFactory().create(
      const NewGameRequest(
        saveName: 'initial-roster-ai-tie-test',
        playerTeamId: 'team_europe_0',
        seed: 97531,
      ),
    );
    final team = save.leagueState.teams.first;
    final goalkeeperCandidates = team.roster
        .where((player) => player.position == Position.gk)
        .toList();
    expect(goalkeeperCandidates.length, greaterThanOrEqualTo(2));

    final tiedPlayers = goalkeeperCandidates
        .asMap()
        .entries
        .map(
          (entry) => entry.value.copyWith(
            id: 'tie-gk-${entry.key}',
            attributes: goalkeeperCandidates.first.attributes,
          ),
        )
        .toList();
    final tieTeam = team.copyWith(
      roster: [
        ...team.roster.where((player) => player.position != Position.gk),
        ...tiedPlayers.reversed,
      ],
      lineupPlayerIds: const [],
      benchPlayerIds: const [],
    );

    final ai = TeamAiService();
    final firstSelection = ai.autoSelectLineup(tieTeam);
    final secondSelection = ai.autoSelectLineup(tieTeam);
    final expectedGoalkeeperId = tiedPlayers.map((player) => player.id).toList()
      ..sort();

    expect(firstSelection.lineupPlayerIds.first, expectedGoalkeeperId.first);
    expect(secondSelection.lineupPlayerIds, firstSelection.lineupPlayerIds);
  });

  test(
    'TeamAiService falls back safely for a malformed team missing a slot position',
    () {
      final save = GameFactory().create(
        const NewGameRequest(
          saveName: 'initial-roster-ai-fallback-test',
          playerTeamId: 'team_europe_0',
          seed: 86420,
        ),
      );
      final team = save.leagueState.teams.first;
      final slots = FormationLayout.of(team.tactics.formation).slots;
      final missingSlotIndex = slots.indexWhere(
        (slot) => slot.position != Position.gk,
      );
      final missingPosition = slots[missingSlotIndex].position;
      final malformedRoster = team.roster
          .where((player) => player.position != missingPosition)
          .toList();
      final malformedTeam = team.copyWith(
        roster: malformedRoster,
        lineupPlayerIds: const [],
        benchPlayerIds: const [],
      );

      final selected = TeamAiService().autoSelectLineup(malformedTeam);
      final playersById = {
        for (final player in malformedRoster) player.id: player,
      };

      // This is intentionally a safe-service test, not an initial-roster
      // invariant: the malformed roster is allowed to have no exact match.
      expect(malformedRoster.length, lessThan(26));
      expect(selected.lineupPlayerIds.length, slots.length);
      expect(
        selected.lineupPlayerIds.toSet().length,
        selected.lineupPlayerIds.length,
      );
      expect(
        playersById[selected.lineupPlayerIds[missingSlotIndex]]!.position,
        isNot(missingPosition),
      );
      expect(selected.lineupPlayerIds.every(playersById.containsKey), isTrue);
    },
  );
}

void _registerIntegrationTests() {
  test('new save passes pre-match bootstrap and its first player match', () {
    const seed = 31415;
    final save = GameFactory().create(
      const NewGameRequest(
        saveName: 'initial-roster-integration-match',
        playerTeamId: 'team_europe_0',
        seed: seed,
      ),
    );
    final league = save.leagueState;
    final playerTeamId = league.playerTeamId!;
    final scheduledMatch = league.currentSeason.schedule.firstWhere(
      (match) =>
          match.homeTeamId == playerTeamId || match.awayTeamId == playerTeamId,
    );
    final home = league.teamById(scheduledMatch.homeTeamId)!;
    final away = league.teamById(scheduledMatch.awayTeamId)!;
    final validator = const PreMatchValidator();
    final preMatch = validator.validate(home: home, away: away);

    expect(
      preMatch.status,
      MatchStatus.played,
      reason: 'seed=$seed first player-team fixture must be playable',
    );
    expect(preMatch.violatingTeamIds, isEmpty);
    final playerReport = home.id == playerTeamId
        ? preMatch.home
        : preMatch.away;
    _expectPreMatchTeamReport(
      playerReport,
      home.id == playerTeamId ? home : away,
      'seed=$seed player team',
    );

    final result = SimulationMatchEngine().simulateFullMatch(
      home: home,
      away: away,
      rngSeed: save.saveSeed,
    );
    expect(result.status, MatchStatus.played);
    expect(result.noGkPenalty, isFalse);
    expect(result.noGkPenaltyTeamIds, isEmpty);

    final playerSnapshot = home.id == playerTeamId
        ? result.homeSnapshot
        : result.awaySnapshot;
    _expectMatchSnapshot(
      playerSnapshot,
      home.id == playerTeamId ? home : away,
      'seed=$seed first match result',
    );
  });

  test(
    'all 30 new-save teams pass pre-match bootstrap before the first match',
    () {
      const seed = 271828;
      final save = GameFactory().create(
        const NewGameRequest(
          saveName: 'initial-roster-integration-league',
          playerTeamId: 'team_europe_0',
          seed: seed,
        ),
      );
      final league = save.leagueState;
      final validator = const PreMatchValidator();

      expect(league.teams, hasLength(30));
      expect(league.playerTeam, isNotNull);
      for (final team in league.teams) {
        final report = validator.inspect(team);
        _expectPreMatchTeamReport(
          report,
          team,
          'seed=$seed team=${team.id} player=${team.id == league.playerTeamId}',
        );
      }
    },
  );

  test(
    'manual post-creation management survives repository save without reinitializing the roster',
    () async {
      const seed = 161803;
      final game = GameFactory().create(
        const NewGameRequest(
          saveName: 'initial-roster-integration-manual',
          playerTeamId: 'team_europe_0',
          seed: seed,
        ),
      );
      final originalTeam = game.leagueState.playerTeam!;
      final alternateFormation = Formation.values.firstWhere(
        (formation) => formation != originalTeam.tactics.formation,
      );
      final manualLineup = [...originalTeam.lineupPlayerIds];
      final firstLineupId = manualLineup.removeAt(0);
      manualLineup.insert(1, firstLineupId);
      final manualTeam = originalTeam.copyWith(
        tactics: originalTeam.tactics.copyWith(
          formation: alternateFormation,
          tempo: Tempo.fast,
          attackWidth: AttackWidth.wide,
        ),
        lineupPlayerIds: manualLineup,
        benchPlayerIds: originalTeam.benchPlayerIds.reversed.toList(),
      );
      final manualSave = game.copyWith(
        leagueState: game.leagueState.updateTeam(manualTeam),
      );
      final tempDir = await Directory.systemTemp.createTemp(
        'initial_roster_integration_manual_',
      );

      try {
        final repository = SaveRepository(overrideDirectory: tempDir);
        await repository.save(manualSave);
        final loaded = await repository.load(manualSave.meta.id);
        final restoredTeam = loaded.leagueState.teamById(originalTeam.id)!;

        expect(restoredTeam.tactics, manualTeam.tactics);
        expect(restoredTeam.lineupPlayerIds, manualTeam.lineupPlayerIds);
        expect(restoredTeam.benchPlayerIds, manualTeam.benchPlayerIds);
        expect(
          restoredTeam.roster.map((player) => player.id).toList(),
          originalTeam.roster.map((player) => player.id).toList(),
        );
        expect(
          restoredTeam.roster.map(_playerProjection).toList(),
          originalTeam.roster.map(_playerProjection).toList(),
        );
        expect(_teamProjection(restoredTeam), _teamProjection(manualTeam));
      } finally {
        if (await tempDir.exists()) await tempDir.delete(recursive: true);
      }
    },
  );
}

void _expectPreMatchTeamReport(
  PreMatchTeamReport report,
  Team team,
  String context,
) {
  final slots = FormationLayout.of(team.tactics.formation).slots;
  final startingIds = report.startingXi.map((player) => player.id).toSet();

  expect(report.rosterSizeLegal, isTrue, reason: '$context roster size');
  expect(report.invalidStartingXi, isFalse, reason: '$context legal XI');
  expect(report.startingXi.length, slots.length, reason: '$context XI length');
  expect(
    startingIds.length,
    report.startingXi.length,
    reason: '$context XI IDs must be unique',
  );
  expect(
    report.startingXi.every(
      (player) => team.roster.any((candidate) => candidate.id == player.id),
    ),
    isTrue,
    reason: '$context XI membership',
  );
  expect(report.hasGoalkeeper, isTrue, reason: '$context goalkeeper');
  expect(report.isBenchIncomplete, isFalse, reason: '$context bench target');
  expect(
    report.bench.every(
      (player) => team.roster.any((candidate) => candidate.id == player.id),
    ),
    isTrue,
    reason: '$context bench membership',
  );
  for (var index = 0; index < slots.length; index++) {
    expect(
      report.startingXi[index].position,
      slots[index].position,
      reason:
          '$context slot=$index expected=${slots[index].position.code} '
          'actual=${report.startingXi[index].position.code}',
    );
  }
}

void _expectMatchSnapshot(
  MatchTeamSnapshot snapshot,
  Team team,
  String context,
) {
  final slots = FormationLayout.of(team.tactics.formation).slots;
  final snapshotIds = snapshot.startingXi.map((player) => player.id).toSet();

  expect(
    snapshot.startingXi.length,
    slots.length,
    reason: '$context XI length',
  );
  expect(
    snapshotIds.length,
    snapshot.startingXi.length,
    reason: '$context XI IDs must be unique',
  );
  expect(
    snapshot.startingXi.any((player) => player.position == Position.gk),
    isTrue,
    reason: '$context goalkeeper',
  );
  expect(
    snapshot.assignedPositions,
    slots.map((slot) => slot.position).toList(),
    reason: '$context assigned positions',
  );
  for (var index = 0; index < slots.length; index++) {
    expect(
      snapshot.startingXi[index].position,
      slots[index].position,
      reason:
          '$context slot=$index expected=${slots[index].position.code} '
          'actual=${snapshot.startingXi[index].position.code}',
    );
  }
}

void _expectInitialTeamInvariant(Team team, int seed) {
  final context =
      'seed=$seed team=${team.id} formation=${team.tactics.formation.name}';
  final formation = team.tactics.formation;
  final slots = FormationLayout.of(formation).slots;
  final expectedCounts = expectedPositionCounts(formation);
  final actualCounts = _actualPositionCounts(team);
  final rosterIds = team.roster.map((player) => player.id).toList();
  final rosterById = {for (final player in team.roster) player.id: player};
  final lineupIds = team.lineupPlayerIds;
  final lineupSet = lineupIds.toSet();
  final benchIds = team.benchPlayerIds;
  final benchSet = benchIds.toSet();

  expect(Formation.values, contains(formation), reason: '$context formation');
  expect(slots.length, 11, reason: '$context slot count');
  expect(team.roster.length, 26, reason: '$context roster length');
  expect(
    rosterIds.toSet().length,
    rosterIds.length,
    reason: '$context roster IDs must be unique',
  );
  for (final position in Position.values) {
    expect(
      actualCounts[position],
      expectedCounts[position],
      reason:
          '$context position=${position.code} expected='
          '${expectedCounts[position]} actual=${actualCounts[position]}',
    );
  }

  expect(lineupIds.length, 11, reason: '$context XI length');
  expect(
    lineupSet.length,
    lineupIds.length,
    reason: '$context XI IDs must be unique',
  );
  expect(
    lineupIds.every((id) => rosterById.containsKey(id)),
    isTrue,
    reason: '$context XI must belong to roster',
  );
  expect(
    lineupIds.every((id) => rosterById[id]!.isAvailable),
    isTrue,
    reason: '$context XI must contain available players',
  );
  for (var index = 0; index < slots.length; index++) {
    final player = rosterById[lineupIds[index]];
    expect(
      player!.position,
      slots[index].position,
      reason:
          '$context slot=$index expected='
          '${slots[index].position.code} actual=${player.position.code}',
    );
  }

  expect(benchIds.length, lessThanOrEqualTo(7), reason: '$context bench limit');
  expect(
    benchSet.length,
    benchIds.length,
    reason: '$context bench IDs must be unique',
  );
  expect(
    benchIds.every((id) => rosterById.containsKey(id)),
    isTrue,
    reason: '$context bench must belong to roster',
  );
  expect(
    lineupSet.intersection(benchSet),
    isEmpty,
    reason: '$context XI and bench must be disjoint',
  );
}

String _initialProjection(GameSave save) => _projectionJson({
  'saveSeed': save.saveSeed,
  'playerTeamId': save.leagueState.playerTeamId,
  'teams': save.leagueState.teams.map(_teamProjection).toList(),
});

Map<String, Object?> _teamProjection(Team team) {
  final counts = _actualPositionCounts(team);
  return {
    'teamId': team.id,
    'formation': team.tactics.formation.name,
    'roster': team.roster.map(_playerProjection).toList(),
    'positionMultiset': {
      for (final position in Position.values) position.name: counts[position],
    },
    'lineupPlayerIds': team.lineupPlayerIds,
    'benchPlayerIds': team.benchPlayerIds,
  };
}

Map<String, Object?> _playerProjection(Player player) => {
  'id': player.id,
  'name': player.name,
  'position': player.position.name,
  'nationality': player.nationality.name,
  'age': player.age,
  'attributes': player.attributes.toJson(),
  'personality': player.personality.name,
  'heightCm': player.heightCm,
  'optimalRole': player.optimalRole.toJson(),
  'contract': player.contract.toJson(),
  'state': player.state.toJson(),
  'hidden': player.hidden.toJson(),
  'potentialStars': player.potentialStars,
  'seasonStartOvr': player.seasonStartOvr,
  'pointValue': player.pointValue,
};

String _rosterIdsProjection(dynamic league) => _projectionJson({
  'teams': league.teams
      .map(
        (team) => {
          'teamId': team.id,
          'rosterIds': team.roster.map((player) => player.id).toList(),
        },
      )
      .toList(),
});

String _projectionJson(Map<String, Object?> value) =>
    jsonEncode(_canonicalize(value));

Object? _canonicalize(Object? value) {
  if (value is Map) {
    final entries = <String, Object?>{
      for (final entry in value.entries)
        entry.key.toString(): _canonicalize(entry.value),
    };
    final keys = entries.keys.toList()..sort();
    return <String, Object?>{for (final key in keys) key: entries[key]};
  }
  if (value is Iterable) {
    return value.map(_canonicalize).toList();
  }
  return value;
}

String? _bugConditionDiagnostic(Team team, int seed) {
  final formation = team.tactics.formation;
  final slots = FormationLayout.of(formation).slots;
  final expectedCounts = expectedPositionCounts(formation);
  final actualCounts = _actualPositionCounts(team);
  final rosterIds = team.roster.map((player) => player.id).toList();
  final rosterById = {for (final player in team.roster) player.id: player};
  final lineupIds = team.lineupPlayerIds;
  final failures = <String>[];

  if (!Formation.values.contains(formation)) {
    failures.add('active formation is not a supported Formation value');
  }
  if (team.roster.length != 26) {
    failures.add('rosterLength=${team.roster.length}, expected=26');
  }
  if (rosterIds.toSet().length != rosterIds.length) {
    failures.add('roster IDs are not unique');
  }

  final countMismatches = Position.values
      .where((position) => expectedCounts[position] != actualCounts[position])
      .map(
        (position) =>
            '${position.code}: expected ${expectedCounts[position]}, '
            'actual ${actualCounts[position]}',
      )
      .toList();
  if (countMismatches.isNotEmpty) {
    failures.add('positionCountMismatches=${countMismatches.join('; ')}');
  }

  if (lineupIds.length != slots.length) {
    failures.add('lineupLength=${lineupIds.length}, expected=${slots.length}');
  }
  if (lineupIds.toSet().length != lineupIds.length) {
    failures.add('lineup IDs are not unique');
  }
  final lineupOutsideRoster = lineupIds
      .where((id) => !rosterById.containsKey(id))
      .toList();
  if (lineupOutsideRoster.isNotEmpty) {
    failures.add('lineup IDs outside roster=$lineupOutsideRoster');
  }

  String? firstXiMismatch;
  for (var index = 0; index < slots.length; index++) {
    if (index >= lineupIds.length) {
      firstXiMismatch =
          'index=$index missing lineup player, '
          'expectedPosition=${slots[index].position.code}';
      break;
    }

    final playerId = lineupIds[index];
    final player = rosterById[playerId];
    if (player == null) {
      firstXiMismatch =
          'index=$index id=$playerId missing from roster, '
          'expectedPosition=${slots[index].position.code}';
      break;
    }
    if (player.position != slots[index].position) {
      firstXiMismatch =
          'index=$index id=$playerId expectedPosition='
          '${slots[index].position.code} actualPosition=${player.position.code}';
      break;
    }
  }
  if (firstXiMismatch != null) {
    failures.add('firstXiMismatch=$firstXiMismatch');
  }

  if (failures.isEmpty) return null;

  return 'seed=$seed teamId=${team.id} '
      'activeFormation=${formation.label} '
      'expectedCounts=${_formatCounts(expectedCounts)} '
      'actualCounts=${_formatCounts(actualCounts)} '
      'rosterPositionSignature=${team.roster.map((p) => p.position.code).join(',')} '
      'firstXiMismatch=${firstXiMismatch ?? 'none'} '
      'checks=${failures.join(' | ')}';
}

Map<Position, int> _actualPositionCounts(Team team) {
  final counts = <Position, int>{
    for (final position in Position.values) position: 0,
  };
  for (final player in team.roster) {
    counts[player.position] = counts[player.position]! + 1;
  }
  return counts;
}

String _formatCounts(Map<Position, int> counts) => Position.values
    .map((position) => '${position.code}:${counts[position]}')
    .join(',');

class _Counterexample {
  const _Counterexample({
    required this.seed,
    required this.violatingTeamCount,
    required this.firstDiagnostic,
  });

  final int seed;
  final int violatingTeamCount;
  final String firstDiagnostic;

  String toDiagnosticString() =>
      'seed=$seed violatingTeams=$violatingTeamCount $firstDiagnostic';
}
