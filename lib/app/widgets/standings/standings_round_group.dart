import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';

/// A single playoff series paired with the conference it belongs to.
///
/// [conference] is `null` for the league final: that series is not owned by
/// either conference, it's the cross-conference decider.
class ConferenceSeries {
  const ConferenceSeries({required this.conference, required this.series});

  final Conference? conference;
  final PlayoffSeries series;
}

/// All series for a single [PlayoffRound], across both conferences.
///
/// An empty [items] list means the round has not started yet (no bracket
/// has produced series for it), which callers use to decide whether to show
/// an expand button for that round at all.
class RoundGroup {
  const RoundGroup({required this.round, required this.items});

  final PlayoffRound round;
  final List<ConferenceSeries> items;

  /// Groups [brackets] by round, ordered most-important-first
  /// (league final -> conference final -> semi-finals -> quarter-finals),
  /// and drops rounds that have not started (empty series list).
  static List<RoundGroup> fromBrackets(List<PlayoffBracket> brackets) {
    List<ConferenceSeries> collect(
      List<PlayoffSeries> Function(PlayoffBracket bracket) pick,
    ) {
      return brackets
          .expand(
            (bracket) => pick(
              bracket,
            ).map((series) => ConferenceSeries(conference: bracket.conference, series: series)),
          )
          .toList();
    }

    final leagueFinalById = <String, PlayoffSeries>{};
    for (final bracket in brackets) {
      final leagueFinal = bracket.leagueFinal;
      if (leagueFinal != null) {
        leagueFinalById[leagueFinal.id] = leagueFinal;
      }
    }

    final groups = [
      RoundGroup(
        round: PlayoffRound.leagueFinal,
        items: leagueFinalById.values
            .map((series) => ConferenceSeries(conference: null, series: series))
            .toList(),
      ),
      RoundGroup(
        round: PlayoffRound.conferenceFinal,
        items: collect((bracket) => bracket.conferenceFinal),
      ),
      RoundGroup(
        round: PlayoffRound.conferenceSemi,
        items: collect((bracket) => bracket.semiFinals),
      ),
      RoundGroup(
        round: PlayoffRound.conferenceQuarter,
        items: collect((bracket) => bracket.quarterFinals),
      ),
    ];

    groups.removeWhere((group) => group.items.isEmpty);
    return groups;
  }
}
