part of 'matchday_screen.dart';

class _LineupPane extends StatelessWidget {
  const _LineupPane({
    required this.team,
    required this.homeSide,
    required this.live,
  });

  final Team team;
  final bool homeSide;
  final SimulationLiveMatch live;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lineup = homeSide ? live.state.homeLineup : live.state.awayLineup;
    final bench = homeSide ? live.state.homeBench : live.state.awayBench;
    final used = homeSide ? live.homeSubsUsed : live.awaySubsUsed;
    final players = <Widget>[
      _LineupSectionHeader(
        title: l10n.matchday_lineup,
        trailing: l10n.matchday_subsUsed(used),
      ),
      ...lineup.map((player) => _LivePlayerTile(player: player, live: live)),
      const Divider(height: 1),
      _LineupSectionHeader(title: l10n.matchday_bench),
      if (bench.isEmpty)
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(l10n.matchday_noPlayers),
        )
      else
        ...bench.map(
          (player) => _LivePlayerTile(player: player, live: live, bench: true),
        ),
    ];

    return Card(
      margin: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Text(
              team.name,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(padding: EdgeInsets.zero, children: players),
          ),
        ],
      ),
    );
  }
}

class _LineupSectionHeader extends StatelessWidget {
  const _LineupSectionHeader({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.labelMedium),
          ),
          if (trailing != null)
            Text(trailing!, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _LivePlayerTile extends StatelessWidget {
  const _LivePlayerTile({
    required this.player,
    required this.live,
    this.bench = false,
  });

  final Player player;
  final SimulationLiveMatch live;
  final bool bench;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final condition = live.legacyMatch.visibleStamina(player);
    final discipline = live.disciplines.where(
      (item) => item.playerId == player.id,
    );
    final yellow =
        (live.state.yellowCardCounts[player.id] ?? 0) > 0 ||
        discipline.any((item) => item.yellowCardsInMatch > 0);
    final sentOff =
        live.state.sentOffPlayerIds.contains(player.id) ||
        discipline.any((item) => item.redCardKind != RedCardKind.none);
    final injured = player.state.injured;
    final suspended = player.state.suspensionGamesRemaining > 0;
    final attention = condition <= 35 || yellow || sentOff || injured;
    final status = sentOff
        ? l10n.matchday_sentOff
        : injured
        ? l10n.matchday_injured
        : suspended
        ? l10n.matchday_suspended
        : yellow
        ? l10n.matchday_yellowCard
        : attention
        ? l10n.matchday_attention
        : l10n.matchday_available;
    final statusColor = sentOff || injured
        ? Theme.of(context).colorScheme.error
        : yellow || attention
        ? Colors.orange.shade800
        : Theme.of(context).colorScheme.onSurfaceVariant;
    final ovr = player.overall().round();

    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: CircleAvatar(
        radius: 15,
        child: Text(player.position.code, style: const TextStyle(fontSize: 9)),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              player.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: bench ? FontWeight.normal : FontWeight.w600,
              ),
            ),
          ),
          if (attention)
            Tooltip(
              message: l10n.matchday_attention,
              child: Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: statusColor,
              ),
            ),
        ],
      ),
      subtitle: Text(
        l10n.matchday_playerMeta(player.position.code, ovr, condition),
        style: const TextStyle(fontSize: 10),
      ),
      trailing: Text(
        status,
        textAlign: TextAlign.right,
        style: TextStyle(fontSize: 9, color: statusColor),
      ),
    );
  }
}
