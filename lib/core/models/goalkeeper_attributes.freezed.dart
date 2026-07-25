// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goalkeeper_attributes.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GoalkeeperAttributes _$GoalkeeperAttributesFromJson(Map<String, dynamic> json) {
  return _GoalkeeperAttributes.fromJson(json);
}

/// @nodoc
mixin _$GoalkeeperAttributes {
  int get diving => throw _privateConstructorUsedError;
  int get handling => throw _privateConstructorUsedError;
  int get kicking => throw _privateConstructorUsedError;
  int get reflexes => throw _privateConstructorUsedError;
  int get speed => throw _privateConstructorUsedError;
  int get positioning => throw _privateConstructorUsedError;

  /// Serializes this GoalkeeperAttributes to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GoalkeeperAttributes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GoalkeeperAttributesCopyWith<GoalkeeperAttributes> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoalkeeperAttributesCopyWith<$Res> {
  factory $GoalkeeperAttributesCopyWith(
    GoalkeeperAttributes value,
    $Res Function(GoalkeeperAttributes) then,
  ) = _$GoalkeeperAttributesCopyWithImpl<$Res, GoalkeeperAttributes>;
  @useResult
  $Res call({
    int diving,
    int handling,
    int kicking,
    int reflexes,
    int speed,
    int positioning,
  });
}

/// @nodoc
class _$GoalkeeperAttributesCopyWithImpl<
  $Res,
  $Val extends GoalkeeperAttributes
>
    implements $GoalkeeperAttributesCopyWith<$Res> {
  _$GoalkeeperAttributesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GoalkeeperAttributes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? diving = null,
    Object? handling = null,
    Object? kicking = null,
    Object? reflexes = null,
    Object? speed = null,
    Object? positioning = null,
  }) {
    return _then(
      _value.copyWith(
            diving: null == diving
                ? _value.diving
                : diving // ignore: cast_nullable_to_non_nullable
                      as int,
            handling: null == handling
                ? _value.handling
                : handling // ignore: cast_nullable_to_non_nullable
                      as int,
            kicking: null == kicking
                ? _value.kicking
                : kicking // ignore: cast_nullable_to_non_nullable
                      as int,
            reflexes: null == reflexes
                ? _value.reflexes
                : reflexes // ignore: cast_nullable_to_non_nullable
                      as int,
            speed: null == speed
                ? _value.speed
                : speed // ignore: cast_nullable_to_non_nullable
                      as int,
            positioning: null == positioning
                ? _value.positioning
                : positioning // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GoalkeeperAttributesImplCopyWith<$Res>
    implements $GoalkeeperAttributesCopyWith<$Res> {
  factory _$$GoalkeeperAttributesImplCopyWith(
    _$GoalkeeperAttributesImpl value,
    $Res Function(_$GoalkeeperAttributesImpl) then,
  ) = __$$GoalkeeperAttributesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int diving,
    int handling,
    int kicking,
    int reflexes,
    int speed,
    int positioning,
  });
}

/// @nodoc
class __$$GoalkeeperAttributesImplCopyWithImpl<$Res>
    extends _$GoalkeeperAttributesCopyWithImpl<$Res, _$GoalkeeperAttributesImpl>
    implements _$$GoalkeeperAttributesImplCopyWith<$Res> {
  __$$GoalkeeperAttributesImplCopyWithImpl(
    _$GoalkeeperAttributesImpl _value,
    $Res Function(_$GoalkeeperAttributesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GoalkeeperAttributes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? diving = null,
    Object? handling = null,
    Object? kicking = null,
    Object? reflexes = null,
    Object? speed = null,
    Object? positioning = null,
  }) {
    return _then(
      _$GoalkeeperAttributesImpl(
        diving: null == diving
            ? _value.diving
            : diving // ignore: cast_nullable_to_non_nullable
                  as int,
        handling: null == handling
            ? _value.handling
            : handling // ignore: cast_nullable_to_non_nullable
                  as int,
        kicking: null == kicking
            ? _value.kicking
            : kicking // ignore: cast_nullable_to_non_nullable
                  as int,
        reflexes: null == reflexes
            ? _value.reflexes
            : reflexes // ignore: cast_nullable_to_non_nullable
                  as int,
        speed: null == speed
            ? _value.speed
            : speed // ignore: cast_nullable_to_non_nullable
                  as int,
        positioning: null == positioning
            ? _value.positioning
            : positioning // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GoalkeeperAttributesImpl implements _GoalkeeperAttributes {
  const _$GoalkeeperAttributesImpl({
    required this.diving,
    required this.handling,
    required this.kicking,
    required this.reflexes,
    required this.speed,
    required this.positioning,
  });

  factory _$GoalkeeperAttributesImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoalkeeperAttributesImplFromJson(json);

  @override
  final int diving;
  @override
  final int handling;
  @override
  final int kicking;
  @override
  final int reflexes;
  @override
  final int speed;
  @override
  final int positioning;

  @override
  String toString() {
    return 'GoalkeeperAttributes(diving: $diving, handling: $handling, kicking: $kicking, reflexes: $reflexes, speed: $speed, positioning: $positioning)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoalkeeperAttributesImpl &&
            (identical(other.diving, diving) || other.diving == diving) &&
            (identical(other.handling, handling) ||
                other.handling == handling) &&
            (identical(other.kicking, kicking) || other.kicking == kicking) &&
            (identical(other.reflexes, reflexes) ||
                other.reflexes == reflexes) &&
            (identical(other.speed, speed) || other.speed == speed) &&
            (identical(other.positioning, positioning) ||
                other.positioning == positioning));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    diving,
    handling,
    kicking,
    reflexes,
    speed,
    positioning,
  );

  /// Create a copy of GoalkeeperAttributes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoalkeeperAttributesImplCopyWith<_$GoalkeeperAttributesImpl>
  get copyWith =>
      __$$GoalkeeperAttributesImplCopyWithImpl<_$GoalkeeperAttributesImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GoalkeeperAttributesImplToJson(this);
  }
}

abstract class _GoalkeeperAttributes implements GoalkeeperAttributes {
  const factory _GoalkeeperAttributes({
    required final int diving,
    required final int handling,
    required final int kicking,
    required final int reflexes,
    required final int speed,
    required final int positioning,
  }) = _$GoalkeeperAttributesImpl;

  factory _GoalkeeperAttributes.fromJson(Map<String, dynamic> json) =
      _$GoalkeeperAttributesImpl.fromJson;

  @override
  int get diving;
  @override
  int get handling;
  @override
  int get kicking;
  @override
  int get reflexes;
  @override
  int get speed;
  @override
  int get positioning;

  /// Create a copy of GoalkeeperAttributes
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoalkeeperAttributesImplCopyWith<_$GoalkeeperAttributesImpl>
  get copyWith => throw _privateConstructorUsedError;
}
