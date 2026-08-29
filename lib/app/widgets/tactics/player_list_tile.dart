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

/// The labelled frame that communicates a player's roster zone.
class ZoneFrame extends StatelessWidget {
  const ZoneFrame({
    super.key,
    required this.l10n,
    required this.zone,
    required this.child,
    this.backgroundColor,
    this.frameColor,
  });

  final AppLocalizations l10n;
  final RosterZone zone;
  final Widget child;
  final Color? backgroundColor;
  final Color? frameColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final rowBackground = backgroundColor ?? colors.surfaceContainerHighest;
    final semanticZoneColor = frameColor ?? rosterZoneColor(zone);
    final resolvedFrameColor = _contrastSafeZoneColor(
      semanticZoneColor,
      rowBackground,
    );
    final label = _zoneLabel(l10n, zone);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final labelInset = (18 * textScale).clamp(18.0, 42.0).toDouble();

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: l10n.squad_zoneFrameSemantics(label),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        padding: EdgeInsets.fromLTRB(8, labelInset, 8, 8),
        decoration: BoxDecoration(
          color: rowBackground,
          border: Border.all(color: resolvedFrameColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final labelWidth = (constraints.maxWidth - 16)
                .clamp(0.0, double.infinity)
                .toDouble();
            return Stack(
              clipBehavior: Clip.none,
              children: [
                child,
                Positioned(
                  top: -labelInset,
                  left: 4,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: labelWidth),
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: rowBackground),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: ExcludeSemantics(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: resolvedFrameColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Circular natural-position badge. Selection is an inner ring, independent
/// from the status background color.
class PositionBadge extends StatelessWidget {
  const PositionBadge({
    super.key,
    required this.position,
    required this.backgroundColor,
    required this.selected,
    required this.size,
    required this.l10n,
  });

  final String position;
  final Color backgroundColor;
  final bool selected;
  final double size;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = foregroundForContrast(backgroundColor);
    return Semantics(
      container: true,
      label: l10n.squad_positionBadgeSemantics(position),
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
            border: selected
                ? Border.all(color: colors.primary, width: 2)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            position,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: TextStyle(
              color: foreground,
              fontSize: size < 34 ? 10 : 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular OVR badge with the shared gradient and contrast-safe text.
class OvrBadge extends StatelessWidget {
  const OvrBadge({
    super.key,
    required this.ovr,
    required this.size,
    required this.l10n,
  });

  final int ovr;
  final double size;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final background = ovrColorForRoundedValue(ovr);
    return Semantics(
      container: true,
      label: l10n.squad_ovrBadgeSemantics(ovr),
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: background),
          alignment: Alignment.center,
          child: Text(
            '$ovr',
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: TextStyle(
              color: foregroundForContrast(background),
              fontSize: size < 34 ? 10 : 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// A clamped, horizontal form track with a compact visible border.
class FormIndicator extends StatelessWidget {
  const FormIndicator({
    super.key,
    required this.form,
    required this.l10n,
    this.width = 34.0,
  });

  final double form;
  final AppLocalizations l10n;
  final double width;

  @override
  Widget build(BuildContext context) {
    final clampedForm = clampedFormValue(form);
    final fill = formFillForValue(clampedForm);
    final fillColor = formColorForClampedValue(clampedForm);
    final colors = Theme.of(context).colorScheme;
    final trackColor = colors.surfaceContainerLow;
    final indicatorWidth = width.clamp(32.0, 36.0).toDouble();

    return Semantics(
      container: true,
      label: l10n.squad_formIndicatorSemantics(_formatForm(clampedForm)),
      child: ExcludeSemantics(
        child: Container(
          key: const ValueKey('squad-form-indicator'),
          width: indicatorWidth,
          height: 10,
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: Border.all(color: colors.outline, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: trackColor),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: fill,
                  child: ColoredBox(color: fillColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A clamped, horizontal stamina track with a compact visible border.
///
/// Mirrors [FormIndicator]'s structure but reads the 0–100 stamina gradient
/// (no blue endpoint) instead of the 0–10 form gradient.
class StaminaIndicator extends StatelessWidget {
  const StaminaIndicator({
    super.key,
    required this.stamina,
    required this.l10n,
    this.width = 34.0,
  });

  final double stamina;
  final AppLocalizations l10n;
  final double width;

  @override
  Widget build(BuildContext context) {
    final clampedStamina = clampedStaminaValue(stamina);
    final fill = staminaFillForValue(clampedStamina);
    final fillColor = staminaColorForClampedValue(clampedStamina);
    final colors = Theme.of(context).colorScheme;
    final trackColor = colors.surfaceContainerLow;
    final indicatorWidth = width.clamp(32.0, 36.0).toDouble();

    return Semantics(
      container: true,
      label: l10n.squad_staminaIndicatorSemantics(
        _formatStamina(clampedStamina),
      ),
      child: ExcludeSemantics(
        child: Container(
          key: const ValueKey('squad-stamina-indicator'),
          width: indicatorWidth,
          height: 10,
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: Border.all(color: colors.outline, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: trackColor),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: fill,
                  child: ColoredBox(color: fillColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small text caption placed under a metric bar (form/stamina) so both
/// tracks are identifiable at a glance. Purely visual: the bar underneath
/// already carries its own [Semantics] label, so the caption is excluded
/// from the accessibility tree to avoid announcing the value twice.
class _MetricBarCaption extends StatelessWidget {
  const _MetricBarCaption({
    required this.label,
    required this.width,
    required this.bar,
  });

  final String label;
  final double width;
  final Widget bar;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          bar,
        ],
      ),
    );
  }
}

class PotentialStars extends StatelessWidget {
  const PotentialStars({
    super.key,
    required this.playerId,
    required this.stars,
    required this.color,
    required this.l10n,
    this.iconSize = 13,
  });

  final String playerId;
  final double stars;
  final Color color;
  final AppLocalizations l10n;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final segments = StaffPresentation.starsForRaw(stars);
    final prefix = 'squad-potential-stars-$playerId';
    return Semantics(
      container: true,
      label: l10n.squad_potentialStarsSemantics(stars.toStringAsFixed(1)),
      child: ExcludeSemantics(
        child: Row(
          key: ValueKey<String>(prefix),
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < segments.length; index++)
              Icon(
                switch (segments[index]) {
                  GraphicStar.full => Icons.star,
                  GraphicStar.half => Icons.star_half,
                  GraphicStar.empty => Icons.star_border,
                },
                key: ValueKey<String>('$prefix-star-$index'),
                size: iconSize,
                color: color,
              ),
          ],
        ),
      ),
    );
  }
}

class OptimalRoleLabel extends StatelessWidget {
  const OptimalRoleLabel({
    super.key,
    required this.playerId,
    required this.label,
    required this.l10n,
    required this.compact,
  });

  final String playerId;
  final String label;
  final AppLocalizations l10n;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final maxChars = compact ? 10 : 14;
    final display = compactRoleLabel(label, maxChars: maxChars);
    return Semantics(
      container: true,
      label: l10n.squad_optimalRoleSemantics(label),
      child: ExcludeSemantics(
        child: ConstrainedBox(
          key: ValueKey<String>('squad-optimal-role-$playerId'),
          constraints: BoxConstraints(maxWidth: compact ? 72 : 96),
          child: Text(
            display,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
              height: 1.1,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

/// A single reserved status slot for injury and suspension meanings.
class StatusIcons extends StatelessWidget {
  const StatusIcons({
    super.key,
    required this.hasActiveInjury,
    required this.hasActiveSuspension,
    required this.l10n,
    this.iconSize = 20,
  });

  final bool hasActiveInjury;
  final bool hasActiveSuspension;
  final AppLocalizations l10n;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final presentation = statusSlotPresentation(
      SquadStatus(
        hasActiveInjury: hasActiveInjury,
        hasActiveSuspension: hasActiveSuspension,
      ),
    );
    final semanticLabels = presentation.semanticStatuses
        .map(_localizedStatusLabel)
        .toList(growable: false);
    final labelsForSlot = semanticLabels.isEmpty
        ? <String>[l10n.squad_statusSlotEmpty]
        : semanticLabels;
    final tooltipMessage = labelsForSlot.join('. ');
    final slotWidth = math.max(25.0, iconSize + 5.0).toDouble();

    IconData? icon;
    Color? color;
    switch (presentation.visual) {
      case StatusVisualKind.none:
        break;
      case StatusVisualKind.injury:
        icon = Icons.healing_outlined;
        color = colors.error;
      case StatusVisualKind.suspension:
        icon = Icons.gavel_outlined;
        color = colors.tertiary;
    }

    return Tooltip(
      message: tooltipMessage,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: SizedBox(
          width: slotWidth,
          height: 32,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (final label in labelsForSlot)
                Semantics(
                  container: true,
                  label: label,
                  child: const SizedBox.expand(),
                ),
              if (icon != null)
                ExcludeSemantics(
                  child: Icon(icon, color: color, size: iconSize),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _localizedStatusLabel(StatusVisualKind status) {
    switch (status) {
      case StatusVisualKind.none:
        return l10n.squad_statusSlotEmpty;
      case StatusVisualKind.injury:
        return l10n.squad_statusInjury;
      case StatusVisualKind.suspension:
        return l10n.squad_statusSuspension;
    }
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

String _zoneLabel(AppLocalizations l10n, RosterZone zone) {
  switch (zone) {
    case RosterZone.xi:
      return l10n.squad_zoneXi;
    case RosterZone.bench:
      return l10n.squad_zoneBench;
    case RosterZone.reserve:
      return l10n.squad_zoneReserves;
  }
}

String _formatForm(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toString();
}

String _formatStamina(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toString();
}

Color _contrastSafeZoneColor(Color color, Color background) {
  if (contrastRatio(color, background) >= 4.5) return color;

  for (var step = 1; step <= 20; step++) {
    final amount = step / 20;
    final result = Color.lerp(color, Colors.black, amount) ?? color;
    if (contrastRatio(result, background) >= 4.5) return result;
  }
  return Colors.black;
}
