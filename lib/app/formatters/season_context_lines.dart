import 'package:flutter/widgets.dart';

import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

/// The three localized, ordered values shown in a career header.
@immutable
class SeasonContextLines {
  const SeasonContextLines({
    required this.seasonLine,
    required this.phaseLine,
    required this.weekDayLine,
  });

  /// Builds the presentation lines from the existing league state only.
  factory SeasonContextLines.fromLeague(
    BuildContext context,
    LeagueState league,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return SeasonContextLines(
      seasonLine: l10n.home_seasonLine(league.currentSeason.year),
      phaseLine: l10n.home_phaseLine(
        seasonPhaseLabel(context, league.currentSeason.phase),
      ),
      weekDayLine: l10n.home_weekDayLine(league.currentWeek, league.currentDay),
    );
  }

  final String seasonLine;
  final String phaseLine;
  final String weekDayLine;

  /// Compatibility aliases for callers that refer to the values by role.
  String get season => seasonLine;
  String get phase => phaseLine;
  String get weekDay => weekDayLine;

  /// The required visual and accessibility order.
  List<String> get values => <String>[seasonLine, phaseLine, weekDayLine];
}
