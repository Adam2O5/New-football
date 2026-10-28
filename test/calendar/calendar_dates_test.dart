import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/services/calendar_service.dart';

void main() {
  const calendar = CalendarService();
  test('date mapping covers all 364 days, leap years and cycle boundaries', () {
    for (final year in [2026, 2027, 2028, 2031]) {
      final start = calendar.week1StartForSeason(year);
      for (var week = 1; week <= 52; week++) {
        for (var day = 1; day <= 7; day++) {
          final civilDate = DateTime(
            start.year,
            start.month,
            start.day + (week - 1) * 7 + day - 1,
          );
          expect(
            calendar.dateForWeekDay(year, week, day),
            civilDate,
            reason: 'Civil date for season $year, week $week, day $day',
          );
          expect(
            calendar.weekDayForDate(
              DateTime.utc(civilDate.year, civilDate.month, civilDate.day),
              year,
            ),
            (week: week, day: day),
          );
          expect(calendar.weekDayForDate(civilDate, year), (
            week: week,
            day: day,
          ));
          expect(
            calendar.weekDayForDate(
              DateTime(civilDate.year, civilDate.month, civilDate.day, 23, 59),
              year,
            ),
            (week: week, day: day),
          );
        }
      }
      expect(
        calendar.weekDayForDate(
          calendar.dateForWeekDay(year, 1, 1).subtract(const Duration(days: 1)),
          year,
        ),
        isNull,
      );
      expect(
        calendar.weekDayForDate(
          calendar.dateForWeekDay(year, 52, 7).add(const Duration(days: 1)),
          year,
        ),
        isNull,
      );
      expect(calendar.advanceDay(52, 7), (1, 1));
      expect(
        calendar.weekDayForDate(
          calendar.dateForWeekDay(year + 1, 1, 1),
          year + 1,
        ),
        (week: 1, day: 1),
      );
    }
  });
}
