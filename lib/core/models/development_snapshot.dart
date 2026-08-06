import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';

/// Extension on [Player] providing development delta computation.
///
/// Uses the player's own [Player.previousOvr] and [Player.previousPotential]
/// fields (set at season rollover) to compute deltas.
extension PlayerDevDeltaX on Player {
  /// Computes the difference between the player's current OVR / potential
  /// and the values stored at season start.
  ///
  /// Returns `(0, 0.0)` when no previous values have been stored.
  (int ovrDelta, double potentialDelta) get devDelta {
    final prevOvr = previousOvr;
    final prevPot = previousPotential;
    if (prevOvr == null || prevPot == null) return (0, 0.0);
    final currentOvr = overall().round();
    return (currentOvr - prevOvr, potentialStars - prevPot);
  }
}

/// Position group sort order used by the Players tab.
///
/// GK=0, Defenders=1, Midfielders=2, Wingers=3, Strikers=4.
int positionGroupOrder(Position pos) => switch (pos) {
  Position.gk => 0,
  Position.cb || Position.lb || Position.rb || Position.lwb || Position.rwb => 1,
  Position.cdm || Position.cm || Position.cam => 2,
  Position.lw || Position.rw => 3,
  Position.st => 4,
};

/// Returns the attribute names relevant to [role], matching the mapping
/// used by [StaffAttributesX.overallForRole].
List<String> attributesForRole(StaffRole role) => switch (role) {
  StaffRole.headCoach => ['tactics', 'motivation', 'development'],
  StaffRole.youthCoach => ['development', 'mentoring'],
  StaffRole.scout => ['coverage', 'evaluation'],
  StaffRole.physio => ['rehabilitation', 'regenaration'],
  StaffRole.doctor => ['prevention', 'care'],
  StaffRole.cfo => ['negotiation'],
};

/// Resolves a staff attribute by [name] from [attrs].
///
/// Returns `0.0` for unrecognised names.
double staffAttributeValue(StaffAttributes attrs, String name) => switch (name) {
  'tactics' => attrs.tactics,
  'motivation' => attrs.motivation,
  'development' => attrs.development,
  'mentoring' => attrs.mentoring,
  'coverage' => attrs.coverage,
  'evaluation' => attrs.evaluation,
  'rehabilitation' => attrs.rehabilitation,
  'regenaration' => attrs.regenaration,
  'prevention' => attrs.prevention,
  'care' => attrs.care,
  'negotiation' => attrs.negotiation,
  _ => 0.0,
};
