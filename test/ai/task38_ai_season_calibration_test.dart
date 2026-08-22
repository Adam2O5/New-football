@Tags(['ai', 'benchmark', 'slow'])
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/ai/ai_evaluation_service.dart';
import 'package:new_football/core/ai/ai_roster_management_service.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/draft_trade_service.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/league_strength_service.dart';
import 'package:new_football/core/services/season_service.dart';
import 'package:new_football/core/services/trade_service.dart';

const _task38Seasons = 10;
const _task38Seed = 3801;
const _task38StartYear = 2026;
const _task38PlayerTeamId = 'team_europe_0';
const bool _task38RunFull = bool.fromEnvironment('TASK38_RUN_FULL');

enum _Task38Profile { accelerated, full }

class _ContractObservation {
  const _ContractObservation({
    required this.signature,
    required this.firstToxicYear,
  });

  final String signature;
  final int? firstToxicYear;
}

class _SeasonMetrics {
  const _SeasonMetrics({
    required this.year,
    required this.championTeamId,
    required this.playoffTeamIds,
    required this.aiWalkovers,
    required this.legalRoster,
    required this.aiTrades,
    required this.playerOffers,
    required this.ufaCohortSize,
    required this.ufaSignedRate,
    required this.staffFillRate,
    required this.payrollAveragePct,
    required this.payrollMaximumPct,
    required this.secondApronPeak,
    required this.stepienViolations,
    required this.expectedRankCorrelation,
    required this.medianRosterAge,
    required this.longLivedToxicContracts,
    required this.contractDumpTrades,
    required this.ntcRefusals,
  });

  final int year;
  final String? championTeamId;
  final Set<String> playoffTeamIds;
  final int aiWalkovers;
  final bool legalRoster;
  final int aiTrades;
  final int playerOffers;
  final int ufaCohortSize;
  final double? ufaSignedRate;
  final double staffFillRate;
  final double payrollAveragePct;
  final double payrollMaximumPct;
  final int secondApronPeak;
  final int stepienViolations;
  final double? expectedRankCorrelation;
  final double medianRosterAge;
  final int longLivedToxicContracts;
  final int contractDumpTrades;
  final int ntcRefusals;
}

class _CalibrationReport {
  _CalibrationReport({
    required this.profile,
    required this.seasons,
    required this.logicalDays,
    required this.executedTicks,
    required this.rebuildToContenderTransitions,
  });

  final _Task38Profile profile;
  final List<_SeasonMetrics> seasons;
  final int logicalDays;
  final int executedTicks;
  final int rebuildToContenderTransitions;

  Set<String> get champions => {
    for (final season in seasons)
      if (season.championTeamId != null) season.championTeamId!,
  };

  int get longestPlayoffStreak {
    final streaks = <String, int>{};
    var longest = 0;
    for (final season in seasons) {
      final qualified = season.playoffTeamIds;
      final teamIds = {...streaks.keys, ...qualified};
      for (final teamId in teamIds) {
        final next = qualified.contains(teamId)
            ? (streaks[teamId] ?? 0) + 1
            : 0;
        streaks[teamId] = next;
        longest = max(longest, next);
      }
    }
    return longest;
  }

  int get aiWalkovers =>
      seasons.fold(0, (total, season) => total + season.aiWalkovers);

  double get legalRosterPct =>
      100.0 *
      seasons.where((season) => season.legalRoster).length /
      seasons.length;

  double get averageAiTrades =>
      _mean(seasons.map((season) => season.aiTrades.toDouble()));

  double get averagePlayerOffers =>
      _mean(seasons.map((season) => season.playerOffers.toDouble()));

  double get averageUfaSignedRate {
    final measured = seasons
        .map((season) => season.ufaSignedRate)
        .whereType<double>()
        .toList();
    return measured.isEmpty ? double.nan : _mean(measured);
  }

  double get averageStaffFill =>
      _mean(seasons.map((season) => season.staffFillRate));

  double get averagePayroll =>
      _mean(seasons.map((season) => season.payrollAveragePct));

  double get maximumPayroll =>
      seasons.map((season) => season.payrollMaximumPct).fold(0.0, max);

  int get maximumSecondApronPeak =>
      seasons.map((season) => season.secondApronPeak).fold(0, max);

  int get stepienViolations =>
      seasons.fold(0, (total, season) => total + season.stepienViolations);

  double get averageRankCorrelation {
    final measured = seasons
        .map((season) => season.expectedRankCorrelation)
        .whereType<double>()
        .toList();
    return measured.isEmpty ? double.nan : _mean(measured);
  }

  double get medianRosterAge =>
      _median(seasons.map((season) => season.medianRosterAge).toList());

  int get maximumLongLivedToxicContracts =>
      seasons.map((season) => season.longLivedToxicContracts).fold(0, max);

