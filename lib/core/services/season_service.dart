import 'dart:math';

import 'package:uuid/uuid.dart';

import 'package:new_football/core/ai/ai_draft_service.dart';
import 'package:new_football/core/ai/ai_draft_models.dart';
import 'package:new_football/core/ai/ai_matchday_service.dart';
import 'package:new_football/core/ai/ai_roster_management_service.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/simulation/match_engine.dart';
import 'package:new_football/core/simulation/match_context_factory.dart';
import 'package:new_football/core/simulation/match_message_emitter.dart';
import 'package:new_football/core/simulation/pre_match_validator.dart';
import 'package:new_football/core/balance/injury_catalog.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/season_awards.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/team_event_state.dart';
import 'package:new_football/core/random/seeds.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/draft_trade_service.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/development_service.dart';
import 'package:new_football/core/services/discipline_service.dart';
import 'package:new_football/core/services/prospect_service.dart';
import 'package:new_football/core/services/match_post_match_service.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/core/services/scouting_service.dart';
import 'package:new_football/core/services/staff_service.dart';
import 'package:new_football/core/services/team_management_service.dart';
import 'package:new_football/core/services/team_event_service.dart';

/// Offseason / playoff pipeline (`docs/offseason.md`, play-in, draft).
class SeasonService {
  SeasonService({
    this.balance = BalanceConfig.defaults,
    SimulationMatchEngine? matchEngine,
    AiMatchdayService? aiMatchdayService,
    AiDraftService? aiDraftService,
    AiRosterManagementService? rosterManagement,
    DraftTradeService? draftTrade,
    ContractMarketService? contractMarket,
    CalendarService? calendar,
    MatchContextFactory? contextFactory,
    MatchMessageEmitter? matchMessageEmitter,
    DevelopmentService? development,
    SalaryCapService? capService,
    StaffService? staffService,
    ScoutingService? scoutingService,
    MessageService? messages,
    TeamEventService? teamEvents,
    Random? random,
  }) : matchEngine = matchEngine ?? SimulationMatchEngine(balance: balance),
       aiMatchdayService =
           aiMatchdayService ??
           AiMatchdayService(
             balance: balance,
             matchEngine:
                 matchEngine ?? SimulationMatchEngine(balance: balance),
           ),
       aiDraftService = aiDraftService ?? AiDraftService(balance: balance),
       rosterManagement =
           rosterManagement ?? AiRosterManagementService(balance: balance),
       draftTrade = draftTrade ?? DraftTradeService(balance: balance),
       contractMarket =
           contractMarket ?? ContractMarketService(balance: balance),
       calendar = calendar ?? CalendarService(balance: balance),
       contextFactory =
           contextFactory ??
           MatchContextFactory(
             calendar: calendar ?? CalendarService(balance: balance),
           ),
       matchMessageEmitter =
           matchMessageEmitter ??
           MatchMessageEmitter(messages: messages ?? MessageService()),
       development = development ?? DevelopmentService(balance: balance),
       capService = capService ?? SalaryCapService(balance: balance),
       staffService = staffService ?? StaffService(balance: balance),
       scoutingService = scoutingService ?? ScoutingService(balance: balance),
       _messages = messages ?? MessageService(),
       teamEvents =
           teamEvents ?? TeamEventService(balance: balance, messages: messages),
       _random = random ?? Random();

  final BalanceConfig balance;
  final SimulationMatchEngine matchEngine;
  final AiMatchdayService aiMatchdayService;
  final AiDraftService aiDraftService;
  final AiRosterManagementService rosterManagement;
  final DraftTradeService draftTrade;
  final ContractMarketService contractMarket;
  final CalendarService calendar;
  final MatchContextFactory contextFactory;
  final MatchMessageEmitter matchMessageEmitter;
  final DevelopmentService development;
  final SalaryCapService capService;
  final StaffService staffService;
  final ScoutingService scoutingService;
  final MessageService _messages;
  final TeamEventService teamEvents;
  final Random _random;
  final _uuid = const Uuid();

  /// Resolves the dated play-in flow without changing the existing atomic
  /// [setupPlayIn] API. Wednesday stores the two opening games for each
  /// conference; Saturday stores the deciding games and promotes the eight
  /// playoff teams.
  LeagueState advancePlayInForDate(
    LeagueState league, {
    required int week,
    required int day,
    int saveSeed = 0,
  }) {
    if (calendar.playInSlotsForDay(week, day).isEmpty) return league;

    var state = league;
    final season = league.currentSeason;
    if (day == 3) {
      final progress = <PlayInProgress>[];
      for (final conference in Conference.values) {
        final progressForConference = season.playInProgress
            .where((p) => p.conference == conference)
            .toList();
        final existing = progressForConference.isEmpty
            ? null
            : progressForConference.first;
        final seeds = _playInSeeds(state, conference);
        if (seeds == null) continue;
        final current =
            existing ??
            PlayInProgress(
              conference: conference,
              seed7TeamId: seeds.s7,
              seed8TeamId: seeds.s8,
              seed9TeamId: seeds.s9,
              seed10TeamId: seeds.s10,
            );

        var game7v8 = current.game7v8;
        if (game7v8 == null) {
          final played = _simPostseason(
            state,
            current.seed7TeamId,
            current.seed8TeamId,
            saveSeed: saveSeed,
            matchId: 'playIn:${conference.name}:7v8',
            phase: SeasonPhase.playIn,
          );
          state = played.league;
          game7v8 = played.result;
        }
        var game9v10 = current.game9v10;
        if (game9v10 == null) {
          final played = _simPostseason(
            state,
            current.seed9TeamId,
            current.seed10TeamId,
            saveSeed: saveSeed,
            matchId: 'playIn:${conference.name}:9v10',
            phase: SeasonPhase.playIn,
          );
          state = played.league;
          game9v10 = played.result;
        }
        progress.add(current.copyWith(game7v8: game7v8, game9v10: game9v10));
      }
      return state.copyWith(
        currentSeason: state.currentSeason.copyWith(
          phase: SeasonPhase.playIn,
          playInProgress: progress,
        ),
      );
    }

    final results = [...season.playInResults];
    final remaining = <PlayInProgress>[];
    for (final progress in season.playInProgress) {
      final game7v8 = progress.game7v8;
      final game9v10 = progress.game9v10;
      if (game7v8 == null || game9v10 == null) {
        remaining.add(progress);
        continue;
      }
      var finalGame = progress.gameFinal;
      if (finalGame == null) {
        final played = _simPostseason(
          state,
          _winnerId(game7v8, progress.seed7TeamId, progress.seed8TeamId) ==
                  progress.seed7TeamId
              ? progress.seed8TeamId
              : progress.seed7TeamId,
          _winnerId(game9v10, progress.seed9TeamId, progress.seed10TeamId),
          saveSeed: saveSeed,
          matchId: 'playIn:${progress.conference.name}:final',
          phase: SeasonPhase.playIn,
        );
        state = played.league;
        finalGame = played.result;
      }
      final loser78 =
          _winnerId(game7v8, progress.seed7TeamId, progress.seed8TeamId) ==
              progress.seed7TeamId
          ? progress.seed8TeamId
          : progress.seed7TeamId;
      final winner910 = _winnerId(
        game9v10,
        progress.seed9TeamId,
        progress.seed10TeamId,
      );
      final playoff8 = _winnerId(finalGame, loser78, winner910);
      final playoff7 = _winnerId(
        game7v8,
        progress.seed7TeamId,
        progress.seed8TeamId,
      );
      results.removeWhere((result) => result.conference == progress.conference);
      results.add(
        PlayInResult(
          conference: progress.conference,
          seed7TeamId: progress.seed7TeamId,
          seed8TeamId: progress.seed8TeamId,
          game7v8: game7v8,
          game9v10: game9v10,
          gameFinal: finalGame,
          playoffSeed7TeamId: playoff7,
          playoffSeed8TeamId: playoff8,
        ),
      );
    }
    return _sendPlayInResultMessages(
      state.copyWith(
        currentSeason: state.currentSeason.copyWith(
          phase: SeasonPhase.playIn,
          playInResults: results,
          playInProgress: remaining,
        ),
      ),
      results,
    );
  }

  ({String s7, String s8, String s9, String s10})? _playInSeeds(
    LeagueState league,
    Conference conference,
  ) {
    final standings = league.currentSeason.standings
        .firstWhere((s) => s.conference == conference)
        .sorted;
    if (standings.length < 10) return null;
    return (
      s7: standings[6].teamId,
      s8: standings[7].teamId,
      s9: standings[8].teamId,
      s10: standings[9].teamId,
    );
  }

  LeagueState setupPlayIn(LeagueState league, {int saveSeed = 0}) {
    final results = <PlayInResult>[];
    var state = league;
    for (final conf in Conference.values) {
      final cs = state.currentSeason.standings.firstWhere(
        (s) => s.conference == conf,
      );
      final sorted = cs.sorted;
      if (sorted.length < 10) continue;
      final s7 = sorted[6].teamId;
      final s8 = sorted[7].teamId;
      final s9 = sorted[8].teamId;
      final s10 = sorted[9].teamId;

      final first = _simPostseason(
        state,
        s7,
        s8,
        saveSeed: saveSeed,
        matchId: 'playIn:${conf.name}:7v8',
        phase: SeasonPhase.playIn,
      );
      state = first.league;
      final second = _simPostseason(
        state,
        s9,
        s10,
        saveSeed: saveSeed,
        matchId: 'playIn:${conf.name}:9v10',
        phase: SeasonPhase.playIn,
      );
      state = second.league;
      final g78 = first.result;
      final g910 = second.result;
      final loser78 = _winnerId(g78, s7, s8) == s7 ? s8 : s7;
      final winner910 = _winnerId(g910, s9, s10);
      final third = _simPostseason(
        state,
        loser78,
        winner910,
        saveSeed: saveSeed,
        matchId: 'playIn:${conf.name}:final',
        phase: SeasonPhase.playIn,
      );
      state = third.league;
      final gFinal = third.result;
      final playoff8 = _winnerId(gFinal, loser78, winner910);
      final playoff7 = _winnerId(g78, s7, s8);

      results.add(
        PlayInResult(
          conference: conf,
          seed7TeamId: s7,
          seed8TeamId: s8,
          game7v8: g78,
          game9v10: g910,
          gameFinal: gFinal,
          playoffSeed7TeamId: playoff7,
          playoffSeed8TeamId: playoff8,
        ),
      );
    }
    return _sendPlayInResultMessages(
      state.copyWith(
        currentSeason: state.currentSeason.copyWith(
          phase: SeasonPhase.playIn,
          playInResults: results,
        ),
      ),
      results,
    );
  }

  LeagueState _sendPlayInResultMessages(
    LeagueState league,
    Iterable<PlayInResult> results,
  ) {
    var state = league;
    for (final result in results) {
      final playoffTeams = {
        result.playoffSeed7TeamId,
        result.playoffSeed8TeamId,
      };
      final ownClub =
          state.playerTeamId != null &&
          playoffTeams.contains(state.playerTeamId);
      state = _messages.send(
        state,
        type: MessageType.playInResult,
        domain: MessageDomain.season,
        args: {
          'conference': result.conference.name,
          'seed7': _teamName(state, result.playoffSeed7TeamId),
          'seed8': _teamName(state, result.playoffSeed8TeamId),
          'ownClub': ownClub,
        },
        payload: {
          'conference': result.conference.name,
          'teamId': ownClub ? state.playerTeamId : null,
          'playoffSeed7TeamId': result.playoffSeed7TeamId,
          'playoffSeed8TeamId': result.playoffSeed8TeamId,
          'ownClub': ownClub,
          'isLeagueMessage': !ownClub,
        },
      );
    }
    return state;
  }

  LeagueState _sendPlayoffSeedingMessages(
    LeagueState league,
    Iterable<PlayoffBracket> brackets,
  ) {
    var state = league;
    for (final bracket in brackets) {
      final seededTeams = {
        for (final series in bracket.quarterFinals) ...[
          series.higherSeedTeamId,
          series.lowerSeedTeamId,
        ],
      };
      final ownClub =
          state.playerTeamId != null &&
          seededTeams.contains(state.playerTeamId);
      state = _messages.send(
        state,
        type: MessageType.playoffSeeding,
        domain: MessageDomain.season,
        args: {
          'conference': bracket.conference.name,
          'seed7': seededTeams.isEmpty
              ? '—'
              : _teamName(state, seededTeams.first),
          'seed8': seededTeams.length < 2
              ? '—'
              : _teamName(state, seededTeams.elementAt(1)),
          'ownClub': ownClub,
        },
        payload: {
          'conference': bracket.conference.name,
          'teamId': ownClub ? state.playerTeamId : null,
          'seededTeamIds': seededTeams.toList(),
          'ownClub': ownClub,
          'isLeagueMessage': !ownClub,
        },
      );
    }
    return state;
  }

