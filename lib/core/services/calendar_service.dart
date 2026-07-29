import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';

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

  /// All registered calendar events falling exactly on (week, day),
  /// regardless of whether they've already resolved this season. Used by
  /// the UI to render event labels on the calendar grid. Single source of
  /// truth: `CalendarEventRegistry` (`docs/game_calendar.md`).
  List<CalendarEventSlot> eventsOn(int week, int day) {
    return CalendarEventRegistry.build(
      _c,
    ).where((e) => e.week == week && e.day == day).toList();
  }
}
