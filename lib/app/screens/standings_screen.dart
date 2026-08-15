import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_football/app/providers/game_provider.dart';
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

    ConferenceStandings? east;
    ConferenceStandings? west;
    for (final cs in league.currentSeason.standings) {
      if (cs.conference == Conference.europe) east = cs;
      if (cs.conference == Conference.restOfTheWorld) west = cs;
    }

    return DefaultTabController(
      length: 3,
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
                  Tab(text: l10n.standings_tabEast),
                  Tab(text: l10n.standings_tabWest),
                  Tab(text: l10n.standings_tabPostseason),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _StandingsTable(
                      standings: east?.sorted ?? const [],
                      league: league,
                    ),
                    _StandingsTable(
                      standings: west?.sorted ?? const [],
                      league: league,
                    ),
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
                  width: 56,
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
                SizedBox(
                  width: 40,
                  child: Text(
                    l10n.standings_col_diff,
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
          title: Text(
            name,
            style: TextStyle(
              fontWeight: isPlayer ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: SizedBox(
            width: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 56,
                  child: Text(
                    '${s.wins}-${s.draws}-${s.losses}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
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
                SizedBox(
                  width: 40,
                  child: Text(
                    '${s.goalDifference >= 0 ? '+' : ''}${s.goalDifference}',
                    textAlign: TextAlign.end,
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

  String _resultLabel(MatchResult result) =>
      '${_teamName(result.homeTeamId)} ${result.homeGoals}–${result.awayGoals} '
      '${_teamName(result.awayTeamId)}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final season = league.currentSeason;
    final hasPostseason =
        season.playInResults.isNotEmpty || season.playoffBrackets.isNotEmpty;

    if (!hasPostseason) {
      return Center(child: Text(l10n.standings_noPostseasonData));
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          l10n.standings_playIn,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (season.playInResults.isEmpty)
          Card(child: ListTile(title: Text(l10n.standings_notStarted)))
        else
          ...season.playInResults.map(
            (result) => _playInCard(context, l10n, result),
          ),
        const SizedBox(height: 16),
        Text(
          l10n.standings_playoffs,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (season.playoffBrackets.isEmpty)
          Card(child: ListTile(title: Text(l10n.standings_notStarted)))
        else
          ...season.playoffBrackets.map(
            (bracket) => _bracketCard(context, l10n, bracket),
          ),
        if (season.championTeamId != null) ...[
          const SizedBox(height: 8),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: ListTile(
              leading: const Icon(Icons.emoji_events_outlined),
              title: Text(
                l10n.standings_champion(_teamName(season.championTeamId!)),
              ),
            ),
          ),
        ],
      ],
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
            subtitle: Text(_resultLabel(result.game7v8)),
          ),
          ListTile(
            dense: true,
            title: Text(l10n.standings_match9v10),
            subtitle: Text(_resultLabel(result.game9v10)),
          ),
          ListTile(
            dense: true,
            title: Text(l10n.standings_playInFinal),
            subtitle: Text(_resultLabel(result.gameFinal)),
          ),
        ],
      ),
    );
  }

  Widget _bracketCard(
    BuildContext context,
    AppLocalizations l10n,
    PlayoffBracket bracket,
  ) {
    return Card(
      child: ExpansionTile(
        title: Text(_conferenceName(l10n, bracket.conference)),
        children: [
          _round(l10n.standings_quarterFinals, bracket.quarterFinals, l10n),
          _round(l10n.standings_semiFinals, bracket.semiFinals, l10n),
          _round(
            l10n.standings_conferenceFinals,
            bracket.conferenceFinal,
            l10n,
          ),
          if (bracket.leagueFinal != null)
            _round(l10n.standings_leagueFinal, [bracket.leagueFinal!], l10n),
        ],
      ),
    );
  }

  Widget _round(
    String title,
    List<PlayoffSeries> series,
    AppLocalizations l10n,
  ) {
    if (series.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...series.map((item) => _seriesTile(item, l10n)),
        ],
      ),
    );
  }

  Widget _seriesTile(PlayoffSeries series, AppLocalizations l10n) {
    final winner = series.winnerTeamId;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.sports_soccer_outlined),
      title: Text(
        '${_teamName(series.higherSeedTeamId)} '
        '${series.higherSeedWins}–${series.lowerSeedWins} '
        '${_teamName(series.lowerSeedTeamId)}',
      ),
      subtitle: Text(
        winner == null
            ? l10n.standings_seriesInProgress
            : l10n.standings_seriesWinner(_teamName(winner)),
      ),
    );
  }
}
