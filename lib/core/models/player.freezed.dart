// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlayerSeasonStats {

 int get year; int get minutes; int get goals; int get assists; int get appearances; int get yellowCards; int get redCards; int get shots; int get shotsOnTarget; double get xg; int get passes; double get passAccuracy; int get duelsWon; int get offsides; int get corners; int get tackles; int get interceptions; int get cleanSheets; int get saves; int get shotsFaced; double get ratingAvg;
/// Create a copy of PlayerSeasonStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerSeasonStatsCopyWith<PlayerSeasonStats> get copyWith => _$PlayerSeasonStatsCopyWithImpl<PlayerSeasonStats>(this as PlayerSeasonStats, _$identity);

  /// Serializes this PlayerSeasonStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerSeasonStats&&(identical(other.year, year) || other.year == year)&&(identical(other.minutes, minutes) || other.minutes == minutes)&&(identical(other.goals, goals) || other.goals == goals)&&(identical(other.assists, assists) || other.assists == assists)&&(identical(other.appearances, appearances) || other.appearances == appearances)&&(identical(other.yellowCards, yellowCards) || other.yellowCards == yellowCards)&&(identical(other.redCards, redCards) || other.redCards == redCards)&&(identical(other.shots, shots) || other.shots == shots)&&(identical(other.shotsOnTarget, shotsOnTarget) || other.shotsOnTarget == shotsOnTarget)&&(identical(other.xg, xg) || other.xg == xg)&&(identical(other.passes, passes) || other.passes == passes)&&(identical(other.passAccuracy, passAccuracy) || other.passAccuracy == passAccuracy)&&(identical(other.duelsWon, duelsWon) || other.duelsWon == duelsWon)&&(identical(other.offsides, offsides) || other.offsides == offsides)&&(identical(other.corners, corners) || other.corners == corners)&&(identical(other.tackles, tackles) || other.tackles == tackles)&&(identical(other.interceptions, interceptions) || other.interceptions == interceptions)&&(identical(other.cleanSheets, cleanSheets) || other.cleanSheets == cleanSheets)&&(identical(other.saves, saves) || other.saves == saves)&&(identical(other.shotsFaced, shotsFaced) || other.shotsFaced == shotsFaced)&&(identical(other.ratingAvg, ratingAvg) || other.ratingAvg == ratingAvg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,year,minutes,goals,assists,appearances,yellowCards,redCards,shots,shotsOnTarget,xg,passes,passAccuracy,duelsWon,offsides,corners,tackles,interceptions,cleanSheets,saves,shotsFaced,ratingAvg]);

@override
String toString() {
  return 'PlayerSeasonStats(year: $year, minutes: $minutes, goals: $goals, assists: $assists, appearances: $appearances, yellowCards: $yellowCards, redCards: $redCards, shots: $shots, shotsOnTarget: $shotsOnTarget, xg: $xg, passes: $passes, passAccuracy: $passAccuracy, duelsWon: $duelsWon, offsides: $offsides, corners: $corners, tackles: $tackles, interceptions: $interceptions, cleanSheets: $cleanSheets, saves: $saves, shotsFaced: $shotsFaced, ratingAvg: $ratingAvg)';
}


}

