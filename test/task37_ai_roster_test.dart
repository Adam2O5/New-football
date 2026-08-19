import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/ai/ai_roster_management_service.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_event_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/team_event_state.dart';

void main() {
  final seeded = SeedDataGenerator(
    random: null,
  ).generateLeague(year: 2026, playerTeamId: 'team_europe_0', seed: 3701);
  final aiSource = seeded.teams.firstWhere(
    (team) => team.id == 'team_europe_1',
  );
  final aiPartner = seeded.teams.firstWhere(
    (team) => team.id == 'team_europe_10',
  );

  Player playerFrom(
    Player source,
    String id, {
    Position? position,
    int salary = 1000000,
    int yearsRemaining = 1,
    int? pointValue,
    Injury? injury,
    PlayerEventState? eventState,
  }) {
    return source.copyWith(
      id: id,
      name: id,
      position: position ?? source.position,
      pointValue: pointValue ?? source.pointValue,
      contract: source.contract.copyWith(
        salary: salary,
        yearsRemaining: yearsRemaining,
        noTradeClause: false,
        blockedTeamIds: const [],
      ),
      state: source.state.copyWith(
        injury: injury,
        suspensionGamesRemaining: 0,
        eventState: eventState ?? source.state.eventState,
      ),
    );
  }

  List<Player> copiesFor(
    List<Player> sources,
    int count,
    String prefix, {
    int salary = 1000000,
    int? pointValue,
  }) {
    return [
      for (var index = 0; index < count; index++)
        playerFrom(
          sources[index % sources.length],
          '$prefix-$index',
          salary: salary,
          pointValue: pointValue,
        ),
    ];
  }

  Team withRoster(
    Team source,
    List<Player> roster, {
    List<String>? lineupPlayerIds,
    TeamEventState eventState = const TeamEventState(),
  }) {
    final lineup =
        lineupPlayerIds ?? roster.take(11).map((player) => player.id).toList();
    return source
        .copyWith(
          roster: roster,
          lineupPlayerIds: lineup,
          benchPlayerIds: roster
              .where((player) => !lineup.contains(player.id))
              .take(7)
              .map((player) => player.id)
              .toList(),
          eventState: eventState,
        )
        .updatePayroll();
  }

  LeagueState stateFor(
    Team target, {
    Team? partner,
    List<Player> freeAgents = const [],
    List<DraftedPlayerRights> draftedRights = const [],
    int week = 1,
    int day = 1,
  }) {
    final replacements = <String, Team>{
      target.id: target,
      if (partner != null) partner.id: partner,
    };
    return seeded.copyWith(
      teams: seeded.teams.map((team) => replacements[team.id] ?? team).toList(),
      playerTeamId: 'team_europe_0',
      currentWeek: week,
      currentDay: day,
      currentSeason: seeded.currentSeason.copyWith(phase: SeasonPhase.regular),
      freeAgents: freeAgents,
      draftedRights: draftedRights,
      inbox: const Inbox(),
    );
  }

  test('AI fills a roster below 20 through emergency FA and is idempotent', () {
    final underRoster = withRoster(aiSource, [
      for (var index = 0; index < 19; index++)
        playerFrom(aiSource.roster[index], 'under-$index'),
    ]);
    final freeAgents = [
      for (final position in Position.values)
        playerFrom(
          aiSource.roster.firstWhere(
            (player) => player.position == position,
            orElse: () => aiSource.roster.first,
          ),
          'fa-${position.name}',
          position: position,
        ),
    ];
    final state = stateFor(underRoster, freeAgents: freeAgents);
    final service = AiRosterManagementService();

    final repaired = service.ensureRosterSafety(state, saveSeed: 3702);
    final repairedTeam = repaired.teamById(underRoster.id)!;

    expect(repairedTeam.roster, hasLength(20));
    expect(
      repairedTeam.roster.any((player) => player.id.startsWith('fa-')),
      isTrue,
    );
    expect(repaired.freeAgents, hasLength(freeAgents.length - 1));
    expect(
      repairedTeam.roster.every((player) => player.contract.salary >= 1000000),
      isTrue,
    );

    final replay = service.ensureRosterSafety(repaired, saveSeed: 3702);
    expect(replay, repaired);
  });

  test('major GK injury gets one same-day goalkeeper signing', () {
    final goalkeeper = aiSource.roster.firstWhere(
      (player) => player.position == Position.gk,
    );
    final nonGoalkeepers = aiSource.roster
        .where((player) => player.position != Position.gk)
        .toList();
    final injury = const Injury(
      id: 'task37-gk-major',
      group: InjuryGroup.legMuscles,
      type: InjuryType.major,
      daysTotal: 30,
      daysRemaining: 30,
    );
    final roster = [
      playerFrom(
        goalkeeper,
        'injured-gk',
        injury: injury,
        position: Position.gk,
      ),
      ...copiesFor(nonGoalkeepers, 24, 'gk-team', salary: 1000000),
    ];
    final team = withRoster(
      aiSource,
      roster,
      lineupPlayerIds: [
        roster.first.id,
        ...roster.skip(1).take(10).map((p) => p.id),
      ],
    );
    final emergencyGk = playerFrom(
      goalkeeper,
      'fa-emergency-gk',
      position: Position.gk,
    );
    final balance = BalanceConfig(
      ai: AiBalance(
        pRosterMajorGk: 1.0,
        pRosterMajorInjury: 0.0,
        pRosterAvailableDepth: 0.0,
      ),
    );
    final service = AiRosterManagementService(balance: balance);

    final repaired = service.ensureRosterSafety(
      stateFor(team, freeAgents: [emergencyGk]),
      saveSeed: 3703,
    );
    final repairedTeam = repaired.teamById(team.id)!;

    expect(repairedTeam.roster, hasLength(26));
    expect(
      repairedTeam.roster.any((player) => player.id == emergencyGk.id),
      isTrue,
    );
    expect(
      repairedTeam.eventState.hasSeasonFlag(
        'aiRosterMajor:injured-gk:task37-gk-major',
        2026,
      ),
      isTrue,
    );
    expect(
      repairedTeam.roster
          .firstWhere((player) => player.id == 'injured-gk')
          .state
          .injury,
      injury,
    );
  });

  test('available depth at or below 13 receives an available emergency FA', () {
    final minorInjury = (int index) => Injury(
      id: 'task37-minor-$index',
      group: InjuryGroup.legMuscles,
      type: InjuryType.minor,
      daysTotal: 7,
      daysRemaining: 7,
    );
    final roster = [
      for (var index = 0; index < aiSource.roster.length; index++)
        playerFrom(
          aiSource.roster[index],
          'depth-$index',
          injury: index < 16 ? minorInjury(index) : null,
        ),
    ];
    final team = withRoster(aiSource, roster);
    final candidate = playerFrom(
      aiSource.roster.first,
      'fa-depth-repair',
      position: aiSource.roster.first.position,
    );
    final balance = BalanceConfig(
      ai: AiBalance(
        pRosterMajorGk: 0.0,
        pRosterMajorInjury: 0.0,
        pRosterAvailableDepth: 1.0,
      ),
    );
    final service = AiRosterManagementService(balance: balance);

    final repaired = service.ensureRosterSafety(
      stateFor(team, freeAgents: [candidate]),
      saveSeed: 3704,
    );
    final repairedTeam = repaired.teamById(team.id)!;

    expect(repairedTeam.availablePlayers, hasLength(11));
    expect(repairedTeam.roster, hasLength(aiSource.roster.length + 1));
    expect(
      repairedTeam.roster.any((player) => player.id == candidate.id),
      isTrue,
    );
  });

  test(
    'a full roster never releases a player and keeps draft rights untouched',
    () {
      final roster = copiesFor(aiSource.roster, 30, 'full', salary: 1000000);
      final team = withRoster(aiSource, roster);
      final right = DraftedPlayerRights(
        id: 'task37-right',
        ownerTeamId: team.id,
        player: roster.first,
        draftYear: 2027,
        pickNumber: 1,
      );
      final state = stateFor(team, draftedRights: [right]);
      final service = AiRosterManagementService(
        balance: BalanceConfig(ai: AiBalance(pRosterSpaceTrade: 0.0)),
      );

      final repaired = service.ensureRosterSafety(state, saveSeed: 3705);

      expect(repaired.teamById(team.id)!.roster, hasLength(30));
      expect(repaired.teamById(team.id)!.roster.map((p) => p.id).toSet(), {
        for (final player in roster) player.id,
      });
      expect(repaired.draftedRights, [right]);
    },
  );

  test(
    'a critical full-roster gap can be repaired by a legal 2-for-1 trade',
    () {
      final goalkeeper = aiSource.roster.firstWhere(
        (player) => player.position == Position.gk,
      );
      final nonGoalkeepers = aiSource.roster
          .where((player) => player.position != Position.gk)
          .toList();
      final sourceRoster = [
        playerFrom(
          goalkeeper,
          'trade-source-gk',
          position: Position.gk,
          injury: const Injury(
            id: 'task37-trade-gk',
            group: InjuryGroup.knees,
            type: InjuryType.major,
            daysTotal: 30,
            daysRemaining: 30,
          ),
          salary: 1000000,
          pointValue: 100,
        ),
        ...copiesFor(
          nonGoalkeepers,
          29,
          'trade-source',
          salary: 1000000,
          pointValue: 100,
        ),
      ];
      final sourceTeam = withRoster(
        aiSource,
        sourceRoster,
        lineupPlayerIds: sourceRoster
            .take(11)
            .map((player) => player.id)
            .toList(),
      );

      final partnerGoalkeeper = aiPartner.roster.firstWhere(
        (player) => player.position == Position.gk,
      );
      final partnerRoster = [
        playerFrom(
          partnerGoalkeeper,
          'trade-target-gk',
          position: Position.gk,
          salary: 2000000,
          pointValue: -500,
        ),
        ...copiesFor(
          aiPartner.roster
              .where((player) => player.position != Position.gk)
              .toList(),
          24,
          'trade-partner',
          salary: 1000000,
          pointValue: 0,
        ),
      ];
      final partnerTeam = withRoster(aiPartner, partnerRoster);
      final state = stateFor(sourceTeam, partner: partnerTeam);
      final balance = BalanceConfig(
        ai: AiBalance(
          pRosterMajorGk: 1.0,
          pRosterSpaceTrade: 1.0,
          tradeAcceptHigh: -100.0,
          tradeAcceptLow: -100.0,
          tradeHardReject: -100.0,
          tradeAcceptProbabilityHigh: 1.0,
        ),
      );

      final repaired = AiRosterManagementService(
        balance: balance,
      ).ensureRosterSafety(state, saveSeed: 3706);
      final repairedSource = repaired.teamById(sourceTeam.id)!;
      final repairedPartner = repaired.teamById(partnerTeam.id)!;

      expect(repaired.tradeHistory, isNotEmpty);
      expect(repaired.tradeHistory.last.outcome, 'accepted');
      expect(repairedSource.roster, hasLength(29));
      expect(repairedPartner.roster, hasLength(26));
      expect(
        repairedSource.roster.any((player) => player.id == 'trade-target-gk'),
        isTrue,
      );
    },
  );

  test('ten deterministic roster-safety runs keep every AI roster legal', () {
    for (var seed = 0; seed < 10; seed++) {
      final league = SeedDataGenerator(random: null).generateLeague(
        year: 2026,
        playerTeamId: 'team_europe_0',
        seed: 3710 + seed,
      );
      final safe = AiRosterManagementService().ensureRosterSafety(
        league,
        saveSeed: 3710 + seed,
      );

      for (final team in safe.teams.where((team) => team.ai != null)) {
        expect(team.roster.length, inInclusiveRange(20, 30));
        expect(team.availablePlayers.length, greaterThanOrEqualTo(11));
      }
    }
  });
}
