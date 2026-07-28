import 'dart:math';

import 'package:uuid/uuid.dart';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/engine/match_engine.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/season_awards.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/development_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/core/services/scouting_service.dart';
import 'package:new_football/core/services/staff_service.dart';

/// Offseason / playoff pipeline (`docs/offseason.md`, play-in, draft).
class SeasonService {
  SeasonService({
    this.balance = BalanceConfig.defaults,
    MatchEngine? matchEngine,
    CalendarService? calendar,
    DevelopmentService? development,
    SalaryCapService? capService,
    StaffService? staffService,
    ScoutingService? scoutingService,
    Random? random,
  }) : matchEngine = matchEngine ?? MatchEngine(balance: balance),
       calendar = calendar ?? CalendarService(balance: balance),
       development = development ?? DevelopmentService(balance: balance),
       capService = capService ?? SalaryCapService(balance: balance),
       staffService = staffService ?? StaffService(balance: balance),
       scoutingService = scoutingService ?? ScoutingService(balance: balance),
       _random = random ?? Random();

  final BalanceConfig balance;
  final MatchEngine matchEngine;
  final CalendarService calendar;
  final DevelopmentService development;
  final SalaryCapService capService;
  final StaffService staffService;
  final ScoutingService scoutingService;
  final Random _random;
  final _uuid = const Uuid();

