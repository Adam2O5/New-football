import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/shell_screen.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
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

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                ? ' ${pm.result!.homeGoals}:${pm.result!.awayGoals}'
                : '';
            playerMatchLabel = '$home – $away$score';
          }
        }
      }

      final eventLabels = <String>[];
      for (final e in calendar.eventsOn(w, d)) {
        if (e.id == 'draft') {
          final draft = league.currentSeason.draftState;
          if (draft != null) {
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

    Future<void> simulateToDate(int targetWeek, int targetDay) async {
      await _runBatch(
        context,
        ref,
        l10n,
        () => ref
            .read(gameControllerProvider.notifier)
            .simulateToDate(targetWeek, targetDay),
      );
      if (!context.mounted) return;
      final nextLeague = ref.read(activeLeagueProvider);
      if (nextLeague == null) return;
      ref.read(calendarCursorMonthProvider.notifier).state = _monthForInGame(
        nextLeague,
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
      body: ListView(
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
                                    .read(calendarCursorMonthProvider.notifier)
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
                                    .read(calendarCursorMonthProvider.notifier)
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
                  GridView.builder(
                    itemCount: totalCells,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 0.85,
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

                      return Opacity(
                        opacity: isInMonth ? 1.0 : 0.35,
                        child: InkWell(
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
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            margin: const EdgeInsets.all(3),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isToday
                                  ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                        .withValues(alpha: 0.45)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected && !isToday
                                  ? Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      width: 1.5,
                                    )
                                  : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${date.day}',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: isEnabled
                                            ? null
                                            : Theme.of(context).disabledColor,
                                        fontWeight: isToday
                                            ? FontWeight.bold
                                            : null,
                                      ),
                                ),
                                if (info != null) ...[
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (info.playerMatchLabel != null)
                                        Tooltip(
                                          message: info.playerMatchLabel!,
                                          child: const Icon(
                                            Icons.sports_soccer,
                                            size: 12,
                                            color: Colors.greenAccent,
                                          ),
                                        )
                                      else if (info.matchCount > 0)
                                        Tooltip(
                                          message: '${info.matchCount} matches',
                                          child: const Icon(
                                            Icons.sports_soccer,
                                            size: 12,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      if (info.eventLabels.isNotEmpty) ...[
                                        if (info.playerMatchLabel != null ||
                                            info.matchCount > 0)
                                          const SizedBox(width: 2),
                                        Tooltip(
                                          message: info.eventLabels.join('\n'),
                                          child: const Icon(
                                            Icons.event_available_outlined,
                                            size: 12,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: canSimulateSelectedDay
                          ? () => simulateToDate(
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
    );
  }
}

// Legacy fast-forward sheet/dialog removed:
// simulation to dates is handled via the "simulate to date" button below
// the calendar grid, using the currently selected day.

Future<void> _runBatch(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  Future Function() run,
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

  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pop();

  if (result.lastResult?.playerMatch != null) {
    context.push('/game/match', extra: result.lastResult!.playerMatch);
    return;
  }
  if (result.stopReason == SimulationStopReason.urgent) {
    // Tabs: Home(0) Calendar(1) Squad(2) Standings(3) Finance(4) Inbox(5).
    ref.read(shellTabIndexProvider.notifier).state = 5;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.calendar_urgentMessage)));
    return;
  }
  if (result.stopReason == SimulationStopReason.event) {
    if (result.eventId == 'draft') {
      context.push('/game/draft');
      return;
    }
    // Inne eventy informacyjne/automatyczne nie powinny tu trafić, bo
    // simulateToEvent()/simulateToDate() same je rozróżniają — ale
    // zachowujemy fallback na wypadek nieoczekiwanego stopu.
  }
  final reasonLabel = switch (result.stopReason as SimulationStopReason) {
    SimulationStopReason.reachedTarget =>
      l10n.calendar_stopReason_reachedTarget,
    SimulationStopReason.cancelled => l10n.calendar_stopReason_cancelled,
    SimulationStopReason.noSave => l10n.calendar_stopReason_noSave,
    SimulationStopReason.playerMatch => l10n.calendar_stopReason_reachedTarget,
    SimulationStopReason.urgent => l10n.calendar_stopReason_reachedTarget,
    SimulationStopReason.event => l10n.calendar_stopReason_draftPick,
  };
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '$reasonLabel · ${l10n.calendar_daysSimulated(result.daysSimulated)}',
      ),
    ),
  );
}
