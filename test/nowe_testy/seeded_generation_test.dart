import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/prospect_service.dart';
import 'package:new_football/core/services/schedule_generator.dart';

import 'support/game_fixtures.dart';

void main() {
  for (final teamId in [
    null,
    'team_europe_0',
    'team_europe_3',
    'team_restOfTheWorld_15',
  ]) {
    test('exactly one controlled club for $teamId', () {
      final league = SeedDataGenerator().generateLeague(
        seed: fixtureSeed,
        playerTeamId: teamId,
      );
      expect(
        league.teams
            .where((t) => t.isPlayerControlled)
            .map((t) => t.id)
            .toList(),
        [teamId ?? 'team_europe_0'],
      );
      expect(league.playerTeamId, teamId ?? 'team_europe_0');
    });
  }
  test('unknown player club is rejected by factory', () {
    expect(
      () => GameFactory().create(
        const NewGameRequest(
          saveName: 'invalid',
          playerTeamId: 'unknown',
          seed: fixtureSeed,
        ),
      ),
      throwsArgumentError,
    );
  });
  test(
    'factory reuse and previews do not change the seeded world or staff IDs',
    () {
      final factory = GameFactory();
      const request = NewGameRequest(
        saveName: 'replay',
        playerTeamId: 'team_europe_3',
        seed: fixtureSeed,
      );
      final first = factory.create(request);
      factory.previewTeams();
      final replay = factory.create(request);
      expect(first.leagueState == replay.leagueState, isTrue);
      expect(
        first.leagueState.teams
            .where((t) => t.isPlayerControlled)
            .map((t) => t.id)
            .toList(),
        ['team_europe_3'],
      );
      final ids = [
        for (final team in replay.leagueState.teams)
          ...team.staff.members.map((m) => m.id),
        ...replay.leagueState.staffFreeAgents.map((m) => m.id),
      ];
      expect(ids.toSet().length, ids.length);
    },
  );
  test('initial and next draft classes ignore unseeded service history', () {
    final generator = SeedDataGenerator(random: Random(1));
    final first = generator.generateLeague(seed: fixtureSeed);
    generator.generateDraftClass(year: 2035);
    expect(generator.generateLeague(seed: fixtureSeed) == first, isTrue);
    final service = ProspectService(random: Random(2));
    final next = service.generateNextDraftClass(
      currentYear: 2026,
      seed: fixtureSeed,
    );
    service.generateNextDraftClass(currentYear: 2035);
    expect(
      service.generateNextDraftClass(currentYear: 2026, seed: fixtureSeed),
      next,
    );
    expect(
      ProspectService(
        random: Random(9),
      ).generateNextDraftClass(currentYear: 2026, seed: fixtureSeed),
      next,
    );
    expect(
      ProspectService().generateNextDraftClass(
            currentYear: 2026,
            seed: fixtureSeed + 1,
          ) ==
          next,
      isFalse,
    );
  });
  test(
    'independent Dart processes reproduce classes, rosters and match dates after save/load',
    () async {
      final flutterRoot = Platform.environment['FLUTTER_ROOT'];
      final cache = flutterRoot == null
          ? File(Platform.resolvedExecutable).parent.parent.parent.parent.path
          : '$flutterRoot/bin/cache';
      final dart =
          '$cache/dart-sdk/bin/dart${Platform.isWindows ? '.exe' : ''}';
      final probe = File(
        'test/nowe_testy/support/determinism_process.dart',
      ).absolute.path;
      final packages = File('.dart_tool/package_config.json').absolute.path;
      Future<ProcessResult> run() => Process.run(
        dart,
        ['--disable-dart-dev', '--packages=$packages', probe, '$fixtureSeed'],
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );
      final first = await run();
      final second = await run();
      expect(first.exitCode, 0, reason: '${first.stderr}');
      expect(second.exitCode, 0, reason: '${second.stderr}');
      expect(first.stdout == second.stdout, isTrue);
      final domain = jsonDecode(first.stdout as String) as Map<String, dynamic>;
      final league = seededLeague();
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
        final loaded = await Process.run(
          dart,
          [
            '--disable-dart-dev',
            '--packages=$packages',
            probe,
            '$fixtureSeed',
            file.path,
          ],
          stdoutEncoding: utf8,
          stderrEncoding: utf8,
        );
        expect(loaded.exitCode, 0, reason: '${loaded.stderr}');
        expect(loaded.stdout == first.stdout, isTrue);
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );
  test('reference match days and legal spacing for several seeds', () {
    const weeks = [1, 2, 15, 29, 32, 43];
    const reference = {
      0: [(3, 6), (3, 7), (3, 6), (4, 7), (4, 7), (3, 7)],
      1: [(3, 6), (3, 6), (4, 7), (4, 7), (4, 7), (4, 7)],
      123: [(3, 7), (4, 7), (4, 7), (3, 6), (3, 7), (4, 7)],
      987654: [(3, 6), (4, 7), (3, 7), (3, 6), (3, 6), (4, 7)],
    };
    for (final entry in reference.entries) {
      expect([
        for (final week in weeks)
          (
            matchDaysForWeek(week, seed: entry.key).midweekDay,
            matchDaysForWeek(week, seed: entry.key).weekendDay,
          ),
      ], entry.value);
    }
    for (final seed in [0, 1, 123, 987654]) {
      for (var week = 1; week <= 52; week++) {
        final days = matchDaysForWeek(week, seed: seed);
        expect([3, 4], contains(days.midweekDay));
        expect([6, 7], contains(days.weekendDay));
        expect(days.weekendDay - days.midweekDay, greaterThanOrEqualTo(3));
      }
    }
  });
}
