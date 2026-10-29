@Tags(['property'])
library;

import 'package:flutter/material.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, expectLater;
import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import '../../helpers/fixtures/presentation_fixtures.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/player_sort.dart';
import 'package:new_football/core/tactics/position_group.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

const _propertyRuns = 120;
const _propertyNineSeed = 8210;

void main() {
  final propertyNineTemplateTeam = _propertyNineTemplateTeam();
  // Feature: squad-screen-redesign, Property 9: Accessible player summary mirrors active state
  // **Validates: Requirements 11.3, 11.4, 11.6, 11.7, 11.9**
  Glados<_GeneratedPropertyNineCase>(
    _generatedPropertyNineCases(propertyNineTemplateTeam),
    ExploreConfig(
      numRuns: _propertyRuns,
      initialSize: 8,
      speed: 1,
      random: Random(_propertyNineSeed),
    ),
  ).test(
    'Feature: squad-screen-redesign, Property 9: Accessible player summary '
    'mirrors active state for $_propertyRuns generated cases '
    '(seed=$_propertyNineSeed)',
    (input) {
      final reason = input.diagnostics;
      final presentation = input.presentation;
      final snapshot = playerSemanticSnapshot(presentation);
      final status = presentation.status;
      final localizedZone = _propertyNineLocalizedZoneLabel(
        input.l10n,
        snapshot.zone,
      );
      final formText = _propertyNineFormatForm(snapshot.clampedForm);
      final localizedStatusLabels = <String>[
        if (status.hasActiveInjury) input.l10n.squad_statusInjury,
        if (status.hasActiveSuspension) input.l10n.squad_statusSuspension,
        if (status.hasPositionMismatch) input.l10n.squad_positionMismatch,
      ];
      final rowBaseLabel = input.l10n.squad_playerRowSemantics(
        snapshot.playerName,
        snapshot.positionCode,
        snapshot.roundedOvr,
        formText,
        localizedZone,
      );
      final rowLabel = localizedStatusLabels.isEmpty
          ? rowBaseLabel
          : '$rowBaseLabel. ${localizedStatusLabels.join('. ')}.';
      final markerLabel = input.l10n.squad_playerMarkerSemantics(
        snapshot.playerName,
        snapshot.positionCode,
        localizedStatusLabels.join(', '),
      );
      final semanticLabel = presentation.semanticLabel;

      expect(input.localeCode, anyOf('en', 'pl'), reason: reason);
      expect(
        input.l10n.localeName,
        startsWith(input.localeCode),
        reason: reason,
      );
      expect(input.team.roster, hasLength(1), reason: reason);
      expect(
        input.team.roster.single.id,
        snapshot.playerId,
        reason: '$reason presentation must describe the generated team player',
      );
      expect(presentation.zone, input.zone, reason: reason);
      expect(snapshot.zone, input.zone, reason: reason);
      expect(
        snapshot.zoneLabel,
        rosterZoneLabel(input.zone),
        reason: '$reason stable presentation zone label',
      );
      expect(snapshot.playerName, presentation.player.name, reason: reason);
      expect(
        snapshot.position,
        presentation.player.position,
        reason: '$reason exact presentation position',
      );
      expect(
        snapshot.positionCode,
        presentation.player.position.code,
        reason: '$reason exact position code',
      );
      expect(
        snapshot.roundedOvr,
        roundedOvrForDisplay(presentation.player.overall()),
        reason: '$reason rounded OVR must match public presentation API',
      );
      expect(
        snapshot.clampedForm,
        clampedFormValue(presentation.player.state.form),
        reason: '$reason clamped form must match public presentation API',
      );
      expect(
        snapshot.clampedForm,
        allOf(greaterThanOrEqualTo(0.0), lessThanOrEqualTo(10.0), isNotNaN),
        reason: '$reason clamped form must stay on the 0–10 scale',
      );
      expect(
        presentation.assignment?.key,
        input.assignment?.key,
        reason: '$reason assignment key must remain visible to semantics',
      );
      expect(
        status.hasActiveInjury,
        input.hasActiveInjury,
        reason: '$reason injury state must be independently projected',
      );
      expect(
        status.hasActiveSuspension,
        input.hasActiveSuspension,
        reason: '$reason suspension state must be independently projected',
      );
      expect(
        status.hasPositionMismatch,
        input.hasPositionMismatch,
        reason: '$reason mismatch state must use the exact assignment',
      );
      if (input.assignment == null) {
        expect(
          status.hasPositionMismatch,
          isFalse,
          reason: '$reason missing assignment cannot create a mismatch',
        );
      }

      // PlayerPresentation exposes the locale-neutral accessibility snapshot;
      // the generated PL/EN labels below mirror the widget row and marker
      // contracts without depending on private widget implementation details.
      expect(semanticLabel, snapshot.label, reason: reason);
      for (final fragment in [
        snapshot.playerName,
        snapshot.positionCode,
        snapshot.roundedOvr.toString(),
        formText,
        snapshot.zoneLabel,
      ]) {
        expect(
          fragment,
          isNotEmpty,
          reason: '$reason non-empty summary fragment',
        );
        expect(
          semanticLabel,
          contains(fragment),
          reason: '$reason neutral summary fragment $fragment',
        );
      }

      final neutralStatusCases = <(String, bool)>[
        ('injury', status.hasActiveInjury),
        ('suspension', status.hasActiveSuspension),
        ('position-mismatch', status.hasPositionMismatch),
      ];
      for (final (token, active) in neutralStatusCases) {
        expect(
          _propertyNineOccurrenceCount(semanticLabel, token),
          active ? 1 : 0,
          reason:
              '$reason neutral status token $token must mirror active state',
        );
      }

      // The row summary contains the complete localized player data contract.
      expect(rowLabel, contains(snapshot.playerName), reason: reason);
      expect(rowLabel, contains(snapshot.positionCode), reason: reason);
      expect(
        rowLabel,
        contains(snapshot.roundedOvr.toString()),
        reason: '$reason localized row rounded OVR',
      );
      expect(
        rowLabel,
        contains(formText),
        reason: '$reason localized row form',
      );
      expect(
        rowLabel,
        contains(localizedZone),
        reason: '$reason localized row zone',
      );
      expect(
        localizedZone,
        isNotEmpty,
        reason: '$reason generated ${input.localeCode} zone label',
      );
      expect(
        input.l10n.squad_zoneFrameSemantics(localizedZone),
        contains(localizedZone),
        reason: '$reason localized zone frame semantics',
      );
      expect(markerLabel, contains(snapshot.playerName), reason: reason);
      expect(markerLabel, contains(snapshot.positionCode), reason: reason);

      final localizedStatusCases = <(String, bool)>[
        (input.l10n.squad_statusInjury, status.hasActiveInjury),
        (input.l10n.squad_statusSuspension, status.hasActiveSuspension),
        (input.l10n.squad_positionMismatch, status.hasPositionMismatch),
      ];
      for (final (label, active) in localizedStatusCases) {
        expect(label, isNotEmpty, reason: '$reason generated status label');
        final expectedOccurrences = active ? 1 : 0;
        expect(
          _propertyNineOccurrenceCount(rowLabel, label),
          expectedOccurrences,
          reason: '$reason row status $label must match active state',
        );
        expect(
          _propertyNineOccurrenceCount(markerLabel, label),
          expectedOccurrences,
          reason: '$reason marker status $label must match active state',
        );
      }
    },
  );
}

