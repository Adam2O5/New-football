@Tags(['ui'])
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/widgets/team_selection/team_row.dart';
import 'package:new_football/app/widgets/team_selection/team_selection_assets.dart';

import '../helpers/widgets/team_selection_harness.dart';

void main() {
  testWidgets(
    'loads and decodes the active placeholder asset before rendering it',
    (tester) async {
      var assetLength = 0;
      var decodedWidth = 0;
      var decodedHeight = 0;
      await tester.runAsync(() async {
        final assetData = await rootBundle.load(
          TeamSelectionAssets.placeholderAsset,
        );
        assetLength = assetData.lengthInBytes;
        final codec = await ui.instantiateImageCodec(
          assetData.buffer.asUint8List(
            assetData.offsetInBytes,
            assetData.lengthInBytes,
          ),
        );
        try {
          final frame = await codec.getNextFrame();
          decodedWidth = frame.image.width;
          decodedHeight = frame.image.height;
          frame.image.dispose();
        } finally {
          codec.dispose();
        }
      });
      expect(assetLength, greaterThan(0));
      expect(decodedWidth, greaterThan(0));
      expect(decodedHeight, greaterThan(0));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamRow(
              teamId: 'asset-smoke-team',
              name: 'Asset Smoke FC',
              city: 'Test City',
              conferenceLabel: 'Test Conference',
              selected: false,
              placeholderAsset: TeamSelectionAssets.placeholderAsset,
              localizedSemanticsLabel:
                  'Asset Smoke FC, Test City, Test Conference, Not selected',
              onActivate: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<AssetImage>());
      expect(
        (image.image as AssetImage).assetName,
        TeamSelectionAssets.placeholderAsset,
      );
      expect(takeException(tester), isNull);
    },
  );

  testWidgets('keeps an unavailable placeholder out of semantics', (
    tester,
  ) async {
    var activations = 0;
    const label = 'Fallback FC, Test City, Test Conference, Not selected';
    final semanticsHandle = ensureSemantics(tester);
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeamRow(
              key: const ValueKey<String>('fallback-team-row'),
              teamId: 'fallback-team',
              name: 'Fallback FC',
              city: 'Test City',
              conferenceLabel: 'Test Conference',
              selected: false,
              placeholderAsset: 'assets/images/not-available.png',
              localizedSemanticsLabel: label,
              onActivate: () => activations++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final rowFinder = find.bySemanticsLabel(label);
      expect(rowFinder, findsOneWidget);
      final rowNode = tester.getSemantics(rowFinder);
      expect(rowNode.flagsCollection.isButton, isTrue);
      expect(
        rowNode.getSemanticsData().hasAction(ui.SemanticsAction.tap),
        isTrue,
      );
      expect(semanticsSubtree(rowNode), hasLength(1));
      expect(find.text('Fallback FC'), findsOneWidget);
      expect(find.text('Test City · Test Conference'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(takeException(tester), isNull);

      await tester.tap(find.byKey(const ValueKey<String>('fallback-team-row')));
      await tester.pump();
      expect(activations, 1);

      performSemanticsTap(rowNode);
      await tester.pump();
      expect(activations, 2);
    } finally {
      semanticsHandle.dispose();
    }
  });
}
