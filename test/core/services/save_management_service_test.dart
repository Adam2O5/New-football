import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/core/services/save_management_service.dart';
import 'package:new_football/data/save_repository.dart';

void main() {
  group('SaveManagementService', () {
    test(
      'listRecords preserves index rows and compatibility when size inspection fails',
      () async {
        final older = _meta(
          id: 'older',
          name: 'Older',
          schemaVersion: SaveSchema.currentVersion - 1,
        );
        final compatible = _meta(
          id: 'compatible',
          name: 'Compatible',
          schemaVersion: SaveSchema.currentVersion,
        );
        final newer = _meta(
          id: 'newer',
          name: 'Newer',
          schemaVersion: SaveSchema.currentVersion + 1,
        );
        final repository = _FakeSaveRepository(
          index: [older, compatible, newer],
          inspections: {
            older.id: const SaveFileInfo.available(128),
            newer.id: const SaveFileInfo.missing(),
          },
          inspectionErrors: {
            compatible.id: StateError('file length unavailable'),
          },
        );

        final records = await _service(
          repository,
          timestamp: DateTime.utc(2026, 1, 1),
        ).listRecords();

        expect(records, hasLength(3));
        expect(records.map((record) => record.meta.id), [
          'older',
          'compatible',
          'newer',
        ]);
        expect(records[0].compatibility, SaveCompatibility.older);
        expect(records[0].serializedFileAvailable, isTrue);
        expect(records[0].sizeBytes, 128);
        expect(records[0].sizeReadFailed, isFalse);

        expect(records[1].compatibility, SaveCompatibility.compatible);
        expect(records[1].serializedFileAvailable, isTrue);
        expect(records[1].sizeBytes, isNull);
        expect(records[1].sizeReadFailed, isTrue);

        expect(records[2].compatibility, SaveCompatibility.newer);
        expect(records[2].serializedFileAvailable, isFalse);
        expect(records[2].sizeBytes, isNull);
        expect(records[2].sizeReadFailed, isFalse);
        expect(repository.inspectCalls, ['older', 'compatible', 'newer']);
      },
    );

    test(
      'duplicate retries IDs against fresh index and disk and uses one fixed timestamp',
      () async {
        final source = _meta(id: 'source', name: 'Season');
        final indexedCollision = _meta(id: 'indexed-id', name: 'Indexed');
        final indexed = [
          source,
          indexedCollision,
          _meta(id: 'copy-base', name: 'Season-copy'),
          _meta(id: 'copy-two', name: 'Season-copy-2'),
          _meta(id: 'copy-four', name: 'Season-copy-4'),
        ];
        final repository = _FakeSaveRepository(
          indexSnapshots: [indexed, indexed, indexed, indexed],
          canonicalFileIds: {'disk-id'},
        );
        final timestamp = DateTime.utc(2030, 5, 6, 7, 8, 9);

        final result = await _service(
          repository,
          timestamp: timestamp,
          idCandidates: ['indexed-id', 'disk-id', 'free-id'],
        ).duplicate(source.id, localeCode: 'en-US');

        expect(result.isDuplicate, isTrue);
        expect(result.isRename, isFalse);
        expect(result.meta.id, 'free-id');
        expect(result.meta.name, 'Season-copy-3');
        expect(result.meta.createdAt, timestamp);
        expect(result.meta.updatedAt, timestamp);
        expect(result.meta.schemaVersion, source.schemaVersion);
        expect(result.meta.seasonYear, source.seasonYear);
        expect(repository.availabilityCalls, [
          'indexed-id',
          'disk-id',
          'free-id',
        ]);
        expect(repository.listSavesCalls, 4);
        expect(repository.duplicateCalls, hasLength(1));
        expect(repository.duplicateCalls.single.sourceId, source.id);
        expect(repository.duplicateCalls.single.duplicateMeta, result.meta);
      },
    );

    test(
      'duplicate uses the localized Polish suffix and reuses a numbering gap',
      () async {
        final source = _meta(id: 'polish-source', name: '  Łódź  ');
        final repository = _FakeSaveRepository(
          index: [
            source,
            _meta(id: 'polish-base', name: 'LODZ-kopia'),
            _meta(id: 'polish-two', name: 'ŁÓDŹ-kopia-2'),
            _meta(id: 'polish-four', name: 'Lodz-kopia-4'),
          ],
        );

        final result = await _service(
          repository,
          timestamp: DateTime.utc(2030, 5, 6),
          idCandidates: ['polish-copy-id'],
        ).duplicate(source.id, localeCode: 'pl-PL');

        expect(result.meta.id, 'polish-copy-id');
        expect(result.meta.name, 'Łódź-kopia-3');
        expect(
          repository.duplicateCalls.single.duplicateMeta.name,
          result.meta.name,
        );
      },
    );

    test(
      'rename trims the stored display name and returns a rename result',
      () async {
        final source = _meta(id: 'source', name: 'Old name');
        final repository = _FakeSaveRepository(index: [source]);

        final result = await _service(
          repository,
          timestamp: DateTime.utc(2030, 5, 6),
        ).rename(source.id, '  New name  ');

        expect(result.isRename, isTrue);
        expect(result.isDuplicate, isFalse);
        expect(result.meta.id, source.id);
        expect(result.meta.name, 'New name');
        expect(repository.renameCalls, hasLength(1));
        expect(repository.renameCalls.single.id, source.id);
        expect(repository.renameCalls.single.newName, 'New name');
      },
    );

    test(
      'rename rejects an empty trimmed name before reading or writing',
      () async {
        final repository = _FakeSaveRepository(
          index: [_meta(id: 'source', name: 'Source')],
        );

        await _expectFailure(
          () => _service(
            repository,
            timestamp: DateTime.utc(2030, 5, 6),
          ).rename('source', ' \t\n '),
          SaveManagementFailure.emptyName,
        );

        expect(repository.listSavesCalls, 0);
        expect(repository.renameCalls, isEmpty);
      },
    );

    test(
      'rename compares the proposed name with the current Name_Key',
      () async {
        final source = _meta(id: 'source', name: 'Śląsk Łódź');
        final repository = _FakeSaveRepository(index: [source]);

        await _expectFailure(
          () => _service(
            repository,
            timestamp: DateTime.utc(2030, 5, 6),
          ).rename(source.id, ' slask lodz '),
          SaveManagementFailure.sameName,
        );

        expect(repository.renameCalls, isEmpty);
      },
    );

    test('rename rejects a collision with another indexed Name_Key', () async {
      final source = _meta(id: 'source', name: 'Home');
      final other = _meta(id: 'other', name: 'ŁÓDŹ');
      final repository = _FakeSaveRepository(index: [source, other]);

      await _expectFailure(
        () => _service(
          repository,
          timestamp: DateTime.utc(2030, 5, 6),
        ).rename(source.id, ' lodz '),
        SaveManagementFailure.nameTaken,
      );

      expect(repository.renameCalls, isEmpty);
    });

    test('duplicate and rename report an absent indexed source', () async {
      final other = _meta(id: 'other', name: 'Other');
      final repository = _FakeSaveRepository(index: [other]);
      final service = _service(
        repository,
        timestamp: DateTime.utc(2030, 5, 6),
        idCandidates: ['unused-id'],
      );

      await _expectFailure(
        () => service.duplicate('missing', localeCode: 'en'),
        SaveManagementFailure.sourceUnavailable,
      );
      await _expectFailure(
        () => service.rename('missing', 'New name'),
        SaveManagementFailure.sourceUnavailable,
      );

      expect(repository.duplicateCalls, isEmpty);
      expect(repository.renameCalls, isEmpty);
    });

    test(
      'maps duplicate source and write exceptions without returning success',
      () async {
        final source = _meta(id: 'source', name: 'Source');
        final cases = <MapEntry<Object, SaveManagementFailure>>[
          MapEntry(
            SaveFileNotFoundException(saveId: source.id),
            SaveManagementFailure.sourceUnavailable,
          ),
          MapEntry(
            InvalidSerializedSaveException(
              saveId: source.id,
              reason: 'invalid JSON',
            ),
            SaveManagementFailure.invalidSerializedSave,
          ),
          MapEntry(
            SaveRepositoryException('write failed'),
            SaveManagementFailure.writeFailed,
          ),
          MapEntry(
            SaveAmbiguousWriteException(saveId: 'duplicate-id'),
            SaveManagementFailure.ambiguousWrite,
          ),
        ];

        for (final entry in cases) {
          final repository = _FakeSaveRepository(
            index: [source],
            duplicateError: entry.key,
          );
          final service = _service(
            repository,
            timestamp: DateTime.utc(2030, 5, 6),
            idCandidates: ['duplicate-id'],
          );

          await _expectFailure(
            () => service.duplicate(source.id, localeCode: 'en'),
            entry.value,
          );
          expect(repository.duplicateCalls, hasLength(1));
        }
      },
    );

    test(
      'maps rename source and write exceptions without returning success',
      () async {
        final source = _meta(id: 'source', name: 'Source');
        final cases = <MapEntry<Object, SaveManagementFailure>>[
          MapEntry(
            SaveFileNotFoundException(saveId: source.id),
            SaveManagementFailure.sourceUnavailable,
          ),
          MapEntry(
            InvalidSerializedSaveException(
              saveId: source.id,
              reason: 'invalid JSON',
            ),
            SaveManagementFailure.invalidSerializedSave,
          ),
          MapEntry(
            SaveRepositoryException('write failed'),
            SaveManagementFailure.writeFailed,
          ),
          MapEntry(
            SaveAmbiguousWriteException(saveId: source.id),
            SaveManagementFailure.ambiguousWrite,
          ),
        ];

        for (final entry in cases) {
          final repository = _FakeSaveRepository(
            index: [source],
            renameError: entry.key,
          );
          final service = _service(
            repository,
            timestamp: DateTime.utc(2030, 5, 6),
          );

          await _expectFailure(
            () => service.rename(source.id, 'Renamed'),
            entry.value,
          );
          expect(repository.renameCalls, hasLength(1));
        }
      },
    );

    test('maps index and ID-selection failures to indexReadFailed', () async {
      final source = _meta(id: 'source', name: 'Source');
      final indexFailureRepository = _FakeSaveRepository(
        listError: SaveRepositoryException('index unavailable'),
      );
      await _expectFailure(
        () => _service(
          indexFailureRepository,
          timestamp: DateTime.utc(2030, 5, 6),
        ).rename(source.id, 'Renamed'),
        SaveManagementFailure.indexReadFailed,
      );
      expect(indexFailureRepository.renameCalls, isEmpty);

      final availabilityFailureRepository = _FakeSaveRepository(
        index: [source],
        availabilityError: SaveRepositoryException('fresh index unavailable'),
      );
      await _expectFailure(
        () => _service(
          availabilityFailureRepository,
          timestamp: DateTime.utc(2030, 5, 6),
          idCandidates: ['candidate'],
        ).duplicate(source.id, localeCode: 'en'),
        SaveManagementFailure.indexReadFailed,
      );
      expect(availabilityFailureRepository.duplicateCalls, isEmpty);
    });

    test('maps malformed indexed names to invalidSerializedSave', () async {
      final repository = _FakeSaveRepository(
        index: [_meta(id: 'source', name: '   ')],
      );

      await _expectFailure(
        () => _service(
          repository,
          timestamp: DateTime.utc(2030, 5, 6),
          idCandidates: ['candidate'],
        ).duplicate('source', localeCode: 'en'),
        SaveManagementFailure.invalidSerializedSave,
      );

      expect(repository.duplicateCalls, isEmpty);
      expect(repository.availabilityCalls, isEmpty);
    });
  });
}