  LeagueState setupPlayoffs(LeagueState league) {
    final brackets = <PlayoffBracket>[];
    for (final conf in Conference.values) {
      final cs = league.currentSeason.standings
          .firstWhere((s) => s.conference == conf)
          .sorted;
      final playIn = league.currentSeason.playInResults
          .cast<PlayInResult?>()
          .firstWhere((p) => p?.conference == conf, orElse: () => null);
      final seeds = <String>[
        cs[0].teamId,
        cs[1].teamId,
        cs[2].teamId,
        cs[3].teamId,
        cs[4].teamId,
        cs[5].teamId,
        playIn?.playoffSeed7TeamId ?? cs[6].teamId,
        playIn?.playoffSeed8TeamId ?? cs[7].teamId,
      ];
      brackets.add(
        PlayoffBracket(
          conference: conf,
          quarterFinals: [
            _series(seeds[0], seeds[7]),
            _series(seeds[1], seeds[6]),
            _series(seeds[2], seeds[5]),
            _series(seeds[3], seeds[4]),
          ],
        ),
      );
    }
    return _sendPlayoffSeedingMessages(
      league.copyWith(
        currentSeason: league.currentSeason.copyWith(
          phase: SeasonPhase.playoff,
          playoffBrackets: brackets,
        ),
      ),
      brackets,
    );
  }

  /// Advances one dated playoff slot. Calls outside the canonical postseason
  /// slots are no-ops, so the daily calendar cannot consume a series game on
  /// an arbitrary day.
  LeagueState advancePlayoffsForDate(
    LeagueState league, {
    required int week,
    required int day,
    int saveSeed = 0,
  }) {
    if (calendar.postseasonSlotForDay(week, day) == null) return league;
    if (calendar.playoffRoundForWeek(week) == null) return league;
    return advancePlayoffs(league, saveSeed: saveSeed);
  }

  LeagueState advancePlayoffs(LeagueState league, {int saveSeed = 0}) {
    var brackets = <PlayoffBracket>[];
    var state = league;
    for (final b in league.currentSeason.playoffBrackets) {
      final advanced = _advanceBracket(state, b, saveSeed);
      state = advanced.league;
      brackets.add(advanced.bracket);
    }

    String? champion;
    PlayoffBracket? east;
    PlayoffBracket? west;
    for (final b in brackets) {
      if (b.conference == Conference.europe) east = b;
      if (b.conference == Conference.restOfTheWorld) west = b;
    }

    if (east != null &&
        west != null &&
        east.conferenceFinal.isNotEmpty &&
        west.conferenceFinal.isNotEmpty &&
        east.conferenceFinal.first.isComplete &&
        west.conferenceFinal.first.isComplete) {
      var leagueFinal =
          east.leagueFinal ??
          west.leagueFinal ??
          _series(
            east.conferenceFinal.first.winnerTeamId!,
            west.conferenceFinal.first.winnerTeamId!,
          );
      if (!leagueFinal.isComplete) {
        final played = _playOneGame(
          state,
          leagueFinal,
          saveSeed,
          stake: MatchStake.leagueFinal,
        );
        state = played.league;
        leagueFinal = played.series;
      }
      champion = leagueFinal.winnerTeamId;
      brackets = brackets
          .map((b) => b.copyWith(leagueFinal: leagueFinal))
          .toList();
    }

    state = state.copyWith(
      currentSeason: state.currentSeason.copyWith(
        playoffBrackets: brackets,
        championTeamId: champion ?? state.currentSeason.championTeamId,
      ),
    );
    if (champion != null) {
      final alreadyApplied = state.currentSeason.championshipAtmosphereApplied;
      if (!alreadyApplied) {
        final championTeam = state.teamById(champion);
        if (championTeam != null) {
          final before = championTeam.atmosphere;
          final updated = const TeamManagementService().applyAtmosphereDelta(
            championTeam,
            30,
          );
          state = state
              .updateTeam(updated)
              .copyWith(
                currentSeason: state.currentSeason.copyWith(
                  championshipAtmosphereApplied: true,
                ),
              );
          if (state.playerTeamId == champion) {
            state = _messages.send(
              state,
              type: MessageType.teamEvent,
              kind: 'atmosphereShift',
              domain: MessageDomain.teamEvent,
              args: {
                'delta': updated.atmosphere - before,
                'oldLevel': before,
                'newLevel': updated.atmosphere,
              },
              payload: {
                'teamId': champion,
                'atmosphereDelta': updated.atmosphere - before,
                'oldLevel': before,
                'newLevel': updated.atmosphere,
                'atmosphereBefore': before,
                'atmosphereAfter': updated.atmosphere,
                'reason': 'championship',
              },
              dedupKey: 'atmosphere:championship:${state.currentSeason.year}',
            );
          }
        } else {
          state = state.copyWith(
            currentSeason: state.currentSeason.copyWith(
              championshipAtmosphereApplied: true,
            ),
          );
        }
      }
      state = teamEvents.afterPlayoffs(state, saveSeed: saveSeed);
    }
    return state;
  }

  LeagueState runCapUpdateTv(LeagueState league, {int saveSeed = 0}) {
    final season = league.currentSeason;
    if (season.capUpdateTvDone) return league;

    var resetSeason = season.nextTvCapResetSeason;
    var increasePct = season.nextTvCapIncreasePct;
    if (resetSeason <= 0 || increasePct <= 0) {
      final initial = capService.tvScheduleFor(
        currentYear: season.year,
        saveSeed: saveSeed,
      );
      resetSeason = initial.nextTvCapResetSeason;
      increasePct = initial.nextTvCapIncreasePct;
    }

    if (season.year != resetSeason) {
      return league.copyWith(
        currentSeason: season.copyWith(
          nextTvCapResetSeason: resetSeason,
          nextTvCapIncreasePct: increasePct,
          capUpdateTvDone: true,
        ),
      );
    }

    final updatedTeams = capService.applyTvUpdate(
      league.teams,
      increasePct: increasePct,
    );
    final nextAgreement = capService.tvScheduleFor(
      currentYear: season.year,
      saveSeed: saveSeed,
    );
    var state = league.copyWith(
      teams: updatedTeams,
      currentSeason: season.copyWith(
        nextTvCapResetSeason: nextAgreement.nextTvCapResetSeason,
        nextTvCapIncreasePct: nextAgreement.nextTvCapIncreasePct,
        capUpdateTvDone: true,
      ),
    );

    state = _messages.send(
      state,
      type: MessageType.capUpdateTv,
      domain: MessageDomain.finance,
      priority: MessagePriority.urgent,
      args: {
        'increasePct': increasePct,
        'salaryCap': state.teams.first.finance.salaryCap,
        'firstApron': state.teams.first.finance.firstApron,
        'secondApron': state.teams.first.finance.secondApron,
        'nextResetSeason': nextAgreement.nextTvCapResetSeason,
      },
      payload: {
        'increasePct': increasePct,
        'salaryCap': state.teams.first.finance.salaryCap,
        'firstApron': state.teams.first.finance.firstApron,
        'secondApron': state.teams.first.finance.secondApron,
        'nextTvCapResetSeason': nextAgreement.nextTvCapResetSeason,
      },
      dedupKey: 'capUpdateTv:${season.year}',
    );

    final playerTeam = state.playerTeam;
    if (playerTeam != null) {
      final snapshot = capService.snapshot(playerTeam);
      if (snapshot.status == CapStatus.firstApron ||
          snapshot.status == CapStatus.secondApron) {
        state = _messages.send(
          state,
          type: MessageType.apronWarning,
          domain: MessageDomain.finance,
          args: {
            'payroll': snapshot.payroll,
            'firstApron': snapshot.firstApron,
            'secondApron': snapshot.secondApron,
            'payrollAboveSecondApron': snapshot.isAboveSecondApron,
          },
          payload: {
            'teamId': playerTeam.id,
            'payroll': snapshot.payroll,
            'firstApron': snapshot.firstApron,
            'secondApron': snapshot.secondApron,
            'payrollAboveSecondApron': snapshot.isAboveSecondApron,
          },
          dedupKey: 'apronWarning:${season.year}:${playerTeam.id}',
        );
      }
    }
    return state;
  }

  LeagueState runStaffGrowthAndRetire(LeagueState league) {
    final state = staffService.growthAndRetireTick(league);
    return state.copyWith(
      currentSeason: state.currentSeason.copyWith(staffGrowthDone: true),
    );
  }

  LeagueState runAwards(LeagueState league) {
    if (league.currentSeason.awards != null) return league;

    final awards = _computeAwards(league);
    var state = league.copyWith(
      currentSeason: league.currentSeason.copyWith(awards: awards),
    );
    state = _sendAwardMessages(state, awards);
    return _messages.send(
      state,
      type: MessageType.seasonSummary,
      domain: MessageDomain.season,
      args: {
        'championTeam': awards.championTeamId == null
            ? '—'
            : _teamName(state, awards.championTeamId!),
        'mvpPlayer': _playerName(state, awards.mvpPlayerId),
        'playoffTeams': _playoffQualifiedTeamIds(state).length,
      },
      payload: {
        'championTeamId': awards.championTeamId,
        'mvpPlayerId': awards.mvpPlayerId,
        'year': awards.year,
      },
      dedupKey: 'seasonSummary:${awards.year}',
    );
  }

  /// Emerytury (śr tyg. 44): wyłącznie tabela bazowa
  /// `BalanceConfig.retirement.baseChanceForAge(age)`, bez modyfikatorów.
  LeagueState runPlayerRetirements(LeagueState league, {int saveSeed = 0}) {
    final retired = <({String id, String name, String teamId})>[];
    final teams = league.teams.map((t) {
      final keep = <Player>[];
      final retiredIds = <String>{};
      for (final p in t.roster) {
        final chance = balance.retirement.baseChanceForAge(p.age);
        if (chance > 0 && _random.nextDouble() < chance) {
          retired.add((id: p.id, name: p.name, teamId: t.id));
          retiredIds.add(p.id);
        } else {
          keep.add(p);
        }
      }
      var updated = t.copyWith(roster: keep);
      if (retiredIds.isNotEmpty) {
        updated = updated.copyWith(
          eventState: t.eventState.clearPlayers(retiredIds),
        );
      }
      return capService.applyPayroll(updated);
    }).toList();

    var state = league.copyWith(
      teams: teams,
      currentSeason: league.currentSeason.copyWith(playerRetirementsDone: true),
    );

    for (final record in retired) {
      if (record.teamId != state.playerTeamId) continue;
      state = _messages.send(
        state,
        type: MessageType.retirementPlayer,
        domain: MessageDomain.roster,
        args: {'playerName': record.name, 'ownClub': true},
        payload: {
          'playerId': record.id,
          'teamId': record.teamId,
          'ownClub': true,
        },
        dedupKey: 'retirementPlayer:${state.currentSeason.year}:${record.id}',
      );
    }

    if (retired.isNotEmpty) {
      state = _messages.send(
        state,
        type: MessageType.retirementLeagueDigest,
        domain: MessageDomain.roster,
        priority: MessagePriority.silenced,
        titleKey: 'msg_retirementLeagueDigest_digest_title',
        bodyKey: 'msg_retirementLeagueDigest_digest_body',
        args: {'count': retired.length, 'week': state.currentWeek},
        payload: {
          'retiredPlayers': [
            for (final record in retired)
              {
                'playerId': record.id,
                'playerName': record.name,
                'teamId': record.teamId,
              },
          ],
          'isLeagueMessage': true,
        },
        groupKey: 'retire:league:${state.currentWeek}',
        dedupKey: 'retire:league:${state.currentSeason.year}',
      );
    }

    return rosterManagement.replenishAfterRetirements(
      state,
      saveSeed: saveSeed,
    );
  }

  LeagueState runLottery(LeagueState league) {
    final lottery = _computeLotteryResults(league);
    final existingClass = league.currentSeason.draftState?.draftClass;
    final draftClass =
        existingClass ??
        SeedDataGenerator(
          random: _random,
        ).generateDraftClass(year: league.currentSeason.year);
    final currentYear = league.currentSeason.year;
    final (order, consumedPickIds) = _buildDraftOrder(
      league,
      lottery,
      currentYear,
    );

    var teams = league.teams;
    if (consumedPickIds.isNotEmpty) {
      teams = teams.map((t) {
        if (!t.ownedPicks.any((p) => consumedPickIds.contains(p.id))) {
          return t;
        }
        return t.copyWith(
          ownedPicks: t.ownedPicks
              .where((p) => !consumedPickIds.contains(p.id))
              .toList(),
        );
      }).toList();
    }

    final draftState = DraftState(
      year: currentYear,
      order: order,
      lotteryResults: lottery,
      draftClass: draftClass,
    );
    var state = league.copyWith(
      teams: teams,
      currentSeason: league.currentSeason.copyWith(
        draftState: draftState,
        phase: SeasonPhase.offseason,
      ),
    );
    final first = lottery.where((l) => l.assignedPick == 1).first;
    return _msg(
      state,
      MessageType.lottery,
      'Loteria draftu',
      'Pick 1: ${_teamName(state, first.teamId)}',
      urgent: true,
    );
  }

