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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selectedColor = colors.primaryContainer.withValues(alpha: 0.72);
    final tileColor = selected ? selectedColor : colors.surfaceContainerHighest;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? colors.primary.withValues(alpha: 0.7)
              : colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          leading: CircleAvatar(
            backgroundColor: selected
                ? colors.primary
                : colors.surfaceContainerLow,
            foregroundColor: selected ? colors.onPrimary : colors.onSurface,
            child: Text(
              player.position.code,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            player.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${l10n.stat_ovr}${player.overall().round()} · '
            '${l10n.stat_form}${player.state.form} · ${_zoneLabel(l10n)}'
            '${player.state.injured ? ' · ${l10n.squad_injury}' : ''}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (player.state.injured)
                Icon(Icons.healing_outlined, color: colors.error, size: 20),
              IconButton(
                tooltip: l10n.playerDetail_title,
                icon: const Icon(Icons.info_outline),
                onPressed: () => context.push('/game/player/${player.id}'),
              ),
            ],
          ),
          onTap: onTap,
        ),
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
