import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/app/utils/squad_tile_metrics.dart';
import 'package:new_football/app/utils/staff_presentation.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/player_sort.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

part 'player_tile_badges.dart';
part 'player_tile_metrics.dart';
part 'player_tile_status_icons.dart';

/// A roster row. The public name is retained for existing imports and callers.
class PlayerListTile extends StatelessWidget {
  const PlayerListTile({
    super.key,
    required this.l10n,
    required this.player,
    required this.zone,
    required this.selected,
    required this.onTap,
    this.positionAssignment,
    this.assignment,
    this.onInfo,
    this.onProfile,
    this.enableDragDrop = false,
    this.onAcceptDrop,
    this.metricMode = SquadTileMetricMode.staminaForm,
  });

  final AppLocalizations l10n;
  final Player player;
  final RosterZone zone;
  final bool selected;
  final VoidCallback onTap;

  /// The exact formation slot used to resolve position mismatch presentation.
  final AssignedSlot? positionAssignment;

  /// Compatibility alias for callers that use the shorter assignment name.
  final AssignedSlot? assignment;

  /// Opens this row's represented player profile when supplied by the caller.
  final VoidCallback? onInfo;

  /// Compatibility alias for profile callbacks named after their destination.
  final VoidCallback? onProfile;

  /// Gdy true, tile jest przeciągalny i akceptuje przeciągnięty id
  /// (`onAcceptDrop`) — caller reużywa `_trySwap` do wykonania zamiany.
  final bool enableDragDrop;
  final void Function(String draggedPlayerId)? onAcceptDrop;
  final SquadTileMetricMode metricMode;

  AssignedSlot? get _resolvedAssignment => positionAssignment ?? assignment;

  void _openProfile(BuildContext context) {
    final callback = onInfo ?? onProfile;
    if (callback != null) {
      callback();
      return;
    }
    context.push('/game/player/${player.id}');
  }

  String _rowSemantics(SquadStatus status, int roundedOvr, double form) {
    final label = l10n.squad_playerRowSemantics(
      player.name,
      player.position.code,
      roundedOvr,
      _formatForm(form),
      _zoneLabel(l10n, zone),
    );
    final statuses = <String>[
      if (status.hasActiveInjury) l10n.squad_statusInjury,
      if (status.hasActiveSuspension) l10n.squad_statusSuspension,
      if (status.hasPositionMismatch) l10n.squad_positionMismatch,
    ];
    if (statuses.isEmpty) return label;
    return '$label. ${statuses.join('. ')}.';
  }

  Widget _tileMetric(
    BuildContext context,
    bool compact,
    double badgeSize,
    double clampedForm,
    double clampedStamina,
  ) {
    switch (metricMode) {
      case SquadTileMetricMode.staminaForm:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MetricBarCaption(
              label: l10n.squad_staminaLabel,
              width: badgeSize,
              bar: StaminaIndicator(
                stamina: clampedStamina,
                l10n: l10n,
                width: badgeSize,
              ),
            ),
            const SizedBox(width: 4),
            _MetricBarCaption(
              label: l10n.squad_formLabel,
              width: badgeSize,
              bar: FormIndicator(
                form: clampedForm,
                l10n: l10n,
                width: badgeSize,
              ),
            ),
          ],
        );
      case SquadTileMetricMode.potential:
        return PotentialStars(
          playerId: player.id,
          stars: displayedPotentialStars(player.potentialStars),
          color: potentialStarColor(player.age),
          l10n: l10n,
          iconSize: compact ? 11 : 13,
        );
      case SquadTileMetricMode.optimalRole:
        return OptimalRoleLabel(
          playerId: player.id,
          label: roleDisplayInfo(player.optimalRole).label,
          l10n: l10n,
          compact: compact,
        );
    }
  }

  Widget _buildPresentationTile(BuildContext context) {
    final status = statusFor(player, _resolvedAssignment);
    final roundedOvr = roundedOvrForDisplay(player.overall());
    final clampedForm = clampedFormValue(player.state.form);
    final clampedStamina = clampedStaminaValue(player.state.stamina.toDouble());
    final nameParts = splitPlayerName(player.name);
    final rowSemantics = _rowSemantics(status, roundedOvr, clampedForm);

    final row = LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;
        final badgeSize = compact ? 32.0 : 36.0;
        final badgeGap = compact ? 4.0 : 6.0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PositionBadge(
              position: player.position.code,
              backgroundColor: status.color,
              selected: selected,
              size: badgeSize,
              l10n: l10n,
            ),
            SizedBox(width: badgeGap),
            OvrBadge(ovr: roundedOvr, size: badgeSize, l10n: l10n),
            SizedBox(width: badgeGap),
            Expanded(child: _NameAndForm(nameParts: nameParts)),
            const SizedBox(width: 2),
            _tileMetric(
              context,
              compact,
              badgeSize,
              clampedForm,
              clampedStamina,
            ),
            const SizedBox(width: 2),
            StatusIcons(
              hasActiveInjury: status.hasActiveInjury,
              hasActiveSuspension: status.hasActiveSuspension,
              l10n: l10n,
              iconSize: compact ? 18 : 20,
            ),
            SizedBox(
              width: compact ? 34 : 38,
              child: Semantics(
                button: true,
                label: l10n.squad_profileAction(player.name),
                child: IconButton(
                  onPressed: () => _openProfile(context),
                  tooltip: l10n.squad_profileAction(player.name),
                  icon: const Icon(Icons.info_outline),
                  iconSize: compact ? 19 : 21,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    final zoneFrame = ZoneFrame(
      key: ValueKey('squad-zone-frame-${player.id}'),
      l10n: l10n,
      zone: zone,
      child: row,
    );
    final selectionAccent = Theme.of(context).colorScheme.primary;
    final selectionSurface = selected
        ? Stack(
            fit: StackFit.passthrough,
            children: [
              zoneFrame,
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: selectionAccent.withValues(alpha: 0.12),
                      border: Border.all(color: selectionAccent, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          )
        : zoneFrame;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: rowSemantics,
      selected: selected,
      value: selected
          ? l10n.squad_playerSelected
          : l10n.squad_playerNotSelected,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: selectionSurface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final row = _buildPresentationTile(context);
    final interactiveRow = enableDragDrop
        ? DragTarget<String>(
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
                      child: row,
                    ),
                  ),
                  childWhenDragging: Opacity(opacity: 0.35, child: row),
                  child: row,
                ),
              );
            },
          )
        : row;

    return KeyedSubtree(
      key: ValueKey('squad-player-row-${player.id}'),
      child: interactiveRow,
    );
  }
}

class _NameAndForm extends StatelessWidget {
  const _NameAndForm({required this.nameParts});

  final NameParts nameParts;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          nameParts.firstLine,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (nameParts.secondLine.isNotEmpty)
          Text(
            nameParts.secondLine,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall,
          ),
      ],
    );
  }
}
