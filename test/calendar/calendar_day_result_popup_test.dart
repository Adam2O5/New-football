@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/models/calendar_simulation_feedback.dart';
import 'package:new_football/app/widgets/calendar_day_result_popup.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

void main() {
  testWidgets(
    'renders one bounded popup with every result and stable row keys',
    (tester) async {
      final feedback = _day(
        runId: 7,
        sequence: 3,
        results: [
          _match(
            id: 'match-1',
            position: 0,
            home: 'North London United',
            away: 'South Coast City',
            homeGoals: 2,
            awayGoals: 1,
          ),
          _match(
            id: 'match-2',
            position: 1,
            home: 'Riverside Athletic',
            away: 'Old Town Rovers',
            homeGoals: 0,
            awayGoals: 3,
          ),
        ],
      );

      await tester.pumpWidget(
        _app(CalendarDayResultPopup(feedback: feedback, teamId: 'team-1')),
      );
      await tester.pump();

      final popupKey = const ValueKey<String>('calendar-day-result-popup-7-3');
      expect(find.byKey(popupKey), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('calendar-day-result-row-7-3-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('calendar-day-result-row-7-3-1')),
        findsOneWidget,
      );
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text('Match results · Week 4, day 2'), findsOneWidget);
      expect(find.text('North London United'), findsOneWidget);
      expect(find.text('South Coast City'), findsOneWidget);
      expect(find.text('2:1'), findsOneWidget);
      expect(find.text('Riverside Athletic'), findsOneWidget);
      expect(find.text('Old Town Rovers'), findsOneWidget);
      expect(find.text('0:3'), findsOneWidget);
      for (final result in feedback.results) {
        final accessibleResult =
            '${result.homeTeamName} ${result.homeGoals}:${result.awayGoals} '
            '${result.awayTeamName}';
        expect(find.byTooltip(accessibleResult), findsOneWidget);
        expect(find.bySemanticsLabel(accessibleResult), findsOneWidget);
      }

      // The popup has no row-level timer or delay and is therefore still
      // present when time is advanced by the test harness.
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(popupKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('an empty completed day does not create a result popup', (
    tester,
  ) async {
    final feedback = _day(runId: 1, sequence: 0, results: const []);

    await tester.pumpWidget(
      _app(CalendarDayResultPopup(feedback: feedback, teamId: 'team-1')),
    );
    await tester.pump();

    expect(find.byType(Card), findsNothing);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.byType(Scrollable), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'wraps long names in bounded scrollable content on a small viewport',
    (tester) async {
      addTearDown(tester.view.reset);
      tester.view.physicalSize = const Size(320, 220);
      tester.view.devicePixelRatio = 1;

      final feedback = _day(
        runId: 12,
        sequence: 5,
        results: [
          for (var index = 0; index < 8; index++)
            _match(
              id: 'long-$index',
              position: index,
              home:
                  'Very Long Home Club Name ${index + 1} With A Descriptive Suffix',
              away:
                  'Very Long Away Club Name ${index + 1} With A Descriptive Suffix',
              homeGoals: index % 4,
              awayGoals: (index + 1) % 4,
            ),
        ],
      );

      await tester.pumpWidget(
        _app(CalendarDayResultPopup(feedback: feedback, teamId: 'team-1')),
      );
      await tester.pump();

      final popup = find.byKey(
        const ValueKey<String>('calendar-day-result-popup-12-5'),
      );
      final popupRect = tester.getRect(popup);
      const viewport = Rect.fromLTWH(0, 0, 320, 220);

      expect(viewport.contains(popupRect.topLeft), isTrue);
      expect(viewport.contains(popupRect.bottomRight), isTrue);
      expect(popupRect.width, lessThanOrEqualTo(320));
      expect(popupRect.height, lessThanOrEqualTo(220));
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('calendar-day-result-row-12-5-7')),
        findsOneWidget,
      );
      for (var index = 0; index < 8; index++) {
        expect(
          find.text(
            'Very Long Home Club Name ${index + 1} '
            'With A Descriptive Suffix',
          ),
          findsOneWidget,
        );
        expect(
          find.text(
            'Very Long Away Club Name ${index + 1} '
            'With A Descriptive Suffix',
          ),
          findsOneWidget,
        );
      }
      expect(tester.takeException(), isNull);

      await tester.drag(
        find.byKey(const ValueKey<String>('calendar-day-result-scroll-12-5')),
        const Offset(0, -150),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('keeps full names in localized tooltip and semantics labels', (
    tester,
  ) async {
    final feedback = _day(
      runId: 2,
      sequence: 4,
      week: 9,
      day: 6,
      results: [
        _match(
          id: 'semantic-match',
          position: 0,
          home: 'Gospodarze Z Bardzo Długą Nazwą',
          away: 'Goście Z Bardzo Długą Nazwą',
          homeGoals: 4,
          awayGoals: 2,
        ),
      ],
    );

    await tester.pumpWidget(
      _app(
        CalendarDayResultPopup(feedback: feedback, teamId: 'team-1'),
        locale: const Locale('pl'),
      ),
    );
    await tester.pump();

    const accessibleResult =
        'Gospodarze Z Bardzo Długą Nazwą 4:2 Goście Z Bardzo Długą Nazwą';
    expect(find.text('Wyniki meczów · tydzień 9, dzień 6'), findsOneWidget);
    expect(find.byTooltip(accessibleResult), findsOneWidget);
    expect(find.bySemanticsLabel(accessibleResult), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

CalendarDaySimulationFeedback _day({
  required int runId,
  required int sequence,
  required List<CalendarMatchFeedback> results,
  int week = 4,
  int day = 2,
}) {
  return CalendarDaySimulationFeedback(
    runId: runId,
    sequence: sequence,
    week: week,
    day: day,
    results: results,
  );
}

CalendarMatchFeedback _match({
  required String id,
  required int position,
  required String home,
  required String away,
  required int homeGoals,
  required int awayGoals,
}) {
  return CalendarMatchFeedback(
    matchId: id,
    homeTeamId: '$id-home',
    homeTeamName: home,
    awayTeamId: '$id-away',
    awayTeamName: away,
    homeGoals: homeGoals,
    awayGoals: awayGoals,
    schedulePosition: position,
  );
}

Widget _app(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}
