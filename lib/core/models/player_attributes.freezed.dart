// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_attributes.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
PlayerAttributes _$PlayerAttributesFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'outfield':
          return OutfieldPlayerAttributes.fromJson(
            json
          );
                case 'goalkeeper':
          return GoalkeeperPlayerAttributes.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'PlayerAttributes',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$PlayerAttributes {

 Object get stats;

  /// Serializes this PlayerAttributes to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerAttributes&&const DeepCollectionEquality().equals(other.stats, stats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(stats));

@override
String toString() {
  return 'PlayerAttributes(stats: $stats)';
}


}

/// @nodoc
class $PlayerAttributesCopyWith<$Res>  {
$PlayerAttributesCopyWith(PlayerAttributes _, $Res Function(PlayerAttributes) __);
}


/// Adds pattern-matching-related methods to [PlayerAttributes].
extension PlayerAttributesPatterns on PlayerAttributes {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( OutfieldPlayerAttributes value)?  outfield,TResult Function( GoalkeeperPlayerAttributes value)?  goalkeeper,required TResult orElse(),}){
final _that = this;
switch (_that) {
case OutfieldPlayerAttributes() when outfield != null:
return outfield(_that);case GoalkeeperPlayerAttributes() when goalkeeper != null:
return goalkeeper(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( OutfieldPlayerAttributes value)  outfield,required TResult Function( GoalkeeperPlayerAttributes value)  goalkeeper,}){
final _that = this;
switch (_that) {
case OutfieldPlayerAttributes():
return outfield(_that);case GoalkeeperPlayerAttributes():
return goalkeeper(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( OutfieldPlayerAttributes value)?  outfield,TResult? Function( GoalkeeperPlayerAttributes value)?  goalkeeper,}){
final _that = this;
switch (_that) {
case OutfieldPlayerAttributes() when outfield != null:
return outfield(_that);case GoalkeeperPlayerAttributes() when goalkeeper != null:
return goalkeeper(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( FieldPlayerAttributes stats)?  outfield,TResult Function( GoalkeeperAttributes stats)?  goalkeeper,required TResult orElse(),}) {final _that = this;
switch (_that) {
case OutfieldPlayerAttributes() when outfield != null:
return outfield(_that.stats);case GoalkeeperPlayerAttributes() when goalkeeper != null:
return goalkeeper(_that.stats);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( FieldPlayerAttributes stats)  outfield,required TResult Function( GoalkeeperAttributes stats)  goalkeeper,}) {final _that = this;
switch (_that) {
case OutfieldPlayerAttributes():
return outfield(_that.stats);case GoalkeeperPlayerAttributes():
return goalkeeper(_that.stats);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( FieldPlayerAttributes stats)?  outfield,TResult? Function( GoalkeeperAttributes stats)?  goalkeeper,}) {final _that = this;
switch (_that) {
case OutfieldPlayerAttributes() when outfield != null:
return outfield(_that.stats);case GoalkeeperPlayerAttributes() when goalkeeper != null:
return goalkeeper(_that.stats);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class OutfieldPlayerAttributes implements PlayerAttributes {
  const OutfieldPlayerAttributes({required this.stats, final  String? $type}): $type = $type ?? 'outfield';
  factory OutfieldPlayerAttributes.fromJson(Map<String, dynamic> json) => _$OutfieldPlayerAttributesFromJson(json);

@override final  FieldPlayerAttributes stats;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of PlayerAttributes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutfieldPlayerAttributesCopyWith<OutfieldPlayerAttributes> get copyWith => _$OutfieldPlayerAttributesCopyWithImpl<OutfieldPlayerAttributes>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutfieldPlayerAttributesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutfieldPlayerAttributes&&(identical(other.stats, stats) || other.stats == stats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stats);

@override
String toString() {
  return 'PlayerAttributes.outfield(stats: $stats)';
}


}

/// @nodoc
abstract mixin class $OutfieldPlayerAttributesCopyWith<$Res> implements $PlayerAttributesCopyWith<$Res> {
  factory $OutfieldPlayerAttributesCopyWith(OutfieldPlayerAttributes value, $Res Function(OutfieldPlayerAttributes) _then) = _$OutfieldPlayerAttributesCopyWithImpl;
@useResult
$Res call({
 FieldPlayerAttributes stats
});


$FieldPlayerAttributesCopyWith<$Res> get stats;

}
/// @nodoc
class _$OutfieldPlayerAttributesCopyWithImpl<$Res>
    implements $OutfieldPlayerAttributesCopyWith<$Res> {
  _$OutfieldPlayerAttributesCopyWithImpl(this._self, this._then);

  final OutfieldPlayerAttributes _self;
  final $Res Function(OutfieldPlayerAttributes) _then;

/// Create a copy of PlayerAttributes
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? stats = null,}) {
  return _then(OutfieldPlayerAttributes(
stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as FieldPlayerAttributes,
  ));
}

/// Create a copy of PlayerAttributes
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FieldPlayerAttributesCopyWith<$Res> get stats {
  
  return $FieldPlayerAttributesCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class GoalkeeperPlayerAttributes implements PlayerAttributes {
  const GoalkeeperPlayerAttributes({required this.stats, final  String? $type}): $type = $type ?? 'goalkeeper';
  factory GoalkeeperPlayerAttributes.fromJson(Map<String, dynamic> json) => _$GoalkeeperPlayerAttributesFromJson(json);

@override final  GoalkeeperAttributes stats;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of PlayerAttributes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalkeeperPlayerAttributesCopyWith<GoalkeeperPlayerAttributes> get copyWith => _$GoalkeeperPlayerAttributesCopyWithImpl<GoalkeeperPlayerAttributes>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoalkeeperPlayerAttributesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoalkeeperPlayerAttributes&&(identical(other.stats, stats) || other.stats == stats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stats);

@override
String toString() {
  return 'PlayerAttributes.goalkeeper(stats: $stats)';
}


}

/// @nodoc
abstract mixin class $GoalkeeperPlayerAttributesCopyWith<$Res> implements $PlayerAttributesCopyWith<$Res> {
  factory $GoalkeeperPlayerAttributesCopyWith(GoalkeeperPlayerAttributes value, $Res Function(GoalkeeperPlayerAttributes) _then) = _$GoalkeeperPlayerAttributesCopyWithImpl;
@useResult
$Res call({
 GoalkeeperAttributes stats
});


$GoalkeeperAttributesCopyWith<$Res> get stats;

}
/// @nodoc
class _$GoalkeeperPlayerAttributesCopyWithImpl<$Res>
    implements $GoalkeeperPlayerAttributesCopyWith<$Res> {
  _$GoalkeeperPlayerAttributesCopyWithImpl(this._self, this._then);

  final GoalkeeperPlayerAttributes _self;
  final $Res Function(GoalkeeperPlayerAttributes) _then;

/// Create a copy of PlayerAttributes
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? stats = null,}) {
  return _then(GoalkeeperPlayerAttributes(
stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as GoalkeeperAttributes,
  ));
}

/// Create a copy of PlayerAttributes
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GoalkeeperAttributesCopyWith<$Res> get stats {
  
  return $GoalkeeperAttributesCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}

// dart format on
