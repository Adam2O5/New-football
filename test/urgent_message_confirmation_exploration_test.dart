import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/inbox_screen.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/data/save_repository.dart';

import 'helpers/widget_harness.dart';

void main() {
  testWidgets('exploration on unchanged F: 300 ms confirmation bursts 2..10 '
      'record saveCount/popCount/pendingUrgent counterexamples', (
    tester,
  ) async {
    final observations = <_ConfirmationObservation>[];
    for (var taps = 2; taps <= 10; taps++) {
      observations.add(
        await _runConfirmationBurst(
          tester,
          taps: taps,
          delay: const Duration(milliseconds: 300),
        ),
      );
    }
    observations.add(await _runCardBurst(tester));

    // This is intentionally a red exploration assertion on the unchanged
    // implementation. A concrete F counterexample is a successful result
    // for task 1 and must be retained for the later fix-checking run.
    final violations = observations
        .where((observation) => !observation.expectedBehavior)
        .toList();
    expect(
      violations,
      isEmpty,
      reason:
          'Property 1 exploration expectedBehavior was violated on F. '
          'Concrete observations (taps, delay, saveCount, popCount, '
          'pendingUrgent, and active/persisted snapshots):\n'
          '${observations.map((observation) => observation.describe()).join('\n')}',
    );
  });

  testWidgets('exploration on unchanged F: zero-delay confirmation bursts 2..10 '
      'report whether the same race reproduces', (tester) async {
    final observations = <_ConfirmationObservation>[];
    for (var taps = 2; taps <= 10; taps++) {
      observations.add(
        await _runConfirmationBurst(tester, taps: taps, delay: Duration.zero),
      );
    }

    // Zero-delay is a separate observation: depending on microtask order,
    // F may close before all requested taps arrive. It must still be
    // reported rather than hidden behind pumpAndSettle.
    final violations = observations
        .where((observation) => !observation.expectedBehavior)
        .toList();
    expect(
      violations,
      isEmpty,
      reason:
          'Zero-delay exploration reproduced a counterexample. '
          'Observed values:\n'
          '${observations.map((observation) => observation.describe()).join('\n')}',
    );
  });
}

Future<_ConfirmationObservation> _runConfirmationBurst(
  WidgetTester tester, {
  required int taps,
  required Duration delay,
}) async {
  await _resetScenario(tester);
  final repository = _ExplorationSaveRepository(delay: delay);
  final observer = _CountingNavigatorObserver();
  late GameController controller;
  final game = _gameWithInbox(
    task41Game(seed: 4103),
    Inbox(messages: [_urgentMessage(decision: false)]),
  );

  await tester.pumpWidget(
    task41App(
      const Scaffold(body: InboxScreen()),
      game,
      saveRepository: repository,
      navigatorObservers: [observer],
      onController: (value) => controller = value,
    ),
  );
  await tester.pump();
  final card = find
      .ancestor(
        of: find.text('Pilna wiadomość').first,
        matching: find.byType(ListTile),
      )
      .first;
  await tester.tap(card);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));

  final acknowledgeButton = find.text('Potwierdź');
  final sheetOpened = acknowledgeButton.evaluate().isNotEmpty;
  var acceptedTapCount = 0;
  if (sheetOpened) {
    for (var index = 0; index < taps; index++) {
      // With zero delay F can close the sheet before the requested burst has
      // been delivered. Record that observation instead of throwing from a
      // missing finder; the 300 ms gate keeps the full burst in flight.
      if (acknowledgeButton.evaluate().isEmpty) break;
      await tester.tap(acknowledgeButton);
      acceptedTapCount++;
    }
  }

  // For delay=300 ms, do not release the Completer before taking the
  // pending snapshot. This is the exact window in which F publishes the
  // acknowledgement before persistence and accepts duplicate taps.
  if (delay > Duration.zero) {
    await tester.pump(const Duration(milliseconds: 100));
  } else {
    await tester.pump();
  }
  final activeBeforeRelease = controller.save;
  final persistedBeforeRelease = repository.lastPersisted;
  final pendingBeforeRelease =
      activeBeforeRelease?.leagueState.inbox.pendingUrgent.length;

  repository.release();
  if (delay > Duration.zero) {
    await tester.pump(delay);
  } else {
    await tester.pump();
  }
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump();

  final unhandledException = await _drainExceptions(tester);
  final activeAfterRelease = controller.save;
  final persistedAfterRelease = repository.lastPersisted;
  final applicationRemainsInteractive = await _probeInboxInteractivity(tester);

  return _ConfirmationObservation(
    kind: 'confirmation',
    taps: taps,
    acceptedTapCount: acceptedTapCount,
    delay: delay,
    saveCount: repository.saveCount,
    confirmationSaveCount: repository.saveCount - 1,
    popCount: observer.popupPopCount,
    popupPushCount: observer.popupPushCount,
    pendingBeforeRelease: pendingBeforeRelease,
    pendingAfterRelease:
        activeAfterRelease?.leagueState.inbox.pendingUrgent.length,
    activeBeforeRelease: activeBeforeRelease,
    persistedBeforeRelease: persistedBeforeRelease,
    activeAfterRelease: activeAfterRelease,
    persistedAfterRelease: persistedAfterRelease,
    unhandledException: unhandledException,
    applicationRemainsInteractive: applicationRemainsInteractive,
    sheetOpened: sheetOpened,
  );
}

