// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'league_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LeagueState {

 List<Team> get teams; Season get currentSeason; List<SeasonHistory> get history; String? get playerTeamId; int get currentRound; int get currentWeek;/// 1 = Monday … 7 = Sunday within [currentWeek].
 int get currentDay;/// Hourly contract mode clock. Null outside extensions/FA phase I;
/// otherwise 1–10 identifies the current offer slot.
 int? get currentHour; bool get hourlyPlayerOfferUsed; bool get hourlyStaffOfferUsed; Inbox get inbox; MessageSettings get messageSettings;/// Sztab bez klubu — pula dostępna do zatrudnienia (`docs/staff_rules.md`).
 List<StaffMember> get staffFreeAgents;/// Zawodnicy bez klubu — niedraftowani + wygasłe kontrakty
/// (`docs/contract_signing.md`, `docs/offseason.md`).
 List<Player> get freeAgents;/// Provenance and active window for players added by the just-completed
/// draft. This must stay separate from [Player.contract] because expired
/// contracts can have the same zero-year shape.
 List<FreshUndraftedPlayer> get freshUndraftedPlayers;/// Tabela siły ligi (`team_management.md`). Jedno źródło prawdy dla
/// `teamStatus`, `expectedRank` i `teamPower` wszystkich 30 drużyn.
/// `null` = jeszcze nie przeliczona (zostanie obliczona przy pierwszym
/// `shouldRecalculate` w `DaySimulator`).
 LeagueStrengthTable? get strengthTable;/// Persistent player/staff negotiation records. A score reaction is not
/// enough to reconstruct deadlines, counters or finalization after load.
 List<ContractNegotiation> get negotiations;/// Temporary subject × club blocks created by hard rejects or expired
/// finalization windows.
 List<NegotiationBlock> get negotiationBlocks;/// Completed and rejected trade attempts. Only accepted entries affect
/// draft-pick Stepien validation; other outcomes remain for the history UI.
 List<TradeHistoryEntry> get tradeHistory;/// Active and terminal offer records for trade/counter threads.
 List<TradeOffer> get tradeOffers;/// Temporary player × destination blocks created by NTC refusals.
 List<NtcTradeBlock> get ntcTradeBlocks;/// Drafted players under team control but not yet signed. Rights are not
/// roster entries and therefore do not affect roster size or matchday.
 List<DraftedPlayerRights> get draftedRights;/// Explicit RFA state. A player has matching rights only while a
/// qualifying offer is present in this list.
 List<RfaQualifyingOffer> get rfaQualifyingOffers; List<RfaOfferSheet> get rfaOfferSheets;
/// Create a copy of LeagueState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeagueStateCopyWith<LeagueState> get copyWith => _$LeagueStateCopyWithImpl<LeagueState>(this as LeagueState, _$identity);

  /// Serializes this LeagueState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeagueState&&const DeepCollectionEquality().equals(other.teams, teams)&&(identical(other.currentSeason, currentSeason) || other.currentSeason == currentSeason)&&const DeepCollectionEquality().equals(other.history, history)&&(identical(other.playerTeamId, playerTeamId) || other.playerTeamId == playerTeamId)&&(identical(other.currentRound, currentRound) || other.currentRound == currentRound)&&(identical(other.currentWeek, currentWeek) || other.currentWeek == currentWeek)&&(identical(other.currentDay, currentDay) || other.currentDay == currentDay)&&(identical(other.currentHour, currentHour) || other.currentHour == currentHour)&&(identical(other.hourlyPlayerOfferUsed, hourlyPlayerOfferUsed) || other.hourlyPlayerOfferUsed == hourlyPlayerOfferUsed)&&(identical(other.hourlyStaffOfferUsed, hourlyStaffOfferUsed) || other.hourlyStaffOfferUsed == hourlyStaffOfferUsed)&&(identical(other.inbox, inbox) || other.inbox == inbox)&&(identical(other.messageSettings, messageSettings) || other.messageSettings == messageSettings)&&const DeepCollectionEquality().equals(other.staffFreeAgents, staffFreeAgents)&&const DeepCollectionEquality().equals(other.freeAgents, freeAgents)&&const DeepCollectionEquality().equals(other.freshUndraftedPlayers, freshUndraftedPlayers)&&(identical(other.strengthTable, strengthTable) || other.strengthTable == strengthTable)&&const DeepCollectionEquality().equals(other.negotiations, negotiations)&&const DeepCollectionEquality().equals(other.negotiationBlocks, negotiationBlocks)&&const DeepCollectionEquality().equals(other.tradeHistory, tradeHistory)&&const DeepCollectionEquality().equals(other.tradeOffers, tradeOffers)&&const DeepCollectionEquality().equals(other.ntcTradeBlocks, ntcTradeBlocks)&&const DeepCollectionEquality().equals(other.draftedRights, draftedRights)&&const DeepCollectionEquality().equals(other.rfaQualifyingOffers, rfaQualifyingOffers)&&const DeepCollectionEquality().equals(other.rfaOfferSheets, rfaOfferSheets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,const DeepCollectionEquality().hash(teams),currentSeason,const DeepCollectionEquality().hash(history),playerTeamId,currentRound,currentWeek,currentDay,currentHour,hourlyPlayerOfferUsed,hourlyStaffOfferUsed,inbox,messageSettings,const DeepCollectionEquality().hash(staffFreeAgents),const DeepCollectionEquality().hash(freeAgents),const DeepCollectionEquality().hash(freshUndraftedPlayers),strengthTable,const DeepCollectionEquality().hash(negotiations),const DeepCollectionEquality().hash(negotiationBlocks),const DeepCollectionEquality().hash(tradeHistory),const DeepCollectionEquality().hash(tradeOffers),const DeepCollectionEquality().hash(ntcTradeBlocks),const DeepCollectionEquality().hash(draftedRights),const DeepCollectionEquality().hash(rfaQualifyingOffers),const DeepCollectionEquality().hash(rfaOfferSheets)]);

