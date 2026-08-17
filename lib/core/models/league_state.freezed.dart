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
 List<Player> get freeAgents;/// Tabela siły ligi (`team_management.md`). Jedno źródło prawdy dla
/// `teamStatus`, `expectedRank` i `teamPower` wszystkich 30 drużyn.
/// `null` = jeszcze nie przeliczona (zostanie obliczona przy pierwszym
/// `shouldRecalculate` w `DaySimulator`).
 LeagueStrengthTable? get strengthTable;
/// Create a copy of LeagueState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeagueStateCopyWith<LeagueState> get copyWith => _$LeagueStateCopyWithImpl<LeagueState>(this as LeagueState, _$identity);

  /// Serializes this LeagueState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeagueState&&const DeepCollectionEquality().equals(other.teams, teams)&&(identical(other.currentSeason, currentSeason) || other.currentSeason == currentSeason)&&const DeepCollectionEquality().equals(other.history, history)&&(identical(other.playerTeamId, playerTeamId) || other.playerTeamId == playerTeamId)&&(identical(other.currentRound, currentRound) || other.currentRound == currentRound)&&(identical(other.currentWeek, currentWeek) || other.currentWeek == currentWeek)&&(identical(other.currentDay, currentDay) || other.currentDay == currentDay)&&(identical(other.currentHour, currentHour) || other.currentHour == currentHour)&&(identical(other.hourlyPlayerOfferUsed, hourlyPlayerOfferUsed) || other.hourlyPlayerOfferUsed == hourlyPlayerOfferUsed)&&(identical(other.hourlyStaffOfferUsed, hourlyStaffOfferUsed) || other.hourlyStaffOfferUsed == hourlyStaffOfferUsed)&&(identical(other.inbox, inbox) || other.inbox == inbox)&&(identical(other.messageSettings, messageSettings) || other.messageSettings == messageSettings)&&const DeepCollectionEquality().equals(other.staffFreeAgents, staffFreeAgents)&&const DeepCollectionEquality().equals(other.freeAgents, freeAgents)&&(identical(other.strengthTable, strengthTable) || other.strengthTable == strengthTable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(teams),currentSeason,const DeepCollectionEquality().hash(history),playerTeamId,currentRound,currentWeek,currentDay,currentHour,hourlyPlayerOfferUsed,hourlyStaffOfferUsed,inbox,messageSettings,const DeepCollectionEquality().hash(staffFreeAgents),const DeepCollectionEquality().hash(freeAgents),strengthTable);

@override
String toString() {
  return 'LeagueState(teams: $teams, currentSeason: $currentSeason, history: $history, playerTeamId: $playerTeamId, currentRound: $currentRound, currentWeek: $currentWeek, currentDay: $currentDay, currentHour: $currentHour, hourlyPlayerOfferUsed: $hourlyPlayerOfferUsed, hourlyStaffOfferUsed: $hourlyStaffOfferUsed, inbox: $inbox, messageSettings: $messageSettings, staffFreeAgents: $staffFreeAgents, freeAgents: $freeAgents, strengthTable: $strengthTable)';
}


}

