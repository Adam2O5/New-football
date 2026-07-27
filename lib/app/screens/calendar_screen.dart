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

    final playerId = league.playerTeamId;
    final currentWeek = week;
    final currentDay = day;

    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = monthEnd.day;
    final leading = monthStart.weekday - 1; // Mon=1 → leading 0
    final totalCells = ((leading + daysInMonth + 6) ~/ 7) * 7;
    final gridStart = monthStart.subtract(Duration(days: leading));

    final calCfg = calendar.balance.calendar;
    final teamNameById = {for (final t in league.teams) t.id: t.name};
    final matchesByRound = <int, List<ScheduledMatch>>{};
    for (final m in league.currentSeason.schedule) {
      matchesByRound.putIfAbsent(m.round, () => <ScheduledMatch>[]).add(m);
    }

    ({int week, int day, bool isPast, int matchCount, String? playerMatchLabel, List<String> eventLabels})?
        dayInfo(DateTime date) {
      final mapped = _inGameWeekDayForDate(date, seasonYear);
      if (mapped == null) return null;
      final w = mapped.week;
      final d = mapped.day;
      final isPast = w < currentWeek || (w == currentWeek && d < currentDay);

      var matchCount = 0;
      String? playerMatchLabel;

      final slot = calendar.regularSeasonSlotForDay(d);
      if (calendar.isRegularSeasonWeek(w) && slot != null) {
        final round = scheduleRoundForWeekSlot(w, slot);
        final fixtures = matchesByRound[round] ?? const [];
        matchCount = fixtures.length;

        if (playerId != null) {
          ScheduledMatch? pm;
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
      if (calendar.isTradeDeadline(w, d)) {
        eventLabels.add(l10n.calendar_event_tradeDeadline);
      }

      if (w == calCfg.awardsWeek && d == 1) {
        eventLabels.add(l10n.calendar_event_awards);
        eventLabels.add(l10n.calendar_event_retirements);
        eventLabels.add(l10n.calendar_event_draftLottery);
      }
      if (w == calCfg.awardsWeek + 1 && d == 1) {
        eventLabels.add(l10n.calendar_event_scoutReport);
      }
      if (w == calCfg.awardsWeek + 1 && d == 3) {
        eventLabels.add(l10n.calendar_event_combine);
      }
      if (w == calCfg.awardsWeek + 1 && d == 5) {
        eventLabels.add(l10n.calendar_event_mockDraft);
      }
      if (w == calCfg.draftWeek && d == 1) {
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
      }
      if (w == calCfg.freeAgencyWeek && d == 1) {
        eventLabels.add(l10n.calendar_event_freeAgency);
      }

      return (
        week: w,
        day: d,
        isPast: isPast,
        matchCount: matchCount,
        playerMatchLabel: playerMatchLabel,
        eventLabels: eventLabels,
      );
    }

    final stripItems = <({
      DateTime date,
      int week,
      int day,
      String? playerMatchLabel,
      List<String> eventLabels,
    })>[];
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      final info = dayInfo(date);
      if (info == null || info.isPast) continue;
      if (info.playerMatchLabel == null && info.eventLabels.isEmpty) continue;
      stripItems.add(
        (
          date: date,
          week: info.week,
          day: info.day,
          playerMatchLabel: info.playerMatchLabel,
          eventLabels: info.eventLabels,
        ),
      );
    }
    stripItems.sort((a, b) => a.date.compareTo(b.date));
    final strip = stripItems.take(14).toList();

    Future<void> simulateDay() async {
      final result =
          await ref.read(gameControllerProvider.notifier).simulateDay();
      if (!context.mounted || result == null) return;
      final nextLeague = ref.read(activeLeagueProvider);
      if (nextLeague != null) {
        ref.read(calendarCursorMonthProvider.notifier).state =
            _monthForInGame(nextLeague);
      }
      if (result.playerMatch != null) {
        context.push('/game/match', extra: result.playerMatch);
        return;
      }
      if (result.pauseForUrgent) {
        ref.read(shellTabIndexProvider.notifier).state = 4;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.calendar_urgentMessage)),
        );
      }
    }

    Future<void> simulateUntilDate(int targetWeek, int targetDay) async {
      await _runBatch(
        context,
        ref,
        l10n,
        () => ref
            .read(gameControllerProvider.notifier)
            .simulateUntilDate(targetWeek, targetDay),
      );
      if (!context.mounted) return;
      final nextLeague = ref.read(activeLeagueProvider);
      if (nextLeague == null) return;
      ref.read(calendarCursorMonthProvider.notifier).state =
          _monthForInGame(nextLeague);
    }

    Future<void> simulateUntilNextMatch() async {
      await _runBatch(
        context,
        ref,
        l10n,
        () => ref.read(gameControllerProvider.notifier).simulateUntilNextMatch(),
      );
      if (!context.mounted) return;
      final nextLeague = ref.read(activeLeagueProvider);
      if (nextLeague == null) return;
      ref.read(calendarCursorMonthProvider.notifier).state =
          _monthForInGame(nextLeague);
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Icon(Icons.home_outlined),
              const SizedBox(width: 8),
              Text(
                l10n.calendar_homeLabel,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: simulateDay,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.calendar_simulateDay),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: simulateUntilNextMatch,
                  icon: const Icon(Icons.fast_forward),
                  label: Text(l10n.calendar_simulateUntilNextMatch),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          ref.read(calendarCursorMonthProvider.notifier).state =
                              DateTime(month.year, month.month - 1, 1);
                        },
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Text(
                          MaterialLocalizations.of(context).formatMonthYear(month),
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ref.read(calendarCursorMonthProvider.notifier).state =
                              DateTime(month.year, month.month + 1, 1);
                        },
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (strip.isNotEmpty)
                    SizedBox(
                      height: 98,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: strip.length,
                        separatorBuilder: (context, _) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final item = strip[i];
                          return InkWell(
                            onTap: () => simulateUntilDate(item.week, item.day),
                            borderRadius: BorderRadius.circular(12),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 220,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${dayName(context, item.day)} ${item.date.day}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge,
                                      ),
                                      const SizedBox(height: 6),
                                      if (item.eventLabels.isNotEmpty)
                                        Text(
                                          item.eventLabels.first,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      if (item.playerMatchLabel != null) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          item.playerMatchLabel!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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
                    ),
                    itemBuilder: (context, i) {
                      final date = gridStart.add(Duration(days: i));
                      final info = dayInfo(date);
                      final isInMonth = date.month == month.month;
                      final isEnabled =
                          info != null && !info.isPast && isInMonth;
                      final isToday = info != null &&
                          info.week == currentWeek &&
                          info.day == currentDay;

                      return Opacity(
                        opacity: isInMonth ? 1.0 : 0.35,
                        child: InkWell(
                          onTap: isEnabled
                              ? () => simulateUntilDate(info.week, info.day)
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
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${date.day}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: isEnabled
                                            ? null
                                            : Theme.of(context)
                                                .disabledColor,
                                        fontWeight:
                                            isToday ? FontWeight.bold : null,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                if (info != null) ...[
                                  if (info.playerMatchLabel != null)
                                    Tooltip(
                                      message: info.playerMatchLabel!,
                                      child: const Icon(
                                        Icons.sports_soccer,
                                        size: 14,
                                        color: Colors.greenAccent,
                                      ),
                                    ),
                                  if (info.playerMatchLabel == null &&
                                      info.matchCount > 0)
                                    Tooltip(
                                      message: '${info.matchCount} matches',
                                      child: const Icon(
                                        Icons.sports_soccer,
                                        size: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  if (info.eventLabels.isNotEmpty)
                                    Tooltip(
                                      message: info.eventLabels.join('\n'),
                                      child: const Icon(
                                        Icons.event_available_outlined,
                                        size: 14,
                                        color: Colors.amber,
                                      ),
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Legacy fast-forward sheet/dialog removed:
  // simulation to dates is handled via tapping calendar day cards.

  Future<void> _runBatch(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Future<BatchSimulationResult> Function() run,
  ) async {
    final controller = ref.read(gameControllerProvider.notifier);
    unawaited(
      showDialog<void>(
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
      ref.read(shellTabIndexProvider.notifier).state = 4;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.calendar_urgentMessage)));
      return;
    }
    if (result.stopReason == SimulationStopReason.draftPick) {
      context.push('/game/draft');
      return;
    }

    final reasonLabel = switch (result.stopReason) {
      SimulationStopReason.reachedTarget => l10n.calendar_stopReason_reachedTarget,
      SimulationStopReason.cancelled => l10n.calendar_stopReason_cancelled,
      SimulationStopReason.noSave => l10n.calendar_stopReason_noSave,
      SimulationStopReason.playerMatch => l10n.calendar_stopReason_reachedTarget,
      SimulationStopReason.urgent => l10n.calendar_stopReason_reachedTarget,
      SimulationStopReason.draftPick => l10n.calendar_stopReason_draftPick,
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$reasonLabel · ${l10n.calendar_daysSimulated(result.daysSimulated)}',
        ),
      ),
    );
  }
}