  double get averageContractDumps =>
      _mean(seasons.map((season) => season.contractDumpTrades.toDouble()));

  double get averageNtcRefusals =>
      _mean(seasons.map((season) => season.ntcRefusals.toDouble()));

  String render() {
    final output = StringBuffer()
      ..writeln('TASK38 CALIBRATION REPORT')
      ..writeln(
        'profile=${profile.name}, seasons=${seasons.length}, '
        'logicalDays=$logicalDays, executedTicks=$executedTicks, '
        'expectedLogicalDays=${seasons.length * 52 * 7}',
      )
      ..writeln('Per-season raw metrics:');
    for (final season in seasons) {
      output.writeln(
        '  ${season.year}: '
        'champion=${season.championTeamId ?? 'NONE'}, '
        'playoff=${season.playoffTeamIds.length}, '
        'walkovers=${season.aiWalkovers}, '
        'legalRoster=${season.legalRoster}, '
        'aiTrades=${season.aiTrades}, '
        'playerOffers=${season.playerOffers}, '
        'ufa=${_formatRate(season.ufaSignedRate, suffix: '%')}, '
        'staff=${season.staffFillRate.toStringAsFixed(2)}%, '
        'payroll=${season.payrollAveragePct.toStringAsFixed(2)}%/'
        '${season.payrollMaximumPct.toStringAsFixed(2)}%, '
        'apronPeak=${season.secondApronPeak}, '
        'stepien=${season.stepienViolations}, '
        'corr=${_formatRate(season.expectedRankCorrelation)}, '
        'age=${season.medianRosterAge.toStringAsFixed(2)}, '
        'toxic>2=${season.longLivedToxicContracts}, '
        'dumps=${season.contractDumpTrades}, '
        'ntc=${season.ntcRefusals}',
      );
    }
    output
      ..writeln('Aggregates:')
      ..writeln(
        '  champions=${champions.length}, '
        'longestPlayoffStreak=$longestPlayoffStreak, '
        'aiWalkovers=$aiWalkovers, '
        'legalRoster=${legalRosterPct.toStringAsFixed(2)}%',
      )
      ..writeln(
        '  aiTrades/season=${averageAiTrades.toStringAsFixed(2)}, '
        'playerOffers/season=${averagePlayerOffers.toStringAsFixed(2)}, '
        'ufaSignedByWeek1=${_formatRate(averageUfaSignedRate, suffix: '%')}',
      )
      ..writeln(
        '  staffFill=${averageStaffFill.toStringAsFixed(2)}%, '
        'payroll=${averagePayroll.toStringAsFixed(2)}%, '
        'payrollMax=${maximumPayroll.toStringAsFixed(2)}%, '
        'secondApronPeak=$maximumSecondApronPeak',
      )
      ..writeln(
        '  stepienViolations=$stepienViolations, '
        'rankCorrelation=${_formatRate(averageRankCorrelation)}, '
        'medianAge=${medianRosterAge.toStringAsFixed(2)}, '
        'rebuildToContender=$rebuildToContenderTransitions',
      )
      ..writeln(
        '  toxicContracts>2=$maximumLongLivedToxicContracts, '
        'contractDumps/season=${averageContractDumps.toStringAsFixed(2)}, '
        'ntcRefusals/season=${averageNtcRefusals.toStringAsFixed(2)}',
      )
      ..writeln('Acceptance status (Task 38 policy):')
      ..writeln(
        '  champions>=6: ${champions.length >= 6}, '
        'playoffStreak<=8: ${longestPlayoffStreak <= 8}, '
        'walkovers=0: ${aiWalkovers == 0}, '
        'legalRoster=100%: ${legalRosterPct == 100.0}',
      )
      ..writeln(
        '  aiTrades 25..45: ${averageAiTrades >= 25 && averageAiTrades <= 45}, '
        'playerOffers 12..20: ${averagePlayerOffers >= 12 && averagePlayerOffers <= 20}, '
        'staff>=92%: ${averageStaffFill >= 92}, '
        'payrollMax<=108%: ${maximumPayroll <= 108},',
      )
      ..writeln(
        '  secondApron<=3: ${maximumSecondApronPeak <= 3}, '
        'stepien=0: ${stepienViolations == 0}, '
        'corr 0.55..0.75: ${averageRankCorrelation >= 0.55 && averageRankCorrelation <= 0.75}, '
        'age 25..28: ${medianRosterAge >= 25 && medianRosterAge <= 28},',
      )
      ..writeln(
        '  rebuildToContender 2..6: '
        '${rebuildToContenderTransitions >= 2 && rebuildToContenderTransitions <= 6}, '
        'toxic<=2: ${maximumLongLivedToxicContracts <= 2}, '
        'dumps 3..10: ${averageContractDumps >= 3 && averageContractDumps <= 10}, '
        'ntc 0..4: ${averageNtcRefusals >= 0 && averageNtcRefusals <= 4}',
      )
      ..writeln(
        '  UFA volume and payroll lower bound remain diagnostic per '
        'Implementation_plan_V1 Task 35/38.',
      );
    return output.toString();
  }
}

