import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/save_record.dart';

void main() {
  group('SaveRecord', () {
    test('maps metadata schema versions to compatibility statuses', () {
      final cases = <int, SaveCompatibility>{
        SaveSchema.currentVersion: SaveCompatibility.compatible,
        SaveSchema.currentVersion - 1: SaveCompatibility.older,
        SaveSchema.currentVersion + 1: SaveCompatibility.newer,
      };

      for (final entry in cases.entries) {
        final meta = _meta(schemaVersion: entry.key);
        final record = SaveRecord(
          meta: meta,
          compatibility: meta.compatibilityWith(SaveSchema.currentVersion),
          serializedFileAvailable: true,
          sizeBytes: 256,
        );

        expect(
          record.compatibility,
          entry.value,
          reason: 'schemaVersion=${entry.key}',
        );
        expect(record.meta, meta);
      }
    });

    test('distinguishes a missing file from an unavailable file size', () {
      const missing = SaveFileInfo.missing();
      expect(missing.exists, isFalse);
      expect(missing.sizeBytes, isNull);
      expect(missing.sizeReadFailed, isFalse);

      final missingRecord = SaveRecord(
        meta: _meta(),
        compatibility: SaveCompatibility.compatible,
        serializedFileAvailable: missing.exists,
        sizeBytes: missing.sizeBytes,
      );
      expect(missingRecord.serializedFileAvailable, isFalse);
      expect(missingRecord.sizeBytes, isNull);
      expect(missingRecord.sizeReadFailed, isFalse);

      const unavailable = SaveFileInfo.sizeUnavailable();
      expect(unavailable.exists, isTrue);
      expect(unavailable.sizeBytes, isNull);
      expect(unavailable.sizeReadFailed, isTrue);

      final unavailableRecord = SaveRecord(
        meta: _meta(),
        compatibility: SaveCompatibility.compatible,
        serializedFileAvailable: unavailable.exists,
        sizeBytes: unavailable.sizeBytes,
      );
      expect(unavailableRecord.serializedFileAvailable, isTrue);
      expect(unavailableRecord.sizeBytes, isNull);
      expect(unavailableRecord.sizeReadFailed, isTrue);
    });

    test('retains an available file size and typed operation result', () {
      const fileInfo = SaveFileInfo.available(2048);
      expect(fileInfo.exists, isTrue);
      expect(fileInfo.sizeBytes, 2048);
      expect(fileInfo.sizeReadFailed, isFalse);

      final meta = _meta();
      final duplicate = SaveManagementResult.duplicate(meta);
      final rename = SaveManagementResult.rename(meta);
      expect(duplicate.meta, meta);
      expect(duplicate.isDuplicate, isTrue);
      expect(duplicate.isRename, isFalse);
      expect(rename.isDuplicate, isFalse);
      expect(rename.isRename, isTrue);
    });
  });
}

GameSaveMeta _meta({int schemaVersion = SaveSchema.currentVersion}) {
  return GameSaveMeta(
    id: 'save-1',
    name: 'Save 1',
    createdAt: DateTime(2026, 1, 1, 10, 30),
    updatedAt: DateTime(2026, 1, 2, 11, 45),
    seasonYear: 2026,
    phase: SeasonPhase.regular,
    playerTeamName: 'Test FC',
    schemaVersion: schemaVersion,
  );
}
