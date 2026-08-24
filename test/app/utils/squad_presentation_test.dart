import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/app/widgets/tactics/pitch_field.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/player_sort.dart';
import 'package:new_football/core/tactics/position_group.dart';

late Player _templatePlayer;
late Team _templateTeam;

void main() {
  setUpAll(() {
    final game = GameFactory().create(
      const NewGameRequest(
        saveName: 'Squad presentation tests',
        playerTeamId: 'team_europe_0',
        seed: 8101,
      ),
    );
    _templateTeam = game.leagueState.teams.firstWhere(
      (team) => team.id == 'team_europe_0',
    );
    _templatePlayer = _templateTeam.roster.firstWhere(
      (player) => player.position != Position.gk,
    );
  });

  group('roster size presentation', () {
    test(
      'clamps progress and keeps inclusive range state at both endpoints',
      () {
        final below = rosterSizePresentation(count: 19, min: 20, max: 30);
        final minimum = rosterSizePresentation(count: 20, min: 20, max: 30);
        final middle = rosterSizePresentation(count: 25, min: 20, max: 30);
        final maximum = rosterSizePresentation(count: 30, min: 20, max: 30);
        final above = rosterSizePresentation(count: 31, min: 20, max: 30);

        expect(below.clampedProgress, 0);
        expect(below.isInRange, isFalse);
        expect(below.state, RosterSizeState.outOfRange);
        expect(below.iconState, RosterSizeIconState.x);
        expect(below.trackColor, Colors.red);

        expect(minimum.clampedProgress, 0);
        expect(minimum.isInRange, isTrue);
        expect(minimum.state, RosterSizeState.inRange);
        expect(minimum.iconState, RosterSizeIconState.check);
        expect(minimum.trackColor, Colors.green);

        expect(middle.clampedProgress, closeTo(0.5, 0.000001));
        expect(middle.isWithinRange, isTrue);
        expect(middle.semanticState, 'in-range');

        expect(maximum.clampedProgress, 1);
        expect(maximum.isInRange, isTrue);
        expect(maximum.iconToken, 'check');

        expect(above.clampedProgress, 1);
        expect(above.isOutOfRange, isTrue);
        expect(above.state, RosterSizeState.outOfRange);
        expect(above.iconState, RosterSizeIconState.x);
        expect(above.semanticState, 'out-of-range');
      },
    );

    test('handles a degenerate or reversed range without NaN progress', () {
      final atOnlyValue = rosterSizePresentation(count: 7, min: 7, max: 7);
      final belowOnlyValue = rosterSizePresentation(count: 6, min: 7, max: 7);
      final aboveOnlyValue = rosterSizePresentation(count: 8, min: 7, max: 7);
      final reversed = rosterSizePresentation(count: 25, min: 30, max: 20);

      expect(atOnlyValue.clampedProgress, 0);
      expect(atOnlyValue.clampedProgress.isFinite, isTrue);
      expect(atOnlyValue.isInRange, isTrue);
      expect(belowOnlyValue.clampedProgress, 0);
      expect(belowOnlyValue.isInRange, isFalse);
      expect(aboveOnlyValue.clampedProgress, 1);
      expect(aboveOnlyValue.isInRange, isFalse);
      expect(reversed.clampedProgress, 0);
      expect(reversed.clampedProgress.isFinite, isTrue);
      expect(reversed.isInRange, isFalse);
    });
  });

  group('name presentation', () {
    test('normalizes whitespace-only and multi-part names', () {
      final empty = splitPlayerName(' \t\n  ');
      final single = splitPlayerName('  Pelé  ');
      final multi = splitPlayerName('  Ada\t Lovelace   Byron  ');

      expect(empty.firstLine, isEmpty);
      expect(empty.secondLine, isEmpty);
      expect(empty.original, ' \t\n  ');

      expect(single.firstLine, 'Pelé');
      expect(single.secondLine, isEmpty);
      expect(single.hasSecondLine, isFalse);

      expect(multi.firstLine, 'Ada');
      expect(multi.secondLine, 'Lovelace Byron');
      expect(multi.normalized, 'Ada Lovelace Byron');
    });
  });

  group('OVR and form color presentation', () {
    test('uses exact OVR stop colors and clamps both endpoints', () {
      const expected = <int, Color>{
        50: Colors.red,
        60: Colors.orange,
        70: Colors.yellow,
        80: Colors.lightGreen,
        90: Color(0xFF2E7D32),
        99: Colors.blue,
      };

      for (final entry in expected.entries) {
        _expectColor(ovrColorForRoundedValue(entry.key), entry.value);
      }
      expect(ovrColorForRoundedValue(49), Colors.red);
      expect(ovrColorForRoundedValue(100), Colors.blue);
      expect(ovrColorForRawValue(49.5), Colors.red);
      expect(ovrColorForRawValue(120), Colors.blue);
    });

    test(
      'uses exact form stop colors, clamped values, and proportional fill',
      () {
        final expected = <double, Color>{
          1: Colors.red,
          3: Colors.orange,
          5: Colors.yellow,
          7: Colors.lightGreen,
          9: const Color(0xFF2E7D32),
          10: Colors.blue,
        };

        for (final entry in expected.entries) {
          _expectColor(formColorForClampedValue(entry.key), entry.value);
        }
        expect(formColorForClampedValue(-2), Colors.red);
        expect(formColorForClampedValue(0), Colors.red);
        expect(formColorForClampedValue(12), Colors.blue);
        expect(clampedFormValue(-2), 0);
        expect(clampedFormValue(12), 10);
        expect(formFillForValue(-2), 0);
        expect(formFillForValue(0), 0);
        expect(formFillForValue(5), closeTo(0.5, 0.000001));
        expect(formFillForValue(10), 1);
        expect(formFillForValue(12), 1);
      },
    );

    test('interpolates channels without mutating the supplied stop order', () {
      final stops = <ColorStop>[
        const ColorStop(value: 60, color: Color(0xFF64C8FF)),
        const ColorStop(value: 50, color: Color(0xFF000000)),
      ];
      final result = interpolateStops(55, stops);

      _expectColor(result, const Color(0xFF326480));
      expect(stops.map((stop) => stop.value), [60, 50]);
    });

    test(
      'rounds finite OVR values half-up and handles non-finite input safely',
      () {
        expect(roundHalfUp(72.49), 72);
        expect(roundHalfUp(72.5), 73);
        expect(roundHalfUp(-72.5), -73);
        expect(roundedOvrForDisplay(69.5), 70);
        expect(roundedOvrForDisplay(double.nan), 50);
        expect(roundedOvrForDisplay(double.negativeInfinity), 50);
        expect(roundedOvrForDisplay(double.infinity), 99);
      },
    );

    test(
      'chooses a foreground with at least 4.5:1 contrast across the OVR range',
      () {
        for (var ovr = 45; ovr <= 104; ovr++) {
          final background = ovrColorForRoundedValue(ovr);
          final foreground = foregroundForContrast(background);

          expect(
            contrastRatio(foreground, background),
            greaterThanOrEqualTo(4.5),
            reason: 'OVR $ovr produced $background with $foreground',
          );
        }
      },
    );
  });

  group('status presentation', () {
    test('covers every injury, suspension, and exact-position combination', () {
      final matchingAssignment = _slot(Position.cm, key: 'matching');
      final mismatchingAssignment = _slot(Position.cdm, key: 'mismatching');

      for (final hasInjury in [false, true]) {
        for (final hasSuspension in [false, true]) {
          for (final hasMismatch in [false, true]) {
            final player = _fixturePlayer(
              id: 'status-$hasInjury-$hasSuspension-$hasMismatch',
              position: Position.cm,
              injury: hasInjury,
              suspension: hasSuspension,
            );
            final assignment = hasMismatch
                ? mismatchingAssignment
                : matchingAssignment;
            final status = statusFor(player, assignment);
            final expectedColor = hasInjury || hasSuspension
                ? Colors.red
                : hasMismatch
                ? Colors.orange
                : Colors.white;

            expect(status.hasActiveInjury, hasInjury);
            expect(status.hasActiveSuspension, hasSuspension);
            expect(status.hasPositionMismatch, hasMismatch);
            expect(statusColorFor(status), expectedColor);
            expect(status.color, expectedColor);
          }
        }
      }
    });

    test(
      'treats missing assignments as no mismatch and compares exact positions',
      () {
        final player = _fixturePlayer(position: Position.cm);
        final sameGroupDifferentPosition = _slot(
          Position.cdm,
          key: 'same-group-mismatch',
        );
        final noAssignment = statusFor(player, null);
        final mismatch = statusFor(player, sameGroupDifferentPosition);

        expect(noAssignment.hasPositionMismatch, isFalse);
        expect(statusColorFor(noAssignment), Colors.white);
        expect(mismatch.hasPositionMismatch, isTrue);
        expect(statusColorFor(mismatch), Colors.orange);
        expect(positionGroupOf(player.position), positionGroupOf(Position.cdm));
      },
    );

    test(
      'retains independent flags when injury and suspension are both active',
      () {
        final status = statusFor(
          _fixturePlayer(injury: true, suspension: true),
          _slot(_templatePlayer.position, key: 'both-statuses'),
        );

        expect(status.hasActiveInjury, isTrue);
        expect(status.hasActiveSuspension, isTrue);
        expect(status.hasAnyStatus, isTrue);
        expect(statusColorFor(status), Colors.red);
      },
    );
  });

  group('roster zones and player snapshots', () {
    test('maps every roster zone to its label and frame color', () {
      const expected = <RosterZone, (String, Color)>{
        RosterZone.xi: ('XI', Colors.green),
        RosterZone.bench: ('Bench', Colors.blue),
        RosterZone.reserve: ('Reserves', Colors.yellow),
      };

      for (final zone in RosterZone.values) {
        final presentation = rosterZonePresentation(zone);
        final expectedValue = expected[zone]!;
        expect(presentation.zone, zone);
        expect(presentation.label, expectedValue.$1);
        expect(presentation.accessibilityLabel, expectedValue.$1);
        expect(presentation.color, expectedValue.$2);
        expect(rosterZoneLabel(zone), expectedValue.$1);
        expect(rosterZoneColor(zone), expectedValue.$2);
      }
    });

    test(
      'derives all zones and preserves XI precedence for duplicate assignment IDs',
      () {
        final player = _fixturePlayer(id: 'zone-player');

        for (final zone in RosterZone.values) {
          final team = _teamFor(
            player,
            lineupPlayerIds: zone == RosterZone.xi ? [player.id] : const [],
            benchPlayerIds: zone == RosterZone.bench ? [player.id] : const [],
          );
          final snapshot = playerPresentation(player: player, team: team);

          expect(snapshot.zone, zone);
          expect(snapshot.zoneLabel, rosterZoneLabel(zone));
        }

        final duplicateTeam = _teamFor(
          player,
          lineupPlayerIds: [player.id],
          benchPlayerIds: [player.id],
        );
        expect(
          playerPresentation(player: player, team: duplicateTeam).zone,
          RosterZone.xi,
        );
      },
    );

    test(
      'builds a snapshot with rounded OVR, clamped form, assignment, and semantics',
      () {
        final player = _fixturePlayer(
          id: 'snapshot-player',
          name: '  First   Middle Last  ',
          form: 14,
          injury: true,
          suspension: true,
          position: Position.cm,
        );
        final team = _teamFor(player, lineupPlayerIds: [player.id]);
        final assignment = _slot(Position.cdm, key: 'snapshot-slot');
        final snapshot = PlayerPresentation.fromPlayer(
          player: player,
          team: team,
          assignment: assignment,
        );

        expect(snapshot.assignment, same(assignment));
        expect(snapshot.nameParts.firstLine, 'First');
        expect(snapshot.nameParts.secondLine, 'Middle Last');
        expect(snapshot.clampedForm, 10);
        expect(snapshot.roundedOvr, roundedOvrForDisplay(player.overall()));
        expect(snapshot.status.hasActiveInjury, isTrue);
        expect(snapshot.status.hasActiveSuspension, isTrue);
        expect(snapshot.positionMismatch, isTrue);
        expect(snapshot.semanticSnapshot.playerName, player.name);
        expect(snapshot.semanticSnapshot.positionCode, player.position.code);
        expect(snapshot.semanticSnapshot.roundedOvr, snapshot.roundedOvr);
        expect(snapshot.semanticSnapshot.clampedForm, 10);
        expect(snapshot.semanticSnapshot.statusTokens, [
          'injury',
          'suspension',
          'position-mismatch',
        ]);
        expect(snapshot.semanticLabel, contains('injury'));
        expect(snapshot.semanticLabel, contains('suspension'));
        expect(snapshot.semanticLabel, contains('position-mismatch'));
      },
    );
  });

  group('assignment projections and immutability', () {
    test(
      'projects only placed players and leaves missing assignments absent',
      () {
        final player = _fixturePlayer(
          id: 'placed-player',
          position: Position.cm,
        );
        final placedSlot = _slot(Position.cm, key: 'placed-slot');
        final emptySlot = _slot(Position.st, key: 'empty-slot');
        final placements = <PlacedPlayer>[
          PlacedPlayer(slot: placedSlot, player: player),
          PlacedPlayer(slot: emptySlot, player: null),
        ];

        final index = PositionAssignmentIndex.fromPlacements(placements);
        final map = assignmentsByPlayerIdFromPlacements(placements);

        expect(index.length, 1);
        expect(index[player.id], same(placedSlot));
        expect(index['missing-player'], isNull);
        expect(index.containsPlayer(player.id), isTrue);
        expect(index.containsPlayer('missing-player'), isFalse);
        expect(map.keys, contains(player.id));
        expect(map.keys, isNot(contains('missing-player')));
      },
    );

    test('uses the direct placement projection for assignment lookup', () {
      final player = _fixturePlayer(id: 'lookup-player', position: Position.cm);
      final slots = <AssignedSlot>[_slot(Position.cm, key: 'cm-slot')];
      final lineupIds = <String>[player.id];
      final playersById = <String, Player>{player.id: player};

      final index = positionAssignmentIndexFor(
        slots: slots,
        lineupPlayerIds: lineupIds,
        playersById: playersById,
      );

      expect(index[player.id]?.key, 'cm-slot');
      expect(
        assignmentsByPlayerIdFor(
          slots: slots,
          lineupPlayerIds: lineupIds,
          playersById: playersById,
        )[player.id]?.position,
        Position.cm,
      );
    });

    test('does not mutate stops, roster, assignment IDs, or player maps', () {
      final playerA = _fixturePlayer(id: 'immutable-a', position: Position.cm);
      final playerB = _fixturePlayer(id: 'immutable-b', position: Position.st);
      final roster = <Player>[playerA, playerB];
      final lineupIds = <String>[playerA.id];
      final benchIds = <String>[playerB.id];
      final playersById = <String, Player>{
        playerA.id: playerA,
        playerB.id: playerB,
      };
      final stops = <ColorStop>[
        const ColorStop(value: 60, color: Colors.orange),
        const ColorStop(value: 50, color: Colors.red),
      ];
      final rosterIdsBefore = roster.map((player) => player.id).toList();
      final lineupBefore = List<String>.from(lineupIds);
      final benchBefore = List<String>.from(benchIds);
      final mapKeysBefore = playersById.keys.toList();
      final stopValuesBefore = stops.map((stop) => stop.value).toList();
      final team = _teamFor(
        playerA,
        lineupPlayerIds: lineupIds,
        benchPlayerIds: benchIds,
      ).copyWith(roster: roster);

      interpolateStops(55, stops);
      positionAssignmentIndexFor(
        slots: FormationLayout.of(Formation.f433).slots,
        lineupPlayerIds: lineupIds,
        playersById: playersById,
      );
      playerPresentationsForRoster(team);

      expect(roster.map((player) => player.id), rosterIdsBefore);
      expect(lineupIds, lineupBefore);
      expect(benchIds, benchBefore);
      expect(playersById.keys, mapKeysBefore);
      expect(stops.map((stop) => stop.value), stopValuesBefore);
    });
  });
}

