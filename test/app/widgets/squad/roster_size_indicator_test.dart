import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/widgets/squad/squad_indicators.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

const _countKey = ValueKey<String>('squad-size-indicator-count');
const _minimumKey = ValueKey<String>('squad-size-indicator-minimum');
const _maximumKey = ValueKey<String>('squad-size-indicator-maximum');
const _fillKey = ValueKey<String>('squad-size-indicator-track-fill');
const _stateIconKey = ValueKey<String>('squad-size-indicator-state-icon');
const _indicatorKey = ValueKey<String>('squad-size-indicator');

void main() {
  testWidgets(
    'renders separate count and endpoints with generated Polish and English labels',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      for (final locale in const [Locale('pl'), Locale('en')]) {
        await _pumpIndicator(tester, locale: locale, count: 25);
        final l10n = _localizations(tester);
        final stateLabel = l10n.squad_rosterStateInRange;
        final semanticsLabel = l10n.squad_rosterSizeSemantics(
          25,
          20,
          30,
          stateLabel,
        );

        final count = tester.widget<Text>(find.byKey(_countKey));
        final minimum = tester.widget<Text>(find.byKey(_minimumKey));
        final maximum = tester.widget<Text>(find.byKey(_maximumKey));

        expect(count.data, '25');
        expect(minimum.data, l10n.squad_rosterMinimum(20));
        expect(maximum.data, l10n.squad_rosterMaximum(30));
        expect(find.byTooltip(l10n.squad_rosterCount(25)), findsOneWidget);
        expect(find.text(l10n.squad_sizeLabel(25, 20, 30)), findsNothing);

        final semanticsFinder = find.bySemanticsLabel(semanticsLabel);
        expect(semanticsFinder, findsOneWidget);
        final semanticsNode = tester.getSemantics(semanticsFinder);
        expect(semanticsNode.label, semanticsLabel);
        expect(semanticsNode.childrenCount, 0);
        expect(find.bySemanticsLabel(stateLabel), findsNothing);
      }
      semanticsHandle.dispose();
    },
  );

  testWidgets(
    'maps endpoints, intermediate counts and out-of-range counts to bounded state',
    (tester) async {
      final scenarios =
          <
            ({
              int count,
              double progress,
              Color color,
              IconData icon,
              bool inRange,
            })
          >[
            (
              count: 19,
              progress: 0,
              color: Colors.red,
              icon: Icons.close,
              inRange: false,
            ),
            (
              count: 20,
              progress: 0,
              color: Colors.green,
              icon: Icons.check,
              inRange: true,
            ),
            (
              count: 25,
              progress: 0.5,
              color: Colors.green,
              icon: Icons.check,
              inRange: true,
            ),
            (
              count: 30,
              progress: 1,
              color: Colors.green,
              icon: Icons.check,
              inRange: true,
            ),
            (
              count: 31,
              progress: 1,
              color: Colors.red,
              icon: Icons.close,
              inRange: false,
            ),
          ];

      for (final scenario in scenarios) {
        await _pumpIndicator(
          tester,
          locale: const Locale('en'),
          count: scenario.count,
        );

        final fillFinder = find.byKey(_fillKey);
        final fill = tester.widget<FractionallySizedBox>(fillFinder);
        final fillColor = tester.widget<ColoredBox>(
          find.descendant(of: fillFinder, matching: find.byType(ColoredBox)),
        );
        final stateIcon = tester.widget<Icon>(find.byKey(_stateIconKey));

        expect(fill.widthFactor, closeTo(scenario.progress, 0.000001));
        expect(fillColor.color, scenario.color);
        expect(stateIcon.icon, scenario.icon);
        expect(stateIcon.color, scenario.color);
        expect(find.byIcon(scenario.icon), findsOneWidget);
        expect(
          find.byIcon(scenario.inRange ? Icons.close : Icons.check),
          findsNothing,
        );
      }
    },
  );

  testWidgets(
    'updates count, progress, color, icon and semantics after a live count change',
    (tester) async {
      final count = ValueNotifier<int>(25);
      addTearDown(count.dispose);
      final semanticsHandle = tester.ensureSemantics();

      await _pumpIndicator(
        tester,
        locale: const Locale('en'),
        indicator: ValueListenableBuilder<int>(
          valueListenable: count,
          builder: (context, value, child) => RosterSizeIndicator(
            key: const ValueKey<String>('live-roster-size-indicator'),
            l10n: _localizationsFromContext(context),
            count: value,
            min: 20,
            max: 30,
          ),
        ),
      );
      _expectState(tester, count: 25, progress: 0.5, color: Colors.green);

      count.value = 15;
      await tester.pump();
      _expectState(tester, count: 15, progress: 0, color: Colors.red);
      final outOfRangeL10n = _localizations(tester);
      expect(
        tester.getSemantics(find.byKey(_indicatorKey)).label,
        outOfRangeL10n.squad_rosterSizeSemantics(
          15,
          20,
          30,
          outOfRangeL10n.squad_rosterStateOutOfRange,
        ),
      );

      count.value = 30;
      await tester.pump();
      _expectState(tester, count: 30, progress: 1, color: Colors.green);
      final inRangeL10n = _localizations(tester);
      expect(
        tester.getSemantics(find.byKey(_indicatorKey)).label,
        inRangeL10n.squad_rosterSizeSemantics(
          30,
          20,
          30,
          inRangeL10n.squad_rosterStateInRange,
        ),
      );
      semanticsHandle.dispose();
    },
  );
}

Future<void> _pumpIndicator(
  WidgetTester tester, {
  required Locale locale,
  int? count,
  Widget? indicator,
}) async {
  final child =
      indicator ??
      _LocalizedRosterSizeIndicator(count: count!, min: 20, max: 30);
  await tester.pumpWidget(_localizedApp(locale, child));
  await tester.pumpAndSettle();
}

Widget _localizedApp(Locale locale, Widget child) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(child: SizedBox(width: 360, child: child)),
    ),
  );
}

AppLocalizations _localizations(WidgetTester tester) {
  return _localizationsFromContext(
    tester.element(find.byType(RosterSizeIndicator)),
  );
}

AppLocalizations _localizationsFromContext(BuildContext context) {
  return AppLocalizations.of(context)!;
}

void _expectState(
  WidgetTester tester, {
  required int count,
  required double progress,
  required Color color,
}) {
  final countText = tester.widget<Text>(find.byKey(_countKey));
  final fillFinder = find.byKey(_fillKey);
  final fill = tester.widget<FractionallySizedBox>(fillFinder);
  final fillColor = tester.widget<ColoredBox>(
    find.descendant(of: fillFinder, matching: find.byType(ColoredBox)),
  );
  final stateIcon = tester.widget<Icon>(find.byKey(_stateIconKey));

  expect(countText.data, '$count');
  expect(fill.widthFactor, closeTo(progress, 0.000001));
  expect(fillColor.color, color);
  expect(stateIcon.color, color);
  expect(stateIcon.icon, color == Colors.green ? Icons.check : Icons.close);
}

class _LocalizedRosterSizeIndicator extends StatelessWidget {
  const _LocalizedRosterSizeIndicator({
    required this.count,
    required this.min,
    required this.max,
  });

  final int count;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return RosterSizeIndicator(
      l10n: AppLocalizations.of(context)!,
      count: count,
      min: min,
      max: max,
    );
  }
}
