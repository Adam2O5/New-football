import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/league_state.dart';

enum CalendarEventKind { match, playerAction, automatic, informational }

/// Typed calendar event identifiers — single source of truth.
/// Replaces stringly-typed IDs across the codebase.
enum CalendarEventId {
  staffGrowth,
  awards,
  retirements,
  lottery,
  scoutReport,
  combine,
  finalMock,
  draft,
  nextClassGeneration,
  tradeWindowOpen,
  contractExtensions,
  tradeDeadline,
  freeAgencyOpen,
}

class CalendarEventSlot {
  const CalendarEventSlot({
    required this.id,
    required this.week,
    required this.day,
    required this.order,
    required this.kind,
    this.endWeek,
    this.endDay,
  });

  final CalendarEventId id;
  final int week;
  final int day;
  final int order;
  final CalendarEventKind kind;
  final int? endWeek;
  final int? endDay;
}

/// A non-point calendar window, such as the trade, extension or FA window.
class CalendarEventWindow {
  const CalendarEventWindow({
    required this.id,
    required this.startWeek,
    required this.startDay,
    required this.endWeek,
    required this.endDay,
    required this.kind,
    this.wrapsYear = false,
  });

  final CalendarEventId id;
  final int startWeek;
  final int startDay;
  final int endWeek;
  final int endDay;
  final CalendarEventKind kind;
  final bool wrapsYear;

  bool contains(int week, int day, int cycleWeeks) {
    final current = (week - 1) * 7 + (day - 1);
    final start = (startWeek - 1) * 7 + (startDay - 1);
    final end = (endWeek - 1) * 7 + (endDay - 1);
    final cycleDays = cycleWeeks * 7;
    if (current < 0 || current >= cycleDays) return false;
    if (!wrapsYear) return current >= start && current <= end;
    return current >= start || current <= end;
  }
}

/// Statyczny rejestr eventów offseasonu, budowany z [BalanceConfig.calendar]
/// żeby numery tygodni nie były zahardkodowane (`docs/game_calendar.md`,
/// `docs/offseason.md`).
class CalendarEventRegistry {
  const CalendarEventRegistry._();

  static List<CalendarEventSlot> build(CalendarBalance calendar) {
    final awardsWeek = calendar.awardsWeek;
    final scoutWeek = awardsWeek + 1;
    return [
      CalendarEventSlot(
        id: CalendarEventId.awards,
        week: awardsWeek,
        day: 1,
        order: 0,
        kind: CalendarEventKind.informational,
      ),
      CalendarEventSlot(
        id: CalendarEventId.staffGrowth,
        week: awardsWeek,
        day: 2,
        order: 0,
        kind: CalendarEventKind.automatic,
      ),
      CalendarEventSlot(
        id: CalendarEventId.retirements,
        week: awardsWeek,
        day: 3,
        order: 0,
        kind: CalendarEventKind.informational,
      ),
      CalendarEventSlot(
        id: CalendarEventId.lottery,
        week: awardsWeek,
        day: 5,
        order: 0,
        kind: CalendarEventKind.playerAction,
      ),
      CalendarEventSlot(
        id: CalendarEventId.tradeWindowOpen,
        week: calendar.tradeWindowOpenWeek,
        day: 1,
        order: -1,
        kind: CalendarEventKind.automatic,
      ),
      CalendarEventSlot(
        id: CalendarEventId.scoutReport,
        week: scoutWeek,
        day: 1,
        order: 0,
        kind: CalendarEventKind.playerAction,
      ),
      CalendarEventSlot(
        id: CalendarEventId.combine,
        week: scoutWeek,
        day: 3,
        order: 0,
        kind: CalendarEventKind.automatic,
      ),
      CalendarEventSlot(
        id: CalendarEventId.finalMock,
        week: scoutWeek,
        day: 5,
        order: 0,
        kind: CalendarEventKind.automatic,
      ),
      CalendarEventSlot(
        id: CalendarEventId.draft,
        week: calendar.draftWeek,
        day: 1,
        order: 0,
        kind: CalendarEventKind.playerAction,
      ),
      CalendarEventSlot(
        id: CalendarEventId.nextClassGeneration,
        week: calendar.draftWeek,
        day: 1,
        order: 1,
        kind: CalendarEventKind.playerAction,
      ),
      CalendarEventSlot(
        id: CalendarEventId.tradeDeadline,
        week: calendar.tradeDeadlineWeek,
        day: 1,
        order: 0,
        kind: CalendarEventKind.informational,
      ),
      CalendarEventSlot(
        id: CalendarEventId.freeAgencyOpen,
        week: calendar.freeAgencyWeek,
        day: 1,
        order: 0,
        kind: CalendarEventKind.playerAction,
      ),
    ];
  }

