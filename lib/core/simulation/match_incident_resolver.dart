import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/injury_service.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

/// Result of the foul roll attached to one lost defensive duel.
class FoulDecision {
  const FoulDecision({required this.probability, required this.occurred});

  final double probability;
  final bool occurred;
}

/// Result of the card rolls attached to one committed foul.
class CardDecision {
  const CardDecision({
    required this.yellowProbability,
    required this.directRedProbability,
    required this.yellow,
    required this.secondYellow,
    required this.directRed,
    required this.directRedSeverity,
  });

  final double yellowProbability;
  final double directRedProbability;
  final bool yellow;
  final bool secondYellow;
  final bool directRed;
  final int directRedSeverity;

  bool get red => secondYellow || directRed;
}

/// Result of one per-player, per-minute injury roll.
class InjuryDecision {
  const InjuryDecision({
    required this.probability,
    required this.occurred,
    this.diagnosis,
  });

  final double probability;
  final bool occurred;
  final InjuryDiagnosis? diagnosis;

  Injury? get injury => diagnosis?.injury;
}

/// Shared Task 20 incident formulas.
///
/// The resolver owns no random generator. Every roll is supplied by callbacks
/// so [MatchRandom] remains the sole deterministic stream for a runtime match.
class MatchIncidentResolver {
  const MatchIncidentResolver({
    this.balance = BalanceConfig.defaults,
    this.injuryService = const InjuryService(),
  });

  final BalanceConfig balance;
  final InjuryService injuryService;

  double foulProbability({
    required double attackerPace,
    required double defenderPhysicality,
    required Player defender,
    required TacticsSetup defendingTactics,
    required MatchContext context,
    bool defendingHome = true,
    int existingYellowCards = 0,
  }) {
    final matchday = balance.matchday;
    final probability =
        matchday.foulBase *
        matchday.foulPressingMultiplier(defendingTactics.pressing) *
        matchday.physGapMultiplier(
          defenderPhysicality: defenderPhysicality,
          attackerPace: attackerPace,
        ) *
        _cardProneMultiplier(defender) *
        (existingYellowCards > 0 ? matchday.foulCardedPlayerMultiplier : 1.0) *
        (context.isDerby ? matchday.derbyFoulMultiplier : 1.0) *
        context.refereeStrictness *
        matchday.refereeCrowdMultiplier(
          crowdIntensity: context.crowdIntensity,
          defendingHome: defendingHome,
        );
    return probability.clamp(0.0, 1.0).toDouble();
  }

  FoulDecision rollFoul({
    required double attackerPace,
    required double defenderPhysicality,
    required Player defender,
    required TacticsSetup defendingTactics,
    required MatchContext context,
    bool defendingHome = true,
    int existingYellowCards = 0,
    required double Function() nextDouble,
  }) {
    final probability = foulProbability(
      attackerPace: attackerPace,
      defenderPhysicality: defenderPhysicality,
      defender: defender,
      defendingTactics: defendingTactics,
      context: context,
      defendingHome: defendingHome,
      existingYellowCards: existingYellowCards,
    );
    return FoulDecision(
      probability: probability,
      occurred: nextDouble() < probability,
    );
  }

  double yellowProbability({
    required Player defender,
    required MatchContext context,
  }) =>
      (balance.matchday.yellowFromFoul *
              context.refereeStrictness *
              (context.isDerby ? balance.matchday.derbyFoulMultiplier : 1.0) *
              _cardProneMultiplier(defender))
          .clamp(0.0, 1.0)
          .toDouble();

  double directRedProbability({required bool oneOnOne}) =>
      (balance.matchday.redDirect * (oneOnOne ? 2.0 : 1.0))
          .clamp(0.0, 1.0)
          .toDouble();

  CardDecision rollCard({
    required Player defender,
    required MatchContext context,
    required bool oneOnOne,
    required int existingYellowCards,
    required double Function() nextDouble,
  }) {
    final yellowP = yellowProbability(defender: defender, context: context);
    final yellow = nextDouble() < yellowP;
    if (yellow) {
      return CardDecision(
        yellowProbability: yellowP,
        directRedProbability: directRedProbability(oneOnOne: oneOnOne),
        yellow: true,
        secondYellow: existingYellowCards >= 1,
        directRed: false,
        directRedSeverity: 0,
      );
    }

    final directP = directRedProbability(oneOnOne: oneOnOne);
    final directRed = nextDouble() < directP;
    final severity = directRed ? directRedSeverityFromRoll(nextDouble()) : 0;
    return CardDecision(
      yellowProbability: yellowP,
      directRedProbability: directP,
      yellow: false,
      secondYellow: false,
      directRed: directRed,
      directRedSeverity: severity,
    );
  }

  static int directRedSeverityFromRoll(double roll) {
    final bounded = roll.clamp(0.0, 0.999999999).toDouble();
    if (bounded < 0.60) return 1;
    if (bounded < 0.90) return 2;
    return 3;
  }

  double injuryProbability({
    required Player player,
    required double stamina,
    required TacticsSetup tactics,
    required MatchContext context,
    required bool duelInvolved,
    StaffMember? physio,
    StaffMember? doctor,
  }) {
    final currentStamina = stamina.round();
    final probability =
        balance.matchday.injuryBase *
        balance.matchday.injuryProneMultiplier(player.hidden.injuryProne) *
        balance.player.injuryRiskMult(currentStamina) *
        injuryService.physioRehabMult(physio) *
        injuryService.doctorPreventionMult(doctor) *
        _professionalMultiplier(player) *
        balance.matchday.injuryIntensityMultiplier(
          tempo: tactics.tempo,
          pressing: tactics.pressing,
        ) *
        balance.matchday.weatherInjuryMultiplier(context.weather) *
        (duelInvolved ? 2.5 : 1.0);
    return probability.clamp(0.0, 1.0).toDouble();
  }

  InjuryDecision rollInjury({
    required Player player,
    required double stamina,
    required TacticsSetup tactics,
    required MatchContext context,
    required bool duelInvolved,
    StaffMember? physio,
    StaffMember? doctor,
    double? doctorCareMultiplier,
    required double Function() nextDouble,
    required int Function(int max) nextInt,
  }) {
    final probability = injuryProbability(
      player: player,
      stamina: stamina,
      tactics: tactics,
      context: context,
      duelInvolved: duelInvolved,
      physio: physio,
      doctor: doctor,
    );
    if (nextDouble() >= probability) {
      return InjuryDecision(probability: probability, occurred: false);
    }

    final diagnosis = injuryService.diagnoseWithCallbacks(
      nextDouble: nextDouble,
      nextInt: nextInt,
      doctor: doctor,
      doctorCareMultiplier: doctorCareMultiplier,
    );
    return InjuryDecision(
      probability: probability,
      occurred: true,
      diagnosis: diagnosis,
    );
  }

  double _cardProneMultiplier(Player player) =>
      player.personality == PlayerPersonality.temperamental
      ? balance.matchday.cardProneTemperamental
      : 1.0;

  double _professionalMultiplier(Player player) =>
      player.personality == PlayerPersonality.professional
      ? balance.matchday.injuryProfessional
      : 1.0;
}