  LeagueState setupPlayIn(LeagueState league) {
    final results = <PlayInResult>[];
    for (final conf in Conference.values) {
      final cs = league.currentSeason.standings.firstWhere(
        (s) => s.conference == conf,
      );
      final sorted = cs.sorted;
      if (sorted.length < 10) continue;
      final s7 = sorted[6].teamId;
      final s8 = sorted[7].teamId;
      final s9 = sorted[8].teamId;
      final s10 = sorted[9].teamId;

      final g78 = _sim(league, s7, s8);
      final g910 = _sim(league, s9, s10);
      final loser78 = _winnerId(g78, s7, s8) == s7 ? s8 : s7;
      final winner910 = _winnerId(g910, s9, s10);
      final gFinal = _sim(league, loser78, winner910);
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
      league.copyWith(
        currentSeason: league.currentSeason.copyWith(
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

  LeagueState advancePlayoffs(LeagueState league) {
    var brackets = <PlayoffBracket>[];
    var state = league;
    for (final b in league.currentSeason.playoffBrackets) {
      brackets.add(_advanceBracket(state, b));
    }

    String? champion;
    PlayoffBracket? east;
    PlayoffBracket? west;
    for (final b in brackets) {
      if (b.conference == Conference.east) east = b;
      if (b.conference == Conference.west) west = b;
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
        leagueFinal = _playOneGame(state, leagueFinal);
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
    final order = _buildDraftOrder(league, lottery);
    final draftState = DraftState(
      year: league.currentSeason.year,
      order: order,
      lotteryResults: lottery,
      draftClass: draftClass,
    );
    var state = league.copyWith(
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

  /// Generuje klasę draftową na przyszły rok, sygnał „done” =
  /// `season.nextDraftState != null`. Promocja do `draftState` przy rollover
  /// jeszcze nieprzeanalizowana — patrz uwaga w odpowiedzi.
  LeagueState runNextClassGeneration(LeagueState league) {
    final draftClass = SeedDataGenerator(
      random: _random,
    ).generateDraftClass(year: league.currentSeason.year + 1);
    final nextDraftState = DraftState(
      year: league.currentSeason.year + 1,
      draftClass: draftClass,
    );
    return league.copyWith(
      currentSeason: league.currentSeason.copyWith(
        nextDraftState: nextDraftState,
      ),
    );
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

      final overallPick = draft.currentPickIndex + 1;
      final salary = balance.salaryCap.rookieSalaryForPick(overallPick);
      final player = chosen.toPlayer(
        contract: Contract(
          salary: salary,
          yearsRemaining: balance.salaryCap.rookieScaleYears,
          isRookieScale: true,
          rookiePickSlot: overallPick,
        ),
        rng: _random,
      );

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
        phase: SeasonPhase.draft,
      ),
    );

    // Draft just finished this call: undrafted prospects go to the FA pool
    // (`docs/offseason.md` §8).
    final nowComplete = draft.currentPickIndex >= draft.order.length;
    if (!wasComplete && nowComplete) {
      final draftedIds = draft.completedPicks
          .map((c) => c.prospectId)
          .whereType<String>()
          .toSet();
      final undrafted = draft.draftClass.prospects
          .where((p) => !draftedIds.contains(p.id))
          .map(
            (p) => p.toPlayer(
              contract: Contract(
                salary: balance.salaryCap.minSalary,
                yearsRemaining: 0,
              ),
              rng: _random,
            ),
          )
          .toList();
      state = state.copyWith(freeAgents: [...state.freeAgents, ...undrafted]);
    }

    return state;
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
        return p.copyWith(
          age: p.age + 1,
          contract: p.contract.copyWith(yearsRemaining: years),
          state: p.state.copyWith(
            seasonsWithTeam: p.state.seasonsWithTeam + 1,
            stamina: 90,
          ),
        );
      }).toList();

      // Player development ticks weekly in `DaySimulator`, not here — avoid
      // double-applying growth on top of the season's weekly ticks.
      var team = t.copyWith(
        roster: roster,
        finance: t.finance.copyWith(midLevelExceptionAvailable: true),
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

  MatchResult _sim(LeagueState league, String homeId, String awayId) {
    return matchEngine.simulateFull(
      home: league.teamById(homeId)!,
      away: league.teamById(awayId)!,
      rngSeed: Object.hash(homeId, awayId, league.currentWeek),
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

  PlayoffBracket _advanceBracket(LeagueState league, PlayoffBracket b) {
    final quarters = b.quarterFinals
        .map((s) => s.isComplete ? s : _playOneGame(league, s))
        .toList();

    var semis = b.semiFinals;
    if (semis.isEmpty && quarters.every((s) => s.isComplete)) {
      semis = [
        _series(quarters[0].winnerTeamId!, quarters[3].winnerTeamId!),
        _series(quarters[1].winnerTeamId!, quarters[2].winnerTeamId!),
      ];
    } else {
      semis = semis
          .map((s) => s.isComplete ? s : _playOneGame(league, s))
          .toList();
    }

    var confFinal = b.conferenceFinal;
    if (confFinal.isEmpty &&
        semis.isNotEmpty &&
        semis.every((s) => s.isComplete)) {
      confFinal = [_series(semis[0].winnerTeamId!, semis[1].winnerTeamId!)];
    } else {
      confFinal = confFinal
          .map((s) => s.isComplete ? s : _playOneGame(league, s))
          .toList();
    }

    return b.copyWith(
      quarterFinals: quarters,
      semiFinals: semis,
      conferenceFinal: confFinal,
    );
  }

  PlayoffSeries _playOneGame(LeagueState league, PlayoffSeries series) {
    final homeFirst = series.games.length.isEven;
    final homeId = homeFirst ? series.higherSeedTeamId : series.lowerSeedTeamId;
    final awayId = homeFirst ? series.lowerSeedTeamId : series.higherSeedTeamId;
    return series.recordGame(_sim(league, homeId, awayId));
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

  List<DraftPick> _buildDraftOrder(
    LeagueState league,
    List<LotteryResult> lottery,
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

    final picks = <DraftPick>[];
    for (var round = 1; round <= 3; round++) {
      for (var i = 0; i < 30; i++) {
        picks.add(
          DraftPick(
            round: round,
            pickNumber: (round - 1) * 30 + i + 1,
            teamId: r1[i % r1.length],
            originalTeamId: r1[i % r1.length],
          ),
        );
      }
    }
    return picks;
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
    final msg = GameMessage(
      id: _uuid.v4(),
      type: type,
      priority: urgent ? MessagePriority.urgent : MessagePriority.normal,
      title: title,
      body: body,
      week: league.currentWeek,
    );
    return league.copyWith(inbox: league.inbox.addMessage(msg));
  }
}
