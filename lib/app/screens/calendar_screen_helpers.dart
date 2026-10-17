part of 'calendar_screen.dart';

DateTime _week1StartForSeason(int seasonYear) =>
    const CalendarService().week1StartForSeason(seasonYear);

DateTime _dateForInGameWeekDay(int seasonYear, int week, int day) =>
    const CalendarService().dateForWeekDay(seasonYear, week, day);

({int week, int day})? _inGameWeekDayForDate(DateTime date, int seasonYear) =>
    const CalendarService().weekDayForDate(date, seasonYear);

DateTime _monthForInGame(LeagueState league) {
  final d = _dateForInGameWeekDay(
    league.currentSeason.year,
    league.currentWeek,
    league.currentDay,
  );
  return DateTime(d.year, d.month);
}

/// Returns a stable logical extent for each calendar row.
///
/// The width-derived value preserves the old visual ratio, while the
/// height-derived cap keeps a short logical viewport from handing a tile an
/// extent that cannot fit its available row space. MediaQuery and
/// BoxConstraints are both logical Flutter units; physical pixel ratio is
/// deliberately not part of this calculation.
double _calendarTileExtent({
  required double logicalWidth,
  required double logicalHeight,
  required int rowCount,
}) {
  final safeWidth = logicalWidth.isFinite && logicalWidth > 0
      ? logicalWidth
      : 48.0 * 7;
  final tileWidth = safeWidth / 7;
  var extent = tileWidth / 0.85;

  if (logicalHeight.isFinite && logicalHeight > 0 && rowCount > 0) {
    final heightBasedExtent = logicalHeight / rowCount;
    if (heightBasedExtent < extent) extent = heightBasedExtent;
  }

  return extent.clamp(1.0, double.infinity).toDouble();
}

/// Formats a final score. Extra-time goals are already folded into
/// [MatchResult.homeGoals]/[awayGoals] by `_resolvePostseasonTiebreak`, so a
/// game decided in extra time never reaches here tied. A shootout, however,
/// leaves regulation+ET score tied on purpose (penalties aren't goals), so
/// that case needs the shootout score appended — otherwise a knockout draw
/// would render as a plain, impossible "1:1".
String _formatMatchScore(MatchResult result) {
  final base = '${result.homeGoals}:${result.awayGoals}';
  if (!result.wentToShootout) return base;
  return '$base (${result.shootoutHomeGoals}:${result.shootoutAwayGoals})';
}

/// The play-in final's placeholder fixture (before both 7v8 and 9v10 are
/// known) has neither side set to a real team id — it can't be, since which
/// two of the four seeded teams actually reach it isn't decided yet — so it
/// can never match [playerId] by simple id equality the way every other
/// fixture does. This checks conference membership instead: is [playerId]
/// one of that conference's four play-in seeds (win-or-lose, one of them
/// always ends up in the final).
bool _isPlayerInPlayInConference(
  LeagueState league,
  String conferenceName,
  String playerId,
) {
  for (final p in league.currentSeason.playInProgress) {
    if (p.conference.name != conferenceName) continue;
    return p.seed7TeamId == playerId ||
        p.seed8TeamId == playerId ||
        p.seed9TeamId == playerId ||
        p.seed10TeamId == playerId;
  }
  return false;
}