  /// Generates the next draft class and immediately assigns AI scouting
  /// watchlists for the class that becomes active after the current draft.
  LeagueState runNextClassGeneration(LeagueState league, {int saveSeed = 0}) {
    var state = ProspectService(
      random: _random,
    ).generateNextClassForLeague(league);
    final nextDraft = state.currentSeason.nextDraftState;
    if (nextDraft == null) return state;
    final year = nextDraft.year;
    final teams = state.teams.map((team) {
      if (team.isPlayerControlled) return team;
      return team.copyWith(
        scouting: aiDraftService.assignWatchlist(
          team: team,
          draftClass: nextDraft.draftClass,
          league: state,
          saveSeed: saveSeed,
          seasonYear: year,
          week: state.currentWeek,
        ),
      );
    }).toList();
    return state.copyWith(teams: teams);
  }

  LeagueState runFreeAgencyOpen(LeagueState league) {
    var state = league.copyWith(
      currentSeason: league.currentSeason.copyWith(faOpenDone: true),
    );
    return _msg(
      state,
      MessageType.calendar,
      'Rynek wolnych agentów otwarty',
      'Możesz teraz składać oferty zawodnikom i sztabowi bez klubu.',
    );
  }

  /// Scout Report (pon tyg. 45, `docs/offseason.md` §5): AI builds or
  /// refreshes its watchlist, then every team picks uncertain Combine targets.
  LeagueState runScoutReport(LeagueState league, {int saveSeed = 0}) {
    final draftClass = league.currentSeason.draftState?.draftClass;
    if (draftClass == null) return league;
    final ranked = [...draftClass.prospects]
      ..sort((a, b) {
        final grade = b.scoutGrade.compareTo(a.scoutGrade);
        return grade != 0 ? grade : a.id.compareTo(b.id);
      });
    final teams = league.teams.map((team) {
      final coverage = team.staff.scout?.attributes.coverage ?? 0.0;
      var scouting = team.scouting;
      if (!team.isPlayerControlled) {
        if (scouting.watchlistProspectIds.isEmpty) {
          scouting = aiDraftService.assignWatchlist(
            team: team,
            draftClass: draftClass,
            league: league,
            saveSeed: saveSeed,
            seasonYear: league.currentSeason.year,
            week: league.currentWeek,
          );
        }
        scouting = scoutingService.updateMonthlyWatchlist(
          scouting,
          rankedProspects: ranked,
          coverageStars: coverage,
          seed: saveSeed,
          seasonYear: league.currentSeason.year,
          week: league.currentWeek,
          teamId: team.id,
        );
        scouting = scoutingService.runScoutReport(
          scouting,
          coverage,
          prospects: draftClass.prospects,
          rankedProspects: ranked,
          seed: saveSeed,
        );
      } else {
        // The player receives the report but chooses Combine targets in the
        // Prospects screen instead of inheriting the AI assignment.
        scouting = scouting.copyWith(combineAssignedProspectIds: const []);
      }
      return team.copyWith(scouting: scouting);
    }).toList();
    return _msg(
      league.copyWith(
        teams: teams,
        currentSeason: league.currentSeason.copyWith(scoutReportDone: true),
      ),
      MessageType.scoutReport,
      'Raport skautingowy',
      'Sztab przygotował raporty z obserwacji i przydział na Combine.',
    );
  }

  /// Draft Combine (śr tyg. 45, `docs/offseason.md` §6).
  LeagueState runCombine(LeagueState league, {int saveSeed = 0}) {
    final draftClass = league.currentSeason.draftState?.draftClass;
    final teams = league.teams.map((team) {
      final evalStars = team.staff.scout?.attributes.evaluation ?? 0.0;
      return team.copyWith(
        scouting: scoutingService.runCombine(
          team.scouting,
          evalStars,
          prospects: draftClass?.prospects ?? const [],
          seed: saveSeed,
          seasonYear: league.currentSeason.year,
          week: league.currentWeek,
          teamId: team.id,
        ),
      );
    }).toList();
    return _msg(
      league.copyWith(
        teams: teams,
        currentSeason: league.currentSeason.copyWith(combineDone: true),
      ),
      MessageType.combine,
      'Draft Combine',
      'Testy fizyczne i mecz pokazowy zakończone.',
    );
  }

  /// Mock Draft finalny (pt tyg. 45, `docs/offseason.md` §7).
  LeagueState runFinalMock(LeagueState league, {int saveSeed = 0}) {
    final draftClass = league.currentSeason.draftState?.draftClass;
    if (draftClass == null) return league;
    final ranked = [...draftClass.prospects]
      ..sort((a, b) {
        final grade = b.scoutGrade.compareTo(a.scoutGrade);
        return grade != 0 ? grade : a.id.compareTo(b.id);
      });
    final teams = league.teams.map((team) {
      final evalStars = team.staff.scout?.attributes.evaluation ?? 0.0;
      return team.copyWith(
        scouting: scoutingService.runFinalMock(
          team.scouting,
          ranked,
          evalStars,
          seed: saveSeed,
          seasonYear: league.currentSeason.year,
          week: league.currentWeek,
          teamId: team.id,
        ),
      );
    }).toList();
    return _msg(
      league.copyWith(
        teams: teams,
        currentSeason: league.currentSeason.copyWith(finalMockDone: true),
      ),
      MessageType.mockDraft,
      'Mock Draft finalny',
      'Scouci opublikowali estymowane sloty draftu.',
    );
  }

  LeagueState _finalizeDraftFreeAgents(LeagueState state, DraftState draft) {
    if (draft.currentPickIndex < draft.order.length) return state;
    final draftedIds = draft.completedPicks
        .map((c) => c.prospectId)
        .whereType<String>()
        .toSet();

    // Draft finalization can be replayed after a save/load boundary. Keep the
    // first existing free-agent snapshot for each id and only create
    // provenance for players that are genuinely added by this finalization.
    final freeAgents = <Player>[];
    final freeAgentIds = <String>{};
    for (final player in state.freeAgents) {
      if (freeAgentIds.add(player.id)) freeAgents.add(player);
    }

    final freshByPlayerId = <String, FreshUndraftedPlayer>{};
    for (final record in state.freshUndraftedPlayers) {
      if (freeAgentIds.contains(record.playerId)) {
        freshByPlayerId.putIfAbsent(record.playerId, () => record);
      }
    }

    for (final prospect in draft.draftClass.prospects) {
      if (draftedIds.contains(prospect.id)) continue;
      final player = prospect
          .toPlayer(
            contract: Contract(
              salary: balance.salaryCap.minSalary,
              yearsRemaining: 0,
            ),
            draftYear: draft.year,
            rng: _random,
          )
          .recalculatePointValue(balance);
      if (!freeAgentIds.add(player.id)) continue;
      freeAgents.add(player);
      freshByPlayerId[player.id] = FreshUndraftedPlayer(
        playerId: player.id,
        draftYear: draft.year,
        activeFromSeasonYear: state.currentSeason.year,
        activeFromWeek: balance.calendar.freeAgencyWeek,
        activeUntilSeasonYear: state.currentSeason.year + 1,
        activeUntilWeek: balance.calendar.freeAgencyPhaseIIEndWeek,
      );
    }

    return state.copyWith(
      freeAgents: freeAgents,
      freshUndraftedPlayers: freshByPlayerId.values.toList(),
    );
  }

  AiDraftDecision _decideAiDraft(
    LeagueState state,
    DraftState draft,
    DraftPick pick,
    int overallPick, {
    required int saveSeed,
  }) {
    final team = state.teamById(pick.teamId);
    if (team == null) {
      return const AiDraftDecision(action: AiDraftAction.pick, board: []);
    }
    final taken = draft.completedPicks
        .map((completed) => completed.prospectId)
        .whereType<String>()
        .toSet();
    return aiDraftService.decidePick(
      team: team,
      prospects: draft.draftClass.prospects,
      pickNumber: overallPick,
      currentPickIndex: draft.currentPickIndex,
      draftOrder: draft.order,
      unavailableProspectIds: taken,
      league: state,
      saveSeed: saveSeed,
      seasonYear: state.currentSeason.year,
      week: state.currentWeek,
    );
  }

  Prospect _chooseAiDraftProspect(
    List<Prospect> remaining,
    AiDraftDecision decision,
  ) {
    final selectedId = decision.selection?.prospect.id;
    return remaining.firstWhere(
      (prospect) => prospect.id == selectedId,
      orElse: () => remaining.first,
    );
  }

  ({LeagueState state, bool swapped, bool pending}) _resolveAiDraftTrade(
    LeagueState state,
    DraftState draft,
    DraftPick pick,
    AiDraftDecision decision,
  ) {
    if (_draftSlotTradeAlreadyResolved(state, pick.id)) {
      return (state: state, swapped: false, pending: false);
    }
    if (decision.action == AiDraftAction.pick) {
      return (state: state, swapped: false, pending: false);
    }

    final targetIndex = decision.action == AiDraftAction.tradeUp
        ? decision.targetPickIndex
        : _tradeDownTargetIndex(state, draft, pick);
    if (targetIndex == null ||
        targetIndex < 0 ||
        targetIndex >= draft.order.length ||
        targetIndex == draft.currentPickIndex) {
      return (state: state, swapped: false, pending: false);
    }
    final target = draft.order[targetIndex];
    final targetValidation = draftTrade.validateActiveSwap(
      state,
      firstPickId: pick.id,
      secondPickId: target.id,
      firstOwnerId: pick.teamId,
      secondOwnerId: target.teamId,
    );
    if (!targetValidation.ok) {
      return (state: state, swapped: false, pending: false);
    }

    final targetTeam = state.teamById(target.teamId);
    if (targetTeam == null || target.teamId == pick.teamId) {
      return (state: state, swapped: false, pending: false);
    }

    // Only documented trade-up plans may pause the player's draft for a
    // response. A weak-board trade-down never creates a player-facing offer.
    if (target.teamId == state.playerTeamId) {
      if (decision.action != AiDraftAction.tradeUp) {
        return (state: state, swapped: false, pending: false);
      }
      final existing = draftTrade.pendingOfferForPick(state, pick.id);
      if (existing != null) {
        return (state: state, swapped: false, pending: true);
      }
      final created = draftTrade.createOfferForSlots(
        state,
        offeredPickId: pick.id,
        targetPickId: target.id,
        offeringTeamId: pick.teamId,
      );
      if (created.outcome != 'pending' || created.offerId == null) {
        return (state: state, swapped: false, pending: false);
      }
      return (state: created.league, swapped: false, pending: true);
    }

    final operationId =
        'draftSwap:${state.currentSeason.year}:${pick.id}:${target.id}';
    final swapped = draftTrade.swapActiveSlots(
      state,
      firstPickId: pick.id,
      secondPickId: target.id,
      firstOwnerId: pick.teamId,
      secondOwnerId: target.teamId,
      operationId: operationId,
      reason:
          'draftTrade:${decision.action.name}:surplus=${decision.surplusPct}',
    );
    return (state: swapped.league, swapped: swapped.changed, pending: false);
  }

  int? _tradeDownTargetIndex(
    LeagueState state,
    DraftState draft,
    DraftPick current,
  ) {
    for (
      var index = draft.currentPickIndex + 1;
      index < draft.order.length;
      index++
    ) {
      final candidate = draft.order[index];
      if (candidate.prospectId != null || candidate.playerName != null) {
        continue;
      }
      final team = state.teamById(candidate.teamId);
      if (team == null ||
          candidate.teamId == state.playerTeamId ||
          team.id == current.teamId) {
        continue;
      }
      return index;
    }
    return null;
  }

  bool _draftSlotTradeAlreadyResolved(LeagueState state, String pickId) {
    for (final entry in state.tradeHistory.reversed) {
      if (entry.seasonYear != state.currentSeason.year) continue;
      final isDraftOutcome = switch (entry.outcome) {
        'accepted' || 'rejected' || 'expired' || 'hardRejected' => true,
        _ => false,
      };
      if (!isDraftOutcome) continue;
      final assets = [...entry.assetsFromA, ...entry.assetsFromB];
      if (assets.any(
        (asset) => asset.type == 'pick' && asset.pickId == pickId,
      )) {
        return true;
      }
    }
    return false;
  }

  LeagueState _maybeSignAiDraftedRight(
    LeagueState state,
    DraftedPlayerRights right,
    DraftPick pick, {
    required int saveSeed,
  }) {
    final team = state.teamById(pick.teamId);
    if (team == null || team.isPlayerControlled) return state;
    final context = aiDraftService.evaluator.contextForTeam(
      team: team,
      league: state,
      saveSeed: saveSeed,
      seasonYear: state.currentSeason.year,
      week: state.currentWeek,
      decisionType: DecisionType.draftPick,
    );
    final needScore =
        aiDraftService.evaluator
            .needForPosition(context, right.player.position)
            ?.needScore ??
        0.0;
    final decision = aiDraftService.draftedSigningDecision(
      team: team,
      round: pick.round,
      prospectId: right.player.id,
      needScore: needScore,
      saveSeed: saveSeed,
      seasonYear: state.currentSeason.year,
      week: state.currentWeek,
    );
    if (!decision.sign) return state;
    return contractMarket.signDraftedRight(
          state,
          right.id,
          saveSeed: saveSeed,
        ) ??
        state;
  }

