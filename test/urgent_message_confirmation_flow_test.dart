import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/router.dart';
import 'package:new_football/app/screens/player_detail_screen.dart';
import 'package:new_football/app/screens/shell_screen.dart';
import 'package:new_football/app/screens/trade_screen.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/player_event_state.dart';
import 'package:new_football/core/models/team_event_state.dart';
import 'package:new_football/core/models/trade_models.dart';
import 'package:new_football/core/services/trade_service.dart';
import 'package:new_football/data/save_repository.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import 'helpers/controlled_save_repository.dart';
import 'helpers/widget_harness.dart';

/// The project does not depend on Flutter's `integration_test` package and has
/// no integration_test directory. These cases therefore use the equivalent
/// full widget/router harness: the production GoRouter, ShellScreen,
/// gameControllerProvider, and a real SaveRepository all run in one tree.
void main() {
  testWidgets(
    'production /game flow persists urgent acknowledgement and decision, '
    'reloads the save, and resumes simulation',
    (tester) async {
      final base = task41Game(seed: 4103);
      final team = base.leagueState.playerTeam!;
      final urgent = _urgentMessage(
        id: 'flow-urgent-ack',
        title: 'Integracja pilne potwierdzenie',
        read: true,
      );
      final teamDecision = _teamDecisionMessage(
        id: 'flow-team-decision',
        title: 'Integracja decyzja zespołu',
        teamId: team.id,
        playerId: team.roster.first.id,
      );
      final game = _withInbox(base, Inbox(messages: [urgent, teamDecision]));
      final fixture = await _newFixture(tester, game);
      addTearDown(() => fixture.dispose(tester));

      await _mountGame(tester, fixture, tab: 5);
      expect(_selectedTab(tester), 5);
      expect(
        fixture.controller.save!.leagueState.inbox.pendingUrgent,
        hasLength(2),
      );

      final blockedBefore = fixture.controller.save!.leagueState;
      final blocked = await tester.runAsync(
        () => fixture.controller.advanceOneDay(),
      );
      expect(blocked, isNull);
      expect(
        fixture.controller.save!.leagueState.currentWeek,
        blockedBefore.currentWeek,
      );
      expect(
        fixture.controller.save!.leagueState.currentDay,
        blockedBefore.currentDay,
      );

      await _selectTab(tester, 0);
      await tester.drag(find.byType(ListView).first, const Offset(0, -800));
      await tester.pump();
      final pauseButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Odczytaj pilną wiadomość'),
      );
      expect(pauseButton.onPressed, isNull);
      await _selectTab(tester, 1);
      await _selectTab(tester, 5);

      await _openMessage(tester, urgent.args['_legacyTitle'] as String);
      await _tapSheetButton(tester, 'Potwierdź');
      await tester.pump();
      await _waitFor(
        tester,
        () =>
            _messageById(fixture.controller.save, urgent.id)?.acknowledged ==
            true,
        reason: 'the urgent acknowledgement did not commit through /game',
      );
      await tester.pumpAndSettle();

      expect(fixture.router.state.uri.path, '/game');
      expect(_selectedTab(tester), 5);
      expect(
        fixture.controller.save!.leagueState.inbox.pendingUrgent,
        hasLength(1),
      );
      final reloadedAfterAcknowledgement = await _reload(tester, fixture);
      expect(
        reloadedAfterAcknowledgement.leagueState,
        fixture.controller.save!.leagueState,
      );

      await _openMessage(tester, teamDecision.args['_legacyTitle'] as String);
      await _tapSheetButton(tester, 'Akceptuj');
      await tester.pump();
      await _waitFor(
        tester,
        () =>
            _messageById(
              fixture.controller.save,
              teamDecision.id,
            )?.acknowledged ==
            true,
        reason:
            'the team decision did not commit through the production router',
      );
      await tester.pumpAndSettle();

      final teamAfter = fixture.controller.save!.leagueState.teamById(team.id)!;
      expect(
        teamAfter.eventState.promises,
        contains(
          predicate<TeamPromise>(
            (promise) => promise.playerId == team.roster.first.id,
          ),
        ),
      );
      expect(fixture.controller.save!.leagueState.inbox.pendingUrgent, isEmpty);
      final reloadedAfterDecision = await _reload(tester, fixture);
      expect(
        reloadedAfterDecision.leagueState,
        fixture.controller.save!.leagueState,
      );
      expect(
        reloadedAfterDecision.schemaVersion,
        SaveRepository.currentSchemaVersion,
      );
      expect(
        (await tester.runAsync(
          () => fixture.repository.listSaves(),
        ))?.singleWhere((save) => save.id == game.meta.id).id,
        game.meta.id,
      );
      expect(fixture.router.state.uri.path, '/game');
      expect(_selectedTab(tester), 5);

      await _selectTab(tester, 0);
      await _selectTab(tester, 1);
      expect(fixture.router.state.uri.path, '/game');
      expect(_selectedTab(tester), 1);

      final beforeSimulation = fixture.controller.save!.leagueState;
      final simulation = await tester.runAsync(
        () => fixture.controller.advanceOneDay(resolveContractMarket: false),
      );
      expect(simulation, isNotNull);
      final afterSimulation = fixture.controller.save!.leagueState;
      expect((
        afterSimulation.currentWeek,
        afterSimulation.currentDay,
      ), isNot((beforeSimulation.currentWeek, beforeSimulation.currentDay)));
      final reloadedAfterSimulation = await _reload(tester, fixture);
      expect(reloadedAfterSimulation.leagueState, afterSimulation);
      expect(fixture.router.state.uri.path, '/game');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'production save failure keeps active game, urgent badge/pause, route, '
    'and retry available until the next commit',
    (tester) async {
      final directory = (await tester.runAsync(
        () => Directory.systemTemp.createTemp('nf_flow_failure_'),
      ))!;
      final repository = ControlledSaveRepository(
        overrideDirectory: directory,
        waitForRelease: true,
        failure: ControlledSaveFailure.beforeWrite,
      );
      final game = _withInbox(
        task41Game(seed: 4103),
        Inbox(
          messages: [
            _urgentMessage(
              id: 'flow-save-failure',
              title: 'Integracja błąd zapisu',
              read: true,
            ),
          ],
        ),
      );
      final fixture = await _newFixture(
        tester,
        game,
        repository: repository,
        directory: directory,
      );
      addTearDown(() => fixture.dispose(tester));

      await _mountGame(tester, fixture, tab: 5);
      final before = fixture.controller.save!;
      await _openMessage(tester, 'Integracja błąd zapisu');
      await _tapSheetButton(tester, 'Potwierdź');
      await tester.pump();
      await _waitFor(
        tester,
        () => repository.saveCount == 1,
        reason: 'the failing confirmation save did not start',
      );
      repository.release();
      await _waitFor(
        tester,
        () => find.text('Spróbuj ponownie').evaluate().isNotEmpty,
        reason: 'the save error did not remain local to the sheet',
      );
      await tester.pump();

      expect(fixture.router.state.uri.path, '/game');
      expect(find.byType(ShellScreen), findsOneWidget);
      expect(_selectedTab(tester), 5);
      expect(fixture.container.read(gameControllerProvider).value, isNotNull);
      expect(fixture.controller.save, same(before));
      expect(
        fixture.controller.save!.leagueState.inbox.pendingUrgent,
        hasLength(1),
      );
      expect(find.byType(Badge), findsWidgets);
      expect(
        tester
            .widgetList<Badge>(find.byType(Badge))
            .any((badge) => badge.backgroundColor != null),
        isTrue,
        reason: 'the urgent pause badge disappeared while retry was available',
      );
      expect(repository.completedSaves, isEmpty);
      final diskAfterFailure = await _reload(tester, fixture);
      expect(diskAfterFailure.leagueState, before.leagueState);
      expect(find.byType(BottomSheet), findsOneWidget);

      repository.failure = ControlledSaveFailure.none;
      await _tapSheetButton(tester, 'Spróbuj ponownie');
      await tester.pump();
      await _waitFor(
        tester,
        () => repository.saveCount == 2,
        reason: 'retry did not start exactly one new save',
      );
      await _waitFor(
        tester,
        () =>
            _messageById(
              fixture.controller.save,
              'flow-save-failure',
            )?.acknowledged ==
            true,
        reason: 'successful retry did not publish the acknowledged save',
      );
      await tester.pumpAndSettle();

      expect(repository.completedSaves, hasLength(1));
      expect(fixture.controller.save!.leagueState.inbox.pendingUrgent, isEmpty);
      expect(find.byType(BottomSheet), findsNothing);
      expect(fixture.router.state.uri.path, '/game');
      await _selectTab(tester, 0);
      await _selectTab(tester, 1);
      expect(fixture.router.state.uri.path, '/game');
      expect(_selectedTab(tester), 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'closing or rerouting the sheet during await does not late-pop or use '
    'a disposed context',
    (tester) async {
      final directory = (await tester.runAsync(
        () => Directory.systemTemp.createTemp('nf_flow_lifecycle_'),
      ))!;
      final repository = ControlledSaveRepository(
        overrideDirectory: directory,
        waitForRelease: true,
      );
      final game = _withInbox(
        task41Game(seed: 4103),
        Inbox(
          messages: [
            _urgentMessage(
              id: 'flow-lifecycle',
              title: 'Integracja lifecycle',
              read: true,
            ),
          ],
        ),
      );
      final fixture = await _newFixture(
        tester,
        game,
        repository: repository,
        directory: directory,
      );
      addTearDown(() => fixture.dispose(tester));

      await _mountGame(tester, fixture, tab: 5);
      await _openMessage(tester, 'Integracja lifecycle');
      await _tapSheetButton(tester, 'Potwierdź');
      await tester.pump();
      await _waitFor(
        tester,
        () => repository.saveCount == 1,
        reason: 'the lifecycle confirmation save did not start',
      );

      final playerId = game.leagueState.playerTeam!.roster.first.id;
      fixture.router.go('/game/player/$playerId');
      await tester.pumpAndSettle();
      expect(fixture.router.state.uri.path, '/game/player/$playerId');
      expect(find.byType(PlayerDetailScreen), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);

      repository.release();
      await _waitFor(
        tester,
        () =>
            _messageById(
              fixture.controller.save,
              'flow-lifecycle',
            )?.acknowledged ==
            true,
        reason: 'the data operation did not finish after the route changed',
      );
      await tester.pumpAndSettle();

      expect(fixture.router.state.uri.path, '/game/player/$playerId');
      expect(find.byType(PlayerDetailScreen), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      expect(tester.takeException(), isNull);

      fixture.router.go('/game', extra: 1);
      await tester.pumpAndSettle();
      expect(fixture.router.state.uri.path, '/game');
      expect(_selectedTab(tester), 1);
      expect(find.byType(ShellScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'production router preserves team and player effects after reload',
    (tester) async {
      final base = task41Game(seed: 4103);
      final team = base.leagueState.playerTeam!;
      final teamDecision = _teamDecisionMessage(
        id: 'flow-team-effect',
        title: 'Integracja efekt zespołu',
        teamId: team.id,
        playerId: team.roster.first.id,
      );
      final playerDecision = _playerDecisionMessage(
        id: 'flow-player-effect',
        title: 'Integracja efekt zawodnika',
        teamId: team.id,
        playerId: team.roster.first.id,
      );
      final fixture = await _newFixture(
        tester,
        _withInbox(base, Inbox(messages: [teamDecision, playerDecision])),
      );
      addTearDown(() => fixture.dispose(tester));

      await _mountGame(tester, fixture, tab: 5);
      await _openMessage(tester, 'Integracja efekt zespołu');
      await _tapSheetButton(tester, 'Akceptuj');
      await tester.pump();
      await _waitFor(
        tester,
        () =>
            _messageById(
              fixture.controller.save,
              teamDecision.id,
            )?.acknowledged ==
            true,
        reason: 'the team decision did not complete',
      );
      await tester.pumpAndSettle();

      final afterTeam = fixture.controller.save!.leagueState.teamById(team.id)!;
      expect(
        afterTeam.eventState.promises,
        contains(
          predicate<TeamPromise>(
            (promise) => promise.playerId == team.roster.first.id,
          ),
        ),
      );

      await _openMessage(tester, 'Integracja efekt zawodnika');
      await _tapSheetButton(tester, 'Akceptuj');
      await tester.pump();
      await _waitFor(
        tester,
        () =>
            _messageById(
              fixture.controller.save,
              playerDecision.id,
            )?.acknowledged ==
            true,
        reason: 'the player decision did not complete',
      );
      await tester.pumpAndSettle();

      final afterPlayer = fixture.controller.save!.leagueState
          .teamById(team.id)!
          .roster
          .firstWhere((player) => player.id == team.roster.first.id);
      expect(
        afterPlayer.state.eventState.isOnCooldown('extraTraining'),
        isTrue,
      );
      expect(fixture.controller.save!.leagueState.inbox.pendingUrgent, isEmpty);
      expect(
        (await _reload(tester, fixture)).leagueState,
        fixture.controller.save!.leagueState,
      );
      expect(fixture.router.state.uri.path, '/game');
      expect(_selectedTab(tester), 5);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'production trade decision commits the trade effect and counter opens '
    'one route with its offer query parameter',
    (tester) async {
      final tradeScenario = _tradeScenario(
        seed: 4103,
        title: 'Integracja oferta wymiany',
      );
      final acceptFixture = await _newFixture(
        tester,
        tradeScenario.game,
        extraOverrides: [
          tradeServiceProvider.overrideWithValue(
            TradeService(random: const _AlwaysAcceptRandom()),
          ),
        ],
      );
      addTearDown(() => acceptFixture.dispose(tester));

      await _mountGame(tester, acceptFixture, tab: 5);
      await _openMessage(tester, tradeScenario.title);
      await _tapSheetButton(tester, 'Akceptuj');
      await tester.pump();
      await _waitFor(
        tester,
        () =>
            _messageById(
              acceptFixture.controller.save,
              tradeScenario.messageId,
            )?.acknowledged ==
            true,
        reason: 'the trade accept decision did not complete',
      );
      await tester.pumpAndSettle();

      final acceptedOffer = acceptFixture.controller.save!.leagueState
          .tradeOfferById(tradeScenario.offerId);
      expect(acceptedOffer?.status, TradeOfferStatus.accepted);
      expect(
        acceptFixture.controller.save!.leagueState.tradeHistory,
        contains(
          predicate<TradeHistoryEntry>(
            (entry) =>
                entry.offerId == tradeScenario.offerId &&
                entry.outcome == 'accepted',
          ),
        ),
      );
      final acceptedPending =
          acceptFixture.controller.save!.leagueState.inbox.pendingUrgent;
      expect(
        acceptedPending.where(
          (message) => message.id == tradeScenario.messageId,
        ),
        isEmpty,
        reason: 'the acknowledged offer must leave pendingUrgent',
      );
      expect(
        acceptedPending,
        contains(
          predicate<GameMessage>(
            (message) =>
                message.payload['tradeOfferId'] == tradeScenario.offerId &&
                message.id != tradeScenario.messageId,
          ),
        ),
        reason:
            'the trade outcome notification should retain its urgent semantics',
      );
      expect(
        (await _reload(tester, acceptFixture)).leagueState,
        acceptFixture.controller.save!.leagueState,
      );
      expect(acceptFixture.router.state.uri.path, '/game');
      expect(_selectedTab(tester), 5);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await acceptFixture.dispose(tester);
      final counterScenario = _tradeScenario(
        seed: 4104,
        title: 'Integracja kontroferta',
      );
      final counterFixture = await _newFixture(tester, counterScenario.game);
      addTearDown(() => counterFixture.dispose(tester));
      await _mountGame(tester, counterFixture, tab: 5);
      await _openMessage(tester, counterScenario.title);

      final counterButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Kontroferta'),
      );
      expect(counterButton.onPressed, isNotNull);
      counterButton.onPressed!();
      counterButton.onPressed!();
      await tester.pumpAndSettle();

      expect(counterFixture.router.state.uri.path, '/game/trade');
      expect(
        counterFixture.router.state.uri.queryParameters['tradeOfferId'],
        counterScenario.offerId,
      );
      expect(find.byType(TradeScreen), findsOneWidget);
      expect(
        tester
            .widget<TradeScreen>(find.byType(TradeScreen))
            .initialTradeOfferId,
        counterScenario.offerId,
      );
      expect(
        counterFixture.controller.save!.leagueState.inbox.pendingUrgent,
        hasLength(1),
      );
      expect(tester.takeException(), isNull);
    },
  );
}

Future<_ProductionFixture> _newFixture(
  WidgetTester tester,
  GameSave game, {
  SaveRepository? repository,
  Directory? directory,
  List<Override> extraOverrides = const [],
}) async {
  final actualDirectory =
      directory ??
      (await tester.runAsync(
        () => Directory.systemTemp.createTemp('nf_flow_'),
      ))!;
  final initialRepository = SaveRepository(overrideDirectory: actualDirectory);
  await tester.runAsync(() => initialRepository.save(game));
  final activeRepository = repository ?? initialRepository;
  final container = ProviderContainer(
    overrides: [
      ...extraOverrides,
      saveRepositoryProvider.overrideWithValue(activeRepository),
      gameControllerProvider.overrideWith((ref) {
        final controller = GameController(ref);
        controller.state = AsyncValue.data(game);
        return controller;
      }),
    ],
  );
  final router = container.read(goRouterProvider);
  return _ProductionFixture(
    directory: actualDirectory,
    repository: activeRepository,
    container: container,
    router: router,
    controller: container.read(gameControllerProvider.notifier),
    game: game,
  );
}

Future<void> _mountGame(
  WidgetTester tester,
  _ProductionFixture fixture, {
  required int tab,
}) async {
  await tester.pumpWidget(fixture.app);
  fixture.router.go('/game', extra: tab);
  await tester.pumpAndSettle();
  expect(fixture.router.state.uri.path, '/game');
  expect(_selectedTab(tester), tab);
}

Future<void> _tapSheetButton(WidgetTester tester, String label) async {
  final filled = find.widgetWithText(FilledButton, label);
  if (filled.evaluate().isNotEmpty) {
    final callback = tester.widget<FilledButton>(filled).onPressed;
    expect(callback, isNotNull, reason: 'sheet button $label is disabled');
    callback!();
  } else {
    final textButton = find.widgetWithText(TextButton, label);
    final callback = tester.widget<TextButton>(textButton).onPressed;
    expect(callback, isNotNull, reason: 'sheet button $label is disabled');
    callback!();
  }
  await tester.pump();
}

Future<void> _openMessage(WidgetTester tester, String title) async {
  await tester.tap(find.text(title).first);
  await tester.pump();
  await _waitFor(
    tester,
    () => find.byType(BottomSheet).evaluate().isNotEmpty,
    reason: 'message details sheet did not open for $title',
  );
}

Future<void> _selectTab(WidgetTester tester, int index) async {
  await tester.tap(find.byType(NavigationDestination).at(index));
  await tester.pump();
  await _waitFor(
    tester,
    () => _selectedTab(tester) == index,
    reason: 'shell tab $index did not become selected',
  );
}

int _selectedTab(WidgetTester tester) =>
    tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

Future<void> _waitFor(
  WidgetTester tester,
  bool Function() condition, {
  required String reason,
}) async {
  for (var attempt = 0; attempt < 120; attempt++) {
    if (condition()) return;
    await tester.pump(const Duration(milliseconds: 1));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 5)),
    );
  }
  expect(condition(), isTrue, reason: reason);
}

Future<GameSave> _reload(
  WidgetTester tester,
  _ProductionFixture fixture,
) async {
  final loaded = await tester.runAsync(
    () => fixture.repository.load(fixture.game.meta.id),
  );
  return loaded!;
}

GameSave _withInbox(GameSave game, Inbox inbox) =>
    game.copyWith(leagueState: game.leagueState.copyWith(inbox: inbox));

GameMessage _urgentMessage({
  required String id,
  required String title,
  required bool read,
}) => GameMessage(
  id: id,
  type: MessageType.playerEvent,
  domain: MessageDomain.playerEvent,
  priority: MessagePriority.urgent,
  seasonYear: 2026,
  week: 1,
  day: 1,
  titleKey: 'msg_playerEvent_title',
  bodyKey: 'msg_playerEvent_body',
  args: {'_legacyTitle': title, '_legacyBody': 'Treść $title'},
  read: read,
);

GameMessage _teamDecisionMessage({
  required String id,
  required String title,
  required String teamId,
  required String playerId,
}) => GameMessage(
  id: id,
  type: MessageType.teamEvent,
  kind: 'moreMinutesRequest',
  domain: MessageDomain.teamEvent,
  priority: MessagePriority.urgent,
  seasonYear: 2026,
  week: 1,
  day: 1,
  titleKey: 'msg_teamEvent_moreMinutesRequest_title',
  bodyKey: 'msg_teamEvent_moreMinutesRequest_body',
  args: {'_legacyTitle': title, '_legacyBody': 'Wybierz decyzję zespołu.'},
  payload: {
    'teamId': teamId,
    'playerId': playerId,
    'eventKind': 'moreMinutesRequest',
  },
  decision: const DecisionSpec(
    options: [
      MessageAction(id: 'accept', labelKey: 'accept'),
      MessageAction(id: 'decline', labelKey: 'decline'),
    ],
    defaultOnExpiry: 'decline',
  ),
  read: true,
);

GameMessage _playerDecisionMessage({
  required String id,
  required String title,
  required String teamId,
  required String playerId,
}) => GameMessage(
  id: id,
  type: MessageType.playerEvent,
  kind: 'extraTraining',
  domain: MessageDomain.playerEvent,
  priority: MessagePriority.urgent,
  seasonYear: 2026,
  week: 1,
  day: 1,
  titleKey: 'msg_playerEvent_title',
  bodyKey: 'msg_playerEvent_body',
  args: {'_legacyTitle': title, '_legacyBody': 'Wybierz decyzję zawodnika.'},
  payload: {
    'teamId': teamId,
    'playerId': playerId,
    'eventKind': 'extraTraining',
  },
  decision: const DecisionSpec(
    options: [
      MessageAction(id: 'accept', labelKey: 'accept'),
      MessageAction(id: 'decline', labelKey: 'decline'),
    ],
    defaultOnExpiry: 'decline',
  ),
  read: true,
);

_TradeScenario _tradeScenario({required int seed, required String title}) {
  final base = task41Game(seed: seed);
  final league = base.leagueState.copyWith(currentWeek: 44, currentDay: 1);
  final own = league.playerTeam!;
  final target = league.teams.firstWhere((team) => team.id != own.id);
  final proposal = TradeProposal(
    teamAId: own.id,
    teamBId: target.id,
    assetsFromA: [TradeAsset.player(own.roster.first.id)],
    assetsFromB: [TradeAsset.player(target.roster.first.id)],
  );
  final created = TradeService().createOffer(
    league,
    proposal,
    offeringTeamId: target.id,
    emitMessages: true,
  );
  if (!created.changed || created.offerId == null) {
    throw StateError('Could not create a valid integration trade offer');
  }
  final generated = created.league.inbox.messages.firstWhere(
    (message) => message.payload['tradeOfferId'] == created.offerId,
  );
  final message = generated.copyWith(
    args: {'_legacyTitle': title, '_legacyBody': 'Oferta wymiany.'},
    read: true,
  );
  final game = base.copyWith(
    leagueState: created.league.copyWith(inbox: Inbox(messages: [message])),
  );
  return _TradeScenario(
    game: game,
    offerId: created.offerId!,
    messageId: message.id,
    title: title,
  );
}

GameMessage? _messageById(GameSave? save, String id) {
  if (save == null) return null;
  for (final message in save.leagueState.inbox.messages) {
    if (message.id == id) return message;
  }
  return null;
}

class _ProductionFixture {
  _ProductionFixture({
    required this.directory,
    required this.repository,
    required this.container,
    required this.router,
    required this.controller,
    required this.game,
  });

  final Directory directory;
  final SaveRepository repository;
  final ProviderContainer container;
  final GoRouter router;
  final GameController controller;
  final GameSave game;

  Widget get app => UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      locale: const Locale('pl'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );

  bool _disposed = false;

  Future<void> dispose(WidgetTester tester) async {
    if (_disposed) return;
    _disposed = true;
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    router.dispose();
    container.dispose();
    await tester.runAsync(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });
  }
}

class _TradeScenario {
  const _TradeScenario({
    required this.game,
    required this.offerId,
    required this.messageId,
    required this.title,
  });

  final GameSave game;
  final String offerId;
  final String messageId;
  final String title;
}

class _AlwaysAcceptRandom implements Random {
  const _AlwaysAcceptRandom();

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) => 0;
}
