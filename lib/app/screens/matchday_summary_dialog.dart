part of 'matchday_screen.dart';

class _MatchSummaryDialog extends StatelessWidget {
  const _MatchSummaryDialog({
    required this.result,
    required this.home,
    required this.away,
    required this.onClose,
  });

  final MatchResult result;
  final Team home;
  final Team away;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final players = <String, Player>{
      for (final player in [...home.roster, ...away.roster]) player.id: player,
    };
    final playerStats = [...result.playerStats]
      ..sort((a, b) {
        final rating = b.rating.compareTo(a.rating);
        if (rating != 0) return rating;
        return b.minutes.compareTo(a.minutes);
      });
    final motm = result.manOfTheMatchPlayerId == null
        ? null
        : players[result.manOfTheMatchPlayerId!]?.name;
    final inspired = result.inspiredPerformancePlayerId == null
        ? null
        : players[result.inspiredPerformancePlayerId!]?.name;

    return AlertDialog(
      title: Text(l10n.matchday_summaryTitle),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${home.name} ${result.homeGoals}:${result.awayGoals} ${away.name}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.matchday_summaryTeamStats,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            _SummaryTeamStats(home: result.homeStats, away: result.awayStats),
            const SizedBox(height: 16),
            _SummaryHighlight(
              label: l10n.matchday_summaryMOTM,
              value: motm ?? l10n.matchday_summaryNone,
            ),
            _SummaryHighlight(
              label: l10n.matchday_summaryInspired,
              value: inspired ?? l10n.matchday_summaryNone,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.matchday_summaryPlayerStats,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            if (playerStats.isEmpty)
              Text(l10n.matchday_summaryNoPlayerStats)
            else
              for (final stat in playerStats)
                _SummaryPlayerRow(
                  stat: stat,
                  player: players[stat.playerId],
                  l10n: l10n,
                ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: onClose,
          child: Text(l10n.matchday_summaryClose),
        ),
      ],
    );
  }
}

class _SummaryTeamStats extends StatelessWidget {
  const _SummaryTeamStats({required this.home, required this.away});

  final TeamMatchStats home;
  final TeamMatchStats away;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rows = <(String, String, String)>[
      (l10n.stats_possession, '${home.possession}%', '${away.possession}%'),
      (
        l10n.stats_shots,
        '${home.shots} (${home.shotsOnTarget})',
        '${away.shots} (${away.shotsOnTarget})',
      ),
      (l10n.stats_xg, home.xg.toStringAsFixed(2), away.xg.toStringAsFixed(2)),
      (l10n.stats_corners, '${home.corners}', '${away.corners}'),
      (l10n.stats_fouls, '${home.fouls}', '${away.fouls}'),
      (l10n.stats_yellowCards, '${home.yellowCards}', '${away.yellowCards}'),
      (l10n.stats_redCards, '${home.redCards}', '${away.redCards}'),
    ];
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.6),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
      },
      children: [
        for (final row in rows)
          TableRow(
            children: [
              _SummaryCell(row.$1),
              _SummaryCell(row.$2, center: true),
              _SummaryCell(row.$3, center: true),
            ],
          ),
      ],
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell(this.text, {this.center = false});

  final String text;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(text, textAlign: center ? TextAlign.center : TextAlign.left),
    );
  }
}

class _SummaryHighlight extends StatelessWidget {
  const _SummaryHighlight({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _SummaryPlayerRow extends StatelessWidget {
  const _SummaryPlayerRow({
    required this.stat,
    required this.player,
    required this.l10n,
  });

  final PlayerMatchStats stat;
  final Player? player;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final name = player?.name ?? stat.playerId;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Expanded(
            child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Text(
            '${l10n.matchday_summaryRating}: ${stat.rating.toStringAsFixed(1)}',
          ),
        ],
      ),
      subtitle: Text(
        '${stat.minutes}\' · ${l10n.stats_goals}: ${stat.goals} · '
        '${l10n.stats_assists}: ${stat.assists} · ${l10n.stats_shots}: ${stat.shots} · '
        '${l10n.matchday_summaryStamina}: ${stat.staminaAfterMatch < 0 ? l10n.matchday_summaryNone : stat.staminaAfterMatch}',
      ),
    );
  }
}
