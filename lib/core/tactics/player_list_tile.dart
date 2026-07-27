import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/tactics/player_sort.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class PlayerListTile extends StatelessWidget {
  const PlayerListTile({
    super.key,
    required this.l10n,
    required this.player,
    required this.zone,
    required this.selected,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final Player player;
  final RosterZone zone;
  final bool selected;
  final VoidCallback onTap;

  String _zoneLabel(AppLocalizations l10n) {
    switch (zone) {
      case RosterZone.xi:
        return l10n.squad_zoneXi;
      case RosterZone.bench:
        return l10n.squad_zoneBench;
      case RosterZone.reserve:
        return l10n.squad_zoneReserves;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: selected
          ? Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.4)
          : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: selected
              ? Theme.of(context).colorScheme.primary
              : null,
          child: Text(
            player.position.code,
            style: const TextStyle(fontSize: 11),
          ),
        ),
        title: Text(player.name),
        subtitle: Text(
          '${l10n.stat_ovr}${player.overall().round()} '
          '${l10n.stat_form}${player.state.form} '
          '${_zoneLabel(l10n)}'
          '${player.state.injured ? ' ${l10n.squad_injury}' : ''}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => context.push('/game/player/${player.id}'),
        ),
        onTap: onTap,
      ),
    );
  }
}