/// @nodoc
abstract mixin class $PlayerSeasonStatsCopyWith<$Res>  {
  factory $PlayerSeasonStatsCopyWith(PlayerSeasonStats value, $Res Function(PlayerSeasonStats) _then) = _$PlayerSeasonStatsCopyWithImpl;
@useResult
$Res call({
 int year, int minutes, int goals, int assists, int appearances, int yellowCards, int redCards, int shots, int shotsOnTarget, double xg, int passes, double passAccuracy, int duelsWon, int offsides, int corners, int tackles, int interceptions, int cleanSheets, int saves, int shotsFaced, double ratingAvg
});




}
/// @nodoc
class _$PlayerSeasonStatsCopyWithImpl<$Res>
    implements $PlayerSeasonStatsCopyWith<$Res> {
  _$PlayerSeasonStatsCopyWithImpl(this._self, this._then);

  final PlayerSeasonStats _self;
  final $Res Function(PlayerSeasonStats) _then;

/// Create a copy of PlayerSeasonStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? minutes = null,Object? goals = null,Object? assists = null,Object? appearances = null,Object? yellowCards = null,Object? redCards = null,Object? shots = null,Object? shotsOnTarget = null,Object? xg = null,Object? passes = null,Object? passAccuracy = null,Object? duelsWon = null,Object? offsides = null,Object? corners = null,Object? tackles = null,Object? interceptions = null,Object? cleanSheets = null,Object? saves = null,Object? shotsFaced = null,Object? ratingAvg = null,}) {
  return _then(_self.copyWith(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,minutes: null == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as int,assists: null == assists ? _self.assists : assists // ignore: cast_nullable_to_non_nullable
as int,appearances: null == appearances ? _self.appearances : appearances // ignore: cast_nullable_to_non_nullable
as int,yellowCards: null == yellowCards ? _self.yellowCards : yellowCards // ignore: cast_nullable_to_non_nullable
as int,redCards: null == redCards ? _self.redCards : redCards // ignore: cast_nullable_to_non_nullable
as int,shots: null == shots ? _self.shots : shots // ignore: cast_nullable_to_non_nullable
as int,shotsOnTarget: null == shotsOnTarget ? _self.shotsOnTarget : shotsOnTarget // ignore: cast_nullable_to_non_nullable
as int,xg: null == xg ? _self.xg : xg // ignore: cast_nullable_to_non_nullable
as double,passes: null == passes ? _self.passes : passes // ignore: cast_nullable_to_non_nullable
as int,passAccuracy: null == passAccuracy ? _self.passAccuracy : passAccuracy // ignore: cast_nullable_to_non_nullable
as double,duelsWon: null == duelsWon ? _self.duelsWon : duelsWon // ignore: cast_nullable_to_non_nullable
as int,offsides: null == offsides ? _self.offsides : offsides // ignore: cast_nullable_to_non_nullable
as int,corners: null == corners ? _self.corners : corners // ignore: cast_nullable_to_non_nullable
as int,tackles: null == tackles ? _self.tackles : tackles // ignore: cast_nullable_to_non_nullable
as int,interceptions: null == interceptions ? _self.interceptions : interceptions // ignore: cast_nullable_to_non_nullable
as int,cleanSheets: null == cleanSheets ? _self.cleanSheets : cleanSheets // ignore: cast_nullable_to_non_nullable
as int,saves: null == saves ? _self.saves : saves // ignore: cast_nullable_to_non_nullable
as int,shotsFaced: null == shotsFaced ? _self.shotsFaced : shotsFaced // ignore: cast_nullable_to_non_nullable
as int,ratingAvg: null == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerSeasonStats].
extension PlayerSeasonStatsPatterns on PlayerSeasonStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerSeasonStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerSeasonStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerSeasonStats value)  $default,){
final _that = this;
switch (_that) {
case _PlayerSeasonStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerSeasonStats value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerSeasonStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  int minutes,  int goals,  int assists,  int appearances,  int yellowCards,  int redCards,  int shots,  int shotsOnTarget,  double xg,  int passes,  double passAccuracy,  int duelsWon,  int offsides,  int corners,  int tackles,  int interceptions,  int cleanSheets,  int saves,  int shotsFaced,  double ratingAvg)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerSeasonStats() when $default != null:
return $default(_that.year,_that.minutes,_that.goals,_that.assists,_that.appearances,_that.yellowCards,_that.redCards,_that.shots,_that.shotsOnTarget,_that.xg,_that.passes,_that.passAccuracy,_that.duelsWon,_that.offsides,_that.corners,_that.tackles,_that.interceptions,_that.cleanSheets,_that.saves,_that.shotsFaced,_that.ratingAvg);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  int minutes,  int goals,  int assists,  int appearances,  int yellowCards,  int redCards,  int shots,  int shotsOnTarget,  double xg,  int passes,  double passAccuracy,  int duelsWon,  int offsides,  int corners,  int tackles,  int interceptions,  int cleanSheets,  int saves,  int shotsFaced,  double ratingAvg)  $default,) {final _that = this;
switch (_that) {
case _PlayerSeasonStats():
return $default(_that.year,_that.minutes,_that.goals,_that.assists,_that.appearances,_that.yellowCards,_that.redCards,_that.shots,_that.shotsOnTarget,_that.xg,_that.passes,_that.passAccuracy,_that.duelsWon,_that.offsides,_that.corners,_that.tackles,_that.interceptions,_that.cleanSheets,_that.saves,_that.shotsFaced,_that.ratingAvg);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  int minutes,  int goals,  int assists,  int appearances,  int yellowCards,  int redCards,  int shots,  int shotsOnTarget,  double xg,  int passes,  double passAccuracy,  int duelsWon,  int offsides,  int corners,  int tackles,  int interceptions,  int cleanSheets,  int saves,  int shotsFaced,  double ratingAvg)?  $default,) {final _that = this;
switch (_that) {
case _PlayerSeasonStats() when $default != null:
return $default(_that.year,_that.minutes,_that.goals,_that.assists,_that.appearances,_that.yellowCards,_that.redCards,_that.shots,_that.shotsOnTarget,_that.xg,_that.passes,_that.passAccuracy,_that.duelsWon,_that.offsides,_that.corners,_that.tackles,_that.interceptions,_that.cleanSheets,_that.saves,_that.shotsFaced,_that.ratingAvg);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayerSeasonStats implements PlayerSeasonStats {
  const _PlayerSeasonStats({required this.year, this.minutes = 0, this.goals = 0, this.assists = 0, this.appearances = 0, this.yellowCards = 0, this.redCards = 0, this.shots = 0, this.shotsOnTarget = 0, this.xg = 0.0, this.passes = 0, this.passAccuracy = 0.0, this.duelsWon = 0, this.offsides = 0, this.corners = 0, this.tackles = 0, this.interceptions = 0, this.cleanSheets = 0, this.saves = 0, this.shotsFaced = 0, this.ratingAvg = 6.0});
  factory _PlayerSeasonStats.fromJson(Map<String, dynamic> json) => _$PlayerSeasonStatsFromJson(json);

@override final  int year;
@override@JsonKey() final  int minutes;
@override@JsonKey() final  int goals;
@override@JsonKey() final  int assists;
@override@JsonKey() final  int appearances;
@override@JsonKey() final  int yellowCards;
@override@JsonKey() final  int redCards;
@override@JsonKey() final  int shots;
@override@JsonKey() final  int shotsOnTarget;
@override@JsonKey() final  double xg;
@override@JsonKey() final  int passes;
@override@JsonKey() final  double passAccuracy;
@override@JsonKey() final  int duelsWon;
@override@JsonKey() final  int offsides;
@override@JsonKey() final  int corners;
@override@JsonKey() final  int tackles;
@override@JsonKey() final  int interceptions;
@override@JsonKey() final  int cleanSheets;
@override@JsonKey() final  int saves;
@override@JsonKey() final  int shotsFaced;
@override@JsonKey() final  double ratingAvg;

/// Create a copy of PlayerSeasonStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerSeasonStatsCopyWith<_PlayerSeasonStats> get copyWith => __$PlayerSeasonStatsCopyWithImpl<_PlayerSeasonStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerSeasonStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerSeasonStats&&(identical(other.year, year) || other.year == year)&&(identical(other.minutes, minutes) || other.minutes == minutes)&&(identical(other.goals, goals) || other.goals == goals)&&(identical(other.assists, assists) || other.assists == assists)&&(identical(other.appearances, appearances) || other.appearances == appearances)&&(identical(other.yellowCards, yellowCards) || other.yellowCards == yellowCards)&&(identical(other.redCards, redCards) || other.redCards == redCards)&&(identical(other.shots, shots) || other.shots == shots)&&(identical(other.shotsOnTarget, shotsOnTarget) || other.shotsOnTarget == shotsOnTarget)&&(identical(other.xg, xg) || other.xg == xg)&&(identical(other.passes, passes) || other.passes == passes)&&(identical(other.passAccuracy, passAccuracy) || other.passAccuracy == passAccuracy)&&(identical(other.duelsWon, duelsWon) || other.duelsWon == duelsWon)&&(identical(other.offsides, offsides) || other.offsides == offsides)&&(identical(other.corners, corners) || other.corners == corners)&&(identical(other.tackles, tackles) || other.tackles == tackles)&&(identical(other.interceptions, interceptions) || other.interceptions == interceptions)&&(identical(other.cleanSheets, cleanSheets) || other.cleanSheets == cleanSheets)&&(identical(other.saves, saves) || other.saves == saves)&&(identical(other.shotsFaced, shotsFaced) || other.shotsFaced == shotsFaced)&&(identical(other.ratingAvg, ratingAvg) || other.ratingAvg == ratingAvg));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,year,minutes,goals,assists,appearances,yellowCards,redCards,shots,shotsOnTarget,xg,passes,passAccuracy,duelsWon,offsides,corners,tackles,interceptions,cleanSheets,saves,shotsFaced,ratingAvg]);

@override
String toString() {
  return 'PlayerSeasonStats(year: $year, minutes: $minutes, goals: $goals, assists: $assists, appearances: $appearances, yellowCards: $yellowCards, redCards: $redCards, shots: $shots, shotsOnTarget: $shotsOnTarget, xg: $xg, passes: $passes, passAccuracy: $passAccuracy, duelsWon: $duelsWon, offsides: $offsides, corners: $corners, tackles: $tackles, interceptions: $interceptions, cleanSheets: $cleanSheets, saves: $saves, shotsFaced: $shotsFaced, ratingAvg: $ratingAvg)';
}


}

/// @nodoc
abstract mixin class _$PlayerSeasonStatsCopyWith<$Res> implements $PlayerSeasonStatsCopyWith<$Res> {
  factory _$PlayerSeasonStatsCopyWith(_PlayerSeasonStats value, $Res Function(_PlayerSeasonStats) _then) = __$PlayerSeasonStatsCopyWithImpl;
@override @useResult
$Res call({
 int year, int minutes, int goals, int assists, int appearances, int yellowCards, int redCards, int shots, int shotsOnTarget, double xg, int passes, double passAccuracy, int duelsWon, int offsides, int corners, int tackles, int interceptions, int cleanSheets, int saves, int shotsFaced, double ratingAvg
});




}
/// @nodoc
class __$PlayerSeasonStatsCopyWithImpl<$Res>
    implements _$PlayerSeasonStatsCopyWith<$Res> {
  __$PlayerSeasonStatsCopyWithImpl(this._self, this._then);

  final _PlayerSeasonStats _self;
  final $Res Function(_PlayerSeasonStats) _then;

/// Create a copy of PlayerSeasonStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? minutes = null,Object? goals = null,Object? assists = null,Object? appearances = null,Object? yellowCards = null,Object? redCards = null,Object? shots = null,Object? shotsOnTarget = null,Object? xg = null,Object? passes = null,Object? passAccuracy = null,Object? duelsWon = null,Object? offsides = null,Object? corners = null,Object? tackles = null,Object? interceptions = null,Object? cleanSheets = null,Object? saves = null,Object? shotsFaced = null,Object? ratingAvg = null,}) {
  return _then(_PlayerSeasonStats(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,minutes: null == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as int,assists: null == assists ? _self.assists : assists // ignore: cast_nullable_to_non_nullable
as int,appearances: null == appearances ? _self.appearances : appearances // ignore: cast_nullable_to_non_nullable
as int,yellowCards: null == yellowCards ? _self.yellowCards : yellowCards // ignore: cast_nullable_to_non_nullable
as int,redCards: null == redCards ? _self.redCards : redCards // ignore: cast_nullable_to_non_nullable
as int,shots: null == shots ? _self.shots : shots // ignore: cast_nullable_to_non_nullable
as int,shotsOnTarget: null == shotsOnTarget ? _self.shotsOnTarget : shotsOnTarget // ignore: cast_nullable_to_non_nullable
as int,xg: null == xg ? _self.xg : xg // ignore: cast_nullable_to_non_nullable
as double,passes: null == passes ? _self.passes : passes // ignore: cast_nullable_to_non_nullable
as int,passAccuracy: null == passAccuracy ? _self.passAccuracy : passAccuracy // ignore: cast_nullable_to_non_nullable
as double,duelsWon: null == duelsWon ? _self.duelsWon : duelsWon // ignore: cast_nullable_to_non_nullable
as int,offsides: null == offsides ? _self.offsides : offsides // ignore: cast_nullable_to_non_nullable
as int,corners: null == corners ? _self.corners : corners // ignore: cast_nullable_to_non_nullable
as int,tackles: null == tackles ? _self.tackles : tackles // ignore: cast_nullable_to_non_nullable
as int,interceptions: null == interceptions ? _self.interceptions : interceptions // ignore: cast_nullable_to_non_nullable
as int,cleanSheets: null == cleanSheets ? _self.cleanSheets : cleanSheets // ignore: cast_nullable_to_non_nullable
as int,saves: null == saves ? _self.saves : saves // ignore: cast_nullable_to_non_nullable
as int,shotsFaced: null == shotsFaced ? _self.shotsFaced : shotsFaced // ignore: cast_nullable_to_non_nullable
as int,ratingAvg: null == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$PlayerHidden {

 int get injuryProne; int get determination; double get overallProgress; double get growthRate; DevelopmentOutcome get developmentOutcome; double get developmentCeilingStars;
/// Create a copy of PlayerHidden
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerHiddenCopyWith<PlayerHidden> get copyWith => _$PlayerHiddenCopyWithImpl<PlayerHidden>(this as PlayerHidden, _$identity);

  /// Serializes this PlayerHidden to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerHidden&&(identical(other.injuryProne, injuryProne) || other.injuryProne == injuryProne)&&(identical(other.determination, determination) || other.determination == determination)&&(identical(other.overallProgress, overallProgress) || other.overallProgress == overallProgress)&&(identical(other.growthRate, growthRate) || other.growthRate == growthRate)&&(identical(other.developmentOutcome, developmentOutcome) || other.developmentOutcome == developmentOutcome)&&(identical(other.developmentCeilingStars, developmentCeilingStars) || other.developmentCeilingStars == developmentCeilingStars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,injuryProne,determination,overallProgress,growthRate,developmentOutcome,developmentCeilingStars);

@override
String toString() {
  return 'PlayerHidden(injuryProne: $injuryProne, determination: $determination, overallProgress: $overallProgress, growthRate: $growthRate, developmentOutcome: $developmentOutcome, developmentCeilingStars: $developmentCeilingStars)';
}


}

/// @nodoc
abstract mixin class $PlayerHiddenCopyWith<$Res>  {
  factory $PlayerHiddenCopyWith(PlayerHidden value, $Res Function(PlayerHidden) _then) = _$PlayerHiddenCopyWithImpl;
@useResult
$Res call({
 int injuryProne, int determination, double overallProgress, double growthRate, DevelopmentOutcome developmentOutcome, double developmentCeilingStars
});




}
/// @nodoc
class _$PlayerHiddenCopyWithImpl<$Res>
    implements $PlayerHiddenCopyWith<$Res> {
  _$PlayerHiddenCopyWithImpl(this._self, this._then);

  final PlayerHidden _self;
  final $Res Function(PlayerHidden) _then;

/// Create a copy of PlayerHidden
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? injuryProne = null,Object? determination = null,Object? overallProgress = null,Object? growthRate = null,Object? developmentOutcome = null,Object? developmentCeilingStars = null,}) {
  return _then(_self.copyWith(
injuryProne: null == injuryProne ? _self.injuryProne : injuryProne // ignore: cast_nullable_to_non_nullable
as int,determination: null == determination ? _self.determination : determination // ignore: cast_nullable_to_non_nullable
as int,overallProgress: null == overallProgress ? _self.overallProgress : overallProgress // ignore: cast_nullable_to_non_nullable
as double,growthRate: null == growthRate ? _self.growthRate : growthRate // ignore: cast_nullable_to_non_nullable
as double,developmentOutcome: null == developmentOutcome ? _self.developmentOutcome : developmentOutcome // ignore: cast_nullable_to_non_nullable
as DevelopmentOutcome,developmentCeilingStars: null == developmentCeilingStars ? _self.developmentCeilingStars : developmentCeilingStars // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerHidden].
extension PlayerHiddenPatterns on PlayerHidden {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerHidden value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerHidden() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerHidden value)  $default,){
final _that = this;
switch (_that) {
case _PlayerHidden():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerHidden value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerHidden() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int injuryProne,  int determination,  double overallProgress,  double growthRate,  DevelopmentOutcome developmentOutcome,  double developmentCeilingStars)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerHidden() when $default != null:
return $default(_that.injuryProne,_that.determination,_that.overallProgress,_that.growthRate,_that.developmentOutcome,_that.developmentCeilingStars);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int injuryProne,  int determination,  double overallProgress,  double growthRate,  DevelopmentOutcome developmentOutcome,  double developmentCeilingStars)  $default,) {final _that = this;
switch (_that) {
case _PlayerHidden():
return $default(_that.injuryProne,_that.determination,_that.overallProgress,_that.growthRate,_that.developmentOutcome,_that.developmentCeilingStars);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int injuryProne,  int determination,  double overallProgress,  double growthRate,  DevelopmentOutcome developmentOutcome,  double developmentCeilingStars)?  $default,) {final _that = this;
switch (_that) {
case _PlayerHidden() when $default != null:
return $default(_that.injuryProne,_that.determination,_that.overallProgress,_that.growthRate,_that.developmentOutcome,_that.developmentCeilingStars);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayerHidden implements PlayerHidden {
  const _PlayerHidden({required this.injuryProne, required this.determination, this.overallProgress = 0.0, this.growthRate = 1.0, required this.developmentOutcome, this.developmentCeilingStars = 0.0});
  factory _PlayerHidden.fromJson(Map<String, dynamic> json) => _$PlayerHiddenFromJson(json);

@override final  int injuryProne;
@override final  int determination;
@override@JsonKey() final  double overallProgress;
@override@JsonKey() final  double growthRate;
@override final  DevelopmentOutcome developmentOutcome;
@override@JsonKey() final  double developmentCeilingStars;

/// Create a copy of PlayerHidden
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerHiddenCopyWith<_PlayerHidden> get copyWith => __$PlayerHiddenCopyWithImpl<_PlayerHidden>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerHiddenToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerHidden&&(identical(other.injuryProne, injuryProne) || other.injuryProne == injuryProne)&&(identical(other.determination, determination) || other.determination == determination)&&(identical(other.overallProgress, overallProgress) || other.overallProgress == overallProgress)&&(identical(other.growthRate, growthRate) || other.growthRate == growthRate)&&(identical(other.developmentOutcome, developmentOutcome) || other.developmentOutcome == developmentOutcome)&&(identical(other.developmentCeilingStars, developmentCeilingStars) || other.developmentCeilingStars == developmentCeilingStars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,injuryProne,determination,overallProgress,growthRate,developmentOutcome,developmentCeilingStars);

@override
String toString() {
  return 'PlayerHidden(injuryProne: $injuryProne, determination: $determination, overallProgress: $overallProgress, growthRate: $growthRate, developmentOutcome: $developmentOutcome, developmentCeilingStars: $developmentCeilingStars)';
}


}

/// @nodoc
abstract mixin class _$PlayerHiddenCopyWith<$Res> implements $PlayerHiddenCopyWith<$Res> {
  factory _$PlayerHiddenCopyWith(_PlayerHidden value, $Res Function(_PlayerHidden) _then) = __$PlayerHiddenCopyWithImpl;
@override @useResult
$Res call({
 int injuryProne, int determination, double overallProgress, double growthRate, DevelopmentOutcome developmentOutcome, double developmentCeilingStars
});




}
/// @nodoc
class __$PlayerHiddenCopyWithImpl<$Res>
    implements _$PlayerHiddenCopyWith<$Res> {
  __$PlayerHiddenCopyWithImpl(this._self, this._then);

  final _PlayerHidden _self;
  final $Res Function(_PlayerHidden) _then;

/// Create a copy of PlayerHidden
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? injuryProne = null,Object? determination = null,Object? overallProgress = null,Object? growthRate = null,Object? developmentOutcome = null,Object? developmentCeilingStars = null,}) {
  return _then(_PlayerHidden(
injuryProne: null == injuryProne ? _self.injuryProne : injuryProne // ignore: cast_nullable_to_non_nullable
as int,determination: null == determination ? _self.determination : determination // ignore: cast_nullable_to_non_nullable
as int,overallProgress: null == overallProgress ? _self.overallProgress : overallProgress // ignore: cast_nullable_to_non_nullable
as double,growthRate: null == growthRate ? _self.growthRate : growthRate // ignore: cast_nullable_to_non_nullable
as double,developmentOutcome: null == developmentOutcome ? _self.developmentOutcome : developmentOutcome // ignore: cast_nullable_to_non_nullable
as DevelopmentOutcome,developmentCeilingStars: null == developmentCeilingStars ? _self.developmentCeilingStars : developmentCeilingStars // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$PlayerState {

 int get stamina; double get form; Injury? get injury; int get regularSeasonYellowCards; int get playoffYellowCards; int get suspensionGamesRemaining; AssignedRole get role; int get seasonsWithTeam; int get minutesThisWeek; int get lastDevelopmentOvrDelta; double get lastDevelopmentProgressDelta; PlayerEventState get eventState;
/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerStateCopyWith<PlayerState> get copyWith => _$PlayerStateCopyWithImpl<PlayerState>(this as PlayerState, _$identity);

  /// Serializes this PlayerState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerState&&(identical(other.stamina, stamina) || other.stamina == stamina)&&(identical(other.form, form) || other.form == form)&&(identical(other.injury, injury) || other.injury == injury)&&(identical(other.regularSeasonYellowCards, regularSeasonYellowCards) || other.regularSeasonYellowCards == regularSeasonYellowCards)&&(identical(other.playoffYellowCards, playoffYellowCards) || other.playoffYellowCards == playoffYellowCards)&&(identical(other.suspensionGamesRemaining, suspensionGamesRemaining) || other.suspensionGamesRemaining == suspensionGamesRemaining)&&(identical(other.role, role) || other.role == role)&&(identical(other.seasonsWithTeam, seasonsWithTeam) || other.seasonsWithTeam == seasonsWithTeam)&&(identical(other.minutesThisWeek, minutesThisWeek) || other.minutesThisWeek == minutesThisWeek)&&(identical(other.lastDevelopmentOvrDelta, lastDevelopmentOvrDelta) || other.lastDevelopmentOvrDelta == lastDevelopmentOvrDelta)&&(identical(other.lastDevelopmentProgressDelta, lastDevelopmentProgressDelta) || other.lastDevelopmentProgressDelta == lastDevelopmentProgressDelta)&&(identical(other.eventState, eventState) || other.eventState == eventState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stamina,form,injury,regularSeasonYellowCards,playoffYellowCards,suspensionGamesRemaining,role,seasonsWithTeam,minutesThisWeek,lastDevelopmentOvrDelta,lastDevelopmentProgressDelta,eventState);

@override
String toString() {
  return 'PlayerState(stamina: $stamina, form: $form, injury: $injury, regularSeasonYellowCards: $regularSeasonYellowCards, playoffYellowCards: $playoffYellowCards, suspensionGamesRemaining: $suspensionGamesRemaining, role: $role, seasonsWithTeam: $seasonsWithTeam, minutesThisWeek: $minutesThisWeek, lastDevelopmentOvrDelta: $lastDevelopmentOvrDelta, lastDevelopmentProgressDelta: $lastDevelopmentProgressDelta, eventState: $eventState)';
}


}

/// @nodoc
abstract mixin class $PlayerStateCopyWith<$Res>  {
  factory $PlayerStateCopyWith(PlayerState value, $Res Function(PlayerState) _then) = _$PlayerStateCopyWithImpl;
@useResult
$Res call({
 int stamina, double form, Injury? injury, int regularSeasonYellowCards, int playoffYellowCards, int suspensionGamesRemaining, AssignedRole role, int seasonsWithTeam, int minutesThisWeek, int lastDevelopmentOvrDelta, double lastDevelopmentProgressDelta, PlayerEventState eventState
});


$InjuryCopyWith<$Res>? get injury;$AssignedRoleCopyWith<$Res> get role;$PlayerEventStateCopyWith<$Res> get eventState;

}
/// @nodoc
class _$PlayerStateCopyWithImpl<$Res>
    implements $PlayerStateCopyWith<$Res> {
  _$PlayerStateCopyWithImpl(this._self, this._then);

  final PlayerState _self;
  final $Res Function(PlayerState) _then;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stamina = null,Object? form = null,Object? injury = freezed,Object? regularSeasonYellowCards = null,Object? playoffYellowCards = null,Object? suspensionGamesRemaining = null,Object? role = null,Object? seasonsWithTeam = null,Object? minutesThisWeek = null,Object? lastDevelopmentOvrDelta = null,Object? lastDevelopmentProgressDelta = null,Object? eventState = null,}) {
  return _then(_self.copyWith(
stamina: null == stamina ? _self.stamina : stamina // ignore: cast_nullable_to_non_nullable
as int,form: null == form ? _self.form : form // ignore: cast_nullable_to_non_nullable
as double,injury: freezed == injury ? _self.injury : injury // ignore: cast_nullable_to_non_nullable
as Injury?,regularSeasonYellowCards: null == regularSeasonYellowCards ? _self.regularSeasonYellowCards : regularSeasonYellowCards // ignore: cast_nullable_to_non_nullable
as int,playoffYellowCards: null == playoffYellowCards ? _self.playoffYellowCards : playoffYellowCards // ignore: cast_nullable_to_non_nullable
as int,suspensionGamesRemaining: null == suspensionGamesRemaining ? _self.suspensionGamesRemaining : suspensionGamesRemaining // ignore: cast_nullable_to_non_nullable
as int,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as AssignedRole,seasonsWithTeam: null == seasonsWithTeam ? _self.seasonsWithTeam : seasonsWithTeam // ignore: cast_nullable_to_non_nullable
as int,minutesThisWeek: null == minutesThisWeek ? _self.minutesThisWeek : minutesThisWeek // ignore: cast_nullable_to_non_nullable
as int,lastDevelopmentOvrDelta: null == lastDevelopmentOvrDelta ? _self.lastDevelopmentOvrDelta : lastDevelopmentOvrDelta // ignore: cast_nullable_to_non_nullable
as int,lastDevelopmentProgressDelta: null == lastDevelopmentProgressDelta ? _self.lastDevelopmentProgressDelta : lastDevelopmentProgressDelta // ignore: cast_nullable_to_non_nullable
as double,eventState: null == eventState ? _self.eventState : eventState // ignore: cast_nullable_to_non_nullable
as PlayerEventState,
  ));
}
/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InjuryCopyWith<$Res>? get injury {
    if (_self.injury == null) {
    return null;
  }

  return $InjuryCopyWith<$Res>(_self.injury!, (value) {
    return _then(_self.copyWith(injury: value));
  });
}/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssignedRoleCopyWith<$Res> get role {
  
  return $AssignedRoleCopyWith<$Res>(_self.role, (value) {
    return _then(_self.copyWith(role: value));
  });
}/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerEventStateCopyWith<$Res> get eventState {
  
  return $PlayerEventStateCopyWith<$Res>(_self.eventState, (value) {
    return _then(_self.copyWith(eventState: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayerState].
extension PlayerStatePatterns on PlayerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerState value)  $default,){
final _that = this;
switch (_that) {
case _PlayerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerState value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int stamina,  double form,  Injury? injury,  int regularSeasonYellowCards,  int playoffYellowCards,  int suspensionGamesRemaining,  AssignedRole role,  int seasonsWithTeam,  int minutesThisWeek,  int lastDevelopmentOvrDelta,  double lastDevelopmentProgressDelta,  PlayerEventState eventState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that.stamina,_that.form,_that.injury,_that.regularSeasonYellowCards,_that.playoffYellowCards,_that.suspensionGamesRemaining,_that.role,_that.seasonsWithTeam,_that.minutesThisWeek,_that.lastDevelopmentOvrDelta,_that.lastDevelopmentProgressDelta,_that.eventState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int stamina,  double form,  Injury? injury,  int regularSeasonYellowCards,  int playoffYellowCards,  int suspensionGamesRemaining,  AssignedRole role,  int seasonsWithTeam,  int minutesThisWeek,  int lastDevelopmentOvrDelta,  double lastDevelopmentProgressDelta,  PlayerEventState eventState)  $default,) {final _that = this;
switch (_that) {
case _PlayerState():
return $default(_that.stamina,_that.form,_that.injury,_that.regularSeasonYellowCards,_that.playoffYellowCards,_that.suspensionGamesRemaining,_that.role,_that.seasonsWithTeam,_that.minutesThisWeek,_that.lastDevelopmentOvrDelta,_that.lastDevelopmentProgressDelta,_that.eventState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int stamina,  double form,  Injury? injury,  int regularSeasonYellowCards,  int playoffYellowCards,  int suspensionGamesRemaining,  AssignedRole role,  int seasonsWithTeam,  int minutesThisWeek,  int lastDevelopmentOvrDelta,  double lastDevelopmentProgressDelta,  PlayerEventState eventState)?  $default,) {final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that.stamina,_that.form,_that.injury,_that.regularSeasonYellowCards,_that.playoffYellowCards,_that.suspensionGamesRemaining,_that.role,_that.seasonsWithTeam,_that.minutesThisWeek,_that.lastDevelopmentOvrDelta,_that.lastDevelopmentProgressDelta,_that.eventState);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayerState implements PlayerState {
  const _PlayerState({this.stamina = 100, this.form = 5.0, this.injury, this.regularSeasonYellowCards = 0, this.playoffYellowCards = 0, this.suspensionGamesRemaining = 0, this.role = const AssignedRole.cm(), this.seasonsWithTeam = 0, this.minutesThisWeek = 0, this.lastDevelopmentOvrDelta = 0, this.lastDevelopmentProgressDelta = 0.0, this.eventState = const PlayerEventState()});
  factory _PlayerState.fromJson(Map<String, dynamic> json) => _$PlayerStateFromJson(json);

@override@JsonKey() final  int stamina;
@override@JsonKey() final  double form;
@override final  Injury? injury;
@override@JsonKey() final  int regularSeasonYellowCards;
@override@JsonKey() final  int playoffYellowCards;
@override@JsonKey() final  int suspensionGamesRemaining;
@override@JsonKey() final  AssignedRole role;
@override@JsonKey() final  int seasonsWithTeam;
@override@JsonKey() final  int minutesThisWeek;
@override@JsonKey() final  int lastDevelopmentOvrDelta;
@override@JsonKey() final  double lastDevelopmentProgressDelta;
@override@JsonKey() final  PlayerEventState eventState;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerStateCopyWith<_PlayerState> get copyWith => __$PlayerStateCopyWithImpl<_PlayerState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerState&&(identical(other.stamina, stamina) || other.stamina == stamina)&&(identical(other.form, form) || other.form == form)&&(identical(other.injury, injury) || other.injury == injury)&&(identical(other.regularSeasonYellowCards, regularSeasonYellowCards) || other.regularSeasonYellowCards == regularSeasonYellowCards)&&(identical(other.playoffYellowCards, playoffYellowCards) || other.playoffYellowCards == playoffYellowCards)&&(identical(other.suspensionGamesRemaining, suspensionGamesRemaining) || other.suspensionGamesRemaining == suspensionGamesRemaining)&&(identical(other.role, role) || other.role == role)&&(identical(other.seasonsWithTeam, seasonsWithTeam) || other.seasonsWithTeam == seasonsWithTeam)&&(identical(other.minutesThisWeek, minutesThisWeek) || other.minutesThisWeek == minutesThisWeek)&&(identical(other.lastDevelopmentOvrDelta, lastDevelopmentOvrDelta) || other.lastDevelopmentOvrDelta == lastDevelopmentOvrDelta)&&(identical(other.lastDevelopmentProgressDelta, lastDevelopmentProgressDelta) || other.lastDevelopmentProgressDelta == lastDevelopmentProgressDelta)&&(identical(other.eventState, eventState) || other.eventState == eventState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stamina,form,injury,regularSeasonYellowCards,playoffYellowCards,suspensionGamesRemaining,role,seasonsWithTeam,minutesThisWeek,lastDevelopmentOvrDelta,lastDevelopmentProgressDelta,eventState);

@override
String toString() {
  return 'PlayerState(stamina: $stamina, form: $form, injury: $injury, regularSeasonYellowCards: $regularSeasonYellowCards, playoffYellowCards: $playoffYellowCards, suspensionGamesRemaining: $suspensionGamesRemaining, role: $role, seasonsWithTeam: $seasonsWithTeam, minutesThisWeek: $minutesThisWeek, lastDevelopmentOvrDelta: $lastDevelopmentOvrDelta, lastDevelopmentProgressDelta: $lastDevelopmentProgressDelta, eventState: $eventState)';
}


}

/// @nodoc
abstract mixin class _$PlayerStateCopyWith<$Res> implements $PlayerStateCopyWith<$Res> {
  factory _$PlayerStateCopyWith(_PlayerState value, $Res Function(_PlayerState) _then) = __$PlayerStateCopyWithImpl;
@override @useResult
$Res call({
 int stamina, double form, Injury? injury, int regularSeasonYellowCards, int playoffYellowCards, int suspensionGamesRemaining, AssignedRole role, int seasonsWithTeam, int minutesThisWeek, int lastDevelopmentOvrDelta, double lastDevelopmentProgressDelta, PlayerEventState eventState
});


@override $InjuryCopyWith<$Res>? get injury;@override $AssignedRoleCopyWith<$Res> get role;@override $PlayerEventStateCopyWith<$Res> get eventState;

}
/// @nodoc
class __$PlayerStateCopyWithImpl<$Res>
    implements _$PlayerStateCopyWith<$Res> {
  __$PlayerStateCopyWithImpl(this._self, this._then);

  final _PlayerState _self;
  final $Res Function(_PlayerState) _then;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stamina = null,Object? form = null,Object? injury = freezed,Object? regularSeasonYellowCards = null,Object? playoffYellowCards = null,Object? suspensionGamesRemaining = null,Object? role = null,Object? seasonsWithTeam = null,Object? minutesThisWeek = null,Object? lastDevelopmentOvrDelta = null,Object? lastDevelopmentProgressDelta = null,Object? eventState = null,}) {
  return _then(_PlayerState(
stamina: null == stamina ? _self.stamina : stamina // ignore: cast_nullable_to_non_nullable
as int,form: null == form ? _self.form : form // ignore: cast_nullable_to_non_nullable
as double,injury: freezed == injury ? _self.injury : injury // ignore: cast_nullable_to_non_nullable
as Injury?,regularSeasonYellowCards: null == regularSeasonYellowCards ? _self.regularSeasonYellowCards : regularSeasonYellowCards // ignore: cast_nullable_to_non_nullable
as int,playoffYellowCards: null == playoffYellowCards ? _self.playoffYellowCards : playoffYellowCards // ignore: cast_nullable_to_non_nullable
as int,suspensionGamesRemaining: null == suspensionGamesRemaining ? _self.suspensionGamesRemaining : suspensionGamesRemaining // ignore: cast_nullable_to_non_nullable
as int,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as AssignedRole,seasonsWithTeam: null == seasonsWithTeam ? _self.seasonsWithTeam : seasonsWithTeam // ignore: cast_nullable_to_non_nullable
as int,minutesThisWeek: null == minutesThisWeek ? _self.minutesThisWeek : minutesThisWeek // ignore: cast_nullable_to_non_nullable
as int,lastDevelopmentOvrDelta: null == lastDevelopmentOvrDelta ? _self.lastDevelopmentOvrDelta : lastDevelopmentOvrDelta // ignore: cast_nullable_to_non_nullable
as int,lastDevelopmentProgressDelta: null == lastDevelopmentProgressDelta ? _self.lastDevelopmentProgressDelta : lastDevelopmentProgressDelta // ignore: cast_nullable_to_non_nullable
as double,eventState: null == eventState ? _self.eventState : eventState // ignore: cast_nullable_to_non_nullable
as PlayerEventState,
  ));
}

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InjuryCopyWith<$Res>? get injury {
    if (_self.injury == null) {
    return null;
  }

  return $InjuryCopyWith<$Res>(_self.injury!, (value) {
    return _then(_self.copyWith(injury: value));
  });
}/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssignedRoleCopyWith<$Res> get role {
  
  return $AssignedRoleCopyWith<$Res>(_self.role, (value) {
    return _then(_self.copyWith(role: value));
  });
}/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerEventStateCopyWith<$Res> get eventState {
  
  return $PlayerEventStateCopyWith<$Res>(_self.eventState, (value) {
    return _then(_self.copyWith(eventState: value));
  });
}
}


/// @nodoc
mixin _$Player {

 String get id; String get name; Position get position; Nationality get nationality; int get age; PlayerAttributes get attributes; Contract get contract; PlayerPersonality get personality; double get potentialStars; int get heightCm; PlayerState get state; PlayerHidden get hidden; List<PlayerSeasonStats> get seasonStats;/// Draft class provenance used by Rookie of the Year. The value is the
/// draft year for both drafted and undrafted players from that class.
 int? get draftYear; int get pointValue;/// Optymalna rola taktyczna zawodnika (`player_management.md`).
/// Gra w tej roli daje bonus cohesion +2 i `roleFitMult` ×1.03
/// (`squad_management.md`, `matchday_model.md`).
 AssignedRole get optimalRole;/// Previous overall rating (rounded) captured at season start.
/// Used by the Development screen to compute OVR delta.
 int? get previousOvr;/// Raw overall rating captured at the start of the current season.
/// This is kept separate from [previousOvr], whose rounded value is part
/// of the existing development UI contract.
 double? get seasonStartOvr;/// Previous potentialStars captured at season start.
/// Used by the Development screen to compute potential delta.
 double? get previousPotential;
/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerCopyWith<Player> get copyWith => _$PlayerCopyWithImpl<Player>(this as Player, _$identity);

  /// Serializes this Player to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Player&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.position, position) || other.position == position)&&(identical(other.nationality, nationality) || other.nationality == nationality)&&(identical(other.age, age) || other.age == age)&&(identical(other.attributes, attributes) || other.attributes == attributes)&&(identical(other.contract, contract) || other.contract == contract)&&(identical(other.personality, personality) || other.personality == personality)&&(identical(other.potentialStars, potentialStars) || other.potentialStars == potentialStars)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.state, state) || other.state == state)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&const DeepCollectionEquality().equals(other.seasonStats, seasonStats)&&(identical(other.draftYear, draftYear) || other.draftYear == draftYear)&&(identical(other.pointValue, pointValue) || other.pointValue == pointValue)&&(identical(other.optimalRole, optimalRole) || other.optimalRole == optimalRole)&&(identical(other.previousOvr, previousOvr) || other.previousOvr == previousOvr)&&(identical(other.seasonStartOvr, seasonStartOvr) || other.seasonStartOvr == seasonStartOvr)&&(identical(other.previousPotential, previousPotential) || other.previousPotential == previousPotential));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,position,nationality,age,attributes,contract,personality,potentialStars,heightCm,state,hidden,const DeepCollectionEquality().hash(seasonStats),draftYear,pointValue,optimalRole,previousOvr,seasonStartOvr,previousPotential]);

@override
String toString() {
  return 'Player(id: $id, name: $name, position: $position, nationality: $nationality, age: $age, attributes: $attributes, contract: $contract, personality: $personality, potentialStars: $potentialStars, heightCm: $heightCm, state: $state, hidden: $hidden, seasonStats: $seasonStats, draftYear: $draftYear, pointValue: $pointValue, optimalRole: $optimalRole, previousOvr: $previousOvr, seasonStartOvr: $seasonStartOvr, previousPotential: $previousPotential)';
}


}

/// @nodoc
abstract mixin class $PlayerCopyWith<$Res>  {
  factory $PlayerCopyWith(Player value, $Res Function(Player) _then) = _$PlayerCopyWithImpl;
@useResult
$Res call({
 String id, String name, Position position, Nationality nationality, int age, PlayerAttributes attributes, Contract contract, PlayerPersonality personality, double potentialStars, int heightCm, PlayerState state, PlayerHidden hidden, List<PlayerSeasonStats> seasonStats, int? draftYear, int pointValue, AssignedRole optimalRole, int? previousOvr, double? seasonStartOvr, double? previousPotential
});


$PlayerAttributesCopyWith<$Res> get attributes;$ContractCopyWith<$Res> get contract;$PlayerStateCopyWith<$Res> get state;$PlayerHiddenCopyWith<$Res> get hidden;$AssignedRoleCopyWith<$Res> get optimalRole;

}
/// @nodoc
class _$PlayerCopyWithImpl<$Res>
    implements $PlayerCopyWith<$Res> {
  _$PlayerCopyWithImpl(this._self, this._then);

  final Player _self;
  final $Res Function(Player) _then;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? position = null,Object? nationality = null,Object? age = null,Object? attributes = null,Object? contract = null,Object? personality = null,Object? potentialStars = null,Object? heightCm = null,Object? state = null,Object? hidden = null,Object? seasonStats = null,Object? draftYear = freezed,Object? pointValue = null,Object? optimalRole = null,Object? previousOvr = freezed,Object? seasonStartOvr = freezed,Object? previousPotential = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Position,nationality: null == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as Nationality,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,attributes: null == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as PlayerAttributes,contract: null == contract ? _self.contract : contract // ignore: cast_nullable_to_non_nullable
as Contract,personality: null == personality ? _self.personality : personality // ignore: cast_nullable_to_non_nullable
as PlayerPersonality,potentialStars: null == potentialStars ? _self.potentialStars : potentialStars // ignore: cast_nullable_to_non_nullable
as double,heightCm: null == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as PlayerState,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as PlayerHidden,seasonStats: null == seasonStats ? _self.seasonStats : seasonStats // ignore: cast_nullable_to_non_nullable
as List<PlayerSeasonStats>,draftYear: freezed == draftYear ? _self.draftYear : draftYear // ignore: cast_nullable_to_non_nullable
as int?,pointValue: null == pointValue ? _self.pointValue : pointValue // ignore: cast_nullable_to_non_nullable
as int,optimalRole: null == optimalRole ? _self.optimalRole : optimalRole // ignore: cast_nullable_to_non_nullable
as AssignedRole,previousOvr: freezed == previousOvr ? _self.previousOvr : previousOvr // ignore: cast_nullable_to_non_nullable
as int?,seasonStartOvr: freezed == seasonStartOvr ? _self.seasonStartOvr : seasonStartOvr // ignore: cast_nullable_to_non_nullable
as double?,previousPotential: freezed == previousPotential ? _self.previousPotential : previousPotential // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}
/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerAttributesCopyWith<$Res> get attributes {
  
  return $PlayerAttributesCopyWith<$Res>(_self.attributes, (value) {
    return _then(_self.copyWith(attributes: value));
  });
}/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContractCopyWith<$Res> get contract {
  
  return $ContractCopyWith<$Res>(_self.contract, (value) {
    return _then(_self.copyWith(contract: value));
  });
}/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerStateCopyWith<$Res> get state {
  
  return $PlayerStateCopyWith<$Res>(_self.state, (value) {
    return _then(_self.copyWith(state: value));
  });
}/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerHiddenCopyWith<$Res> get hidden {
  
  return $PlayerHiddenCopyWith<$Res>(_self.hidden, (value) {
    return _then(_self.copyWith(hidden: value));
  });
}/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssignedRoleCopyWith<$Res> get optimalRole {
  
  return $AssignedRoleCopyWith<$Res>(_self.optimalRole, (value) {
    return _then(_self.copyWith(optimalRole: value));
  });
}
}


/// Adds pattern-matching-related methods to [Player].
extension PlayerPatterns on Player {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Player value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Player() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Player value)  $default,){
final _that = this;
switch (_that) {
case _Player():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Player value)?  $default,){
final _that = this;
switch (_that) {
case _Player() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  Position position,  Nationality nationality,  int age,  PlayerAttributes attributes,  Contract contract,  PlayerPersonality personality,  double potentialStars,  int heightCm,  PlayerState state,  PlayerHidden hidden,  List<PlayerSeasonStats> seasonStats,  int? draftYear,  int pointValue,  AssignedRole optimalRole,  int? previousOvr,  double? seasonStartOvr,  double? previousPotential)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Player() when $default != null:
return $default(_that.id,_that.name,_that.position,_that.nationality,_that.age,_that.attributes,_that.contract,_that.personality,_that.potentialStars,_that.heightCm,_that.state,_that.hidden,_that.seasonStats,_that.draftYear,_that.pointValue,_that.optimalRole,_that.previousOvr,_that.seasonStartOvr,_that.previousPotential);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  Position position,  Nationality nationality,  int age,  PlayerAttributes attributes,  Contract contract,  PlayerPersonality personality,  double potentialStars,  int heightCm,  PlayerState state,  PlayerHidden hidden,  List<PlayerSeasonStats> seasonStats,  int? draftYear,  int pointValue,  AssignedRole optimalRole,  int? previousOvr,  double? seasonStartOvr,  double? previousPotential)  $default,) {final _that = this;
switch (_that) {
case _Player():
return $default(_that.id,_that.name,_that.position,_that.nationality,_that.age,_that.attributes,_that.contract,_that.personality,_that.potentialStars,_that.heightCm,_that.state,_that.hidden,_that.seasonStats,_that.draftYear,_that.pointValue,_that.optimalRole,_that.previousOvr,_that.seasonStartOvr,_that.previousPotential);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  Position position,  Nationality nationality,  int age,  PlayerAttributes attributes,  Contract contract,  PlayerPersonality personality,  double potentialStars,  int heightCm,  PlayerState state,  PlayerHidden hidden,  List<PlayerSeasonStats> seasonStats,  int? draftYear,  int pointValue,  AssignedRole optimalRole,  int? previousOvr,  double? seasonStartOvr,  double? previousPotential)?  $default,) {final _that = this;
switch (_that) {
case _Player() when $default != null:
return $default(_that.id,_that.name,_that.position,_that.nationality,_that.age,_that.attributes,_that.contract,_that.personality,_that.potentialStars,_that.heightCm,_that.state,_that.hidden,_that.seasonStats,_that.draftYear,_that.pointValue,_that.optimalRole,_that.previousOvr,_that.seasonStartOvr,_that.previousPotential);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Player implements Player {
  const _Player({required this.id, required this.name, required this.position, required this.nationality, required this.age, required this.attributes, required this.contract, required this.personality, required this.potentialStars, required this.heightCm, required this.state, required this.hidden, final  List<PlayerSeasonStats> seasonStats = const [], this.draftYear, this.pointValue = 0, required this.optimalRole, this.previousOvr, this.seasonStartOvr, this.previousPotential}): _seasonStats = seasonStats;
  factory _Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

@override final  String id;
@override final  String name;
@override final  Position position;
@override final  Nationality nationality;
@override final  int age;
@override final  PlayerAttributes attributes;
@override final  Contract contract;
@override final  PlayerPersonality personality;
@override final  double potentialStars;
@override final  int heightCm;
@override final  PlayerState state;
@override final  PlayerHidden hidden;
 final  List<PlayerSeasonStats> _seasonStats;
@override@JsonKey() List<PlayerSeasonStats> get seasonStats {
  if (_seasonStats is EqualUnmodifiableListView) return _seasonStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_seasonStats);
}

/// Draft class provenance used by Rookie of the Year. The value is the
/// draft year for both drafted and undrafted players from that class.
@override final  int? draftYear;
@override@JsonKey() final  int pointValue;
/// Optymalna rola taktyczna zawodnika (`player_management.md`).
/// Gra w tej roli daje bonus cohesion +2 i `roleFitMult` ×1.03
/// (`squad_management.md`, `matchday_model.md`).
@override final  AssignedRole optimalRole;
/// Previous overall rating (rounded) captured at season start.
/// Used by the Development screen to compute OVR delta.
@override final  int? previousOvr;
/// Raw overall rating captured at the start of the current season.
/// This is kept separate from [previousOvr], whose rounded value is part
/// of the existing development UI contract.
@override final  double? seasonStartOvr;
/// Previous potentialStars captured at season start.
/// Used by the Development screen to compute potential delta.
@override final  double? previousPotential;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerCopyWith<_Player> get copyWith => __$PlayerCopyWithImpl<_Player>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Player&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.position, position) || other.position == position)&&(identical(other.nationality, nationality) || other.nationality == nationality)&&(identical(other.age, age) || other.age == age)&&(identical(other.attributes, attributes) || other.attributes == attributes)&&(identical(other.contract, contract) || other.contract == contract)&&(identical(other.personality, personality) || other.personality == personality)&&(identical(other.potentialStars, potentialStars) || other.potentialStars == potentialStars)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.state, state) || other.state == state)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&const DeepCollectionEquality().equals(other._seasonStats, _seasonStats)&&(identical(other.draftYear, draftYear) || other.draftYear == draftYear)&&(identical(other.pointValue, pointValue) || other.pointValue == pointValue)&&(identical(other.optimalRole, optimalRole) || other.optimalRole == optimalRole)&&(identical(other.previousOvr, previousOvr) || other.previousOvr == previousOvr)&&(identical(other.seasonStartOvr, seasonStartOvr) || other.seasonStartOvr == seasonStartOvr)&&(identical(other.previousPotential, previousPotential) || other.previousPotential == previousPotential));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,position,nationality,age,attributes,contract,personality,potentialStars,heightCm,state,hidden,const DeepCollectionEquality().hash(_seasonStats),draftYear,pointValue,optimalRole,previousOvr,seasonStartOvr,previousPotential]);

@override
String toString() {
  return 'Player(id: $id, name: $name, position: $position, nationality: $nationality, age: $age, attributes: $attributes, contract: $contract, personality: $personality, potentialStars: $potentialStars, heightCm: $heightCm, state: $state, hidden: $hidden, seasonStats: $seasonStats, draftYear: $draftYear, pointValue: $pointValue, optimalRole: $optimalRole, previousOvr: $previousOvr, seasonStartOvr: $seasonStartOvr, previousPotential: $previousPotential)';
}


}

