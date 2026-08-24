import 'package:flutter/material.dart';
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

/// Presents the current roster count against its configured inclusive range.
///
/// The count and both endpoint labels are intentionally rendered as separate
/// values. The old combined `size / min–max` label is not used here.
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

    return Semantics(
      key: const ValueKey<String>('squad-size-indicator'),
      container: true,
      excludeSemantics: true,
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: presentation.trackColor.withValues(alpha: 0.08),
            border: Border.all(
              color: presentation.trackColor.withValues(alpha: 0.32),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _RangeStateIcon(presentation: presentation),
                  const SizedBox(width: 8),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Tooltip(
                      message: l10n.squad_rosterCount(presentation.count),
                      child: Text(
                        '${presentation.count}',
                        key: const ValueKey<String>(
                          'squad-size-indicator-count',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RangeTrack(
                      key: const ValueKey<String>(
                        'squad-size-indicator-range-track',
                      ),
                      presentation: presentation,
                      minimumLabel: l10n.squad_rosterMinimum(presentation.min),
                      maximumLabel: l10n.squad_rosterMaximum(presentation.max),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RangeStateIcon extends StatelessWidget {
  const _RangeStateIcon({required this.presentation});

  final RosterSizePresentation presentation;

  @override
  Widget build(BuildContext context) {
    return Icon(
      presentation.iconState == RosterSizeIconState.check
          ? Icons.check
          : Icons.close,
      key: const ValueKey<String>('squad-size-indicator-state-icon'),
      color: presentation.trackColor,
      semanticLabel: null,
    );
  }
}

/// A bounded horizontal range track with distinct endpoint labels.
///
/// [RosterSizePresentation.clampedProgress] is already guaranteed to be in
/// the inclusive 0–1 interval by the presentation utility. The track still
/// uses a [LayoutBuilder] and a fractional child so its fill is always sized
/// from the constraints supplied by its parent rather than a device width.
class RangeTrack extends StatelessWidget {
  const RangeTrack({
    super.key,
    required this.presentation,
    required this.minimumLabel,
    required this.maximumLabel,
  });

  final RosterSizePresentation presentation;
  final String minimumLabel;
  final String maximumLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey<String>('squad-size-indicator-range'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                minimumLabel,
                key: const ValueKey<String>('squad-size-indicator-minimum'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                maximumLabel,
                key: const ValueKey<String>('squad-size-indicator-maximum'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        LayoutBuilder(
          builder: (context, constraints) {
            return ClipRRect(
              key: const ValueKey<String>('squad-size-indicator-track-bar'),
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 8,
                width: constraints.maxWidth,
                child: ColoredBox(
                  color: colors.surfaceContainerHighest,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      key: const ValueKey<String>(
                        'squad-size-indicator-track-fill',
                      ),
                      widthFactor: presentation.clampedProgress,
                      child: ColoredBox(color: presentation.trackColor),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
