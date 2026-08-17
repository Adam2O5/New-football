// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draft_pick.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DraftPick {

 String get id; int get year; int get round; int? get pickNumber; String get teamId; String get originalTeamId; String? get prospectId; String? get playerName; int? get protectedTopN; int get tradeValue;
/// Create a copy of DraftPick
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftPickCopyWith<DraftPick> get copyWith => _$DraftPickCopyWithImpl<DraftPick>(this as DraftPick, _$identity);

  /// Serializes this DraftPick to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DraftPick&&(identical(other.id, id) || other.id == id)&&(identical(other.year, year) || other.year == year)&&(identical(other.round, round) || other.round == round)&&(identical(other.pickNumber, pickNumber) || other.pickNumber == pickNumber)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.originalTeamId, originalTeamId) || other.originalTeamId == originalTeamId)&&(identical(other.prospectId, prospectId) || other.prospectId == prospectId)&&(identical(other.playerName, playerName) || other.playerName == playerName)&&(identical(other.protectedTopN, protectedTopN) || other.protectedTopN == protectedTopN)&&(identical(other.tradeValue, tradeValue) || other.tradeValue == tradeValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,year,round,pickNumber,teamId,originalTeamId,prospectId,playerName,protectedTopN,tradeValue);

@override
String toString() {
  return 'DraftPick(id: $id, year: $year, round: $round, pickNumber: $pickNumber, teamId: $teamId, originalTeamId: $originalTeamId, prospectId: $prospectId, playerName: $playerName, protectedTopN: $protectedTopN, tradeValue: $tradeValue)';
}


}

