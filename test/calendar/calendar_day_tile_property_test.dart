@Tags(['ui', 'property'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/widgets/calendar_day_tile.dart';

void main() {
  // **Validates: Requirements 2.6, 2.7**
  testWidgets(
    'seeded covering generator keeps selected tiles bounded across constraints',
    (tester) async {
      addTearDown(tester.view.reset);
      final semanticsHandle = tester.ensureSemantics();

      for (final configuration in _generatedTileCases()) {
        final viewportHeight = configuration.landscape ? 320.0 : 600.0;
        tester.view.physicalSize = Size(
          configuration.width * configuration.pixelRatio,
          viewportHeight * configuration.pixelRatio,
        );
        tester.view.devicePixelRatio = configuration.pixelRatio;

        var tapCount = 0;
        await tester.pumpWidget(
          _tileApp(configuration, onTap: () => tapCount++),
        );
        await tester.pump();

        final description = configuration.description;
        final exception = tester.takeException();
        expect(
          exception,
          isNull,
          reason: '$description: tester.takeException() returned $exception',
        );

        final tile = find.byType(InkWell);
        expect(
          tile,
          findsOneWidget,
          reason: '$description: missing tap target',
        );
        final tileRect = tester.getRect(tile);
        final dayNumber = find.text('3');
        expect(dayNumber, findsOneWidget, reason: '$description: day number');
        expect(
          tester.getSemantics(dayNumber),
          matchesSemantics(label: '3'),
          reason: '$description: day-number semantics changed',
        );

        if (configuration.hasMatch) {
          final matchTooltip = find.byTooltip(configuration.matchTooltip!);
          expect(
            matchTooltip,
            findsOneWidget,
            reason: '$description: match tooltip',
          );
          expect(
            tester.getSemantics(matchTooltip),
            isNotNull,
            reason: '$description: match tooltip lost its semantics node',
          );
          final matchIcon = find.descendant(
            of: matchTooltip,
            matching: find.byIcon(Icons.sports_soccer),
          );
          expect(matchIcon, findsOneWidget, reason: '$description: match icon');
          _expectInsideTile(tester.getRect(matchIcon), tileRect, description);
          final icon = tester.widget<Icon>(matchIcon);
          expect(
            icon.color,
            configuration.playerMatch ? Colors.greenAccent : Colors.white70,
            reason: '$description: match indicator meaning/color changed',
          );
        } else {
          expect(find.byIcon(Icons.sports_soccer), findsNothing);
        }

        if (configuration.hasEvent) {
          final eventTooltip = find.byTooltip(configuration.eventTooltip!);
          expect(
            eventTooltip,
            findsOneWidget,
            reason: '$description: event tooltip',
          );
          expect(
            tester.getSemantics(eventTooltip),
            isNotNull,
            reason: '$description: event tooltip lost its semantics node',
          );
          final eventIcon = find.descendant(
            of: eventTooltip,
            matching: find.byIcon(Icons.event_available_outlined),
          );
          expect(eventIcon, findsOneWidget, reason: '$description: event icon');
          _expectInsideTile(tester.getRect(eventIcon), tileRect, description);
          expect(
            tester.widget<Icon>(eventIcon).color,
            Colors.amber,
            reason: '$description: event indicator meaning/color changed',
          );
        } else {
          expect(find.byIcon(Icons.event_available_outlined), findsNothing);
        }

        if (configuration.hasMatch && configuration.hasEvent) {
          final matchRect = tester.getRect(
            find.descendant(
              of: find.byTooltip(configuration.matchTooltip!),
              matching: find.byIcon(Icons.sports_soccer),
            ),
          );
          final eventRect = tester.getRect(
            find.descendant(
              of: find.byTooltip(configuration.eventTooltip!),
              matching: find.byIcon(Icons.event_available_outlined),
            ),
          );
          expect(
            matchRect.overlaps(eventRect),
            isFalse,
            reason: '$description: indicators overlap',
          );
        }

        await tester.tap(tile);
        await tester.pump();
        expect(tapCount, 1, reason: '$description: tile tap was lost');
        expect(
          tester.takeException(),
          isNull,
          reason: '$description: tap produced a layout exception',
        );
      }
      semanticsHandle.dispose();
    },
  );

  // **Validates: Requirements 3.5, 3.6**
  testWidgets(
    'generated unaffected tile states preserve seven columns, meaning, and interaction',
    (tester) async {
      final tapCounts = List<int>.filled(7, 0);
      final states = _unaffectedTileCases();
      await tester.pumpWidget(
        _sevenColumnApp(states, onTap: (index) => tapCounts[index]++),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 7);

      for (var index = 0; index < states.length; index++) {
        final state = states[index];
        final cell = find.byKey(ValueKey<String>('unaffected-$index'));
        expect(cell, findsOneWidget, reason: state.description);
        final icons = tester
            .widgetList<Icon>(
              find.descendant(of: cell, matching: find.byType(Icon)),
            )
            .toList();
        final tooltips = tester
            .widgetList<Tooltip>(
              find.descendant(of: cell, matching: find.byType(Tooltip)),
            )
            .toList();

        expect(
          icons.length,
          (state.hasMatch ? 1 : 0) + (state.hasEvent ? 1 : 0),
        );
        expect(
          tooltips.length,
          (state.hasMatch ? 1 : 0) + (state.hasEvent ? 1 : 0),
          reason: '${state.description}: tooltip count changed',
        );
        if (state.hasMatch) {
          final matchIcon = icons.firstWhere(
            (icon) => icon.icon == Icons.sports_soccer,
          );
          expect(
            matchIcon.color,
            state.playerMatch ? Colors.greenAccent : Colors.white70,
            reason: '${state.description}: match meaning/color changed',
          );
          expect(
            find.descendant(
              of: cell,
              matching: find.byTooltip(state.matchTooltip!),
            ),
            findsOneWidget,
          );
        }
        if (state.hasEvent) {
          expect(
            find.descendant(
              of: cell,
              matching: find.byTooltip(state.eventTooltip!),
            ),
            findsOneWidget,
          );
          expect(
            icons.any((icon) => icon.icon == Icons.event_available_outlined),
            isTrue,
            reason: '${state.description}: event meaning changed',
          );
        }
        expect(
          find.descendant(of: cell, matching: find.text('3')),
          findsOneWidget,
          reason: '${state.description}: day number changed',
        );

        await tester.tap(
          find.descendant(of: cell, matching: find.byType(InkWell)),
        );
        await tester.pump();
      }
      expect(tapCounts, List<int>.filled(7, 1));
      expect(tester.takeException(), isNull);
    },
  );
}

final class _TileConfiguration {
  const _TileConfiguration({
    required this.index,
    required this.width,
    required this.pixelRatio,
    required this.textScale,
    required this.landscape,
    required this.hasMatch,
    required this.hasEvent,
    required this.selected,
    required this.playerMatch,
  });

  final int index;
  final double width;
  final double pixelRatio;
  final double textScale;
  final bool landscape;
  final bool hasMatch;
  final bool hasEvent;
  final bool selected;
  final bool playerMatch;

  String? get matchTooltip {
    if (!hasMatch) return null;
    return playerMatch ? 'Generated Home – Generated Away' : '3 matches';
  }

  String? get eventTooltip => hasEvent ? 'Generated event $index' : null;

  String get description =>
      'case=$index width=${width}dp pixelRatio=$pixelRatio '
      'textScale=$textScale orientation=${landscape ? 'landscape' : 'portrait'} '
      'match=$hasMatch event=$hasEvent selected=$selected';
}

List<_TileConfiguration> _generatedTileCases() {
  const widths = [320.0, 360.0, 393.0, 414.0, 600.0];
  const pixelRatios = [1.0, 2.0, 2.75, 3.0];
  const textScales = [1.0, 1.3, 1.5, 2.0];
  final random = _SeededGenerator(0x52a7_1c03);
  final cases = <_TileConfiguration>[];

  // This is a covering sample, not another 160-case Cartesian run: the
  // existing focused tile test owns the full matrix. Every value in each
  // required axis occurs here, and the seed makes failures reproducible.
  for (var index = 0; index < 24; index++) {
    final hasMatch = index % 4 != 0;
    final hasEvent = index % 5 != 0;
    cases.add(
      _TileConfiguration(
        index: index,
        width: widths[(index + random.nextInt(widths.length)) % widths.length],
        pixelRatio:
            pixelRatios[(index + random.nextInt(pixelRatios.length)) %
                pixelRatios.length],
        textScale:
            textScales[(index + random.nextInt(textScales.length)) %
                textScales.length],
        landscape: index.isOdd,
        hasMatch: hasMatch,
        hasEvent: hasEvent,
        selected: index.isEven,
        playerMatch: hasMatch && index % 3 == 1,
      ),
    );
  }
  return cases;
}

List<_TileConfiguration> _unaffectedTileCases() => const [
  _TileConfiguration(
    index: 0,
    width: 600,
    pixelRatio: 1,
    textScale: 1,
    landscape: false,
    hasMatch: false,
    hasEvent: false,
    selected: false,
    playerMatch: false,
  ),
  _TileConfiguration(
    index: 1,
    width: 600,
    pixelRatio: 2,
    textScale: 1.3,
    landscape: false,
    hasMatch: true,
    hasEvent: false,
    selected: false,
    playerMatch: false,
  ),
  _TileConfiguration(
    index: 2,
    width: 600,
    pixelRatio: 2.75,
    textScale: 1.5,
    landscape: true,
    hasMatch: false,
    hasEvent: true,
    selected: false,
    playerMatch: false,
  ),
  _TileConfiguration(
    index: 3,
    width: 600,
    pixelRatio: 3,
    textScale: 2,
    landscape: false,
    hasMatch: true,
    hasEvent: true,
    selected: false,
    playerMatch: true,
  ),
  _TileConfiguration(
    index: 4,
    width: 600,
    pixelRatio: 1,
    textScale: 1.3,
    landscape: false,
    hasMatch: false,
    hasEvent: false,
    selected: true,
    playerMatch: false,
  ),
  _TileConfiguration(
    index: 5,
    width: 600,
    pixelRatio: 2,
    textScale: 1.5,
    landscape: false,
    hasMatch: true,
    hasEvent: false,
    selected: true,
    playerMatch: false,
  ),
  _TileConfiguration(
    index: 6,
    width: 600,
    pixelRatio: 2.75,
    textScale: 2,
    landscape: false,
    hasMatch: false,
    hasEvent: true,
    selected: true,
    playerMatch: false,
  ),
];

Widget _tileApp(
  _TileConfiguration configuration, {
  required VoidCallback onTap,
}) {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        return Scaffold(
          body: Center(
            child: MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(configuration.textScale),
              ),
              child: SizedBox(
                width: configuration.width / 7,
                height: (configuration.width / 7) / 0.85,
                child: CalendarDayTile(
                  date: DateTime(2026, 8, 3),
                  isInMonth: true,
                  isEnabled: true,
                  isToday: false,
                  isSelected: configuration.selected,
                  matchCount: configuration.hasMatch
                      ? (configuration.playerMatch ? 1 : 3)
                      : 0,
                  playerMatchLabel: configuration.playerMatch
                      ? configuration.matchTooltip
                      : null,
                  eventLabels: configuration.hasEvent
                      ? [configuration.eventTooltip!]
                      : const [],
                  onTap: onTap,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

Widget _sevenColumnApp(
  List<_TileConfiguration> configurations, {
  required void Function(int index) onTap,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 600,
        height: 160,
        child: GridView.builder(
          itemCount: configurations.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: 70,
          ),
          itemBuilder: (context, index) {
            final configuration = configurations[index];
            return CalendarDayTile(
              key: ValueKey<String>('unaffected-$index'),
              date: DateTime(2026, 8, 3),
              isInMonth: true,
              isEnabled: true,
              isToday: false,
              isSelected: configuration.selected,
              matchCount: configuration.hasMatch
                  ? (configuration.playerMatch ? 1 : 3)
                  : 0,
              playerMatchLabel: configuration.playerMatch
                  ? configuration.matchTooltip
                  : null,
              eventLabels: configuration.hasEvent
                  ? [configuration.eventTooltip!]
                  : const [],
              onTap: () => onTap(index),
            );
          },
        ),
      ),
    ),
  );
}

void _expectInsideTile(Rect indicator, Rect tile, String description) {
  final bounds = tile.inflate(0.1);
  expect(
    bounds.contains(indicator.topLeft) &&
        bounds.contains(indicator.bottomRight),
    isTrue,
    reason:
        '$description: indicator outside tile bounds; tile=$tile icon=$indicator',
  );
}

final class _SeededGenerator {
  _SeededGenerator(this._state);

  int _state;

  int nextInt(int upperBound) {
    _state = (_state * 1_664_525 + 1_013_904_223) & 0x7fffffff;
    return _state % upperBound;
  }
}
