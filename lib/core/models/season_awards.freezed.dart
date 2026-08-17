// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'season_awards.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SeasonAwards {

 int get year; String? get mvpPlayerId; String? get rotyPlayerId; String? get dpoyPlayerId; String? get topScorerPlayerId; String? get topAssistPlayerId; String? get bestGkPlayerId; String? get coachOfYearTeamId; Map<TeamOfSeasonSlot, String> get teamOfSeason; String? get championTeamId;
/// Create a copy of SeasonAwards
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeasonAwardsCopyWith<SeasonAwards> get copyWith => _$SeasonAwardsCopyWithImpl<SeasonAwards>(this as SeasonAwards, _$identity);

  /// Serializes this SeasonAwards to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeasonAwards&&(identical(other.year, year) || other.year == year)&&(identical(other.mvpPlayerId, mvpPlayerId) || other.mvpPlayerId == mvpPlayerId)&&(identical(other.rotyPlayerId, rotyPlayerId) || other.rotyPlayerId == rotyPlayerId)&&(identical(other.dpoyPlayerId, dpoyPlayerId) || other.dpoyPlayerId == dpoyPlayerId)&&(identical(other.topScorerPlayerId, topScorerPlayerId) || other.topScorerPlayerId == topScorerPlayerId)&&(identical(other.topAssistPlayerId, topAssistPlayerId) || other.topAssistPlayerId == topAssistPlayerId)&&(identical(other.bestGkPlayerId, bestGkPlayerId) || other.bestGkPlayerId == bestGkPlayerId)&&(identical(other.coachOfYearTeamId, coachOfYearTeamId) || other.coachOfYearTeamId == coachOfYearTeamId)&&const DeepCollectionEquality().equals(other.teamOfSeason, teamOfSeason)&&(identical(other.championTeamId, championTeamId) || other.championTeamId == championTeamId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,mvpPlayerId,rotyPlayerId,dpoyPlayerId,topScorerPlayerId,topAssistPlayerId,bestGkPlayerId,coachOfYearTeamId,const DeepCollectionEquality().hash(teamOfSeason),championTeamId);

@override
String toString() {
  return 'SeasonAwards(year: $year, mvpPlayerId: $mvpPlayerId, rotyPlayerId: $rotyPlayerId, dpoyPlayerId: $dpoyPlayerId, topScorerPlayerId: $topScorerPlayerId, topAssistPlayerId: $topAssistPlayerId, bestGkPlayerId: $bestGkPlayerId, coachOfYearTeamId: $coachOfYearTeamId, teamOfSeason: $teamOfSeason, championTeamId: $championTeamId)';
}


}

