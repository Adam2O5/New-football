@Tags(['integration'])
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/save_management_provider.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/save_record.dart';
import 'package:new_football/core/services/save_management_service.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/data/save_management_repository_adapter.dart';

import '../helpers/fixtures/game_fixtures.dart';

Future<Map<String, List<int>>> _snapshot(Directory directory) async => {
  for (final file in (await directory.list().toList()).whereType<File>())
    file.uri.pathSegments.last: await file.readAsBytes(),
};

class _AmbiguousInspection extends SaveRepository {
  _AmbiguousInspection(this.meta);
  final GameSaveMeta meta;
  @override
  Future<List<GameSaveMeta>> listSaves() async => [meta];
  @override
  Future<SaveFileInfo> inspectFile(String id) async =>
      throw SaveAmbiguousWriteException(saveId: id);
}

void main() {
  test(
    'malformed journal blocks operations and reaches the management provider',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'football-ambiguous-',
      );
      try {
        final repository = SaveRepository(overrideDirectory: directory);
        final save = controllerSave();
        await repository.save(save);
        await File(
          '${directory.path}/.save-transaction-v1.json',
        ).writeAsString('{broken');
        final before = await _snapshot(directory);
        for (final operation in <Future<Object?> Function()>[
          repository.listSaves,
          () => repository.load(save.meta.id),
          () => repository.inspectFile(save.meta.id),
          () => repository.readRawSave(save.meta.id),
          () => repository.isSaveIdAvailable('unused'),
          () => repository.save(save),
          () => repository.renameRaw(id: save.meta.id, newName: 'new'),
          () => repository.duplicateRaw(
            sourceId: save.meta.id,
            duplicateMeta: save.meta.copyWith(id: 'copy'),
          ),
          () => repository.delete(save.meta.id),
        ]) {
          await expectLater(
            operation(),
            throwsA(isA<SaveAmbiguousWriteException>()),
          );
          expect(await _snapshot(directory), before);
        }
        final container = ProviderContainer(
          overrides: [saveRepositoryProvider.overrideWithValue(repository)],
        );
        try {
          await expectLater(
            container.read(saveRecordsProvider.future),
            throwsA(
              isA<SaveManagementException>().having(
                (e) => e.code,
                'code',
                SaveManagementFailure.ambiguousWrite,
              ),
            ),
          );
        } finally {
          container.dispose();
        }
        expect(await _snapshot(directory), before);
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );
  test(
    'inspection cannot hide an ambiguous recovery as unavailable size',
    () async {
      final service = SaveManagementService(
        repository: SaveManagementRepositoryAdapter(
          _AmbiguousInspection(controllerSave().meta),
        ),
      );
      await expectLater(
        service.listRecords(),
        throwsA(
          isA<SaveManagementException>().having(
            (e) => e.code,
            'code',
            SaveManagementFailure.ambiguousWrite,
          ),
        ),
      );
    },
  );

  test(
    'unpublished journal staging is safe to discard; legacy files are left alone',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'football-journal-staging-',
      );
      try {
        final repository = SaveRepository(overrideDirectory: directory);
        await repository.save(controllerSave());
        final old = await repository.load('stage-zero');
        final pending = File(
          '${directory.path}/.save-transaction-v1.json.pending',
        );
        final legacy = File('${directory.path}/stage-zero.json.bak-historical');
        await pending.writeAsString('partial journal');
        await legacy.writeAsString('untouched');
        expect(await repository.load('stage-zero'), old);
        expect(await pending.exists(), isFalse);
        expect(await legacy.readAsString(), 'untouched');
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );
}
