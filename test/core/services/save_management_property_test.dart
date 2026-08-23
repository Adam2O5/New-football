@Tags(['property'])
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, expectLater;
import 'package:new_football/app/utils/save_formatters.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/core/services/save_management_service.dart';
import 'package:new_football/core/services/save_name_policy.dart';
import 'package:new_football/data/save_repository.dart';

const _propertyTag =
    'Feature: save-management, Property 1: stable Name_Key and name validation';
const _propertyRuns = 120;
const _propertyTwoTag =
    'Feature: save-management, Property 2: smallest free copy suffix';
const _propertyTwoRuns = 120;
const _propertyThreeTag =
    'Feature: save-management, Property 3: duplicate preserves source snapshot';
const _propertyThreeRuns = 120;
const _propertyFourTag =
    'Feature: save-management, Property 4: rename preserves source snapshot';
const _propertyFourRuns = 120;

void main() {
  // **Validates: Requirements 3.2, 3.3, 3.4, 8.21, 8.22, 8.23**
  Glados<_GeneratedName>(
    _generatedNames,
    ExploreConfig(
      numRuns: _propertyRuns,
      initialSize: 8,
      speed: 1,
      random: Random(1),
    ),
  ).test(
    '$_propertyTag holds for $_propertyRuns independently generated inputs',
    (input) {
      final persistedBefore = input.persistedName;
      final equivalentBefore = input.equivalentName;
      final trimmedPersisted = _oracleTrim(input.persistedName);
      final trimmedEquivalent = _oracleTrim(input.equivalentName);

      if (input.whitespaceOnly) {
        expect(trimmedPersisted, isEmpty);
        expect(trimmedEquivalent, isEmpty);
        expect(SaveNamePolicy.trimName(input.persistedName), isEmpty);
        expect(SaveNamePolicy.trimName(input.equivalentName), isEmpty);
        expect(
          () => SaveNamePolicy.nameKey(input.persistedName),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => SaveNamePolicy.nameKey(input.equivalentName),
          throwsA(isA<ArgumentError>()),
        );

        // The policy validates the candidate but does not mutate the value
        // that would remain persisted by the caller.
        expect(input.persistedName, persistedBefore);
        expect(input.equivalentName, equivalentBefore);
        return;
      }

      expect(trimmedPersisted, isNotEmpty);
      expect(trimmedEquivalent, isNotEmpty);
      expect(SaveNamePolicy.trimName(input.persistedName), trimmedPersisted);
      expect(SaveNamePolicy.trimName(input.equivalentName), trimmedEquivalent);

      // The expected key is rebuilt from the generated text, independently
      // from SaveNamePolicy's canonicalization table and implementation.
      final expectedKey = _oracleNameKey(input.persistedName);
      final expectedEquivalentKey = _oracleNameKey(input.equivalentName);
      expect(expectedEquivalentKey, expectedKey);
      expect(SaveNamePolicy.nameKey(input.persistedName), expectedKey);
      expect(SaveNamePolicy.nameKey(input.equivalentName), expectedKey);
      expect(
        SaveNamePolicy.nameKey(input.persistedName),
        SaveNamePolicy.nameKey(input.equivalentName),
      );

      // Name_Key is a comparison value only; neither generated persisted name
      // may be replaced by its trimmed or canonical representation.
      expect(input.persistedName, persistedBefore);
      expect(input.equivalentName, equivalentBefore);
    },
  );

  // **Validates: Requirements 2.3, 2.4, 5.6, 5.7, 8.4, 8.9, 8.10, 8.16, 8.17**
  Glados<_GeneratedCopyCase>(
    _generatedCopyCases,
    ExploreConfig(
      numRuns: _propertyTwoRuns,
      initialSize: 8,
      speed: 1,
      random: Random(2),
    ),
  ).test('$_propertyTwoTag holds for $_propertyTwoRuns independently generated '
      'locales, source names, and occupied keys', (input) {
    final source = _oracleTrim(input.sourceName);
    final suffix = input.locale == 'pl' ? '-kopia' : '-copy';
    final occupiedKeys = <String>{
      for (final occupiedName in input.occupiedKeys)
        _oracleNameKey(occupiedName),
    };
    final expected = _oracleCopySelection(source, suffix, occupiedKeys);
    final actual = SaveNamePolicy.copyName(
      input.sourceName,
      input.locale,
      input.occupiedKeys,
    );

    // The expected name is selected without calling any SaveNamePolicy
    // method, so the oracle independently checks the localized suffix and
    // the first free candidate.
    expect(actual, expected.name);
    expect(actual, startsWith(source));
    expect(actual, contains(suffix));
    expect(_oracleNameKey(actual), isNot(isIn(occupiedKeys)));

    // A free base candidate must be returned as-is; otherwise every lower
    // numbered candidate is occupied and the selected number is >= 2.
    final baseKey = _oracleNameKey('$source$suffix');
    if (input.baseCandidateOccupied) {
      expect(occupiedKeys, contains(baseKey));
      final selectedNumber = expected.number;
      expect(selectedNumber, isNotNull);
      expect(selectedNumber!, greaterThanOrEqualTo(2));
      for (var number = 2; number < selectedNumber; number++) {
        expect(
          occupiedKeys,
          contains(_oracleNameKey('$source$suffix-$number')),
        );
      }
      expect(
        occupiedKeys,
        isNot(contains(_oracleNameKey('$source$suffix-$selectedNumber'))),
      );
    } else {
      expect(occupiedKeys, isNot(contains(baseKey)));
      expect(expected.number, isNull);
      expect(actual, '$source$suffix');
    }

    // The forced-gap cases prove that a free lower number wins over a
    // higher occupied number, while the candidate set and result remain
    // unique in Name_Key space.
    if (input.forcedGap != null) {
      final gap = input.forcedGap!;
      expect(input.baseCandidateOccupied, isTrue);
      expect(expected.number, gap);
      expect(
        occupiedKeys,
        contains(_oracleNameKey('$source$suffix-${gap + 1}')),
      );
      expect(
        occupiedKeys,
        isNot(contains(_oracleNameKey('$source$suffix-$gap'))),
      );
    }

    final candidateKeys = <String>{
      for (final candidate in expected.candidates) _oracleNameKey(candidate),
    };
    expect(candidateKeys.length, expected.candidates.length);
    final allGeneratedKeys = {...occupiedKeys, _oracleNameKey(actual)};
    expect(allGeneratedKeys.length, occupiedKeys.length + 1);
  });

  Directory? propertyThreeDirectory;
  SaveRepository? propertyThreeRepository;
  Glados<_GeneratedRawSnapshot>(
    _generatedRawSnapshots,
    ExploreConfig(
      numRuns: _propertyThreeRuns,
      initialSize: 8,
      speed: 1,
      random: Random(3),
    ),
  ).test(
    '$_propertyThreeTag holds for $_propertyThreeRuns generated raw snapshots',
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

      await _assertRawDuplicateSnapshot(
        repository: propertyThreeRepository!,
        directory: propertyThreeDirectory!,
        input: input,
      );
    },
  );

  Directory? propertyFourDirectory;
  SaveManagementService? propertyFourService;
  // **Validates: Requirements 3.2, 3.3, 3.10, 3.11, 3.12, 3.13, 3.14, 7.10, 8.6, 8.7**
  Glados<_GeneratedRenameCase>(
    _generatedRenameCases,
    ExploreConfig(
      numRuns: _propertyFourRuns,
      initialSize: 8,
      speed: 1,
      random: Random(4),
    ),
  ).test(
    '$_propertyFourTag holds for $_propertyFourRuns independently generated '
    'raw snapshots and proposed names',
    (input) async {
      if (propertyFourDirectory == null) {
        final directory = await Directory.systemTemp.createTemp(
          'nf_save_management_property_four_',
        );
        propertyFourDirectory = directory;
        propertyFourService = SaveManagementService(
          repository: SaveRepository(overrideDirectory: directory),
        );
        addTearDown(() async {
          if (await directory.exists()) {
            await directory.delete(recursive: true);
          }
        });
      }

      await _assertRawRenameSnapshot(
        service: propertyFourService!,
        directory: propertyFourDirectory!,
        input: input,
      );
    },
  );

  // **Validates: Requirements 4.8, 4.9, 4.12, 4.13, 8.24, 8.25**
  const kibibyte = 1024;
  const mebibyte = kibibyte * 1024;
  const gibibyte = mebibyte * 1024;
  const propertySixRuns = 120;

  // This oracle mirrors the requirements directly and does not call the
  // production formatter or reuse its unit-selection helpers.
  String? oracleSize(int? sizeBytes) {
    if (sizeBytes == null) return null;
    if (sizeBytes < kibibyte) return '$sizeBytes B';
    if (sizeBytes >= gibibyte) {
      return '${(sizeBytes / gibibyte).toStringAsFixed(1)} GiB';
    }
    if (sizeBytes >= mebibyte) {
      return '${(sizeBytes / mebibyte).toStringAsFixed(1)} MiB';
    }
    return '${(sizeBytes / kibibyte).toStringAsFixed(1)} KiB';
  }

  final generatedSizes = any.simple<int?>(
    generate: (random, size) {
      // Cycle through unavailable and every unit boundary so the minimum
      // number of runs cannot accidentally miss a required threshold.
      switch (size % 11) {
        case 0:
          return null;
        case 1:
          return 0;
        case 2:
          return 1;
        case 3:
          return kibibyte - 1;
        case 4:
          return kibibyte;
        case 5:
          return kibibyte + 1;
        case 6:
          return mebibyte - 1;
        case 7:
          return mebibyte;
        case 8:
          return gibibyte - 1;
        case 9:
          return gibibyte;
        default:
          final wholeGib = random.nextInt(8);
          final remainder = random.nextInt(1 << 30);
          return wholeGib * gibibyte + remainder;
      }
    },
    shrink: (input) sync* {
      if (input == null || input == 0) return;
      yield 0;
    },
  );

  Glados<int?>(
    generatedSizes,
    ExploreConfig(
      numRuns: propertySixRuns,
      initialSize: 8,
      speed: 1,
      random: Random(6),
    ),
  ).test(
    'Feature: save-management, Property 6: binary size formatter holds for '
    '$propertySixRuns generated sizes and null cases',
    (sizeBytes) {
      final actual = SaveSizeFormatter.format(sizeBytes);
      expect(actual, oracleSize(sizeBytes));

      if (sizeBytes == null) {
        // Unavailable size must stay unavailable, never become zero bytes.
        expect(actual, isNull);
        expect(actual, isNot('0'));
        expect(actual, isNot('0 B'));
        return;
      }

      expect(sizeBytes, greaterThanOrEqualTo(0));
      if (sizeBytes < kibibyte) {
        expect(actual, '$sizeBytes B');
        expect(actual, endsWith(' B'));
      } else if (sizeBytes < mebibyte) {
        expect(actual, endsWith(' KiB'));
      } else if (sizeBytes < gibibyte) {
        expect(actual, endsWith(' MiB'));
      } else {
        expect(actual, endsWith(' GiB'));
      }

      // These exact cases are generated repeatedly and make each transition
      // explicit, including the values immediately below each threshold.
      final boundaryExpectation = <int, String>{
        0: '0 B',
        kibibyte - 1: '1023 B',
        kibibyte: '1.0 KiB',
        mebibyte - 1: '1024.0 KiB',
        mebibyte: '1.0 MiB',
        gibibyte - 1: '1024.0 MiB',
        gibibyte: '1.0 GiB',
      }[sizeBytes];
      if (boundaryExpectation != null) {
        expect(actual, boundaryExpectation);
      }
    },
  );

  _registerPropertyFiveTest();
}

