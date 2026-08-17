// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draft_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Prospect {

 String get id; String get name; Nationality get nationality; Position get position; int get age; PlayerAttributes get attributes; int get scoutGrade;//unevaluated
 int get combineScore;//unevaluated
 double get potentialStars; int get heightCm; int get injuryProne; int get determination; PlayerPersonality get personality;/// Optymalna rola taktyczna (`player_management.md`).
/// Ujawniana przez Combine (`offseason.md` §7).
 AssignedRole get optimalRole;
/// Create a copy of Prospect
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProspectCopyWith<Prospect> get copyWith => _$ProspectCopyWithImpl<Prospect>(this as Prospect, _$identity);

  /// Serializes this Prospect to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Prospect&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nationality, nationality) || other.nationality == nationality)&&(identical(other.position, position) || other.position == position)&&(identical(other.age, age) || other.age == age)&&(identical(other.attributes, attributes) || other.attributes == attributes)&&(identical(other.scoutGrade, scoutGrade) || other.scoutGrade == scoutGrade)&&(identical(other.combineScore, combineScore) || other.combineScore == combineScore)&&(identical(other.potentialStars, potentialStars) || other.potentialStars == potentialStars)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.injuryProne, injuryProne) || other.injuryProne == injuryProne)&&(identical(other.determination, determination) || other.determination == determination)&&(identical(other.personality, personality) || other.personality == personality)&&(identical(other.optimalRole, optimalRole) || other.optimalRole == optimalRole));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nationality,position,age,attributes,scoutGrade,combineScore,potentialStars,heightCm,injuryProne,determination,personality,optimalRole);

@override
String toString() {
  return 'Prospect(id: $id, name: $name, nationality: $nationality, position: $position, age: $age, attributes: $attributes, scoutGrade: $scoutGrade, combineScore: $combineScore, potentialStars: $potentialStars, heightCm: $heightCm, injuryProne: $injuryProne, determination: $determination, personality: $personality, optimalRole: $optimalRole)';
}


}

/// @nodoc
abstract mixin class $ProspectCopyWith<$Res>  {
  factory $ProspectCopyWith(Prospect value, $Res Function(Prospect) _then) = _$ProspectCopyWithImpl;
@useResult
$Res call({
 String id, String name, Nationality nationality, Position position, int age, PlayerAttributes attributes, int scoutGrade, int combineScore, double potentialStars, int heightCm, int injuryProne, int determination, PlayerPersonality personality, AssignedRole optimalRole
});


$PlayerAttributesCopyWith<$Res> get attributes;$AssignedRoleCopyWith<$Res> get optimalRole;

}
/// @nodoc
class _$ProspectCopyWithImpl<$Res>
    implements $ProspectCopyWith<$Res> {
  _$ProspectCopyWithImpl(this._self, this._then);

  final Prospect _self;
  final $Res Function(Prospect) _then;

/// Create a copy of Prospect
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? nationality = null,Object? position = null,Object? age = null,Object? attributes = null,Object? scoutGrade = null,Object? combineScore = null,Object? potentialStars = null,Object? heightCm = null,Object? injuryProne = null,Object? determination = null,Object? personality = null,Object? optimalRole = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nationality: null == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as Nationality,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Position,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,attributes: null == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as PlayerAttributes,scoutGrade: null == scoutGrade ? _self.scoutGrade : scoutGrade // ignore: cast_nullable_to_non_nullable
as int,combineScore: null == combineScore ? _self.combineScore : combineScore // ignore: cast_nullable_to_non_nullable
as int,potentialStars: null == potentialStars ? _self.potentialStars : potentialStars // ignore: cast_nullable_to_non_nullable
as double,heightCm: null == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as int,injuryProne: null == injuryProne ? _self.injuryProne : injuryProne // ignore: cast_nullable_to_non_nullable
as int,determination: null == determination ? _self.determination : determination // ignore: cast_nullable_to_non_nullable
as int,personality: null == personality ? _self.personality : personality // ignore: cast_nullable_to_non_nullable
as PlayerPersonality,optimalRole: null == optimalRole ? _self.optimalRole : optimalRole // ignore: cast_nullable_to_non_nullable
as AssignedRole,
  ));
}
/// Create a copy of Prospect
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerAttributesCopyWith<$Res> get attributes {
  
  return $PlayerAttributesCopyWith<$Res>(_self.attributes, (value) {
    return _then(_self.copyWith(attributes: value));
  });
}/// Create a copy of Prospect
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AssignedRoleCopyWith<$Res> get optimalRole {
  
  return $AssignedRoleCopyWith<$Res>(_self.optimalRole, (value) {
    return _then(_self.copyWith(optimalRole: value));
  });
}
}


/// Adds pattern-matching-related methods to [Prospect].
extension ProspectPatterns on Prospect {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Prospect value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Prospect() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Prospect value)  $default,){
final _that = this;
switch (_that) {
case _Prospect():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Prospect value)?  $default,){
final _that = this;
switch (_that) {
case _Prospect() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  Nationality nationality,  Position position,  int age,  PlayerAttributes attributes,  int scoutGrade,  int combineScore,  double potentialStars,  int heightCm,  int injuryProne,  int determination,  PlayerPersonality personality,  AssignedRole optimalRole)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Prospect() when $default != null:
return $default(_that.id,_that.name,_that.nationality,_that.position,_that.age,_that.attributes,_that.scoutGrade,_that.combineScore,_that.potentialStars,_that.heightCm,_that.injuryProne,_that.determination,_that.personality,_that.optimalRole);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  Nationality nationality,  Position position,  int age,  PlayerAttributes attributes,  int scoutGrade,  int combineScore,  double potentialStars,  int heightCm,  int injuryProne,  int determination,  PlayerPersonality personality,  AssignedRole optimalRole)  $default,) {final _that = this;
switch (_that) {
case _Prospect():
return $default(_that.id,_that.name,_that.nationality,_that.position,_that.age,_that.attributes,_that.scoutGrade,_that.combineScore,_that.potentialStars,_that.heightCm,_that.injuryProne,_that.determination,_that.personality,_that.optimalRole);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  Nationality nationality,  Position position,  int age,  PlayerAttributes attributes,  int scoutGrade,  int combineScore,  double potentialStars,  int heightCm,  int injuryProne,  int determination,  PlayerPersonality personality,  AssignedRole optimalRole)?  $default,) {final _that = this;
switch (_that) {
case _Prospect() when $default != null:
return $default(_that.id,_that.name,_that.nationality,_that.position,_that.age,_that.attributes,_that.scoutGrade,_that.combineScore,_that.potentialStars,_that.heightCm,_that.injuryProne,_that.determination,_that.personality,_that.optimalRole);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Prospect implements Prospect {
  const _Prospect({required this.id, required this.name, required this.nationality, required this.position, required this.age, required this.attributes, this.scoutGrade = 0, this.combineScore = 0, required this.potentialStars, required this.heightCm, required this.injuryProne, required this.determination, required this.personality, required this.optimalRole});
  factory _Prospect.fromJson(Map<String, dynamic> json) => _$ProspectFromJson(json);

@override final  String id;
@override final  String name;
@override final  Nationality nationality;
@override final  Position position;
@override final  int age;
@override final  PlayerAttributes attributes;
@override@JsonKey() final  int scoutGrade;
//unevaluated
@override@JsonKey() final  int combineScore;
//unevaluated
@override final  double potentialStars;
@override final  int heightCm;
@override final  int injuryProne;
@override final  int determination;
@override final  PlayerPersonality personality;
/// Optymalna rola taktyczna (`player_management.md`).
/// Ujawniana przez Combine (`offseason.md` §7).
@override final  AssignedRole optimalRole;

/// Create a copy of Prospect
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProspectCopyWith<_Prospect> get copyWith => __$ProspectCopyWithImpl<_Prospect>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProspectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Prospect&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nationality, nationality) || other.nationality == nationality)&&(identical(other.position, position) || other.position == position)&&(identical(other.age, age) || other.age == age)&&(identical(other.attributes, attributes) || other.attributes == attributes)&&(identical(other.scoutGrade, scoutGrade) || other.scoutGrade == scoutGrade)&&(identical(other.combineScore, combineScore) || other.combineScore == combineScore)&&(identical(other.potentialStars, potentialStars) || other.potentialStars == potentialStars)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.injuryProne, injuryProne) || other.injuryProne == injuryProne)&&(identical(other.determination, determination) || other.determination == determination)&&(identical(other.personality, personality) || other.personality == personality)&&(identical(other.optimalRole, optimalRole) || other.optimalRole == optimalRole));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nationality,position,age,attributes,scoutGrade,combineScore,potentialStars,heightCm,injuryProne,determination,personality,optimalRole);

@override
String toString() {
  return 'Prospect(id: $id, name: $name, nationality: $nationality, position: $position, age: $age, attributes: $attributes, scoutGrade: $scoutGrade, combineScore: $combineScore, potentialStars: $potentialStars, heightCm: $heightCm, injuryProne: $injuryProne, determination: $determination, personality: $personality, optimalRole: $optimalRole)';
}


}

/// @nodoc
abstract mixin class _$ProspectCopyWith<$Res> implements $ProspectCopyWith<$Res> {
  factory _$ProspectCopyWith(_Prospect value, $Res Function(_Prospect) _then) = __$ProspectCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, Nationality nationality, Position position, int age, PlayerAttributes attributes, int scoutGrade, int combineScore, double potentialStars, int heightCm, int injuryProne, int determination, PlayerPersonality personality, AssignedRole optimalRole
});


@override $PlayerAttributesCopyWith<$Res> get attributes;@override $AssignedRoleCopyWith<$Res> get optimalRole;

}
/// @nodoc
class __$ProspectCopyWithImpl<$Res>
    implements _$ProspectCopyWith<$Res> {
  __$ProspectCopyWithImpl(this._self, this._then);

  final _Prospect _self;
  final $Res Function(_Prospect) _then;

/// Create a copy of Prospect
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? nationality = null,Object? position = null,Object? age = null,Object? attributes = null,Object? scoutGrade = null,Object? combineScore = null,Object? potentialStars = null,Object? heightCm = null,Object? injuryProne = null,Object? determination = null,Object? personality = null,Object? optimalRole = null,}) {
  return _then(_Prospect(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nationality: null == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as Nationality,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Position,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,attributes: null == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as PlayerAttributes,scoutGrade: null == scoutGrade ? _self.scoutGrade : scoutGrade // ignore: cast_nullable_to_non_nullable
as int,combineScore: null == combineScore ? _self.combineScore : combineScore // ignore: cast_nullable_to_non_nullable
as int,potentialStars: null == potentialStars ? _self.potentialStars : potentialStars // ignore: cast_nullable_to_non_nullable
as double,heightCm: null == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as int,injuryProne: null == injuryProne ? _self.injuryProne : injuryProne // ignore: cast_nullable_to_non_nullable
as int,determination: null == determination ? _self.determination : determination // ignore: cast_nullable_to_non_nullable
as int,personality: null == personality ? _self.personality : personality // ignore: cast_nullable_to_non_nullable
as PlayerPersonality,optimalRole: null == optimalRole ? _self.optimalRole : optimalRole // ignore: cast_nullable_to_non_nullable
as AssignedRole,
  ));
}

