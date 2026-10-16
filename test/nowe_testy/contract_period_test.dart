import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/contract_period_service.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/season_service.dart';

import 'support/game_fixtures.dart';

void main() {
  const periods = ContractPeriodService();
  for (final entry in [
    (1, 2026),
    (43, 2026),
    (44, 2027),
    (45, 2027),
    (46, 2027),
    (47, 2027),
    (48, 2027),
    (52, 2027),
  ]) {
    test('one-year signing in week ${entry.$1} covers ${entry.$2}', () {
      final contract = periods.playerContract(
        const Contract(salary: 1000000, yearsRemaining: 1),
        seasonYear: 2026,
        week: entry.$1,
      );
      expect(
        (contract.firstSeason, contract.lastSeason, contract.yearsRemaining),
        (entry.$2, entry.$2, 1),
      );
      expect(
        Contract.fromJson(
          jsonDecode(jsonEncode(contract.toJson())) as Map<String, dynamic>,
        ),
        contract,
      );
      final staff = periods.staffContract(
        const StaffContract(salary: 1000000, yearsRemaining: 1),
        seasonYear: 2026,
        week: entry.$1,
      );
      expect(
        (staff.firstSeason, staff.lastSeason, staff.yearsRemaining),
        (entry.$2, entry.$2, 1),
      );
    });
  }
  test(
    'canonical dates repair the projection; rollover does not shorten a future signing',
    () {
      final signed = periods.playerContract(
        const Contract(salary: 1000000, yearsRemaining: 1),
        seasonYear: 2026,
        week: 47,
      );
      expect(
        periods
            .playerContract(
              signed.copyWith(yearsRemaining: 9),
              seasonYear: 2027,
              week: 1,
            )
            .yearsRemaining,
        1,
      );
      final initial = periods.playerContract(
        const Contract(salary: 1000000, yearsRemaining: 1),
        seasonYear: 2026,
        week: 1,
        initial: true,
      );
      expect(
        periods
            .playerContract(initial, seasonYear: 2026, week: 46)
            .yearsRemaining,
        1,
      );
      expect(
        periods
            .playerContract(initial, seasonYear: 2026, week: 47)
            .yearsRemaining,
        0,
      );
    },
  );
  test(
    'old contracts leave at week 47, future contracts survive year rollover',
    () {
      final initial = seededLeague();
      final base = initial.copyWith(
        teams: initial.teams.map((t) => t.copyWith(ai: null)).toList(),
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
      final input = base
          .updateTeam(team.copyWith(roster: [old, future]))
          .copyWith(currentWeek: 47);
      final service = SeasonService();
      final expired = service.expireContracts(input);
      expect(expired.playerTeam!.roster.map((p) => p.id).toList(), [future.id]);
      expect(expired.freeAgents.where((p) => p.id == old.id), hasLength(1));
      expect(
        service
            .expireContracts(expired)
            .freeAgents
            .where((p) => p.id == old.id),
        hasLength(1),
      );
      final rolled = service.rolloverSeason(
        expired.copyWith(currentWeek: 52, currentDay: 7),
      );
      expect(rolled.playerTeam!.roster.single.contract.yearsRemaining, 1);
      expect(rolled.playerTeam!.roster.single.contract.firstSeason, 2027);
    },
  );
  test(
    'central signing sets a future period and updates valuation once signed',
    () {
      final base = controllerSave().leagueState;
      final player = base.freeAgents.single;
      final signed = ContractService().signPlayer(
        team: base.playerTeam!,
        player: player,
        offer: const ContractOffer(salary: 1000000, years: 1),
        seasonYear: 2026,
        week: 47,
      )!;
      final added = signed.roster.last;
      expect(added.contract.firstSeason, 2027);
      expect(added.pointValue, added.recalculatePointValue().pointValue);
    },
  );
}
