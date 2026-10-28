import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/data/save_repository.dart';

import '../helpers/fixtures/game_fixtures.dart';

void main() {
  test(
    'current large payload survives save, load, rename and duplicate',
    () async {
      final game = largerSave();
      final directory = await Directory.systemTemp.createTemp(
        'football-payload-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final repository = SaveRepository(overrideDirectory: directory);
      final beforeSave = DateTime.now();

      await repository.save(game);

      final afterSave = DateTime.now();

      final loaded = await repository.load(game.meta.id);

      expect(loaded.meta.updatedAt.isBefore(beforeSave), isFalse);
      expect(loaded.meta.updatedAt.isAfter(afterSave), isFalse);
      expect(
        loaded ==
            game.copyWith(
              meta: game.meta.copyWith(updatedAt: loaded.meta.updatedAt),
            ),
        isTrue,
        reason: 'Only the save timestamp may change during save/load.',
      );

      final renamed = await repository.renameRaw(
        id: game.meta.id,
        newName: 'renamed-fixture',
      );

      expect(renamed.name, 'renamed-fixture');

      final duplicateMeta = renamed.copyWith(
        id: 'duplicate-fixture',
        name: 'duplicate-fixture',
      );

      await repository.duplicateRaw(
        sourceId: game.meta.id,
        duplicateMeta: duplicateMeta,
      );

      expect(
        await repository.load(game.meta.id) == loaded.copyWith(meta: renamed),
        isTrue,
        reason: 'Rename must preserve the payload and other metadata.',
      );
      expect(
        await repository.load(duplicateMeta.id) ==
            loaded.copyWith(meta: duplicateMeta),
        isTrue,
        reason: 'Duplicate must preserve the payload.',
      );
      expect(await repository.listSaves(), hasLength(2));
    },
  );
}
