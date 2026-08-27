import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/widgets/tactics/pitch_field.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/position_group.dart';

void main() {
  testWidgets(
    'omitting markerStyleBuilder preserves the default tactics marker and gestures',
    (tester) async {
      final source = _fixturePlayers()[0];
      final player = _copyPlayer(
        source,
        id: 'tactics-default-player',
        name: 'Tactics Default',
        position: Position.gk,
      );
      Player? tapped;
      Player? longPressed;

      await tester.pumpWidget(
        _pitchApp(
          PitchField(
            formation: Formation.f442,
            lineupPlayerIds: [player.id],
            playersById: {player.id: player},
            selectedId: null,
            onTap: (value) => tapped = value,
            onLongPress: (value) => longPressed = value,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.backgroundColor, Colors.white);
      expect(find.bySemanticsLabel('squad-only marker'), findsNothing);

      final markerName = find.text(player.name);
      expect(markerName, findsOneWidget);
      await tester.tap(markerName);
      await tester.pump();
      expect(tapped, same(player));

      await tester.longPress(markerName);
      await tester.pump();
      expect(longPressed, same(player));
    },
  );

  testWidgets(
    'custom builder receives exact placements and exposes status semantics and selected ring',
    (tester) async {
      final roster = _fixturePlayers();
      final exactPlayer = _copyPlayer(
        roster[0],
        id: 'custom-exact-player',
        name: 'Exact Placement',
        position: Position.cm,
      );
      final mismatchPlayer = _copyPlayer(
        roster[1],
        id: 'custom-mismatch-player',
        name: 'Mismatch Placement',
        position: Position.st,
      );
      final exactPlacement = PlacedPlayer(
        slot: _slot('exact-cm-slot', Position.cm, 0.25, 0.48),
        player: exactPlayer,
      );
      final mismatchPlacement = PlacedPlayer(
        slot: _slot('mismatch-cm-slot', Position.cm, 0.75, 0.48),
        player: mismatchPlayer,
      );
      final received = <PlacedPlayer>[];
      final semanticsHandle = tester.ensureSemantics();

      await tester.pumpWidget(
        _pitchApp(
          PitchField(
            formation: Formation.f442,
            lineupPlayerIds: [exactPlayer.id, mismatchPlayer.id],
            playersById: {
              exactPlayer.id: exactPlayer,
              mismatchPlayer.id: mismatchPlayer,
            },
            selectedId: mismatchPlayer.id,
            precomputedPlacements: [exactPlacement, mismatchPlacement],
            onTap: (_) {},
            markerStyleBuilder: (context, placement) {
              received.add(placement);
              final player = placement.player!;
              final hasMismatch = player.position != placement.slot.position;
              final isStatusMarker = player.id == mismatchPlayer.id;
              return PitchMarkerStyle(
                backgroundColor: hasMismatch ? Colors.orange : Colors.white,
                foregroundColor: Colors.black,
                selectedRingColor: Colors.purple,
                selectedRingWidth: 3,
                semanticLabel: 'marker-${player.id}',
                statusLabel: isStatusMarker
                    ? 'Active injury; Active suspension; Position mismatch'
                    : 'Position aligned',
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final receivedById = <String, PlacedPlayer>{
        for (final placement in received) placement.player!.id: placement,
      };
      expect(receivedById[exactPlayer.id], same(exactPlacement));
      expect(receivedById[mismatchPlayer.id], same(mismatchPlacement));
      expect(receivedById[exactPlayer.id]!.slot.position, exactPlayer.position);
      expect(
        receivedById[mismatchPlayer.id]!.slot.position,
        isNot(mismatchPlayer.position),
      );

      final statusFinder = find.bySemanticsLabel('marker-${mismatchPlayer.id}');
      expect(statusFinder, findsOneWidget);
      final statusNode = tester.getSemantics(statusFinder);
      expect(statusNode.label, 'marker-${mismatchPlayer.id}');
      expect(
        statusNode.value,
        'Active injury; Active suspension; Position mismatch',
      );

      final exactFinder = find.bySemanticsLabel('marker-${exactPlayer.id}');
      expect(tester.getSemantics(exactFinder).value, 'Position aligned');

      final ringDecorations = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .where(_isPurpleSelectionRing)
          .toList();
      expect(ringDecorations, hasLength(1));
      semanticsHandle.dispose();
    },
  );

  testWidgets('custom markers retain long-press drag and drop callback IDs', (
    tester,
  ) async {
    final roster = _fixturePlayers();
    final source = _copyPlayer(
      roster[0],
      id: 'drag-source-player',
      name: 'Drag Source',
      position: Position.gk,
    );
    final target = _copyPlayer(
      roster[1],
      id: 'drag-target-player',
      name: 'Drag Target',
      position: Position.st,
    );
    final sourcePlacement = PlacedPlayer(
      slot: _slot('drag-source-slot', Position.gk, 0.25, 0.5),
      player: source,
    );
    final targetPlacement = PlacedPlayer(
      slot: _slot('drag-target-slot', Position.st, 0.75, 0.5),
      player: target,
    );
    final drops = <({String dragged, String target})>[];
    final semanticsHandle = tester.ensureSemantics();

    await tester.pumpWidget(
      _pitchApp(
        PitchField(
          formation: Formation.f442,
          lineupPlayerIds: [source.id, target.id],
          playersById: {source.id: source, target.id: target},
          selectedId: null,
          precomputedPlacements: [sourcePlacement, targetPlacement],
          enableDragDrop: true,
          onTap: (_) {},
          markerStyleBuilder: (context, placement) => PitchMarkerStyle(
            semanticLabel: placement.player!.id == source.id
                ? 'drag-source-marker'
                : 'drag-target-marker',
            statusLabel: 'Drag enabled',
          ),
          onAcceptDrop: (draggedPlayerId, targetPlayerId) {
            drops.add((dragged: draggedPlayerId, target: targetPlayerId));
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final sourceFinder = find.bySemanticsLabel('drag-source-marker');
    final targetFinder = find.bySemanticsLabel('drag-target-marker');
    expect(sourceFinder, findsOneWidget);
    expect(targetFinder, findsOneWidget);

    final gesture = await tester.startGesture(tester.getCenter(sourceFinder));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    await gesture.moveTo(tester.getCenter(targetFinder));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(drops, [(dragged: source.id, target: target.id)]);
    semanticsHandle.dispose();
  });
}

Widget _pitchApp(Widget pitch) {
  return MaterialApp(
    home: Scaffold(body: SizedBox(width: 360, height: 640, child: pitch)),
  );
}

List<Player> _fixturePlayers() {
  final game = GameFactory().create(
    const NewGameRequest(
      saveName: 'PitchField widget test',
      playerTeamId: 'team_europe_0',
      seed: 9303,
    ),
  );
  return game.leagueState.playerTeam!.roster;
}

Player _copyPlayer(
  Player source, {
  required String id,
  required String name,
  required Position position,
}) {
  return source.copyWith(
    id: id,
    name: name,
    position: position,
    state: source.state.copyWith(injury: null, suspensionGamesRemaining: 0),
  );
}

AssignedSlot _slot(String key, Position position, double x, double y) {
  return AssignedSlot(
    key: key,
    position: position,
    group: positionGroupOf(position),
    x: x,
    y: y,
  );
}

bool _isPurpleSelectionRing(DecoratedBox widget) {
  final decoration = widget.decoration;
  if (decoration is! BoxDecoration || decoration.shape != BoxShape.circle) {
    return false;
  }
  final border = decoration.border;
  return border is Border &&
      border.top.color == Colors.purple &&
      border.top.width == 3;
}
