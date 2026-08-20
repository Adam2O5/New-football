import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/widgets/calendar_day_tile.dart';

void main() {
  testWidgets(
    'keeps a selected tile with both indicators bounded across the logical matrix',
    (tester) async {
      addTearDown(tester.view.reset);
      final semanticsHandle = tester.ensureSemantics();

      const widths = [320.0, 360.0, 393.0, 414.0, 600.0];
      const pixelRatios = [1.0, 2.0, 2.75, 3.0];
      const textScales = [1.0, 1.3, 1.5, 2.0];

      for (final width in widths) {
        for (final pixelRatio in pixelRatios) {
          for (final textScale in textScales) {
            for (final landscape in [false, true]) {
              final logicalHeight = landscape ? 320.0 : 600.0;
              tester.view.physicalSize = Size(
                width * pixelRatio,
                logicalHeight * pixelRatio,
              );
              tester.view.devicePixelRatio = pixelRatio;

              var tapCount = 0;
              await tester.pumpWidget(
                _tileApp(
                  width: width / 7,
                  height: (width / 7) / 0.85,
                  textScale: textScale,
                  matchCount: 1,
                  playerMatchLabel: 'Home Club – Away Club',
                  eventLabels: const ['Awards'],
                  onTap: () => tapCount++,
                ),
              );
              await tester.pump();

              final exception = tester.takeException();
              expect(
                exception,
                isNull,
                reason:
                    'Tile overflowed at width=${width}dp, '
                    'pixelRatio=$pixelRatio, textScale=$textScale, '
                    'orientation=${landscape ? 'landscape' : 'portrait'}: '
                    '$exception',
              );

              final tile = find.byType(InkWell);
              final tileRect = tester.getRect(tile);
              expect(
                find.byWidgetPredicate((widget) {
                  if (widget is! Container ||
                      widget.decoration is! BoxDecoration) {
                    return false;
                  }
                  final decoration = widget.decoration! as BoxDecoration;
                  return decoration.border != null;
                }),
                findsOneWidget,
                reason: 'selected tile lost its selection border',
              );
              final matchTooltip = find.byTooltip('Home Club – Away Club');
              final eventTooltip = find.byTooltip('Awards');
              final matchIcon = find.descendant(
                of: matchTooltip,
                matching: find.byIcon(Icons.sports_soccer),
              );
              final eventIcon = find.descendant(
                of: eventTooltip,
                matching: find.byIcon(Icons.event_available_outlined),
              );

              expect(matchTooltip, findsOneWidget);
              expect(eventTooltip, findsOneWidget);
              expect(matchIcon, findsOneWidget);
              expect(eventIcon, findsOneWidget);
              final dayNumber = find.text('3');
              expect(dayNumber, findsOneWidget);
              expect(
                tester.getSemantics(dayNumber),
                matchesSemantics(label: '3'),
              );

              final matchRect = tester.getRect(matchIcon);
              final eventRect = tester.getRect(eventIcon);
              expect(tileRect.inflate(0.1).contains(matchRect.topLeft), isTrue);
              expect(
                tileRect.inflate(0.1).contains(matchRect.bottomRight),
                isTrue,
              );
              expect(tileRect.inflate(0.1).contains(eventRect.topLeft), isTrue);
              expect(
                tileRect.inflate(0.1).contains(eventRect.bottomRight),
                isTrue,
              );
              expect(matchRect.overlaps(eventRect), isFalse);

              await tester.tap(tile);
              await tester.pump();
              expect(tapCount, 1);
            }
          }
        }
      }
      semanticsHandle.dispose();
    },
  );

  testWidgets(
    'preserves no-icon and single-icon meaning, tooltips, semantics, and tap',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      final cases = [
        (
          name: 'no indicators',
          matchCount: 0,
          playerMatchLabel: null,
          eventLabels: const <String>[],
          matchTooltip: null,
          eventTooltip: null,
          matchColor: null,
          isToday: false,
          isInMonth: false,
          isEnabled: false,
        ),
        (
          name: 'league match',
          matchCount: 2,
          playerMatchLabel: null,
          eventLabels: const <String>[],
          matchTooltip: '2 matches',
          eventTooltip: null,
          matchColor: Colors.white70,
          isToday: false,
          isInMonth: true,
          isEnabled: false,
        ),
        (
          name: 'player match and event',
          matchCount: 1,
          playerMatchLabel: 'Home Club – Away Club',
          eventLabels: const ['Awards'],
          matchTooltip: 'Home Club – Away Club',
          eventTooltip: 'Awards',
          matchColor: Colors.greenAccent,
          isToday: true,
          isInMonth: true,
          isEnabled: true,
        ),
        (
          name: 'event only',
          matchCount: 0,
          playerMatchLabel: null,
          eventLabels: const ['Awards', 'Combine'],
          matchTooltip: null,
          eventTooltip: 'Awards\nCombine',
          matchColor: null,
          isToday: false,
          isInMonth: true,
          isEnabled: true,
        ),
      ];

      for (final configuration in cases) {
        var tapCount = 0;
        await tester.pumpWidget(
          _tileApp(
            width: 96,
            height: 80,
            textScale: 2.0,
            matchCount: configuration.matchCount,
            playerMatchLabel: configuration.playerMatchLabel,
            eventLabels: configuration.eventLabels,
            isToday: configuration.isToday,
            isInMonth: configuration.isInMonth,
            isEnabled: configuration.isEnabled,
            onTap: () => tapCount++,
          ),
        );
        await tester.pump();

        expect(
          tester.takeException(),
          isNull,
          reason: 'Unexpected tile exception for ${configuration.name}.',
        );
        final dayNumber = find.text('3');
        expect(dayNumber, findsOneWidget);
        expect(tester.getSemantics(dayNumber), matchesSemantics(label: '3'));
        if (configuration.matchTooltip != null) {
          expect(find.byTooltip(configuration.matchTooltip!), findsOneWidget);
        } else {
          expect(find.byIcon(Icons.sports_soccer), findsNothing);
        }
        if (configuration.eventTooltip != null) {
          expect(find.byTooltip(configuration.eventTooltip!), findsOneWidget);
        } else {
          expect(find.byIcon(Icons.event_available_outlined), findsNothing);
        }

        if (configuration.matchTooltip != null) {
          final icon = tester.widget<Icon>(
            find.descendant(
              of: find.byTooltip(configuration.matchTooltip!),
              matching: find.byIcon(Icons.sports_soccer),
            ),
          );
          expect(icon.color, configuration.matchColor);
        }
        if (configuration.eventTooltip != null) {
          expect(
            find.descendant(
              of: find.byTooltip(configuration.eventTooltip!),
              matching: find.byIcon(Icons.event_available_outlined),
            ),
            findsOneWidget,
          );
        }

        await tester.tap(find.byType(InkWell));
        await tester.pump();
        expect(tapCount, 1, reason: configuration.name);
      }
      semanticsHandle.dispose();
    },
  );
}

Widget _tileApp({
  required double width,
  required double height,
  required double textScale,
  required int matchCount,
  required String? playerMatchLabel,
  required List<String> eventLabels,
  required VoidCallback onTap,
  bool isInMonth = true,
  bool isEnabled = true,
  bool isToday = false,
  bool isSelected = true,
}) {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        return Scaffold(
          body: Center(
            child: MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(textScale),
              ),
              child: SizedBox(
                width: width,
                height: height,
                child: CalendarDayTile(
                  date: DateTime(2026, 8, 3),
                  isInMonth: isInMonth,
                  isEnabled: isEnabled,
                  isToday: isToday,
                  isSelected: isSelected,
                  matchCount: matchCount,
                  playerMatchLabel: playerMatchLabel,
                  eventLabels: eventLabels,
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
