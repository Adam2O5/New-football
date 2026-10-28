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

void main() {
  const propertyFiveTag =
      'Feature: save-management, Property 5: index invariant and list order';
  const batches = 12;
  const runsPerBatch = 10;
  for (var batch = 0; batch < batches; batch++) {
    // **Validates: Requirements 1.10, 2.1, 2.14, 2.15, 3.18, 7.9, 8.10**
    Glados<GeneratedPropertyFiveCase>(
      generatedPropertyFiveCases,
      ExploreConfig(
        numRuns: runsPerBatch,
        initialSize: (8 + batch * runsPerBatch).toDouble(),
        speed: 1,
        random: Random(5 + batch),
      ),
    ).test(
      '$propertyFiveTag batch ${batch + 1}/$batches: $runsPerBatch multi-save '
      'metadata and raw snapshot cases',
      (input) async {
        // Glados may execute asynchronous generated cases concurrently. Each
        // case therefore owns its directory so one case cannot clear another
        // case's canonical files while it is committing duplicate/rename.
        final directory = await Directory.systemTemp.createTemp(
          'nf_save_management_property_five_',
        );
        try {
          await assertPropertyFive(directory: directory, input: input);
        } finally {
          if (await directory.exists()) {
            await directory.delete(recursive: true);
          }
        }
      },
    );
  }
}