Future<_ConfirmationObservation> _runCardBurst(WidgetTester tester) async {
  await _resetScenario(tester);
  final repository = _ExplorationSaveRepository(
    delay: const Duration(milliseconds: 300),
    blockFirstSave: true,
  );
  final observer = _CountingNavigatorObserver();
  late GameController controller;
  final game = _gameWithInbox(
    task41Game(seed: 4103),
    Inbox(messages: [_urgentMessage(decision: false)]),
  );

  await tester.pumpWidget(
    task41App(
      const Scaffold(body: InboxScreen()),
      game,
      saveRepository: repository,
      navigatorObservers: [observer],
      onController: (value) => controller = value,
    ),
  );
  await tester.pump();

  final card = find
      .ancestor(
        of: find.text('Pilna wiadomość').first,
        matching: find.byType(ListTile),
      )
      .first;
  var acceptedTapCount = 0;
  for (var index = 0; index < 3; index++) {
    if (card.evaluate().isEmpty) break;
    await tester.tap(card);
    acceptedTapCount++;
  }
  await tester.pump(const Duration(milliseconds: 100));

  final activeBeforeRelease = controller.save;
  final persistedBeforeRelease = repository.lastPersisted;
  final pendingBeforeRelease =
      activeBeforeRelease?.leagueState.inbox.pendingUrgent.length;

  repository.release();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 250));

  // Close any sheets opened by the unfixed callbacks so the next scenario can
  // start from a clean widget tree. The counters are captured before cleanup.
  while (observer.popupPopCount < observer.popupPushCount &&
      find.byType(InboxScreen).evaluate().isNotEmpty) {
    Navigator.of(tester.element(find.byType(InboxScreen))).pop();
    await tester.pump(const Duration(milliseconds: 250));
  }

  await tester.pump();
  final unhandledException = await _drainExceptions(tester);
  final activeAfterRelease = controller.save;
  final persistedAfterRelease = repository.lastPersisted;
  final applicationRemainsInteractive = await _probeInboxInteractivity(tester);

  return _ConfirmationObservation(
    kind: 'card-open',
    taps: 3,
    acceptedTapCount: acceptedTapCount,
    delay: const Duration(milliseconds: 300),
    saveCount: repository.saveCount,
    confirmationSaveCount: repository.saveCount,
    popCount: observer.popupPopCount,
    popupPushCount: observer.popupPushCount,
    pendingBeforeRelease: pendingBeforeRelease,
    pendingAfterRelease:
        activeAfterRelease?.leagueState.inbox.pendingUrgent.length,
    activeBeforeRelease: activeBeforeRelease,
    persistedBeforeRelease: persistedBeforeRelease,
    activeAfterRelease: activeAfterRelease,
    persistedAfterRelease: persistedAfterRelease,
    unhandledException: unhandledException,
    applicationRemainsInteractive: applicationRemainsInteractive,
    sheetOpened: observer.popupPushCount > 0,
  );
}

