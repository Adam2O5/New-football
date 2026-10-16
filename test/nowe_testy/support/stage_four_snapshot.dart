import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/season_awards.dart';
import 'package:new_football/core/models/seed_data.dart';
import 'package:new_football/core/models/seed_data_generator.dart';

const stageFourBaselinePath =
    'test/nowe_testy/support/stage_four_baseline.json';

// Compact, order-sensitive fingerprints for the large generated worlds and
// name catalog. The model JSON itself is retained below for compatibility tests.
String _fingerprint(Object value) {
  var hash = 0x811c9dc5;
  for (final byte in utf8.encode(jsonEncode(value))) {
    hash = ((hash ^ byte) * 0x01000193) & 0xffffffff;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}

Map<String, dynamic> stageFourSnapshot() {
  final league = SeedDataGenerator().generateLeague(seed: 123);
  final prospect = league.currentSeason.draftState!.draftClass.prospects.first;
  final draftClass = DraftClass(year: 2026, prospects: [prospect]);
  final board = MockDraftBoard(
    displayedRank: {prospect.id: 1},
    previousDisplayedRank: {prospect.id: 2},
  );
  final pick = DraftPick(
    id: 'split-pick',
    year: 2026,
    round: 1,
    pickNumber: 2,
    teamId: 'club-a',
    originalTeamId: 'club-b',
    prospectId: prospect.id,
    playerName: prospect.name,
    protectedTopN: 3,
    tradeValue: 600,
  );
  const lottery = LotteryResult(
    teamId: 'club-a',
    originalRank: 4,
    assignedPick: 2,
    oddsForFirstPick: 0.125,
  );
  final draft = DraftState(
    year: 2026,
    order: [pick],
    completedPicks: [pick],
    lotteryResults: [lottery],
    draftClass: draftClass,
    currentPickIndex: 1,
    mockDraftBoard: board,
  );
  const match = MatchResult(
    homeTeamId: 'club-a',
    awayTeamId: 'club-b',
    homeGoals: 2,
    awayGoals: 1,
    homeStats: TeamMatchStats(teamId: 'club-a', goals: 2),
    awayStats: TeamMatchStats(teamId: 'club-b', goals: 1),
  );
  const progress = PlayInProgress(
    conference: Conference.europe,
    seed7TeamId: 'club-a',
    seed8TeamId: 'club-b',
    seed9TeamId: 'club-c',
    seed10TeamId: 'club-d',
    game7v8: match,
    game9v10: match,
    gameFinal: match,
  );
  const playIn = PlayInResult(
    conference: Conference.europe,
    seed7TeamId: 'club-a',
    seed8TeamId: 'club-b',
    game7v8: match,
    game9v10: match,
    gameFinal: match,
    playoffSeed7TeamId: 'club-a',
    playoffSeed8TeamId: 'club-b',
  );
  const bracket = PlayoffBracket(conference: Conference.europe);
  const awards = SeasonAwards(year: 2026, mvpPlayerId: 'player-a');
  final season = Season(
    year: 2026,
    phase: SeasonPhase.offseason,
    standings: league.currentSeason.standings,
    playInResults: [playIn],
    playInProgress: [progress],
    playoffBrackets: [bracket],
    championTeamId: 'club-a',
    championshipAtmosphereApplied: true,
    playoffMissAtmosphereApplied: true,
    draftState: draft,
    awards: awards,
    staffGrowthDone: true,
    playerRetirementsDone: true,
    nextTvCapResetSeason: 2031,
    nextTvCapIncreasePct: 8,
    capUpdateTvDone: true,
    combineDone: true,
    finalMockDone: true,
    faOpenDone: true,
    scoutReportDone: true,
    tradeDeadlineAcked: true,
    nextClassGenerationDone: true,
    schedule: league.currentSeason.schedule.take(1).toList(),
    postseasonFixtures: league.currentSeason.schedule.take(1).toList(),
  );
  final history = SeasonHistory(
    year: 2026,
    finalStandings: season.standings,
    championTeamId: 'club-a',
    draftPicks: [pick],
    awards: awards,
  );
  final rng = Random(456);
  final player = prospect.toPlayer(
    contract: const Contract(salary: 8000000, yearsRemaining: 2),
    rng: rng,
    draftYear: 2026,
  );
  const balance = BalanceConfig.defaults;
  return jsonDecode(
        jsonEncode({
          'models': {
            'Prospect': prospect.toJson(),
            'DraftClass': draftClass.toJson(),
            'MockDraftBoard': board.toJson(),
            'LotteryResult': lottery.toJson(),
            'DraftState': draft.toJson(),
            'CompletedDraft': CompletedDraft(
              year: 2026,
              completedPicks: [pick],
            ).toJson(),
            'PlayInProgress': progress.toJson(),
            'PlayInResult': playIn.toJson(),
            'PlayoffBracket': bracket.toJson(),
            'Season': season.toJson(),
            'SeasonHistory': history.toJson(),
          },
          'conversion': {
            'player': player.toJson(),
            'nextRandom': rng.nextInt(1000000),
          },
          'balance': {
            'stamina90': [
              for (final position in Position.values)
                balance.player.staminaLossForMinutes(position, 90),
            ],
            'rookieSalaries': [
              for (final pick in [1, 30, 90])
                balance.salaryCap.rookieSalaryForPick(pick),
            ],
            'growth': [
              for (var age = 18; age <= 40; age++)
                balance.development.ageBonusFor(age),
            ],
            'retirement': [
              for (var age = 30; age <= 40; age++)
                balance.retirement.baseChanceForAge(age),
            ],
            'lotteryWeights': DraftBalance.lotteryWeights,
            'limits': [
              balance.roster.matchdaySquadSize,
              balance.staff.salaryCap,
              balance.cash.startingCash,
              balance.awards.possibleMinutes,
              balance.contracts.hoursPerDay,
              balance.calendar.seasonCycleWeeks,
              balance.chemistry.multMin,
              balance.chemistry.multMax,
            ],
          },
          'seeds': {
            'world123': _fingerprint(league.toJson()),
            'world456': _fingerprint(
              SeedDataGenerator().generateLeague(seed: 456).toJson(),
            ),
            'nameOrder': namePools.keys.map((n) => n.name).toList(),
            'names': _fingerprint([
              for (final entry in namePools.entries)
                [entry.key.name, entry.value.firstNames, entry.value.lastNames],
            ]),
            'clubs': [
              for (final club in [...europeTeams, ...restOfTheWorldTeams])
                [club.$1, club.$2],
            ],
          },
        }),
      )
      as Map<String, dynamic>;
}

/// Explicitly records the reference before the split; normal tests only read it.
void main() {
  File(
    stageFourBaselinePath,
  ).writeAsStringSync(jsonEncode(stageFourSnapshot()));
  stdout.writeln('Recorded stage 4 reference: $stageFourBaselinePath');
}
