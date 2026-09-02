import 'dart:async';

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
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

final calendarCursorMonthProvider = StateProvider<DateTime?>((ref) => null);

/// Currently selected day in the calendar grid, driving the info panel.
final calendarSelectedDayProvider = StateProvider<DateTime?>((ref) => null);

DateTime _week1StartForSeason(int seasonYear) {
  // Docs: week #1 starts at the first full Mon–Sun week inside August.
  DateTime d = DateTime(seasonYear, 8, 1);
  while (d.weekday != DateTime.monday) {
    d = d.add(const Duration(days: 1));
  }
  while (d.month != 8 || d.add(const Duration(days: 6)).month != 8) {
    d = d.add(const Duration(days: 7));
  }
  return DateTime(d.year, d.month, d.day);
}

DateTime _dateForInGameWeekDay(int seasonYear, int week, int day) {
  final week1Start = _week1StartForSeason(seasonYear);
  final offsetDays = (week - 1) * 7 + (day - 1);
  return week1Start.add(Duration(days: offsetDays));
}

({int week, int day})? _inGameWeekDayForDate(DateTime date, int seasonYear) {
  final week1Start = _week1StartForSeason(seasonYear);
  final diffDays = date.difference(week1Start).inDays;
  if (diffDays < 0) return null;
  final week = diffDays ~/ 7 + 1;
  final day = diffDays % 7 + 1;
  final endWeek = BalanceConfig.defaults.calendar.freeAgencyWeek;
  if (week < 1 || week > endWeek) return null;
  return (week: week, day: day);
}

DateTime _monthForInGame(LeagueState league) {
  final d = _dateForInGameWeekDay(
    league.currentSeason.year,
    league.currentWeek,
    league.currentDay,
  );
  return DateTime(d.year, d.month);
}

/// Returns a stable logical extent for each calendar row.
///
/// The width-derived value preserves the old visual ratio, while the
/// height-derived cap keeps a short logical viewport from handing a tile an
/// extent that cannot fit its available row space. MediaQuery and
/// BoxConstraints are both logical Flutter units; physical pixel ratio is
/// deliberately not part of this calculation.
double _calendarTileExtent({
  required double logicalWidth,
  required double logicalHeight,
  required int rowCount,
}) {
  final safeWidth = logicalWidth.isFinite && logicalWidth > 0
      ? logicalWidth
      : 48.0 * 7;
  final tileWidth = safeWidth / 7;
  var extent = tileWidth / 0.85;

  if (logicalHeight.isFinite && logicalHeight > 0 && rowCount > 0) {
    final heightBasedExtent = logicalHeight / rowCount;
    if (heightBasedExtent < extent) extent = heightBasedExtent;
  }

  return extent.clamp(1.0, double.infinity).toDouble();
}

