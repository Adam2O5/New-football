import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';

/// Lineup cohesion calculation (`squad_management.md`).
///
/// Cohesion is a per-match score (0–100) describing how well the starting XI
/// fit their assigned positions and roles. It modifies effective attributes
/// via `cohesionMult` in the match engine (`matchday_model.md` §4).
class CohesionService {
  const CohesionService();

  /// Per-player position bonus.
  static const int _positionCorrect = 2;
  static const int _positionForeign = -5;

  /// Per-player optimal role bonus.
  static const int _optimalRoleBonus = 2;

  /// Compute raw cohesion score for a lineup (0–100, clamped).
  ///
  /// Each player in [lineup] contributes:
  /// - +2 if playing their natural position, -5 if foreign
  /// - +2 if playing their optimal role (no penalty otherwise)
  ///
  /// Base score = 50 + sum of bonuses, clamped to [0, 100].
  int computeCohesion(List<Player> lineup) {
    if (lineup.isEmpty) return 50;

    var bonus = 0;
    for (final p in lineup) {
      // Position check: assigned role type maps to position(s).
      final positionFits = _positionFitsRole(p.position, p.state.role);
      bonus += positionFits ? _positionCorrect : _positionForeign;

      // Optimal role check.
      if (_rolesMatch(p.state.role, p.optimalRole)) {
        bonus += _optimalRoleBonus;
      }
    }

    return (50 + bonus).clamp(0, 100);
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
  double cohesionMult(int cohesion, {StaffMember? headCoach}) {
    final baseMult = _baseCohesionMult(cohesion);
    final motivationFactor = _hcMotivationFactor(headCoach);
    return baseMult * motivationFactor;
  }

  static double _baseCohesionMult(int cohesion) {
    if (cohesion <= 20) return 1.01;
    if (cohesion <= 40) return 1.02;
    if (cohesion <= 60) return 1.03;
    if (cohesion <= 80) return 1.04;
    return 1.05;
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
  static double _hcMotivationFactor(StaffMember? hc) {
    if (hc == null) return 1.0;
    final motivation = hc.attributes.motivation;
    if (motivation < 1.0) return 0.97;
    if (motivation < 2.0) return 0.99;
    if (motivation < 3.0) return 1.00;
    if (motivation < 4.0) return 1.01;
    return 1.03;
  }

  /// Whether the player's natural position matches the assigned role type.
  static bool _positionFitsRole(Position position, AssignedRole role) {
    return role.map(
      gk: (_) => position == Position.gk,
      cb: (_) => position == Position.cb,
      fullBack: (_) => position == Position.lb || position == Position.rb,
      wingBack: (_) => position == Position.lwb || position == Position.rwb,
      cdm: (_) => position == Position.cdm,
      cm: (_) => position == Position.cm,
      cam: (_) => position == Position.cam,
      winger: (_) => position == Position.lw || position == Position.rw,
      striker: (_) => position == Position.st,
    );
  }

  /// Two AssignedRole instances match if they have the same discriminator type
  /// AND the same inner role variant.
  static bool _rolesMatch(AssignedRole a, AssignedRole b) {
    // freezed union equality handles this correctly.
    return a == b;
  }
}
