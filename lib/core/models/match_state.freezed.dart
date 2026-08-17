// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MatchContext {

 String get homeTeamId; String get awayTeamId; Weather get weather; int get temperatureC; bool get isDerby; MatchStake get stake; double get refereeStrictness; int get crowdIntensity; int get homeMatchInWeek; int get awayMatchInWeek; int get seed; double get homeAdvantage;
/// Create a copy of MatchContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchContextCopyWith<MatchContext> get copyWith => _$MatchContextCopyWithImpl<MatchContext>(this as MatchContext, _$identity);

  /// Serializes this MatchContext to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchContext&&(identical(other.homeTeamId, homeTeamId) || other.homeTeamId == homeTeamId)&&(identical(other.awayTeamId, awayTeamId) || other.awayTeamId == awayTeamId)&&(identical(other.weather, weather) || other.weather == weather)&&(identical(other.temperatureC, temperatureC) || other.temperatureC == temperatureC)&&(identical(other.isDerby, isDerby) || other.isDerby == isDerby)&&(identical(other.stake, stake) || other.stake == stake)&&(identical(other.refereeStrictness, refereeStrictness) || other.refereeStrictness == refereeStrictness)&&(identical(other.crowdIntensity, crowdIntensity) || other.crowdIntensity == crowdIntensity)&&(identical(other.homeMatchInWeek, homeMatchInWeek) || other.homeMatchInWeek == homeMatchInWeek)&&(identical(other.awayMatchInWeek, awayMatchInWeek) || other.awayMatchInWeek == awayMatchInWeek)&&(identical(other.seed, seed) || other.seed == seed)&&(identical(other.homeAdvantage, homeAdvantage) || other.homeAdvantage == homeAdvantage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,homeTeamId,awayTeamId,weather,temperatureC,isDerby,stake,refereeStrictness,crowdIntensity,homeMatchInWeek,awayMatchInWeek,seed,homeAdvantage);

@override
String toString() {
  return 'MatchContext(homeTeamId: $homeTeamId, awayTeamId: $awayTeamId, weather: $weather, temperatureC: $temperatureC, isDerby: $isDerby, stake: $stake, refereeStrictness: $refereeStrictness, crowdIntensity: $crowdIntensity, homeMatchInWeek: $homeMatchInWeek, awayMatchInWeek: $awayMatchInWeek, seed: $seed, homeAdvantage: $homeAdvantage)';
}


}

