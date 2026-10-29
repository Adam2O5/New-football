@Tags(['ui'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/player_detail_screen.dart';
import 'package:new_football/app/screens/squad_screen.dart';
import 'package:new_football/app/widgets/tactics/pitch_field.dart';
import 'package:new_football/app/widgets/tactics/role_picker_sheet.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import '../helpers/widgets/career_dashboard_harness.dart';

void main() {
  testWidgets('zmiany wszystkich ustawien taktyki zapisują się automatycznie', (
    tester,
  ) async {
    final game = dashboardGame(seed: 4005);
    late GameController controller;
    await tester.pumpWidget(
      dashboardAppWithOverrides(
        const SquadScreen(),
        game,
        onController: (value) => controller = value,
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(SquadScreen)))!;
    await tester.tap(find.text(l10n.squad_tacticsTitle).first);
    await tester.pumpAndSettle();

    final formationFinder = find.byType(DropdownButtonFormField<Formation>);
    final tempoFinder = find.byType(DropdownButtonFormField<Tempo>);
    final pressingFinder = find.byType(
      DropdownButtonFormField<PressingIntensity>,
    );
    final lineFinder = find.byType(DropdownButtonFormField<DefensiveLine>);
    final widthFinder = find.byType(DropdownButtonFormField<AttackWidth>);
    expect(formationFinder, findsOneWidget);
    expect(tempoFinder, findsOneWidget);
    expect(pressingFinder, findsOneWidget);
    expect(lineFinder, findsOneWidget);
    expect(widthFinder, findsOneWidget);

    final formation = tester.widget<DropdownButtonFormField<Formation>>(
      formationFinder,
    );
    final tempo = tester.widget<DropdownButtonFormField<Tempo>>(tempoFinder);
    final pressing = tester.widget<DropdownButtonFormField<PressingIntensity>>(
      pressingFinder,
    );
    final line = tester.widget<DropdownButtonFormField<DefensiveLine>>(
      lineFinder,
    );
    final width = tester.widget<DropdownButtonFormField<AttackWidth>>(
      widthFinder,
    );
    final changedFormation = Formation.values.firstWhere(
      (value) => value != formation.initialValue,
    );
    final changedTempo = Tempo.values.firstWhere(
      (value) => value != tempo.initialValue,
    );
    final changedPressing = PressingIntensity.values.firstWhere(
      (value) => value != pressing.initialValue,
    );
    final changedLine = DefensiveLine.values.firstWhere(
      (value) => value != line.initialValue,
    );
    final changedWidth = AttackWidth.values.firstWhere(
      (value) => value != width.initialValue,
    );

    formation.onChanged!(changedFormation);
    tempo.onChanged!(changedTempo);
    pressing.onChanged!(changedPressing);
    line.onChanged!(changedLine);
    width.onChanged!(changedWidth);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    var persisted = controller.save!.leagueState.playerTeam!.tactics;
    expect(persisted.formation, changedFormation);
    expect(persisted.tempo, changedTempo);
    expect(persisted.pressing, changedPressing);
    expect(persisted.defensiveLine, changedLine);
    expect(persisted.attackWidth, changedWidth);
    expect(find.text(l10n.tactics_autosaved), findsOneWidget);

    await tester.tap(find.text(l10n.squad_rosterTitle).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.squad_tacticsTitle).first);
    await tester.pumpAndSettle();

    persisted = controller.save!.leagueState.playerTeam!.tactics;
    expect(persisted.formation, changedFormation);
    expect(persisted.tempo, changedTempo);
    expect(persisted.pressing, changedPressing);
    expect(persisted.defensiveLine, changedLine);
    expect(persisted.attackWidth, changedWidth);
    expect(
      tester
          .widget<DropdownButtonFormField<Formation>>(formationFinder)
          .initialValue,
      changedFormation,
    );
    expect(
      tester.widget<DropdownButtonFormField<Tempo>>(tempoFinder).initialValue,
      changedTempo,
    );
    expect(
      tester
          .widget<DropdownButtonFormField<PressingIntensity>>(pressingFinder)
          .initialValue,
      changedPressing,
    );
    expect(
      tester
          .widget<DropdownButtonFormField<DefensiveLine>>(lineFinder)
          .initialValue,
      changedLine,
    );
    expect(
      tester
          .widget<DropdownButtonFormField<AttackWidth>>(widthFinder)
          .initialValue,
      changedWidth,
    );
    expect(find.text(l10n.tactics_autosaved), findsOneWidget);
  });

  testWidgets(
    'Tactics_Tab zachowuje domyślne znaczniki, role picker i profil long-press',
    (tester) async {
      final game = dashboardGame(seed: 4007);
      final team = game.leagueState.playerTeam!;
      final tacticsPlayer = team.roster.firstWhere(
        (player) =>
            team.lineupPlayerIds.contains(player.id) &&
            (player.state.injury?.daysRemaining ?? 0) <= 0 &&
            player.state.suspensionGamesRemaining == 0,
      );
      final router = GoRouter(
        initialLocation: '/squad',
        routes: [
          GoRoute(
            path: '/squad',
            builder: (context, state) => const Scaffold(body: SquadScreen()),
          ),
          GoRoute(
            path: '/game/player/:id',
            builder: (context, state) =>
                PlayerDetailScreen(playerId: state.pathParameters['id']!),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(dashboardRouterApp(router, game));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(SquadScreen)),
      )!;
      await tester.tap(find.text(l10n.squad_tacticsTitle).first);
      await tester.pumpAndSettle();

      final tacticsPitchFinder = find.descendant(
        of: find.byKey(const ValueKey('squad-tactics-scroll')),
        matching: find.byType(PitchField),
      );
      expect(tacticsPitchFinder, findsOneWidget);
      final tacticsPitch = tester.widget<PitchField>(tacticsPitchFinder);
      expect(tacticsPitch.markerStyleBuilder, isNull);
      expect(
        find.bySemanticsLabel(
          l10n.squad_playerMarkerSemantics(
            tacticsPlayer.name,
            tacticsPlayer.position.code,
            '',
          ),
        ),
        findsNothing,
      );

      final tacticsMarker = find.descendant(
        of: tacticsPitchFinder,
        matching: find.text(tacticsPlayer.name),
      );
      expect(tacticsMarker, findsOneWidget);
      final tacticsAvatar = tester.widget<CircleAvatar>(
        find
            .descendant(
              of: tacticsPitchFinder,
              matching: find.byType(CircleAvatar),
            )
            .first,
      );
      expect(tacticsAvatar.backgroundColor, Colors.white);

      await tester.tap(tacticsMarker);
      await tester.pumpAndSettle();
      expect(find.byType(RolePickerSheet), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(RolePickerSheet),
          matching: find.text(tacticsPlayer.name),
        ),
        findsOneWidget,
      );
      Navigator.of(tester.element(find.byType(RolePickerSheet))).pop();
      await tester.pumpAndSettle();

      await tester.longPress(tacticsMarker);
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/game/player/${tacticsPlayer.id}');
      expect(find.byType(PlayerDetailScreen), findsOneWidget);
    },
  );
}