@override
String toString() {
  return 'LeagueState(teams: $teams, currentSeason: $currentSeason, history: $history, playerTeamId: $playerTeamId, currentRound: $currentRound, currentWeek: $currentWeek, currentDay: $currentDay, currentHour: $currentHour, hourlyPlayerOfferUsed: $hourlyPlayerOfferUsed, hourlyStaffOfferUsed: $hourlyStaffOfferUsed, inbox: $inbox, messageSettings: $messageSettings, staffFreeAgents: $staffFreeAgents, freeAgents: $freeAgents, freshUndraftedPlayers: $freshUndraftedPlayers, strengthTable: $strengthTable, negotiations: $negotiations, negotiationBlocks: $negotiationBlocks, tradeHistory: $tradeHistory, tradeOffers: $tradeOffers, ntcTradeBlocks: $ntcTradeBlocks, draftedRights: $draftedRights, rfaQualifyingOffers: $rfaQualifyingOffers, rfaOfferSheets: $rfaOfferSheets)';
}


}

/// @nodoc
abstract mixin class $LeagueStateCopyWith<$Res>  {
  factory $LeagueStateCopyWith(LeagueState value, $Res Function(LeagueState) _then) = _$LeagueStateCopyWithImpl;
@useResult
$Res call({
 List<Team> teams, Season currentSeason, List<SeasonHistory> history, String? playerTeamId, int currentRound, int currentWeek, int currentDay, int? currentHour, bool hourlyPlayerOfferUsed, bool hourlyStaffOfferUsed, Inbox inbox, MessageSettings messageSettings, List<StaffMember> staffFreeAgents, List<Player> freeAgents, List<FreshUndraftedPlayer> freshUndraftedPlayers, LeagueStrengthTable? strengthTable, List<ContractNegotiation> negotiations, List<NegotiationBlock> negotiationBlocks, List<TradeHistoryEntry> tradeHistory, List<TradeOffer> tradeOffers, List<NtcTradeBlock> ntcTradeBlocks, List<DraftedPlayerRights> draftedRights, List<RfaQualifyingOffer> rfaQualifyingOffers, List<RfaOfferSheet> rfaOfferSheets
});


$SeasonCopyWith<$Res> get currentSeason;$InboxCopyWith<$Res> get inbox;$MessageSettingsCopyWith<$Res> get messageSettings;$LeagueStrengthTableCopyWith<$Res>? get strengthTable;

}
/// @nodoc
class _$LeagueStateCopyWithImpl<$Res>
    implements $LeagueStateCopyWith<$Res> {
  _$LeagueStateCopyWithImpl(this._self, this._then);

  final LeagueState _self;
  final $Res Function(LeagueState) _then;

/// Create a copy of LeagueState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? teams = null,Object? currentSeason = null,Object? history = null,Object? playerTeamId = freezed,Object? currentRound = null,Object? currentWeek = null,Object? currentDay = null,Object? currentHour = freezed,Object? hourlyPlayerOfferUsed = null,Object? hourlyStaffOfferUsed = null,Object? inbox = null,Object? messageSettings = null,Object? staffFreeAgents = null,Object? freeAgents = null,Object? freshUndraftedPlayers = null,Object? strengthTable = freezed,Object? negotiations = null,Object? negotiationBlocks = null,Object? tradeHistory = null,Object? tradeOffers = null,Object? ntcTradeBlocks = null,Object? draftedRights = null,Object? rfaQualifyingOffers = null,Object? rfaOfferSheets = null,}) {
  return _then(_self.copyWith(
teams: null == teams ? _self.teams : teams // ignore: cast_nullable_to_non_nullable
as List<Team>,currentSeason: null == currentSeason ? _self.currentSeason : currentSeason // ignore: cast_nullable_to_non_nullable
as Season,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<SeasonHistory>,playerTeamId: freezed == playerTeamId ? _self.playerTeamId : playerTeamId // ignore: cast_nullable_to_non_nullable
as String?,currentRound: null == currentRound ? _self.currentRound : currentRound // ignore: cast_nullable_to_non_nullable
as int,currentWeek: null == currentWeek ? _self.currentWeek : currentWeek // ignore: cast_nullable_to_non_nullable
as int,currentDay: null == currentDay ? _self.currentDay : currentDay // ignore: cast_nullable_to_non_nullable
as int,currentHour: freezed == currentHour ? _self.currentHour : currentHour // ignore: cast_nullable_to_non_nullable
as int?,hourlyPlayerOfferUsed: null == hourlyPlayerOfferUsed ? _self.hourlyPlayerOfferUsed : hourlyPlayerOfferUsed // ignore: cast_nullable_to_non_nullable
as bool,hourlyStaffOfferUsed: null == hourlyStaffOfferUsed ? _self.hourlyStaffOfferUsed : hourlyStaffOfferUsed // ignore: cast_nullable_to_non_nullable
as bool,inbox: null == inbox ? _self.inbox : inbox // ignore: cast_nullable_to_non_nullable
as Inbox,messageSettings: null == messageSettings ? _self.messageSettings : messageSettings // ignore: cast_nullable_to_non_nullable
as MessageSettings,staffFreeAgents: null == staffFreeAgents ? _self.staffFreeAgents : staffFreeAgents // ignore: cast_nullable_to_non_nullable
as List<StaffMember>,freeAgents: null == freeAgents ? _self.freeAgents : freeAgents // ignore: cast_nullable_to_non_nullable
as List<Player>,freshUndraftedPlayers: null == freshUndraftedPlayers ? _self.freshUndraftedPlayers : freshUndraftedPlayers // ignore: cast_nullable_to_non_nullable
as List<FreshUndraftedPlayer>,strengthTable: freezed == strengthTable ? _self.strengthTable : strengthTable // ignore: cast_nullable_to_non_nullable
as LeagueStrengthTable?,negotiations: null == negotiations ? _self.negotiations : negotiations // ignore: cast_nullable_to_non_nullable
as List<ContractNegotiation>,negotiationBlocks: null == negotiationBlocks ? _self.negotiationBlocks : negotiationBlocks // ignore: cast_nullable_to_non_nullable
as List<NegotiationBlock>,tradeHistory: null == tradeHistory ? _self.tradeHistory : tradeHistory // ignore: cast_nullable_to_non_nullable
as List<TradeHistoryEntry>,tradeOffers: null == tradeOffers ? _self.tradeOffers : tradeOffers // ignore: cast_nullable_to_non_nullable
as List<TradeOffer>,ntcTradeBlocks: null == ntcTradeBlocks ? _self.ntcTradeBlocks : ntcTradeBlocks // ignore: cast_nullable_to_non_nullable
as List<NtcTradeBlock>,draftedRights: null == draftedRights ? _self.draftedRights : draftedRights // ignore: cast_nullable_to_non_nullable
as List<DraftedPlayerRights>,rfaQualifyingOffers: null == rfaQualifyingOffers ? _self.rfaQualifyingOffers : rfaQualifyingOffers // ignore: cast_nullable_to_non_nullable
as List<RfaQualifyingOffer>,rfaOfferSheets: null == rfaOfferSheets ? _self.rfaOfferSheets : rfaOfferSheets // ignore: cast_nullable_to_non_nullable
as List<RfaOfferSheet>,
  ));
}
/// Create a copy of LeagueState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeasonCopyWith<$Res> get currentSeason {
  
  return $SeasonCopyWith<$Res>(_self.currentSeason, (value) {
    return _then(_self.copyWith(currentSeason: value));
  });
}/// Create a copy of LeagueState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InboxCopyWith<$Res> get inbox {
  
  return $InboxCopyWith<$Res>(_self.inbox, (value) {
    return _then(_self.copyWith(inbox: value));
  });
}/// Create a copy of LeagueState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageSettingsCopyWith<$Res> get messageSettings {
  
  return $MessageSettingsCopyWith<$Res>(_self.messageSettings, (value) {
    return _then(_self.copyWith(messageSettings: value));
  });
}/// Create a copy of LeagueState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LeagueStrengthTableCopyWith<$Res>? get strengthTable {
    if (_self.strengthTable == null) {
    return null;
  }

  return $LeagueStrengthTableCopyWith<$Res>(_self.strengthTable!, (value) {
    return _then(_self.copyWith(strengthTable: value));
  });
}
}


