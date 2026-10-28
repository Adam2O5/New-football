part of '../save_management_property_cases.dart';

final Generator<GeneratedRawSnapshot> generatedRawSnapshots = any
    .simple<GeneratedRawSnapshot>(
      generate: generateRawSnapshot,
      shrink: (input) sync* {
        if (input.sourceId != 'p3-source-shrunk') {
          yield buildRawSnapshot(
            sourceId: 'p3-source-shrunk',
            duplicateId: 'p3-copy-shrunk',
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
        }
      },
    );

GeneratedRawSnapshot generateRawSnapshot(Random random, int size) {
  final token = random.nextInt(1 << 30);
  final sourceId = 'p3-source-$size-$token';
  final duplicateId = 'p3-copy-$size-$token';
  final sourceName = generatedRawName(random, size, 'source');
  final duplicateName = generatedRawName(random, size, 'copy');
  final sourceCreatedAt = generatedTimestamp(random);
  final sourceUpdatedAt = sourceCreatedAt.add(
    Duration(minutes: 1 + random.nextInt(1_000_000)),
  );
  var duplicateTimestamp = generatedTimestamp(random);
  if (duplicateTimestamp == sourceCreatedAt ||
      duplicateTimestamp == sourceUpdatedAt) {
    duplicateTimestamp = duplicateTimestamp.add(
      const Duration(microseconds: 1),
    );
  }

  final topLevelSchemaVersion = generatedSchemaVersion(random, size);
  final metaSchemaVersion = generatedSchemaVersion(random, size + 1);
  final playerTeamName = random.nextBool()
      ? generatedRawName(random, size, 'team')
      : null;
  final payloadMarker = random.nextInt(1 << 30);

  return buildRawSnapshot(
    sourceId: sourceId,
    duplicateId: duplicateId,
    sourceName: sourceName,
    duplicateName: duplicateName,
    sourceCreatedAt: sourceCreatedAt,
    sourceUpdatedAt: sourceUpdatedAt,
    duplicateTimestamp: duplicateTimestamp,
    topLevelSchemaVersion: topLevelSchemaVersion,
    metaSchemaVersion: metaSchemaVersion,
    seasonYear: 1900 + random.nextInt(301),
    phase: SeasonPhase.values[random.nextInt(SeasonPhase.values.length)],
    playerTeamName: playerTeamName,
    saveSeed: random.nextInt(1 << 30) - (1 << 29),
    payload: <String, dynamic>{
      'payloadMarker': payloadMarker,
      'nested': <dynamic>[
        sourceName,
        random.nextBool(),
        <String, dynamic>{'keep': random.nextInt(10_000)},
      ],
      'futureLeagueState': <String, dynamic>{
        'schema': topLevelSchemaVersion,
        'marker': '$sourceId-payload',
      },
    },
    unknownMeta: <String, dynamic>{
      'futureMetaMarker': random.nextInt(1 << 20),
      'nested': <dynamic>[
        sourceId,
        metaSchemaVersion,
        <String, dynamic>{'preserve': random.nextBool()},
      ],
    },
    unknownTopLevel: <String, dynamic>{
      'futureTopLevelMarker': random.nextInt(1 << 20),
      'nested': <String, dynamic>{
        'name': sourceName,
        'payloadMarker': payloadMarker,
      },
    },
  );
}

GeneratedRawSnapshot buildRawSnapshot({
  required String sourceId,
  required String duplicateId,
  required String sourceName,
  required String duplicateName,
  required DateTime sourceCreatedAt,
  required DateTime sourceUpdatedAt,
  required DateTime duplicateTimestamp,
  required int topLevelSchemaVersion,
  required int metaSchemaVersion,
  required int seasonYear,
  required SeasonPhase phase,
  required String? playerTeamName,
  required int saveSeed,
  required Map<String, dynamic> payload,
  required Map<String, dynamic> unknownMeta,
  required Map<String, dynamic> unknownTopLevel,
}) {
  final sourceIndexMeta = <String, dynamic>{
    'id': sourceId,
    'name': sourceName,
    'createdAt': sourceCreatedAt.toIso8601String(),
    'updatedAt': sourceUpdatedAt.toIso8601String(),
    'seasonYear': seasonYear,
    'phase': phase.name,
    'playerTeamName': playerTeamName,
    'schemaVersion': metaSchemaVersion,
  };
  final sourceJson = <String, dynamic>{
    'schemaVersion': topLevelSchemaVersion,
    'meta': <String, dynamic>{
      ...sourceIndexMeta,
      'futureMeta': cloneJsonMap(unknownMeta),
    },
    'leagueState': cloneJsonMap(payload),
    'saveSeed': saveSeed,
    'futureTopLevel': cloneJsonMap(unknownTopLevel),
  };
  final duplicateMeta = GameSaveMeta(
    id: duplicateId,
    name: duplicateName,
    createdAt: duplicateTimestamp,
    updatedAt: duplicateTimestamp,
    seasonYear: seasonYear,
    phase: phase,
    playerTeamName: playerTeamName,
    schemaVersion: metaSchemaVersion,
  );

  return GeneratedRawSnapshot(
    sourceId: sourceId,
    duplicateId: duplicateId,
    sourceName: sourceName,
    duplicateName: duplicateName,
    sourceCreatedAt: sourceCreatedAt,
    sourceUpdatedAt: sourceUpdatedAt,
    duplicateTimestamp: duplicateTimestamp,
    sourceJson: sourceJson,
    sourceIndexMeta: sourceIndexMeta,
    duplicateMeta: duplicateMeta,
  );
}

int generatedSchemaVersion(Random random, int size) =>
    SaveRepository.currentSchemaVersion + (size % 3) - 1;

String generatedRawName(Random random, int size, String prefix) {
  final length = 1 + random.nextInt(size.clamp(1, 8));
  final body = StringBuffer();
  for (var index = 0; index < length; index++) {
    final variants = latinUnits[random.nextInt(latinUnits.length)];
    body.write(variants[random.nextInt(variants.length)]);
  }
  return '${outerWhitespace(random)}$prefix-${body.toString()}${outerWhitespace(random)}';
}

DateTime generatedTimestamp(Random random) {
  final year = 1970 + random.nextInt(131);
  final month = 1 + random.nextInt(12);
  final day = 1 + random.nextInt(DateTime.utc(year, month + 1, 0).day);
  return DateTime.utc(
    year,
    month,
    day,
    random.nextInt(24),
    random.nextInt(60),
    random.nextInt(60),
    random.nextInt(1000),
    random.nextInt(1000),
  );
}

class GeneratedRawSnapshot {
  const GeneratedRawSnapshot({
    required this.sourceId,
    required this.duplicateId,
    required this.sourceName,
    required this.duplicateName,
    required this.sourceCreatedAt,
    required this.sourceUpdatedAt,
    required this.duplicateTimestamp,
    required this.sourceJson,
    required this.sourceIndexMeta,
    required this.duplicateMeta,
  });

  final String sourceId;
  final String duplicateId;
  final String sourceName;
  final String duplicateName;
  final DateTime sourceCreatedAt;
  final DateTime sourceUpdatedAt;
  final DateTime duplicateTimestamp;
  final Map<String, dynamic> sourceJson;
  final Map<String, dynamic> sourceIndexMeta;
  final GameSaveMeta duplicateMeta;

  @override
  String toString() =>
      'GeneratedRawSnapshot('
      'sourceId: $sourceId, duplicateId: $duplicateId, '
      'sourceName: ${sourceName.replaceAll('\n', r'\n')}, '
      'duplicateName: ${duplicateName.replaceAll('\n', r'\n')}, '
      'sourceCreatedAt: $sourceCreatedAt, '
      'sourceUpdatedAt: $sourceUpdatedAt, '
      'duplicateTimestamp: $duplicateTimestamp, '
      'sourceJson: $sourceJson)';
}

/// Generates related persisted/candidate names without consulting production
/// code. The exploration size deliberately cycles through four domains so the
