import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class StandingsScreen extends ConsumerWidget {
  const StandingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    if (league == null) {
      return Center(child: Text(l10n.standings_noLeague));
    }

    ConferenceStandings? east;
    ConferenceStandings? west;
    for (final cs in league.currentSeason.standings) {
      if (cs.conference == Conference.east) east = cs;
      if (cs.conference == Conference.west) west = cs;
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: l10n.standings_tabEast),
              Tab(text: l10n.standings_tabWest),
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
