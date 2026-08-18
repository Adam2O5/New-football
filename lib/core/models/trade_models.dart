import 'package:freezed_annotation/freezed_annotation.dart';

part 'trade_models.freezed.dart';
part 'trade_models.g.dart';

/// Serializable representation of an asset included in a completed or
/// rejected trade. The runtime [TradeAsset] remains a lightweight input type;
/// this snapshot makes history stable even if the roster changes later.
@freezed
abstract class TradeAssetSnapshot with _$TradeAssetSnapshot {
  const factory TradeAssetSnapshot({
    required String type,
    String? playerId,
    String? draftedRightsId,
    String? pickId,
    int? pickYear,
    int? pickRound,
    String? originalTeamId,
  }) = _TradeAssetSnapshot;

  factory TradeAssetSnapshot.fromJson(Map<String, dynamic> json) =>
      _$TradeAssetSnapshotFromJson(json);
}

/// Persistent record of a trade attempt. Only `accepted` entries affect the
/// Stepien calculation; refusal/rejection entries are retained for the UI and
/// audit trail without consuming future draft flexibility.
@freezed
abstract class TradeHistoryEntry with _$TradeHistoryEntry {
  const factory TradeHistoryEntry({
    required String id,
    required String teamAId,
    required String teamBId,
    required int seasonYear,
    required int week,
    @Default(1) int day,
    @Default('accepted') String outcome,
    @Default([]) List<TradeAssetSnapshot> assetsFromA,
    @Default([]) List<TradeAssetSnapshot> assetsFromB,
    String? reason,
    String? ntcPlayerId,
    double? ntcConsentProbability,
    String? offerId,
    String? threadId,
    @Default(1) int round,
  }) = _TradeHistoryEntry;

  factory TradeHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$TradeHistoryEntryFromJson(json);
}

/// A temporary player × destination block created after an NTC refusal.
/// Dates use logical game time rather than wall-clock time so saves remain
/// deterministic and testable across platforms.
@freezed
abstract class NtcTradeBlock with _$NtcTradeBlock {
  const factory NtcTradeBlock({
    required String playerId,
    required String destinationTeamId,
    required DateTime createdAt,
    required DateTime expiresAt,
  }) = _NtcTradeBlock;

  factory NtcTradeBlock.fromJson(Map<String, dynamic> json) =>
      _$NtcTradeBlockFromJson(json);
}

enum TradeOfferStatus {
  pending,
  countered,
  accepted,
  rejected,
  hardRejected,
  expired,
  ntcRefused,
  cancelled,
}

/// Persisted lifecycle record for an offer and its counter-offer thread.
///
/// The proposal orientation is stable for the whole thread: assetsFromA are
/// always sent by teamAId and assetsFromB are always sent by teamBId. A
/// counter-offer is represented by a new record linked through
/// [parentOfferId] and [threadId].
@freezed
abstract class TradeOffer with _$TradeOffer {
  const factory TradeOffer({
    required String id,
    required String threadId,
    String? parentOfferId,
    required String teamAId,
    required String teamBId,
    @Default([]) List<TradeAssetSnapshot> assetsFromA,
    @Default([]) List<TradeAssetSnapshot> assetsFromB,
    @Default(1) int round,
    @Default(TradeOfferStatus.pending) TradeOfferStatus status,
    required String awaitingTeamId,
    required int seasonYear,
    required int week,
    @Default(1) int day,
    @Default(0) int hour,
    required int expirySeasonYear,
    required int expiryWeek,
    @Default(1) int expiryDay,
    @Default(0) int expiryHour,
    String? supersededById,
    String? reason,
  }) = _TradeOffer;

  factory TradeOffer.fromJson(Map<String, dynamic> json) =>
      _$TradeOfferFromJson(json);
}

extension TradeOfferX on TradeOffer {
  bool get isTerminal => switch (status) {
    TradeOfferStatus.rejected ||
    TradeOfferStatus.hardRejected ||
    TradeOfferStatus.accepted ||
    TradeOfferStatus.expired ||
    TradeOfferStatus.ntcRefused ||
    TradeOfferStatus.cancelled ||
    TradeOfferStatus.countered => true,
    TradeOfferStatus.pending => false,
  };

  bool get isPending => status == TradeOfferStatus.pending;
}

extension NtcTradeBlockX on NtcTradeBlock {
  bool isActiveAt(DateTime now) => now.isBefore(expiresAt);
}
