import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/league_state.dart';

enum CalendarEventKind { match, playerAction, automatic, informational }

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
        id: 'staffGrowth',
        week: awardsWeek,
        day: 1,
        order: 0,
        kind: CalendarEventKind.automatic,
      ),
      CalendarEventSlot(
        id: 'awards',
        week: awardsWeek,
        day: 1,
        order: 1,
        kind: CalendarEventKind.informational,
      ),
      CalendarEventSlot(
        id: 'retirements',
        week: awardsWeek,
        day: 3,
        order: 0,
        kind: CalendarEventKind.informational,
      ),
      CalendarEventSlot(
        id: 'lottery',
        week: awardsWeek,
        day: 5,
        order: 0,
        kind: CalendarEventKind.informational,
      ),
      CalendarEventSlot(
        id: 'scoutReport',
        week: scoutWeek,
        day: 1,
        order: 0,
        kind: CalendarEventKind.playerAction,
      ),
      CalendarEventSlot(
        id: 'combine',
        week: scoutWeek,
        day: 3,
        order: 0,
        kind: CalendarEventKind.automatic,
      ),
      CalendarEventSlot(
        id: 'finalMock',
        week: scoutWeek,
        day: 5,
        order: 0,
        kind: CalendarEventKind.automatic,
      ),
      CalendarEventSlot(
        id: 'draft',
        week: calendar.draftWeek,
        day: 1,
        order: 0,
        kind: CalendarEventKind.playerAction,
      ),
      CalendarEventSlot(
        id: 'nextClassGeneration',
        week: calendar.draftWeek,
        day: 1,
        order: 1,
        kind: CalendarEventKind.playerAction,
      ),
      CalendarEventSlot(
        id: 'tradeDeadline',
        week: calendar.tradeDeadlineWeek,
        day: 1,
        order: 0,
        kind: CalendarEventKind.informational,
      ),
      CalendarEventSlot(
        id: 'freeAgencyOpen',
        week: calendar.freeAgencyWeek,
        day: 1,
        order: 0,
        kind: CalendarEventKind.playerAction,
      ),
    ];
  }

  /// Czy akcja przypisana do [id] została już wykonana w bieżącym sezonie.
  static bool isDone(Season season, String id) {
    switch (id) {
      case 'staffGrowth':
        return season.staffGrowthDone;
      case 'awards':
        return season.awards != null;
      case 'retirements':
        return season.playerRetirementsDone;
      case 'lottery':
        return (season.draftState?.lotteryResults.isNotEmpty) ?? false;
      case 'scoutReport':
        return season.scoutReportDone;
      case 'combine':
        return season.combineDone;
      case 'finalMock':
        return season.finalMockDone;
      case 'draft':
        final draft = season.draftState;
        return draft != null && draft.currentPickIndex >= draft.order.length;
      case 'nextClassGeneration':
        return season.nextDraftState != null;
      case 'tradeDeadline':
        return season.tradeDeadlineAcked;
      case 'freeAgencyOpen':
        return season.faOpenDone;
      default:
        throw ArgumentError.value(id, 'id', 'Unknown calendar event slot id');
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
