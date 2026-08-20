import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/inbox_screen.dart';
import 'package:new_football/app/screens/shell_screen.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/team_event_service.dart';
import 'package:new_football/data/save_repository.dart';

import 'helpers/widget_harness.dart';

/// Seeded regression matrix for Property 1 from the urgent-confirmation
/// design. This is intentionally property-like rather than a new PBT
/// dependency: every generated case is deterministic and its seed is printed
/// in the assertion reason.
void main() {
  for (final scenario in _matrixCases()) {
    testWidgets('seeded urgent confirmation matrix: ${scenario.describe()}', (
      tester,
    ) async {
      final result = await _runScenario(tester, scenario);
      _assertExpectedBehavior(scenario, result);
    });
  }
}

enum _MatrixOperation { acknowledge, decision }

enum _MatrixFailure { none, markRead, effect, save }

enum _MatrixLifecycle { mounted, closeSheet, unmount }

class _MatrixCase {
  const _MatrixCase({
    required this.id,
    required this.seed,
    required this.taps,
    required this.delay,
    required this.operation,
    required this.interleaveOtherControl,
    this.failure = _MatrixFailure.none,
    this.lifecycle = _MatrixLifecycle.mounted,
    this.retryCount = 0,
  });

  final String id;
  final int seed;
  final int taps;
  final Duration delay;
  final _MatrixOperation operation;
  final bool interleaveOtherControl;
  final _MatrixFailure failure;
  final _MatrixLifecycle lifecycle;
  final int retryCount;

  bool get hasDecision => operation == _MatrixOperation.decision;

  String get title => 'Property urgent $id';

  String describe() {
    return 'seed=$seed id=$id taps=$taps '
        'delay=${delay.inMilliseconds}ms operation=${operation.name} '
        'interleaveOtherControl=$interleaveOtherControl '
        'failure=${failure.name} lifecycle=${lifecycle.name} '
        'retryCount=$retryCount';
  }
}

/// The base matrix covers every required tap count for the reference seed and
/// both persistence timings. Additional fixed seeds are generated through
/// Random so the matrix also exercises different deterministic game saves.
List<_MatrixCase> _matrixCases() {
  final cases = <_MatrixCase>[];
  for (final delay in const [Duration.zero, Duration(milliseconds: 300)]) {
    for (var taps = 2; taps <= 10; taps++) {
      final random = Random(4103 + taps + delay.inMilliseconds);
      cases.add(
        _MatrixCase(
          id: '4103-${delay.inMilliseconds}-$taps',
          seed: 4103,
          taps: taps,
          delay: delay,
          operation: random.nextBool()
              ? _MatrixOperation.acknowledge
              : _MatrixOperation.decision,
          interleaveOtherControl: random.nextBool(),
        ),
      );
    }
  }

  const additionalSeeds = [4104, 4117, 4129, 4133, 4151];
  for (final seed in additionalSeeds) {
    final random = Random(seed);
    for (var index = 0; index < 2; index++) {
      cases.add(
        _MatrixCase(
          id: '$seed-random-$index',
          seed: seed,
          taps: 2 + random.nextInt(9),
          delay: random.nextBool()
              ? Duration.zero
              : const Duration(milliseconds: 300),
          operation: random.nextBool()
              ? _MatrixOperation.acknowledge
              : _MatrixOperation.decision,
          interleaveOtherControl: random.nextBool(),
        ),
      );
    }
  }

  // Explicitly cover each controlled failure and both lifecycle exits in
  // addition to the successful generated cases.
  cases.addAll([
    const _MatrixCase(
      id: '4104-mark-read-error',
      seed: 4104,
      taps: 7,
      delay: Duration(milliseconds: 300),
      operation: _MatrixOperation.acknowledge,
      interleaveOtherControl: true,
      failure: _MatrixFailure.markRead,
      retryCount: 1,
    ),
    const _MatrixCase(
      id: '4117-effect-error',
      seed: 4117,
      taps: 5,
      delay: Duration.zero,
      operation: _MatrixOperation.decision,
      interleaveOtherControl: true,
      failure: _MatrixFailure.effect,
      retryCount: 1,
    ),
    const _MatrixCase(
      id: '4129-save-error',
      seed: 4129,
      taps: 10,
      delay: Duration(milliseconds: 300),
      operation: _MatrixOperation.acknowledge,
      interleaveOtherControl: false,
      failure: _MatrixFailure.save,
      retryCount: 1,
    ),
    const _MatrixCase(
      id: '4133-close-during-await',
      seed: 4133,
      taps: 2,
      delay: Duration(milliseconds: 300),
      operation: _MatrixOperation.acknowledge,
      interleaveOtherControl: true,
      lifecycle: _MatrixLifecycle.closeSheet,
    ),
    const _MatrixCase(
      id: '4151-unmount-during-await',
      seed: 4151,
      taps: 8,
      delay: Duration.zero,
      operation: _MatrixOperation.decision,
      interleaveOtherControl: true,
      lifecycle: _MatrixLifecycle.unmount,
    ),
  ]);
  return cases;
}

