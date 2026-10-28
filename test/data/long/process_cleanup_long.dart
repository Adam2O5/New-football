@Tags(['long', 'integration'])
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../helpers/processes/test_process.dart';

void main() {
  final root = Platform.environment['FLUTTER_ROOT'];
  final cache = root == null
      ? File(Platform.resolvedExecutable).parent.parent.parent.parent.path
      : '$root/bin/cache';
  final dart = '$cache/dart-sdk/bin/dart${Platform.isWindows ? '.exe' : ''}';
  final worker = File(
    'test/helpers/processes/waiting_worker.dart',
  ).absolute.path;

  test(
    'Windows cleanup after a callback failure terminates parent and child',
    () async {
      final process = await startTestProcess(dart, [worker]);
      late Map<String, dynamic> pids;
      final failure = StateError('interrupted assertion');
      await expectLater(() async {
        try {
          final line = await process.stdout
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .first
              .timeout(const Duration(seconds: 15));
          pids = jsonDecode(line) as Map<String, dynamic>;
          throw failure;
        } finally {
          await stopTestProcessTree(process);
        }
      }(), throwsA(same(failure)));
      expect(
        Process.killPid(pids['parent'] as int, ProcessSignal.sigterm),
        isFalse,
      );
      expect(
        Process.killPid(pids['child'] as int, ProcessSignal.sigterm),
        isFalse,
      );
    },
    skip: !Platform.isWindows,
  );

  test(
    'a stalled worker times out and pipe cleanup completes promptly',
    () async {
      await expectLater(
        runTestProcess(dart, [
          worker,
        ], timeout: const Duration(milliseconds: 200)),
        throwsA(isA<TimeoutException>()),
      );
    },
  );
}
