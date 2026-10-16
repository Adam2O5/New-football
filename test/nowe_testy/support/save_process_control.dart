import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Future<void> killInterruptedWriter(
  Directory directory, {
  String checkpoint = 'gamePublished',
  String operation = 'save',
  bool initial = false,
  Future<void> Function()? whileBlocked,
}) async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  final cache = flutterRoot == null
      ? File(Platform.resolvedExecutable).parent.parent.parent.parent.path
      : '$flutterRoot/bin/cache';
  final process = await Process.start(
    '$cache/dart-sdk/bin/dart${Platform.isWindows ? '.exe' : ''}',
    [
      '$cache/flutter_tools.snapshot',
      'test',
      '--no-pub',
      'test/nowe_testy/support/save_crash_worker.dart',
      '--reporter',
      'expanded',
    ],
    environment: {
      'FOOTBALL_CRASH_DIR': directory.path,
      'FOOTBALL_CRASH_PHASE': checkpoint,
      'FOOTBALL_CRASH_OPERATION': operation,
      'FOOTBALL_CRASH_INITIAL': '$initial',
    },
  );
  final output = StringBuffer();
  final stdoutDone = process.stdout
      .transform(utf8.decoder)
      .listen(output.write)
      .asFuture<void>();
  final stderrDone = process.stderr
      .transform(utf8.decoder)
      .listen(output.write)
      .asFuture<void>();
  final ready = File('${directory.path}/worker-ready.json');
  final timeout = Stopwatch()..start();
  int? workerPid;
  int? ended;
  final exit = process.exitCode.then((code) => ended = code);
  try {
    while (!await ready.exists()) {
      if (ended != null) fail('Worker exited with $ended: $output');
      if (timeout.elapsed > const Duration(seconds: 90)) {
        fail('Worker did not reach publication barrier: $output');
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    final marker =
        jsonDecode(await ready.readAsString()) as Map<String, dynamic>;
    workerPid = marker['pid'] as int;
    await whileBlocked?.call();
    expect(Process.killPid(workerPid, ProcessSignal.sigkill), isTrue);
    await exit.timeout(const Duration(seconds: 30));
    workerPid = null;
    await Future.wait([stdoutDone, stderrDone]);
    expect(await File('${directory.path}/worker-finally').exists(), isFalse);
  } finally {
    if (workerPid != null) Process.killPid(workerPid, ProcessSignal.sigkill);
    process.kill();
  }
}