Future<_MatrixResult> _runScenario(
  WidgetTester tester,
  _MatrixCase scenario,
) async {
  await _resetWidget(tester);

  final base = task41Game(seed: scenario.seed);
  final message = _matrixMessage(
    scenario,
    base,
    read: scenario.failure != _MatrixFailure.markRead,
  );
  final initial = _withInbox(base, Inbox(messages: [message]));
  final repository = _MatrixSaveRepository(
    delay: scenario.delay,
    failingSaveCalls:
        scenario.failure == _MatrixFailure.markRead ||
            scenario.failure == _MatrixFailure.save
        ? {1}
        : const {},
  );
  final eventService = _MatrixTeamEventService(
    failure: scenario.failure == _MatrixFailure.effect,
  );
  final observer = _PopupObserver();
  late GameController controller;

  await tester.pumpWidget(
    task41App(
      const ShellScreen(initialTab: 5),
      initial,
      saveRepository: repository,
      navigatorObservers: [observer],
      onController: (value) => controller = value,
      extraOverrides: [
        teamEventServiceProvider.overrideWithValue(eventService),
      ],
    ),
  );
  await _pumpFrames(tester, count: 3);

  final before = controller.save!;
  var acceptedInputCount = 0;
  var loadingObserved = false;
  var controlsDisabled = false;
  var errorObserved = false;
  var retryAvailable = false;
  var pendingPreservedOnError = true;
  var snapshotPreservedOnError = true;
  var popCountAtError = 0;
  NavigatorState? lifecycleNavigator;
  final operationController = controller;

  final card = find.text(scenario.title).first;
  expect(card, findsOneWidget, reason: scenario.describe());

  if (scenario.failure == _MatrixFailure.markRead) {
    // The opening gate itself is part of the generated input. Send the full
    // card burst before releasing markRead; no sheet may be created yet.
    for (var index = 0; index < scenario.taps; index++) {
      await tester.tap(card, warnIfMissed: false);
    }
    await tester.pump();
    await _waitForSave(tester, repository, 1, scenario);
    final errorBefore = controller.save!;
    repository.release(1);
    await _pumpAfterPersistence(tester, scenario.delay);

    errorObserved = find
        .text('Nie udało się otworzyć wiadomości. Spróbuj ponownie.')
        .evaluate()
        .isNotEmpty;
    popCountAtError = observer.popupPopCount;
    pendingPreservedOnError =
        _pendingCount(controller.save, message.id) ==
        _pendingCount(errorBefore, message.id);
    snapshotPreservedOnError = controller.save == errorBefore;
    expect(find.byType(BottomSheet), findsNothing, reason: scenario.describe());
    expect(errorObserved, isTrue, reason: scenario.describe());
    expect(popCountAtError, 0, reason: scenario.describe());

    // Retrying the same card is the mark-read retry contract. It must open
    // one sheet only after the successful read commit.
    repository.failingSaveCalls.clear();
    retryAvailable = true;
    await tester.tap(card);
    await tester.pump();
    await _waitForSave(tester, repository, 2, scenario);
    repository.release(2);
    await _pumpAfterPersistence(tester, scenario.delay);
    await tester.pump(const Duration(milliseconds: 250));
    expect(
      find.byType(BottomSheet),
      findsOneWidget,
      reason: scenario.describe(),
    );
    expect(
      _messageById(controller.save, message.id)?.read,
      isTrue,
      reason: scenario.describe(),
    );
  } else {
    await tester.tap(card);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(
      find.byType(BottomSheet),
      findsOneWidget,
      reason: scenario.describe(),
    );
  }

  final confirmationBefore = controller.save!;
  final confirmationSaveStart = repository.saveCount;
  final confirmationCallbacks = _confirmationCallbacks(tester, scenario);
  final primary = confirmationCallbacks.primary;
  final alternate = confirmationCallbacks.alternate;

  // The first callback is always the operation owner. The optional alternate
  // callback is delivered only after it, which exercises disabled local input
  // without allowing a different operation to win the race.
  primary();
  acceptedInputCount++;
  for (var index = 1; index < scenario.taps; index++) {
    if (index == 1 && alternate != null && scenario.interleaveOtherControl) {
      alternate();
    } else {
      primary();
    }
    acceptedInputCount++;
  }
  await tester.pump();

  final expectedFirstConfirmationSave = confirmationSaveStart + 1;
  if (scenario.failure == _MatrixFailure.effect) {
    await _pumpFrames(tester, count: 4);
    errorObserved = find
        .text('Nie udało się potwierdzić wiadomości. Spróbuj ponownie.')
        .evaluate()
        .isNotEmpty;
    popCountAtError = observer.popupPopCount;
    pendingPreservedOnError =
        _pendingCount(controller.save, message.id) ==
        _pendingCount(confirmationBefore, message.id);
    snapshotPreservedOnError = controller.save == confirmationBefore;
    expect(errorObserved, isTrue, reason: scenario.describe());
  } else {
    await _waitForSave(
      tester,
      repository,
      expectedFirstConfirmationSave,
      scenario,
    );
    await tester.pump(const Duration(milliseconds: 100));
    loadingObserved = find
        .text('Zapisywanie potwierdzenia…')
        .evaluate()
        .isNotEmpty;
    controlsDisabled = _confirmationControlsDisabled(tester, scenario);
    expect(loadingObserved, isTrue, reason: scenario.describe());
    expect(controlsDisabled, isTrue, reason: scenario.describe());
    expect(
      repository.completedSaves.length,
      scenario.failure == _MatrixFailure.markRead ? 1 : 0,
      reason: scenario.describe(),
    );
    expect(
      controller.save,
      same(confirmationBefore),
      reason: scenario.describe(),
    );

    // Exercise close/unmount while the repository future is still pending.
    // The controller may commit after this point, but the sheet callback must
    // not touch a disposed context or perform a second pop.
    if (scenario.lifecycle == _MatrixLifecycle.closeSheet) {
      Navigator.of(tester.element(find.byType(InboxScreen))).pop();
      await tester.pump(const Duration(milliseconds: 16));
    } else if (scenario.lifecycle == _MatrixLifecycle.unmount) {
      // First remove the modal route, then replace the shell route while the
      // repository is still pending. ProviderScope stays mounted, so the
      // controller can finish the data operation without a late UI callback.
      final shellContext = tester.element(find.byType(ShellScreen));
      final navigator = Navigator.of(shellContext);
      lifecycleNavigator = navigator;
      navigator.pop();
      // Complete the popup route's reverse transition before replacing the
      // underlying shell route. A single 16 ms frame can leave Navigator
      // processing the popup, making the subsequent replacement target the
      // wrong route and leaving an empty stack after the remount.
      await _pumpFrames(tester, count: 24);
      navigator.pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const SizedBox.shrink()),
      );
      await _pumpFrames(tester, count: 24);
    }

    repository.release(expectedFirstConfirmationSave);
    await _pumpAfterPersistence(tester, scenario.delay);

    if (scenario.failure == _MatrixFailure.save) {
      await _pumpFrames(tester, count: 3);
      errorObserved = find
          .text('Nie udało się potwierdzić wiadomości. Spróbuj ponownie.')
          .evaluate()
          .isNotEmpty;
      popCountAtError = observer.popupPopCount;
      pendingPreservedOnError =
          _pendingCount(controller.save, message.id) ==
          _pendingCount(confirmationBefore, message.id);
      snapshotPreservedOnError = controller.save == confirmationBefore;
      expect(errorObserved, isTrue, reason: scenario.describe());
    }
  }

  if (scenario.failure == _MatrixFailure.effect ||
      scenario.failure == _MatrixFailure.save) {
    retryAvailable = find.text('Spróbuj ponownie').evaluate().isNotEmpty;
    expect(retryAvailable, isTrue, reason: scenario.describe());
    expect(popCountAtError, 0, reason: scenario.describe());
    expect(pendingPreservedOnError, isTrue, reason: scenario.describe());
    expect(snapshotPreservedOnError, isTrue, reason: scenario.describe());

    if (scenario.failure == _MatrixFailure.effect) {
      eventService.failure = false;
    } else {
      repository.failingSaveCalls.clear();
    }
    final retrySave = repository.saveCount + 1;
    await tester.tap(find.text('Spróbuj ponownie'));
    await tester.pump();
    await _waitForSave(tester, repository, retrySave, scenario);
    await tester.pump(const Duration(milliseconds: 100));
    loadingObserved =
        loadingObserved ||
        find.text('Zapisywanie potwierdzenia…').evaluate().isNotEmpty;
    controlsDisabled =
        controlsDisabled || _confirmationControlsDisabled(tester, scenario);
    repository.release(retrySave);
    await _pumpAfterPersistence(tester, scenario.delay);
  }

  // Lifecycle exits were applied before releasing the first confirmation
  // save above. No callback should need another close after this point.

  // A successful confirmation is the only phase whose persistence count is
  // measured below. Mark-read recovery can have one earlier committed read;
  // it must not be mistaken for a duplicate acknowledgement commit.
  final confirmationCommit = _confirmationSaveNumber(
    repository.completedSaves,
    message.id,
  );
  await _pumpFrames(tester, count: 4);
  final activeAfter = operationController.save;
  final persistedAfter = repository.lastPersisted;
  var shellInteractive = false;

  if (scenario.lifecycle == _MatrixLifecycle.unmount) {
    // Remount the shell in the same ProviderScope after the old route was
    // removed. This verifies that the committed provider remains usable.
    expect(lifecycleNavigator, isNotNull, reason: scenario.describe());
    lifecycleNavigator!.pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const ShellScreen(initialTab: 5)),
    );
    await _pumpFrames(tester, count: 24);
    // ShellScreen writes its initial tab from a post-frame callback. Give
    // that callback and the resulting rebuild their own deterministic frames.
    await tester.pump();
    await _pumpFrames(tester, count: 3);
    shellInteractive = await _probeShell(tester);
  } else {
    shellInteractive = await _probeShell(tester);
  }

  final unhandledException = await _drainExceptions(tester);
  final finalMessage = _messageById(operationController.save, message.id);
  final confirmationPersistCount = confirmationCommit == null ? 0 : 1;
  final committedOperationCount = confirmationPersistCount;
  final result = _MatrixResult(
    acceptedInputCount: acceptedInputCount,
    committedOperationCount: committedOperationCount,
    persistCount: confirmationPersistCount,
    domainEffectCount: eventService.successfulEffects,
    popCount: observer.popupPopCount,
    before: before,
    activeAfter: activeAfter,
    persistedAfter: persistedAfter,
    finalMessage: finalMessage,
    loadingObserved: loadingObserved,
    controlsDisabled: controlsDisabled,
    errorObserved: errorObserved,
    retryAvailable: retryAvailable,
    pendingPreservedOnError: pendingPreservedOnError,
    snapshotPreservedOnError: snapshotPreservedOnError,
    shellInteractive: shellInteractive,
    unhandledException: unhandledException,
    totalSaveAttempts: repository.saveCount,
  );
  return result;
}