/// @nodoc
abstract mixin class $SeasonAwardsCopyWith<$Res>  {
  factory $SeasonAwardsCopyWith(SeasonAwards value, $Res Function(SeasonAwards) _then) = _$SeasonAwardsCopyWithImpl;
@useResult
$Res call({
 int year, String? mvpPlayerId, String? rotyPlayerId, String? dpoyPlayerId, String? topScorerPlayerId, String? topAssistPlayerId, String? bestGkPlayerId, String? coachOfYearTeamId, Map<TeamOfSeasonSlot, String> teamOfSeason, String? championTeamId
});




}
/// @nodoc
class _$SeasonAwardsCopyWithImpl<$Res>
    implements $SeasonAwardsCopyWith<$Res> {
  _$SeasonAwardsCopyWithImpl(this._self, this._then);

  final SeasonAwards _self;
  final $Res Function(SeasonAwards) _then;

/// Create a copy of SeasonAwards
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? mvpPlayerId = freezed,Object? rotyPlayerId = freezed,Object? dpoyPlayerId = freezed,Object? topScorerPlayerId = freezed,Object? topAssistPlayerId = freezed,Object? bestGkPlayerId = freezed,Object? coachOfYearTeamId = freezed,Object? teamOfSeason = null,Object? championTeamId = freezed,}) {
  return _then(_self.copyWith(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,mvpPlayerId: freezed == mvpPlayerId ? _self.mvpPlayerId : mvpPlayerId // ignore: cast_nullable_to_non_nullable
as String?,rotyPlayerId: freezed == rotyPlayerId ? _self.rotyPlayerId : rotyPlayerId // ignore: cast_nullable_to_non_nullable
as String?,dpoyPlayerId: freezed == dpoyPlayerId ? _self.dpoyPlayerId : dpoyPlayerId // ignore: cast_nullable_to_non_nullable
as String?,topScorerPlayerId: freezed == topScorerPlayerId ? _self.topScorerPlayerId : topScorerPlayerId // ignore: cast_nullable_to_non_nullable
as String?,topAssistPlayerId: freezed == topAssistPlayerId ? _self.topAssistPlayerId : topAssistPlayerId // ignore: cast_nullable_to_non_nullable
as String?,bestGkPlayerId: freezed == bestGkPlayerId ? _self.bestGkPlayerId : bestGkPlayerId // ignore: cast_nullable_to_non_nullable
as String?,coachOfYearTeamId: freezed == coachOfYearTeamId ? _self.coachOfYearTeamId : coachOfYearTeamId // ignore: cast_nullable_to_non_nullable
as String?,teamOfSeason: null == teamOfSeason ? _self.teamOfSeason : teamOfSeason // ignore: cast_nullable_to_non_nullable
as Map<TeamOfSeasonSlot, String>,championTeamId: freezed == championTeamId ? _self.championTeamId : championTeamId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SeasonAwards].
extension SeasonAwardsPatterns on SeasonAwards {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SeasonAwards value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SeasonAwards() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SeasonAwards value)  $default,){
final _that = this;
switch (_that) {
case _SeasonAwards():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SeasonAwards value)?  $default,){
final _that = this;
switch (_that) {
case _SeasonAwards() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  String? mvpPlayerId,  String? rotyPlayerId,  String? dpoyPlayerId,  String? topScorerPlayerId,  String? topAssistPlayerId,  String? bestGkPlayerId,  String? coachOfYearTeamId,  Map<TeamOfSeasonSlot, String> teamOfSeason,  String? championTeamId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeasonAwards() when $default != null:
return $default(_that.year,_that.mvpPlayerId,_that.rotyPlayerId,_that.dpoyPlayerId,_that.topScorerPlayerId,_that.topAssistPlayerId,_that.bestGkPlayerId,_that.coachOfYearTeamId,_that.teamOfSeason,_that.championTeamId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  String? mvpPlayerId,  String? rotyPlayerId,  String? dpoyPlayerId,  String? topScorerPlayerId,  String? topAssistPlayerId,  String? bestGkPlayerId,  String? coachOfYearTeamId,  Map<TeamOfSeasonSlot, String> teamOfSeason,  String? championTeamId)  $default,) {final _that = this;
switch (_that) {
case _SeasonAwards():
return $default(_that.year,_that.mvpPlayerId,_that.rotyPlayerId,_that.dpoyPlayerId,_that.topScorerPlayerId,_that.topAssistPlayerId,_that.bestGkPlayerId,_that.coachOfYearTeamId,_that.teamOfSeason,_that.championTeamId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  String? mvpPlayerId,  String? rotyPlayerId,  String? dpoyPlayerId,  String? topScorerPlayerId,  String? topAssistPlayerId,  String? bestGkPlayerId,  String? coachOfYearTeamId,  Map<TeamOfSeasonSlot, String> teamOfSeason,  String? championTeamId)?  $default,) {final _that = this;
switch (_that) {
case _SeasonAwards() when $default != null:
return $default(_that.year,_that.mvpPlayerId,_that.rotyPlayerId,_that.dpoyPlayerId,_that.topScorerPlayerId,_that.topAssistPlayerId,_that.bestGkPlayerId,_that.coachOfYearTeamId,_that.teamOfSeason,_that.championTeamId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SeasonAwards implements SeasonAwards {
  const _SeasonAwards({required this.year, this.mvpPlayerId, this.rotyPlayerId, this.dpoyPlayerId, this.topScorerPlayerId, this.topAssistPlayerId, this.bestGkPlayerId, this.coachOfYearTeamId, final  Map<TeamOfSeasonSlot, String> teamOfSeason = const {}, this.championTeamId}): _teamOfSeason = teamOfSeason;
  factory _SeasonAwards.fromJson(Map<String, dynamic> json) => _$SeasonAwardsFromJson(json);

@override final  int year;
@override final  String? mvpPlayerId;
@override final  String? rotyPlayerId;
@override final  String? dpoyPlayerId;
@override final  String? topScorerPlayerId;
@override final  String? topAssistPlayerId;
@override final  String? bestGkPlayerId;
@override final  String? coachOfYearTeamId;
 final  Map<TeamOfSeasonSlot, String> _teamOfSeason;
@override@JsonKey() Map<TeamOfSeasonSlot, String> get teamOfSeason {
  if (_teamOfSeason is EqualUnmodifiableMapView) return _teamOfSeason;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_teamOfSeason);
}

@override final  String? championTeamId;

/// Create a copy of SeasonAwards
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeasonAwardsCopyWith<_SeasonAwards> get copyWith => __$SeasonAwardsCopyWithImpl<_SeasonAwards>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeasonAwardsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeasonAwards&&(identical(other.year, year) || other.year == year)&&(identical(other.mvpPlayerId, mvpPlayerId) || other.mvpPlayerId == mvpPlayerId)&&(identical(other.rotyPlayerId, rotyPlayerId) || other.rotyPlayerId == rotyPlayerId)&&(identical(other.dpoyPlayerId, dpoyPlayerId) || other.dpoyPlayerId == dpoyPlayerId)&&(identical(other.topScorerPlayerId, topScorerPlayerId) || other.topScorerPlayerId == topScorerPlayerId)&&(identical(other.topAssistPlayerId, topAssistPlayerId) || other.topAssistPlayerId == topAssistPlayerId)&&(identical(other.bestGkPlayerId, bestGkPlayerId) || other.bestGkPlayerId == bestGkPlayerId)&&(identical(other.coachOfYearTeamId, coachOfYearTeamId) || other.coachOfYearTeamId == coachOfYearTeamId)&&const DeepCollectionEquality().equals(other._teamOfSeason, _teamOfSeason)&&(identical(other.championTeamId, championTeamId) || other.championTeamId == championTeamId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,mvpPlayerId,rotyPlayerId,dpoyPlayerId,topScorerPlayerId,topAssistPlayerId,bestGkPlayerId,coachOfYearTeamId,const DeepCollectionEquality().hash(_teamOfSeason),championTeamId);

@override
String toString() {
  return 'SeasonAwards(year: $year, mvpPlayerId: $mvpPlayerId, rotyPlayerId: $rotyPlayerId, dpoyPlayerId: $dpoyPlayerId, topScorerPlayerId: $topScorerPlayerId, topAssistPlayerId: $topAssistPlayerId, bestGkPlayerId: $bestGkPlayerId, coachOfYearTeamId: $coachOfYearTeamId, teamOfSeason: $teamOfSeason, championTeamId: $championTeamId)';
}


}

/// @nodoc
abstract mixin class _$SeasonAwardsCopyWith<$Res> implements $SeasonAwardsCopyWith<$Res> {
  factory _$SeasonAwardsCopyWith(_SeasonAwards value, $Res Function(_SeasonAwards) _then) = __$SeasonAwardsCopyWithImpl;
@override @useResult
$Res call({
 int year, String? mvpPlayerId, String? rotyPlayerId, String? dpoyPlayerId, String? topScorerPlayerId, String? topAssistPlayerId, String? bestGkPlayerId, String? coachOfYearTeamId, Map<TeamOfSeasonSlot, String> teamOfSeason, String? championTeamId
});




}
/// @nodoc
class __$SeasonAwardsCopyWithImpl<$Res>
    implements _$SeasonAwardsCopyWith<$Res> {
  __$SeasonAwardsCopyWithImpl(this._self, this._then);

  final _SeasonAwards _self;
  final $Res Function(_SeasonAwards) _then;

/// Create a copy of SeasonAwards
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? mvpPlayerId = freezed,Object? rotyPlayerId = freezed,Object? dpoyPlayerId = freezed,Object? topScorerPlayerId = freezed,Object? topAssistPlayerId = freezed,Object? bestGkPlayerId = freezed,Object? coachOfYearTeamId = freezed,Object? teamOfSeason = null,Object? championTeamId = freezed,}) {
  return _then(_SeasonAwards(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,mvpPlayerId: freezed == mvpPlayerId ? _self.mvpPlayerId : mvpPlayerId // ignore: cast_nullable_to_non_nullable
as String?,rotyPlayerId: freezed == rotyPlayerId ? _self.rotyPlayerId : rotyPlayerId // ignore: cast_nullable_to_non_nullable
as String?,dpoyPlayerId: freezed == dpoyPlayerId ? _self.dpoyPlayerId : dpoyPlayerId // ignore: cast_nullable_to_non_nullable
as String?,topScorerPlayerId: freezed == topScorerPlayerId ? _self.topScorerPlayerId : topScorerPlayerId // ignore: cast_nullable_to_non_nullable
as String?,topAssistPlayerId: freezed == topAssistPlayerId ? _self.topAssistPlayerId : topAssistPlayerId // ignore: cast_nullable_to_non_nullable
as String?,bestGkPlayerId: freezed == bestGkPlayerId ? _self.bestGkPlayerId : bestGkPlayerId // ignore: cast_nullable_to_non_nullable
as String?,coachOfYearTeamId: freezed == coachOfYearTeamId ? _self.coachOfYearTeamId : coachOfYearTeamId // ignore: cast_nullable_to_non_nullable
as String?,teamOfSeason: null == teamOfSeason ? _self._teamOfSeason : teamOfSeason // ignore: cast_nullable_to_non_nullable
as Map<TeamOfSeasonSlot, String>,championTeamId: freezed == championTeamId ? _self.championTeamId : championTeamId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