Future<void> assertPropertyFive({
  required Directory directory,
  required GeneratedPropertyFiveCase input,
}) async {
  final indexFile = File('${directory.path}/saves_index.json');
  for (final save in input.saves) {
    await File(
      '${directory.path}/${save.id}.json',
    ).writeAsString(jsonEncode(save.rawJson));
  }
  await indexFile.writeAsString(
    jsonEncode([
      for (final index in input.initialIndexOrder)
        cloneJsonMap(input.saves[index].indexMeta),
    ]),
  );

  final repository = SaveRepository(overrideDirectory: directory);
  final service = SaveManagementService(
    repository: SaveManagementRepositoryAdapter(repository),
    clock: () => input.duplicateTimestamp,
    idGenerator: () => input.duplicateId,
  );

  final expectedRawById = <String, Map<String, dynamic>>{
    for (final save in input.saves) save.id: cloneJsonMap(save.rawJson),
  };
  final expectedIndexById = <String, Map<String, dynamic>>{
    for (final save in input.saves) save.id: cloneJsonMap(save.indexMeta),
  };

  // This copy-name oracle is independent from SaveNamePolicy and from the
  // service result. The generated names are deliberately padded so the
  // oracle also proves that persisted display text is trimmed only where the
  // duplicate contract requires it.
  final source = input.saves.singleWhere(
    (save) => save.id == input.duplicateSourceId,
  );
  final suffix = input.locale == 'pl' ? '-kopia' : '-copy';
  final occupiedKeys = <String>{
    for (final save in input.saves) oracleNameKey(save.name),
  };
  final expectedDuplicateName = oracleCopySelection(
    oracleTrim(source.name),
    suffix,
    occupiedKeys,
  ).name;
  final expectedDuplicateRaw = oraclePropertyFiveDuplicateRaw(
    source,
    duplicateId: input.duplicateId,
    duplicateName: expectedDuplicateName,
    duplicateTimestamp: input.duplicateTimestamp,
  );
  final expectedDuplicateIndex = oraclePropertyFiveDuplicateIndex(
    source,
    duplicateId: input.duplicateId,
    duplicateName: expectedDuplicateName,
    duplicateTimestamp: input.duplicateTimestamp,
  );

  expect(input.saves.length, greaterThanOrEqualTo(3));
  expect(
    input.saves.map((save) => save.updatedAt).toSet().length,
    greaterThanOrEqualTo(2),
  );
  expect(
    input.saves
        .where((save) => save.updatedAt == input.saves.first.updatedAt)
        .length,
    greaterThanOrEqualTo(2),
  );
  expect(input.duplicateId, isNot(isIn(expectedIndexById.keys)));
  expect(expectedDuplicateName, startsWith(oracleTrim(source.name)));
  expect(expectedDuplicateName, contains(suffix));

  // The initial state is checked as well as both operation results. This
  // makes the generated index itself an independent multi-save oracle rather
  // than relying only on the post-operation cardinalities.
  await assertPropertyFiveState(
    repository: repository,
    service: service,
    directory: directory,
    expectedRawById: expectedRawById,
    expectedIndexById: expectedIndexById,
    state: 'initial',
  );

  final duplicateResult = await service.duplicate(
    input.duplicateSourceId,
    localeCode: input.locale,
  );
  expect(duplicateResult.isDuplicate, isTrue);
  expect(duplicateResult.meta.toJson(), equals(expectedDuplicateIndex));
  expect(duplicateResult.meta.id, input.duplicateId);
  expect(duplicateResult.meta.name, expectedDuplicateName);
  expect(duplicateResult.meta.createdAt, input.duplicateTimestamp);
  expect(duplicateResult.meta.updatedAt, input.duplicateTimestamp);

  final sourceRawAfterDuplicate = await readRawJsonFile(
    File('${directory.path}/${source.id}.json'),
  );
  final duplicateRawAfterDuplicate = await readRawJsonFile(
    File('${directory.path}/${input.duplicateId}.json'),
  );
  expectPropertyFiveMetaChanges(
    before: source.rawJson,
    after: duplicateRawAfterDuplicate,
    allowed: const {'id', 'name', 'createdAt', 'updatedAt'},
    requiredChanges: const {'id', 'name', 'createdAt'},
    reason: 'duplicate must preserve every non-owned source field',
  );
  expect(sourceRawAfterDuplicate, equals(source.rawJson));
  expect(duplicateRawAfterDuplicate, equals(expectedDuplicateRaw));

  expectedRawById[input.duplicateId] = expectedDuplicateRaw;
  expectedIndexById[input.duplicateId] = expectedDuplicateIndex;
  expect(expectedIndexById.length, input.saves.length + 1);
  expect(
    expectedIndexById.keys.toSet(),
    equals({...input.saves.map((save) => save.id), input.duplicateId}),
  );

  // Duplicate must add exactly one ID and exactly one index entry before the
  // rename is attempted.
  await assertPropertyFiveState(
    repository: repository,
    service: service,
    directory: directory,
    expectedRawById: expectedRawById,
    expectedIndexById: expectedIndexById,
    state: 'after duplicate',
  );

  final renameBefore = cloneJsonMap(expectedRawById[input.renameId]!);
  final expectedRenamedName = oracleTrim(input.proposedName);
  final expectedRenamedRaw = cloneJsonMap(renameBefore);
  final expectedRenamedMeta = Map<String, dynamic>.from(
    expectedRenamedRaw['meta'] as Map,
  )..['name'] = expectedRenamedName;
  expectedRenamedRaw['meta'] = expectedRenamedMeta;
  final expectedRenamedIndex = cloneJsonMap(expectedIndexById[input.renameId]!)
    ..['name'] = expectedRenamedName;

  expect(expectedRenamedName, isNotEmpty);
  expect(
    oracleNameKey(expectedRenamedName),
    isNot(
      isIn(
        expectedIndexById.values.map(
          (meta) => oracleNameKey(meta['name'] as String),
        ),
      ),
    ),
  );

  final renameResult = await service.rename(input.renameId, input.proposedName);
  expect(renameResult.isRename, isTrue);
  expect(renameResult.meta.toJson(), equals(expectedRenamedIndex));
  expect(renameResult.meta.id, input.renameId);
  expect(renameResult.meta.name, expectedRenamedName);
  expect(
    renameResult.meta.createdAt,
    DateTime.parse(
      renameBefore['meta'] is Map
          ? (renameBefore['meta'] as Map)['createdAt'] as String
          : '',
    ),
  );
  expect(
    renameResult.meta.updatedAt,
    DateTime.parse(
      renameBefore['meta'] is Map
          ? (renameBefore['meta'] as Map)['updatedAt'] as String
          : '',
    ),
  );

  final renameAfter = await readRawJsonFile(
    File('${directory.path}/${input.renameId}.json'),
  );
  expectPropertyFiveMetaChanges(
    before: renameBefore,
    after: renameAfter,
    allowed: const {'name'},
    requiredChanges: const {'name'},
    reason: 'rename must preserve ID, timestamps, payload, and metadata',
  );
  expect(renameAfter, equals(expectedRenamedRaw));

  expectedRawById[input.renameId] = expectedRenamedRaw;
  expectedIndexById[input.renameId] = expectedRenamedIndex;

  // Rename must keep the duplicate cardinality and ID set unchanged.
  expect(expectedIndexById.length, input.saves.length + 1);
  expect(
    expectedIndexById.keys.toSet(),
    equals({...input.saves.map((save) => save.id), input.duplicateId}),
  );
  await assertPropertyFiveState(
    repository: repository,
    service: service,
    directory: directory,
    expectedRawById: expectedRawById,
    expectedIndexById: expectedIndexById,
    state: 'after rename',
  );
}

