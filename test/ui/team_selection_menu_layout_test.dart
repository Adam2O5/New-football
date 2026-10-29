@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/widgets/team_selection/team_row.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/widgets/layout_scenarios.dart';
import '../helpers/widgets/team_selection_harness.dart';

void main() {
  testWidgets(
    'keeps one bounded team scroll region and a stable fixed action',
    (tester) async {
      final harness = TeamSelectionHarness(
        viewport: const Size(320, 568),
        textScale: 1.0,
      );
      addTearDown(() => harness.dispose(tester));

      await harness.pump(tester);

      final teamList = find.byKey(const ValueKey<String>('new-game-team-list'));
      final fixedAction = find.byKey(
        const ValueKey<String>('new-game-fixed-action'),
      );
      final startButton = find.byKey(
        const ValueKey<String>('new-game-start-button'),
      );
      final verticalScrollables = find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      );
      final listScrollable = teamListScrollable(teamList);
      final expectedTeams = harness.gameFactory.previewTeams();
      final expectedRowKeys = expectedTeams
          .map((team) => 'new-game-team-row-${team.id}')
          .toSet();
      final listWidget = tester.widget<ListView>(teamList);
      final visibleListRows = find.descendant(
        of: teamList,
        matching: find.byType(TeamRow),
      );

      void expectVisibleListRowsOnly() {
        final rows = tester.widgetList<TeamRow>(visibleListRows).toList();
        expect(rows, isNotEmpty);
        for (final row in rows) {
          final key = row.key;
          expect(key, isA<ValueKey<String>>());
          expect(expectedRowKeys, contains((key! as ValueKey<String>).value));
        }
        expect(
          find.byType(TeamRow),
          findsNWidgets(rows.length),
          reason: 'all mounted TeamRow widgets must belong to the team list',
        );
      }

      expect(listWidget.childrenDelegate, isA<SliverChildBuilderDelegate>());
      expect(
        (listWidget.childrenDelegate as SliverChildBuilderDelegate).childCount,
        expectedTeams.length,
      );
      expect(verticalScrollables, findsOneWidget);
      expect(listScrollable, findsOneWidget);
      expect(
        find.descendant(of: teamList, matching: find.byType(Scrollable)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: teamList, matching: fixedAction),
        findsNothing,
      );
      expect(
        find.descendant(of: teamList, matching: startButton),
        findsNothing,
      );
      expect(
        find.descendant(of: fixedAction, matching: startButton),
        findsOneWidget,
      );

      final scrollableState = tester.state<ScrollableState>(
        verticalScrollables,
      );
      final scrollPosition = scrollableState.position;
      expect(
        scrollableState.position,
        same(scrollPosition),
        reason: 'the single Scrollable must retain one scroll position',
      );
      expect(scrollPosition.maxScrollExtent, greaterThan(0));

      final teamListRect = rect(tester, teamList);
      final fixedActionRect = rect(tester, fixedAction);
      final startButtonRect = rect(tester, startButton);
      final viewportRect = testViewportRect(tester);

      expect(teamListRect.height, greaterThan(0));
      expect(fixedActionRect.height, greaterThan(0));
      expect(
        teamListRect.bottom,
        lessThanOrEqualTo(fixedActionRect.top - 8.0 + geometryTolerance),
      );
      expect(teamListRect.overlaps(fixedActionRect), isFalse);
      expectRectInside(viewportRect, teamListRect);
      expectRectInside(viewportRect, fixedActionRect);
      expectRectInside(fixedActionRect, startButtonRect);
      expectRectInside(viewportRect, startButtonRect);

      expectVisibleListRowsOnly();
      scrollPosition.jumpTo(0);
      await tester.pumpAndSettle();
      expect(scrollPosition.pixels, closeTo(0, geometryTolerance));

      final firstTeam = expectedTeams.first;
      final firstRow = find.byKey(
        ValueKey<String>('new-game-team-row-${firstTeam.id}'),
      );
      expect(firstRow, findsOneWidget);
      expectRectInside(teamListRect, rect(tester, firstRow));
      expectVisibleListRowsOnly();
      expectRectStable(
        fixedActionRect,
        rect(tester, fixedAction),
        reason: 'fixed action moved at the beginning of the team list',
      );
      expectRectStable(
        startButtonRect,
        rect(tester, startButton),
        reason: 'start button moved at the beginning of the team list',
      );
      expectRectInside(viewportRect, rect(tester, startButton));

      scrollPosition.jumpTo(scrollPosition.maxScrollExtent);
      await tester.pumpAndSettle();
      scrollPosition.jumpTo(scrollPosition.maxScrollExtent);
      await tester.pumpAndSettle();

      expect(
        scrollPosition.pixels,
        closeTo(scrollPosition.maxScrollExtent, geometryTolerance),
      );
      final lastTeam = expectedTeams.last;
      final lastRow = find.byKey(
        ValueKey<String>('new-game-team-row-${lastTeam.id}'),
      );
      expect(lastRow, findsOneWidget);
      final lastRowRect = rect(tester, lastRow);
      expect(
        lastRowRect.top,
        greaterThanOrEqualTo(teamListRect.top - geometryTolerance),
      );
      expect(
        lastRowRect.bottom,
        lessThanOrEqualTo(teamListRect.bottom + geometryTolerance),
      );
      expectVisibleListRowsOnly();
      expectRectStable(
        fixedActionRect,
        rect(tester, fixedAction),
        reason: 'fixed action moved to the end of the team list',
      );
      expectRectStable(
        startButtonRect,
        rect(tester, startButton),
        reason: 'start button moved to the end of the team list',
      );
      expectRectInside(viewportRect, rect(tester, startButton));
      expect(
        find.descendant(of: teamList, matching: fixedAction),
        findsNothing,
      );
      expect(
        find.descendant(of: teamList, matching: startButton),
        findsNothing,
      );
    },
  );

  testWidgets(
    'keeps the selection screen bounded across the viewport and text-scale matrix',
    (tester) async {
      for (final layout in layoutScenarios) {
        final viewport = layout.viewport;
        for (final textScale in [layout.textScale]) {
          final harness = TeamSelectionHarness(
            viewport: viewport,
            textScale: textScale,
            locale: layout.locale,
          );
          SemanticsHandle? semanticsHandle;
          final scenario =
              '${viewport.width.toInt()}x${viewport.height.toInt()} '
              'at text scale $textScale';
          try {
            await harness.pump(tester);
            if (textScale == 2.0) {
              semanticsHandle = ensureSemantics(tester);
              await tester.pump();
            }

            final teams = harness.gameFactory.previewTeams();
            expectResponsiveGeometry(
              tester,
              teamId: teams.first.id,
              scenario: scenario,
            );
            expect(
              takeException(tester),
              isNull,
              reason: 'layout exception for $scenario',
            );

            if (textScale == 2.0) {
              final l10n = await AppLocalizations.delegate.load(harness.locale);
              await expectScaleTwoRowsRemainComplete(
                tester,
                teams: teams,
                l10n: l10n,
                scenario: scenario,
              );
            }
            expect(
              takeException(tester),
              isNull,
              reason: 'overflow after scrolling for $scenario',
            );
          } finally {
            semanticsHandle?.dispose();
            await harness.dispose(tester);
          }
        }
      }
    },
  );

  testWidgets(
    'retains the selected team when resizing from portrait to landscape',
    (tester) async {
      final harness = TeamSelectionHarness(
        viewport: const Size(390, 844),
        textScale: 1.0,
      );
      try {
        await harness.pump(tester);
        final selectedTeam = harness.gameFactory.previewTeams()[4];
        await activateTeam(tester, selectedTeam.id);
        expect(
          tester.widget<TeamRow>(teamRowFinder(selectedTeam.id)).selected,
          isTrue,
        );
        expect(takeException(tester), isNull);

        configureTestView(tester, viewport: const Size(844, 390));
        await tester.pumpAndSettle();
        expect(
          takeException(tester),
          isNull,
          reason: 'portrait-to-landscape resize produced an exception',
        );

        final selectedRow = teamRowFinder(selectedTeam.id);
        await tester.scrollUntilVisible(
          selectedRow,
          300,
          scrollable: teamListScrollable(
            find.byKey(const ValueKey<String>('new-game-team-list')),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.widget<TeamRow>(selectedRow).selected, isTrue);
        final selectedRows = tester
            .widgetList<TeamRow>(find.byType(TeamRow))
            .where((row) => row.selected)
            .toList();
        expect(selectedRows, hasLength(1));
        expect(selectedRows.single.teamId, selectedTeam.id);

        expectResponsiveGeometry(
          tester,
          teamId: selectedTeam.id,
          scenario: 'portrait-to-landscape resize',
        );
      } finally {
        await harness.dispose(tester);
      }
    },
  );
}
