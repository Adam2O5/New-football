import 'dart:math';

import 'package:new_football/core/balance/injury_catalog.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';

class InjuryDiagnosis {
  const InjuryDiagnosis({
    required this.definition,
    required this.injury,
    required this.potentialLoss,
  });

  final InjuryDefinition definition;
  final Injury injury;
  final bool potentialLoss;
}

/// Deterministic injury rules shared by match simulation and tests.
class InjuryService {
  const InjuryService();

  static const majorPotentialLossChance = 0.10;

  InjuryDefinition pickDefinition(Random random) {
    final target = random.nextDouble() * InjuryCatalog.totalWeight;
    var cursor = 0.0;
    for (final definition in InjuryCatalog.definitions) {
      cursor += definition.weight;
      if (target < cursor) return definition;
    }
    return InjuryCatalog.definitions.last;
  }

  InjuryDiagnosis diagnose({
    required Random random,
    StaffMember? doctor,
    bool potentialLossRoll = true,
    double? doctorCareMultiplier,
  }) {
    final definition = pickDefinition(random);
    final rawDays = definition.minDays == definition.maxDays
        ? definition.minDays
        : definition.minDays +
              random.nextInt(definition.maxDays - definition.minDays + 1);
    final days = (rawDays * (doctorCareMultiplier ?? doctorCareMult(doctor)))
        .round()
        .clamp(0, 365)
        .toInt();
    final injury = Injury(
      id: definition.id,
      group: definition.group,
      type: definition.type,
      daysTotal: days,
      daysRemaining: days,
    );
    final potentialLoss =
        definition.type == InjuryType.major &&
        potentialLossRoll &&
        random.nextDouble() < majorPotentialLossChance;
    return InjuryDiagnosis(
      definition: definition,
      injury: injury,
      potentialLoss: potentialLoss,
    );
  }

  /// Callback-based counterpart used by the match-owned [MatchRandom]
  /// stream. It deliberately does not allocate a second `Random` instance.
  InjuryDiagnosis diagnoseWithCallbacks({
    required double Function() nextDouble,
    required int Function(int max) nextInt,
    StaffMember? doctor,
    bool potentialLossRoll = true,
    double? doctorCareMultiplier,
  }) {
    final definition = pickDefinitionWithCallback(nextDouble);
    final rawDays = definition.minDays == definition.maxDays
        ? definition.minDays
        : definition.minDays +
              nextInt(definition.maxDays - definition.minDays + 1);
    final days = (rawDays * (doctorCareMultiplier ?? doctorCareMult(doctor)))
        .round()
        .clamp(0, 365)
        .toInt();
    final injury = Injury(
      id: definition.id,
      group: definition.group,
      type: definition.type,
      daysTotal: days,
      daysRemaining: days,
    );
    final potentialLoss =
        definition.type == InjuryType.major &&
        potentialLossRoll &&
        nextDouble() < majorPotentialLossChance;
    return InjuryDiagnosis(
      definition: definition,
      injury: injury,
      potentialLoss: potentialLoss,
    );
  }

  InjuryDefinition pickDefinitionWithCallback(double Function() nextDouble) {
    final target = nextDouble() * InjuryCatalog.totalWeight;
    var cursor = 0.0;
    for (final definition in InjuryCatalog.definitions) {
      cursor += definition.weight;
      if (target < cursor) return definition;
    }
    return InjuryCatalog.definitions.last;
  }

  /// Missing staff is slightly worse than the best 5-star specialist.
  double doctorCareMult(StaffMember? doctor) =>
      _staffMultiplier(doctor, (attributes) => attributes.care);

  double doctorPreventionMult(StaffMember? doctor) =>
      _staffMultiplier(doctor, (attributes) => attributes.prevention);

  double physioRehabMult(StaffMember? physio) =>
      _staffMultiplier(physio, (attributes) {
        return (attributes.rehabilitation + attributes.regenaration) / 2.0;
      });

  Player applyPotentialLoss(Player player, InjuryDiagnosis diagnosis) {
    if (!diagnosis.potentialLoss) return player;
    return player
        .copyWith(
          potentialStars: (player.potentialStars - 0.5)
              .clamp(0.5, 5.0)
              .toDouble(),
        )
        .recalculatePointValue();
  }

  double _staffMultiplier(
    StaffMember? member,
    double Function(StaffAttributes) value,
  ) {
    if (member == null) return 1.05;
    final stars = value(member.attributes).clamp(0.0, 5.0).toDouble();
    return 1.05 - stars * 0.036;
  }
}