class _Task38Harness {
  _Task38Harness({
    this.profile = _Task38Profile.accelerated,
    this.seasonCount = _task38Seasons,
    this.rootSeed = _task38Seed,
    this.balance = BalanceConfig.defaults,
  }) : calendar = CalendarService(balance: balance),
       contractMarket = ContractMarketService(balance: balance),
       daySimulator = DaySimulator(balance: balance),
       seasonService = SeasonService(
         balance: balance,
         random: Random(rootSeed + 1),
       ),
       tradeService = TradeService(balance: balance),
       draftTrades = DraftTradeService(balance: balance),
       strengthService = LeagueStrengthService(balance: balance),
       evaluator = AiEvaluationService(balance: balance),
       rosterManagement = AiRosterManagementService(balance: balance);

  final _Task38Profile profile;
  final int seasonCount;
  final int rootSeed;
  final BalanceConfig balance;
  final CalendarService calendar;
  final ContractMarketService contractMarket;
  final DaySimulator daySimulator;
  final SeasonService seasonService;
  final TradeService tradeService;
  final DraftTradeService draftTrades;
  final LeagueStrengthService strengthService;
  final AiEvaluationService evaluator;
  final AiRosterManagementService rosterManagement;

  final Map<String, List<TeamStatus>> _statusHistory = {};
  final Map<String, List<bool>> _r1History = {};
  final Map<String, _ContractObservation> _contractLedger = {};
  final List<_SeasonMetrics> _seasonMetrics = [];
  final Set<String> _seenResultKeys = {};

  int _walkovers = 0;
  int _secondApronPeak = 0;
  Set<String> _faCohortIds = {};
  Map<String, int> _preseasonExpectedRanks = {};
  int _logicalDays = 0;
  int _executedTicks = 0;

  _CalibrationReport run() {
    var league = _initialLeague();
    for (var seasonIndex = 0; seasonIndex < seasonCount; seasonIndex++) {
      final year = league.currentSeason.year;
      league = _prepareSeasonStart(league, year: year);
      _walkovers = 0;
      _secondApronPeak = 0;
      _faCohortIds = {};
      _seenResultKeys.clear();

      var daysInSeason = 0;
      while (league.currentSeason.year == year) {
        if (daysInSeason >= balance.calendar.seasonCycleWeeks * 7 + 14) {
          throw StateError('Task 38 runner exceeded one season at $year');
        }
        final isCycleEnd =
            league.currentWeek == balance.calendar.seasonCycleWeeks &&
            league.currentDay == 7;

        league = _runDatedPostseasonHooks(league);
        league = _runCalendarEvents(league);
        if (league.currentWeek == balance.calendar.freeAgencyWeek &&
            league.currentDay == 1) {
          _faCohortIds = league.freeAgents.map((player) => player.id).toSet();
        }
        league = league.copyWith(
          currentHour: calendar.initialHourForDate(
            league.currentWeek,
            league.currentDay,
          ),
          hourlyPlayerOfferUsed: false,
          hourlyStaffOfferUsed: false,
        );

        final executeFullTick =
            profile == _Task38Profile.full || _requiresFullTick(league);
        if (executeFullTick) {
          final result = daySimulator.simulateDay(
            league,
            saveSeed: rootSeed,
            simulatePlayerMatch: true,
          );
          for (final match in result.simulatedResults) {
            _recordResult(league, match);
          }
          league = tradeService.expireOffers(
            result.league,
            emitMessages: false,
          );
          _executedTicks++;
        } else {
          league = _advanceAcceleratedDay(league);
        }
        _observeAprons(league);
        _logicalDays++;
        daysInSeason++;

        if (isCycleEnd) {
          _collectPostseasonResults(league);
          _recordSeason(league, year);
          league = seasonService.rolloverSeason(league, saveSeed: rootSeed);
          league = _repairPassiveRoster(league, saveSeed: rootSeed);
        }
      }
    }

    return _CalibrationReport(
      profile: profile,
      seasons: List.unmodifiable(_seasonMetrics),
      logicalDays: _logicalDays,
      executedTicks: _executedTicks,
      rebuildToContenderTransitions: _countRebuildToContenderTransitions(),
    );
  }

