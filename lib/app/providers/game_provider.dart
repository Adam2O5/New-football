import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_football/core/engine/match_engine.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/random/seeds.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/draft_service.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/core/services/scouting_service.dart';
import 'package:new_football/core/services/season_service.dart';
import 'package:new_football/core/services/message_service.dart';
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

final draftServiceProvider = Provider((ref) => DraftService());

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
  /// `CalendarEventSlot` that needs attention. `null` when the stop reason is
  /// the player's match or other non-calendar reasons.
  final CalendarEventId? eventId;
}

/// Next actionable thing on the calendar: the player's upcoming fixture, or
/// the next unresolved `CalendarEventSlot`. Drives the contextual button on
/// `HomeScreen` — `kind` decides which button(s) are shown.
class UpcomingAction {
  const UpcomingAction({
    required this.kind,
    required this.id,
    this.calendarEventId,
    required this.week,
    required this.day,
  });

  final CalendarEventKind kind;

  /// Registry event id, or `'match'` for the player's next fixture.
  final String id;

  /// If this action corresponds to a calendar event from the registry, this
  /// is its typed id. `null` for the player's match.
  final CalendarEventId? calendarEventId;
  final int week;
  final int day;
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

  bool _hasPendingUrgent(LeagueState league) =>
      league.inbox.pendingUrgent.isNotEmpty;

  LeagueState _deliverStartOfDay(LeagueState league, {int? hour}) {
    return league.copyWith(
      inbox: league.inbox.deliverScheduled(
        league.currentWeek,
        league.currentDay,
        hour: hour,
      ),
    );
  }

  LeagueState _setClockForDate(LeagueState league) {
    final hour = _calendar.initialHourForDate(
      league.currentWeek,
      league.currentDay,
    );
    return league.copyWith(
      currentHour: hour,
      hourlyPlayerOfferUsed: false,
      hourlyStaffOfferUsed: false,
    );
  }

  /// Advances the calendar by exactly one day: no phase hooks, no
  /// calendar-event auto-resolution, no auto-simulating the player's match.
  /// This is the raw primitive `simulateToEvent`/`simulateToDate` build on.
  Future<DaySimulationResult?> advanceOneDay() async {
    final current = save;
    if (current == null) return null;

    var league = _deliverStartOfDay(
      current.leagueState,
      hour: current.leagueState.currentHour,
    );
    if (_hasPendingUrgent(league)) {
      await updateLeague((_) => league);
      return null;
    }
    final calendar = _calendar;
    if (calendar
        .playInSlotsForDay(league.currentWeek, league.currentDay)
        .isNotEmpty) {
      league = _season.advancePlayInForDate(
        league,
        week: league.currentWeek,
        day: league.currentDay,
        saveSeed: current.saveSeed,
      );
    }
    if (calendar.phaseForWeek(league.currentWeek) == SeasonPhase.playoff &&
        league.currentSeason.playoffBrackets.isEmpty &&
        league.currentSeason.playInResults.isNotEmpty) {
      league = _season.setupPlayoffs(league);
    }
    if (calendar.postseasonSlotForDay(league.currentWeek, league.currentDay) !=
        null) {
      league = _season.advancePlayoffsForDate(
        league,
        week: league.currentWeek,
        day: league.currentDay,
        saveSeed: current.saveSeed,
      );
    }

    final result = _days.simulateDay(league, saveSeed: current.saveSeed);
    var updatedLeague = result.league;
    final isCycleEnd =
        current.leagueState.currentWeek ==
            calendar.balance.calendar.seasonCycleWeeks &&
        current.leagueState.currentDay == 7;
    if (isCycleEnd) {
      updatedLeague = _season.rolloverSeason(updatedLeague);
    }
    updatedLeague = _setClockForDate(updatedLeague);
    updatedLeague = _deliverStartOfDay(
      updatedLeague,
      hour: updatedLeague.currentHour,
    );
    if (isCycleEnd) {
      final updatedResult = DaySimulationResult(
        league: updatedLeague,
        pauseForUrgent: updatedLeague.inbox.pendingUrgent.isNotEmpty,
        playerMatch: result.playerMatch,
        simulatedResults: result.simulatedResults,
        eventId: result.eventId,
      );
      await updateLeague((_) => updatedLeague);
      return updatedResult;
    }
    await updateLeague((_) => updatedLeague);
    return result;
  }

