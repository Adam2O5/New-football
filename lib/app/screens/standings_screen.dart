import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/widgets/standings/standings_bracket_view.dart';
import 'package:new_football/app/widgets/standings/standings_series_list.dart';
import 'package:new_football/app/widgets/branding/club_logo.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class StandingsScreen extends ConsumerWidget {
  const StandingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    if (league == null) {
      return ScreenBackground(
        child: Center(child: Text(l10n.standings_noLeague)),
      );
    }

    return DefaultTabController(
      length: 2,
      child: ScreenBackground(
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: l10n.standings_tabRegularSeason),
                  Tab(text: l10n.standings_tabPostseason),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _RegularSeasonTab(league: league),
                    _PostseasonTab(league: league),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegularSeasonTab extends StatelessWidget {
  const _RegularSeasonTab({required this.league});

  final LeagueState league;

  /// Merges both conferences and re-ranks 1..N by points, then goal
  /// difference (same tie-break as `ConferenceStandingsX.sorted`). This is
  /// a display-only rank: `Standing.conferenceRank` is reused as the field
  /// name, but here it holds a league-wide position rather than a
  /// per-conference one.
  List<Standing> _globalStandings(
    ConferenceStandings? a,
    ConferenceStandings? b,
  ) {
    final merged = [...?a?.standings, ...?b?.standings];
    merged.sort((x, y) {
      final pts = y.points.compareTo(x.points);
      if (pts != 0) return pts;
      return y.goalDifference.compareTo(x.goalDifference);
    });
    return merged
        .asMap()
        .entries
        .map((e) => e.value.copyWith(conferenceRank: e.key + 1))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ConferenceStandings? europe;
    ConferenceStandings? restOfWorld;
    for (final cs in league.currentSeason.standings) {
      if (cs.conference == Conference.europe) europe = cs;
      if (cs.conference == Conference.restOfTheWorld) restOfWorld = cs;
    }

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: l10n.standings_tabEast),
              Tab(text: l10n.standings_tabWest),
              Tab(text: l10n.standings_tabLeague),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _StandingsTable(
                  standings: europe?.sorted ?? const [],
                  league: league,
                ),
                _StandingsTable(
                  standings: restOfWorld?.sorted ?? const [],
                  league: league,
                ),
                _StandingsTable(
                  standings: _globalStandings(europe, restOfWorld),
                  league: league,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StandingsTable extends StatelessWidget {
  const _StandingsTable({required this.standings, required this.league});

  final List<Standing> standings;
  final LeagueState league;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (standings.isEmpty) {
      return Center(child: Text(l10n.standings_empty));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: standings.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 28, child: Text('#')),
                Expanded(child: Text(l10n.standings_col_team)),
                SizedBox(
                  width: 64,
                  child: Text(
                    l10n.standings_col_record,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    l10n.standings_col_points,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          );
        }
        final s = standings[i - 1];
        final name = league.teamById(s.teamId)?.name ?? s.teamId;
        final isPlayer = league.playerTeamId == s.teamId;
        return ListTile(
          dense: true,
          selected: isPlayer,
          leading: Text('${s.conferenceRank}'),
          title: Row(
            children: [
              TeamLogo(teamId: s.teamId, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isPlayer ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          trailing: SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 64,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${s.wins}-${s.draws}-${s.losses}',
                      maxLines: 1,
                      softWrap: false,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${s.points}',
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PostseasonTab extends StatelessWidget {
  const _PostseasonTab({required this.league});

  final LeagueState league;

  String _teamName(String id) => league.teamById(id)?.name ?? id;

  String _conferenceName(AppLocalizations l10n, Conference conference) =>
      conference == Conference.europe
      ? l10n.standings_tabEast
      : l10n.standings_tabWest;

  String _resultLabel(AppLocalizations l10n, MatchResult result) {
    final resolution = result.wentToShootout
        ? l10n.standings_shootout(
            result.shootoutHomeGoals,
            result.shootoutAwayGoals,
          )
        : result.wentToExtraTime
        ? l10n.standings_extraTime
        : '';
    return '${_teamName(result.homeTeamId)} ${result.homeGoals}–${result.awayGoals} '
        '${_teamName(result.awayTeamId)}$resolution';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final season = league.currentSeason;
    final hasPostseason =
        season.playInResults.isNotEmpty ||
        season.playInProgress.isNotEmpty ||
        season.playoffBrackets.isNotEmpty;

    if (!hasPostseason) {
      return Center(child: Text(l10n.standings_noPostseasonData));
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              // Reusing the existing seasonPhase-style labels — no need for
              // separate standings_tabPlayIn/standings_tabPlayoff keys.
              Tab(text: l10n.standings_playIn),
              Tab(text: l10n.standings_playoffs),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                if (season.playInResults.isEmpty &&
                    season.playInProgress.isEmpty)
                  Center(child: Text(l10n.standings_notStarted))
                else
                  ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      PlayInBracket(
                        results: season.playInResults,
                        progress: season.playInProgress,
                        teamName: _teamName,
                      ),
                      const Divider(height: 24),
                      ...season.playInResults.map(
                        (result) => _playInCard(context, l10n, result),
                      ),
                      ...season.playInProgress.map(
                        (progress) =>
                            _playInProgressCard(context, l10n, progress),
                      ),
                    ],
                  ),
                if (season.playoffBrackets.isEmpty)
                  Center(child: Text(l10n.standings_notStarted))
                else
                  ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      PlayoffBracketView(
                        brackets: season.playoffBrackets,
                        teamName: _teamName,
                      ),
                      const Divider(height: 24),
                      SeriesRoundList(
                        brackets: season.playoffBrackets,
                        league: league,
                      ),
                      if (season.championTeamId != null) ...[
                        const SizedBox(height: 8),
                        Card(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: ListTile(
                            leading: const Icon(Icons.emoji_events_outlined),
                            title: Text(
                              l10n.standings_champion(
                                _teamName(season.championTeamId!),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _playInCard(
    BuildContext context,
    AppLocalizations l10n,
    PlayInResult result,
  ) {
    return Card(
      child: ExpansionTile(
        title: Text(_conferenceName(l10n, result.conference)),
        children: [
          ListTile(
            dense: true,
            title: Text(l10n.standings_match7v8),
            subtitle: Text(_resultLabel(l10n, result.game7v8)),
          ),
          ListTile(
            dense: true,
            title: Text(l10n.standings_match9v10),
            subtitle: Text(_resultLabel(l10n, result.game9v10)),
          ),
          ListTile(
            dense: true,
            title: Text(l10n.standings_playInFinal),
            subtitle: Text(_resultLabel(l10n, result.gameFinal)),
          ),
        ],
      ),
    );
  }

  Widget _playInProgressCard(
    BuildContext context,
    AppLocalizations l10n,
    PlayInProgress progress,
  ) {
    String label(MatchResult? result) =>
        result == null ? l10n.standings_notStarted : _resultLabel(l10n, result);
    return Card(
      child: ExpansionTile(
        title: Text(_conferenceName(l10n, progress.conference)),
        subtitle: Text(l10n.standings_seriesInProgress),
        children: [
          ListTile(
            dense: true,
            title: Text(l10n.standings_match7v8),
            subtitle: Text(label(progress.game7v8)),
          ),
          ListTile(
            dense: true,
            title: Text(l10n.standings_match9v10),
            subtitle: Text(label(progress.game9v10)),
          ),
          ListTile(
            dense: true,
            title: Text(l10n.standings_playInFinal),
            subtitle: Text(label(progress.gameFinal)),
          ),
        ],
      ),
    );
  }
}
