@Tags(['ui'])
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/widgets/team_selection/team_row.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/widgets/team_selection_harness.dart';

void main() {
  testWidgets(
    'exposes localized row semantics and orders every row before start',
    (tester) async {
      for (final locale in const [Locale('pl'), Locale('en')]) {
        final harness = TeamSelectionHarness(locale: locale);
        SemanticsHandle? semanticsHandle;
        try {
          await harness.pump(tester);
          semanticsHandle = ensureSemantics(tester);
          await tester.pump();

          final l10n = await AppLocalizations.delegate.load(locale);
          expectLocalizedNewGameChrome(tester, l10n);
          final teams = harness.gameFactory.previewTeams();
          final startFinder = find.bySemanticsLabel(l10n.newGame_start);
          expect(startFinder, findsOneWidget);
          final startNode = tester.getSemantics(startFinder);
          expect(startNode.label, l10n.newGame_start);
          expect(startNode.flagsCollection.isButton, isTrue);
          expect(
            startNode.getSemanticsData().hasAction(ui.SemanticsAction.tap),
            isTrue,
          );
          expect(l10n.newGame_start, isNotEmpty);

          for (final team in teams) {
            final rowFinder = teamRowFinder(team.id);
            if (rowFinder.evaluate().isEmpty) {
              final teamList = find.byKey(
                const ValueKey<String>('new-game-team-list'),
              );
              await tester.scrollUntilVisible(
                rowFinder,
                300,
                scrollable: teamListScrollable(teamList),
              );
            }
            await tester.pumpAndSettle();
            expect(rowFinder, findsOneWidget);

            final rowNode = expectTeamRowSemantics(
              tester,
              l10n,
              teamId: team.id,
              name: team.name,
              city: team.city,
              conferenceLabel: selectionConferenceLabel(l10n, team.conference),
              selected: false,
            );
            expectSemanticsPrecedes(rowNode, startNode);

            final imageFinder = find.descendant(
              of: rowFinder,
              matching: find.byType(Image),
            );
            expect(imageFinder, findsOneWidget);
            expect(
              semanticsSubtree(rowNode),
              hasLength(1),
              reason:
                  'the decorative logo must not add a semantics or focus node',
            );
          }

          final selectedTeam = teams.first;
          final teamList = find.byKey(
            const ValueKey<String>('new-game-team-list'),
          );
          final listScrollableState = tester.state<ScrollableState>(
            teamListScrollable(teamList),
          );
          listScrollableState.position.jumpTo(0);
          await tester.pumpAndSettle();
          await activateTeam(tester, selectedTeam.id);
          final selectedNode = expectTeamRowSemantics(
            tester,
            l10n,
            teamId: selectedTeam.id,
            name: selectedTeam.name,
            city: selectedTeam.city,
            conferenceLabel: selectionConferenceLabel(
              l10n,
              selectedTeam.conference,
            ),
            selected: true,
          );
          expectSemanticsPrecedes(selectedNode, startNode);

          final selectedRow = teamRowFinder(selectedTeam.id);
          expect(tester.widget<TeamRow>(selectedRow).selected, isTrue);
          final secondTeam = teams[1];
          final secondNode = expectTeamRowSemantics(
            tester,
            l10n,
            teamId: secondTeam.id,
            name: secondTeam.name,
            city: secondTeam.city,
            conferenceLabel: selectionConferenceLabel(
              l10n,
              secondTeam.conference,
            ),
            selected: false,
          );
          performSemanticsTap(secondNode);
          await tester.pump();

          expect(tester.widget<TeamRow>(selectedRow).selected, isFalse);
          expect(
            tester.widget<TeamRow>(teamRowFinder(secondTeam.id)).selected,
            isTrue,
          );
          expectTeamRowSemantics(
            tester,
            l10n,
            teamId: selectedTeam.id,
            name: selectedTeam.name,
            city: selectedTeam.city,
            conferenceLabel: selectionConferenceLabel(
              l10n,
              selectedTeam.conference,
            ),
            selected: false,
          );
          expectTeamRowSemantics(
            tester,
            l10n,
            teamId: secondTeam.id,
            name: secondTeam.name,
            city: secondTeam.city,
            conferenceLabel: selectionConferenceLabel(
              l10n,
              secondTeam.conference,
            ),
            selected: true,
          );
        } finally {
          semanticsHandle?.dispose();
          await harness.dispose(tester);
        }
      }
    },
  );

  testWidgets('semantic activation has the same result as a tap', (
    tester,
  ) async {
    final targetTeam = GameFactory().previewTeams().first;

    for (final locale in const [Locale('pl'), Locale('en')]) {
      final tapHarness = TeamSelectionHarness(locale: locale);
      try {
        await tapHarness.pump(tester);
        await activateTeam(tester, targetTeam.id);
        final tapSelection = tester
            .widget<TeamRow>(teamRowFinder(targetTeam.id))
            .selected;
        expect(tapSelection, isTrue);
      } finally {
        await tapHarness.dispose(tester);
      }

      final semanticHarness = TeamSelectionHarness(locale: locale);
      SemanticsHandle? semanticsHandle;
      try {
        await semanticHarness.pump(tester);
        semanticsHandle = ensureSemantics(tester);
        await tester.pump();
        final l10n = await AppLocalizations.delegate.load(locale);
        final rowNode = expectTeamRowSemantics(
          tester,
          l10n,
          teamId: targetTeam.id,
          name: targetTeam.name,
          city: targetTeam.city,
          conferenceLabel: selectionConferenceLabel(
            l10n,
            targetTeam.conference,
          ),
          selected: false,
        );
        performSemanticsTap(rowNode);
        await tester.pump();

        expect(
          tester.widget<TeamRow>(teamRowFinder(targetTeam.id)).selected,
          isTrue,
        );
      } finally {
        semanticsHandle?.dispose();
        await semanticHarness.dispose(tester);
      }
    }
  });
}
