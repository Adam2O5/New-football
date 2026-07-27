import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';

enum PlayerSortMode { overall, assignedZone, form, position }

enum RosterZone { xi, bench, reserve }

extension RosterZoneOrder on RosterZone {
  int get order {
    switch (this) {
      case RosterZone.xi:
        return 0;
      case RosterZone.bench:
        return 1;
      case RosterZone.reserve:
        return 2;
    }
  }
}

RosterZone rosterZoneOf(Team team, String playerId) {
  if (team.lineupPlayerIds.contains(playerId)) return RosterZone.xi;
  if (team.benchPlayerIds.contains(playerId)) return RosterZone.bench;
  return RosterZone.reserve;
}

int _positionOrder(Position position) => Position.values.indexOf(position);

/// Sortuje cały roster zespołu wg wybranego kryterium. Nie modyfikuje
/// [team] — to czysto prezentacyjna funkcja pomocnicza dla widoku listy.
List<Player> sortRoster(Team team, List<Player> players, PlayerSortMode mode) {
  final sorted = [...players];
  switch (mode) {
    case PlayerSortMode.overall:
      sorted.sort((a, b) => b.overall().compareTo(a.overall()));
      break;
    case PlayerSortMode.assignedZone:
      sorted.sort((a, b) {
        final zoneA = rosterZoneOf(team, a.id);
        final zoneB = rosterZoneOf(team, b.id);
        final zoneCompare = zoneA.order.compareTo(zoneB.order);
        if (zoneCompare != 0) return zoneCompare;
        return _positionOrder(a.position).compareTo(_positionOrder(b.position));
      });
      break;
    case PlayerSortMode.form:
      sorted.sort((a, b) => b.state.form.compareTo(a.state.form));
      break;
    case PlayerSortMode.position:
      sorted.sort(
        (a, b) =>
            _positionOrder(a.position).compareTo(_positionOrder(b.position)),
      );
      break;
  }
  return sorted;
}
