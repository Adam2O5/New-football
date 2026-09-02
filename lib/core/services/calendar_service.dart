import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/schedule_generator.dart';

/// Canonical season calendar helpers (`docs/game_calendar.md`).
class CalendarService {
  const CalendarService({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  CalendarBalance get _c => balance.calendar;

  SeasonPhase phaseForWeek(int week) {
    if (week < 1) {
      return SeasonPhase.preseason;
    }
    if (week <= _c.regularSeasonWeeks) {
      return SeasonPhase.regular;
    }
    if (week == _c.breakWeek) {
      return SeasonPhase.regular; // break before play-in
    }
    if (week == _c.playInWeek) return SeasonPhase.playIn;
    if (week >= _c.playoffStartWeek && week <= _c.playoffEndWeek) {
      return SeasonPhase.playoff;
    }
    // Tydzień draftu (46) należy do offseason — `game_calendar.md` definiuje
    // dokładnie 5 faz: preseason → regular → playIn → playoff → offseason.
    return SeasonPhase.offseason;
  }

  bool isRegularSeasonWeek(int week) =>
      week >= 1 && week <= _c.regularSeasonWeeks;

  bool isBreakWeek(int week) => week == _c.breakWeek;

  /// Contract extensions run Tuesday–Sunday of draft week.
  bool isContractExtensionWindow(int week, int day) =>
      week == _c.draftWeek && day >= 2 && day <= 7;

  /// Free agency phase I is the ten-slot hourly window in week 47.
  bool isFreeAgencyPhaseI(int week, [int day = 1]) =>
      week == _c.freeAgencyWeek && day >= 1 && day <= 7;

  /// Free agency phase II wraps around the season boundary: it starts on
  /// Monday of week 48 and ends on Sunday of week 45. Week 46 Monday is the
  /// draft/buffer day and is intentionally closed.
  bool isFreeAgencyPhaseII(int week, [int day = 1]) {
    if (day < 1 ||
        day > 7 ||
        week == _c.draftWeek ||
        week == _c.freeAgencyWeek) {
      return false;
    }
    return (week > _c.freeAgencyWeek && week <= _c.seasonCycleWeeks) ||
        (week >= 1 && week <= _c.freeAgencyPhaseIIEndWeek);
  }

  /// True when any contract market window accepts a submission on the date.
  bool isActiveContractWindow(int week, int day) =>
      isContractExtensionWindow(week, day) ||
      isFreeAgencyPhaseI(week, day) ||
      isFreeAgencyPhaseII(week, day);

  /// Hourly mode is limited to extensions and FA phase I. FA phase II is a
  /// daily/unlimited market and therefore deliberately returns false here.
  bool isHourlyContractMode(int week, int day) =>
      isContractExtensionWindow(week, day) || isFreeAgencyPhaseI(week, day);

  int? initialHourForDate(int week, int day) =>
      isHourlyContractMode(week, day) ? 1 : null;

  int hoursForDate(int week, int day) =>
      isHourlyContractMode(week, day) ? balance.contracts.hoursPerDay : 0;

  bool isLastHour(int week, int day, int hour) =>
      isHourlyContractMode(week, day) && hour >= hoursForDate(week, day);

  bool isTradeDeadline(int week, int day) =>
      week == _c.tradeDeadlineWeek && day == 1;

  bool isTradeWindowOpen(int week, {int day = 1}) {
    // Open from week 44 until the week 23 deadline, which closes the window
    // at the start of deadline day. The optional day keeps old callers valid.
    if (week >= _c.tradeWindowOpenWeek) return true;
    if (week < _c.tradeDeadlineWeek) return true;
    if (week == _c.tradeDeadlineWeek) return false;
    return false;
  }

  /// Days that can host regular-season fixtures: Wed/Thu (slot 0), Sat/Sun (slot 1).
  int? regularSeasonSlotForDay(int day) {
    if (day == 3 || day == 4) return 0;
    if (day == 6 || day == 7) return 1;
    return null;
  }

  /// True only for the deterministic, actual match day picked for a given week.
  bool isActualMatchDay(int week, int day, {int seed = 0}) {
    if (!isRegularSeasonWeek(week)) return false;

    final slot = regularSeasonSlotForDay(day);
    if (slot == null) return false;

    final matchDays = matchDaysForWeek(week, seed: seed);
    return switch (slot) {
      0 => day == matchDays.midweekDay,
      1 => day == matchDays.weekendDay,
      _ => false,
    };
  }

  /// Returns all play-in slots for a date. Wednesday hosts two games and
  /// Saturday hosts the deciding game for each conference.
  List<int> playInSlotsForDay(int week, int day) {
    if (week != _c.playInWeek) return const [];
    return switch (day) {
      3 => const [0, 1],
      6 => const [2],
      _ => const [],
    };
  }

  /// Backwards-compatible single-slot view of the play-in calendar.
  /// Wednesday returns its first slot; Saturday returns slot 2.
  int? playInSlotForDay(int week, int day) {
    final slots = playInSlotsForDay(week, day);
    return slots.isEmpty ? null : slots.first;
  }

  /// The six calendar slots (2/week × 3 weeks) available to playoff [round]
  /// (1 = quarterfinals … 4 = league final), in chronological order — the
  /// single source of truth for both "which dates can a series' games land
  /// on" (`SeasonService` eagerly schedules fixtures from this) and "is this
  /// (week, day) a valid postseason slot" ([postseasonSlotForDay]). Sharing
  /// one source keeps the fixtures shown on the calendar and the days the
  /// simulation actually plays on from ever drifting apart.
  ///
  /// Like the regular season, the exact midweek/weekend day varies per week
  /// via [matchDaysForWeek] — unlike play-in, which `game_calendar.md` fixes
  /// to Wednesday/Saturday, playoff match days get the same week-to-week
  /// variety as the regular season.
  List<(int week, int day)> playoffRoundSlotDates(int round, {int seed = 0}) {
    final startWeek = _c.playoffStartWeek + (round - 1) * 3;
    final dates = <(int, int)>[];
    for (var w = startWeek; w < startWeek + 3; w++) {
      final days = matchDaysForWeek(w, seed: seed);
      dates.add((w, days.midweekDay));
      dates.add((w, days.weekendDay));
    }
    return dates;
  }

  /// True only if (week, day) is one of the six slots [playoffRoundSlotDates]
  /// assigns to that week's round — the sole gate `advancePlayoffsForDate`
  /// uses (no second, week-specific narrowing like [isActualMatchDay] does
  /// for the regular season), so it must already be day-exact.
  int? postseasonSlotForDay(int week, int day, {int seed = 0}) {
    final round = playoffRoundForWeek(week);
    if (round == null) return null;
    final dates = playoffRoundSlotDates(round, seed: seed);
    final index = dates.indexWhere((d) => d.$1 == week && d.$2 == day);
    if (index == -1) return null;
    return index.isEven ? 0 : 1;
  }

  /// Playoff round block: conference quarter-finals, semi-finals,
  /// conference finals, then league final.
  int? playoffRoundForWeek(int week) {
    if (week < _c.playoffStartWeek || week > _c.playoffEndWeek) {
      return null;
    }
    final offset = week - _c.playoffStartWeek;
    return offset ~/ 3 + 1;
  }

  /// Home-team pattern for BO5 format 1-2-2 (game index is zero-based).
  bool higherSeedHomeForGame(int gameIndex) => gameIndex == 0 || gameIndex >= 3;

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

  /// Advance one day and wrap to week 1 after the configured calendar cycle.
  /// The controller is responsible for calling `rolloverSeason` at this
  /// boundary; this helper only owns the date arithmetic.
  (int week, int day) advanceDay(int week, int day) {
    if (day < 7) return (week, day + 1);
    if (week >= _c.seasonCycleWeeks) return (1, 1);
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
      case SeasonPhase.offseason:
        return (_c.seasonCycleWeeks, 7);
    }
  }

  /// All registered calendar events falling exactly on (week, day),
  /// regardless of whether they've already resolved this season. Used by
  /// the UI to render event labels on the calendar grid. Single source of
  /// truth: `CalendarEventRegistry` (`docs/game_calendar.md`).
  List<CalendarEventSlot> eventsOn(int week, int day) {
    final events = CalendarEventRegistry.build(
      _c,
    ).where((event) => event.week == week && event.day == day).toList();
    events.sort((a, b) => a.order.compareTo(b.order));
    return events;
  }

  /// All registered event windows containing (week, day). Windows are kept
  /// separate from [eventsOn] so existing point-event consumers remain
  /// source-compatible.
  List<CalendarEventWindow> windowsOn(int week, int day) {
    return CalendarEventRegistry.buildWindows(_c)
        .where((window) => window.contains(week, day, _c.seasonCycleWeeks))
        .toList();
  }
}
