import 'dart:async';

import 'package:new_football/core/services/calendar_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/models/calendar_simulation_feedback.dart';
import 'package:new_football/app/services/calendar_simulation_pacer.dart';
import 'package:new_football/app/widgets/calendar_day_result_popup.dart';
import 'package:new_football/app/widgets/calendar_day_tile.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/shell_screen.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

part 'calendar_screen_helpers.dart';
part 'calendar_screen_body.dart';

final calendarCursorMonthProvider = StateProvider<DateTime?>((ref) => null);

/// Currently selected day in the calendar grid, driving the info panel.
final calendarSelectedDayProvider = StateProvider<DateTime?>((ref) => null);

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with _CalendarScreenShared, _CalendarScreenBody {
  static const _feedbackDuration = Duration(milliseconds: 500);

  @override
  CalendarDaySimulationFeedback? _feedback;
  Timer? _feedbackDismissTimer;
  Completer<void>? _feedbackDismissalCompleter;
  @override
  GameController? _activeController;
  var _runId = 0;
  var _feedbackGeneration = 0;
  @override
  var _isSimulating = false;

  @override
  void dispose() {
    _cancelFeedbackTimer();
    if (_isSimulating) {
      _activeController?.cancelSimulation();
    }
    _activeController = null;
    super.dispose();
  }

  void _cancelFeedbackTimer() {
    _feedbackDismissTimer?.cancel();
    _feedbackDismissTimer = null;
    final dismissal = _feedbackDismissalCompleter;
    _feedbackDismissalCompleter = null;
    if (dismissal != null && !dismissal.isCompleted) dismissal.complete();
    _feedbackGeneration++;
  }

  int _beginCalendarRun() {
    // The button is disabled while a run is active, but explicitly invalidating
    // the old controller session here also protects programmatic restarts.
    if (_isSimulating) _activeController?.cancelSimulation();
    _cancelFeedbackTimer();
    final runId = ++_runId;
    if (mounted) {
      setState(() {
        _feedback = null;
        _isSimulating = true;
      });
    }
    return runId;
  }

  bool _isCurrentRun(int runId) => mounted && runId == _runId;

  Future<void> _publishCalendarFeedback(
    int runId,
    CalendarDaySimulationFeedback feedback,
  ) async {
    if (!_isCurrentRun(runId)) return;

    _cancelFeedbackTimer();
    if (feedback.results.isEmpty) {
      if (_feedback != null) {
        setState(() => _feedback = null);
      }
      return;
    }

    final generation = _feedbackGeneration;
    final dismissal = Completer<void>();
    _feedbackDismissalCompleter = dismissal;
    setState(() => _feedback = feedback);
    _feedbackDismissTimer = Timer(_feedbackDuration, () {
      if (!_isCurrentRun(runId) || generation != _feedbackGeneration) return;
      _feedbackDismissTimer = null;
      if (_feedback != null) setState(() => _feedback = null);
      if (identical(_feedbackDismissalCompleter, dismissal)) {
        _feedbackDismissalCompleter = null;
      }
      if (!dismissal.isCompleted) dismissal.complete();
    });

    await dismissal.future;
  }

  void _clearTransientUi({required int runId}) {
    if (!_isCurrentRun(runId)) return;
    _cancelFeedbackTimer();
    setState(() {
      _feedback = null;
      _isSimulating = false;
    });
  }

  void _openInbox() {
    if (!mounted) return;
    ref.read(shellTabIndexProvider.notifier).state = 5;

    // CalendarScreen normally lives inside ShellScreen, where changing the
    // tab is sufficient. If a result action is still visible after a pushed
    // game route, return to the shell so the selected Inbox is actually
    // visible instead of only updating the background tab.
    final router = GoRouter.maybeOf(context);
    if (router != null && router.state.matchedLocation != '/game') {
      router.go('/game', extra: 5);
    }
  }

  void _showPendingUrgentSnackBar(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.simulation_pendingUrgentNotice),
        action: SnackBarAction(
          label: l10n.simulation_openInbox,
          onPressed: _openInbox,
        ),
      ),
    );
  }

  Future<void> _showDraftSimulationBlocked(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.calendar_event_draft),
        content: Text(l10n.calendar_stopReason_draftPick),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> _simulateToDate(int targetWeek, int targetDay) async {
    final runId = _beginCalendarRun();
    final result = await _runBatch(
      runId,
      targetWeek: targetWeek,
      targetDay: targetDay,
    );
    if (!_isCurrentRun(runId) || result == null) return;

    // Keep the existing cursor refresh after the controller has committed its
    // final state, including target, cancellation, and stop-at-event results.
    final nextLeague = ref.read(activeLeagueProvider);
    if (nextLeague == null) return;
    ref.read(calendarCursorMonthProvider.notifier).state = _monthForInGame(
      nextLeague,
    );
  }

  Future<BatchSimulationResult?> _runBatch(
    int runId, {
    required int targetWeek,
    required int targetDay,
  }) async {
    if (!_isCurrentRun(runId)) return null;

    final controller = ref.read(gameControllerProvider.notifier);
    _activeController = controller;
    final pacer = CalendarSimulationPacer();
    final pacingCyclesBeforeRun = pacer.completedCycles;
    int? controllerRunId;
    int? lastSequence;
    ({int week, int day})? lastDate;

    Future<void> observe(CalendarDaySimulationFeedback feedback) async {
      if (!_isCurrentRun(runId)) return;
      controllerRunId ??= feedback.runId;
      if (feedback.runId != controllerRunId) return;
      if (lastSequence != null && feedback.sequence <= lastSequence!) return;
      if (lastDate != null &&
          feedback.week == lastDate!.week &&
          feedback.day == lastDate!.day) {
        return;
      }
      lastSequence = feedback.sequence;
      lastDate = (week: feedback.week, day: feedback.day);
      await _publishCalendarFeedback(runId, feedback);
    }

    try {
      final result = await controller.simulateToDate(
        targetWeek,
        targetDay,
        observer: observe,
        pacer: pacer,
      );
      if (!_isCurrentRun(runId)) return null;

      // The controller pacer targets the interval between day starts, while
      // this route owns the popup's visual dismissal cycle. If the domain step
      // itself consumed the full interval, the controller can return while
      // the popup timer is still active. Keep the popup visible until that
      // real cycle closes, but do not wait for test doubles that never call
      // the injected pacer.
      final dismissal = _feedbackDismissalCompleter;
      if (pacer.completedCycles > pacingCyclesBeforeRun &&
          _feedback?.results.isNotEmpty == true &&
          dismissal != null) {
        await dismissal.future;
        if (!_isCurrentRun(runId)) return null;
      }

      // The result/popup host is route-owned. Clear it before removing the
      // progress layer and before any snackbar or navigation can run.
      _clearTransientUi(runId: runId);
      _activeController = null;
      await _handleBatchResult(runId, result);
      return result;
    } catch (error, stackTrace) {
      if (_isCurrentRun(runId)) _clearTransientUi(runId: runId);
      if (identical(_activeController, controller)) _activeController = null;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'calendar_screen',
          context: ErrorDescription('while running calendar simulation'),
        ),
      );
      return null;
    } finally {
      if (identical(_activeController, controller)) _activeController = null;
    }
  }

  Future<void> _handleBatchResult(
    int runId,
    BatchSimulationResult result,
  ) async {
    if (!_isCurrentRun(runId)) return;
    final context = this.context;
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final hasPendingUrgent =
        ref.read(activeLeagueProvider)?.inbox.pendingUrgent.isNotEmpty == true;

    if (result.lastResult?.playerMatch != null) {
      if (hasPendingUrgent) {
        _showPendingUrgentSnackBar(context, l10n);
      }
      context.push('/game/match', extra: result.lastResult!.playerMatch);
      return;
    }
    if (result.stopReason == SimulationStopReason.urgent) {
      // Tabs: Home(0) Calendar(1) Squad(2) Standings(3) Other(4) Inbox(5).
      _openInbox();
      _showPendingUrgentSnackBar(context, l10n);
      return;
    }
    if (result.stopReason == SimulationStopReason.event) {
      if (result.eventId == CalendarEventId.draft) {
        if (hasPendingUrgent) {
          _showPendingUrgentSnackBar(context, l10n);
        }
        await _showDraftSimulationBlocked(context, l10n);
        if (!_isCurrentRun(runId) || !context.mounted) return;
        context.push('/game/draft');
        return;
      }
      final route = switch (result.eventId) {
        CalendarEventId.lottery => '/game/lottery',
        CalendarEventId.scoutReport =>
          '/game/prospects?watchlist=true&combine=true',
        CalendarEventId.freeAgencyOpen => '/game/contracts',
        _ => null,
      };
      if (route != null) {
        if (hasPendingUrgent) {
          _showPendingUrgentSnackBar(context, l10n);
        }
        if (result.eventId == CalendarEventId.scoutReport) {
          await ref
              .read(gameControllerProvider.notifier)
              .runEventAtCurrentDay(CalendarEventId.scoutReport);
          if (!_isCurrentRun(runId) || !context.mounted) return;
        }
        context.push(route);
        return;
      }
      // Other informational/automatic events should not reach this path, but
      // retain the existing fallback snackbar for an unexpected stop.
    }
    final reasonLabel = switch (result.stopReason) {
      SimulationStopReason.reachedTarget =>
        l10n.calendar_stopReason_reachedTarget,
      SimulationStopReason.cancelled => l10n.calendar_stopReason_cancelled,
      SimulationStopReason.noSave => l10n.calendar_stopReason_noSave,
      SimulationStopReason.playerMatch =>
        l10n.calendar_stopReason_reachedTarget,
      SimulationStopReason.urgent => l10n.calendar_stopReason_reachedTarget,
      SimulationStopReason.event => l10n.calendar_stopReason_draftPick,
    };
    final ordinaryResultMessage =
        '$reasonLabel · ${l10n.calendar_daysSimulated(result.daysSimulated)}';
    final content = hasPendingUrgent
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ordinaryResultMessage),
              const SizedBox(height: 4),
              Text(l10n.simulation_pendingUrgentNotice),
            ],
          )
        : Text(ordinaryResultMessage);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: content,
        action: hasPendingUrgent
            ? SnackBarAction(
                label: l10n.simulation_openInbox,
                onPressed: _openInbox,
              )
            : null,
      ),
    );
  }
}

mixin _CalendarScreenShared on ConsumerState<CalendarScreen> {
  CalendarDaySimulationFeedback? get _feedback;

  GameController? get _activeController;

  bool get _isSimulating;

  Future<void> _simulateToDate(int targetWeek, int targetDay);
}
