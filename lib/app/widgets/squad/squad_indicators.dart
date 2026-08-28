import 'package:flutter/material.dart';
import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

/// Presents the current roster count against its configured inclusive range.
///
/// The in-range/out-of-range icon and the numeric count are rendered above
/// the track rather than inline with it; the track itself no longer shows
/// the minimum/maximum endpoint labels.
class RosterSizeIndicator extends StatelessWidget {
  const RosterSizeIndicator({
    super.key,
    required this.l10n,
    required this.count,
    required this.min,
    required this.max,
  });

  final AppLocalizations l10n;
  final int count;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    final presentation = rosterSizePresentation(
      count: count,
      min: min,
      max: max,
    );
    final stateLabel = presentation.isInRange
        ? l10n.squad_rosterStateInRange
        : l10n.squad_rosterStateOutOfRange;
    final semanticsLabel = l10n.squad_rosterSizeSemantics(
      presentation.count,
      presentation.min,
      presentation.max,
      stateLabel,
    );
    final colorScheme = Theme.of(context).colorScheme;
    final rangeColor = interpolateStops(
      presentation.isInRange ? 1 : 0,
      _rangeStateColorStops,
    );

    return Semantics(
      key: const ValueKey<String>('squad-size-indicator'),
      container: true,
      excludeSemantics: true,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.32),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            l10n.squad_rosterSizeLabel,
                            key: const ValueKey<String>(
                              'squad-size-indicator-label',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _RangeStateIcon(
                          color: rangeColor,
                          presentation: presentation,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: l10n.squad_rosterCount(presentation.count),
                    child: Text(
                      '${presentation.count}',
                      key: const ValueKey<String>('squad-size-indicator-count'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              RangeTrack(
                key: const ValueKey<String>('squad-size-indicator-range-track'),
                presentation: presentation,
                fillColor: rangeColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Binary red/out-of-range vs. green/in-range colour scale for the squad
/// size indicator's icon and track fill, resolved via [interpolateStops] for
/// consistency with the rest of the app's colour interpolation utilities.
const List<ColorStop> _rangeStateColorStops = <ColorStop>[
  ColorStop(value: 0, color: Colors.red),
  ColorStop(value: 1, color: Colors.green),
];

class _RangeStateIcon extends StatelessWidget {
  const _RangeStateIcon({required this.color, required this.presentation});

  final Color color;
  final RosterSizePresentation presentation;

  @override
  Widget build(BuildContext context) {
    return Icon(
      presentation.iconState == RosterSizeIconState.check
          ? Icons.check
          : Icons.close,
      key: const ValueKey<String>('squad-size-indicator-state-icon'),
      color: color,
      semanticLabel: null,
    );
  }
}

/// A bounded horizontal range track.
///
/// [RosterSizePresentation.clampedProgress] is already guaranteed to be in
/// the inclusive 0–1 interval by the presentation utility. The track still
/// uses a [LayoutBuilder] and a fractional child so its fill is always sized
/// from the constraints supplied by its parent rather than a device width.
class RangeTrack extends StatelessWidget {
  const RangeTrack({
    super.key,
    required this.presentation,
    required this.fillColor,
  });

  final RosterSizePresentation presentation;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          key: const ValueKey<String>('squad-size-indicator-track-bar'),
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 8,
            width: constraints.maxWidth,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(color: colors.surfaceContainerHighest),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: constraints.maxWidth * presentation.clampedProgress,
                  child: ColoredBox(
                    key: const ValueKey<String>(
                      'squad-size-indicator-track-fill',
                    ),
                    color: fillColor,
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

/// A 0–100 metric bar (lineup cohesion, chemistry, atmosphere).
///
/// The numeric [value] is shown above the track; unlike [RosterSizeIndicator]
/// there is no in-range/out-of-range icon, since these metrics do not have a
/// configured target range. Fill colour is derived from [value] via
/// [percentColorForClampedValue].
class SquadValueBar extends StatelessWidget {
  const SquadValueBar({super.key, required this.label, required this.value});

  final String label;
  final num value;

  @override
  Widget build(BuildContext context) {
    final clampedValue = clampedPercentValue(value.toDouble());
    final trackColor = percentColorForClampedValue(clampedValue);
    final fill = percentFillForValue(clampedValue);
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: '$label: ${clampedValue.round()}',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.32),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${clampedValue.round()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              LayoutBuilder(
                builder: (context, constraints) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: SizedBox(
                      height: 8,
                      width: constraints.maxWidth,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ColoredBox(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            width: constraints.maxWidth * fill,
                            child: ColoredBox(color: trackColor),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
