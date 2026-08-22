@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/calendar_screen.dart';
import 'package:new_football/core/models/game_save.dart';

import '../helpers/widget_harness.dart';

GameSave _calendarBaselineGame() {
  final game = task41Game(seed: 7);
  return game.copyWith(
    leagueState: game.leagueState.copyWith(
      // Week 23/day 1 contains the deterministic trade-deadline event. The
      // following match day is still visible in the same calendar month, so
      // the fixture covers past, current, future, event, and match tiles.
      currentWeek: 23,
      currentDay: 1,
      currentHour: null,
      hourlyPlayerOfferUsed: false,
      hourlyStaffOfferUsed: false,
    ),
  );
}

List<Opacity> _calendarTiles(WidgetTester tester) => tester
    .widgetList<Opacity>(find.byType(Opacity))
    .where((tile) => tile.child is InkWell)
    .toList();

InkWell _tileInk(WidgetTester tester, Opacity tile) => tester.widget<InkWell>(
  find.descendant(of: find.byWidget(tile), matching: find.byType(InkWell)),
);

List<Icon> _tileIcons(WidgetTester tester, Opacity tile) => tester
    .widgetList<Icon>(
      find.descendant(of: find.byWidget(tile), matching: find.byType(Icon)),
    )
    .toList();

List<Text> _tileTexts(WidgetTester tester, Opacity tile) => tester
    .widgetList<Text>(
      find.descendant(of: find.byWidget(tile), matching: find.byType(Text)),
    )
    .toList();

List<Tooltip> _tileTooltips(WidgetTester tester, Opacity tile) => tester
    .widgetList<Tooltip>(
      find.descendant(of: find.byWidget(tile), matching: find.byType(Tooltip)),
    )
    .toList();

BoxDecoration? _tileDecoration(WidgetTester tester, Opacity tile) {
  final containers = tester
      .widgetList<Container>(
        find.descendant(
          of: find.byWidget(tile),
          matching: find.byType(Container),
        ),
      )
      .toList();
  if (containers.isEmpty) return null;
  final decoration = containers.first.decoration;
  return decoration is BoxDecoration ? decoration : null;
}

Opacity _findTile(
  WidgetTester tester,
  bool Function(List<Icon> icons, InkWell ink) predicate,
) {
  for (final tile in _calendarTiles(tester)) {
    if (predicate(_tileIcons(tester, tile), _tileInk(tester, tile))) {
      return tile;
    }
  }
  throw StateError('Expected calendar tile was not rendered');
}

void main() {
  testWidgets(
    'Calendar baseline keeps seven columns, tile meaning, tooltips, and tap semantics',
    (tester) async {
      await tester.pumpWidget(
        task41App(const CalendarScreen(), _calendarBaselineGame()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 7);

      final tiles = _calendarTiles(tester);
      expect(tiles, isNotEmpty);
      final noIconTile = _findTile(
        tester,
        (icons, ink) => icons.isEmpty && ink.onTap != null,
      );
      final matchTile = _findTile(
        tester,
        (icons, ink) =>
            ink.onTap != null &&
            icons.any((icon) => icon.icon == Icons.sports_soccer),
      );
      final eventTile = _findTile(
        tester,
        (icons, ink) =>
            ink.onTap != null &&
            icons.any((icon) => icon.icon == Icons.event_available_outlined),
      );

      expect(_tileIcons(tester, noIconTile), isEmpty);
      expect(_tileIcons(tester, matchTile), hasLength(1));
      expect(_tileIcons(tester, eventTile), hasLength(1));
      final matchTooltip = _tileTooltips(tester, matchTile).single.message!;
      final eventTooltip = _tileTooltips(tester, eventTile).single.message!;
      expect(_tileTooltips(tester, matchTile), hasLength(1));
      expect(_tileTooltips(tester, eventTile), hasLength(1));
      expect(matchTooltip, isNotEmpty);
      expect(eventTooltip, isNotEmpty);

      final styles = <TextStyle?>[];
      for (final tile in tiles) {
        styles.addAll(_tileTexts(tester, tile).map((text) => text.style));
      }
      final theme = Theme.of(tester.element(find.byType(CalendarScreen)));
      expect(
        styles.any((style) => style?.fontWeight == FontWeight.bold),
        isTrue,
        reason: 'The current-day number must retain its bold visual meaning.',
      );
      expect(
        styles.any((style) => style?.color == theme.disabledColor),
        isTrue,
        reason: 'Past/out-of-month dates must retain disabled coloring.',
      );
      expect(
        styles.any((style) => style?.color != theme.disabledColor),
        isTrue,
        reason: 'Future dates must retain an enabled, non-disabled color.',
      );

      final selectedHeading = find.textContaining('Wybrany dzień');
      expect(selectedHeading, findsOneWidget);
      final beforeTap = tester.widget<Text>(selectedHeading).data;
      await tester.tap(find.byWidget(noIconTile));
      await tester.pump();
      expect(tester.takeException(), isNull);
      final afterTap = tester.widget<Text>(selectedHeading).data;
      expect(afterTap, isNot(beforeTap));

      final borderedTiles = _calendarTiles(
        tester,
      ).where((tile) => _tileDecoration(tester, tile)?.border != null).toList();
      expect(borderedTiles, hasLength(1));
      expect(
        _tileIcons(tester, borderedTiles.single),
        isEmpty,
        reason: 'Selecting an icon-free tile must not change its meaning.',
      );
      expect(find.byTooltip(matchTooltip), findsOneWidget);
      expect(find.byTooltip(eventTooltip), findsOneWidget);
    },
  );

  testWidgets(
    'Calendar baseline shows the final snackbar and no result popup for a no-result day',
    (tester) async {
      late GameController controller;
      final baseGame = _calendarBaselineGame();
      final noResultGame = baseGame.copyWith(
        leagueState: baseGame.leagueState.copyWith(
          currentWeek: 1,
          currentDay: 1,
        ),
      );
      await tester.pumpWidget(
        task41App(
          const CalendarScreen(),
          noResultGame,
          onController: (value) => controller = value,
          selectedCalendarDay: DateTime(2026, 8, 4),
        ),
      );
      await tester.pumpAndSettle();

      final simulateButton = find.widgetWithText(
        FilledButton,
        'Do wybranej daty',
      );
      await tester.ensureVisible(simulateButton);
      await tester.pumpAndSettle();
      await tester.tap(simulateButton);
      await tester.pumpAndSettle();

      expect(controller.save!.leagueState.currentWeek, 1);
      expect(controller.save!.leagueState.currentDay, 2);
      expect(find.textContaining('Cel osiągnięty'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
