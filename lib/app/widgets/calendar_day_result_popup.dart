import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:new_football/app/models/calendar_simulation_feedback.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

/// A bounded, non-modal presentation of the player's own match result from
/// one completed calendar day.
///
/// The owner of the calendar screen controls when this widget is inserted and
/// removed. This widget deliberately has no timer, delay, or asynchronous
/// work of its own. It only ever shows the single result belonging to
/// [teamId]; other matches completed the same day are not displayed.
class CalendarDayResultPopup extends StatelessWidget {
  const CalendarDayResultPopup({
    super.key,
    required this.feedback,
    required this.teamId,
  });

  static const _maxWidth = 560.0;
  static const _maxHeight = 360.0;
  static const _baseHeight = 104.0;
  static const _rowHeight = 64.0;

  /// The immutable snapshot for one fully completed calendar day.
  final CalendarDaySimulationFeedback feedback;

  /// The player's own team id. Only the match involving this team, if any,
  /// is shown. `null` means the player has no team yet, so nothing is shown.
  final String? teamId;

  @override
  Widget build(BuildContext context) {
    // No team yet (e.g. career not started), or a completed day without a
    // result for the player's own team: neither needs a result popup.
    final teamId = this.teamId;
    if (teamId == null) return const SizedBox.shrink();
    final ownMatch = _ownMatch(feedback.results, teamId);
    if (ownMatch == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final title = l10n.calendar_simulationResults_title(
      feedback.week,
      feedback.day,
    );
    final borderColor = _resultBorderColor(ownMatch, teamId);
    final cardShape = Theme.of(context).cardTheme.shape;
    final shape = cardShape is RoundedRectangleBorder
        ? cardShape.copyWith(side: BorderSide(color: borderColor, width: 2))
        : RoundedRectangleBorder(
            side: BorderSide(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          );

    return SafeArea(
      minimum: const EdgeInsets.all(12),
      child: Align(
        alignment: Alignment.center,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : _maxWidth;
            final availableHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : _maxHeight;
            final width = math.min(_maxWidth, math.max(0.0, availableWidth));
            final desiredHeight = _baseHeight + _rowHeight;
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
                shape: shape,
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
                      _CalendarMatchResultRow(
                        key: ValueKey<String>(
                          'calendar-day-result-row-'
                          '${feedback.runId}-${feedback.sequence}',
                        ),
                        feedback: ownMatch,
                      ),
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

/// Returns the result belonging to [teamId] from [results], or `null` if
/// that team did not play on this calendar day.
CalendarMatchFeedback? _ownMatch(
  List<CalendarMatchFeedback> results,
  String teamId,
) {
  for (final result in results) {
    if (result.homeTeamId == teamId || result.awayTeamId == teamId) {
      return result;
    }
  }
  return null;
}

/// Win/draw/loss border colour for [match] from [teamId]'s perspective.
Color _resultBorderColor(CalendarMatchFeedback match, String teamId) {
  final isHome = match.homeTeamId == teamId;
  final ownGoals = isHome ? match.homeGoals : match.awayGoals;
  final opponentGoals = isHome ? match.awayGoals : match.homeGoals;
  if (ownGoals > opponentGoals) return Colors.green;
  if (ownGoals < opponentGoals) return Colors.red;
  return Colors.yellow;
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
