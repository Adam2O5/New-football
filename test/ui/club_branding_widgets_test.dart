import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/branding/club_branding_registry.dart';
import 'package:new_football/app/branding/club_branding_types.dart';
import 'package:new_football/app/widgets/team_selection/team_row.dart';

void main() {
  testWidgets('renders preview text, branded surfaces, and the mapped logo', (
    tester,
  ) async {
    final branding = ClubBrandingRegistry.production.resolve('team_europe_2');
    const label = 'Marseille CF, Marseille, Europe, Not selected';

    await tester.pumpWidget(
      _tileApp(
        branding: branding,
        selected: false,
        label: label,
        onActivate: () {},
      ),
    );
    await tester.pump();

    expect(find.text('Marseille CF'), findsOneWidget);
    expect(find.text('Marseille · Europe'), findsOneWidget);
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<AssetImage>());
    expect((image.image as AssetImage).assetName, branding.logoAsset);
    expect(tester.getSize(find.byType(Image)), const Size(48, 48));
    expect(
      find.byKey(const ValueKey<String>('team-row-secondary-team_europe_2')),
      findsOneWidget,
    );
    expect(tester.widget<Card>(find.byType(Card)).color, branding.primaryColor);
    expect(
      tester
          .getSize(
            find.byKey(
              const ValueKey<String>('team-row-secondary-team_europe_2'),
            ),
          )
          .height,
      4,
    );
  });

  testWidgets(
    'selected tile exposes one activation node and a non-color indicator',
    (tester) async {
      var activations = 0;
      final branding = ClubBrandingRegistry.production.resolve('team_europe_0');
      const label = 'Syrenka FC, Warsaw, Europe, Selected';
      final semanticsHandle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          _tileApp(
            branding: branding,
            selected: true,
            label: label,
            onActivate: () => activations++,
          ),
        );
        await tester.pump();

        expect(find.byIcon(Icons.check_circle), findsOneWidget);
        final row = find.bySemanticsLabel(label);
        expect(row, findsOneWidget);
        final node = tester.getSemantics(row);
        expect(node.flagsCollection.isButton, isTrue);
        expect(node.flagsCollection.isSelected, ui.Tristate.isTrue);
        expect(
          node.getSemanticsData().hasAction(ui.SemanticsAction.tap),
          isTrue,
        );

        await tester.tap(find.byType(TeamRow));
        await tester.pump();
        expect(activations, 1);
      } finally {
        semanticsHandle.dispose();
      }
    },
  );

  testWidgets(
    'keeps a complete renderable resolution for every production ID',
    (tester) async {
      for (final record in ClubBrandingRegistry.production.records) {
        final branding = ClubBrandingRegistry.production.resolve(record.teamId);
        await tester.pumpWidget(
          _tileApp(
            branding: branding,
            selected: false,
            label: '${record.teamId}, not selected',
            onActivate: () {},
          ),
        );
        await tester.pump();

        final image = tester.widget<Image>(find.byType(Image));
        expect((image.image as AssetImage).assetName, record.logoAsset);
        expect(find.byType(TeamRow), findsOneWidget);
        expect(tester.getSize(find.byType(Image)), const Size(48, 48));
      }
    },
  );
}

Widget _tileApp({
  required ClubBrandingResolution branding,
  required bool selected,
  required String label,
  required VoidCallback onActivate,
}) {
  return MaterialApp(
    theme: ThemeData.dark(useMaterial3: true),
    home: Scaffold(
      body: SizedBox(
        width: 360,
        child: TeamRow(
          teamId: branding.teamId,
          name: branding.teamId == 'team_europe_2'
              ? 'Marseille CF'
              : 'Syrenka FC',
          city: branding.teamId == 'team_europe_2' ? 'Marseille' : 'Warsaw',
          conferenceLabel: 'Europe',
          branding: branding,
          selected: selected,
          localizedSemanticsLabel: label,
          onActivate: onActivate,
        ),
      ),
    ),
  );
}
