import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/scouting.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/staff_service.dart';

import 'support/game_fixtures.dart';
import 'support/memory_save_repository.dart';

void main() {
  late MemorySaveRepository repository;
  late ProviderContainer container;
  late GameController controller;

  setUp(() async {
    repository = MemorySaveRepository(controllerSave());
    container = ProviderContainer(
      overrides: [saveRepositoryProvider.overrideWithValue(repository)],
    );
    controller = container.read(gameControllerProvider.notifier);
    await controller.loadGame(repository.game.meta.id);
  });
  tearDown(() => container.dispose());

  test('two queued player offers preserve both negotiations', () async {
    await controller.updateLeague(
      (league) => league.copyWith(
        freeAgents: [
          league.freeAgents.single,
          league.freeAgents.single.copyWith(id: 'second-free-agent'),
        ],
      ),
      autosave: false,
    );
    final gate = Completer<void>();
    final blocking = controller.enqueueSaveManagement(() => gate.future);
    const offer = ContractOffer(salary: 60000000, years: 2);
    final first = controller.offerFreeAgent(fixtureFreeAgentId, offer);
    final second = controller.offerFreeAgent('second-free-agent', offer);
    gate.complete();
    await blocking;
    expect(await first, ContractReaction.accept);
    expect(await second, ContractReaction.accept);
    expect(
      controller.save!.leagueState.negotiations.map((item) => item.subjectId),
      unorderedEquals([fixtureFreeAgentId, 'second-free-agent']),
    );
  });

  test('firing staff keeps a preceding roster and atmosphere update', () async {
    final league = beforeRollover();
    final originalTeam = league.playerTeam!;
    final expiredScout = originalTeam.staff.scout!.copyWith(
      contract: const StaffContract(salary: 1000000, yearsRemaining: 0),
    );
    final game = saveForLeague(
      league.updateTeam(
        originalTeam.copyWith(
          staff: originalTeam.staff.withMember(StaffRole.scout, expiredScout),
        ),
      ),
    );
    repository.games[game.meta.id] = game;
    await controller.loadGame(game.meta.id);
    final gate = Completer<void>();
    final blocking = controller.enqueueSaveManagement(() => gate.future);
    final change = controller.updateLeague((league) {
      final team = league.playerTeam!;
      return league.updateTeam(
        team.copyWith(
          atmosphere: 77,
          roster: [team.roster.first.copyWith(age: 32), ...team.roster.skip(1)],
        ),
      );
    });
    final fired = controller.fireStaff(StaffRole.scout);
    gate.complete();
    await blocking;
    await change;
    expect(await fired, isTrue);
    final team = controller.save!.leagueState.playerTeam!;
    expect(team.staff.scout, isNull);
    expect(team.atmosphere, 77);
    expect(team.roster.first.age, 32);
  });

  test(
    'a staff candidate removed while queued is not offered a contract',
    () async {
      final candidate = beforeRollover().staffFreeAgents.single;
      await controller.updateLeague(
        (league) => league.copyWith(staffFreeAgents: [candidate]),
        autosave: false,
      );
      final gate = Completer<void>();
      final blocking = controller.enqueueSaveManagement(() => gate.future);
      final removal = controller.updateLeague(
        (league) => league.copyWith(staffFreeAgents: []),
      );
      final offer = controller.offerStaff(
        candidate,
        const StaffOffer(salary: 1000000, years: 2),
      );
      gate.complete();
      await blocking;
      await removal;
      expect(await offer, StaffReaction.hardReject);
      expect(controller.save!.leagueState.staffFreeAgents, isEmpty);
      expect(controller.save!.leagueState.negotiations, isEmpty);
    },
  );

  test('Combine assignments validate the current completion flag', () async {
    final initial = seededLeague();
    final prospectId =
        initial.currentSeason.draftState!.draftClass.prospects.first.id;
    final team = initial.playerTeam!;
    final scout = beforeRollover().playerTeam!.staff.scout!.copyWith(
      attributes: const StaffAttributes(coverage: 5, evaluation: 5),
    );
    final league = initial
        .updateTeam(
          team.copyWith(
            staff: team.staff.withMember(StaffRole.scout, scout),
            scouting: TeamScouting(watchlistProspectIds: [prospectId]),
          ),
        )
        .copyWith(
          currentSeason: initial.currentSeason.copyWith(scoutReportDone: true),
        );
    final game = saveForLeague(league);
    repository.games[game.meta.id] = game;
    await controller.loadGame(game.meta.id);
    final gate = Completer<void>();
    final blocking = controller.enqueueSaveManagement(() => gate.future);
    final completion = controller.updateLeague(
      (league) => league.copyWith(
        currentSeason: league.currentSeason.copyWith(combineDone: true),
      ),
    );
    final assignments = controller.setCombineAssignments([prospectId]);
    gate.complete();
    await blocking;
    await completion;
    expect(await assignments, isFalse);
    expect(controller.save!.leagueState.currentSeason.combineDone, isTrue);
  });

  test('a failed mutation leaves the queue usable', () async {
    await expectLater(
      controller.updateLeague((_) => throw StateError('invalid command')),
      throwsStateError,
    );
    await controller.updateLeague((league) => league.copyWith(currentDay: 2));
    await controller.flushPendingSave();
    expect(repository.game.leagueState.currentDay, 2);
  });

  test('queued autosave preserves metadata applied before the write', () async {
    final change = controller.updateLeague(
      (league) => league.copyWith(currentDay: 2),
    );
    final rename = controller.enqueueSaveManagement(() async {
      final current = controller.save!;
      expect(
        controller.applyManagedMeta(
          current.meta.id,
          current.meta.copyWith(name: 'renamed-career'),
        ),
        isTrue,
      );
    });
    await change;
    await rename;
    await controller.flushPendingSave();
    expect(repository.game.meta.name, 'renamed-career');
    expect(repository.game.leagueState.currentDay, 2);
  });
}