  LeagueState advanceDraft(
    LeagueState league, {
    String? playerPickProspectId,
    int saveSeed = 0,
  }) {
    var draft = league.currentSeason.draftState;
    if (draft == null) return league;
    final wasComplete = draft.currentPickIndex >= draft.order.length;
    var state = league;
    var draftedRights = List<DraftedPlayerRights>.from(state.draftedRights);
    while (draft!.currentPickIndex < draft.order.length) {
      final pick = draft.order[draft.currentPickIndex];
      final isPlayer = pick.teamId == state.playerTeamId;
      if (isPlayer && playerPickProspectId == null) {
        return state.copyWith(
          currentSeason: state.currentSeason.copyWith(draftState: draft),
        );
      }

      final taken = draft.completedPicks
          .map((c) => c.prospectId)
          .whereType<String>()
          .toSet();
      final remaining =
          draft.draftClass.prospects
              .where((p) => !taken.contains(p.id))
              .toList()
            ..sort((a, b) => b.scoutGrade.compareTo(a.scoutGrade));
      if (remaining.isEmpty) break;
      final overallPick = pick.pickNumber ?? draft.currentPickIndex + 1;
      final decision = isPlayer
          ? null
          : _decideAiDraft(state, draft, pick, overallPick, saveSeed: saveSeed);
      if (!isPlayer) {
        final trade = _resolveAiDraftTrade(state, draft, pick, decision!);
        if (trade.pending) {
          return trade.state;
        }
        if (trade.swapped) {
          state = trade.state;
          draft = state.currentSeason.draftState!;
          draftedRights = List<DraftedPlayerRights>.from(state.draftedRights);
          continue;
        }
      }
      final chosen = isPlayer
          ? remaining.firstWhere(
              (p) => p.id == playerPickProspectId,
              orElse: () => remaining.first,
            )
          : _chooseAiDraftProspect(remaining, decision!);
      final salary = balance.salaryCap.rookieSalaryForPick(overallPick);
      final player = chosen
          .toPlayer(
            contract: Contract(
              salary: salary,
              yearsRemaining: balance.salaryCap.rookieScaleYears,
              isRookieScale: true,
              rookiePickSlot: overallPick,
            ),
            draftYear: draft.year,
            rng: _random,
          )
          .recalculatePointValue(balance);

      final right = DraftedPlayerRights(
        id: 'rights:${state.currentSeason.year}:$overallPick:${chosen.id}',
        ownerTeamId: pick.teamId,
        player: player,
        draftYear: state.currentSeason.year,
        pickNumber: overallPick,
        reminderSent: isPlayer,
      );
      draftedRights.add(right);
      state = state.copyWith(draftedRights: draftedRights);
      if (!isPlayer) {
        state = _maybeSignAiDraftedRight(
          state,
          right,
          pick,
          saveSeed: saveSeed,
        );
        draftedRights = List<DraftedPlayerRights>.from(state.draftedRights);
      }

      final completed = pick.copyWith(
        prospectId: chosen.id,
        playerName: chosen.name,
      );
      final newOrder = List<DraftPick>.from(draft.order);
      newOrder[draft.currentPickIndex] = completed;
      draft = draft.copyWith(
        completedPicks: [...draft.completedPicks, completed],
        currentPickIndex: draft.currentPickIndex + 1,
        order: newOrder,
      );
      if (isPlayer) {
        state = state.copyWith(
          draftedRights: draftedRights,
          currentSeason: state.currentSeason.copyWith(draftState: draft),
        );
        state = _messages.send(
          state,
          type: MessageType.draftedRightsReminder,
          domain: MessageDomain.draft,
          args: {
            'playerName': chosen.name,
            'rosterCount': state.teamById(pick.teamId)?.roster.length ?? 0,
          },
          payload: {
            'rightsId': right.id,
            'playerId': player.id,
            'teamId': pick.teamId,
            'draftYear': state.currentSeason.year,
            'pickNumber': overallPick,
          },
          dedupKey:
              'draftedRightsReminder:${state.currentSeason.year}:${right.id}',
        );
        state = _msg(
          state,
          MessageType.draftPick,
          'Draft: wybrano ${chosen.name}',
          'Pick $overallPick: ${chosen.position.code}',
          urgent: true,
        );
        playerPickProspectId = null;
      }
    }

    state = state.copyWith(
      draftedRights: draftedRights,
      currentSeason: state.currentSeason.copyWith(
        draftState: draft,
        phase: SeasonPhase.offseason,
      ),
    );

    // Draft just finished this call: undrafted prospects go to the FA pool
    // (`docs/offseason.md` §8).
    final nowComplete = draft.currentPickIndex >= draft.order.length;
    if (!wasComplete && nowComplete) {
      state = _finalizeDraftFreeAgents(state, draft);
    }

    return state;
  }

  /// Advances the draft by exactly one AI pick. Does nothing if:
  /// - draftState is null
  /// - draft is already complete
  /// - the current pick belongs to the player's team
  LeagueState advanceDraftOnePick(LeagueState league, {int saveSeed = 0}) {
    var draft = league.currentSeason.draftState;
    if (draft == null) return league;
    if (draft.currentPickIndex >= draft.order.length) return league;

    final pick = draft.order[draft.currentPickIndex];
    if (pick.teamId == league.playerTeamId) return league;

    final taken = draft.completedPicks
        .map((c) => c.prospectId)
        .whereType<String>()
        .toSet();
    final remaining =
        draft.draftClass.prospects.where((p) => !taken.contains(p.id)).toList()
          ..sort((a, b) => b.scoutGrade.compareTo(a.scoutGrade));
    if (remaining.isEmpty) return league;

    final overallPick = pick.pickNumber ?? draft.currentPickIndex + 1;
    final decision = _decideAiDraft(
      league,
      draft,
      pick,
      overallPick,
      saveSeed: saveSeed,
    );
    final trade = _resolveAiDraftTrade(league, draft, pick, decision);
    if (trade.pending || trade.swapped) return trade.state;
    final chosen = _chooseAiDraftProspect(remaining, decision);
    final salary = balance.salaryCap.rookieSalaryForPick(overallPick);
    final player = chosen
        .toPlayer(
          contract: Contract(
            salary: salary,
            yearsRemaining: balance.salaryCap.rookieScaleYears,
            isRookieScale: true,
            rookiePickSlot: overallPick,
          ),
          draftYear: draft.year,
          rng: _random,
        )
        .recalculatePointValue(balance);

    final right = DraftedPlayerRights(
      id: 'rights:${league.currentSeason.year}:$overallPick:${chosen.id}',
      ownerTeamId: pick.teamId,
      player: player,
      draftYear: league.currentSeason.year,
      pickNumber: overallPick,
    );
    final draftedRights = [
      ...league.draftedRights.where((item) => item.id != right.id),
      right,
    ];

    final completed = pick.copyWith(
      prospectId: chosen.id,
      playerName: chosen.name,
    );
    final newOrder = List<DraftPick>.from(draft.order);
    newOrder[draft.currentPickIndex] = completed;
    draft = draft.copyWith(
      completedPicks: [...draft.completedPicks, completed],
      currentPickIndex: draft.currentPickIndex + 1,
      order: newOrder,
    );

    var state = league.copyWith(
      draftedRights: draftedRights,
      currentSeason: league.currentSeason.copyWith(
        draftState: draft,
        phase: SeasonPhase.offseason,
      ),
    );
    state = _maybeSignAiDraftedRight(state, right, pick, saveSeed: saveSeed);
    return _finalizeDraftFreeAgents(state, draft);
  }

  /// Removes player and staff contracts that have reached zero years. The
  /// operation is idempotent, so the season rollover can call it exactly once
  /// without duplicating free-agent entries.
  LeagueState expireContracts(LeagueState league) {
    final freeAgents = List<Player>.from(league.freeAgents);
    final staffFreeAgents = List<StaffMember>.from(
      league.canonicalStaffFreeAgents,
    );
    var state = league;
    final playerTeamId = league.playerTeamId;
    final teams = league.teams.map((t) {
      final keep = <Player>[];
      final expiredIds = <String>{};
      for (final p in t.roster) {
        if (t.id == playerTeamId && p.contract.yearsRemaining == 1) {
          state = _messages.send(
            state,
            type: MessageType.contractExpiring,
            kind: 'player',
            domain: MessageDomain.contracts,
            args: {
              'playerName': p.name,
              'teamName': t.name,
              'yearsRemaining': p.contract.yearsRemaining,
            },
            payload: {
              'playerId': p.id,
              'teamId': t.id,
              'contractKind': 'player',
              'yearsRemaining': p.contract.yearsRemaining,
            },
            dedupKey:
                'contractExpiring:player:${league.currentSeason.year}:${p.id}',
          );
        }
        if (p.contract.yearsRemaining <= 0) {
          if (!freeAgents.any((item) => item.id == p.id)) {
            freeAgents.add(p);
          }
          expiredIds.add(p.id);
          if (t.id == playerTeamId) {
            state = _messages.send(
              state,
              type: MessageType.contractExpired,
              kind: 'player',
              domain: MessageDomain.contracts,
              args: {'playerName': p.name, 'teamName': t.name},
              payload: {
                'playerId': p.id,
                'teamId': t.id,
                'contractKind': 'player',
                'expired': true,
              },
              dedupKey:
                  'contractExpired:player:${league.currentSeason.year}:${p.id}',
            );
          }
        } else {
          keep.add(p);
        }
      }

      var staff = t.staff;
      for (final role in StaffRole.values) {
        final member = staff.canonicalMember(role);
        final memberId = member?.id;
        final contract = member?.contract;
        if (member == null || memberId == null || contract == null) {
          continue;
        }
        if (t.id == playerTeamId && contract.yearsRemaining == 1) {
          state = _messages.send(
            state,
            type: MessageType.contractExpiring,
            kind: 'staff',
            domain: MessageDomain.staff,
            args: {
              'staffName': member.name,
              'role': member.role.name,
              'teamName': t.name,
              'yearsRemaining': contract.yearsRemaining,
            },
            payload: {
              'staffId': memberId,
              'teamId': t.id,
              'contractKind': 'staff',
              'yearsRemaining': contract.yearsRemaining,
            },
            dedupKey:
                'contractExpiring:staff:${league.currentSeason.year}:$memberId',
          );
        }
        if (contract.yearsRemaining > 0) continue;
        if (!staffFreeAgents.any((item) => item.id == memberId)) {
          staffFreeAgents.add(member.copyWith(contract: null));
        }
        if (t.id == playerTeamId) {
          state = _messages.send(
            state,
            type: MessageType.contractExpired,
            kind: 'staff',
            domain: MessageDomain.staff,
            args: {
              'staffName': member.name,
              'role': member.role.name,
              'teamName': t.name,
            },
            payload: {
              'staffId': memberId,
              'teamId': t.id,
              'contractKind': 'staff',
              'expired': true,
            },
            dedupKey:
                'contractExpired:staff:${league.currentSeason.year}:$memberId',
          );
        }
        staff = staff.withMember(role, null);
      }

      if (expiredIds.isEmpty && staff == t.staff) return t;
      return capService.applyPayroll(
        t.copyWith(
          roster: keep,
          eventState: t.eventState.clearPlayers(expiredIds),
          staff: staff,
        ),
      );
    }).toList();
    return state.copyWith(
      teams: teams,
      freeAgents: freeAgents,
      staffFreeAgents: staffFreeAgents,
    );
  }

