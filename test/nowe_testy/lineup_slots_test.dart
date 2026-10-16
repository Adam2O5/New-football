import 'dart:convert';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/lineup_slots.dart';

import 'support/game_fixtures.dart';
import 'support/memory_save_repository.dart';

Team _team() {
  final base = controllerSave().leagueState.playerTeam!;
  final backs = fullBacks();
  return reconcileLineupSlots(
    base.copyWith(
      tactics: base.tactics.copyWith(formation: Formation.f433),
      roster: [backs.left, backs.right, ...base.roster],
      lineupPlayerIds: [backs.left.id, backs.right.id],
      benchPlayerIds: [base.roster.first.id],
    ),
  );
}

void main() {
  test('queued swap validates the roster after an earlier removal', () async {
    final base = controllerSave().leagueState;
    final team = _team();
    final repository = MemorySaveRepository(
      saveForLeague(base.updateTeam(team)),
    );
    final container = ProviderContainer(
      overrides: [saveRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final controller = container.read(gameControllerProvider.notifier);
    await controller.loadGame(repository.game.meta.id);
    final gate = Completer<void>();
    final blocker = controller.enqueueSaveManagement(() => gate.future);
    final removedId = team.lineupPlayerIds.first;
    final otherId = team.lineupPlayerIds[1];
    final removal = controller.updateLeague(
      (league) => league.updateTeam(
        league.playerTeam!.copyWith(
          roster: league.playerTeam!.roster
              .where((p) => p.id != removedId)
              .toList(),
        ),
      ),
    );
    final swap = controller.updateLeague(
      (league) => league.updateTeam(
        swapLineupPlayers(league.playerTeam!, removedId, otherId),
      ),
    );
    gate.complete();
    await blocker;
    await removal;
    await swap;
    final current = controller.save!.leagueState.playerTeam!;
    expect(current.roster.any((p) => p.id == removedId), isFalse);
    expect(current.lineupSlots.values, isNot(contains(removedId)));
  });
  test('LB/RB swap changes persisted slots and survives save/load', () {
    final team = _team();
    final backs = fullBacks();
    final left = team.lineupSlots.entries
        .singleWhere((e) => e.value == backs.left.id)
        .key;
    final right = team.lineupSlots.entries
        .singleWhere((e) => e.value == backs.right.id)
        .key;
    final next = swapLineupPlayers(team, backs.left.id, backs.right.id);
    expect(next.lineupSlots[left], backs.right.id);
    expect(next.lineupSlots[right], backs.left.id);
    final loaded = Team.fromJson(
      jsonDecode(jsonEncode(next.toJson())) as Map<String, dynamic>,
    );
    expect(reconcileLineupSlots(loaded).lineupSlots, next.lineupSlots);
  });
  test('XI and bench swap is disjoint; stale removed player cannot return', () {
    final team = _team();
    final first = team.lineupPlayerIds.first;
    final reserve = team.benchPlayerIds.single;
    final next = swapLineupPlayers(team, first, reserve);
    expect(next.lineupPlayerIds, contains(reserve));
    expect(next.benchPlayerIds, contains(first));
    expect(
      next.lineupPlayerIds.toSet().intersection(next.benchPlayerIds.toSet()),
      isEmpty,
    );
    final removed = team.copyWith(
      roster: team.roster.where((p) => p.id != first).toList(),
    );
    expect(
      identical(swapLineupPlayers(removed, first, reserve), removed),
      isTrue,
    );
  });
  test('formation changes keep valid slot choices and fill the rest once', () {
    final team = _team();
    final manual = swapLineupPlayers(
      team,
      team.lineupPlayerIds[0],
      team.lineupPlayerIds[1],
    );
    for (final formation in Formation.values) {
      final next = reconcileLineupSlots(
        manual.copyWith(tactics: manual.tactics.copyWith(formation: formation)),
      );
      expect(next.lineupSlots.values.toSet(), manual.lineupPlayerIds.toSet());
      expect(
        next.lineupSlots.keys.every(
          FormationLayout.of(formation).slots.map((s) => s.key).contains,
        ),
        isTrue,
      );
      expect(reconcileLineupSlots(next).lineupSlots, next.lineupSlots);
    }
  });
  test('injured or suspended starter leaves no stale slot reference', () {
    final team = _team();
    final id = team.lineupPlayerIds.first;
    final next = reconcileLineupSlots(
      team.copyWith(
        roster: [
          for (final p in team.roster)
            if (p.id == id)
              p.copyWith(state: p.state.copyWith(suspensionGamesRemaining: 1))
            else
              p,
        ],
      ),
    );
    expect(next.lineupSlots.values, isNot(contains(id)));
    expect(next.lineupPlayerIds, isNot(contains(id)));
  });
}
