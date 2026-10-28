@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/models/calendar_simulation_feedback.dart';
import 'package:new_football/app/widgets/calendar_day_result_popup.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

void main() {
  for (final locale in [const Locale('pl'), const Locale('en')]) {
    testWidgets(
      'only the player match is shown with localized semantics ($locale)',
      (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          final own = _match('ours', 'opponent', 2, 1);
          final other = _match('unrelated-home', 'unrelated-away', 0, 3);
          final feedback = _day([other, own]);
          await tester.pumpWidget(
            _app(
              CalendarDayResultPopup(feedback: feedback, teamId: 'ours'),
              locale: locale,
            ),
          );
          await tester.pump();
          final l10n = await AppLocalizations.delegate.load(locale);
          expect(
            find.byKey(const ValueKey('calendar-day-result-popup-7-3')),
            findsOneWidget,
          );
          expect(
            find.text(l10n.calendar_simulationResults_title(4, 2)),
            findsOneWidget,
          );
          expect(find.text('ours'), findsOneWidget);
          expect(find.text('opponent'), findsOneWidget);
          expect(find.text('2:1'), findsOneWidget);
          expect(find.text('unrelated-home'), findsNothing);
          expect(find.text('unrelated-away'), findsNothing);
          final label = l10n.calendar_simulationResults_match(
            'ours',
            'opponent',
            2,
            1,
          );
          expect(find.byTooltip(label), findsOneWidget);
          expect(find.bySemanticsLabel(label), findsOneWidget);
          await tester.pump(const Duration(seconds: 1));
          expect(find.byType(Card), findsOneWidget);
          expect(tester.takeException(), isNull);
        } finally {
          semantics.dispose();
        }
      },
    );
  }
  for (final teamId in <String?>[null, 'missing']) {
    testWidgets('no result popup when player team is $teamId', (tester) async {
      await tester.pumpWidget(
        _app(
          CalendarDayResultPopup(
            feedback: _day([_match('home', 'away', 1, 0)]),
            teamId: teamId,
          ),
        ),
      );
      expect(find.byType(Card), findsNothing);
    });
  }
  testWidgets('an empty completed day has no popup', (tester) async {
    await tester.pumpWidget(
      _app(CalendarDayResultPopup(feedback: _day([]), teamId: 'ours')),
    );
    expect(find.byType(Card), findsNothing);
  });
  for (final isHome in [false, true]) {
    for (final score in [
      (2, 1, Colors.green),
      (1, 1, Colors.yellow),
      (0, 1, Colors.red),
    ]) {
      testWidgets(
        'result border reflects player score ${score.$1}:${score.$2} (home: $isHome)',
        (tester) async {
          final match = isHome
              ? _match('ours', 'other', score.$1, score.$2)
              : _match('other', 'ours', score.$2, score.$1);
          await tester.pumpWidget(
            _app(
              CalendarDayResultPopup(feedback: _day([match]), teamId: 'ours'),
            ),
          );
          final card = tester.widget<Card>(find.byType(Card));
          expect((card.shape! as RoundedRectangleBorder).side.color, score.$3);
        },
      );
    }
  }
  testWidgets(
    'long player-match names remain scrollable within a small viewport',
    (tester) async {
      tester.view.physicalSize = const Size(320, 360);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final home = List.filled(12, 'Long Home Club').join(' ');
      final away = List.filled(12, 'Long Away Club').join(' ');
      final match = CalendarMatchFeedback(
        matchId: 'long-names',
        schedulePosition: 0,
        homeTeamId: 'ours',
        homeTeamName: home,
        awayTeamId: 'other',
        awayTeamName: away,
        homeGoals: 1,
        awayGoals: 0,
      );
      await tester.pumpWidget(
        _app(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 360),
              textScaler: TextScaler.linear(2),
            ),
            child: CalendarDayResultPopup(
              feedback: _day([match]),
              teamId: 'ours',
            ),
          ),
        ),
      );
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      final card = tester.getRect(find.byType(Card));
      expect(card.width, lessThanOrEqualTo(320));
      expect(card.height, lessThanOrEqualTo(360));
      expect(find.text(home), findsOneWidget);
      expect(find.text(away), findsOneWidget);
      await tester.ensureVisible(find.text(away));
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}

CalendarDaySimulationFeedback _day(List<CalendarMatchFeedback> results) =>
    CalendarDaySimulationFeedback(
      runId: 7,
      sequence: 3,
      week: 4,
      day: 2,
      results: results,
    );
CalendarMatchFeedback _match(
  String home,
  String away,
  int homeGoals,
  int awayGoals,
) => CalendarMatchFeedback(
  matchId: '$home-$away',
  schedulePosition: 0,
  homeTeamId: home,
  homeTeamName: home,
  awayTeamId: away,
  awayTeamName: away,
  homeGoals: homeGoals,
  awayGoals: awayGoals,
);

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
