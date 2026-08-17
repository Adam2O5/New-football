// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'injury.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Injury {

 String get id; InjuryGroup get group; InjuryType get type; int get daysTotal; int get daysRemaining;
/// Create a copy of Injury
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InjuryCopyWith<Injury> get copyWith => _$InjuryCopyWithImpl<Injury>(this as Injury, _$identity);

  /// Serializes this Injury to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Injury&&(identical(other.id, id) || other.id == id)&&(identical(other.group, group) || other.group == group)&&(identical(other.type, type) || other.type == type)&&(identical(other.daysTotal, daysTotal) || other.daysTotal == daysTotal)&&(identical(other.daysRemaining, daysRemaining) || other.daysRemaining == daysRemaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,group,type,daysTotal,daysRemaining);

@override
String toString() {
  return 'Injury(id: $id, group: $group, type: $type, daysTotal: $daysTotal, daysRemaining: $daysRemaining)';
}


}

/// @nodoc
abstract mixin class $InjuryCopyWith<$Res>  {
  factory $InjuryCopyWith(Injury value, $Res Function(Injury) _then) = _$InjuryCopyWithImpl;
@useResult
$Res call({
 String id, InjuryGroup group, InjuryType type, int daysTotal, int daysRemaining
});




}
/// @nodoc
class _$InjuryCopyWithImpl<$Res>
    implements $InjuryCopyWith<$Res> {
  _$InjuryCopyWithImpl(this._self, this._then);

  final Injury _self;
  final $Res Function(Injury) _then;

/// Create a copy of Injury
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? group = null,Object? type = null,Object? daysTotal = null,Object? daysRemaining = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as InjuryGroup,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InjuryType,daysTotal: null == daysTotal ? _self.daysTotal : daysTotal // ignore: cast_nullable_to_non_nullable
as int,daysRemaining: null == daysRemaining ? _self.daysRemaining : daysRemaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Injury].
extension InjuryPatterns on Injury {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Injury value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Injury() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Injury value)  $default,){
final _that = this;
switch (_that) {
case _Injury():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Injury value)?  $default,){
final _that = this;
switch (_that) {
case _Injury() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  InjuryGroup group,  InjuryType type,  int daysTotal,  int daysRemaining)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Injury() when $default != null:
return $default(_that.id,_that.group,_that.type,_that.daysTotal,_that.daysRemaining);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  InjuryGroup group,  InjuryType type,  int daysTotal,  int daysRemaining)  $default,) {final _that = this;
switch (_that) {
case _Injury():
return $default(_that.id,_that.group,_that.type,_that.daysTotal,_that.daysRemaining);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  InjuryGroup group,  InjuryType type,  int daysTotal,  int daysRemaining)?  $default,) {final _that = this;
switch (_that) {
case _Injury() when $default != null:
return $default(_that.id,_that.group,_that.type,_that.daysTotal,_that.daysRemaining);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Injury implements Injury {
  const _Injury({required this.id, required this.group, required this.type, required this.daysTotal, required this.daysRemaining});
  factory _Injury.fromJson(Map<String, dynamic> json) => _$InjuryFromJson(json);

@override final  String id;
@override final  InjuryGroup group;
@override final  InjuryType type;
@override final  int daysTotal;
@override final  int daysRemaining;

/// Create a copy of Injury
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InjuryCopyWith<_Injury> get copyWith => __$InjuryCopyWithImpl<_Injury>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InjuryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Injury&&(identical(other.id, id) || other.id == id)&&(identical(other.group, group) || other.group == group)&&(identical(other.type, type) || other.type == type)&&(identical(other.daysTotal, daysTotal) || other.daysTotal == daysTotal)&&(identical(other.daysRemaining, daysRemaining) || other.daysRemaining == daysRemaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,group,type,daysTotal,daysRemaining);

@override
String toString() {
  return 'Injury(id: $id, group: $group, type: $type, daysTotal: $daysTotal, daysRemaining: $daysRemaining)';
}


}

/// @nodoc
abstract mixin class _$InjuryCopyWith<$Res> implements $InjuryCopyWith<$Res> {
  factory _$InjuryCopyWith(_Injury value, $Res Function(_Injury) _then) = __$InjuryCopyWithImpl;
@override @useResult
$Res call({
 String id, InjuryGroup group, InjuryType type, int daysTotal, int daysRemaining
});




}
/// @nodoc
class __$InjuryCopyWithImpl<$Res>
    implements _$InjuryCopyWith<$Res> {
  __$InjuryCopyWithImpl(this._self, this._then);

  final _Injury _self;
  final $Res Function(_Injury) _then;

/// Create a copy of Injury
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? group = null,Object? type = null,Object? daysTotal = null,Object? daysRemaining = null,}) {
  return _then(_Injury(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as InjuryGroup,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InjuryType,daysTotal: null == daysTotal ? _self.daysTotal : daysTotal // ignore: cast_nullable_to_non_nullable
as int,daysRemaining: null == daysRemaining ? _self.daysRemaining : daysRemaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