/// Adds pattern-matching-related methods to [LeagueState].
extension LeagueStatePatterns on LeagueState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeagueState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeagueState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeagueState value)  $default,){
final _that = this;
switch (_that) {
case _LeagueState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeagueState value)?  $default,){
final _that = this;
switch (_that) {
case _LeagueState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Team> teams,  Season currentSeason,  List<SeasonHistory> history,  String? playerTeamId,  int currentRound,  int currentWeek,  int currentDay,  int? currentHour,  bool hourlyPlayerOfferUsed,  bool hourlyStaffOfferUsed,  Inbox inbox,  MessageSettings messageSettings,  List<StaffMember> staffFreeAgents,  List<Player> freeAgents,  List<FreshUndraftedPlayer> freshUndraftedPlayers,  LeagueStrengthTable? strengthTable,  List<ContractNegotiation> negotiations,  List<NegotiationBlock> negotiationBlocks,  List<TradeHistoryEntry> tradeHistory,  List<TradeOffer> tradeOffers,  List<NtcTradeBlock> ntcTradeBlocks,  List<DraftedPlayerRights> draftedRights,  List<RfaQualifyingOffer> rfaQualifyingOffers,  List<RfaOfferSheet> rfaOfferSheets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeagueState() when $default != null:
return $default(_that.teams,_that.currentSeason,_that.history,_that.playerTeamId,_that.currentRound,_that.currentWeek,_that.currentDay,_that.currentHour,_that.hourlyPlayerOfferUsed,_that.hourlyStaffOfferUsed,_that.inbox,_that.messageSettings,_that.staffFreeAgents,_that.freeAgents,_that.freshUndraftedPlayers,_that.strengthTable,_that.negotiations,_that.negotiationBlocks,_that.tradeHistory,_that.tradeOffers,_that.ntcTradeBlocks,_that.draftedRights,_that.rfaQualifyingOffers,_that.rfaOfferSheets);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Team> teams,  Season currentSeason,  List<SeasonHistory> history,  String? playerTeamId,  int currentRound,  int currentWeek,  int currentDay,  int? currentHour,  bool hourlyPlayerOfferUsed,  bool hourlyStaffOfferUsed,  Inbox inbox,  MessageSettings messageSettings,  List<StaffMember> staffFreeAgents,  List<Player> freeAgents,  List<FreshUndraftedPlayer> freshUndraftedPlayers,  LeagueStrengthTable? strengthTable,  List<ContractNegotiation> negotiations,  List<NegotiationBlock> negotiationBlocks,  List<TradeHistoryEntry> tradeHistory,  List<TradeOffer> tradeOffers,  List<NtcTradeBlock> ntcTradeBlocks,  List<DraftedPlayerRights> draftedRights,  List<RfaQualifyingOffer> rfaQualifyingOffers,  List<RfaOfferSheet> rfaOfferSheets)  $default,) {final _that = this;
switch (_that) {
case _LeagueState():
return $default(_that.teams,_that.currentSeason,_that.history,_that.playerTeamId,_that.currentRound,_that.currentWeek,_that.currentDay,_that.currentHour,_that.hourlyPlayerOfferUsed,_that.hourlyStaffOfferUsed,_that.inbox,_that.messageSettings,_that.staffFreeAgents,_that.freeAgents,_that.freshUndraftedPlayers,_that.strengthTable,_that.negotiations,_that.negotiationBlocks,_that.tradeHistory,_that.tradeOffers,_that.ntcTradeBlocks,_that.draftedRights,_that.rfaQualifyingOffers,_that.rfaOfferSheets);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Team> teams,  Season currentSeason,  List<SeasonHistory> history,  String? playerTeamId,  int currentRound,  int currentWeek,  int currentDay,  int? currentHour,  bool hourlyPlayerOfferUsed,  bool hourlyStaffOfferUsed,  Inbox inbox,  MessageSettings messageSettings,  List<StaffMember> staffFreeAgents,  List<Player> freeAgents,  List<FreshUndraftedPlayer> freshUndraftedPlayers,  LeagueStrengthTable? strengthTable,  List<ContractNegotiation> negotiations,  List<NegotiationBlock> negotiationBlocks,  List<TradeHistoryEntry> tradeHistory,  List<TradeOffer> tradeOffers,  List<NtcTradeBlock> ntcTradeBlocks,  List<DraftedPlayerRights> draftedRights,  List<RfaQualifyingOffer> rfaQualifyingOffers,  List<RfaOfferSheet> rfaOfferSheets)?  $default,) {final _that = this;
switch (_that) {
case _LeagueState() when $default != null:
return $default(_that.teams,_that.currentSeason,_that.history,_that.playerTeamId,_that.currentRound,_that.currentWeek,_that.currentDay,_that.currentHour,_that.hourlyPlayerOfferUsed,_that.hourlyStaffOfferUsed,_that.inbox,_that.messageSettings,_that.staffFreeAgents,_that.freeAgents,_that.freshUndraftedPlayers,_that.strengthTable,_that.negotiations,_that.negotiationBlocks,_that.tradeHistory,_that.tradeOffers,_that.ntcTradeBlocks,_that.draftedRights,_that.rfaQualifyingOffers,_that.rfaOfferSheets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeagueState implements LeagueState {
  const _LeagueState({required final  List<Team> teams, required this.currentSeason, final  List<SeasonHistory> history = const [], this.playerTeamId, this.currentRound = 0, this.currentWeek = 1, this.currentDay = 1, this.currentHour, this.hourlyPlayerOfferUsed = false, this.hourlyStaffOfferUsed = false, this.inbox = const Inbox(), this.messageSettings = const MessageSettings(), final  List<StaffMember> staffFreeAgents = const [], final  List<Player> freeAgents = const [], final  List<FreshUndraftedPlayer> freshUndraftedPlayers = const [], this.strengthTable, final  List<ContractNegotiation> negotiations = const [], final  List<NegotiationBlock> negotiationBlocks = const [], final  List<TradeHistoryEntry> tradeHistory = const [], final  List<TradeOffer> tradeOffers = const [], final  List<NtcTradeBlock> ntcTradeBlocks = const [], final  List<DraftedPlayerRights> draftedRights = const [], final  List<RfaQualifyingOffer> rfaQualifyingOffers = const [], final  List<RfaOfferSheet> rfaOfferSheets = const []}): _teams = teams,_history = history,_staffFreeAgents = staffFreeAgents,_freeAgents = freeAgents,_freshUndraftedPlayers = freshUndraftedPlayers,_negotiations = negotiations,_negotiationBlocks = negotiationBlocks,_tradeHistory = tradeHistory,_tradeOffers = tradeOffers,_ntcTradeBlocks = ntcTradeBlocks,_draftedRights = draftedRights,_rfaQualifyingOffers = rfaQualifyingOffers,_rfaOfferSheets = rfaOfferSheets;
  factory _LeagueState.fromJson(Map<String, dynamic> json) => _$LeagueStateFromJson(json);

 final  List<Team> _teams;
@override List<Team> get teams {
  if (_teams is EqualUnmodifiableListView) return _teams;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_teams);
}

@override final  Season currentSeason;
 final  List<SeasonHistory> _history;
@override@JsonKey() List<SeasonHistory> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

@override final  String? playerTeamId;
@override@JsonKey() final  int currentRound;
@override@JsonKey() final  int currentWeek;
/// 1 = Monday … 7 = Sunday within [currentWeek].
@override@JsonKey() final  int currentDay;
/// Hourly contract mode clock. Null outside extensions/FA phase I;
/// otherwise 1–10 identifies the current offer slot.
@override final  int? currentHour;
@override@JsonKey() final  bool hourlyPlayerOfferUsed;
@override@JsonKey() final  bool hourlyStaffOfferUsed;
@override@JsonKey() final  Inbox inbox;
@override@JsonKey() final  MessageSettings messageSettings;
/// Sztab bez klubu — pula dostępna do zatrudnienia (`docs/staff_rules.md`).
 final  List<StaffMember> _staffFreeAgents;
/// Sztab bez klubu — pula dostępna do zatrudnienia (`docs/staff_rules.md`).
@override@JsonKey() List<StaffMember> get staffFreeAgents {
  if (_staffFreeAgents is EqualUnmodifiableListView) return _staffFreeAgents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_staffFreeAgents);
}

/// Zawodnicy bez klubu — niedraftowani + wygasłe kontrakty
/// (`docs/contract_signing.md`, `docs/offseason.md`).
 final  List<Player> _freeAgents;
/// Zawodnicy bez klubu — niedraftowani + wygasłe kontrakty
/// (`docs/contract_signing.md`, `docs/offseason.md`).
@override@JsonKey() List<Player> get freeAgents {
  if (_freeAgents is EqualUnmodifiableListView) return _freeAgents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_freeAgents);
}

/// Provenance and active window for players added by the just-completed
/// draft. This must stay separate from [Player.contract] because expired
/// contracts can have the same zero-year shape.
 final  List<FreshUndraftedPlayer> _freshUndraftedPlayers;
/// Provenance and active window for players added by the just-completed
/// draft. This must stay separate from [Player.contract] because expired
/// contracts can have the same zero-year shape.
@override@JsonKey() List<FreshUndraftedPlayer> get freshUndraftedPlayers {
  if (_freshUndraftedPlayers is EqualUnmodifiableListView) return _freshUndraftedPlayers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_freshUndraftedPlayers);
}

