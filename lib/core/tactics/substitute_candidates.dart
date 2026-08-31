import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';

const int kVisibleSubstituteCandidateLimit = 10;

const Map<Position, List<Position>> _substituteOptionsByPosition = {
  Position.gk: [Position.gk],
  Position.lb: [Position.lb, Position.lwb, Position.rb, Position.rwb],
  Position.rb: [Position.rb, Position.rwb, Position.lb, Position.lwb],
  Position.cb: [Position.cb, Position.lb, Position.rb, Position.cdm],
  Position.lwb: [
    Position.lwb,
    Position.lb,
    Position.rwb,
    Position.rb,
    Position.lw,
  ],
  Position.rwb: [
    Position.rwb,
    Position.rb,
    Position.lwb,
    Position.lb,
    Position.rw,
  ],
  Position.cdm: [Position.cdm, Position.cm, Position.cb],
  Position.cm: [Position.cm, Position.cdm, Position.cam],
  Position.cam: [Position.cam, Position.cm, Position.st],
  Position.lw: [Position.lw, Position.rw, Position.st],
  Position.rw: [Position.rw, Position.lw, Position.st],
  Position.st: [Position.st, Position.lw, Position.rw, Position.cam],
};

List<Position> substituteOptionsFor(Position position) =>
    _substituteOptionsByPosition[position] ?? [position];

List<Player> allSubstituteCandidatesFor({
  required Team team,
  required Player outPlayer,
}) {
  final xiIds = team.lineupPlayerIds.toSet();
  final allowedPositions = substituteOptionsFor(outPlayer.position);
  final positionPriority = {
    for (var index = 0; index < allowedPositions.length; index++)
      allowedPositions[index]: index,
  };

  final candidates = team.roster
      .where((player) => !xiIds.contains(player.id))
      .where((player) => allowedPositions.contains(player.position))
      .toList();

  candidates.sort((a, b) {
    final aExact = a.position == outPlayer.position;
    final bExact = b.position == outPlayer.position;
    if (aExact != bExact) {
      return aExact ? -1 : 1;
    }

    final aPriority = positionPriority[a.position] ?? allowedPositions.length;
    final bPriority = positionPriority[b.position] ?? allowedPositions.length;
    if (aPriority != bPriority) {
      return aPriority.compareTo(bPriority);
    }

    return b.overall().compareTo(a.overall());
  });

  return candidates;
}

List<Player> substituteCandidatesFor({
  required Team team,
  required Player outPlayer,
  int limit = kVisibleSubstituteCandidateLimit,
}) {
  final allCandidates = allSubstituteCandidatesFor(
    team: team,
    outPlayer: outPlayer,
  );

  if (allCandidates.length <= limit) {
    return allCandidates;
  }

  return allCandidates.take(limit).toList();
}
