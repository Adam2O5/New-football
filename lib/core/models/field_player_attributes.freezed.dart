// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'field_player_attributes.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FieldPlayerAttributes _$FieldPlayerAttributesFromJson(
  Map<String, dynamic> json,
) {
  return _FieldPlayerAttributes.fromJson(json);
}

/// @nodoc
mixin _$FieldPlayerAttributes {
  int get pace => throw _privateConstructorUsedError;
  int get shooting => throw _privateConstructorUsedError;
  int get passing => throw _privateConstructorUsedError;
  int get dribbling => throw _privateConstructorUsedError;
  int get defending => throw _privateConstructorUsedError;
  int get physicality => throw _privateConstructorUsedError;

  /// Serializes this FieldPlayerAttributes to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FieldPlayerAttributes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FieldPlayerAttributesCopyWith<FieldPlayerAttributes> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FieldPlayerAttributesCopyWith<$Res> {
  factory $FieldPlayerAttributesCopyWith(
    FieldPlayerAttributes value,
    $Res Function(FieldPlayerAttributes) then,
  ) = _$FieldPlayerAttributesCopyWithImpl<$Res, FieldPlayerAttributes>;
  @useResult
  $Res call({
    int pace,
    int shooting,
    int passing,
    int dribbling,
    int defending,
    int physicality,
  });
}

/// @nodoc
class _$FieldPlayerAttributesCopyWithImpl<
  $Res,
  $Val extends FieldPlayerAttributes
>
    implements $FieldPlayerAttributesCopyWith<$Res> {
  _$FieldPlayerAttributesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FieldPlayerAttributes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pace = null,
    Object? shooting = null,
    Object? passing = null,
    Object? dribbling = null,
    Object? defending = null,
    Object? physicality = null,
  }) {
    return _then(
      _value.copyWith(
            pace: null == pace
                ? _value.pace
                : pace // ignore: cast_nullable_to_non_nullable
                      as int,
            shooting: null == shooting
                ? _value.shooting
                : shooting // ignore: cast_nullable_to_non_nullable
                      as int,
            passing: null == passing
                ? _value.passing
                : passing // ignore: cast_nullable_to_non_nullable
                      as int,
            dribbling: null == dribbling
                ? _value.dribbling
                : dribbling // ignore: cast_nullable_to_non_nullable
                      as int,
            defending: null == defending
                ? _value.defending
                : defending // ignore: cast_nullable_to_non_nullable
                      as int,
            physicality: null == physicality
                ? _value.physicality
                : physicality // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FieldPlayerAttributesImplCopyWith<$Res>
    implements $FieldPlayerAttributesCopyWith<$Res> {
  factory _$$FieldPlayerAttributesImplCopyWith(
    _$FieldPlayerAttributesImpl value,
    $Res Function(_$FieldPlayerAttributesImpl) then,
  ) = __$$FieldPlayerAttributesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int pace,
    int shooting,
    int passing,
    int dribbling,
    int defending,
    int physicality,
  });
}

/// @nodoc
class __$$FieldPlayerAttributesImplCopyWithImpl<$Res>
    extends
        _$FieldPlayerAttributesCopyWithImpl<$Res, _$FieldPlayerAttributesImpl>
    implements _$$FieldPlayerAttributesImplCopyWith<$Res> {
  __$$FieldPlayerAttributesImplCopyWithImpl(
    _$FieldPlayerAttributesImpl _value,
    $Res Function(_$FieldPlayerAttributesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FieldPlayerAttributes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pace = null,
    Object? shooting = null,
    Object? passing = null,
    Object? dribbling = null,
    Object? defending = null,
    Object? physicality = null,
  }) {
    return _then(
      _$FieldPlayerAttributesImpl(
        pace: null == pace
            ? _value.pace
            : pace // ignore: cast_nullable_to_non_nullable
                  as int,
        shooting: null == shooting
            ? _value.shooting
            : shooting // ignore: cast_nullable_to_non_nullable
                  as int,
        passing: null == passing
            ? _value.passing
            : passing // ignore: cast_nullable_to_non_nullable
                  as int,
        dribbling: null == dribbling
            ? _value.dribbling
            : dribbling // ignore: cast_nullable_to_non_nullable
                  as int,
        defending: null == defending
            ? _value.defending
            : defending // ignore: cast_nullable_to_non_nullable
                  as int,
        physicality: null == physicality
            ? _value.physicality
            : physicality // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FieldPlayerAttributesImpl implements _FieldPlayerAttributes {
  const _$FieldPlayerAttributesImpl({
    required this.pace,
    required this.shooting,
    required this.passing,
    required this.dribbling,
    required this.defending,
    required this.physicality,
  });

  factory _$FieldPlayerAttributesImpl.fromJson(Map<String, dynamic> json) =>
      _$$FieldPlayerAttributesImplFromJson(json);

  @override
  final int pace;
  @override
  final int shooting;
  @override
  final int passing;
  @override
  final int dribbling;
  @override
  final int defending;
  @override
  final int physicality;

  @override
  String toString() {
    return 'FieldPlayerAttributes(pace: $pace, shooting: $shooting, passing: $passing, dribbling: $dribbling, defending: $defending, physicality: $physicality)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FieldPlayerAttributesImpl &&
            (identical(other.pace, pace) || other.pace == pace) &&
            (identical(other.shooting, shooting) ||
                other.shooting == shooting) &&
            (identical(other.passing, passing) || other.passing == passing) &&
            (identical(other.dribbling, dribbling) ||
                other.dribbling == dribbling) &&
            (identical(other.defending, defending) ||
                other.defending == defending) &&
            (identical(other.physicality, physicality) ||
                other.physicality == physicality));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    pace,
    shooting,
    passing,
    dribbling,
    defending,
    physicality,
  );

  /// Create a copy of FieldPlayerAttributes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FieldPlayerAttributesImplCopyWith<_$FieldPlayerAttributesImpl>
  get copyWith =>
      __$$FieldPlayerAttributesImplCopyWithImpl<_$FieldPlayerAttributesImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FieldPlayerAttributesImplToJson(this);
  }
}

abstract class _FieldPlayerAttributes implements FieldPlayerAttributes {
  const factory _FieldPlayerAttributes({
    required final int pace,
    required final int shooting,
    required final int passing,
    required final int dribbling,
    required final int defending,
    required final int physicality,
  }) = _$FieldPlayerAttributesImpl;

  factory _FieldPlayerAttributes.fromJson(Map<String, dynamic> json) =
      _$FieldPlayerAttributesImpl.fromJson;

  @override
  int get pace;
  @override
  int get shooting;
  @override
  int get passing;
  @override
  int get dribbling;
  @override
  int get defending;
  @override
  int get physicality;

  /// Create a copy of FieldPlayerAttributes
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FieldPlayerAttributesImplCopyWith<_$FieldPlayerAttributesImpl>
  get copyWith => throw _privateConstructorUsedError;
}