  /// Advances one offer hour during extensions/FA phase I. The tenth hour
  /// delegates to the regular end-of-day pipeline, so matches and events are
  /// still resolved exactly once at the end of the calendar day.
  Future<DaySimulationResult?> advanceOneHour() async {
    final current = save;
    if (current == null) return null;

    var league = _deliverStartOfDay(
      current.leagueState,
      hour: current.leagueState.currentHour,
    );
    if (!_calendar.isHourlyContractMode(
      league.currentWeek,
      league.currentDay,
    )) {
      return null;
    }
    if (_hasPendingUrgent(league)) {
      await updateLeague((_) => league);
      return null;
    }

    final hour = league.currentHour ?? 1;
    if (hour >= 10) {
      await updateLeague(
        (_) => league.copyWith(currentHour: 10),
        autosave: true,
      );
      return advanceOneDay();
    }

    final next = league.copyWith(
      currentHour: hour + 1,
      hourlyPlayerOfferUsed: false,
      hourlyStaffOfferUsed: false,
    );
    await updateLeague((_) => next);
    return DaySimulationResult(league: next, pauseForUrgent: false);
  }

  /// Earliest unplayed fixture of the player's team, mapped to its
  /// calendar (week, day). Uses the deterministic actual match day for the
  /// fixture's week/slot, so HomeScreen and batch simulation point to the
  /// same date as `DaySimulator`.
  (int week, int day)? _nextPlayerMatchDate(LeagueState league) {
    final playerId = league.playerTeamId;
    if (playerId == null) return null;
    final fixtures =
        league.currentSeason.schedule
            .where(
              (m) =>
                  (m.homeTeamId == playerId || m.awayTeamId == playerId) &&
                  m.result == null,
            )
            .toList()
          ..sort((a, b) => a.round.compareTo(b.round));
    if (fixtures.isEmpty) return null;
    final round = fixtures.first.round;
    if (round < 1 || round > 58) return null;

    final (week, slot) = weekSlotForRound(round);
    final matchDays = matchDaysForWeek(week);

    return (week, slot == 0 ? matchDays.midweekDay : matchDays.weekendDay);
  }

  /// Next actionable item on the calendar: the player's fixture or the next
  /// unresolved `CalendarEventSlot`, whichever comes first. Returns `null`
  /// only if neither exists (e.g. no player team and no pending events).
  UpcomingAction? nextEvent({LeagueState? league}) {
    final state = league ?? save?.leagueState;
    if (state == null) return null;

    final matchDate = _nextPlayerMatchDate(state);
    final eventSlot = CalendarEventRegistry.nextEvent(state);

    if (matchDate == null && eventSlot == null) return null;
    if (eventSlot == null) {
      return UpcomingAction(
        kind: CalendarEventKind.match,
        id: 'match',
        week: matchDate!.$1,
        day: matchDate.$2,
      );
    }
    if (matchDate == null) {
      return UpcomingAction(
        kind: eventSlot.kind,
        id: eventSlot.id.name,
        calendarEventId: eventSlot.id,
        week: eventSlot.week,
        day: eventSlot.day,
      );
    }

    final fromWeek = state.currentWeek;
    final fromDay = state.currentDay;
    int normWeek(int week, int day) =>
        (week < fromWeek || (week == fromWeek && day < fromDay))
        ? week + _calendar.balance.calendar.seasonCycleWeeks
        : week;

    final matchNorm = normWeek(matchDate.$1, matchDate.$2);
    final eventNorm = normWeek(eventSlot.week, eventSlot.day);
    final matchFirst = matchNorm != eventNorm
        ? matchNorm < eventNorm
        : matchDate.$2 < eventSlot.day;

    return matchFirst
        ? UpcomingAction(
            kind: CalendarEventKind.match,
            id: 'match',
            week: matchDate.$1,
            day: matchDate.$2,
          )
        : UpcomingAction(
            kind: eventSlot.kind,
            id: eventSlot.id.name,
            calendarEventId: eventSlot.id,
            week: eventSlot.week,
            day: eventSlot.day,
          );
  }

