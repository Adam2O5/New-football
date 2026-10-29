@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/utils/squad_tile_metrics.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/app/widgets/tactics/substitute_sheet.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../../../helpers/fixtures/presentation_fixtures.dart';

void main() {
  for (final language in ['pl', 'en']) {
    for (final empty in [false, true]) {
      testWidgets('small screen, text 200%, $language, empty=$empty', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(320, 568));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final team = presentationTeam();
        final outgoing = team.roster.first.copyWith(
          name: 'Responsive Player With An Exceptionally Long Name For Layout',
        );
        final candidates = empty
            ? team.roster.take(0).toList()
            : team.roster.skip(1).toList();
        final selected = <String>[];
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(language),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            ),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showSubstituteSheet(
                    context,
                    l10n: AppLocalizations.of(context)!,
                    team: team,
                    outPlayer: outgoing,
                    candidates: candidates,
                    totalCandidateCount: candidates.length,
                    metricMode: SquadTileMetricMode.staminaForm,
                    onSelected: (player) => selected.add(player.id),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final scrollable = find.descendant(
          of: find.byType(SubstituteSheet),
          matching: find.byType(Scrollable),
        );
        if (empty) {
          await tester.drag(scrollable, const Offset(0, -500));
          await tester.pumpAndSettle();
          final context = tester.element(find.byType(SubstituteSheet));
          expect(
            find.text(AppLocalizations.of(context)!.substitute_sheetEmpty),
            findsWidgets,
          );
          expect(find.byType(PlayerListTile), findsNothing);
          expect(selected, isEmpty);
        } else {
          final last = find.byWidgetPredicate(
            (widget) =>
                widget is PlayerListTile &&
                widget.player.id == candidates.last.id,
          );
          await tester.scrollUntilVisible(last, 200, scrollable: scrollable);
          await tester.ensureVisible(last);
          await tester.tap(last);
          await tester.pumpAndSettle();
          expect(selected, [candidates.last.id]);
          expect(find.byType(SubstituteSheet), findsNothing);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
