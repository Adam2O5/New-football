import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/player.dart';

part 'contract_market_models.freezed.dart';
part 'contract_market_models.g.dart';

/// A draft pick creates control of a player without placing the player on a
/// roster. The player snapshot is kept with the right so the save remains
/// self-contained until the right is signed or traded.
@freezed
abstract class DraftedPlayerRights with _$DraftedPlayerRights {
  const factory DraftedPlayerRights({
    required String id,
    required String ownerTeamId,
    required Player player,
    required int draftYear,
    required int pickNumber,
    @Default(false) bool reminderSent,
  }) = _DraftedPlayerRights;

  factory DraftedPlayerRights.fromJson(Map<String, dynamic> json) =>
      _$DraftedPlayerRightsFromJson(json);
}

/// A newly undrafted player is eligible for the special AI signing policy only
/// inside this explicit window. Expired contracts are deliberately not
/// represented here even though they can also have zero years remaining.
@freezed
abstract class FreshUndraftedPlayer with _$FreshUndraftedPlayer {
  const factory FreshUndraftedPlayer({
    required String playerId,
    required int draftYear,
    required int activeFromSeasonYear,
    required int activeFromWeek,
    required int activeUntilSeasonYear,
    required int activeUntilWeek,
  }) = _FreshUndraftedPlayer;

  factory FreshUndraftedPlayer.fromJson(Map<String, dynamic> json) =>
      _$FreshUndraftedPlayerFromJson(json);
}

extension FreshUndraftedPlayerX on FreshUndraftedPlayer {
  bool isActiveAt({required int seasonYear, required int week}) {
    final afterStart =
        seasonYear > activeFromSeasonYear ||
        (seasonYear == activeFromSeasonYear && week >= activeFromWeek);
    final beforeEnd =
        seasonYear < activeUntilSeasonYear ||
        (seasonYear == activeUntilSeasonYear && week <= activeUntilWeek);
    return afterStart && beforeEnd;
  }
}

/// A qualifying offer is the switch that turns an expired rookie into an RFA.
/// Without this record the same player is treated as an unrestricted FA.
@freezed
abstract class RfaQualifyingOffer with _$RfaQualifyingOffer {
  const factory RfaQualifyingOffer({
    required String playerId,
    required String ownerTeamId,
    required int salary,
    @Default(1) int years,
    required int seasonYear,
    @Default(false) bool declined,
  }) = _RfaQualifyingOffer;

  factory RfaQualifyingOffer.fromJson(Map<String, dynamic> json) =>
      _$RfaQualifyingOfferFromJson(json);
}

/// Conditions offered by a rival and the exact match deadline for the
/// original club. Match always copies these terms; it never renegotiates them.
@freezed
abstract class RfaOfferSheet with _$RfaOfferSheet {
  const factory RfaOfferSheet({
    required String id,
    required String playerId,
    required String originalTeamId,
    required String offeringTeamId,
    required int salary,
    required int years,
    required NegotiationPhase phase,
    required int seasonYear,
    required int week,
    @Default(1) int day,
    @Default(1) int hour,
    required int expirySeasonYear,
    required int expiryWeek,
    @Default(1) int expiryDay,
    @Default(0) int expiryHour,
    @Default(false) bool matched,
    @Default(false) bool declined,
  }) = _RfaOfferSheet;

  factory RfaOfferSheet.fromJson(Map<String, dynamic> json) =>
      _$RfaOfferSheetFromJson(json);
}

extension RfaOfferSheetX on RfaOfferSheet {
  bool get isTerminal => matched || declined;
}