Team _propertyNineTemplateTeam() {
  return presentationTeam();
}

Generator<_GeneratedPropertyNineCase> _generatedPropertyNineCases(
  Team template,
) => any.simple<_GeneratedPropertyNineCase>(
  generate: (random, size) {
    final statusScenario = size % 8;
    final assignmentScenario = (size ~/ 8) % 3;
    final localeCode = size.isEven ? 'en' : 'pl';
    final zone =
        RosterZone.values[(size + random.nextInt(RosterZone.values.length)) %
            RosterZone.values.length];
    final templatePlayer =
        template.roster[random.nextInt(template.roster.length)];
    final token = random.nextInt(1 << 30);
    final player = templatePlayer.copyWith(
      id: 'p9-$size-$token',
      name: 'Property 9 p9-$size-$token',
      state: templatePlayer.state.copyWith(
        form: _propertyNineRawForm(random, size),
        injury: (statusScenario & 1) != 0
            ? const Injury(
                id: 'squad-property-nine-injury',
                group: InjuryGroup.legMuscles,
                type: InjuryType.minor,
                daysTotal: 5,
                daysRemaining: 2,
              )
            : null,
        suspensionGamesRemaining: (statusScenario & 2) != 0 ? 2 : 0,
      ),
    );
    final assignment = switch (assignmentScenario) {
      0 => null,
      1 => _propertyNineAssignedSlot(
        player: player,
        position: player.position,
        size: size,
        token: token,
      ),
      _ => _propertyNineAssignedSlot(
        player: player,
        position: _propertyNineDifferentPosition(player.position),
        size: size,
        token: token,
      ),
    };
    final team = _propertyNineTeamForZone(template, player, zone);
    final presentation = playerPresentation(
      player: player,
      team: team,
      assignment: assignment,
    );
    final hasPositionMismatch =
        assignment != null && player.position != assignment.position;

    return _GeneratedPropertyNineCase(
      team: team,
      presentation: presentation,
      l10n: lookupAppLocalizations(Locale(localeCode)),
      localeCode: localeCode,
      zone: zone,
      assignment: assignment,
      hasActiveInjury: (statusScenario & 1) != 0,
      hasActiveSuspension: (statusScenario & 2) != 0,
      hasPositionMismatch: hasPositionMismatch,
      generationSize: size,
      token: token,
      scenario:
          'locale=$localeCode zone=${zone.name} '
          'assignment=${_propertyNineAssignmentScenarioName(assignmentScenario)} '
          '${_propertyNineStatusScenarioName(statusScenario)}',
      shrunk: false,
    );
  },
  shrink: (input) sync* {
    if (input.shrunk) return;

    final player = input.presentation.player.copyWith(
      id: 'p9-shrunk',
      name: 'Property 9 shrunk',
      state: input.presentation.player.state.copyWith(
        form: 0.0,
        injury: null,
        suspensionGamesRemaining: 0,
      ),
    );
    final team = _propertyNineTeamForZone(
      input.team,
      player,
      RosterZone.reserve,
    );
    yield _GeneratedPropertyNineCase(
      team: team,
      presentation: playerPresentation(
        player: player,
        team: team,
        assignment: null,
      ),
      l10n: lookupAppLocalizations(const Locale('en')),
      localeCode: 'en',
      zone: RosterZone.reserve,
      assignment: null,
      hasActiveInjury: false,
      hasActiveSuspension: false,
      hasPositionMismatch: false,
      generationSize: 0,
      token: 0,
      scenario: 'shrunk-no-assignment',
      shrunk: true,
    );
  },
);