Future<void> _assertRawRenameSnapshot({
  required SaveManagementService service,
  required Directory directory,
  required _GeneratedRenameCase input,
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
    _cloneJsonMap(snapshot.sourceIndexMeta),
  ];
  if (input.scenario == _RenameScenario.occupiedName) {
    await occupiedFile.writeAsString(
      jsonEncode(_oracleDuplicateSnapshot(snapshot)),
    );
    indexEntries.add(_cloneJsonMap(snapshot.duplicateMeta.toJson()));
  }
  await indexFile.writeAsString(jsonEncode(indexEntries));

  final sourceTextBefore = await sourceFile.readAsString();
  final sourceBefore = _cloneJsonMap(snapshot.sourceJson);
  final occupiedTextBefore = input.scenario == _RenameScenario.occupiedName
      ? await occupiedFile.readAsString()
      : null;
  final occupiedBefore = input.scenario == _RenameScenario.occupiedName
      ? await _readRawJsonFile(occupiedFile)
      : null;
  final indexBefore = await _readRawIndex(indexFile);
  final recordsBefore = await service.listRecords();
  final sourceRecordBefore = recordsBefore.singleWhere(
    (record) => record.meta.id == snapshot.sourceId,
  );
  final expectedCompatibility = _oracleCompatibility(
    (snapshot.sourceIndexMeta['schemaVersion'] as num).toInt(),
  );

  expect(sourceRecordBefore.meta.toJson(), equals(snapshot.sourceIndexMeta));
  expect(sourceRecordBefore.compatibility, expectedCompatibility);
  expect(sourceRecordBefore.serializedFileAvailable, isTrue);

  final expectedName = _oracleTrim(input.proposedName);
  if (input.scenario == _RenameScenario.valid) {
    expect(expectedName, isNotEmpty);
    expect(
      _oracleNameKey(input.proposedName),
      isNot(_oracleNameKey(snapshot.sourceName)),
    );

    final result = await service.rename(snapshot.sourceId, input.proposedName);
    expect(result.isRename, isTrue);

    // The expected raw snapshot and index metadata are built by changing only
    // the contract-owned name field; no production serializer or rename
    // method is used to calculate either oracle.
    final expectedJson = _oracleRenamedSnapshot(snapshot, expectedName);
    final expectedIndexMeta = _oracleRenamedIndexMeta(snapshot, expectedName);
    expect(result.meta.toJson(), equals(expectedIndexMeta));

    final renamedJson = await _readRawJsonFile(sourceFile);
    expect(renamedJson, equals(expectedJson));

    final sourceMeta = Map<String, dynamic>.from(sourceBefore['meta'] as Map);
    final renamedMeta = Map<String, dynamic>.from(renamedJson['meta'] as Map);
    final changedKeys = <String>{};
    for (final key in {...sourceMeta.keys, ...renamedMeta.keys}) {
      if (!_rawJsonValuesEqual(sourceMeta[key], renamedMeta[key])) {
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

    final renamedIndex = await _readRawIndex(indexFile);
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
    case _RenameScenario.whitespaceOnly:
      expect(expectedName, isEmpty);
      break;
    case _RenameScenario.sameName:
      expect(expectedName, isNotEmpty);
      expect(
        _oracleNameKey(input.proposedName),
        _oracleNameKey(snapshot.sourceName),
      );
      break;
    case _RenameScenario.occupiedName:
      expect(expectedName, isNotEmpty);
      expect(
        _oracleNameKey(input.proposedName),
        _oracleNameKey(snapshot.duplicateName),
      );
      expect(
        _oracleNameKey(input.proposedName),
        isNot(_oracleNameKey(snapshot.sourceName)),
      );
      break;
    case _RenameScenario.valid:
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
  expect(await _readRawJsonFile(sourceFile), equals(sourceBefore));
  expect(await _readRawIndex(indexFile), equals(indexBefore));
  if (input.scenario == _RenameScenario.occupiedName) {
    expect(await occupiedFile.readAsString(), occupiedTextBefore);
    expect(await _readRawJsonFile(occupiedFile), equals(occupiedBefore));
  } else {
    expect(await occupiedFile.exists(), isFalse);
  }

  final recordsAfter = await service.listRecords();
  expect(recordsAfter, equals(recordsBefore));
}

Map<String, dynamic> _oracleRenamedSnapshot(
  _GeneratedRawSnapshot snapshot,
  String expectedName,
) {
  final source = _cloneJsonMap(snapshot.sourceJson);
  final renamedMeta = Map<String, dynamic>.from(source['meta'] as Map)
    ..['name'] = expectedName;
  return <String, dynamic>{...source, 'meta': renamedMeta};
}

Map<String, dynamic> _oracleRenamedIndexMeta(
  _GeneratedRawSnapshot snapshot,
  String expectedName,
) {
  return <String, dynamic>{
    ..._cloneJsonMap(snapshot.sourceIndexMeta),
    'name': expectedName,
  };
}

SaveCompatibility _oracleCompatibility(int schemaVersion) {
  if (schemaVersion == SaveRepository.currentSchemaVersion) {
    return SaveCompatibility.compatible;
  }
  return schemaVersion < SaveRepository.currentSchemaVersion
      ? SaveCompatibility.older
      : SaveCompatibility.newer;
}

final Generator<_GeneratedRenameCase> _generatedRenameCases = any
    .simple<_GeneratedRenameCase>(
      generate: (random, size) {
        final snapshot = _generateRawSnapshot(random, size);
        final scenario = _RenameScenario.values[size % 4];
        late final String proposedName;

        switch (scenario) {
          case _RenameScenario.valid:
            proposedName = _generatedRawName(random, size, 'renamed');
            break;
          case _RenameScenario.whitespaceOnly:
            proposedName = _whitespaceOnly(random, size);
            break;
          case _RenameScenario.sameName:
            proposedName =
                '${_outerWhitespace(random)}'
                '${_oracleTrim(snapshot.sourceName).toUpperCase()}'
                '${_outerWhitespace(random)}';
            break;
          case _RenameScenario.occupiedName:
            proposedName =
                '${_outerWhitespace(random)}'
                '${_oracleTrim(snapshot.duplicateName).toUpperCase()}'
                '${_outerWhitespace(random)}';
            break;
        }

        return _GeneratedRenameCase(
          snapshot: snapshot,
          scenario: scenario,
          proposedName: proposedName,
          expectedFailure: switch (scenario) {
            _RenameScenario.valid => null,
            _RenameScenario.whitespaceOnly => SaveManagementFailure.emptyName,
            _RenameScenario.sameName => SaveManagementFailure.sameName,
            _RenameScenario.occupiedName => SaveManagementFailure.nameTaken,
          },
        );
      },
      shrink: (input) sync* {
        if (input.snapshot.sourceId == 'p4-source-shrunk') return;
        final snapshot = _buildRawSnapshot(
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
          _RenameScenario.valid => ' renamed ',
          _RenameScenario.whitespaceOnly => ' \t\n',
          _RenameScenario.sameName => ' SOURCE ',
          _RenameScenario.occupiedName => ' COPY ',
        };
        yield _GeneratedRenameCase(
          snapshot: snapshot,
          scenario: input.scenario,
          proposedName: proposedName,
          expectedFailure: input.expectedFailure,
        );
      },
    );

enum _RenameScenario { valid, whitespaceOnly, sameName, occupiedName }

class _GeneratedRenameCase {
  const _GeneratedRenameCase({
    required this.snapshot,
    required this.scenario,
    required this.proposedName,
    required this.expectedFailure,
  });

  final _GeneratedRawSnapshot snapshot;
  final _RenameScenario scenario;
  final String proposedName;
  final SaveManagementFailure? expectedFailure;

  @override
  String toString() =>
      '_GeneratedRenameCase('
      'scenario: $scenario, sourceId: ${snapshot.sourceId}, '
      'proposedName: ${proposedName.replaceAll('\n', r'\n')}, '
      'sourceName: ${snapshot.sourceName.replaceAll('\n', r'\n')}, '
      'duplicateName: ${snapshot.duplicateName.replaceAll('\n', r'\n')}, '
      'expectedFailure: $expectedFailure)';
}

Future<void> _assertRawDuplicateSnapshot({
  required SaveRepository repository,
  required Directory directory,
  required _GeneratedRawSnapshot input,
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
  final sourceBefore = _cloneJsonMap(input.sourceJson);
  final returned = await repository.duplicateRaw(
    sourceId: input.sourceId,
    duplicateMeta: input.duplicateMeta,
  );

  expect(returned, input.duplicateMeta);
  expect(await duplicateFile.exists(), isTrue);

  // The oracle starts with the generated source map and changes only the four
  // fields named by the duplicate contract. It does not call duplicateRaw or
  // any serializer to calculate the expected copied snapshot.
  final duplicateJson = await _readRawJsonFile(duplicateFile);
  expect(duplicateJson, equals(_oracleDuplicateSnapshot(input)));

  final sourceAfter = await _readRawJsonFile(sourceFile);
  expect(sourceAfter, equals(sourceBefore));
  expect(await sourceFile.readAsString(), sourceTextBefore);

  final sourceMeta = Map<String, dynamic>.from(input.sourceJson['meta'] as Map);
  final copiedMeta = Map<String, dynamic>.from(duplicateJson['meta'] as Map);
  const duplicateOwnedFields = <String>{'id', 'name', 'createdAt', 'updatedAt'};
  final changedKeys = <String>{};
  for (final key in {...sourceMeta.keys, ...copiedMeta.keys}) {
    if (!_rawJsonValuesEqual(sourceMeta[key], copiedMeta[key])) {
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

  final index = await _readRawIndex(indexFile);
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
    equals(_oracleDuplicateIndexMeta(input)),
  );
}

Future<Map<String, dynamic>> _readRawJsonFile(File file) async {
  final decoded = jsonDecode(await file.readAsString());
  return Map<String, dynamic>.from(decoded as Map);
}

Future<List<Map<String, dynamic>>> _readRawIndex(File file) async {
  final decoded = jsonDecode(await file.readAsString()) as List<dynamic>;
  return [for (final entry in decoded) Map<String, dynamic>.from(entry as Map)];
}

Map<String, dynamic> _cloneJsonMap(Map<String, dynamic> source) {
  return Map<String, dynamic>.from(jsonDecode(jsonEncode(source)) as Map);
}

Map<String, dynamic> _oracleDuplicateSnapshot(_GeneratedRawSnapshot input) {
  final source = _cloneJsonMap(input.sourceJson);
  final sourceMeta = Map<String, dynamic>.from(source['meta'] as Map);
  final duplicateMeta = Map<String, dynamic>.from(sourceMeta)
    ..['id'] = input.duplicateId
    ..['name'] = input.duplicateName
    ..['createdAt'] = input.duplicateTimestamp.toIso8601String()
    ..['updatedAt'] = input.duplicateTimestamp.toIso8601String();
  return <String, dynamic>{...source, 'meta': duplicateMeta};
}

Map<String, dynamic> _oracleDuplicateIndexMeta(_GeneratedRawSnapshot input) {
  return <String, dynamic>{
    ...input.sourceIndexMeta,
    'id': input.duplicateId,
    'name': input.duplicateName,
    'createdAt': input.duplicateTimestamp.toIso8601String(),
    'updatedAt': input.duplicateTimestamp.toIso8601String(),
  };
}

bool _rawJsonValuesEqual(Object? left, Object? right) {
  if (left is Map && right is Map) {
    if (left.length != right.length) return false;
    for (final key in left.keys) {
      if (!right.containsKey(key) ||
          !_rawJsonValuesEqual(left[key], right[key])) {
        return false;
      }
    }
    return true;
  }
  if (left is List && right is List) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (!_rawJsonValuesEqual(left[index], right[index])) return false;
    }
    return true;
  }
  return left == right;
}

final Generator<_GeneratedRawSnapshot> _generatedRawSnapshots = any
    .simple<_GeneratedRawSnapshot>(
      generate: _generateRawSnapshot,
      shrink: (input) sync* {
        if (input.sourceId != 'p3-source-shrunk') {
          yield _buildRawSnapshot(
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

_GeneratedRawSnapshot _generateRawSnapshot(Random random, int size) {
  final token = random.nextInt(1 << 30);
  final sourceId = 'p3-source-$size-$token';
  final duplicateId = 'p3-copy-$size-$token';
  final sourceName = _generatedRawName(random, size, 'source');
  final duplicateName = _generatedRawName(random, size, 'copy');
  final sourceCreatedAt = _generatedTimestamp(random);
  final sourceUpdatedAt = sourceCreatedAt.add(
    Duration(minutes: 1 + random.nextInt(1_000_000)),
  );
  var duplicateTimestamp = _generatedTimestamp(random);
  if (duplicateTimestamp == sourceCreatedAt ||
      duplicateTimestamp == sourceUpdatedAt) {
    duplicateTimestamp = duplicateTimestamp.add(
      const Duration(microseconds: 1),
    );
  }

  final topLevelSchemaVersion = _generatedSchemaVersion(random, size);
  final metaSchemaVersion = _generatedSchemaVersion(random, size + 1);
  final playerTeamName = random.nextBool()
      ? _generatedRawName(random, size, 'team')
      : null;
  final payloadMarker = random.nextInt(1 << 30);

  return _buildRawSnapshot(
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

_GeneratedRawSnapshot _buildRawSnapshot({
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
      'futureMeta': _cloneJsonMap(unknownMeta),
    },
    'leagueState': _cloneJsonMap(payload),
    'saveSeed': saveSeed,
    'futureTopLevel': _cloneJsonMap(unknownTopLevel),
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

  return _GeneratedRawSnapshot(
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

int _generatedSchemaVersion(Random random, int size) {
  switch (size % 5) {
    case 0:
      return -1 - random.nextInt(size + 1);
    case 1:
      return 0;
    case 2:
      return SaveRepository.currentSchemaVersion;
    case 3:
      return SaveRepository.currentSchemaVersion + 1 + random.nextInt(1_000);
    default:
      return random.nextInt(100_001) - 50_000;
  }
}

String _generatedRawName(Random random, int size, String prefix) {
  final length = 1 + random.nextInt(size.clamp(1, 8));
  final body = StringBuffer();
  for (var index = 0; index < length; index++) {
    final variants = _latinUnits[random.nextInt(_latinUnits.length)];
    body.write(variants[random.nextInt(variants.length)]);
  }
  return '${_outerWhitespace(random)}$prefix-${body.toString()}${_outerWhitespace(random)}';
}

DateTime _generatedTimestamp(Random random) {
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

class _GeneratedRawSnapshot {
  const _GeneratedRawSnapshot({
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
      '_GeneratedRawSnapshot('
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
/// 120 runs always include whitespace rejection, Polish diacritics, broader
/// Latin diacritics, and varied mixed names.
final Generator<_GeneratedName> _generatedNames = any.simple<_GeneratedName>(
  generate: (random, size) {
    final scenario = size % 4;
    if (scenario == 0) {
      final persisted = _whitespaceOnly(random, size);
      return _GeneratedName(
        persistedName: persisted,
        equivalentName: _whitespaceOnly(random, size),
        whitespaceOnly: true,
      );
    }

    final units = switch (scenario) {
      1 => _polishUnits,
      2 => _latinUnits,
      _ => _randomUnits(random, size),
    };
    final mode = switch (scenario) {
      1 => _VariantMode.accented,
      2 => _VariantMode.accented,
      _ => _VariantMode.mixed,
    };

    return _GeneratedName(
      persistedName: _render(units, random, mode: mode, uppercase: true),
      equivalentName: _render(
        units,
        random,
        mode: _VariantMode.ascii,
        uppercase: false,
      ),
      whitespaceOnly: false,
    );
  },
  // Keep shrinking independent of the production policy while preserving the
  // semantic relation between the two generated names.
  shrink: (input) sync* {
    if (input.whitespaceOnly) {
      if (input.persistedName != ' ') {
        yield const _GeneratedName(
          persistedName: ' ',
          equivalentName: '\t',
          whitespaceOnly: true,
        );
      }
      return;
    }

    if (input.persistedName != ' A ' || input.equivalentName != 'a') {
      yield const _GeneratedName(
        persistedName: ' A ',
        equivalentName: 'a',
        whitespaceOnly: false,
      );
    }
  },
);

class _GeneratedName {
  const _GeneratedName({
    required this.persistedName,
    required this.equivalentName,
    required this.whitespaceOnly,
  });

  final String persistedName;
  final String equivalentName;
  final bool whitespaceOnly;

  @override
  String toString() =>
      '_GeneratedName('
      'persistedName: ${persistedName.replaceAll('\n', r'\n')}, '
      'equivalentName: ${equivalentName.replaceAll('\n', r'\n')}, '
      'whitespaceOnly: $whitespaceOnly)';
}

enum _VariantMode { ascii, accented, mixed }

const _polishUnits = <List<String>>[
  ['a', 'ą'],
  ['c', 'ć'],
  ['e', 'ę'],
  ['l', 'ł'],
  ['n', 'ń'],
  ['o', 'ó'],
  ['s', 'ś'],
  ['z', 'ź'],
  ['z', 'ż'],
];

const _latinUnits = <List<String>>[
  ['a', 'á', 'à', 'â', 'ä', 'ã', 'å', 'a\u0301', 'a\u0328'],
  ['c', 'ç', 'č', 'c\u0327'],
  ['d', 'ď', 'đ', 'd\u030c'],
  ['e', 'é', 'è', 'ê', 'ë', 'ě', 'e\u0301', 'e\u0328'],
  ['g', 'ğ', 'ģ', 'g\u030c'],
  ['i', 'í', 'ì', 'î', 'ï', 'i\u0301'],
  ['j', 'ĵ', 'j\u0302'],
  ['l', 'ĺ', 'ľ', 'l\u0301'],
  ['n', 'ñ', 'ň', 'n\u0303'],
  ['o', 'ó', 'ò', 'ô', 'ö', 'õ', 'ø', 'ő', 'o\u0301'],
  ['r', 'ŕ', 'ř', 'r\u0301'],
  ['s', 'ś', 'š', 'ş', 's\u0301'],
  ['t', 'ť', 'ţ', 't\u030c'],
  ['u', 'ú', 'ù', 'û', 'ü', 'ů', 'ű', 'u\u0301'],
  ['w', 'ŵ', 'w\u0302'],
  ['y', 'ý', 'ÿ', 'y\u0301'],
  ['z', 'ź', 'ż', 'ž', 'z\u0301'],
];

List<List<String>> _randomUnits(Random random, int size) {
  final length = 1 + random.nextInt(size.clamp(1, 12));
  return [
    for (var index = 0; index < length; index++)
      _latinUnits[random.nextInt(_latinUnits.length)],
  ];
}

String _render(
  List<List<String>> units,
  Random random, {
  required _VariantMode mode,
  required bool uppercase,
}) {
  final body = StringBuffer();
  for (final variants in units) {
    final value = switch (mode) {
      _VariantMode.ascii => variants.first,
      _VariantMode.accented =>
        variants.length == 1
            ? variants.first
            : variants[1 + random.nextInt(variants.length - 1)],
      _VariantMode.mixed => variants[random.nextInt(variants.length)],
    };
    body.write(value);
  }

  final rendered = uppercase ? body.toString().toUpperCase() : body.toString();
  return '${_outerWhitespace(random)}$rendered${_outerWhitespace(random)}';
}

String _outerWhitespace(Random random) {
  const whitespace = <String>[' ', '\t', '\n', '\r', '\u00a0'];
  final count = 1 + random.nextInt(3);
  return List<String>.generate(
    count,
    (_) => whitespace[random.nextInt(whitespace.length)],
  ).join();
}

String _whitespaceOnly(Random random, int size) {
  const whitespace = <String>[' ', '\t', '\n', '\r', '\u00a0'];
  final count = 1 + random.nextInt(size.clamp(1, 12));
  return List<String>.generate(
    count,
    (_) => whitespace[random.nextInt(whitespace.length)],
  ).join();
}

/// Independent oracle for trim over every whitespace character generated by
/// this test. It intentionally does not call SaveNamePolicy.trimName.
String _oracleTrim(String input) {
  var start = 0;
  var end = input.length;
  while (start < end && _isOracleWhitespace(input.codeUnitAt(start))) {
    start++;
  }
  while (end > start && _isOracleWhitespace(input.codeUnitAt(end - 1))) {
    end--;
  }
  return input.substring(start, end);
}

bool _isOracleWhitespace(int codeUnit) => switch (codeUnit) {
  0x09 || 0x0a || 0x0d || 0x20 || 0x00a0 => true,
  _ => false,
};

/// Independent Name_Key oracle: trim, Unicode case folding supplied by Dart,
/// then explicit Latin/Polish canonicalization and combining-mark removal.
String _oracleNameKey(String input) {
  final trimmed = _oracleTrim(input);
  if (trimmed.isEmpty) {
    throw ArgumentError.value(input, 'input');
  }

  final lowered = trimmed.toLowerCase();
  final result = StringBuffer();
  for (final rune in lowered.runes) {
    if (_isOracleCombiningMark(rune)) continue;
    result.write(_oracleReplacements[rune] ?? String.fromCharCode(rune));
  }
  return result.toString();
}

bool _isOracleCombiningMark(int rune) =>
    (rune >= 0x0300 && rune <= 0x036f) ||
    (rune >= 0x1ab0 && rune <= 0x1aff) ||
    (rune >= 0x1dc0 && rune <= 0x1dff) ||
    (rune >= 0x20d0 && rune <= 0x20ff) ||
    (rune >= 0xfe20 && rune <= 0xfe2f);

const _oracleReplacements = <int, String>{
  // Polish letters and common Latin-1 accents.
  0x0105: 'a',
  0x00e1: 'a',
  0x00e0: 'a',
  0x00e2: 'a',
  0x00e4: 'a',
  0x00e3: 'a',
  0x00e5: 'a',
  0x0107: 'c',
  0x00e7: 'c',
  0x010d: 'c',
  0x010f: 'd',
  0x0111: 'd',
  0x0119: 'e',
  0x00e9: 'e',
  0x00e8: 'e',
  0x00ea: 'e',
  0x00eb: 'e',
  0x011b: 'e',
  0x011f: 'g',
  0x0123: 'g',
  0x00ed: 'i',
  0x00ec: 'i',
  0x00ee: 'i',
  0x00ef: 'i',
  0x0135: 'j',
  0x0142: 'l',
  0x013a: 'l',
  0x013e: 'l',
  0x0144: 'n',
  0x00f1: 'n',
  0x0148: 'n',
  0x014b: 'n',
  0x00f3: 'o',
  0x00f2: 'o',
  0x00f4: 'o',
  0x00f6: 'o',
  0x00f5: 'o',
  0x00f8: 'o',
  0x0151: 'o',
  0x0155: 'r',
  0x0159: 'r',
  0x015b: 's',
  0x0161: 's',
  0x015f: 's',
  0x0165: 't',
  0x0163: 't',
  0x00fa: 'u',
  0x00f9: 'u',
  0x00fb: 'u',
  0x00fc: 'u',
  0x016f: 'u',
  0x0171: 'u',
  0x0175: 'w',
  0x00fd: 'y',
  0x00ff: 'y',
  0x017a: 'z',
  0x017c: 'z',
  0x017e: 'z',
};

/// Generates a source name, locale, and occupied Name_Key values separately
/// from the production policy. The four scenarios guarantee free-base,
/// forced-gap, contiguous-number, and sparse-number cases across the run.
final Generator<_GeneratedCopyCase> _generatedCopyCases = any
    .simple<_GeneratedCopyCase>(
      generate: (random, size) {
        final scenario = size % 4;
        // Locale selection is an independent generator draw, not derived from
        // the source spelling or occupied-number layout.
        final locale = random.nextBool() ? 'en' : 'pl';
        final sourceName = _generatedCopySourceName(random, size);
        final source = _oracleTrim(sourceName);
        final suffix = locale == 'pl' ? '-kopia' : '-copy';
        final baseCandidateOccupied = scenario != 0;
        final occupiedKeys = <String>{};
        if (baseCandidateOccupied) {
          occupiedKeys.add(_oracleNameKey('$source$suffix'));
        }

        final maxNumber = 3 + random.nextInt(5);
        final occupiedNumbers = <int>{};
        int? forcedGap;
        if (scenario == 0) {
          // Numbered names may exist even while the unsuffixed base is free.
          for (var number = 2; number <= maxNumber; number++) {
            if (random.nextBool()) occupiedNumbers.add(number);
          }
        } else if (scenario == 1) {
          // Occupy every lower number, leave a deliberate gap, and occupy a
          // higher number so the oracle must choose the gap.
          forcedGap = 2 + random.nextInt(4);
          for (var number = 2; number < forcedGap; number++) {
            occupiedNumbers.add(number);
          }
          occupiedNumbers.add(forcedGap + 1);
          for (var number = forcedGap + 2; number <= maxNumber + 1; number++) {
            if (random.nextBool()) occupiedNumbers.add(number);
          }
        } else if (scenario == 2) {
          // A contiguous prefix checks that the next number is selected.
          for (var number = 2; number <= maxNumber; number++) {
            occupiedNumbers.add(number);
          }
        } else {
          // Sparse random numbering covers additional holes and collisions.
          for (var number = 2; number <= maxNumber; number++) {
            if (random.nextBool()) occupiedNumbers.add(number);
          }
          if (occupiedNumbers.isEmpty) occupiedNumbers.add(2);
        }

        for (final number in occupiedNumbers) {
          occupiedKeys.add(_oracleNameKey('$source$suffix-$number'));
        }

        // These unrelated keys make the occupied-key set independently
        // generated rather than a list containing only expected candidates.
        final unrelatedCount = random.nextInt(3);
        for (var index = 0; index < unrelatedCount; index++) {
          occupiedKeys.add(
            'independent-key-${size.abs()}-$index-'
            '${random.nextInt(1000000)}',
          );
        }

        return _GeneratedCopyCase(
          sourceName: sourceName,
          locale: locale,
          occupiedKeys: occupiedKeys,
          baseCandidateOccupied: baseCandidateOccupied,
          forcedGap: forcedGap,
        );
      },
      shrink: (input) sync* {
        if (input.sourceName == ' A ') return;

        final suffix = input.locale == 'pl' ? '-kopia' : '-copy';
        if (input.forcedGap != null) {
          final gap = input.forcedGap!;
          yield _GeneratedCopyCase(
            sourceName: ' A ',
            locale: input.locale,
            occupiedKeys: {
              _oracleNameKey('A$suffix'),
              for (var number = 2; number < gap; number++)
                _oracleNameKey('A$suffix-$number'),
              _oracleNameKey('A$suffix-${gap + 1}'),
            },
            baseCandidateOccupied: true,
            forcedGap: gap,
          );
        } else if (input.baseCandidateOccupied) {
          yield _GeneratedCopyCase(
            sourceName: ' A ',
            locale: input.locale,
            occupiedKeys: {_oracleNameKey('A$suffix')},
            baseCandidateOccupied: true,
            forcedGap: null,
          );
        } else {
          yield _GeneratedCopyCase(
            sourceName: ' A ',
            locale: input.locale,
            occupiedKeys: const <String>{},
            baseCandidateOccupied: false,
            forcedGap: null,
          );
        }
      },
    );

String _generatedCopySourceName(Random random, int size) {
  final units = switch (size % 3) {
    0 => _polishUnits,
    1 => _latinUnits,
    _ => _randomUnits(random, size),
  };
  final length = 1 + random.nextInt(size.clamp(1, 8));
  final body = StringBuffer();
  for (var index = 0; index < length; index++) {
    final variants = units[random.nextInt(units.length)];
    body.write(variants[random.nextInt(variants.length)]);
  }
  final rendered = random.nextBool() ? body.toString().toUpperCase() : body;
  return '${_outerWhitespace(random)}$rendered${_outerWhitespace(random)}';
}

_OracleCopySelection _oracleCopySelection(
  String source,
  String suffix,
  Set<String> occupiedKeys,
) {
  final candidates = <String>[];
  final baseCandidate = '$source$suffix';
  candidates.add(baseCandidate);
  if (!occupiedKeys.contains(_oracleNameKey(baseCandidate))) {
    return _OracleCopySelection(
      name: baseCandidate,
      number: null,
      candidates: List<String>.unmodifiable(candidates),
    );
  }

  for (var number = 2; ; number++) {
    final candidate = '$source$suffix-$number';
    candidates.add(candidate);
    if (!occupiedKeys.contains(_oracleNameKey(candidate))) {
      return _OracleCopySelection(
        name: candidate,
        number: number,
        candidates: List<String>.unmodifiable(candidates),
      );
    }
  }
}

class _GeneratedCopyCase {
  const _GeneratedCopyCase({
    required this.sourceName,
    required this.locale,
    required this.occupiedKeys,
    required this.baseCandidateOccupied,
    required this.forcedGap,
  });

  final String sourceName;
  final String locale;
  final Set<String> occupiedKeys;
  final bool baseCandidateOccupied;
  final int? forcedGap;

  @override
  String toString() =>
      '_GeneratedCopyCase('
      'sourceName: ${sourceName.replaceAll('\n', r'\n')}, '
      'locale: $locale, occupiedKeys: $occupiedKeys, '
      'baseCandidateOccupied: $baseCandidateOccupied, '
      'forcedGap: $forcedGap)';
}

class _OracleCopySelection {
  const _OracleCopySelection({
    required this.name,
    required this.number,
    required this.candidates,
  });

  final String name;
  final int? number;
  final List<String> candidates;
}

void _registerPropertyFiveTest() {
  const propertyFiveTag =
      'Feature: save-management, Property 5: index invariant and list order';
  const propertyFiveRuns = 120;

  // **Validates: Requirements 1.10, 2.1, 2.14, 2.15, 3.18, 7.9, 8.10**
  Glados<_GeneratedPropertyFiveCase>(
    _generatedPropertyFiveCases,
    ExploreConfig(
      numRuns: propertyFiveRuns,
      initialSize: 8,
      speed: 1,
      random: Random(5),
    ),
  ).test('$propertyFiveTag holds for $propertyFiveRuns generated multi-save '
      'metadata and raw snapshot cases', (input) async {
    // Glados may execute asynchronous generated cases concurrently. Each
    // case therefore owns its directory so one case cannot clear another
    // case's canonical files while it is committing duplicate/rename.
    final directory = await Directory.systemTemp.createTemp(
      'nf_save_management_property_five_',
    );
    try {
      await _assertPropertyFive(directory: directory, input: input);
    } finally {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    }
  });
}

Future<void> _assertPropertyFive({
  required Directory directory,
  required _GeneratedPropertyFiveCase input,
}) async {
  await _clearPropertyFiveDirectory(directory);

  final indexFile = File('${directory.path}/saves_index.json');
  for (final save in input.saves) {
    await File(
      '${directory.path}/${save.id}.json',
    ).writeAsString(jsonEncode(save.rawJson));
  }
  await indexFile.writeAsString(
    jsonEncode([
      for (final index in input.initialIndexOrder)
        _cloneJsonMap(input.saves[index].indexMeta),
    ]),
  );

  final repository = SaveRepository(overrideDirectory: directory);
  final service = SaveManagementService(
    repository: repository,
    clock: () => input.duplicateTimestamp,
    idGenerator: () => input.duplicateId,
  );

  final expectedRawById = <String, Map<String, dynamic>>{
    for (final save in input.saves) save.id: _cloneJsonMap(save.rawJson),
  };
  final expectedIndexById = <String, Map<String, dynamic>>{
    for (final save in input.saves) save.id: _cloneJsonMap(save.indexMeta),
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
    for (final save in input.saves) _oracleNameKey(save.name),
  };
  final expectedDuplicateName = _oracleCopySelection(
    _oracleTrim(source.name),
    suffix,
    occupiedKeys,
  ).name;
  final expectedDuplicateRaw = _oraclePropertyFiveDuplicateRaw(
    source,
    duplicateId: input.duplicateId,
    duplicateName: expectedDuplicateName,
    duplicateTimestamp: input.duplicateTimestamp,
  );
  final expectedDuplicateIndex = _oraclePropertyFiveDuplicateIndex(
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
  expect(expectedDuplicateName, startsWith(_oracleTrim(source.name)));
  expect(expectedDuplicateName, contains(suffix));

  // The initial state is checked as well as both operation results. This
  // makes the generated index itself an independent multi-save oracle rather
  // than relying only on the post-operation cardinalities.
  await _assertPropertyFiveState(
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

  final sourceRawAfterDuplicate = await _readRawJsonFile(
    File('${directory.path}/${source.id}.json'),
  );
  final duplicateRawAfterDuplicate = await _readRawJsonFile(
    File('${directory.path}/${input.duplicateId}.json'),
  );
  _expectPropertyFiveMetaChanges(
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
  await _assertPropertyFiveState(
    repository: repository,
    service: service,
    directory: directory,
    expectedRawById: expectedRawById,
    expectedIndexById: expectedIndexById,
    state: 'after duplicate',
  );

  final renameBefore = _cloneJsonMap(expectedRawById[input.renameId]!);
  final expectedRenamedName = _oracleTrim(input.proposedName);
  final expectedRenamedRaw = _cloneJsonMap(renameBefore);
  final expectedRenamedMeta = Map<String, dynamic>.from(
    expectedRenamedRaw['meta'] as Map,
  )..['name'] = expectedRenamedName;
  expectedRenamedRaw['meta'] = expectedRenamedMeta;
  final expectedRenamedIndex = _cloneJsonMap(expectedIndexById[input.renameId]!)
    ..['name'] = expectedRenamedName;

  expect(expectedRenamedName, isNotEmpty);
  expect(
    _oracleNameKey(expectedRenamedName),
    isNot(
      isIn(
        expectedIndexById.values.map(
          (meta) => _oracleNameKey(meta['name'] as String),
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

  final renameAfter = await _readRawJsonFile(
    File('${directory.path}/${input.renameId}.json'),
  );
  _expectPropertyFiveMetaChanges(
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
  await _assertPropertyFiveState(
    repository: repository,
    service: service,
    directory: directory,
    expectedRawById: expectedRawById,
    expectedIndexById: expectedIndexById,
    state: 'after rename',
  );
}

Future<void> _clearPropertyFiveDirectory(Directory directory) async {
  if (!await directory.exists()) await directory.create(recursive: true);
  await for (final entity in directory.list()) {
    if (entity is Directory) {
      await entity.delete(recursive: true);
    } else {
      await entity.delete();
    }
  }
}

Future<void> _assertPropertyFiveState({
  required SaveRepository repository,
  required SaveManagementService service,
  required Directory directory,
  required Map<String, Map<String, dynamic>> expectedRawById,
  required Map<String, Map<String, dynamic>> expectedIndexById,
  required String state,
}) async {
  final index = await _readRawIndex(File('${directory.path}/saves_index.json'));
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
    final actual = await _readRawJsonFile(file);
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
  _assertPropertyFiveListOrder(
    listed,
    expectedIndexById,
    '$state repository list',
  );
  final records = await service.listRecords();
  _assertPropertyFiveListOrder(
    records.map((record) => record.meta).toList(),
    expectedIndexById,
    '$state service list',
  );
}

void _assertPropertyFiveListOrder(
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
    final key = _propertyFiveTimestampKey(
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
    final key = _propertyFiveTimestampKey(meta.updatedAt);
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

String _propertyFiveTimestampKey(DateTime value) =>
    value.toUtc().toIso8601String();

Map<String, dynamic> _oraclePropertyFiveDuplicateRaw(
  _GeneratedPropertyFiveSave source, {
  required String duplicateId,
  required String duplicateName,
  required DateTime duplicateTimestamp,
}) {
  final copied = _cloneJsonMap(source.rawJson);
  final copiedMeta = Map<String, dynamic>.from(copied['meta'] as Map)
    ..['id'] = duplicateId
    ..['name'] = duplicateName
    ..['createdAt'] = duplicateTimestamp.toIso8601String()
    ..['updatedAt'] = duplicateTimestamp.toIso8601String();
  copied['meta'] = copiedMeta;
  return copied;
}

Map<String, dynamic> _oraclePropertyFiveDuplicateIndex(
  _GeneratedPropertyFiveSave source, {
  required String duplicateId,
  required String duplicateName,
  required DateTime duplicateTimestamp,
}) {
  return <String, dynamic>{
    ..._cloneJsonMap(source.indexMeta),
    'id': duplicateId,
    'name': duplicateName,
    'createdAt': duplicateTimestamp.toIso8601String(),
    'updatedAt': duplicateTimestamp.toIso8601String(),
  };
}

void _expectPropertyFiveMetaChanges({
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
    if (!_rawJsonValuesEqual(beforeMeta[key], afterMeta[key])) {
      changedKeys.add(key);
    }
  }
  expect(changedKeys.difference(allowed), isEmpty, reason: reason);
  expect(changedKeys.containsAll(requiredChanges), isTrue, reason: reason);
}

final Generator<_GeneratedPropertyFiveCase> _generatedPropertyFiveCases = any
    .simple<_GeneratedPropertyFiveCase>(
      generate: (random, size) =>
          _generatePropertyFiveCase(random, size, shrunk: false),
      shrink: (input) sync* {
        if (input.shrunk) return;
        yield _generatePropertyFiveCase(Random(505), 1, shrunk: true);
      },
    );

_GeneratedPropertyFiveCase _generatePropertyFiveCase(
  Random random,
  int size, {
  required bool shrunk,
}) {
  final normalizedSize = size < 0 ? -size : size;
  final token = random.nextInt(1 << 30);
  final saveCount = 3 + normalizedSize % 3;
  final baseTimestamp = DateTime.utc(
    2020 + normalizedSize % 5,
    1 + normalizedSize % 10,
    10,
    12,
    15,
    30,
  );
  final saves = <_GeneratedPropertyFiveSave>[];

  for (var index = 0; index < saveCount; index++) {
    final updatedAt = switch (index) {
      0 || 1 => baseTimestamp,
      2 => baseTimestamp.add(const Duration(hours: 1)),
      3 => baseTimestamp.subtract(const Duration(hours: 1)),
      _ => baseTimestamp.add(Duration(hours: index + 1)),
    };
    final createdAt = updatedAt.subtract(const Duration(days: 1));
    final id = 'p5-save-$token-$index';
    final name = index.isEven
        ? ' p5-save-$token-$index\n'
        : '\tp5-save-$token-$index\r ';
    final schemaVersion = (index % 3) - 1;
    final phase = SeasonPhase
        .values[(index + normalizedSize) % SeasonPhase.values.length];
    final indexMeta = <String, dynamic>{
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'seasonYear': 2020 + index,
      'phase': phase.name,
      'playerTeamName': index.isEven ? 'P5 Team $index' : null,
      'schemaVersion': schemaVersion,
    };
    final rawJson = <String, dynamic>{
      'schemaVersion': schemaVersion + 10,
      'meta': <String, dynamic>{
        ..._cloneJsonMap(indexMeta),
        'futureMeta': <String, dynamic>{
          'caseToken': token,
          'saveIndex': index,
          'preserve': <dynamic>[index, 'meta-$token'],
        },
      },
      'leagueState': <String, dynamic>{
        'payloadMarker': 'p5-payload-$token-$index',
        'nested': <dynamic>[
          index,
          token,
          <String, dynamic>{'keep': true},
        ],
      },
      'saveSeed': token - index,
      'futureTopLevel': <String, dynamic>{
        'caseToken': token,
        'saveIndex': index,
        'preserve': <dynamic>['top-level', index],
      },
    };
    saves.add(
      _GeneratedPropertyFiveSave(
        id: id,
        name: name,
        updatedAt: updatedAt,
        indexMeta: indexMeta,
        rawJson: rawJson,
      ),
    );
  }

  final initialIndexOrder = List<int>.generate(saveCount, (index) => index)
    ..shuffle(random);
  final duplicateTimestamp = normalizedSize.isEven
      ? baseTimestamp
      : baseTimestamp.add(const Duration(days: 5));
  final locale = random.nextBool() ? 'en' : 'pl';

  return _GeneratedPropertyFiveCase(
    saves: saves,
    initialIndexOrder: initialIndexOrder,
    duplicateSourceId: saves.first.id,
    renameId: saves[1].id,
    duplicateId: 'p5-copy-$token',
    duplicateTimestamp: duplicateTimestamp,
    locale: locale,
    proposedName: ' \tp5-renamed-$token \n',
    shrunk: shrunk,
  );
}

class _GeneratedPropertyFiveCase {
  const _GeneratedPropertyFiveCase({
    required this.saves,
    required this.initialIndexOrder,
    required this.duplicateSourceId,
    required this.renameId,
    required this.duplicateId,
    required this.duplicateTimestamp,
    required this.locale,
    required this.proposedName,
    required this.shrunk,
  });

  final List<_GeneratedPropertyFiveSave> saves;
  final List<int> initialIndexOrder;
  final String duplicateSourceId;
  final String renameId;
  final String duplicateId;
  final DateTime duplicateTimestamp;
  final String locale;
  final String proposedName;
  final bool shrunk;

  @override
  String toString() =>
      '_GeneratedPropertyFiveCase('
      'ids: ${saves.map((save) => save.id).toList()}, '
      'duplicateSourceId: $duplicateSourceId, '
      'renameId: $renameId, duplicateId: $duplicateId, '
      'duplicateTimestamp: $duplicateTimestamp, locale: $locale, '
      'proposedName: ${proposedName.replaceAll('\n', r'\n')}, '
      'shrunk: $shrunk)';
}

class _GeneratedPropertyFiveSave {
  const _GeneratedPropertyFiveSave({
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.indexMeta,
    required this.rawJson,
  });

  final String id;
  final String name;
  final DateTime updatedAt;
  final Map<String, dynamic> indexMeta;
  final Map<String, dynamic> rawJson;
}
