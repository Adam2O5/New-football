import 'package:flutter/material.dart';

import 'package:new_football/app/widgets/branding/club_logo.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

/// Normalizes the two persisted play-in shapes ([PlayInResult] for a
/// finished play-in, [PlayInProgress] for one still in progress) into a
/// single shape the bracket widget can render without branching on type.
class _PlayInMatchup {
  const _PlayInMatchup({
    required this.conference,
    required this.seed7TeamId,
    required this.seed8TeamId,
    required this.seed9TeamId,
    required this.seed10TeamId,
    required this.game7v8,
    required this.game9v10,
    required this.gameFinal,
  });

  final Conference conference;
  final String seed7TeamId;
  final String seed8TeamId;
  final String seed9TeamId;
  final String seed10TeamId;
  final MatchResult? game7v8;
  final MatchResult? game9v10;
  final MatchResult? gameFinal;

  factory _PlayInMatchup.fromResult(PlayInResult r) => _PlayInMatchup(
    conference: r.conference,
    seed7TeamId: r.seed7TeamId,
    seed8TeamId: r.seed8TeamId,
    // PlayInResult doesn't carry seed9/10 explicitly, but game9v10 is
    // required (always played by the time a result exists), so its two
    // participants are exactly seed 9 and seed 10.
    seed9TeamId: r.game9v10.homeTeamId,
    seed10TeamId: r.game9v10.awayTeamId,
    game7v8: r.game7v8,
    game9v10: r.game9v10,
    gameFinal: r.gameFinal,
  );

  factory _PlayInMatchup.fromProgress(PlayInProgress p) => _PlayInMatchup(
    conference: p.conference,
    seed7TeamId: p.seed7TeamId,
    seed8TeamId: p.seed8TeamId,
    seed9TeamId: p.seed9TeamId,
    seed10TeamId: p.seed10TeamId,
    game7v8: p.game7v8,
    game9v10: p.game9v10,
    gameFinal: p.gameFinal,
  );
}

/// Winner of a completed knockout [MatchResult]. Prefers the explicit
/// `winnerTeamId` (set for shootout/extra-time resolutions) and falls back
/// to comparing goals.
String? _winnerOf(MatchResult? result) {
  if (result == null) return null;
  return result.winnerTeamId ??
      (result.homeGoals > result.awayGoals
          ? result.homeTeamId
          : result.awayTeamId);
}

/// Goals scored by [teamId] in [result], or `null` if the game hasn't been
/// played yet or [teamId] isn't a participant.
int? _goalsFor(MatchResult? result, String? teamId) {
  if (result == null || teamId == null) return null;
  if (result.homeTeamId == teamId) return result.homeGoals;
  if (result.awayTeamId == teamId) return result.awayGoals;
  return null;
}

/// Graphical play-in bracket: seed7-vs-8 and seed9-vs-10 feeding into a
/// final decider game, one section per conference present in the data.
class PlayInBracket extends StatelessWidget {
  const PlayInBracket({
    super.key,
    required this.results,
    required this.progress,
    required this.teamName,
  });

  final List<PlayInResult> results;
  final List<PlayInProgress> progress;
  final String Function(String teamId) teamName;

  static const double _gap = 16;
  static const double _connectorWidth = 28;

