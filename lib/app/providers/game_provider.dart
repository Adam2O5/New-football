import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_football/core/engine/match_engine.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/scouting_service.dart';
import 'package:new_football/core/services/season_service.dart';
import 'package:new_football/core/services/staff_service.dart';
import 'package:new_football/data/save_repository.dart';

final saveRepositoryProvider = Provider<SaveRepository>((ref) {
  return SaveRepository();
});

final gameFactoryProvider = Provider<GameFactory>((ref) => GameFactory());

final calendarServiceProvider = Provider<CalendarService>(
  (ref) => const CalendarService(),
);

final matchEngineProvider = Provider<MatchEngine>((ref) => const MatchEngine());

final daySimulatorProvider = Provider<DaySimulator>((ref) {
  return DaySimulator(matchEngine: ref.watch(matchEngineProvider));
});

final seasonServiceProvider = Provider<SeasonService>((ref) => SeasonService());

final staffServiceProvider = Provider<StaffService>((ref) => StaffService());

final scoutingServiceProvider = Provider<ScoutingService>(
  (ref) => ScoutingService(),
);

final contractServiceProvider = Provider<ContractService>(
  (ref) => ContractService(),
);

final savesListProvider = FutureProvider.autoDispose<List<GameSaveMeta>>((
  ref,
) async {
  return ref.watch(saveRepositoryProvider).listSaves();
});

/// Why a batch simulation (`GameController.simulateUntil...`) stopped.
enum SimulationStopReason {
  /// Target date / phase end reached without any blocking event.
  reachedTarget,

  /// The player's team has a match today — UI should open matchday.
  playerMatch,

  /// An urgent inbox message needs attention.
  urgent,

  /// It's the player's turn to make a draft pick.
  draftPick,

  /// User cancelled the batch simulation.
  cancelled,

  /// No active save (nothing to simulate).
  noSave,
}

class BatchSimulationResult {
  const BatchSimulationResult({
    required this.stopReason,
    required this.daysSimulated,
    this.lastResult,
  });

  final SimulationStopReason stopReason;
  final int daysSimulated;
  final DaySimulationResult? lastResult;
}

class GameController extends StateNotifier<AsyncValue<GameSave?>> {
  GameController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  SaveRepository get _repo => _ref.read(saveRepositoryProvider);
  DaySimulator get _days => _ref.read(daySimulatorProvider);
  SeasonService get _season => _ref.read(seasonServiceProvider);

  GameSave? get save => state.valueOrNull;

