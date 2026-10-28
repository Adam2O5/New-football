@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/data/staff_data_compatibility.dart';

import '../helpers/staff_role_ratings_test_helpers.dart';

void main() {
  test('normalizes invalid staff records without mutating the source tree', () {
    final active = staffMemberJson(
      role: StaffRole.headCoach,
      id: 'compat-active',
      contract: staffFixtureContract(),
    );
    final mismatch = staffMemberJson(
      role: StaffRole.doctor,
      id: 'compat-mismatch',
    );
    final validFreeAgent = staffMemberJson(
      role: StaffRole.scout,
      id: 'compat-free-agent',
    );
    final input = <String, dynamic>{
      'teams': [
        <String, dynamic>{
          'staff': teamStaffJson({
            StaffRole.headCoach: active,
            StaffRole.scout: mismatch,
          }),
        },
      ],
      'staffFreeAgents': [
        validFreeAgent,
        Map<String, dynamic>.from(validFreeAgent),
        staffMemberJson(
          role: StaffRole.cfo,
          rawRole: unknownStaffRoleValue,
          id: 'compat-unknown',
        ),
        <String, dynamic>{'id': 'compat-malformed', 'role': 'scout'},
      ],
    };
    final original = jsonDecode(jsonEncode(input)) as Map<String, dynamic>;

    final result = StaffDataCompatibility.sanitizeLeagueStateJson(input);
    final sanitizedLeague = result.sanitizedJson;
    final sanitizedTeam =
        (sanitizedLeague['teams'] as List<dynamic>).single
            as Map<String, dynamic>;
    final sanitizedStaff = sanitizedTeam['staff'] as Map<String, dynamic>;
    final sanitizedFreeAgents =
        sanitizedLeague['staffFreeAgents'] as List<dynamic>;

    expect(input, equals(original));
    expect(
      (sanitizedStaff['headCoach'] as Map<String, dynamic>)['id'],
      'compat-active',
    );
    expect(
      sanitizedStaff['scout'],
      isNull,
      reason: 'a mismatch must become an EmptySlot, never another role',
    );
    expect(sanitizedFreeAgents, hasLength(1));
    expect(
      (sanitizedFreeAgents.single as Map<String, dynamic>)['id'],
      'compat-free-agent',
    );
    expect(
      result.diagnostics.map((diagnostic) => diagnostic.reason),
      containsAll(<String>[
        StaffDataDiagnosticReason.roleSlotMismatch,
        StaffDataDiagnosticReason.unknownRole,
        StaffDataDiagnosticReason.malformedStaffRecord,
        StaffDataDiagnosticReason.duplicateStaffRecord,
      ]),
    );
  });

  test('typed staff collections exclude mismatches and duplicate IDs', () {
    final active = staffMemberFor(
      StaffRole.headCoach,
      id: 'typed-active',
      contract: staffFixtureContract(salary: 1250000),
    );
    final duplicate = active.copyWith(
      attributes: active.attributes.copyWith(tactics: 1.0),
    );
    final mismatched = staffMemberFor(
      StaffRole.doctor,
      id: 'typed-mismatch',
      contract: staffFixtureContract(salary: 2250000),
    );
    final staff = TeamStaff(headCoach: active, scout: mismatched);

    expect(staff.canonicalMember(StaffRole.headCoach), same(active));
    expect(staff.canonicalMember(StaffRole.scout), isNull);
    expect(staff.members, [active]);
    expect(staff.totalSalary, active.contract!.salary);

    final league = staffFixtureLeague(
      staffFreeAgents: [active, duplicate, mismatched],
    );
    expect(league.canonicalStaffFreeAgents, [active, mismatched]);
  });

  group('SaveRepository staff compatibility boundary', () {
    late Directory tempDir;
    late SaveRepository repository;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('nf_staff_compat_');
      repository = SaveRepository(overrideDirectory: tempDir);
    });

    tearDown(() async {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    test(
      'loads valid staff, excludes invalid records, and preserves players',
      () async {
        final game = GameFactory().create(
          const NewGameRequest(
            saveName: 'Staff compatibility',
            playerTeamId: 'team_europe_0',
            seed: 4242,
          ),
        );
        await repository.save(game);

        final file = File('${tempDir.path}/${game.meta.id}.json');
        final json =
            jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        final league = json['leagueState'] as Map<String, dynamic>;
        final teams = league['teams'] as List<dynamic>;
        final firstTeam = teams.first as Map<String, dynamic>;
        final active = staffMemberJson(
          role: StaffRole.headCoach,
          id: 'load-active-head',
          contract: staffFixtureContract(salary: 1250000),
        );
        final mismatch = staffMemberJson(
          role: StaffRole.doctor,
          id: 'load-mismatched-scout',
        );
        final unknown = staffMemberJson(
          role: StaffRole.cfo,
          rawRole: unknownStaffRoleValue,
          id: 'load-unknown-cfo',
        );
        final validFreeAgent = staffMemberJson(
          role: StaffRole.youthCoach,
          id: 'load-valid-free-agent',
        );
        final malformed = <String, dynamic>{
          'id': 'load-malformed',
          'role': StaffRole.scout.name,
        };
        firstTeam['staff'] = teamStaffJson({
          StaffRole.headCoach: active,
          StaffRole.scout: mismatch,
          StaffRole.cfo: unknown,
        });
        league['staffFreeAgents'] = [
          validFreeAgent,
          Map<String, dynamic>.from(validFreeAgent),
          unknown,
          malformed,
        ];
        await file.writeAsString(jsonEncode(json));

        final loaded = await repository.load(game.meta.id);
        final loadedTeam = loaded.leagueState.teams.first;
        final loadedFreeAgents = loaded.leagueState.staffFreeAgents;

        expect(loaded.schemaVersion, SaveSchema.currentVersion);
        expect(loaded.saveSeed, game.saveSeed);
        expect(loaded.leagueState.teams.length, game.leagueState.teams.length);
        expect(
          loadedTeam.roster.length,
          game.leagueState.teams.first.roster.length,
          reason:
              'player roster data must not be changed by staff sanitization',
        );
        expect(loadedTeam.staff.headCoach?.id, 'load-active-head');
        expect(
          loadedTeam.staff.scout,
          isNull,
          reason: 'role/slot mismatch must be excluded before decoding',
        );
        expect(
          loadedTeam.staff.cfo,
          isNull,
          reason: 'UnknownRole must not be assigned to a fallback slot',
        );
        expect(
          loadedFreeAgents.where(
            (member) => member.id == 'load-valid-free-agent',
          ),
          hasLength(1),
        );
        expect(
          loadedFreeAgents.where((member) => member.id == 'load-unknown-cfo'),
          isEmpty,
        );
        expect(
          loadedFreeAgents.where((member) => member.id == 'load-malformed'),
          isEmpty,
        );
        expect(
          loadedTeam.staff.totalSalary,
          1250000,
          reason: 'only the valid active team contract may enter payroll',
        );

        final diagnostics = repository.lastStaffDiagnostics;
        expect(diagnostics, isNotEmpty);
        expect(
          diagnostics.map((diagnostic) => diagnostic.reason),
          containsAll(<String>[
            StaffDataDiagnosticReason.roleSlotMismatch,
            StaffDataDiagnosticReason.unknownRole,
            StaffDataDiagnosticReason.malformedStaffRecord,
            StaffDataDiagnosticReason.duplicateStaffRecord,
          ]),
        );
        expect(diagnostics, isA<List<StaffDataDiagnostic>>());
      },
    );
  });
}