  @override
  Widget build(BuildContext context) {
    final matchups = [
      ...results.map(_PlayInMatchup.fromResult),
      ...progress.map(_PlayInMatchup.fromProgress),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: matchups
          .map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: _gap),
              child: _conferenceSection(context, m),
            ),
          )
          .toList(),
    );
  }

  Widget _conferenceSection(BuildContext context, _PlayInMatchup m) {
    final l10n = AppLocalizations.of(context)!;
    final winner7v8 = _winnerOf(m.game7v8);
    final finalTopTeamId = winner7v8 == null
        ? null
        : (winner7v8 == m.seed7TeamId ? m.seed8TeamId : m.seed7TeamId);
    final finalBottomTeamId = _winnerOf(m.game9v10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          m.conference == Conference.europe
              ? l10n.standings_tabEast
              : l10n.standings_tabWest,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _BracketNode(
                    topTeamId: m.seed7TeamId,
                    bottomTeamId: m.seed8TeamId,
                    topScore: _goalsFor(m.game7v8, m.seed7TeamId),
                    bottomScore: _goalsFor(m.game7v8, m.seed8TeamId),
                    teamName: teamName,
                  ),
                  const SizedBox(height: _gap),
                  _BracketNode(
                    topTeamId: m.seed9TeamId,
                    bottomTeamId: m.seed10TeamId,
                    topScore: _goalsFor(m.game9v10, m.seed9TeamId),
                    bottomScore: _goalsFor(m.game9v10, m.seed10TeamId),
                    teamName: teamName,
                  ),
                ],
              ),
              SizedBox(
                width: _connectorWidth,
                child: CustomPaint(
                  painter: _BracketConnectorPainter(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              Center(
                child: _BracketNode(
                  topTeamId: finalTopTeamId,
                  bottomTeamId: finalBottomTeamId,
                  topScore: _goalsFor(m.gameFinal, finalTopTeamId),
                  bottomScore: _goalsFor(m.gameFinal, finalBottomTeamId),
                  teamName: teamName,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A single bracket node: two stacked team rows (logo + score once known,
/// full name only via [Tooltip] — see [width] for why). A `null` team id
/// renders as a "?" placeholder — used for a node whose participants aren't
/// decided yet (a play-in final before both semi-games are played, or a
/// playoff round that hasn't been generated yet).
class _BracketNode extends StatelessWidget {
  const _BracketNode({
    required this.topTeamId,
    required this.bottomTeamId,
    required this.topScore,
    required this.bottomScore,
    required this.teamName,
  });

  final String? topTeamId;
  final String? bottomTeamId;
  final int? topScore;
  final int? bottomScore;
  final String Function(String teamId) teamName;

  /// Fixed node width/logo size, shared with [_ConferenceBracketView]'s
  /// column-position math. No team name is shown (there isn't room for it
  /// next to a readable logo on narrow screens — this caused a `RenderFlex`
  /// overflow before), so the logo is the only identifier; the full name is
  /// still available via [Tooltip] (long-press on mobile).
  static const double width = 84;
  static const double _logoSize = 32;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _teamRow(context, topTeamId, topScore),
          const Divider(height: 6),
          _teamRow(context, bottomTeamId, bottomScore),
        ],
      ),
    );
  }

  Widget _teamRow(BuildContext context, String? teamId, int? score) {
    if (teamId == null) {
      return Row(
        children: [
          Container(
            width: _logoSize,
            height: _logoSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Text('?', style: Theme.of(context).textTheme.labelSmall),
          ),
          const Spacer(),
        ],
      );
    }
    return Row(
      children: [
        Tooltip(
          message: teamName(teamId),
          child: TeamLogo(teamId: teamId, size: _logoSize),
        ),
        const Spacer(),
        if (score != null)
          Text('$score', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

/// Draws two horizontal stubs from the round-1 nodes' vertical centers,
/// joined by a vertical segment, continuing as one horizontal line into the
/// next round's node.
class _BracketConnectorPainter extends CustomPainter {
  _BracketConnectorPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final topY = size.height * 0.25;
    final bottomY = size.height * 0.75;
    final midY = size.height * 0.5;
    final midX = size.width * 0.5;

    canvas.drawLine(Offset(0, topY), Offset(midX, topY), paint);
    canvas.drawLine(Offset(0, bottomY), Offset(midX, bottomY), paint);
    canvas.drawLine(Offset(midX, topY), Offset(midX, bottomY), paint);
    canvas.drawLine(Offset(midX, midY), Offset(size.width, midY), paint);
  }

  @override
  bool shouldRepaint(covariant _BracketConnectorPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// One pair-merge for [_MergePainter]: two source lines (at [sourceTopY] and
/// [sourceBottomY]) converging into a single line at [targetY].
class _MergeSpec {
  const _MergeSpec({
    required this.sourceTopY,
    required this.sourceBottomY,
    required this.targetY,
  });

  final double sourceTopY;
  final double sourceBottomY;
  final double targetY;
}

/// Draws one or more [_MergeSpec]s in the same canvas — used for the
/// quarter-final -> semi-final gap, which needs two independent merges side
/// by side, as well as single-merge gaps (semi-final -> conference final).
class _MergePainter extends CustomPainter {
  _MergePainter({required this.color, required this.merges});

  final Color color;
  final List<_MergeSpec> merges;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final midX = size.width / 2;

    for (final merge in merges) {
      canvas.drawLine(
        Offset(0, merge.sourceTopY),
        Offset(midX, merge.sourceTopY),
        paint,
      );
      canvas.drawLine(
        Offset(0, merge.sourceBottomY),
        Offset(midX, merge.sourceBottomY),
        paint,
      );
      canvas.drawLine(
        Offset(midX, merge.sourceTopY),
        Offset(midX, merge.sourceBottomY),
        paint,
      );
      canvas.drawLine(
        Offset(midX, merge.targetY),
        Offset(size.width, merge.targetY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MergePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.merges != merges;
}

/// Graphical bracket for a single conference: 4 quarter-finals -> 2
/// semi-finals -> 1 conference final.
///
/// `PlayoffBracket.quarterFinals` is stored as `[1v8, 2v7, 3v6, 4v5]`
/// (indices 0..3), but the actual advancement pairs index 0 with 3 and 1
/// with 2 (confirmed in `SeasonService._advanceBracket`: `semis[0]` comes
/// from `quarters[0]` + `quarters[3]`, `semis[1]` from `quarters[1]` +
/// `quarters[2]`). Displaying them in that raw order would draw crossing
/// connector lines, so this widget reorders them to `[QF0, QF3, QF1, QF2]`
/// for display so that paired series sit next to each other.
class _ConferenceBracketView extends StatelessWidget {
  const _ConferenceBracketView({required this.bracket, required this.teamName});

  final PlayoffBracket bracket;
  final String Function(String teamId) teamName;

  static const double _nodeWidth = _BracketNode.width;
  // Two 32px logo rows + divider + vertical padding, now that names are
  // gone (see _BracketNode) — taller than the old 64 because the logo grew
  // from 20 to 32px.
  static const double _nodeHeight = 82;
  static const double _gapWithinPair = 16;
  static const double _gapBetweenPairs = 32;
  static const double _colGap = 32;

  @override
  Widget build(BuildContext context) {
    final qf = [
      bracket.quarterFinals[0],
      bracket.quarterFinals[3],
      bracket.quarterFinals[1],
      bracket.quarterFinals[2],
    ];

    final qfY = <double>[
      0,
      _nodeHeight + _gapWithinPair,
      2 * _nodeHeight + _gapWithinPair + _gapBetweenPairs,
      3 * _nodeHeight + 2 * _gapWithinPair + _gapBetweenPairs,
    ];
    final totalHeight = qfY[3] + _nodeHeight;

    double centerOf(double y) => y + _nodeHeight / 2;

    final sf0MidY = (centerOf(qfY[0]) + centerOf(qfY[1])) / 2;
    final sf1MidY = (centerOf(qfY[2]) + centerOf(qfY[3])) / 2;
    final sfY = [sf0MidY - _nodeHeight / 2, sf1MidY - _nodeHeight / 2];

    final cfMidY = (centerOf(sfY[0]) + centerOf(sfY[1])) / 2;
    final cfY = cfMidY - _nodeHeight / 2;

    PlayoffSeries? sfAt(int i) =>
        i < bracket.semiFinals.length ? bracket.semiFinals[i] : null;
    final sf0 = sfAt(0);
    final sf1 = sfAt(1);
    final cf = bracket.conferenceFinal.isNotEmpty
        ? bracket.conferenceFinal[0]
        : null;

    const qfX = 0.0;
    const sfX = _nodeWidth + _colGap;
    const cfX = sfX + _nodeWidth + _colGap;
    final totalWidth = cfX + _nodeWidth;

    final lineColor = Theme.of(context).colorScheme.outlineVariant;

    return SizedBox(
      width: totalWidth,
      height: totalHeight,
      child: Stack(
        children: [
          Positioned(
            left: qfX + _nodeWidth,
            top: 0,
            width: _colGap,
            height: totalHeight,
            child: CustomPaint(
              painter: _MergePainter(
                color: lineColor,
                merges: [
                  _MergeSpec(
                    sourceTopY: centerOf(qfY[0]),
                    sourceBottomY: centerOf(qfY[1]),
                    targetY: centerOf(sfY[0]),
                  ),
                  _MergeSpec(
                    sourceTopY: centerOf(qfY[2]),
                    sourceBottomY: centerOf(qfY[3]),
                    targetY: centerOf(sfY[1]),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: sfX + _nodeWidth,
            top: 0,
            width: _colGap,
            height: totalHeight,
            child: CustomPaint(
              painter: _MergePainter(
                color: lineColor,
                merges: [
                  _MergeSpec(
                    sourceTopY: centerOf(sfY[0]),
                    sourceBottomY: centerOf(sfY[1]),
                    targetY: centerOf(cfY),
                  ),
                ],
              ),
            ),
          ),
          for (var i = 0; i < 4; i++)
            Positioned(
              left: qfX,
              top: qfY[i],
              width: _nodeWidth,
              child: _seriesNode(qf[i]),
            ),
          Positioned(
            left: sfX,
            top: sfY[0],
            width: _nodeWidth,
            child: sf0 != null
                ? _seriesNode(sf0)
                : _phantomNode(qf[0].winnerTeamId, qf[1].winnerTeamId),
          ),
          Positioned(
            left: sfX,
            top: sfY[1],
            width: _nodeWidth,
            child: sf1 != null
                ? _seriesNode(sf1)
                : _phantomNode(qf[2].winnerTeamId, qf[3].winnerTeamId),
          ),
          Positioned(
            left: cfX,
            top: cfY,
            width: _nodeWidth,
            child: cf != null
                ? _seriesNode(cf)
                : _phantomNode(sf0?.winnerTeamId, sf1?.winnerTeamId),
          ),
        ],
      ),
    );
  }

  Widget _seriesNode(PlayoffSeries series) => _BracketNode(
    topTeamId: series.higherSeedTeamId,
    bottomTeamId: series.lowerSeedTeamId,
    topScore: series.higherSeedWins,
    bottomScore: series.lowerSeedWins,
    teamName: teamName,
  );

  /// A round that hasn't been generated yet ([PlayoffBracket] only creates
  /// semi/conference-final series once the previous round is complete).
  /// Shows known prospective participants (previous round's winner) where
  /// available, "TBD" otherwise — no score, since the series doesn't exist.
  Widget _phantomNode(String? topTeamId, String? bottomTeamId) => _BracketNode(
    topTeamId: topTeamId,
    bottomTeamId: bottomTeamId,
    topScore: null,
    bottomScore: null,
    teamName: teamName,
  );
}

/// Full playoff visualization: one [_ConferenceBracketView] per conference,
/// followed by the league final merging both conference champions.
class PlayoffBracketView extends StatelessWidget {
  const PlayoffBracketView({
    super.key,
    required this.brackets,
    required this.teamName,
  });

  final List<PlayoffBracket> brackets;
  final String Function(String teamId) teamName;

  PlayoffBracket? _bracketFor(Conference conference) {
    for (final bracket in brackets) {
      if (bracket.conference == conference) return bracket;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final bracket in brackets) ...[
            Text(
              bracket.conference == Conference.europe
                  ? l10n.standings_tabEast
                  : l10n.standings_tabWest,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            _ConferenceBracketView(bracket: bracket, teamName: teamName),
            const SizedBox(height: 24),
          ],
          Text(
            l10n.standings_leagueFinal,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _leagueFinalNode(),
        ],
      ),
    );
  }

  Widget _leagueFinalNode() {
    final finalSeries = brackets
        .map((b) => b.leagueFinal)
        .firstWhere((s) => s != null, orElse: () => null);

    String? winnerOf(Conference conference) {
      final bracket = _bracketFor(conference);
      if (bracket == null || bracket.conferenceFinal.isEmpty) return null;
      return bracket.conferenceFinal[0].winnerTeamId;
    }

    return _BracketNode(
      topTeamId: finalSeries?.higherSeedTeamId ?? winnerOf(Conference.europe),
      bottomTeamId:
          finalSeries?.lowerSeedTeamId ?? winnerOf(Conference.restOfTheWorld),
      topScore: finalSeries?.higherSeedWins,
      bottomScore: finalSeries?.lowerSeedWins,
      teamName: teamName,
    );
  }
}
