import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';

/// Canonical season calendar helpers (`docs/game_calendar.md`).
class CalendarService {
  const CalendarService({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  CalendarBalance get _c => balance.calendar;

  SeasonPhase phaseForWeek(int week) {
    if (week < 1) return SeasonPhase.preseason;
    if (week <= _c.regularSeasonWeeks) return SeasonPhase.regular;
    if (week == 30) return SeasonPhase.regular; // break before play-in
    if (week == _c.playInWeek) return SeasonPhase.playIn;
    if (week >= _c.playoffStartWeek && week <= _c.playoffEndWeek) {
      return SeasonPhase.playoff;
    }
    if (week == _c.draftWeek) return SeasonPhase.draft;
    return SeasonPhase.offseason;
  }

  bool isRegularSeasonWeek(int week) =>
      week >= 1 && week <= _c.regularSeasonWeeks;

  bool isBreakWeek(int week) => week == 30;

  bool isTradeDeadline(int week, int day) =>
      week == _c.tradeDeadlineWeek && day == 1;

  bool isTradeWindowOpen(int week) {
    // Open from week 44 until deadline Monday of week 23 (wraps seasons).
    if (week >= _c.tradeWindowOpenWeek) return true;
    if (week < _c.tradeDeadlineWeek) return true;
    if (week == _c.tradeDeadlineWeek) return false; // closed after Mon
    return false;
  }

  /// Days that can host regular-season fixtures: Wed/Thu (slot 0), Sat/Sun (slot 1).
  int? regularSeasonSlotForDay(int day) {
    if (day == 3 || day == 4) return 0;
    if (day == 6 || day == 7) return 1;
    return null;
  }

  String dayName(int day) {
    const names = [
      '',
      'Poniedziałek',
      'Wtorek',
      'Środa',
      'Czwartek',
      'Piątek',
      'Sobota',
      'Niedziela',
    ];
    if (day < 1 || day > 7) return 'Dzień $day';
    return names[day];
  }

  /// Advance one day. Returns (week, day).
  (int week, int day) advanceDay(int week, int day) {
    if (day < 7) return (week, day + 1);
    return (week + 1, 1);
  }

  /// True if (week, day) is at or past (targetWeek, targetDay).
  bool isAtOrAfter(int week, int day, int targetWeek, int targetDay) {
    if (week != targetWeek) return week > targetWeek;
    return day >= targetDay;
  }

  /// Last (week, day) belonging to [phase], per `docs/game_calendar.md`.
  /// For phases that repeat/wrap (offseason), returns the last week before
  /// the season rolls over.
  (int week, int day) endOfPhase(SeasonPhase phase) {
    switch (phase) {
      case SeasonPhase.preseason:
        return (0, 7);
      case SeasonPhase.regular:
        return (_c.regularSeasonWeeks, 7);
      case SeasonPhase.playIn:
        return (_c.playInWeek, 7);
      case SeasonPhase.playoff:
        return (_c.playoffEndWeek, 7);
      case SeasonPhase.draft:
        return (_c.draftWeek, 7);
      case SeasonPhase.offseason:
        return (_c.freeAgencyWeek, 7);
    }
  }

  // ---------------------------------------------------------------------
  // Event registry (krok 1 + krok 5)
  // ---------------------------------------------------------------------

  /// Non-interactive vs. player-facing calendar events.
  List<CalendarEventSlot> _registry() {
    final week44 = _c.awardsWeek;
    final week45 = week44 + 1;
    final week46 = _c.draftWeek;
    final week47 = _c.freeAgencyWeek;
    return [
      CalendarEventSlot(
        id: 'staffGrowth',
        week: week44,
        day: 1,
        order: 0,
        kind: CalendarEventKind.automatic,
      ),
      CalendarEventSlot(
        id: 'retirements',
        week: week44,
        day: 1,
        order: 1,
        kind: CalendarEventKind.automatic,
      ),
      CalendarEventSlot(
        id: 'awards',
        week: week44,
        day: 1,
        order: 2,
        kind: CalendarEventKind.informational,
      ),
      CalendarEventSlot(
        id: 'lottery',
        week: week44,
        day: 1,
        order: 3,
        kind: CalendarEventKind.informational,
      ),
      CalendarEventSlot(
        id: 'scoutReport',
        week: week45,
        day: 1,
        order: 0,
        kind: CalendarEventKind.automatic,
      ),
      CalendarEventSlot(
        id: 'combine',
        week: week45,
        day: 3,
        order: 0,
        kind: CalendarEventKind.automatic,
      ),
      CalendarEventSlot(
        id: 'finalMock',
        week: week45,
        day: 5,
        order: 0,
        kind: CalendarEventKind.automatic,
      ),
      CalendarEventSlot(
        id: 'nextClassGeneration',
        week: week46,
        day: 1,
        order: 0,
        kind: CalendarEventKind.automatic,
      ),
      CalendarEventSlot(
        id: 'draft',
        week: week46,
        day: 1,
        order: 1,
        kind: CalendarEventKind.playerAction,
      ),
      CalendarEventSlot(
        id: 'freeAgencyOpen',
        week: week47,
        day: 1,
        order: 0,
        kind: CalendarEventKind.informational,
      ),
      CalendarEventSlot(
        id: 'tradeDeadline',
        week: _c.tradeDeadlineWeek,
        day: 1,
        order: 0,
        kind: CalendarEventKind.informational,
      ),
    ];
  }

  /// All registered calendar events falling exactly on (week, day),
  /// regardless of whether they've already resolved this season. Used by
  /// the UI to render event labels on the calendar grid.
  List<CalendarEventSlot> eventsOn(int week, int day) {
    return _registry().where((e) => e.week == week && e.day == day).toList();
  }

  /// Returns the next unresolved event at or after (week, day), or null if
  /// none remain registered ahead (caller should fall back to phase-end /
  /// rollover logic). `isDone` decides whether a slot has already fired
  /// this season, per the flags on `Season`.
  CalendarEventSlot? nextEvent(
    int week,
    int day,
    bool Function(String id) isDone,
  ) {
    final ahead =
        _registry().where((e) => !isDone(e.id)).where((e) {
          if (e.week != week) return e.week > week;
          return e.day >= day;
        }).toList()..sort((a, b) {
          final byWeek = a.week.compareTo(b.week);
          if (byWeek != 0) return byWeek;
          final byDay = a.day.compareTo(b.day);
          if (byDay != 0) return byDay;
          return a.order.compareTo(b.order);
        });
    if (ahead.isEmpty) return null;
    return ahead.first;
  }
}

/// Whether a calendar event resolves itself or needs player input.
enum CalendarEventKind { automatic, informational, playerAction }

/// A single scheduled slot in the offseason event registry.
class CalendarEventSlot {
  const CalendarEventSlot({
    required this.id,
    required this.week,
    required this.day,
    required this.order,
    required this.kind,
  });

  final String id;
  final int week;
  final int day;

  /// Tie-breaker for multiple events on the same (week, day).
  final int order;
  final CalendarEventKind kind;
}
