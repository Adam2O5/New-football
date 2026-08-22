@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/free_agency_screen.dart';
import 'package:new_football/app/screens/staff_screen.dart';
import 'package:new_football/app/widgets/staff_rating_stars.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/staff_role_ratings_test_helpers.dart';

// This is an independent UI oracle transcribed from docs/staff.md. Do not
// replace it with StaffPresentation.roleRelevantAttributes: these tests are
// intended to catch a production mapping that is wrong in both layers.
const _uiRelevantAttributeNames = <StaffRole, List<String>>{
  StaffRole.headCoach: ['tactics', 'motivation'],
  StaffRole.youthCoach: ['development', 'mentoring'],
  StaffRole.scout: ['coverage', 'evaluation'],
  StaffRole.physio: ['rehabilitation', 'regenaration'],
  StaffRole.doctor: ['prevention', 'care'],
  StaffRole.cfo: ['negotiation'],
};

const _uiAttributeLabels = <String, String>{
  'tactics': 'Taktyka',
  'motivation': 'Motywacja',
  'development': 'Rozwój',
  'mentoring': 'Mentoring',
  'coverage': 'Zasięg',
  'evaluation': 'Ocena',
  'rehabilitation': 'Rehabilitacja',
  'regenaration': 'Regeneracja',
  'prevention': 'Prewencja',
  'care': 'Opieka',
  'negotiation': 'Negocjacje',
};

const _allUiAttributeNames = <String>[
  'tactics',
  'motivation',
  'development',
  'mentoring',
  'coverage',
  'evaluation',
  'rehabilitation',
  'regenaration',
  'prevention',
  'care',
  'negotiation',
];

const _fourFullOneEmpty = <IconData>[
  Icons.star,
  Icons.star,
  Icons.star,
  Icons.star,
  Icons.star_border,
];

const _fourFullOneHalf = <IconData>[
  Icons.star,
  Icons.star,
  Icons.star,
  Icons.star,
  Icons.star_half,
];

const _threeFullOneHalfOneEmpty = <IconData>[
  Icons.star,
  Icons.star,
  Icons.star,
  Icons.star_half,
  Icons.star_border,
];

const _threeFullTwoEmpty = <IconData>[
  Icons.star,
  Icons.star,
  Icons.star,
  Icons.star_border,
  Icons.star_border,
];

