import 'dart:math';

import 'package:uuid/uuid.dart';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/simulation/match_engine.dart';
import 'package:new_football/core/simulation/match_context_factory.dart';
import 'package:new_football/core/simulation/match_message_emitter.dart';
import 'package:new_football/core/simulation/pre_match_validator.dart';
import 'package:new_football/core/balance/injury_catalog.dart';
import 'package:new_football/core/models/contract.dart';
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
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/calendar_service.dart';
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

/// Offseason / playoff pipeline (`docs/offseason.md`, play-in, draft).
class SeasonService {
  SeasonService({
    this.balance = BalanceConfig.defaults,
    SimulationMatchEngine? matchEngine,
    CalendarService? calendar,
    MatchContextFactory? contextFactory,
    MatchMessageEmitter? matchMessageEmitter,
    DevelopmentService? development,
    SalaryCapService? capService,
    StaffService? staffService,
    ScoutingService? scoutingService,
    MessageService? messages,
    Random? random,
  }) : matchEngine = matchEngine ?? SimulationMatchEngine(balance: balance),
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
       _random = random ?? Random();

  final BalanceConfig balance;
  final SimulationMatchEngine matchEngine;
  final CalendarService calendar;
  final MatchContextFactory contextFactory;
  final MatchMessageEmitter matchMessageEmitter;
  final DevelopmentService development;
  final SalaryCapService capService;
  final StaffService staffService;
  final ScoutingService scoutingService;
  final MessageService _messages;
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
    return state.copyWith(
      currentSeason: state.currentSeason.copyWith(
        phase: SeasonPhase.playIn,
        playInResults: results,
        playInProgress: remaining,
      ),
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
    return _msg(
      state.copyWith(
        currentSeason: state.currentSeason.copyWith(
          phase: SeasonPhase.playIn,
          playInResults: results,
        ),
      ),
      MessageType.calendar,
      'Play-in zakończony',
      'Znamy 8 drużyn playoff z każdej konferencji.',
      urgent: true,
    );
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
    return league.copyWith(
      currentSeason: league.currentSeason.copyWith(
        phase: SeasonPhase.playoff,
        playoffBrackets: brackets,
      ),
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
              args: {'delta': updated.atmosphere - before},
              payload: {
                'teamId': champion,
                'atmosphereDelta': updated.atmosphere - before,
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
      final name = state.teamById(champion)?.name ?? champion;
      state = _msg(
        state,
        MessageType.award,
        'Mistrz ligi: $name',
        'Sezon zakończony. Offseason rozpoczyna się w tygodniu 44.',
        urgent: true,
      );
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
    final awards = _computeAwards(league);
    var state = league.copyWith(
      currentSeason: league.currentSeason.copyWith(awards: awards),
    );
    return _msg(
      state,
      MessageType.award,
      'Nagrody sezonu',
      'MVP: ${_playerName(state, awards.mvpPlayerId)}',
      urgent: true,
    );
  }

  /// Emerytury (śr tyg. 44): wyłącznie tabela bazowa
  /// `BalanceConfig.retirement.baseChanceForAge(age)`, bez modyfikatorów.
  LeagueState runPlayerRetirements(LeagueState league) {
    final retired = <String>[];
    final teams = league.teams.map((t) {
      final keep = <Player>[];
      for (final p in t.roster) {
        final chance = balance.retirement.baseChanceForAge(p.age);
        if (chance > 0 && _random.nextDouble() < chance) {
          retired.add(p.name);
        } else {
          keep.add(p);
        }
      }
      return capService.applyPayroll(t.copyWith(roster: keep));
    }).toList();

    var state = league.copyWith(
      teams: teams,
      currentSeason: league.currentSeason.copyWith(playerRetirementsDone: true),
    );
    if (retired.isNotEmpty) {
      state = _msg(
        state,
        MessageType.calendar,
        'Emerytury',
        'Kariery zakończyli: ${retired.join(', ')}.',
      );
    }
    return state;
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

  /// Generuje klasę draftową na przyszły rok oraz przedłuża o jeden rok
  /// horyzont handlowalnych picków każdej drużyny (`docs/trade_rules.md` —
  /// max 7 lat w przód). Sygnał „done” = `season.nextDraftState != null`.
  /// Promocja do `draftState` przy rollover jeszcze nieprzeanalizowana —
  /// patrz uwaga w odpowiedzi.
  LeagueState runNextClassGeneration(LeagueState league) {
    return ProspectService(random: _random).generateNextClassForLeague(league);
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

  /// Scout Report (pon tyg. 45, `docs/offseason.md` §5): AI auto-assigns a
  /// watchlist if it hasn't yet, then everyone picks Combine focus targets.
  LeagueState runScoutReport(LeagueState league) {
    final draftClass = league.currentSeason.draftState?.draftClass;
    if (draftClass == null) return league;
    final teams = league.teams.map((t) {
      final coverage = t.staff.scout?.attributes.coverage ?? 0.0;
      var scouting = t.scouting;
      if (!t.isPlayerControlled && scouting.watchlistProspectIds.isEmpty) {
        final picks = draftClass.prospects
            .take(scoutingService.maxWatched(coverage))
            .map((p) => p.id)
            .toList();
        scouting = scoutingService.setWatchlist(
          scouting,
          picks,
          coverageStars: coverage,
        );
      }
      scouting = scoutingService.runScoutReport(scouting, coverage);
      return t.copyWith(scouting: scouting);
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
  LeagueState runCombine(LeagueState league) {
    final teams = league.teams.map((t) {
      final evalStars = t.staff.scout?.attributes.evaluation ?? 0.0;
      return t.copyWith(
        scouting: scoutingService.runCombine(t.scouting, evalStars),
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
  LeagueState runFinalMock(LeagueState league) {
    final draftClass = league.currentSeason.draftState?.draftClass;
    if (draftClass == null) return league;
    final ranked = [...draftClass.prospects]
      ..sort((a, b) => b.scoutGrade.compareTo(a.scoutGrade));
    final teams = league.teams.map((t) {
      final evalStars = t.staff.scout?.attributes.evaluation ?? 0.0;
      return t.copyWith(
        scouting: scoutingService.runFinalMock(t.scouting, ranked, evalStars),
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
    final undrafted = draft.draftClass.prospects
        .where((p) => !draftedIds.contains(p.id))
        .map(
          (p) => p
              .toPlayer(
                contract: Contract(
                  salary: balance.salaryCap.minSalary,
                  yearsRemaining: 0,
                ),
                rng: _random,
              )
              .recalculatePointValue(balance),
        )
        .toList();
    return state.copyWith(freeAgents: [...state.freeAgents, ...undrafted]);
  }

  LeagueState advanceDraft(LeagueState league, {String? playerPickProspectId}) {
    var draft = league.currentSeason.draftState;
    if (draft == null) return league;
    final wasComplete = draft.currentPickIndex >= draft.order.length;
    var state = league;
    var teams = List<Team>.from(state.teams);

    while (draft!.currentPickIndex < draft.order.length) {
      final pick = draft.order[draft.currentPickIndex];
      final isPlayer = pick.teamId == state.playerTeamId;
      if (isPlayer && playerPickProspectId == null) {
        return state.copyWith(
          currentSeason: state.currentSeason.copyWith(draftState: draft),
          teams: teams,
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

      final chosen = isPlayer
          ? remaining.firstWhere(
              (p) => p.id == playerPickProspectId,
              orElse: () => remaining.first,
            )
          : remaining.first;

      final overallPick = pick.pickNumber ?? draft.currentPickIndex + 1;
      final salary = balance.salaryCap.rookieSalaryForPick(overallPick);
      final player = chosen
          .toPlayer(
            contract: Contract(
              salary: salary,
              yearsRemaining: balance.salaryCap.rookieScaleYears,
              isRookieScale: true,
              rookiePickSlot: overallPick,
            ),
            rng: _random,
          )
          .recalculatePointValue(balance);

      teams = teams.map((t) {
        if (t.id != pick.teamId) return t;
        return capService.applyPayroll(
          t.copyWith(roster: [...t.roster, player]),
        );
      }).toList();

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
      teams: teams,
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
  LeagueState advanceDraftOnePick(LeagueState league) {
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

    final chosen = remaining.first;
    final overallPick = pick.pickNumber ?? draft.currentPickIndex + 1;
    final salary = balance.salaryCap.rookieSalaryForPick(overallPick);
    final player = chosen
        .toPlayer(
          contract: Contract(
            salary: salary,
            yearsRemaining: balance.salaryCap.rookieScaleYears,
            isRookieScale: true,
            rookiePickSlot: overallPick,
          ),
          rng: _random,
        )
        .recalculatePointValue(balance);

    var teams = league.teams.map((t) {
      if (t.id != pick.teamId) return t;
      return capService.applyPayroll(t.copyWith(roster: [...t.roster, player]));
    }).toList();

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
      teams: teams,
      currentSeason: league.currentSeason.copyWith(
        draftState: draft,
        phase: SeasonPhase.offseason,
      ),
    );
    return _finalizeDraftFreeAgents(state, draft);
  }

  /// Contracts that hit 0 years (decremented at rollover) leave the roster
  /// and join the FA pool when the market opens (`docs/offseason.md` §10).
  LeagueState expireContracts(LeagueState league) {
    final freeAgents = List<Player>.from(league.freeAgents);
    final teams = league.teams.map((t) {
      final keep = <Player>[];
      for (final p in t.roster) {
        if (p.contract.yearsRemaining <= 0) {
          freeAgents.add(p);
        } else {
          keep.add(p);
        }
      }
      if (keep.length == t.roster.length) return t;
      return capService.applyPayroll(t.copyWith(roster: keep));
    }).toList();
    return league.copyWith(teams: teams, freeAgents: freeAgents);
  }

  LeagueState rolloverSeason(LeagueState league) {
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
            'atmosphere': playerTeam?.atmosphere ?? 0,
          },
          payload: {
            'teamId': playerId,
            'atmosphereDelta': playerDelta,
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

      // Player development ticks weekly in `DaySimulator`, not here — avoid
      // double-applying growth on top of the season's weekly ticks.
      var team = t.copyWith(
        roster: roster
            .map(
              (p) => p.copyWith(
                previousOvr: p.overall(balance).round(),
                previousPotential: p.potentialStars,
              ),
            )
            .toList(),
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

    return league.copyWith(
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
      ),
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
    return matchEngine.simulateFullMatch(
      home: home,
      away: away,
      context: context,
      rngSeed: context.seed,
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
    var state = league;
    final effectiveStake = stake ?? _stakeForPhase(phase);
    final home = league.teamById(homeId);
    final away = league.teamById(awayId);
    if (home != null && away != null && league.playerTeamId != null) {
      final playerInFixture =
          league.playerTeamId == homeId || league.playerTeamId == awayId;
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
    final result = _sim(
      state,
      homeId,
      awayId,
      saveSeed: saveSeed,
      matchId: matchId,
      phase: phase,
      stake: effectiveStake,
    );
    return (
      league: _applyPostseasonDiscipline(
        state,
        result,
        phase,
        matchId: matchId,
      ),
      result: result,
    );
  }

  String _winnerId(MatchResult r, String homeId, String awayId) {
    if (r.homeGoals == r.awayGoals) {
      return _random.nextBool() ? homeId : awayId;
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
          dedupKey: 'inspired:${matchId ?? result.homeTeamId}:${inspiredId}',
        );
      }
    }

    final playerTeamId = state.playerTeamId;
    if (playerTeamId == result.homeTeamId ||
        playerTeamId == result.awayTeamId) {
      final administrative = TeamManagementService.isWalkoverResult(result);
      final type = administrative
          ? MessageType.walkover
          : MessageType.matchResult;
      final responsibleTeamId = result.violatingTeamIds.isEmpty
          ? result.homeTeamId
          : result.violatingTeamIds.first;
      final motm = result.manOfTheMatchPlayerId == null
          ? null
          : _playerName(state, result.manOfTheMatchPlayerId);
      state = _messages.send(
        state,
        type: type,
        priority: administrative
            ? MessagePriority.urgent
            : MessagePriority.normal,
        args: {
          'homeTeam': _teamName(state, result.homeTeamId),
          'awayTeam': _teamName(state, result.awayTeamId),
          'homeGoals': result.homeGoals,
          'awayGoals': result.awayGoals,
          'team': _teamName(state, responsibleTeamId),
          'reason': result.reasonCode ?? 'administrative_result',
          'posA': result.homeStats.possession,
          'posB': result.awayStats.possession,
          'xgA': result.homeStats.xg,
          'xgB': result.awayStats.xg,
          'motm': motm ?? '—',
        },
        payload: {
          'matchId': matchId,
          'homeTeamId': result.homeTeamId,
          'awayTeamId': result.awayTeamId,
          'homeGoals': result.homeGoals,
          'awayGoals': result.awayGoals,
          'status': result.status.name,
          'reasonCode': result.reasonCode,
          'violatingTeamIds': result.violatingTeamIds,
          'homeStats': result.homeStats.toJson(),
          'awayStats': result.awayStats.toJson(),
          'manOfTheMatchPlayerId': result.manOfTheMatchPlayerId,
        },
        dedupKey: matchId == null ? null : '${type.name}:result:$matchId',
      );
    }
    return state;
  }

  SeasonAwards _computeAwards(LeagueState league) {
    Player? best;
    Player? bestYoung;
    for (final t in league.teams) {
      for (final p in t.roster) {
        if (best == null || p.overall(balance) > best.overall(balance)) {
          best = p;
        }
        if (p.age <= 22 &&
            (bestYoung == null ||
                p.overall(balance) > bestYoung.overall(balance))) {
          bestYoung = p;
        }
      }
    }
    return SeasonAwards(
      year: league.currentSeason.year,
      mvpPlayerId: best?.id,
      rotyPlayerId: bestYoung?.id,
      championTeamId: league.currentSeason.championTeamId,
    );
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
