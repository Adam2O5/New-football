part of 'player_list_tile.dart';

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
    final resolvedFrameColor = semanticZoneColor;
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
