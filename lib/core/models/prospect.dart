import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/development.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_attributes.dart';

part 'prospect.freezed.dart';
part 'prospect.g.dart';

@freezed
abstract class Prospect with _$Prospect {
  const factory Prospect({
    required String id,
    required String name,
    required Nationality nationality,
    required Position position,
    required int age,
    required PlayerAttributes attributes,
    @Default(0) int scoutGrade, //unevaluated
    @Default(0) int combineScore, //unevaluated
    required double potentialStars,
    required int heightCm,
    required int injuryProne,
    required int determination,
    required PlayerPersonality personality,

    /// Optymalna rola taktyczna (`player_management.md`).
    /// Ujawniana przez Combine (`offseason.md` §7).
    required AssignedRole optimalRole,
  }) = _Prospect;

  factory Prospect.fromJson(Map<String, dynamic> json) =>
      _$ProspectFromJson(json);
}

extension ProspectX on Prospect {
  double projectedOverall([BalanceConfig balance = BalanceConfig.defaults]) =>
      attributes.overallForPosition(position, balance);

  /// Converts prospect → player after draft pick or undrafted FA sign.
  /// Rolls [DevelopmentOutcome] here (hidden while still a prospect).
  Player toPlayer({
    required Contract contract,
    required Random rng,
    int? draftYear,
    BalanceConfig balance = BalanceConfig.defaults,
  }) {
    final outcome = rollDevelopmentOutcome(determination, rng, balance);
    final player = Player(
      id: id,
      name: name,
      position: position,
      nationality: nationality,
      age: age,
      attributes: attributes,
      contract: contract,
      personality: personality,
      draftYear: draftYear,
      potentialStars: potentialStars,
      heightCm: heightCm,
      optimalRole: optimalRole,
      state: PlayerState(
        stamina: 100,
        form: (1 + rng.nextInt(10)).toDouble(),
        role: position.defaultAssignedRole,
        seasonsWithTeam: 0,
      ),
      hidden: PlayerHidden(
        injuryProne: injuryProne,
        determination: determination,
        overallProgress: (40 + rng.nextInt(50)).toDouble(),
        growthRate: balance.development.baseGrowthRateFor(determination),
        developmentOutcome: outcome,
        developmentCeilingStars: rollDevelopmentCeilingStars(
          potentialStars,
          outcome,
          rng,
        ),
      ),
    );
    return player
        .copyWith(seasonStartOvr: player.overall(balance))
        .recalculatePointValue(balance);
  }
}
