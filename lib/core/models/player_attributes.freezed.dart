// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_attributes.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlayerAttributes _$PlayerAttributesFromJson(Map<String, dynamic> json) {
  switch (json['type']) {
    case 'outfield':
      return OutfieldPlayerAttributes.fromJson(json);
    case 'goalkeeper':
      return GoalkeeperPlayerAttributes.fromJson(json);

    default:
      throw CheckedFromJsonException(
        json,
        'type',
        'PlayerAttributes',
        'Invalid union type "${json['type']}"!',
      );
  }
}

/// @nodoc
mixin _$PlayerAttributes {
  Object get stats => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(FieldPlayerAttributes stats) outfield,
    required TResult Function(GoalkeeperAttributes stats) goalkeeper,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(FieldPlayerAttributes stats)? outfield,
    TResult? Function(GoalkeeperAttributes stats)? goalkeeper,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(FieldPlayerAttributes stats)? outfield,
    TResult Function(GoalkeeperAttributes stats)? goalkeeper,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OutfieldPlayerAttributes value) outfield,
    required TResult Function(GoalkeeperPlayerAttributes value) goalkeeper,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OutfieldPlayerAttributes value)? outfield,
    TResult? Function(GoalkeeperPlayerAttributes value)? goalkeeper,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OutfieldPlayerAttributes value)? outfield,
    TResult Function(GoalkeeperPlayerAttributes value)? goalkeeper,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this PlayerAttributes to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerAttributesCopyWith<$Res> {
  factory $PlayerAttributesCopyWith(
    PlayerAttributes value,
    $Res Function(PlayerAttributes) then,
  ) = _$PlayerAttributesCopyWithImpl<$Res, PlayerAttributes>;
}

