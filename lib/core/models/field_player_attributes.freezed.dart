// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'field_player_attributes.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FieldPlayerAttributes {

 int get pace; int get shooting; int get passing; int get dribbling; int get defending; int get physicality;
/// Create a copy of FieldPlayerAttributes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FieldPlayerAttributesCopyWith<FieldPlayerAttributes> get copyWith => _$FieldPlayerAttributesCopyWithImpl<FieldPlayerAttributes>(this as FieldPlayerAttributes, _$identity);

  /// Serializes this FieldPlayerAttributes to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldPlayerAttributes&&(identical(other.pace, pace) || other.pace == pace)&&(identical(other.shooting, shooting) || other.shooting == shooting)&&(identical(other.passing, passing) || other.passing == passing)&&(identical(other.dribbling, dribbling) || other.dribbling == dribbling)&&(identical(other.defending, defending) || other.defending == defending)&&(identical(other.physicality, physicality) || other.physicality == physicality));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pace,shooting,passing,dribbling,defending,physicality);

@override
String toString() {
  return 'FieldPlayerAttributes(pace: $pace, shooting: $shooting, passing: $passing, dribbling: $dribbling, defending: $defending, physicality: $physicality)';
}


}

/// @nodoc
abstract mixin class $FieldPlayerAttributesCopyWith<$Res>  {
  factory $FieldPlayerAttributesCopyWith(FieldPlayerAttributes value, $Res Function(FieldPlayerAttributes) _then) = _$FieldPlayerAttributesCopyWithImpl;
@useResult
$Res call({
 int pace, int shooting, int passing, int dribbling, int defending, int physicality
});




}
/// @nodoc
class _$FieldPlayerAttributesCopyWithImpl<$Res>
    implements $FieldPlayerAttributesCopyWith<$Res> {
  _$FieldPlayerAttributesCopyWithImpl(this._self, this._then);

  final FieldPlayerAttributes _self;
  final $Res Function(FieldPlayerAttributes) _then;

/// Create a copy of FieldPlayerAttributes
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pace = null,Object? shooting = null,Object? passing = null,Object? dribbling = null,Object? defending = null,Object? physicality = null,}) {
  return _then(_self.copyWith(
pace: null == pace ? _self.pace : pace // ignore: cast_nullable_to_non_nullable
as int,shooting: null == shooting ? _self.shooting : shooting // ignore: cast_nullable_to_non_nullable
as int,passing: null == passing ? _self.passing : passing // ignore: cast_nullable_to_non_nullable
as int,dribbling: null == dribbling ? _self.dribbling : dribbling // ignore: cast_nullable_to_non_nullable
as int,defending: null == defending ? _self.defending : defending // ignore: cast_nullable_to_non_nullable
as int,physicality: null == physicality ? _self.physicality : physicality // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FieldPlayerAttributes].
extension FieldPlayerAttributesPatterns on FieldPlayerAttributes {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FieldPlayerAttributes value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FieldPlayerAttributes() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FieldPlayerAttributes value)  $default,){
final _that = this;
switch (_that) {
case _FieldPlayerAttributes():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FieldPlayerAttributes value)?  $default,){
final _that = this;
switch (_that) {
case _FieldPlayerAttributes() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int pace,  int shooting,  int passing,  int dribbling,  int defending,  int physicality)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FieldPlayerAttributes() when $default != null:
return $default(_that.pace,_that.shooting,_that.passing,_that.dribbling,_that.defending,_that.physicality);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int pace,  int shooting,  int passing,  int dribbling,  int defending,  int physicality)  $default,) {final _that = this;
switch (_that) {
case _FieldPlayerAttributes():
return $default(_that.pace,_that.shooting,_that.passing,_that.dribbling,_that.defending,_that.physicality);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int pace,  int shooting,  int passing,  int dribbling,  int defending,  int physicality)?  $default,) {final _that = this;
switch (_that) {
case _FieldPlayerAttributes() when $default != null:
return $default(_that.pace,_that.shooting,_that.passing,_that.dribbling,_that.defending,_that.physicality);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FieldPlayerAttributes implements FieldPlayerAttributes {
  const _FieldPlayerAttributes({required this.pace, required this.shooting, required this.passing, required this.dribbling, required this.defending, required this.physicality});
  factory _FieldPlayerAttributes.fromJson(Map<String, dynamic> json) => _$FieldPlayerAttributesFromJson(json);

@override final  int pace;
@override final  int shooting;
@override final  int passing;
@override final  int dribbling;
@override final  int defending;
@override final  int physicality;

/// Create a copy of FieldPlayerAttributes
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FieldPlayerAttributesCopyWith<_FieldPlayerAttributes> get copyWith => __$FieldPlayerAttributesCopyWithImpl<_FieldPlayerAttributes>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FieldPlayerAttributesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FieldPlayerAttributes&&(identical(other.pace, pace) || other.pace == pace)&&(identical(other.shooting, shooting) || other.shooting == shooting)&&(identical(other.passing, passing) || other.passing == passing)&&(identical(other.dribbling, dribbling) || other.dribbling == dribbling)&&(identical(other.defending, defending) || other.defending == defending)&&(identical(other.physicality, physicality) || other.physicality == physicality));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pace,shooting,passing,dribbling,defending,physicality);

@override
String toString() {
  return 'FieldPlayerAttributes(pace: $pace, shooting: $shooting, passing: $passing, dribbling: $dribbling, defending: $defending, physicality: $physicality)';
}


}

/// @nodoc
abstract mixin class _$FieldPlayerAttributesCopyWith<$Res> implements $FieldPlayerAttributesCopyWith<$Res> {
  factory _$FieldPlayerAttributesCopyWith(_FieldPlayerAttributes value, $Res Function(_FieldPlayerAttributes) _then) = __$FieldPlayerAttributesCopyWithImpl;
@override @useResult
$Res call({
 int pace, int shooting, int passing, int dribbling, int defending, int physicality
});




}
/// @nodoc
class __$FieldPlayerAttributesCopyWithImpl<$Res>
    implements _$FieldPlayerAttributesCopyWith<$Res> {
  __$FieldPlayerAttributesCopyWithImpl(this._self, this._then);

  final _FieldPlayerAttributes _self;
  final $Res Function(_FieldPlayerAttributes) _then;

/// Create a copy of FieldPlayerAttributes
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pace = null,Object? shooting = null,Object? passing = null,Object? dribbling = null,Object? defending = null,Object? physicality = null,}) {
  return _then(_FieldPlayerAttributes(
pace: null == pace ? _self.pace : pace // ignore: cast_nullable_to_non_nullable
as int,shooting: null == shooting ? _self.shooting : shooting // ignore: cast_nullable_to_non_nullable
as int,passing: null == passing ? _self.passing : passing // ignore: cast_nullable_to_non_nullable
as int,dribbling: null == dribbling ? _self.dribbling : dribbling // ignore: cast_nullable_to_non_nullable
as int,defending: null == defending ? _self.defending : defending // ignore: cast_nullable_to_non_nullable
as int,physicality: null == physicality ? _self.physicality : physicality // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
