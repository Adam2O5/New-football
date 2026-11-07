import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';

void main() {
  const clock = CalendarService();

  test(
    'configured event dates drive registration and market gates together',
    () {
      const custom = CalendarService(
        balance: BalanceConfig(
          calendar: CalendarBalance(
            awardsDay: 2,
            scoutWeekOffset: 2,
            combineDay: 4,
            tradeWindowOpenDay: 3,
            tradeDeadlineDay: 4,
            freeAgencyOpenDay: 2,
            contractExtensionStartDay: 3,
          ),
        ),
      );
      expect(custom.eventsOn(44, 2).first.id, CalendarEventId.capUpdateTv);
      expect(
        custom.eventsOn(44, 2).map((e) => e.id),
        contains(CalendarEventId.awards),
      );
      expect(
        custom.eventsOn(46, 4).map((e) => e.id),
        contains(CalendarEventId.combine),
      );
      expect(custom.isTradeWindowOpen(44, day: 2), isFalse);
      expect(custom.isTradeWindowOpen(44, day: 3), isTrue);
      expect(custom.isTradeWindowOpen(23, day: 3), isTrue);
      expect(custom.isTradeWindowOpen(23, day: 4), isFalse);
      expect(custom.isTradeDeadline(23, 4), isTrue);
      expect(custom.tradeOfferDeadline(2027, 23, 2, 2), (2027, 23, 4, 0));
      expect(custom.isFreeAgencyPhaseI(47, 1), isFalse);
      expect(custom.isFreeAgencyPhaseI(47, 2), isTrue);
      expect(custom.isContractExtensionWindow(46, 2), isFalse);
      expect(custom.isContractExtensionWindow(46, 3), isTrue);
      expect(
        custom
            .windowsOn(44, 2)
            .where((e) => e.id == CalendarEventId.tradeWindowOpen),
        isEmpty,
      );
      expect(
        custom.windowsOn(44, 3).map((e) => e.id),
        contains(CalendarEventId.tradeWindowOpen),
      );
    },
  );

  test('logical rollover skips the civil gap between August anchors', () {
    expect(clock.week1StartForSeason(2027), DateTime(2027, 8, 2));
    expect(clock.week1StartForSeason(2028), DateTime(2028, 8, 7));
    expect(clock.dateTimeForMoment(2027, 52, 7), DateTime.utc(2028, 7, 30));
    expect(clock.addDays(2027, 52, 7, 2, 1), (2028, 1, 1, 2));
    expect(clock.dateAfterDays(2027, 52, 7, 1, 2), DateTime.utc(2028, 8, 7, 2));
    expect(clock.addDays(2028, 1, 1, 0, -1), (2027, 52, 7, 0));
    expect(clock.weekDayForDate(DateTime(2028, 8, 1), 2027), isNull);
    expect(clock.dayIndex(2028, 1, 1) - clock.dayIndex(2027, 52, 7), 1);
    expect(clock.weekIndex(2028, 1) - clock.weekIndex(2027, 52), 1);
  });

  test('civil year does not replace the explicit season year', () {
    final january = clock.dateTimeForMoment(2027, 23, 1);
    expect(january.year, 2028);
    expect(clock.weekDayForDate(january, 2027), (week: 23, day: 1));
    expect(clock.weekDayForDate(january, 2028), isNull);
  });

  test(
    'last market slot and next day zero are distinct consecutive instants',
    () {
      expect(
        clock.momentIndex(2028, 1, 1),
        clock.momentIndex(2027, 52, 7, 10) + 1,
      );
      const shortDay = CalendarService(
        balance: BalanceConfig(contracts: ContractNegBalance(hoursPerDay: 2)),
      );
      expect(
        shortDay.momentIndex(2028, 1, 1),
        shortDay.momentIndex(2027, 52, 7, 2) + 1,
      );
    },
  );

  test(
    'offer expiry is seven logical days and is capped by trade deadline',
    () {
      expect(clock.tradeOfferDeadline(2027, 52, 7, 2), (2028, 1, 7, 2));
      expect(clock.tradeOfferDeadline(2027, 22, 7, 10), (2027, 23, 1, 0));
      const custom = CalendarService(
        balance: BalanceConfig(
          calendar: CalendarBalance(tradeDeadlineWeek: 24),
          messages: MessagesBalance(tradeOfferExpiryDays: 3),
        ),
      );
      expect(custom.tradeOfferDeadline(2027, 22, 7, 2), (2027, 23, 3, 2));
      expect(custom.tradeOfferDeadline(2027, 23, 7, 2), (2027, 24, 1, 0));
    },
  );

  test('adding logical days round-trips across leap and ordinary seasons', () {
    for (final year in [2026, 2027, 2028, 2031]) {
      for (final day in [0, 1, 6, 7, 180, 363, 364, 365, 728]) {
        final next = clock.addDays(year, 1, 1, 0, day);
        expect(
          clock.dayIndex(next.$1, next.$2, next.$3),
          clock.dayIndex(year, 1, 1) + day,
        );
        final projected = clock.dateTimeForMoment(next.$1, next.$2, next.$3);
        expect(clock.weekDayForDate(projected, next.$1), (
          week: next.$2,
          day: next.$3,
        ));
      }
    }
  });
}