/// Tabela siły ligi (`team_management.md`). Jedno źródło prawdy dla
/// `teamStatus`, `expectedRank` i `teamPower` wszystkich 30 drużyn.
/// `null` = jeszcze nie przeliczona (zostanie obliczona przy pierwszym
/// `shouldRecalculate` w `DaySimulator`).
@override final  LeagueStrengthTable? strengthTable;
/// Persistent player/staff negotiation records. A score reaction is not
/// enough to reconstruct deadlines, counters or finalization after load.
 final  List<ContractNegotiation> _negotiations;
/// Persistent player/staff negotiation records. A score reaction is not
/// enough to reconstruct deadlines, counters or finalization after load.
@override@JsonKey() List<ContractNegotiation> get negotiations {
  if (_negotiations is EqualUnmodifiableListView) return _negotiations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_negotiations);
}

/// Temporary subject × club blocks created by hard rejects or expired
/// finalization windows.
 final  List<NegotiationBlock> _negotiationBlocks;
/// Temporary subject × club blocks created by hard rejects or expired
/// finalization windows.
@override@JsonKey() List<NegotiationBlock> get negotiationBlocks {
  if (_negotiationBlocks is EqualUnmodifiableListView) return _negotiationBlocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_negotiationBlocks);
}

/// Completed and rejected trade attempts. Only accepted entries affect
/// draft-pick Stepien validation; other outcomes remain for the history UI.
 final  List<TradeHistoryEntry> _tradeHistory;
