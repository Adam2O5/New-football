@Tags(['ui'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';

import '../helpers/widgets/squad_screen_harness.dart';
import '../helpers/widgets/widget_harness.dart';

void main() {
  testWidgets('rejects unavailable assignments without changing domain lists', (
    tester,
  ) async {
    final base = task41Game(seed: 9405);
    final baseTeam = base.leagueState.playerTeam!;
    final starterId = baseTeam.lineupPlayerIds.first;
    final injuredId = baseTeam.benchPlayerIds.first;
    final injuredSource = baseTeam.roster.firstWhere(
      (player) => player.id == injuredId,
    );
    final injured = injuredSource.copyWith(
      state: injuredSource.state.copyWith(
        injury: const Injury(
          id: 'swap-rejection-injury',
          group: InjuryGroup.legMuscles,
          type: InjuryType.minor,
          daysTotal: 5,
          daysRemaining: 3,
        ),
      ),
    );
    final team = baseTeam.copyWith(
      roster: [
        for (final player in baseTeam.roster)
          player.id == injuredId ? injured : player,
      ],
    );
    final game = base.copyWith(leagueState: base.leagueState.updateTeam(team));
    final harness = SquadHarness(game);
    final semanticsHandle = tester.ensureSemantics();
    addTearDown(() => harness.dispose(tester));

    try {
      await harness.pump(tester);
      // A real load normalizes unavailable lineup/bench members first.
      await harness.controller.updateLeague((league) => league);
      await tester.pumpAndSettle();
      final l10n = screenLocalizations(tester);
      final normalizedTeam = harness.controller.save!.leagueState.playerTeam!;
      final beforeLineup = [...normalizedTeam.lineupPlayerIds];
      final beforeBench = [...normalizedTeam.benchPlayerIds];
      final starterTile = tester.widget<PlayerListTile>(tileFinder(starterId));
      expectRosterRowSelectionSemantics(
        tester,
        l10n,
        starterTile,
        selected: false,
      );
      starterTile.onTap();
      await tester.pump();
      expectRosterRowSelectionSemantics(
        tester,
        l10n,
        tester.widget<PlayerListTile>(tileFinder(starterId)),
        selected: true,
      );
      tester.widget<PlayerListTile>(tileFinder(injuredId)).onTap();
      await tester.pumpAndSettle();

      final after = harness.controller.save!.leagueState.playerTeam!;
      expect(after.lineupPlayerIds, beforeLineup);
      expect(after.benchPlayerIds, beforeBench);
      expectRosterRowSelectionSemantics(
        tester,
        l10n,
        tester.widget<PlayerListTile>(tileFinder(starterId)),
        selected: false,
      );
      expectRosterRowSelectionSemantics(
        tester,
        l10n,
        tester.widget<PlayerListTile>(tileFinder(injuredId)),
        selected: false,
      );
      expect(find.text(l10n.squad_cannotFieldInjured), findsOneWidget);
    } finally {
      semanticsHandle.dispose();
    }
  });
}
