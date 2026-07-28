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

final saveRepositoryProvider = Provider((ref) {
  return SaveRepository();
});

final gameFactoryProvider = Provider((ref) => GameFactory());

final calendarServiceProvider = Provider((ref) => const CalendarService());

final matchEngineProvider = Provider((ref) => const MatchEngine());

final daySimulatorProvider = Provider((ref) {
  return DaySimulator(matchEngine: ref.watch(matchEngineProvider));
});

final seasonServiceProvider = Provider((ref) => SeasonService());

final staffServiceProvider = Provider((ref) => StaffService());

final scoutingServiceProvider = Provider((ref) => ScoutingService());

final contractServiceProvider = Provider((ref) => ContractService());

final savesListProvider = FutureProvider.autoDispose<List<GameSaveMeta>>((
  ref,
) async {
  return ref.watch(saveRepositoryProvider).listSaves();
});

/// Why a batch simulation (`GameController.simulateTo...`) stopped.
enum SimulationStopReason {
  /// Target date / phase end reached without any blocking event.
  reachedTarget,

  /// The player's team has a match today — UI should open matchday.
  playerMatch,

  /// An urgent inbox message needs attention.
  urgent,

  /// The next registered calendar event needs player input (e.g. draft
  /// pick) — UI should navigate there. Draft has no separate stop reason:
  /// it is just a `playerAction` event like any other.
  event,

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
    this.eventId,
  });

  final SimulationStopReason stopReason;
  final int daysSimulated;
  final DaySimulationResult? lastResult;

  /// Set when [stopReason] is [SimulationStopReason.event] — the id of the
  /// `CalendarEventSlot` that needs attention.
  final String? eventId;
}

class GameController extends StateNotifier<AsyncValue<GameSave?>> {
  GameController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  SaveRepository get _repo => _ref.read(saveRepositoryProvider);
  DaySimulator get _days => _ref.read(daySimulatorProvider);
  SeasonService get _season => _ref.read(seasonServiceProvider);
  CalendarService get _calendar => _ref.read(calendarServiceProvider);

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

  bool _cancelRequested = false;

  /// Requests that an in-progress batch stop as soon as possible (checked
  /// between simulated days).
  void cancelSimulation() {
    _cancelRequested = true;
  }

  /// Advances the calendar by exactly one day: no phase hooks, no
  /// calendar-event auto-resolution, no auto-simulating the player's match.
  /// This is the raw primitive `simulateToEvent`/`simulateToDate` build on.
  Future<DaySimulationResult?> advanceOneDay() async {
    final current = save;
    if (current == null) return null;
    final result = _days.simulateDay(current.leagueState);
    await updateLeague((_) => result.league);
    return result;
  }

  /// Returns the id of the calendar event registered at [week]/[day] that
  /// still needs to run this season, or null if none is due today.
  String? _dueEventIdToday(LeagueState league) {
    final due = _calendar.nextEvent(
      league.currentWeek,
      league.currentDay,
      (id) => _isEventDone(league, id),
    );
    if (due == null) return null;
    if (due.week != league.currentWeek || due.day != league.currentDay) {
      return null;
    }
    return due.id;
  }

  bool _isEventDone(LeagueState league, String id) {
    final s = league.currentSeason;
    switch (id) {
      case 'staffGrowth':
        return s.staffGrowthDone;
      case 'retirements':
        return s.playerRetirementsDone;
      case 'awards':
        return s.awards != null;
      case 'lottery':
        return s.draftState != null;
      case 'scoutReport':
        return s.scoutReportDone;
      case 'combine':
        return s.combineDone;
      case 'finalMock':
        return s.finalMockDone;
      case 'nextClassGeneration':
        return s.nextDraftState != null;
      case 'draft':
        final draft = s.draftState;
        if (draft == null) return false;
        return draft.currentPickIndex >= draft.order.length;
      case 'freeAgencyOpen':
        return s.faOpenDone;
      case 'tradeDeadline':
        return s.tradeDeadlineAcked;
      default:
        return true;
    }
  }

  /// Returns true if the calendar event due today is a `playerAction` that
  /// the batch must stop for (currently only the draft, when it's the
  /// player's turn to pick).
  bool _isBlockingPlayerEvent(LeagueState league, String eventId) {
    if (eventId != 'draft') return false;
    final draft = league.currentSeason.draftState;
    if (draft == null) return false;
    if (draft.currentPickIndex >= draft.order.length) return false;
    return draft.order[draft.currentPickIndex].teamId == league.playerTeamId;
  }

