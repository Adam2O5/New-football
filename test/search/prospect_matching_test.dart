import 'package:new_football/core/models/search_filters.dart';
import 'package:new_football/core/services/search_filter_matching.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/search_filters_provider.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';

ProspectFilterInput _prospect({
  Nationality nationality = Nationality.poland,
  Position position = Position.cm,
  AssignedRole optimalRole = const AssignedRole.cm(),
  int age = 19,
  bool roleKnown = true,
  double? estimatedPotentialMin = 2.5,
  double? estimatedPotentialMax = 3.5,
  int? estimatedOvrMin = 65,
  int? estimatedOvrMax = 75,
  int? scoutingTier = 2,
}) {
  return ProspectFilterInput(
    nationality: nationality,
    position: position,
    optimalRole: optimalRole,
    age: age,
    roleKnown: roleKnown,
    estimatedPotentialMin: estimatedPotentialMin,
    estimatedPotentialMax: estimatedPotentialMax,
    estimatedOvrMin: estimatedOvrMin,
    estimatedOvrMax: estimatedOvrMax,
    scoutingTier: scoutingTier,
  );
}

void main() {
  test(
    'prospect unknown roles and overlapping interval boundaries stay stable',
    () {
      const prospect = ProspectFilterInput(
        nationality: Nationality.poland,
        position: Position.st,
        optimalRole: AssignedRole.striker(),
        age: 18,
        roleKnown: false,
        estimatedPotentialMin: 3,
        estimatedPotentialMax: 4,
        estimatedOvrMin: 70,
        estimatedOvrMax: 80,
        scoutingTier: 2,
      );
      expect(
        matchesProspectFilters(
          prospect,
          const ProspectsFilterState(
            potential: RangeFilter(min: 4),
            ovr: RangeFilter(max: 70),
            scoutingTiers: {2},
          ),
        ),
        isTrue,
      );
      expect(
        matchesProspectFilters(
          prospect,
          const ProspectsFilterState(optimalRole: AssignedRole.striker()),
        ),
        isFalse,
      );
      expect(
        matchesProspectFilters(
          prospect,
          const ProspectsFilterState(potential: RangeFilter(min: 4.5)),
        ),
        isFalse,
      );
    },
  );

  group('matchesProspectFilters', () {
    test('default (unset) filter state matches any prospect', () {
      expect(
        matchesProspectFilters(_prospect(), const ProspectsFilterState()),
        isTrue,
      );
    });

    test('nationality filter', () {
      const f = ProspectsFilterState(nationality: Nationality.brazil);
      expect(
        matchesProspectFilters(_prospect(nationality: Nationality.brazil), f),
        isTrue,
      );
      expect(
        matchesProspectFilters(_prospect(nationality: Nationality.poland), f),
        isFalse,
      );
    });

    test('position filter', () {
      const f = ProspectsFilterState(position: Position.st);
      expect(
        matchesProspectFilters(_prospect(position: Position.st), f),
        isTrue,
      );
      expect(
        matchesProspectFilters(_prospect(position: Position.cm), f),
        isFalse,
      );
    });

    group('optimal role filter', () {
      const f = ProspectsFilterState(optimalRole: AssignedRole.striker());

      test('matches only when role is known and equal', () {
        expect(
          matchesProspectFilters(
            _prospect(
              optimalRole: const AssignedRole.striker(),
              roleKnown: true,
            ),
            f,
          ),
          isTrue,
        );
      });

      test('rejects when role matches but is not yet revealed', () {
        expect(
          matchesProspectFilters(
            _prospect(
              optimalRole: const AssignedRole.striker(),
              roleKnown: false,
            ),
            f,
          ),
          isFalse,
        );
      });

      test('rejects when role is known but does not match', () {
        expect(
          matchesProspectFilters(
            _prospect(optimalRole: const AssignedRole.cm(), roleKnown: true),
            f,
          ),
          isFalse,
        );
      });
    });

    group('potential range filter (scout-estimated)', () {
      const f = ProspectsFilterState(potential: RangeFilter(min: 3, max: 4));

      test('excludes prospects the scout has not evaluated', () {
        expect(
          matchesProspectFilters(
            _prospect(estimatedPotentialMin: null, estimatedPotentialMax: null),
            f,
          ),
          isFalse,
        );
      });

      test('matches when the estimated range overlaps the filter', () {
        expect(
          matchesProspectFilters(
            _prospect(estimatedPotentialMin: 3.5, estimatedPotentialMax: 4.5),
            f,
          ),
          isTrue,
        );
      });

      test('rejects when the estimated range does not overlap the filter', () {
        expect(
          matchesProspectFilters(
            _prospect(estimatedPotentialMin: 0.5, estimatedPotentialMax: 1.5),
            f,
          ),
          isFalse,
        );
      });
    });

    test('age range filter', () {
      const f = ProspectsFilterState(age: RangeFilter(min: 18, max: 21));
      expect(matchesProspectFilters(_prospect(age: 18), f), isTrue);
      expect(matchesProspectFilters(_prospect(age: 21), f), isTrue);
      expect(matchesProspectFilters(_prospect(age: 17), f), isFalse);
      expect(matchesProspectFilters(_prospect(age: 22), f), isFalse);
    });

    group('ovr range filter (scout-estimated)', () {
      const f = ProspectsFilterState(ovr: RangeFilter(min: 70, max: 80));

      test('excludes prospects with no scouted ovr range', () {
        expect(
          matchesProspectFilters(
            _prospect(estimatedOvrMin: null, estimatedOvrMax: null),
            f,
          ),
          isFalse,
        );
      });

      test('matches on any overlap with the estimated range', () {
        expect(
          matchesProspectFilters(
            _prospect(estimatedOvrMin: 78, estimatedOvrMax: 85),
            f,
          ),
          isTrue,
        );
      });

      test('rejects a disjoint estimated range', () {
        expect(
          matchesProspectFilters(
            _prospect(estimatedOvrMin: 50, estimatedOvrMax: 60),
            f,
          ),
          isFalse,
        );
      });
    });

    group('scouting tier filter', () {
      test('empty selection means no restriction, even if unscouted', () {
        const f = ProspectsFilterState();
        expect(
          matchesProspectFilters(_prospect(scoutingTier: null), f),
          isTrue,
        );
      });

      test('excludes unscouted prospects once a tier is selected', () {
        const f = ProspectsFilterState(scoutingTiers: {1, 2});
        expect(
          matchesProspectFilters(_prospect(scoutingTier: null), f),
          isFalse,
        );
      });

      test('matches a selected tier, rejects others', () {
        const f = ProspectsFilterState(scoutingTiers: {1, 2});
        expect(matchesProspectFilters(_prospect(scoutingTier: 2), f), isTrue);
        expect(matchesProspectFilters(_prospect(scoutingTier: 4), f), isFalse);
      });
    });
  });
}