  /// Builds ranges that are intentionally not actionable point events.
  static List<CalendarEventWindow> buildWindows(CalendarBalance calendar) {
    return [
      CalendarEventWindow(
        id: CalendarEventId.tradeWindowOpen,
        startWeek: calendar.tradeWindowOpenWeek,
        startDay: 1,
        endWeek: calendar.tradeDeadlineWeek,
        endDay: 1,
        kind: CalendarEventKind.automatic,
        wrapsYear: true,
      ),
      CalendarEventWindow(
        id: CalendarEventId.contractExtensions,
        startWeek: calendar.draftWeek,
        startDay: 2,
        endWeek: calendar.draftWeek,
        endDay: 7,
        kind: CalendarEventKind.playerAction,
      ),
      CalendarEventWindow(
        id: CalendarEventId.freeAgencyOpen,
        startWeek: calendar.freeAgencyWeek,
        startDay: 1,
        endWeek: calendar.seasonCycleWeeks,
        endDay: 7,
        kind: CalendarEventKind.playerAction,
      ),
    ];
  }

  /// Czy akcja przypisana do [id] została już wykonana w bieżącym sezonie.
  static bool isDone(Season season, CalendarEventId id) {
    switch (id) {
      case CalendarEventId.staffGrowth:
        return season.staffGrowthDone;
      case CalendarEventId.awards:
        return season.awards != null;
      case CalendarEventId.retirements:
        return season.playerRetirementsDone;
      case CalendarEventId.lottery:
        return (season.draftState?.lotteryResults.isNotEmpty) ?? false;
      case CalendarEventId.scoutReport:
        return season.scoutReportDone;
      case CalendarEventId.combine:
        return season.combineDone;
      case CalendarEventId.finalMock:
        return season.finalMockDone;
      case CalendarEventId.draft:
        final draft = season.draftState;
        return draft != null && draft.currentPickIndex >= draft.order.length;
      case CalendarEventId.nextClassGeneration:
        return season.nextDraftState != null;
      case CalendarEventId.tradeWindowOpen:
      case CalendarEventId.contractExtensions:
        // These are derived ranges, not one-shot stateful events.
        return true;
      case CalendarEventId.tradeDeadline:
        return season.tradeDeadlineAcked;
      case CalendarEventId.freeAgencyOpen:
        return season.faOpenDone;
    }
  }

  /// Normalizuje tydzień slotu względem bieżącej daty, zawijając do
  /// kolejnego roku gdy (week, day, order) slotu wypada w przeszłości
  /// względem (fromWeek, fromDay, fromOrder).
  static int _normalizedWeek(
    CalendarEventSlot slot,
    int fromWeek,
    int fromDay,
    int fromOrder,
    int cycleWeeks,
  ) {
    final isPast =
        slot.week < fromWeek ||
        (slot.week == fromWeek &&
            (slot.day < fromDay ||
                (slot.day == fromDay && slot.order < fromOrder)));
    return isPast ? slot.week + cycleWeeks : slot.week;
  }

  /// Zwraca najbliższy nieukończony slot kalendarzowy od bieżącej daty
  /// (włącznie), porównując (week, day, order) leksykograficznie, z
  /// zawijaniem do kolejnego roku. Zwraca null jeśli wszystkie sloty
  /// w rejestrze są już done (nie powinno się zdarzyć w praniu bieżącej gry).
  ///
  /// Nie uwzględnia jeszcze priorytetu meczu gracza — patrz TODO w
  /// `GameController.nextEvent()`, który scala ten wynik z najbliższym
  /// meczem gracza (wymaga mapowania round → week/day ze
  /// `schedule_generator.dart`, jeszcze nieprzeanalizowanego).
  static CalendarEventSlot? nextEvent(
    LeagueState league, {
    BalanceConfig balance = BalanceConfig.defaults,
  }) {
    final season = league.currentSeason;
    final fromWeek = league.currentWeek;
    final fromDay = league.currentDay;
    const fromOrder = 0;

    final candidates = build(
      balance.calendar,
    ).where((slot) => !isDone(season, slot.id)).toList();
    if (candidates.isEmpty) return null;

    candidates.sort((a, b) {
      final wa = _normalizedWeek(
        a,
        fromWeek,
        fromDay,
        fromOrder,
        balance.calendar.seasonCycleWeeks,
      );
      final wb = _normalizedWeek(
        b,
        fromWeek,
        fromDay,
        fromOrder,
        balance.calendar.seasonCycleWeeks,
      );
      if (wa != wb) return wa.compareTo(wb);
      if (a.day != b.day) return a.day.compareTo(b.day);
      return a.order.compareTo(b.order);
    });
    return candidates.first;
  }
}
