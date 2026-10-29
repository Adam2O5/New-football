@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/widgets/player_list_tile_harness.dart';

void main() {
  testWidgets(
    'opens the represented profile independently from row selection',
    (tester) async {
      final game = fixtureGame(seed: 4211);
      final player = copyPlayer(
        game,
        id: 'profile-action-player',
        name: 'Profile Target',
      );
      var tapCount = 0;
      final profileIds = <String>[];

      await tester.pumpWidget(
        tileApp(
          game,
          player: player,
          onTap: () => tapCount++,
          onInfo: () => profileIds.add(player.id),
        ),
      );
      await tester.pumpAndSettle();

      final l10n = tileLocalizations(tester);
      expect(
        find.bySemanticsLabel(l10n.squad_profileAction(player.name)),
        findsOneWidget,
      );

      await tester.tap(find.byKey(ValueKey('squad-player-row-${player.id}')));
      await tester.pump();
      expect(tapCount, 1);
      expect(profileIds, isEmpty);

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump();
      expect(tapCount, 1);
      expect(profileIds, [player.id]);
    },
  );

  testWidgets('drag target rejects itself and forwards an accepted player id', (
    tester,
  ) async {
    final game = fixtureGame(seed: 4216);
    final player = copyPlayer(
      game,
      id: 'drag-target-player',
      name: 'Drag Target',
    );
    const otherPlayerId = 'other-player';
    final acceptedIds = <String>[];

    await tester.pumpWidget(
      tileApp(
        game,
        player: player,
        enableDragDrop: true,
        onTap: () {},
        onAcceptDrop: acceptedIds.add,
      ),
    );
    await tester.pumpAndSettle();

    final dragTarget = tester.widget<DragTarget<String>>(
      find.byType(DragTarget<String>),
    );
    final selfDetails = DragTargetDetails<String>(
      data: player.id,
      offset: Offset.zero,
    );
    final otherDetails = DragTargetDetails<String>(
      data: otherPlayerId,
      offset: Offset.zero,
    );

    expect(dragTarget.onWillAcceptWithDetails!(selfDetails), isFalse);
    expect(dragTarget.onWillAcceptWithDetails!(otherDetails), isTrue);
    dragTarget.onAcceptWithDetails!(otherDetails);
    expect(acceptedIds, [otherPlayerId]);

    final draggable = tester.widget<LongPressDraggable<String>>(
      find.byType(LongPressDraggable<String>),
    );
    expect(draggable.data, player.id);
  });
}