/// Completed and rejected trade attempts. Only accepted entries affect
/// draft-pick Stepien validation; other outcomes remain for the history UI.
@override@JsonKey() List<TradeHistoryEntry> get tradeHistory {
  if (_tradeHistory is EqualUnmodifiableListView) return _tradeHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tradeHistory);
}

/// Active and terminal offer records for trade/counter threads.
 final  List<TradeOffer> _tradeOffers;
/// Active and terminal offer records for trade/counter threads.
@override@JsonKey() List<TradeOffer> get tradeOffers {
  if (_tradeOffers is EqualUnmodifiableListView) return _tradeOffers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tradeOffers);
}

/// Temporary player × destination blocks created by NTC refusals.
 final  List<NtcTradeBlock> _ntcTradeBlocks;
/// Temporary player × destination blocks created by NTC refusals.
@override@JsonKey() List<NtcTradeBlock> get ntcTradeBlocks {
  if (_ntcTradeBlocks is EqualUnmodifiableListView) return _ntcTradeBlocks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ntcTradeBlocks);
}

/// Drafted players under team control but not yet signed. Rights are not
/// roster entries and therefore do not affect roster size or matchday.
 final  List<DraftedPlayerRights> _draftedRights;
/// Drafted players under team control but not yet signed. Rights are not
/// roster entries and therefore do not affect roster size or matchday.
@override@JsonKey() List<DraftedPlayerRights> get draftedRights {
  if (_draftedRights is EqualUnmodifiableListView) return _draftedRights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_draftedRights);
}