void main() {
  testWidgets(
    'StaffScreen renders occupied, empty and unavailable slots without stale stars',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();

      final occupied = staffMemberFor(
        StaffRole.headCoach,
        attributes: staffAttributesForRole(
          StaffRole.headCoach,
          [4.5, 3.0],
          // The legacy field must not leak into the role-specific rating or
          // the offer preview.
          irrelevantValue: 5.0,
        ),
        id: 'ui-occupied-head-coach',
        name: 'UI Occupied Head Coach',
        contract: staffFixtureContract(),
      );
      final mismatched = staffMemberFor(
        StaffRole.doctor,
        relevantValues: [3.0, 3.0],
        id: 'ui-mismatched-scout-slot',
        name: 'UI Mismatched Scout Slot',
      );
      final team = staffFixtureTeam(
        staff: teamStaffOf({
          StaffRole.headCoach: occupied,
          StaffRole.scout: mismatched,
        }),
      );
      final league = staffFixtureLeague(teams: [team]);

      await tester.pumpWidget(_app(const StaffScreen(), league));
      await tester.pumpAndSettle();

      expect(
        _iconsForPrefix(tester, 'staff-member-rating-${occupied.id}'),
        _fourFullOneEmpty,
        reason: 'raw 3.75 must be displayed as four full icons and one empty',
      );
      expect(
        tester.getSemantics(
          find.byKey(
            ValueKey<String>('staff-member-rating-${occupied.id}-semantics'),
          ),
        ),
        matchesSemantics(label: 'Rating 4.0 out of 5'),
        reason: 'the UI accessibility value must use DisplayedRating 4.0',
      );

      final emptyPrefix = 'staff-slot-rating-${StaffRole.youthCoach.name}';
      expect(
        find.byKey(ValueKey<String>('$emptyPrefix-empty')),
        findsOneWidget,
      );
      expect(
        find.byKey(ValueKey<String>('$emptyPrefix-star-0')),
        findsNothing,
        reason: 'EmptySlot must not render five empty member stars',
      );
      expect(
        tester.getSemantics(
          find.byKey(ValueKey<String>('$emptyPrefix-semantics')),
        ),
        matchesSemantics(label: 'Staff slot empty'),
      );

      await _scrollToText(tester, '—');
      const unavailablePrefix = 'staff-slot-rating-scout';
      expect(
        find.byKey(const ValueKey<String>('$unavailablePrefix-empty')),
        findsOneWidget,
      );
      expect(
        tester.getSemantics(
          find.byKey(const ValueKey<String>('$unavailablePrefix-semantics')),
        ),
        matchesSemantics(label: 'Staff rating unavailable'),
        reason: 'a role/slot mismatch must be unavailable, not a fake rating',
      );
      expect(
        find.byKey(const ValueKey<String>('$unavailablePrefix-star-0')),
        findsNothing,
      );

      await _scrollToText(tester, occupied.name);
      await tester.tap(find.text(occupied.name));
      await tester.pump();
      await _scrollToText(tester, 'Podgląd oferty: ${occupied.name}');

      expect(find.text('Podgląd oferty: ${occupied.name}'), findsOneWidget);
      expect(
        find.textContaining('★'),
        findsNothing,
        reason: 'staff ratings must be graphical, not text-only star strings',
      );

      const expectedAttributeIcons = <String, List<IconData>>{
        'tactics': _fourFullOneHalf,
        'motivation': _threeFullTwoEmpty,
      };
      for (final name in _uiRelevantAttributeNames[StaffRole.headCoach]!) {
        final prefix = 'staff-attribute-${occupied.id}-$name';
        expect(_attributeFinder(prefix), findsOneWidget);
        expect(
          _iconsForPrefix(tester, prefix),
          expectedAttributeIcons[name],
          reason: '$name must use the same five-position renderer',
        );
        expect(find.text(_uiAttributeLabels[name]!), findsOneWidget);
      }
      expect(
        _attributeFinder('staff-attribute-${occupied.id}-development'),
        findsNothing,
        reason: 'headCoach offer preview must exclude legacy Development',
      );
      expect(find.text('Rozwój'), findsNothing);
      semanticsHandle.dispose();
    },
  );

  testWidgets(
    'StaffScreen offer editor exposes only canonical attributes for every role',
    (tester) async {
      final candidates = [
        for (final role in StaffRole.values)
          staffMemberFor(
            role,
            attributes: staffAttributesWithRawOverall(
              role,
              3.0,
              irrelevantValue: 5.0,
            ),
            id: 'ui-offer-${role.name}',
            name: 'UI Offer ${role.name}',
          ),
      ];
      final league = staffFixtureLeague(staffFreeAgents: candidates);

      await tester.pumpWidget(_app(const StaffScreen(), league));
      await tester.pumpAndSettle();

      for (final candidate in candidates) {
        await _scrollToText(tester, candidate.name);
        await tester.tap(find.text(candidate.name));
        await tester.pump();
        await _scrollToText(tester, 'Podgląd oferty: ${candidate.name}');
        await tester.pump();

        final expectedNames = _uiRelevantAttributeNames[candidate.role]!;
        expect(
          expectedNames,
          isNotEmpty,
          reason: 'the fixture must cover ${candidate.role.name}',
        );
        expect(find.text('Podgląd oferty: ${candidate.name}'), findsOneWidget);
        for (final name in expectedNames) {
          final prefix = 'staff-attribute-${candidate.id}-$name';
          expect(
            _attributeFinder(prefix),
            findsOneWidget,
            reason: '${candidate.role.name} offer preview omitted $name',
          );
          expect(
            _iconsForPrefix(tester, prefix),
            _threeFullTwoEmpty,
            reason: '$name must render five graphical positions',
          );
          expect(find.text(_uiAttributeLabels[name]!), findsOneWidget);
        }
        for (final name in _allUiAttributeNames) {
          final prefix = 'staff-attribute-${candidate.id}-$name';
          if (!expectedNames.contains(name)) {
            expect(
              _attributeFinder(prefix),
              findsNothing,
              reason:
                  '${candidate.role.name} offer preview leaked irrelevant $name',
            );
          }
        }
      }
    },
  );

  testWidgets(
    'StaffScreen and FreeAgencyScreen preserve raw/id order and displayed stars',
    (tester) async {
      final league = _candidateLeague();
      const expectedOrder = [
        'UI Scout tie A',
        'UI Scout tie B',
        'UI Scout raw 3.30',
        'UI Scout raw 3.26',
      ];
      final names = expectedOrder.toSet();

      for (final screen in const [StaffScreen(), FreeAgencyScreen()]) {
        await tester.pumpWidget(_app(screen, league));
        await tester.pumpAndSettle();
        await _scrollToText(tester, 'UI Scout raw 3.26');

        expect(
          _candidateNamesInTiles(tester, names),
          expectedOrder,
          reason:
              'both screens must use descending RawOverall and ascending ID '
              'for equal raw values',
        );
        expect(
          _iconsForPrefix(tester, 'staff-candidate-rating-ui-scout-330'),
          _threeFullOneHalfOneEmpty,
          reason: 'raw 3.30 must display 3.5, not a text rating',
        );
        expect(
          _iconsForPrefix(tester, 'staff-candidate-rating-ui-scout-326'),
          _threeFullOneHalfOneEmpty,
          reason: 'raw 3.26 shares the 3.5 displayed bucket',
        );
        expect(
          tester.getSemantics(
            find.byKey(
              const ValueKey<String>(
                'staff-candidate-rating-ui-scout-326-semantics',
              ),
            ),
          ),
          matchesSemantics(label: 'Rating 3.5 out of 5'),
          reason: 'semantics must expose DisplayedRating, not raw 3.26',
        );
        expect(find.textContaining('★'), findsNothing);
      }
    },
  );

  testWidgets(
    'staff contract actions are enabled in an open window and disabled when unavailable',
    (tester) async {
      for (final screen in const [StaffScreen(), FreeAgencyScreen()]) {
        final activeLeague = _candidateLeague();
        await tester.pumpWidget(_app(screen, activeLeague));
        await tester.pumpAndSettle();
        await _scrollToText(tester, 'UI Scout raw 3.26');

        final activeLabel = screen is StaffScreen
            ? 'Zatrudnij'
            : 'Złóż ofertę sztabowi';
        final activeButtons = tester
            .widgetList<FilledButton>(
              find.widgetWithText(FilledButton, activeLabel),
            )
            .toList();
        expect(activeButtons, hasLength(4));
        expect(
          activeButtons.every((button) => button.onPressed != null),
          isTrue,
          reason: '$activeLabel must be active during free-agency phase I',
        );

        final usedHourLeague = _candidateLeague(hourlyStaffOfferUsed: true);
        await tester.pumpWidget(_app(screen, usedHourLeague));
        await tester.pumpAndSettle();
        await _scrollToText(tester, 'UI Scout raw 3.26');
        final disabledButtons = tester
            .widgetList<FilledButton>(
              find.widgetWithText(FilledButton, activeLabel),
            )
            .toList();
        expect(disabledButtons, hasLength(4));
        expect(
          disabledButtons.every((button) => button.onPressed == null),
          isTrue,
          reason: '$activeLabel must be disabled after the hourly staff offer',
        );
      }

      final candidate = staffMemberFor(
        StaffRole.scout,
        relevantValues: [3.0, 3.0],
        id: 'ui-unavailable-candidate',
        name: 'UI Unavailable Candidate',
      );
      final mismatched = staffMemberFor(
        StaffRole.doctor,
        relevantValues: [3.0, 3.0],
        id: 'ui-unavailable-slot-member',
        name: 'UI Unavailable Slot Member',
      );
      final unavailableLeague = staffFixtureLeague(
        teams: [
          staffFixtureTeam(staff: teamStaffOf({StaffRole.scout: mismatched})),
        ],
        staffFreeAgents: [candidate],
      );

      await tester.pumpWidget(
        _app(const FreeAgencyScreen(), unavailableLeague),
      );
      await tester.pumpAndSettle();
      await _scrollToText(tester, candidate.name);
      final unavailableButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Złóż ofertę sztabowi'),
      );
      expect(
        unavailableButton.onPressed,
        isNull,
        reason: 'a role/slot mismatch must disable the FreeAgency action',
      );

      await tester.pumpWidget(_app(const StaffScreen(), unavailableLeague));
      await tester.pumpAndSettle();
      await _scrollToText(tester, '—');
      expect(
        find.byKey(const ValueKey<String>('staff-slot-rating-scout-empty')),
        findsOneWidget,
        reason: 'StaffScreen must retain the unavailable slot state',
      );
      expect(
        find.byKey(const ValueKey<String>('staff-slot-rating-scout-star-0')),
        findsNothing,
        reason: 'unavailable StaffScreen slots must not render stars',
      );
      expect(
        find.widgetWithText(FilledButton, 'Zatrudnij'),
        findsNothing,
        reason: 'StaffScreen must not offer a mismatched occupied slot',
      );
    },
  );
}