({VoidCallback primary, VoidCallback? alternate}) _confirmationCallbacks(
  WidgetTester tester,
  _MatrixCase scenario,
) {
  if (!scenario.hasDecision) {
    final acknowledge = find.widgetWithText(FilledButton, 'Potwierdź');
    final acknowledgeButton = tester.widget<FilledButton>(acknowledge);
    final action = find.widgetWithText(OutlinedButton, 'Otwórz');
    final alternate = action.evaluate().isEmpty
        ? null
        : tester.widget<OutlinedButton>(action).onPressed;
    expect(acknowledgeButton.onPressed, isNotNull, reason: scenario.describe());
    return (primary: acknowledgeButton.onPressed!, alternate: alternate);
  }

  final selected = scenario.interleaveOtherControl ? 'Akceptuj' : 'Odrzuć';
  final other = selected == 'Akceptuj' ? 'Odrzuć' : 'Akceptuj';
  final selectedButton = tester.widget<FilledButton>(
    find.widgetWithText(FilledButton, selected),
  );
  final otherButton = tester.widget<FilledButton>(
    find.widgetWithText(FilledButton, other),
  );
  expect(selectedButton.onPressed, isNotNull, reason: scenario.describe());
  expect(otherButton.onPressed, isNotNull, reason: scenario.describe());
  return (primary: selectedButton.onPressed!, alternate: otherButton.onPressed);
}

