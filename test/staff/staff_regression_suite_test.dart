@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/free_agency_screen.dart';
import 'package:new_football/app/screens/staff_screen.dart';
import 'package:new_football/app/utils/staff_presentation.dart';
import 'package:new_football/core/ai/ai_contract_market_service.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/staff_service.dart';
import 'package:new_football/data/staff_data_compatibility.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/staff_role_ratings_test_helpers.dart';

/// Final named regression matrix for task 10.1.
///
/// The individual Property 1–12 files remain the exhaustive correctness
/// suites. This file is intentionally a compact, independently named smoke
/// matrix for every Requirement 10.1–10.12, so the final validation command
/// has one stable StaffRegressionSuite entry point as well as the properties.
void main() {
  group('StaffRegressionSuite', () {
    test('Requirements 10.1-10.6: all six role fixtures use RawOverall', () {
      for (final testCase in staffRatingRegressionCases) {
        final member = testCase.member();
        expect(member.overall, testCase.expectedRaw, reason: testCase.label);
        expect(
          member.overall,
          expectedStaffRawOverall(testCase.attributes, testCase.role),
          reason: '${testCase.label}: independent role oracle mismatch',
        );
      }

      const headCoach = StaffAttributes(
        tactics: 4.0,
        motivation: 2.0,
        development: 5.0,
      );
      expect(headCoach.overallForRole(StaffRole.headCoach), 3.0);
      expect(
        headCoach
            .copyWith(development: 0.0)
            .overallForRole(StaffRole.headCoach),
        3.0,
        reason: 'Requirement 10.1: legacy Development must be inert',
      );

      const youthCoach = StaffAttributes(
        development: 4.0,
        mentoring: 2.0,
        tactics: 5.0,
      );
      expect(youthCoach.overallForRole(StaffRole.youthCoach), 3.0);
      expect(
        youthCoach.copyWith(tactics: 0.0).overallForRole(StaffRole.youthCoach),
        3.0,
        reason: 'Requirement 10.2: Tactics must be irrelevant to youthCoach',
      );
    });

    test('Requirements 10.7-10.8: quarter ratings use the graphic rule', () {
      final raw325 = StaffPresentation.viewForMember(
        staffMemberFor(
          StaffRole.headCoach,
          relevantValues: [3.25, 3.25],
          id: 'regression-raw-325',
        ),
      ).rating!;
      expect(raw325.rawOverall, 3.25);
      expect(raw325.displayedRating, 3.5);
      expect(raw325.stars, const [
        GraphicStar.full,
        GraphicStar.full,
        GraphicStar.full,
        GraphicStar.half,
        GraphicStar.empty,
      ]);

      final raw375 = StaffPresentation.viewForMember(
        staffMemberFor(
          StaffRole.headCoach,
          relevantValues: [3.75, 3.75],
          id: 'regression-raw-375',
        ),
      ).rating!;
      expect(raw375.rawOverall, 3.75);
      expect(raw375.displayedRating, 4.0);
      expect(raw375.stars, const [
        GraphicStar.full,
        GraphicStar.full,
        GraphicStar.full,
        GraphicStar.full,
        GraphicStar.empty,
      ]);
    });

    test('Requirement 10.9: irrelevant mutation preserves sorting, contracts, '
        'negotiation and AI classification', () {
      final service = StaffService();
      final base = staffMemberFor(
        StaffRole.headCoach,
        relevantValues: [3.3, 3.3],
        irrelevantValue: 0.0,
        id: 'regression-head-base',
      );
      final mutated = base.copyWith(
        attributes: withIrrelevantStaffAttribute(
          base.attributes,
          base.role,
          value: 5.0,
        ),
      );
      final competitor = staffMemberFor(
        StaffRole.headCoach,
        relevantValues: [3.0, 3.0],
        id: 'regression-head-competitor',
      );
      final offer = staffOfferFor(base, service: service);

      expect(mutated.overall, base.overall);
      expect(
        StaffPresentation.sortStaffCandidates([
          competitor,
          base,
        ], base.role).map((member) => member.id).toList(),
        StaffPresentation.sortStaffCandidates([
          competitor,
          mutated,
        ], base.role).map((member) => member.id).toList(),
      );
      expect(service.marketSalary(mutated), service.marketSalary(base));
      expect(service.staffWant(mutated), service.staffWant(base));
      expect(service.expectedSalary(mutated), service.expectedSalary(base));
      expect(service.expectedLength(mutated), service.expectedLength(base));
      expect(
        service.staffOfferScore(mutated, offer),
        service.staffOfferScore(base, offer),
      );

      final policy = AiContractMarketService();
      final baseLeague = staffFixtureLeague(staffFreeAgents: [base]);
      final mutatedLeague = staffFixtureLeague(staffFreeAgents: [mutated]);
      final baseTeam = baseLeague.playerTeam!;
      final mutatedTeam = mutatedLeague.playerTeam!;
      final basePlan = policy.staffFreeAgentPlan(
        league: baseLeague,
        team: baseTeam,
        saveSeed: staffFixtureSaveSeed,
      );
      final mutatedPlan = policy.staffFreeAgentPlan(
        league: mutatedLeague,
        team: mutatedTeam,
        saveSeed: staffFixtureSaveSeed,
      );
      _expectPlansEqual(mutatedPlan, basePlan);
    });

    test(
      'Requirement 10.10: EmptySlot stays empty and UnknownRole is recoverable',
      () {
        final empty = StaffPresentation.viewForSlot(null, StaffRole.scout);
        expect(empty.state, StaffSlotState.empty);
        expect(empty.rating, isNull);
        expect(empty.stars, isEmpty);

        final mismatch = staffMemberJson(
          role: StaffRole.doctor,
          id: 'regression-role-slot-mismatch',
        );
        final unknown = staffMemberJson(
          role: StaffRole.cfo,
          rawRole: unknownStaffRoleValue,
          id: 'regression-unknown-role',
        );
        final result = StaffDataCompatibility.sanitizeLeagueStateJson({
          'teams': [
            <String, dynamic>{
              'id': 'regression-team',
              'staff': teamStaffJson({StaffRole.headCoach: mismatch}),
            },
          ],
          'staffFreeAgents': [unknown],
        });
        final team =
            (result.sanitizedJson['teams'] as List<dynamic>).single
                as Map<String, dynamic>;
        final staff = team['staff'] as Map<String, dynamic>;
        expect(staff['headCoach'], isNull);
        expect(result.sanitizedJson['staffFreeAgents'], isEmpty);
        expect(
          result.diagnostics.map((diagnostic) => diagnostic.reason),
          containsAll(<String>[
            StaffDataDiagnosticReason.roleSlotMismatch,
            StaffDataDiagnosticReason.unknownRole,
          ]),
        );
      },
    );

    testWidgets(
      'Requirement 10.11: both staff screens render graphical ratings',
      (tester) async {
        final member = staffMemberFor(
          StaffRole.headCoach,
          relevantValues: [2.5, 2.5],
          id: 'regression-screen-member',
          name: 'Regression screen member',
          contract: staffFixtureContract(),
        );
        final candidate = staffMemberFor(
          StaffRole.scout,
          relevantValues: [4.5, 4.5],
          id: 'regression-screen-candidate',
          name: 'Regression screen candidate',
        );
        final league = staffFixtureLeague(
          teams: [
            staffFixtureTeam(staff: teamStaffOf({StaffRole.headCoach: member})),
          ],
          staffFreeAgents: [candidate],
        );

        await tester.pumpWidget(_app(const StaffScreen(), league));
        await tester.pumpAndSettle();
        _expectFiveIcons(tester, 'staff-member-rating-${member.id}');
        await _scrollToText(tester, candidate.name);
        _expectFiveIcons(tester, 'staff-candidate-rating-${candidate.id}');
        expect(find.textContaining('★'), findsNothing);

        await tester.pumpWidget(_app(const FreeAgencyScreen(), league));
        await tester.pumpAndSettle();
        await _scrollToText(tester, candidate.name);
        _expectFiveIcons(tester, 'staff-candidate-rating-${candidate.id}');
        expect(find.textContaining('★'), findsNothing);
      },
    );

    test(
      'Requirement 10.12: canonical map covers six roles without legacy field',
      () {
        expect(StaffRatingSystem.roleRelevantAttributes.keys, StaffRole.values);
        for (final role in StaffRole.values) {
          expect(
            StaffRatingSystem.serializedNamesForRole(role),
            relevantStaffAttributeNames(role),
            reason: '${role.name} diverged from docs/staff.md',
          );
        }
        expect(
          StaffRatingSystem.serializedNamesForRole(StaffRole.headCoach),
          isNot(contains('development')),
        );
        expect(StaffRatingSystem.serializedNamesForRole(StaffRole.physio), [
          'rehabilitation',
          'regenaration',
        ]);
      },
    );
  });
}

void _expectPlansEqual(AiStaffOfferPlan? actual, AiStaffOfferPlan? expected) {
  expect(actual == null, expected == null);
  if (actual == null || expected == null) return;
  expect(actual.member.id, expected.member.id);
  expect(actual.role, expected.role);
  expect(actual.offer.salary, expected.offer.salary);
  expect(actual.offer.years, expected.offer.years);
  expect(actual.offerScore, closeTo(expected.offerScore, 1e-9));
}

void _expectFiveIcons(WidgetTester tester, String prefix) {
  final row = find.byWidgetPredicate(
    (widget) => widget is Row && widget.key == ValueKey<String>(prefix),
  );
  expect(row, findsOneWidget, reason: 'missing graphic rating row $prefix');
  final icons = tester
      .widgetList<Icon>(find.descendant(of: row, matching: find.byType(Icon)))
      .toList(growable: false);
  expect(icons, hasLength(5), reason: 'rating $prefix must have five icons');
}

Future<void> _scrollToText(WidgetTester tester, String text) async {
  final target = find.text(text);
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
