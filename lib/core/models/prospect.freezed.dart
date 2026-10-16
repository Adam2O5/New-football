// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prospect.dart';

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

// dart format on
