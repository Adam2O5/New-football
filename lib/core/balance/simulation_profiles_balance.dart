import 'package:new_football/core/models/enums.dart';

class SequenceStageProfile {
  const SequenceStageProfile({
    required this.attackerPositions,
    required this.defenderPositions,
    required this.attackerWeights,
    required this.defenderWeights,
    this.attackerAerialWeight = 0.0,
    this.defenderAerialWeight = 0.0,
  });

  final Set<Position> attackerPositions;
  final Set<Position> defenderPositions;
  final Map<EffectiveAttribute, double> attackerWeights;
  final Map<EffectiveAttribute, double> defenderWeights;
  final double attackerAerialWeight;
  final double defenderAerialWeight;
}
