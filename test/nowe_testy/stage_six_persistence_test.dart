import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/data/staff_data_compatibility.dart';

import 'support/game_fixtures.dart';

class _NoGeneration extends SeedDataGenerator {
  @override
  LeagueState generateLeague({
    int year = 2026,
    String? playerTeamId,
    int? seed,
  }) {
    throw StateError('Preview must not generate a league.');
  }
}

void main() {
  test(
    'concurrent raw workers preserve all entries in the shared index',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'stage-six-workers-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final first = SaveRepository(overrideDirectory: directory);
      final second = SaveRepository(overrideDirectory: directory);
      final game = controllerSave();
      await first.save(game);
      await Future.wait([
        first.renameRaw(id: game.meta.id, newName: 'Renamed'),
        second.duplicateRaw(
          sourceId: game.meta.id,
          duplicateMeta: game.meta.copyWith(id: 'copy-one', name: 'Copy one'),
        ),
        first.duplicateRaw(
          sourceId: game.meta.id,
          duplicateMeta: game.meta.copyWith(id: 'copy-two', name: 'Copy two'),
        ),
      ]);
      final index = await first.listSaves();
      expect(index.map((meta) => meta.id).toSet(), {
        game.meta.id,
        'copy-one',
        'copy-two',
      });
      for (final meta in index) {
        final loaded = await second.load(meta.id);
        expect(loaded.meta, meta);
        expect(loaded.leagueState, game.leagueState);
      }
    },
  );
  test('club catalog agrees with generated IDs without generating people', () {
    final factory = GameFactory(seedGenerator: _NoGeneration());
    final preview = factory.previewTeams();
    expect(factory.previewTeams(), same(preview));
    expect(
      preview,
      seededLeague().teams
          .map(
            (team) => (
              id: team.id,
              name: team.name,
              city: team.city,
              conference: team.conference,
            ),
          )
          .toList(),
    );
    expect(() => preview.clear(), throwsUnsupportedError);
  });

  test(
    'staff normalization copies only edited branches and preserves input',
    () {
      final json =
          jsonDecode(jsonEncode(controllerSave().toJson()))
              as Map<String, dynamic>;
      final league = json['leagueState'] as Map<String, dynamic>;
      final team = (league['teams'] as List).first as Map<String, dynamic>;
      team['staff'] = {
        'headCoach': {'id': 'bad-role', 'role': 'unknown'},
      };
      league['staffFreeAgents'] = [42];
      final before = jsonEncode(json);
      final result = StaffDataCompatibility.sanitizeGameSaveJson(json);
      final normalizedLeague =
          result.json['leagueState'] as Map<String, dynamic>;
      final normalizedTeam = (normalizedLeague['teams'] as List).first as Map;
      expect(jsonEncode(json), before);
      expect(normalizedTeam['staff'], {'headCoach': null});
      expect(normalizedLeague['staffFreeAgents'], isEmpty);
      expect(normalizedTeam['roster'], same(team['roster']));
      expect(normalizedLeague['currentSeason'], same(league['currentSeason']));
      expect(result.diagnostics.map((d) => d.reason), [
        StaffDataDiagnosticReason.unknownRole,
        StaffDataDiagnosticReason.malformedStaffRecord,
      ]);
      final again = StaffDataCompatibility.sanitizeGameSaveJson(result.json);
      expect(again.json, result.json);
      expect(again.diagnostics, isEmpty);
      final leagueOnly = StaffDataCompatibility.sanitizeLeagueStateJson(league);
      expect(leagueOnly.json, normalizedLeague);
      expect(jsonEncode(json), before);
    },
  );

  for (final isolated in [false, true]) {
    test(
      'compact raw operations preserve payload (isolate: $isolated)',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'stage-six-raw-',
        );
        addTearDown(() => directory.delete(recursive: true));
        final repo = SaveRepository(
          overrideDirectory: directory,
          saveInIsolate: isolated,
        );
        final game = controllerSave();
        await repo.save(game);
        final file = File('${directory.path}/${game.meta.id}.json');
        final before =
            jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        final meta = await repo.renameRaw(
          id: game.meta.id,
          newName: 'New name',
        );
        final after =
            jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        final expected = {
          ...before,
          'meta': {...before['meta'] as Map, 'name': 'New name'},
        };
        expect(after, expected);
        expect(await file.length(), utf8.encode(jsonEncode(expected)).length);
        final copy = meta.copyWith(id: 'copy', name: 'Copy');
        await repo.duplicateRaw(sourceId: game.meta.id, duplicateMeta: copy);
        final copied = await repo.readRawSave(copy.id);
        expect(copied['leagueState'], before['leagueState']);
        expect(copied['meta'], copy.toJson());
        expect(
          await File('${directory.path}/copy.json').length(),
          utf8.encode(jsonEncode(copied)).length,
        );
      },
    );

    test(
      'load returns diagnostics and typed errors (isolate: $isolated)',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'stage-six-load-',
        );
        addTearDown(() => directory.delete(recursive: true));
        final repo = SaveRepository(
          overrideDirectory: directory,
          saveInIsolate: isolated,
        );
        final game = controllerSave();
        await repo.save(game);
        final file = File('${directory.path}/${game.meta.id}.json');
        final json =
            jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        final league = json['leagueState'] as Map<String, dynamic>;
        final team = (league['teams'] as List).first as Map<String, dynamic>;
        team['staff'] = {
          'headCoach': {'id': 'invalid', 'role': 'unknown'},
        };
        await file.writeAsString(jsonEncode(json));
        final loaded = await repo.load(game.meta.id);
        expect(loaded.leagueState.playerTeam!.staff.headCoach, isNull);
        expect(
          repo.lastStaffDiagnostics.single.reason,
          StaffDataDiagnosticReason.unknownRole,
        );
        expect(() => repo.lastStaffDiagnostics.clear(), throwsUnsupportedError);
        // Diagnostics survive a subsequent domain decoder error too.
        league['currentSeason'] = 'malformed';
        await file.writeAsString(jsonEncode(json));
        await expectLater(
          repo.load(game.meta.id),
          throwsA(isA<SaveRepositoryException>()),
        );
        expect(repo.lastStaffDiagnostics, hasLength(1));
        json['schemaVersion'] = SaveSchema.currentVersion + 1;
        await file.writeAsString(jsonEncode(json));
        await expectLater(
          repo.load(game.meta.id),
          throwsA(isA<SaveSchemaMismatchException>()),
        );
        expect(repo.lastStaffDiagnostics, isEmpty);
      },
    );
  }
}
