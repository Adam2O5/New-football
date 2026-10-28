@Tags(['property'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, expectLater;
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/services/save_management_service.dart';
import 'package:new_football/data/save_management_repository_adapter.dart';
import 'package:new_football/data/save_repository.dart';

import '../helpers/persistence/save_management_property_cases.dart';

const propertyThreeTag =
    'Feature: save-management, Property 3: duplicate preserves source snapshot';
const propertyThreeRuns = 120;
const propertyFourTag =
    'Feature: save-management, Property 4: rename preserves source snapshot';
const propertyFourRuns = 120;

void main() {
  Directory? propertyThreeDirectory;
  SaveRepository? propertyThreeRepository;
  Glados<GeneratedRawSnapshot>(
    generatedRawSnapshots,
    ExploreConfig(
      numRuns: propertyThreeRuns,
      initialSize: 8,
      speed: 1,
      random: Random(3),
    ),
  ).test(
    '$propertyThreeTag holds for $propertyThreeRuns generated raw snapshots',
    (input) async {
      if (propertyThreeDirectory == null) {
        final directory = await Directory.systemTemp.createTemp(
          'nf_save_management_property_three_',
        );
        propertyThreeDirectory = directory;
        propertyThreeRepository = SaveRepository(overrideDirectory: directory);
        addTearDown(() async {
          if (await directory.exists()) {
            await directory.delete(recursive: true);
          }
        });
      }

      await assertRawDuplicateSnapshot(
        repository: propertyThreeRepository!,
        directory: propertyThreeDirectory!,
        input: input,
      );
    },
  );

  Directory? propertyFourDirectory;
  SaveManagementService? propertyFourService;
  // **Validates: Requirements 3.2, 3.3, 3.10, 3.11, 3.12, 3.13, 3.14, 7.10, 8.6, 8.7**
  Glados<GeneratedRenameCase>(
    generatedRenameCases,
    ExploreConfig(
      numRuns: propertyFourRuns,
      initialSize: 8,
      speed: 1,
      random: Random(4),
    ),
  ).test('$propertyFourTag holds for $propertyFourRuns independently generated '
      'raw snapshots and proposed names', (input) async {
    if (propertyFourDirectory == null) {
      final directory = await Directory.systemTemp.createTemp(
        'nf_save_management_property_four_',
      );
      propertyFourDirectory = directory;
      propertyFourService = SaveManagementService(
        repository: SaveManagementRepositoryAdapter(
          SaveRepository(overrideDirectory: directory),
        ),
      );
      addTearDown(() async {
        if (await directory.exists()) {
          await directory.delete(recursive: true);
        }
      });
    }

    await assertRawRenameSnapshot(
      service: propertyFourService!,
      directory: propertyFourDirectory!,
      input: input,
    );
  });
}

Future<void> assertRawRenameSnapshot({
  required SaveManagementService service,
  required Directory directory,
  required GeneratedRenameCase input,
}) async {
  final snapshot = input.snapshot;
  final sourceFile = File('${directory.path}/${snapshot.sourceId}.json');
  final occupiedFile = File('${directory.path}/${snapshot.duplicateId}.json');
  final indexFile = File('${directory.path}/saves_index.json');

  // Reuse one directory across all generated cases, but reset every
  // canonical path so a prior case cannot affect the fresh index decision.
  for (final file in <File>[sourceFile, occupiedFile]) {
    if (await file.exists()) await file.delete();
  }
  await sourceFile.writeAsString(jsonEncode(snapshot.sourceJson));

  final indexEntries = <Map<String, dynamic>>[
    cloneJsonMap(snapshot.sourceIndexMeta),
  ];
  if (input.scenario == RenameScenario.occupiedName) {
    await occupiedFile.writeAsString(
      jsonEncode(oracleDuplicateSnapshot(snapshot)),
    );
    indexEntries.add(cloneJsonMap(snapshot.duplicateMeta.toJson()));
  }
  await indexFile.writeAsString(jsonEncode(indexEntries));

  final sourceTextBefore = await sourceFile.readAsString();
  final sourceBefore = cloneJsonMap(snapshot.sourceJson);
  final occupiedTextBefore = input.scenario == RenameScenario.occupiedName
      ? await occupiedFile.readAsString()
      : null;
  final occupiedBefore = input.scenario == RenameScenario.occupiedName
      ? await readRawJsonFile(occupiedFile)
      : null;
  final indexBefore = await readRawIndex(indexFile);
  final recordsBefore = await service.listRecords();
  final sourceRecordBefore = recordsBefore.singleWhere(
    (record) => record.meta.id == snapshot.sourceId,
  );
  final expectedCompatibility = oracleCompatibility(
    (snapshot.sourceIndexMeta['schemaVersion'] as num).toInt(),
  );

  expect(sourceRecordBefore.meta.toJson(), equals(snapshot.sourceIndexMeta));
  expect(sourceRecordBefore.compatibility, expectedCompatibility);
  expect(sourceRecordBefore.serializedFileAvailable, isTrue);

  final expectedName = oracleTrim(input.proposedName);
  if (input.scenario == RenameScenario.valid) {
    expect(expectedName, isNotEmpty);
    expect(
      oracleNameKey(input.proposedName),
      isNot(oracleNameKey(snapshot.sourceName)),
    );

    final result = await service.rename(snapshot.sourceId, input.proposedName);
    expect(result.isRename, isTrue);

    // The expected raw snapshot and index metadata are built by changing only
    // the contract-owned name field; no production serializer or rename
    // method is used to calculate either oracle.
    final expectedJson = oracleRenamedSnapshot(snapshot, expectedName);
    final expectedIndexMeta = oracleRenamedIndexMeta(snapshot, expectedName);
    expect(result.meta.toJson(), equals(expectedIndexMeta));

    final renamedJson = await readRawJsonFile(sourceFile);
    expect(renamedJson, equals(expectedJson));

    final sourceMeta = Map<String, dynamic>.from(sourceBefore['meta'] as Map);
    final renamedMeta = Map<String, dynamic>.from(renamedJson['meta'] as Map);
    final changedKeys = <String>{};
    for (final key in {...sourceMeta.keys, ...renamedMeta.keys}) {
      if (!rawJsonValuesEqual(sourceMeta[key], renamedMeta[key])) {
        changedKeys.add(key);
      }
    }
    expect(changedKeys, equals({'name'}));

    // Keep the preservation guarantees explicit in addition to the complete
    // raw-map oracle above: payload, both schema locations, timestamps, and
    // known and unknown metadata all survive the rename byte-for-byte.
    expect(renamedJson['schemaVersion'], sourceBefore['schemaVersion']);
    expect(renamedJson['leagueState'], sourceBefore['leagueState']);
    expect(renamedJson['saveSeed'], sourceBefore['saveSeed']);
    expect(renamedJson['futureTopLevel'], sourceBefore['futureTopLevel']);
    for (final key in const [
      'id',
      'createdAt',
      'updatedAt',
      'seasonYear',
      'phase',
      'playerTeamName',
      'schemaVersion',
      'futureMeta',
    ]) {
      expect(renamedMeta[key], sourceMeta[key]);
    }
    expect(renamedMeta['name'], expectedName);

    final renamedIndex = await readRawIndex(indexFile);
    expect(renamedIndex, hasLength(1));
    final matchingIndex = renamedIndex
        .where((entry) => entry['id'] == snapshot.sourceId)
        .toList();
    expect(matchingIndex, hasLength(1));
    expect(matchingIndex.single, equals(expectedIndexMeta));
    expect(
      renamedIndex.map((entry) => entry['id']).toSet(),
      equals({snapshot.sourceId}),
    );
    expect(await occupiedFile.exists(), isFalse);

    final recordsAfter = await service.listRecords();
    expect(recordsAfter, hasLength(1));
    final sourceRecordAfter = recordsAfter.single;
    expect(sourceRecordAfter.meta.toJson(), equals(expectedIndexMeta));
    expect(sourceRecordAfter.meta.id, sourceRecordBefore.meta.id);
    expect(sourceRecordAfter.meta.createdAt, sourceRecordBefore.meta.createdAt);
    expect(sourceRecordAfter.meta.updatedAt, sourceRecordBefore.meta.updatedAt);
    expect(
      sourceRecordAfter.meta.schemaVersion,
      sourceRecordBefore.meta.schemaVersion,
    );
    expect(sourceRecordAfter.meta.name, expectedName);
    expect(sourceRecordAfter.compatibility, sourceRecordBefore.compatibility);
    expect(sourceRecordAfter.compatibility, expectedCompatibility);
    expect(sourceRecordAfter.serializedFileAvailable, isTrue);
    return;
  }

  final expectedFailure = input.expectedFailure!;
  switch (input.scenario) {
    case RenameScenario.whitespaceOnly:
      expect(expectedName, isEmpty);
      break;
    case RenameScenario.sameName:
      expect(expectedName, isNotEmpty);
      expect(
        oracleNameKey(input.proposedName),
        oracleNameKey(snapshot.sourceName),
      );
      break;
    case RenameScenario.occupiedName:
      expect(expectedName, isNotEmpty);
      expect(
        oracleNameKey(input.proposedName),
        oracleNameKey(snapshot.duplicateName),
      );
      expect(
        oracleNameKey(input.proposedName),
        isNot(oracleNameKey(snapshot.sourceName)),
      );
      break;
    case RenameScenario.valid:
      fail('valid rename case must be handled before failure cases');
  }

  // A rejected validation must never produce a SaveManagementResult. The
  // typed failure is checked independently of repository error text.
  await expectLater(
    service.rename(snapshot.sourceId, input.proposedName),
    throwsA(
      isA<SaveManagementException>().having(
        (error) => error.code,
        'code',
        expectedFailure,
      ),
    ),
  );

  expect(await sourceFile.readAsString(), sourceTextBefore);
  expect(await readRawJsonFile(sourceFile), equals(sourceBefore));
  expect(await readRawIndex(indexFile), equals(indexBefore));
  if (input.scenario == RenameScenario.occupiedName) {
    expect(await occupiedFile.readAsString(), occupiedTextBefore);
    expect(await readRawJsonFile(occupiedFile), equals(occupiedBefore));
  } else {
    expect(await occupiedFile.exists(), isFalse);
  }

  final recordsAfter = await service.listRecords();
  expect(recordsAfter, equals(recordsBefore));
}

Map<String, dynamic> oracleRenamedSnapshot(
  GeneratedRawSnapshot snapshot,
  String expectedName,
) {
  final source = cloneJsonMap(snapshot.sourceJson);
  final renamedMeta = Map<String, dynamic>.from(source['meta'] as Map)
    ..['name'] = expectedName;
  return <String, dynamic>{...source, 'meta': renamedMeta};
}

Map<String, dynamic> oracleRenamedIndexMeta(
  GeneratedRawSnapshot snapshot,
  String expectedName,
) {
  return <String, dynamic>{
    ...cloneJsonMap(snapshot.sourceIndexMeta),
    'name': expectedName,
  };
}

SaveCompatibility oracleCompatibility(int schemaVersion) {
  if (schemaVersion == SaveRepository.currentSchemaVersion) {
    return SaveCompatibility.compatible;
  }
  return schemaVersion < SaveRepository.currentSchemaVersion
      ? SaveCompatibility.older
      : SaveCompatibility.newer;
}

Future<void> assertRawDuplicateSnapshot({
  required SaveRepository repository,
  required Directory directory,
  required GeneratedRawSnapshot input,
}) async {
  final sourceFile = File('${directory.path}/${input.sourceId}.json');
  final duplicateFile = File('${directory.path}/${input.duplicateId}.json');
  final indexFile = File('${directory.path}/saves_index.json');

  // Reuse one directory across all Glados cases while ensuring an old
  // duplicate ID can never make a generated case fail for the wrong reason.
  if (await duplicateFile.exists()) await duplicateFile.delete();
  await sourceFile.writeAsString(jsonEncode(input.sourceJson));
  await indexFile.writeAsString(jsonEncode([input.sourceIndexMeta]));

  final sourceTextBefore = await sourceFile.readAsString();
  final sourceBefore = cloneJsonMap(input.sourceJson);
  final returned = await repository.duplicateRaw(
    sourceId: input.sourceId,
    duplicateMeta: input.duplicateMeta,
  );

  expect(returned, input.duplicateMeta);
  expect(await duplicateFile.exists(), isTrue);

  // The oracle starts with the generated source map and changes only the four
  // fields named by the duplicate contract. It does not call duplicateRaw or
  // any serializer to calculate the expected copied snapshot.
  final duplicateJson = await readRawJsonFile(duplicateFile);
  expect(duplicateJson, equals(oracleDuplicateSnapshot(input)));

  final sourceAfter = await readRawJsonFile(sourceFile);
  expect(sourceAfter, equals(sourceBefore));
  expect(await sourceFile.readAsString(), sourceTextBefore);

  final sourceMeta = Map<String, dynamic>.from(input.sourceJson['meta'] as Map);
  final copiedMeta = Map<String, dynamic>.from(duplicateJson['meta'] as Map);
  const duplicateOwnedFields = <String>{'id', 'name', 'createdAt', 'updatedAt'};
  final changedKeys = <String>{};
  for (final key in {...sourceMeta.keys, ...copiedMeta.keys}) {
    if (!rawJsonValuesEqual(sourceMeta[key], copiedMeta[key])) {
      changedKeys.add(key);
    }
  }
  expect(changedKeys, equals(duplicateOwnedFields));

  expect(input.duplicateId, isNot(input.sourceId));
  expect(input.duplicateName, isNot(input.sourceName));
  expect(copiedMeta['id'], input.duplicateId);
  expect(copiedMeta['name'], input.duplicateName);
  expect(copiedMeta['createdAt'], input.duplicateTimestamp.toIso8601String());
  expect(copiedMeta['updatedAt'], input.duplicateTimestamp.toIso8601String());
  expect(copiedMeta['createdAt'], copiedMeta['updatedAt']);
  expect(copiedMeta['createdAt'], isNot(sourceMeta['createdAt']));
  expect(copiedMeta['updatedAt'], isNot(sourceMeta['updatedAt']));

  for (final key in sourceMeta.keys) {
    if (!duplicateOwnedFields.contains(key)) {
      expect(copiedMeta[key], equals(sourceMeta[key]));
    }
  }

  // Explicitly name the payload, persistent schema, and unknown raw fields in
  // addition to the complete-map oracle above so each preservation guarantee
  // remains visible if the fixture grows new fields later.
  expect(duplicateJson['leagueState'], equals(input.sourceJson['leagueState']));
  expect(duplicateJson['saveSeed'], input.sourceJson['saveSeed']);
  expect(duplicateJson['schemaVersion'], input.sourceJson['schemaVersion']);
  expect(
    duplicateJson['futureTopLevel'],
    equals(input.sourceJson['futureTopLevel']),
  );
  expect(copiedMeta['futureMeta'], equals(sourceMeta['futureMeta']));

  final index = await readRawIndex(indexFile);
  expect(index, hasLength(2));
  final indexIds = index.map((entry) => entry['id']).toSet();
  expect(indexIds, equals({input.sourceId, input.duplicateId}));
  expect(index.where((entry) => entry['id'] == input.sourceId), hasLength(1));
  expect(
    index.where((entry) => entry['id'] == input.duplicateId),
    hasLength(1),
  );
  expect(
    index.singleWhere((entry) => entry['id'] == input.sourceId),
    equals(input.sourceIndexMeta),
  );
  expect(
    index.singleWhere((entry) => entry['id'] == input.duplicateId),
    equals(oracleDuplicateIndexMeta(input)),
  );
}