  LeagueState rolloverSeason(LeagueState league, {int saveSeed = 0}) {
    if (!league.currentSeason.playoffMissAtmosphereApplied) {
      final table = league.strengthTable;
      final qualified = _playoffQualifiedTeamIds(league);
      final atmosphereDeltas = <String, int>{};
      final teams = league.teams.map((team) {
        final status = table?.statusOf(team.id);
        final delta = status == TeamStatus.elite
            ? -15
            : status == TeamStatus.contender
            ? -12
            : status == TeamStatus.pretender
            ? -8
            : 0;
        if (delta == 0 || qualified.contains(team.id)) return team;
        final updated = const TeamManagementService().applyAtmosphereDelta(
          team,
          delta,
        );
        atmosphereDeltas[team.id] = updated.atmosphere - team.atmosphere;
        return updated;
      }).toList();
      league = league.copyWith(
        teams: teams,
        currentSeason: league.currentSeason.copyWith(
          playoffMissAtmosphereApplied: true,
        ),
      );

      final playerId = league.playerTeamId;
      final playerDelta = playerId == null ? null : atmosphereDeltas[playerId];
      if (playerDelta != null) {
        final playerTeam = league.teamById(playerId!);
        league = _messages.send(
          league,
          type: MessageType.playoffMissed,
          domain: MessageDomain.season,
          priority: MessagePriority.urgent,
          args: {
            'atmosphereDelta': playerDelta,
            'oldLevel': (playerTeam?.atmosphere ?? 0) - playerDelta,
            'newLevel': playerTeam?.atmosphere ?? 0,
            'atmosphere': playerTeam?.atmosphere ?? 0,
          },
          payload: {
            'teamId': playerId,
            'atmosphereDelta': playerDelta,
            'oldLevel': (playerTeam?.atmosphere ?? 0) - playerDelta,
            'newLevel': playerTeam?.atmosphere ?? 0,
            'atmosphereBefore': (playerTeam?.atmosphere ?? 0) - playerDelta,
            'atmosphereAfter': playerTeam?.atmosphere ?? 0,
            'atmosphere': playerTeam?.atmosphere ?? 0,
          },
          dedupKey: 'playoffMissed:${league.currentSeason.year}:$playerId',
        );
      }
    }

    final history = SeasonHistory(
      year: league.currentSeason.year,
      finalStandings: league.currentSeason.standings,
      championTeamId: league.currentSeason.championTeamId,
      draftPicks: league.currentSeason.draftState?.completedPicks ?? [],
      awards: league.currentSeason.awards,
    );

    final newYear = league.currentSeason.year + 1;

    // Promocja: draftClass wygenerowana przez runNextClassGeneration (tydz. 46/1,
    // order 1) staje się bazą draftState nowego sezonu. Wyjątek: pierwszy sezon
    // (nowy save) nie ma nextDraftState — draftState zostaje null, a runLottery
    // wygeneruje draftClass "w locie" jako fallback (patrz zmiana w runLottery).
    final promotedDraftState = league.currentSeason.nextDraftState != null
        ? DraftState(
            year: newYear,
            draftClass: league.currentSeason.nextDraftState!.draftClass,
          )
        : null;

    var teams = league.teams.map((t) {
      final roster = t.roster.map((p) {
        final years = (p.contract.yearsRemaining - 1).clamp(0, 10);
        return p
            .copyWith(
              age: p.age + 1,
              contract: p.contract.copyWith(yearsRemaining: years),
              state: p.state.copyWith(
                seasonsWithTeam: p.state.seasonsWithTeam + 1,
                stamina: 90,
                regularSeasonYellowCards: 0,
                playoffYellowCards: 0,
              ),
            )
            .recalculatePointValue(balance);
      }).toList();

      var staff = t.staff;
      for (final role in StaffRole.values) {
        final member = staff.canonicalMember(role);
        final contract = member?.contract;
        if (member == null || contract == null) continue;
        staff = staff.withMember(
          role,
          member.copyWith(
            contract: contract.copyWith(
              yearsRemaining: (contract.yearsRemaining - 1).clamp(0, 10),
            ),
          ),
        );
      }

      // Player development ticks weekly in `DaySimulator`, not here — avoid
      // double-applying growth on top of the season's weekly ticks.
      var team = t.copyWith(
        roster: roster
            .map(
              (p) => p.copyWith(
                previousOvr: p.overall(balance).round(),
                seasonStartOvr: p.overall(balance),
                previousPotential: p.potentialStars,
              ),
            )
            .toList(),
        eventState: t.eventState.resetForSeason(),
        staff: staff,
        finance: t.finance.copyWith(midLevelExceptionAvailable: true),
        // Prognoza miejsca w tabeli (`projectedFinish`) i dyskonto czasowe
        // zmieniają się co sezon — przeliczyć wartość wszystkich
        // posiadanych picków pod nowy `currentYear`.
        ownedPicks: t.ownedPicks
            .map((p) => p.recalculateTradeValue(currentYear: newYear))
            .toList(),
      );

      return capService.applyPayroll(team);
    }).toList();

    final schedule = const ScheduleGenerator().generateDoubleRoundRobin(
      teams.map((t) => t.id).toList(),
    );
    final standings = [
      for (final conf in Conference.values)
        ConferenceStandings(
          conference: conf,
          standings: teams
              .where((t) => t.conference == conf)
              .map((t) => Standing(teamId: t.id))
              .toList(),
        ),
    ];

    var nextLeague = league.copyWith(
      teams: teams,
      history: [...league.history, history],
      currentWeek: 1,
      currentDay: 1,
      currentRound: 0,
      currentSeason: Season(
        year: newYear,
        phase: SeasonPhase.regular,
        schedule: schedule,
        standings: standings,
        draftState: promotedDraftState,
        staffGrowthDone: false,
        playerRetirementsDone: false,
        combineDone: false,
        finalMockDone: false,
        faOpenDone: false,
        scoutReportDone: false,
        tradeDeadlineAcked: false,
        nextDraftState: null,
        nextTvCapResetSeason: league.currentSeason.nextTvCapResetSeason,
        nextTvCapIncreasePct: league.currentSeason.nextTvCapIncreasePct,
        capUpdateTvDone: false,
      ),
    );
    nextLeague = expireContracts(nextLeague);
    return rosterManagement.ensurePreseasonRoster(
      nextLeague,
      saveSeed: saveSeed,
    );
  }

  Set<String> _playoffQualifiedTeamIds(LeagueState league) {
    final qualified = <String>{};
    for (final bracket in league.currentSeason.playoffBrackets) {
      for (final series in [
        ...bracket.quarterFinals,
        ...bracket.semiFinals,
        ...bracket.conferenceFinal,
        if (bracket.leagueFinal != null) bracket.leagueFinal!,
      ]) {
        qualified
          ..add(series.higherSeedTeamId)
          ..add(series.lowerSeedTeamId);
      }
    }
    return qualified;
  }

  MatchResult _sim(
    LeagueState league,
    String homeId,
    String awayId, {
    required int saveSeed,
    required String matchId,
    SeasonPhase phase = SeasonPhase.regular,
    MatchStake? stake,
  }) {
    final home = league.teamById(homeId)!;
    final away = league.teamById(awayId)!;
    final context = contextFactory.createForPostseason(
      home: home,
      away: away,
      seasonYear: league.currentSeason.year,
      matchId: matchId,
      saveSeed: saveSeed,
      stake: stake ?? _stakeForPhase(phase),
      week: league.currentWeek,
    );
    return aiMatchdayService.simulateFullMatch(
      home: home,
      away: away,
      context: context,
      saveSeed: saveSeed,
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      matchId: matchId,
      phase: phase,
      homeOpponentFormationHistory:
          AiMatchdayService.formationHistoryFromSchedule(
            league.currentSeason.schedule,
            home.id,
            away.id,
          ),
      awayOpponentFormationHistory:
          AiMatchdayService.formationHistoryFromSchedule(
            league.currentSeason.schedule,
            away.id,
            home.id,
          ),
    );
  }

  MatchStake _stakeForPhase(SeasonPhase phase) => switch (phase) {
    SeasonPhase.playIn => MatchStake.playIn,
    SeasonPhase.playoff => MatchStake.playoff,
    _ => MatchStake.regular,
  };

  ({LeagueState league, MatchResult result}) _simPostseason(
    LeagueState league,
    String homeId,
    String awayId, {
    required int saveSeed,
    required String matchId,
    required SeasonPhase phase,
    MatchStake? stake,
  }) {
    var state = rosterManagement.ensurePreMatchdaySafety(
      league,
      saveSeed: saveSeed,
    );
    final effectiveStake = stake ?? _stakeForPhase(phase);
    final home = state.teamById(homeId);
    final away = state.teamById(awayId);
    if (home != null && away != null && state.playerTeamId != null) {
      final playerInFixture =
          state.playerTeamId == homeId || state.playerTeamId == awayId;
      if (playerInFixture) {
        final context = contextFactory.createForPostseason(
          home: home,
          away: away,
          seasonYear: league.currentSeason.year,
          matchId: matchId,
          saveSeed: saveSeed,
          stake: effectiveStake,
          week: league.currentWeek,
        );
        final report = PreMatchValidator(
          balance: balance,
        ).validate(home: home, away: away);
        state = matchMessageEmitter.emitPreMatch(
          league: state,
          matchId: matchId,
          homeTeamId: homeId,
          awayTeamId: awayId,
          context: context,
          report: report,
        );
      }
    }
    final rawResult = _sim(
      state,
      homeId,
      awayId,
      saveSeed: saveSeed,
      matchId: matchId,
      phase: phase,
      stake: effectiveStake,
    );
    final result = _resolvePostseasonTiebreak(
      rawResult,
      saveSeed: saveSeed,
      seasonYear: state.currentSeason.year,
      matchId: matchId,
    );
    var postseasonState = _applyPostseasonDiscipline(
      state,
      result,
      phase,
      matchId: matchId,
    );
    postseasonState = teamEvents.afterMatch(
      postseasonState,
      result,
      saveSeed: saveSeed,
    );
    return (league: postseasonState, result: result);
  }

  String _winnerId(MatchResult r, String homeId, String awayId) {
    final persistedWinner = r.winnerTeamId;
    if (persistedWinner == homeId || persistedWinner == awayId) {
      return persistedWinner!;
    }
    if (r.wentToShootout && r.shootoutHomeGoals != r.shootoutAwayGoals) {
      return r.shootoutHomeGoals > r.shootoutAwayGoals ? homeId : awayId;
    }
    if (r.homeGoals == r.awayGoals) {
      final seed = matchSeed(0, 0, 'legacy-tiebreak:$homeId:$awayId');
      return seed.isEven ? homeId : awayId;
    }
    return r.homeGoals > r.awayGoals ? homeId : awayId;
  }

  PlayoffSeries _series(String high, String low) => PlayoffSeries(
    id: _uuid.v4(),
    higherSeedTeamId: high,
    lowerSeedTeamId: low,
    winsNeeded: 3,
  );

  ({LeagueState league, PlayoffBracket bracket}) _advanceBracket(
    LeagueState league,
    PlayoffBracket b,
    int saveSeed,
  ) {
    var state = league;
    final quarters = <PlayoffSeries>[];
    for (final series in b.quarterFinals) {
      if (series.isComplete) {
        quarters.add(series);
      } else {
        final played = _playOneGame(state, series, saveSeed);
        state = played.league;
        quarters.add(played.series);
      }
    }

    var semis = b.semiFinals;
    if (semis.isEmpty && quarters.every((s) => s.isComplete)) {
      semis = [
        _series(quarters[0].winnerTeamId!, quarters[3].winnerTeamId!),
        _series(quarters[1].winnerTeamId!, quarters[2].winnerTeamId!),
      ];
    } else {
      final advanced = <PlayoffSeries>[];
      for (final series in semis) {
        if (series.isComplete) {
          advanced.add(series);
        } else {
          final played = _playOneGame(state, series, saveSeed);
          state = played.league;
          advanced.add(played.series);
        }
      }
      semis = advanced;
    }

    var confFinal = b.conferenceFinal;
    if (confFinal.isEmpty &&
        semis.isNotEmpty &&
        semis.every((s) => s.isComplete)) {
      confFinal = [_series(semis[0].winnerTeamId!, semis[1].winnerTeamId!)];
    } else {
      final advanced = <PlayoffSeries>[];
      for (final series in confFinal) {
        if (series.isComplete) {
          advanced.add(series);
        } else {
          final played = _playOneGame(state, series, saveSeed);
          state = played.league;
          advanced.add(played.series);
        }
      }
      confFinal = advanced;
    }

    return (
      league: state,
      bracket: b.copyWith(
        quarterFinals: quarters,
        semiFinals: semis,
        conferenceFinal: confFinal,
      ),
    );
  }

  MatchStake _stakeForSeries(PlayoffSeries series) {
    final winsNeededForElimination = series.winsNeeded - 1;
    final eliminationGame =
        winsNeededForElimination > 0 &&
        (series.higherSeedWins >= winsNeededForElimination ||
            series.lowerSeedWins >= winsNeededForElimination);
    return eliminationGame ? MatchStake.playoffElimination : MatchStake.playoff;
  }

  ({LeagueState league, PlayoffSeries series}) _playOneGame(
    LeagueState league,
    PlayoffSeries series,
    int saveSeed, {
    MatchStake? stake,
  }) {
    final homeFirst = calendar.higherSeedHomeForGame(series.games.length);
    final homeId = homeFirst ? series.higherSeedTeamId : series.lowerSeedTeamId;
    final awayId = homeFirst ? series.lowerSeedTeamId : series.higherSeedTeamId;
    final played = _simPostseason(
      league,
      homeId,
      awayId,
      saveSeed: saveSeed,
      matchId: 'playoff:${series.id}:${series.games.length}',
      phase: SeasonPhase.playoff,
      stake: stake ?? _stakeForSeries(series),
    );
    return (league: played.league, series: series.recordGame(played.result));
  }

  MatchResult _resolvePostseasonTiebreak(
    MatchResult result, {
    required int saveSeed,
    required int seasonYear,
    required String matchId,
  }) {
    if (result.homeGoals != result.awayGoals) return result;

    final random = Random(matchSeed(saveSeed, seasonYear, '$matchId:tiebreak'));
    final homeId = result.homeTeamId;
    final awayId = result.awayTeamId;

    // A tied knockout match always reaches extra time. A deterministic
    // extra-time goal resolves most ties; the remaining ties go to a
    // deterministic shootout. The regulation score remains separate from
    // shootout kicks, so player/league statistics do not count penalties as
    // goals.
    if (random.nextDouble() < 0.55) {
      final homeWins = random.nextBool();
      final homeGoals = result.homeGoals + (homeWins ? 1 : 0);
      final awayGoals = result.awayGoals + (homeWins ? 0 : 1);
      final resolved = result.copyWith(
        homeGoals: homeGoals,
        awayGoals: awayGoals,
        homeStats: result.homeStats.copyWith(goals: homeGoals),
        awayStats: result.awayStats.copyWith(goals: awayGoals),
        wentToExtraTime: true,
        winnerTeamId: homeWins ? homeId : awayId,
        matchEndMinute: 120,
      );
      return _attributeExtraTimeGoal(
        resolved,
        teamId: homeWins ? homeId : awayId,
        random: random,
      );
    }

    var homeShootout = 3 + random.nextInt(3);
    var awayShootout = 3 + random.nextInt(3);
    if (homeShootout == awayShootout) {
      if (random.nextBool()) {
        homeShootout++;
      } else {
        awayShootout++;
      }
    }
    return result.copyWith(
      wentToExtraTime: true,
      wentToShootout: true,
      shootoutHomeGoals: homeShootout,
      shootoutAwayGoals: awayShootout,
      winnerTeamId: homeShootout > awayShootout ? homeId : awayId,
      matchEndMinute: 120,
    );
  }

