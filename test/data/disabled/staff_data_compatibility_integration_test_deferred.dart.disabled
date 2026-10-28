@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/ai/ai_contract_market_service.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/negotiation_service.dart';
import 'package:new_football/core/services/staff_service.dart';
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

    test(
      'loads a realistic legacy save and keeps downstream staff boundaries canonical',
      () async {
        final game = GameFactory().create(
          const NewGameRequest(
            saveName: 'Legacy staff integration',
            playerTeamId: 'team_europe_0',
            seed: 424242,
          ),
        );
        await repository.save(game);

        final playerTeamId = game.leagueState.playerTeamId!;
        final originalTeam = game.leagueState.teamById(playerTeamId)!;
        final saveFile = File('${tempDir.path}/${game.meta.id}.json');
        final originalJson =
            jsonDecode(await saveFile.readAsString()) as Map<String, dynamic>;

        final legacyHead = staffMemberJson(
          role: StaffRole.headCoach,
          id: 'legacy-active-head',
          name: 'Legacy head coach',
          attributes: const StaffAttributes(
            tactics: 4.0,
            motivation: 2.0,
            // This field exists in old saves but is not relevant to headCoach.
            development: 5.0,
          ),
          extraAttributes: const {unknownStaffAttributeName: 4.0},
          previousAttributes: const StaffAttributes(
            tactics: 3.5,
            motivation: 2.0,
            development: 5.0,
          ),
          contract: staffFixtureContract(salary: 1250000, yearsRemaining: 2),
        );
        final mismatch = staffMemberJson(
          role: StaffRole.doctor,
          id: 'legacy-mismatched-scout',
          attributes: staffAttributesWithRawOverall(StaffRole.doctor, 4.5),
          contract: staffFixtureContract(salary: 2250000),
        );
        final unknownTeamCfo = staffMemberJson(
          role: StaffRole.cfo,
          rawRole: unknownStaffRoleValue,
          id: 'legacy-unknown-team-cfo',
          contract: staffFixtureContract(salary: 3000000),
        );
        final highScoutJson = staffMemberJson(
          role: StaffRole.scout,
          id: 'legacy-scout-326',
          attributes: staffAttributesWithRawOverall(
            StaffRole.scout,
            3.26,
            irrelevantValue: 5.0,
          ),
          extraAttributes: const {unknownStaffAttributeName: 4.0},
        );
        final lowScoutJson = staffMemberJson(
          role: StaffRole.scout,
          id: 'legacy-scout-324',
          attributes: staffAttributesWithRawOverall(
            StaffRole.scout,
            3.24,
            irrelevantValue: 5.0,
          ),
        );
        final duplicateScout = staffMemberJson(
          role: StaffRole.scout,
          id: 'legacy-scout-326',
          attributes: staffAttributesWithRawOverall(StaffRole.scout, 1.0),
        );
        final occupiedHeadCandidate = staffMemberJson(
          role: StaffRole.headCoach,
          id: 'legacy-occupied-head-candidate',
          attributes: staffAttributesWithRawOverall(StaffRole.headCoach, 5.0),
        );
        final partialLegacyHead = staffMemberJson(
          role: StaffRole.headCoach,
          id: 'legacy-partial-head',
          attributes: const StaffAttributes(
            tactics: 3.0,
            motivation: 2.0,
            // Missing motivation below must decode as 0.0; this legacy value
            // must not become a third head-coach rating input.
            development: 5.0,
          ),
          omitAttributes: const {'motivation'},
        );
        final malformedContract =
            staffMemberJson(
                role: StaffRole.doctor,
                id: 'legacy-malformed-contract',
              )
              ..['contract'] = <String, dynamic>{
                'salary': 'not-a-number',
                'yearsRemaining': 2,
              };
        final malformedRecord = <String, dynamic>{
          'id': 'legacy-malformed-record',
          'role': StaffRole.physio.name,
        };
        final unknownFreeAgent = staffMemberJson(
          role: StaffRole.scout,
          rawRole: unknownStaffRoleValue,
          id: 'legacy-unknown-free-agent',
          contract: staffFixtureContract(salary: 3500000),
        );

        final legacyJson = withRawStaffJson(
          originalJson,
          teamId: playerTeamId,
          teamStaff: teamStaffJson({
            StaffRole.headCoach: legacyHead,
            // The declared role is doctor, so this is a mismatch—not a scout.
            StaffRole.scout: mismatch,
            // This unknown role must become an EmptySlot, not a fallback CFO.
            StaffRole.cfo: unknownTeamCfo,
          }),
          staffFreeAgents: [
            highScoutJson,
            lowScoutJson,
            duplicateScout,
            occupiedHeadCandidate,
            partialLegacyHead,
            unknownFreeAgent,
            malformedContract,
            malformedRecord,
          ],
        );
        final legacyLeague = legacyJson['leagueState'] as Map<String, dynamic>;
        // Place the persisted fixture in a real FA-I market window while
        // retaining the generated schedule, rosters and player state.
        legacyLeague['currentWeek'] = staffFixtureFreeAgencyWeek();
        legacyLeague['currentDay'] = 1;
        legacyLeague['currentHour'] = 1;
        legacyLeague['hourlyStaffOfferUsed'] = false;
        (legacyLeague['currentSeason'] as Map<String, dynamic>)['phase'] =
            SeasonPhase.offseason.name;

        final originalLegacyJson =
            jsonDecode(jsonEncode(legacyJson)) as Map<String, dynamic>;
        final sanitized = StaffDataCompatibility.sanitizeGameSaveJson(
          legacyJson,
        );
        expect(
          legacyJson,
          equals(originalLegacyJson),
          reason: 'sanitization must not mutate the untrusted save tree',
        );

        final sanitizedLeague =
            sanitized.sanitizedJson['leagueState'] as Map<String, dynamic>;
        final sanitizedTeams = sanitizedLeague['teams'] as List<dynamic>;
        final sanitizedTeam = sanitizedTeams
            .cast<Map<String, dynamic>>()
            .firstWhere((team) => team['id'] == playerTeamId);
        final sanitizedStaff = sanitizedTeam['staff'] as Map<String, dynamic>;
        expect(sanitizedStaff['scout'], isNull);
        expect(sanitizedStaff['cfo'], isNull);
        expect(sanitizedStaff['youthCoach'], isNull);
        expect(sanitizedStaff['physio'], isNull);
        expect(sanitizedStaff['doctor'], isNull);
        expect(
          (sanitizedStaff['headCoach'] as Map<String, dynamic>)['id'],
          legacyHead['id'],
        );
        final sanitizedFreeAgents =
            sanitizedLeague['staffFreeAgents'] as List<dynamic>;
        final sanitizedFreeAgentIds = sanitizedFreeAgents
            .cast<Map<String, dynamic>>()
            .map((record) => record['id'])
            .toList(growable: false);
        expect(
          sanitizedFreeAgentIds,
          <String>[
            'legacy-scout-326',
            'legacy-scout-324',
            'legacy-occupied-head-candidate',
            'legacy-partial-head',
          ],
          reason:
              'only valid records, in persisted order, may cross the boundary',
        );
        final retainedScout = sanitizedFreeAgents
            .cast<Map<String, dynamic>>()
            .firstWhere((record) => record['id'] == 'legacy-scout-326');
        expect(
          (retainedScout['attributes']
              as Map<String, dynamic>)[unknownStaffAttributeName],
          4.0,
          reason: 'unknown attributes are tolerated at the JSON boundary',
        );

        final diagnostics = sanitized.diagnostics;
        expect(
          diagnostics.where(
            (diagnostic) =>
                diagnostic.reason == StaffDataDiagnosticReason.roleSlotMismatch,
          ),
          hasLength(1),
        );
        expect(
          diagnostics.where(
            (diagnostic) =>
                diagnostic.reason == StaffDataDiagnosticReason.unknownRole,
          ),
          hasLength(2),
        );
        expect(
          diagnostics.where(
            (diagnostic) =>
                diagnostic.reason ==
                StaffDataDiagnosticReason.duplicateStaffRecord,
          ),
          hasLength(1),
        );
        expect(
          diagnostics.where(
            (diagnostic) =>
                diagnostic.reason ==
                StaffDataDiagnosticReason.malformedStaffRecord,
          ),
          hasLength(2),
        );
        expect(
          diagnostics.map((diagnostic) => diagnostic.memberId),
          containsAll(<String>[
            'legacy-mismatched-scout',
            'legacy-unknown-team-cfo',
            'legacy-unknown-free-agent',
            'legacy-scout-326',
            'legacy-malformed-contract',
            'legacy-malformed-record',
          ]),
        );

        // Write the untrusted tree and prove SaveRepository performs the same
        // sanitation immediately before generated model decoding.
        await saveFile.writeAsString(jsonEncode(legacyJson));
        final loaded = await repository.load(game.meta.id);
        final loadedLeague = loaded.leagueState;
        final loadedTeam = loadedLeague.playerTeam!;
        expect(repository.lastStaffDiagnostics, equals(diagnostics));
        expect(loaded.schemaVersion, SaveSchema.currentVersion);
        expect(loaded.saveSeed, game.saveSeed);
        expect(loadedLeague.teams.length, game.leagueState.teams.length);
        expect(
          loadedLeague.currentSeason.year,
          game.leagueState.currentSeason.year,
        );
        expect(
          loadedLeague.currentSeason.schedule,
          game.leagueState.currentSeason.schedule,
          reason: 'legacy staff cleanup must not replace the saved schedule',
        );
        expect(
          loadedLeague.freeAgents,
          game.leagueState.freeAgents,
          reason: 'player free-agent state must survive staff cleanup',
        );
        expect(
          loadedTeam.roster,
          originalTeam.roster,
          reason: 'player roster and nested player state must survive load',
        );
        expect(loadedTeam.finance, originalTeam.finance);
        expect(loadedTeam.lineupPlayerIds, originalTeam.lineupPlayerIds);
        expect(loadedTeam.benchPlayerIds, originalTeam.benchPlayerIds);
        expect(loadedLeague.currentWeek, staffFixtureFreeAgencyWeek());
        expect(loadedLeague.currentDay, 1);
        expect(loadedLeague.currentHour, 1);

        final loadedHead = loadedTeam.staff.headCoach!;
        expect(loadedHead.id, 'legacy-active-head');
        expect(loadedHead.attributes.development, 5.0);
        expect(
          loadedHead.overall,
          3.0,
          reason:
              'legacy headCoach.development is retained as data but excluded from RawOverall',
        );
        expect(loadedTeam.staff.scout, isNull);
        expect(loadedTeam.staff.cfo, isNull);
        expect(loadedTeam.staff.youthCoach, isNull);
        expect(loadedTeam.staff.physio, isNull);
        expect(loadedTeam.staff.doctor, isNull);
        expect(loadedTeam.staff.canonicalMember(StaffRole.scout), isNull);
        expect(loadedTeam.staff.members.map((member) => member.id).toList(), [
          'legacy-active-head',
        ]);
        expect(
          loadedTeam.staff.totalSalary,
          1250000,
          reason: 'only the active valid contract may enter staff payroll',
        );

        final loadedFreeAgents = loadedLeague.canonicalStaffFreeAgents;
        expect(
          loadedFreeAgents.map((member) => member.id).toList(),
          sanitizedFreeAgentIds,
        );
        expect(
          loadedFreeAgents.every((member) => member.contract == null),
          isTrue,
          reason: 'free-agent records must not carry a malformed/legacy salary',
        );
        final loadedPartialHead = loadedFreeAgents.firstWhere(
          (member) => member.id == 'legacy-partial-head',
        );
        expect(loadedPartialHead.attributes.motivation, 0.0);
        expect(loadedPartialHead.attributes.development, 5.0);
        expect(
          loadedPartialHead.overall,
          1.5,
          reason: 'missing relevant legacy values use the model default 0.0',
        );
        final highScout = loadedFreeAgents.firstWhere(
          (member) => member.id == 'legacy-scout-326',
        );
        final lowScout = loadedFreeAgents.firstWhere(
          (member) => member.id == 'legacy-scout-324',
        );
        expect(highScout.overall, 3.26);
        expect(lowScout.overall, 3.24);
        expect(
          highScout.overall,
          greaterThan(lowScout.overall),
          reason: 'the two candidates intentionally collide only visually',
        );
        expect(
          loadedFreeAgents.where(
            (member) => member.id == 'legacy-unknown-free-agent',
          ),
          isEmpty,
        );
        expect(
          loadedFreeAgents.where(
            (member) => member.id == 'legacy-malformed-contract',
          ),
          isEmpty,
        );

        final marketStatus =
            loadedLeague.strengthTable?.entryFor(loadedTeam.id)?.teamStatus ??
            TeamStatus.pretender;
        final aiPolicy = AiContractMarketService();
        final aiPlan = aiPolicy.staffFreeAgentPlan(
          league: loadedLeague,
          team: loadedTeam,
          saveSeed: game.saveSeed,
        );
        expect(aiPlan, isNotNull);
        expect(
          aiPlan!.role,
          StaffRole.scout,
          reason:
              'AI must skip occupied headCoach and empty roles without candidates',
        );
        expect(
          aiPlan.member.id,
          'legacy-scout-326',
          reason:
              'AI must rank by RawOverall, not input order or a displayed bucket',
        );
        expect(aiPlan.member.overall, 3.26);
        expect(
          aiPlan.offerScore,
          closeTo(
            StaffService().staffOfferScore(
              highScout,
              aiPlan.offer,
              offeringTeamStatus: marketStatus,
              currentTeamStatus: marketStatus,
            ),
            1e-9,
          ),
        );
        expect(
          StaffService().hireValidationReason(loadedTeam, aiPlan.offer.salary),
          isNull,
        );

        final market = ContractMarketService();
        final occupiedHead = loadedFreeAgents.firstWhere(
          (member) => member.id == 'legacy-occupied-head-candidate',
        );
        expect(
          market.submitStaffOffer(
            league: loadedLeague,
            candidate: occupiedHead,
            offer: aiPlan.offer,
            saveSeed: game.saveSeed,
          ),
          isNull,
          reason: 'an occupied role must reject a valid free-agent candidate',
        );
        expect(
          market.submitStaffOffer(
            league: loadedLeague,
            candidate: highScout.copyWith(id: 'legacy-forged-candidate'),
            offer: aiPlan.offer,
            saveSeed: game.saveSeed,
          ),
          isNull,
          reason: 'market must not offer a member absent from loaded state',
        );
        final submitted = market.submitStaffOffer(
          league: loadedLeague,
          candidate: highScout,
          offer: aiPlan.offer,
          saveSeed: game.saveSeed,
        );
        expect(submitted, isNotNull);
        expect(submitted!.league.playerTeam!.staff.scout, isNull);
        final submittedNegotiation = submitted.league.negotiations.single;
        expect(submittedNegotiation.subjectId, highScout.id);
        expect(
          submittedNegotiation.offerScore,
          closeTo(aiPlan.offerScore, 1e-9),
          reason: 'the user market must reuse the AI/StaffService raw score',
        );

        final negotiationService = const NegotiationService();
        final pending = negotiationService
            .start(
              id: 'legacy-valid-signing',
              subjectId: highScout.id,
              subjectKind: NegotiationSubjectKind.staff,
              teamId: loadedTeam.id,
              phase: NegotiationPhase.freeAgencyPhaseI,
              offer: NegotiationOffer(
                salary: aiPlan.offer.salary,
                years: aiPlan.offer.years,
              ),
              seasonYear: loadedLeague.currentSeason.year,
              week: loadedLeague.currentWeek,
              day: loadedLeague.currentDay,
              hour: loadedLeague.currentHour!,
              offerScore: aiPlan.offerScore,
            )
            .copyWith(
              status: NegotiationStatus.pendingFinalization,
              requiresFinalization: true,
            );
        final signed = market.finalizeNegotiation(
          loadedLeague.copyWith(negotiations: [pending]),
          pending.id,
          saveSeed: game.saveSeed,
        );
        expect(signed, isNotNull);
        expect(signed!.playerTeam!.staff.scout?.id, highScout.id);
        expect(
          signed.playerTeam!.staff.totalSalary,
          1250000 + aiPlan.offer.salary,
        );
        expect(
          signed.canonicalStaffFreeAgents.where(
            (member) => member.id == highScout.id,
          ),
          isEmpty,
        );

        final absentPending = pending.copyWith(
          id: 'legacy-absent-signing',
          subjectId: 'legacy-malformed-contract',
        );
        final blockedSigning = market.finalizeNegotiation(
          loadedLeague.copyWith(negotiations: [absentPending]),
          absentPending.id,
          saveSeed: game.saveSeed,
        );
        expect(
          blockedSigning,
          isNull,
          reason:
              'signing must re-check the canonical post-load free-agent pool',
        );
        expect(loadedTeam.staff.scout, isNull);
        expect(loadedTeam.staff.totalSalary, 1250000);

        // A typed clean state can be saved again. The second load must be
        // semantically identical, and the compatibility boundary must now be
        // diagnostic-free without relying on generated/presentation output.
        await repository.save(loaded);
        final reloaded = await repository.load(game.meta.id);
        expect(repository.lastStaffDiagnostics, isEmpty);
        expect(reloaded.leagueState, loaded.leagueState);
        expect(reloaded.saveSeed, loaded.saveSeed);
        expect(reloaded.schemaVersion, loaded.schemaVersion);
        expect(reloaded.leagueState.playerTeam!.roster, originalTeam.roster);
        expect(reloaded.leagueState.playerTeam!.staff.totalSalary, 1250000);
        expect(
          reloaded.leagueState.canonicalStaffFreeAgents
              .map((member) => member.id)
              .toList(),
          sanitizedFreeAgentIds,
        );
        final cleanRaw = decodedSaveJson(reloaded);
        final cleanResult = StaffDataCompatibility.sanitizeGameSaveJson(
          cleanRaw,
        );
        expect(cleanResult.diagnostics, isEmpty);
        expect(cleanResult.sanitizedJson, cleanRaw);
      },
    );
  });
}
