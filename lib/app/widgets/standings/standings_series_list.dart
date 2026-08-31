import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_football/app/providers/club_branding_provider.dart';
import 'package:new_football/app/widgets/branding/club_logo.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import 'package:new_football/app/widgets/standings/standings_round_group.dart';

/// Fixed accent colour per conference, used as a left-edge marker on series
/// tiles. `Conference` carries no branding of its own (it's a scheduling
/// concept, not a club), so these are plain constants rather than anything
/// data-driven — change here if you want different colours.
Color _conferenceAccent(Conference conference) {
  return conference == Conference.europe
      ? const Color(0xFF3B82F6)
      : const Color(0xFFF97316);
}

/// Playoff series segregated by round, most important first (league final,
/// then conference final, semi-finals, quarter-finals). Replaces the
/// previous per-conference expandable cards.
class SeriesRoundList extends StatelessWidget {
  const SeriesRoundList({
    super.key,
    required this.brackets,
    required this.league,
  });

  final List<PlayoffBracket> brackets;
  final LeagueState league;

  String _teamName(String id) => league.teamById(id)?.name ?? id;

  String _roundLabel(AppLocalizations l10n, PlayoffRound round) {
    switch (round) {
      case PlayoffRound.leagueFinal:
        return l10n.standings_leagueFinal;
      case PlayoffRound.conferenceFinal:
        return l10n.standings_conferenceFinals;
      case PlayoffRound.conferenceSemi:
        return l10n.standings_semiFinals;
      case PlayoffRound.conferenceQuarter:
        return l10n.standings_quarterFinals;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final groups = RoundGroup.fromBrackets(brackets);

    return Column(
      children: groups
          .map((group) => _roundTile(context, l10n, group))
          .toList(),
    );
  }

  Widget _roundTile(
    BuildContext context,
    AppLocalizations l10n,
    RoundGroup group,
  ) {
    return Card(
      child: ExpansionTile(
        title: Text(_roundLabel(l10n, group.round)),
        initiallyExpanded: group.round == PlayoffRound.leagueFinal,
        children: group.items
            .map((item) => _SeriesTile(item: item, teamName: _teamName))
            .toList(),
      ),
    );
  }
}

/// A single series tile. In progress: neutral look with a left-edge accent
/// bar identifying the conference (ball icon, as before). Completed: the
/// ball icon is replaced by the winning team's logo and the tile background
/// takes that team's primary brand colour.
class _SeriesTile extends ConsumerWidget {
  const _SeriesTile({required this.item, required this.teamName});

  final ConferenceSeries item;
  final String Function(String teamId) teamName;

  Color _readableOn(Color background) {
    return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final series = item.series;
    final winner = series.winnerTeamId;
    final accent = item.conference == null
        ? Theme.of(context).colorScheme.outline
        : _conferenceAccent(item.conference!);

    final matchupText =
        '${teamName(series.higherSeedTeamId)} '
        '${series.higherSeedWins}–${series.lowerSeedWins} '
        '${teamName(series.lowerSeedTeamId)}';

    if (winner == null) {
      return Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: accent, width: 4)),
        ),
        child: ListTile(
          dense: true,
          leading: Icon(Icons.sports_soccer_outlined, color: accent),
          title: Text(matchupText),
          subtitle: Text(l10n.standings_seriesInProgress),
        ),
      );
    }

    final background = ref
        .watch(clubBrandingProvider)
        .resolve(winner)
        .primaryColor;
    final textColor = _readableOn(background);
    return Container(
      decoration: BoxDecoration(
        color: background,
        border: Border(left: BorderSide(color: accent, width: 4)),
      ),
      child: ListTile(
        dense: true,
        leading: TeamLogo(teamId: winner, size: 28),
        title: Text(matchupText, style: TextStyle(color: textColor)),
        subtitle: Text(
          l10n.standings_seriesWinner(teamName(winner)),
          style: TextStyle(color: textColor.withValues(alpha: 0.85)),
        ),
      ),
    );
  }
}
