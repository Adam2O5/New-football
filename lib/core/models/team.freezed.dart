// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TeamAiConfig {

 double get aggressionLevel; double get riskTolerance; Map<String, dynamic> get playerPatternMemory;
/// Create a copy of TeamAiConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamAiConfigCopyWith<TeamAiConfig> get copyWith => _$TeamAiConfigCopyWithImpl<TeamAiConfig>(this as TeamAiConfig, _$identity);

  /// Serializes this TeamAiConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamAiConfig&&(identical(other.aggressionLevel, aggressionLevel) || other.aggressionLevel == aggressionLevel)&&(identical(other.riskTolerance, riskTolerance) || other.riskTolerance == riskTolerance)&&const DeepCollectionEquality().equals(other.playerPatternMemory, playerPatternMemory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,aggressionLevel,riskTolerance,const DeepCollectionEquality().hash(playerPatternMemory));

@override
String toString() {
  return 'TeamAiConfig(aggressionLevel: $aggressionLevel, riskTolerance: $riskTolerance, playerPatternMemory: $playerPatternMemory)';
}


}

/// @nodoc
abstract mixin class $TeamAiConfigCopyWith<$Res>  {
  factory $TeamAiConfigCopyWith(TeamAiConfig value, $Res Function(TeamAiConfig) _then) = _$TeamAiConfigCopyWithImpl;
@useResult
$Res call({
 double aggressionLevel, double riskTolerance, Map<String, dynamic> playerPatternMemory
});




}
/// @nodoc
class _$TeamAiConfigCopyWithImpl<$Res>
    implements $TeamAiConfigCopyWith<$Res> {
  _$TeamAiConfigCopyWithImpl(this._self, this._then);

  final TeamAiConfig _self;
  final $Res Function(TeamAiConfig) _then;

/// Create a copy of TeamAiConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? aggressionLevel = null,Object? riskTolerance = null,Object? playerPatternMemory = null,}) {
  return _then(_self.copyWith(
aggressionLevel: null == aggressionLevel ? _self.aggressionLevel : aggressionLevel // ignore: cast_nullable_to_non_nullable
as double,riskTolerance: null == riskTolerance ? _self.riskTolerance : riskTolerance // ignore: cast_nullable_to_non_nullable
as double,playerPatternMemory: null == playerPatternMemory ? _self.playerPatternMemory : playerPatternMemory // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamAiConfig].
extension TeamAiConfigPatterns on TeamAiConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamAiConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamAiConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamAiConfig value)  $default,){
final _that = this;
switch (_that) {
case _TeamAiConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamAiConfig value)?  $default,){
final _that = this;
switch (_that) {
case _TeamAiConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double aggressionLevel,  double riskTolerance,  Map<String, dynamic> playerPatternMemory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamAiConfig() when $default != null:
return $default(_that.aggressionLevel,_that.riskTolerance,_that.playerPatternMemory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double aggressionLevel,  double riskTolerance,  Map<String, dynamic> playerPatternMemory)  $default,) {final _that = this;
switch (_that) {
case _TeamAiConfig():
return $default(_that.aggressionLevel,_that.riskTolerance,_that.playerPatternMemory);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double aggressionLevel,  double riskTolerance,  Map<String, dynamic> playerPatternMemory)?  $default,) {final _that = this;
switch (_that) {
case _TeamAiConfig() when $default != null:
return $default(_that.aggressionLevel,_that.riskTolerance,_that.playerPatternMemory);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamAiConfig implements TeamAiConfig {
  const _TeamAiConfig({this.aggressionLevel = 0.5, this.riskTolerance = 0.5, final  Map<String, dynamic> playerPatternMemory = const {}}): _playerPatternMemory = playerPatternMemory;
  factory _TeamAiConfig.fromJson(Map<String, dynamic> json) => _$TeamAiConfigFromJson(json);

@override@JsonKey() final  double aggressionLevel;
@override@JsonKey() final  double riskTolerance;
 final  Map<String, dynamic> _playerPatternMemory;
@override@JsonKey() Map<String, dynamic> get playerPatternMemory {
  if (_playerPatternMemory is EqualUnmodifiableMapView) return _playerPatternMemory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_playerPatternMemory);
}


/// Create a copy of TeamAiConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamAiConfigCopyWith<_TeamAiConfig> get copyWith => __$TeamAiConfigCopyWithImpl<_TeamAiConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamAiConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamAiConfig&&(identical(other.aggressionLevel, aggressionLevel) || other.aggressionLevel == aggressionLevel)&&(identical(other.riskTolerance, riskTolerance) || other.riskTolerance == riskTolerance)&&const DeepCollectionEquality().equals(other._playerPatternMemory, _playerPatternMemory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,aggressionLevel,riskTolerance,const DeepCollectionEquality().hash(_playerPatternMemory));

@override
String toString() {
  return 'TeamAiConfig(aggressionLevel: $aggressionLevel, riskTolerance: $riskTolerance, playerPatternMemory: $playerPatternMemory)';
}


}

/// @nodoc
abstract mixin class _$TeamAiConfigCopyWith<$Res> implements $TeamAiConfigCopyWith<$Res> {
  factory _$TeamAiConfigCopyWith(_TeamAiConfig value, $Res Function(_TeamAiConfig) _then) = __$TeamAiConfigCopyWithImpl;
@override @useResult
$Res call({
 double aggressionLevel, double riskTolerance, Map<String, dynamic> playerPatternMemory
});




}
/// @nodoc
class __$TeamAiConfigCopyWithImpl<$Res>
    implements _$TeamAiConfigCopyWith<$Res> {
  __$TeamAiConfigCopyWithImpl(this._self, this._then);

  final _TeamAiConfig _self;
  final $Res Function(_TeamAiConfig) _then;

/// Create a copy of TeamAiConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? aggressionLevel = null,Object? riskTolerance = null,Object? playerPatternMemory = null,}) {
  return _then(_TeamAiConfig(
aggressionLevel: null == aggressionLevel ? _self.aggressionLevel : aggressionLevel // ignore: cast_nullable_to_non_nullable
as double,riskTolerance: null == riskTolerance ? _self.riskTolerance : riskTolerance // ignore: cast_nullable_to_non_nullable
as double,playerPatternMemory: null == playerPatternMemory ? _self._playerPatternMemory : playerPatternMemory // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$TeamWeeklyHistory {

 int get seasonYear; int get week; int get atmosphereDelta; double get chemistryDelta; int get atmosphere; double get chemistry; int get wins; int get draws; int get losses;
/// Create a copy of TeamWeeklyHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamWeeklyHistoryCopyWith<TeamWeeklyHistory> get copyWith => _$TeamWeeklyHistoryCopyWithImpl<TeamWeeklyHistory>(this as TeamWeeklyHistory, _$identity);

  /// Serializes this TeamWeeklyHistory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamWeeklyHistory&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear)&&(identical(other.week, week) || other.week == week)&&(identical(other.atmosphereDelta, atmosphereDelta) || other.atmosphereDelta == atmosphereDelta)&&(identical(other.chemistryDelta, chemistryDelta) || other.chemistryDelta == chemistryDelta)&&(identical(other.atmosphere, atmosphere) || other.atmosphere == atmosphere)&&(identical(other.chemistry, chemistry) || other.chemistry == chemistry)&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.draws, draws) || other.draws == draws)&&(identical(other.losses, losses) || other.losses == losses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,seasonYear,week,atmosphereDelta,chemistryDelta,atmosphere,chemistry,wins,draws,losses);

@override
String toString() {
  return 'TeamWeeklyHistory(seasonYear: $seasonYear, week: $week, atmosphereDelta: $atmosphereDelta, chemistryDelta: $chemistryDelta, atmosphere: $atmosphere, chemistry: $chemistry, wins: $wins, draws: $draws, losses: $losses)';
}


}

/// @nodoc
abstract mixin class $TeamWeeklyHistoryCopyWith<$Res>  {
  factory $TeamWeeklyHistoryCopyWith(TeamWeeklyHistory value, $Res Function(TeamWeeklyHistory) _then) = _$TeamWeeklyHistoryCopyWithImpl;
@useResult
$Res call({
 int seasonYear, int week, int atmosphereDelta, double chemistryDelta, int atmosphere, double chemistry, int wins, int draws, int losses
});




}
/// @nodoc
class _$TeamWeeklyHistoryCopyWithImpl<$Res>
    implements $TeamWeeklyHistoryCopyWith<$Res> {
  _$TeamWeeklyHistoryCopyWithImpl(this._self, this._then);

  final TeamWeeklyHistory _self;
  final $Res Function(TeamWeeklyHistory) _then;

/// Create a copy of TeamWeeklyHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? seasonYear = null,Object? week = null,Object? atmosphereDelta = null,Object? chemistryDelta = null,Object? atmosphere = null,Object? chemistry = null,Object? wins = null,Object? draws = null,Object? losses = null,}) {
  return _then(_self.copyWith(
seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,week: null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as int,atmosphereDelta: null == atmosphereDelta ? _self.atmosphereDelta : atmosphereDelta // ignore: cast_nullable_to_non_nullable
as int,chemistryDelta: null == chemistryDelta ? _self.chemistryDelta : chemistryDelta // ignore: cast_nullable_to_non_nullable
as double,atmosphere: null == atmosphere ? _self.atmosphere : atmosphere // ignore: cast_nullable_to_non_nullable
as int,chemistry: null == chemistry ? _self.chemistry : chemistry // ignore: cast_nullable_to_non_nullable
as double,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,draws: null == draws ? _self.draws : draws // ignore: cast_nullable_to_non_nullable
as int,losses: null == losses ? _self.losses : losses // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamWeeklyHistory].
extension TeamWeeklyHistoryPatterns on TeamWeeklyHistory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamWeeklyHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamWeeklyHistory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamWeeklyHistory value)  $default,){
final _that = this;
switch (_that) {
case _TeamWeeklyHistory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamWeeklyHistory value)?  $default,){
final _that = this;
switch (_that) {
case _TeamWeeklyHistory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int seasonYear,  int week,  int atmosphereDelta,  double chemistryDelta,  int atmosphere,  double chemistry,  int wins,  int draws,  int losses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamWeeklyHistory() when $default != null:
return $default(_that.seasonYear,_that.week,_that.atmosphereDelta,_that.chemistryDelta,_that.atmosphere,_that.chemistry,_that.wins,_that.draws,_that.losses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int seasonYear,  int week,  int atmosphereDelta,  double chemistryDelta,  int atmosphere,  double chemistry,  int wins,  int draws,  int losses)  $default,) {final _that = this;
switch (_that) {
case _TeamWeeklyHistory():
return $default(_that.seasonYear,_that.week,_that.atmosphereDelta,_that.chemistryDelta,_that.atmosphere,_that.chemistry,_that.wins,_that.draws,_that.losses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int seasonYear,  int week,  int atmosphereDelta,  double chemistryDelta,  int atmosphere,  double chemistry,  int wins,  int draws,  int losses)?  $default,) {final _that = this;
switch (_that) {
case _TeamWeeklyHistory() when $default != null:
return $default(_that.seasonYear,_that.week,_that.atmosphereDelta,_that.chemistryDelta,_that.atmosphere,_that.chemistry,_that.wins,_that.draws,_that.losses);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamWeeklyHistory implements TeamWeeklyHistory {
  const _TeamWeeklyHistory({required this.seasonYear, required this.week, this.atmosphereDelta = 0, this.chemistryDelta = 0.0, required this.atmosphere, required this.chemistry, this.wins = 0, this.draws = 0, this.losses = 0});
  factory _TeamWeeklyHistory.fromJson(Map<String, dynamic> json) => _$TeamWeeklyHistoryFromJson(json);

@override final  int seasonYear;
@override final  int week;
@override@JsonKey() final  int atmosphereDelta;
@override@JsonKey() final  double chemistryDelta;
@override final  int atmosphere;
@override final  double chemistry;
@override@JsonKey() final  int wins;
@override@JsonKey() final  int draws;
@override@JsonKey() final  int losses;

/// Create a copy of TeamWeeklyHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamWeeklyHistoryCopyWith<_TeamWeeklyHistory> get copyWith => __$TeamWeeklyHistoryCopyWithImpl<_TeamWeeklyHistory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamWeeklyHistoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamWeeklyHistory&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear)&&(identical(other.week, week) || other.week == week)&&(identical(other.atmosphereDelta, atmosphereDelta) || other.atmosphereDelta == atmosphereDelta)&&(identical(other.chemistryDelta, chemistryDelta) || other.chemistryDelta == chemistryDelta)&&(identical(other.atmosphere, atmosphere) || other.atmosphere == atmosphere)&&(identical(other.chemistry, chemistry) || other.chemistry == chemistry)&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.draws, draws) || other.draws == draws)&&(identical(other.losses, losses) || other.losses == losses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,seasonYear,week,atmosphereDelta,chemistryDelta,atmosphere,chemistry,wins,draws,losses);

@override
String toString() {
  return 'TeamWeeklyHistory(seasonYear: $seasonYear, week: $week, atmosphereDelta: $atmosphereDelta, chemistryDelta: $chemistryDelta, atmosphere: $atmosphere, chemistry: $chemistry, wins: $wins, draws: $draws, losses: $losses)';
}


}

/// @nodoc
abstract mixin class _$TeamWeeklyHistoryCopyWith<$Res> implements $TeamWeeklyHistoryCopyWith<$Res> {
  factory _$TeamWeeklyHistoryCopyWith(_TeamWeeklyHistory value, $Res Function(_TeamWeeklyHistory) _then) = __$TeamWeeklyHistoryCopyWithImpl;
@override @useResult
$Res call({
 int seasonYear, int week, int atmosphereDelta, double chemistryDelta, int atmosphere, double chemistry, int wins, int draws, int losses
});




}
/// @nodoc
class __$TeamWeeklyHistoryCopyWithImpl<$Res>
    implements _$TeamWeeklyHistoryCopyWith<$Res> {
  __$TeamWeeklyHistoryCopyWithImpl(this._self, this._then);

  final _TeamWeeklyHistory _self;
  final $Res Function(_TeamWeeklyHistory) _then;

/// Create a copy of TeamWeeklyHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? seasonYear = null,Object? week = null,Object? atmosphereDelta = null,Object? chemistryDelta = null,Object? atmosphere = null,Object? chemistry = null,Object? wins = null,Object? draws = null,Object? losses = null,}) {
  return _then(_TeamWeeklyHistory(
seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,week: null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as int,atmosphereDelta: null == atmosphereDelta ? _self.atmosphereDelta : atmosphereDelta // ignore: cast_nullable_to_non_nullable
as int,chemistryDelta: null == chemistryDelta ? _self.chemistryDelta : chemistryDelta // ignore: cast_nullable_to_non_nullable
as double,atmosphere: null == atmosphere ? _self.atmosphere : atmosphere // ignore: cast_nullable_to_non_nullable
as int,chemistry: null == chemistry ? _self.chemistry : chemistry // ignore: cast_nullable_to_non_nullable
as double,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,draws: null == draws ? _self.draws : draws // ignore: cast_nullable_to_non_nullable
as int,losses: null == losses ? _self.losses : losses // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Team {

 String get id; String get name; String get city; Conference get conference; List<Player> get roster; TeamFinance get finance; TacticsSetup get tactics; List<String> get lineupPlayerIds; List<String> get benchPlayerIds; int get atmosphere; double get chemistry; List<TeamWeeklyHistory> get weeklyHistory; List<int> get recentMatchResults; Map<String, int> get chemistryAppearances; TeamEventState get eventState; TeamStaff get staff; TeamScouting get scouting;/// Picki draftowe (własne i nabyte) — bieżący rocznik oraz przyszłe,
/// handlowalne (`docs/trade_rules.md`, `DraftPick`).
 List<DraftPick> get ownedPicks;/// `null` = drużyna gracza; ustawione = drużyna AI.
 TeamAiConfig? get ai;
/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamCopyWith<Team> get copyWith => _$TeamCopyWithImpl<Team>(this as Team, _$identity);

  /// Serializes this Team to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Team&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.city, city) || other.city == city)&&(identical(other.conference, conference) || other.conference == conference)&&const DeepCollectionEquality().equals(other.roster, roster)&&(identical(other.finance, finance) || other.finance == finance)&&(identical(other.tactics, tactics) || other.tactics == tactics)&&const DeepCollectionEquality().equals(other.lineupPlayerIds, lineupPlayerIds)&&const DeepCollectionEquality().equals(other.benchPlayerIds, benchPlayerIds)&&(identical(other.atmosphere, atmosphere) || other.atmosphere == atmosphere)&&(identical(other.chemistry, chemistry) || other.chemistry == chemistry)&&const DeepCollectionEquality().equals(other.weeklyHistory, weeklyHistory)&&const DeepCollectionEquality().equals(other.recentMatchResults, recentMatchResults)&&const DeepCollectionEquality().equals(other.chemistryAppearances, chemistryAppearances)&&(identical(other.eventState, eventState) || other.eventState == eventState)&&(identical(other.staff, staff) || other.staff == staff)&&(identical(other.scouting, scouting) || other.scouting == scouting)&&const DeepCollectionEquality().equals(other.ownedPicks, ownedPicks)&&(identical(other.ai, ai) || other.ai == ai));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,city,conference,const DeepCollectionEquality().hash(roster),finance,tactics,const DeepCollectionEquality().hash(lineupPlayerIds),const DeepCollectionEquality().hash(benchPlayerIds),atmosphere,chemistry,const DeepCollectionEquality().hash(weeklyHistory),const DeepCollectionEquality().hash(recentMatchResults),const DeepCollectionEquality().hash(chemistryAppearances),eventState,staff,scouting,const DeepCollectionEquality().hash(ownedPicks),ai]);

@override
String toString() {
  return 'Team(id: $id, name: $name, city: $city, conference: $conference, roster: $roster, finance: $finance, tactics: $tactics, lineupPlayerIds: $lineupPlayerIds, benchPlayerIds: $benchPlayerIds, atmosphere: $atmosphere, chemistry: $chemistry, weeklyHistory: $weeklyHistory, recentMatchResults: $recentMatchResults, chemistryAppearances: $chemistryAppearances, eventState: $eventState, staff: $staff, scouting: $scouting, ownedPicks: $ownedPicks, ai: $ai)';
}


}

/// @nodoc
abstract mixin class $TeamCopyWith<$Res>  {
  factory $TeamCopyWith(Team value, $Res Function(Team) _then) = _$TeamCopyWithImpl;
@useResult
$Res call({
 String id, String name, String city, Conference conference, List<Player> roster, TeamFinance finance, TacticsSetup tactics, List<String> lineupPlayerIds, List<String> benchPlayerIds, int atmosphere, double chemistry, List<TeamWeeklyHistory> weeklyHistory, List<int> recentMatchResults, Map<String, int> chemistryAppearances, TeamEventState eventState, TeamStaff staff, TeamScouting scouting, List<DraftPick> ownedPicks, TeamAiConfig? ai
});


$TeamFinanceCopyWith<$Res> get finance;$TacticsSetupCopyWith<$Res> get tactics;$TeamEventStateCopyWith<$Res> get eventState;$TeamStaffCopyWith<$Res> get staff;$TeamScoutingCopyWith<$Res> get scouting;$TeamAiConfigCopyWith<$Res>? get ai;

}
/// @nodoc
class _$TeamCopyWithImpl<$Res>
    implements $TeamCopyWith<$Res> {
  _$TeamCopyWithImpl(this._self, this._then);

  final Team _self;
  final $Res Function(Team) _then;

/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? city = null,Object? conference = null,Object? roster = null,Object? finance = null,Object? tactics = null,Object? lineupPlayerIds = null,Object? benchPlayerIds = null,Object? atmosphere = null,Object? chemistry = null,Object? weeklyHistory = null,Object? recentMatchResults = null,Object? chemistryAppearances = null,Object? eventState = null,Object? staff = null,Object? scouting = null,Object? ownedPicks = null,Object? ai = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,conference: null == conference ? _self.conference : conference // ignore: cast_nullable_to_non_nullable
as Conference,roster: null == roster ? _self.roster : roster // ignore: cast_nullable_to_non_nullable
as List<Player>,finance: null == finance ? _self.finance : finance // ignore: cast_nullable_to_non_nullable
as TeamFinance,tactics: null == tactics ? _self.tactics : tactics // ignore: cast_nullable_to_non_nullable
as TacticsSetup,lineupPlayerIds: null == lineupPlayerIds ? _self.lineupPlayerIds : lineupPlayerIds // ignore: cast_nullable_to_non_nullable
as List<String>,benchPlayerIds: null == benchPlayerIds ? _self.benchPlayerIds : benchPlayerIds // ignore: cast_nullable_to_non_nullable
as List<String>,atmosphere: null == atmosphere ? _self.atmosphere : atmosphere // ignore: cast_nullable_to_non_nullable
as int,chemistry: null == chemistry ? _self.chemistry : chemistry // ignore: cast_nullable_to_non_nullable
as double,weeklyHistory: null == weeklyHistory ? _self.weeklyHistory : weeklyHistory // ignore: cast_nullable_to_non_nullable
as List<TeamWeeklyHistory>,recentMatchResults: null == recentMatchResults ? _self.recentMatchResults : recentMatchResults // ignore: cast_nullable_to_non_nullable
as List<int>,chemistryAppearances: null == chemistryAppearances ? _self.chemistryAppearances : chemistryAppearances // ignore: cast_nullable_to_non_nullable
as Map<String, int>,eventState: null == eventState ? _self.eventState : eventState // ignore: cast_nullable_to_non_nullable
as TeamEventState,staff: null == staff ? _self.staff : staff // ignore: cast_nullable_to_non_nullable
as TeamStaff,scouting: null == scouting ? _self.scouting : scouting // ignore: cast_nullable_to_non_nullable
as TeamScouting,ownedPicks: null == ownedPicks ? _self.ownedPicks : ownedPicks // ignore: cast_nullable_to_non_nullable
as List<DraftPick>,ai: freezed == ai ? _self.ai : ai // ignore: cast_nullable_to_non_nullable
as TeamAiConfig?,
  ));
}
/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamFinanceCopyWith<$Res> get finance {
  
  return $TeamFinanceCopyWith<$Res>(_self.finance, (value) {
    return _then(_self.copyWith(finance: value));
  });
}/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TacticsSetupCopyWith<$Res> get tactics {
  
  return $TacticsSetupCopyWith<$Res>(_self.tactics, (value) {
    return _then(_self.copyWith(tactics: value));
  });
}/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamEventStateCopyWith<$Res> get eventState {
  
  return $TeamEventStateCopyWith<$Res>(_self.eventState, (value) {
    return _then(_self.copyWith(eventState: value));
  });
}/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamStaffCopyWith<$Res> get staff {
  
  return $TeamStaffCopyWith<$Res>(_self.staff, (value) {
    return _then(_self.copyWith(staff: value));
  });
}/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamScoutingCopyWith<$Res> get scouting {
  
  return $TeamScoutingCopyWith<$Res>(_self.scouting, (value) {
    return _then(_self.copyWith(scouting: value));
  });
}/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamAiConfigCopyWith<$Res>? get ai {
    if (_self.ai == null) {
    return null;
  }

  return $TeamAiConfigCopyWith<$Res>(_self.ai!, (value) {
    return _then(_self.copyWith(ai: value));
  });
}
}


/// Adds pattern-matching-related methods to [Team].
extension TeamPatterns on Team {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Team value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Team() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Team value)  $default,){
final _that = this;
switch (_that) {
case _Team():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Team value)?  $default,){
final _that = this;
switch (_that) {
case _Team() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String city,  Conference conference,  List<Player> roster,  TeamFinance finance,  TacticsSetup tactics,  List<String> lineupPlayerIds,  List<String> benchPlayerIds,  int atmosphere,  double chemistry,  List<TeamWeeklyHistory> weeklyHistory,  List<int> recentMatchResults,  Map<String, int> chemistryAppearances,  TeamEventState eventState,  TeamStaff staff,  TeamScouting scouting,  List<DraftPick> ownedPicks,  TeamAiConfig? ai)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Team() when $default != null:
return $default(_that.id,_that.name,_that.city,_that.conference,_that.roster,_that.finance,_that.tactics,_that.lineupPlayerIds,_that.benchPlayerIds,_that.atmosphere,_that.chemistry,_that.weeklyHistory,_that.recentMatchResults,_that.chemistryAppearances,_that.eventState,_that.staff,_that.scouting,_that.ownedPicks,_that.ai);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String city,  Conference conference,  List<Player> roster,  TeamFinance finance,  TacticsSetup tactics,  List<String> lineupPlayerIds,  List<String> benchPlayerIds,  int atmosphere,  double chemistry,  List<TeamWeeklyHistory> weeklyHistory,  List<int> recentMatchResults,  Map<String, int> chemistryAppearances,  TeamEventState eventState,  TeamStaff staff,  TeamScouting scouting,  List<DraftPick> ownedPicks,  TeamAiConfig? ai)  $default,) {final _that = this;
switch (_that) {
case _Team():
return $default(_that.id,_that.name,_that.city,_that.conference,_that.roster,_that.finance,_that.tactics,_that.lineupPlayerIds,_that.benchPlayerIds,_that.atmosphere,_that.chemistry,_that.weeklyHistory,_that.recentMatchResults,_that.chemistryAppearances,_that.eventState,_that.staff,_that.scouting,_that.ownedPicks,_that.ai);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String city,  Conference conference,  List<Player> roster,  TeamFinance finance,  TacticsSetup tactics,  List<String> lineupPlayerIds,  List<String> benchPlayerIds,  int atmosphere,  double chemistry,  List<TeamWeeklyHistory> weeklyHistory,  List<int> recentMatchResults,  Map<String, int> chemistryAppearances,  TeamEventState eventState,  TeamStaff staff,  TeamScouting scouting,  List<DraftPick> ownedPicks,  TeamAiConfig? ai)?  $default,) {final _that = this;
switch (_that) {
case _Team() when $default != null:
return $default(_that.id,_that.name,_that.city,_that.conference,_that.roster,_that.finance,_that.tactics,_that.lineupPlayerIds,_that.benchPlayerIds,_that.atmosphere,_that.chemistry,_that.weeklyHistory,_that.recentMatchResults,_that.chemistryAppearances,_that.eventState,_that.staff,_that.scouting,_that.ownedPicks,_that.ai);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Team implements Team {
  const _Team({required this.id, required this.name, required this.city, required this.conference, required final  List<Player> roster, required this.finance, this.tactics = const TacticsSetup(), final  List<String> lineupPlayerIds = const [], final  List<String> benchPlayerIds = const [], this.atmosphere = 50, this.chemistry = 50.0, final  List<TeamWeeklyHistory> weeklyHistory = const [], final  List<int> recentMatchResults = const [], final  Map<String, int> chemistryAppearances = const {}, this.eventState = const TeamEventState(), this.staff = const TeamStaff(), this.scouting = const TeamScouting(), final  List<DraftPick> ownedPicks = const [], this.ai}): _roster = roster,_lineupPlayerIds = lineupPlayerIds,_benchPlayerIds = benchPlayerIds,_weeklyHistory = weeklyHistory,_recentMatchResults = recentMatchResults,_chemistryAppearances = chemistryAppearances,_ownedPicks = ownedPicks;
  factory _Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);

@override final  String id;
@override final  String name;
@override final  String city;
@override final  Conference conference;
 final  List<Player> _roster;
@override List<Player> get roster {
  if (_roster is EqualUnmodifiableListView) return _roster;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roster);
}

@override final  TeamFinance finance;
@override@JsonKey() final  TacticsSetup tactics;
 final  List<String> _lineupPlayerIds;
@override@JsonKey() List<String> get lineupPlayerIds {
  if (_lineupPlayerIds is EqualUnmodifiableListView) return _lineupPlayerIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lineupPlayerIds);
}

 final  List<String> _benchPlayerIds;
@override@JsonKey() List<String> get benchPlayerIds {
  if (_benchPlayerIds is EqualUnmodifiableListView) return _benchPlayerIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_benchPlayerIds);
}

@override@JsonKey() final  int atmosphere;
@override@JsonKey() final  double chemistry;
 final  List<TeamWeeklyHistory> _weeklyHistory;
@override@JsonKey() List<TeamWeeklyHistory> get weeklyHistory {
  if (_weeklyHistory is EqualUnmodifiableListView) return _weeklyHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weeklyHistory);
}

 final  List<int> _recentMatchResults;
@override@JsonKey() List<int> get recentMatchResults {
  if (_recentMatchResults is EqualUnmodifiableListView) return _recentMatchResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentMatchResults);
}

 final  Map<String, int> _chemistryAppearances;
@override@JsonKey() Map<String, int> get chemistryAppearances {
  if (_chemistryAppearances is EqualUnmodifiableMapView) return _chemistryAppearances;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_chemistryAppearances);
}

@override@JsonKey() final  TeamEventState eventState;
@override@JsonKey() final  TeamStaff staff;
@override@JsonKey() final  TeamScouting scouting;
/// Picki draftowe (własne i nabyte) — bieżący rocznik oraz przyszłe,
/// handlowalne (`docs/trade_rules.md`, `DraftPick`).
 final  List<DraftPick> _ownedPicks;
/// Picki draftowe (własne i nabyte) — bieżący rocznik oraz przyszłe,
/// handlowalne (`docs/trade_rules.md`, `DraftPick`).
@override@JsonKey() List<DraftPick> get ownedPicks {
  if (_ownedPicks is EqualUnmodifiableListView) return _ownedPicks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ownedPicks);
}

/// `null` = drużyna gracza; ustawione = drużyna AI.
@override final  TeamAiConfig? ai;

/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamCopyWith<_Team> get copyWith => __$TeamCopyWithImpl<_Team>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Team&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.city, city) || other.city == city)&&(identical(other.conference, conference) || other.conference == conference)&&const DeepCollectionEquality().equals(other._roster, _roster)&&(identical(other.finance, finance) || other.finance == finance)&&(identical(other.tactics, tactics) || other.tactics == tactics)&&const DeepCollectionEquality().equals(other._lineupPlayerIds, _lineupPlayerIds)&&const DeepCollectionEquality().equals(other._benchPlayerIds, _benchPlayerIds)&&(identical(other.atmosphere, atmosphere) || other.atmosphere == atmosphere)&&(identical(other.chemistry, chemistry) || other.chemistry == chemistry)&&const DeepCollectionEquality().equals(other._weeklyHistory, _weeklyHistory)&&const DeepCollectionEquality().equals(other._recentMatchResults, _recentMatchResults)&&const DeepCollectionEquality().equals(other._chemistryAppearances, _chemistryAppearances)&&(identical(other.eventState, eventState) || other.eventState == eventState)&&(identical(other.staff, staff) || other.staff == staff)&&(identical(other.scouting, scouting) || other.scouting == scouting)&&const DeepCollectionEquality().equals(other._ownedPicks, _ownedPicks)&&(identical(other.ai, ai) || other.ai == ai));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,city,conference,const DeepCollectionEquality().hash(_roster),finance,tactics,const DeepCollectionEquality().hash(_lineupPlayerIds),const DeepCollectionEquality().hash(_benchPlayerIds),atmosphere,chemistry,const DeepCollectionEquality().hash(_weeklyHistory),const DeepCollectionEquality().hash(_recentMatchResults),const DeepCollectionEquality().hash(_chemistryAppearances),eventState,staff,scouting,const DeepCollectionEquality().hash(_ownedPicks),ai]);