  /// Full ticks retain expensive match-day work. Phase-II's daily market is
  /// handled by [_advanceAcceleratedDay], so it does not force a full tick on
  /// every regular-season date.
  bool _requiresFullTick(LeagueState league) {
    final week = league.currentWeek;
    final day = league.currentDay;
    final isPostseasonDate =
        calendar.playInSlotsForDay(week, day).isNotEmpty ||
        calendar.postseasonSlotForDay(week, day) != null;
    final isHourlyContractWindow = calendar.isHourlyContractMode(week, day);
    final isPeriodicStrengthDate =
        (week == 1 && day == 1) ||
        (day == 1 &&
            week >= 5 &&
            week < balance.calendar.tradeDeadlineWeek &&
            (week - 1) % 4 == 0);
    return day == 7 ||
        calendar.isActualMatchDay(week, day) ||
        isPostseasonDate ||
        isHourlyContractWindow ||
        isPeriodicStrengthDate ||
        calendar.eventsOn(week, day).isNotEmpty;
  }

  /// Advances one non-critical logical day without invoking match simulation.
  /// This keeps stamina/injury recovery, phase-II FA resolution, offer expiry,
  /// and the exact calendar date while weekly AI remains owned by full Sunday
  /// ticks.
  LeagueState _advanceAcceleratedDay(LeagueState league) {
    final week = league.currentWeek;
    final day = league.currentDay;
    var state = league.copyWith(
      teams: league.teams
          .map(
            (team) => team.copyWith(
              roster: team.roster
                  .map((player) => player.recoverBetweenMatches(balance))
                  .toList(),
            ),
          )
          .toList(),
    );
    if (calendar.isFreeAgencyPhaseII(week, day)) {
      state = contractMarket.resolveDay(state, saveSeed: rootSeed);
    }

    final (nextWeek, nextDay) = calendar.advanceDay(week, day);
    state = state.copyWith(
      currentWeek: nextWeek,
      currentDay: nextDay,
      currentHour: calendar.initialHourForDate(nextWeek, nextDay),
      hourlyPlayerOfferUsed: false,
      hourlyStaffOfferUsed: false,
      currentSeason: state.currentSeason.copyWith(
        phase: calendar.phaseForWeek(nextWeek),
      ),
    );
    return tradeService.expireOffers(state, emitMessages: false);
  }

  LeagueState _initialLeague() {
    final save = GameFactory().create(
      NewGameRequest(
        saveName: 'task38-calibration',
        playerTeamId: _task38PlayerTeamId,
        seasonYear: _task38StartYear,
        seed: rootSeed,
      ),
    );
    return save.leagueState;
  }

  LeagueState _prepareSeasonStart(LeagueState league, {required int year}) {
    var state = _repairPassiveRoster(league, saveSeed: rootSeed);
    final table = strengthService.calculate(
      state,
      previousTable: state.strengthTable,
      week: state.currentWeek,
      day: state.currentDay,
      seasonYear: year,
    );
    state = state.copyWith(strengthTable: table);
    _preseasonExpectedRanks = {
      for (final entry in table.entries) entry.teamId: entry.expectedRank,
    };

    final aiTeams = _aiTeams(state);
    for (final entry in table.entries) {
      _statusHistory.putIfAbsent(entry.teamId, () => []).add(entry.teamStatus);
    }
    final legalRoster = aiTeams.every(
      (team) =>
          team.roster.length >= 20 &&
          team.roster.length <= 30 &&
          team.availablePlayers.length >= 11,
    );
    final staffSlots = aiTeams.fold<int>(
      0,
      (total, team) =>
          total +
          StaffRole.values
              .where((role) => team.staff.member(role) != null)
              .length,
    );
    final staffTotalSlots = aiTeams.length * StaffRole.values.length;
    final payrollPcts = aiTeams.map((team) {
      if (team.finance.salaryCap <= 0) return 0.0;
      return team.finance.totalPayroll * 100.0 / team.finance.salaryCap;
    }).toList();
    final ages = [
      for (final team in aiTeams)
        for (final player in team.roster) player.age.toDouble(),
    ];
    final longLivedToxic = _observeContracts(state, year);

    _seasonMetrics.add(
      _SeasonMetrics(
        year: year,
        championTeamId: null,
        playoffTeamIds: const {},
        aiWalkovers: 0,
        legalRoster: legalRoster,
        aiTrades: 0,
        playerOffers: 0,
        ufaCohortSize: 0,
        ufaSignedRate: null,
        staffFillRate: staffTotalSlots == 0
            ? 0.0
            : staffSlots * 100.0 / staffTotalSlots,
        payrollAveragePct: _mean(payrollPcts),
        payrollMaximumPct: payrollPcts.fold(0.0, max),
        secondApronPeak: 0,
        stepienViolations: 0,
        expectedRankCorrelation: null,
        medianRosterAge: _median(ages),
        longLivedToxicContracts: longLivedToxic,
        contractDumpTrades: 0,
        ntcRefusals: 0,
      ),
    );
    _observeAprons(state);
    return state;
  }

