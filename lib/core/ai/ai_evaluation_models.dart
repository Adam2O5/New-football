import 'package:new_football/core/models/enums.dart';

/// The seven roster buckets used by the AI valuation model.
enum AiRosterGroup { gk, cb, wideDefenders, centralMidfield, cam, wings, st }

extension AiRosterGroupX on AiRosterGroup {
  String get label => switch (this) {
    AiRosterGroup.gk => 'gk',
    AiRosterGroup.cb => 'cb',
    AiRosterGroup.wideDefenders => 'lb/rb/lwb/rwb',
    AiRosterGroup.centralMidfield => 'cdm/cm',
    AiRosterGroup.cam => 'cam',
    AiRosterGroup.wings => 'lw/rw',
    AiRosterGroup.st => 'st',
  };
}

/// Balance definition for one roster bucket.
class AiRosterGroupDefinition {
  const AiRosterGroupDefinition({
    required this.group,
    required this.positions,
    required this.min,
    required this.target,
    required this.max,
  });

  final AiRosterGroup group;
  final List<Position> positions;
  final int min;
  final int target;
  final int max;

  bool contains(Position position) => positions.contains(position);
}

/// Classification used by the need multiplier and trade policy.
enum AiNeedBand { critical, belowTarget, target, surplus }

/// A fully explainable need calculation for one roster bucket.
class AiPositionNeed {
  const AiPositionNeed({
    required this.definition,
    required this.count,
    required this.bestOvr,
    required this.leagueMedianOvr,
    required this.gapPenalty,
    required this.qualityGap,
    required this.needScore,
    required this.band,
  });

  final AiRosterGroupDefinition definition;
  final int count;
  final double bestOvr;
  final double leagueMedianOvr;
  final double gapPenalty;
  final double qualityGap;
  final double needScore;
  final AiNeedBand band;

  bool get isCritical => band == AiNeedBand.critical;
}

/// One anchor in the canonical draft-slot value curve.
class AiPickValuePoint {
  const AiPickValuePoint({required this.slot, required this.value});

  final double slot;
  final double value;
}

/// Payroll target band for a relative team status.
class AiPayrollBand {
  const AiPayrollBand({
    required this.status,
    required this.minCapFraction,
    required this.maxCapFraction,
    required this.apronPenalty,
  });

  final TeamStatus status;
  final double minCapFraction;
  final double maxCapFraction;
  final int apronPenalty;
}

/// Contract-drag severity from `AI_behaviour.md` §9.3.
enum AiContractDragClass { acceptable, burden, anchor, toxic }

enum AiAssetKind { player, pick, rights, unknown }

/// Explainable valuation of one asset from the recipient club's perspective.
///
/// The model deliberately contains no [PlayerHidden] data. It can therefore
/// be safely used by UI/debug views without leaking private development data.
class AiAssetValuation {
  const AiAssetValuation({
    required this.kind,
    required this.assetId,
    required this.value,
    required this.pointValue,
    this.statusAgeMult = 1.0,
    this.needMult = 1.0,
    this.contextMult = 1.0,
    this.futureDiscount = 1.0,
    this.uncertaintyMult = 1.0,
    this.statusPickMult = 1.0,
    this.rightsMult = 1.0,
    this.projectedSlot,
    this.contractDrag = 0.0,
    this.contractDragClass = AiContractDragClass.acceptable,
    this.contextFactors = const [],
  });

  final AiAssetKind kind;
  final String assetId;
  final double value;
  final double pointValue;
  final double statusAgeMult;
  final double needMult;
  final double contextMult;
  final double futureDiscount;
  final double uncertaintyMult;
  final double statusPickMult;
  final double rightsMult;
  final double? projectedSlot;
  final double contractDrag;
  final AiContractDragClass contractDragClass;
  final List<String> contextFactors;

  double get assetValue => value;
}

/// Package-level evaluation. Noise is applied exactly once here, never per
/// asset, so the same package can be replayed from the canonical aiSeed.
class AiPackageEvaluation {
  const AiPackageEvaluation({
    required this.incoming,
    required this.outgoing,
    required this.inValue,
    required this.outValue,
    required this.netValue,
    required this.rawSurplusPct,
    required this.surplusPct,
    required this.evaluationNoisePp,
    required this.apronPenalty,
    required this.resultingPayroll,
    required this.secondApronBlocked,
    required this.secondApronRoll,
  });

  final List<AiAssetValuation> incoming;
  final List<AiAssetValuation> outgoing;
  final double inValue;
  final double outValue;
  final double netValue;
  final double rawSurplusPct;
  final double surplusPct;
  final double evaluationNoisePp;
  final int apronPenalty;
  final int resultingPayroll;
  final bool secondApronBlocked;
  final double? secondApronRoll;

  bool get hardRejected => secondApronBlocked;
}
