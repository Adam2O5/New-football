@Tags(['long', 'slow', 'integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures/game_fixtures.dart';
import '../../helpers/processes/test_process.dart';

void main() {
  test(
    'independent Dart processes replay generation, dates, lottery and retirement after save/load',
    () async {
      final flutterRoot = Platform.environment['FLUTTER_ROOT'];
      final cache = flutterRoot == null
          ? File(Platform.resolvedExecutable).parent.parent.parent.parent.path
          : '$flutterRoot/bin/cache';
      final dart =
          '$cache/dart-sdk/bin/dart${Platform.isWindows ? '.exe' : ''}';
      final probe = File(
        'test/helpers/processes/determinism_process.dart',
      ).absolute.path;
      final packages = File('.dart_tool/package_config.json').absolute.path;
      Future<ProcessResult> run() => runTestProcess(dart, [
        '--disable-dart-dev',
        '--packages=$packages',
        probe,
        '$fixtureSeed',
      ]);
      final first = await run();
      final second = await run();
      expect(first.exitCode, 0, reason: '${first.stderr}');
      expect(second.exitCode, 0, reason: '${second.stderr}');
      expect(first.stdout == second.stdout, isTrue);
      final domain = jsonDecode(first.stdout as String) as Map<String, dynamic>;
      final league = seededLeague();
      expect(domain['lottery'], hasLength(10));
      expect(domain['draftOrder'], hasLength(90));
      final retirement = domain['retirement'] as Map<String, dynamic>;
      expect(retirement['done'], isTrue);
      final survivors = (retirement['rosters'] as List)
          .cast<List<dynamic>>()
          .fold<int>(0, (count, roster) => count + roster.length);
      final initialPlayers = league.teams.fold<int>(
        0,
        (count, team) => count + team.roster.length,
      );
      expect(survivors, inExclusiveRange(0, initialPlayers));
      expect(domain['class'] == null, isFalse);
      expect(
        jsonEncode(domain['class']),
        jsonEncode(league.currentSeason.draftState!.draftClass.toJson()),
      );
      final directory = await Directory.systemTemp.createTemp(
        'football-replay-',
      );
      try {
        final file = File('${directory.path}/game.json');
        await file.writeAsString(jsonEncode(saveForLeague(league).toJson()));
        final loaded = await runTestProcess(dart, [
          '--disable-dart-dev',
          '--packages=$packages',
          probe,
          '$fixtureSeed',
          file.path,
        ]);
        expect(loaded.exitCode, 0, reason: '${loaded.stderr}');
        expect(loaded.stdout == first.stdout, isTrue);
      } finally {
        await directory.delete(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