Player _fixturePlayer({
  String? id,
  String? name,
  Position? position,
  double? form,
  bool injury = false,
  bool suspension = false,
}) {
  return _templatePlayer.copyWith(
    id: id ?? _templatePlayer.id,
    name: name ?? _templatePlayer.name,
    position: position ?? _templatePlayer.position,
    state: _templatePlayer.state.copyWith(
      form: form ?? _templatePlayer.state.form,
      injury: injury
          ? const Injury(
              id: 'squad-presentation-injury',
              group: InjuryGroup.legMuscles,
              type: InjuryType.minor,
              daysTotal: 5,
              daysRemaining: 2,
            )
          : null,
      suspensionGamesRemaining: suspension ? 2 : 0,
    ),
  );
}

Team _teamFor(
  Player player, {
  List<String> lineupPlayerIds = const [],
  List<String> benchPlayerIds = const [],
}) {
  return _templateTeam.copyWith(
    roster: [player],
    lineupPlayerIds: lineupPlayerIds,
    benchPlayerIds: benchPlayerIds,
  );
}

AssignedSlot _slot(Position position, {required String key}) {
  return AssignedSlot(
    key: key,
    position: position,
    group: positionGroupOf(position),
    x: 0.5,
    y: 0.5,
  );
}

void _expectColor(Color actual, Color expected) {
  expect(actual.a, expected.a);
  expect(actual.r, expected.r);
  expect(actual.g, expected.g);
  expect(actual.b, expected.b);
}