Future<void> assertPropertyFiveState({
  required SaveRepository repository,
  required SaveManagementService service,
  required Directory directory,
  required Map<String, Map<String, dynamic>> expectedRawById,
  required Map<String, Map<String, dynamic>> expectedIndexById,
  required String state,
}) async {
  final index = await readRawIndex(File('${directory.path}/saves_index.json'));
  final indexIds = [for (final entry in index) entry['id']];
  final expectedIds = expectedIndexById.keys.toSet();

  expect(index, hasLength(expectedIds.length), reason: '$state index length');
  expect(indexIds.toSet(), equals(expectedIds), reason: '$state index ID set');
  expect(
    indexIds.toSet().length,
    expectedIds.length,
    reason: '$state index has duplicate IDs',
  );

  for (final id in expectedIds) {
    final matches = index.where((entry) => entry['id'] == id).toList();
    expect(matches, hasLength(1), reason: '$state index exact-once $id');
    expect(
      matches.single,
      equals(expectedIndexById[id]),
      reason: '$state index metadata $id',
    );
  }

  for (final id in expectedIds) {
    final file = File('${directory.path}/$id.json');
    expect(await file.exists(), isTrue, reason: '$state file exists $id');
    final actual = await readRawJsonFile(file);
    final expected = expectedRawById[id]!;
    expect(actual, equals(expected), reason: '$state raw snapshot $id');

    // Keep the required preservation fields explicit in addition to the
    // complete-map oracle, so a future fixture change cannot hide them.
    for (final key in const [
      'schemaVersion',
      'leagueState',
      'saveSeed',
      'futureTopLevel',
    ]) {
      expect(actual[key], equals(expected[key]), reason: '$state $id $key');
    }
    final actualMeta = Map<String, dynamic>.from(actual['meta'] as Map);
    final expectedMeta = Map<String, dynamic>.from(expected['meta'] as Map);
    for (final key in const [
      'id',
      'name',
      'createdAt',
      'updatedAt',
      'seasonYear',
      'phase',
      'playerTeamName',
      'schemaVersion',
      'futureMeta',
    ]) {
      expect(
        actualMeta[key],
        equals(expectedMeta[key]),
        reason: '$state $id meta.$key',
      );
    }
  }

  final listed = await repository.listSaves();
  assertPropertyFiveListOrder(
    listed,
    expectedIndexById,
    '$state repository list',
  );
  final records = await service.listRecords();
  assertPropertyFiveListOrder(
    records.map((record) => record.meta).toList(),
    expectedIndexById,
    '$state service list',
  );
}

