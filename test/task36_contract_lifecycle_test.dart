import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/ai/ai_draft_service.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/season_service.dart';

void main() {
  final generator = SeedDataGenerator();
  final balance = BalanceConfig.defaults;

  Team _aiTeam(LeagueState league) =>
      league.teams.firstWhere((team) => team.ai != null);

  LeagueState _replaceTeam(LeagueState league, Team replacement) =>
      league.copyWith(
        teams: [
          for (final team in league.teams)
            team.id == replacement.id ? replacement : team,
        ],
      );

  Player _prospectPlayer(
    LeagueState league, {
    required String id,
    required int index,
    required int yearsRemaining,
    bool rookieScale = false,
  }) {
    final prospect = generator
        .generateDraftClass(year: league.currentSeason.year)
        .prospects[index]
        .copyWith(id: id);
    return prospect
        .toPlayer(
          contract: Contract(
            salary: rookieScale
                ? balance.salaryCap.rookieSalaryForPick(60)
                : balance.salaryCap.minSalary,
            yearsRemaining: yearsRemaining,
            isRookieScale: rookieScale,
            rookiePickSlot: rookieScale ? 60 : 0,
          ),
          rng: Random(index + 36000),
        )
        .recalculatePointValue(balance);
  }

  FreshUndraftedPlayer _freshRecord(LeagueState league, String playerId) =>
      FreshUndraftedPlayer(
        playerId: playerId,
        draftYear: league.currentSeason.year,
        activeFromSeasonYear: league.currentSeason.year,
        activeFromWeek: balance.calendar.freeAgencyWeek,
        activeUntilSeasonYear: league.currentSeason.year + 1,
        activeUntilWeek: balance.calendar.freeAgencyPhaseIIEndWeek,
      );

  test('draft free-agent provenance is idempotent and serializable', () {
    final season = SeasonService();
    var league = generator
        .generateLeague(seed: 3610)
        .copyWith(playerTeamId: null);
    league = season.runLottery(league);
    final finalized = season.advanceDraft(league, saveSeed: 3610);

    expect(finalized.freeAgents, hasLength(30));
    expect(finalized.freshUndraftedPlayers, hasLength(30));
    expect(
      finalized.freshUndraftedPlayers.map((record) => record.playerId).toSet(),
      hasLength(30),
    );
    expect(
      finalized.freshUndraftedPlayers.every(
        (record) =>
            record.activeFromWeek == balance.calendar.freeAgencyWeek &&
            record.activeUntilWeek == balance.calendar.freeAgencyPhaseIIEndWeek,
      ),
      isTrue,
    );

    final replay = season.advanceDraft(finalized, saveSeed: 3610);
    expect(replay.freeAgents, finalized.freeAgents);
    expect(replay.freshUndraftedPlayers, finalized.freshUndraftedPlayers);

    final restored = LeagueState.fromJson(
      jsonDecode(jsonEncode(finalized.toJson())) as Map<String, dynamic>,
    );
    expect(restored.freshUndraftedPlayers, finalized.freshUndraftedPlayers);

    final save = GameSave(
      meta: GameSaveMeta(
        id: 'task36-lifecycle',
        name: 'Task 36 lifecycle',
        createdAt: DateTime.utc(2036, 1, 1),
        updatedAt: DateTime.utc(2036, 1, 1),
        seasonYear: finalized.currentSeason.year,
        phase: finalized.currentSeason.phase,
        schemaVersion: SaveSchema.currentVersion,
      ),
      leagueState: finalized,
      saveSeed: 3610,
      schemaVersion: SaveSchema.currentVersion,
    );
    final restoredSave = GameSave.fromJson(
      jsonDecode(jsonEncode(save.toJson())) as Map<String, dynamic>,
    );
    expect(restoredSave.leagueState.freshUndraftedPlayers, hasLength(30));
    expect(SaveSchema.currentVersion, 21);
  });

  test('weekly deferred-rights policy signs legal AI-owned rights', () {
    final base = generator
        .generateLeague(seed: 3611)
        .copyWith(currentWeek: 47, currentDay: 1, currentHour: 1);
    final originalTeam = _aiTeam(base);
    final team = originalTeam.copyWith(
      roster: originalTeam.roster.take(20).toList(),
    );
    final player = _prospectPlayer(
      base,
      id: 'task36-deferred-right',
      index: 2,
      yearsRemaining: balance.salaryCap.rookieScaleYears,
      rookieScale: true,
    );
    final right = DraftedPlayerRights(
      id: 'rights:3611:60:${player.id}',
      ownerTeamId: team.id,
      player: player,
      draftYear: base.currentSeason.year,
      pickNumber: 60,
    );
    final state = _replaceTeam(base.copyWith(draftedRights: [right]), team);
    final policy = AiDraftService();
    final market = ContractMarketService();

    LeagueState? signed;
    for (var seed = 0; seed < 500; seed++) {
      final decision = policy.deferredRightsSigningDecision(
        team: team,
        prospectId: player.id,
        saveSeed: seed,
        seasonYear: state.currentSeason.year,
        week: state.currentWeek,
      );
      if (!decision.sign) continue;
      final candidate = market.weeklyTick(state, saveSeed: seed);
      if (!candidate.draftedRights.any((item) => item.id == right.id)) {
        signed = candidate;
        break;
      }
    }

    expect(signed, isNotNull);
    expect(signed!.draftedRights, isEmpty);
    expect(signed.teamById(team.id)!.roster, hasLength(team.roster.length + 1));
  });

  test(
    'fresh undrafted offer enters negotiation and cleans provenance on sign',
    () {
      final base = generator.generateLeague(seed: 3612);
      final originalTeam = _aiTeam(base);
      final team = originalTeam.copyWith(
        roster: originalTeam.roster.take(19).toList(),
      );
      final player = _prospectPlayer(
        base,
        id: 'task36-fresh-undrafted',
        index: 4,
        yearsRemaining: 0,
      );
      final state = _replaceTeam(
        base.copyWith(
          currentWeek: 47,
          currentDay: 1,
          currentHour: 1,
          freeAgents: [player],
          freshUndraftedPlayers: [_freshRecord(base, player.id)],
        ),
        team,
      );
      final market = ContractMarketService();

      LeagueState? offered;
      for (var seed = 0; seed < 100; seed++) {
        final candidate = market.weeklyTick(state, saveSeed: seed);
        if (candidate.negotiations.any(
          (item) => item.subjectId == player.id && item.teamId == team.id,
        )) {
          offered = candidate;
          break;
        }
      }

      expect(offered, isNotNull);
      final negotiation = offered!.negotiations.firstWhere(
        (item) => item.subjectId == player.id && item.teamId == team.id,
      );
      expect(negotiation.isAiOffer, isTrue);
      expect(negotiation.status, NegotiationStatus.pendingFinalization);
      expect(negotiation.lastOffer.salary, balance.salaryCap.minSalary);
      expect(negotiation.lastOffer.years, 2);

      final resolved = market.resolveDay(offered, saveSeed: 3612);
      expect(resolved.freeAgents.any((item) => item.id == player.id), isFalse);
      expect(
        resolved.freshUndraftedPlayers.any(
          (item) => item.playerId == player.id,
        ),
        isFalse,
      );
      expect(
        resolved.teams.any(
          (candidate) => candidate.roster.any((p) => p.id == player.id),
        ),
        isTrue,
      );
    },
  );

  test(
    'fresh undrafted offers compete and FA-II remains capped at two attempts',
    () {
      final base = generator.generateLeague(seed: 3613);
      final aiTeams = base.teams
          .where((team) => team.ai != null)
          .take(2)
          .toList();
      final configuredTeams = [
        for (final team in aiTeams)
          team.copyWith(roster: team.roster.take(19).toList()),
      ];
      final player = _prospectPlayer(
        base,
        id: 'task36-competition-undrafted',
        index: 6,
        yearsRemaining: 0,
      );
      var state = _replaceTeam(
        base.copyWith(
          currentWeek: 47,
          currentDay: 1,
          currentHour: 1,
          freeAgents: [player],
          freshUndraftedPlayers: [_freshRecord(base, player.id)],
        ),
        configuredTeams.first,
      );
      state = _replaceTeam(state, configuredTeams.last);
      final market = ContractMarketService();

      LeagueState? competing;
      int? seedWithCompetition;
      for (var seed = 0; seed < 500; seed++) {
        final candidate = market.weeklyTick(state, saveSeed: seed);
        final offers = candidate.negotiations
            .where(
              (item) =>
                  item.subjectId == player.id &&
                  item.isAiOffer &&
                  item.phase == NegotiationPhase.freeAgencyPhaseI,
            )
            .toList();
        if (offers.length >= 2) {
          competing = candidate;
          seedWithCompetition = seed;
          break;
        }
      }

      expect(competing, isNotNull);
      final resolved = market.resolveDay(
        competing!,
        saveSeed: seedWithCompetition!,
      );
      final signedTeams = resolved.teams
          .where((team) => team.roster.any((p) => p.id == player.id))
          .toList();
      expect(signedTeams, hasLength(1));
      expect(
        resolved.negotiations
            .where((item) => item.subjectId == player.id && item.isAiOffer)
            .where((item) => item.status == NegotiationStatus.completed)
            .length,
        1,
      );

      final phaseTwoPlayers = [
        for (var index = 0; index < 6; index++)
          _prospectPlayer(
            base,
            id: 'task36-phase-two-$index',
            index: index + 10,
            yearsRemaining: 0,
          ),
      ];
      final phaseTwoState = _replaceTeam(
        base.copyWith(
          currentWeek: 48,
          currentDay: 1,
          currentHour: null,
          freeAgents: phaseTwoPlayers,
          freshUndraftedPlayers: [
            for (final candidate in phaseTwoPlayers)
              _freshRecord(base, candidate.id),
          ],
        ),
        configuredTeams.first,
      );
      final phaseTwo = market.weeklyTick(phaseTwoState, saveSeed: 3613);
      expect(
        phaseTwo.negotiations
            .where(
              (item) =>
                  item.isAiOffer &&
                  item.teamId == configuredTeams.first.id &&
                  item.phase == NegotiationPhase.freeAgencyPhaseII &&
                  item.week == 48,
            )
            .length,
        lessThanOrEqualTo(balance.ai.faPhaseTwoWeeklyOfferLimit),
      );
    },
  );

  test('central cap validation rejects a fresh undrafted offer', () {
    final base = generator.generateLeague(seed: 3614);
    final originalTeam = _aiTeam(base);
    final expensiveTeam = originalTeam.copyWith(
      roster: [
        for (final player in originalTeam.roster.take(20))
          player.copyWith(
            contract: player.contract.copyWith(
              salary: balance.salaryCap.maxSalary,
              yearsRemaining: 1,
            ),
          ),
      ],
    );
    final player = _prospectPlayer(
      base,
      id: 'task36-cap-rejected-undrafted',
      index: 8,
      yearsRemaining: 0,
    );
    final state = _replaceTeam(
      base.copyWith(
        currentWeek: 47,
        currentDay: 1,
        currentHour: 1,
        freeAgents: [player],
        freshUndraftedPlayers: [_freshRecord(base, player.id)],
      ),
      expensiveTeam,
    );

    final result = ContractMarketService().weeklyTick(state, saveSeed: 3614);
    expect(
      result.negotiations.any((item) => item.subjectId == player.id),
      isFalse,
    );
    expect(result.freeAgents, contains(player));
  });

  test(
    'weekly special market pass is disabled with resolveContractMarket false',
    () {
      final base = generator.generateLeague(seed: 3615);
      final player = _prospectPlayer(
        base,
        id: 'task36-disabled-undrafted',
        index: 9,
        yearsRemaining: 0,
      );
      final state = base.copyWith(
        currentWeek: 46,
        currentDay: 7,
        currentHour: null,
        freeAgents: [player],
        freshUndraftedPlayers: [_freshRecord(base, player.id)],
      );

      final result = DaySimulator()
          .simulateDay(state, saveSeed: 3615, resolveContractMarket: false)
          .league;
      expect(result.currentWeek, 47);
      expect(
        result.negotiations.any((item) => item.subjectId == player.id),
        isFalse,
      );
      expect(result.freshUndraftedPlayers, hasLength(1));
    },
  );
}