  LeagueState _runDatedPostseasonHooks(LeagueState league) {
    var state = league;
    final week = state.currentWeek;
    final day = state.currentDay;
    if (calendar.playInSlotsForDay(week, day).isNotEmpty) {
      state = seasonService.advancePlayInForDate(
        state,
        week: week,
        day: day,
        saveSeed: rootSeed,
      );
      _collectPostseasonResults(state);
    }
    if (calendar.phaseForWeek(week) == SeasonPhase.playoff &&
        state.currentSeason.playoffBrackets.isEmpty &&
        state.currentSeason.playInResults.isNotEmpty) {
      state = seasonService.setupPlayoffs(state);
    }
    if (calendar.postseasonSlotForDay(week, day) != null) {
      state = seasonService.advancePlayoffsForDate(
        state,
        week: week,
        day: day,
        saveSeed: rootSeed,
      );
      _collectPostseasonResults(state);
    }
    _observeAprons(state);
    return state;
  }

  LeagueState _runCalendarEvents(LeagueState league) {
    var state = league;
    final week = state.currentWeek;
    final day = state.currentDay;
    final calendarBalance = balance.calendar;

    if (week == calendarBalance.awardsWeek && day == 1) {
      if (!state.currentSeason.capUpdateTvDone) {
        state = seasonService.runCapUpdateTv(state, saveSeed: rootSeed);
      }
      if (state.currentSeason.awards == null) {
        state = seasonService.runAwards(state);
      }
    }
    if (week == calendarBalance.awardsWeek &&
        day == 2 &&
        !state.currentSeason.staffGrowthDone) {
      state = seasonService.runStaffGrowthAndRetire(state);
    }
    if (week == calendarBalance.awardsWeek &&
        day == 3 &&
        !state.currentSeason.playerRetirementsDone) {
      state = seasonService.runPlayerRetirements(state, saveSeed: rootSeed);
      state = _repairPassiveRoster(state, saveSeed: rootSeed);
    }
    if (week == calendarBalance.awardsWeek &&
        day == 5 &&
        (state.currentSeason.draftState?.lotteryResults.isEmpty ?? true)) {
      state = seasonService.runLottery(state);
    }

    final scoutWeek = calendarBalance.awardsWeek + 1;
    if (week == scoutWeek && day == 1 && !state.currentSeason.scoutReportDone) {
      state = seasonService.runScoutReport(state, saveSeed: rootSeed);
    }
    if (week == scoutWeek && day == 3 && !state.currentSeason.combineDone) {
      state = seasonService.runCombine(state, saveSeed: rootSeed);
    }
    if (week == scoutWeek && day == 5 && !state.currentSeason.finalMockDone) {
      state = seasonService.runFinalMock(state, saveSeed: rootSeed);
    }
    if (week == calendarBalance.draftWeek && day == 1) {
      state = _completePassiveDraft(state);
      if (state.currentSeason.nextDraftState == null &&
          (state.currentSeason.draftState?.currentPickIndex ?? 0) >=
              (state.currentSeason.draftState?.order.length ?? 0)) {
        state = seasonService.runNextClassGeneration(state, saveSeed: rootSeed);
      }
    }
    if (week == calendarBalance.tradeDeadlineWeek &&
        day == 1 &&
        !state.currentSeason.tradeDeadlineAcked) {
      state = state.copyWith(
        currentSeason: state.currentSeason.copyWith(tradeDeadlineAcked: true),
      );
    }
    if (week == calendarBalance.freeAgencyWeek &&
        day == 1 &&
        !state.currentSeason.faOpenDone) {
      state = seasonService.runFreeAgencyOpen(state);
    }
    _observeAprons(state);
    return state;
  }

