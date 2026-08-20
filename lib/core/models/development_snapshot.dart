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
  Position.cb ||
  Position.lb ||
  Position.rb ||
  Position.lwb ||
  Position.rwb => 1,
  Position.cdm || Position.cm || Position.cam => 2,
  Position.lw || Position.rw => 3,
  Position.st => 4,
};

/// Serialized names of the attributes relevant to [role], in canonical order.
///
/// Thin projection of [StaffRatingSystem.roleRelevantAttributes]: this file
/// keeps no role → attributes mapping of its own, so the snapshot can never
/// drift from the RawOverall used by the domain. `headCoach` therefore excludes
/// the legacy `development` field, and `physio` keeps the existing serialized
/// spelling `regenaration`.
List<String> attributesForRole(StaffRole role) =>
    StaffRatingSystem.serializedNamesForRole(role);

/// Resolves the staff attribute serialized as [name] from [attrs].
///
/// Delegates to the canonical key table: a recognized name returns the matching
/// field, and an UnknownAttribute returns `0.0` without throwing. A relevant
/// field missing from legacy JSON decodes to the `StaffAttributes` default
/// `0.0`, so absent data reads as `0.0` through the same path.
double staffAttributeValue(StaffAttributes attrs, String name) {
  final key = StaffRatingSystem.keyForSerializedName(name);
  if (key == null) return 0.0;
  return StaffRatingSystem.attributeValue(attrs, key);
}

/// Snapshot of one recognized [TeamStaff] slot for the Development screen.
///
/// Names, current values and deltas are all derived from
/// [StaffRatingSystem.roleRelevantAttributes], so the snapshot shows exactly
/// the attributes that produce the role's RawOverall. [attributeNames],
/// [currentValues] and [deltas] always have the same length and share the
/// canonical order. The type is Flutter-free so it can be asserted directly.
class StaffDevelopmentSnapshot {
  const StaffDevelopmentSnapshot({
    required this.role,
    required this.member,
    required this.attributeNames,
    required this.currentValues,
    required this.deltas,
  });

  /// Snapshot of the [role] slot currently holding [member].
  ///
  /// An EmptySlot (`member == null`) yields the canonical names, `0.0` current
  /// values and `null` deltas: it never borrows another role's attributes and
  /// never keeps a previous occupant's rating. An occupied slot without
  /// `previousAttributes` keeps its current values and reports `null` deltas.
  factory StaffDevelopmentSnapshot.forSlot(
    StaffRole role,
    StaffMember? member,
  ) {
    final names = attributesForRole(role);

    if (member == null) {
      return StaffDevelopmentSnapshot(
        role: role,
        member: null,
        attributeNames: names,
        currentValues: List<double>.filled(names.length, 0.0),
        deltas: List<double?>.filled(names.length, null),
      );
    }

    final current = member.attributes;
    final previous = member.previousAttributes;

    return StaffDevelopmentSnapshot(
      role: role,
      member: member,
      attributeNames: names,
      currentValues: names
          .map((name) => staffAttributeValue(current, name))
          .toList(growable: false),
      deltas: names
          .map(
            (name) => previous == null
                ? null
                : staffAttributeValue(current, name) -
                      staffAttributeValue(previous, name),
          )
          .toList(growable: false),
    );
  }

  /// Snapshots of all six recognized staff slots, in [StaffRole.values] order.
  static List<StaffDevelopmentSnapshot> forTeamStaff(TeamStaff staff) =>
      StaffRole.values
          .map(
            (role) => StaffDevelopmentSnapshot.forSlot(
              role,
              staff.canonicalMember(role),
            ),
          )
          .toList(growable: false);

  /// The recognized slot this snapshot describes.
  final StaffRole role;

  /// Occupant of the slot, or `null` for an EmptySlot.
  final StaffMember? member;

  /// Canonical serialized names of the role-relevant attributes.
  final List<String> attributeNames;

  /// Current attribute values, in [attributeNames] order.
  final List<double> currentValues;

  /// Growth deltas, in [attributeNames] order; `null` means no previous data.
  final List<double?> deltas;

  /// Whether the slot is an EmptySlot rather than an occupied one.
  bool get isEmptySlot => member == null;
}