/// @nodoc
abstract mixin class $MatchContextCopyWith<$Res>  {
  factory $MatchContextCopyWith(MatchContext value, $Res Function(MatchContext) _then) = _$MatchContextCopyWithImpl;
@useResult
$Res call({
 String homeTeamId, String awayTeamId, Weather weather, int temperatureC, bool isDerby, MatchStake stake, double refereeStrictness, int crowdIntensity, int homeMatchInWeek, int awayMatchInWeek, int seed, double homeAdvantage
});




}
/// @nodoc
class _$MatchContextCopyWithImpl<$Res>
    implements $MatchContextCopyWith<$Res> {
  _$MatchContextCopyWithImpl(this._self, this._then);

  final MatchContext _self;
  final $Res Function(MatchContext) _then;

/// Create a copy of MatchContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? homeTeamId = null,Object? awayTeamId = null,Object? weather = null,Object? temperatureC = null,Object? isDerby = null,Object? stake = null,Object? refereeStrictness = null,Object? crowdIntensity = null,Object? homeMatchInWeek = null,Object? awayMatchInWeek = null,Object? seed = null,Object? homeAdvantage = null,}) {
  return _then(_self.copyWith(
homeTeamId: null == homeTeamId ? _self.homeTeamId : homeTeamId // ignore: cast_nullable_to_non_nullable
as String,awayTeamId: null == awayTeamId ? _self.awayTeamId : awayTeamId // ignore: cast_nullable_to_non_nullable
as String,weather: null == weather ? _self.weather : weather // ignore: cast_nullable_to_non_nullable
as Weather,temperatureC: null == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as int,isDerby: null == isDerby ? _self.isDerby : isDerby // ignore: cast_nullable_to_non_nullable
as bool,stake: null == stake ? _self.stake : stake // ignore: cast_nullable_to_non_nullable
as MatchStake,refereeStrictness: null == refereeStrictness ? _self.refereeStrictness : refereeStrictness // ignore: cast_nullable_to_non_nullable
as double,crowdIntensity: null == crowdIntensity ? _self.crowdIntensity : crowdIntensity // ignore: cast_nullable_to_non_nullable
as int,homeMatchInWeek: null == homeMatchInWeek ? _self.homeMatchInWeek : homeMatchInWeek // ignore: cast_nullable_to_non_nullable
as int,awayMatchInWeek: null == awayMatchInWeek ? _self.awayMatchInWeek : awayMatchInWeek // ignore: cast_nullable_to_non_nullable
as int,seed: null == seed ? _self.seed : seed // ignore: cast_nullable_to_non_nullable
as int,homeAdvantage: null == homeAdvantage ? _self.homeAdvantage : homeAdvantage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchContext].
extension MatchContextPatterns on MatchContext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchContext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchContext value)  $default,){
final _that = this;
switch (_that) {
case _MatchContext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchContext value)?  $default,){
final _that = this;
switch (_that) {
case _MatchContext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String homeTeamId,  String awayTeamId,  Weather weather,  int temperatureC,  bool isDerby,  MatchStake stake,  double refereeStrictness,  int crowdIntensity,  int homeMatchInWeek,  int awayMatchInWeek,  int seed,  double homeAdvantage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchContext() when $default != null:
return $default(_that.homeTeamId,_that.awayTeamId,_that.weather,_that.temperatureC,_that.isDerby,_that.stake,_that.refereeStrictness,_that.crowdIntensity,_that.homeMatchInWeek,_that.awayMatchInWeek,_that.seed,_that.homeAdvantage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String homeTeamId,  String awayTeamId,  Weather weather,  int temperatureC,  bool isDerby,  MatchStake stake,  double refereeStrictness,  int crowdIntensity,  int homeMatchInWeek,  int awayMatchInWeek,  int seed,  double homeAdvantage)  $default,) {final _that = this;
switch (_that) {
case _MatchContext():
return $default(_that.homeTeamId,_that.awayTeamId,_that.weather,_that.temperatureC,_that.isDerby,_that.stake,_that.refereeStrictness,_that.crowdIntensity,_that.homeMatchInWeek,_that.awayMatchInWeek,_that.seed,_that.homeAdvantage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String homeTeamId,  String awayTeamId,  Weather weather,  int temperatureC,  bool isDerby,  MatchStake stake,  double refereeStrictness,  int crowdIntensity,  int homeMatchInWeek,  int awayMatchInWeek,  int seed,  double homeAdvantage)?  $default,) {final _that = this;
switch (_that) {
case _MatchContext() when $default != null:
return $default(_that.homeTeamId,_that.awayTeamId,_that.weather,_that.temperatureC,_that.isDerby,_that.stake,_that.refereeStrictness,_that.crowdIntensity,_that.homeMatchInWeek,_that.awayMatchInWeek,_that.seed,_that.homeAdvantage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatchContext implements MatchContext {
  const _MatchContext({this.homeTeamId = '', this.awayTeamId = '', this.weather = Weather.clear, this.temperatureC = 0, this.isDerby = false, this.stake = MatchStake.regular, this.refereeStrictness = 1.0, this.crowdIntensity = 0, this.homeMatchInWeek = 1, this.awayMatchInWeek = 1, this.seed = 0, this.homeAdvantage = 0.05});
  factory _MatchContext.fromJson(Map<String, dynamic> json) => _$MatchContextFromJson(json);

@override@JsonKey() final  String homeTeamId;
@override@JsonKey() final  String awayTeamId;
@override@JsonKey() final  Weather weather;
@override@JsonKey() final  int temperatureC;
@override@JsonKey() final  bool isDerby;
@override@JsonKey() final  MatchStake stake;
@override@JsonKey() final  double refereeStrictness;
@override@JsonKey() final  int crowdIntensity;
@override@JsonKey() final  int homeMatchInWeek;
@override@JsonKey() final  int awayMatchInWeek;
@override@JsonKey() final  int seed;
@override@JsonKey() final  double homeAdvantage;

/// Create a copy of MatchContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchContextCopyWith<_MatchContext> get copyWith => __$MatchContextCopyWithImpl<_MatchContext>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchContextToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchContext&&(identical(other.homeTeamId, homeTeamId) || other.homeTeamId == homeTeamId)&&(identical(other.awayTeamId, awayTeamId) || other.awayTeamId == awayTeamId)&&(identical(other.weather, weather) || other.weather == weather)&&(identical(other.temperatureC, temperatureC) || other.temperatureC == temperatureC)&&(identical(other.isDerby, isDerby) || other.isDerby == isDerby)&&(identical(other.stake, stake) || other.stake == stake)&&(identical(other.refereeStrictness, refereeStrictness) || other.refereeStrictness == refereeStrictness)&&(identical(other.crowdIntensity, crowdIntensity) || other.crowdIntensity == crowdIntensity)&&(identical(other.homeMatchInWeek, homeMatchInWeek) || other.homeMatchInWeek == homeMatchInWeek)&&(identical(other.awayMatchInWeek, awayMatchInWeek) || other.awayMatchInWeek == awayMatchInWeek)&&(identical(other.seed, seed) || other.seed == seed)&&(identical(other.homeAdvantage, homeAdvantage) || other.homeAdvantage == homeAdvantage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,homeTeamId,awayTeamId,weather,temperatureC,isDerby,stake,refereeStrictness,crowdIntensity,homeMatchInWeek,awayMatchInWeek,seed,homeAdvantage);

@override
String toString() {
  return 'MatchContext(homeTeamId: $homeTeamId, awayTeamId: $awayTeamId, weather: $weather, temperatureC: $temperatureC, isDerby: $isDerby, stake: $stake, refereeStrictness: $refereeStrictness, crowdIntensity: $crowdIntensity, homeMatchInWeek: $homeMatchInWeek, awayMatchInWeek: $awayMatchInWeek, seed: $seed, homeAdvantage: $homeAdvantage)';
}


}

/// @nodoc
abstract mixin class _$MatchContextCopyWith<$Res> implements $MatchContextCopyWith<$Res> {
  factory _$MatchContextCopyWith(_MatchContext value, $Res Function(_MatchContext) _then) = __$MatchContextCopyWithImpl;
@override @useResult
$Res call({
 String homeTeamId, String awayTeamId, Weather weather, int temperatureC, bool isDerby, MatchStake stake, double refereeStrictness, int crowdIntensity, int homeMatchInWeek, int awayMatchInWeek, int seed, double homeAdvantage
});




}
/// @nodoc
class __$MatchContextCopyWithImpl<$Res>
    implements _$MatchContextCopyWith<$Res> {
  __$MatchContextCopyWithImpl(this._self, this._then);

  final _MatchContext _self;
  final $Res Function(_MatchContext) _then;

/// Create a copy of MatchContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? homeTeamId = null,Object? awayTeamId = null,Object? weather = null,Object? temperatureC = null,Object? isDerby = null,Object? stake = null,Object? refereeStrictness = null,Object? crowdIntensity = null,Object? homeMatchInWeek = null,Object? awayMatchInWeek = null,Object? seed = null,Object? homeAdvantage = null,}) {
  return _then(_MatchContext(
homeTeamId: null == homeTeamId ? _self.homeTeamId : homeTeamId // ignore: cast_nullable_to_non_nullable
as String,awayTeamId: null == awayTeamId ? _self.awayTeamId : awayTeamId // ignore: cast_nullable_to_non_nullable
as String,weather: null == weather ? _self.weather : weather // ignore: cast_nullable_to_non_nullable
as Weather,temperatureC: null == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as int,isDerby: null == isDerby ? _self.isDerby : isDerby // ignore: cast_nullable_to_non_nullable
as bool,stake: null == stake ? _self.stake : stake // ignore: cast_nullable_to_non_nullable
as MatchStake,refereeStrictness: null == refereeStrictness ? _self.refereeStrictness : refereeStrictness // ignore: cast_nullable_to_non_nullable
as double,crowdIntensity: null == crowdIntensity ? _self.crowdIntensity : crowdIntensity // ignore: cast_nullable_to_non_nullable
as int,homeMatchInWeek: null == homeMatchInWeek ? _self.homeMatchInWeek : homeMatchInWeek // ignore: cast_nullable_to_non_nullable
as int,awayMatchInWeek: null == awayMatchInWeek ? _self.awayMatchInWeek : awayMatchInWeek // ignore: cast_nullable_to_non_nullable
as int,seed: null == seed ? _self.seed : seed // ignore: cast_nullable_to_non_nullable
as int,homeAdvantage: null == homeAdvantage ? _self.homeAdvantage : homeAdvantage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$MatchState {

 int get minute; int get homeGoals; int get awayGoals; List<Player> get homeLineup; List<Player> get awayLineup; List<Player> get homeBench; List<Player> get awayBench; TacticsSetup get homeTactics; TacticsSetup get awayTactics; Map<String, int> get yellowCardCounts; List<String> get sentOffPlayerIds; List<String> get injuriesThisMatch; double get momentum; double get moraleModHome; double get moraleModAway; MatchContext get context; int? get rngSeed;
/// Create a copy of MatchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchStateCopyWith<MatchState> get copyWith => _$MatchStateCopyWithImpl<MatchState>(this as MatchState, _$identity);

  /// Serializes this MatchState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchState&&(identical(other.minute, minute) || other.minute == minute)&&(identical(other.homeGoals, homeGoals) || other.homeGoals == homeGoals)&&(identical(other.awayGoals, awayGoals) || other.awayGoals == awayGoals)&&const DeepCollectionEquality().equals(other.homeLineup, homeLineup)&&const DeepCollectionEquality().equals(other.awayLineup, awayLineup)&&const DeepCollectionEquality().equals(other.homeBench, homeBench)&&const DeepCollectionEquality().equals(other.awayBench, awayBench)&&(identical(other.homeTactics, homeTactics) || other.homeTactics == homeTactics)&&(identical(other.awayTactics, awayTactics) || other.awayTactics == awayTactics)&&const DeepCollectionEquality().equals(other.yellowCardCounts, yellowCardCounts)&&const DeepCollectionEquality().equals(other.sentOffPlayerIds, sentOffPlayerIds)&&const DeepCollectionEquality().equals(other.injuriesThisMatch, injuriesThisMatch)&&(identical(other.momentum, momentum) || other.momentum == momentum)&&(identical(other.moraleModHome, moraleModHome) || other.moraleModHome == moraleModHome)&&(identical(other.moraleModAway, moraleModAway) || other.moraleModAway == moraleModAway)&&(identical(other.context, context) || other.context == context)&&(identical(other.rngSeed, rngSeed) || other.rngSeed == rngSeed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minute,homeGoals,awayGoals,const DeepCollectionEquality().hash(homeLineup),const DeepCollectionEquality().hash(awayLineup),const DeepCollectionEquality().hash(homeBench),const DeepCollectionEquality().hash(awayBench),homeTactics,awayTactics,const DeepCollectionEquality().hash(yellowCardCounts),const DeepCollectionEquality().hash(sentOffPlayerIds),const DeepCollectionEquality().hash(injuriesThisMatch),momentum,moraleModHome,moraleModAway,context,rngSeed);

@override
String toString() {
  return 'MatchState(minute: $minute, homeGoals: $homeGoals, awayGoals: $awayGoals, homeLineup: $homeLineup, awayLineup: $awayLineup, homeBench: $homeBench, awayBench: $awayBench, homeTactics: $homeTactics, awayTactics: $awayTactics, yellowCardCounts: $yellowCardCounts, sentOffPlayerIds: $sentOffPlayerIds, injuriesThisMatch: $injuriesThisMatch, momentum: $momentum, moraleModHome: $moraleModHome, moraleModAway: $moraleModAway, context: $context, rngSeed: $rngSeed)';
}


}

/// @nodoc
abstract mixin class $MatchStateCopyWith<$Res>  {
  factory $MatchStateCopyWith(MatchState value, $Res Function(MatchState) _then) = _$MatchStateCopyWithImpl;
@useResult
$Res call({
 int minute, int homeGoals, int awayGoals, List<Player> homeLineup, List<Player> awayLineup, List<Player> homeBench, List<Player> awayBench, TacticsSetup homeTactics, TacticsSetup awayTactics, Map<String, int> yellowCardCounts, List<String> sentOffPlayerIds, List<String> injuriesThisMatch, double momentum, double moraleModHome, double moraleModAway, MatchContext context, int? rngSeed
});


$TacticsSetupCopyWith<$Res> get homeTactics;$TacticsSetupCopyWith<$Res> get awayTactics;$MatchContextCopyWith<$Res> get context;

}
/// @nodoc
class _$MatchStateCopyWithImpl<$Res>
    implements $MatchStateCopyWith<$Res> {
  _$MatchStateCopyWithImpl(this._self, this._then);

  final MatchState _self;
  final $Res Function(MatchState) _then;

/// Create a copy of MatchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? minute = null,Object? homeGoals = null,Object? awayGoals = null,Object? homeLineup = null,Object? awayLineup = null,Object? homeBench = null,Object? awayBench = null,Object? homeTactics = null,Object? awayTactics = null,Object? yellowCardCounts = null,Object? sentOffPlayerIds = null,Object? injuriesThisMatch = null,Object? momentum = null,Object? moraleModHome = null,Object? moraleModAway = null,Object? context = null,Object? rngSeed = freezed,}) {
  return _then(_self.copyWith(
minute: null == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int,homeGoals: null == homeGoals ? _self.homeGoals : homeGoals // ignore: cast_nullable_to_non_nullable
as int,awayGoals: null == awayGoals ? _self.awayGoals : awayGoals // ignore: cast_nullable_to_non_nullable
as int,homeLineup: null == homeLineup ? _self.homeLineup : homeLineup // ignore: cast_nullable_to_non_nullable
as List<Player>,awayLineup: null == awayLineup ? _self.awayLineup : awayLineup // ignore: cast_nullable_to_non_nullable
as List<Player>,homeBench: null == homeBench ? _self.homeBench : homeBench // ignore: cast_nullable_to_non_nullable
as List<Player>,awayBench: null == awayBench ? _self.awayBench : awayBench // ignore: cast_nullable_to_non_nullable
as List<Player>,homeTactics: null == homeTactics ? _self.homeTactics : homeTactics // ignore: cast_nullable_to_non_nullable
as TacticsSetup,awayTactics: null == awayTactics ? _self.awayTactics : awayTactics // ignore: cast_nullable_to_non_nullable
as TacticsSetup,yellowCardCounts: null == yellowCardCounts ? _self.yellowCardCounts : yellowCardCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,sentOffPlayerIds: null == sentOffPlayerIds ? _self.sentOffPlayerIds : sentOffPlayerIds // ignore: cast_nullable_to_non_nullable
as List<String>,injuriesThisMatch: null == injuriesThisMatch ? _self.injuriesThisMatch : injuriesThisMatch // ignore: cast_nullable_to_non_nullable
as List<String>,momentum: null == momentum ? _self.momentum : momentum // ignore: cast_nullable_to_non_nullable
as double,moraleModHome: null == moraleModHome ? _self.moraleModHome : moraleModHome // ignore: cast_nullable_to_non_nullable
as double,moraleModAway: null == moraleModAway ? _self.moraleModAway : moraleModAway // ignore: cast_nullable_to_non_nullable
as double,context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as MatchContext,rngSeed: freezed == rngSeed ? _self.rngSeed : rngSeed // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of MatchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TacticsSetupCopyWith<$Res> get homeTactics {
  
  return $TacticsSetupCopyWith<$Res>(_self.homeTactics, (value) {
    return _then(_self.copyWith(homeTactics: value));
  });
}/// Create a copy of MatchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TacticsSetupCopyWith<$Res> get awayTactics {
  
  return $TacticsSetupCopyWith<$Res>(_self.awayTactics, (value) {
    return _then(_self.copyWith(awayTactics: value));
  });
}/// Create a copy of MatchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchContextCopyWith<$Res> get context {
  
  return $MatchContextCopyWith<$Res>(_self.context, (value) {
    return _then(_self.copyWith(context: value));
  });
}
}


/// Adds pattern-matching-related methods to [MatchState].
extension MatchStatePatterns on MatchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchState value)  $default,){
final _that = this;
switch (_that) {
case _MatchState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchState value)?  $default,){
final _that = this;
switch (_that) {
case _MatchState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int minute,  int homeGoals,  int awayGoals,  List<Player> homeLineup,  List<Player> awayLineup,  List<Player> homeBench,  List<Player> awayBench,  TacticsSetup homeTactics,  TacticsSetup awayTactics,  Map<String, int> yellowCardCounts,  List<String> sentOffPlayerIds,  List<String> injuriesThisMatch,  double momentum,  double moraleModHome,  double moraleModAway,  MatchContext context,  int? rngSeed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchState() when $default != null:
return $default(_that.minute,_that.homeGoals,_that.awayGoals,_that.homeLineup,_that.awayLineup,_that.homeBench,_that.awayBench,_that.homeTactics,_that.awayTactics,_that.yellowCardCounts,_that.sentOffPlayerIds,_that.injuriesThisMatch,_that.momentum,_that.moraleModHome,_that.moraleModAway,_that.context,_that.rngSeed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int minute,  int homeGoals,  int awayGoals,  List<Player> homeLineup,  List<Player> awayLineup,  List<Player> homeBench,  List<Player> awayBench,  TacticsSetup homeTactics,  TacticsSetup awayTactics,  Map<String, int> yellowCardCounts,  List<String> sentOffPlayerIds,  List<String> injuriesThisMatch,  double momentum,  double moraleModHome,  double moraleModAway,  MatchContext context,  int? rngSeed)  $default,) {final _that = this;
switch (_that) {
case _MatchState():
return $default(_that.minute,_that.homeGoals,_that.awayGoals,_that.homeLineup,_that.awayLineup,_that.homeBench,_that.awayBench,_that.homeTactics,_that.awayTactics,_that.yellowCardCounts,_that.sentOffPlayerIds,_that.injuriesThisMatch,_that.momentum,_that.moraleModHome,_that.moraleModAway,_that.context,_that.rngSeed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int minute,  int homeGoals,  int awayGoals,  List<Player> homeLineup,  List<Player> awayLineup,  List<Player> homeBench,  List<Player> awayBench,  TacticsSetup homeTactics,  TacticsSetup awayTactics,  Map<String, int> yellowCardCounts,  List<String> sentOffPlayerIds,  List<String> injuriesThisMatch,  double momentum,  double moraleModHome,  double moraleModAway,  MatchContext context,  int? rngSeed)?  $default,) {final _that = this;
switch (_that) {
case _MatchState() when $default != null:
return $default(_that.minute,_that.homeGoals,_that.awayGoals,_that.homeLineup,_that.awayLineup,_that.homeBench,_that.awayBench,_that.homeTactics,_that.awayTactics,_that.yellowCardCounts,_that.sentOffPlayerIds,_that.injuriesThisMatch,_that.momentum,_that.moraleModHome,_that.moraleModAway,_that.context,_that.rngSeed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatchState implements MatchState {
  const _MatchState({this.minute = 0, this.homeGoals = 0, this.awayGoals = 0, final  List<Player> homeLineup = const [], final  List<Player> awayLineup = const [], final  List<Player> homeBench = const [], final  List<Player> awayBench = const [], this.homeTactics = const TacticsSetup(), this.awayTactics = const TacticsSetup(), final  Map<String, int> yellowCardCounts = const {}, final  List<String> sentOffPlayerIds = const [], final  List<String> injuriesThisMatch = const [], this.momentum = 0.0, this.moraleModHome = 0.0, this.moraleModAway = 0.0, this.context = const MatchContext(), this.rngSeed}): _homeLineup = homeLineup,_awayLineup = awayLineup,_homeBench = homeBench,_awayBench = awayBench,_yellowCardCounts = yellowCardCounts,_sentOffPlayerIds = sentOffPlayerIds,_injuriesThisMatch = injuriesThisMatch;
  factory _MatchState.fromJson(Map<String, dynamic> json) => _$MatchStateFromJson(json);

@override@JsonKey() final  int minute;
@override@JsonKey() final  int homeGoals;
@override@JsonKey() final  int awayGoals;
 final  List<Player> _homeLineup;
@override@JsonKey() List<Player> get homeLineup {
  if (_homeLineup is EqualUnmodifiableListView) return _homeLineup;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_homeLineup);
}

 final  List<Player> _awayLineup;
@override@JsonKey() List<Player> get awayLineup {
  if (_awayLineup is EqualUnmodifiableListView) return _awayLineup;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_awayLineup);
}

 final  List<Player> _homeBench;
@override@JsonKey() List<Player> get homeBench {
  if (_homeBench is EqualUnmodifiableListView) return _homeBench;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_homeBench);
}

 final  List<Player> _awayBench;
@override@JsonKey() List<Player> get awayBench {
  if (_awayBench is EqualUnmodifiableListView) return _awayBench;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_awayBench);
}

@override@JsonKey() final  TacticsSetup homeTactics;
@override@JsonKey() final  TacticsSetup awayTactics;
 final  Map<String, int> _yellowCardCounts;
@override@JsonKey() Map<String, int> get yellowCardCounts {
  if (_yellowCardCounts is EqualUnmodifiableMapView) return _yellowCardCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_yellowCardCounts);
}

 final  List<String> _sentOffPlayerIds;
@override@JsonKey() List<String> get sentOffPlayerIds {
  if (_sentOffPlayerIds is EqualUnmodifiableListView) return _sentOffPlayerIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sentOffPlayerIds);
}

 final  List<String> _injuriesThisMatch;
@override@JsonKey() List<String> get injuriesThisMatch {
  if (_injuriesThisMatch is EqualUnmodifiableListView) return _injuriesThisMatch;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_injuriesThisMatch);
}

@override@JsonKey() final  double momentum;
@override@JsonKey() final  double moraleModHome;
@override@JsonKey() final  double moraleModAway;
@override@JsonKey() final  MatchContext context;
@override final  int? rngSeed;

/// Create a copy of MatchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchStateCopyWith<_MatchState> get copyWith => __$MatchStateCopyWithImpl<_MatchState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchState&&(identical(other.minute, minute) || other.minute == minute)&&(identical(other.homeGoals, homeGoals) || other.homeGoals == homeGoals)&&(identical(other.awayGoals, awayGoals) || other.awayGoals == awayGoals)&&const DeepCollectionEquality().equals(other._homeLineup, _homeLineup)&&const DeepCollectionEquality().equals(other._awayLineup, _awayLineup)&&const DeepCollectionEquality().equals(other._homeBench, _homeBench)&&const DeepCollectionEquality().equals(other._awayBench, _awayBench)&&(identical(other.homeTactics, homeTactics) || other.homeTactics == homeTactics)&&(identical(other.awayTactics, awayTactics) || other.awayTactics == awayTactics)&&const DeepCollectionEquality().equals(other._yellowCardCounts, _yellowCardCounts)&&const DeepCollectionEquality().equals(other._sentOffPlayerIds, _sentOffPlayerIds)&&const DeepCollectionEquality().equals(other._injuriesThisMatch, _injuriesThisMatch)&&(identical(other.momentum, momentum) || other.momentum == momentum)&&(identical(other.moraleModHome, moraleModHome) || other.moraleModHome == moraleModHome)&&(identical(other.moraleModAway, moraleModAway) || other.moraleModAway == moraleModAway)&&(identical(other.context, context) || other.context == context)&&(identical(other.rngSeed, rngSeed) || other.rngSeed == rngSeed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minute,homeGoals,awayGoals,const DeepCollectionEquality().hash(_homeLineup),const DeepCollectionEquality().hash(_awayLineup),const DeepCollectionEquality().hash(_homeBench),const DeepCollectionEquality().hash(_awayBench),homeTactics,awayTactics,const DeepCollectionEquality().hash(_yellowCardCounts),const DeepCollectionEquality().hash(_sentOffPlayerIds),const DeepCollectionEquality().hash(_injuriesThisMatch),momentum,moraleModHome,moraleModAway,context,rngSeed);

@override
String toString() {
  return 'MatchState(minute: $minute, homeGoals: $homeGoals, awayGoals: $awayGoals, homeLineup: $homeLineup, awayLineup: $awayLineup, homeBench: $homeBench, awayBench: $awayBench, homeTactics: $homeTactics, awayTactics: $awayTactics, yellowCardCounts: $yellowCardCounts, sentOffPlayerIds: $sentOffPlayerIds, injuriesThisMatch: $injuriesThisMatch, momentum: $momentum, moraleModHome: $moraleModHome, moraleModAway: $moraleModAway, context: $context, rngSeed: $rngSeed)';
}


}

/// @nodoc
abstract mixin class _$MatchStateCopyWith<$Res> implements $MatchStateCopyWith<$Res> {
  factory _$MatchStateCopyWith(_MatchState value, $Res Function(_MatchState) _then) = __$MatchStateCopyWithImpl;
@override @useResult
$Res call({
 int minute, int homeGoals, int awayGoals, List<Player> homeLineup, List<Player> awayLineup, List<Player> homeBench, List<Player> awayBench, TacticsSetup homeTactics, TacticsSetup awayTactics, Map<String, int> yellowCardCounts, List<String> sentOffPlayerIds, List<String> injuriesThisMatch, double momentum, double moraleModHome, double moraleModAway, MatchContext context, int? rngSeed
});


@override $TacticsSetupCopyWith<$Res> get homeTactics;@override $TacticsSetupCopyWith<$Res> get awayTactics;@override $MatchContextCopyWith<$Res> get context;

}
/// @nodoc
class __$MatchStateCopyWithImpl<$Res>
    implements _$MatchStateCopyWith<$Res> {
  __$MatchStateCopyWithImpl(this._self, this._then);

  final _MatchState _self;
  final $Res Function(_MatchState) _then;

/// Create a copy of MatchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? minute = null,Object? homeGoals = null,Object? awayGoals = null,Object? homeLineup = null,Object? awayLineup = null,Object? homeBench = null,Object? awayBench = null,Object? homeTactics = null,Object? awayTactics = null,Object? yellowCardCounts = null,Object? sentOffPlayerIds = null,Object? injuriesThisMatch = null,Object? momentum = null,Object? moraleModHome = null,Object? moraleModAway = null,Object? context = null,Object? rngSeed = freezed,}) {
  return _then(_MatchState(
minute: null == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int,homeGoals: null == homeGoals ? _self.homeGoals : homeGoals // ignore: cast_nullable_to_non_nullable
as int,awayGoals: null == awayGoals ? _self.awayGoals : awayGoals // ignore: cast_nullable_to_non_nullable
as int,homeLineup: null == homeLineup ? _self._homeLineup : homeLineup // ignore: cast_nullable_to_non_nullable
as List<Player>,awayLineup: null == awayLineup ? _self._awayLineup : awayLineup // ignore: cast_nullable_to_non_nullable
as List<Player>,homeBench: null == homeBench ? _self._homeBench : homeBench // ignore: cast_nullable_to_non_nullable
as List<Player>,awayBench: null == awayBench ? _self._awayBench : awayBench // ignore: cast_nullable_to_non_nullable
as List<Player>,homeTactics: null == homeTactics ? _self.homeTactics : homeTactics // ignore: cast_nullable_to_non_nullable
as TacticsSetup,awayTactics: null == awayTactics ? _self.awayTactics : awayTactics // ignore: cast_nullable_to_non_nullable
as TacticsSetup,yellowCardCounts: null == yellowCardCounts ? _self._yellowCardCounts : yellowCardCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,sentOffPlayerIds: null == sentOffPlayerIds ? _self._sentOffPlayerIds : sentOffPlayerIds // ignore: cast_nullable_to_non_nullable
as List<String>,injuriesThisMatch: null == injuriesThisMatch ? _self._injuriesThisMatch : injuriesThisMatch // ignore: cast_nullable_to_non_nullable
as List<String>,momentum: null == momentum ? _self.momentum : momentum // ignore: cast_nullable_to_non_nullable
as double,moraleModHome: null == moraleModHome ? _self.moraleModHome : moraleModHome // ignore: cast_nullable_to_non_nullable
as double,moraleModAway: null == moraleModAway ? _self.moraleModAway : moraleModAway // ignore: cast_nullable_to_non_nullable
as double,context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as MatchContext,rngSeed: freezed == rngSeed ? _self.rngSeed : rngSeed // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of MatchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TacticsSetupCopyWith<$Res> get homeTactics {
  
  return $TacticsSetupCopyWith<$Res>(_self.homeTactics, (value) {
    return _then(_self.copyWith(homeTactics: value));
  });
}/// Create a copy of MatchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TacticsSetupCopyWith<$Res> get awayTactics {
  
  return $TacticsSetupCopyWith<$Res>(_self.awayTactics, (value) {
    return _then(_self.copyWith(awayTactics: value));
  });
}/// Create a copy of MatchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchContextCopyWith<$Res> get context {
  
  return $MatchContextCopyWith<$Res>(_self.context, (value) {
    return _then(_self.copyWith(context: value));
  });
}
}

// dart format on
