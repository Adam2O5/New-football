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
    this.enableDragDrop = false,
    this.onAcceptDrop,
  });

  final AppLocalizations l10n;
  final Player player;
  final RosterZone zone;
  final bool selected;
  final VoidCallback onTap;

  /// Gdy true, tile jest przeciągalny i akceptuje przeciągnięty id
  /// (`onAcceptDrop`) — caller reużywa `_trySwap` do wykonania zamiany.
  final bool enableDragDrop;
  final void Function(String draggedPlayerId)? onAcceptDrop;

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

  Widget _buildTile(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    final tile = _buildTile(context);
    if (!enableDragDrop) return tile;

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => details.data != player.id,
      onAcceptWithDetails: (details) => onAcceptDrop?.call(details.data),
      builder: (context, candidateData, rejectedData) {
        final hovered = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            border: hovered
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: LongPressDraggable<String>(
            data: player.id,
            feedback: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: tile,
              ),
            ),
            childWhenDragging: Opacity(opacity: 0.35, child: tile),
            child: tile,
          ),
        );
      },
    );
  }
}