AssignedSlot _propertyNineAssignedSlot({
  required Player player,
  required Position position,
  required int size,
  required int token,
}) => AssignedSlot(
  key: 'p9-slot-$size-$token-${player.id}',
  position: position,
  group: positionGroupOf(position),
  x: 0.5,
  y: 0.5,
);

Position _propertyNineDifferentPosition(Position position) {
  final nextIndex = (position.index + 1) % Position.values.length;
  return Position.values[nextIndex];
}

Team _propertyNineTeamForZone(Team template, Player player, RosterZone zone) =>
    template.copyWith(
      roster: [player],
      lineupPlayerIds: zone == RosterZone.xi ? [player.id] : const <String>[],
      benchPlayerIds: zone == RosterZone.bench ? [player.id] : const <String>[],
    );

double _propertyNineRawForm(Random random, int size) {
  switch (size % 7) {
    case 0:
      return -1.0 - random.nextInt(20);
    case 1:
      return 0.0;
    case 2:
      return random.nextInt(1001) / 100.0;
    case 3:
      return 10.0;
    case 4:
      return 10.0 + random.nextInt(20) + 0.5;
    case 5:
      return 1.0;
    default:
      return random.nextInt(1001) / 100.0;
  }
}

String _propertyNineLocalizedZoneLabel(AppLocalizations l10n, RosterZone zone) {
  switch (zone) {
    case RosterZone.xi:
      return l10n.squad_zoneXi;
    case RosterZone.bench:
      return l10n.squad_zoneBench;
    case RosterZone.reserve:
      return l10n.squad_zoneReserves;
  }
}

String _propertyNineFormatForm(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toString();
}

int _propertyNineOccurrenceCount(String text, String value) {
  if (value.isEmpty) return 0;
  var count = 0;
  var start = 0;
  while (start < text.length) {
    final index = text.indexOf(value, start);
    if (index < 0) break;
    count++;
    start = index + value.length;
  }
  return count;
}

String _propertyNineAssignmentScenarioName(int scenario) => switch (scenario) {
  0 => 'missing',
  1 => 'exact',
  _ => 'mismatch',
};

String _propertyNineStatusScenarioName(int scenario) {
  final injury = (scenario & 1) != 0;
  final suspension = (scenario & 2) != 0;
  final mismatchRequested = (scenario & 4) != 0;
  return 'injury=$injury suspension=$suspension '
      'mismatchRequested=$mismatchRequested';
}

class _GeneratedPropertyNineCase {
  const _GeneratedPropertyNineCase({
    required this.team,
    required this.presentation,
    required this.l10n,
    required this.localeCode,
    required this.zone,
    required this.assignment,
    required this.hasActiveInjury,
    required this.hasActiveSuspension,
    required this.hasPositionMismatch,
    required this.generationSize,
    required this.token,
    required this.scenario,
    required this.shrunk,
  });

  final Team team;
  final PlayerPresentation presentation;
  final AppLocalizations l10n;
  final String localeCode;
  final RosterZone zone;
  final AssignedSlot? assignment;
  final bool hasActiveInjury;
  final bool hasActiveSuspension;
  final bool hasPositionMismatch;
  final int generationSize;
  final int token;
  final String scenario;
  final bool shrunk;

  String get diagnostics {
    final player = presentation.player;
    return 'seed=$_propertyNineSeed generationSize=$generationSize '
        'scenario=$scenario token=$token player=${player.id} '
        'position=${player.position.code} rawForm=${player.state.form} '
        'clampedForm=${presentation.clampedForm} '
        'roundedOvr=${presentation.roundedOvr} '
        'assignment=${assignment?.position.code ?? 'none'}';
  }

  @override
  String toString() => diagnostics;
}