@override
String toString() {
  return 'Team(id: $id, name: $name, city: $city, conference: $conference, roster: $roster, finance: $finance, tactics: $tactics, lineupPlayerIds: $lineupPlayerIds, benchPlayerIds: $benchPlayerIds, atmosphere: $atmosphere, chemistry: $chemistry, weeklyHistory: $weeklyHistory, recentMatchResults: $recentMatchResults, chemistryAppearances: $chemistryAppearances, eventState: $eventState, staff: $staff, scouting: $scouting, ownedPicks: $ownedPicks, ai: $ai)';
}


}

/// @nodoc
abstract mixin class _$TeamCopyWith<$Res> implements $TeamCopyWith<$Res> {
  factory _$TeamCopyWith(_Team value, $Res Function(_Team) _then) = __$TeamCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String city, Conference conference, List<Player> roster, TeamFinance finance, TacticsSetup tactics, List<String> lineupPlayerIds, List<String> benchPlayerIds, int atmosphere, double chemistry, List<TeamWeeklyHistory> weeklyHistory, List<int> recentMatchResults, Map<String, int> chemistryAppearances, TeamEventState eventState, TeamStaff staff, TeamScouting scouting, List<DraftPick> ownedPicks, TeamAiConfig? ai
});


@override $TeamFinanceCopyWith<$Res> get finance;@override $TacticsSetupCopyWith<$Res> get tactics;@override $TeamEventStateCopyWith<$Res> get eventState;@override $TeamStaffCopyWith<$Res> get staff;@override $TeamScoutingCopyWith<$Res> get scouting;@override $TeamAiConfigCopyWith<$Res>? get ai;

}
/// @nodoc
class __$TeamCopyWithImpl<$Res>
    implements _$TeamCopyWith<$Res> {
  __$TeamCopyWithImpl(this._self, this._then);

  final _Team _self;
  final $Res Function(_Team) _then;

/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? city = null,Object? conference = null,Object? roster = null,Object? finance = null,Object? tactics = null,Object? lineupPlayerIds = null,Object? benchPlayerIds = null,Object? atmosphere = null,Object? chemistry = null,Object? weeklyHistory = null,Object? recentMatchResults = null,Object? chemistryAppearances = null,Object? eventState = null,Object? staff = null,Object? scouting = null,Object? ownedPicks = null,Object? ai = freezed,}) {
  return _then(_Team(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,conference: null == conference ? _self.conference : conference // ignore: cast_nullable_to_non_nullable
as Conference,roster: null == roster ? _self._roster : roster // ignore: cast_nullable_to_non_nullable
as List<Player>,finance: null == finance ? _self.finance : finance // ignore: cast_nullable_to_non_nullable
as TeamFinance,tactics: null == tactics ? _self.tactics : tactics // ignore: cast_nullable_to_non_nullable
as TacticsSetup,lineupPlayerIds: null == lineupPlayerIds ? _self._lineupPlayerIds : lineupPlayerIds // ignore: cast_nullable_to_non_nullable
as List<String>,benchPlayerIds: null == benchPlayerIds ? _self._benchPlayerIds : benchPlayerIds // ignore: cast_nullable_to_non_nullable
as List<String>,atmosphere: null == atmosphere ? _self.atmosphere : atmosphere // ignore: cast_nullable_to_non_nullable
as int,chemistry: null == chemistry ? _self.chemistry : chemistry // ignore: cast_nullable_to_non_nullable
as double,weeklyHistory: null == weeklyHistory ? _self._weeklyHistory : weeklyHistory // ignore: cast_nullable_to_non_nullable
as List<TeamWeeklyHistory>,recentMatchResults: null == recentMatchResults ? _self._recentMatchResults : recentMatchResults // ignore: cast_nullable_to_non_nullable
as List<int>,chemistryAppearances: null == chemistryAppearances ? _self._chemistryAppearances : chemistryAppearances // ignore: cast_nullable_to_non_nullable
as Map<String, int>,eventState: null == eventState ? _self.eventState : eventState // ignore: cast_nullable_to_non_nullable
as TeamEventState,staff: null == staff ? _self.staff : staff // ignore: cast_nullable_to_non_nullable
as TeamStaff,scouting: null == scouting ? _self.scouting : scouting // ignore: cast_nullable_to_non_nullable
as TeamScouting,ownedPicks: null == ownedPicks ? _self._ownedPicks : ownedPicks // ignore: cast_nullable_to_non_nullable
as List<DraftPick>,ai: freezed == ai ? _self.ai : ai // ignore: cast_nullable_to_non_nullable
as TeamAiConfig?,
  ));
}