/// @nodoc
class _$PlayerAttributesCopyWithImpl<$Res, $Val extends PlayerAttributes>
    implements $PlayerAttributesCopyWith<$Res> {
  _$PlayerAttributesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayerAttributes
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$OutfieldPlayerAttributesImplCopyWith<$Res> {
  factory _$$OutfieldPlayerAttributesImplCopyWith(
    _$OutfieldPlayerAttributesImpl value,
    $Res Function(_$OutfieldPlayerAttributesImpl) then,
  ) = __$$OutfieldPlayerAttributesImplCopyWithImpl<$Res>;
  @useResult
  $Res call({FieldPlayerAttributes stats});

  $FieldPlayerAttributesCopyWith<$Res> get stats;
}

/// @nodoc
class __$$OutfieldPlayerAttributesImplCopyWithImpl<$Res>
    extends _$PlayerAttributesCopyWithImpl<$Res, _$OutfieldPlayerAttributesImpl>
    implements _$$OutfieldPlayerAttributesImplCopyWith<$Res> {
  __$$OutfieldPlayerAttributesImplCopyWithImpl(
    _$OutfieldPlayerAttributesImpl _value,
    $Res Function(_$OutfieldPlayerAttributesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlayerAttributes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? stats = null}) {
    return _then(
      _$OutfieldPlayerAttributesImpl(
        stats: null == stats
            ? _value.stats
            : stats // ignore: cast_nullable_to_non_nullable
                  as FieldPlayerAttributes,
      ),
    );
  }

  /// Create a copy of PlayerAttributes
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FieldPlayerAttributesCopyWith<$Res> get stats {
    return $FieldPlayerAttributesCopyWith<$Res>(_value.stats, (value) {
      return _then(_value.copyWith(stats: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$OutfieldPlayerAttributesImpl implements OutfieldPlayerAttributes {
  const _$OutfieldPlayerAttributesImpl({
    required this.stats,
    final String? $type,
  }) : $type = $type ?? 'outfield';

  factory _$OutfieldPlayerAttributesImpl.fromJson(Map<String, dynamic> json) =>
      _$$OutfieldPlayerAttributesImplFromJson(json);

  @override
  final FieldPlayerAttributes stats;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'PlayerAttributes.outfield(stats: $stats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OutfieldPlayerAttributesImpl &&
            (identical(other.stats, stats) || other.stats == stats));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, stats);

  /// Create a copy of PlayerAttributes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OutfieldPlayerAttributesImplCopyWith<_$OutfieldPlayerAttributesImpl>
  get copyWith =>
      __$$OutfieldPlayerAttributesImplCopyWithImpl<
        _$OutfieldPlayerAttributesImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(FieldPlayerAttributes stats) outfield,
    required TResult Function(GoalkeeperAttributes stats) goalkeeper,
  }) {
    return outfield(stats);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(FieldPlayerAttributes stats)? outfield,
    TResult? Function(GoalkeeperAttributes stats)? goalkeeper,
  }) {
    return outfield?.call(stats);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(FieldPlayerAttributes stats)? outfield,
    TResult Function(GoalkeeperAttributes stats)? goalkeeper,
    required TResult orElse(),
  }) {
    if (outfield != null) {
      return outfield(stats);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OutfieldPlayerAttributes value) outfield,
    required TResult Function(GoalkeeperPlayerAttributes value) goalkeeper,
  }) {
    return outfield(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OutfieldPlayerAttributes value)? outfield,
    TResult? Function(GoalkeeperPlayerAttributes value)? goalkeeper,
  }) {
    return outfield?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OutfieldPlayerAttributes value)? outfield,
    TResult Function(GoalkeeperPlayerAttributes value)? goalkeeper,
    required TResult orElse(),
  }) {
    if (outfield != null) {
      return outfield(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$OutfieldPlayerAttributesImplToJson(this);
  }
}

abstract class OutfieldPlayerAttributes implements PlayerAttributes {
  const factory OutfieldPlayerAttributes({
    required final FieldPlayerAttributes stats,
  }) = _$OutfieldPlayerAttributesImpl;

  factory OutfieldPlayerAttributes.fromJson(Map<String, dynamic> json) =
      _$OutfieldPlayerAttributesImpl.fromJson;

  @override
  FieldPlayerAttributes get stats;

  /// Create a copy of PlayerAttributes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OutfieldPlayerAttributesImplCopyWith<_$OutfieldPlayerAttributesImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GoalkeeperPlayerAttributesImplCopyWith<$Res> {
  factory _$$GoalkeeperPlayerAttributesImplCopyWith(
    _$GoalkeeperPlayerAttributesImpl value,
    $Res Function(_$GoalkeeperPlayerAttributesImpl) then,
  ) = __$$GoalkeeperPlayerAttributesImplCopyWithImpl<$Res>;
  @useResult
  $Res call({GoalkeeperAttributes stats});

  $GoalkeeperAttributesCopyWith<$Res> get stats;
}

/// @nodoc
class __$$GoalkeeperPlayerAttributesImplCopyWithImpl<$Res>
    extends
        _$PlayerAttributesCopyWithImpl<$Res, _$GoalkeeperPlayerAttributesImpl>
    implements _$$GoalkeeperPlayerAttributesImplCopyWith<$Res> {
  __$$GoalkeeperPlayerAttributesImplCopyWithImpl(
    _$GoalkeeperPlayerAttributesImpl _value,
    $Res Function(_$GoalkeeperPlayerAttributesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlayerAttributes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? stats = null}) {
    return _then(
      _$GoalkeeperPlayerAttributesImpl(
        stats: null == stats
            ? _value.stats
            : stats // ignore: cast_nullable_to_non_nullable
                  as GoalkeeperAttributes,
      ),
    );
  }

  /// Create a copy of PlayerAttributes
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GoalkeeperAttributesCopyWith<$Res> get stats {
    return $GoalkeeperAttributesCopyWith<$Res>(_value.stats, (value) {
      return _then(_value.copyWith(stats: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _$GoalkeeperPlayerAttributesImpl implements GoalkeeperPlayerAttributes {
  const _$GoalkeeperPlayerAttributesImpl({
    required this.stats,
    final String? $type,
  }) : $type = $type ?? 'goalkeeper';

  factory _$GoalkeeperPlayerAttributesImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$GoalkeeperPlayerAttributesImplFromJson(json);

  @override
  final GoalkeeperAttributes stats;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'PlayerAttributes.goalkeeper(stats: $stats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoalkeeperPlayerAttributesImpl &&
            (identical(other.stats, stats) || other.stats == stats));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, stats);

  /// Create a copy of PlayerAttributes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoalkeeperPlayerAttributesImplCopyWith<_$GoalkeeperPlayerAttributesImpl>
  get copyWith =>
      __$$GoalkeeperPlayerAttributesImplCopyWithImpl<
        _$GoalkeeperPlayerAttributesImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(FieldPlayerAttributes stats) outfield,
    required TResult Function(GoalkeeperAttributes stats) goalkeeper,
  }) {
    return goalkeeper(stats);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(FieldPlayerAttributes stats)? outfield,
    TResult? Function(GoalkeeperAttributes stats)? goalkeeper,
  }) {
    return goalkeeper?.call(stats);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(FieldPlayerAttributes stats)? outfield,
    TResult Function(GoalkeeperAttributes stats)? goalkeeper,
    required TResult orElse(),
  }) {
    if (goalkeeper != null) {
      return goalkeeper(stats);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OutfieldPlayerAttributes value) outfield,
    required TResult Function(GoalkeeperPlayerAttributes value) goalkeeper,
  }) {
    return goalkeeper(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OutfieldPlayerAttributes value)? outfield,
    TResult? Function(GoalkeeperPlayerAttributes value)? goalkeeper,
  }) {
    return goalkeeper?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OutfieldPlayerAttributes value)? outfield,
    TResult Function(GoalkeeperPlayerAttributes value)? goalkeeper,
    required TResult orElse(),
  }) {
    if (goalkeeper != null) {
      return goalkeeper(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$GoalkeeperPlayerAttributesImplToJson(this);
  }
}

abstract class GoalkeeperPlayerAttributes implements PlayerAttributes {
  const factory GoalkeeperPlayerAttributes({
    required final GoalkeeperAttributes stats,
  }) = _$GoalkeeperPlayerAttributesImpl;

  factory GoalkeeperPlayerAttributes.fromJson(Map<String, dynamic> json) =
      _$GoalkeeperPlayerAttributesImpl.fromJson;

  @override
  GoalkeeperAttributes get stats;

  /// Create a copy of PlayerAttributes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoalkeeperPlayerAttributesImplCopyWith<_$GoalkeeperPlayerAttributesImpl>
  get copyWith => throw _privateConstructorUsedError;
}
