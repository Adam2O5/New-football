@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/save_management_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/core/services/save_management_service.dart';
import 'package:new_football/data/save_repository.dart';

import '../helpers/fixtures/game_fixtures.dart';
import '../helpers/persistence/controlled_save_repository.dart';

void main() {
  late Directory directory;
  late ControlledSaveRepository repository;
  late ProviderContainer container;
  late GameController controller;
  late GameSave initial;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'football-management-flow-',
    );
    repository = ControlledSaveRepository(overrideDirectory: directory);
    initial = controllerSave();
    await repository.save(initial);
    SharedPreferences.setMockInitialValues({'app_locale': 'en'});
    final preferences = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        saveRepositoryProvider.overrideWithValue(repository),
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
    );
    controller = container.read(gameControllerProvider.notifier);
    await controller.loadGame(initial.meta.id);
  });

  tearDown(() async {
    repository.release();
    try {
      await controller.enqueueSaveManagement(() async {});
    } finally {
      container.dispose();
      await directory.delete(recursive: true);
    }
  });

  test(
    'rename, persist, duplicate, reload and delete use one real save store',
    () async {
      final coordinator = container.read(saveManagementCoordinatorProvider);
      await coordinator.rename(initial.meta.id, '  Renamed career  ');
      await controller.persist();
      final beforeDuplicate = controller.save!;
      final copy = await coordinator.duplicate(initial.meta.id);
      expect(copy.meta.id, isNot(initial.meta.id));
      expect(copy.meta.name, 'Renamed career-copy');
      expect(controller.save, same(beforeDuplicate));

      final records = await container.read(saveRecordsProvider.future);
      expect(
        records.map((r) => r.meta.id),
        unorderedEquals([initial.meta.id, copy.meta.id]),
      );
      for (final record in records) {
        expect(record.serializedFileAvailable, isTrue);
        expect(record.compatibility, SaveCompatibility.compatible);
        expect(
          record.sizeBytes,
          await File('${directory.path}/${record.meta.id}.json').length(),
        );
      }
      await controller.clear();
      await controller.loadGame(copy.meta.id);
      expect(controller.save!.meta.name, copy.meta.name);
      expect(
        controller.save!.leagueState == beforeDuplicate.leagueState,
        isTrue,
        reason: 'Duplicate and reload must preserve the complete league.',
      );
      expect(controller.save!.saveSeed, initial.saveSeed);
      await coordinator.delete(copy.meta.id);
      await controller.flushPendingSave();
      expect(controller.save, isNull);
      expect(
        await File('${directory.path}/${copy.meta.id}.json').exists(),
        isFalse,
      );
      expect((await repository.listSaves()).single.id, initial.meta.id);
      await controller.loadGame(initial.meta.id);
      expect(controller.save!.meta.name, 'Renamed career');
    },
  );

  test(
    'incompatible load rejects its Future and preserves the usable active career',
    () async {
      final incompatible = <GameSave>[];
      for (final version in [
        SaveSchema.currentVersion - 1,
        SaveSchema.currentVersion + 1,
      ]) {
        final game = initial.copyWith(
          schemaVersion: version,
          meta: initial.meta.copyWith(
            id: 'schema-$version',
            schemaVersion: version,
          ),
        );
        incompatible.add(game);
        await File(
          '${directory.path}/${game.meta.id}.json',
        ).writeAsString(jsonEncode(game.toJson()));
      }
      await File('${directory.path}/saves_index.json').writeAsString(
        jsonEncode([
          ...(await repository.listSaves()).map((m) => m.toJson()),
          ...incompatible.map((g) => g.meta.toJson()),
        ]),
      );
      await controller.updateLeague(
        (l) => l.copyWith(currentDay: 2),
        autosave: false,
      );
      final previous = controller.save!;
      for (final game in incompatible) {
        await expectLater(
          controller.loadGame(game.meta.id),
          throwsA(
            isA<SaveSchemaMismatchException>().having(
              (e) => e.foundVersion,
              'foundVersion',
              game.schemaVersion,
            ),
          ),
        );
        expect(controller.save, same(previous));
        expect(controller.state.hasError, isFalse);
        expect(
          (await repository.load(initial.meta.id)).leagueState ==
              previous.leagueState,
          isTrue,
        );
      }
      // The failed transitions must leave the controller and management queue usable.
      await controller.persist();
      await container
          .read(saveManagementCoordinatorProvider)
          .delete(initial.meta.id);
      expect(controller.save, isNull);
      expect(
        (await repository.listSaves()).map((m) => m.id),
        unorderedEquals(incompatible.map((g) => g.meta.id)),
      );
    },
  );

  test(
    'a failed management transaction rolls back and the shared queue can retry',
    () async {
      final coordinator = container.read(saveManagementCoordinatorProvider);
      final source = File('${directory.path}/${initial.meta.id}.json');
      final index = File('${directory.path}/saves_index.json');
      final sourceBefore = await source.readAsString();
      final indexBefore = await index.readAsString();
      repository.managementFailure =
          ControlledManagementFailure.beforeIndexPublication;
      await expectLater(
        coordinator.duplicate(initial.meta.id),
        throwsA(
          isA<SaveManagementException>().having(
            (e) => e.code,
            'code',
            SaveManagementFailure.writeFailed,
          ),
        ),
      );
      expect(await source.readAsString(), sourceBefore);
      expect(await index.readAsString(), indexBefore);
      expect(
        coordinator.isActionInFlight(
          initial.meta.id,
          SaveManagementAction.duplicate,
        ),
        isFalse,
      );
      repository.managementFailure = ControlledManagementFailure.none;
      await controller.updateLeague((l) => l.copyWith(currentDay: 2));
      await controller.persist();
      final result = await coordinator.duplicate(initial.meta.id);
      await controller.clear();
      await controller.loadGame(result.meta.id);
      expect(controller.save!.leagueState.currentDay, 2);
      expect(await repository.listSaves(), hasLength(2));
      expect(
        directory.listSync().where(
          (e) => RegExp(
            r'\.(tmp|bak|old|restore)-|\.save-transaction-v1\.json',
          ).hasMatch(e.path),
        ),
        isEmpty,
      );
    },
  );
}