List<IconData> _iconsForPrefix(WidgetTester tester, String prefix) {
  final row = find.byWidgetPredicate(
    (widget) => widget is Row && widget.key == ValueKey<String>(prefix),
  );
  expect(row, findsOneWidget, reason: 'missing graphic star row $prefix');
  return tester
      .widgetList<Icon>(find.descendant(of: row, matching: find.byType(Icon)))
      .map((icon) => icon.icon!)
      .toList(growable: false);
}

Finder _attributeFinder(String prefix) => find.byWidgetPredicate(
  (widget) =>
      widget is StaffAttributeStars && widget.key == ValueKey<String>(prefix),
);

List<String> _candidateNamesInTiles(
  WidgetTester tester,
  Set<String> expectedNames,
) => tester
    .widgetList<ListTile>(find.byType(ListTile))
    .map((tile) => tile.title)
    .whereType<Text>()
    .map((title) => title.data)
    .whereType<String>()
    .where((name) => expectedNames.contains(name))
    .toList(growable: false);

LeagueState _candidateLeague({bool hourlyStaffOfferUsed = false}) {
  final candidates = <StaffMember>[
    staffMemberFor(
      StaffRole.scout,
      relevantValues: [3.26, 3.26],
      id: 'ui-scout-326',
      name: 'UI Scout raw 3.26',
    ),
    staffMemberFor(
      StaffRole.scout,
      relevantValues: [4.0, 4.0],
      id: 'ui-scout-tie-b',
      name: 'UI Scout tie B',
    ),
    staffMemberFor(
      StaffRole.scout,
      relevantValues: [3.30, 3.30],
      id: 'ui-scout-330',
      name: 'UI Scout raw 3.30',
    ),
    staffMemberFor(
      StaffRole.scout,
      relevantValues: [4.0, 4.0],
      id: 'ui-scout-tie-a',
      name: 'UI Scout tie A',
    ),
  ];
  return staffFixtureLeague(
    staffFreeAgents: candidates,
    hourlyStaffOfferUsed: hourlyStaffOfferUsed,
  );
}

Future<void> _scrollToText(WidgetTester tester, String text) async {
  final target = find.text(text);

  // ListView(children: ...) lazily mounts distant sections. Reset to the top
  // first so this helper also works when a previous assertion left the viewport
  // near the offer editor at the bottom.
  for (var attempt = 0; attempt < 12; attempt++) {
    if (target.evaluate().isNotEmpty) break;
    await tester.drag(_verticalScrollable(), const Offset(0, 800));
    await tester.pumpAndSettle();
  }
  for (var attempt = 0; attempt < 40; attempt++) {
    if (target.evaluate().isNotEmpty) break;
    await tester.drag(_verticalScrollable(), const Offset(0, -600));
    await tester.pumpAndSettle();
  }

  expect(target, findsOneWidget, reason: 'could not mount text $text');
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

Finder _verticalScrollable() => find.byWidgetPredicate(
  (widget) =>
      widget is Scrollable && widget.axisDirection == AxisDirection.down,
);

Widget _app(Widget screen, LeagueState league) => ProviderScope(
  overrides: [activeLeagueProvider.overrideWithValue(league)],
  child: MaterialApp(
    locale: const Locale('pl'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: screen,
  ),
);