  /// Non-null only when a non-match calendar event is due exactly today.
  UpcomingAction? _dueActionToday(LeagueState league) {
    final action = nextEvent(league: league);
    if (action == null) return null;
    if (action.week != league.currentWeek || action.day != league.currentDay) {
      return null;
    }
    return action;
  }

  /// Returns true if the calendar event due today is a `playerAction` that
  /// the batch must stop for (currently only the draft, when it's the
  /// player's turn to pick, or the lottery which requires interactive UI).
  bool _isBlockingPlayerEvent(LeagueState league, CalendarEventId eventId) {
    if (eventId == CalendarEventId.lottery) return true;
    if (eventId != CalendarEventId.draft) return false;
    final draft = league.currentSeason.draftState;
    if (draft == null) return false;
    if (draft.currentPickIndex >= draft.order.length) return false;
    return draft.order[draft.currentPickIndex].teamId == league.playerTeamId;
  }

  /// Runs the automatic/informational calendar event registered for
  /// [eventId] at the current date. No-op (besides validation) for
  /// `playerAction` events like `draft` — those are driven entirely by the
  /// dedicated UI + `makeDraftPick`.
  Future<void> runEventAtCurrentDay(CalendarEventId eventId) async {
    await updateLeague((league) {
      switch (eventId) {
        case CalendarEventId.staffGrowth:
          return _season.runStaffGrowthAndRetire(league);
        case CalendarEventId.retirements:
          return _season.runPlayerRetirements(league);
        case CalendarEventId.awards:
          return _season.runAwards(league);
        case CalendarEventId.lottery:
          // playerAction — handled by the lottery screen interactively.
          return league;
        case CalendarEventId.scoutReport:
          return _season.runScoutReport(league);
        case CalendarEventId.combine:
          return _season.runCombine(league);
        case CalendarEventId.finalMock:
          return _season.runFinalMock(league);
        case CalendarEventId.nextClassGeneration:
          return _season.runNextClassGeneration(league);
        case CalendarEventId.tradeWindowOpen:
        case CalendarEventId.contractExtensions:
          // Ranges are derived windows, not one-shot actions.
          return league;
        case CalendarEventId.draft:
          // playerAction — handled by the draft screen + makeDraftPick.
          return league;
        case CalendarEventId.freeAgencyOpen:
          return _season.runFreeAgencyOpen(league);
        case CalendarEventId.tradeDeadline:
          return league.copyWith(
            currentSeason: league.currentSeason.copyWith(
              tradeDeadlineAcked: true,
            ),
          );
      }
    });
  }

  /// Auto-simulates the player's fixture headlessly (same engine call as
  /// AI-vs-AI fixtures in `DaySimulator._resolveRound`) and applies the
  /// result via `applyPlayerMatchResult`. Used only by `simulateToDate` —
  /// `simulateToEvent` must hand the match off to `MatchdayScreen` instead
  /// (`DaySimulator.simulateDay` deliberately does not auto-sim it).
  /// Returns `null` if either team can't be resolved (should not happen in
  /// practice; treated as a hard stop by the caller).
  Future<MatchResult?> _autoSimulatePlayerMatch(ScheduledMatch match) async {
    final current = save;
    if (current == null) return null;
    final league = current.leagueState;
    final home = league.teamById(match.homeTeamId);
    final away = league.teamById(match.awayTeamId);
    if (home == null || away == null) return null;

    final engine = _ref.read(matchEngineProvider);
    final result = engine.simulateFull(
      home: home,
      away: away,
      rngSeed: matchSeed(current.saveSeed, league.currentSeason.year, match.id),
    );
    await updateLeague((l) => _days.applyPlayerMatchResult(l, match, result));
    return result;
  }