Future<bool> _probeInboxInteractivity(WidgetTester tester) async {
  if (find.byType(InboxScreen).evaluate().isEmpty) return false;
  final segmentedButton = find.byWidgetPredicate(
    (widget) => widget.runtimeType.toString().startsWith('SegmentedButton'),
  );
  if (segmentedButton.evaluate().isEmpty) return false;
  await tester.tap(segmentedButton, warnIfMissed: false);
  await tester.pump();
  return find.byType(InboxScreen).evaluate().isNotEmpty;
}

Future<Object?> _drainExceptions(WidgetTester tester) async {
  Object? firstException;
  for (var frame = 0; frame < 4; frame++) {
    final exception = tester.takeException();
    firstException ??= exception;
    await tester.pump();
  }
  firstException ??= tester.takeException();
  return firstException;
}

Future<void> _resetScenario(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 250));
}

class _ExplorationSaveRepository extends SaveRepository {
  _ExplorationSaveRepository({
    required this.delay,
    this.blockFirstSave = false,
  });

  final Duration delay;
  final bool blockFirstSave;
  final Completer<void> _releaseCompleter = Completer<void>();

  int saveCount = 0;
  final List<GameSave> completedSaves = [];
  GameSave? lastPersisted;

  @override
  Future<void> save(GameSave gameSave) async {
    saveCount++;
    final callNumber = saveCount;
    final shouldWait =
        (blockFirstSave && callNumber == 1) ||
        (!blockFirstSave && callNumber > 1 && delay > Duration.zero);
    if (shouldWait) {
      await Future.wait<void>([
        Future<void>.delayed(delay),
        _releaseCompleter.future,
      ]);
    } else if (callNumber > 1) {
      // Keep the zero-delay case asynchronous without introducing a timing
      // grace period that could conceal duplicate operations.
      await Future<void>.delayed(Duration.zero);
    }
    completedSaves.add(gameSave);
    lastPersisted = gameSave;
  }

  void release() {
    if (!_releaseCompleter.isCompleted) _releaseCompleter.complete();
  }
}

class _CountingNavigatorObserver extends NavigatorObserver {
  int popupPushCount = 0;
  int popupPopCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PopupRoute<dynamic>) popupPushCount++;
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PopupRoute<dynamic>) popupPopCount++;
    super.didPop(route, previousRoute);
  }
}

class _ConfirmationObservation {
  const _ConfirmationObservation({
    required this.kind,
    required this.taps,
    required this.acceptedTapCount,
    required this.delay,
    required this.saveCount,
    required this.confirmationSaveCount,
    required this.popCount,
    required this.popupPushCount,
    required this.pendingBeforeRelease,
    required this.pendingAfterRelease,
    required this.activeBeforeRelease,
    required this.persistedBeforeRelease,
    required this.activeAfterRelease,
    required this.persistedAfterRelease,
    required this.unhandledException,
    required this.applicationRemainsInteractive,
    required this.sheetOpened,
  });

  final String kind;
  final int taps;
  final int acceptedTapCount;
  final Duration delay;
  final int saveCount;
  final int confirmationSaveCount;
  final int popCount;
  final int popupPushCount;
  final int? pendingBeforeRelease;
  final int? pendingAfterRelease;
  final GameSave? activeBeforeRelease;
  final GameSave? persistedBeforeRelease;
  final GameSave? activeAfterRelease;
  final GameSave? persistedAfterRelease;
  final Object? unhandledException;
  final bool applicationRemainsInteractive;
  final bool sheetOpened;