  LeagueState _completePassiveDraft(LeagueState league) {
    var state = league;
    for (var attempt = 0; attempt < 140; attempt++) {
      final draft = state.currentSeason.draftState;
      if (draft == null || draft.currentPickIndex >= draft.order.length) {
        return state;
      }
      final pick = draft.order[draft.currentPickIndex];
      final pending = draftTrades.pendingOfferForPick(state, pick.id);
      if (pending != null) {
        state = draftTrades
            .rejectOffer(
              state,
              pending.id,
              actingTeamId: state.playerTeamId ?? _task38PlayerTeamId,
              emitMessages: false,
            )
            .league;
        continue;
      }
      final playerPickProspectId = pick.teamId == state.playerTeamId
          ? _bestRemainingProspectId(draft)
          : null;
      final beforeIndex = draft.currentPickIndex;
      state = seasonService.advanceDraft(
        state,
        playerPickProspectId: playerPickProspectId,
        saveSeed: rootSeed,
      );
      final nextDraft = state.currentSeason.draftState;
      if (nextDraft == null ||
          nextDraft.currentPickIndex >= nextDraft.order.length) {
        return state;
      }
      if (nextDraft.currentPickIndex == beforeIndex) {
        final nextPick = nextDraft.order[nextDraft.currentPickIndex];
        final nextPending = draftTrades.pendingOfferForPick(state, nextPick.id);
        if (nextPending != null) continue;
        String? forcedProspectId;
        if (nextPick.teamId == state.playerTeamId) {
          // An AI trade-up can swap the current slot to the passive club after
          // [advanceDraft] has already computed its player-pick argument.
          // Recompute the choice against the swapped draft state instead of
          // treating the intentional player pause as a lifecycle failure.
          forcedProspectId = _bestRemainingProspectId(nextDraft);
          if (forcedProspectId == null) {
            throw StateError(
              'Passive player draft pick has no remaining prospect '
              '(index ${nextDraft.currentPickIndex}, '
              'completed ${nextDraft.completedPicks.length}, '
              'class ${nextDraft.draftClass.prospects.length})',
            );
          }
          state = seasonService.advanceDraft(
            state,
            playerPickProspectId: forcedProspectId,
            saveSeed: rootSeed,
          );
          final afterRetry = state.currentSeason.draftState;
          if (afterRetry == null ||
              afterRetry.currentPickIndex != beforeIndex) {
            continue;
          }
        }
        throw StateError('Passive player draft pick did not advance');
      }
    }
    throw StateError('Task 38 draft did not finish');
  }

  String? _bestRemainingProspectId(DraftState draft) {
    final taken = draft.completedPicks
        .map((pick) => pick.prospectId)
        .whereType<String>()
        .toSet();
    final remaining = [...draft.draftClass.prospects]
      ..removeWhere((prospect) => taken.contains(prospect.id))
      ..sort((a, b) {
        final grade = b.scoutGrade.compareTo(a.scoutGrade);
        return grade == 0 ? a.id.compareTo(b.id) : grade;
      });
    return remaining.isEmpty ? null : remaining.first.id;
  }

  void _recordSeason(LeagueState league, int year) {
    final index = _seasonMetrics.indexWhere((season) => season.year == year);
    if (index < 0) throw StateError('Missing Task 38 season snapshot $year');
    final base = _seasonMetrics[index];
    final finalStandings = _globalFinalRank(league);
    final correlation = _pearson(_preseasonExpectedRanks, finalStandings);
    final draft = league.currentSeason.draftState;
    var stepienViolations = 0;
    if (draft != null && draft.currentPickIndex >= draft.order.length) {
      for (final team in _aiTeams(league)) {
        final hasR1 = draft.completedPicks.any(
          (pick) => pick.teamId == team.id && pick.round == 1,
        );
        final history = _r1History.putIfAbsent(team.id, () => []);
        history.add(hasR1);
        if (history.length >= 2 &&
            !history[history.length - 1] &&
            !history[history.length - 2]) {
          stepienViolations++;
        }
      }
    }
    final playerOfferCount = league.tradeOffers.where((offer) {
      final offeringTeam = league.teamById(offer.teamAId);
      return offer.seasonYear == year &&
          offer.teamBId == _task38PlayerTeamId &&
          offeringTeam?.ai != null;
    }).length;
    final aiTradeCount = league.tradeHistory.where((entry) {
      final a = league.teamById(entry.teamAId);
      final b = league.teamById(entry.teamBId);
      return entry.seasonYear == year &&
          entry.outcome == 'accepted' &&
          a?.ai != null &&
          b?.ai != null;
    }).length;
    final contractDumps = league.tradeHistory.where((entry) {
      return entry.seasonYear == year &&
          entry.outcome == 'accepted' &&
          (entry.reason == 'contractDump' ||
              (entry.reason?.contains('contractDump') ?? false));
    }).length;
    final ntcRefusals = league.tradeHistory.where((entry) {
      return entry.seasonYear == year && entry.outcome == 'ntcRefused';
    }).length;
    final ufaRate = _ufaSignedRate(league);
    final playoffTeams = _playoffTeams(league.currentSeason);

    _seasonMetrics[index] = _SeasonMetrics(
      year: year,
      championTeamId: league.currentSeason.championTeamId,
      playoffTeamIds: playoffTeams,
      aiWalkovers: _walkovers,
      legalRoster: base.legalRoster,
      aiTrades: aiTradeCount,
      playerOffers: playerOfferCount,
      ufaCohortSize: _faCohortIds.length,
      ufaSignedRate: ufaRate,
      staffFillRate: base.staffFillRate,
      payrollAveragePct: base.payrollAveragePct,
      payrollMaximumPct: base.payrollMaximumPct,
      secondApronPeak: _secondApronPeak,
      stepienViolations: stepienViolations,
      expectedRankCorrelation: correlation,
      medianRosterAge: base.medianRosterAge,
      longLivedToxicContracts: base.longLivedToxicContracts,
      contractDumpTrades: contractDumps,
      ntcRefusals: ntcRefusals,
    );
  }

