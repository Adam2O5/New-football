import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/calendar_screen.dart';
import 'package:new_football/app/screens/shell_screen.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

DateTime _week1StartForSeason(int seasonYear) {
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

Future<void> _runBatch(
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

  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pop();

  final nextLeague = ref.read(activeLeagueProvider);
  if (nextLeague != null) {
    ref.read(calendarCursorMonthProvider.notifier).state = _monthForInGame(
      nextLeague,
    );
  }

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
  if (result.stopReason == SimulationStopReason.draftPick) {
    context.push('/game/draft');
    return;
  }

  final reasonLabel = switch (result.stopReason) {
    SimulationStopReason.reachedTarget =>
      l10n.calendar_stopReason_reachedTarget,
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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    if (league == null) {
      return Center(child: Text(l10n.calendar_noLeague));
    }

    final calendar = ref.watch(calendarServiceProvider);
    final currentWeek = league.currentWeek;
    final currentDay = league.currentDay;
    final seasonYear = league.currentSeason.year;
    final playerId = league.playerTeamId;

    final calCfg = calendar.balance.calendar;
    final teamNameById = {for (final t in league.teams) t.id: t.name};
    final matchesByRound = <int, List<ScheduledMatch>>{};
    for (final m in league.currentSeason.schedule) {
      matchesByRound.putIfAbsent(m.round, () => []).add(m);
    }

    ({int? conferenceRank, int? overallRank, int wins, int draws, int losses})
    standingsInfo() {
      if (playerId == null) {
        return (
          conferenceRank: null,
          overallRank: null,
          wins: 0,
          draws: 0,
          losses: 0,
        );
      }
      int wins = 0;
      int draws = 0;
      int losses = 0;
      ConferenceStandings? east;
      ConferenceStandings? west;

      for (final cs in league.currentSeason.standings) {
        if (cs.conference == Conference.east) east = cs;
        if (cs.conference == Conference.west) west = cs;
      }
      final eastSorted = east?.sorted ?? const <Standing>[];
      final westSorted = west?.sorted ?? const <Standing>[];

      int? conferenceRank;
      for (final s in [...eastSorted, ...westSorted]) {
        if (s.teamId == playerId) {
          conferenceRank = s.conferenceRank;
          wins = s.wins;
          draws = s.draws;
          losses = s.losses;
          break;
        }
      }

      final overall = [...eastSorted, ...westSorted]
        ..sort((a, b) {
          final byPoints = b.points.compareTo(a.points);
          if (byPoints != 0) return byPoints;
          return b.goalDifference.compareTo(a.goalDifference);
        });
      int? overallRank;
      for (var i = 0; i < overall.length; i++) {
        if (overall[i].teamId == playerId) {
          overallRank = i + 1;
          break;
        }
      }

      return (
        conferenceRank: conferenceRank,
        overallRank: overallRank,
        wins: wins,
        draws: draws,
        losses: losses,
      );
    }

    final standings = standingsInfo();

    ScheduledMatch? lastPlayed;
    ScheduledMatch? nextUpcoming;
    if (playerId != null) {
      final playerFixtures =
          league.currentSeason.schedule
              .where(
                (m) => m.homeTeamId == playerId || m.awayTeamId == playerId,
              )
              .toList()
            ..sort((a, b) => a.round.compareTo(b.round));
      for (final m in playerFixtures) {
        if (m.result != null) {
          lastPlayed = m;
        } else if (nextUpcoming == null) {
          nextUpcoming = m;
        }
      }
    }

    String matchLine(ScheduledMatch m, {required bool withResult}) {
      final home = teamNameById[m.homeTeamId] ?? m.homeTeamId;
      final away = teamNameById[m.awayTeamId] ?? m.awayTeamId;
      if (withResult && m.result != null) {
        return '$home ${m.result!.homeGoals}:${m.result!.awayGoals} $away';
      }
      return '$home – $away';
    }

    ({int week, int day, String? playerMatchLabel, List<String> eventLabels})?
    dayInfo(DateTime date) {
      final mapped = _inGameWeekDayForDate(date, seasonYear);
      if (mapped == null) return null;
      final w = mapped.week;
      final d = mapped.day;

      String? playerMatchLabel;
      final slot = calendar.regularSeasonSlotForDay(d);
      if (calendar.isRegularSeasonWeek(w) && slot != null) {
        final round = scheduleRoundForWeekSlot(w, slot);
        final fixtures = matchesByRound[round] ?? const [];
        if (playerId != null) {
          ScheduledMatch? pm;
          for (final f in fixtures) {
            if (f.homeTeamId == playerId || f.awayTeamId == playerId) {
              pm = f;
              break;
            }
          }
          if (pm != null) {
            playerMatchLabel = matchLine(pm, withResult: true);
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
        eventLabels.add(l10n.calendar_event_draft);
      }
      if (w == calCfg.freeAgencyWeek && d == 1) {
        eventLabels.add(l10n.calendar_event_freeAgency);
      }

      return (
        week: w,
        day: d,
        playerMatchLabel: playerMatchLabel,
        eventLabels: eventLabels,
      );
    }

    final today = _dateForInGameWeekDay(seasonYear, currentWeek, currentDay);
    final next7 = List<DateTime>.generate(
      7,
      (i) => today.add(Duration(days: i)),
    );

    Future<void> simulateDay() async {
      final result = await ref
          .read(gameControllerProvider.notifier)
          .simulateDay();
      if (!context.mounted || result == null) return;
      final nextLeague = ref.read(activeLeagueProvider);
      if (nextLeague != null) {
        ref.read(calendarCursorMonthProvider.notifier).state = _monthForInGame(
          nextLeague,
        );
      }
      if (result.playerMatch != null) {
        context.push('/game/match', extra: result.playerMatch);
        return;
      }
      if (result.pauseForUrgent) {
        ref.read(shellTabIndexProvider.notifier).state = 5;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.calendar_urgentMessage)));
      }
    }

    Future<void> simulateUntilNextEvent() async {
      await _runBatch(
        context,
        ref,
        l10n,
        () =>
            ref.read(gameControllerProvider.notifier).simulateUntilNextEvent(),
      );
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: next7.length,
              separatorBuilder: (context, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final date = next7[i];
                final info = dayInfo(date);
                final isToday = i == 0;
                return Card(
                  color: isToday
                      ? Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.45)
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            dayName(context, date.weekday),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Text(
                            '${date.day}.${date.month.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          if (info?.playerMatchLabel != null)
                            Text(
                              info!.playerMatchLabel!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          else if (info != null && info.eventLabels.isNotEmpty)
                            Text(
                              info.eventLabels.first,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.home_record,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${standings.wins}-${standings.draws}-${standings.losses}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.home_conferenceRankLabel,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          standings.conferenceRank != null
                              ? '#${standings.conferenceRank}'
                              : '—',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.home_overallRankLabel,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          standings.overallRank != null
                              ? '#${standings.overallRank}'
                              : '—',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.home_lastMatchTitle,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lastPlayed != null
                              ? matchLine(lastPlayed, withResult: true)
                              : l10n.home_noPreviousMatch,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.home_nextMatchTitle,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nextUpcoming != null
                              ? matchLine(nextUpcoming, withResult: false)
                              : l10n.home_noNextMatch,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                  onPressed: simulateUntilNextEvent,
                  icon: const Icon(Icons.fast_forward),
                  label: Text(l10n.home_simulateUntilNextEvent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
