@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/utils/squad_tile_metrics.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';

import '../../../helpers/widgets/player_list_tile_harness.dart';

void main() {
  testWidgets(
    'renders badges in order with equal dimensions and normalized name lines',
    (tester) async {
      final game = fixtureGame(seed: 4210);
      final player = copyPlayer(
        game,
        id: 'badge-order-player',
        name: '  Ada   Lovelace   Hamilton  ',
        form: 7.25,
        position: Position.cm,
      );

      await tester.pumpWidget(
        tileApp(
          game,
          player: player,
          onTap: () {},
          positionAssignment: slot('cm-slot', Position.cm),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ada'), findsOneWidget);
      expect(find.text('Lovelace Hamilton'), findsOneWidget);
      expect(find.byType(FormIndicator), findsOneWidget);
      expect(find.text('7.25'), findsNothing);

      final positionFinder = find.byType(PositionBadge);
      final ovrFinder = find.byType(OvrBadge);
      expect(positionFinder, findsOneWidget);
      expect(ovrFinder, findsOneWidget);

      final positionRect = tester.getRect(positionFinder);
      final ovrRect = tester.getRect(ovrFinder);
      expect(positionRect.right, lessThanOrEqualTo(ovrRect.left));
      expect(tester.getSize(positionFinder), tester.getSize(ovrFinder));
      expect(
        tester.widget<PositionBadge>(positionFinder).size,
        tester.widget<OvrBadge>(ovrFinder).size,
      );
    },
  );

  testWidgets(
    'keeps a one-part name on the upper line without a second name line',
    (tester) async {
      final game = fixtureGame(seed: 42101);
      final player = copyPlayer(
        game,
        id: 'single-name-player',
        name: 'Pelé',
        position: Position.st,
      );

      await tester.pumpWidget(tileApp(game, player: player, onTap: () {}));
      await tester.pumpAndSettle();

      expect(find.text('Pelé'), findsOneWidget);
      final nameTexts = tester
          .widgetList<Text>(find.byType(Text))
          .where((text) => text.data == 'Pelé' || text.data == '')
          .toList();
      expect(nameTexts, hasLength(1));
      expect(find.byType(FormIndicator), findsOneWidget);
    },
  );

  testWidgets(
    'shows stamina bars, gold or faded potential stars, and the optimal role',
    (tester) async {
      final game = fixtureGame(seed: 4290);
      final young = copyPlayer(
        game,
        id: 'metric-young',
        name: 'Young Star',
        form: 6,
        position: Position.cm,
      ).copyWith(age: 22, potentialStars: 3.5);
      final veteran = young.copyWith(
        id: 'metric-veteran',
        name: 'Veteran Star',
        age: 30,
      );

      await tester.pumpWidget(
        tileApp(
          game,
          player: young,
          onTap: () {},
          positionAssignment: slot('cm-slot', Position.cm),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FormIndicator), findsOneWidget);
      expect(find.byType(StaminaIndicator), findsOneWidget);

      await tester.pumpWidget(
        tileApp(
          game,
          player: young,
          onTap: () {},
          positionAssignment: slot('cm-slot', Position.cm),
          metricMode: SquadTileMetricMode.potential,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FormIndicator), findsNothing);
      final youngStars = tester.widget<PotentialStars>(
        find.byType(PotentialStars),
      );
      expect(youngStars.stars, 3.5);
      expect(youngStars.color, const Color(0xFFFFC107));

      await tester.pumpWidget(
        tileApp(
          game,
          player: veteran,
          onTap: () {},
          positionAssignment: slot('cm-slot', Position.cm),
          metricMode: SquadTileMetricMode.potential,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<PotentialStars>(find.byType(PotentialStars)).color,
        const Color(0xFFB8A98A),
      );

      await tester.pumpWidget(
        tileApp(
          game,
          player: young,
          onTap: () {},
          positionAssignment: slot('cm-slot', Position.cm),
          metricMode: SquadTileMetricMode.optimalRole,
        ),
      );
      await tester.pumpAndSettle();
      final expected = compactRoleLabel(
        roleDisplayInfo(young.optimalRole).label,
      );
      expect(find.text(expected), findsOneWidget);
    },
  );
}