  double? _ufaSignedRate(LeagueState league) {
    if (_faCohortIds.isEmpty) return null;
    final remaining = league.freeAgents.map((player) => player.id).toSet();
    final unsigned = _faCohortIds.intersection(remaining).length;
    return (_faCohortIds.length - unsigned) * 100.0 / _faCohortIds.length;
  }

  Set<String> _playoffTeams(Season season) {
    final teams = <String>{};
    for (final bracket in season.playoffBrackets) {
      for (final series in _seriesOf(bracket)) {
        teams
          ..add(series.higherSeedTeamId)
          ..add(series.lowerSeedTeamId);
      }
    }
    return teams;
  }

  Iterable<PlayoffSeries> _seriesOf(PlayoffBracket bracket) sync* {
    yield* bracket.quarterFinals;
    yield* bracket.semiFinals;
    yield* bracket.conferenceFinal;
    if (bracket.leagueFinal != null) yield bracket.leagueFinal!;
  }

  int _observeContracts(LeagueState league, int year) {
    var longLived = 0;
    for (final team in _aiTeams(league)) {
      for (final player in team.roster) {
        final signature = _contractSignature(player);
        final previous = _contractLedger[player.id];
        var firstToxicYear = previous?.firstToxicYear;
        if (previous == null || previous.signature != signature) {
          firstToxicYear = null;
        }
        final drag = evaluator.contractDrag(player);
        if (drag >= balance.ai.contractDragToxic) {
          firstToxicYear ??= year;
          if (year - firstToxicYear > 2) longLived++;
        } else {
          firstToxicYear = null;
        }
        _contractLedger[player.id] = _ContractObservation(
          signature: signature,
          firstToxicYear: firstToxicYear,
        );
      }
    }
    return longLived;
  }

  String _contractSignature(Player player) {
    final contract = player.contract;
    final blocked = [...contract.blockedTeamIds]..sort();
    return [
      contract.salary,
      contract.isRookieScale,
      contract.rookiePickSlot,
      contract.noTradeClause,
      blocked.join(','),
    ].join('|');
  }

  int _countRebuildToContenderTransitions() {
    var transitions = 0;
    for (final statuses in _statusHistory.values) {
      for (var index = 0; index < statuses.length; index++) {
        if (statuses[index] != TeamStatus.rebuild) continue;
        final end = min(index + 4, statuses.length - 1);
        if (statuses
            .sublist(index + 1, end + 1)
            .any(
              (status) =>
                  status == TeamStatus.contender || status == TeamStatus.elite,
            )) {
          transitions++;
          break;
        }
      }
    }
    return transitions;
  }

  Map<String, int> _globalFinalRank(LeagueState league) {
    final standings = [
      for (final conference in league.currentSeason.standings)
        ...conference.standings,
    ];
    standings.sort((a, b) {
      final points = b.points.compareTo(a.points);
      if (points != 0) return points;
      final difference = b.goalDifference.compareTo(a.goalDifference);
      if (difference != 0) return difference;
      final goals = b.goalsFor.compareTo(a.goalsFor);
      if (goals != 0) return goals;
      return a.teamId.compareTo(b.teamId);
    });
    return {
      for (var index = 0; index < standings.length; index++)
        standings[index].teamId: index + 1,
    };
  }

  double? _pearson(Map<String, int> expected, Map<String, int> actual) {
    final keys = expected.keys.where(actual.containsKey).toList();
    if (keys.length < 2) return null;
    final x = [for (final key in keys) expected[key]!.toDouble()];
    final y = [for (final key in keys) actual[key]!.toDouble()];
    final meanX = _mean(x);
    final meanY = _mean(y);
    var numerator = 0.0;
    var denominatorX = 0.0;
    var denominatorY = 0.0;
    for (var index = 0; index < keys.length; index++) {
      final dx = x[index] - meanX;
      final dy = y[index] - meanY;
      numerator += dx * dy;
      denominatorX += dx * dx;
      denominatorY += dy * dy;
    }
    final denominator = sqrt(denominatorX * denominatorY);
    return denominator == 0 ? null : numerator / denominator;
  }

  void _observeAprons(LeagueState league) {
    final count = _aiTeams(league)
        .where((team) => team.finance.totalPayroll > team.finance.secondApron)
        .length;
    _secondApronPeak = max(_secondApronPeak, count);
  }

  List<Team> _aiTeams(LeagueState league) => [
    for (final team in league.teams)
      if (team.ai != null && team.id != _task38PlayerTeamId) team,
  ];