/// @nodoc
abstract mixin class $LeagueStateCopyWith<$Res>  {
  factory $LeagueStateCopyWith(LeagueState value, $Res Function(LeagueState) _then) = _$LeagueStateCopyWithImpl;
@useResult
$Res call({
 List<Team> teams, Season currentSeason, List<SeasonHistory> history, String? playerTeamId, int currentRound, int currentWeek, int currentDay, int? currentHour, bool hourlyPlayerOfferUsed, bool hourlyStaffOfferUsed, Inbox inbox, MessageSettings messageSettings, List<StaffMember> staffFreeAgents, List<Player> freeAgents, LeagueStrengthTable? strengthTable
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
@pragma('vm:prefer-inline') @override $Res call({Object? teams = null,Object? currentSeason = null,Object? history = null,Object? playerTeamId = freezed,Object? currentRound = null,Object? currentWeek = null,Object? currentDay = null,Object? currentHour = freezed,Object? hourlyPlayerOfferUsed = null,Object? hourlyStaffOfferUsed = null,Object? inbox = null,Object? messageSettings = null,Object? staffFreeAgents = null,Object? freeAgents = null,Object? strengthTable = freezed,}) {
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
as List<Player>,strengthTable: freezed == strengthTable ? _self.strengthTable : strengthTable // ignore: cast_nullable_to_non_nullable
as LeagueStrengthTable?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Team> teams,  Season currentSeason,  List<SeasonHistory> history,  String? playerTeamId,  int currentRound,  int currentWeek,  int currentDay,  int? currentHour,  bool hourlyPlayerOfferUsed,  bool hourlyStaffOfferUsed,  Inbox inbox,  MessageSettings messageSettings,  List<StaffMember> staffFreeAgents,  List<Player> freeAgents,  LeagueStrengthTable? strengthTable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeagueState() when $default != null:
return $default(_that.teams,_that.currentSeason,_that.history,_that.playerTeamId,_that.currentRound,_that.currentWeek,_that.currentDay,_that.currentHour,_that.hourlyPlayerOfferUsed,_that.hourlyStaffOfferUsed,_that.inbox,_that.messageSettings,_that.staffFreeAgents,_that.freeAgents,_that.strengthTable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Team> teams,  Season currentSeason,  List<SeasonHistory> history,  String? playerTeamId,  int currentRound,  int currentWeek,  int currentDay,  int? currentHour,  bool hourlyPlayerOfferUsed,  bool hourlyStaffOfferUsed,  Inbox inbox,  MessageSettings messageSettings,  List<StaffMember> staffFreeAgents,  List<Player> freeAgents,  LeagueStrengthTable? strengthTable)  $default,) {final _that = this;
switch (_that) {
case _LeagueState():
return $default(_that.teams,_that.currentSeason,_that.history,_that.playerTeamId,_that.currentRound,_that.currentWeek,_that.currentDay,_that.currentHour,_that.hourlyPlayerOfferUsed,_that.hourlyStaffOfferUsed,_that.inbox,_that.messageSettings,_that.staffFreeAgents,_that.freeAgents,_that.strengthTable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Team> teams,  Season currentSeason,  List<SeasonHistory> history,  String? playerTeamId,  int currentRound,  int currentWeek,  int currentDay,  int? currentHour,  bool hourlyPlayerOfferUsed,  bool hourlyStaffOfferUsed,  Inbox inbox,  MessageSettings messageSettings,  List<StaffMember> staffFreeAgents,  List<Player> freeAgents,  LeagueStrengthTable? strengthTable)?  $default,) {final _that = this;
switch (_that) {
case _LeagueState() when $default != null:
return $default(_that.teams,_that.currentSeason,_that.history,_that.playerTeamId,_that.currentRound,_that.currentWeek,_that.currentDay,_that.currentHour,_that.hourlyPlayerOfferUsed,_that.hourlyStaffOfferUsed,_that.inbox,_that.messageSettings,_that.staffFreeAgents,_that.freeAgents,_that.strengthTable);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeagueState implements LeagueState {
  const _LeagueState({required final  List<Team> teams, required this.currentSeason, final  List<SeasonHistory> history = const [], this.playerTeamId, this.currentRound = 0, this.currentWeek = 1, this.currentDay = 1, this.currentHour, this.hourlyPlayerOfferUsed = false, this.hourlyStaffOfferUsed = false, this.inbox = const Inbox(), this.messageSettings = const MessageSettings(), final  List<StaffMember> staffFreeAgents = const [], final  List<Player> freeAgents = const [], this.strengthTable}): _teams = teams,_history = history,_staffFreeAgents = staffFreeAgents,_freeAgents = freeAgents;
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

/// Tabela siły ligi (`team_management.md`). Jedno źródło prawdy dla
/// `teamStatus`, `expectedRank` i `teamPower` wszystkich 30 drużyn.
/// `null` = jeszcze nie przeliczona (zostanie obliczona przy pierwszym
/// `shouldRecalculate` w `DaySimulator`).
@override final  LeagueStrengthTable? strengthTable;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeagueState&&const DeepCollectionEquality().equals(other._teams, _teams)&&(identical(other.currentSeason, currentSeason) || other.currentSeason == currentSeason)&&const DeepCollectionEquality().equals(other._history, _history)&&(identical(other.playerTeamId, playerTeamId) || other.playerTeamId == playerTeamId)&&(identical(other.currentRound, currentRound) || other.currentRound == currentRound)&&(identical(other.currentWeek, currentWeek) || other.currentWeek == currentWeek)&&(identical(other.currentDay, currentDay) || other.currentDay == currentDay)&&(identical(other.currentHour, currentHour) || other.currentHour == currentHour)&&(identical(other.hourlyPlayerOfferUsed, hourlyPlayerOfferUsed) || other.hourlyPlayerOfferUsed == hourlyPlayerOfferUsed)&&(identical(other.hourlyStaffOfferUsed, hourlyStaffOfferUsed) || other.hourlyStaffOfferUsed == hourlyStaffOfferUsed)&&(identical(other.inbox, inbox) || other.inbox == inbox)&&(identical(other.messageSettings, messageSettings) || other.messageSettings == messageSettings)&&const DeepCollectionEquality().equals(other._staffFreeAgents, _staffFreeAgents)&&const DeepCollectionEquality().equals(other._freeAgents, _freeAgents)&&(identical(other.strengthTable, strengthTable) || other.strengthTable == strengthTable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_teams),currentSeason,const DeepCollectionEquality().hash(_history),playerTeamId,currentRound,currentWeek,currentDay,currentHour,hourlyPlayerOfferUsed,hourlyStaffOfferUsed,inbox,messageSettings,const DeepCollectionEquality().hash(_staffFreeAgents),const DeepCollectionEquality().hash(_freeAgents),strengthTable);

@override
String toString() {
  return 'LeagueState(teams: $teams, currentSeason: $currentSeason, history: $history, playerTeamId: $playerTeamId, currentRound: $currentRound, currentWeek: $currentWeek, currentDay: $currentDay, currentHour: $currentHour, hourlyPlayerOfferUsed: $hourlyPlayerOfferUsed, hourlyStaffOfferUsed: $hourlyStaffOfferUsed, inbox: $inbox, messageSettings: $messageSettings, staffFreeAgents: $staffFreeAgents, freeAgents: $freeAgents, strengthTable: $strengthTable)';
}


}

/// @nodoc
abstract mixin class _$LeagueStateCopyWith<$Res> implements $LeagueStateCopyWith<$Res> {
  factory _$LeagueStateCopyWith(_LeagueState value, $Res Function(_LeagueState) _then) = __$LeagueStateCopyWithImpl;
@override @useResult
$Res call({
 List<Team> teams, Season currentSeason, List<SeasonHistory> history, String? playerTeamId, int currentRound, int currentWeek, int currentDay, int? currentHour, bool hourlyPlayerOfferUsed, bool hourlyStaffOfferUsed, Inbox inbox, MessageSettings messageSettings, List<StaffMember> staffFreeAgents, List<Player> freeAgents, LeagueStrengthTable? strengthTable
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
@override @pragma('vm:prefer-inline') $Res call({Object? teams = null,Object? currentSeason = null,Object? history = null,Object? playerTeamId = freezed,Object? currentRound = null,Object? currentWeek = null,Object? currentDay = null,Object? currentHour = freezed,Object? hourlyPlayerOfferUsed = null,Object? hourlyStaffOfferUsed = null,Object? inbox = null,Object? messageSettings = null,Object? staffFreeAgents = null,Object? freeAgents = null,Object? strengthTable = freezed,}) {
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
as List<Player>,strengthTable: freezed == strengthTable ? _self.strengthTable : strengthTable // ignore: cast_nullable_to_non_nullable
as LeagueStrengthTable?,
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
