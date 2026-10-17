import 'dart:async';

import 'package:new_football/core/services/calendar_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/formatters/season_context_lines.dart';
import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/app/providers/club_branding_provider.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/calendar_screen.dart';
import 'package:new_football/app/screens/shell_screen.dart';
import 'package:new_football/app/widgets/branding/club_logo.dart';
import 'package:new_football/app/widgets/home/season_context.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

part 'home_calendar_actions.dart';
part 'home_action_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final brandingRegistry = ref.watch(clubBrandingProvider);
    final league = ref.watch(activeLeagueProvider);
    final activeTeamId = league?.playerTeamId;
    final activeTeam = league?.teamById(activeTeamId ?? '');
    final teamName = activeTeam?.name ?? l10n.shell_defaultCareerName;
    final branding = brandingRegistry.resolve(activeTeamId ?? '');
    final fallbackLogoAsset = brandingRegistry.assets.fallbackLogoAsset;

    if (league == null) {
      return Scaffold(
        body: ScreenBackground(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HomeDashboardHeader(
                teamName: teamName,
                logoAsset: branding.logoAsset,
                fallbackLogoAsset: fallbackLogoAsset,
              ),
              const SizedBox(height: 16),
              Center(child: Text(l10n.calendar_noLeague)),
            ],
          ),
        ),
      );
    }

    final nextAction = ref.watch(nextGameEventProvider);
    final currentWeek = league.currentWeek;
    final currentDay = league.currentDay;
    final seasonYear = league.currentSeason.year;
    final playerId = activeTeamId;

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
        } else {
          nextUpcoming ??= m;
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
    final seasonContextLines = SeasonContextLines.fromLeague(context, league);

    return Scaffold(
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HomeDashboardHeader(
              teamName: teamName,
              logoAsset: branding.logoAsset,
              fallbackLogoAsset: fallbackLogoAsset,
              seasonLines: seasonContextLines,
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
                        height: 78,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.topLeft,
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
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  )
                                else if (info != null &&
                                    info.eventLabels.isNotEmpty)
                                  Text(
                                    info.eventLabels.first,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
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
