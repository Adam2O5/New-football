// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assigned_role.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AssignedRole _$AssignedRoleFromJson(Map<String, dynamic> json) {
  switch (json['type']) {
    case 'gk':
      return AssignedGkRole.fromJson(json);
    case 'cb':
      return AssignedCbRole.fromJson(json);
    case 'fullBack':
      return AssignedFullBackRole.fromJson(json);
    case 'wingBack':
      return AssignedWingBackRole.fromJson(json);
    case 'cdm':
      return AssignedCdmRole.fromJson(json);
    case 'cm':
      return AssignedCmRole.fromJson(json);
    case 'cam':
      return AssignedCamRole.fromJson(json);
    case 'winger':
      return AssignedWingerRole.fromJson(json);
    case 'striker':
      return AssignedStrikerRole.fromJson(json);

    default:
      throw CheckedFromJsonException(
        json,
        'type',
        'AssignedRole',
        'Invalid union type "${json['type']}"!',
      );
  }
}

/// @nodoc
mixin _$AssignedRole {
  Enum get role => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(GkRole role) gk,
    required TResult Function(CbRole role) cb,
    required TResult Function(FullBackRole role) fullBack,
    required TResult Function(WingBackRole role) wingBack,
    required TResult Function(CdmRole role) cdm,
    required TResult Function(CmRole role) cm,
    required TResult Function(CamRole role) cam,
    required TResult Function(WingerRole role) winger,
    required TResult Function(StrikerRole role) striker,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(GkRole role)? gk,
    TResult? Function(CbRole role)? cb,
    TResult? Function(FullBackRole role)? fullBack,
    TResult? Function(WingBackRole role)? wingBack,
    TResult? Function(CdmRole role)? cdm,
    TResult? Function(CmRole role)? cm,
    TResult? Function(CamRole role)? cam,
    TResult? Function(WingerRole role)? winger,
    TResult? Function(StrikerRole role)? striker,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(GkRole role)? gk,
    TResult Function(CbRole role)? cb,
    TResult Function(FullBackRole role)? fullBack,
    TResult Function(WingBackRole role)? wingBack,
    TResult Function(CdmRole role)? cdm,
    TResult Function(CmRole role)? cm,
    TResult Function(CamRole role)? cam,
    TResult Function(WingerRole role)? winger,
    TResult Function(StrikerRole role)? striker,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AssignedGkRole value) gk,
    required TResult Function(AssignedCbRole value) cb,
    required TResult Function(AssignedFullBackRole value) fullBack,
    required TResult Function(AssignedWingBackRole value) wingBack,
    required TResult Function(AssignedCdmRole value) cdm,
    required TResult Function(AssignedCmRole value) cm,
    required TResult Function(AssignedCamRole value) cam,
    required TResult Function(AssignedWingerRole value) winger,
    required TResult Function(AssignedStrikerRole value) striker,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AssignedGkRole value)? gk,
    TResult? Function(AssignedCbRole value)? cb,
    TResult? Function(AssignedFullBackRole value)? fullBack,
    TResult? Function(AssignedWingBackRole value)? wingBack,
    TResult? Function(AssignedCdmRole value)? cdm,
    TResult? Function(AssignedCmRole value)? cm,
    TResult? Function(AssignedCamRole value)? cam,
    TResult? Function(AssignedWingerRole value)? winger,
    TResult? Function(AssignedStrikerRole value)? striker,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AssignedGkRole value)? gk,
    TResult Function(AssignedCbRole value)? cb,
    TResult Function(AssignedFullBackRole value)? fullBack,
    TResult Function(AssignedWingBackRole value)? wingBack,
    TResult Function(AssignedCdmRole value)? cdm,
    TResult Function(AssignedCmRole value)? cm,
    TResult Function(AssignedCamRole value)? cam,
    TResult Function(AssignedWingerRole value)? winger,
    TResult Function(AssignedStrikerRole value)? striker,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this AssignedRole to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AssignedRoleCopyWith<$Res> {
  factory $AssignedRoleCopyWith(
    AssignedRole value,
    $Res Function(AssignedRole) then,
  ) = _$AssignedRoleCopyWithImpl<$Res, AssignedRole>;
}

