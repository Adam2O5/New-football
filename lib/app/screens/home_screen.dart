import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/calendar_screen.dart';
import 'package:new_football/app/screens/shell_screen.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
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
  CalendarEventId.scoutReport => '/game/draft',
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

void _showBatchSnack(
  BuildContext context,
  AppLocalizations l10n,
  BatchSimulationResult result,
) {
  final reasonLabel = switch (result.stopReason) {
    SimulationStopReason.reachedTarget =>
      l10n.calendar_stopReason_reachedTarget,
    SimulationStopReason.cancelled => l10n.calendar_stopReason_cancelled,
    SimulationStopReason.noSave => l10n.calendar_stopReason_noSave,
    SimulationStopReason.playerMatch => l10n.calendar_stopReason_reachedTarget,
    SimulationStopReason.urgent => l10n.calendar_stopReason_reachedTarget,
    SimulationStopReason.event => l10n.calendar_stopReason_reachedTarget,
  };
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '$reasonLabel · ${l10n.calendar_daysSimulated(result.daysSimulated)}',
      ),
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

  if (result.stopReason == SimulationStopReason.urgent) {
    ref.read(shellTabIndexProvider.notifier).state = 5;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.calendar_urgentMessage)));
    return;
  }

  if (result.stopReason != SimulationStopReason.event &&
      result.stopReason != SimulationStopReason.playerMatch) {
    _showBatchSnack(context, l10n, result);
    return;
  }

  if (!openRoute) {
    return;
  }

  if (result.stopReason == SimulationStopReason.playerMatch) {
    return;
  }

  final route = _routeForEvent(action.calendarEventId!);
  if (route != null) {
    context.push(route);
    return;
  }

  _showBatchSnack(context, l10n, result);
}

/// "Symuluj {event}": dociąga kalendarz do dnia eventu, wykonuje go
/// (`runEventAtCurrentDay`) i dopiero wtedy przesuwa dzień o jeden.
/// `runEventAtCurrentDay` samo w sobie NIE przesuwa kalendarza (patrz
/// `GameController.runEventAtCurrentDay` w `game_provider.dart`) — bez
/// `advanceOneDay()` po jego wywołaniu `currentWeek`/`currentDay`
/// zostawałyby zamrożone na dniu eventu na stałe, mimo że event jest już
/// oznaczony jako wykonany (i przycisk "wygląda" na zmieniony).
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

  if (result.stopReason == SimulationStopReason.urgent) {
    ref.read(shellTabIndexProvider.notifier).state = 5;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.calendar_urgentMessage)));
    return;
  }
  if (result.stopReason != SimulationStopReason.event) {
    _showBatchSnack(context, l10n, result);
    return;
  }

  final controller = ref.read(gameControllerProvider.notifier);
  await controller.runEventAtCurrentDay(action.calendarEventId!);
  final dayResult = await controller.advanceOneDay();
  if (!context.mounted) return;
  _refreshCalendarCursor(ref);

  if (dayResult?.playerMatch != null) {
    context.push('/game/match', extra: dayResult!.playerMatch);
    return;
  }
  if (dayResult?.pauseForUrgent ?? false) {
    ref.read(shellTabIndexProvider.notifier).state = 5;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.calendar_urgentMessage)));
    return;
  }

  final label = action.calendarEventId == null
      ? action.id
      : calendarEventLabel(context, action.calendarEventId!) ?? action.id;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(l10n.home_actionExecuted(label))));
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

  if (result.lastResult?.playerMatch != null) {
    context.push('/game/match', extra: result.lastResult!.playerMatch);
    return;
  }
  if (result.stopReason == SimulationStopReason.urgent) {
    ref.read(shellTabIndexProvider.notifier).state = 5;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.calendar_urgentMessage)));
    return;
  }
  _showBatchSnack(context, l10n, result);
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

