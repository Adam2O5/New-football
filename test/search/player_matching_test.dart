import 'package:new_football/core/models/search_filters.dart';
import 'package:new_football/core/services/search_filter_matching.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/search_filters_provider.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';

/// A fully-matching default player: no filter dimension should reject it
/// when the corresponding filter is left unset.

PlayerFilterInput _player({
  String? teamId = 'team-1',
  Nationality nationality = Nationality.poland,
  Position position = Position.cm,
  AssignedRole optimalRole = const AssignedRole.cm(),
  double potentialStars = 3.0,
  int age = 25,
  double overall = 75.0,
  double salary = 5000000,
  int contractYearsRemaining = 2,
}) {
  return PlayerFilterInput(
    teamId: teamId,
    nationality: nationality,
    position: position,
    optimalRole: optimalRole,
    potentialStars: potentialStars,
    age: age,
    overall: overall,
    salary: salary,
    contractYearsRemaining: contractYearsRemaining,
  );
}

void main() {
  test(
    'player display rounding and free-agent club selection are unchanged',
    () {
      const player = PlayerFilterInput(
        teamId: null,
        nationality: Nationality.poland,
        position: Position.st,
        optimalRole: AssignedRole.striker(),
        potentialStars: 3.76,
        age: 20,
        overall: 86.4,
        salary: 100,
        contractYearsRemaining: 2,
      );
      const filters = PlayersFilterState(
        position: Position.st,
        potential: RangeFilter(min: 4, max: 4),
        ovr: RangeFilter(min: 86, max: 86),
        age: RangeFilter(min: 20, max: 20),
        salary: RangeFilter(max: 100),
        contractLength: RangeFilter(min: 2),
        clubIds: {PlayersFilterState.noClubSentinel},
      );
      expect(matchesPlayerFilters(player, filters), isTrue);
      expect(
        matchesPlayerFilters(player, filters.copyWith(clubIds: {'team'})),
        isFalse,
      );
      expect(
        matchesPlayerFilters(
          player,
          filters.copyWith(age: const RangeFilter(min: 21)),
        ),
        isFalse,
      );
    },
  );

  group('matchesPlayerFilters', () {
    test('default (unset) filter state matches any player', () {
      expect(
        matchesPlayerFilters(_player(), const PlayersFilterState()),
        isTrue,
      );
    });

    test('nationality filter', () {
      const f = PlayersFilterState(nationality: Nationality.brazil);
      expect(
        matchesPlayerFilters(_player(nationality: Nationality.brazil), f),
        isTrue,
      );
      expect(
        matchesPlayerFilters(_player(nationality: Nationality.poland), f),
        isFalse,
      );
    });

    test('position filter', () {
      const f = PlayersFilterState(position: Position.st);
      expect(matchesPlayerFilters(_player(position: Position.st), f), isTrue);
      expect(matchesPlayerFilters(_player(position: Position.cm), f), isFalse);
    });

    test('optimal role filter', () {
      const f = PlayersFilterState(optimalRole: AssignedRole.striker());
      expect(
        matchesPlayerFilters(
          _player(optimalRole: const AssignedRole.striker()),
          f,
        ),
        isTrue,
      );
      expect(
        matchesPlayerFilters(
          _player(
            optimalRole: const AssignedRole.striker(
              role: StrikerRole.falseNine,
            ),
          ),
          f,
        ),
        isFalse,
      );
      expect(
        matchesPlayerFilters(_player(optimalRole: const AssignedRole.cm()), f),
        isFalse,
      );
    });

    test('potential range filter', () {
      const f = PlayersFilterState(potential: RangeFilter(min: 3, max: 4));
      expect(matchesPlayerFilters(_player(potentialStars: 3.5), f), isTrue);
      expect(matchesPlayerFilters(_player(potentialStars: 3), f), isTrue);
      expect(matchesPlayerFilters(_player(potentialStars: 4), f), isTrue);
      expect(matchesPlayerFilters(_player(potentialStars: 2.5), f), isFalse);
      expect(matchesPlayerFilters(_player(potentialStars: 4.5), f), isFalse);
    });

    test('regression: potential is rounded to the nearest half-star before '
        'comparing, so raw floating-point noise around a whole/half value '
        "doesn't fall just outside the filter", () {
      const f = PlayersFilterState(potential: RangeFilter(min: 4, max: 4));
      expect(matchesPlayerFilters(_player(potentialStars: 4.24), f), isTrue);
      expect(matchesPlayerFilters(_player(potentialStars: 3.76), f), isTrue);
      expect(matchesPlayerFilters(_player(potentialStars: 3.74), f), isFalse);
      expect(matchesPlayerFilters(_player(potentialStars: 4.26), f), isFalse);
    });

    test('age range filter', () {
      const f = PlayersFilterState(age: RangeFilter(min: 20, max: 30));
      expect(matchesPlayerFilters(_player(age: 20), f), isTrue);
      expect(matchesPlayerFilters(_player(age: 30), f), isTrue);
      expect(matchesPlayerFilters(_player(age: 19), f), isFalse);
      expect(matchesPlayerFilters(_player(age: 31), f), isFalse);
    });

    test('ovr range filter', () {
      const f = PlayersFilterState(ovr: RangeFilter(min: 70, max: 90));
      expect(matchesPlayerFilters(_player(overall: 70), f), isTrue);
      expect(matchesPlayerFilters(_player(overall: 90), f), isTrue);
      // .4 rounds down / .6 rounds up, so these land just outside the range
      // even after rounding to the nearest whole point.
      expect(matchesPlayerFilters(_player(overall: 69.4), f), isFalse);
      expect(matchesPlayerFilters(_player(overall: 90.6), f), isFalse);
    });

    test(
      'regression: a fractional overall matching the displayed (rounded) OVR '
      'is included, even right at the filter boundary — reported as '
      '"OVR 86-86 only found one of two 86-OVR players"',
      () {
        const f = PlayersFilterState(ovr: RangeFilter(min: 86, max: 86));
        // Displays as "86 OVR" but the raw value is just past 86 — must
        // still match an "86-86" filter.
        expect(matchesPlayerFilters(_player(overall: 86.4), f), isTrue);
        // Displays as "87 OVR" — must not match.
        expect(matchesPlayerFilters(_player(overall: 86.6), f), isFalse);
      },
    );

    test('salary range filter', () {
      const f = PlayersFilterState(
        salary: RangeFilter(min: 1000000, max: 10000000),
      );
      expect(matchesPlayerFilters(_player(salary: 5000000), f), isTrue);
      expect(matchesPlayerFilters(_player(salary: 999999), f), isFalse);
      expect(matchesPlayerFilters(_player(salary: 10000001), f), isFalse);
    });

    test('contract length range filter', () {
      const f = PlayersFilterState(contractLength: RangeFilter(min: 1, max: 3));
      expect(
        matchesPlayerFilters(_player(contractYearsRemaining: 1), f),
        isTrue,
      );
      expect(
        matchesPlayerFilters(_player(contractYearsRemaining: 3), f),
        isTrue,
      );
      expect(
        matchesPlayerFilters(_player(contractYearsRemaining: 0), f),
        isFalse,
      );
      expect(
        matchesPlayerFilters(_player(contractYearsRemaining: 4), f),
        isFalse,
      );
    });

    group('club filter', () {
      test('empty selection means no restriction', () {
        const f = PlayersFilterState();
        expect(matchesPlayerFilters(_player(teamId: 'team-1'), f), isTrue);
        expect(matchesPlayerFilters(_player(teamId: null), f), isTrue);
      });

      test('matches a selected team, rejects others', () {
        const f = PlayersFilterState(clubIds: {'team-1'});
        expect(matchesPlayerFilters(_player(teamId: 'team-1'), f), isTrue);
        expect(matchesPlayerFilters(_player(teamId: 'team-2'), f), isFalse);
      });

      test('noClubSentinel selects free agents specifically', () {
        final f = const PlayersFilterState(
          clubIds: {PlayersFilterState.noClubSentinel},
        );
        expect(matchesPlayerFilters(_player(teamId: null), f), isTrue);
        expect(matchesPlayerFilters(_player(teamId: 'team-1'), f), isFalse);
      });

      test('a team + noClubSentinel selection includes both', () {
        final f = const PlayersFilterState(
          clubIds: {'team-1', PlayersFilterState.noClubSentinel},
        );
        expect(matchesPlayerFilters(_player(teamId: 'team-1'), f), isTrue);
        expect(matchesPlayerFilters(_player(teamId: null), f), isTrue);
        expect(matchesPlayerFilters(_player(teamId: 'team-2'), f), isFalse);
      });
    });

    test('every filter dimension must pass simultaneously', () {
      const f = PlayersFilterState(
        nationality: Nationality.brazil,
        position: Position.st,
        age: RangeFilter(min: 20, max: 25),
      );
      final almost = _player(
        nationality: Nationality.brazil,
        position: Position.st,
        age: 30,
      );
      expect(matchesPlayerFilters(almost, f), isFalse);
      final full = _player(
        nationality: Nationality.brazil,
        position: Position.st,
        age: 22,
      );
      expect(matchesPlayerFilters(full, f), isTrue);
    });
  });
}
