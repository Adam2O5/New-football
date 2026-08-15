import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/ai/team_ai_service.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/development_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/core/services/trade_service.dart';

void main() {
  final league = SeedDataGenerator().generateLeague(seed: 7);

  test('SalaryCapService snapshot under cap for seeded teams', () {
    const svc = SalaryCapService();
    final snap = svc.snapshot(league.teams.first);
    expect(snap.payroll, greaterThan(0));
    expect(snap.cap, 300000000);
  });

  test('TradeService rejects illegal roster after trade dump', () {
    final a = league.teams[0];
    final b = league.teams[1];
    final svc = TradeService();
    // Try to send almost entire roster A -> B
    final assets = a.roster
        .take(15)
        .map((p) => TradeAsset.player(p.id))
        .toList();
    final proposal = TradeProposal(
      teamAId: a.id,
      teamBId: b.id,
      assetsFromA: assets,
      assetsFromB: const [],
    );
    final validation = svc.validate(a, b, proposal);
    expect(validation.ok, isFalse);
  });

  test('ContractService evaluates strong offer as accept', () {
    final player = league.teams[0].roster.first;
    final svc = ContractService();
    final want = svc.playerWant(player);
    final reaction = svc.evaluate(
      player,
      ContractOffer(salary: (want * 1.2).round(), years: 4),
    );
    expect(reaction, ContractReaction.accept);
  });

  test('TeamAiService autoSelectLineup includes GK', () {
    final ai = TeamAiService();
    final team = ai.autoSelectLineup(league.teams[2]);
    expect(team.lineupPlayerIds.length, 11);
    final xi = team.startingEleven;
    expect(xi.any((p) => p.position == Position.gk), isTrue);
  });

  test('TradeService rejects trades outside the trade window', () {
    final a = league.teams[0];
    final b = league.teams[1];
    final svc = TradeService();
    final proposal = TradeProposal(
      teamAId: a.id,
      teamBId: b.id,
      assetsFromA: [TradeAsset.player(a.roster.first.id)],
      assetsFromB: [TradeAsset.player(b.roster.first.id)],
    );
    // Week 30: after the trade deadline (23), before the window reopens (44).
    final validation = svc.validate(a, b, proposal, currentWeek: 30);
    expect(validation.ok, isFalse);
    expect(validation.reason, contains('zamknięte'));
  });

  test(
    'DaySimulator ticks player development weekly, not just at rollover',
    () {
      final sim = DaySimulator();
      final team = league.teams.first;
      // No player team, so fixtures never pause the sim before the
      // week-boundary development tick runs.
      var state = league.copyWith(
        currentWeek: 5,
        currentDay: 1,
        playerTeamId: null,
      );
      final before = state
          .teamById(team.id)!
          .roster
          .fold<double>(0, (sum, p) => sum + p.hidden.overallProgress);

      // Four full weeks — enough for per-player rounding noise to average
      // out across a ~25-player roster.
      for (var i = 0; i < 28; i++) {
        state = sim.simulateDay(state).league;
      }

      final after = state
          .teamById(team.id)!
          .roster
          .fold<double>(0, (sum, p) => sum + p.hidden.overallProgress);
      expect(after, greaterThan(before));
    },
  );

  test('DevelopmentService.developTeam applies a single weekly delta', () {
    final dev = DevelopmentService();
    final team = league.teams.first;
    final before = team.roster.map((p) => p.hidden.overallProgress).toList();
    final after = dev
        .developTeam(team)
        .roster
        .map((p) => p.hidden.overallProgress)
        .toList();
    // At least the young/growing players should have moved (non-decreasing
    // for everyone isn't guaranteed for veterans, but some change happens).
    expect(after, isNot(equals(before)));
  });
}
