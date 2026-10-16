// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'season_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SeasonHistory {

 int get year; List<ConferenceStandings> get finalStandings; String? get championTeamId; List<DraftPick> get draftPicks; SeasonAwards? get awards;
/// Create a copy of SeasonHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeasonHistoryCopyWith<SeasonHistory> get copyWith => _$SeasonHistoryCopyWithImpl<SeasonHistory>(this as SeasonHistory, _$identity);

  /// Serializes this SeasonHistory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeasonHistory&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other.finalStandings, finalStandings)&&(identical(other.championTeamId, championTeamId) || other.championTeamId == championTeamId)&&const DeepCollectionEquality().equals(other.draftPicks, draftPicks)&&(identical(other.awards, awards) || other.awards == awards));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,const DeepCollectionEquality().hash(finalStandings),championTeamId,const DeepCollectionEquality().hash(draftPicks),awards);

@override
String toString() {
  return 'SeasonHistory(year: $year, finalStandings: $finalStandings, championTeamId: $championTeamId, draftPicks: $draftPicks, awards: $awards)';
}


}

/// @nodoc
abstract mixin class $SeasonHistoryCopyWith<$Res>  {
  factory $SeasonHistoryCopyWith(SeasonHistory value, $Res Function(SeasonHistory) _then) = _$SeasonHistoryCopyWithImpl;
@useResult
$Res call({
 int year, List<ConferenceStandings> finalStandings, String? championTeamId, List<DraftPick> draftPicks, SeasonAwards? awards
});


$SeasonAwardsCopyWith<$Res>? get awards;

}
/// @nodoc
class _$SeasonHistoryCopyWithImpl<$Res>
    implements $SeasonHistoryCopyWith<$Res> {
  _$SeasonHistoryCopyWithImpl(this._self, this._then);

  final SeasonHistory _self;
  final $Res Function(SeasonHistory) _then;

/// Create a copy of SeasonHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? finalStandings = null,Object? championTeamId = freezed,Object? draftPicks = null,Object? awards = freezed,}) {
  return _then(_self.copyWith(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,finalStandings: null == finalStandings ? _self.finalStandings : finalStandings // ignore: cast_nullable_to_non_nullable
as List<ConferenceStandings>,championTeamId: freezed == championTeamId ? _self.championTeamId : championTeamId // ignore: cast_nullable_to_non_nullable
as String?,draftPicks: null == draftPicks ? _self.draftPicks : draftPicks // ignore: cast_nullable_to_non_nullable
as List<DraftPick>,awards: freezed == awards ? _self.awards : awards // ignore: cast_nullable_to_non_nullable
as SeasonAwards?,
  ));
}
/// Create a copy of SeasonHistory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeasonAwardsCopyWith<$Res>? get awards {
    if (_self.awards == null) {
    return null;
  }

  return $SeasonAwardsCopyWith<$Res>(_self.awards!, (value) {
    return _then(_self.copyWith(awards: value));
  });
}
}