/// Formats a final score. Extra-time goals are already folded into
/// [MatchResult.homeGoals]/[awayGoals] by `_resolvePostseasonTiebreak`, so a
/// game decided in extra time never reaches here tied. A shootout, however,
/// leaves regulation+ET score tied on purpose (penalties aren't goals), so
/// that case needs the shootout score appended — otherwise a knockout draw
/// would render as a plain, impossible "1:1".
String _formatMatchScore(MatchResult result) {
  final base = '${result.homeGoals}:${result.awayGoals}';
  if (!result.wentToShootout) return base;
  return '$base (${result.shootoutHomeGoals}:${result.shootoutAwayGoals})';
}

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  static const _progressOverlayKey = ValueKey<String>(
    'calendar-batch-progress-overlay',
  );
  static const _cancelButtonKey = ValueKey<String>('calendar-batch-cancel');
  static const _feedbackHostKey = ValueKey<String>(
    'calendar-day-result-feedback-host',
  );
  static const _feedbackDuration = Duration(milliseconds: 500);

  CalendarDaySimulationFeedback? _feedback;
  Timer? _feedbackDismissTimer;
  Completer<void>? _feedbackDismissalCompleter;
  GameController? _activeController;
  var _runId = 0;
  var _feedbackGeneration = 0;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    if (league == null) {
      return Center(child: Text(l10n.calendar_noLeague));
    }

    final calendar = ref.watch(calendarServiceProvider);
    final week = league.currentWeek;
    final day = league.currentDay;
    final seasonYear = league.currentSeason.year;

    final currentMonth = _monthForInGame(league);
    final cursorMonthValue = ref.watch(calendarCursorMonthProvider);
    if (cursorMonthValue == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ref.read(calendarCursorMonthProvider.notifier).state = currentMonth;
      });
    }
    final month = cursorMonthValue ?? currentMonth;
    final firstSeasonYear = league.history.isNotEmpty
        ? league.history.map((h) => h.year).reduce((a, b) => a < b ? a : b)
        : seasonYear;
    final minMonthDate = _week1StartForSeason(firstSeasonYear);
    final minMonth = DateTime(minMonthDate.year, minMonthDate.month);
    final maxMonth = DateTime(currentMonth.year, currentMonth.month + 12);

    final playerId = league.playerTeamId;
    final currentWeek = week;
    final currentDay = day;

    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = monthEnd.day;
    final leading = monthStart.weekday - 1; // Mon=1 → leading 0
    final totalCells = ((leading + daysInMonth + 6) ~/ 7) * 7;
    final gridStart = monthStart.subtract(Duration(days: leading));

    final teamNameById = {for (final t in league.teams) t.id: t.name};
    final matchesByRound = <int, List<ScheduledMatch>>{};
    for (final m in league.currentSeason.schedule) {
      matchesByRound.putIfAbsent(m.round, () => []).add(m);
    }

    ({
      int week,
      int day,
      bool isPast,
      int matchCount,
      int? round,
      String? playerMatchLabel,
      ScheduledMatch? playerMatch,
      List<String> eventLabels,
    })?
    dayInfo(DateTime date) {
      final mapped = _inGameWeekDayForDate(date, seasonYear);
      if (mapped == null) return null;
      final w = mapped.week;
      final d = mapped.day;
      final isPast = w < currentWeek || (w == currentWeek && d < currentDay);

      var matchCount = 0;
      int? round;
      String? playerMatchLabel;
      ScheduledMatch? pm;

      final slot = calendar.regularSeasonSlotForDay(d);
      final isActualMatchDay = slot != null && calendar.isActualMatchDay(w, d);

      if (calendar.isRegularSeasonWeek(w) && slot != null && isActualMatchDay) {
        round = scheduleRoundForWeekSlot(w, slot);
        final fixtures = matchesByRound[round] ?? const [];
        matchCount = fixtures.length;

        if (playerId != null) {
          for (final f in fixtures) {
            if (f.homeTeamId == playerId || f.awayTeamId == playerId) {
              pm = f;
              break;
            }
          }
          if (pm != null) {
            final home = teamNameById[pm.homeTeamId] ?? pm.homeTeamId;
            final away = teamNameById[pm.awayTeamId] ?? pm.awayTeamId;
            final score = pm.result != null
                ? ' ${_formatMatchScore(pm.result!)}'
                : '';
            playerMatchLabel = '$home – $away$score';
          }
        }
      } else {
        // Play-in/playoff fixtures aren't part of `schedule` — they live in
        // `postseasonFixtures`, written eagerly as soon as each pairing is
        // known (see `game_calendar.md`), so — unlike the regular season
        // branch above — no "today or earlier" gating is needed here: a
        // fixture simply isn't in the list yet if it isn't known yet.
        //
        // Unlike the regular season (where every team plays every match
        // day), most teams aren't in the play-in/playoff at all — so, unless
        // the player's own team has a fixture today, no icon is shown.
        if (playerId != null) {
          for (final f in league.currentSeason.postseasonFixtures) {
            if (f.week != w || f.day != d) continue;
            if (f.homeTeamId == playerId || f.awayTeamId == playerId) {
              pm = f;
              break;
            }
          }
          if (pm != null) {
            matchCount = 1;
            final home =
                pm.homePlaceholderLabel ??
                teamNameById[pm.homeTeamId] ??
                pm.homeTeamId;
            final away =
                pm.awayPlaceholderLabel ??
                teamNameById[pm.awayTeamId] ??
                pm.awayTeamId;
            final score = pm.result != null
                ? ' ${_formatMatchScore(pm.result!)}'
                : '';
            playerMatchLabel = '$home – $away$score';
          }
        }
      }

      final eventLabels = <String>[];
      for (final e in calendar.eventsOn(w, d)) {
        if (e.id == CalendarEventId.draft) {
          final draft = league.currentSeason.draftState;
          if (draft != null && draft.order.isNotEmpty) {
            final total = draft.order.length;
            final currentPick = (draft.currentPickIndex + 1).clamp(1, total);
            eventLabels.add(
              '${l10n.calendar_event_draft} · ${l10n.calendar_pickProgress(currentPick, total)}',
            );
          } else {
            eventLabels.add(l10n.calendar_event_draft);
          }
          continue;
        }
        final label = calendarEventLabel(context, e.id);
        if (label != null) eventLabels.add(label);
      }

      return (
        week: w,
        day: d,
        isPast: isPast,
        matchCount: matchCount,
        round: round,
        playerMatchLabel: playerMatchLabel,
        playerMatch: pm,
        eventLabels: eventLabels,
      );
    }

    final selectedDay =
        ref.watch(calendarSelectedDayProvider) ??
        _dateForInGameWeekDay(seasonYear, currentWeek, currentDay);
    final selectedInfo = dayInfo(selectedDay);

    String selectedDayBody;
    final selectedMatch = selectedInfo?.playerMatch;
    if (selectedMatch != null) {
      final homeName =
          teamNameById[selectedMatch.homeTeamId] ?? selectedMatch.homeTeamId;
      final awayName =
          teamNameById[selectedMatch.awayTeamId] ?? selectedMatch.awayTeamId;
      final isPlayerHome = selectedMatch.homeTeamId == playerId;
      final opponentName = isPlayerHome ? awayName : homeName;
      if (selectedMatch.result != null) {
        selectedDayBody = l10n.calendar_selectedDay_matchResult(
          homeName,
          awayName,
          selectedMatch.result!.homeGoals,
          selectedMatch.result!.awayGoals,
        );
      } else {
        selectedDayBody = l10n.calendar_selectedDay_matchUpcoming(opponentName);
      }
    } else if (selectedInfo != null && selectedInfo.eventLabels.isNotEmpty) {
      selectedDayBody = l10n.calendar_selectedDay_offseasonEvent(
        selectedInfo.eventLabels.join(', '),
      );
    } else {
      selectedDayBody = l10n.calendar_selectedDay_noEvent;
    }

    final canSimulateSelectedDay = selectedInfo != null && !selectedInfo.isPast;

    return Scaffold(
      body: Stack(
        children: [
          ScreenBackground(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: month.isAfter(minMonth)
                                  ? () {
                                      ref
                                          .read(
                                            calendarCursorMonthProvider
                                                .notifier,
                                          )
                                          .state = DateTime(
                                        month.year,
                                        month.month - 1,
                                        1,
                                      );
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                            ),
                            Expanded(
                              child: Text(
                                MaterialLocalizations.of(
                                  context,
                                ).formatMonthYear(month),
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              onPressed: month.isBefore(maxMonth)
                                  ? () {
                                      ref
                                          .read(
                                            calendarCursorMonthProvider
                                                .notifier,
                                          )
                                          .state = DateTime(
                                        month.year,
                                        month.month + 1,
                                        1,
                                      );
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${l10n.calendar_selectedDay_title} · ${dayName(context, selectedDay.weekday)} ${selectedDay.day}.${selectedDay.month.toString().padLeft(2, '0')}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                selectedDayBody,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, gridConstraints) {
                            // Grid dimensions are logical Flutter constraints. Do
                            // not use devicePixelRatio here: the seven-column
                            // geometry must be identical at every pixel density.
                            final logicalWidth = gridConstraints.hasBoundedWidth
                                ? gridConstraints.maxWidth
                                : MediaQuery.sizeOf(context).width;
                            final logicalHeight =
                                gridConstraints.hasBoundedHeight
                                ? gridConstraints.maxHeight
                                : MediaQuery.sizeOf(context).height;
                            final rowCount = (totalCells + 6) ~/ 7;
                            final tileExtent = _calendarTileExtent(
                              logicalWidth: logicalWidth,
                              logicalHeight: logicalHeight,
                              rowCount: rowCount,
                            );

                            return GridView.builder(
                              itemCount: totalCells,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 7,
                                    mainAxisExtent: tileExtent,
                                  ),
                              itemBuilder: (context, i) {
                                final date = gridStart.add(Duration(days: i));
                                final info = dayInfo(date);
                                final isInMonth = date.month == month.month;
                                final isEnabled =
                                    info != null && !info.isPast && isInMonth;
                                final isToday =
                                    info != null &&
                                    info.week == currentWeek &&
                                    info.day == currentDay;
                                final isSelected =
                                    info != null &&
                                    date.year == selectedDay.year &&
                                    date.month == selectedDay.month &&
                                    date.day == selectedDay.day;

                                return CalendarDayTile(
                                  key: ValueKey<DateTime>(date),
                                  date: date,
                                  isInMonth: isInMonth,
                                  isEnabled: isEnabled,
                                  isToday: isToday,
                                  isSelected: isSelected,
                                  matchCount: info?.matchCount ?? 0,
                                  matchConfirmed:
                                      info?.playerMatch?.confirmed ?? true,
                                  playerMatchLabel: info?.playerMatchLabel,
                                  eventLabels: info?.eventLabels ?? const [],
                                  onTap: info != null
                                      ? () {
                                          ref
                                                  .read(
                                                    calendarSelectedDayProvider
                                                        .notifier,
                                                  )
                                                  .state =
                                              date;
                                        }
                                      : null,
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: canSimulateSelectedDay && !_isSimulating
                                ? () => _simulateToDate(
                                    selectedInfo.week,
                                    selectedInfo.day,
                                  )
                                : null,
                            icon: const Icon(Icons.fast_forward),
                            label: Text(l10n.calendar_simulateUntilDate),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // The progress host is inserted before the feedback host. The
          // feedback is intentionally above the dimming layer, while
          // IgnorePointer keeps it non-blocking and leaves Cancel usable.
          if (_isSimulating)
            Positioned.fill(
              key: _progressOverlayKey,
              child: Stack(
                children: [
                  const ModalBarrier(dismissible: false, color: Colors.black54),
                  Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Flexible(child: Text(l10n.calendar_simulating)),
                              const SizedBox(width: 8),
                              TextButton(
                                key: _cancelButtonKey,
                                onPressed: _activeController?.cancelSimulation,
                                child: Text(l10n.calendar_cancel),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_feedback != null && _feedback!.results.isNotEmpty)
            Positioned.fill(
              key: _feedbackHostKey,
              child: IgnorePointer(
                child: CalendarDayResultPopup(
                  feedback: _feedback!,
                  teamId: playerId,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