  bool get expectedBehavior {
    if (kind == 'card-open') {
      final messageAfter = activeAfterRelease?.leagueState.inbox.messages
          .where((message) => message.id == 'task41-urgent')
          .firstOrNull;
      return acceptedTapCount >= 1 &&
          saveCount <= 1 &&
          popupPushCount <= 1 &&
          popCount <= 1 &&
          pendingAfterRelease == 1 &&
          messageAfter?.read == true &&
          messageAfter?.acknowledged == false &&
          _sameSave(activeAfterRelease, persistedAfterRelease) &&
          unhandledException == null &&
          applicationRemainsInteractive;
    }

    final messageAfter = activeAfterRelease?.leagueState.inbox.messages
        .where((message) => message.id == 'task41-urgent')
        .firstOrNull;
    return sheetOpened &&
        confirmationSaveCount <= 1 &&
        _sameSave(activeBeforeRelease, persistedBeforeRelease) &&
        popCount <= 1 &&
        pendingAfterRelease == 0 &&
        messageAfter?.read == true &&
        messageAfter?.acknowledged == true &&
        _sameSave(activeAfterRelease, persistedAfterRelease) &&
        unhandledException == null &&
        applicationRemainsInteractive;
  }

  String describe() {
    final activeBefore = _messageState(activeBeforeRelease);
    final persistedBefore = _messageState(persistedBeforeRelease);
    final activeAfter = _messageState(activeAfterRelease);
    final persistedAfter = _messageState(persistedAfterRelease);
    return '$kind taps=$taps acceptedTapCount=$acceptedTapCount '
        'delay=${delay.inMilliseconds}ms saveCount=$saveCount '
        'confirmationSaveCount=$confirmationSaveCount '
        'popupPushCount=$popupPushCount popCount=$popCount '
        'pendingUrgentBeforeRelease=$pendingBeforeRelease '
        'pendingUrgentAfterRelease=$pendingAfterRelease '
        'activeBefore=$activeBefore persistedBefore=$persistedBefore '
        'activeAfter=$activeAfter persistedAfter=$persistedAfter '
        'unhandledException=$unhandledException '
        'applicationRemainsInteractive=$applicationRemainsInteractive '
        'sheetOpened=$sheetOpened expectedBehavior=$expectedBehavior';
  }

  static String _messageState(GameSave? save) {
    if (save == null) return 'null';
    final message = save.leagueState.inbox.messages.firstWhere(
      (candidate) => candidate.id == 'task41-urgent',
      orElse: () => _urgentMessage(decision: false),
    );
    return '{read:${message.read},ack:${message.acknowledged}}';
  }
}

bool _sameSave(GameSave? left, GameSave? right) =>
    left != null && left == right;

GameSave _gameWithInbox(GameSave game, Inbox inbox) =>
    game.copyWith(leagueState: game.leagueState.copyWith(inbox: inbox));

GameMessage _urgentMessage({required bool decision}) => GameMessage(
  id: decision ? 'task41-decision' : 'task41-urgent',
  type: MessageType.playerEvent,
  domain: MessageDomain.playerEvent,
  priority: MessagePriority.urgent,
  seasonYear: 2026,
  week: 1,
  day: 1,
  titleKey: 'msg_playerEvent_title',
  bodyKey: 'msg_playerEvent_body',
  args: const {
    '_legacyTitle': 'Pilna wiadomość',
    '_legacyBody': 'Treść pilnej wiadomości.',
  },
  decision: decision
      ? const DecisionSpec(
          options: [
            MessageAction(id: 'accept', labelKey: 'accept'),
            MessageAction(id: 'decline', labelKey: 'decline'),
          ],
          defaultOnExpiry: 'decline',
        )
      : null,
);
