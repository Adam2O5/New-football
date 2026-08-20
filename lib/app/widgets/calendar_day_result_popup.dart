import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:new_football/app/models/calendar_simulation_feedback.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

/// A bounded, non-modal presentation of all match results from one completed
/// calendar day.
///
/// The owner of the calendar screen controls when this widget is inserted and
/// removed. This widget deliberately has no timer, delay, or asynchronous
/// work of its own: all rows are rendered in one scrollable surface so one
/// result cannot race or replace another.
class CalendarDayResultPopup extends StatelessWidget {
  const CalendarDayResultPopup({super.key, required this.feedback});

  static const _maxWidth = 560.0;
  static const _maxHeight = 360.0;
  static const _baseHeight = 104.0;
  static const _rowHeight = 64.0;
  static const _maxRowsHeight = 256.0;

  /// The immutable snapshot for one fully completed calendar day.
  final CalendarDaySimulationFeedback feedback;

  @override
  Widget build(BuildContext context) {
    // A completed day without a persisted result still produces controller
    // feedback so the host can clear stale UI, but it does not need a result
    // popup of its own.
    if (feedback.results.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final title = l10n.calendar_simulationResults_title(
      feedback.week,
      feedback.day,
    );

    return SafeArea(
      minimum: const EdgeInsets.all(12),
      child: Align(
        alignment: Alignment.topCenter,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : _maxWidth;
            final availableHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : _maxHeight;
            final width = math.min(_maxWidth, math.max(0.0, availableWidth));
            final desiredHeight =
                _baseHeight +
                math.min(_maxRowsHeight, feedback.results.length * _rowHeight);
            final height = math.min(
              math.min(_maxHeight, desiredHeight),
              math.max(0.0, availableHeight),
            );

            return SizedBox(
              width: width,
              height: height,
              child: Card(
                key: ValueKey<String>(
                  'calendar-day-result-popup-'
                  '${feedback.runId}-${feedback.sequence}',
                ),
                margin: EdgeInsets.zero,
                child: SingleChildScrollView(
                  key: ValueKey<String>(
                    'calendar-day-result-scroll-'
                    '${feedback.runId}-${feedback.sequence}',
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        key: ValueKey<String>(
                          'calendar-day-result-title-'
                          '${feedback.runId}-${feedback.sequence}',
                        ),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      const SizedBox(height: 4),
                      for (
                        var index = 0;
                        index < feedback.results.length;
                        index++
                      ) ...[
                        _CalendarMatchResultRow(
                          key: ValueKey<String>(
                            'calendar-day-result-row-'
                            '${feedback.runId}-${feedback.sequence}-$index',
                          ),
                          feedback: feedback.results[index],
                        ),
                        if (index < feedback.results.length - 1)
                          const Divider(height: 1),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CalendarMatchResultRow extends StatelessWidget {
  const _CalendarMatchResultRow({super.key, required this.feedback});

  final CalendarMatchFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accessibleResult = l10n.calendar_simulationResults_match(
      feedback.homeTeamName,
      feedback.awayTeamName,
      feedback.homeGoals,
      feedback.awayGoals,
    );

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: accessibleResult,
      child: Tooltip(
        message: accessibleResult,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(feedback.homeTeamName, softWrap: true)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${feedback.homeGoals}:${feedback.awayGoals}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Expanded(
                child: Text(
                  feedback.awayTeamName,
                  softWrap: true,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
