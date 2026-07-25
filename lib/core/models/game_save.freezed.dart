// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_save.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GameSaveMeta _$GameSaveMetaFromJson(Map<String, dynamic> json) {
  return _GameSaveMeta.fromJson(json);
}

/// @nodoc
mixin _$GameSaveMeta {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  int get seasonYear => throw _privateConstructorUsedError;
  SeasonPhase get phase => throw _privateConstructorUsedError;
  String? get playerTeamName => throw _privateConstructorUsedError;

  /// Serializes this GameSaveMeta to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameSaveMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameSaveMetaCopyWith<GameSaveMeta> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameSaveMetaCopyWith<$Res> {
  factory $GameSaveMetaCopyWith(
    GameSaveMeta value,
    $Res Function(GameSaveMeta) then,
  ) = _$GameSaveMetaCopyWithImpl<$Res, GameSaveMeta>;
  @useResult
  $Res call({
    String id,
    String name,
    DateTime createdAt,
    DateTime updatedAt,
    int seasonYear,
    SeasonPhase phase,
    String? playerTeamName,
  });
}

/// @nodoc
class _$GameSaveMetaCopyWithImpl<$Res, $Val extends GameSaveMeta>
    implements $GameSaveMetaCopyWith<$Res> {
  _$GameSaveMetaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameSaveMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? seasonYear = null,
    Object? phase = null,
    Object? playerTeamName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            seasonYear: null == seasonYear
                ? _value.seasonYear
                : seasonYear // ignore: cast_nullable_to_non_nullable
                      as int,
            phase: null == phase
                ? _value.phase
                : phase // ignore: cast_nullable_to_non_nullable
                      as SeasonPhase,
            playerTeamName: freezed == playerTeamName
                ? _value.playerTeamName
                : playerTeamName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameSaveMetaImplCopyWith<$Res>
    implements $GameSaveMetaCopyWith<$Res> {
  factory _$$GameSaveMetaImplCopyWith(
    _$GameSaveMetaImpl value,
    $Res Function(_$GameSaveMetaImpl) then,
  ) = __$$GameSaveMetaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    DateTime createdAt,
    DateTime updatedAt,
    int seasonYear,
    SeasonPhase phase,
    String? playerTeamName,
  });
}

/// @nodoc
class __$$GameSaveMetaImplCopyWithImpl<$Res>
    extends _$GameSaveMetaCopyWithImpl<$Res, _$GameSaveMetaImpl>
    implements _$$GameSaveMetaImplCopyWith<$Res> {
  __$$GameSaveMetaImplCopyWithImpl(
    _$GameSaveMetaImpl _value,
    $Res Function(_$GameSaveMetaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameSaveMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? seasonYear = null,
    Object? phase = null,
    Object? playerTeamName = freezed,
  }) {
    return _then(
      _$GameSaveMetaImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        seasonYear: null == seasonYear
            ? _value.seasonYear
            : seasonYear // ignore: cast_nullable_to_non_nullable
                  as int,
        phase: null == phase
            ? _value.phase
            : phase // ignore: cast_nullable_to_non_nullable
                  as SeasonPhase,
        playerTeamName: freezed == playerTeamName
            ? _value.playerTeamName
            : playerTeamName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameSaveMetaImpl implements _GameSaveMeta {
  const _$GameSaveMetaImpl({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.seasonYear,
    required this.phase,
    this.playerTeamName,
  });

  factory _$GameSaveMetaImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameSaveMetaImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final int seasonYear;
  @override
  final SeasonPhase phase;
  @override
  final String? playerTeamName;

  @override
  String toString() {
    return 'GameSaveMeta(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt, seasonYear: $seasonYear, phase: $phase, playerTeamName: $playerTeamName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameSaveMetaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.seasonYear, seasonYear) ||
                other.seasonYear == seasonYear) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.playerTeamName, playerTeamName) ||
                other.playerTeamName == playerTeamName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    createdAt,
    updatedAt,
    seasonYear,
    phase,
    playerTeamName,
  );

  /// Create a copy of GameSaveMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameSaveMetaImplCopyWith<_$GameSaveMetaImpl> get copyWith =>
      __$$GameSaveMetaImplCopyWithImpl<_$GameSaveMetaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameSaveMetaImplToJson(this);
  }
}

abstract class _GameSaveMeta implements GameSaveMeta {
  const factory _GameSaveMeta({
    required final String id,
    required final String name,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    required final int seasonYear,
    required final SeasonPhase phase,
    final String? playerTeamName,
  }) = _$GameSaveMetaImpl;

  factory _GameSaveMeta.fromJson(Map<String, dynamic> json) =
      _$GameSaveMetaImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  int get seasonYear;
  @override
  SeasonPhase get phase;
  @override
  String? get playerTeamName;

  /// Create a copy of GameSaveMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameSaveMetaImplCopyWith<_$GameSaveMetaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameSave _$GameSaveFromJson(Map<String, dynamic> json) {
  return _GameSave.fromJson(json);
}