/// Create a copy of Prospect
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerAttributesCopyWith<$Res> get attributes {
  
  return $PlayerAttributesCopyWith<$Res>(_self.attributes, (value) {
    return _then(_self.copyWith(attributes: value));
  });
}/// Create a copy of Prospect
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


/// @nodoc
mixin _$DraftClass {

 int get year; List<Prospect> get prospects;
/// Create a copy of DraftClass
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftClassCopyWith<DraftClass> get copyWith => _$DraftClassCopyWithImpl<DraftClass>(this as DraftClass, _$identity);

  /// Serializes this DraftClass to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DraftClass&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other.prospects, prospects));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,const DeepCollectionEquality().hash(prospects));

@override
String toString() {
  return 'DraftClass(year: $year, prospects: $prospects)';
}


}

/// @nodoc
abstract mixin class $DraftClassCopyWith<$Res>  {
  factory $DraftClassCopyWith(DraftClass value, $Res Function(DraftClass) _then) = _$DraftClassCopyWithImpl;
@useResult
$Res call({
 int year, List<Prospect> prospects
});




}
/// @nodoc
class _$DraftClassCopyWithImpl<$Res>
    implements $DraftClassCopyWith<$Res> {
  _$DraftClassCopyWithImpl(this._self, this._then);

  final DraftClass _self;
  final $Res Function(DraftClass) _then;

/// Create a copy of DraftClass
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? prospects = null,}) {
  return _then(_self.copyWith(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,prospects: null == prospects ? _self.prospects : prospects // ignore: cast_nullable_to_non_nullable
as List<Prospect>,
  ));
}

}


/// Adds pattern-matching-related methods to [DraftClass].
extension DraftClassPatterns on DraftClass {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DraftClass value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DraftClass() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DraftClass value)  $default,){
final _that = this;
switch (_that) {
case _DraftClass():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DraftClass value)?  $default,){
final _that = this;
switch (_that) {
case _DraftClass() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  List<Prospect> prospects)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DraftClass() when $default != null:
return $default(_that.year,_that.prospects);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  List<Prospect> prospects)  $default,) {final _that = this;
switch (_that) {
case _DraftClass():
return $default(_that.year,_that.prospects);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  List<Prospect> prospects)?  $default,) {final _that = this;
switch (_that) {
case _DraftClass() when $default != null:
return $default(_that.year,_that.prospects);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DraftClass implements DraftClass {
  const _DraftClass({required this.year, final  List<Prospect> prospects = const []}): _prospects = prospects;
  factory _DraftClass.fromJson(Map<String, dynamic> json) => _$DraftClassFromJson(json);

@override final  int year;
 final  List<Prospect> _prospects;
@override@JsonKey() List<Prospect> get prospects {
  if (_prospects is EqualUnmodifiableListView) return _prospects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_prospects);
}


/// Create a copy of DraftClass
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftClassCopyWith<_DraftClass> get copyWith => __$DraftClassCopyWithImpl<_DraftClass>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DraftClassToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DraftClass&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other._prospects, _prospects));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,const DeepCollectionEquality().hash(_prospects));

@override
String toString() {
  return 'DraftClass(year: $year, prospects: $prospects)';
}


}

/// @nodoc
abstract mixin class _$DraftClassCopyWith<$Res> implements $DraftClassCopyWith<$Res> {
  factory _$DraftClassCopyWith(_DraftClass value, $Res Function(_DraftClass) _then) = __$DraftClassCopyWithImpl;
@override @useResult
$Res call({
 int year, List<Prospect> prospects
});




}
/// @nodoc
class __$DraftClassCopyWithImpl<$Res>
    implements _$DraftClassCopyWith<$Res> {
  __$DraftClassCopyWithImpl(this._self, this._then);

  final _DraftClass _self;
  final $Res Function(_DraftClass) _then;

/// Create a copy of DraftClass
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? prospects = null,}) {
  return _then(_DraftClass(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,prospects: null == prospects ? _self._prospects : prospects // ignore: cast_nullable_to_non_nullable
as List<Prospect>,
  ));
}


}


/// @nodoc
mixin _$DraftState {

 int get year; List<DraftPick> get order; List<DraftPick> get completedPicks; List<LotteryResult> get lotteryResults; DraftClass get draftClass; int get currentPickIndex;
/// Create a copy of DraftState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftStateCopyWith<DraftState> get copyWith => _$DraftStateCopyWithImpl<DraftState>(this as DraftState, _$identity);

  /// Serializes this DraftState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DraftState&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other.order, order)&&const DeepCollectionEquality().equals(other.completedPicks, completedPicks)&&const DeepCollectionEquality().equals(other.lotteryResults, lotteryResults)&&(identical(other.draftClass, draftClass) || other.draftClass == draftClass)&&(identical(other.currentPickIndex, currentPickIndex) || other.currentPickIndex == currentPickIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,const DeepCollectionEquality().hash(order),const DeepCollectionEquality().hash(completedPicks),const DeepCollectionEquality().hash(lotteryResults),draftClass,currentPickIndex);

@override
String toString() {
  return 'DraftState(year: $year, order: $order, completedPicks: $completedPicks, lotteryResults: $lotteryResults, draftClass: $draftClass, currentPickIndex: $currentPickIndex)';
}


}

