import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Deliberately idle process tree used only by process-cleanup tests.
Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty) {
    final child = await Process.start(Platform.resolvedExecutable, [
      Platform.script.toFilePath(),
      'child',
    ]);
    stdout.writeln(jsonEncode({'parent': pid, 'child': child.pid}));
    await stdout.flush();
  }
  await Future<void>.delayed(const Duration(minutes: 10));
}
