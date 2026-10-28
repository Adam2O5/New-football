import 'dart:convert';
import 'dart:io';

/// A separate process group on Linux lets cleanup reach a worker even when
/// the Flutter launcher failed before publishing the worker PID.
Future<Process> startTestProcess(
  String executable,
  List<String> arguments, {
  Map<String, String>? environment,
}) => Process.start(
  Platform.isLinux ? 'setsid' : executable,
  Platform.isLinux ? [executable, ...arguments] : arguments,
  environment: environment,
);

Future<void> stopTestProcessTree(Process process) async {
  if (Platform.isWindows) {
    await Process.run('taskkill', ['/PID', '${process.pid}', '/T', '/F']);
  } else if (Platform.isLinux) {
    await Process.run('kill', ['-KILL', '--', '-${process.pid}']);
  } else {
    process.kill(ProcessSignal.sigkill);
  }
  await process.exitCode.timeout(const Duration(seconds: 10));
}

Future<ProcessResult> runTestProcess(
  String executable,
  List<String> arguments, {
  Duration timeout = const Duration(seconds: 90),
}) async {
  final process = await startTestProcess(executable, arguments);
  // A timeout may cut a UTF-8 sequence. Keep pipe cleanup independent from
  // whether the interrupted worker finished writing a character.
  const decoder = Utf8Decoder(allowMalformed: true);
  final stdout = process.stdout.transform(decoder).join();
  final stderr = process.stderr.transform(decoder).join();
  try {
    final code = await process.exitCode.timeout(timeout);
    final output = await Future.wait([
      stdout,
      stderr,
    ]).timeout(const Duration(seconds: 10));
    return ProcessResult(process.pid, code, output[0], output[1]);
  } finally {
    await stopTestProcessTree(process);
    await Future.wait([stdout, stderr]).timeout(const Duration(seconds: 10));
  }
}