  /// Repeatedly advances one day at a time until [reachedTarget] holds
  /// (checked before each day), a due event/match/urgent condition stops
  /// the batch, cancellation is requested, or [maxDays] is hit as a safety
  /// cap.
  ///
  /// [autoResolveEvents] controls whether automatic/informational/
  /// non-blocking `playerAction` events encountered along the way are
  /// executed immediately (`simulateToDate` semantics) or left for the
  /// caller to react to (`simulateToEvent` semantics).
  ///
  /// [autoSimulatePlayerMatch] controls whether the player's own fixture is
  /// auto-simulated headlessly and the batch continues (`simulateToDate`:
  /// calendar fast-forward skips most matches/events), or the batch stops
  /// so the caller can hand off to `MatchdayScreen` (`simulateToEvent`:
  /// home-screen day-by-day / next-match-or-event, matching the FIFA-style
  /// "stop right before it happens" flow).
  Future<BatchSimulationResult> _simulateUntil(
    bool Function(LeagueState league) reachedTarget, {
    bool autoResolveEvents = false,
    bool autoSimulatePlayerMatch = false,
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
      final due = _dueActionToday(league);
      final dueEventId = (due != null && due.kind != CalendarEventKind.match)
          ? due.calendarEventId
          : null;

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

      final wasHourlyEnd =
          _calendar.isHourlyContractMode(
            league.currentWeek,
            league.currentDay,
          ) &&
          (league.currentHour ?? 1) >= 10;
      final result =
          _calendar.isHourlyContractMode(league.currentWeek, league.currentDay)
          ? await advanceOneHour()
          : await advanceOneDay();
      if (result == null) {
        return BatchSimulationResult(
          stopReason: SimulationStopReason.noSave,
          daysSimulated: daysSimulated,
          lastResult: lastResult,
        );
      }
      lastResult = result;
      if (!wasHourlyEnd &&
          !_calendar.isHourlyContractMode(
            league.currentWeek,
            league.currentDay,
          )) {
        daysSimulated++;
      } else if (wasHourlyEnd) {
        daysSimulated++;
      }

      if (result.playerMatch != null) {
        if (autoSimulatePlayerMatch) {
          final autoResult = await _autoSimulatePlayerMatch(
            result.playerMatch!,
          );
          if (autoResult != null) {
            final leagueAfter = save!.leagueState;
            lastResult = DaySimulationResult(
              league: leagueAfter,
              pauseForUrgent: leagueAfter.inbox.pendingUrgent.isNotEmpty,
              simulatedResults: [autoResult],
              eventId: null,
            );
            if (leagueAfter.inbox.pendingUrgent.isNotEmpty) {
              return BatchSimulationResult(
                stopReason: SimulationStopReason.urgent,
                daysSimulated: daysSimulated,
                lastResult: lastResult,
              );
            }
            continue;
          }
        }
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
  /// player's match comes up — whichever happens first. Nic nie jest
  /// auto-resolwowane: to jest ścieżka `HomeScreen` (day-by-day / do
  /// następnego meczu-lub-eventu), caller reaguje na `BatchSimulationResult`.
  Future<BatchSimulationResult> simulateToEvent() {
    return _simulateUntil(
      (_) => false,
      autoResolveEvents: false,
      autoSimulatePlayerMatch: false,
    );
  }

  /// Szybka symulacja kalendarzowa: dociąga do (week, day), auto-resolwując
  /// po drodze zarówno automatyczne/informacyjne eventy, jak i mecze
  /// gracza (headlessly, silnikiem — bez otwierania `MatchdayScreen`).
  /// Zatrzymuje się wyłącznie na: pilnej wiadomości w skrzynce lub
  /// `playerAction` evencie, na który wymagana jest realna decyzja gracza
  /// (obecnie tylko tura draftu gracza).
  Future<BatchSimulationResult> simulateToDate(int targetWeek, int targetDay) {
    return _simulateUntil(
      (league) => _calendar.isAtOrAfter(
        league.currentWeek,
        league.currentDay,
        targetWeek,
        targetDay,
      ),
      autoResolveEvents: true,
      autoSimulatePlayerMatch: true,
    );
  }

  /// Simulates through the last day of [phase] (inclusive), stopping at the
  /// first day of whatever comes next. Ta sama semantyka co `simulateToDate`
  /// (auto-resolve eventów i meczów gracza).
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

  /// Marks a message as read without acknowledging an urgent pause.
  Future<void> markMessageRead(String id) async {
    await updateLeague((l) => l.copyWith(inbox: l.inbox.markRead(id)));
  }

  /// Acknowledges an urgent message and releases its simulation pause.
  Future<void> acknowledgeMessage(String id) async {
    await updateLeague((l) => l.copyWith(inbox: l.inbox.acknowledge(id)));
  }

  /// Applies a decision effect, then acknowledges the message.
  ///
  /// The optional dispatcher is deliberately injected by the caller because
  /// message effects belong to their owning domain service. Without one, the
  /// choice is still recorded and the urgent pause is released safely.
  Future<void> resolveMessageDecision(
    String id,
    String optionId, {
    MessageDecisionHandler? onDecision,
  }) async {
    await updateLeague(
      (league) => MessageService().resolveDecision(
        league,
        id,
        optionId,
        onDecision: onDecision,
      ),
    );
  }

  Future<void> makeDraftPick(String prospectId) async {
    await updateLeague(
      (l) => _season.advanceDraft(l, playerPickProspectId: prospectId),
    );
  }

  Future<void> simulateOneDraftPick() async {
    await updateLeague((l) => _season.advanceDraftOnePick(l));
  }

  Future<void> simulateDraftToPlayerTurn() async {
    await updateLeague((l) => _season.advanceDraft(l));
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
    final hourly = _calendar.isHourlyContractMode(
      league.currentWeek,
      league.currentDay,
    );
    if (hourly && league.hourlyPlayerOfferUsed) {
      return ContractReaction.hardReject;
    }
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
      await updateLeague((l) {
        var next = l
            .updateTeam(signed)
            .copyWith(
              freeAgents: l.freeAgents
                  .where((p) => p.id != freeAgentId)
                  .toList(),
            );
        if (hourly) next = next.copyWith(hourlyPlayerOfferUsed: true);
        return next;
      });
    } else if (hourly) {
      await updateLeague((l) => l.copyWith(hourlyPlayerOfferUsed: true));
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
    final hourly = _calendar.isHourlyContractMode(
      league.currentWeek,
      league.currentDay,
    );
    if (hourly && league.hourlyStaffOfferUsed) return false;
    final team = league.playerTeam;
    if (team == null) return false;

    if (hourly) {
      await updateLeague((l) => l.copyWith(hourlyStaffOfferUsed: true));
    }
    final reaction = _staff.evaluateOffer(candidate, offer);
    if (reaction != StaffReaction.accept) return false;

    final hired = _staff.hire(team: team, member: candidate, offer: offer);
    if (hired == null) return false;

    await updateLeague((l) {
      var next = l
          .updateTeam(hired)
          .copyWith(
            staffFreeAgents: l.staffFreeAgents
                .where((m) => m.id != candidate.id)
                .toList(),
          );
      if (hourly) next = next.copyWith(hourlyStaffOfferUsed: true);
      return next;
    });
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

/// Next fixture/event the player can act on, driving the contextual button
/// on `HomeScreen`. Recomputed whenever `activeLeagueProvider` changes.
final nextGameEventProvider = Provider<UpcomingAction?>((ref) {
  ref.watch(activeLeagueProvider);
  return ref.read(gameControllerProvider.notifier).nextEvent();
});
