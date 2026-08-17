// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goalkeeper_attributes.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GoalkeeperAttributes {

 int get diving; int get handling; int get kicking; int get reflexes; int get speed; int get positioning;
/// Create a copy of GoalkeeperAttributes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalkeeperAttributesCopyWith<GoalkeeperAttributes> get copyWith => _$GoalkeeperAttributesCopyWithImpl<GoalkeeperAttributes>(this as GoalkeeperAttributes, _$identity);

  /// Serializes this GoalkeeperAttributes to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoalkeeperAttributes&&(identical(other.diving, diving) || other.diving == diving)&&(identical(other.handling, handling) || other.handling == handling)&&(identical(other.kicking, kicking) || other.kicking == kicking)&&(identical(other.reflexes, reflexes) || other.reflexes == reflexes)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.positioning, positioning) || other.positioning == positioning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,diving,handling,kicking,reflexes,speed,positioning);

@override
String toString() {
  return 'GoalkeeperAttributes(diving: $diving, handling: $handling, kicking: $kicking, reflexes: $reflexes, speed: $speed, positioning: $positioning)';
}


}

/// @nodoc
abstract mixin class $GoalkeeperAttributesCopyWith<$Res>  {
  factory $GoalkeeperAttributesCopyWith(GoalkeeperAttributes value, $Res Function(GoalkeeperAttributes) _then) = _$GoalkeeperAttributesCopyWithImpl;
@useResult
$Res call({
 int diving, int handling, int kicking, int reflexes, int speed, int positioning
});




}
/// @nodoc
class _$GoalkeeperAttributesCopyWithImpl<$Res>
    implements $GoalkeeperAttributesCopyWith<$Res> {
  _$GoalkeeperAttributesCopyWithImpl(this._self, this._then);

  final GoalkeeperAttributes _self;
  final $Res Function(GoalkeeperAttributes) _then;

/// Create a copy of GoalkeeperAttributes
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? diving = null,Object? handling = null,Object? kicking = null,Object? reflexes = null,Object? speed = null,Object? positioning = null,}) {
  return _then(_self.copyWith(
diving: null == diving ? _self.diving : diving // ignore: cast_nullable_to_non_nullable
as int,handling: null == handling ? _self.handling : handling // ignore: cast_nullable_to_non_nullable
as int,kicking: null == kicking ? _self.kicking : kicking // ignore: cast_nullable_to_non_nullable
as int,reflexes: null == reflexes ? _self.reflexes : reflexes // ignore: cast_nullable_to_non_nullable
as int,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as int,positioning: null == positioning ? _self.positioning : positioning // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GoalkeeperAttributes].
extension GoalkeeperAttributesPatterns on GoalkeeperAttributes {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoalkeeperAttributes value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoalkeeperAttributes() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoalkeeperAttributes value)  $default,){
final _that = this;
switch (_that) {
case _GoalkeeperAttributes():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoalkeeperAttributes value)?  $default,){
final _that = this;
switch (_that) {
case _GoalkeeperAttributes() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int diving,  int handling,  int kicking,  int reflexes,  int speed,  int positioning)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoalkeeperAttributes() when $default != null:
return $default(_that.diving,_that.handling,_that.kicking,_that.reflexes,_that.speed,_that.positioning);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int diving,  int handling,  int kicking,  int reflexes,  int speed,  int positioning)  $default,) {final _that = this;
switch (_that) {
case _GoalkeeperAttributes():
return $default(_that.diving,_that.handling,_that.kicking,_that.reflexes,_that.speed,_that.positioning);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int diving,  int handling,  int kicking,  int reflexes,  int speed,  int positioning)?  $default,) {final _that = this;
switch (_that) {
case _GoalkeeperAttributes() when $default != null:
return $default(_that.diving,_that.handling,_that.kicking,_that.reflexes,_that.speed,_that.positioning);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoalkeeperAttributes implements GoalkeeperAttributes {
  const _GoalkeeperAttributes({required this.diving, required this.handling, required this.kicking, required this.reflexes, required this.speed, required this.positioning});
  factory _GoalkeeperAttributes.fromJson(Map<String, dynamic> json) => _$GoalkeeperAttributesFromJson(json);

@override final  int diving;
@override final  int handling;
@override final  int kicking;
@override final  int reflexes;
@override final  int speed;
@override final  int positioning;

/// Create a copy of GoalkeeperAttributes
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalkeeperAttributesCopyWith<_GoalkeeperAttributes> get copyWith => __$GoalkeeperAttributesCopyWithImpl<_GoalkeeperAttributes>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoalkeeperAttributesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoalkeeperAttributes&&(identical(other.diving, diving) || other.diving == diving)&&(identical(other.handling, handling) || other.handling == handling)&&(identical(other.kicking, kicking) || other.kicking == kicking)&&(identical(other.reflexes, reflexes) || other.reflexes == reflexes)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.positioning, positioning) || other.positioning == positioning));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,diving,handling,kicking,reflexes,speed,positioning);

@override
String toString() {
  return 'GoalkeeperAttributes(diving: $diving, handling: $handling, kicking: $kicking, reflexes: $reflexes, speed: $speed, positioning: $positioning)';
}


}

/// @nodoc
abstract mixin class _$GoalkeeperAttributesCopyWith<$Res> implements $GoalkeeperAttributesCopyWith<$Res> {
  factory _$GoalkeeperAttributesCopyWith(_GoalkeeperAttributes value, $Res Function(_GoalkeeperAttributes) _then) = __$GoalkeeperAttributesCopyWithImpl;
@override @useResult
$Res call({
 int diving, int handling, int kicking, int reflexes, int speed, int positioning
});




}
/// @nodoc
class __$GoalkeeperAttributesCopyWithImpl<$Res>
    implements _$GoalkeeperAttributesCopyWith<$Res> {
  __$GoalkeeperAttributesCopyWithImpl(this._self, this._then);

  final _GoalkeeperAttributes _self;
  final $Res Function(_GoalkeeperAttributes) _then;

/// Create a copy of GoalkeeperAttributes
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? diving = null,Object? handling = null,Object? kicking = null,Object? reflexes = null,Object? speed = null,Object? positioning = null,}) {
  return _then(_GoalkeeperAttributes(
diving: null == diving ? _self.diving : diving // ignore: cast_nullable_to_non_nullable
as int,handling: null == handling ? _self.handling : handling // ignore: cast_nullable_to_non_nullable
as int,kicking: null == kicking ? _self.kicking : kicking // ignore: cast_nullable_to_non_nullable
as int,reflexes: null == reflexes ? _self.reflexes : reflexes // ignore: cast_nullable_to_non_nullable
as int,speed: null == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as int,positioning: null == positioning ? _self.positioning : positioning // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
