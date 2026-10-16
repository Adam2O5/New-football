import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/data/save_repository.dart';

void main() {
  // Simulate a native registration whose root-isolate receiver no longer lives.
  final stopped = ReceivePort();
  IsolateNameServer.registerPortWithName(
    stopped.sendPort,
    'new_football.save_directory_coordinator.v1',
  );
  stopped.close();
  SaveRepository.initializeCoordinator();

  test('startup replaces a stale root coordinator registration', () async {
    final directory = await Directory.systemTemp.createTemp(
      'football-coordinator-start-',
    );
    try {
      expect(
        await SaveRepository(
          overrideDirectory: directory,
        ).listSaves().timeout(const Duration(seconds: 3)),
        isEmpty,
      );
      SaveRepository.initializeCoordinator();
      expect(
        await SaveRepository(overrideDirectory: directory).listSaves(),
        isEmpty,
      );
    } finally {
      await directory.delete(recursive: true);
    }
  });
}