/// Explicit RFA state. A player has matching rights only while a
/// qualifying offer is present in this list.
 final  List<RfaQualifyingOffer> _rfaQualifyingOffers;
/// Explicit RFA state. A player has matching rights only while a
/// qualifying offer is present in this list.
@override@JsonKey() List<RfaQualifyingOffer> get rfaQualifyingOffers {
  if (_rfaQualifyingOffers is EqualUnmodifiableListView) return _rfaQualifyingOffers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rfaQualifyingOffers);
}

 final  List<RfaOfferSheet> _rfaOfferSheets;
@override@JsonKey() List<RfaOfferSheet> get rfaOfferSheets {
  if (_rfaOfferSheets is EqualUnmodifiableListView) return _rfaOfferSheets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rfaOfferSheets);
}


/// Create a copy of LeagueState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeagueStateCopyWith<_LeagueState> get copyWith => __$LeagueStateCopyWithImpl<_LeagueState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeagueStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeagueState&&const DeepCollectionEquality().equals(other._teams, _teams)&&(identical(other.currentSeason, currentSeason) || other.currentSeason == currentSeason)&&const DeepCollectionEquality().equals(other._history, _history)&&(identical(other.playerTeamId, playerTeamId) || other.playerTeamId == playerTeamId)&&(identical(other.currentRound, currentRound) || other.currentRound == currentRound)&&(identical(other.currentWeek, currentWeek) || other.currentWeek == currentWeek)&&(identical(other.currentDay, currentDay) || other.currentDay == currentDay)&&(identical(other.currentHour, currentHour) || other.currentHour == currentHour)&&(identical(other.hourlyPlayerOfferUsed, hourlyPlayerOfferUsed) || other.hourlyPlayerOfferUsed == hourlyPlayerOfferUsed)&&(identical(other.hourlyStaffOfferUsed, hourlyStaffOfferUsed) || other.hourlyStaffOfferUsed == hourlyStaffOfferUsed)&&(identical(other.inbox, inbox) || other.inbox == inbox)&&(identical(other.messageSettings, messageSettings) || other.messageSettings == messageSettings)&&const DeepCollectionEquality().equals(other._staffFreeAgents, _staffFreeAgents)&&const DeepCollectionEquality().equals(other._freeAgents, _freeAgents)&&const DeepCollectionEquality().equals(other._freshUndraftedPlayers, _freshUndraftedPlayers)&&(identical(other.strengthTable, strengthTable) || other.strengthTable == strengthTable)&&const DeepCollectionEquality().equals(other._negotiations, _negotiations)&&const DeepCollectionEquality().equals(other._negotiationBlocks, _negotiationBlocks)&&const DeepCollectionEquality().equals(other._tradeHistory, _tradeHistory)&&const DeepCollectionEquality().equals(other._tradeOffers, _tradeOffers)&&const DeepCollectionEquality().equals(other._ntcTradeBlocks, _ntcTradeBlocks)&&const DeepCollectionEquality().equals(other._draftedRights, _draftedRights)&&const DeepCollectionEquality().equals(other._rfaQualifyingOffers, _rfaQualifyingOffers)&&const DeepCollectionEquality().equals(other._rfaOfferSheets, _rfaOfferSheets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,const DeepCollectionEquality().hash(_teams),currentSeason,const DeepCollectionEquality().hash(_history),playerTeamId,currentRound,currentWeek,currentDay,currentHour,hourlyPlayerOfferUsed,hourlyStaffOfferUsed,inbox,messageSettings,const DeepCollectionEquality().hash(_staffFreeAgents),const DeepCollectionEquality().hash(_freeAgents),const DeepCollectionEquality().hash(_freshUndraftedPlayers),strengthTable,const DeepCollectionEquality().hash(_negotiations),const DeepCollectionEquality().hash(_negotiationBlocks),const DeepCollectionEquality().hash(_tradeHistory),const DeepCollectionEquality().hash(_tradeOffers),const DeepCollectionEquality().hash(_ntcTradeBlocks),const DeepCollectionEquality().hash(_draftedRights),const DeepCollectionEquality().hash(_rfaQualifyingOffers),const DeepCollectionEquality().hash(_rfaOfferSheets)]);