void assertPropertyFiveListOrder(
  List<GameSaveMeta> listed,
  Map<String, Map<String, dynamic>> expectedIndexById,
  String reason,
) {
  final expectedIds = expectedIndexById.keys.toSet();
  expect(listed, hasLength(expectedIds.length), reason: '$reason length');
  expect(
    listed.map((meta) => meta.id).toSet(),
    equals(expectedIds),
    reason: '$reason IDs',
  );
  for (final meta in listed) {
    expect(
      meta.toJson(),
      equals(expectedIndexById[meta.id]),
      reason: '$reason metadata ${meta.id}',
    );
  }

  for (var index = 1; index < listed.length; index++) {
    expect(
      !listed[index - 1].updatedAt.isBefore(listed[index].updatedAt),
      isTrue,
      reason: '$reason updatedAt must be descending',
    );
  }

  final expectedBuckets = <String, List<String>>{};
  for (final entry in expectedIndexById.values) {
    final key = propertyFiveTimestampKey(
      DateTime.parse(entry['updatedAt'] as String),
    );
    expectedBuckets
        .putIfAbsent(key, () => <String>[])
        .add(entry['id'] as String);
  }
  final expectedBucketOrder = expectedBuckets.keys.toList()
    ..sort(
      (left, right) => DateTime.parse(right).compareTo(DateTime.parse(left)),
    );

  final actualBuckets = <String, List<String>>{};
  final actualBucketOrder = <String>[];
  for (final meta in listed) {
    final key = propertyFiveTimestampKey(meta.updatedAt);
    if (!actualBuckets.containsKey(key)) actualBucketOrder.add(key);
    actualBuckets.putIfAbsent(key, () => <String>[]).add(meta.id);
  }
  expect(
    actualBucketOrder,
    equals(expectedBucketOrder),
    reason: '$reason timestamp buckets',
  );

  // SaveRepository's comparator returns zero for equal updatedAt values and
  // has no secondary production key. The deterministic oracle therefore
  // orders timestamp buckets descending and canonicalizes IDs inside each
  // equal-time bucket before comparison. This matches repository behavior:
  // every permutation inside a tie bucket has the same valid contract.
  for (final timestamp in expectedBucketOrder) {
    final expectedTieIds = [...expectedBuckets[timestamp]!]..sort();
    final actualTieIds = [...actualBuckets[timestamp]!]..sort();
    expect(
      actualTieIds,
      equals(expectedTieIds),
      reason: '$reason equal-updatedAt tie bucket $timestamp',
    );
  }
}

String propertyFiveTimestampKey(DateTime value) =>
    value.toUtc().toIso8601String();

Map<String, dynamic> oraclePropertyFiveDuplicateRaw(
  GeneratedPropertyFiveSave source, {
  required String duplicateId,
  required String duplicateName,
  required DateTime duplicateTimestamp,
}) {
  final copied = cloneJsonMap(source.rawJson);
  final copiedMeta = Map<String, dynamic>.from(copied['meta'] as Map)
    ..['id'] = duplicateId
    ..['name'] = duplicateName
    ..['createdAt'] = duplicateTimestamp.toIso8601String()
    ..['updatedAt'] = duplicateTimestamp.toIso8601String();
  copied['meta'] = copiedMeta;
  return copied;
}

Map<String, dynamic> oraclePropertyFiveDuplicateIndex(
  GeneratedPropertyFiveSave source, {
  required String duplicateId,
  required String duplicateName,
  required DateTime duplicateTimestamp,
}) {
  return <String, dynamic>{
    ...cloneJsonMap(source.indexMeta),
    'id': duplicateId,
    'name': duplicateName,
    'createdAt': duplicateTimestamp.toIso8601String(),
    'updatedAt': duplicateTimestamp.toIso8601String(),
  };
}

void expectPropertyFiveMetaChanges({
  required Map<String, dynamic> before,
  required Map<String, dynamic> after,
  required Set<String> allowed,
  required Set<String> requiredChanges,
  required String reason,
}) {
  final topLevelKeys = {...before.keys, ...after.keys};
  for (final key in topLevelKeys) {
    if (key == 'meta') continue;
    expect(after[key], equals(before[key]), reason: '$reason top-level $key');
  }

  final beforeMeta = Map<String, dynamic>.from(before['meta'] as Map);
  final afterMeta = Map<String, dynamic>.from(after['meta'] as Map);
  final changedKeys = <String>{};
  for (final key in {...beforeMeta.keys, ...afterMeta.keys}) {
    if (!rawJsonValuesEqual(beforeMeta[key], afterMeta[key])) {
      changedKeys.add(key);
    }
  }
  expect(changedKeys.difference(allowed), isEmpty, reason: reason);
  expect(changedKeys.containsAll(requiredChanges), isTrue, reason: reason);
}
