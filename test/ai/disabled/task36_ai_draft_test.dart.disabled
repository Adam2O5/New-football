@Tags(['ai'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/ai/ai_draft_service.dart';
import 'package:new_football/core/ai/ai_evaluation_models.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/scouting.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/scouting_service.dart';
import 'package:new_football/core/services/season_service.dart';

void main() {
  final generator = SeedDataGenerator();

  test('coverage uses four base slots plus six per coverage star', () {
    final service = ScoutingService();
    expect(service.maxWatched(0), 4);
    expect(service.maxWatched(2.5), 19);
    expect(service.maxWatched(5), 34);
  });

  test('AI assignment is deterministic, capacity-limited and needs-aware', () {
    final league = generator.generateLeague(seed: 3601);
    final baseTeam = league.teams.firstWhere(
      (candidate) => candidate.ai != null,
    );
    final team = baseTeam.copyWith(
      staff: const TeamStaff(
        scout: StaffMember(
          id: 'task36-scout',
          name: 'Task 36 Scout',
          nationality: Nationality.poland,
          age: 40,
          role: StaffRole.scout,
          attributes: StaffAttributes(coverage: 5, evaluation: 5),
        ),
      ),
    );
    final draftClass = generator.generateDraftClass(year: 2036);
    final ai = AiDraftService();
    final first = ai.assignWatchlist(
      team: team,
      draftClass: draftClass,
      league: league,
      saveSeed: 3601,
      seasonYear: 2036,
    );
    final second = ai.assignWatchlist(
      team: team,
      draftClass: draftClass,
      league: league,
      saveSeed: 3601,
      seasonYear: 2036,
    );

    expect(first.watchlistProspectIds.length, 34);
    expect(first.watchlistProspectIds, second.watchlistProspectIds);
    expect(first.mockRanks, second.mockRanks);
    expect(first.watchlistProspectIds.toSet().length, 34);
    expect(first.mockRanks.length, draftClass.prospects.length);
  });

  test(
    'team without scout has no watchlist and drafts through public mock proxy',
    () {
      final league = generator.generateLeague(seed: 3602);
      final team = league.teams.first.copyWith(staff: const TeamStaff());
      final draftClass = generator.generateDraftClass(year: 2036);
      final ai = AiDraftService();
      final scouting = ai.assignWatchlist(
        team: team,
        draftClass: draftClass,
        league: league,
        saveSeed: 3602,
        seasonYear: 2036,
      );

      expect(scouting.watchlistProspectIds, isEmpty);
      expect(scouting.knowledge, isEmpty);

      final board = ai.buildBoard(
        team: team.copyWith(scouting: scouting),
        prospects: draftClass.prospects,
        pickNumber: 1,
        league: league,
        saveSeed: 3602,
        seasonYear: 2036,
      );
      expect(board, isNotEmpty);
      expect(board.first.tier, ScoutingTier.tier1);
    },
  );

  test(
    'board is deterministic and uses a scouting range instead of truth fields',
    () {
      final league = generator.generateLeague(seed: 3603);
      final team = league.teams.firstWhere((candidate) => candidate.ai != null);
      final draftClass = generator.generateDraftClass(year: 2036);
      final prospect = draftClass.prospects.first;
      final scouting = TeamScouting(
        watchlistProspectIds: [prospect.id],
        knowledge: [
          ScoutingKnowledge(
            prospectId: prospect.id,
            tier: ScoutingTier.tier4,
            estimatedOvrMin: 70,
            estimatedOvrMax: 80,
            estimatedPotentialMin: 3.0,
            estimatedPotentialMax: 4.0,
          ),
        ],
      );
      final ai = AiDraftService();
      final first = ai
          .buildBoard(
            team: team.copyWith(scouting: scouting),
            prospects: [prospect],
            pickNumber: 1,
            league: league,
            saveSeed: 3603,
            seasonYear: 2036,
          )
          .single;
      final second = ai
          .buildBoard(
            team: team.copyWith(scouting: scouting),
            prospects: [prospect],
            pickNumber: 1,
            league: league,
            saveSeed: 3603,
            seasonYear: 2036,
          )
          .single;

      expect(first.estimatedOvrMid, 75);
      expect(first.estimatedPotentialStars, 3.5);
      expect(first.score, second.score);
      expect(first.noise, second.noise);
      expect(first.score, isNot(prospect.projectedOverall()));
    },
  );

  test('late GK need receives the +20 bonus after pick 45', () {
    final league = generator.generateLeague(seed: 3604);
    final team = league.teams.firstWhere((candidate) => candidate.ai != null);
    final noGoalkeepers = team.copyWith(
      roster: team.roster
          .where((player) => player.position != Position.gk)
          .toList(),
    );
    final draftClass = generator.generateDraftClass(year: 2036);
    final goalkeeper = draftClass.prospects.first.copyWith(
      id: 'task36-goalkeeper',
      position: Position.gk,
    );
    final ai = AiDraftService();
    final board = ai.buildBoard(
      team: noGoalkeepers,
      prospects: [goalkeeper],
      pickNumber: 46,
      league: league,
      saveSeed: 3604,
      seasonYear: 2036,
    );

    expect(board.single.needBonus, 20);
  });

  test('Combine limit and monthly replacement follow scouting rules', () {
    final draftClass = generator.generateDraftClass(year: 2036);
    final ids = draftClass.prospects.take(8).map((p) => p.id).toList();
    final scouting = TeamScouting(
      watchlistProspectIds: ids,
      knowledge: [
        for (final id in ids)
          ScoutingKnowledge(
            prospectId: id,
            tier: id == ids.first ? ScoutingTier.tier5 : ScoutingTier.tier1,
          ),
      ],
      mockRanks: {
        for (var i = 0; i < draftClass.prospects.length; i++)
          draftClass.prospects[i].id: i + 1,
        'rising': 50,
      },
    );
    final service = ScoutingService();
    final report = service.runScoutReport(
      scouting,
      5.0,
      prospects: draftClass.prospects,
      rankedProspects: draftClass.prospects,
      seed: 3605,
    );
    expect(report.combineAssignedProspectIds.length, 2);
    expect(report.combineAssignedProspectIds, isNot(contains(ids.first)));

    final rising = draftClass.prospects.first.copyWith(id: 'rising');
    final reordered = [rising, ...draftClass.prospects];
    final replaced = service.updateMonthlyWatchlist(
      scouting,
      rankedProspects: reordered,
      coverageStars: 5.0,
      seed: 3605,
      replacementProbability: 1.0,
    );
    expect(replaced.watchlistProspectIds, contains('rising'));
    expect(replaced.watchlistProspectIds.length, 8);
  });

  test('draft lifecycle uses AI policy and keeps legal rights state', () {
    final season = SeasonService();
    var league = generator
        .generateLeague(seed: 3606)
        .copyWith(playerTeamId: null);
    league = season.runLottery(league);
    final before = league.currentSeason.draftState!;
    league = season.advanceDraft(league, saveSeed: 3606);

    expect(
      league.currentSeason.draftState!.currentPickIndex,
      before.order.length,
    );
    expect(league.currentSeason.draftState!.completedPicks.length, 90);
    expect(league.freeAgents.length, 30);
    expect(
      league.draftedRights.every(
        (right) => league.teams.any((team) => team.id == right.ownerTeamId),
      ),
      isTrue,
    );
  });

  test('undrafted policy exposes fixed minimum-salary two-year offer', () {
    final league = generator.generateLeague(seed: 3607);
    final team = league.teams.firstWhere((candidate) => candidate.ai != null);
    final ai = AiDraftService();
    final decision = ai.undraftedSigningDecision(
      team: team,
      prospectId: 'undrafted-1',
      needBand: AiNeedBand.belowTarget,
      saveSeed: 3607,
      seasonYear: 2036,
    );

    expect(decision.salary, BalanceConfig.defaults.salaryCap.minSalary);
    expect(decision.years, 2);
    expect(decision.probability, 0.05);
  });

  test('monthly scouting refresh runs in DaySimulator and emits a report', () {
    final base = generator.generateLeague(seed: 3608);
    final draftClass = generator.generateDraftClass(
      year: base.currentSeason.year,
    );
    final ranked = [...draftClass.prospects]
      ..sort((a, b) {
        final grade = b.scoutGrade.compareTo(a.scoutGrade);
        return grade != 0 ? grade : a.id.compareTo(b.id);
      });
    final rising = ranked.first;
    final watched = ranked.last;
    final previousRanks = {
      for (var i = 0; i < ranked.length; i++) ranked[i].id: i + 1,
      rising.id: 40,
    };
    final aiTeam = base.teams.firstWhere((team) => team.ai != null);
    final configuredTeam = aiTeam.copyWith(
      staff: const TeamStaff(
        scout: StaffMember(
          id: 'task36-monthly-scout',
          name: 'Monthly Scout',
          nationality: Nationality.poland,
          age: 40,
          role: StaffRole.scout,
          attributes: StaffAttributes(coverage: 5, evaluation: 5),
        ),
      ),
      scouting: TeamScouting(
        watchlistProspectIds: [watched.id],
        knowledge: [ScoutingKnowledge(prospectId: watched.id)],
        mockRanks: previousRanks,
      ),
    );
    var league = base.copyWith(
      currentWeek: 5,
      currentDay: 1,
      teams: [
        for (final team in base.teams)
          team.id == configuredTeam.id ? configuredTeam : team,
      ],
      currentSeason: base.currentSeason.copyWith(
        draftState: DraftState(year: draftClass.year, draftClass: draftClass),
      ),
    );

    league = DaySimulator()
        .simulateDay(league, saveSeed: 3608, resolveContractMarket: false)
        .league;

    final updatedTeam = league.teams.firstWhere(
      (team) => team.id == configuredTeam.id,
    );
    expect(updatedTeam.scouting.mockRanks[rising.id], 1);
    expect(
      league.inbox.messages.any(
        (message) =>
            message.type == MessageType.scoutReport &&
            message.kind == 'monthly',
      ),
      isTrue,
    );
  });
}