/// @nodoc
abstract mixin class _$PlayerCopyWith<$Res> implements $PlayerCopyWith<$Res> {
  factory _$PlayerCopyWith(_Player value, $Res Function(_Player) _then) = __$PlayerCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, Position position, Nationality nationality, int age, PlayerAttributes attributes, Contract contract, PlayerPersonality personality, double potentialStars, int heightCm, PlayerState state, PlayerHidden hidden, List<PlayerSeasonStats> seasonStats, int? draftYear, int pointValue, AssignedRole optimalRole, int? previousOvr, double? seasonStartOvr, double? previousPotential
});


@override $PlayerAttributesCopyWith<$Res> get attributes;@override $ContractCopyWith<$Res> get contract;@override $PlayerStateCopyWith<$Res> get state;@override $PlayerHiddenCopyWith<$Res> get hidden;@override $AssignedRoleCopyWith<$Res> get optimalRole;

}
/// @nodoc
class __$PlayerCopyWithImpl<$Res>
    implements _$PlayerCopyWith<$Res> {
  __$PlayerCopyWithImpl(this._self, this._then);

  final _Player _self;
  final $Res Function(_Player) _then;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? position = null,Object? nationality = null,Object? age = null,Object? attributes = null,Object? contract = null,Object? personality = null,Object? potentialStars = null,Object? heightCm = null,Object? state = null,Object? hidden = null,Object? seasonStats = null,Object? draftYear = freezed,Object? pointValue = null,Object? optimalRole = null,Object? previousOvr = freezed,Object? seasonStartOvr = freezed,Object? previousPotential = freezed,}) {
  return _then(_Player(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Position,nationality: null == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as Nationality,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,attributes: null == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as PlayerAttributes,contract: null == contract ? _self.contract : contract // ignore: cast_nullable_to_non_nullable
as Contract,personality: null == personality ? _self.personality : personality // ignore: cast_nullable_to_non_nullable
as PlayerPersonality,potentialStars: null == potentialStars ? _self.potentialStars : potentialStars // ignore: cast_nullable_to_non_nullable
as double,heightCm: null == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as PlayerState,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as PlayerHidden,seasonStats: null == seasonStats ? _self._seasonStats : seasonStats // ignore: cast_nullable_to_non_nullable
as List<PlayerSeasonStats>,draftYear: freezed == draftYear ? _self.draftYear : draftYear // ignore: cast_nullable_to_non_nullable
as int?,pointValue: null == pointValue ? _self.pointValue : pointValue // ignore: cast_nullable_to_non_nullable
as int,optimalRole: null == optimalRole ? _self.optimalRole : optimalRole // ignore: cast_nullable_to_non_nullable
as AssignedRole,previousOvr: freezed == previousOvr ? _self.previousOvr : previousOvr // ignore: cast_nullable_to_non_nullable
as int?,seasonStartOvr: freezed == seasonStartOvr ? _self.seasonStartOvr : seasonStartOvr // ignore: cast_nullable_to_non_nullable
as double?,previousPotential: freezed == previousPotential ? _self.previousPotential : previousPotential // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerAttributesCopyWith<$Res> get attributes {
  
  return $PlayerAttributesCopyWith<$Res>(_self.attributes, (value) {
    return _then(_self.copyWith(attributes: value));
  });
}/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContractCopyWith<$Res> get contract {
  
  return $ContractCopyWith<$Res>(_self.contract, (value) {
    return _then(_self.copyWith(contract: value));
  });
}/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerStateCopyWith<$Res> get state {
  
  return $PlayerStateCopyWith<$Res>(_self.state, (value) {
    return _then(_self.copyWith(state: value));
  });
}/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerHiddenCopyWith<$Res> get hidden {
  
  return $PlayerHiddenCopyWith<$Res>(_self.hidden, (value) {
    return _then(_self.copyWith(hidden: value));
  });
}/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssignedRoleCopyWith<$Res> get optimalRole {
  
  return $AssignedRoleCopyWith<$Res>(_self.optimalRole, (value) {
    return _then(_self.copyWith(optimalRole: value));
  });
}
}


/// @nodoc
mixin _$PlayerMatchStats {

 String get playerId; int get minutes; int get goals; int get assists; int get shots; int get shotsOnTarget; double get xg; int get passes; double get passAccuracy; int get duelsWon; int get offsides; int get corners; int get yellowCards; int get redCards; int get tackles; int get interceptions; int get saves; int get shotsFaced; int get ownGoals; bool get cleanSheet; int get staminaAfterMatch; double get rating;
/// Create a copy of PlayerMatchStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerMatchStatsCopyWith<PlayerMatchStats> get copyWith => _$PlayerMatchStatsCopyWithImpl<PlayerMatchStats>(this as PlayerMatchStats, _$identity);

  /// Serializes this PlayerMatchStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerMatchStats&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.minutes, minutes) || other.minutes == minutes)&&(identical(other.goals, goals) || other.goals == goals)&&(identical(other.assists, assists) || other.assists == assists)&&(identical(other.shots, shots) || other.shots == shots)&&(identical(other.shotsOnTarget, shotsOnTarget) || other.shotsOnTarget == shotsOnTarget)&&(identical(other.xg, xg) || other.xg == xg)&&(identical(other.passes, passes) || other.passes == passes)&&(identical(other.passAccuracy, passAccuracy) || other.passAccuracy == passAccuracy)&&(identical(other.duelsWon, duelsWon) || other.duelsWon == duelsWon)&&(identical(other.offsides, offsides) || other.offsides == offsides)&&(identical(other.corners, corners) || other.corners == corners)&&(identical(other.yellowCards, yellowCards) || other.yellowCards == yellowCards)&&(identical(other.redCards, redCards) || other.redCards == redCards)&&(identical(other.tackles, tackles) || other.tackles == tackles)&&(identical(other.interceptions, interceptions) || other.interceptions == interceptions)&&(identical(other.saves, saves) || other.saves == saves)&&(identical(other.shotsFaced, shotsFaced) || other.shotsFaced == shotsFaced)&&(identical(other.ownGoals, ownGoals) || other.ownGoals == ownGoals)&&(identical(other.cleanSheet, cleanSheet) || other.cleanSheet == cleanSheet)&&(identical(other.staminaAfterMatch, staminaAfterMatch) || other.staminaAfterMatch == staminaAfterMatch)&&(identical(other.rating, rating) || other.rating == rating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,playerId,minutes,goals,assists,shots,shotsOnTarget,xg,passes,passAccuracy,duelsWon,offsides,corners,yellowCards,redCards,tackles,interceptions,saves,shotsFaced,ownGoals,cleanSheet,staminaAfterMatch,rating]);

@override
String toString() {
  return 'PlayerMatchStats(playerId: $playerId, minutes: $minutes, goals: $goals, assists: $assists, shots: $shots, shotsOnTarget: $shotsOnTarget, xg: $xg, passes: $passes, passAccuracy: $passAccuracy, duelsWon: $duelsWon, offsides: $offsides, corners: $corners, yellowCards: $yellowCards, redCards: $redCards, tackles: $tackles, interceptions: $interceptions, saves: $saves, shotsFaced: $shotsFaced, ownGoals: $ownGoals, cleanSheet: $cleanSheet, staminaAfterMatch: $staminaAfterMatch, rating: $rating)';
}


}

/// @nodoc
abstract mixin class $PlayerMatchStatsCopyWith<$Res>  {
  factory $PlayerMatchStatsCopyWith(PlayerMatchStats value, $Res Function(PlayerMatchStats) _then) = _$PlayerMatchStatsCopyWithImpl;
@useResult
$Res call({
 String playerId, int minutes, int goals, int assists, int shots, int shotsOnTarget, double xg, int passes, double passAccuracy, int duelsWon, int offsides, int corners, int yellowCards, int redCards, int tackles, int interceptions, int saves, int shotsFaced, int ownGoals, bool cleanSheet, int staminaAfterMatch, double rating
});




}
/// @nodoc
class _$PlayerMatchStatsCopyWithImpl<$Res>
    implements $PlayerMatchStatsCopyWith<$Res> {
  _$PlayerMatchStatsCopyWithImpl(this._self, this._then);

  final PlayerMatchStats _self;
  final $Res Function(PlayerMatchStats) _then;

/// Create a copy of PlayerMatchStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playerId = null,Object? minutes = null,Object? goals = null,Object? assists = null,Object? shots = null,Object? shotsOnTarget = null,Object? xg = null,Object? passes = null,Object? passAccuracy = null,Object? duelsWon = null,Object? offsides = null,Object? corners = null,Object? yellowCards = null,Object? redCards = null,Object? tackles = null,Object? interceptions = null,Object? saves = null,Object? shotsFaced = null,Object? ownGoals = null,Object? cleanSheet = null,Object? staminaAfterMatch = null,Object? rating = null,}) {
  return _then(_self.copyWith(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,minutes: null == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as int,assists: null == assists ? _self.assists : assists // ignore: cast_nullable_to_non_nullable
as int,shots: null == shots ? _self.shots : shots // ignore: cast_nullable_to_non_nullable
as int,shotsOnTarget: null == shotsOnTarget ? _self.shotsOnTarget : shotsOnTarget // ignore: cast_nullable_to_non_nullable
as int,xg: null == xg ? _self.xg : xg // ignore: cast_nullable_to_non_nullable
as double,passes: null == passes ? _self.passes : passes // ignore: cast_nullable_to_non_nullable
as int,passAccuracy: null == passAccuracy ? _self.passAccuracy : passAccuracy // ignore: cast_nullable_to_non_nullable
as double,duelsWon: null == duelsWon ? _self.duelsWon : duelsWon // ignore: cast_nullable_to_non_nullable
as int,offsides: null == offsides ? _self.offsides : offsides // ignore: cast_nullable_to_non_nullable
as int,corners: null == corners ? _self.corners : corners // ignore: cast_nullable_to_non_nullable
as int,yellowCards: null == yellowCards ? _self.yellowCards : yellowCards // ignore: cast_nullable_to_non_nullable
as int,redCards: null == redCards ? _self.redCards : redCards // ignore: cast_nullable_to_non_nullable
as int,tackles: null == tackles ? _self.tackles : tackles // ignore: cast_nullable_to_non_nullable
as int,interceptions: null == interceptions ? _self.interceptions : interceptions // ignore: cast_nullable_to_non_nullable
as int,saves: null == saves ? _self.saves : saves // ignore: cast_nullable_to_non_nullable
as int,shotsFaced: null == shotsFaced ? _self.shotsFaced : shotsFaced // ignore: cast_nullable_to_non_nullable
as int,ownGoals: null == ownGoals ? _self.ownGoals : ownGoals // ignore: cast_nullable_to_non_nullable
as int,cleanSheet: null == cleanSheet ? _self.cleanSheet : cleanSheet // ignore: cast_nullable_to_non_nullable
as bool,staminaAfterMatch: null == staminaAfterMatch ? _self.staminaAfterMatch : staminaAfterMatch // ignore: cast_nullable_to_non_nullable
as int,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerMatchStats].
extension PlayerMatchStatsPatterns on PlayerMatchStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerMatchStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerMatchStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerMatchStats value)  $default,){
final _that = this;
switch (_that) {
case _PlayerMatchStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerMatchStats value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerMatchStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String playerId,  int minutes,  int goals,  int assists,  int shots,  int shotsOnTarget,  double xg,  int passes,  double passAccuracy,  int duelsWon,  int offsides,  int corners,  int yellowCards,  int redCards,  int tackles,  int interceptions,  int saves,  int shotsFaced,  int ownGoals,  bool cleanSheet,  int staminaAfterMatch,  double rating)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerMatchStats() when $default != null:
return $default(_that.playerId,_that.minutes,_that.goals,_that.assists,_that.shots,_that.shotsOnTarget,_that.xg,_that.passes,_that.passAccuracy,_that.duelsWon,_that.offsides,_that.corners,_that.yellowCards,_that.redCards,_that.tackles,_that.interceptions,_that.saves,_that.shotsFaced,_that.ownGoals,_that.cleanSheet,_that.staminaAfterMatch,_that.rating);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String playerId,  int minutes,  int goals,  int assists,  int shots,  int shotsOnTarget,  double xg,  int passes,  double passAccuracy,  int duelsWon,  int offsides,  int corners,  int yellowCards,  int redCards,  int tackles,  int interceptions,  int saves,  int shotsFaced,  int ownGoals,  bool cleanSheet,  int staminaAfterMatch,  double rating)  $default,) {final _that = this;
switch (_that) {
case _PlayerMatchStats():
return $default(_that.playerId,_that.minutes,_that.goals,_that.assists,_that.shots,_that.shotsOnTarget,_that.xg,_that.passes,_that.passAccuracy,_that.duelsWon,_that.offsides,_that.corners,_that.yellowCards,_that.redCards,_that.tackles,_that.interceptions,_that.saves,_that.shotsFaced,_that.ownGoals,_that.cleanSheet,_that.staminaAfterMatch,_that.rating);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String playerId,  int minutes,  int goals,  int assists,  int shots,  int shotsOnTarget,  double xg,  int passes,  double passAccuracy,  int duelsWon,  int offsides,  int corners,  int yellowCards,  int redCards,  int tackles,  int interceptions,  int saves,  int shotsFaced,  int ownGoals,  bool cleanSheet,  int staminaAfterMatch,  double rating)?  $default,) {final _that = this;
switch (_that) {
case _PlayerMatchStats() when $default != null:
return $default(_that.playerId,_that.minutes,_that.goals,_that.assists,_that.shots,_that.shotsOnTarget,_that.xg,_that.passes,_that.passAccuracy,_that.duelsWon,_that.offsides,_that.corners,_that.yellowCards,_that.redCards,_that.tackles,_that.interceptions,_that.saves,_that.shotsFaced,_that.ownGoals,_that.cleanSheet,_that.staminaAfterMatch,_that.rating);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayerMatchStats implements PlayerMatchStats {
  const _PlayerMatchStats({required this.playerId, this.minutes = 0, this.goals = 0, this.assists = 0, this.shots = 0, this.shotsOnTarget = 0, this.xg = 0.0, this.passes = 0, this.passAccuracy = 0.0, this.duelsWon = 0, this.offsides = 0, this.corners = 0, this.yellowCards = 0, this.redCards = 0, this.tackles = 0, this.interceptions = 0, this.saves = 0, this.shotsFaced = 0, this.ownGoals = 0, this.cleanSheet = false, this.staminaAfterMatch = -1, this.rating = 6.0});
  factory _PlayerMatchStats.fromJson(Map<String, dynamic> json) => _$PlayerMatchStatsFromJson(json);

@override final  String playerId;
@override@JsonKey() final  int minutes;
@override@JsonKey() final  int goals;
@override@JsonKey() final  int assists;
@override@JsonKey() final  int shots;
@override@JsonKey() final  int shotsOnTarget;
@override@JsonKey() final  double xg;
@override@JsonKey() final  int passes;
@override@JsonKey() final  double passAccuracy;
@override@JsonKey() final  int duelsWon;
@override@JsonKey() final  int offsides;
@override@JsonKey() final  int corners;
@override@JsonKey() final  int yellowCards;
@override@JsonKey() final  int redCards;
@override@JsonKey() final  int tackles;
@override@JsonKey() final  int interceptions;
@override@JsonKey() final  int saves;
@override@JsonKey() final  int shotsFaced;
@override@JsonKey() final  int ownGoals;
@override@JsonKey() final  bool cleanSheet;
@override@JsonKey() final  int staminaAfterMatch;
@override@JsonKey() final  double rating;

/// Create a copy of PlayerMatchStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerMatchStatsCopyWith<_PlayerMatchStats> get copyWith => __$PlayerMatchStatsCopyWithImpl<_PlayerMatchStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerMatchStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerMatchStats&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.minutes, minutes) || other.minutes == minutes)&&(identical(other.goals, goals) || other.goals == goals)&&(identical(other.assists, assists) || other.assists == assists)&&(identical(other.shots, shots) || other.shots == shots)&&(identical(other.shotsOnTarget, shotsOnTarget) || other.shotsOnTarget == shotsOnTarget)&&(identical(other.xg, xg) || other.xg == xg)&&(identical(other.passes, passes) || other.passes == passes)&&(identical(other.passAccuracy, passAccuracy) || other.passAccuracy == passAccuracy)&&(identical(other.duelsWon, duelsWon) || other.duelsWon == duelsWon)&&(identical(other.offsides, offsides) || other.offsides == offsides)&&(identical(other.corners, corners) || other.corners == corners)&&(identical(other.yellowCards, yellowCards) || other.yellowCards == yellowCards)&&(identical(other.redCards, redCards) || other.redCards == redCards)&&(identical(other.tackles, tackles) || other.tackles == tackles)&&(identical(other.interceptions, interceptions) || other.interceptions == interceptions)&&(identical(other.saves, saves) || other.saves == saves)&&(identical(other.shotsFaced, shotsFaced) || other.shotsFaced == shotsFaced)&&(identical(other.ownGoals, ownGoals) || other.ownGoals == ownGoals)&&(identical(other.cleanSheet, cleanSheet) || other.cleanSheet == cleanSheet)&&(identical(other.staminaAfterMatch, staminaAfterMatch) || other.staminaAfterMatch == staminaAfterMatch)&&(identical(other.rating, rating) || other.rating == rating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,playerId,minutes,goals,assists,shots,shotsOnTarget,xg,passes,passAccuracy,duelsWon,offsides,corners,yellowCards,redCards,tackles,interceptions,saves,shotsFaced,ownGoals,cleanSheet,staminaAfterMatch,rating]);

@override
String toString() {
  return 'PlayerMatchStats(playerId: $playerId, minutes: $minutes, goals: $goals, assists: $assists, shots: $shots, shotsOnTarget: $shotsOnTarget, xg: $xg, passes: $passes, passAccuracy: $passAccuracy, duelsWon: $duelsWon, offsides: $offsides, corners: $corners, yellowCards: $yellowCards, redCards: $redCards, tackles: $tackles, interceptions: $interceptions, saves: $saves, shotsFaced: $shotsFaced, ownGoals: $ownGoals, cleanSheet: $cleanSheet, staminaAfterMatch: $staminaAfterMatch, rating: $rating)';
}


}

/// @nodoc
abstract mixin class _$PlayerMatchStatsCopyWith<$Res> implements $PlayerMatchStatsCopyWith<$Res> {
  factory _$PlayerMatchStatsCopyWith(_PlayerMatchStats value, $Res Function(_PlayerMatchStats) _then) = __$PlayerMatchStatsCopyWithImpl;
@override @useResult
$Res call({
 String playerId, int minutes, int goals, int assists, int shots, int shotsOnTarget, double xg, int passes, double passAccuracy, int duelsWon, int offsides, int corners, int yellowCards, int redCards, int tackles, int interceptions, int saves, int shotsFaced, int ownGoals, bool cleanSheet, int staminaAfterMatch, double rating
});




}
/// @nodoc
class __$PlayerMatchStatsCopyWithImpl<$Res>
    implements _$PlayerMatchStatsCopyWith<$Res> {
  __$PlayerMatchStatsCopyWithImpl(this._self, this._then);

  final _PlayerMatchStats _self;
  final $Res Function(_PlayerMatchStats) _then;

/// Create a copy of PlayerMatchStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playerId = null,Object? minutes = null,Object? goals = null,Object? assists = null,Object? shots = null,Object? shotsOnTarget = null,Object? xg = null,Object? passes = null,Object? passAccuracy = null,Object? duelsWon = null,Object? offsides = null,Object? corners = null,Object? yellowCards = null,Object? redCards = null,Object? tackles = null,Object? interceptions = null,Object? saves = null,Object? shotsFaced = null,Object? ownGoals = null,Object? cleanSheet = null,Object? staminaAfterMatch = null,Object? rating = null,}) {
  return _then(_PlayerMatchStats(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,minutes: null == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as int,assists: null == assists ? _self.assists : assists // ignore: cast_nullable_to_non_nullable
as int,shots: null == shots ? _self.shots : shots // ignore: cast_nullable_to_non_nullable
as int,shotsOnTarget: null == shotsOnTarget ? _self.shotsOnTarget : shotsOnTarget // ignore: cast_nullable_to_non_nullable
as int,xg: null == xg ? _self.xg : xg // ignore: cast_nullable_to_non_nullable
as double,passes: null == passes ? _self.passes : passes // ignore: cast_nullable_to_non_nullable
as int,passAccuracy: null == passAccuracy ? _self.passAccuracy : passAccuracy // ignore: cast_nullable_to_non_nullable
as double,duelsWon: null == duelsWon ? _self.duelsWon : duelsWon // ignore: cast_nullable_to_non_nullable
as int,offsides: null == offsides ? _self.offsides : offsides // ignore: cast_nullable_to_non_nullable
as int,corners: null == corners ? _self.corners : corners // ignore: cast_nullable_to_non_nullable
as int,yellowCards: null == yellowCards ? _self.yellowCards : yellowCards // ignore: cast_nullable_to_non_nullable
as int,redCards: null == redCards ? _self.redCards : redCards // ignore: cast_nullable_to_non_nullable
as int,tackles: null == tackles ? _self.tackles : tackles // ignore: cast_nullable_to_non_nullable
as int,interceptions: null == interceptions ? _self.interceptions : interceptions // ignore: cast_nullable_to_non_nullable
as int,saves: null == saves ? _self.saves : saves // ignore: cast_nullable_to_non_nullable
as int,shotsFaced: null == shotsFaced ? _self.shotsFaced : shotsFaced // ignore: cast_nullable_to_non_nullable
as int,ownGoals: null == ownGoals ? _self.ownGoals : ownGoals // ignore: cast_nullable_to_non_nullable
as int,cleanSheet: null == cleanSheet ? _self.cleanSheet : cleanSheet // ignore: cast_nullable_to_non_nullable
as bool,staminaAfterMatch: null == staminaAfterMatch ? _self.staminaAfterMatch : staminaAfterMatch // ignore: cast_nullable_to_non_nullable
as int,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