  Future<void> createNewGame(NewGameRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final game = _ref.read(gameFactoryProvider).create(request);
      await _repo.save(game);
      return game;
    });
  }

  Future<void> loadGame(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => _repo.load(id));
  }

  Future<void> persist() async {
    final current = save;
    if (current == null) return;
    await _repo.save(current);
  }

  Future<void> updateLeague(
    LeagueState Function(LeagueState) transform, {
    bool autosave = true,
  }) async {
    final current = save;
    if (current == null) return;
    final league = transform(current.leagueState);
    final next = current.copyWith(
      leagueState: league,
      meta: current.meta.copyWith(
        updatedAt: DateTime.now(),
        seasonYear: league.currentSeason.year,
        phase: league.currentSeason.phase,
        playerTeamName: league.playerTeam?.name,
      ),
    );
    state = AsyncValue.data(next);
    if (autosave) await _repo.save(next);
  }

  Future<DaySimulationResult?> simulateDay() async {
    final current = save;
    if (current == null) return null;
    var league = _maybeRunPhaseHooks(current.leagueState);
    final result = _days.simulateDay(league);
    await updateLeague((_) => result.league);
    return result;
  }

  bool _cancelRequested = false;

  /// Requests that an in-progress `simulateUntil...` batch stop as soon as
  /// possible (checked between simulated days).
  void cancelSimulation() {
    _cancelRequested = true;
  }

  bool _awaitingPlayerDraftPick(LeagueState league) {
    final draft = league.currentSeason.draftState;
    if (draft == null) return false;
    if (draft.currentPickIndex >= draft.order.length) return false;
    return draft.order[draft.currentPickIndex].teamId == league.playerTeamId;
  }

  /// Repeatedly calls [simulateDay] until [reachedTarget] holds (checked
  /// before each day), the player's match/turn comes up, an urgent message
  /// arrives, the batch is cancelled, or [maxDays] is hit as a safety cap.
  Future<BatchSimulationResult> _simulateUntil(
    bool Function(LeagueState league) reachedTarget, {
    int maxDays = 400,
  }) async {
    _cancelRequested = false;
    var daysSimulated = 0;
    DaySimulationResult? lastResult;

    while (true) {
      final current = save;
      if (current == null) {
        return BatchSimulationResult(
          stopReason: SimulationStopReason.noSave,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
        );
      }
      if (_cancelRequested) {
        return BatchSimulationResult(
          stopReason: SimulationStopReason.cancelled,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
        );
      }
      if (_awaitingPlayerDraftPick(current.leagueState)) {
        return BatchSimulationResult(
          stopReason: SimulationStopReason.draftPick,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
        );
      }
      if (reachedTarget(current.leagueState)) {
        return BatchSimulationResult(
          stopReason: SimulationStopReason.reachedTarget,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
        );
      }
      if (daysSimulated >= maxDays) {
        return BatchSimulationResult(
          stopReason: SimulationStopReason.reachedTarget,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
        );
      }

      final result = await simulateDay();
      if (result == null) {
        return BatchSimulationResult(
          stopReason: SimulationStopReason.noSave,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
        );
      }
      lastResult = result;
      daysSimulated++;

      if (result.playerMatch != null) {
        return BatchSimulationResult(
          stopReason: SimulationStopReason.playerMatch,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
        );
      }
      if (result.pauseForUrgent) {
        return BatchSimulationResult(
          stopReason: SimulationStopReason.urgent,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
        );
      }
    }
  }

  /// Simulates day by day until the player's next match comes up (or the
  /// simulation is otherwise interrupted).
  Future<BatchSimulationResult> simulateUntilNextMatch() {
    return _simulateUntil((_) => false);
  }

  bool _isCalendarEventDay(LeagueState league) {
    final calendar = _ref.read(calendarServiceProvider);
    final calCfg = calendar.balance.calendar;
    final week = league.currentWeek;
    final day = league.currentDay;
    if (calendar.isTradeDeadline(week, day)) return true;
    if (week == calCfg.awardsWeek && day == 1) return true;
    if (week == calCfg.awardsWeek + 1 && (day == 1 || day == 3 || day == 5)) {
      return true;
    }
    if (week == calCfg.draftWeek && day == 1) return true;
    if (week == calCfg.freeAgencyWeek && day == 1) return true;
    return false;
  }

  /// Simulates day by day until the player's next match, or the next
  /// offseason/calendar event (trade deadline, awards, draft, free agency),
  /// comes up — whichever happens first.
  Future<BatchSimulationResult> simulateUntilNextEvent() {
    return _simulateUntil(_isCalendarEventDay);
  }

  /// Simulates day by day until (week, day) is reached — i.e. stops with the
  /// calendar sitting on that date, ready to be played from there.
  Future<BatchSimulationResult> simulateUntilDate(
    int targetWeek,
    int targetDay,
  ) {
    final calendar = _ref.read(calendarServiceProvider);
    return _simulateUntil(
      (league) => calendar.isAtOrAfter(
        league.currentWeek,
        league.currentDay,
        targetWeek,
        targetDay,
      ),
    );
  }

  /// Simulates through the last day of [phase] (inclusive), stopping at the
  /// first day of whatever comes next.
  Future<BatchSimulationResult> simulateUntilPhaseEnd(SeasonPhase phase) {
    final calendar = _ref.read(calendarServiceProvider);
    final (endWeek, endDay) = calendar.endOfPhase(phase);
    final (targetWeek, targetDay) = calendar.advanceDay(endWeek, endDay);
    return simulateUntilDate(targetWeek, targetDay);
  }

  LeagueState _maybeRunPhaseHooks(LeagueState league) {
    final week = league.currentWeek;
    final day = league.currentDay;
    if (week == 31 && day == 1 && league.currentSeason.playInResults.isEmpty) {
      return _season.setupPlayIn(league);
    }
    if (week == 32 &&
        day == 1 &&
        league.currentSeason.playoffBrackets.isEmpty) {
      var s = league;
      if (s.currentSeason.playInResults.isEmpty) {
        s = _season.setupPlayIn(s);
      }
      return _season.setupPlayoffs(s);
    }
    if (week >= 32 &&
        week <= 43 &&
        league.currentSeason.playoffBrackets.isNotEmpty &&
        league.currentSeason.championTeamId == null &&
        day == 3) {
      return _season.advancePlayoffs(league);
    }
    if (week == 44 && day == 1 && league.currentSeason.awards == null) {
      return _season.runAwardsAndLottery(league);
    }
    if (week == 45 && day == 1) {
      return _season.runScoutReport(league);
    }
    if (week == 45 && day == 3) {
      return _season.runCombine(league);
    }
    if (week == 45 && day == 5) {
      return _season.runFinalMock(league);
    }
    if (week == 46 && day == 1) {
      return _season.advanceDraft(league);
    }
    if (week == 47 && day == 1) {
      return _season.expireContracts(league);
    }
    if (week >= 48 && day == 1) {
      return _season.rolloverSeason(league);
    }
    return league;
  }

  Future<void> applyPlayerMatch(
    ScheduledMatch match,
    MatchResult result,
  ) async {
    await updateLeague((l) => _days.applyPlayerMatchResult(l, match, result));
  }

  Future<void> markMessageRead(String id) async {
    await updateLeague((l) => l.copyWith(inbox: l.inbox.markRead(id)));
  }

  Future<void> makeDraftPick(String prospectId) async {
    await updateLeague(
      (l) => _season.advanceDraft(l, playerPickProspectId: prospectId),
    );
  }

  ContractService get _contracts => _ref.read(contractServiceProvider);

  /// Submits the player's offer for a free agent. On `accept` the player
  /// signs immediately and the FA pool updates (`docs/contract_signing.md`).
  Future<ContractReaction> offerFreeAgent(
    String freeAgentId,
    ContractOffer offer,
  ) async {
    final current = save;
    if (current == null) return ContractReaction.hardReject;
    final league = current.leagueState;
    final team = league.playerTeam;
    Player? player;
    for (final p in league.freeAgents) {
      if (p.id == freeAgentId) player = p;
    }
    if (team == null || player == null) return ContractReaction.hardReject;

    final reaction = _contracts.evaluate(player, offer);
    if (reaction == ContractReaction.accept) {
      final signed = _contracts.signPlayer(
        team: team,
        player: player,
        offer: offer,
      );
      if (signed == null) return ContractReaction.hardReject;
      await updateLeague(
        (l) => l
            .updateTeam(signed)
            .copyWith(
              freeAgents: l.freeAgents
                  .where((p) => p.id != freeAgentId)
                  .toList(),
            ),
      );
    }
    return reaction;
  }

  StaffService get _staff => _ref.read(staffServiceProvider);

  /// Hires [candidate] from `staffFreeAgents` for the player's team at
  /// [offer]. Returns `false` if the offer is rejected or invalid.
  Future<bool> hireStaff(StaffMember candidate, StaffOffer offer) async {
    final current = save;
    if (current == null) return false;
    final league = current.leagueState;
    final team = league.playerTeam;
    if (team == null) return false;

    final reaction = _staff.evaluateOffer(candidate, offer);
    if (reaction != StaffReaction.accept) return false;

    final hired = _staff.hire(team: team, member: candidate, offer: offer);
    if (hired == null) return false;

    await updateLeague(
      (l) => l
          .updateTeam(hired)
          .copyWith(
            staffFreeAgents: l.staffFreeAgents
                .where((m) => m.id != candidate.id)
                .toList(),
          ),
    );
    return true;
  }

  Future<void> fireStaff(StaffRole role) async {
    await updateLeague((l) {
      final team = l.playerTeam;
      if (team == null) return l;
      return l.updateTeam(_staff.fire(team, role));
    });
  }

  ScoutingService get _scouting => _ref.read(scoutingServiceProvider);

  /// Sets the player team's scouting watchlist, capped by scout Coverage.
  Future<void> setScoutWatchlist(List<String> prospectIds) async {
    await updateLeague((l) {
      final team = l.playerTeam;
      if (team == null) return l;
      final coverage = team.staff.scout?.attributes.coverage ?? 0.0;
      final scouting = _scouting.setWatchlist(
        team.scouting,
        prospectIds,
        coverageStars: coverage,
      );
      return l.updateTeam(team.copyWith(scouting: scouting));
    });
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

final gameControllerProvider =
    StateNotifierProvider<GameController, AsyncValue<GameSave?>>((ref) {
      return GameController(ref);
    });

final activeLeagueProvider = Provider<LeagueState?>((ref) {
  return ref.watch(gameControllerProvider).valueOrNull?.leagueState;
});