  MatchResult _attributeExtraTimeGoal(
    MatchResult result, {
    required String teamId,
    required Random random,
  }) {
    final teamPlayerIds = teamId == result.homeTeamId
        ? {
            ...result.homeLineup.map((player) => player.id),
            ...result.homeSnapshot.startingXi.map((player) => player.id),
            ...result.homeSnapshot.bench.map((player) => player.id),
          }
        : {
            ...result.awayLineup.map((player) => player.id),
            ...result.awaySnapshot.startingXi.map((player) => player.id),
            ...result.awaySnapshot.bench.map((player) => player.id),
          };
    final eligible = result.playerStats
        .where((stats) => teamPlayerIds.contains(stats.playerId))
        .toList();
    if (eligible.isEmpty) return result;
    final played = eligible.where((stats) => stats.minutes > 0).toList();
    final scorerPool = played.isEmpty ? eligible : played;
    final scorer = scorerPool[random.nextInt(scorerPool.length)];

    return result.copyWith(
      playerStats: [
        for (final stats in result.playerStats)
          if (stats.playerId == scorer.playerId)
            stats.copyWith(goals: stats.goals + 1)
          else
            stats,
      ],
      events: [
        ...result.events,
        MatchEvent(
          type: MatchEventType.goal,
          minute: 105,
          teamId: teamId,
          playerId: scorer.playerId,
          description: 'extra_time_goal',
        ),
      ],
    );
  }

  LeagueState _applyPostseasonDiscipline(
    LeagueState league,
    MatchResult result,
    SeasonPhase phase, {
    String? matchId,
  }) {
    final disciplineService = const DisciplineService();
    final administrativeTeamIds = TeamManagementService.walkoverTeamIds(result);
    final isAdministrative = TeamManagementService.isWalkoverResult(result);
    final statsByPlayer = {
      for (final stats in result.playerStats) stats.playerId: stats,
    };
    final injuriesByPlayer = {
      for (final injury in result.injuries)
        if (injury.teamId == result.homeTeamId ||
            injury.teamId == result.awayTeamId)
          '${injury.teamId}:${injury.playerId}': injury,
    };
    final notifications =
        <({String teamId, DisciplineNotification notification})>[];

    final teams = league.teams.map((team) {
      final isParticipant =
          team.id == result.homeTeamId || team.id == result.awayTeamId;
      if (!isParticipant) return team;

      var next = team;
      if (!isAdministrative) {
        final roster = team.roster
            .map(
              (player) => applyMatchPlayerEffects(
                player: player,
                teamId: team.id,
                result: result,
                seasonYear: league.currentSeason.year,
                balance: balance,
                stats: statsByPlayer[player.id],
                matchInjury: injuriesByPlayer['${team.id}:${player.id}'],
              ),
            )
            .toList();
        next = team.copyWith(roster: roster);

        final application = disciplineService.applyToTeam(
          team: next,
          result: result,
          phase: phase,
        );
        notifications.addAll(
          application.notifications.map(
            (notification) => (teamId: team.id, notification: notification),
          ),
        );
        next = application.team;
      }

      final original = league.teamById(team.id);
      final snapshot = team.id == result.homeTeamId
          ? result.homeLineup
          : result.awayLineup;
      final startingEleven = snapshot.isNotEmpty
          ? snapshot
          : original?.startingEleven ?? const <Player>[];
      final assignedPositions = team.id == result.homeTeamId
          ? result.homeLineupPositions
          : result.awayLineupPositions;
      next = const TeamManagementService()
          .applyMatchResult(
            team: next,
            result: result,
            startingEleven: startingEleven,
            assignedPositions: assignedPositions.isEmpty
                ? null
                : assignedPositions,
          )
          .team;
      if (isAdministrative && administrativeTeamIds.contains(team.id)) {
        next = const TeamManagementService().applyAtmosphereDelta(next, -15);
      }
      return next;
    }).toList();

    var state = league.copyWith(teams: teams);
    for (final item in notifications) {
      if (state.playerTeamId != item.teamId) continue;
      final notification = item.notification;
      if (notification.started) {
        state = _messages.send(
          state,
          type: MessageType.suspensionStart,
          domain: MessageDomain.matchday,
          priority: notification.playerInStartingXi
              ? MessagePriority.urgent
              : MessagePriority.normal,
          args: {
            'playerName': notification.player.name,
            'games': notification.games,
          },
          payload: {
            'playerId': notification.player.id,
            'teamId': item.teamId,
            'games': notification.games,
            'reason': notification.reason,
            'playerInStartingXi': notification.playerInStartingXi,
          },
        );
      }
      if (notification.ended) {
        state = _messages.send(
          state,
          type: MessageType.suspensionEnd,
          domain: MessageDomain.matchday,
          args: {'playerName': notification.player.name},
          payload: {'playerId': notification.player.id, 'teamId': item.teamId},
        );
      }
    }

    for (final injury in result.injuries) {
      final team = state.teamById(injury.teamId);
      final player = team?.roster.cast<Player?>().firstWhere(
        (candidate) => candidate?.id == injury.playerId,
        orElse: () => null,
      );
      if (team == null || player == null || state.playerTeamId != team.id) {
        continue;
      }
      final definition = InjuryCatalog.byId(injury.injury.id);
      state = _messages.send(
        state,
        type: MessageType.injury,
        domain: MessageDomain.health,
        args: {
          'playerName': player.name,
          'injuryName': definition.name,
          'injuryType': injury.injury.type.name,
          'days': injury.injury.daysTotal,
        },
        payload: {
          'playerId': player.id,
          'teamId': team.id,
          'injuryId': injury.injury.id,
          'injuryType': injury.injury.type.name,
          'playerInStartingXi': injury.playerInStartingXi,
        },
        dedupKey: 'injury:${player.id}:${injury.injury.id}',
      );
      if (injury.potentialLoss) {
        state = _messages.send(
          state,
          type: MessageType.potentialLoss,
          domain: MessageDomain.health,
          args: {'playerName': player.name},
          payload: {'playerId': player.id, 'injuryId': injury.injury.id},
          dedupKey: 'potentialLoss:${player.id}:${injury.injury.id}',
        );
      }
    }

    final inspiredId = result.inspiredPerformancePlayerId;
    if (inspiredId != null) {
      final team = state.teamById(result.homeTeamId);
      final awayTeam = state.teamById(result.awayTeamId);
      final player =
          team?.roster.cast<Player?>().firstWhere(
            (candidate) => candidate?.id == inspiredId,
            orElse: () => null,
          ) ??
          awayTeam?.roster.cast<Player?>().firstWhere(
            (candidate) => candidate?.id == inspiredId,
            orElse: () => null,
          );
      final inspiredTeam = team?.roster.any((p) => p.id == inspiredId) == true
          ? team
          : awayTeam;
      if (player != null &&
          inspiredTeam != null &&
          state.playerTeamId == inspiredTeam.id) {
        final stat = statsByPlayer[inspiredId];
        state = _messages.send(
          state,
          type: MessageType.playerEvent,
          kind: 'inspiredPerformance',
          domain: MessageDomain.playerEvent,
          args: {'playerName': player.name},
          payload: {
            'playerId': inspiredId,
            'teamId': inspiredTeam.id,
            'rating': stat?.rating ?? 0.0,
            'manOfTheMatch': true,
          },
          dedupKey: 'inspired:${matchId ?? result.homeTeamId}:$inspiredId',
        );
      }
    }

    final playerTeamId = state.playerTeamId;
    if (playerTeamId == result.homeTeamId ||
        playerTeamId == result.awayTeamId) {
      if (!TeamManagementService.isWalkoverResult(result)) {
        return state;
      }
      final responsibleTeamId = result.violatingTeamIds.isEmpty
          ? result.homeTeamId
          : result.violatingTeamIds.first;
      state = _messages.send(
        state,
        type: MessageType.walkover,
        args: {
          'homeTeam':
              league.teamById(result.homeTeamId)?.name ?? result.homeTeamId,
          'awayTeam':
              league.teamById(result.awayTeamId)?.name ?? result.awayTeamId,
          'team': league.teamById(responsibleTeamId)?.name ?? responsibleTeamId,
          'reason': result.reasonCode ?? 'administrative_result',
        },
        payload: {
          'matchId': matchId,
          'homeTeamId': result.homeTeamId,
          'awayTeamId': result.awayTeamId,
          'teamId': responsibleTeamId,
          'reasonCode': result.reasonCode,
          'violatingTeamIds': result.violatingTeamIds,
        },
        dedupKey: matchId == null ? null : 'walkover:$matchId',
      );
    }
    return state;
  }

  SeasonAwards _computeAwards(LeagueState league) {
    const possibleMinutes = 58 * 90;
    final playersById = <String, Player>{};
    final currentTeamByPlayerId = <String, String>{};
    for (final team in league.teams) {
      for (final player in team.roster) {
        playersById[player.id] = player;
        currentTeamByPlayerId[player.id] = team.id;
      }
    }

    final regularResults = league.currentSeason.schedule
        .map((match) => match.result)
        .whereType<MatchResult>()
        .toList();
    final regularStats = _collectAwardStats(
      league,
      regularResults,
      postseason: false,
    );
    final postseasonStats = _collectAwardStats(
      league,
      _postseasonResults(league.currentSeason),
      postseason: true,
    );

    final candidates = <_AwardCandidate>[];
    for (final player in playersById.values) {
      final stats = regularResults.isEmpty
          ? _AwardStats.fromSeasonStats(
              player.seasonStats.firstWhere(
                (item) => item.year == league.currentSeason.year,
                orElse: () =>
                    PlayerSeasonStats(year: league.currentSeason.year),
              ),
              player.position,
            )
          : (regularStats[player.id] ?? _AwardStats());
      stats.mergePostseason(postseasonStats[player.id]);
      candidates.add(
        _AwardCandidate(
          player: player,
          teamId: currentTeamByPlayerId[player.id],
          stats: stats,
        ),
      );
    }

    final mvpPool = candidates.where(
      (candidate) => candidate.stats.minutes >= possibleMinutes * 0.40,
    );
    final mvp = _bestCandidate(mvpPool, (candidate) => _mvpScore(candidate));

    final rotyPool = candidates.where(
      (candidate) =>
          candidate.player.draftYear == league.currentSeason.year - 1 &&
          candidate.stats.minutes >= possibleMinutes * 0.25,
    );
    final roty = _bestCandidate(
      rotyPool,
      (candidate) => _mvpScore(candidate, rookie: true),
    );

    final dpoyPool = candidates.where(
      (candidate) => candidate.stats.minutes >= possibleMinutes * 0.40,
    );
    final dpoy = _bestDefender(dpoyPool);

    final topScorer = _bestStatCandidate(
      candidates,
      (candidate) => candidate.stats.goals,
      (candidate) => candidate.stats.assists,
    );
    final topAssist = _bestStatCandidate(
      candidates,
      (candidate) => candidate.stats.assists,
      (candidate) => candidate.stats.goals,
    );

    final gkPool = candidates.where(
      (candidate) => candidate.stats.gkMinutes >= possibleMinutes * 0.40,
    );
    final bestGk = _bestGoalkeeper(gkPool);

    final coachTeamId = _coachOfYearTeamId(league);
    final teamOfSeason = _computeTeamOfSeason(
      candidates,
      possibleMinutes: possibleMinutes,
    );

    final awardedPlayerIds = <String>{
      if (mvp != null) mvp.player.id,
      if (roty != null) roty.player.id,
      if (dpoy != null) dpoy.player.id,
      if (topScorer != null) topScorer.player.id,
      if (topAssist != null) topAssist.player.id,
      if (bestGk != null) bestGk.player.id,
      ...teamOfSeason.values,
    };
    final playerNames = <String, String>{};
    for (final playerId in awardedPlayerIds) {
      final player = playersById[playerId];
      if (player != null) playerNames[playerId] = player.name;
    }

    return SeasonAwards(
      year: league.currentSeason.year,
      mvpPlayerId: mvp?.player.id,
      rotyPlayerId: roty?.player.id,
      dpoyPlayerId: dpoy?.player.id,
      topScorerPlayerId: topScorer?.player.id,
      topAssistPlayerId: topAssist?.player.id,
      bestGkPlayerId: bestGk?.player.id,
      playerNames: playerNames,
      coachOfYearTeamId: coachTeamId,
      teamOfSeason: teamOfSeason,
      championTeamId: league.currentSeason.championTeamId,
    );
  }

