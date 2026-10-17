part of 'home_screen.dart';

DateTime _dateForInGameWeekDay(int seasonYear, int week, int day) =>
    const CalendarService().dateForWeekDay(seasonYear, week, day);

({int week, int day})? _inGameWeekDayForDate(DateTime date, int seasonYear) =>
    const CalendarService().weekDayForDate(date, seasonYear);

DateTime _monthForInGame(LeagueState league) {
  final d = _dateForInGameWeekDay(
    league.currentSeason.year,
    league.currentWeek,
    league.currentDay,
  );
  return DateTime(d.year, d.month);
}

void _refreshCalendarCursor(WidgetRef ref) {
  final league = ref.read(activeLeagueProvider);
  if (league == null) return;
  ref.read(calendarCursorMonthProvider.notifier).state = _monthForInGame(
    league,
  );
}

/// Screen route for `playerAction` events that have a dedicated UI. Events
/// without one (e.g. `scoutReport`, `nextClassGeneration` today) fall back
/// to the draft screen, since that's where the related watchlist/board UI
/// currently lives.
String? _routeForEvent(CalendarEventId id) => switch (id) {
  CalendarEventId.lottery => '/game/lottery',
  CalendarEventId.draft => '/game/draft',
  CalendarEventId.scoutReport => '/game/prospects?watchlist=true&combine=true',
  CalendarEventId.nextClassGeneration => '/game/draft',
  CalendarEventId.freeAgencyOpen => '/game/contracts',
  _ => null,
};

Future<BatchSimulationResult> _runBatchDialog(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  Future<BatchSimulationResult> Function() run,
) async {
  final controller = ref.read(gameControllerProvider.notifier);
  unawaited(
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        content: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(l10n.calendar_simulating)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: controller.cancelSimulation,
            child: Text(l10n.calendar_cancel),
          ),
        ],
      ),
    ),
  );

  final result = await run();

  if (context.mounted) {
    Navigator.of(context, rootNavigator: true).pop();
  }
  return result;
}

/// Presents a Home batch result without changing message lifecycle state.
///
/// The caller remains responsible for route-specific actions. This keeps a
/// player match or a dedicated event screen visible even when a pending urgent
/// message is left behind by a batch. The pending check deliberately reads the
/// final controller state, never the live simulation-setting preference.
void _presentHomeBatchResult(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n, {
  BatchSimulationResult? batchResult,
  DaySimulationResult? dayResult,
  String? message,
  bool showBatchResult = true,
  bool playerMatchTakesPriority = false,
}) {
  final playerMatch =
      dayResult?.playerMatch ?? batchResult?.lastResult?.playerMatch;
  final stoppedForUrgent =
      batchResult?.stopReason == SimulationStopReason.urgent ||
      (dayResult?.pauseForUrgent ?? false);
  if (stoppedForUrgent && !(playerMatchTakesPriority && playerMatch != null)) {
    ref.read(shellTabIndexProvider.notifier).state = 5;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.calendar_urgentMessage)));
    return;
  }

  final hasPendingUrgent =
      ref.read(activeLeagueProvider)?.inbox.pendingUrgent.isNotEmpty == true;
  final resultMessage =
      message ??
      (showBatchResult && batchResult != null
          ? switch (batchResult.stopReason) {
              SimulationStopReason.reachedTarget =>
                '${l10n.calendar_stopReason_reachedTarget} · ${l10n.calendar_daysSimulated(batchResult.daysSimulated)}',
              SimulationStopReason.cancelled =>
                '${l10n.calendar_stopReason_cancelled} · ${l10n.calendar_daysSimulated(batchResult.daysSimulated)}',
              SimulationStopReason.noSave =>
                '${l10n.calendar_stopReason_noSave} · ${l10n.calendar_daysSimulated(batchResult.daysSimulated)}',
              SimulationStopReason.playerMatch =>
                '${l10n.calendar_stopReason_reachedTarget} · ${l10n.calendar_daysSimulated(batchResult.daysSimulated)}',
              SimulationStopReason.urgent =>
                '${l10n.calendar_stopReason_reachedTarget} · ${l10n.calendar_daysSimulated(batchResult.daysSimulated)}',
              SimulationStopReason.event =>
                '${l10n.calendar_stopReason_reachedTarget} · ${l10n.calendar_daysSimulated(batchResult.daysSimulated)}',
            }
          : null);
  if (resultMessage == null && !hasPendingUrgent) return;

  void openInbox() {
    if (!context.mounted) return;
    ref.read(shellTabIndexProvider.notifier).state = 5;
    final router = GoRouter.maybeOf(context);
    if (router != null && router.state.matchedLocation != '/game') {
      router.go('/game', extra: 5);
    }
  }

  final content = <Widget>[
    if (resultMessage != null) Text(resultMessage),
    if (hasPendingUrgent) ...[
      if (resultMessage != null) const SizedBox(height: 4),
      Text(l10n.simulation_pendingUrgentNotice),
    ],
  ];
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content,
      ),
      action: hasPendingUrgent
          ? SnackBarAction(
              label: l10n.simulation_openInbox,
              onPressed: openInbox,
            )
          : null,
    ),
  );
}

