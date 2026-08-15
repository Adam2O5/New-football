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
  });

  final CalendarEventId id;
  final int week;
  final int day;
  final int order;
  final CalendarEventKind kind;
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
        id: CalendarEventId.staffGrowth,
        week: awardsWeek,
        day: 1,
        order: 0,
        kind: CalendarEventKind.automatic,
      ),
      CalendarEventSlot(
        id: CalendarEventId.awards,
        week: awardsWeek,
        day: 1,
        order: 1,
        kind: CalendarEventKind.informational,
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
  ) {
    final isPast =
        slot.week < fromWeek ||
        (slot.week == fromWeek &&
            (slot.day < fromDay ||
                (slot.day == fromDay && slot.order < fromOrder)));
    return isPast ? slot.week + 52 : slot.week;
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
      final wa = _normalizedWeek(a, fromWeek, fromDay, fromOrder);
      final wb = _normalizedWeek(b, fromWeek, fromDay, fromOrder);
      if (wa != wb) return wa.compareTo(wb);
      if (a.day != b.day) return a.day.compareTo(b.day);
      return a.order.compareTo(b.order);
    });
    return candidates.first;
  }
}