  LeagueState _repairPassiveRoster(
    LeagueState league, {
    required int saveSeed,
  }) {
    final player = league.teamById(_task38PlayerTeamId);
    if (player == null ||
        (player.roster.length >= 20 && player.availablePlayers.length >= 11)) {
      return league;
    }
    final neutral = league.copyWith(
      playerTeamId: null,
      teams: league.teams
          .map(
            (team) => team.id == _task38PlayerTeamId
                ? team.copyWith(ai: const TeamAiConfig())
                : team,
          )
          .toList(),
    );
    final repaired = rosterManagement.ensureRosterSafety(
      neutral,
      saveSeed: saveSeed,
    );
    return repaired.copyWith(
      playerTeamId: _task38PlayerTeamId,
      teams: repaired.teams
          .map(
            (team) =>
                team.id == _task38PlayerTeamId ? team.copyWith(ai: null) : team,
          )
          .toList(),
    );
  }

  void _collectPostseasonResults(LeagueState league) {
    for (final progress in league.currentSeason.playInProgress) {
      _recordOptionalResult(league, progress.game7v8);
      _recordOptionalResult(league, progress.game9v10);
      _recordOptionalResult(league, progress.gameFinal);
    }
    for (final result in league.currentSeason.playInResults) {
      _recordResult(league, result.game7v8);
      _recordResult(league, result.game9v10);
      _recordResult(league, result.gameFinal);
    }
    for (final bracket in league.currentSeason.playoffBrackets) {
      for (final series in _seriesOf(bracket)) {
        for (final result in series.games) {
          _recordResult(league, result);
        }
      }
    }
  }

  void _recordOptionalResult(LeagueState league, MatchResult? result) {
    if (result != null) _recordResult(league, result);
  }

  void _recordResult(LeagueState league, MatchResult result) {
    final key = [
      league.currentSeason.year,
      result.homeTeamId,
      result.awayTeamId,
      result.homeGoals,
      result.awayGoals,
      result.status.name,
      result.reasonCode,
      result.context.seed,
      result.isWalkover,
    ].join('|');
    if (!_seenResultKeys.add(key)) return;
    if (!result.isWalkover) return;
    final aiIds = {for (final team in _aiTeams(league)) team.id};
    final isAiCause = result.violatingTeamIds.isNotEmpty
        ? result.violatingTeamIds.any(aiIds.contains)
        : (aiIds.contains(result.homeTeamId) &&
              aiIds.contains(result.awayTeamId));
    if (isAiCause) _walkovers++;
  }
}

String _formatRate(double? value, {String suffix = ''}) {
  if (value == null || value.isNaN) return 'n/a';
  return '${value.toStringAsFixed(2)}$suffix';
}

double _mean(Iterable<double> values) {
  final list = values.toList();
  if (list.isEmpty) return 0.0;
  return list.reduce((a, b) => a + b) / list.length;
}

double _median(List<double> values) {
  if (values.isEmpty) return 0.0;
  values.sort();
  final middle = values.length ~/ 2;
  if (values.length.isOdd) return values[middle];
  return (values[middle - 1] + values[middle]) / 2.0;
}

void main() {
  test('Task 38 accelerated calibration runs ten deterministic seasons', () {
    final report = _Task38Harness(
      profile: _Task38Profile.accelerated,
      seasonCount: _task38Seasons,
    ).run();
    print(report.render());

    expect(report.profile, _Task38Profile.accelerated);
    expect(report.seasons, hasLength(_task38Seasons));
    expect(report.logicalDays, _task38Seasons * 52 * 7);
    expect(report.executedTicks, lessThan(report.logicalDays));
    expect(
      report.seasons.every((season) => season.championTeamId != null),
      isTrue,
    );
  }, skip: !_task38RunFull);

  test('Task 38 full-fidelity one-season smoke test', () {
    final report = _Task38Harness(
      profile: _Task38Profile.full,
      seasonCount: 1,
    ).run();
    print(report.render());

    expect(report.profile, _Task38Profile.full);
    expect(report.seasons, hasLength(1));
    expect(report.logicalDays, 52 * 7);
    expect(report.executedTicks, 52 * 7);
    expect(report.seasons.single.championTeamId, isNotNull);
  });

  test('Task 38 full 10-season benchmark', () {
    final report = _Task38Harness(
      profile: _Task38Profile.full,
      seasonCount: _task38Seasons,
    ).run();
    print(report.render());

    expect(report.profile, _Task38Profile.full);
    expect(report.seasons, hasLength(_task38Seasons));
    expect(report.logicalDays, _task38Seasons * 52 * 7);
    expect(report.executedTicks, _task38Seasons * 52 * 7);
    expect(
      report.seasons.every((season) => season.championTeamId != null),
      isTrue,
    );
  }, skip: !_task38RunFull);
}