/// Adds pattern-matching-related methods to [SeasonHistory].
extension SeasonHistoryPatterns on SeasonHistory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SeasonHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SeasonHistory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SeasonHistory value)  $default,){
final _that = this;
switch (_that) {
case _SeasonHistory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SeasonHistory value)?  $default,){
final _that = this;
switch (_that) {
case _SeasonHistory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  List<ConferenceStandings> finalStandings,  String? championTeamId,  List<DraftPick> draftPicks,  SeasonAwards? awards)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeasonHistory() when $default != null:
return $default(_that.year,_that.finalStandings,_that.championTeamId,_that.draftPicks,_that.awards);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  List<ConferenceStandings> finalStandings,  String? championTeamId,  List<DraftPick> draftPicks,  SeasonAwards? awards)  $default,) {final _that = this;
switch (_that) {
case _SeasonHistory():
return $default(_that.year,_that.finalStandings,_that.championTeamId,_that.draftPicks,_that.awards);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  List<ConferenceStandings> finalStandings,  String? championTeamId,  List<DraftPick> draftPicks,  SeasonAwards? awards)?  $default,) {final _that = this;
switch (_that) {
case _SeasonHistory() when $default != null:
return $default(_that.year,_that.finalStandings,_that.championTeamId,_that.draftPicks,_that.awards);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SeasonHistory implements SeasonHistory {
  const _SeasonHistory({required this.year, required final  List<ConferenceStandings> finalStandings, this.championTeamId, final  List<DraftPick> draftPicks = const [], this.awards}): _finalStandings = finalStandings,_draftPicks = draftPicks;
  factory _SeasonHistory.fromJson(Map<String, dynamic> json) => _$SeasonHistoryFromJson(json);

@override final  int year;
 final  List<ConferenceStandings> _finalStandings;
@override List<ConferenceStandings> get finalStandings {
  if (_finalStandings is EqualUnmodifiableListView) return _finalStandings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_finalStandings);
}

@override final  String? championTeamId;
 final  List<DraftPick> _draftPicks;
@override@JsonKey() List<DraftPick> get draftPicks {
  if (_draftPicks is EqualUnmodifiableListView) return _draftPicks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_draftPicks);
}

@override final  SeasonAwards? awards;

/// Create a copy of SeasonHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeasonHistoryCopyWith<_SeasonHistory> get copyWith => __$SeasonHistoryCopyWithImpl<_SeasonHistory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeasonHistoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeasonHistory&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other._finalStandings, _finalStandings)&&(identical(other.championTeamId, championTeamId) || other.championTeamId == championTeamId)&&const DeepCollectionEquality().equals(other._draftPicks, _draftPicks)&&(identical(other.awards, awards) || other.awards == awards));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,const DeepCollectionEquality().hash(_finalStandings),championTeamId,const DeepCollectionEquality().hash(_draftPicks),awards);

@override
String toString() {
  return 'SeasonHistory(year: $year, finalStandings: $finalStandings, championTeamId: $championTeamId, draftPicks: $draftPicks, awards: $awards)';
}


}

/// @nodoc
abstract mixin class _$SeasonHistoryCopyWith<$Res> implements $SeasonHistoryCopyWith<$Res> {
  factory _$SeasonHistoryCopyWith(_SeasonHistory value, $Res Function(_SeasonHistory) _then) = __$SeasonHistoryCopyWithImpl;
@override @useResult
$Res call({
 int year, List<ConferenceStandings> finalStandings, String? championTeamId, List<DraftPick> draftPicks, SeasonAwards? awards
});


@override $SeasonAwardsCopyWith<$Res>? get awards;

}
/// @nodoc
class __$SeasonHistoryCopyWithImpl<$Res>
    implements _$SeasonHistoryCopyWith<$Res> {
  __$SeasonHistoryCopyWithImpl(this._self, this._then);

  final _SeasonHistory _self;
  final $Res Function(_SeasonHistory) _then;

/// Create a copy of SeasonHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? finalStandings = null,Object? championTeamId = freezed,Object? draftPicks = null,Object? awards = freezed,}) {
  return _then(_SeasonHistory(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,finalStandings: null == finalStandings ? _self._finalStandings : finalStandings // ignore: cast_nullable_to_non_nullable
as List<ConferenceStandings>,championTeamId: freezed == championTeamId ? _self.championTeamId : championTeamId // ignore: cast_nullable_to_non_nullable
as String?,draftPicks: null == draftPicks ? _self._draftPicks : draftPicks // ignore: cast_nullable_to_non_nullable
as List<DraftPick>,awards: freezed == awards ? _self.awards : awards // ignore: cast_nullable_to_non_nullable
as SeasonAwards?,
  ));
}

/// Create a copy of SeasonHistory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeasonAwardsCopyWith<$Res>? get awards {
    if (_self.awards == null) {
    return null;
  }

  return $SeasonAwardsCopyWith<$Res>(_self.awards!, (value) {
    return _then(_self.copyWith(awards: value));
  });
}
}

// dart format on
