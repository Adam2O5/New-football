// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'injury.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Injury _$InjuryFromJson(Map<String, dynamic> json) {
  return _Injury.fromJson(json);
}

/// @nodoc
mixin _$Injury {
  String get id => throw _privateConstructorUsedError;
  InjuryGroup get group => throw _privateConstructorUsedError;
  InjuryType get type => throw _privateConstructorUsedError;
  int get daysTotal => throw _privateConstructorUsedError;
  int get daysRemaining => throw _privateConstructorUsedError;

  /// Serializes this Injury to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Injury
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InjuryCopyWith<Injury> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InjuryCopyWith<$Res> {
  factory $InjuryCopyWith(Injury value, $Res Function(Injury) then) =
      _$InjuryCopyWithImpl<$Res, Injury>;
  @useResult
  $Res call({
    String id,
    InjuryGroup group,
    InjuryType type,
    int daysTotal,
    int daysRemaining,
  });
}

/// @nodoc
class _$InjuryCopyWithImpl<$Res, $Val extends Injury>
    implements $InjuryCopyWith<$Res> {
  _$InjuryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Injury
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? group = null,
    Object? type = null,
    Object? daysTotal = null,
    Object? daysRemaining = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            group: null == group
                ? _value.group
                : group // ignore: cast_nullable_to_non_nullable
                      as InjuryGroup,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as InjuryType,
            daysTotal: null == daysTotal
                ? _value.daysTotal
                : daysTotal // ignore: cast_nullable_to_non_nullable
                      as int,
            daysRemaining: null == daysRemaining
                ? _value.daysRemaining
                : daysRemaining // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InjuryImplCopyWith<$Res> implements $InjuryCopyWith<$Res> {
  factory _$$InjuryImplCopyWith(
    _$InjuryImpl value,
    $Res Function(_$InjuryImpl) then,
  ) = __$$InjuryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    InjuryGroup group,
    InjuryType type,
    int daysTotal,
    int daysRemaining,
  });
}

/// @nodoc
class __$$InjuryImplCopyWithImpl<$Res>
    extends _$InjuryCopyWithImpl<$Res, _$InjuryImpl>
    implements _$$InjuryImplCopyWith<$Res> {
  __$$InjuryImplCopyWithImpl(
    _$InjuryImpl _value,
    $Res Function(_$InjuryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Injury
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? group = null,
    Object? type = null,
    Object? daysTotal = null,
    Object? daysRemaining = null,
  }) {
    return _then(
      _$InjuryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        group: null == group
            ? _value.group
            : group // ignore: cast_nullable_to_non_nullable
                  as InjuryGroup,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as InjuryType,
        daysTotal: null == daysTotal
            ? _value.daysTotal
            : daysTotal // ignore: cast_nullable_to_non_nullable
                  as int,
        daysRemaining: null == daysRemaining
            ? _value.daysRemaining
            : daysRemaining // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InjuryImpl implements _Injury {
  const _$InjuryImpl({
    required this.id,
    required this.group,
    required this.type,
    required this.daysTotal,
    required this.daysRemaining,
  });

  factory _$InjuryImpl.fromJson(Map<String, dynamic> json) =>
      _$$InjuryImplFromJson(json);

  @override
  final String id;
  @override
  final InjuryGroup group;
  @override
  final InjuryType type;
  @override
  final int daysTotal;
  @override
  final int daysRemaining;

  @override
  String toString() {
    return 'Injury(id: $id, group: $group, type: $type, daysTotal: $daysTotal, daysRemaining: $daysRemaining)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InjuryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.group, group) || other.group == group) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.daysTotal, daysTotal) ||
                other.daysTotal == daysTotal) &&
            (identical(other.daysRemaining, daysRemaining) ||
                other.daysRemaining == daysRemaining));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, group, type, daysTotal, daysRemaining);

  /// Create a copy of Injury
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InjuryImplCopyWith<_$InjuryImpl> get copyWith =>
      __$$InjuryImplCopyWithImpl<_$InjuryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InjuryImplToJson(this);
  }
}

abstract class _Injury implements Injury {
  const factory _Injury({
    required final String id,
    required final InjuryGroup group,
    required final InjuryType type,
    required final int daysTotal,
    required final int daysRemaining,
  }) = _$InjuryImpl;

  factory _Injury.fromJson(Map<String, dynamic> json) = _$InjuryImpl.fromJson;

  @override
  String get id;
  @override
  InjuryGroup get group;
  @override
  InjuryType get type;
  @override
  int get daysTotal;
  @override
  int get daysRemaining;

  /// Create a copy of Injury
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InjuryImplCopyWith<_$InjuryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