/// @nodoc
class _$AssignedRoleCopyWithImpl<$Res, $Val extends AssignedRole>
    implements $AssignedRoleCopyWith<$Res> {
  _$AssignedRoleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$AssignedGkRoleImplCopyWith<$Res> {
  factory _$$AssignedGkRoleImplCopyWith(
    _$AssignedGkRoleImpl value,
    $Res Function(_$AssignedGkRoleImpl) then,
  ) = __$$AssignedGkRoleImplCopyWithImpl<$Res>;
  @useResult
  $Res call({GkRole role});
}

/// @nodoc
class __$$AssignedGkRoleImplCopyWithImpl<$Res>
    extends _$AssignedRoleCopyWithImpl<$Res, _$AssignedGkRoleImpl>
    implements _$$AssignedGkRoleImplCopyWith<$Res> {
  __$$AssignedGkRoleImplCopyWithImpl(
    _$AssignedGkRoleImpl _value,
    $Res Function(_$AssignedGkRoleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? role = null}) {
    return _then(
      _$AssignedGkRoleImpl(
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as GkRole,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssignedGkRoleImpl implements AssignedGkRole {
  const _$AssignedGkRoleImpl({this.role = GkRole.standard, final String? $type})
    : $type = $type ?? 'gk';

  factory _$AssignedGkRoleImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssignedGkRoleImplFromJson(json);

  @override
  @JsonKey()
  final GkRole role;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'AssignedRole.gk(role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignedGkRoleImpl &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, role);

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignedGkRoleImplCopyWith<_$AssignedGkRoleImpl> get copyWith =>
      __$$AssignedGkRoleImplCopyWithImpl<_$AssignedGkRoleImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(GkRole role) gk,
    required TResult Function(CbRole role) cb,
    required TResult Function(FullBackRole role) fullBack,
    required TResult Function(WingBackRole role) wingBack,
    required TResult Function(CdmRole role) cdm,
    required TResult Function(CmRole role) cm,
    required TResult Function(CamRole role) cam,
    required TResult Function(WingerRole role) winger,
    required TResult Function(StrikerRole role) striker,
  }) {
    return gk(role);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(GkRole role)? gk,
    TResult? Function(CbRole role)? cb,
    TResult? Function(FullBackRole role)? fullBack,
    TResult? Function(WingBackRole role)? wingBack,
    TResult? Function(CdmRole role)? cdm,
    TResult? Function(CmRole role)? cm,
    TResult? Function(CamRole role)? cam,
    TResult? Function(WingerRole role)? winger,
    TResult? Function(StrikerRole role)? striker,
  }) {
    return gk?.call(role);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(GkRole role)? gk,
    TResult Function(CbRole role)? cb,
    TResult Function(FullBackRole role)? fullBack,
    TResult Function(WingBackRole role)? wingBack,
    TResult Function(CdmRole role)? cdm,
    TResult Function(CmRole role)? cm,
    TResult Function(CamRole role)? cam,
    TResult Function(WingerRole role)? winger,
    TResult Function(StrikerRole role)? striker,
    required TResult orElse(),
  }) {
    if (gk != null) {
      return gk(role);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AssignedGkRole value) gk,
    required TResult Function(AssignedCbRole value) cb,
    required TResult Function(AssignedFullBackRole value) fullBack,
    required TResult Function(AssignedWingBackRole value) wingBack,
    required TResult Function(AssignedCdmRole value) cdm,
    required TResult Function(AssignedCmRole value) cm,
    required TResult Function(AssignedCamRole value) cam,
    required TResult Function(AssignedWingerRole value) winger,
    required TResult Function(AssignedStrikerRole value) striker,
  }) {
    return gk(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AssignedGkRole value)? gk,
    TResult? Function(AssignedCbRole value)? cb,
    TResult? Function(AssignedFullBackRole value)? fullBack,
    TResult? Function(AssignedWingBackRole value)? wingBack,
    TResult? Function(AssignedCdmRole value)? cdm,
    TResult? Function(AssignedCmRole value)? cm,
    TResult? Function(AssignedCamRole value)? cam,
    TResult? Function(AssignedWingerRole value)? winger,
    TResult? Function(AssignedStrikerRole value)? striker,
  }) {
    return gk?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AssignedGkRole value)? gk,
    TResult Function(AssignedCbRole value)? cb,
    TResult Function(AssignedFullBackRole value)? fullBack,
    TResult Function(AssignedWingBackRole value)? wingBack,
    TResult Function(AssignedCdmRole value)? cdm,
    TResult Function(AssignedCmRole value)? cm,
    TResult Function(AssignedCamRole value)? cam,
    TResult Function(AssignedWingerRole value)? winger,
    TResult Function(AssignedStrikerRole value)? striker,
    required TResult orElse(),
  }) {
    if (gk != null) {
      return gk(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$AssignedGkRoleImplToJson(this);
  }
}

abstract class AssignedGkRole implements AssignedRole {
  const factory AssignedGkRole({final GkRole role}) = _$AssignedGkRoleImpl;

  factory AssignedGkRole.fromJson(Map<String, dynamic> json) =
      _$AssignedGkRoleImpl.fromJson;

  @override
  GkRole get role;

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignedGkRoleImplCopyWith<_$AssignedGkRoleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AssignedCbRoleImplCopyWith<$Res> {
  factory _$$AssignedCbRoleImplCopyWith(
    _$AssignedCbRoleImpl value,
    $Res Function(_$AssignedCbRoleImpl) then,
  ) = __$$AssignedCbRoleImplCopyWithImpl<$Res>;
  @useResult
  $Res call({CbRole role});
}

/// @nodoc
class __$$AssignedCbRoleImplCopyWithImpl<$Res>
    extends _$AssignedRoleCopyWithImpl<$Res, _$AssignedCbRoleImpl>
    implements _$$AssignedCbRoleImplCopyWith<$Res> {
  __$$AssignedCbRoleImplCopyWithImpl(
    _$AssignedCbRoleImpl _value,
    $Res Function(_$AssignedCbRoleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? role = null}) {
    return _then(
      _$AssignedCbRoleImpl(
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as CbRole,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssignedCbRoleImpl implements AssignedCbRole {
  const _$AssignedCbRoleImpl({this.role = CbRole.standard, final String? $type})
    : $type = $type ?? 'cb';

  factory _$AssignedCbRoleImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssignedCbRoleImplFromJson(json);

  @override
  @JsonKey()
  final CbRole role;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'AssignedRole.cb(role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignedCbRoleImpl &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, role);

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignedCbRoleImplCopyWith<_$AssignedCbRoleImpl> get copyWith =>
      __$$AssignedCbRoleImplCopyWithImpl<_$AssignedCbRoleImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(GkRole role) gk,
    required TResult Function(CbRole role) cb,
    required TResult Function(FullBackRole role) fullBack,
    required TResult Function(WingBackRole role) wingBack,
    required TResult Function(CdmRole role) cdm,
    required TResult Function(CmRole role) cm,
    required TResult Function(CamRole role) cam,
    required TResult Function(WingerRole role) winger,
    required TResult Function(StrikerRole role) striker,
  }) {
    return cb(role);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(GkRole role)? gk,
    TResult? Function(CbRole role)? cb,
    TResult? Function(FullBackRole role)? fullBack,
    TResult? Function(WingBackRole role)? wingBack,
    TResult? Function(CdmRole role)? cdm,
    TResult? Function(CmRole role)? cm,
    TResult? Function(CamRole role)? cam,
    TResult? Function(WingerRole role)? winger,
    TResult? Function(StrikerRole role)? striker,
  }) {
    return cb?.call(role);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(GkRole role)? gk,
    TResult Function(CbRole role)? cb,
    TResult Function(FullBackRole role)? fullBack,
    TResult Function(WingBackRole role)? wingBack,
    TResult Function(CdmRole role)? cdm,
    TResult Function(CmRole role)? cm,
    TResult Function(CamRole role)? cam,
    TResult Function(WingerRole role)? winger,
    TResult Function(StrikerRole role)? striker,
    required TResult orElse(),
  }) {
    if (cb != null) {
      return cb(role);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AssignedGkRole value) gk,
    required TResult Function(AssignedCbRole value) cb,
    required TResult Function(AssignedFullBackRole value) fullBack,
    required TResult Function(AssignedWingBackRole value) wingBack,
    required TResult Function(AssignedCdmRole value) cdm,
    required TResult Function(AssignedCmRole value) cm,
    required TResult Function(AssignedCamRole value) cam,
    required TResult Function(AssignedWingerRole value) winger,
    required TResult Function(AssignedStrikerRole value) striker,
  }) {
    return cb(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AssignedGkRole value)? gk,
    TResult? Function(AssignedCbRole value)? cb,
    TResult? Function(AssignedFullBackRole value)? fullBack,
    TResult? Function(AssignedWingBackRole value)? wingBack,
    TResult? Function(AssignedCdmRole value)? cdm,
    TResult? Function(AssignedCmRole value)? cm,
    TResult? Function(AssignedCamRole value)? cam,
    TResult? Function(AssignedWingerRole value)? winger,
    TResult? Function(AssignedStrikerRole value)? striker,
  }) {
    return cb?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AssignedGkRole value)? gk,
    TResult Function(AssignedCbRole value)? cb,
    TResult Function(AssignedFullBackRole value)? fullBack,
    TResult Function(AssignedWingBackRole value)? wingBack,
    TResult Function(AssignedCdmRole value)? cdm,
    TResult Function(AssignedCmRole value)? cm,
    TResult Function(AssignedCamRole value)? cam,
    TResult Function(AssignedWingerRole value)? winger,
    TResult Function(AssignedStrikerRole value)? striker,
    required TResult orElse(),
  }) {
    if (cb != null) {
      return cb(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$AssignedCbRoleImplToJson(this);
  }
}

abstract class AssignedCbRole implements AssignedRole {
  const factory AssignedCbRole({final CbRole role}) = _$AssignedCbRoleImpl;

  factory AssignedCbRole.fromJson(Map<String, dynamic> json) =
      _$AssignedCbRoleImpl.fromJson;

  @override
  CbRole get role;

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignedCbRoleImplCopyWith<_$AssignedCbRoleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AssignedFullBackRoleImplCopyWith<$Res> {
  factory _$$AssignedFullBackRoleImplCopyWith(
    _$AssignedFullBackRoleImpl value,
    $Res Function(_$AssignedFullBackRoleImpl) then,
  ) = __$$AssignedFullBackRoleImplCopyWithImpl<$Res>;
  @useResult
  $Res call({FullBackRole role});
}

/// @nodoc
class __$$AssignedFullBackRoleImplCopyWithImpl<$Res>
    extends _$AssignedRoleCopyWithImpl<$Res, _$AssignedFullBackRoleImpl>
    implements _$$AssignedFullBackRoleImplCopyWith<$Res> {
  __$$AssignedFullBackRoleImplCopyWithImpl(
    _$AssignedFullBackRoleImpl _value,
    $Res Function(_$AssignedFullBackRoleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? role = null}) {
    return _then(
      _$AssignedFullBackRoleImpl(
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as FullBackRole,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssignedFullBackRoleImpl implements AssignedFullBackRole {
  const _$AssignedFullBackRoleImpl({
    this.role = FullBackRole.standard,
    final String? $type,
  }) : $type = $type ?? 'fullBack';

  factory _$AssignedFullBackRoleImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssignedFullBackRoleImplFromJson(json);

  @override
  @JsonKey()
  final FullBackRole role;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'AssignedRole.fullBack(role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignedFullBackRoleImpl &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, role);

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignedFullBackRoleImplCopyWith<_$AssignedFullBackRoleImpl>
  get copyWith =>
      __$$AssignedFullBackRoleImplCopyWithImpl<_$AssignedFullBackRoleImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(GkRole role) gk,
    required TResult Function(CbRole role) cb,
    required TResult Function(FullBackRole role) fullBack,
    required TResult Function(WingBackRole role) wingBack,
    required TResult Function(CdmRole role) cdm,
    required TResult Function(CmRole role) cm,
    required TResult Function(CamRole role) cam,
    required TResult Function(WingerRole role) winger,
    required TResult Function(StrikerRole role) striker,
  }) {
    return fullBack(role);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(GkRole role)? gk,
    TResult? Function(CbRole role)? cb,
    TResult? Function(FullBackRole role)? fullBack,
    TResult? Function(WingBackRole role)? wingBack,
    TResult? Function(CdmRole role)? cdm,
    TResult? Function(CmRole role)? cm,
    TResult? Function(CamRole role)? cam,
    TResult? Function(WingerRole role)? winger,
    TResult? Function(StrikerRole role)? striker,
  }) {
    return fullBack?.call(role);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(GkRole role)? gk,
    TResult Function(CbRole role)? cb,
    TResult Function(FullBackRole role)? fullBack,
    TResult Function(WingBackRole role)? wingBack,
    TResult Function(CdmRole role)? cdm,
    TResult Function(CmRole role)? cm,
    TResult Function(CamRole role)? cam,
    TResult Function(WingerRole role)? winger,
    TResult Function(StrikerRole role)? striker,
    required TResult orElse(),
  }) {
    if (fullBack != null) {
      return fullBack(role);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AssignedGkRole value) gk,
    required TResult Function(AssignedCbRole value) cb,
    required TResult Function(AssignedFullBackRole value) fullBack,
    required TResult Function(AssignedWingBackRole value) wingBack,
    required TResult Function(AssignedCdmRole value) cdm,
    required TResult Function(AssignedCmRole value) cm,
    required TResult Function(AssignedCamRole value) cam,
    required TResult Function(AssignedWingerRole value) winger,
    required TResult Function(AssignedStrikerRole value) striker,
  }) {
    return fullBack(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AssignedGkRole value)? gk,
    TResult? Function(AssignedCbRole value)? cb,
    TResult? Function(AssignedFullBackRole value)? fullBack,
    TResult? Function(AssignedWingBackRole value)? wingBack,
    TResult? Function(AssignedCdmRole value)? cdm,
    TResult? Function(AssignedCmRole value)? cm,
    TResult? Function(AssignedCamRole value)? cam,
    TResult? Function(AssignedWingerRole value)? winger,
    TResult? Function(AssignedStrikerRole value)? striker,
  }) {
    return fullBack?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AssignedGkRole value)? gk,
    TResult Function(AssignedCbRole value)? cb,
    TResult Function(AssignedFullBackRole value)? fullBack,
    TResult Function(AssignedWingBackRole value)? wingBack,
    TResult Function(AssignedCdmRole value)? cdm,
    TResult Function(AssignedCmRole value)? cm,
    TResult Function(AssignedCamRole value)? cam,
    TResult Function(AssignedWingerRole value)? winger,
    TResult Function(AssignedStrikerRole value)? striker,
    required TResult orElse(),
  }) {
    if (fullBack != null) {
      return fullBack(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$AssignedFullBackRoleImplToJson(this);
  }
}

abstract class AssignedFullBackRole implements AssignedRole {
  const factory AssignedFullBackRole({final FullBackRole role}) =
      _$AssignedFullBackRoleImpl;

  factory AssignedFullBackRole.fromJson(Map<String, dynamic> json) =
      _$AssignedFullBackRoleImpl.fromJson;

  @override
  FullBackRole get role;

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignedFullBackRoleImplCopyWith<_$AssignedFullBackRoleImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AssignedWingBackRoleImplCopyWith<$Res> {
  factory _$$AssignedWingBackRoleImplCopyWith(
    _$AssignedWingBackRoleImpl value,
    $Res Function(_$AssignedWingBackRoleImpl) then,
  ) = __$$AssignedWingBackRoleImplCopyWithImpl<$Res>;
  @useResult
  $Res call({WingBackRole role});
}

/// @nodoc
class __$$AssignedWingBackRoleImplCopyWithImpl<$Res>
    extends _$AssignedRoleCopyWithImpl<$Res, _$AssignedWingBackRoleImpl>
    implements _$$AssignedWingBackRoleImplCopyWith<$Res> {
  __$$AssignedWingBackRoleImplCopyWithImpl(
    _$AssignedWingBackRoleImpl _value,
    $Res Function(_$AssignedWingBackRoleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? role = null}) {
    return _then(
      _$AssignedWingBackRoleImpl(
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as WingBackRole,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssignedWingBackRoleImpl implements AssignedWingBackRole {
  const _$AssignedWingBackRoleImpl({
    this.role = WingBackRole.standard,
    final String? $type,
  }) : $type = $type ?? 'wingBack';

  factory _$AssignedWingBackRoleImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssignedWingBackRoleImplFromJson(json);

  @override
  @JsonKey()
  final WingBackRole role;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'AssignedRole.wingBack(role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignedWingBackRoleImpl &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, role);

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignedWingBackRoleImplCopyWith<_$AssignedWingBackRoleImpl>
  get copyWith =>
      __$$AssignedWingBackRoleImplCopyWithImpl<_$AssignedWingBackRoleImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(GkRole role) gk,
    required TResult Function(CbRole role) cb,
    required TResult Function(FullBackRole role) fullBack,
    required TResult Function(WingBackRole role) wingBack,
    required TResult Function(CdmRole role) cdm,
    required TResult Function(CmRole role) cm,
    required TResult Function(CamRole role) cam,
    required TResult Function(WingerRole role) winger,
    required TResult Function(StrikerRole role) striker,
  }) {
    return wingBack(role);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(GkRole role)? gk,
    TResult? Function(CbRole role)? cb,
    TResult? Function(FullBackRole role)? fullBack,
    TResult? Function(WingBackRole role)? wingBack,
    TResult? Function(CdmRole role)? cdm,
    TResult? Function(CmRole role)? cm,
    TResult? Function(CamRole role)? cam,
    TResult? Function(WingerRole role)? winger,
    TResult? Function(StrikerRole role)? striker,
  }) {
    return wingBack?.call(role);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(GkRole role)? gk,
    TResult Function(CbRole role)? cb,
    TResult Function(FullBackRole role)? fullBack,
    TResult Function(WingBackRole role)? wingBack,
    TResult Function(CdmRole role)? cdm,
    TResult Function(CmRole role)? cm,
    TResult Function(CamRole role)? cam,
    TResult Function(WingerRole role)? winger,
    TResult Function(StrikerRole role)? striker,
    required TResult orElse(),
  }) {
    if (wingBack != null) {
      return wingBack(role);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AssignedGkRole value) gk,
    required TResult Function(AssignedCbRole value) cb,
    required TResult Function(AssignedFullBackRole value) fullBack,
    required TResult Function(AssignedWingBackRole value) wingBack,
    required TResult Function(AssignedCdmRole value) cdm,
    required TResult Function(AssignedCmRole value) cm,
    required TResult Function(AssignedCamRole value) cam,
    required TResult Function(AssignedWingerRole value) winger,
    required TResult Function(AssignedStrikerRole value) striker,
  }) {
    return wingBack(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AssignedGkRole value)? gk,
    TResult? Function(AssignedCbRole value)? cb,
    TResult? Function(AssignedFullBackRole value)? fullBack,
    TResult? Function(AssignedWingBackRole value)? wingBack,
    TResult? Function(AssignedCdmRole value)? cdm,
    TResult? Function(AssignedCmRole value)? cm,
    TResult? Function(AssignedCamRole value)? cam,
    TResult? Function(AssignedWingerRole value)? winger,
    TResult? Function(AssignedStrikerRole value)? striker,
  }) {
    return wingBack?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AssignedGkRole value)? gk,
    TResult Function(AssignedCbRole value)? cb,
    TResult Function(AssignedFullBackRole value)? fullBack,
    TResult Function(AssignedWingBackRole value)? wingBack,
    TResult Function(AssignedCdmRole value)? cdm,
    TResult Function(AssignedCmRole value)? cm,
    TResult Function(AssignedCamRole value)? cam,
    TResult Function(AssignedWingerRole value)? winger,
    TResult Function(AssignedStrikerRole value)? striker,
    required TResult orElse(),
  }) {
    if (wingBack != null) {
      return wingBack(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$AssignedWingBackRoleImplToJson(this);
  }
}

abstract class AssignedWingBackRole implements AssignedRole {
  const factory AssignedWingBackRole({final WingBackRole role}) =
      _$AssignedWingBackRoleImpl;

  factory AssignedWingBackRole.fromJson(Map<String, dynamic> json) =
      _$AssignedWingBackRoleImpl.fromJson;

  @override
  WingBackRole get role;

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignedWingBackRoleImplCopyWith<_$AssignedWingBackRoleImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AssignedCdmRoleImplCopyWith<$Res> {
  factory _$$AssignedCdmRoleImplCopyWith(
    _$AssignedCdmRoleImpl value,
    $Res Function(_$AssignedCdmRoleImpl) then,
  ) = __$$AssignedCdmRoleImplCopyWithImpl<$Res>;
  @useResult
  $Res call({CdmRole role});
}

/// @nodoc
class __$$AssignedCdmRoleImplCopyWithImpl<$Res>
    extends _$AssignedRoleCopyWithImpl<$Res, _$AssignedCdmRoleImpl>
    implements _$$AssignedCdmRoleImplCopyWith<$Res> {
  __$$AssignedCdmRoleImplCopyWithImpl(
    _$AssignedCdmRoleImpl _value,
    $Res Function(_$AssignedCdmRoleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? role = null}) {
    return _then(
      _$AssignedCdmRoleImpl(
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as CdmRole,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssignedCdmRoleImpl implements AssignedCdmRole {
  const _$AssignedCdmRoleImpl({
    this.role = CdmRole.standard,
    final String? $type,
  }) : $type = $type ?? 'cdm';

  factory _$AssignedCdmRoleImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssignedCdmRoleImplFromJson(json);

  @override
  @JsonKey()
  final CdmRole role;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'AssignedRole.cdm(role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignedCdmRoleImpl &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, role);

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignedCdmRoleImplCopyWith<_$AssignedCdmRoleImpl> get copyWith =>
      __$$AssignedCdmRoleImplCopyWithImpl<_$AssignedCdmRoleImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(GkRole role) gk,
    required TResult Function(CbRole role) cb,
    required TResult Function(FullBackRole role) fullBack,
    required TResult Function(WingBackRole role) wingBack,
    required TResult Function(CdmRole role) cdm,
    required TResult Function(CmRole role) cm,
    required TResult Function(CamRole role) cam,
    required TResult Function(WingerRole role) winger,
    required TResult Function(StrikerRole role) striker,
  }) {
    return cdm(role);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(GkRole role)? gk,
    TResult? Function(CbRole role)? cb,
    TResult? Function(FullBackRole role)? fullBack,
    TResult? Function(WingBackRole role)? wingBack,
    TResult? Function(CdmRole role)? cdm,
    TResult? Function(CmRole role)? cm,
    TResult? Function(CamRole role)? cam,
    TResult? Function(WingerRole role)? winger,
    TResult? Function(StrikerRole role)? striker,
  }) {
    return cdm?.call(role);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(GkRole role)? gk,
    TResult Function(CbRole role)? cb,
    TResult Function(FullBackRole role)? fullBack,
    TResult Function(WingBackRole role)? wingBack,
    TResult Function(CdmRole role)? cdm,
    TResult Function(CmRole role)? cm,
    TResult Function(CamRole role)? cam,
    TResult Function(WingerRole role)? winger,
    TResult Function(StrikerRole role)? striker,
    required TResult orElse(),
  }) {
    if (cdm != null) {
      return cdm(role);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AssignedGkRole value) gk,
    required TResult Function(AssignedCbRole value) cb,
    required TResult Function(AssignedFullBackRole value) fullBack,
    required TResult Function(AssignedWingBackRole value) wingBack,
    required TResult Function(AssignedCdmRole value) cdm,
    required TResult Function(AssignedCmRole value) cm,
    required TResult Function(AssignedCamRole value) cam,
    required TResult Function(AssignedWingerRole value) winger,
    required TResult Function(AssignedStrikerRole value) striker,
  }) {
    return cdm(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AssignedGkRole value)? gk,
    TResult? Function(AssignedCbRole value)? cb,
    TResult? Function(AssignedFullBackRole value)? fullBack,
    TResult? Function(AssignedWingBackRole value)? wingBack,
    TResult? Function(AssignedCdmRole value)? cdm,
    TResult? Function(AssignedCmRole value)? cm,
    TResult? Function(AssignedCamRole value)? cam,
    TResult? Function(AssignedWingerRole value)? winger,
    TResult? Function(AssignedStrikerRole value)? striker,
  }) {
    return cdm?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AssignedGkRole value)? gk,
    TResult Function(AssignedCbRole value)? cb,
    TResult Function(AssignedFullBackRole value)? fullBack,
    TResult Function(AssignedWingBackRole value)? wingBack,
    TResult Function(AssignedCdmRole value)? cdm,
    TResult Function(AssignedCmRole value)? cm,
    TResult Function(AssignedCamRole value)? cam,
    TResult Function(AssignedWingerRole value)? winger,
    TResult Function(AssignedStrikerRole value)? striker,
    required TResult orElse(),
  }) {
    if (cdm != null) {
      return cdm(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$AssignedCdmRoleImplToJson(this);
  }
}

abstract class AssignedCdmRole implements AssignedRole {
  const factory AssignedCdmRole({final CdmRole role}) = _$AssignedCdmRoleImpl;

  factory AssignedCdmRole.fromJson(Map<String, dynamic> json) =
      _$AssignedCdmRoleImpl.fromJson;

  @override
  CdmRole get role;

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignedCdmRoleImplCopyWith<_$AssignedCdmRoleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AssignedCmRoleImplCopyWith<$Res> {
  factory _$$AssignedCmRoleImplCopyWith(
    _$AssignedCmRoleImpl value,
    $Res Function(_$AssignedCmRoleImpl) then,
  ) = __$$AssignedCmRoleImplCopyWithImpl<$Res>;
  @useResult
  $Res call({CmRole role});
}

/// @nodoc
class __$$AssignedCmRoleImplCopyWithImpl<$Res>
    extends _$AssignedRoleCopyWithImpl<$Res, _$AssignedCmRoleImpl>
    implements _$$AssignedCmRoleImplCopyWith<$Res> {
  __$$AssignedCmRoleImplCopyWithImpl(
    _$AssignedCmRoleImpl _value,
    $Res Function(_$AssignedCmRoleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? role = null}) {
    return _then(
      _$AssignedCmRoleImpl(
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as CmRole,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssignedCmRoleImpl implements AssignedCmRole {
  const _$AssignedCmRoleImpl({this.role = CmRole.standard, final String? $type})
    : $type = $type ?? 'cm';

  factory _$AssignedCmRoleImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssignedCmRoleImplFromJson(json);

  @override
  @JsonKey()
  final CmRole role;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'AssignedRole.cm(role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignedCmRoleImpl &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, role);

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignedCmRoleImplCopyWith<_$AssignedCmRoleImpl> get copyWith =>
      __$$AssignedCmRoleImplCopyWithImpl<_$AssignedCmRoleImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(GkRole role) gk,
    required TResult Function(CbRole role) cb,
    required TResult Function(FullBackRole role) fullBack,
    required TResult Function(WingBackRole role) wingBack,
    required TResult Function(CdmRole role) cdm,
    required TResult Function(CmRole role) cm,
    required TResult Function(CamRole role) cam,
    required TResult Function(WingerRole role) winger,
    required TResult Function(StrikerRole role) striker,
  }) {
    return cm(role);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(GkRole role)? gk,
    TResult? Function(CbRole role)? cb,
    TResult? Function(FullBackRole role)? fullBack,
    TResult? Function(WingBackRole role)? wingBack,
    TResult? Function(CdmRole role)? cdm,
    TResult? Function(CmRole role)? cm,
    TResult? Function(CamRole role)? cam,
    TResult? Function(WingerRole role)? winger,
    TResult? Function(StrikerRole role)? striker,
  }) {
    return cm?.call(role);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(GkRole role)? gk,
    TResult Function(CbRole role)? cb,
    TResult Function(FullBackRole role)? fullBack,
    TResult Function(WingBackRole role)? wingBack,
    TResult Function(CdmRole role)? cdm,
    TResult Function(CmRole role)? cm,
    TResult Function(CamRole role)? cam,
    TResult Function(WingerRole role)? winger,
    TResult Function(StrikerRole role)? striker,
    required TResult orElse(),
  }) {
    if (cm != null) {
      return cm(role);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AssignedGkRole value) gk,
    required TResult Function(AssignedCbRole value) cb,
    required TResult Function(AssignedFullBackRole value) fullBack,
    required TResult Function(AssignedWingBackRole value) wingBack,
    required TResult Function(AssignedCdmRole value) cdm,
    required TResult Function(AssignedCmRole value) cm,
    required TResult Function(AssignedCamRole value) cam,
    required TResult Function(AssignedWingerRole value) winger,
    required TResult Function(AssignedStrikerRole value) striker,
  }) {
    return cm(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AssignedGkRole value)? gk,
    TResult? Function(AssignedCbRole value)? cb,
    TResult? Function(AssignedFullBackRole value)? fullBack,
    TResult? Function(AssignedWingBackRole value)? wingBack,
    TResult? Function(AssignedCdmRole value)? cdm,
    TResult? Function(AssignedCmRole value)? cm,
    TResult? Function(AssignedCamRole value)? cam,
    TResult? Function(AssignedWingerRole value)? winger,
    TResult? Function(AssignedStrikerRole value)? striker,
  }) {
    return cm?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AssignedGkRole value)? gk,
    TResult Function(AssignedCbRole value)? cb,
    TResult Function(AssignedFullBackRole value)? fullBack,
    TResult Function(AssignedWingBackRole value)? wingBack,
    TResult Function(AssignedCdmRole value)? cdm,
    TResult Function(AssignedCmRole value)? cm,
    TResult Function(AssignedCamRole value)? cam,
    TResult Function(AssignedWingerRole value)? winger,
    TResult Function(AssignedStrikerRole value)? striker,
    required TResult orElse(),
  }) {
    if (cm != null) {
      return cm(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$AssignedCmRoleImplToJson(this);
  }
}

abstract class AssignedCmRole implements AssignedRole {
  const factory AssignedCmRole({final CmRole role}) = _$AssignedCmRoleImpl;

  factory AssignedCmRole.fromJson(Map<String, dynamic> json) =
      _$AssignedCmRoleImpl.fromJson;

  @override
  CmRole get role;

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignedCmRoleImplCopyWith<_$AssignedCmRoleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AssignedCamRoleImplCopyWith<$Res> {
  factory _$$AssignedCamRoleImplCopyWith(
    _$AssignedCamRoleImpl value,
    $Res Function(_$AssignedCamRoleImpl) then,
  ) = __$$AssignedCamRoleImplCopyWithImpl<$Res>;
  @useResult
  $Res call({CamRole role});
}

/// @nodoc
class __$$AssignedCamRoleImplCopyWithImpl<$Res>
    extends _$AssignedRoleCopyWithImpl<$Res, _$AssignedCamRoleImpl>
    implements _$$AssignedCamRoleImplCopyWith<$Res> {
  __$$AssignedCamRoleImplCopyWithImpl(
    _$AssignedCamRoleImpl _value,
    $Res Function(_$AssignedCamRoleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? role = null}) {
    return _then(
      _$AssignedCamRoleImpl(
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as CamRole,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssignedCamRoleImpl implements AssignedCamRole {
  const _$AssignedCamRoleImpl({
    this.role = CamRole.standard,
    final String? $type,
  }) : $type = $type ?? 'cam';

  factory _$AssignedCamRoleImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssignedCamRoleImplFromJson(json);

  @override
  @JsonKey()
  final CamRole role;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'AssignedRole.cam(role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignedCamRoleImpl &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, role);

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignedCamRoleImplCopyWith<_$AssignedCamRoleImpl> get copyWith =>
      __$$AssignedCamRoleImplCopyWithImpl<_$AssignedCamRoleImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(GkRole role) gk,
    required TResult Function(CbRole role) cb,
    required TResult Function(FullBackRole role) fullBack,
    required TResult Function(WingBackRole role) wingBack,
    required TResult Function(CdmRole role) cdm,
    required TResult Function(CmRole role) cm,
    required TResult Function(CamRole role) cam,
    required TResult Function(WingerRole role) winger,
    required TResult Function(StrikerRole role) striker,
  }) {
    return cam(role);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(GkRole role)? gk,
    TResult? Function(CbRole role)? cb,
    TResult? Function(FullBackRole role)? fullBack,
    TResult? Function(WingBackRole role)? wingBack,
    TResult? Function(CdmRole role)? cdm,
    TResult? Function(CmRole role)? cm,
    TResult? Function(CamRole role)? cam,
    TResult? Function(WingerRole role)? winger,
    TResult? Function(StrikerRole role)? striker,
  }) {
    return cam?.call(role);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(GkRole role)? gk,
    TResult Function(CbRole role)? cb,
    TResult Function(FullBackRole role)? fullBack,
    TResult Function(WingBackRole role)? wingBack,
    TResult Function(CdmRole role)? cdm,
    TResult Function(CmRole role)? cm,
    TResult Function(CamRole role)? cam,
    TResult Function(WingerRole role)? winger,
    TResult Function(StrikerRole role)? striker,
    required TResult orElse(),
  }) {
    if (cam != null) {
      return cam(role);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AssignedGkRole value) gk,
    required TResult Function(AssignedCbRole value) cb,
    required TResult Function(AssignedFullBackRole value) fullBack,
    required TResult Function(AssignedWingBackRole value) wingBack,
    required TResult Function(AssignedCdmRole value) cdm,
    required TResult Function(AssignedCmRole value) cm,
    required TResult Function(AssignedCamRole value) cam,
    required TResult Function(AssignedWingerRole value) winger,
    required TResult Function(AssignedStrikerRole value) striker,
  }) {
    return cam(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AssignedGkRole value)? gk,
    TResult? Function(AssignedCbRole value)? cb,
    TResult? Function(AssignedFullBackRole value)? fullBack,
    TResult? Function(AssignedWingBackRole value)? wingBack,
    TResult? Function(AssignedCdmRole value)? cdm,
    TResult? Function(AssignedCmRole value)? cm,
    TResult? Function(AssignedCamRole value)? cam,
    TResult? Function(AssignedWingerRole value)? winger,
    TResult? Function(AssignedStrikerRole value)? striker,
  }) {
    return cam?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AssignedGkRole value)? gk,
    TResult Function(AssignedCbRole value)? cb,
    TResult Function(AssignedFullBackRole value)? fullBack,
    TResult Function(AssignedWingBackRole value)? wingBack,
    TResult Function(AssignedCdmRole value)? cdm,
    TResult Function(AssignedCmRole value)? cm,
    TResult Function(AssignedCamRole value)? cam,
    TResult Function(AssignedWingerRole value)? winger,
    TResult Function(AssignedStrikerRole value)? striker,
    required TResult orElse(),
  }) {
    if (cam != null) {
      return cam(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$AssignedCamRoleImplToJson(this);
  }
}

abstract class AssignedCamRole implements AssignedRole {
  const factory AssignedCamRole({final CamRole role}) = _$AssignedCamRoleImpl;

  factory AssignedCamRole.fromJson(Map<String, dynamic> json) =
      _$AssignedCamRoleImpl.fromJson;

  @override
  CamRole get role;

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignedCamRoleImplCopyWith<_$AssignedCamRoleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AssignedWingerRoleImplCopyWith<$Res> {
  factory _$$AssignedWingerRoleImplCopyWith(
    _$AssignedWingerRoleImpl value,
    $Res Function(_$AssignedWingerRoleImpl) then,
  ) = __$$AssignedWingerRoleImplCopyWithImpl<$Res>;
  @useResult
  $Res call({WingerRole role});
}

/// @nodoc
class __$$AssignedWingerRoleImplCopyWithImpl<$Res>
    extends _$AssignedRoleCopyWithImpl<$Res, _$AssignedWingerRoleImpl>
    implements _$$AssignedWingerRoleImplCopyWith<$Res> {
  __$$AssignedWingerRoleImplCopyWithImpl(
    _$AssignedWingerRoleImpl _value,
    $Res Function(_$AssignedWingerRoleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? role = null}) {
    return _then(
      _$AssignedWingerRoleImpl(
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as WingerRole,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssignedWingerRoleImpl implements AssignedWingerRole {
  const _$AssignedWingerRoleImpl({
    this.role = WingerRole.standard,
    final String? $type,
  }) : $type = $type ?? 'winger';

  factory _$AssignedWingerRoleImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssignedWingerRoleImplFromJson(json);

  @override
  @JsonKey()
  final WingerRole role;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'AssignedRole.winger(role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignedWingerRoleImpl &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, role);

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignedWingerRoleImplCopyWith<_$AssignedWingerRoleImpl> get copyWith =>
      __$$AssignedWingerRoleImplCopyWithImpl<_$AssignedWingerRoleImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(GkRole role) gk,
    required TResult Function(CbRole role) cb,
    required TResult Function(FullBackRole role) fullBack,
    required TResult Function(WingBackRole role) wingBack,
    required TResult Function(CdmRole role) cdm,
    required TResult Function(CmRole role) cm,
    required TResult Function(CamRole role) cam,
    required TResult Function(WingerRole role) winger,
    required TResult Function(StrikerRole role) striker,
  }) {
    return winger(role);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(GkRole role)? gk,
    TResult? Function(CbRole role)? cb,
    TResult? Function(FullBackRole role)? fullBack,
    TResult? Function(WingBackRole role)? wingBack,
    TResult? Function(CdmRole role)? cdm,
    TResult? Function(CmRole role)? cm,
    TResult? Function(CamRole role)? cam,
    TResult? Function(WingerRole role)? winger,
    TResult? Function(StrikerRole role)? striker,
  }) {
    return winger?.call(role);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(GkRole role)? gk,
    TResult Function(CbRole role)? cb,
    TResult Function(FullBackRole role)? fullBack,
    TResult Function(WingBackRole role)? wingBack,
    TResult Function(CdmRole role)? cdm,
    TResult Function(CmRole role)? cm,
    TResult Function(CamRole role)? cam,
    TResult Function(WingerRole role)? winger,
    TResult Function(StrikerRole role)? striker,
    required TResult orElse(),
  }) {
    if (winger != null) {
      return winger(role);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AssignedGkRole value) gk,
    required TResult Function(AssignedCbRole value) cb,
    required TResult Function(AssignedFullBackRole value) fullBack,
    required TResult Function(AssignedWingBackRole value) wingBack,
    required TResult Function(AssignedCdmRole value) cdm,
    required TResult Function(AssignedCmRole value) cm,
    required TResult Function(AssignedCamRole value) cam,
    required TResult Function(AssignedWingerRole value) winger,
    required TResult Function(AssignedStrikerRole value) striker,
  }) {
    return winger(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AssignedGkRole value)? gk,
    TResult? Function(AssignedCbRole value)? cb,
    TResult? Function(AssignedFullBackRole value)? fullBack,
    TResult? Function(AssignedWingBackRole value)? wingBack,
    TResult? Function(AssignedCdmRole value)? cdm,
    TResult? Function(AssignedCmRole value)? cm,
    TResult? Function(AssignedCamRole value)? cam,
    TResult? Function(AssignedWingerRole value)? winger,
    TResult? Function(AssignedStrikerRole value)? striker,
  }) {
    return winger?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AssignedGkRole value)? gk,
    TResult Function(AssignedCbRole value)? cb,
    TResult Function(AssignedFullBackRole value)? fullBack,
    TResult Function(AssignedWingBackRole value)? wingBack,
    TResult Function(AssignedCdmRole value)? cdm,
    TResult Function(AssignedCmRole value)? cm,
    TResult Function(AssignedCamRole value)? cam,
    TResult Function(AssignedWingerRole value)? winger,
    TResult Function(AssignedStrikerRole value)? striker,
    required TResult orElse(),
  }) {
    if (winger != null) {
      return winger(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$AssignedWingerRoleImplToJson(this);
  }
}

abstract class AssignedWingerRole implements AssignedRole {
  const factory AssignedWingerRole({final WingerRole role}) =
      _$AssignedWingerRoleImpl;

  factory AssignedWingerRole.fromJson(Map<String, dynamic> json) =
      _$AssignedWingerRoleImpl.fromJson;

  @override
  WingerRole get role;

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignedWingerRoleImplCopyWith<_$AssignedWingerRoleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AssignedStrikerRoleImplCopyWith<$Res> {
  factory _$$AssignedStrikerRoleImplCopyWith(
    _$AssignedStrikerRoleImpl value,
    $Res Function(_$AssignedStrikerRoleImpl) then,
  ) = __$$AssignedStrikerRoleImplCopyWithImpl<$Res>;
  @useResult
  $Res call({StrikerRole role});
}

/// @nodoc
class __$$AssignedStrikerRoleImplCopyWithImpl<$Res>
    extends _$AssignedRoleCopyWithImpl<$Res, _$AssignedStrikerRoleImpl>
    implements _$$AssignedStrikerRoleImplCopyWith<$Res> {
  __$$AssignedStrikerRoleImplCopyWithImpl(
    _$AssignedStrikerRoleImpl _value,
    $Res Function(_$AssignedStrikerRoleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? role = null}) {
    return _then(
      _$AssignedStrikerRoleImpl(
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as StrikerRole,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AssignedStrikerRoleImpl implements AssignedStrikerRole {
  const _$AssignedStrikerRoleImpl({
    this.role = StrikerRole.standard,
    final String? $type,
  }) : $type = $type ?? 'striker';

  factory _$AssignedStrikerRoleImpl.fromJson(Map<String, dynamic> json) =>
      _$$AssignedStrikerRoleImplFromJson(json);

  @override
  @JsonKey()
  final StrikerRole role;

  @JsonKey(name: 'type')
  final String $type;

  @override
  String toString() {
    return 'AssignedRole.striker(role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AssignedStrikerRoleImpl &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, role);

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AssignedStrikerRoleImplCopyWith<_$AssignedStrikerRoleImpl> get copyWith =>
      __$$AssignedStrikerRoleImplCopyWithImpl<_$AssignedStrikerRoleImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(GkRole role) gk,
    required TResult Function(CbRole role) cb,
    required TResult Function(FullBackRole role) fullBack,
    required TResult Function(WingBackRole role) wingBack,
    required TResult Function(CdmRole role) cdm,
    required TResult Function(CmRole role) cm,
    required TResult Function(CamRole role) cam,
    required TResult Function(WingerRole role) winger,
    required TResult Function(StrikerRole role) striker,
  }) {
    return striker(role);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(GkRole role)? gk,
    TResult? Function(CbRole role)? cb,
    TResult? Function(FullBackRole role)? fullBack,
    TResult? Function(WingBackRole role)? wingBack,
    TResult? Function(CdmRole role)? cdm,
    TResult? Function(CmRole role)? cm,
    TResult? Function(CamRole role)? cam,
    TResult? Function(WingerRole role)? winger,
    TResult? Function(StrikerRole role)? striker,
  }) {
    return striker?.call(role);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(GkRole role)? gk,
    TResult Function(CbRole role)? cb,
    TResult Function(FullBackRole role)? fullBack,
    TResult Function(WingBackRole role)? wingBack,
    TResult Function(CdmRole role)? cdm,
    TResult Function(CmRole role)? cm,
    TResult Function(CamRole role)? cam,
    TResult Function(WingerRole role)? winger,
    TResult Function(StrikerRole role)? striker,
    required TResult orElse(),
  }) {
    if (striker != null) {
      return striker(role);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AssignedGkRole value) gk,
    required TResult Function(AssignedCbRole value) cb,
    required TResult Function(AssignedFullBackRole value) fullBack,
    required TResult Function(AssignedWingBackRole value) wingBack,
    required TResult Function(AssignedCdmRole value) cdm,
    required TResult Function(AssignedCmRole value) cm,
    required TResult Function(AssignedCamRole value) cam,
    required TResult Function(AssignedWingerRole value) winger,
    required TResult Function(AssignedStrikerRole value) striker,
  }) {
    return striker(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AssignedGkRole value)? gk,
    TResult? Function(AssignedCbRole value)? cb,
    TResult? Function(AssignedFullBackRole value)? fullBack,
    TResult? Function(AssignedWingBackRole value)? wingBack,
    TResult? Function(AssignedCdmRole value)? cdm,
    TResult? Function(AssignedCmRole value)? cm,
    TResult? Function(AssignedCamRole value)? cam,
    TResult? Function(AssignedWingerRole value)? winger,
    TResult? Function(AssignedStrikerRole value)? striker,
  }) {
    return striker?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AssignedGkRole value)? gk,
    TResult Function(AssignedCbRole value)? cb,
    TResult Function(AssignedFullBackRole value)? fullBack,
    TResult Function(AssignedWingBackRole value)? wingBack,
    TResult Function(AssignedCdmRole value)? cdm,
    TResult Function(AssignedCmRole value)? cm,
    TResult Function(AssignedCamRole value)? cam,
    TResult Function(AssignedWingerRole value)? winger,
    TResult Function(AssignedStrikerRole value)? striker,
    required TResult orElse(),
  }) {
    if (striker != null) {
      return striker(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$AssignedStrikerRoleImplToJson(this);
  }
}

abstract class AssignedStrikerRole implements AssignedRole {
  const factory AssignedStrikerRole({final StrikerRole role}) =
      _$AssignedStrikerRoleImpl;

  factory AssignedStrikerRole.fromJson(Map<String, dynamic> json) =
      _$AssignedStrikerRoleImpl.fromJson;

  @override
  StrikerRole get role;

  /// Create a copy of AssignedRole
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AssignedStrikerRoleImplCopyWith<_$AssignedStrikerRoleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