Future<void> _expectFailure<T>(
  Future<T> Function() operation,
  SaveManagementFailure expected,
) async {
  await expectLater(
    operation(),
    throwsA(
      isA<SaveManagementException>().having(
        (error) => error.code,
        'code',
        expected,
      ),
    ),
  );
}

SaveManagementService _service(
  _FakeSaveRepository repository, {
  required DateTime timestamp,
  List<String> idCandidates = const <String>[],
}) {
  final candidates = idCandidates.iterator;
  return SaveManagementService(
    repository: repository,
    clock: () => timestamp,
    idGenerator: () {
      if (!candidates.moveNext()) {
        throw StateError('The test ID generator ran out of candidates');
      }
      return candidates.current;
    },
  );
}

GameSaveMeta _meta({
  required String id,
  required String name,
  int schemaVersion = SaveSchema.currentVersion,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return GameSaveMeta(
    id: id,
    name: name,
    createdAt: createdAt ?? DateTime.utc(2024, 1, 2, 3, 4),
    updatedAt: updatedAt ?? DateTime.utc(2024, 2, 3, 4, 5),
    seasonYear: 2024,
    phase: SeasonPhase.regular,
    playerTeamName: 'Test FC',
    schemaVersion: schemaVersion,
  );
}

class _FakeSaveRepository extends SaveRepository {
  _FakeSaveRepository({
    List<GameSaveMeta> index = const <GameSaveMeta>[],
    List<List<GameSaveMeta>>? indexSnapshots,
    Set<String> canonicalFileIds = const <String>{},
    Map<String, SaveFileInfo> inspections = const <String, SaveFileInfo>{},
    Map<String, Object> inspectionErrors = const <String, Object>{},
    this.listError,
    this.availabilityError,
    this.duplicateError,
    this.renameError,
  }) : _indexSnapshots = (indexSnapshots ?? <List<GameSaveMeta>>[index])
           .map(List<GameSaveMeta>.from)
           .toList(),
       _canonicalFileIds = Set<String>.from(canonicalFileIds),
       _inspections = Map<String, SaveFileInfo>.from(inspections),
       _inspectionErrors = Map<String, Object>.from(inspectionErrors),
       super();

  final List<List<GameSaveMeta>> _indexSnapshots;
  final Set<String> _canonicalFileIds;
  final Map<String, SaveFileInfo> _inspections;
  final Map<String, Object> _inspectionErrors;
  final Object? listError;
  final Object? availabilityError;
  final Object? duplicateError;
  final Object? renameError;

  int listSavesCalls = 0;
  final inspectCalls = <String>[];
  final availabilityCalls = <String>[];
  final duplicateCalls = <_DuplicateCall>[];
  final renameCalls = <_RenameCall>[];
  int _indexCursor = 0;

  @override
  Future<List<GameSaveMeta>> listSaves() async {
    listSavesCalls++;
    if (listError != null) throw listError!;
    if (_indexSnapshots.isEmpty) return const <GameSaveMeta>[];

    final snapshotIndex = _indexCursor < _indexSnapshots.length
        ? _indexCursor
        : _indexSnapshots.length - 1;
    _indexCursor++;
    return List<GameSaveMeta>.from(_indexSnapshots[snapshotIndex]);
  }

  @override
  Future<SaveFileInfo> inspectFile(String id) async {
    inspectCalls.add(id);
    final error = _inspectionErrors[id];
    if (error != null) throw error;
    return _inspections[id] ?? const SaveFileInfo.missing();
  }

  @override
  Future<bool> isSaveIdAvailable(String id) async {
    availabilityCalls.add(id);
    if (availabilityError != null) throw availabilityError!;
    final indexed = (await listSaves()).any((meta) => meta.id == id);
    return !indexed && !_canonicalFileIds.contains(id);
  }

  @override
  Future<GameSaveMeta> duplicateRaw({
    required String sourceId,
    required GameSaveMeta duplicateMeta,
  }) async {
    duplicateCalls.add(
      _DuplicateCall(sourceId: sourceId, duplicateMeta: duplicateMeta),
    );
    if (duplicateError != null) throw duplicateError!;
    return duplicateMeta;
  }

  @override
  Future<GameSaveMeta> renameRaw({
    required String id,
    required String newName,
  }) async {
    renameCalls.add(_RenameCall(id: id, newName: newName));
    if (renameError != null) throw renameError!;

    for (final meta in _indexSnapshots.last) {
      if (meta.id == id) return meta.copyWith(name: newName);
    }
    throw StateError('No indexed save for $id');
  }
}

class _DuplicateCall {
  const _DuplicateCall({required this.sourceId, required this.duplicateMeta});

  final String sourceId;
  final GameSaveMeta duplicateMeta;
}

class _RenameCall {
  const _RenameCall({required this.id, required this.newName});

  final String id;
  final String newName;
}
