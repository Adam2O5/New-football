@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/free_agency_screen.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/staff_role_ratings_test_helpers.dart';

void main() {
  testWidgets(
    'FreeAgencyScreen sorts staff by raw rating and renders shared stars',
    (tester) async {
      final low = staffMemberFor(
        StaffRole.scout,
        relevantValues: [3.26, 3.26],
        id: 'scout-low',
        name: 'Scout low',
      );
      final high = staffMemberFor(
        StaffRole.scout,
        relevantValues: [3.30, 3.30],
        id: 'scout-high',
        name: 'Scout high',
      );
      final tieB = staffMemberFor(
        StaffRole.scout,
        relevantValues: [4.0, 4.0],
        id: 'scout-b',
        name: 'Scout tie B',
      );
      final tieA = staffMemberFor(
        StaffRole.scout,
        relevantValues: [4.0, 4.0],
        id: 'scout-a',
        name: 'Scout tie A',
      );
      final league = staffFixtureLeague(
        staffFreeAgents: [low, tieB, high, tieA],
      );

      await tester.pumpWidget(_app(league));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(low.name),
        400,
        scrollable: _verticalScrollable(),
      );

      final names = [tieA.name, tieB.name, high.name, low.name];
      final candidateTiles = tester
          .widgetList<ListTile>(find.byType(ListTile))
          .where((tile) {
            final title = tile.title;
            return title is Text && names.contains(title.data);
          })
          .map((tile) => (tile.title! as Text).data)
          .toList();
      expect(candidateTiles, names);

      final prefix = 'staff-candidate-rating-${high.id}';
      final icons = List.generate(
        5,
        (index) => tester
            .widget<Icon>(find.byKey(ValueKey<String>('$prefix-star-$index')))
            .icon,
      );
      expect(icons, [
        Icons.star,
        Icons.star,
        Icons.star,
        Icons.star_half,
        Icons.star_border,
      ]);
      expect(find.textContaining('★'), findsNothing);

      final offerButtons = tester
          .widgetList<FilledButton>(
            find.widgetWithText(FilledButton, 'Złóż ofertę sztabowi'),
          )
          .toList();
      expect(offerButtons, hasLength(4));
      expect(offerButtons.every((button) => button.onPressed != null), isTrue);
    },
  );

  testWidgets(
    'FreeAgencyScreen disables an offer for an unavailable staff slot',
    (tester) async {
      final candidate = staffMemberFor(
        StaffRole.scout,
        relevantValues: [3.0, 3.0],
        id: 'scout-unavailable-candidate',
        name: 'Unavailable Scout Candidate',
      );
      final mismatchedSlotMember = staffMemberFor(
        StaffRole.doctor,
        relevantValues: [3.0, 3.0],
        id: 'mismatched-slot-member',
        name: 'Mismatched Slot Member',
      );
      final team = staffFixtureTeam(
        staff: teamStaffOf({StaffRole.scout: mismatchedSlotMember}),
      );
      final league = staffFixtureLeague(
        teams: [team],
        staffFreeAgents: [candidate],
      );

      await tester.pumpWidget(_app(league));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(candidate.name),
        400,
        scrollable: _verticalScrollable(),
      );

      final offerButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Złóż ofertę sztabowi'),
      );
      expect(offerButton.onPressed, isNull);
    },
  );
}

Finder _verticalScrollable() => find.byWidgetPredicate(
  (widget) =>
      widget is Scrollable && widget.axisDirection == AxisDirection.down,
);

Widget _app(LeagueState league) {
  return ProviderScope(
    overrides: [activeLeagueProvider.overrideWithValue(league)],
    child: const MaterialApp(
      locale: Locale('pl'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: FreeAgencyScreen(),
    ),
  );
}