/// "Przejdź do {event}": dociąga kalendarz do dnia eventu bez jego
/// wykonania, potem — jeśli istnieje dedykowany ekran — nawiguje do niego.
Future<void> _goToEvent(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  UpcomingAction action, {
  bool openRoute = true,
}) async {
  final result = await _runBatchDialog(
    context,
    ref,
    l10n,
    ref.read(gameControllerProvider.notifier).simulateToEvent,
  );
  if (!context.mounted) return;
  _refreshCalendarCursor(ref);

  final canOpenEventResult =
      result.stopReason == SimulationStopReason.event ||
      result.stopReason == SimulationStopReason.playerMatch;
  if (!canOpenEventResult) {
    _presentHomeBatchResult(context, ref, l10n, batchResult: result);
    return;
  }

  // "Go to" intentionally does not open a player match. It still presents a
  // pending urgent CTA when the batch reached an ordinary result.
  if (!openRoute || result.stopReason == SimulationStopReason.playerMatch) {
    _presentHomeBatchResult(
      context,
      ref,
      l10n,
      batchResult: result,
      showBatchResult: false,
    );
    return;
  }

  if (action.calendarEventId == CalendarEventId.scoutReport) {
    _presentHomeBatchResult(
      context,
      ref,
      l10n,
      batchResult: result,
      showBatchResult: false,
    );
    await ref
        .read(gameControllerProvider.notifier)
        .runEventAtCurrentDay(CalendarEventId.scoutReport);
    if (!context.mounted) return;
    context.push('/game/prospects?watchlist=true&combine=true');
    return;
  }

  final route = _routeForEvent(action.calendarEventId!);
  if (route != null) {
    _presentHomeBatchResult(
      context,
      ref,
      l10n,
      batchResult: result,
      showBatchResult: false,
    );
    context.push(route);
    return;
  }

  _presentHomeBatchResult(context, ref, l10n, batchResult: result);
}

/// "Symuluj {event}": dociąga kalendarz do eventu i kończy go przez wspólny
/// pipeline dnia. Po ostatnim evencie data przesuwa się automatycznie.
Future<void> _simulateEvent(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  UpcomingAction action,
) async {
  final result = await _runBatchDialog(
    context,
    ref,
    l10n,
    ref.read(gameControllerProvider.notifier).simulateToEvent,
  );
  if (!context.mounted) return;
  _refreshCalendarCursor(ref);

  if (result.stopReason != SimulationStopReason.event) {
    _presentHomeBatchResult(context, ref, l10n, batchResult: result);
    return;
  }

  final controller = ref.read(gameControllerProvider.notifier);
  final dayResult = await controller.completeEventAtCurrentDay(
    action.calendarEventId!,
  );
  if (!context.mounted) return;
  _refreshCalendarCursor(ref);

  if (dayResult?.playerMatch != null) {
    _presentHomeBatchResult(
      context,
      ref,
      l10n,
      batchResult: result,
      dayResult: dayResult,
      showBatchResult: false,
      playerMatchTakesPriority: true,
    );
    context.push('/game/match', extra: dayResult!.playerMatch);
    return;
  }

  final label = action.calendarEventId == null
      ? action.id
      : calendarEventLabel(context, action.calendarEventId!) ?? action.id;
  _presentHomeBatchResult(
    context,
    ref,
    l10n,
    batchResult: result,
    dayResult: dayResult,
    message: l10n.home_actionExecuted(label),
    showBatchResult: false,
  );
}

/// "Symuluj mecz": dociąga kalendarz do dnia meczu gracza i otwiera
/// `MatchdayScreen`. Nie rozgrywa meczu samodzielnie.
Future<void> _simulateMatch(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) async {
  final result = await _runBatchDialog(
    context,
    ref,
    l10n,
    ref.read(gameControllerProvider.notifier).simulateToEvent,
  );
  if (!context.mounted) return;
  _refreshCalendarCursor(ref);

  final playerMatch = result.lastResult?.playerMatch;
  if (playerMatch != null) {
    _presentHomeBatchResult(
      context,
      ref,
      l10n,
      batchResult: result,
      showBatchResult: false,
      playerMatchTakesPriority: true,
    );
    context.push('/game/match', extra: playerMatch);
    return;
  }
  _presentHomeBatchResult(context, ref, l10n, batchResult: result);
}

bool _isGoToOnlyEvent(CalendarEventId id) {
  switch (id) {
    case CalendarEventId.lottery:
    case CalendarEventId.draft:
    case CalendarEventId.freeAgencyOpen:
    case CalendarEventId.nextClassGeneration:
    case CalendarEventId.scoutReport:
      return true;
    case CalendarEventId.staffGrowth:
      return false;
    default:
      return false;
  }
}

bool _isSimulateOnlyEvent(CalendarEventId id) {
  switch (id) {
    case CalendarEventId.combine:
    case CalendarEventId.finalMock:
    case CalendarEventId.staffGrowth:
      return true;
    default:
      return false;
  }
}

Future<void> _advanceOneHour(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) async {
  final controller = ref.read(gameControllerProvider.notifier);
  final result = await controller.advanceOneHour();
  if (!context.mounted) return;
  _refreshCalendarCursor(ref);
  if (result == null &&
      ref.read(activeLeagueProvider)?.inbox.pendingUrgent.isNotEmpty == true) {
    ref.read(shellTabIndexProvider.notifier).state = 5;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.calendar_urgentMessage)));
  }
}

Future<void> _simulateDay(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) async {
  final controller = ref.read(gameControllerProvider.notifier);
  final result = await controller.simulateDay();
  if (!context.mounted) return;
  _refreshCalendarCursor(ref);

  if (result?.playerMatch != null) {
    context.push('/game/match', extra: result!.playerMatch);
    return;
  }
  if (result?.pauseForUrgent ?? false) {
    ref.read(shellTabIndexProvider.notifier).state = 5;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.calendar_urgentMessage)));
  }
}
