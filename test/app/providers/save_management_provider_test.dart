import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/save_management_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/save_management_service.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/controlled_save_repository.dart';

void main() {
  late Directory tempDir;
  late SharedPreferences preferences;
  late GameSave activeGame;
  late ControlledSaveRepository repository;
  ProviderContainer? container;
  late GameController controller;

  SaveManagementService serviceFor(SaveRepository saveRepository) {
    var nextId = 0;
    return SaveManagementService(
      repository: saveRepository,
      clock: () => DateTime.utc(2040, 1, 2, 3, 4, 5),
      idGenerator: () => 'managed-${nextId++}',
    );
  }

  void openContainer({
    SaveRepository? saveRepository,
    SaveManagementService? service,
  }) {
    final effectiveRepository = saveRepository ?? repository;
    container?.dispose();
    container = ProviderContainer(
      overrides: [
        saveRepositoryProvider.overrideWithValue(effectiveRepository),
        saveManagementServiceProvider.overrideWithValue(
          service ?? serviceFor(effectiveRepository),
        ),
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
    );
    controller = container!.read(gameControllerProvider.notifier);
    controller.state = AsyncValue.data(activeGame);
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('nf_save_management_');
    SharedPreferences.setMockInitialValues(<String, Object>{
      'app_locale': 'en',
    });
    preferences = await SharedPreferences.getInstance();

    activeGame = _game();
    await SaveRepository(overrideDirectory: tempDir).save(activeGame);
    repository = ControlledSaveRepository(
      overrideDirectory: tempDir,
      waitForRelease: true,
      waitForManagementRelease: true,
    );
    openContainer();
  });

  tearDown(() async {
    container?.dispose();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test(
    'a pending persist completes before a duplicate enters the management queue',
    () async {
      final coordinator = container!.read(saveManagementCoordinatorProvider);
      final persist = controller.persist();
      await repository.firstSaveStarted;

      final duplicate = coordinator.duplicate(activeGame.meta.id);
      expect(repository.managementOperationCount, 0);
      expect(
        coordinator.isActionInFlight(
          activeGame.meta.id,
          SaveManagementAction.duplicate,
        ),
        isTrue,
      );

      repository.releaseSave();
      await repository.firstManagementOperationStarted;
      expect(repository.managementOperationCount, 1);

      repository.releaseManagement();
      final result = await duplicate;
      await persist;

      expect(result.isDuplicate, isTrue);
      expect(coordinator.isActionInFlight(
        activeGame.meta.id,
        SaveManagementAction.duplicate,
      ), isFalse);
      expect(repository.saveCount, 1);
      expect((await repository.listSaves()), hasLength(2));
    },
  );

  test(
    'a pending persist completes before an active rename enters the management queue',
    () async {
      final coordinator = container!.read(saveManagementCoordinatorProvider);
      final persist = controller.persist();
      await repository.firstSaveStarted;

      final rename = coordinator.rename(activeGame.meta.id, 'Renamed Active');
      expect(repository.managementOperationCount, 0);
      expect(
        coordinator.isActionInFlight(
          activeGame.meta.id,
          SaveManagementAction.rename,
        ),
        isTrue,
      );

      repository.releaseSave();
      await repository.firstManagementOperationStarted;
      expect(repository.managementOperationCount, 1);

      repository.releaseManagement();
      final result = await rename;
      await persist;

      expect(result.isRename, isTrue);
      expect(result.meta.name, 'Renamed Active');
      expect(coordinator.isActionInFlight(
        activeGame.meta.id,
        SaveManagementAction.rename,
      ), isFalse);
      expect((await repository.listSaves()).singleWhere(
        (meta) => meta.id == activeGame.meta.id,
      ).name, 'Renamed Active');
    },
  );

  test('management writes are serialized with no concurrent transactions', () async {
    final coordinator = container!.read(saveManagementCoordinatorProvider);
    final first = coordinator.duplicate(activeGame.meta.id);
    final second = coordinator.duplicate(activeGame.meta.id);

    await repository.firstManagementOperationStarted;
    expect(repository.managementOperationCount, 1);
    expect(repository.activeManagementWriteCount, 1);
    expect(
      coordinator.isActionInFlight(
        activeGame.meta.id,
        SaveManagementAction.duplicate,
      ),
      isTrue,
    );

    repository.releaseManagement();
    final results = await Future.wait([first, second]);

    expect(results.map((result) => result.meta.name).toList(), [
      'Active Save-copy',
      'Active Save-copy-2',
    ]);
    expect(repository.managementOperationCount, 2);
    expect(repository.activeManagementWriteCount, 0);
    expect(repository.maxConcurrentManagementWrites, 1);
    expect(
      coordinator.isActionInFlight(
        activeGame.meta.id,
        SaveManagementAction.duplicate,
      ),
      isFalse,
    );
  });

  test('duplicating the active save leaves the active GameSave unchanged', () async {
    final before = controller.save!;
    final coordinator = container!.read(saveManagementCoordinatorProvider);
    final duplicate = coordinator.duplicate(activeGame.meta.id);

    await repository.firstManagementOperationStarted;
    repository.releaseManagement();
    final result = await duplicate;

    expect(result.isDuplicate, isTrue);
    expect(controller.save, same(before));
    expect(controller.save!.meta, same(before.meta));
    expect(controller.save!.leagueState, same(before.leagueState));
    expect(controller.save!.saveSeed, before.saveSeed);
    expect((await repository.listSaves()), hasLength(2));
  });

  test(
    'renaming the active save synchronizes only metadata before the next persist',
    () async {
      final before = controller.save!;
      final coordinator = container!.read(saveManagementCoordinatorProvider);
      final rename = coordinator.rename(activeGame.meta.id, 'Renamed Active');

      await repository.firstManagementOperationStarted;
      final persist = controller.persist();
      expect(repository.saveCount, 0);

      repository.releaseManagement();
      await repository.firstSaveStarted;

      final attempted = repository.attemptedSaves.single;
      expect(attempted.meta.id, activeGame.meta.id);
      expect(attempted.meta.name, 'Renamed Active');
      expect(attempted.leagueState, same(before.leagueState));
      expect(attempted.saveSeed, before.saveSeed);
      expect(controller.save!.meta.name, 'Renamed Active');
      expect(controller.save!.leagueState, same(before.leagueState));
      expect(controller.save!.saveSeed, before.saveSeed);

      final result = await rename;
      repository.releaseSave();
      await persist;

      expect(result.isRename, isTrue);
      expect(result.meta.name, 'Renamed Active');
      expect(repository.saveCount, 1);
    },
  );

  test(
    'successful coordinator actions invalidate both save-list providers, but failures do not',
    () async {
      final countingRepository = _CountingSaveRepository([activeGame.meta]);
      final service = _CountingManagementService(
        repository: countingRepository,
        source: activeGame.meta,
      );
      openContainer(
        saveRepository: countingRepository,
        service: service,
      );

      final recordsSubscription = container!.listen(
        saveRecordsProvider,
        (_, _) {},
        fireImmediately: true,
      );
      final savesSubscription = container!.listen(
        savesListProvider,
        (_, _) {},
        fireImmediately: true,
      );
      await Future.wait([
        container!.read(saveRecordsProvider.future),
        container!.read(savesListProvider.future),
      ]);
      final initialRecordReads = service.listRecordsCalls;
      final initialLegacyReads = countingRepository.listSavesCalls;

      final coordinator = container!.read(saveManagementCoordinatorProvider);
      await coordinator.duplicate(activeGame.meta.id);
      await container!.read(saveRecordsProvider.future);
      await container!.read(savesListProvider.future);

      expect(service.listRecordsCalls, initialRecordReads + 1);
      expect(countingRepository.listSavesCalls, initialLegacyReads + 1);

      service.duplicateFailure = const SaveManagementException(
        SaveManagementFailure.writeFailed,
      );
      await expectLater(
        coordinator.duplicate(activeGame.meta.id),
        throwsA(
          isA<SaveManagementException>().having(
            (error) => error.code,
            'code',
            SaveManagementFailure.writeFailed,
          ),
        ),
      );

      final recordReadsAfterFailure = service.listRecordsCalls;
      final legacyReadsAfterFailure = countingRepository.listSavesCalls;
      await Future.wait([
        container!.read(saveRecordsProvider.future),
        container!.read(savesListProvider.future),
      ]);
      expect(service.listRecordsCalls, recordReadsAfterFailure);
      expect(countingRepository.listSavesCalls, legacyReadsAfterFailure);

      recordsSubscription.close();
      savesSubscription.close();
    },
  );

  test('a failed management write can be retried after the queue tail recovers', () async {
    final coordinator = container!.read(saveManagementCoordinatorProvider);
    repository.managementFailure = ControlledManagementFailure.beforeWrite;

    await expectLater(
      coordinator.duplicate(activeGame.meta.id),
      throwsA(
        isA<SaveManagementException>().having(
          (error) => error.code,
          'code',
          SaveManagementFailure.writeFailed,
        ),
      ),
    );
    expect(
      coordinator.isActionInFlight(
        activeGame.meta.id,
        SaveManagementAction.duplicate,
      ),
      isFalse,
    );
    expect(repository.activeManagementWriteCount, 0);
    expect((await repository.listSaves()), hasLength(1));

    repository.managementFailure = ControlledManagementFailure.none;
    repository.releaseManagement();
    final retry = await coordinator.duplicate(activeGame.meta.id);

    expect(retry.isDuplicate, isTrue);
    expect(repository.managementOperationCount, 2);
    expect((await repository.listSaves()), hasLength(2));
  });

  test('duplicate captures the locale at invocation before queued execution', () async {
    final localeController = container!.read(localeProvider.notifier);
    await localeController.setLocale(const Locale('en'));

    final coordinator = container!.read(saveManagementCoordinatorProvider);
    final persist = controller.persist();
    await repository.firstSaveStarted;
    final duplicate = coordinator.duplicate(activeGame.meta.id);

    await localeController.setLocale(const Locale('pl'));
    repository.releaseSave();
    await repository.firstManagementOperationStarted;
    repository.releaseManagement();

    final result = await duplicate;
    await persist;

    expect(result.meta.name, 'Active Save-copy');
    expect(result.meta.name, isNot(contains('-kopia')));
  });

  test('two rapid duplicates read the fresh index from the previous transaction', () async {
    final coordinator = container!.read(saveManagementCoordinatorProvider);
    final first = coordinator.duplicate(activeGame.meta.id);
    final second = coordinator.duplicate(activeGame.meta.id);

    await repository.firstManagementOperationStarted;
    repository.releaseManagement();
    final results = await Future.wait([first, second]);

    expect(results.map((result) => result.meta.name).toList(), [
      'Active Save-copy',
      'Active Save-copy-2',
    ]);
    expect(results.map((result) => result.meta.id).toSet(), hasLength(2));

    final index = await repository.listSaves();
    expect(index.where((meta) => meta.id == activeGame.meta.id), hasLength(1));
    for (final result in results) {
      expect(index.where((meta) => meta.id == result.meta.id), hasLength(1));
    }
    expect(
      index.where((meta) => meta.name.startsWith('Active Save-copy')),
      hasLength(2),
    );
  });

}

GameSave _game() {
  final generated = GameFactory().create(
    const NewGameRequest(
      saveName: 'Active Save',
      playerTeamId: 'team_europe_0',
      seed: 7811,
    ),
  );
  final timestamp = DateTime.utc(2026, 1, 2, 3, 4, 5);
  return generated.copyWith(
    meta: generated.meta.copyWith(
      id: 'active-save',
      name: 'Active Save',
      createdAt: timestamp,
      updatedAt: timestamp,
    ),
  );
}

class _CountingSaveRepository extends SaveRepository {
  _CountingSaveRepository(this._metas);

  final List<GameSaveMeta> _metas;
  int listSavesCalls = 0;

  @override
  Future<List<GameSaveMeta>> listSaves() async {
    listSavesCalls++;
    return List<GameSaveMeta>.from(_metas);
  }
}

class _CountingManagementService extends SaveManagementService {
  _CountingManagementService({
    required SaveRepository repository,
    required this.source,
  }) : super(repository: repository);

  final GameSaveMeta source;
  int listRecordsCalls = 0;
  SaveManagementException? duplicateFailure;

  @override
  Future<List<SaveRecord>> listRecords() async {
    listRecordsCalls++;
    return [
      SaveRecord(
        meta: source,
        compatibility: source.compatibilityWith(
          SaveRepository.currentSchemaVersion,
        ),
        serializedFileAvailable: true,
        sizeBytes: 1,
      ),
    ];
  }

  @override
  Future<SaveManagementResult> duplicate(
    String sourceId, {
    required String localeCode,
  }) async {
    final failure = duplicateFailure;
    if (failure != null) throw failure;
    return SaveManagementResult.duplicate(
      source.copyWith(
        id: 'fake-copy',
        name: '${source.name}-copy',
      ),
    );
  }
}