Future<void> _advanceOneDay(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) async {
  final controller = ref.read(gameControllerProvider.notifier);
  final result = await controller.advanceOneDay();
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

Widget _buildNextActionSection(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  LeagueState league,
  UpcomingAction? action,
) {
  final calendar = ref.read(calendarServiceProvider);
  final hourly = calendar.isHourlyContractMode(
    league.currentWeek,
    league.currentDay,
  );
  final blockedByUrgent = league.inbox.pendingUrgent.isNotEmpty;

  if (blockedByUrgent) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: null,
        icon: const Icon(Icons.lock_outline),
        label: Text(l10n.home_readUrgent),
      ),
    );
  }

  if (hourly) {
    final hour = league.currentHour ?? 1;
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _advanceOneHour(context, ref, l10n),
        icon: const Icon(Icons.schedule),
        label: Text(l10n.home_simulateHour(hour)),
      ),
    );
  }

  String actionLabel(UpcomingAction? upcoming) {
    if (upcoming == null) return l10n.home_nextEvent;
    final eventId = upcoming.calendarEventId;
    return eventId == null
        ? upcoming.id
        : calendarEventLabel(context, eventId) ?? upcoming.id;
  }

  final actionIsToday =
      action != null &&
      action.week == league.currentWeek &&
      action.day == league.currentDay;

  if (!actionIsToday) {
    final secondaryLabel = switch (action?.kind) {
      CalendarEventKind.match => l10n.home_simulateToNextMatch,
      CalendarEventKind.playerAction ||
      CalendarEventKind.automatic ||
      CalendarEventKind.informational =>
        action != null
            ? l10n.home_simulateToEvent(actionLabel(action))
            : l10n.home_simulateUntilEvent,
      null => l10n.home_simulateUntilEvent,
    };

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _advanceOneDay(context, ref, l10n),
            icon: const Icon(Icons.skip_next_outlined),
            label: Text(l10n.home_simulateDay),
            style: OutlinedButton.styleFrom(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.85),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: action == null
                ? null
                : () =>
                      _goToEvent(context, ref, l10n, action, openRoute: false),
            icon: const Icon(Icons.fast_forward),
            label: Text(secondaryLabel),
          ),
        ),
      ],
    );
  }

  if (action.kind == CalendarEventKind.match) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _simulateMatch(context, ref, l10n),
        icon: const Icon(Icons.sports_soccer),
        label: Text(l10n.home_simulateMatch),
      ),
    );
  }

  final label = actionLabel(action);
  final goToOnly =
      action.calendarEventId != null &&
      _isGoToOnlyEvent(action.calendarEventId!);
  final simulateOnly =
      action.calendarEventId != null &&
      _isSimulateOnlyEvent(action.calendarEventId!);

  if (goToOnly) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _goToEvent(context, ref, l10n, action),
        icon: const Icon(Icons.event_available_outlined),
        label: Text(l10n.home_goToEvent(label)),
      ),
    );
  }

  if (simulateOnly) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _simulateEvent(context, ref, l10n, action),
        icon: const Icon(Icons.fast_forward),
        label: Text(l10n.home_simulateEvent(label)),
      ),
    );
  }

  return Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () => _goToEvent(context, ref, l10n, action),
          style: OutlinedButton.styleFrom(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.85),
          ),
          child: Text(l10n.home_goToEvent(label)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: FilledButton(
          onPressed: () => _simulateEvent(context, ref, l10n, action),
          child: Text(l10n.home_simulateEvent(label)),
        ),
      ),
    ],
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

    final nextAction = ref.watch(nextGameEventProvider);
    final currentWeek = league.currentWeek;
    final currentDay = league.currentDay;
    final seasonYear = league.currentSeason.year;
    final playerId = league.playerTeamId;

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
        if (cs.conference == Conference.europe) east = cs;
        if (cs.conference == Conference.restOfTheWorld) west = cs;
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

    ({
      int week,
      int day,
      int? round,
      String? playerMatchLabel,
      List<String> eventLabels,
    })?
    dayInfo(DateTime date) {
      final mapped = _inGameWeekDayForDate(date, seasonYear);
      if (mapped == null) return null;
      final w = mapped.week;
      final d = mapped.day;

      int? round;
      String? playerMatchLabel;
      final calendar = ref.read(calendarServiceProvider);
      final slot = calendar.regularSeasonSlotForDay(d);
      final isActualMatchDay = slot != null && calendar.isActualMatchDay(w, d);

      if (calendar.isRegularSeasonWeek(w) && slot != null && isActualMatchDay) {
        round = scheduleRoundForWeekSlot(w, slot);
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
      for (final e in calendar.eventsOn(w, d)) {
        final label = calendarEventLabel(context, e.id);
        if (label != null) eventLabels.add(label);
      }

      return (
        week: w,
        day: d,
        round: round,
        playerMatchLabel: playerMatchLabel,
        eventLabels: eventLabels,
      );
    }

    final today = _dateForInGameWeekDay(seasonYear, currentWeek, currentDay);
    final next7 = List<DateTime>.generate(
      7,
      (i) => today.add(Duration(days: i)),
    );
    final playerTeam = league.playerTeam;
    final teamName = playerTeam?.name ?? l10n.shell_defaultCareerName;
    final teamInitial = teamName.trim().isEmpty
        ? '?'
        : teamName.trim().substring(0, 1).toUpperCase();
    final seasonContext = l10n.home_context(
      seasonYear,
      seasonPhaseLabel(context, league.currentSeason.phase),
      currentWeek,
      currentDay,
    );

    return Scaffold(
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              key: const ValueKey('home-dashboard-header'),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: Text(teamInitial),
                ),
                title: Text(
                  teamName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle: Text(seasonContext),
                trailing: Icon(
                  Icons.calendar_month_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.home_next7days,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              key: const ValueKey('home-next-seven-days'),
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
                            else if (info != null &&
                                info.eventLabels.isNotEmpty)
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
            Text(
              l10n.home_nextActionTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildNextActionSection(context, ref, l10n, league, nextAction),
          ],
        ),
      ),
    );
  }
}