/// @nodoc
abstract mixin class $DraftStateCopyWith<$Res>  {
  factory $DraftStateCopyWith(DraftState value, $Res Function(DraftState) _then) = _$DraftStateCopyWithImpl;
@useResult
$Res call({
 int year, List<DraftPick> order, List<DraftPick> completedPicks, List<LotteryResult> lotteryResults, DraftClass draftClass, int currentPickIndex
});


$DraftClassCopyWith<$Res> get draftClass;

}
/// @nodoc
class _$DraftStateCopyWithImpl<$Res>
    implements $DraftStateCopyWith<$Res> {
  _$DraftStateCopyWithImpl(this._self, this._then);

  final DraftState _self;
  final $Res Function(DraftState) _then;

/// Create a copy of DraftState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? order = null,Object? completedPicks = null,Object? lotteryResults = null,Object? draftClass = null,Object? currentPickIndex = null,}) {
  return _then(_self.copyWith(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as List<DraftPick>,completedPicks: null == completedPicks ? _self.completedPicks : completedPicks // ignore: cast_nullable_to_non_nullable
as List<DraftPick>,lotteryResults: null == lotteryResults ? _self.lotteryResults : lotteryResults // ignore: cast_nullable_to_non_nullable
as List<LotteryResult>,draftClass: null == draftClass ? _self.draftClass : draftClass // ignore: cast_nullable_to_non_nullable
as DraftClass,currentPickIndex: null == currentPickIndex ? _self.currentPickIndex : currentPickIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of DraftState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DraftClassCopyWith<$Res> get draftClass {
  
  return $DraftClassCopyWith<$Res>(_self.draftClass, (value) {
    return _then(_self.copyWith(draftClass: value));
  });
}
}


/// Adds pattern-matching-related methods to [DraftState].
extension DraftStatePatterns on DraftState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DraftState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DraftState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DraftState value)  $default,){
final _that = this;
switch (_that) {
case _DraftState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DraftState value)?  $default,){
final _that = this;
switch (_that) {
case _DraftState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  List<DraftPick> order,  List<DraftPick> completedPicks,  List<LotteryResult> lotteryResults,  DraftClass draftClass,  int currentPickIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DraftState() when $default != null:
return $default(_that.year,_that.order,_that.completedPicks,_that.lotteryResults,_that.draftClass,_that.currentPickIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  List<DraftPick> order,  List<DraftPick> completedPicks,  List<LotteryResult> lotteryResults,  DraftClass draftClass,  int currentPickIndex)  $default,) {final _that = this;
switch (_that) {
case _DraftState():
return $default(_that.year,_that.order,_that.completedPicks,_that.lotteryResults,_that.draftClass,_that.currentPickIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  List<DraftPick> order,  List<DraftPick> completedPicks,  List<LotteryResult> lotteryResults,  DraftClass draftClass,  int currentPickIndex)?  $default,) {final _that = this;
switch (_that) {
case _DraftState() when $default != null:
return $default(_that.year,_that.order,_that.completedPicks,_that.lotteryResults,_that.draftClass,_that.currentPickIndex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DraftState implements DraftState {
  const _DraftState({required this.year, final  List<DraftPick> order = const [], final  List<DraftPick> completedPicks = const [], final  List<LotteryResult> lotteryResults = const [], required this.draftClass, this.currentPickIndex = 0}): _order = order,_completedPicks = completedPicks,_lotteryResults = lotteryResults;
  factory _DraftState.fromJson(Map<String, dynamic> json) => _$DraftStateFromJson(json);

@override final  int year;
 final  List<DraftPick> _order;
@override@JsonKey() List<DraftPick> get order {
  if (_order is EqualUnmodifiableListView) return _order;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_order);
}

 final  List<DraftPick> _completedPicks;
@override@JsonKey() List<DraftPick> get completedPicks {
  if (_completedPicks is EqualUnmodifiableListView) return _completedPicks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_completedPicks);
}

 final  List<LotteryResult> _lotteryResults;
@override@JsonKey() List<LotteryResult> get lotteryResults {
  if (_lotteryResults is EqualUnmodifiableListView) return _lotteryResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lotteryResults);
}

@override final  DraftClass draftClass;
@override@JsonKey() final  int currentPickIndex;

/// Create a copy of DraftState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftStateCopyWith<_DraftState> get copyWith => __$DraftStateCopyWithImpl<_DraftState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DraftStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DraftState&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other._order, _order)&&const DeepCollectionEquality().equals(other._completedPicks, _completedPicks)&&const DeepCollectionEquality().equals(other._lotteryResults, _lotteryResults)&&(identical(other.draftClass, draftClass) || other.draftClass == draftClass)&&(identical(other.currentPickIndex, currentPickIndex) || other.currentPickIndex == currentPickIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,const DeepCollectionEquality().hash(_order),const DeepCollectionEquality().hash(_completedPicks),const DeepCollectionEquality().hash(_lotteryResults),draftClass,currentPickIndex);

@override
String toString() {
  return 'DraftState(year: $year, order: $order, completedPicks: $completedPicks, lotteryResults: $lotteryResults, draftClass: $draftClass, currentPickIndex: $currentPickIndex)';
}


}

/// @nodoc
abstract mixin class _$DraftStateCopyWith<$Res> implements $DraftStateCopyWith<$Res> {
  factory _$DraftStateCopyWith(_DraftState value, $Res Function(_DraftState) _then) = __$DraftStateCopyWithImpl;
@override @useResult
$Res call({
 int year, List<DraftPick> order, List<DraftPick> completedPicks, List<LotteryResult> lotteryResults, DraftClass draftClass, int currentPickIndex
});


@override $DraftClassCopyWith<$Res> get draftClass;

}
/// @nodoc
class __$DraftStateCopyWithImpl<$Res>
    implements _$DraftStateCopyWith<$Res> {
  __$DraftStateCopyWithImpl(this._self, this._then);

  final _DraftState _self;
  final $Res Function(_DraftState) _then;

/// Create a copy of DraftState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? order = null,Object? completedPicks = null,Object? lotteryResults = null,Object? draftClass = null,Object? currentPickIndex = null,}) {
  return _then(_DraftState(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,order: null == order ? _self._order : order // ignore: cast_nullable_to_non_nullable
as List<DraftPick>,completedPicks: null == completedPicks ? _self._completedPicks : completedPicks // ignore: cast_nullable_to_non_nullable
as List<DraftPick>,lotteryResults: null == lotteryResults ? _self._lotteryResults : lotteryResults // ignore: cast_nullable_to_non_nullable
as List<LotteryResult>,draftClass: null == draftClass ? _self.draftClass : draftClass // ignore: cast_nullable_to_non_nullable
as DraftClass,currentPickIndex: null == currentPickIndex ? _self.currentPickIndex : currentPickIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of DraftState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DraftClassCopyWith<$Res> get draftClass {
  
  return $DraftClassCopyWith<$Res>(_self.draftClass, (value) {
    return _then(_self.copyWith(draftClass: value));
  });
}
}


/// @nodoc
mixin _$PlayInResult {

 Conference get conference; String get seed7TeamId; String get seed8TeamId; MatchResult get game7v8; MatchResult get game9v10; MatchResult get gameFinal; String get playoffSeed7TeamId; String get playoffSeed8TeamId;
/// Create a copy of PlayInResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayInResultCopyWith<PlayInResult> get copyWith => _$PlayInResultCopyWithImpl<PlayInResult>(this as PlayInResult, _$identity);

  /// Serializes this PlayInResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayInResult&&(identical(other.conference, conference) || other.conference == conference)&&(identical(other.seed7TeamId, seed7TeamId) || other.seed7TeamId == seed7TeamId)&&(identical(other.seed8TeamId, seed8TeamId) || other.seed8TeamId == seed8TeamId)&&(identical(other.game7v8, game7v8) || other.game7v8 == game7v8)&&(identical(other.game9v10, game9v10) || other.game9v10 == game9v10)&&(identical(other.gameFinal, gameFinal) || other.gameFinal == gameFinal)&&(identical(other.playoffSeed7TeamId, playoffSeed7TeamId) || other.playoffSeed7TeamId == playoffSeed7TeamId)&&(identical(other.playoffSeed8TeamId, playoffSeed8TeamId) || other.playoffSeed8TeamId == playoffSeed8TeamId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conference,seed7TeamId,seed8TeamId,game7v8,game9v10,gameFinal,playoffSeed7TeamId,playoffSeed8TeamId);

@override
String toString() {
  return 'PlayInResult(conference: $conference, seed7TeamId: $seed7TeamId, seed8TeamId: $seed8TeamId, game7v8: $game7v8, game9v10: $game9v10, gameFinal: $gameFinal, playoffSeed7TeamId: $playoffSeed7TeamId, playoffSeed8TeamId: $playoffSeed8TeamId)';
}


}

/// @nodoc
abstract mixin class $PlayInResultCopyWith<$Res>  {
  factory $PlayInResultCopyWith(PlayInResult value, $Res Function(PlayInResult) _then) = _$PlayInResultCopyWithImpl;
@useResult
$Res call({
 Conference conference, String seed7TeamId, String seed8TeamId, MatchResult game7v8, MatchResult game9v10, MatchResult gameFinal, String playoffSeed7TeamId, String playoffSeed8TeamId
});


$MatchResultCopyWith<$Res> get game7v8;$MatchResultCopyWith<$Res> get game9v10;$MatchResultCopyWith<$Res> get gameFinal;

}
/// @nodoc
class _$PlayInResultCopyWithImpl<$Res>
    implements $PlayInResultCopyWith<$Res> {
  _$PlayInResultCopyWithImpl(this._self, this._then);

  final PlayInResult _self;
  final $Res Function(PlayInResult) _then;

/// Create a copy of PlayInResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conference = null,Object? seed7TeamId = null,Object? seed8TeamId = null,Object? game7v8 = null,Object? game9v10 = null,Object? gameFinal = null,Object? playoffSeed7TeamId = null,Object? playoffSeed8TeamId = null,}) {
  return _then(_self.copyWith(
conference: null == conference ? _self.conference : conference // ignore: cast_nullable_to_non_nullable
as Conference,seed7TeamId: null == seed7TeamId ? _self.seed7TeamId : seed7TeamId // ignore: cast_nullable_to_non_nullable
as String,seed8TeamId: null == seed8TeamId ? _self.seed8TeamId : seed8TeamId // ignore: cast_nullable_to_non_nullable
as String,game7v8: null == game7v8 ? _self.game7v8 : game7v8 // ignore: cast_nullable_to_non_nullable
as MatchResult,game9v10: null == game9v10 ? _self.game9v10 : game9v10 // ignore: cast_nullable_to_non_nullable
as MatchResult,gameFinal: null == gameFinal ? _self.gameFinal : gameFinal // ignore: cast_nullable_to_non_nullable
as MatchResult,playoffSeed7TeamId: null == playoffSeed7TeamId ? _self.playoffSeed7TeamId : playoffSeed7TeamId // ignore: cast_nullable_to_non_nullable
as String,playoffSeed8TeamId: null == playoffSeed8TeamId ? _self.playoffSeed8TeamId : playoffSeed8TeamId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of PlayInResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res> get game7v8 {
  
  return $MatchResultCopyWith<$Res>(_self.game7v8, (value) {
    return _then(_self.copyWith(game7v8: value));
  });
}/// Create a copy of PlayInResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res> get game9v10 {
  
  return $MatchResultCopyWith<$Res>(_self.game9v10, (value) {
    return _then(_self.copyWith(game9v10: value));
  });
}/// Create a copy of PlayInResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res> get gameFinal {
  
  return $MatchResultCopyWith<$Res>(_self.gameFinal, (value) {
    return _then(_self.copyWith(gameFinal: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayInResult].
extension PlayInResultPatterns on PlayInResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayInResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayInResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayInResult value)  $default,){
final _that = this;
switch (_that) {
case _PlayInResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayInResult value)?  $default,){
final _that = this;
switch (_that) {
case _PlayInResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Conference conference,  String seed7TeamId,  String seed8TeamId,  MatchResult game7v8,  MatchResult game9v10,  MatchResult gameFinal,  String playoffSeed7TeamId,  String playoffSeed8TeamId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayInResult() when $default != null:
return $default(_that.conference,_that.seed7TeamId,_that.seed8TeamId,_that.game7v8,_that.game9v10,_that.gameFinal,_that.playoffSeed7TeamId,_that.playoffSeed8TeamId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Conference conference,  String seed7TeamId,  String seed8TeamId,  MatchResult game7v8,  MatchResult game9v10,  MatchResult gameFinal,  String playoffSeed7TeamId,  String playoffSeed8TeamId)  $default,) {final _that = this;
switch (_that) {
case _PlayInResult():
return $default(_that.conference,_that.seed7TeamId,_that.seed8TeamId,_that.game7v8,_that.game9v10,_that.gameFinal,_that.playoffSeed7TeamId,_that.playoffSeed8TeamId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Conference conference,  String seed7TeamId,  String seed8TeamId,  MatchResult game7v8,  MatchResult game9v10,  MatchResult gameFinal,  String playoffSeed7TeamId,  String playoffSeed8TeamId)?  $default,) {final _that = this;
switch (_that) {
case _PlayInResult() when $default != null:
return $default(_that.conference,_that.seed7TeamId,_that.seed8TeamId,_that.game7v8,_that.game9v10,_that.gameFinal,_that.playoffSeed7TeamId,_that.playoffSeed8TeamId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayInResult implements PlayInResult {
  const _PlayInResult({required this.conference, required this.seed7TeamId, required this.seed8TeamId, required this.game7v8, required this.game9v10, required this.gameFinal, required this.playoffSeed7TeamId, required this.playoffSeed8TeamId});
  factory _PlayInResult.fromJson(Map<String, dynamic> json) => _$PlayInResultFromJson(json);

@override final  Conference conference;
@override final  String seed7TeamId;
@override final  String seed8TeamId;
@override final  MatchResult game7v8;
@override final  MatchResult game9v10;
@override final  MatchResult gameFinal;
@override final  String playoffSeed7TeamId;
@override final  String playoffSeed8TeamId;

/// Create a copy of PlayInResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayInResultCopyWith<_PlayInResult> get copyWith => __$PlayInResultCopyWithImpl<_PlayInResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayInResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayInResult&&(identical(other.conference, conference) || other.conference == conference)&&(identical(other.seed7TeamId, seed7TeamId) || other.seed7TeamId == seed7TeamId)&&(identical(other.seed8TeamId, seed8TeamId) || other.seed8TeamId == seed8TeamId)&&(identical(other.game7v8, game7v8) || other.game7v8 == game7v8)&&(identical(other.game9v10, game9v10) || other.game9v10 == game9v10)&&(identical(other.gameFinal, gameFinal) || other.gameFinal == gameFinal)&&(identical(other.playoffSeed7TeamId, playoffSeed7TeamId) || other.playoffSeed7TeamId == playoffSeed7TeamId)&&(identical(other.playoffSeed8TeamId, playoffSeed8TeamId) || other.playoffSeed8TeamId == playoffSeed8TeamId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conference,seed7TeamId,seed8TeamId,game7v8,game9v10,gameFinal,playoffSeed7TeamId,playoffSeed8TeamId);

@override
String toString() {
  return 'PlayInResult(conference: $conference, seed7TeamId: $seed7TeamId, seed8TeamId: $seed8TeamId, game7v8: $game7v8, game9v10: $game9v10, gameFinal: $gameFinal, playoffSeed7TeamId: $playoffSeed7TeamId, playoffSeed8TeamId: $playoffSeed8TeamId)';
}


}

/// @nodoc
abstract mixin class _$PlayInResultCopyWith<$Res> implements $PlayInResultCopyWith<$Res> {
  factory _$PlayInResultCopyWith(_PlayInResult value, $Res Function(_PlayInResult) _then) = __$PlayInResultCopyWithImpl;
@override @useResult
$Res call({
 Conference conference, String seed7TeamId, String seed8TeamId, MatchResult game7v8, MatchResult game9v10, MatchResult gameFinal, String playoffSeed7TeamId, String playoffSeed8TeamId
});


@override $MatchResultCopyWith<$Res> get game7v8;@override $MatchResultCopyWith<$Res> get game9v10;@override $MatchResultCopyWith<$Res> get gameFinal;

}
/// @nodoc
class __$PlayInResultCopyWithImpl<$Res>
    implements _$PlayInResultCopyWith<$Res> {
  __$PlayInResultCopyWithImpl(this._self, this._then);

  final _PlayInResult _self;
  final $Res Function(_PlayInResult) _then;

/// Create a copy of PlayInResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conference = null,Object? seed7TeamId = null,Object? seed8TeamId = null,Object? game7v8 = null,Object? game9v10 = null,Object? gameFinal = null,Object? playoffSeed7TeamId = null,Object? playoffSeed8TeamId = null,}) {
  return _then(_PlayInResult(
conference: null == conference ? _self.conference : conference // ignore: cast_nullable_to_non_nullable
as Conference,seed7TeamId: null == seed7TeamId ? _self.seed7TeamId : seed7TeamId // ignore: cast_nullable_to_non_nullable
as String,seed8TeamId: null == seed8TeamId ? _self.seed8TeamId : seed8TeamId // ignore: cast_nullable_to_non_nullable
as String,game7v8: null == game7v8 ? _self.game7v8 : game7v8 // ignore: cast_nullable_to_non_nullable
as MatchResult,game9v10: null == game9v10 ? _self.game9v10 : game9v10 // ignore: cast_nullable_to_non_nullable
as MatchResult,gameFinal: null == gameFinal ? _self.gameFinal : gameFinal // ignore: cast_nullable_to_non_nullable
as MatchResult,playoffSeed7TeamId: null == playoffSeed7TeamId ? _self.playoffSeed7TeamId : playoffSeed7TeamId // ignore: cast_nullable_to_non_nullable
as String,playoffSeed8TeamId: null == playoffSeed8TeamId ? _self.playoffSeed8TeamId : playoffSeed8TeamId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of PlayInResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res> get game7v8 {
  
  return $MatchResultCopyWith<$Res>(_self.game7v8, (value) {
    return _then(_self.copyWith(game7v8: value));
  });
}/// Create a copy of PlayInResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res> get game9v10 {
  
  return $MatchResultCopyWith<$Res>(_self.game9v10, (value) {
    return _then(_self.copyWith(game9v10: value));
  });
}/// Create a copy of PlayInResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res> get gameFinal {
  
  return $MatchResultCopyWith<$Res>(_self.gameFinal, (value) {
    return _then(_self.copyWith(gameFinal: value));
  });
}
}


/// @nodoc
mixin _$PlayInProgress {

 Conference get conference; String get seed7TeamId; String get seed8TeamId; String get seed9TeamId; String get seed10TeamId; MatchResult? get game7v8; MatchResult? get game9v10; MatchResult? get gameFinal;
/// Create a copy of PlayInProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayInProgressCopyWith<PlayInProgress> get copyWith => _$PlayInProgressCopyWithImpl<PlayInProgress>(this as PlayInProgress, _$identity);

  /// Serializes this PlayInProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayInProgress&&(identical(other.conference, conference) || other.conference == conference)&&(identical(other.seed7TeamId, seed7TeamId) || other.seed7TeamId == seed7TeamId)&&(identical(other.seed8TeamId, seed8TeamId) || other.seed8TeamId == seed8TeamId)&&(identical(other.seed9TeamId, seed9TeamId) || other.seed9TeamId == seed9TeamId)&&(identical(other.seed10TeamId, seed10TeamId) || other.seed10TeamId == seed10TeamId)&&(identical(other.game7v8, game7v8) || other.game7v8 == game7v8)&&(identical(other.game9v10, game9v10) || other.game9v10 == game9v10)&&(identical(other.gameFinal, gameFinal) || other.gameFinal == gameFinal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conference,seed7TeamId,seed8TeamId,seed9TeamId,seed10TeamId,game7v8,game9v10,gameFinal);

@override
String toString() {
  return 'PlayInProgress(conference: $conference, seed7TeamId: $seed7TeamId, seed8TeamId: $seed8TeamId, seed9TeamId: $seed9TeamId, seed10TeamId: $seed10TeamId, game7v8: $game7v8, game9v10: $game9v10, gameFinal: $gameFinal)';
}


}

/// @nodoc
abstract mixin class $PlayInProgressCopyWith<$Res>  {
  factory $PlayInProgressCopyWith(PlayInProgress value, $Res Function(PlayInProgress) _then) = _$PlayInProgressCopyWithImpl;
@useResult
$Res call({
 Conference conference, String seed7TeamId, String seed8TeamId, String seed9TeamId, String seed10TeamId, MatchResult? game7v8, MatchResult? game9v10, MatchResult? gameFinal
});


$MatchResultCopyWith<$Res>? get game7v8;$MatchResultCopyWith<$Res>? get game9v10;$MatchResultCopyWith<$Res>? get gameFinal;

}
/// @nodoc
class _$PlayInProgressCopyWithImpl<$Res>
    implements $PlayInProgressCopyWith<$Res> {
  _$PlayInProgressCopyWithImpl(this._self, this._then);

  final PlayInProgress _self;
  final $Res Function(PlayInProgress) _then;

/// Create a copy of PlayInProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conference = null,Object? seed7TeamId = null,Object? seed8TeamId = null,Object? seed9TeamId = null,Object? seed10TeamId = null,Object? game7v8 = freezed,Object? game9v10 = freezed,Object? gameFinal = freezed,}) {
  return _then(_self.copyWith(
conference: null == conference ? _self.conference : conference // ignore: cast_nullable_to_non_nullable
as Conference,seed7TeamId: null == seed7TeamId ? _self.seed7TeamId : seed7TeamId // ignore: cast_nullable_to_non_nullable
as String,seed8TeamId: null == seed8TeamId ? _self.seed8TeamId : seed8TeamId // ignore: cast_nullable_to_non_nullable
as String,seed9TeamId: null == seed9TeamId ? _self.seed9TeamId : seed9TeamId // ignore: cast_nullable_to_non_nullable
as String,seed10TeamId: null == seed10TeamId ? _self.seed10TeamId : seed10TeamId // ignore: cast_nullable_to_non_nullable
as String,game7v8: freezed == game7v8 ? _self.game7v8 : game7v8 // ignore: cast_nullable_to_non_nullable
as MatchResult?,game9v10: freezed == game9v10 ? _self.game9v10 : game9v10 // ignore: cast_nullable_to_non_nullable
as MatchResult?,gameFinal: freezed == gameFinal ? _self.gameFinal : gameFinal // ignore: cast_nullable_to_non_nullable
as MatchResult?,
  ));
}
/// Create a copy of PlayInProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res>? get game7v8 {
    if (_self.game7v8 == null) {
    return null;
  }

  return $MatchResultCopyWith<$Res>(_self.game7v8!, (value) {
    return _then(_self.copyWith(game7v8: value));
  });
}/// Create a copy of PlayInProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res>? get game9v10 {
    if (_self.game9v10 == null) {
    return null;
  }

  return $MatchResultCopyWith<$Res>(_self.game9v10!, (value) {
    return _then(_self.copyWith(game9v10: value));
  });
}/// Create a copy of PlayInProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res>? get gameFinal {
    if (_self.gameFinal == null) {
    return null;
  }

  return $MatchResultCopyWith<$Res>(_self.gameFinal!, (value) {
    return _then(_self.copyWith(gameFinal: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayInProgress].
extension PlayInProgressPatterns on PlayInProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayInProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayInProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayInProgress value)  $default,){
final _that = this;
switch (_that) {
case _PlayInProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayInProgress value)?  $default,){
final _that = this;
switch (_that) {
case _PlayInProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Conference conference,  String seed7TeamId,  String seed8TeamId,  String seed9TeamId,  String seed10TeamId,  MatchResult? game7v8,  MatchResult? game9v10,  MatchResult? gameFinal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayInProgress() when $default != null:
return $default(_that.conference,_that.seed7TeamId,_that.seed8TeamId,_that.seed9TeamId,_that.seed10TeamId,_that.game7v8,_that.game9v10,_that.gameFinal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Conference conference,  String seed7TeamId,  String seed8TeamId,  String seed9TeamId,  String seed10TeamId,  MatchResult? game7v8,  MatchResult? game9v10,  MatchResult? gameFinal)  $default,) {final _that = this;
switch (_that) {
case _PlayInProgress():
return $default(_that.conference,_that.seed7TeamId,_that.seed8TeamId,_that.seed9TeamId,_that.seed10TeamId,_that.game7v8,_that.game9v10,_that.gameFinal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Conference conference,  String seed7TeamId,  String seed8TeamId,  String seed9TeamId,  String seed10TeamId,  MatchResult? game7v8,  MatchResult? game9v10,  MatchResult? gameFinal)?  $default,) {final _that = this;
switch (_that) {
case _PlayInProgress() when $default != null:
return $default(_that.conference,_that.seed7TeamId,_that.seed8TeamId,_that.seed9TeamId,_that.seed10TeamId,_that.game7v8,_that.game9v10,_that.gameFinal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayInProgress implements PlayInProgress {
  const _PlayInProgress({required this.conference, required this.seed7TeamId, required this.seed8TeamId, required this.seed9TeamId, required this.seed10TeamId, this.game7v8, this.game9v10, this.gameFinal});
  factory _PlayInProgress.fromJson(Map<String, dynamic> json) => _$PlayInProgressFromJson(json);

@override final  Conference conference;
@override final  String seed7TeamId;
@override final  String seed8TeamId;
@override final  String seed9TeamId;
@override final  String seed10TeamId;
@override final  MatchResult? game7v8;
@override final  MatchResult? game9v10;
@override final  MatchResult? gameFinal;

/// Create a copy of PlayInProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayInProgressCopyWith<_PlayInProgress> get copyWith => __$PlayInProgressCopyWithImpl<_PlayInProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayInProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayInProgress&&(identical(other.conference, conference) || other.conference == conference)&&(identical(other.seed7TeamId, seed7TeamId) || other.seed7TeamId == seed7TeamId)&&(identical(other.seed8TeamId, seed8TeamId) || other.seed8TeamId == seed8TeamId)&&(identical(other.seed9TeamId, seed9TeamId) || other.seed9TeamId == seed9TeamId)&&(identical(other.seed10TeamId, seed10TeamId) || other.seed10TeamId == seed10TeamId)&&(identical(other.game7v8, game7v8) || other.game7v8 == game7v8)&&(identical(other.game9v10, game9v10) || other.game9v10 == game9v10)&&(identical(other.gameFinal, gameFinal) || other.gameFinal == gameFinal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conference,seed7TeamId,seed8TeamId,seed9TeamId,seed10TeamId,game7v8,game9v10,gameFinal);

@override
String toString() {
  return 'PlayInProgress(conference: $conference, seed7TeamId: $seed7TeamId, seed8TeamId: $seed8TeamId, seed9TeamId: $seed9TeamId, seed10TeamId: $seed10TeamId, game7v8: $game7v8, game9v10: $game9v10, gameFinal: $gameFinal)';
}


}

/// @nodoc
abstract mixin class _$PlayInProgressCopyWith<$Res> implements $PlayInProgressCopyWith<$Res> {
  factory _$PlayInProgressCopyWith(_PlayInProgress value, $Res Function(_PlayInProgress) _then) = __$PlayInProgressCopyWithImpl;
@override @useResult
$Res call({
 Conference conference, String seed7TeamId, String seed8TeamId, String seed9TeamId, String seed10TeamId, MatchResult? game7v8, MatchResult? game9v10, MatchResult? gameFinal
});


@override $MatchResultCopyWith<$Res>? get game7v8;@override $MatchResultCopyWith<$Res>? get game9v10;@override $MatchResultCopyWith<$Res>? get gameFinal;

}
/// @nodoc
class __$PlayInProgressCopyWithImpl<$Res>
    implements _$PlayInProgressCopyWith<$Res> {
  __$PlayInProgressCopyWithImpl(this._self, this._then);

  final _PlayInProgress _self;
  final $Res Function(_PlayInProgress) _then;

/// Create a copy of PlayInProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conference = null,Object? seed7TeamId = null,Object? seed8TeamId = null,Object? seed9TeamId = null,Object? seed10TeamId = null,Object? game7v8 = freezed,Object? game9v10 = freezed,Object? gameFinal = freezed,}) {
  return _then(_PlayInProgress(
conference: null == conference ? _self.conference : conference // ignore: cast_nullable_to_non_nullable
as Conference,seed7TeamId: null == seed7TeamId ? _self.seed7TeamId : seed7TeamId // ignore: cast_nullable_to_non_nullable
as String,seed8TeamId: null == seed8TeamId ? _self.seed8TeamId : seed8TeamId // ignore: cast_nullable_to_non_nullable
as String,seed9TeamId: null == seed9TeamId ? _self.seed9TeamId : seed9TeamId // ignore: cast_nullable_to_non_nullable
as String,seed10TeamId: null == seed10TeamId ? _self.seed10TeamId : seed10TeamId // ignore: cast_nullable_to_non_nullable
as String,game7v8: freezed == game7v8 ? _self.game7v8 : game7v8 // ignore: cast_nullable_to_non_nullable
as MatchResult?,game9v10: freezed == game9v10 ? _self.game9v10 : game9v10 // ignore: cast_nullable_to_non_nullable
as MatchResult?,gameFinal: freezed == gameFinal ? _self.gameFinal : gameFinal // ignore: cast_nullable_to_non_nullable
as MatchResult?,
  ));
}

/// Create a copy of PlayInProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res>? get game7v8 {
    if (_self.game7v8 == null) {
    return null;
  }

  return $MatchResultCopyWith<$Res>(_self.game7v8!, (value) {
    return _then(_self.copyWith(game7v8: value));
  });
}/// Create a copy of PlayInProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res>? get game9v10 {
    if (_self.game9v10 == null) {
    return null;
  }

  return $MatchResultCopyWith<$Res>(_self.game9v10!, (value) {
    return _then(_self.copyWith(game9v10: value));
  });
}/// Create a copy of PlayInProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res>? get gameFinal {
    if (_self.gameFinal == null) {
    return null;
  }

  return $MatchResultCopyWith<$Res>(_self.gameFinal!, (value) {
    return _then(_self.copyWith(gameFinal: value));
  });
}
}


/// @nodoc
mixin _$PlayoffBracket {

 Conference get conference; List<PlayoffSeries> get quarterFinals; List<PlayoffSeries> get semiFinals; List<PlayoffSeries> get conferenceFinal; PlayoffSeries? get leagueFinal;
/// Create a copy of PlayoffBracket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayoffBracketCopyWith<PlayoffBracket> get copyWith => _$PlayoffBracketCopyWithImpl<PlayoffBracket>(this as PlayoffBracket, _$identity);

  /// Serializes this PlayoffBracket to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayoffBracket&&(identical(other.conference, conference) || other.conference == conference)&&const DeepCollectionEquality().equals(other.quarterFinals, quarterFinals)&&const DeepCollectionEquality().equals(other.semiFinals, semiFinals)&&const DeepCollectionEquality().equals(other.conferenceFinal, conferenceFinal)&&(identical(other.leagueFinal, leagueFinal) || other.leagueFinal == leagueFinal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conference,const DeepCollectionEquality().hash(quarterFinals),const DeepCollectionEquality().hash(semiFinals),const DeepCollectionEquality().hash(conferenceFinal),leagueFinal);

@override
String toString() {
  return 'PlayoffBracket(conference: $conference, quarterFinals: $quarterFinals, semiFinals: $semiFinals, conferenceFinal: $conferenceFinal, leagueFinal: $leagueFinal)';
}


}

/// @nodoc
abstract mixin class $PlayoffBracketCopyWith<$Res>  {
  factory $PlayoffBracketCopyWith(PlayoffBracket value, $Res Function(PlayoffBracket) _then) = _$PlayoffBracketCopyWithImpl;
@useResult
$Res call({
 Conference conference, List<PlayoffSeries> quarterFinals, List<PlayoffSeries> semiFinals, List<PlayoffSeries> conferenceFinal, PlayoffSeries? leagueFinal
});


$PlayoffSeriesCopyWith<$Res>? get leagueFinal;

}
/// @nodoc
class _$PlayoffBracketCopyWithImpl<$Res>
    implements $PlayoffBracketCopyWith<$Res> {
  _$PlayoffBracketCopyWithImpl(this._self, this._then);

  final PlayoffBracket _self;
  final $Res Function(PlayoffBracket) _then;

/// Create a copy of PlayoffBracket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conference = null,Object? quarterFinals = null,Object? semiFinals = null,Object? conferenceFinal = null,Object? leagueFinal = freezed,}) {
  return _then(_self.copyWith(
conference: null == conference ? _self.conference : conference // ignore: cast_nullable_to_non_nullable
as Conference,quarterFinals: null == quarterFinals ? _self.quarterFinals : quarterFinals // ignore: cast_nullable_to_non_nullable
as List<PlayoffSeries>,semiFinals: null == semiFinals ? _self.semiFinals : semiFinals // ignore: cast_nullable_to_non_nullable
as List<PlayoffSeries>,conferenceFinal: null == conferenceFinal ? _self.conferenceFinal : conferenceFinal // ignore: cast_nullable_to_non_nullable
as List<PlayoffSeries>,leagueFinal: freezed == leagueFinal ? _self.leagueFinal : leagueFinal // ignore: cast_nullable_to_non_nullable
as PlayoffSeries?,
  ));
}
/// Create a copy of PlayoffBracket
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayoffSeriesCopyWith<$Res>? get leagueFinal {
    if (_self.leagueFinal == null) {
    return null;
  }

  return $PlayoffSeriesCopyWith<$Res>(_self.leagueFinal!, (value) {
    return _then(_self.copyWith(leagueFinal: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayoffBracket].
extension PlayoffBracketPatterns on PlayoffBracket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayoffBracket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayoffBracket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayoffBracket value)  $default,){
final _that = this;
switch (_that) {
case _PlayoffBracket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayoffBracket value)?  $default,){
final _that = this;
switch (_that) {
case _PlayoffBracket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Conference conference,  List<PlayoffSeries> quarterFinals,  List<PlayoffSeries> semiFinals,  List<PlayoffSeries> conferenceFinal,  PlayoffSeries? leagueFinal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayoffBracket() when $default != null:
return $default(_that.conference,_that.quarterFinals,_that.semiFinals,_that.conferenceFinal,_that.leagueFinal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Conference conference,  List<PlayoffSeries> quarterFinals,  List<PlayoffSeries> semiFinals,  List<PlayoffSeries> conferenceFinal,  PlayoffSeries? leagueFinal)  $default,) {final _that = this;
switch (_that) {
case _PlayoffBracket():
return $default(_that.conference,_that.quarterFinals,_that.semiFinals,_that.conferenceFinal,_that.leagueFinal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Conference conference,  List<PlayoffSeries> quarterFinals,  List<PlayoffSeries> semiFinals,  List<PlayoffSeries> conferenceFinal,  PlayoffSeries? leagueFinal)?  $default,) {final _that = this;
switch (_that) {
case _PlayoffBracket() when $default != null:
return $default(_that.conference,_that.quarterFinals,_that.semiFinals,_that.conferenceFinal,_that.leagueFinal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayoffBracket implements PlayoffBracket {
  const _PlayoffBracket({required this.conference, final  List<PlayoffSeries> quarterFinals = const [], final  List<PlayoffSeries> semiFinals = const [], final  List<PlayoffSeries> conferenceFinal = const [], this.leagueFinal}): _quarterFinals = quarterFinals,_semiFinals = semiFinals,_conferenceFinal = conferenceFinal;
  factory _PlayoffBracket.fromJson(Map<String, dynamic> json) => _$PlayoffBracketFromJson(json);

@override final  Conference conference;
 final  List<PlayoffSeries> _quarterFinals;
@override@JsonKey() List<PlayoffSeries> get quarterFinals {
  if (_quarterFinals is EqualUnmodifiableListView) return _quarterFinals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_quarterFinals);
}

 final  List<PlayoffSeries> _semiFinals;
@override@JsonKey() List<PlayoffSeries> get semiFinals {
  if (_semiFinals is EqualUnmodifiableListView) return _semiFinals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_semiFinals);
}

 final  List<PlayoffSeries> _conferenceFinal;
@override@JsonKey() List<PlayoffSeries> get conferenceFinal {
  if (_conferenceFinal is EqualUnmodifiableListView) return _conferenceFinal;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conferenceFinal);
}

@override final  PlayoffSeries? leagueFinal;

/// Create a copy of PlayoffBracket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayoffBracketCopyWith<_PlayoffBracket> get copyWith => __$PlayoffBracketCopyWithImpl<_PlayoffBracket>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayoffBracketToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayoffBracket&&(identical(other.conference, conference) || other.conference == conference)&&const DeepCollectionEquality().equals(other._quarterFinals, _quarterFinals)&&const DeepCollectionEquality().equals(other._semiFinals, _semiFinals)&&const DeepCollectionEquality().equals(other._conferenceFinal, _conferenceFinal)&&(identical(other.leagueFinal, leagueFinal) || other.leagueFinal == leagueFinal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conference,const DeepCollectionEquality().hash(_quarterFinals),const DeepCollectionEquality().hash(_semiFinals),const DeepCollectionEquality().hash(_conferenceFinal),leagueFinal);

@override
String toString() {
  return 'PlayoffBracket(conference: $conference, quarterFinals: $quarterFinals, semiFinals: $semiFinals, conferenceFinal: $conferenceFinal, leagueFinal: $leagueFinal)';
}


}

/// @nodoc
abstract mixin class _$PlayoffBracketCopyWith<$Res> implements $PlayoffBracketCopyWith<$Res> {
  factory _$PlayoffBracketCopyWith(_PlayoffBracket value, $Res Function(_PlayoffBracket) _then) = __$PlayoffBracketCopyWithImpl;
@override @useResult
$Res call({
 Conference conference, List<PlayoffSeries> quarterFinals, List<PlayoffSeries> semiFinals, List<PlayoffSeries> conferenceFinal, PlayoffSeries? leagueFinal
});


@override $PlayoffSeriesCopyWith<$Res>? get leagueFinal;

}
/// @nodoc
class __$PlayoffBracketCopyWithImpl<$Res>
    implements _$PlayoffBracketCopyWith<$Res> {
  __$PlayoffBracketCopyWithImpl(this._self, this._then);

  final _PlayoffBracket _self;
  final $Res Function(_PlayoffBracket) _then;

/// Create a copy of PlayoffBracket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conference = null,Object? quarterFinals = null,Object? semiFinals = null,Object? conferenceFinal = null,Object? leagueFinal = freezed,}) {
  return _then(_PlayoffBracket(
conference: null == conference ? _self.conference : conference // ignore: cast_nullable_to_non_nullable
as Conference,quarterFinals: null == quarterFinals ? _self._quarterFinals : quarterFinals // ignore: cast_nullable_to_non_nullable
as List<PlayoffSeries>,semiFinals: null == semiFinals ? _self._semiFinals : semiFinals // ignore: cast_nullable_to_non_nullable
as List<PlayoffSeries>,conferenceFinal: null == conferenceFinal ? _self._conferenceFinal : conferenceFinal // ignore: cast_nullable_to_non_nullable
as List<PlayoffSeries>,leagueFinal: freezed == leagueFinal ? _self.leagueFinal : leagueFinal // ignore: cast_nullable_to_non_nullable
as PlayoffSeries?,
  ));
}

/// Create a copy of PlayoffBracket
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayoffSeriesCopyWith<$Res>? get leagueFinal {
    if (_self.leagueFinal == null) {
    return null;
  }

  return $PlayoffSeriesCopyWith<$Res>(_self.leagueFinal!, (value) {
    return _then(_self.copyWith(leagueFinal: value));
  });
}
}


/// @nodoc
mixin _$Season {

 int get year; SeasonPhase get phase; List<ScheduledMatch> get schedule; List<ConferenceStandings> get standings; List<PlayInResult> get playInResults; List<PlayInProgress> get playInProgress; List<PlayoffBracket> get playoffBrackets; String? get championTeamId; bool get championshipAtmosphereApplied; bool get playoffMissAtmosphereApplied; DraftState? get draftState; SeasonAwards? get awards; bool get staffGrowthDone; bool get playerRetirementsDone;/// Persisted TV agreement: the exact reset year and increase are known
/// before the event fires, so loading a save cannot reroll the cap.
 int get nextTvCapResetSeason; int get nextTvCapIncreasePct; bool get capUpdateTvDone; bool get combineDone; bool get finalMockDone; bool get faOpenDone; bool get scoutReportDone; bool get tradeDeadlineAcked; DraftState? get nextDraftState;
/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeasonCopyWith<Season> get copyWith => _$SeasonCopyWithImpl<Season>(this as Season, _$identity);

  /// Serializes this Season to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Season&&(identical(other.year, year) || other.year == year)&&(identical(other.phase, phase) || other.phase == phase)&&const DeepCollectionEquality().equals(other.schedule, schedule)&&const DeepCollectionEquality().equals(other.standings, standings)&&const DeepCollectionEquality().equals(other.playInResults, playInResults)&&const DeepCollectionEquality().equals(other.playInProgress, playInProgress)&&const DeepCollectionEquality().equals(other.playoffBrackets, playoffBrackets)&&(identical(other.championTeamId, championTeamId) || other.championTeamId == championTeamId)&&(identical(other.championshipAtmosphereApplied, championshipAtmosphereApplied) || other.championshipAtmosphereApplied == championshipAtmosphereApplied)&&(identical(other.playoffMissAtmosphereApplied, playoffMissAtmosphereApplied) || other.playoffMissAtmosphereApplied == playoffMissAtmosphereApplied)&&(identical(other.draftState, draftState) || other.draftState == draftState)&&(identical(other.awards, awards) || other.awards == awards)&&(identical(other.staffGrowthDone, staffGrowthDone) || other.staffGrowthDone == staffGrowthDone)&&(identical(other.playerRetirementsDone, playerRetirementsDone) || other.playerRetirementsDone == playerRetirementsDone)&&(identical(other.nextTvCapResetSeason, nextTvCapResetSeason) || other.nextTvCapResetSeason == nextTvCapResetSeason)&&(identical(other.nextTvCapIncreasePct, nextTvCapIncreasePct) || other.nextTvCapIncreasePct == nextTvCapIncreasePct)&&(identical(other.capUpdateTvDone, capUpdateTvDone) || other.capUpdateTvDone == capUpdateTvDone)&&(identical(other.combineDone, combineDone) || other.combineDone == combineDone)&&(identical(other.finalMockDone, finalMockDone) || other.finalMockDone == finalMockDone)&&(identical(other.faOpenDone, faOpenDone) || other.faOpenDone == faOpenDone)&&(identical(other.scoutReportDone, scoutReportDone) || other.scoutReportDone == scoutReportDone)&&(identical(other.tradeDeadlineAcked, tradeDeadlineAcked) || other.tradeDeadlineAcked == tradeDeadlineAcked)&&(identical(other.nextDraftState, nextDraftState) || other.nextDraftState == nextDraftState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,year,phase,const DeepCollectionEquality().hash(schedule),const DeepCollectionEquality().hash(standings),const DeepCollectionEquality().hash(playInResults),const DeepCollectionEquality().hash(playInProgress),const DeepCollectionEquality().hash(playoffBrackets),championTeamId,championshipAtmosphereApplied,playoffMissAtmosphereApplied,draftState,awards,staffGrowthDone,playerRetirementsDone,nextTvCapResetSeason,nextTvCapIncreasePct,capUpdateTvDone,combineDone,finalMockDone,faOpenDone,scoutReportDone,tradeDeadlineAcked,nextDraftState]);

@override
String toString() {
  return 'Season(year: $year, phase: $phase, schedule: $schedule, standings: $standings, playInResults: $playInResults, playInProgress: $playInProgress, playoffBrackets: $playoffBrackets, championTeamId: $championTeamId, championshipAtmosphereApplied: $championshipAtmosphereApplied, playoffMissAtmosphereApplied: $playoffMissAtmosphereApplied, draftState: $draftState, awards: $awards, staffGrowthDone: $staffGrowthDone, playerRetirementsDone: $playerRetirementsDone, nextTvCapResetSeason: $nextTvCapResetSeason, nextTvCapIncreasePct: $nextTvCapIncreasePct, capUpdateTvDone: $capUpdateTvDone, combineDone: $combineDone, finalMockDone: $finalMockDone, faOpenDone: $faOpenDone, scoutReportDone: $scoutReportDone, tradeDeadlineAcked: $tradeDeadlineAcked, nextDraftState: $nextDraftState)';
}


}

/// @nodoc
abstract mixin class $SeasonCopyWith<$Res>  {
  factory $SeasonCopyWith(Season value, $Res Function(Season) _then) = _$SeasonCopyWithImpl;
@useResult
$Res call({
 int year, SeasonPhase phase, List<ScheduledMatch> schedule, List<ConferenceStandings> standings, List<PlayInResult> playInResults, List<PlayInProgress> playInProgress, List<PlayoffBracket> playoffBrackets, String? championTeamId, bool championshipAtmosphereApplied, bool playoffMissAtmosphereApplied, DraftState? draftState, SeasonAwards? awards, bool staffGrowthDone, bool playerRetirementsDone, int nextTvCapResetSeason, int nextTvCapIncreasePct, bool capUpdateTvDone, bool combineDone, bool finalMockDone, bool faOpenDone, bool scoutReportDone, bool tradeDeadlineAcked, DraftState? nextDraftState
});


$DraftStateCopyWith<$Res>? get draftState;$SeasonAwardsCopyWith<$Res>? get awards;$DraftStateCopyWith<$Res>? get nextDraftState;

}
/// @nodoc
class _$SeasonCopyWithImpl<$Res>
    implements $SeasonCopyWith<$Res> {
  _$SeasonCopyWithImpl(this._self, this._then);

  final Season _self;
  final $Res Function(Season) _then;

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? phase = null,Object? schedule = null,Object? standings = null,Object? playInResults = null,Object? playInProgress = null,Object? playoffBrackets = null,Object? championTeamId = freezed,Object? championshipAtmosphereApplied = null,Object? playoffMissAtmosphereApplied = null,Object? draftState = freezed,Object? awards = freezed,Object? staffGrowthDone = null,Object? playerRetirementsDone = null,Object? nextTvCapResetSeason = null,Object? nextTvCapIncreasePct = null,Object? capUpdateTvDone = null,Object? combineDone = null,Object? finalMockDone = null,Object? faOpenDone = null,Object? scoutReportDone = null,Object? tradeDeadlineAcked = null,Object? nextDraftState = freezed,}) {
  return _then(_self.copyWith(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SeasonPhase,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as List<ScheduledMatch>,standings: null == standings ? _self.standings : standings // ignore: cast_nullable_to_non_nullable
as List<ConferenceStandings>,playInResults: null == playInResults ? _self.playInResults : playInResults // ignore: cast_nullable_to_non_nullable
as List<PlayInResult>,playInProgress: null == playInProgress ? _self.playInProgress : playInProgress // ignore: cast_nullable_to_non_nullable
as List<PlayInProgress>,playoffBrackets: null == playoffBrackets ? _self.playoffBrackets : playoffBrackets // ignore: cast_nullable_to_non_nullable
as List<PlayoffBracket>,championTeamId: freezed == championTeamId ? _self.championTeamId : championTeamId // ignore: cast_nullable_to_non_nullable
as String?,championshipAtmosphereApplied: null == championshipAtmosphereApplied ? _self.championshipAtmosphereApplied : championshipAtmosphereApplied // ignore: cast_nullable_to_non_nullable
as bool,playoffMissAtmosphereApplied: null == playoffMissAtmosphereApplied ? _self.playoffMissAtmosphereApplied : playoffMissAtmosphereApplied // ignore: cast_nullable_to_non_nullable
as bool,draftState: freezed == draftState ? _self.draftState : draftState // ignore: cast_nullable_to_non_nullable
as DraftState?,awards: freezed == awards ? _self.awards : awards // ignore: cast_nullable_to_non_nullable
as SeasonAwards?,staffGrowthDone: null == staffGrowthDone ? _self.staffGrowthDone : staffGrowthDone // ignore: cast_nullable_to_non_nullable
as bool,playerRetirementsDone: null == playerRetirementsDone ? _self.playerRetirementsDone : playerRetirementsDone // ignore: cast_nullable_to_non_nullable
as bool,nextTvCapResetSeason: null == nextTvCapResetSeason ? _self.nextTvCapResetSeason : nextTvCapResetSeason // ignore: cast_nullable_to_non_nullable
as int,nextTvCapIncreasePct: null == nextTvCapIncreasePct ? _self.nextTvCapIncreasePct : nextTvCapIncreasePct // ignore: cast_nullable_to_non_nullable
as int,capUpdateTvDone: null == capUpdateTvDone ? _self.capUpdateTvDone : capUpdateTvDone // ignore: cast_nullable_to_non_nullable
as bool,combineDone: null == combineDone ? _self.combineDone : combineDone // ignore: cast_nullable_to_non_nullable
as bool,finalMockDone: null == finalMockDone ? _self.finalMockDone : finalMockDone // ignore: cast_nullable_to_non_nullable
as bool,faOpenDone: null == faOpenDone ? _self.faOpenDone : faOpenDone // ignore: cast_nullable_to_non_nullable
as bool,scoutReportDone: null == scoutReportDone ? _self.scoutReportDone : scoutReportDone // ignore: cast_nullable_to_non_nullable
as bool,tradeDeadlineAcked: null == tradeDeadlineAcked ? _self.tradeDeadlineAcked : tradeDeadlineAcked // ignore: cast_nullable_to_non_nullable
as bool,nextDraftState: freezed == nextDraftState ? _self.nextDraftState : nextDraftState // ignore: cast_nullable_to_non_nullable
as DraftState?,
  ));
}
/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DraftStateCopyWith<$Res>? get draftState {
    if (_self.draftState == null) {
    return null;
  }

  return $DraftStateCopyWith<$Res>(_self.draftState!, (value) {
    return _then(_self.copyWith(draftState: value));
  });
}/// Create a copy of Season
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
}/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DraftStateCopyWith<$Res>? get nextDraftState {
    if (_self.nextDraftState == null) {
    return null;
  }

  return $DraftStateCopyWith<$Res>(_self.nextDraftState!, (value) {
    return _then(_self.copyWith(nextDraftState: value));
  });
}
}


/// Adds pattern-matching-related methods to [Season].
extension SeasonPatterns on Season {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Season value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Season() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Season value)  $default,){
final _that = this;
switch (_that) {
case _Season():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Season value)?  $default,){
final _that = this;
switch (_that) {
case _Season() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  SeasonPhase phase,  List<ScheduledMatch> schedule,  List<ConferenceStandings> standings,  List<PlayInResult> playInResults,  List<PlayInProgress> playInProgress,  List<PlayoffBracket> playoffBrackets,  String? championTeamId,  bool championshipAtmosphereApplied,  bool playoffMissAtmosphereApplied,  DraftState? draftState,  SeasonAwards? awards,  bool staffGrowthDone,  bool playerRetirementsDone,  int nextTvCapResetSeason,  int nextTvCapIncreasePct,  bool capUpdateTvDone,  bool combineDone,  bool finalMockDone,  bool faOpenDone,  bool scoutReportDone,  bool tradeDeadlineAcked,  DraftState? nextDraftState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that.year,_that.phase,_that.schedule,_that.standings,_that.playInResults,_that.playInProgress,_that.playoffBrackets,_that.championTeamId,_that.championshipAtmosphereApplied,_that.playoffMissAtmosphereApplied,_that.draftState,_that.awards,_that.staffGrowthDone,_that.playerRetirementsDone,_that.nextTvCapResetSeason,_that.nextTvCapIncreasePct,_that.capUpdateTvDone,_that.combineDone,_that.finalMockDone,_that.faOpenDone,_that.scoutReportDone,_that.tradeDeadlineAcked,_that.nextDraftState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  SeasonPhase phase,  List<ScheduledMatch> schedule,  List<ConferenceStandings> standings,  List<PlayInResult> playInResults,  List<PlayInProgress> playInProgress,  List<PlayoffBracket> playoffBrackets,  String? championTeamId,  bool championshipAtmosphereApplied,  bool playoffMissAtmosphereApplied,  DraftState? draftState,  SeasonAwards? awards,  bool staffGrowthDone,  bool playerRetirementsDone,  int nextTvCapResetSeason,  int nextTvCapIncreasePct,  bool capUpdateTvDone,  bool combineDone,  bool finalMockDone,  bool faOpenDone,  bool scoutReportDone,  bool tradeDeadlineAcked,  DraftState? nextDraftState)  $default,) {final _that = this;
switch (_that) {
case _Season():
return $default(_that.year,_that.phase,_that.schedule,_that.standings,_that.playInResults,_that.playInProgress,_that.playoffBrackets,_that.championTeamId,_that.championshipAtmosphereApplied,_that.playoffMissAtmosphereApplied,_that.draftState,_that.awards,_that.staffGrowthDone,_that.playerRetirementsDone,_that.nextTvCapResetSeason,_that.nextTvCapIncreasePct,_that.capUpdateTvDone,_that.combineDone,_that.finalMockDone,_that.faOpenDone,_that.scoutReportDone,_that.tradeDeadlineAcked,_that.nextDraftState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  SeasonPhase phase,  List<ScheduledMatch> schedule,  List<ConferenceStandings> standings,  List<PlayInResult> playInResults,  List<PlayInProgress> playInProgress,  List<PlayoffBracket> playoffBrackets,  String? championTeamId,  bool championshipAtmosphereApplied,  bool playoffMissAtmosphereApplied,  DraftState? draftState,  SeasonAwards? awards,  bool staffGrowthDone,  bool playerRetirementsDone,  int nextTvCapResetSeason,  int nextTvCapIncreasePct,  bool capUpdateTvDone,  bool combineDone,  bool finalMockDone,  bool faOpenDone,  bool scoutReportDone,  bool tradeDeadlineAcked,  DraftState? nextDraftState)?  $default,) {final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that.year,_that.phase,_that.schedule,_that.standings,_that.playInResults,_that.playInProgress,_that.playoffBrackets,_that.championTeamId,_that.championshipAtmosphereApplied,_that.playoffMissAtmosphereApplied,_that.draftState,_that.awards,_that.staffGrowthDone,_that.playerRetirementsDone,_that.nextTvCapResetSeason,_that.nextTvCapIncreasePct,_that.capUpdateTvDone,_that.combineDone,_that.finalMockDone,_that.faOpenDone,_that.scoutReportDone,_that.tradeDeadlineAcked,_that.nextDraftState);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Season implements Season {
  const _Season({required this.year, this.phase = SeasonPhase.preseason, final  List<ScheduledMatch> schedule = const [], final  List<ConferenceStandings> standings = const [], final  List<PlayInResult> playInResults = const [], final  List<PlayInProgress> playInProgress = const [], final  List<PlayoffBracket> playoffBrackets = const [], this.championTeamId, this.championshipAtmosphereApplied = false, this.playoffMissAtmosphereApplied = false, this.draftState, this.awards, this.staffGrowthDone = false, this.playerRetirementsDone = false, this.nextTvCapResetSeason = 0, this.nextTvCapIncreasePct = 0, this.capUpdateTvDone = false, this.combineDone = false, this.finalMockDone = false, this.faOpenDone = false, this.scoutReportDone = false, this.tradeDeadlineAcked = false, this.nextDraftState}): _schedule = schedule,_standings = standings,_playInResults = playInResults,_playInProgress = playInProgress,_playoffBrackets = playoffBrackets;
  factory _Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);

@override final  int year;
@override@JsonKey() final  SeasonPhase phase;
 final  List<ScheduledMatch> _schedule;
@override@JsonKey() List<ScheduledMatch> get schedule {
  if (_schedule is EqualUnmodifiableListView) return _schedule;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_schedule);
}

 final  List<ConferenceStandings> _standings;
@override@JsonKey() List<ConferenceStandings> get standings {
  if (_standings is EqualUnmodifiableListView) return _standings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_standings);
}

 final  List<PlayInResult> _playInResults;
@override@JsonKey() List<PlayInResult> get playInResults {
  if (_playInResults is EqualUnmodifiableListView) return _playInResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playInResults);
}

 final  List<PlayInProgress> _playInProgress;
@override@JsonKey() List<PlayInProgress> get playInProgress {
  if (_playInProgress is EqualUnmodifiableListView) return _playInProgress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playInProgress);
}

 final  List<PlayoffBracket> _playoffBrackets;
@override@JsonKey() List<PlayoffBracket> get playoffBrackets {
  if (_playoffBrackets is EqualUnmodifiableListView) return _playoffBrackets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playoffBrackets);
}

@override final  String? championTeamId;
@override@JsonKey() final  bool championshipAtmosphereApplied;
@override@JsonKey() final  bool playoffMissAtmosphereApplied;
@override final  DraftState? draftState;
@override final  SeasonAwards? awards;
@override@JsonKey() final  bool staffGrowthDone;
@override@JsonKey() final  bool playerRetirementsDone;
/// Persisted TV agreement: the exact reset year and increase are known
/// before the event fires, so loading a save cannot reroll the cap.
@override@JsonKey() final  int nextTvCapResetSeason;
@override@JsonKey() final  int nextTvCapIncreasePct;
@override@JsonKey() final  bool capUpdateTvDone;
@override@JsonKey() final  bool combineDone;
@override@JsonKey() final  bool finalMockDone;
@override@JsonKey() final  bool faOpenDone;
@override@JsonKey() final  bool scoutReportDone;
@override@JsonKey() final  bool tradeDeadlineAcked;
@override final  DraftState? nextDraftState;

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeasonCopyWith<_Season> get copyWith => __$SeasonCopyWithImpl<_Season>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeasonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Season&&(identical(other.year, year) || other.year == year)&&(identical(other.phase, phase) || other.phase == phase)&&const DeepCollectionEquality().equals(other._schedule, _schedule)&&const DeepCollectionEquality().equals(other._standings, _standings)&&const DeepCollectionEquality().equals(other._playInResults, _playInResults)&&const DeepCollectionEquality().equals(other._playInProgress, _playInProgress)&&const DeepCollectionEquality().equals(other._playoffBrackets, _playoffBrackets)&&(identical(other.championTeamId, championTeamId) || other.championTeamId == championTeamId)&&(identical(other.championshipAtmosphereApplied, championshipAtmosphereApplied) || other.championshipAtmosphereApplied == championshipAtmosphereApplied)&&(identical(other.playoffMissAtmosphereApplied, playoffMissAtmosphereApplied) || other.playoffMissAtmosphereApplied == playoffMissAtmosphereApplied)&&(identical(other.draftState, draftState) || other.draftState == draftState)&&(identical(other.awards, awards) || other.awards == awards)&&(identical(other.staffGrowthDone, staffGrowthDone) || other.staffGrowthDone == staffGrowthDone)&&(identical(other.playerRetirementsDone, playerRetirementsDone) || other.playerRetirementsDone == playerRetirementsDone)&&(identical(other.nextTvCapResetSeason, nextTvCapResetSeason) || other.nextTvCapResetSeason == nextTvCapResetSeason)&&(identical(other.nextTvCapIncreasePct, nextTvCapIncreasePct) || other.nextTvCapIncreasePct == nextTvCapIncreasePct)&&(identical(other.capUpdateTvDone, capUpdateTvDone) || other.capUpdateTvDone == capUpdateTvDone)&&(identical(other.combineDone, combineDone) || other.combineDone == combineDone)&&(identical(other.finalMockDone, finalMockDone) || other.finalMockDone == finalMockDone)&&(identical(other.faOpenDone, faOpenDone) || other.faOpenDone == faOpenDone)&&(identical(other.scoutReportDone, scoutReportDone) || other.scoutReportDone == scoutReportDone)&&(identical(other.tradeDeadlineAcked, tradeDeadlineAcked) || other.tradeDeadlineAcked == tradeDeadlineAcked)&&(identical(other.nextDraftState, nextDraftState) || other.nextDraftState == nextDraftState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,year,phase,const DeepCollectionEquality().hash(_schedule),const DeepCollectionEquality().hash(_standings),const DeepCollectionEquality().hash(_playInResults),const DeepCollectionEquality().hash(_playInProgress),const DeepCollectionEquality().hash(_playoffBrackets),championTeamId,championshipAtmosphereApplied,playoffMissAtmosphereApplied,draftState,awards,staffGrowthDone,playerRetirementsDone,nextTvCapResetSeason,nextTvCapIncreasePct,capUpdateTvDone,combineDone,finalMockDone,faOpenDone,scoutReportDone,tradeDeadlineAcked,nextDraftState]);

@override
String toString() {
  return 'Season(year: $year, phase: $phase, schedule: $schedule, standings: $standings, playInResults: $playInResults, playInProgress: $playInProgress, playoffBrackets: $playoffBrackets, championTeamId: $championTeamId, championshipAtmosphereApplied: $championshipAtmosphereApplied, playoffMissAtmosphereApplied: $playoffMissAtmosphereApplied, draftState: $draftState, awards: $awards, staffGrowthDone: $staffGrowthDone, playerRetirementsDone: $playerRetirementsDone, nextTvCapResetSeason: $nextTvCapResetSeason, nextTvCapIncreasePct: $nextTvCapIncreasePct, capUpdateTvDone: $capUpdateTvDone, combineDone: $combineDone, finalMockDone: $finalMockDone, faOpenDone: $faOpenDone, scoutReportDone: $scoutReportDone, tradeDeadlineAcked: $tradeDeadlineAcked, nextDraftState: $nextDraftState)';
}


}

/// @nodoc
abstract mixin class _$SeasonCopyWith<$Res> implements $SeasonCopyWith<$Res> {
  factory _$SeasonCopyWith(_Season value, $Res Function(_Season) _then) = __$SeasonCopyWithImpl;
@override @useResult
$Res call({
 int year, SeasonPhase phase, List<ScheduledMatch> schedule, List<ConferenceStandings> standings, List<PlayInResult> playInResults, List<PlayInProgress> playInProgress, List<PlayoffBracket> playoffBrackets, String? championTeamId, bool championshipAtmosphereApplied, bool playoffMissAtmosphereApplied, DraftState? draftState, SeasonAwards? awards, bool staffGrowthDone, bool playerRetirementsDone, int nextTvCapResetSeason, int nextTvCapIncreasePct, bool capUpdateTvDone, bool combineDone, bool finalMockDone, bool faOpenDone, bool scoutReportDone, bool tradeDeadlineAcked, DraftState? nextDraftState
});


@override $DraftStateCopyWith<$Res>? get draftState;@override $SeasonAwardsCopyWith<$Res>? get awards;@override $DraftStateCopyWith<$Res>? get nextDraftState;

}
/// @nodoc
class __$SeasonCopyWithImpl<$Res>
    implements _$SeasonCopyWith<$Res> {
  __$SeasonCopyWithImpl(this._self, this._then);

  final _Season _self;
  final $Res Function(_Season) _then;

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? phase = null,Object? schedule = null,Object? standings = null,Object? playInResults = null,Object? playInProgress = null,Object? playoffBrackets = null,Object? championTeamId = freezed,Object? championshipAtmosphereApplied = null,Object? playoffMissAtmosphereApplied = null,Object? draftState = freezed,Object? awards = freezed,Object? staffGrowthDone = null,Object? playerRetirementsDone = null,Object? nextTvCapResetSeason = null,Object? nextTvCapIncreasePct = null,Object? capUpdateTvDone = null,Object? combineDone = null,Object? finalMockDone = null,Object? faOpenDone = null,Object? scoutReportDone = null,Object? tradeDeadlineAcked = null,Object? nextDraftState = freezed,}) {
  return _then(_Season(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SeasonPhase,schedule: null == schedule ? _self._schedule : schedule // ignore: cast_nullable_to_non_nullable
as List<ScheduledMatch>,standings: null == standings ? _self._standings : standings // ignore: cast_nullable_to_non_nullable
as List<ConferenceStandings>,playInResults: null == playInResults ? _self._playInResults : playInResults // ignore: cast_nullable_to_non_nullable
as List<PlayInResult>,playInProgress: null == playInProgress ? _self._playInProgress : playInProgress // ignore: cast_nullable_to_non_nullable
as List<PlayInProgress>,playoffBrackets: null == playoffBrackets ? _self._playoffBrackets : playoffBrackets // ignore: cast_nullable_to_non_nullable
as List<PlayoffBracket>,championTeamId: freezed == championTeamId ? _self.championTeamId : championTeamId // ignore: cast_nullable_to_non_nullable
as String?,championshipAtmosphereApplied: null == championshipAtmosphereApplied ? _self.championshipAtmosphereApplied : championshipAtmosphereApplied // ignore: cast_nullable_to_non_nullable
as bool,playoffMissAtmosphereApplied: null == playoffMissAtmosphereApplied ? _self.playoffMissAtmosphereApplied : playoffMissAtmosphereApplied // ignore: cast_nullable_to_non_nullable
as bool,draftState: freezed == draftState ? _self.draftState : draftState // ignore: cast_nullable_to_non_nullable
as DraftState?,awards: freezed == awards ? _self.awards : awards // ignore: cast_nullable_to_non_nullable
as SeasonAwards?,staffGrowthDone: null == staffGrowthDone ? _self.staffGrowthDone : staffGrowthDone // ignore: cast_nullable_to_non_nullable
as bool,playerRetirementsDone: null == playerRetirementsDone ? _self.playerRetirementsDone : playerRetirementsDone // ignore: cast_nullable_to_non_nullable
as bool,nextTvCapResetSeason: null == nextTvCapResetSeason ? _self.nextTvCapResetSeason : nextTvCapResetSeason // ignore: cast_nullable_to_non_nullable
as int,nextTvCapIncreasePct: null == nextTvCapIncreasePct ? _self.nextTvCapIncreasePct : nextTvCapIncreasePct // ignore: cast_nullable_to_non_nullable
as int,capUpdateTvDone: null == capUpdateTvDone ? _self.capUpdateTvDone : capUpdateTvDone // ignore: cast_nullable_to_non_nullable
as bool,combineDone: null == combineDone ? _self.combineDone : combineDone // ignore: cast_nullable_to_non_nullable
as bool,finalMockDone: null == finalMockDone ? _self.finalMockDone : finalMockDone // ignore: cast_nullable_to_non_nullable
as bool,faOpenDone: null == faOpenDone ? _self.faOpenDone : faOpenDone // ignore: cast_nullable_to_non_nullable
as bool,scoutReportDone: null == scoutReportDone ? _self.scoutReportDone : scoutReportDone // ignore: cast_nullable_to_non_nullable
as bool,tradeDeadlineAcked: null == tradeDeadlineAcked ? _self.tradeDeadlineAcked : tradeDeadlineAcked // ignore: cast_nullable_to_non_nullable
as bool,nextDraftState: freezed == nextDraftState ? _self.nextDraftState : nextDraftState // ignore: cast_nullable_to_non_nullable
as DraftState?,
  ));
}

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DraftStateCopyWith<$Res>? get draftState {
    if (_self.draftState == null) {
    return null;
  }

  return $DraftStateCopyWith<$Res>(_self.draftState!, (value) {
    return _then(_self.copyWith(draftState: value));
  });
}/// Create a copy of Season
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
}/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DraftStateCopyWith<$Res>? get nextDraftState {
    if (_self.nextDraftState == null) {
    return null;
  }

  return $DraftStateCopyWith<$Res>(_self.nextDraftState!, (value) {
    return _then(_self.copyWith(nextDraftState: value));
  });
}
}


/// @nodoc
mixin _$SeasonHistory {

 int get year; List<ConferenceStandings> get finalStandings; String? get championTeamId; List<DraftPick> get draftPicks;
/// Create a copy of SeasonHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeasonHistoryCopyWith<SeasonHistory> get copyWith => _$SeasonHistoryCopyWithImpl<SeasonHistory>(this as SeasonHistory, _$identity);

  /// Serializes this SeasonHistory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeasonHistory&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other.finalStandings, finalStandings)&&(identical(other.championTeamId, championTeamId) || other.championTeamId == championTeamId)&&const DeepCollectionEquality().equals(other.draftPicks, draftPicks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,const DeepCollectionEquality().hash(finalStandings),championTeamId,const DeepCollectionEquality().hash(draftPicks));

@override
String toString() {
  return 'SeasonHistory(year: $year, finalStandings: $finalStandings, championTeamId: $championTeamId, draftPicks: $draftPicks)';
}


}

/// @nodoc
abstract mixin class $SeasonHistoryCopyWith<$Res>  {
  factory $SeasonHistoryCopyWith(SeasonHistory value, $Res Function(SeasonHistory) _then) = _$SeasonHistoryCopyWithImpl;
@useResult
$Res call({
 int year, List<ConferenceStandings> finalStandings, String? championTeamId, List<DraftPick> draftPicks
});




}
/// @nodoc
class _$SeasonHistoryCopyWithImpl<$Res>
    implements $SeasonHistoryCopyWith<$Res> {
  _$SeasonHistoryCopyWithImpl(this._self, this._then);

  final SeasonHistory _self;
  final $Res Function(SeasonHistory) _then;

/// Create a copy of SeasonHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? finalStandings = null,Object? championTeamId = freezed,Object? draftPicks = null,}) {
  return _then(_self.copyWith(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,finalStandings: null == finalStandings ? _self.finalStandings : finalStandings // ignore: cast_nullable_to_non_nullable
as List<ConferenceStandings>,championTeamId: freezed == championTeamId ? _self.championTeamId : championTeamId // ignore: cast_nullable_to_non_nullable
as String?,draftPicks: null == draftPicks ? _self.draftPicks : draftPicks // ignore: cast_nullable_to_non_nullable
as List<DraftPick>,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  List<ConferenceStandings> finalStandings,  String? championTeamId,  List<DraftPick> draftPicks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeasonHistory() when $default != null:
return $default(_that.year,_that.finalStandings,_that.championTeamId,_that.draftPicks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  List<ConferenceStandings> finalStandings,  String? championTeamId,  List<DraftPick> draftPicks)  $default,) {final _that = this;
switch (_that) {
case _SeasonHistory():
return $default(_that.year,_that.finalStandings,_that.championTeamId,_that.draftPicks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  List<ConferenceStandings> finalStandings,  String? championTeamId,  List<DraftPick> draftPicks)?  $default,) {final _that = this;
switch (_that) {
case _SeasonHistory() when $default != null:
return $default(_that.year,_that.finalStandings,_that.championTeamId,_that.draftPicks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SeasonHistory implements SeasonHistory {
  const _SeasonHistory({required this.year, required final  List<ConferenceStandings> finalStandings, this.championTeamId, final  List<DraftPick> draftPicks = const []}): _finalStandings = finalStandings,_draftPicks = draftPicks;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeasonHistory&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other._finalStandings, _finalStandings)&&(identical(other.championTeamId, championTeamId) || other.championTeamId == championTeamId)&&const DeepCollectionEquality().equals(other._draftPicks, _draftPicks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,const DeepCollectionEquality().hash(_finalStandings),championTeamId,const DeepCollectionEquality().hash(_draftPicks));

@override
String toString() {
  return 'SeasonHistory(year: $year, finalStandings: $finalStandings, championTeamId: $championTeamId, draftPicks: $draftPicks)';
}


}

/// @nodoc
abstract mixin class _$SeasonHistoryCopyWith<$Res> implements $SeasonHistoryCopyWith<$Res> {
  factory _$SeasonHistoryCopyWith(_SeasonHistory value, $Res Function(_SeasonHistory) _then) = __$SeasonHistoryCopyWithImpl;
@override @useResult
$Res call({
 int year, List<ConferenceStandings> finalStandings, String? championTeamId, List<DraftPick> draftPicks
});




}
/// @nodoc
class __$SeasonHistoryCopyWithImpl<$Res>
    implements _$SeasonHistoryCopyWith<$Res> {
  __$SeasonHistoryCopyWithImpl(this._self, this._then);

  final _SeasonHistory _self;
  final $Res Function(_SeasonHistory) _then;

/// Create a copy of SeasonHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? finalStandings = null,Object? championTeamId = freezed,Object? draftPicks = null,}) {
  return _then(_SeasonHistory(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,finalStandings: null == finalStandings ? _self._finalStandings : finalStandings // ignore: cast_nullable_to_non_nullable
as List<ConferenceStandings>,championTeamId: freezed == championTeamId ? _self.championTeamId : championTeamId // ignore: cast_nullable_to_non_nullable
as String?,draftPicks: null == draftPicks ? _self._draftPicks : draftPicks // ignore: cast_nullable_to_non_nullable
as List<DraftPick>,
  ));
}


}

// dart format on