/// @nodoc
abstract mixin class $DraftPickCopyWith<$Res>  {
  factory $DraftPickCopyWith(DraftPick value, $Res Function(DraftPick) _then) = _$DraftPickCopyWithImpl;
@useResult
$Res call({
 String id, int year, int round, int? pickNumber, String teamId, String originalTeamId, String? prospectId, String? playerName, int? protectedTopN, int tradeValue
});




}
/// @nodoc
class _$DraftPickCopyWithImpl<$Res>
    implements $DraftPickCopyWith<$Res> {
  _$DraftPickCopyWithImpl(this._self, this._then);

  final DraftPick _self;
  final $Res Function(DraftPick) _then;

/// Create a copy of DraftPick
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? year = null,Object? round = null,Object? pickNumber = freezed,Object? teamId = null,Object? originalTeamId = null,Object? prospectId = freezed,Object? playerName = freezed,Object? protectedTopN = freezed,Object? tradeValue = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as int,pickNumber: freezed == pickNumber ? _self.pickNumber : pickNumber // ignore: cast_nullable_to_non_nullable
as int?,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,originalTeamId: null == originalTeamId ? _self.originalTeamId : originalTeamId // ignore: cast_nullable_to_non_nullable
as String,prospectId: freezed == prospectId ? _self.prospectId : prospectId // ignore: cast_nullable_to_non_nullable
as String?,playerName: freezed == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String?,protectedTopN: freezed == protectedTopN ? _self.protectedTopN : protectedTopN // ignore: cast_nullable_to_non_nullable
as int?,tradeValue: null == tradeValue ? _self.tradeValue : tradeValue // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DraftPick].
extension DraftPickPatterns on DraftPick {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DraftPick value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DraftPick() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DraftPick value)  $default,){
final _that = this;
switch (_that) {
case _DraftPick():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DraftPick value)?  $default,){
final _that = this;
switch (_that) {
case _DraftPick() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int year,  int round,  int? pickNumber,  String teamId,  String originalTeamId,  String? prospectId,  String? playerName,  int? protectedTopN,  int tradeValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DraftPick() when $default != null:
return $default(_that.id,_that.year,_that.round,_that.pickNumber,_that.teamId,_that.originalTeamId,_that.prospectId,_that.playerName,_that.protectedTopN,_that.tradeValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int year,  int round,  int? pickNumber,  String teamId,  String originalTeamId,  String? prospectId,  String? playerName,  int? protectedTopN,  int tradeValue)  $default,) {final _that = this;
switch (_that) {
case _DraftPick():
return $default(_that.id,_that.year,_that.round,_that.pickNumber,_that.teamId,_that.originalTeamId,_that.prospectId,_that.playerName,_that.protectedTopN,_that.tradeValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int year,  int round,  int? pickNumber,  String teamId,  String originalTeamId,  String? prospectId,  String? playerName,  int? protectedTopN,  int tradeValue)?  $default,) {final _that = this;
switch (_that) {
case _DraftPick() when $default != null:
return $default(_that.id,_that.year,_that.round,_that.pickNumber,_that.teamId,_that.originalTeamId,_that.prospectId,_that.playerName,_that.protectedTopN,_that.tradeValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DraftPick implements DraftPick {
  const _DraftPick({required this.id, required this.year, required this.round, this.pickNumber, required this.teamId, required this.originalTeamId, this.prospectId, this.playerName, this.protectedTopN, this.tradeValue = 0});
  factory _DraftPick.fromJson(Map<String, dynamic> json) => _$DraftPickFromJson(json);

@override final  String id;
@override final  int year;
@override final  int round;
@override final  int? pickNumber;
@override final  String teamId;
@override final  String originalTeamId;
@override final  String? prospectId;
@override final  String? playerName;
@override final  int? protectedTopN;
@override@JsonKey() final  int tradeValue;

/// Create a copy of DraftPick
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftPickCopyWith<_DraftPick> get copyWith => __$DraftPickCopyWithImpl<_DraftPick>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DraftPickToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DraftPick&&(identical(other.id, id) || other.id == id)&&(identical(other.year, year) || other.year == year)&&(identical(other.round, round) || other.round == round)&&(identical(other.pickNumber, pickNumber) || other.pickNumber == pickNumber)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.originalTeamId, originalTeamId) || other.originalTeamId == originalTeamId)&&(identical(other.prospectId, prospectId) || other.prospectId == prospectId)&&(identical(other.playerName, playerName) || other.playerName == playerName)&&(identical(other.protectedTopN, protectedTopN) || other.protectedTopN == protectedTopN)&&(identical(other.tradeValue, tradeValue) || other.tradeValue == tradeValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,year,round,pickNumber,teamId,originalTeamId,prospectId,playerName,protectedTopN,tradeValue);

@override
String toString() {
  return 'DraftPick(id: $id, year: $year, round: $round, pickNumber: $pickNumber, teamId: $teamId, originalTeamId: $originalTeamId, prospectId: $prospectId, playerName: $playerName, protectedTopN: $protectedTopN, tradeValue: $tradeValue)';
}


}

/// @nodoc
abstract mixin class _$DraftPickCopyWith<$Res> implements $DraftPickCopyWith<$Res> {
  factory _$DraftPickCopyWith(_DraftPick value, $Res Function(_DraftPick) _then) = __$DraftPickCopyWithImpl;
@override @useResult
$Res call({
 String id, int year, int round, int? pickNumber, String teamId, String originalTeamId, String? prospectId, String? playerName, int? protectedTopN, int tradeValue
});




}
/// @nodoc
class __$DraftPickCopyWithImpl<$Res>
    implements _$DraftPickCopyWith<$Res> {
  __$DraftPickCopyWithImpl(this._self, this._then);

  final _DraftPick _self;
  final $Res Function(_DraftPick) _then;

/// Create a copy of DraftPick
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? year = null,Object? round = null,Object? pickNumber = freezed,Object? teamId = null,Object? originalTeamId = null,Object? prospectId = freezed,Object? playerName = freezed,Object? protectedTopN = freezed,Object? tradeValue = null,}) {
  return _then(_DraftPick(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as int,pickNumber: freezed == pickNumber ? _self.pickNumber : pickNumber // ignore: cast_nullable_to_non_nullable
as int?,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,originalTeamId: null == originalTeamId ? _self.originalTeamId : originalTeamId // ignore: cast_nullable_to_non_nullable
as String,prospectId: freezed == prospectId ? _self.prospectId : prospectId // ignore: cast_nullable_to_non_nullable
as String?,playerName: freezed == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String?,protectedTopN: freezed == protectedTopN ? _self.protectedTopN : protectedTopN // ignore: cast_nullable_to_non_nullable
as int?,tradeValue: null == tradeValue ? _self.tradeValue : tradeValue // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
