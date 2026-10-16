import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/screens/squad_screen.dart';
import 'package:new_football/app/widgets/tactics/pitch_field.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/tactics/lineup_slots.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/game_fixtures.dart';
import 'support/memory_save_repository.dart';

void main() {
  late ProviderContainer container;
  late GameController controller;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final base = controllerSave().leagueState;
    final backs = fullBacks();
    final team = reconcileLineupSlots(
      base.playerTeam!.copyWith(
        tactics: base.playerTeam!.tactics.copyWith(formation: Formation.f433),
        roster: [backs.left, backs.right, ...base.playerTeam!.roster],
        lineupPlayerIds: [backs.left.id, backs.right.id],
      ),
    );
    final repository = MemorySaveRepository(
      saveForLeague(base.updateTeam(team)),
    );
    container = ProviderContainer(
      overrides: [
        saveRepositoryProvider.overrideWithValue(repository),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    controller = container.read(gameControllerProvider.notifier);
    await controller.loadGame(repository.game.meta.id);
  });
  tearDown(() => container.dispose());
  testWidgets(
    'drag LB onto RB changes the displayed slot and persists after load',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1500));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final router = GoRouter(
        initialLocation: '/game',
        routes: [
          GoRoute(
            path: '/game',
            builder: (_, _) => const Scaffold(body: SquadScreen()),
          ),
          GoRoute(
            path: '/game/player/:id',
            builder: (_, _) => const Scaffold(body: Text('Profile')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final backs = fullBacks();
      Finder marker(String id) => find.descendant(
        of: find.byKey(const ValueKey('squad-pitch-field')),
        matching: find.byWidgetPredicate(
          (w) => w is LongPressDraggable<String> && w.data == id,
        ),
      );
      await tester.ensureVisible(marker(backs.left.id));
      await tester.pumpAndSettle();
      final leftBefore = tester.getCenter(marker(backs.left.id));
      final rightBefore = tester.getCenter(marker(backs.right.id));
      final before = controller.save!.leagueState.playerTeam!.lineupSlots;
      Offset avatar(String id) => tester.getCenter(
        find
            .descendant(of: marker(id), matching: find.byType(CircleAvatar))
            .first,
      );
      final avatarCount = find.byType(CircleAvatar).evaluate().length;
      final gesture = await tester.startGesture(avatar(backs.left.id));
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.moveBy(const Offset(1, 0));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(
        find.text('Profile'),
        findsNothing,
        reason: 'Dragging a marker must not open its profile',
      );
      expect(
        find.byType(CircleAvatar).evaluate().length,
        avatarCount + 1,
        reason: 'Long press must start the real draggable feedback',
      );
      await gesture.moveTo(avatar(backs.right.id));
      await tester.pump(const Duration(milliseconds: 150));
      await gesture.up();
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/game');
      final after = controller.save!.leagueState.playerTeam!.lineupSlots;
      expect(after, isNot(before));
      expect(tester.getCenter(marker(backs.left.id)), rightBefore);
      expect(tester.getCenter(marker(backs.right.id)), leftBefore);
      final id = controller.save!.meta.id;
      await tester.runAsync(() async {
        await controller.flushPendingSave();
        await controller.loadGame(id);
      });
      await tester.pumpAndSettle();
      expect(controller.save!.leagueState.playerTeam!.lineupSlots, after);
      expect(tester.getCenter(marker(backs.left.id)), rightBefore);
      final pitch = tester.widget<PitchField>(
        find.byKey(const ValueKey('squad-pitch-field')),
      );
      expect(
        pitch.precomputedPlacements!
            .where((p) => p.player?.id == backs.left.id)
            .single
            .slot
            .key,
        after.entries.singleWhere((e) => e.value == backs.left.id).key,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('pitch without drag retains profile long press', (tester) async {
    final player = fullBacks().left;
    final openedProfiles = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 340,
            child: PitchField(
              formation: Formation.f433,
              lineupPlayerIds: [player.id],
              playersById: {player.id: player},
              selectedId: null,
              onTap: (_) {},
              onLongPress: (p) => openedProfiles.add(p.id),
            ),
          ),
        ),
      ),
    );
    await tester.longPress(find.byType(CircleAvatar));
    await tester.pumpAndSettle();
    expect(openedProfiles, [player.id]);
    expect(find.byType(LongPressDraggable<String>), findsNothing);
  });
}