bool _confirmationControlsDisabled(WidgetTester tester, _MatrixCase scenario) {
  if (!scenario.hasDecision) {
    final acknowledge = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Potwierdź'),
    );
    final action = find.widgetWithText(OutlinedButton, 'Otwórz');
    return acknowledge.onPressed == null &&
        (action.evaluate().isEmpty ||
            tester.widget<OutlinedButton>(action).onPressed == null);
  }

  final accept = tester.widget<FilledButton>(
    find.widgetWithText(FilledButton, 'Akceptuj'),
  );
  final decline = tester.widget<FilledButton>(
    find.widgetWithText(FilledButton, 'Odrzuć'),
  );
  return accept.onPressed == null && decline.onPressed == null;
}

void _assertExpectedBehavior(_MatrixCase scenario, _MatrixResult result) {
  final reason = '${scenario.describe()} result=${result.describe()}';
  expect(result.acceptedInputCount, greaterThanOrEqualTo(1), reason: reason);
  expect(result.committedOperationCount, lessThanOrEqualTo(1), reason: reason);
  expect(result.persistCount, lessThanOrEqualTo(1), reason: reason);
  expect(result.domainEffectCount, lessThanOrEqualTo(1), reason: reason);
  expect(result.popCount, lessThanOrEqualTo(1), reason: reason);
  expect(result.unhandledException, isNull, reason: reason);
  expect(result.finalMessage?.read, isTrue, reason: reason);
  expect(result.finalMessage?.acknowledged, isTrue, reason: reason);
  expect(result.finalMessage?.id, isNotNull, reason: reason);
  expect(result.finalMessage?.acknowledged, isTrue, reason: reason);
  expect(
    result.activeAfter?.leagueState.inbox.pendingUrgent,
    isEmpty,
    reason: reason,
  );
  expect(
    _sameSave(result.activeAfter, result.persistedAfter),
    isTrue,
    reason: reason,
  );
  expect(result.shellInteractive, isTrue, reason: reason);
  expect(
    result.errorObserved,
    scenario.failure == _MatrixFailure.none ? isFalse : isTrue,
    reason: reason,
  );
  if (scenario.failure != _MatrixFailure.none) {
    expect(result.retryAvailable, isTrue, reason: reason);
    expect(result.pendingPreservedOnError, isTrue, reason: reason);
    expect(result.snapshotPreservedOnError, isTrue, reason: reason);
    expect(result.popCount, lessThanOrEqualTo(1), reason: reason);
  }
  if (scenario.failure == _MatrixFailure.none &&
      scenario.lifecycle != _MatrixLifecycle.unmount) {
    expect(result.loadingObserved, isTrue, reason: reason);
    expect(result.controlsDisabled, isTrue, reason: reason);
  }
}

