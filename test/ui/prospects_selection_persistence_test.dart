@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/prospects_screen.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/scouting.dart';
import 'package:new_football/core/models/staff.dart';

import '../helpers/fixtures/game_fixtures.dart';
import '../helpers/widgets/stateful_screen_harness.dart';

void main() {
  for (final combine in [false, true]) {
    testWidgets(
      'prospect table persists selections on exit (Combine: $combine)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1600, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final original = seededLeague();
        final prospects = original
            .currentSeason
            .draftState!
            .draftClass
            .prospects
            .take(3)
            .toList();
        final scout = beforeRollover().playerTeam!.staff.scout!.copyWith(
          attributes: const StaffAttributes(coverage: 5, evaluation: 5),
        );
        final team = original.playerTeam!;
        final watchlist = combine
            ? prospects.take(2).map((p) => p.id).toList()
            : <String>[];
        final league = original.copyWith(
          teams: [
            team.copyWith(
              staff: team.staff.withMember(StaffRole.scout, scout),
              scouting: TeamScouting(watchlistProspectIds: watchlist),
            ),
          ],
          currentSeason: original.currentSeason.copyWith(
            scoutReportDone: true,
            draftState: original.currentSeason.draftState!.copyWith(
              draftClass: DraftClass(
                year: original.currentSeason.year,
                prospects: prospects,
              ),
            ),
          ),
        );
        final container = await screenSession(league);
        await mountStatefulScreen(
          tester,
          container,
          ProspectsScreen(initialCombine: combine),
          'en',
        );
        expect(find.byType(Checkbox), findsNWidgets(combine ? 2 : 3));
        final selectedRow = find.ancestor(
          of: find.text(prospects.first.name),
          matching: find.byType(InkWell),
        );
        final checkbox = find.descendant(
          of: selectedRow,
          matching: find.byType(Checkbox),
        );
        await tester.tap(checkbox);
        await tester.pumpAndSettle();
        expect(tester.widget<Checkbox>(checkbox).value, isTrue);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.runAsync(
          () => container
              .read(gameControllerProvider.notifier)
              .flushPendingSave(),
        );
        await tester.pumpAndSettle();
        final saved = container
            .read(activeLeagueProvider)!
            .playerTeam!
            .scouting;
        expect(
          saved.watchlistProspectIds,
          combine ? watchlist : [prospects.first.id],
        );
        expect(
          saved.combineAssignedProspectIds,
          combine ? [prospects.first.id] : isEmpty,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
