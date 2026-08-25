import 'package:flutter/foundation.dart' show immutable;

/// Immutable presentation mapping for one stable team identifier.
///
/// [teamId] is the only business key. Display names, cities, conferences, and
/// any other domain or presentation metadata are intentionally not stored in
/// this record.
@immutable
class ClubBrandingRecord {
  const ClubBrandingRecord({
    required this.teamId,
    required this.logoAsset,
    required this.primaryColorName,
    required this.secondaryColorName,
  });

  /// The stable domain identifier used to resolve this presentation record.
  final String teamId;

  /// The explicitly registered logo asset path for [teamId].
  final String logoAsset;

  /// The semantic token name for the primary club colour.
  final String primaryColorName;

  /// The semantic token name for the secondary club colour.
  final String secondaryColorName;

  @override
  bool operator ==(Object other) {
    return other is ClubBrandingRecord &&
        other.teamId == teamId &&
        other.logoAsset == logoAsset &&
        other.primaryColorName == primaryColorName &&
        other.secondaryColorName == secondaryColorName;
  }

  @override
  int get hashCode =>
      Object.hash(teamId, logoAsset, primaryColorName, secondaryColorName);
}
