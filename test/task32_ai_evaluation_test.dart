import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/ai/ai_evaluation_context.dart';
import 'package:new_football/core/ai/ai_evaluation_models.dart';
import 'package:new_football/core/ai/ai_evaluation_service.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/team_event_state.dart';
import 'package:new_football/core/random/seeds.dart';
import 'package:new_football/core/services/game_factory.dart';

void main() {
  late GameSave save;
  const evaluator = AiEvaluationService();

  setUpAll(() {
    save = GameFactory().create(
      const NewGameRequest(
        saveName: 'Task 32 evaluator',
        playerTeamId: 'team_europe_0',
        seed: 3201,
      ),
    );
  });

  test('roster balance exposes seven groups and a critical empty-GK gap', () {
    final baseTeam = save.leagueState.teamById('team_europe_0')!;
    final team = baseTeam.copyWith(
      roster: baseTeam.roster
          .where((player) => player.position != Position.gk)
          .toList(),
    );
    final league = save.leagueState.copyWith(
      teams: save.leagueState.teams
          .map((candidate) => candidate.id == team.id ? team : candidate)
          .toList(),
    );
    final context = evaluator.contextForTeam(team: team, league: league);
    final needs = evaluator.rosterNeeds(context);
    final gk = needs.firstWhere(
      (need) => need.definition.group == AiRosterGroup.gk,
    );

    expect(needs, hasLength(7));
    expect(
      needs.map((need) => need.definition.target).reduce((a, b) => a + b),
      25,
    );
    expect(gk.count, 0);
    expect(gk.needScore, greaterThanOrEqualTo(40));
    expect(gk.isCritical, isTrue);
  });

  test(
    'status and age multipliers favor young rebuild assets and prime elite assets',
    () {
      final team = save.leagueState.teamById('team_europe_0')!;
      final player = team.roster.first;
      final young = player.copyWith(age: 22);
      final prime = player.copyWith(age: 30);
      final rebuild = _context(
        team,
        status: TeamStatus.rebuild,
        expectedRank: 30,
      );
      final elite = _context(team, status: TeamStatus.elite, expectedRank: 1);

      final youngValue = evaluator.evaluatePlayer(young, rebuild);
      final primeValue = evaluator.evaluatePlayer(prime, elite);

      expect(youngValue.statusAgeMult, 1.30);
      expect(primeValue.statusAgeMult, 1.15);
      expect(youngValue.value, greaterThan(primeValue.value));
    },
  );

  test('all documented context multipliers compose from public state', () {
    final team = save.leagueState.teamById('team_europe_0')!;
    final player = team.roster.first.copyWith(
      state: team.roster.first.state.copyWith(
        injury: const Injury(
          id: 'task32-major',
          group: InjuryGroup.headFace,
          type: InjuryType.major,
          daysTotal: 30,
          daysRemaining: 20,
        ),
      ),
      contract: team.roster.first.contract.copyWith(
        salary: 100000000,
        yearsRemaining: 3,
        noTradeClause: true,
      ),
    );
    final source = team.copyWith(
      eventState: team.eventState.copyWith(
        transferSituations: [
          TeamTransferSituation(
            id: 'task32-transfer',
            playerId: player.id,
            kind: 'transferRequest',
            createdSeasonYear: save.leagueState.currentSeason.year,
            createdWeek: 1,
          ),
        ],
      ),
    );
    final valuation = evaluator.evaluatePlayer(
      player,
      _context(team),
      sourceTeam: source,
    );

    final expiring = player.copyWith(
      contract: player.contract.copyWith(
        salary: 1000000,
        yearsRemaining: 1,
        noTradeClause: false,
        isRookieScale: false,
      ),
    );
    final expiringValuation = evaluator.evaluatePlayer(
      expiring,
      _context(team),
      sourceTeam: source,
    );
    final rookie = player.copyWith(
      contract: player.contract.copyWith(
        salary: 1000000,
        yearsRemaining: 4,
        noTradeClause: false,
        isRookieScale: true,
      ),
    );
    final rookieValuation = evaluator.evaluatePlayer(
      rookie,
      _context(team),
      sourceTeam: source,
    );

    expect(expiringValuation.contextFactors, contains('expiringContract'));
    expect(rookieValuation.contextFactors, contains('rookieScaleYearOne'));
    expect(
      valuation.contextFactors,
      containsAll(<String>[
        'transferRequest',
        'majorInjury',
        'ntc',
        'overpaidContract',
      ]),
    );
    expect(valuation.contextMult, lessThan(0.90));
    expect(valuation.contractDragClass, AiContractDragClass.toxic);
  });

  test('hidden traits do not change a foreign-player valuation', () {
    final team = save.leagueState.teamById('team_europe_0')!;
    final player = team.roster.first;
    final changedHidden = player.copyWith(
      hidden: player.hidden.copyWith(
        injuryProne: 10,
        determination: 1,
        overallProgress: 99,
        growthRate: 4.0,
        developmentOutcome: DevelopmentOutcome.under,
        developmentCeilingStars: 0.5,
      ),
    );
    final context = _context(team);

    final original = evaluator.evaluatePlayer(player, context);
    final changed = evaluator.evaluatePlayer(changedHidden, context);

    expect(changed.value, closeTo(original.value, 0.000001));
    expect(changed.contextMult, original.contextMult);
  });

  test(
    'future lottery pick is smoothed and not valued as a guaranteed first pick',
    () {
      final team = save.leagueState.teamById('team_europe_0')!;
      final context = _context(
        team,
        status: TeamStatus.rebuild,
        expectedRank: 30,
      );
      final future = DraftPick(
        id: 'task32-future-r1',
        year: 2027,
        round: 1,
        teamId: team.id,
        originalTeamId: team.id,
      );
      final first = future.copyWith(id: 'task32-first', pickNumber: 1);

      final futureValue = evaluator.evaluatePick(future, context);
      final firstValue = evaluator.evaluatePick(first, context);

      expect(futureValue.projectedSlot, closeTo(3.5, 0.000001));
      expect(futureValue.value, lessThan(firstValue.value));
    },
  );

  test('drafted rights are valued as the matching pick multiplied by 0.85', () {
    final team = save.leagueState.teamById('team_europe_0')!;
    final context = _context(team, expectedRank: 15);
    final pick = DraftPick(
      id: 'task32-pick',
      year: 2026,
      round: 1,
      pickNumber: 8,
      teamId: team.id,
      originalTeamId: team.id,
    );
    final rights = DraftedPlayerRights(
      id: 'task32-rights',
      ownerTeamId: team.id,
      player: team.roster.first,
      draftYear: 2026,
      pickNumber: 8,
    );

    final pickValue = evaluator.evaluatePick(pick, context);
    final rightsValue = evaluator.evaluateRights(rights, context);

    expect(rightsValue.rightsMult, 0.85);
    expect(rightsValue.value, closeTo(pickValue.value * 0.85, 0.000001));
  });

  test('package noise is deterministic and applied once', () {
    final team = save.leagueState.teamById('team_europe_0')!;
    final context = _context(
      team,
      status: TeamStatus.contender,
      expectedRank: 5,
      saveSeed: 77,
      seasonYear: 2026,
      week: 12,
    );
    final asset = evaluator.evaluatePlayer(team.roster.first, context);
    final first = evaluator.evaluatePackage(
      recipient: context,
      incoming: [asset],
    );
    final second = evaluator.evaluatePackage(
      recipient: context,
      incoming: [asset],
    );
    final otherDecision = evaluator.evaluatePackage(
      recipient: context.withDecision(decisionType: DecisionType.faOffer),
      incoming: [asset],
    );

    expect(second.surplusPct, first.surplusPct);
    expect(second.evaluationNoisePp, first.evaluationNoisePp);
    expect(otherDecision.evaluationNoisePp, isNot(first.evaluationNoisePp));
  });

  test('crossing the first apron exposes the status payroll penalty', () {
    final team = save.leagueState.teamById('team_europe_0')!;
    final context = _context(
      team,
      status: TeamStatus.contender,
      expectedRank: 5,
    );
    final package = evaluator.evaluatePackage(
      recipient: context,
      currentPayroll: 350000000,
      resultingPayroll: 400000000,
    );

    expect(package.apronPenalty, 25);
    expect(package.resultingPayroll, 400000000);
    expect(package.secondApronBlocked, isFalse);
  });

  test('contract drag uses the shared estimated salary helper', () {
    final team = save.leagueState.teamById('team_europe_0')!;
    final player = team.roster.first.copyWith(
      contract: team.roster.first.contract.copyWith(
        salary: 80000000,
        yearsRemaining: 4,
      ),
    );

    final drag = evaluator.contractDrag(player);

    expect(drag, greaterThan(60));
    expect(evaluator.contractDragClass(player), AiContractDragClass.toxic);
  });
}

AiEvaluationContext _context(
  Team team, {
  TeamStatus status = TeamStatus.pretender,
  int expectedRank = 15,
  int saveSeed = 0,
  int seasonYear = 2026,
  int week = 1,
}) => AiEvaluationContext(
  team: team,
  teamStatus: status,
  expectedRank: expectedRank,
  leagueTeams: [team],
  saveSeed: saveSeed,
  seasonYear: seasonYear,
  week: week,
);
