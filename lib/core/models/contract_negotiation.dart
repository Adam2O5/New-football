import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';

part 'contract_negotiation.freezed.dart';
part 'contract_negotiation.g.dart';

/// The entity whose contract is being negotiated.
enum NegotiationSubjectKind { player, staff }

/// Contract-market context used to select waiting and finalization rules.
enum NegotiationPhase { contractExtension, freeAgencyPhaseI, freeAgencyPhaseII }

/// Persisted lifecycle of one player/club or staff/club negotiation.
enum NegotiationStatus {
  active,
  waiting,
  pendingFinalization,
  counter,
  rejected,
  hardRejected,
  completed,
  cancelled,
}

/// Serializable offer payload shared by player and staff negotiations.
@freezed
abstract class NegotiationOffer with _$NegotiationOffer {
  const factory NegotiationOffer({
    required int salary,
    required int years,
    CapExceptionType? exception,
    int? rookiePickSlot,
  }) = _NegotiationOffer;

  factory NegotiationOffer.fromJson(Map<String, dynamic> json) =>
      _$NegotiationOfferFromJson(json);
}

/// Persisted negotiation state. Accept is intentionally not a signature:
/// it creates [NegotiationStatus.pendingFinalization] until the user or the
/// appropriate offseason resolver finalizes it.
@freezed
abstract class ContractNegotiation with _$ContractNegotiation {
  const factory ContractNegotiation({
    required String id,
    required String subjectId,
    required NegotiationSubjectKind subjectKind,
    required String teamId,
    required NegotiationPhase phase,
    @Default(1) int round,
    required NegotiationOffer lastOffer,
    NegotiationOffer? counterOffer,
    @Default(NegotiationStatus.active) NegotiationStatus status,
    required int seasonYear,
    required int week,
    @Default(1) int day,
    @Default(0) int hour,
    required int expirySeasonYear,
    required int expiryWeek,
    @Default(1) int expiryDay,
    @Default(0) int expiryHour,
    @Default(false) bool requiresFinalization,
    @Default(false) bool selectedByRival,
    @Default(false) bool rivalFinalized,

    /// Score used by the central market resolver to rank simultaneous bids.
    @Default(0.0) double offerScore,

    /// AI bids are finalized automatically when they win a market slot;
    /// player-controlled bids remain pending until the user confirms them.
    @Default(false) bool isAiOffer,

    /// Waiting is a persisted timer rather than an implicit UI state. The
    /// nullable date fields keep the timer correct across a day boundary.
    int? waitingUntilSeasonYear,
    int? waitingUntilWeek,
    int? waitingUntilDay,
    int? waitingUntilHour,
  }) = _ContractNegotiation;

  factory ContractNegotiation.fromJson(Map<String, dynamic> json) =>
      _$ContractNegotiationFromJson(json);
}

/// A temporary subject–club block created by a hard reject or an expired
/// finalization. It is separate from Contract.blockedTeamIds (which models a
/// contract NTC and has different semantics).
@freezed
abstract class NegotiationBlock with _$NegotiationBlock {
  const factory NegotiationBlock({
    required String subjectId,
    required NegotiationSubjectKind subjectKind,
    required String teamId,
    required int untilSeasonYear,
    required int untilWeek,
    required int untilDay,
    @Default(0) int untilHour,
  }) = _NegotiationBlock;

  factory NegotiationBlock.fromJson(Map<String, dynamic> json) =>
      _$NegotiationBlockFromJson(json);
}

extension ContractNegotiationX on ContractNegotiation {
  bool get isTerminal => switch (status) {
    NegotiationStatus.rejected ||
    NegotiationStatus.hardRejected ||
    NegotiationStatus.completed ||
    NegotiationStatus.cancelled => true,
    _ => false,
  };
}