@override
String toString() {
  return 'LeagueState(teams: $teams, currentSeason: $currentSeason, history: $history, playerTeamId: $playerTeamId, currentRound: $currentRound, currentWeek: $currentWeek, currentDay: $currentDay, currentHour: $currentHour, hourlyPlayerOfferUsed: $hourlyPlayerOfferUsed, hourlyStaffOfferUsed: $hourlyStaffOfferUsed, inbox: $inbox, messageSettings: $messageSettings, staffFreeAgents: $staffFreeAgents, freeAgents: $freeAgents, freshUndraftedPlayers: $freshUndraftedPlayers, strengthTable: $strengthTable, negotiations: $negotiations, negotiationBlocks: $negotiationBlocks, tradeHistory: $tradeHistory, tradeOffers: $tradeOffers, ntcTradeBlocks: $ntcTradeBlocks, draftedRights: $draftedRights, rfaQualifyingOffers: $rfaQualifyingOffers, rfaOfferSheets: $rfaOfferSheets)';
}


}

/// @nodoc
abstract mixin class _$LeagueStateCopyWith<$Res> implements $LeagueStateCopyWith<$Res> {
  factory _$LeagueStateCopyWith(_LeagueState value, $Res Function(_LeagueState) _then) = __$LeagueStateCopyWithImpl;
@override @useResult
$Res call({
 List<Team> teams, Season currentSeason, List<SeasonHistory> history, String? playerTeamId, int currentRound, int currentWeek, int currentDay, int? currentHour, bool hourlyPlayerOfferUsed, bool hourlyStaffOfferUsed, Inbox inbox, MessageSettings messageSettings, List<StaffMember> staffFreeAgents, List<Player> freeAgents, List<FreshUndraftedPlayer> freshUndraftedPlayers, LeagueStrengthTable? strengthTable, List<ContractNegotiation> negotiations, List<NegotiationBlock> negotiationBlocks, List<TradeHistoryEntry> tradeHistory, List<TradeOffer> tradeOffers, List<NtcTradeBlock> ntcTradeBlocks, List<DraftedPlayerRights> draftedRights, List<RfaQualifyingOffer> rfaQualifyingOffers, List<RfaOfferSheet> rfaOfferSheets
});


@override $SeasonCopyWith<$Res> get currentSeason;@override $InboxCopyWith<$Res> get inbox;@override $MessageSettingsCopyWith<$Res> get messageSettings;@override $LeagueStrengthTableCopyWith<$Res>? get strengthTable;

}
/// @nodoc
class __$LeagueStateCopyWithImpl<$Res>
    implements _$LeagueStateCopyWith<$Res> {
  __$LeagueStateCopyWithImpl(this._self, this._then);

  final _LeagueState _self;
  final $Res Function(_LeagueState) _then;

/// Create a copy of LeagueState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? teams = null,Object? currentSeason = null,Object? history = null,Object? playerTeamId = freezed,Object? currentRound = null,Object? currentWeek = null,Object? currentDay = null,Object? currentHour = freezed,Object? hourlyPlayerOfferUsed = null,Object? hourlyStaffOfferUsed = null,Object? inbox = null,Object? messageSettings = null,Object? staffFreeAgents = null,Object? freeAgents = null,Object? freshUndraftedPlayers = null,Object? strengthTable = freezed,Object? negotiations = null,Object? negotiationBlocks = null,Object? tradeHistory = null,Object? tradeOffers = null,Object? ntcTradeBlocks = null,Object? draftedRights = null,Object? rfaQualifyingOffers = null,Object? rfaOfferSheets = null,}) {
  return _then(_LeagueState(
teams: null == teams ? _self._teams : teams // ignore: cast_nullable_to_non_nullable
as List<Team>,currentSeason: null == currentSeason ? _self.currentSeason : currentSeason // ignore: cast_nullable_to_non_nullable
as Season,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<SeasonHistory>,playerTeamId: freezed == playerTeamId ? _self.playerTeamId : playerTeamId // ignore: cast_nullable_to_non_nullable
as String?,currentRound: null == currentRound ? _self.currentRound : currentRound // ignore: cast_nullable_to_non_nullable
as int,currentWeek: null == currentWeek ? _self.currentWeek : currentWeek // ignore: cast_nullable_to_non_nullable
as int,currentDay: null == currentDay ? _self.currentDay : currentDay // ignore: cast_nullable_to_non_nullable
as int,currentHour: freezed == currentHour ? _self.currentHour : currentHour // ignore: cast_nullable_to_non_nullable
as int?,hourlyPlayerOfferUsed: null == hourlyPlayerOfferUsed ? _self.hourlyPlayerOfferUsed : hourlyPlayerOfferUsed // ignore: cast_nullable_to_non_nullable
as bool,hourlyStaffOfferUsed: null == hourlyStaffOfferUsed ? _self.hourlyStaffOfferUsed : hourlyStaffOfferUsed // ignore: cast_nullable_to_non_nullable
as bool,inbox: null == inbox ? _self.inbox : inbox // ignore: cast_nullable_to_non_nullable
as Inbox,messageSettings: null == messageSettings ? _self.messageSettings : messageSettings // ignore: cast_nullable_to_non_nullable
as MessageSettings,staffFreeAgents: null == staffFreeAgents ? _self._staffFreeAgents : staffFreeAgents // ignore: cast_nullable_to_non_nullable
as List<StaffMember>,freeAgents: null == freeAgents ? _self._freeAgents : freeAgents // ignore: cast_nullable_to_non_nullable
as List<Player>,freshUndraftedPlayers: null == freshUndraftedPlayers ? _self._freshUndraftedPlayers : freshUndraftedPlayers // ignore: cast_nullable_to_non_nullable
as List<FreshUndraftedPlayer>,strengthTable: freezed == strengthTable ? _self.strengthTable : strengthTable // ignore: cast_nullable_to_non_nullable
as LeagueStrengthTable?,negotiations: null == negotiations ? _self._negotiations : negotiations // ignore: cast_nullable_to_non_nullable
as List<ContractNegotiation>,negotiationBlocks: null == negotiationBlocks ? _self._negotiationBlocks : negotiationBlocks // ignore: cast_nullable_to_non_nullable
as List<NegotiationBlock>,tradeHistory: null == tradeHistory ? _self._tradeHistory : tradeHistory // ignore: cast_nullable_to_non_nullable
as List<TradeHistoryEntry>,tradeOffers: null == tradeOffers ? _self._tradeOffers : tradeOffers // ignore: cast_nullable_to_non_nullable
as List<TradeOffer>,ntcTradeBlocks: null == ntcTradeBlocks ? _self._ntcTradeBlocks : ntcTradeBlocks // ignore: cast_nullable_to_non_nullable
as List<NtcTradeBlock>,draftedRights: null == draftedRights ? _self._draftedRights : draftedRights // ignore: cast_nullable_to_non_nullable
as List<DraftedPlayerRights>,rfaQualifyingOffers: null == rfaQualifyingOffers ? _self._rfaQualifyingOffers : rfaQualifyingOffers // ignore: cast_nullable_to_non_nullable
as List<RfaQualifyingOffer>,rfaOfferSheets: null == rfaOfferSheets ? _self._rfaOfferSheets : rfaOfferSheets // ignore: cast_nullable_to_non_nullable
as List<RfaOfferSheet>,
  ));
}

/// Create a copy of LeagueState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeasonCopyWith<$Res> get currentSeason {
  
  return $SeasonCopyWith<$Res>(_self.currentSeason, (value) {
    return _then(_self.copyWith(currentSeason: value));
  });
}/// Create a copy of LeagueState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InboxCopyWith<$Res> get inbox {
  
  return $InboxCopyWith<$Res>(_self.inbox, (value) {
    return _then(_self.copyWith(inbox: value));
  });
}/// Create a copy of LeagueState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageSettingsCopyWith<$Res> get messageSettings {
  
  return $MessageSettingsCopyWith<$Res>(_self.messageSettings, (value) {
    return _then(_self.copyWith(messageSettings: value));
  });
}/// Create a copy of LeagueState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LeagueStrengthTableCopyWith<$Res>? get strengthTable {
    if (_self.strengthTable == null) {
    return null;
  }

  return $LeagueStrengthTableCopyWith<$Res>(_self.strengthTable!, (value) {
    return _then(_self.copyWith(strengthTable: value));
  });
}
}

// dart format on
