import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/services/mock_draft_service.dart';

/// Service managing prospect/draft-class generation and related mechanics.
class ProspectService {
  ProspectService({
    Random? random,
    BalanceConfig balance = BalanceConfig.defaults,
    MockDraftService? mockDraftService,
  }) : _random = random ?? Random(),
       _mockDraftService =
           mockDraftService ?? MockDraftService(balance: balance);

  final Random _random;
  final MockDraftService _mockDraftService;

  /// Generates a [DraftState] for the next year's draft class, including the
  /// mock wstępny (`draft.md` §"Mock wstępny (po generacji klasy)") that
  /// establishes the initial displayed board. `seed` should be the save's
  /// deterministic root when available, so the mock is reproducible; falls
  /// back to the injected `_random` for legacy/test callers.
  /// Used both at league creation (seed) and during mid-season calendar event.
  DraftState generateNextDraftClass({required int currentYear, int? seed}) {
    final draftClass = SeedDataGenerator(
      random: _random,
    ).generateDraftClass(year: currentYear + 1, seed: seed);
    final trueBoard = _mockDraftService.trueBoard(draftClass.prospects);
    final initialMock = _mockDraftService.generateInitialMock(
      trueBoard,
      seed: seed,
      seasonYear: currentYear + 1,
    );
    return DraftState(
      year: currentYear + 1,
      draftClass: draftClass,
      mockDraftBoard: initialMock,
    );
  }

  /// Generates the next draft class AND extends each team's owned picks
  /// horizon by one year (7-year rolling window).
  /// Full logic previously in SeasonService.runNextClassGeneration.
  LeagueState generateNextClassForLeague(LeagueState league, {int? seed}) {
    final newDraftState = generateNextDraftClass(
      currentYear: league.currentSeason.year,
      seed: seed,
    );

    final oldDraftState = league.currentSeason.draftState;

    final currentYear = league.currentSeason.year;
    final horizonYear = currentYear + 7;
    final teams = league.teams.map((t) {
      final newPicks = [
        for (var round = 1; round <= 3; round++)
          DraftPick(
            id: 'pick_${t.id}_${horizonYear}_r$round',
            year: horizonYear,
            round: round,
            teamId: t.id,
            originalTeamId: t.id,
          ).recalculateTradeValue(currentYear: currentYear),
      ];
      return t.copyWith(ownedPicks: [...t.ownedPicks, ...newPicks]);
    }).toList();

    return league.copyWith(
      teams: teams,
      lastCompletedDraft: oldDraftState == null
          ? league.lastCompletedDraft
          : CompletedDraft(
              year: oldDraftState.year,
              completedPicks: oldDraftState.completedPicks,
            ),
      currentSeason: league.currentSeason.copyWith(
        draftState: newDraftState,
        nextClassGenerationDone: true,
      ),
    );
  }
}