/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamFinanceCopyWith<$Res> get finance {
  
  return $TeamFinanceCopyWith<$Res>(_self.finance, (value) {
    return _then(_self.copyWith(finance: value));
  });
}/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TacticsSetupCopyWith<$Res> get tactics {
  
  return $TacticsSetupCopyWith<$Res>(_self.tactics, (value) {
    return _then(_self.copyWith(tactics: value));
  });
}/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamEventStateCopyWith<$Res> get eventState {
  
  return $TeamEventStateCopyWith<$Res>(_self.eventState, (value) {
    return _then(_self.copyWith(eventState: value));
  });
}/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamStaffCopyWith<$Res> get staff {
  
  return $TeamStaffCopyWith<$Res>(_self.staff, (value) {
    return _then(_self.copyWith(staff: value));
  });
}/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamScoutingCopyWith<$Res> get scouting {
  
  return $TeamScoutingCopyWith<$Res>(_self.scouting, (value) {
    return _then(_self.copyWith(scouting: value));
  });
}/// Create a copy of Team
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamAiConfigCopyWith<$Res>? get ai {
    if (_self.ai == null) {
    return null;
  }

  return $TeamAiConfigCopyWith<$Res>(_self.ai!, (value) {
    return _then(_self.copyWith(ai: value));
  });
}
}

// dart format on
