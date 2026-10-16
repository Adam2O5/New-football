// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lottery_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LotteryResult {

 String get teamId; int get originalRank; int get assignedPick; double get oddsForFirstPick;
/// Create a copy of LotteryResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LotteryResultCopyWith<LotteryResult> get copyWith => _$LotteryResultCopyWithImpl<LotteryResult>(this as LotteryResult, _$identity);

  /// Serializes this LotteryResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LotteryResult&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.originalRank, originalRank) || other.originalRank == originalRank)&&(identical(other.assignedPick, assignedPick) || other.assignedPick == assignedPick)&&(identical(other.oddsForFirstPick, oddsForFirstPick) || other.oddsForFirstPick == oddsForFirstPick));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamId,originalRank,assignedPick,oddsForFirstPick);

@override
String toString() {
  return 'LotteryResult(teamId: $teamId, originalRank: $originalRank, assignedPick: $assignedPick, oddsForFirstPick: $oddsForFirstPick)';
}


}

/// @nodoc
abstract mixin class $LotteryResultCopyWith<$Res>  {
  factory $LotteryResultCopyWith(LotteryResult value, $Res Function(LotteryResult) _then) = _$LotteryResultCopyWithImpl;
@useResult
$Res call({
 String teamId, int originalRank, int assignedPick, double oddsForFirstPick
});




}
/// @nodoc
class _$LotteryResultCopyWithImpl<$Res>
    implements $LotteryResultCopyWith<$Res> {
  _$LotteryResultCopyWithImpl(this._self, this._then);

  final LotteryResult _self;
  final $Res Function(LotteryResult) _then;

/// Create a copy of LotteryResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? teamId = null,Object? originalRank = null,Object? assignedPick = null,Object? oddsForFirstPick = null,}) {
  return _then(_self.copyWith(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,originalRank: null == originalRank ? _self.originalRank : originalRank // ignore: cast_nullable_to_non_nullable
as int,assignedPick: null == assignedPick ? _self.assignedPick : assignedPick // ignore: cast_nullable_to_non_nullable
as int,oddsForFirstPick: null == oddsForFirstPick ? _self.oddsForFirstPick : oddsForFirstPick // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [LotteryResult].
extension LotteryResultPatterns on LotteryResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LotteryResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LotteryResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LotteryResult value)  $default,){
final _that = this;
switch (_that) {
case _LotteryResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LotteryResult value)?  $default,){
final _that = this;
switch (_that) {
case _LotteryResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String teamId,  int originalRank,  int assignedPick,  double oddsForFirstPick)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LotteryResult() when $default != null:
return $default(_that.teamId,_that.originalRank,_that.assignedPick,_that.oddsForFirstPick);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String teamId,  int originalRank,  int assignedPick,  double oddsForFirstPick)  $default,) {final _that = this;
switch (_that) {
case _LotteryResult():
return $default(_that.teamId,_that.originalRank,_that.assignedPick,_that.oddsForFirstPick);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String teamId,  int originalRank,  int assignedPick,  double oddsForFirstPick)?  $default,) {final _that = this;
switch (_that) {
case _LotteryResult() when $default != null:
return $default(_that.teamId,_that.originalRank,_that.assignedPick,_that.oddsForFirstPick);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LotteryResult implements LotteryResult {
  const _LotteryResult({required this.teamId, required this.originalRank, required this.assignedPick, required this.oddsForFirstPick});
  factory _LotteryResult.fromJson(Map<String, dynamic> json) => _$LotteryResultFromJson(json);

@override final  String teamId;
@override final  int originalRank;
@override final  int assignedPick;
@override final  double oddsForFirstPick;

/// Create a copy of LotteryResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LotteryResultCopyWith<_LotteryResult> get copyWith => __$LotteryResultCopyWithImpl<_LotteryResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LotteryResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LotteryResult&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.originalRank, originalRank) || other.originalRank == originalRank)&&(identical(other.assignedPick, assignedPick) || other.assignedPick == assignedPick)&&(identical(other.oddsForFirstPick, oddsForFirstPick) || other.oddsForFirstPick == oddsForFirstPick));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamId,originalRank,assignedPick,oddsForFirstPick);

@override
String toString() {
  return 'LotteryResult(teamId: $teamId, originalRank: $originalRank, assignedPick: $assignedPick, oddsForFirstPick: $oddsForFirstPick)';
}


}

/// @nodoc
abstract mixin class _$LotteryResultCopyWith<$Res> implements $LotteryResultCopyWith<$Res> {
  factory _$LotteryResultCopyWith(_LotteryResult value, $Res Function(_LotteryResult) _then) = __$LotteryResultCopyWithImpl;
@override @useResult
$Res call({
 String teamId, int originalRank, int assignedPick, double oddsForFirstPick
});




}
/// @nodoc
class __$LotteryResultCopyWithImpl<$Res>
    implements _$LotteryResultCopyWith<$Res> {
  __$LotteryResultCopyWithImpl(this._self, this._then);

  final _LotteryResult _self;
  final $Res Function(_LotteryResult) _then;

/// Create a copy of LotteryResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? teamId = null,Object? originalRank = null,Object? assignedPick = null,Object? oddsForFirstPick = null,}) {
  return _then(_LotteryResult(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,originalRank: null == originalRank ? _self.originalRank : originalRank // ignore: cast_nullable_to_non_nullable
as int,assignedPick: null == assignedPick ? _self.assignedPick : assignedPick // ignore: cast_nullable_to_non_nullable
as int,oddsForFirstPick: null == oddsForFirstPick ? _self.oddsForFirstPick : oddsForFirstPick // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
