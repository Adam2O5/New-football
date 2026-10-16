import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';

/// Covered seasons are authoritative; yearsRemaining is their compatibility
/// projection for existing UI/placeholder consumers, updated only here.
class ContractPeriodService {
  const ContractPeriodService({this.balance = BalanceConfig.defaults});
  final BalanceConfig balance;

  bool _sameReferences<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!identical(a[i], b[i])) return false;
    }
    return true;
  }

  int firstSeasonForSigning(int seasonYear, int week) =>
      seasonYear + (week > balance.calendar.playoffEndWeek ? 1 : 0);

  int _remaining(int first, int last, int seasonYear, int week) {
    final reference = seasonYear + (week > balance.calendar.draftWeek ? 1 : 0);
    return max(0, last - max(first, reference) + 1).toInt();
  }

  Contract playerContract(
    Contract contract, {
    required int seasonYear,
    required int week,
    bool initial = false,
  }) {
    if (contract.firstSeason == null && contract.lastSeason == null) {
      if (contract.yearsRemaining <= 0) return contract;
      final first = initial
          ? seasonYear
          : firstSeasonForSigning(seasonYear, week);
      return contract.copyWith(
        firstSeason: first,
        lastSeason: first + contract.yearsRemaining - 1,
      );
    }
    if (contract.firstSeason == null ||
        contract.lastSeason == null ||
        contract.lastSeason! < contract.firstSeason!) {
      throw StateError('Invalid player contract period');
    }
    final years = _remaining(
      contract.firstSeason!,
      contract.lastSeason!,
      seasonYear,
      week,
    );
    return years == contract.yearsRemaining
        ? contract
        : contract.copyWith(yearsRemaining: years);
  }

  StaffContract staffContract(
    StaffContract contract, {
    required int seasonYear,
    required int week,
    bool initial = false,
  }) {
    if (contract.firstSeason == null && contract.lastSeason == null) {
      if (contract.yearsRemaining <= 0) return contract;
      final first = initial
          ? seasonYear
          : firstSeasonForSigning(seasonYear, week);
      return contract.copyWith(
        firstSeason: first,
        lastSeason: first + contract.yearsRemaining - 1,
      );
    }
    if (contract.firstSeason == null ||
        contract.lastSeason == null ||
        contract.lastSeason! < contract.firstSeason!) {
      throw StateError('Invalid staff contract period');
    }
    final years = _remaining(
      contract.firstSeason!,
      contract.lastSeason!,
      seasonYear,
      week,
    );
    return years == contract.yearsRemaining
        ? contract
        : contract.copyWith(yearsRemaining: years);
  }

  LeagueState normalizeLeague(LeagueState league, {bool initial = false}) {
    final year = league.currentSeason.year;
    final week = league.currentWeek;
    Player normalizePlayer(Player player) {
      final contract = playerContract(
        player.contract,
        seasonYear: year,
        week: week,
        initial: initial,
      );
      return identical(contract, player.contract)
          ? player
          : player.copyWith(contract: contract).recalculatePointValue(balance);
    }

    StaffMember normalizeStaff(StaffMember member) {
      final contract = member.contract;
      if (contract == null) return member;
      final next = staffContract(
        contract,
        seasonYear: year,
        week: week,
        initial: initial,
      );
      return identical(next, contract)
          ? member
          : member.copyWith(contract: next);
    }

    final teams = league.teams.map((team) {
      final roster = team.roster.map(normalizePlayer).toList();
      final nextStaff = StaffRole.values.fold<TeamStaff>(team.staff, (
        staff,
        role,
      ) {
        final member = staff.canonicalMember(role);
        if (member == null) return staff;
        final next = normalizeStaff(member);
        return identical(next, member) ? staff : staff.withMember(role, next);
      });
      return _sameReferences(team.roster, roster) &&
              identical(team.staff, nextStaff)
          ? team
          : team.copyWith(roster: roster, staff: nextStaff);
    }).toList();
    final freeAgents = league.freeAgents.map(normalizePlayer).toList();
    final staffFreeAgents = league.canonicalStaffFreeAgents
        .map(normalizeStaff)
        .toList();
    if (_sameReferences(teams, league.teams) &&
        _sameReferences(freeAgents, league.freeAgents) &&
        _sameReferences(staffFreeAgents, league.staffFreeAgents)) {
      return league;
    }
    return league.copyWith(
      teams: teams,
      freeAgents: freeAgents,
      staffFreeAgents: staffFreeAgents,
    );
  }
}