  /// Runs the automatic/informational calendar event registered for
  /// [eventId] at the current date. No-op (besides validation) for
  /// `playerAction` events like `draft` — those are driven entirely by the
  /// dedicated UI + `makeDraftPick`.
  Future<void> runEventAtCurrentDay(String eventId) async {
    await updateLeague((league) {
      switch (eventId) {
        case 'staffGrowth':
          return _season.runStaffGrowthAndRetire(league);
        case 'retirements':
          return _season.runPlayerRetirements(league);
        case 'awards':
          return _season.runAwards(league);
        case 'lottery':
          return _season.runLottery(league);
        case 'scoutReport':
          return _season.runScoutReport(league);
        case 'combine':
          return _season.runCombine(league);
        case 'finalMock':
          return _season.runFinalMock(league);
        case 'nextClassGeneration':
          return _season.runNextClassGeneration(league);
        case 'draft':
          // playerAction — handled by the draft screen + makeDraftPick.
          return league;
        case 'freeAgencyOpen':
          return _season.runFreeAgencyOpen(league);
        case 'tradeDeadline':
          return league.copyWith(
            currentSeason: league.currentSeason.copyWith(
              tradeDeadlineAcked: true,
            ),
          );
        default:
          return league;
      }
    });
  }

  /// Repeatedly advances one day at a time until [reachedTarget] holds
  /// (checked before each day), a due event/match/urgent condition stops
  /// the batch, cancellation is requested, or [maxDays] is hit as a safety
  /// cap. [autoResolveEvents] controls whether automatic/informational
  /// events encountered along the way are executed immediately
  /// (`simulateToDate` semantics) or left for the caller to react to
  /// (`simulateToEvent` semantics).
  Future<BatchSimulationResult> _simulateUntil(
    bool Function(LeagueState league) reachedTarget, {
    bool autoResolveEvents = false,
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

      final league = current.leagueState;
      final dueEventId = _dueEventIdToday(league);
      if (dueEventId != null && _isBlockingPlayerEvent(league, dueEventId)) {
        return BatchSimulationResult(
          stopReason: SimulationStopReason.event,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
          eventId: dueEventId,
        );
      }

      if (reachedTarget(league)) {
        return BatchSimulationResult(
          stopReason: SimulationStopReason.reachedTarget,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
        );
      }

      if (dueEventId != null) {
        if (!autoResolveEvents) {
          return BatchSimulationResult(
            stopReason: SimulationStopReason.event,
            daysSimulated: daysSimulated,
            lastResult: lastResult,
            eventId: dueEventId,
          );
        }
        await runEventAtCurrentDay(dueEventId);
      }

      if (daysSimulated >= maxDays) {
        return BatchSimulationResult(
          stopReason: SimulationStopReason.reachedTarget,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
        );
      }

      final result = await advanceOneDay();
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

  /// Simulates day by day until the next unresolved calendar event or the
  /// player's match comes up — whichever happens first. Encountered events
  /// are NOT auto-resolved; the caller reacts to `BatchSimulationResult`.
  Future<BatchSimulationResult> simulateToEvent() {
    return _simulateUntil((_) => false, autoResolveEvents: false);
  }

  /// Simulates day by day until (week, day) is reached, auto-resolving any
  /// automatic/informational events encountered along the way. Stops early
  /// if the player's match comes up, an urgent message arrives, or a
  /// `playerAction` event (draft, when it's the player's turn) is due.
  Future<BatchSimulationResult> simulateToDate(int targetWeek, int targetDay) {
    return _simulateUntil(
      (league) => _calendar.isAtOrAfter(
        league.currentWeek,
        league.currentDay,
        targetWeek,
        targetDay,
      ),
      autoResolveEvents: true,
    );
  }

  /// Simulates day by day until the player's next match comes up (or the
  /// simulation is otherwise interrupted). Events along the way are NOT
  /// auto-resolved.
  Future<BatchSimulationResult> simulateUntilNextMatch() {
    return _simulateUntil((_) => false, autoResolveEvents: false);
  }

  /// Simulates through the last day of [phase] (inclusive), stopping at the
  /// first day of whatever comes next. Auto-resolves events along the way.
  Future<BatchSimulationResult> simulateUntilPhaseEnd(SeasonPhase phase) {
    final (endWeek, endDay) = _calendar.endOfPhase(phase);
    final (targetWeek, targetDay) = _calendar.advanceDay(endWeek, endDay);
    return simulateToDate(targetWeek, targetDay);
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

final activeLeagueProvider = Provider((ref) {
  return ref.watch(gameControllerProvider).valueOrNull?.leagueState;
});
