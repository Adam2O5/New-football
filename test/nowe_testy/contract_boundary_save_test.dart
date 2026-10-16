import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/day_pipeline.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/season_service.dart';
import 'package:new_football/core/tactics/lineup_slots.dart';
import 'package:new_football/data/save_repository.dart';

import 'support/game_fixtures.dart';

class _BoundaryMarket extends ContractMarketService {
  _BoundaryMarket(this.expiringPlayerId);
  final String expiringPlayerId;
  bool sawExpiredPlayer = false;

  @override
  LeagueState resolveDay(LeagueState league, {int saveSeed = 0}) => league;

  @override
  LeagueState weeklyTick(LeagueState league, {int saveSeed = 0}) {
    sawExpiredPlayer = league.freeAgents.any((p) => p.id == expiringPlayerId);
    return league;
  }
}

void main() {
  test(
    'disk reload preserves player/staff periods and slots across 46/47 and 52/1',
    () async {
      final initial = seededLeague();
      final base = initial.copyWith(
        teams: initial.teams.map((t) => t.copyWith(ai: null)).toList(),
        currentWeek: 46,
        currentDay: 7,
      );
      final team = base.playerTeam!;
      final old = team.roster.first.copyWith(
        contract: const Contract(
          salary: 1000000,
          yearsRemaining: 1,
          firstSeason: 2026,
          lastSeason: 2026,
        ),
      );
      final future = team.roster[1].copyWith(
        contract: const Contract(
          salary: 1000000,
          yearsRemaining: 1,
          firstSeason: 2027,
          lastSeason: 2027,
        ),
      );
      const oldCoach = StaffMember(
        id: 'boundary-old-coach',
        name: 'Old Coach',
        nationality: Nationality.poland,
        age: 40,
        role: StaffRole.headCoach,
        contract: StaffContract(
          salary: 1000000,
          yearsRemaining: 1,
          firstSeason: 2026,
          lastSeason: 2026,
        ),
      );
      final futureScout = oldCoach.copyWith(
        id: 'boundary-future-scout',
        role: StaffRole.scout,
        contract: oldCoach.contract!.copyWith(
          firstSeason: 2027,
          lastSeason: 2027,
        ),
      );
      var state = reconcileLeagueLineups(
        base.updateTeam(
          team.copyWith(
            roster: [old, future],
            lineupPlayerIds: [old.id, future.id],
            benchPlayerIds: [],
            lineupSlots: {},
            staff: TeamStaff(headCoach: oldCoach, scout: futureScout),
          ),
        ),
      );
      final directory = await Directory.systemTemp.createTemp(
        'football-periods-',
      );
      try {
        Future<LeagueState> restart(LeagueState league) async {
          final save = saveForLeague(league, id: 'period-boundaries');
          await SaveRepository(overrideDirectory: directory).save(save);
          final loaded = await SaveRepository(
            overrideDirectory: directory,
          ).load(save.meta.id);
          expect(loaded.leagueState, league);
          return loaded.leagueState;
        }

        state = await restart(state);
        expect(state.playerTeam!.staff.headCoach!.contract!.yearsRemaining, 1);
        final market = _BoundaryMarket(old.id);
        state = DayPipeline(contractMarket: market)
            .advanceDay(
              state,
              saveSeed: fixtureSeed,
              blockOnPendingUrgent: false,
            )
            .league;
        expect(market.sawExpiredPlayer, isTrue);
        state = await restart(state);
        expect((state.currentWeek, state.currentDay), (47, 1));
        expect(state.playerTeam!.roster.map((p) => p.id), [future.id]);
        expect(state.playerTeam!.staff.headCoach, isNull);
        expect(
          state.staffFreeAgents.where((m) => m.id == oldCoach.id),
          hasLength(1),
        );
        expect(state.playerTeam!.staff.scout!.contract!.yearsRemaining, 1);
        expect(state.playerTeam!.lineupSlots.values, [future.id]);

        state = await restart(state.copyWith(currentWeek: 52, currentDay: 7));
        final slots = state.playerTeam!.lineupSlots;
        state = reconcileLeagueLineups(SeasonService().rolloverSeason(state));
        state = await restart(state);
        expect(
          (state.currentSeason.year, state.currentWeek, state.currentDay),
          (2027, 1, 1),
        );
        final contract = state.playerTeam!.roster.single.contract;
        expect(
          (contract.firstSeason, contract.lastSeason, contract.yearsRemaining),
          (2027, 2027, 1),
        );
        final staffContract = state.playerTeam!.staff.scout!.contract!;
        expect(
          (
            staffContract.firstSeason,
            staffContract.lastSeason,
            staffContract.yearsRemaining,
          ),
          (2027, 2027, 1),
        );
        expect(state.playerTeam!.lineupSlots, slots);
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );
}