/// @nodoc
mixin _$GameSave {
  GameSaveMeta get meta => throw _privateConstructorUsedError;
  LeagueState get leagueState => throw _privateConstructorUsedError;
  int get schemaVersion => throw _privateConstructorUsedError;

  /// Serializes this GameSave to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameSave
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameSaveCopyWith<GameSave> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameSaveCopyWith<$Res> {
  factory $GameSaveCopyWith(GameSave value, $Res Function(GameSave) then) =
      _$GameSaveCopyWithImpl<$Res, GameSave>;
  @useResult
  $Res call({GameSaveMeta meta, LeagueState leagueState, int schemaVersion});

  $GameSaveMetaCopyWith<$Res> get meta;
  $LeagueStateCopyWith<$Res> get leagueState;
}

/// @nodoc
class _$GameSaveCopyWithImpl<$Res, $Val extends GameSave>
    implements $GameSaveCopyWith<$Res> {
  _$GameSaveCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameSave
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meta = null,
    Object? leagueState = null,
    Object? schemaVersion = null,
  }) {
    return _then(
      _value.copyWith(
            meta: null == meta
                ? _value.meta
                : meta // ignore: cast_nullable_to_non_nullable
                      as GameSaveMeta,
            leagueState: null == leagueState
                ? _value.leagueState
                : leagueState // ignore: cast_nullable_to_non_nullable
                      as LeagueState,
            schemaVersion: null == schemaVersion
                ? _value.schemaVersion
                : schemaVersion // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of GameSave
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameSaveMetaCopyWith<$Res> get meta {
    return $GameSaveMetaCopyWith<$Res>(_value.meta, (value) {
      return _then(_value.copyWith(meta: value) as $Val);
    });
  }

  /// Create a copy of GameSave
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LeagueStateCopyWith<$Res> get leagueState {
    return $LeagueStateCopyWith<$Res>(_value.leagueState, (value) {
      return _then(_value.copyWith(leagueState: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameSaveImplCopyWith<$Res>
    implements $GameSaveCopyWith<$Res> {
  factory _$$GameSaveImplCopyWith(
    _$GameSaveImpl value,
    $Res Function(_$GameSaveImpl) then,
  ) = __$$GameSaveImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({GameSaveMeta meta, LeagueState leagueState, int schemaVersion});

  @override
  $GameSaveMetaCopyWith<$Res> get meta;
  @override
  $LeagueStateCopyWith<$Res> get leagueState;
}

/// @nodoc
class __$$GameSaveImplCopyWithImpl<$Res>
    extends _$GameSaveCopyWithImpl<$Res, _$GameSaveImpl>
    implements _$$GameSaveImplCopyWith<$Res> {
  __$$GameSaveImplCopyWithImpl(
    _$GameSaveImpl _value,
    $Res Function(_$GameSaveImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameSave
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? meta = null,
    Object? leagueState = null,
    Object? schemaVersion = null,
  }) {
    return _then(
      _$GameSaveImpl(
        meta: null == meta
            ? _value.meta
            : meta // ignore: cast_nullable_to_non_nullable
                  as GameSaveMeta,
        leagueState: null == leagueState
            ? _value.leagueState
            : leagueState // ignore: cast_nullable_to_non_nullable
                  as LeagueState,
        schemaVersion: null == schemaVersion
            ? _value.schemaVersion
            : schemaVersion // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameSaveImpl implements _GameSave {
  const _$GameSaveImpl({
    required this.meta,
    required this.leagueState,
    this.schemaVersion = 1,
  });

  factory _$GameSaveImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameSaveImplFromJson(json);

  @override
  final GameSaveMeta meta;
  @override
  final LeagueState leagueState;
  @override
  @JsonKey()
  final int schemaVersion;

  @override
  String toString() {
    return 'GameSave(meta: $meta, leagueState: $leagueState, schemaVersion: $schemaVersion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameSaveImpl &&
            (identical(other.meta, meta) || other.meta == meta) &&
            (identical(other.leagueState, leagueState) ||
                other.leagueState == leagueState) &&
            (identical(other.schemaVersion, schemaVersion) ||
                other.schemaVersion == schemaVersion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, meta, leagueState, schemaVersion);

  /// Create a copy of GameSave
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameSaveImplCopyWith<_$GameSaveImpl> get copyWith =>
      __$$GameSaveImplCopyWithImpl<_$GameSaveImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameSaveImplToJson(this);
  }
}

abstract class _GameSave implements GameSave {
  const factory _GameSave({
    required final GameSaveMeta meta,
    required final LeagueState leagueState,
    final int schemaVersion,
  }) = _$GameSaveImpl;

  factory _GameSave.fromJson(Map<String, dynamic> json) =
      _$GameSaveImpl.fromJson;

  @override
  GameSaveMeta get meta;
  @override
  LeagueState get leagueState;
  @override
  int get schemaVersion;

  /// Create a copy of GameSave
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameSaveImplCopyWith<_$GameSaveImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
