part of '../save_management_property_cases.dart';

final Generator<GeneratedRenameCase> generatedRenameCases = any
    .simple<GeneratedRenameCase>(
      generate: (random, size) {
        final snapshot = generateRawSnapshot(random, size);
        final scenario = RenameScenario.values[size % 4];
        late final String proposedName;

        switch (scenario) {
          case RenameScenario.valid:
            proposedName = generatedRawName(random, size, 'renamed');
            break;
          case RenameScenario.whitespaceOnly:
            proposedName = whitespaceOnly(random, size);
            break;
          case RenameScenario.sameName:
            proposedName =
                '${outerWhitespace(random)}'
                '${oracleTrim(snapshot.sourceName).toUpperCase()}'
                '${outerWhitespace(random)}';
            break;
          case RenameScenario.occupiedName:
            proposedName =
                '${outerWhitespace(random)}'
                '${oracleTrim(snapshot.duplicateName).toUpperCase()}'
                '${outerWhitespace(random)}';
            break;
        }

        return GeneratedRenameCase(
          snapshot: snapshot,
          scenario: scenario,
          proposedName: proposedName,
          expectedFailure: switch (scenario) {
            RenameScenario.valid => null,
            RenameScenario.whitespaceOnly => SaveManagementFailure.emptyName,
            RenameScenario.sameName => SaveManagementFailure.sameName,
            RenameScenario.occupiedName => SaveManagementFailure.nameTaken,
          },
        );
      },
      shrink: (input) sync* {
        if (input.snapshot.sourceId == 'p4-source-shrunk') return;
        final snapshot = buildRawSnapshot(
          sourceId: 'p4-source-shrunk',
          duplicateId: 'p4-copy-shrunk',
          sourceName: ' source ',
          duplicateName: 'copy',
          sourceCreatedAt: DateTime.utc(2020, 1, 2, 3, 4),
          sourceUpdatedAt: DateTime.utc(2020, 1, 3, 4, 5),
          duplicateTimestamp: DateTime.utc(2025, 6, 7, 8, 9),
          topLevelSchemaVersion: SaveRepository.currentSchemaVersion + 1,
          metaSchemaVersion: SaveRepository.currentSchemaVersion - 1,
          seasonYear: 2024,
          phase: SeasonPhase.regular,
          playerTeamName: 'Team',
          saveSeed: -17,
          payload: <String, dynamic>{
            'state': <dynamic>['kept', 7],
          },
          unknownMeta: <String, dynamic>{
            'future': <String, dynamic>{'kept': true},
          },
          unknownTopLevel: <String, dynamic>{
            'future': <dynamic>['raw', false],
          },
        );
        final proposedName = switch (input.scenario) {
          RenameScenario.valid => ' renamed ',
          RenameScenario.whitespaceOnly => ' \t\n',
          RenameScenario.sameName => ' SOURCE ',
          RenameScenario.occupiedName => ' COPY ',
        };
        yield GeneratedRenameCase(
          snapshot: snapshot,
          scenario: input.scenario,
          proposedName: proposedName,
          expectedFailure: input.expectedFailure,
        );
      },
    );

enum RenameScenario { valid, whitespaceOnly, sameName, occupiedName }

class GeneratedRenameCase {
  const GeneratedRenameCase({
    required this.snapshot,
    required this.scenario,
    required this.proposedName,
    required this.expectedFailure,
  });

  final GeneratedRawSnapshot snapshot;
  final RenameScenario scenario;
  final String proposedName;
  final SaveManagementFailure? expectedFailure;

  @override
  String toString() =>
      'GeneratedRenameCase('
      'scenario: $scenario, sourceId: ${snapshot.sourceId}, '
      'proposedName: ${proposedName.replaceAll('\n', r'\n')}, '
      'sourceName: ${snapshot.sourceName.replaceAll('\n', r'\n')}, '
      'duplicateName: ${snapshot.duplicateName.replaceAll('\n', r'\n')}, '
      'expectedFailure: $expectedFailure)';
}