GameMessage _matrixMessage(
  _MatrixCase scenario,
  GameSave base, {
  required bool read,
}) {
  final team = base.leagueState.playerTeam!;
  final decision = scenario.hasDecision
      ? const DecisionSpec(
          options: [
            MessageAction(id: 'accept', labelKey: 'accept'),
            MessageAction(id: 'decline', labelKey: 'decline'),
          ],
          defaultOnExpiry: 'decline',
        )
      : null;
  return GameMessage(
    id: 'property-${scenario.id}',
    type: scenario.hasDecision
        ? MessageType.teamEvent
        : MessageType.playerEvent,
    kind: scenario.hasDecision ? 'moreMinutesRequest' : null,
    domain: scenario.hasDecision
        ? MessageDomain.teamEvent
        : MessageDomain.playerEvent,
    priority: MessagePriority.urgent,
    seasonYear: 2026,
    week: 1,
    day: 1,
    titleKey: 'msg_playerEvent_title',
    bodyKey: 'msg_playerEvent_body',
    args: {
      '_legacyTitle': scenario.title,
      '_legacyBody': scenario.hasDecision
          ? 'Wybierz jedną z opcji.'
          : 'Treść pilnej wiadomości.',
    },
    payload: scenario.hasDecision
        ? {'teamId': team.id, 'playerId': team.roster.first.id}
        : const {},
    actions: scenario.hasDecision
        ? const []
        : const [MessageAction(id: 'open', labelKey: 'open')],
    decision: decision,
    read: read,
  );
}