  LeagueState _sendAwardMessages(LeagueState league, SeasonAwards awards) {
    var state = league;

    void sendPlayerAward(String kind, String? playerId) {
      if (playerId == null) return;
      final teamId = _teamIdForPlayer(state, playerId);
      state = _messages.send(
        state,
        type: MessageType.award,
        kind: kind,
        domain: MessageDomain.season,
        args: {
          'playerName': _playerName(state, playerId),
          'teamName': teamId == null ? '—' : _teamName(state, teamId),
          'ownClub': teamId != null && teamId == state.playerTeamId,
        },
        payload: {
          'playerId': playerId,
          'teamId': teamId,
          'ownClub': teamId != null && teamId == state.playerTeamId,
          'awardYear': awards.year,
        },
      );
    }

    sendPlayerAward('mvp', awards.mvpPlayerId);
    sendPlayerAward('roty', awards.rotyPlayerId);
    sendPlayerAward('dpoy', awards.dpoyPlayerId);
    sendPlayerAward('topScorer', awards.topScorerPlayerId);
    sendPlayerAward('topAssist', awards.topAssistPlayerId);
    sendPlayerAward('bestGk', awards.bestGkPlayerId);

    final coachTeamId = awards.coachOfYearTeamId;
    if (coachTeamId != null) {
      state = _messages.send(
        state,
        type: MessageType.award,
        kind: 'coachOfYear',
        domain: MessageDomain.season,
        args: {
          'teamName': _teamName(state, coachTeamId),
          'ownClub': coachTeamId == state.playerTeamId,
        },
        payload: {
          'teamId': coachTeamId,
          'ownClub': coachTeamId == state.playerTeamId,
          'awardYear': awards.year,
        },
      );
    }

    if (awards.teamOfSeason.isNotEmpty) {
      final teamOfSeasonPlayers = awards.teamOfSeason.values.toSet();
      final teamOfSeasonOwnClub = teamOfSeasonPlayers.any(
        (playerId) => _teamIdForPlayer(state, playerId) == state.playerTeamId,
      );
      state = _messages.send(
        state,
        type: MessageType.award,
        kind: 'teamOfSeason',
        domain: MessageDomain.season,
        args: {
          'playerName': teamOfSeasonPlayers
              .map((playerId) => _playerName(state, playerId))
              .join(', '),
          'slot': '4-3-3',
          'ownClub': teamOfSeasonOwnClub,
        },
        payload: {
          'teamOfSeason': awards.teamOfSeason,
          'ownClub': teamOfSeasonOwnClub,
          'awardYear': awards.year,
        },
      );
    }

    final championTeamId = awards.championTeamId;
    if (championTeamId == null) return state;
    return _messages.send(
      state,
      type: MessageType.award,
      kind: 'champion',
      domain: MessageDomain.season,
      args: {
        'teamName': _teamName(state, championTeamId),
        'ownClub': championTeamId == state.playerTeamId,
      },
      payload: {
        'teamId': championTeamId,
        'ownClub': championTeamId == state.playerTeamId,
        'awardYear': awards.year,
      },
    );
  }

  String? _teamIdForPlayer(LeagueState league, String? playerId) {
    if (playerId == null) return null;
    for (final team in league.teams) {
      if (team.roster.any((player) => player.id == playerId)) return team.id;
    }
    return null;
  }

  Map<String, _AwardStats> _collectAwardStats(
    LeagueState league,
    Iterable<MatchResult> results, {
    required bool postseason,
  }) {
    final currentPlayers = <String, Player>{};
    final currentTeamByPlayerId = <String, String>{};
    for (final team in league.teams) {
      for (final player in team.roster) {
        currentPlayers[player.id] = player;
        currentTeamByPlayerId[player.id] = team.id;
      }
    }

    final byPlayer = <String, _AwardStats>{};
    for (final result in results) {
      final playerTeamIds = <String, String>{
        for (final player in [
          ...result.homeLineup,
          ...result.homeSnapshot.startingXi,
        ])
          player.id: result.homeTeamId,
        for (final player in [
          ...result.awayLineup,
          ...result.awaySnapshot.startingXi,
        ])
          player.id: result.awayTeamId,
      };
      for (final stat in result.playerStats) {
        final player = currentPlayers[stat.playerId];
        if (player == null) continue;
        final teamId =
            playerTeamIds[stat.playerId] ?? currentTeamByPlayerId[player.id];
        if (teamId == null) continue;
        final isHome = teamId == result.homeTeamId;
        final scored = isHome ? result.homeGoals : result.awayGoals;
        final conceded = isHome ? result.awayGoals : result.homeGoals;
        final teamPoints = scored > conceded
            ? 3
            : scored == conceded
            ? 1
            : 0;
        final position = _positionForPlayer(result, stat.playerId, player);
        final aggregate = byPlayer.putIfAbsent(stat.playerId, _AwardStats.new);
        aggregate.addMatch(
          stat,
          position: position,
          teamPoints: teamPoints,
          conceded: conceded,
          postseason: postseason,
        );
      }
    }
    return byPlayer;
  }

  Position _positionForPlayer(
    MatchResult result,
    String playerId,
    Player player,
  ) {
    final homeIndex = result.homeLineup.indexWhere(
      (candidate) => candidate.id == playerId,
    );
    if (homeIndex >= 0 && homeIndex < result.homeLineupPositions.length) {
      return result.homeLineupPositions[homeIndex];
    }
    final awayIndex = result.awayLineup.indexWhere(
      (candidate) => candidate.id == playerId,
    );
    if (awayIndex >= 0 && awayIndex < result.awayLineupPositions.length) {
      return result.awayLineupPositions[awayIndex];
    }
    return player.position;
  }

  List<MatchResult> _postseasonResults(Season season) {
    final seen = <MatchResult>{};
    final results = <MatchResult>[];
    void add(MatchResult? result) {
      if (result != null && seen.add(result)) results.add(result);
    }

    for (final progress in season.playInProgress) {
      add(progress.game7v8);
      add(progress.game9v10);
      add(progress.gameFinal);
    }
    for (final result in season.playInResults) {
      add(result.game7v8);
      add(result.game9v10);
      add(result.gameFinal);
    }
    for (final bracket in season.playoffBrackets) {
      for (final series in [
        ...bracket.quarterFinals,
        ...bracket.semiFinals,
        ...bracket.conferenceFinal,
        if (bracket.leagueFinal != null) bracket.leagueFinal!,
      ]) {
        for (final result in series.games) {
          add(result);
        }
      }
    }
    return results;
  }

  _AwardCandidate? _bestCandidate(
    Iterable<_AwardCandidate> candidates,
    double Function(_AwardCandidate) score,
  ) {
    _AwardCandidate? best;
    var bestScore = double.negativeInfinity;
    for (final candidate in candidates) {
      final currentScore = score(candidate);
      if (currentScore > bestScore ||
          (currentScore == bestScore &&
              (best == null ||
                  candidate.player.id.compareTo(best.player.id) < 0))) {
        best = candidate;
        bestScore = currentScore;
      }
    }
    return best;
  }

  double _mvpScore(_AwardCandidate candidate, {bool rookie = false}) {
    final stats = candidate.stats;
    final teamShare = stats.teamPossiblePointsWhenOn == 0
        ? 0.0
        : stats.teamPointsWhenOn / stats.teamPossiblePointsWhenOn;
    final production = stats.minutes == 0
        ? 0.0
        : ((stats.goals + stats.assists) * 90 / stats.minutes / 4)
              .clamp(0.0, 1.0)
              .toDouble();
    final playoffBonus = stats.postseasonMinutes == 0
        ? 0.0
        : ((stats.postseasonGoals + stats.postseasonAssists) *
                      90 /
                      stats.postseasonMinutes /
                      4 +
                  stats.postseasonRatingAvg / 10)
              .clamp(0.0, 1.0)
              .toDouble();
    final overallNorm = ((candidate.player.overall(balance) - 50) / 49)
        .clamp(0.0, 1.0)
        .toDouble();
    final playoffWeight = rookie ? 0.05 : 0.10;
    return 0.35 * teamShare +
        0.25 * (stats.ratingAvg / 10).clamp(0.0, 1.0).toDouble() +
        0.20 * production +
        playoffWeight * (rookie ? playoffBonus * 0.5 : playoffBonus) +
        0.10 * overallNorm;
  }

  _AwardCandidate? _bestDefender(Iterable<_AwardCandidate> pool) {
    final candidates = pool.toList();
    if (candidates.isEmpty) return null;
    final maxDefensiveActions = candidates.fold<int>(
      0,
      (max, candidate) =>
          max > candidate.stats.tackles + candidate.stats.interceptions
          ? max
          : candidate.stats.tackles + candidate.stats.interceptions,
    );
    final maxConcededRate = candidates.fold<double>(
      0.0,
      (max, candidate) => max > candidate.stats.concededPer90
          ? max
          : candidate.stats.concededPer90,
    );
    return _bestCandidate(candidates, (candidate) {
      final stats = candidate.stats;
      final cleanShare = stats.appearances == 0
          ? 0.0
          : stats.cleanSheets / stats.appearances;
      final actions = maxDefensiveActions == 0
          ? 0.0
          : (stats.tackles + stats.interceptions) / maxDefensiveActions;
      final conceded = maxConcededRate == 0
          ? 1.0
          : (1 - stats.concededPer90 / maxConcededRate)
                .clamp(0.0, 1.0)
                .toDouble();
      return 0.40 * (stats.ratingAvg / 10).clamp(0.0, 1.0).toDouble() +
          0.25 * cleanShare +
          0.20 * actions +
          0.15 * conceded;
    });
  }

  _AwardCandidate? _bestStatCandidate(
    Iterable<_AwardCandidate> candidates,
    int Function(_AwardCandidate) primary,
    int Function(_AwardCandidate) secondary,
  ) {
    final sorted =
        candidates.where((candidate) => primary(candidate) > 0).toList()..sort((
          a,
          b,
        ) {
          final primaryCompare = primary(b).compareTo(primary(a));
          if (primaryCompare != 0) return primaryCompare;
          final minutesCompare = a.stats.minutes.compareTo(b.stats.minutes);
          if (minutesCompare != 0) return minutesCompare;
          final secondaryCompare = secondary(b).compareTo(secondary(a));
          if (secondaryCompare != 0) return secondaryCompare;
          final ratingCompare = b.stats.ratingAvg.compareTo(a.stats.ratingAvg);
          if (ratingCompare != 0) return ratingCompare;
          return a.player.id.compareTo(b.player.id);
        });
    return sorted.isEmpty ? null : sorted.first;
  }

  _AwardCandidate? _bestGoalkeeper(Iterable<_AwardCandidate> pool) {
    final candidates = pool.toList();
    if (candidates.isEmpty) return null;
    final maxCleanSheets = candidates.fold<int>(
      0,
      (max, candidate) =>
          max > candidate.stats.cleanSheets ? max : candidate.stats.cleanSheets,
    );
    final maxGoalsPrevented = candidates.fold<double>(
      0.0,
      (max, candidate) => max > candidate.stats.goalsPrevented
          ? max
          : candidate.stats.goalsPrevented.toDouble(),
    );
    return _bestCandidate(candidates, (candidate) {
      final stats = candidate.stats;
      final savePct = stats.shotsFaced == 0
          ? 0.0
          : stats.saves / stats.shotsFaced;
      final cleanSheets = maxCleanSheets == 0
          ? 0.0
          : stats.cleanSheets / maxCleanSheets;
      final goalsPrevented = maxGoalsPrevented == 0
          ? 0.0
          : stats.goalsPrevented / maxGoalsPrevented;
      return 0.45 * savePct +
          0.25 * cleanSheets +
          0.20 * goalsPrevented +
          0.10 * (stats.ratingAvg / 10).clamp(0.0, 1.0).toDouble();
    });
  }

  Map<TeamOfSeasonSlot, String> _computeTeamOfSeason(
    Iterable<_AwardCandidate> candidates, {
    required int possibleMinutes,
  }) {
    const slotPositions = <TeamOfSeasonSlot, List<Position>>{
      TeamOfSeasonSlot.gk: [Position.gk],
      TeamOfSeasonSlot.lb: [Position.lb, Position.lwb],
      TeamOfSeasonSlot.cb1: [Position.cb],
      TeamOfSeasonSlot.cb2: [Position.cb],
      TeamOfSeasonSlot.rb: [Position.rb, Position.rwb],
      TeamOfSeasonSlot.mid1: [Position.cdm, Position.cm, Position.cam],
      TeamOfSeasonSlot.mid2: [Position.cdm, Position.cm, Position.cam],
      TeamOfSeasonSlot.mid3: [Position.cdm, Position.cm, Position.cam],
      TeamOfSeasonSlot.lw: [Position.lw],
      TeamOfSeasonSlot.st: [Position.st],
      TeamOfSeasonSlot.rw: [Position.rw],
    };
    final options = <_TeamOfSeasonOption>[];
    for (final slot in TeamOfSeasonSlot.values) {
      final positions = slotPositions[slot]!;
      for (final candidate in candidates) {
        final minutes = positions.fold<int>(
          0,
          (sum, position) =>
              sum + (candidate.stats.positionMinutes[position] ?? 0),
        );
        if (minutes < possibleMinutes * 0.30) continue;
        final score = _teamOfSeasonScore(candidate, minutes);
        options.add(
          _TeamOfSeasonOption(
            slot: slot,
            playerId: candidate.player.id,
            score: score,
          ),
        );
      }
    }
    options.sort((a, b) {
      final score = b.score.compareTo(a.score);
      if (score != 0) return score;
      final slot = a.slot.index.compareTo(b.slot.index);
      if (slot != 0) return slot;
      return a.playerId.compareTo(b.playerId);
    });

    final result = <TeamOfSeasonSlot, String>{};
    final usedPlayers = <String>{};
    for (final option in options) {
      if (result.containsKey(option.slot) ||
          usedPlayers.contains(option.playerId)) {
        continue;
      }
      result[option.slot] = option.playerId;
      usedPlayers.add(option.playerId);
    }
    return result;
  }

