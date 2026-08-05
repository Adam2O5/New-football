import 'dart:math';

import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';

/// Service managing prospect/draft-class generation and related mechanics.
class ProspectService {
  ProspectService({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Generates a [DraftState] for the next year's draft class.
  /// Used both at league creation (seed) and during mid-season calendar event.
  DraftState generateNextDraftClass({required int currentYear}) {
    final draftClass = SeedDataGenerator(
      random: _random,
    ).generateDraftClass(year: currentYear + 1);
    return DraftState(
      year: currentYear + 1,
      draftClass: draftClass,
    );
  }

  /// Generates the next draft class AND extends each team's owned picks
  /// horizon by one year (7-year rolling window).
  /// Full logic previously in SeasonService.runNextClassGeneration.
  LeagueState generateNextClassForLeague(LeagueState league) {
    final nextDraftState = generateNextDraftClass(
      currentYear: league.currentSeason.year,
    );

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
      currentSeason: league.currentSeason.copyWith(
        nextDraftState: nextDraftState,
      ),
    );
  }
}
