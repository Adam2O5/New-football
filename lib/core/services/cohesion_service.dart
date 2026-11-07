import 'package:new_football/core/tactics/position_role_fit.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/balance/balance_config.dart';

/// Lineup cohesion calculation (`squad_management.md`).
///
/// Cohesion is a per-match score (0–100) describing how well the starting XI
/// fit their assigned positions and roles. It modifies effective attributes
/// via `cohesionMult` in the match engine (`matchday_model.md` §4).
class CohesionService {
  const CohesionService({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  /// Compute raw cohesion score for a lineup (0–100, clamped).
  ///
  /// Each player in [lineup] contributes:
  /// - +2 if playing their natural position, -5 if foreign
  /// - +2 if playing their optimal role (no penalty otherwise)
  ///
  /// Base score = 50 + sum of bonuses, clamped to [0, 100].
  int computeCohesion(List<Player> lineup) {
    final b = balance.chemistry;
    if (lineup.isEmpty) return b.cohesionBase;

    var bonus = 0;
    for (final p in lineup) {
      // Position check: assigned role type maps to position(s).
      final positionFits = positionFitsRole(p.position, p.state.role);
      bonus += positionFits
          ? b.cohesionCorrectPosition
          : b.cohesionForeignPosition;

      // Optimal role check.
      if (_rolesMatch(p.state.role, p.optimalRole)) {
        bonus += b.cohesionOptimalRole;
      }
    }

    return (b.cohesionBase + bonus).clamp(b.scoreMin, b.scoreMax);
  }

  /// Cohesion multiplier for the match engine.
  ///
  /// | Cohesion | Mult |
  /// | 0–20     | 1.01 |
  /// | 21–40    | 1.02 |
  /// | 41–60    | 1.03 |
  /// | 61–80    | 1.04 |
  /// | 81–100   | 1.05 |
  ///
  /// Then multiplied by HC Motivation factor (`staff.md`).
  double cohesionMult(num cohesion, {StaffMember? headCoach}) {
    final baseMult = _baseCohesionMult(cohesion.toDouble());
    final motivationFactor = _hcMotivationFactor(headCoach);
    return baseMult * motivationFactor;
  }

  double _baseCohesionMult(double cohesion) {
    for (final (upperBound, multiplier)
        in balance.chemistry.cohesionMultipliers) {
      if (cohesion <= upperBound) return multiplier;
    }
    return balance.chemistry.cohesionMultipliers.last.$2;
  }

  /// HC Motivation multiplier (`staff.md`).
  /// Maps motivation attribute (0–5 stars scale, stored as 0.0–5.0)
  /// to a multiplier.
  ///
  /// | Motivation ★ | Multiplier |
  /// | 0–1          | 0.97       |
  /// | 1–2          | 0.99       |
  /// | 2–3          | 1.00       |
  /// | 3–4          | 1.01       |
  /// | 4–5          | 1.03       |
  ///
  /// No HC = 1.00 (no bonus, no penalty beyond empty slot effects elsewhere).
  double _hcMotivationFactor(StaffMember? hc) {
    if (hc == null) return 1.0;
    final motivation = hc.attributes.motivation;
    for (final (upperBound, multiplier)
        in balance.chemistry.headCoachMotivationMultipliers) {
      if (motivation < upperBound) return multiplier;
    }
    return balance.chemistry.headCoachMotivationMultipliers.last.$2;
  }

  /// Two AssignedRole instances match if they have the same discriminator type
  /// AND the same inner role variant.
  static bool _rolesMatch(AssignedRole a, AssignedRole b) {
    // freezed union equality handles this correctly.
    return a == b;
  }
}