  double _teamOfSeasonScore(_AwardCandidate candidate, int minutes) {
    final stats = candidate.stats;
    final production = minutes == 0
        ? 0.0
        : ((stats.goals + stats.assists) * 90 / minutes / 4)
              .clamp(0.0, 1.0)
              .toDouble();
    final defensive = ((stats.tackles + stats.interceptions) / 40)
        .clamp(0.0, 1.0)
        .toDouble();
    return 0.60 * (stats.ratingAvg / 10).clamp(0.0, 1.0).toDouble() +
        0.25 * production +
        0.15 * defensive;
  }

  String? _coachOfYearTeamId(LeagueState league) {
    final standings =
        [
          for (final conference in league.currentSeason.standings)
            ...conference.standings,
        ]..sort((a, b) {
          final points = b.points.compareTo(a.points);
          if (points != 0) return points;
          final difference = b.goalDifference.compareTo(a.goalDifference);
          if (difference != 0) return difference;
          final goals = b.goalsFor.compareTo(a.goalsFor);
          if (goals != 0) return goals;
          return a.teamId.compareTo(b.teamId);
        });
    final finalPositions = <String, int>{
      for (var index = 0; index < standings.length; index++)
        standings[index].teamId: index + 1,
    };

    String? bestTeamId;
    var bestScore = double.negativeInfinity;
    var bestPlace = double.negativeInfinity;
    for (final team in league.teams) {
      if (team.staff.headCoach == null) continue;
      final standing = standings.firstWhere(
        (item) => item.teamId == team.id,
        orElse: () => Standing(teamId: team.id),
      );
      final entry = league.strengthTable?.entryFor(team.id);
      final expectedRank = entry?.expectedRank ?? 15;
      final finalPosition = finalPositions[team.id] ?? 30;
      final placeVsSeed = expectedRank - finalPosition;
      final winsVsProjected =
          standing.wins - TeamManagementService.expectedWins(expectedRank);
      final score = winsVsProjected + placeVsSeed;
      if (score > bestScore ||
          (score == bestScore && placeVsSeed > bestPlace) ||
          (score == bestScore &&
              placeVsSeed == bestPlace &&
              (bestTeamId == null || team.id.compareTo(bestTeamId) < 0))) {
        bestTeamId = team.id;
        bestScore = score.toDouble();
        bestPlace = placeVsSeed.toDouble();
      }
    }
    return bestTeamId;
  }

  List<LotteryResult> _computeLotteryResults(LeagueState league) {
    final all = <Standing>[];
    for (final cs in league.currentSeason.standings) {
      all.addAll(cs.standings);
    }
    all.sort((a, b) {
      final pts = a.points.compareTo(b.points);
      if (pts != 0) return pts;
      return a.goalDifference.compareTo(b.goalDifference);
    });
    final lotteryTeams = all.take(10).toList();
    if (lotteryTeams.length < 10) return [];
    final weights = [140, 120, 100, 90, 80, 70, 60, 50, 40, 30];
    final remaining = List<Standing>.from(lotteryTeams);
    final remainingWeights = List<int>.from(weights);
    final results = <LotteryResult>[];
    final totalOdds = weights.fold<int>(0, (s, w) => s + w);

    for (var pick = 1; pick <= 10; pick++) {
      final total = remainingWeights.fold<int>(0, (s, w) => s + w);
      var roll = _random.nextInt(total);
      var idx = 0;
      for (var i = 0; i < remainingWeights.length; i++) {
        roll -= remainingWeights[i];
        if (roll < 0) {
          idx = i;
          break;
        }
      }
      results.add(
        LotteryResult(
          teamId: remaining[idx].teamId,
          originalRank:
              all.indexWhere((s) => s.teamId == remaining[idx].teamId) + 1,
          assignedPick: pick,
          oddsForFirstPick: remainingWeights[idx] / totalOdds,
        ),
      );
      remaining.removeAt(idx);
      remainingWeights.removeAt(idx);
    }
    return results;
  }

  /// Buduje kolejność draftu na [currentYear]. Dla każdego slotu próbuje
  /// znaleźć pasujący, wcześniej wygenerowany `DraftPick`
  /// (`originalTeamId` + `year` + `round`) w puli którejkolwiek drużyny —
  /// tak materializuje się realny efekt handlu przyszłymi pickami
  /// (`Team.ownedPicks`, `docs/trade_rules.md`). Jeśli żadna drużyna nie
  /// posiada takiego picka (np. pierwszy sezon kariery — pick na rok
  /// bieżący nigdy nie został wstępnie wygenerowany), slot jest
  /// syntetyzowany na miejscu i przypisany drużynie oryginalnej.
  ///
  /// Zwraca zbudowaną kolejność oraz zbiór `id` picków skonsumowanych z
  /// `ownedPicks` — wywołujący (`runLottery`) musi je usunąć z odpowiednich
  /// drużyn.
  (List<DraftPick>, Set<String>) _buildDraftOrder(
    LeagueState league,
    List<LotteryResult> lottery,
    int currentYear,
  ) {
    final all = <Standing>[];
    for (final cs in league.currentSeason.standings) {
      all.addAll(cs.standings);
    }
    all.sort((a, b) {
      final pts = a.points.compareTo(b.points);
      if (pts != 0) return pts;
      return a.goalDifference.compareTo(b.goalDifference);
    });
    final lotteryIds = lottery.map((l) => l.teamId).toSet();
    final nonLottery = all
        .where((s) => !lotteryIds.contains(s.teamId))
        .toList()
        .reversed
        .toList();

    final r1 = <String>[
      ...lottery.map((l) => l.teamId),
      ...nonLottery.map((s) => s.teamId),
    ];
    while (r1.length < 30) {
      for (final s in all) {
        if (!r1.contains(s.teamId)) r1.add(s.teamId);
        if (r1.length >= 30) break;
      }
      if (r1.length < 30) break;
    }

    final consumed = <String>{};

    DraftPick? findOwnedPick(String originalTeamId, int round) {
      for (final t in league.teams) {
        for (final p in t.ownedPicks) {
          if (p.originalTeamId == originalTeamId &&
              p.year == currentYear &&
              p.round == round) {
            return p.copyWith(teamId: t.id);
          }
        }
      }
      return null;
    }

    DraftPick pickFor(String originalTeamId, int round, int overallPickNumber) {
      final owned = findOwnedPick(originalTeamId, round);
      if (owned != null) {
        consumed.add(owned.id);
        return owned.copyWith(pickNumber: overallPickNumber);
      }
      // Brak wstępnie wygenerowanego picka (typowo: pierwszy sezon kariery)
      // — syntetyzujemy slot na miejscu, przypisany oryginalnej drużynie.
      return DraftPick(
        id: 'draftpick_${currentYear}_${round}_$originalTeamId',
        year: currentYear,
        round: round,
        pickNumber: overallPickNumber,
        teamId: originalTeamId,
        originalTeamId: originalTeamId,
      );
    }

    final picks = <DraftPick>[];
    for (var round = 1; round <= 3; round++) {
      for (var i = 0; i < 30; i++) {
        final overallPickNumber = (round - 1) * 30 + i + 1;
        picks.add(pickFor(r1[i % r1.length], round, overallPickNumber));
      }
    }
    return (picks, consumed);
  }

  String _playerName(LeagueState s, String? id) {
    if (id == null) return '—';
    for (final t in s.teams) {
      for (final p in t.roster) {
        if (p.id == id) return p.name;
      }
    }
    return id;
  }

  String _teamName(LeagueState s, String id) => s.teamById(id)?.name ?? id;

  LeagueState _msg(
    LeagueState league,
    MessageType type,
    String title,
    String body, {
    bool urgent = false,
  }) {
    return _messages.send(
      league,
      type: type,
      priority: urgent ? MessagePriority.urgent : MessagePriority.normal,
      titleKey: 'msg_${type.name}_title',
      bodyKey: 'msg_${type.name}_body',
      args: {'_legacyTitle': title, '_legacyBody': body},
    );
  }
}

class _AwardCandidate {
  const _AwardCandidate({
    required this.player,
    required this.teamId,
    required this.stats,
  });

  final Player player;
  final String? teamId;
  final _AwardStats stats;
}

class _AwardStats {
  _AwardStats() : positionMinutes = {};

  _AwardStats.fromSeasonStats(PlayerSeasonStats stats, Position naturalPosition)
    : minutes = stats.minutes,
      goals = stats.goals,
      assists = stats.assists,
      appearances = stats.appearances,
      tackles = stats.tackles,
      interceptions = stats.interceptions,
      cleanSheets = stats.cleanSheets,
      saves = stats.saves,
      shotsFaced = stats.shotsFaced,
      ratingTotal = stats.ratingAvg * (stats.minutes > 0 ? stats.minutes : 1),
      ratingWeight = stats.minutes > 0 ? stats.minutes : 1,
      gkMinutes = naturalPosition == Position.gk ? stats.minutes : 0,
      goalsPrevented = (stats.shotsFaced - stats.goals).clamp(
        0,
        stats.shotsFaced,
      ),
      positionMinutes = {naturalPosition: stats.minutes};

  int minutes = 0;
  int goals = 0;
  int assists = 0;
  int appearances = 0;
  int tackles = 0;
  int interceptions = 0;
  int cleanSheets = 0;
  int saves = 0;
  int shotsFaced = 0;
  int gkMinutes = 0;
  int goalsPrevented = 0;
  int goalsConcededWhenOn = 0;
  int teamPointsWhenOn = 0;
  int teamPossiblePointsWhenOn = 0;
  double ratingTotal = 0.0;
  int ratingWeight = 0;
  late final Map<Position, int> positionMinutes;

  int postseasonMinutes = 0;
  int postseasonGoals = 0;
  int postseasonAssists = 0;
  double postseasonRatingTotal = 0.0;
  int postseasonRatingWeight = 0;

  double get ratingAvg => ratingWeight == 0 ? 0.0 : ratingTotal / ratingWeight;

  double get postseasonRatingAvg => postseasonRatingWeight == 0
      ? 0.0
      : postseasonRatingTotal / postseasonRatingWeight;

  double get concededPer90 =>
      minutes == 0 ? 0.0 : goalsConcededWhenOn * 90 / minutes;

  void addMatch(
    PlayerMatchStats stat, {
    required Position position,
    required int teamPoints,
    required int conceded,
    required bool postseason,
  }) {
    if (postseason) {
      postseasonMinutes += stat.minutes;
      postseasonGoals += stat.goals;
      postseasonAssists += stat.assists;
      if (stat.minutes > 0) {
        postseasonRatingTotal += stat.rating * stat.minutes;
        postseasonRatingWeight += stat.minutes;
      }
      return;
    }

    minutes += stat.minutes;
    goals += stat.goals;
    assists += stat.assists;
    if (stat.minutes > 0) {
      appearances++;
      positionMinutes[position] =
          (positionMinutes[position] ?? 0) + stat.minutes;
      if (position == Position.gk) gkMinutes += stat.minutes;
      teamPointsWhenOn += teamPoints;
      teamPossiblePointsWhenOn += 3;
      goalsConcededWhenOn += conceded;
    }
    tackles += stat.tackles;
    interceptions += stat.interceptions;
    cleanSheets += stat.cleanSheet || (stat.minutes > 0 && conceded == 0)
        ? 1
        : 0;
    saves += stat.saves;
    shotsFaced += stat.shotsFaced;
    goalsPrevented += (stat.shotsFaced - conceded).clamp(0, stat.shotsFaced);
    if (stat.minutes > 0) {
      ratingTotal += stat.rating * stat.minutes;
      ratingWeight += stat.minutes;
    }
  }

  void mergePostseason(_AwardStats? other) {
    if (other == null) return;
    postseasonMinutes += other.postseasonMinutes;
    postseasonGoals += other.postseasonGoals;
    postseasonAssists += other.postseasonAssists;
    postseasonRatingTotal += other.postseasonRatingTotal;
    postseasonRatingWeight += other.postseasonRatingWeight;
  }
}

class _TeamOfSeasonOption {
  const _TeamOfSeasonOption({
    required this.slot,
    required this.playerId,
    required this.score,
  });

  final TeamOfSeasonSlot slot;
  final String playerId;
  final double score;
}