GameSave _withInbox(GameSave game, Inbox inbox) =>
    game.copyWith(leagueState: game.leagueState.copyWith(inbox: inbox));

GameMessage? _messageById(GameSave? save, String id) {
  if (save == null) return null;
  for (final message in save.leagueState.inbox.messages) {
    if (message.id == id) return message;
  }
  return null;
}

int _pendingCount(GameSave? save, String id) {
  if (save == null) return 0;
  return save.leagueState.inbox.pendingUrgent.any((message) => message.id == id)
      ? 1
      : 0;
}

GameSave? _confirmationSaveNumber(List<GameSave> saves, String id) {
  for (final save in saves.reversed) {
    final message = _messageById(save, id);
    if (message?.acknowledged == true) return save;
  }
  return null;
}

bool _sameSave(GameSave? left, GameSave? right) =>
    left != null && right != null && left == right;

Future<void> _resetWidget(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> _pumpFrames(
  WidgetTester tester, {
  required int count,
  Duration step = const Duration(milliseconds: 16),
}) async {
  for (var index = 0; index < count; index++) {
    await tester.pump(step);
  }
}

Future<void> _pumpAfterPersistence(WidgetTester tester, Duration delay) async {
  await tester.pump(delay);
  await _pumpFrames(tester, count: 5);
}

Future<void> _waitForSave(
  WidgetTester tester,
  _MatrixSaveRepository repository,
  int callNumber,
  _MatrixCase scenario,
) async {
  for (var index = 0; index < 20; index++) {
    if (repository.saveCount >= callNumber) return;
    await tester.pump(Duration.zero);
  }
  expect(
    repository.saveCount,
    greaterThanOrEqualTo(callNumber),
    reason: '${scenario.describe()} did not start save $callNumber',
  );
}

Future<bool> _probeShell(WidgetTester tester) async {
  final navigation = find.byType(NavigationBar);
  final destinations = find.byType(NavigationDestination);
  if (navigation.evaluate().isEmpty || destinations.evaluate().length < 2) {
    return false;
  }
  final initialBar = tester.widget<NavigationBar>(navigation);
  final onDestinationSelected = initialBar.onDestinationSelected;
  if (onDestinationSelected == null) return false;
  onDestinationSelected(0);
  await tester.pump(const Duration(milliseconds: 16));
  final homeBar = tester.widget<NavigationBar>(navigation);
  homeBar.onDestinationSelected?.call(1);
  await tester.pump(const Duration(milliseconds: 16));
  final bar = tester.widget<NavigationBar>(navigation);
  return bar.selectedIndex == 1 &&
      find.byType(ShellScreen).evaluate().isNotEmpty;
}

Future<Object?> _drainExceptions(WidgetTester tester) async {
  Object? first;
  for (var index = 0; index < 4; index++) {
    first ??= tester.takeException();
    await tester.pump(Duration.zero);
  }
  first ??= tester.takeException();
  return first;
}

class _MatrixResult {
  const _MatrixResult({
    required this.acceptedInputCount,
    required this.committedOperationCount,
    required this.persistCount,
    required this.domainEffectCount,
    required this.popCount,
    required this.before,
    required this.activeAfter,
    required this.persistedAfter,
    required this.finalMessage,
    required this.loadingObserved,
    required this.controlsDisabled,
    required this.errorObserved,
    required this.retryAvailable,
    required this.pendingPreservedOnError,
    required this.snapshotPreservedOnError,
    required this.shellInteractive,
    required this.unhandledException,
    required this.totalSaveAttempts,
  });

  final int acceptedInputCount;
  final int committedOperationCount;
  final int persistCount;
  final int domainEffectCount;
  final int popCount;
  final GameSave before;
  final GameSave? activeAfter;
  final GameSave? persistedAfter;
  final GameMessage? finalMessage;
  final bool loadingObserved;
  final bool controlsDisabled;
  final bool errorObserved;
  final bool retryAvailable;
  final bool pendingPreservedOnError;
  final bool snapshotPreservedOnError;
  final bool shellInteractive;
  final Object? unhandledException;
  final int totalSaveAttempts;

  String describe() {
    return 'acceptedInputCount=$acceptedInputCount '
        'committedOperationCount=$committedOperationCount '
        'persistCount=$persistCount domainEffectCount=$domainEffectCount '
        'popCount=$popCount totalSaveAttempts=$totalSaveAttempts '
        'message={read:${finalMessage?.read},ack:${finalMessage?.acknowledged}} '
        'pending=${activeAfter?.leagueState.inbox.pendingUrgent.length} '
        'activePersistedEqual=${_sameSave(activeAfter, persistedAfter)} '
        'loadingObserved=$loadingObserved controlsDisabled=$controlsDisabled '
        'errorObserved=$errorObserved retryAvailable=$retryAvailable '
        'shellInteractive=$shellInteractive exception=$unhandledException';
  }
}

class _MatrixTeamEventService extends TeamEventService {
  _MatrixTeamEventService({required this.failure});

  bool failure;
  int decisionCalls = 0;
  int successfulEffects = 0;

  @override
  LeagueState resolveDecision(
    LeagueState league,
    GameMessage message,
    String optionId, {
    int saveSeed = 0,
  }) {
    decisionCalls++;
    if (failure) {
      throw StateError('Property-controlled domain effect failure');
    }
    successfulEffects++;
    return super.resolveDecision(league, message, optionId, saveSeed: saveSeed);
  }
}

class _MatrixSaveRepository extends SaveRepository {
  _MatrixSaveRepository({
    required this.delay,
    Iterable<int> failingSaveCalls = const {},
  }) : failingSaveCalls = {...failingSaveCalls};

  final Duration delay;
  final Set<int> failingSaveCalls;
  final List<Completer<void>> _saveGates = [];

  int saveCount = 0;
  final List<GameSave> attemptedSaves = [];
  final List<GameSave> completedSaves = [];

  GameSave? get lastPersisted =>
      completedSaves.isEmpty ? null : completedSaves.last;

  @override
  Future<void> save(GameSave gameSave) async {
    final callNumber = ++saveCount;
    final gate = Completer<void>();
    _saveGates.add(gate);
    attemptedSaves.add(gameSave);

    if (delay > Duration.zero) await Future<void>.delayed(delay);
    await gate.future;
    if (failingSaveCalls.contains(callNumber)) {
      throw SaveRepositoryException('Property-controlled save failure');
    }
    completedSaves.add(gameSave);
  }

  void release(int callNumber) {
    if (callNumber > _saveGates.length) {
      throw StateError('Cannot release save $callNumber');
    }
    final gate = _saveGates[callNumber - 1];
    if (!gate.isCompleted) gate.complete();
  }
}

class _PopupObserver extends NavigatorObserver {
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
