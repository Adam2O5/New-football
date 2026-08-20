import 'package:flutter/material.dart';

/// A single day cell in the calendar's seven-column grid.
///
/// The screen owns date mapping and selection state. This widget only renders
/// the supplied snapshot, keeping the tile's hit target and indicator meaning
/// independent from the grid delegate that lays it out.
class CalendarDayTile extends StatelessWidget {
  const CalendarDayTile({
    super.key,
    required this.date,
    required this.isInMonth,
    required this.isEnabled,
    required this.isToday,
    required this.isSelected,
    required this.matchCount,
    required this.playerMatchLabel,
    required this.eventLabels,
    required this.onTap,
  });

  final DateTime date;
  final bool isInMonth;
  final bool isEnabled;
  final bool isToday;
  final bool isSelected;
  final int matchCount;
  final String? playerMatchLabel;
  final List<String> eventLabels;
  final VoidCallback? onTap;

  String? get matchTooltip {
    if (playerMatchLabel != null) return playerMatchLabel;
    if (matchCount > 0) return '$matchCount matches';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchMessage = matchTooltip;
    final eventMessage = eventLabels.isEmpty ? null : eventLabels.join('\n');
    final hasIndicators = matchMessage != null || eventMessage != null;
    final hasSelectionBorder = isSelected && !isToday;
    final borderWidth = hasSelectionBorder ? 1.5 : 0.0;

    return Opacity(
      opacity: isInMonth ? 1.0 : 0.35,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isToday
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.45)
                : null,
            borderRadius: BorderRadius.circular(8),
            border: hasSelectionBorder
                ? Border.all(
                    color: theme.colorScheme.primary,
                    width: borderWidth,
                  )
                : null,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // BoxDecoration paints its border inside the tile. Reserve the
              // border on every side before laying out the content so neither
              // the number nor an indicator can paint under the selection.
              final horizontalInset =
                  _adaptiveInset(constraints.maxWidth, minimum: 2.0) +
                  borderWidth;
              final verticalInset =
                  _adaptiveInset(constraints.maxHeight, minimum: 1.5) +
                  borderWidth;
              final contentHeight = constraints.maxHeight.isFinite
                  ? (constraints.maxHeight - verticalInset * 2).clamp(
                      0.0,
                      double.infinity,
                    )
                  : double.infinity;
              final indicatorGap = hasIndicators && contentHeight.isFinite
                  ? (contentHeight >= 2.0 ? 2.0 : 0.0)
                  : (hasIndicators ? 2.0 : 0.0);

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalInset,
                  verticalInset,
                  horizontalInset,
                  verticalInset,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Semantics(
                          container: true,
                          excludeSemantics: true,
                          label: '${date.day}',
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.topLeft,
                            child: Text(
                              '${date.day}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isEnabled ? null : theme.disabledColor,
                                fontWeight: isToday ? FontWeight.bold : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (hasIndicators) ...[
                      SizedBox(height: indicatorGap),
                      Flexible(
                        fit: FlexFit.tight,
                        child: _CalendarDayIndicators(
                          matchTooltip: matchMessage,
                          eventTooltip: eventMessage,
                          isPlayerMatch: playerMatchLabel != null,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Uses normal-sized indicators when the complete row fits, then a
/// deterministic dense row and a bounded scale-down fallback. Neither
/// indicator is removed, and the two Tooltip nodes remain separate in both
/// variants.
class _CalendarDayIndicators extends StatelessWidget {
  const _CalendarDayIndicators({
    required this.matchTooltip,
    required this.eventTooltip,
    required this.isPlayerMatch,
  });

  final String? matchTooltip;
  final String? eventTooltip;
  final bool isPlayerMatch;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final indicatorCount =
            (matchTooltip == null ? 0 : 1) + (eventTooltip == null ? 0 : 1);
        final normalIconSize = 12.0;
        final normalGap = indicatorCount > 1 ? 2.0 : 0.0;
        final normalWidth = indicatorCount * normalIconSize + normalGap;
        final normalFits =
            (!constraints.maxWidth.isFinite ||
                constraints.maxWidth >= normalWidth) &&
            (!constraints.maxHeight.isFinite ||
                constraints.maxHeight >= normalIconSize);
        final iconSize = normalFits ? normalIconSize : 10.0;
        final gap = indicatorCount > 1 ? (normalFits ? normalGap : 1.0) : 0.0;

        final indicators = <Widget>[];
        if (matchTooltip != null) {
          indicators.add(
            Tooltip(
              key: const ValueKey<String>('calendar-match-indicator'),
              message: matchTooltip!,
              child: Icon(
                Icons.sports_soccer,
                size: iconSize,
                color: isPlayerMatch ? Colors.greenAccent : Colors.white70,
              ),
            ),
          );
        }
        if (eventTooltip != null) {
          if (indicators.isNotEmpty) {
            indicators.add(SizedBox(width: gap));
          }
          indicators.add(
            Tooltip(
              key: const ValueKey<String>('calendar-event-indicator'),
              message: eventTooltip!,
              child: Icon(
                Icons.event_available_outlined,
                size: iconSize,
                color: Colors.amber,
              ),
            ),
          );
        }

        // FittedBox is only a final bounded fallback. It scales the complete
        // row, including the gap, so both icons remain distinct without using
        // clipping or an unconstrained Row.
        return Align(
          alignment: Alignment.centerLeft,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(mainAxisSize: MainAxisSize.min, children: indicators),
          ),
        );
      },
    );
  }
}

double _adaptiveInset(double extent, {required double minimum}) {
  if (!extent.isFinite || extent <= 0) return minimum;
  return (extent * 0.12).clamp(minimum, 6.0).toDouble();
}
