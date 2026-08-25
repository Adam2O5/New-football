import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'package:new_football/app/formatters/season_context_lines.dart';

/// Renders season, phase, and calendar position as exactly three lines.
class SeasonContext extends StatelessWidget {
  const SeasonContext({
    super.key,
    required this.lines,
    this.textStyle,
    this.sortKey,
  });

  final SeasonContextLines lines;
  final TextStyle? textStyle;
  final SemanticsSortKey? sortKey;

  static const double _lineHeight = 24;

  @override
  Widget build(BuildContext context) {
    final style = textStyle ?? Theme.of(context).textTheme.bodyMedium;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      sortKey: sortKey,
      child: Column(
        key: const ValueKey<String>('home-season-context'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _line(
            key: const ValueKey<String>('home-season-line'),
            text: lines.seasonLine,
            style: style,
            order: 0,
          ),
          _line(
            key: const ValueKey<String>('home-phase-line'),
            text: lines.phaseLine,
            style: style,
            order: 1,
          ),
          _line(
            key: const ValueKey<String>('home-week-day-line'),
            text: lines.weekDayLine,
            style: style,
            order: 2,
          ),
        ],
      ),
    );
  }

  Widget _line({
    required Key key,
    required String text,
    required TextStyle? style,
    required double order,
  }) {
    return SizedBox(
      key: key,
      width: double.infinity,
      height: _lineHeight,
      child: Semantics(
        container: true,
        excludeSemantics: true,
        label: text,
        sortKey: OrdinalSortKey(order),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
        ),
      ),
    );
  }
}
