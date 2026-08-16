// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MatchEvent _$MatchEventFromJson(Map<String, dynamic> json) {
  return _MatchEvent.fromJson(json);
}

/// @nodoc
mixin _$MatchEvent {
  MatchEventType get type => throw _privateConstructorUsedError;
  int get minute => throw _privateConstructorUsedError;
  String get teamId => throw _privateConstructorUsedError;
  String? get playerId => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this MatchEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchEventCopyWith<MatchEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchEventCopyWith<$Res> {
  factory $MatchEventCopyWith(
    MatchEvent value,
    $Res Function(MatchEvent) then,
  ) = _$MatchEventCopyWithImpl<$Res, MatchEvent>;
  @useResult
  $Res call({
    MatchEventType type,
    int minute,
    String teamId,
    String? playerId,
    String? description,
  });
}

/// @nodoc
class _$MatchEventCopyWithImpl<$Res, $Val extends MatchEvent>
    implements $MatchEventCopyWith<$Res> {
  _$MatchEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? minute = null,
    Object? teamId = null,
    Object? playerId = freezed,
    Object? description = freezed,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as MatchEventType,
            minute: null == minute
                ? _value.minute
                : minute // ignore: cast_nullable_to_non_nullable
                      as int,
            teamId: null == teamId
                ? _value.teamId
                : teamId // ignore: cast_nullable_to_non_nullable
                      as String,
            playerId: freezed == playerId
                ? _value.playerId
                : playerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchEventImplCopyWith<$Res>
    implements $MatchEventCopyWith<$Res> {
  factory _$$MatchEventImplCopyWith(
    _$MatchEventImpl value,
    $Res Function(_$MatchEventImpl) then,
  ) = __$$MatchEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    MatchEventType type,
    int minute,
    String teamId,
    String? playerId,
    String? description,
  });
}

/// @nodoc
class __$$MatchEventImplCopyWithImpl<$Res>
    extends _$MatchEventCopyWithImpl<$Res, _$MatchEventImpl>
    implements _$$MatchEventImplCopyWith<$Res> {
  __$$MatchEventImplCopyWithImpl(
    _$MatchEventImpl _value,
    $Res Function(_$MatchEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? minute = null,
    Object? teamId = null,
    Object? playerId = freezed,
    Object? description = freezed,
  }) {
    return _then(
      _$MatchEventImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as MatchEventType,
        minute: null == minute
            ? _value.minute
            : minute // ignore: cast_nullable_to_non_nullable
                  as int,
        teamId: null == teamId
            ? _value.teamId
            : teamId // ignore: cast_nullable_to_non_nullable
                  as String,
        playerId: freezed == playerId
            ? _value.playerId
            : playerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchEventImpl implements _MatchEvent {
  const _$MatchEventImpl({
    required this.type,
    required this.minute,
    required this.teamId,
    this.playerId,
    this.description,
  });

  factory _$MatchEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchEventImplFromJson(json);

  @override
  final MatchEventType type;
  @override
  final int minute;
  @override
  final String teamId;
  @override
  final String? playerId;
  @override
  final String? description;

  @override
  String toString() {
    return 'MatchEvent(type: $type, minute: $minute, teamId: $teamId, playerId: $playerId, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchEventImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.minute, minute) || other.minute == minute) &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, minute, teamId, playerId, description);

  /// Create a copy of MatchEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchEventImplCopyWith<_$MatchEventImpl> get copyWith =>
      __$$MatchEventImplCopyWithImpl<_$MatchEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchEventImplToJson(this);
  }
}

abstract class _MatchEvent implements MatchEvent {
  const factory _MatchEvent({
    required final MatchEventType type,
    required final int minute,
    required final String teamId,
    final String? playerId,
    final String? description,
  }) = _$MatchEventImpl;

  factory _MatchEvent.fromJson(Map<String, dynamic> json) =
      _$MatchEventImpl.fromJson;

  @override
  MatchEventType get type;
  @override
  int get minute;
  @override
  String get teamId;
  @override
  String? get playerId;
  @override
  String? get description;

  /// Create a copy of MatchEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchEventImplCopyWith<_$MatchEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchInjury _$MatchInjuryFromJson(Map<String, dynamic> json) {
  return _MatchInjury.fromJson(json);
}

/// @nodoc
mixin _$MatchInjury {
  String get teamId => throw _privateConstructorUsedError;
  String get playerId => throw _privateConstructorUsedError;
  Injury get injury => throw _privateConstructorUsedError;
  bool get playerInStartingXi => throw _privateConstructorUsedError;
  bool get potentialLoss => throw _privateConstructorUsedError;

  /// Serializes this MatchInjury to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchInjury
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchInjuryCopyWith<MatchInjury> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchInjuryCopyWith<$Res> {
  factory $MatchInjuryCopyWith(
    MatchInjury value,
    $Res Function(MatchInjury) then,
  ) = _$MatchInjuryCopyWithImpl<$Res, MatchInjury>;
  @useResult
  $Res call({
    String teamId,
    String playerId,
    Injury injury,
    bool playerInStartingXi,
    bool potentialLoss,
  });

  $InjuryCopyWith<$Res> get injury;
}

/// @nodoc
class _$MatchInjuryCopyWithImpl<$Res, $Val extends MatchInjury>
    implements $MatchInjuryCopyWith<$Res> {
  _$MatchInjuryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchInjury
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teamId = null,
    Object? playerId = null,
    Object? injury = null,
    Object? playerInStartingXi = null,
    Object? potentialLoss = null,
  }) {
    return _then(
      _value.copyWith(
            teamId: null == teamId
                ? _value.teamId
                : teamId // ignore: cast_nullable_to_non_nullable
                      as String,
            playerId: null == playerId
                ? _value.playerId
                : playerId // ignore: cast_nullable_to_non_nullable
                      as String,
            injury: null == injury
                ? _value.injury
                : injury // ignore: cast_nullable_to_non_nullable
                      as Injury,
            playerInStartingXi: null == playerInStartingXi
                ? _value.playerInStartingXi
                : playerInStartingXi // ignore: cast_nullable_to_non_nullable
                      as bool,
            potentialLoss: null == potentialLoss
                ? _value.potentialLoss
                : potentialLoss // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of MatchInjury
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InjuryCopyWith<$Res> get injury {
    return $InjuryCopyWith<$Res>(_value.injury, (value) {
      return _then(_value.copyWith(injury: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchInjuryImplCopyWith<$Res>
    implements $MatchInjuryCopyWith<$Res> {
  factory _$$MatchInjuryImplCopyWith(
    _$MatchInjuryImpl value,
    $Res Function(_$MatchInjuryImpl) then,
  ) = __$$MatchInjuryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String teamId,
    String playerId,
    Injury injury,
    bool playerInStartingXi,
    bool potentialLoss,
  });

  @override
  $InjuryCopyWith<$Res> get injury;
}

/// @nodoc
class __$$MatchInjuryImplCopyWithImpl<$Res>
    extends _$MatchInjuryCopyWithImpl<$Res, _$MatchInjuryImpl>
    implements _$$MatchInjuryImplCopyWith<$Res> {
  __$$MatchInjuryImplCopyWithImpl(
    _$MatchInjuryImpl _value,
    $Res Function(_$MatchInjuryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchInjury
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teamId = null,
    Object? playerId = null,
    Object? injury = null,
    Object? playerInStartingXi = null,
    Object? potentialLoss = null,
  }) {
    return _then(
      _$MatchInjuryImpl(
        teamId: null == teamId
            ? _value.teamId
            : teamId // ignore: cast_nullable_to_non_nullable
                  as String,
        playerId: null == playerId
            ? _value.playerId
            : playerId // ignore: cast_nullable_to_non_nullable
                  as String,
        injury: null == injury
            ? _value.injury
            : injury // ignore: cast_nullable_to_non_nullable
                  as Injury,
        playerInStartingXi: null == playerInStartingXi
            ? _value.playerInStartingXi
            : playerInStartingXi // ignore: cast_nullable_to_non_nullable
                  as bool,
        potentialLoss: null == potentialLoss
            ? _value.potentialLoss
            : potentialLoss // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchInjuryImpl implements _MatchInjury {
  const _$MatchInjuryImpl({
    required this.teamId,
    required this.playerId,
    required this.injury,
    required this.playerInStartingXi,
    this.potentialLoss = false,
  });

  factory _$MatchInjuryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchInjuryImplFromJson(json);

  @override
  final String teamId;
  @override
  final String playerId;
  @override
  final Injury injury;
  @override
  final bool playerInStartingXi;
  @override
  @JsonKey()
  final bool potentialLoss;

  @override
  String toString() {
    return 'MatchInjury(teamId: $teamId, playerId: $playerId, injury: $injury, playerInStartingXi: $playerInStartingXi, potentialLoss: $potentialLoss)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchInjuryImpl &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.injury, injury) || other.injury == injury) &&
            (identical(other.playerInStartingXi, playerInStartingXi) ||
                other.playerInStartingXi == playerInStartingXi) &&
            (identical(other.potentialLoss, potentialLoss) ||
                other.potentialLoss == potentialLoss));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    teamId,
    playerId,
    injury,
    playerInStartingXi,
    potentialLoss,
  );

  /// Create a copy of MatchInjury
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchInjuryImplCopyWith<_$MatchInjuryImpl> get copyWith =>
      __$$MatchInjuryImplCopyWithImpl<_$MatchInjuryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchInjuryImplToJson(this);
  }
}

abstract class _MatchInjury implements MatchInjury {
  const factory _MatchInjury({
    required final String teamId,
    required final String playerId,
    required final Injury injury,
    required final bool playerInStartingXi,
    final bool potentialLoss,
  }) = _$MatchInjuryImpl;

  factory _MatchInjury.fromJson(Map<String, dynamic> json) =
      _$MatchInjuryImpl.fromJson;

  @override
  String get teamId;
  @override
  String get playerId;
  @override
  Injury get injury;
  @override
  bool get playerInStartingXi;
  @override
  bool get potentialLoss;

  /// Create a copy of MatchInjury
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchInjuryImplCopyWith<_$MatchInjuryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchDiscipline _$MatchDisciplineFromJson(Map<String, dynamic> json) {
  return _MatchDiscipline.fromJson(json);
}

/// @nodoc
mixin _$MatchDiscipline {
  String get teamId => throw _privateConstructorUsedError;
  String get playerId => throw _privateConstructorUsedError;
  int get yellowCardsInMatch => throw _privateConstructorUsedError;
  RedCardKind get redCardKind => throw _privateConstructorUsedError;
  int get directRedSeverity => throw _privateConstructorUsedError;
  bool get playerInStartingXi => throw _privateConstructorUsedError;

  /// Serializes this MatchDiscipline to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchDiscipline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchDisciplineCopyWith<MatchDiscipline> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchDisciplineCopyWith<$Res> {
  factory $MatchDisciplineCopyWith(
    MatchDiscipline value,
    $Res Function(MatchDiscipline) then,
  ) = _$MatchDisciplineCopyWithImpl<$Res, MatchDiscipline>;
  @useResult
  $Res call({
    String teamId,
    String playerId,
    int yellowCardsInMatch,
    RedCardKind redCardKind,
    int directRedSeverity,
    bool playerInStartingXi,
  });
}

/// @nodoc
class _$MatchDisciplineCopyWithImpl<$Res, $Val extends MatchDiscipline>
    implements $MatchDisciplineCopyWith<$Res> {
  _$MatchDisciplineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchDiscipline
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teamId = null,
    Object? playerId = null,
    Object? yellowCardsInMatch = null,
    Object? redCardKind = null,
    Object? directRedSeverity = null,
    Object? playerInStartingXi = null,
  }) {
    return _then(
      _value.copyWith(
            teamId: null == teamId
                ? _value.teamId
                : teamId // ignore: cast_nullable_to_non_nullable
                      as String,
            playerId: null == playerId
                ? _value.playerId
                : playerId // ignore: cast_nullable_to_non_nullable
                      as String,
            yellowCardsInMatch: null == yellowCardsInMatch
                ? _value.yellowCardsInMatch
                : yellowCardsInMatch // ignore: cast_nullable_to_non_nullable
                      as int,
            redCardKind: null == redCardKind
                ? _value.redCardKind
                : redCardKind // ignore: cast_nullable_to_non_nullable
                      as RedCardKind,
            directRedSeverity: null == directRedSeverity
                ? _value.directRedSeverity
                : directRedSeverity // ignore: cast_nullable_to_non_nullable
                      as int,
            playerInStartingXi: null == playerInStartingXi
                ? _value.playerInStartingXi
                : playerInStartingXi // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchDisciplineImplCopyWith<$Res>
    implements $MatchDisciplineCopyWith<$Res> {
  factory _$$MatchDisciplineImplCopyWith(
    _$MatchDisciplineImpl value,
    $Res Function(_$MatchDisciplineImpl) then,
  ) = __$$MatchDisciplineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String teamId,
    String playerId,
    int yellowCardsInMatch,
    RedCardKind redCardKind,
    int directRedSeverity,
    bool playerInStartingXi,
  });
}

/// @nodoc
class __$$MatchDisciplineImplCopyWithImpl<$Res>
    extends _$MatchDisciplineCopyWithImpl<$Res, _$MatchDisciplineImpl>
    implements _$$MatchDisciplineImplCopyWith<$Res> {
  __$$MatchDisciplineImplCopyWithImpl(
    _$MatchDisciplineImpl _value,
    $Res Function(_$MatchDisciplineImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchDiscipline
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teamId = null,
    Object? playerId = null,
    Object? yellowCardsInMatch = null,
    Object? redCardKind = null,
    Object? directRedSeverity = null,
    Object? playerInStartingXi = null,
  }) {
    return _then(
      _$MatchDisciplineImpl(
        teamId: null == teamId
            ? _value.teamId
            : teamId // ignore: cast_nullable_to_non_nullable
                  as String,
        playerId: null == playerId
            ? _value.playerId
            : playerId // ignore: cast_nullable_to_non_nullable
                  as String,
        yellowCardsInMatch: null == yellowCardsInMatch
            ? _value.yellowCardsInMatch
            : yellowCardsInMatch // ignore: cast_nullable_to_non_nullable
                  as int,
        redCardKind: null == redCardKind
            ? _value.redCardKind
            : redCardKind // ignore: cast_nullable_to_non_nullable
                  as RedCardKind,
        directRedSeverity: null == directRedSeverity
            ? _value.directRedSeverity
            : directRedSeverity // ignore: cast_nullable_to_non_nullable
                  as int,
        playerInStartingXi: null == playerInStartingXi
            ? _value.playerInStartingXi
            : playerInStartingXi // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchDisciplineImpl implements _MatchDiscipline {
  const _$MatchDisciplineImpl({
    required this.teamId,
    required this.playerId,
    this.yellowCardsInMatch = 0,
    this.redCardKind = RedCardKind.none,
    this.directRedSeverity = 0,
    this.playerInStartingXi = false,
  });

  factory _$MatchDisciplineImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchDisciplineImplFromJson(json);

  @override
  final String teamId;
  @override
  final String playerId;
  @override
  @JsonKey()
  final int yellowCardsInMatch;
  @override
  @JsonKey()
  final RedCardKind redCardKind;
  @override
  @JsonKey()
  final int directRedSeverity;
  @override
  @JsonKey()
  final bool playerInStartingXi;

  @override
  String toString() {
    return 'MatchDiscipline(teamId: $teamId, playerId: $playerId, yellowCardsInMatch: $yellowCardsInMatch, redCardKind: $redCardKind, directRedSeverity: $directRedSeverity, playerInStartingXi: $playerInStartingXi)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchDisciplineImpl &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.yellowCardsInMatch, yellowCardsInMatch) ||
                other.yellowCardsInMatch == yellowCardsInMatch) &&
            (identical(other.redCardKind, redCardKind) ||
                other.redCardKind == redCardKind) &&
            (identical(other.directRedSeverity, directRedSeverity) ||
                other.directRedSeverity == directRedSeverity) &&
            (identical(other.playerInStartingXi, playerInStartingXi) ||
                other.playerInStartingXi == playerInStartingXi));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    teamId,
    playerId,
    yellowCardsInMatch,
    redCardKind,
    directRedSeverity,
    playerInStartingXi,
  );

  /// Create a copy of MatchDiscipline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchDisciplineImplCopyWith<_$MatchDisciplineImpl> get copyWith =>
      __$$MatchDisciplineImplCopyWithImpl<_$MatchDisciplineImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchDisciplineImplToJson(this);
  }
}

abstract class _MatchDiscipline implements MatchDiscipline {
  const factory _MatchDiscipline({
    required final String teamId,
    required final String playerId,
    final int yellowCardsInMatch,
    final RedCardKind redCardKind,
    final int directRedSeverity,
    final bool playerInStartingXi,
  }) = _$MatchDisciplineImpl;

  factory _MatchDiscipline.fromJson(Map<String, dynamic> json) =
      _$MatchDisciplineImpl.fromJson;

  @override
  String get teamId;
  @override
  String get playerId;
  @override
  int get yellowCardsInMatch;
  @override
  RedCardKind get redCardKind;
  @override
  int get directRedSeverity;
  @override
  bool get playerInStartingXi;

  /// Create a copy of MatchDiscipline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchDisciplineImplCopyWith<_$MatchDisciplineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TeamMatchStats _$TeamMatchStatsFromJson(Map<String, dynamic> json) {
  return _TeamMatchStats.fromJson(json);
}

/// @nodoc
mixin _$TeamMatchStats {
  String get teamId => throw _privateConstructorUsedError;
  int get goals => throw _privateConstructorUsedError;
  int get shots => throw _privateConstructorUsedError;
  int get shotsOnTarget => throw _privateConstructorUsedError;
  int get possession => throw _privateConstructorUsedError;
  double get xg => throw _privateConstructorUsedError;
  int get corners => throw _privateConstructorUsedError;
  int get fouls => throw _privateConstructorUsedError;
  int get yellowCards => throw _privateConstructorUsedError;
  int get redCards => throw _privateConstructorUsedError;

  /// Serializes this TeamMatchStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeamMatchStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamMatchStatsCopyWith<TeamMatchStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamMatchStatsCopyWith<$Res> {
  factory $TeamMatchStatsCopyWith(
    TeamMatchStats value,
    $Res Function(TeamMatchStats) then,
  ) = _$TeamMatchStatsCopyWithImpl<$Res, TeamMatchStats>;
  @useResult
  $Res call({
    String teamId,
    int goals,
    int shots,
    int shotsOnTarget,
    int possession,
    double xg,
    int corners,
    int fouls,
    int yellowCards,
    int redCards,
  });
}

/// @nodoc
class _$TeamMatchStatsCopyWithImpl<$Res, $Val extends TeamMatchStats>
    implements $TeamMatchStatsCopyWith<$Res> {
  _$TeamMatchStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeamMatchStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teamId = null,
    Object? goals = null,
    Object? shots = null,
    Object? shotsOnTarget = null,
    Object? possession = null,
    Object? xg = null,
    Object? corners = null,
    Object? fouls = null,
    Object? yellowCards = null,
    Object? redCards = null,
  }) {
    return _then(
      _value.copyWith(
            teamId: null == teamId
                ? _value.teamId
                : teamId // ignore: cast_nullable_to_non_nullable
                      as String,
            goals: null == goals
                ? _value.goals
                : goals // ignore: cast_nullable_to_non_nullable
                      as int,
            shots: null == shots
                ? _value.shots
                : shots // ignore: cast_nullable_to_non_nullable
                      as int,
            shotsOnTarget: null == shotsOnTarget
                ? _value.shotsOnTarget
                : shotsOnTarget // ignore: cast_nullable_to_non_nullable
                      as int,
            possession: null == possession
                ? _value.possession
                : possession // ignore: cast_nullable_to_non_nullable
                      as int,
            xg: null == xg
                ? _value.xg
                : xg // ignore: cast_nullable_to_non_nullable
                      as double,
            corners: null == corners
                ? _value.corners
                : corners // ignore: cast_nullable_to_non_nullable
                      as int,
            fouls: null == fouls
                ? _value.fouls
                : fouls // ignore: cast_nullable_to_non_nullable
                      as int,
            yellowCards: null == yellowCards
                ? _value.yellowCards
                : yellowCards // ignore: cast_nullable_to_non_nullable
                      as int,
            redCards: null == redCards
                ? _value.redCards
                : redCards // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeamMatchStatsImplCopyWith<$Res>
    implements $TeamMatchStatsCopyWith<$Res> {
  factory _$$TeamMatchStatsImplCopyWith(
    _$TeamMatchStatsImpl value,
    $Res Function(_$TeamMatchStatsImpl) then,
  ) = __$$TeamMatchStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String teamId,
    int goals,
    int shots,
    int shotsOnTarget,
    int possession,
    double xg,
    int corners,
    int fouls,
    int yellowCards,
    int redCards,
  });
}

/// @nodoc
class __$$TeamMatchStatsImplCopyWithImpl<$Res>
    extends _$TeamMatchStatsCopyWithImpl<$Res, _$TeamMatchStatsImpl>
    implements _$$TeamMatchStatsImplCopyWith<$Res> {
  __$$TeamMatchStatsImplCopyWithImpl(
    _$TeamMatchStatsImpl _value,
    $Res Function(_$TeamMatchStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeamMatchStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teamId = null,
    Object? goals = null,
    Object? shots = null,
    Object? shotsOnTarget = null,
    Object? possession = null,
    Object? xg = null,
    Object? corners = null,
    Object? fouls = null,
    Object? yellowCards = null,
    Object? redCards = null,
  }) {
    return _then(
      _$TeamMatchStatsImpl(
        teamId: null == teamId
            ? _value.teamId
            : teamId // ignore: cast_nullable_to_non_nullable
                  as String,
        goals: null == goals
            ? _value.goals
            : goals // ignore: cast_nullable_to_non_nullable
                  as int,
        shots: null == shots
            ? _value.shots
            : shots // ignore: cast_nullable_to_non_nullable
                  as int,
        shotsOnTarget: null == shotsOnTarget
            ? _value.shotsOnTarget
            : shotsOnTarget // ignore: cast_nullable_to_non_nullable
                  as int,
        possession: null == possession
            ? _value.possession
            : possession // ignore: cast_nullable_to_non_nullable
                  as int,
        xg: null == xg
            ? _value.xg
            : xg // ignore: cast_nullable_to_non_nullable
                  as double,
        corners: null == corners
            ? _value.corners
            : corners // ignore: cast_nullable_to_non_nullable
                  as int,
        fouls: null == fouls
            ? _value.fouls
            : fouls // ignore: cast_nullable_to_non_nullable
                  as int,
        yellowCards: null == yellowCards
            ? _value.yellowCards
            : yellowCards // ignore: cast_nullable_to_non_nullable
                  as int,
        redCards: null == redCards
            ? _value.redCards
            : redCards // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamMatchStatsImpl implements _TeamMatchStats {
  const _$TeamMatchStatsImpl({
    required this.teamId,
    this.goals = 0,
    this.shots = 0,
    this.shotsOnTarget = 0,
    this.possession = 0,
    this.xg = 0.0,
    this.corners = 0,
    this.fouls = 0,
    this.yellowCards = 0,
    this.redCards = 0,
  });

  factory _$TeamMatchStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamMatchStatsImplFromJson(json);

  @override
  final String teamId;
  @override
  @JsonKey()
  final int goals;
  @override
  @JsonKey()
  final int shots;
  @override
  @JsonKey()
  final int shotsOnTarget;
  @override
  @JsonKey()
  final int possession;
  @override
  @JsonKey()
  final double xg;
  @override
  @JsonKey()
  final int corners;
  @override
  @JsonKey()
  final int fouls;
  @override
  @JsonKey()
  final int yellowCards;
  @override
  @JsonKey()
  final int redCards;

  @override
  String toString() {
    return 'TeamMatchStats(teamId: $teamId, goals: $goals, shots: $shots, shotsOnTarget: $shotsOnTarget, possession: $possession, xg: $xg, corners: $corners, fouls: $fouls, yellowCards: $yellowCards, redCards: $redCards)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamMatchStatsImpl &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.goals, goals) || other.goals == goals) &&
            (identical(other.shots, shots) || other.shots == shots) &&
            (identical(other.shotsOnTarget, shotsOnTarget) ||
                other.shotsOnTarget == shotsOnTarget) &&
            (identical(other.possession, possession) ||
                other.possession == possession) &&
            (identical(other.xg, xg) || other.xg == xg) &&
            (identical(other.corners, corners) || other.corners == corners) &&
            (identical(other.fouls, fouls) || other.fouls == fouls) &&
            (identical(other.yellowCards, yellowCards) ||
                other.yellowCards == yellowCards) &&
            (identical(other.redCards, redCards) ||
                other.redCards == redCards));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    teamId,
    goals,
    shots,
    shotsOnTarget,
    possession,
    xg,
    corners,
    fouls,
    yellowCards,
    redCards,
  );

  /// Create a copy of TeamMatchStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamMatchStatsImplCopyWith<_$TeamMatchStatsImpl> get copyWith =>
      __$$TeamMatchStatsImplCopyWithImpl<_$TeamMatchStatsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamMatchStatsImplToJson(this);
  }
}

abstract class _TeamMatchStats implements TeamMatchStats {
  const factory _TeamMatchStats({
    required final String teamId,
    final int goals,
    final int shots,
    final int shotsOnTarget,
    final int possession,
    final double xg,
    final int corners,
    final int fouls,
    final int yellowCards,
    final int redCards,
  }) = _$TeamMatchStatsImpl;

  factory _TeamMatchStats.fromJson(Map<String, dynamic> json) =
      _$TeamMatchStatsImpl.fromJson;

  @override
  String get teamId;
  @override
  int get goals;
  @override
  int get shots;
  @override
  int get shotsOnTarget;
  @override
  int get possession;
  @override
  double get xg;
  @override
  int get corners;
  @override
  int get fouls;
  @override
  int get yellowCards;
  @override
  int get redCards;

  /// Create a copy of TeamMatchStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamMatchStatsImplCopyWith<_$TeamMatchStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchTeamSnapshot _$MatchTeamSnapshotFromJson(Map<String, dynamic> json) {
  return _MatchTeamSnapshot.fromJson(json);
}

/// @nodoc
mixin _$MatchTeamSnapshot {
  String get teamId => throw _privateConstructorUsedError;
  List<Player> get startingXi => throw _privateConstructorUsedError;
  List<Player> get bench => throw _privateConstructorUsedError;
  List<Position> get assignedPositions => throw _privateConstructorUsedError;
  List<AssignedRole> get assignedRoles => throw _privateConstructorUsedError;
  TacticsSetup get tactics => throw _privateConstructorUsedError;
  double get chemistry => throw _privateConstructorUsedError;
  int get atmosphere => throw _privateConstructorUsedError;
  double get cohesionMultiplier => throw _privateConstructorUsedError;
  TeamStaff get staff => throw _privateConstructorUsedError;

  /// Serializes this MatchTeamSnapshot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchTeamSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchTeamSnapshotCopyWith<MatchTeamSnapshot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchTeamSnapshotCopyWith<$Res> {
  factory $MatchTeamSnapshotCopyWith(
    MatchTeamSnapshot value,
    $Res Function(MatchTeamSnapshot) then,
  ) = _$MatchTeamSnapshotCopyWithImpl<$Res, MatchTeamSnapshot>;
  @useResult
  $Res call({
    String teamId,
    List<Player> startingXi,
    List<Player> bench,
    List<Position> assignedPositions,
    List<AssignedRole> assignedRoles,
    TacticsSetup tactics,
    double chemistry,
    int atmosphere,
    double cohesionMultiplier,
    TeamStaff staff,
  });

  $TacticsSetupCopyWith<$Res> get tactics;
  $TeamStaffCopyWith<$Res> get staff;
}

/// @nodoc
class _$MatchTeamSnapshotCopyWithImpl<$Res, $Val extends MatchTeamSnapshot>
    implements $MatchTeamSnapshotCopyWith<$Res> {
  _$MatchTeamSnapshotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchTeamSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teamId = null,
    Object? startingXi = null,
    Object? bench = null,
    Object? assignedPositions = null,
    Object? assignedRoles = null,
    Object? tactics = null,
    Object? chemistry = null,
    Object? atmosphere = null,
    Object? cohesionMultiplier = null,
    Object? staff = null,
  }) {
    return _then(
      _value.copyWith(
            teamId: null == teamId
                ? _value.teamId
                : teamId // ignore: cast_nullable_to_non_nullable
                      as String,
            startingXi: null == startingXi
                ? _value.startingXi
                : startingXi // ignore: cast_nullable_to_non_nullable
                      as List<Player>,
            bench: null == bench
                ? _value.bench
                : bench // ignore: cast_nullable_to_non_nullable
                      as List<Player>,
            assignedPositions: null == assignedPositions
                ? _value.assignedPositions
                : assignedPositions // ignore: cast_nullable_to_non_nullable
                      as List<Position>,
            assignedRoles: null == assignedRoles
                ? _value.assignedRoles
                : assignedRoles // ignore: cast_nullable_to_non_nullable
                      as List<AssignedRole>,
            tactics: null == tactics
                ? _value.tactics
                : tactics // ignore: cast_nullable_to_non_nullable
                      as TacticsSetup,
            chemistry: null == chemistry
                ? _value.chemistry
                : chemistry // ignore: cast_nullable_to_non_nullable
                      as double,
            atmosphere: null == atmosphere
                ? _value.atmosphere
                : atmosphere // ignore: cast_nullable_to_non_nullable
                      as int,
            cohesionMultiplier: null == cohesionMultiplier
                ? _value.cohesionMultiplier
                : cohesionMultiplier // ignore: cast_nullable_to_non_nullable
                      as double,
            staff: null == staff
                ? _value.staff
                : staff // ignore: cast_nullable_to_non_nullable
                      as TeamStaff,
          )
          as $Val,
    );
  }

  /// Create a copy of MatchTeamSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TacticsSetupCopyWith<$Res> get tactics {
    return $TacticsSetupCopyWith<$Res>(_value.tactics, (value) {
      return _then(_value.copyWith(tactics: value) as $Val);
    });
  }

  /// Create a copy of MatchTeamSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamStaffCopyWith<$Res> get staff {
    return $TeamStaffCopyWith<$Res>(_value.staff, (value) {
      return _then(_value.copyWith(staff: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchTeamSnapshotImplCopyWith<$Res>
    implements $MatchTeamSnapshotCopyWith<$Res> {
  factory _$$MatchTeamSnapshotImplCopyWith(
    _$MatchTeamSnapshotImpl value,
    $Res Function(_$MatchTeamSnapshotImpl) then,
  ) = __$$MatchTeamSnapshotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String teamId,
    List<Player> startingXi,
    List<Player> bench,
    List<Position> assignedPositions,
    List<AssignedRole> assignedRoles,
    TacticsSetup tactics,
    double chemistry,
    int atmosphere,
    double cohesionMultiplier,
    TeamStaff staff,
  });

  @override
  $TacticsSetupCopyWith<$Res> get tactics;
  @override
  $TeamStaffCopyWith<$Res> get staff;
}

/// @nodoc
class __$$MatchTeamSnapshotImplCopyWithImpl<$Res>
    extends _$MatchTeamSnapshotCopyWithImpl<$Res, _$MatchTeamSnapshotImpl>
    implements _$$MatchTeamSnapshotImplCopyWith<$Res> {
  __$$MatchTeamSnapshotImplCopyWithImpl(
    _$MatchTeamSnapshotImpl _value,
    $Res Function(_$MatchTeamSnapshotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchTeamSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teamId = null,
    Object? startingXi = null,
    Object? bench = null,
    Object? assignedPositions = null,
    Object? assignedRoles = null,
    Object? tactics = null,
    Object? chemistry = null,
    Object? atmosphere = null,
    Object? cohesionMultiplier = null,
    Object? staff = null,
  }) {
    return _then(
      _$MatchTeamSnapshotImpl(
        teamId: null == teamId
            ? _value.teamId
            : teamId // ignore: cast_nullable_to_non_nullable
                  as String,
        startingXi: null == startingXi
            ? _value._startingXi
            : startingXi // ignore: cast_nullable_to_non_nullable
                  as List<Player>,
        bench: null == bench
            ? _value._bench
            : bench // ignore: cast_nullable_to_non_nullable
                  as List<Player>,
        assignedPositions: null == assignedPositions
            ? _value._assignedPositions
            : assignedPositions // ignore: cast_nullable_to_non_nullable
                  as List<Position>,
        assignedRoles: null == assignedRoles
            ? _value._assignedRoles
            : assignedRoles // ignore: cast_nullable_to_non_nullable
                  as List<AssignedRole>,
        tactics: null == tactics
            ? _value.tactics
            : tactics // ignore: cast_nullable_to_non_nullable
                  as TacticsSetup,
        chemistry: null == chemistry
            ? _value.chemistry
            : chemistry // ignore: cast_nullable_to_non_nullable
                  as double,
        atmosphere: null == atmosphere
            ? _value.atmosphere
            : atmosphere // ignore: cast_nullable_to_non_nullable
                  as int,
        cohesionMultiplier: null == cohesionMultiplier
            ? _value.cohesionMultiplier
            : cohesionMultiplier // ignore: cast_nullable_to_non_nullable
                  as double,
        staff: null == staff
            ? _value.staff
            : staff // ignore: cast_nullable_to_non_nullable
                  as TeamStaff,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchTeamSnapshotImpl implements _MatchTeamSnapshot {
  const _$MatchTeamSnapshotImpl({
    this.teamId = '',
    final List<Player> startingXi = const [],
    final List<Player> bench = const [],
    final List<Position> assignedPositions = const [],
    final List<AssignedRole> assignedRoles = const [],
    this.tactics = const TacticsSetup(),
    this.chemistry = 50.0,
    this.atmosphere = 50,
    this.cohesionMultiplier = 1.0,
    this.staff = const TeamStaff(),
  }) : _startingXi = startingXi,
       _bench = bench,
       _assignedPositions = assignedPositions,
       _assignedRoles = assignedRoles;

  factory _$MatchTeamSnapshotImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchTeamSnapshotImplFromJson(json);

  @override
  @JsonKey()
  final String teamId;
  final List<Player> _startingXi;
  @override
  @JsonKey()
  List<Player> get startingXi {
    if (_startingXi is EqualUnmodifiableListView) return _startingXi;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_startingXi);
  }

  final List<Player> _bench;
  @override
  @JsonKey()
  List<Player> get bench {
    if (_bench is EqualUnmodifiableListView) return _bench;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bench);
  }

  final List<Position> _assignedPositions;
  @override
  @JsonKey()
  List<Position> get assignedPositions {
    if (_assignedPositions is EqualUnmodifiableListView)
      return _assignedPositions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assignedPositions);
  }

  final List<AssignedRole> _assignedRoles;
  @override
  @JsonKey()
  List<AssignedRole> get assignedRoles {
    if (_assignedRoles is EqualUnmodifiableListView) return _assignedRoles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_assignedRoles);
  }

  @override
  @JsonKey()
  final TacticsSetup tactics;
  @override
  @JsonKey()
  final double chemistry;
  @override
  @JsonKey()
  final int atmosphere;
  @override
  @JsonKey()
  final double cohesionMultiplier;
  @override
  @JsonKey()
  final TeamStaff staff;

  @override
  String toString() {
    return 'MatchTeamSnapshot(teamId: $teamId, startingXi: $startingXi, bench: $bench, assignedPositions: $assignedPositions, assignedRoles: $assignedRoles, tactics: $tactics, chemistry: $chemistry, atmosphere: $atmosphere, cohesionMultiplier: $cohesionMultiplier, staff: $staff)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchTeamSnapshotImpl &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            const DeepCollectionEquality().equals(
              other._startingXi,
              _startingXi,
            ) &&
            const DeepCollectionEquality().equals(other._bench, _bench) &&
            const DeepCollectionEquality().equals(
              other._assignedPositions,
              _assignedPositions,
            ) &&
            const DeepCollectionEquality().equals(
              other._assignedRoles,
              _assignedRoles,
            ) &&
            (identical(other.tactics, tactics) || other.tactics == tactics) &&
            (identical(other.chemistry, chemistry) ||
                other.chemistry == chemistry) &&
            (identical(other.atmosphere, atmosphere) ||
                other.atmosphere == atmosphere) &&
            (identical(other.cohesionMultiplier, cohesionMultiplier) ||
                other.cohesionMultiplier == cohesionMultiplier) &&
            (identical(other.staff, staff) || other.staff == staff));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    teamId,
    const DeepCollectionEquality().hash(_startingXi),
    const DeepCollectionEquality().hash(_bench),
    const DeepCollectionEquality().hash(_assignedPositions),
    const DeepCollectionEquality().hash(_assignedRoles),
    tactics,
    chemistry,
    atmosphere,
    cohesionMultiplier,
    staff,
  );

  /// Create a copy of MatchTeamSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchTeamSnapshotImplCopyWith<_$MatchTeamSnapshotImpl> get copyWith =>
      __$$MatchTeamSnapshotImplCopyWithImpl<_$MatchTeamSnapshotImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchTeamSnapshotImplToJson(this);
  }
}

abstract class _MatchTeamSnapshot implements MatchTeamSnapshot {
  const factory _MatchTeamSnapshot({
    final String teamId,
    final List<Player> startingXi,
    final List<Player> bench,
    final List<Position> assignedPositions,
    final List<AssignedRole> assignedRoles,
    final TacticsSetup tactics,
    final double chemistry,
    final int atmosphere,
    final double cohesionMultiplier,
    final TeamStaff staff,
  }) = _$MatchTeamSnapshotImpl;

  factory _MatchTeamSnapshot.fromJson(Map<String, dynamic> json) =
      _$MatchTeamSnapshotImpl.fromJson;

  @override
  String get teamId;
  @override
  List<Player> get startingXi;
  @override
  List<Player> get bench;
  @override
  List<Position> get assignedPositions;
  @override
  List<AssignedRole> get assignedRoles;
  @override
  TacticsSetup get tactics;
  @override
  double get chemistry;
  @override
  int get atmosphere;
  @override
  double get cohesionMultiplier;
  @override
  TeamStaff get staff;

  /// Create a copy of MatchTeamSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchTeamSnapshotImplCopyWith<_$MatchTeamSnapshotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchResult _$MatchResultFromJson(Map<String, dynamic> json) {
  return _MatchResult.fromJson(json);
}

/// @nodoc
mixin _$MatchResult {
  String get homeTeamId => throw _privateConstructorUsedError;
  String get awayTeamId => throw _privateConstructorUsedError;
  int get homeGoals => throw _privateConstructorUsedError;
  int get awayGoals => throw _privateConstructorUsedError;
  TeamMatchStats get homeStats => throw _privateConstructorUsedError;
  TeamMatchStats get awayStats => throw _privateConstructorUsedError;
  MatchStatus get status => throw _privateConstructorUsedError;
  String? get reasonCode => throw _privateConstructorUsedError;
  List<String> get violatingTeamIds => throw _privateConstructorUsedError;
  bool get isWalkover => throw _privateConstructorUsedError;
  bool get noGkPenalty => throw _privateConstructorUsedError;
  List<String> get noGkPenaltyTeamIds => throw _privateConstructorUsedError;
  MatchContext get context => throw _privateConstructorUsedError;
  TacticsSetup get homeTactics => throw _privateConstructorUsedError;
  TacticsSetup get awayTactics => throw _privateConstructorUsedError;
  List<Player> get homeLineup => throw _privateConstructorUsedError;
  List<Player> get awayLineup => throw _privateConstructorUsedError;
  List<Position> get homeLineupPositions => throw _privateConstructorUsedError;
  List<Position> get awayLineupPositions => throw _privateConstructorUsedError;
  MatchTeamSnapshot get homeSnapshot => throw _privateConstructorUsedError;
  MatchTeamSnapshot get awaySnapshot => throw _privateConstructorUsedError;
  List<PlayerMatchStats> get playerStats => throw _privateConstructorUsedError;
  List<MatchEvent> get events => throw _privateConstructorUsedError;
  List<MatchInjury> get injuries => throw _privateConstructorUsedError;
  List<MatchDiscipline> get disciplines => throw _privateConstructorUsedError;

  /// Serializes this MatchResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchResultCopyWith<MatchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchResultCopyWith<$Res> {
  factory $MatchResultCopyWith(
    MatchResult value,
    $Res Function(MatchResult) then,
  ) = _$MatchResultCopyWithImpl<$Res, MatchResult>;
  @useResult
  $Res call({
    String homeTeamId,
    String awayTeamId,
    int homeGoals,
    int awayGoals,
    TeamMatchStats homeStats,
    TeamMatchStats awayStats,
    MatchStatus status,
    String? reasonCode,
    List<String> violatingTeamIds,
    bool isWalkover,
    bool noGkPenalty,
    List<String> noGkPenaltyTeamIds,
    MatchContext context,
    TacticsSetup homeTactics,
    TacticsSetup awayTactics,
    List<Player> homeLineup,
    List<Player> awayLineup,
    List<Position> homeLineupPositions,
    List<Position> awayLineupPositions,
    MatchTeamSnapshot homeSnapshot,
    MatchTeamSnapshot awaySnapshot,
    List<PlayerMatchStats> playerStats,
    List<MatchEvent> events,
    List<MatchInjury> injuries,
    List<MatchDiscipline> disciplines,
  });

  $TeamMatchStatsCopyWith<$Res> get homeStats;
  $TeamMatchStatsCopyWith<$Res> get awayStats;
  $MatchContextCopyWith<$Res> get context;
  $TacticsSetupCopyWith<$Res> get homeTactics;
  $TacticsSetupCopyWith<$Res> get awayTactics;
  $MatchTeamSnapshotCopyWith<$Res> get homeSnapshot;
  $MatchTeamSnapshotCopyWith<$Res> get awaySnapshot;
}

/// @nodoc
class _$MatchResultCopyWithImpl<$Res, $Val extends MatchResult>
    implements $MatchResultCopyWith<$Res> {
  _$MatchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? homeTeamId = null,
    Object? awayTeamId = null,
    Object? homeGoals = null,
    Object? awayGoals = null,
    Object? homeStats = null,
    Object? awayStats = null,
    Object? status = null,
    Object? reasonCode = freezed,
    Object? violatingTeamIds = null,
    Object? isWalkover = null,
    Object? noGkPenalty = null,
    Object? noGkPenaltyTeamIds = null,
    Object? context = null,
    Object? homeTactics = null,
    Object? awayTactics = null,
    Object? homeLineup = null,
    Object? awayLineup = null,
    Object? homeLineupPositions = null,
    Object? awayLineupPositions = null,
    Object? homeSnapshot = null,
    Object? awaySnapshot = null,
    Object? playerStats = null,
    Object? events = null,
    Object? injuries = null,
    Object? disciplines = null,
  }) {
    return _then(
      _value.copyWith(
            homeTeamId: null == homeTeamId
                ? _value.homeTeamId
                : homeTeamId // ignore: cast_nullable_to_non_nullable
                      as String,
            awayTeamId: null == awayTeamId
                ? _value.awayTeamId
                : awayTeamId // ignore: cast_nullable_to_non_nullable
                      as String,
            homeGoals: null == homeGoals
                ? _value.homeGoals
                : homeGoals // ignore: cast_nullable_to_non_nullable
                      as int,
            awayGoals: null == awayGoals
                ? _value.awayGoals
                : awayGoals // ignore: cast_nullable_to_non_nullable
                      as int,
            homeStats: null == homeStats
                ? _value.homeStats
                : homeStats // ignore: cast_nullable_to_non_nullable
                      as TeamMatchStats,
            awayStats: null == awayStats
                ? _value.awayStats
                : awayStats // ignore: cast_nullable_to_non_nullable
                      as TeamMatchStats,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MatchStatus,
            reasonCode: freezed == reasonCode
                ? _value.reasonCode
                : reasonCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            violatingTeamIds: null == violatingTeamIds
                ? _value.violatingTeamIds
                : violatingTeamIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            isWalkover: null == isWalkover
                ? _value.isWalkover
                : isWalkover // ignore: cast_nullable_to_non_nullable
                      as bool,
            noGkPenalty: null == noGkPenalty
                ? _value.noGkPenalty
                : noGkPenalty // ignore: cast_nullable_to_non_nullable
                      as bool,
            noGkPenaltyTeamIds: null == noGkPenaltyTeamIds
                ? _value.noGkPenaltyTeamIds
                : noGkPenaltyTeamIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            context: null == context
                ? _value.context
                : context // ignore: cast_nullable_to_non_nullable
                      as MatchContext,
            homeTactics: null == homeTactics
                ? _value.homeTactics
                : homeTactics // ignore: cast_nullable_to_non_nullable
                      as TacticsSetup,
            awayTactics: null == awayTactics
                ? _value.awayTactics
                : awayTactics // ignore: cast_nullable_to_non_nullable
                      as TacticsSetup,
            homeLineup: null == homeLineup
                ? _value.homeLineup
                : homeLineup // ignore: cast_nullable_to_non_nullable
                      as List<Player>,
            awayLineup: null == awayLineup
                ? _value.awayLineup
                : awayLineup // ignore: cast_nullable_to_non_nullable
                      as List<Player>,
            homeLineupPositions: null == homeLineupPositions
                ? _value.homeLineupPositions
                : homeLineupPositions // ignore: cast_nullable_to_non_nullable
                      as List<Position>,
            awayLineupPositions: null == awayLineupPositions
                ? _value.awayLineupPositions
                : awayLineupPositions // ignore: cast_nullable_to_non_nullable
                      as List<Position>,
            homeSnapshot: null == homeSnapshot
                ? _value.homeSnapshot
                : homeSnapshot // ignore: cast_nullable_to_non_nullable
                      as MatchTeamSnapshot,
            awaySnapshot: null == awaySnapshot
                ? _value.awaySnapshot
                : awaySnapshot // ignore: cast_nullable_to_non_nullable
                      as MatchTeamSnapshot,
            playerStats: null == playerStats
                ? _value.playerStats
                : playerStats // ignore: cast_nullable_to_non_nullable
                      as List<PlayerMatchStats>,
            events: null == events
                ? _value.events
                : events // ignore: cast_nullable_to_non_nullable
                      as List<MatchEvent>,
            injuries: null == injuries
                ? _value.injuries
                : injuries // ignore: cast_nullable_to_non_nullable
                      as List<MatchInjury>,
            disciplines: null == disciplines
                ? _value.disciplines
                : disciplines // ignore: cast_nullable_to_non_nullable
                      as List<MatchDiscipline>,
          )
          as $Val,
    );
  }

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamMatchStatsCopyWith<$Res> get homeStats {
    return $TeamMatchStatsCopyWith<$Res>(_value.homeStats, (value) {
      return _then(_value.copyWith(homeStats: value) as $Val);
    });
  }

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamMatchStatsCopyWith<$Res> get awayStats {
    return $TeamMatchStatsCopyWith<$Res>(_value.awayStats, (value) {
      return _then(_value.copyWith(awayStats: value) as $Val);
    });
  }

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchContextCopyWith<$Res> get context {
    return $MatchContextCopyWith<$Res>(_value.context, (value) {
      return _then(_value.copyWith(context: value) as $Val);
    });
  }

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TacticsSetupCopyWith<$Res> get homeTactics {
    return $TacticsSetupCopyWith<$Res>(_value.homeTactics, (value) {
      return _then(_value.copyWith(homeTactics: value) as $Val);
    });
  }

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TacticsSetupCopyWith<$Res> get awayTactics {
    return $TacticsSetupCopyWith<$Res>(_value.awayTactics, (value) {
      return _then(_value.copyWith(awayTactics: value) as $Val);
    });
  }

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchTeamSnapshotCopyWith<$Res> get homeSnapshot {
    return $MatchTeamSnapshotCopyWith<$Res>(_value.homeSnapshot, (value) {
      return _then(_value.copyWith(homeSnapshot: value) as $Val);
    });
  }

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchTeamSnapshotCopyWith<$Res> get awaySnapshot {
    return $MatchTeamSnapshotCopyWith<$Res>(_value.awaySnapshot, (value) {
      return _then(_value.copyWith(awaySnapshot: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchResultImplCopyWith<$Res>
    implements $MatchResultCopyWith<$Res> {
  factory _$$MatchResultImplCopyWith(
    _$MatchResultImpl value,
    $Res Function(_$MatchResultImpl) then,
  ) = __$$MatchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String homeTeamId,
    String awayTeamId,
    int homeGoals,
    int awayGoals,
    TeamMatchStats homeStats,
    TeamMatchStats awayStats,
    MatchStatus status,
    String? reasonCode,
    List<String> violatingTeamIds,
    bool isWalkover,
    bool noGkPenalty,
    List<String> noGkPenaltyTeamIds,
    MatchContext context,
    TacticsSetup homeTactics,
    TacticsSetup awayTactics,
    List<Player> homeLineup,
    List<Player> awayLineup,
    List<Position> homeLineupPositions,
    List<Position> awayLineupPositions,
    MatchTeamSnapshot homeSnapshot,
    MatchTeamSnapshot awaySnapshot,
    List<PlayerMatchStats> playerStats,
    List<MatchEvent> events,
    List<MatchInjury> injuries,
    List<MatchDiscipline> disciplines,
  });

  @override
  $TeamMatchStatsCopyWith<$Res> get homeStats;
  @override
  $TeamMatchStatsCopyWith<$Res> get awayStats;
  @override
  $MatchContextCopyWith<$Res> get context;
  @override
  $TacticsSetupCopyWith<$Res> get homeTactics;
  @override
  $TacticsSetupCopyWith<$Res> get awayTactics;
  @override
  $MatchTeamSnapshotCopyWith<$Res> get homeSnapshot;
  @override
  $MatchTeamSnapshotCopyWith<$Res> get awaySnapshot;
}

/// @nodoc
class __$$MatchResultImplCopyWithImpl<$Res>
    extends _$MatchResultCopyWithImpl<$Res, _$MatchResultImpl>
    implements _$$MatchResultImplCopyWith<$Res> {
  __$$MatchResultImplCopyWithImpl(
    _$MatchResultImpl _value,
    $Res Function(_$MatchResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? homeTeamId = null,
    Object? awayTeamId = null,
    Object? homeGoals = null,
    Object? awayGoals = null,
    Object? homeStats = null,
    Object? awayStats = null,
    Object? status = null,
    Object? reasonCode = freezed,
    Object? violatingTeamIds = null,
    Object? isWalkover = null,
    Object? noGkPenalty = null,
    Object? noGkPenaltyTeamIds = null,
    Object? context = null,
    Object? homeTactics = null,
    Object? awayTactics = null,
    Object? homeLineup = null,
    Object? awayLineup = null,
    Object? homeLineupPositions = null,
    Object? awayLineupPositions = null,
    Object? homeSnapshot = null,
    Object? awaySnapshot = null,
    Object? playerStats = null,
    Object? events = null,
    Object? injuries = null,
    Object? disciplines = null,
  }) {
    return _then(
      _$MatchResultImpl(
        homeTeamId: null == homeTeamId
            ? _value.homeTeamId
            : homeTeamId // ignore: cast_nullable_to_non_nullable
                  as String,
        awayTeamId: null == awayTeamId
            ? _value.awayTeamId
            : awayTeamId // ignore: cast_nullable_to_non_nullable
                  as String,
        homeGoals: null == homeGoals
            ? _value.homeGoals
            : homeGoals // ignore: cast_nullable_to_non_nullable
                  as int,
        awayGoals: null == awayGoals
            ? _value.awayGoals
            : awayGoals // ignore: cast_nullable_to_non_nullable
                  as int,
        homeStats: null == homeStats
            ? _value.homeStats
            : homeStats // ignore: cast_nullable_to_non_nullable
                  as TeamMatchStats,
        awayStats: null == awayStats
            ? _value.awayStats
            : awayStats // ignore: cast_nullable_to_non_nullable
                  as TeamMatchStats,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MatchStatus,
        reasonCode: freezed == reasonCode
            ? _value.reasonCode
            : reasonCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        violatingTeamIds: null == violatingTeamIds
            ? _value._violatingTeamIds
            : violatingTeamIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        isWalkover: null == isWalkover
            ? _value.isWalkover
            : isWalkover // ignore: cast_nullable_to_non_nullable
                  as bool,
        noGkPenalty: null == noGkPenalty
            ? _value.noGkPenalty
            : noGkPenalty // ignore: cast_nullable_to_non_nullable
                  as bool,
        noGkPenaltyTeamIds: null == noGkPenaltyTeamIds
            ? _value._noGkPenaltyTeamIds
            : noGkPenaltyTeamIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        context: null == context
            ? _value.context
            : context // ignore: cast_nullable_to_non_nullable
                  as MatchContext,
        homeTactics: null == homeTactics
            ? _value.homeTactics
            : homeTactics // ignore: cast_nullable_to_non_nullable
                  as TacticsSetup,
        awayTactics: null == awayTactics
            ? _value.awayTactics
            : awayTactics // ignore: cast_nullable_to_non_nullable
                  as TacticsSetup,
        homeLineup: null == homeLineup
            ? _value._homeLineup
            : homeLineup // ignore: cast_nullable_to_non_nullable
                  as List<Player>,
        awayLineup: null == awayLineup
            ? _value._awayLineup
            : awayLineup // ignore: cast_nullable_to_non_nullable
                  as List<Player>,
        homeLineupPositions: null == homeLineupPositions
            ? _value._homeLineupPositions
            : homeLineupPositions // ignore: cast_nullable_to_non_nullable
                  as List<Position>,
        awayLineupPositions: null == awayLineupPositions
            ? _value._awayLineupPositions
            : awayLineupPositions // ignore: cast_nullable_to_non_nullable
                  as List<Position>,
        homeSnapshot: null == homeSnapshot
            ? _value.homeSnapshot
            : homeSnapshot // ignore: cast_nullable_to_non_nullable
                  as MatchTeamSnapshot,
        awaySnapshot: null == awaySnapshot
            ? _value.awaySnapshot
            : awaySnapshot // ignore: cast_nullable_to_non_nullable
                  as MatchTeamSnapshot,
        playerStats: null == playerStats
            ? _value._playerStats
            : playerStats // ignore: cast_nullable_to_non_nullable
                  as List<PlayerMatchStats>,
        events: null == events
            ? _value._events
            : events // ignore: cast_nullable_to_non_nullable
                  as List<MatchEvent>,
        injuries: null == injuries
            ? _value._injuries
            : injuries // ignore: cast_nullable_to_non_nullable
                  as List<MatchInjury>,
        disciplines: null == disciplines
            ? _value._disciplines
            : disciplines // ignore: cast_nullable_to_non_nullable
                  as List<MatchDiscipline>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchResultImpl implements _MatchResult {
  const _$MatchResultImpl({
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeGoals,
    required this.awayGoals,
    required this.homeStats,
    required this.awayStats,
    this.status = MatchStatus.played,
    this.reasonCode,
    final List<String> violatingTeamIds = const [],
    this.isWalkover = false,
    this.noGkPenalty = false,
    final List<String> noGkPenaltyTeamIds = const [],
    this.context = const MatchContext(),
    this.homeTactics = const TacticsSetup(),
    this.awayTactics = const TacticsSetup(),
    final List<Player> homeLineup = const [],
    final List<Player> awayLineup = const [],
    final List<Position> homeLineupPositions = const [],
    final List<Position> awayLineupPositions = const [],
    this.homeSnapshot = const MatchTeamSnapshot(),
    this.awaySnapshot = const MatchTeamSnapshot(),
    final List<PlayerMatchStats> playerStats = const [],
    final List<MatchEvent> events = const [],
    final List<MatchInjury> injuries = const [],
    final List<MatchDiscipline> disciplines = const [],
  }) : _violatingTeamIds = violatingTeamIds,
       _noGkPenaltyTeamIds = noGkPenaltyTeamIds,
       _homeLineup = homeLineup,
       _awayLineup = awayLineup,
       _homeLineupPositions = homeLineupPositions,
       _awayLineupPositions = awayLineupPositions,
       _playerStats = playerStats,
       _events = events,
       _injuries = injuries,
       _disciplines = disciplines;

  factory _$MatchResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchResultImplFromJson(json);

  @override
  final String homeTeamId;
  @override
  final String awayTeamId;
  @override
  final int homeGoals;
  @override
  final int awayGoals;
  @override
  final TeamMatchStats homeStats;
  @override
  final TeamMatchStats awayStats;
  @override
  @JsonKey()
  final MatchStatus status;
  @override
  final String? reasonCode;
  final List<String> _violatingTeamIds;
  @override
  @JsonKey()
  List<String> get violatingTeamIds {
    if (_violatingTeamIds is EqualUnmodifiableListView)
      return _violatingTeamIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_violatingTeamIds);
  }

  @override
  @JsonKey()
  final bool isWalkover;
  @override
  @JsonKey()
  final bool noGkPenalty;
  final List<String> _noGkPenaltyTeamIds;
  @override
  @JsonKey()
  List<String> get noGkPenaltyTeamIds {
    if (_noGkPenaltyTeamIds is EqualUnmodifiableListView)
      return _noGkPenaltyTeamIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_noGkPenaltyTeamIds);
  }

  @override
  @JsonKey()
  final MatchContext context;
  @override
  @JsonKey()
  final TacticsSetup homeTactics;
  @override
  @JsonKey()
  final TacticsSetup awayTactics;
  final List<Player> _homeLineup;
  @override
  @JsonKey()
  List<Player> get homeLineup {
    if (_homeLineup is EqualUnmodifiableListView) return _homeLineup;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_homeLineup);
  }

  final List<Player> _awayLineup;
  @override
  @JsonKey()
  List<Player> get awayLineup {
    if (_awayLineup is EqualUnmodifiableListView) return _awayLineup;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_awayLineup);
  }

  final List<Position> _homeLineupPositions;
  @override
  @JsonKey()
  List<Position> get homeLineupPositions {
    if (_homeLineupPositions is EqualUnmodifiableListView)
      return _homeLineupPositions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_homeLineupPositions);
  }

  final List<Position> _awayLineupPositions;
  @override
  @JsonKey()
  List<Position> get awayLineupPositions {
    if (_awayLineupPositions is EqualUnmodifiableListView)
      return _awayLineupPositions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_awayLineupPositions);
  }

  @override
  @JsonKey()
  final MatchTeamSnapshot homeSnapshot;
  @override
  @JsonKey()
  final MatchTeamSnapshot awaySnapshot;
  final List<PlayerMatchStats> _playerStats;
  @override
  @JsonKey()
  List<PlayerMatchStats> get playerStats {
    if (_playerStats is EqualUnmodifiableListView) return _playerStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playerStats);
  }

  final List<MatchEvent> _events;
  @override
  @JsonKey()
  List<MatchEvent> get events {
    if (_events is EqualUnmodifiableListView) return _events;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_events);
  }

  final List<MatchInjury> _injuries;
  @override
  @JsonKey()
  List<MatchInjury> get injuries {
    if (_injuries is EqualUnmodifiableListView) return _injuries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_injuries);
  }

  final List<MatchDiscipline> _disciplines;
  @override
  @JsonKey()
  List<MatchDiscipline> get disciplines {
    if (_disciplines is EqualUnmodifiableListView) return _disciplines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_disciplines);
  }

  @override
  String toString() {
    return 'MatchResult(homeTeamId: $homeTeamId, awayTeamId: $awayTeamId, homeGoals: $homeGoals, awayGoals: $awayGoals, homeStats: $homeStats, awayStats: $awayStats, status: $status, reasonCode: $reasonCode, violatingTeamIds: $violatingTeamIds, isWalkover: $isWalkover, noGkPenalty: $noGkPenalty, noGkPenaltyTeamIds: $noGkPenaltyTeamIds, context: $context, homeTactics: $homeTactics, awayTactics: $awayTactics, homeLineup: $homeLineup, awayLineup: $awayLineup, homeLineupPositions: $homeLineupPositions, awayLineupPositions: $awayLineupPositions, homeSnapshot: $homeSnapshot, awaySnapshot: $awaySnapshot, playerStats: $playerStats, events: $events, injuries: $injuries, disciplines: $disciplines)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchResultImpl &&
            (identical(other.homeTeamId, homeTeamId) ||
                other.homeTeamId == homeTeamId) &&
            (identical(other.awayTeamId, awayTeamId) ||
                other.awayTeamId == awayTeamId) &&
            (identical(other.homeGoals, homeGoals) ||
                other.homeGoals == homeGoals) &&
            (identical(other.awayGoals, awayGoals) ||
                other.awayGoals == awayGoals) &&
            (identical(other.homeStats, homeStats) ||
                other.homeStats == homeStats) &&
            (identical(other.awayStats, awayStats) ||
                other.awayStats == awayStats) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reasonCode, reasonCode) ||
                other.reasonCode == reasonCode) &&
            const DeepCollectionEquality().equals(
              other._violatingTeamIds,
              _violatingTeamIds,
            ) &&
            (identical(other.isWalkover, isWalkover) ||
                other.isWalkover == isWalkover) &&
            (identical(other.noGkPenalty, noGkPenalty) ||
                other.noGkPenalty == noGkPenalty) &&
            const DeepCollectionEquality().equals(
              other._noGkPenaltyTeamIds,
              _noGkPenaltyTeamIds,
            ) &&
            (identical(other.context, context) || other.context == context) &&
            (identical(other.homeTactics, homeTactics) ||
                other.homeTactics == homeTactics) &&
            (identical(other.awayTactics, awayTactics) ||
                other.awayTactics == awayTactics) &&
            const DeepCollectionEquality().equals(
              other._homeLineup,
              _homeLineup,
            ) &&
            const DeepCollectionEquality().equals(
              other._awayLineup,
              _awayLineup,
            ) &&
            const DeepCollectionEquality().equals(
              other._homeLineupPositions,
              _homeLineupPositions,
            ) &&
            const DeepCollectionEquality().equals(
              other._awayLineupPositions,
              _awayLineupPositions,
            ) &&
            (identical(other.homeSnapshot, homeSnapshot) ||
                other.homeSnapshot == homeSnapshot) &&
            (identical(other.awaySnapshot, awaySnapshot) ||
                other.awaySnapshot == awaySnapshot) &&
            const DeepCollectionEquality().equals(
              other._playerStats,
              _playerStats,
            ) &&
            const DeepCollectionEquality().equals(other._events, _events) &&
            const DeepCollectionEquality().equals(other._injuries, _injuries) &&
            const DeepCollectionEquality().equals(
              other._disciplines,
              _disciplines,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    homeTeamId,
    awayTeamId,
    homeGoals,
    awayGoals,
    homeStats,
    awayStats,
    status,
    reasonCode,
    const DeepCollectionEquality().hash(_violatingTeamIds),
    isWalkover,
    noGkPenalty,
    const DeepCollectionEquality().hash(_noGkPenaltyTeamIds),
    context,
    homeTactics,
    awayTactics,
    const DeepCollectionEquality().hash(_homeLineup),
    const DeepCollectionEquality().hash(_awayLineup),
    const DeepCollectionEquality().hash(_homeLineupPositions),
    const DeepCollectionEquality().hash(_awayLineupPositions),
    homeSnapshot,
    awaySnapshot,
    const DeepCollectionEquality().hash(_playerStats),
    const DeepCollectionEquality().hash(_events),
    const DeepCollectionEquality().hash(_injuries),
    const DeepCollectionEquality().hash(_disciplines),
  ]);

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchResultImplCopyWith<_$MatchResultImpl> get copyWith =>
      __$$MatchResultImplCopyWithImpl<_$MatchResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchResultImplToJson(this);
  }
}

abstract class _MatchResult implements MatchResult {
  const factory _MatchResult({
    required final String homeTeamId,
    required final String awayTeamId,
    required final int homeGoals,
    required final int awayGoals,
    required final TeamMatchStats homeStats,
    required final TeamMatchStats awayStats,
    final MatchStatus status,
    final String? reasonCode,
    final List<String> violatingTeamIds,
    final bool isWalkover,
    final bool noGkPenalty,
    final List<String> noGkPenaltyTeamIds,
    final MatchContext context,
    final TacticsSetup homeTactics,
    final TacticsSetup awayTactics,
    final List<Player> homeLineup,
    final List<Player> awayLineup,
    final List<Position> homeLineupPositions,
    final List<Position> awayLineupPositions,
    final MatchTeamSnapshot homeSnapshot,
    final MatchTeamSnapshot awaySnapshot,
    final List<PlayerMatchStats> playerStats,
    final List<MatchEvent> events,
    final List<MatchInjury> injuries,
    final List<MatchDiscipline> disciplines,
  }) = _$MatchResultImpl;

  factory _MatchResult.fromJson(Map<String, dynamic> json) =
      _$MatchResultImpl.fromJson;

  @override
  String get homeTeamId;
  @override
  String get awayTeamId;
  @override
  int get homeGoals;
  @override
  int get awayGoals;
  @override
  TeamMatchStats get homeStats;
  @override
  TeamMatchStats get awayStats;
  @override
  MatchStatus get status;
  @override
  String? get reasonCode;
  @override
  List<String> get violatingTeamIds;
  @override
  bool get isWalkover;
  @override
  bool get noGkPenalty;
  @override
  List<String> get noGkPenaltyTeamIds;
  @override
  MatchContext get context;
  @override
  TacticsSetup get homeTactics;
  @override
  TacticsSetup get awayTactics;
  @override
  List<Player> get homeLineup;
  @override
  List<Player> get awayLineup;
  @override
  List<Position> get homeLineupPositions;
  @override
  List<Position> get awayLineupPositions;
  @override
  MatchTeamSnapshot get homeSnapshot;
  @override
  MatchTeamSnapshot get awaySnapshot;
  @override
  List<PlayerMatchStats> get playerStats;
  @override
  List<MatchEvent> get events;
  @override
  List<MatchInjury> get injuries;
  @override
  List<MatchDiscipline> get disciplines;

  /// Create a copy of MatchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchResultImplCopyWith<_$MatchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchSetup _$MatchSetupFromJson(Map<String, dynamic> json) {
  return _MatchSetup.fromJson(json);
}

/// @nodoc
mixin _$MatchSetup {
  String get homeTeamId => throw _privateConstructorUsedError;
  String get awayTeamId => throw _privateConstructorUsedError;
  List<Player> get homeLineup => throw _privateConstructorUsedError;
  List<Player> get awayLineup => throw _privateConstructorUsedError;
  TacticsSetup get homeTactics => throw _privateConstructorUsedError;
  TacticsSetup get awayTactics => throw _privateConstructorUsedError;
  bool get isHomeAdvantage => throw _privateConstructorUsedError;
  int get roundNumber => throw _privateConstructorUsedError;

  /// Serializes this MatchSetup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchSetup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchSetupCopyWith<MatchSetup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchSetupCopyWith<$Res> {
  factory $MatchSetupCopyWith(
    MatchSetup value,
    $Res Function(MatchSetup) then,
  ) = _$MatchSetupCopyWithImpl<$Res, MatchSetup>;
  @useResult
  $Res call({
    String homeTeamId,
    String awayTeamId,
    List<Player> homeLineup,
    List<Player> awayLineup,
    TacticsSetup homeTactics,
    TacticsSetup awayTactics,
    bool isHomeAdvantage,
    int roundNumber,
  });

  $TacticsSetupCopyWith<$Res> get homeTactics;
  $TacticsSetupCopyWith<$Res> get awayTactics;
}

/// @nodoc
class _$MatchSetupCopyWithImpl<$Res, $Val extends MatchSetup>
    implements $MatchSetupCopyWith<$Res> {
  _$MatchSetupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchSetup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? homeTeamId = null,
    Object? awayTeamId = null,
    Object? homeLineup = null,
    Object? awayLineup = null,
    Object? homeTactics = null,
    Object? awayTactics = null,
    Object? isHomeAdvantage = null,
    Object? roundNumber = null,
  }) {
    return _then(
      _value.copyWith(
            homeTeamId: null == homeTeamId
                ? _value.homeTeamId
                : homeTeamId // ignore: cast_nullable_to_non_nullable
                      as String,
            awayTeamId: null == awayTeamId
                ? _value.awayTeamId
                : awayTeamId // ignore: cast_nullable_to_non_nullable
                      as String,
            homeLineup: null == homeLineup
                ? _value.homeLineup
                : homeLineup // ignore: cast_nullable_to_non_nullable
                      as List<Player>,
            awayLineup: null == awayLineup
                ? _value.awayLineup
                : awayLineup // ignore: cast_nullable_to_non_nullable
                      as List<Player>,
            homeTactics: null == homeTactics
                ? _value.homeTactics
                : homeTactics // ignore: cast_nullable_to_non_nullable
                      as TacticsSetup,
            awayTactics: null == awayTactics
                ? _value.awayTactics
                : awayTactics // ignore: cast_nullable_to_non_nullable
                      as TacticsSetup,
            isHomeAdvantage: null == isHomeAdvantage
                ? _value.isHomeAdvantage
                : isHomeAdvantage // ignore: cast_nullable_to_non_nullable
                      as bool,
            roundNumber: null == roundNumber
                ? _value.roundNumber
                : roundNumber // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of MatchSetup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TacticsSetupCopyWith<$Res> get homeTactics {
    return $TacticsSetupCopyWith<$Res>(_value.homeTactics, (value) {
      return _then(_value.copyWith(homeTactics: value) as $Val);
    });
  }

  /// Create a copy of MatchSetup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TacticsSetupCopyWith<$Res> get awayTactics {
    return $TacticsSetupCopyWith<$Res>(_value.awayTactics, (value) {
      return _then(_value.copyWith(awayTactics: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchSetupImplCopyWith<$Res>
    implements $MatchSetupCopyWith<$Res> {
  factory _$$MatchSetupImplCopyWith(
    _$MatchSetupImpl value,
    $Res Function(_$MatchSetupImpl) then,
  ) = __$$MatchSetupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String homeTeamId,
    String awayTeamId,
    List<Player> homeLineup,
    List<Player> awayLineup,
    TacticsSetup homeTactics,
    TacticsSetup awayTactics,
    bool isHomeAdvantage,
    int roundNumber,
  });

  @override
  $TacticsSetupCopyWith<$Res> get homeTactics;
  @override
  $TacticsSetupCopyWith<$Res> get awayTactics;
}

/// @nodoc
class __$$MatchSetupImplCopyWithImpl<$Res>
    extends _$MatchSetupCopyWithImpl<$Res, _$MatchSetupImpl>
    implements _$$MatchSetupImplCopyWith<$Res> {
  __$$MatchSetupImplCopyWithImpl(
    _$MatchSetupImpl _value,
    $Res Function(_$MatchSetupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchSetup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? homeTeamId = null,
    Object? awayTeamId = null,
    Object? homeLineup = null,
    Object? awayLineup = null,
    Object? homeTactics = null,
    Object? awayTactics = null,
    Object? isHomeAdvantage = null,
    Object? roundNumber = null,
  }) {
    return _then(
      _$MatchSetupImpl(
        homeTeamId: null == homeTeamId
            ? _value.homeTeamId
            : homeTeamId // ignore: cast_nullable_to_non_nullable
                  as String,
        awayTeamId: null == awayTeamId
            ? _value.awayTeamId
            : awayTeamId // ignore: cast_nullable_to_non_nullable
                  as String,
        homeLineup: null == homeLineup
            ? _value._homeLineup
            : homeLineup // ignore: cast_nullable_to_non_nullable
                  as List<Player>,
        awayLineup: null == awayLineup
            ? _value._awayLineup
            : awayLineup // ignore: cast_nullable_to_non_nullable
                  as List<Player>,
        homeTactics: null == homeTactics
            ? _value.homeTactics
            : homeTactics // ignore: cast_nullable_to_non_nullable
                  as TacticsSetup,
        awayTactics: null == awayTactics
            ? _value.awayTactics
            : awayTactics // ignore: cast_nullable_to_non_nullable
                  as TacticsSetup,
        isHomeAdvantage: null == isHomeAdvantage
            ? _value.isHomeAdvantage
            : isHomeAdvantage // ignore: cast_nullable_to_non_nullable
                  as bool,
        roundNumber: null == roundNumber
            ? _value.roundNumber
            : roundNumber // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchSetupImpl implements _MatchSetup {
  const _$MatchSetupImpl({
    required this.homeTeamId,
    required this.awayTeamId,
    required final List<Player> homeLineup,
    required final List<Player> awayLineup,
    required this.homeTactics,
    required this.awayTactics,
    this.isHomeAdvantage = false,
    this.roundNumber = 0,
  }) : _homeLineup = homeLineup,
       _awayLineup = awayLineup;

  factory _$MatchSetupImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchSetupImplFromJson(json);

  @override
  final String homeTeamId;
  @override
  final String awayTeamId;
  final List<Player> _homeLineup;
  @override
  List<Player> get homeLineup {
    if (_homeLineup is EqualUnmodifiableListView) return _homeLineup;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_homeLineup);
  }

  final List<Player> _awayLineup;
  @override
  List<Player> get awayLineup {
    if (_awayLineup is EqualUnmodifiableListView) return _awayLineup;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_awayLineup);
  }

  @override
  final TacticsSetup homeTactics;
  @override
  final TacticsSetup awayTactics;
  @override
  @JsonKey()
  final bool isHomeAdvantage;
  @override
  @JsonKey()
  final int roundNumber;

  @override
  String toString() {
    return 'MatchSetup(homeTeamId: $homeTeamId, awayTeamId: $awayTeamId, homeLineup: $homeLineup, awayLineup: $awayLineup, homeTactics: $homeTactics, awayTactics: $awayTactics, isHomeAdvantage: $isHomeAdvantage, roundNumber: $roundNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchSetupImpl &&
            (identical(other.homeTeamId, homeTeamId) ||
                other.homeTeamId == homeTeamId) &&
            (identical(other.awayTeamId, awayTeamId) ||
                other.awayTeamId == awayTeamId) &&
            const DeepCollectionEquality().equals(
              other._homeLineup,
              _homeLineup,
            ) &&
            const DeepCollectionEquality().equals(
              other._awayLineup,
              _awayLineup,
            ) &&
            (identical(other.homeTactics, homeTactics) ||
                other.homeTactics == homeTactics) &&
            (identical(other.awayTactics, awayTactics) ||
                other.awayTactics == awayTactics) &&
            (identical(other.isHomeAdvantage, isHomeAdvantage) ||
                other.isHomeAdvantage == isHomeAdvantage) &&
            (identical(other.roundNumber, roundNumber) ||
                other.roundNumber == roundNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    homeTeamId,
    awayTeamId,
    const DeepCollectionEquality().hash(_homeLineup),
    const DeepCollectionEquality().hash(_awayLineup),
    homeTactics,
    awayTactics,
    isHomeAdvantage,
    roundNumber,
  );

  /// Create a copy of MatchSetup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchSetupImplCopyWith<_$MatchSetupImpl> get copyWith =>
      __$$MatchSetupImplCopyWithImpl<_$MatchSetupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchSetupImplToJson(this);
  }
}

abstract class _MatchSetup implements MatchSetup {
  const factory _MatchSetup({
    required final String homeTeamId,
    required final String awayTeamId,
    required final List<Player> homeLineup,
    required final List<Player> awayLineup,
    required final TacticsSetup homeTactics,
    required final TacticsSetup awayTactics,
    final bool isHomeAdvantage,
    final int roundNumber,
  }) = _$MatchSetupImpl;

  factory _MatchSetup.fromJson(Map<String, dynamic> json) =
      _$MatchSetupImpl.fromJson;

  @override
  String get homeTeamId;
  @override
  String get awayTeamId;
  @override
  List<Player> get homeLineup;
  @override
  List<Player> get awayLineup;
  @override
  TacticsSetup get homeTactics;
  @override
  TacticsSetup get awayTactics;
  @override
  bool get isHomeAdvantage;
  @override
  int get roundNumber;

  /// Create a copy of MatchSetup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchSetupImplCopyWith<_$MatchSetupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScheduledMatch _$ScheduledMatchFromJson(Map<String, dynamic> json) {
  return _ScheduledMatch.fromJson(json);
}

/// @nodoc
mixin _$ScheduledMatch {
  String get id => throw _privateConstructorUsedError;
  String get homeTeamId => throw _privateConstructorUsedError;
  String get awayTeamId => throw _privateConstructorUsedError;
  int get round => throw _privateConstructorUsedError;
  MatchResult? get result => throw _privateConstructorUsedError;

  /// Serializes this ScheduledMatch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScheduledMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScheduledMatchCopyWith<ScheduledMatch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduledMatchCopyWith<$Res> {
  factory $ScheduledMatchCopyWith(
    ScheduledMatch value,
    $Res Function(ScheduledMatch) then,
  ) = _$ScheduledMatchCopyWithImpl<$Res, ScheduledMatch>;
  @useResult
  $Res call({
    String id,
    String homeTeamId,
    String awayTeamId,
    int round,
    MatchResult? result,
  });

  $MatchResultCopyWith<$Res>? get result;
}

/// @nodoc
class _$ScheduledMatchCopyWithImpl<$Res, $Val extends ScheduledMatch>
    implements $ScheduledMatchCopyWith<$Res> {
  _$ScheduledMatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScheduledMatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? homeTeamId = null,
    Object? awayTeamId = null,
    Object? round = null,
    Object? result = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            homeTeamId: null == homeTeamId
                ? _value.homeTeamId
                : homeTeamId // ignore: cast_nullable_to_non_nullable
                      as String,
            awayTeamId: null == awayTeamId
                ? _value.awayTeamId
                : awayTeamId // ignore: cast_nullable_to_non_nullable
                      as String,
            round: null == round
                ? _value.round
                : round // ignore: cast_nullable_to_non_nullable
                      as int,
            result: freezed == result
                ? _value.result
                : result // ignore: cast_nullable_to_non_nullable
                      as MatchResult?,
          )
          as $Val,
    );
  }

  /// Create a copy of ScheduledMatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchResultCopyWith<$Res>? get result {
    if (_value.result == null) {
      return null;
    }

    return $MatchResultCopyWith<$Res>(_value.result!, (value) {
      return _then(_value.copyWith(result: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ScheduledMatchImplCopyWith<$Res>
    implements $ScheduledMatchCopyWith<$Res> {
  factory _$$ScheduledMatchImplCopyWith(
    _$ScheduledMatchImpl value,
    $Res Function(_$ScheduledMatchImpl) then,
  ) = __$$ScheduledMatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String homeTeamId,
    String awayTeamId,
    int round,
    MatchResult? result,
  });

  @override
  $MatchResultCopyWith<$Res>? get result;
}

/// @nodoc
class __$$ScheduledMatchImplCopyWithImpl<$Res>
    extends _$ScheduledMatchCopyWithImpl<$Res, _$ScheduledMatchImpl>
    implements _$$ScheduledMatchImplCopyWith<$Res> {
  __$$ScheduledMatchImplCopyWithImpl(
    _$ScheduledMatchImpl _value,
    $Res Function(_$ScheduledMatchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScheduledMatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? homeTeamId = null,
    Object? awayTeamId = null,
    Object? round = null,
    Object? result = freezed,
  }) {
    return _then(
      _$ScheduledMatchImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        homeTeamId: null == homeTeamId
            ? _value.homeTeamId
            : homeTeamId // ignore: cast_nullable_to_non_nullable
                  as String,
        awayTeamId: null == awayTeamId
            ? _value.awayTeamId
            : awayTeamId // ignore: cast_nullable_to_non_nullable
                  as String,
        round: null == round
            ? _value.round
            : round // ignore: cast_nullable_to_non_nullable
                  as int,
        result: freezed == result
            ? _value.result
            : result // ignore: cast_nullable_to_non_nullable
                  as MatchResult?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduledMatchImpl implements _ScheduledMatch {
  const _$ScheduledMatchImpl({
    required this.id,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.round,
    this.result,
  });

  factory _$ScheduledMatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduledMatchImplFromJson(json);

  @override
  final String id;
  @override
  final String homeTeamId;
  @override
  final String awayTeamId;
  @override
  final int round;
  @override
  final MatchResult? result;

  @override
  String toString() {
    return 'ScheduledMatch(id: $id, homeTeamId: $homeTeamId, awayTeamId: $awayTeamId, round: $round, result: $result)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduledMatchImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.homeTeamId, homeTeamId) ||
                other.homeTeamId == homeTeamId) &&
            (identical(other.awayTeamId, awayTeamId) ||
                other.awayTeamId == awayTeamId) &&
            (identical(other.round, round) || other.round == round) &&
            (identical(other.result, result) || other.result == result));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, homeTeamId, awayTeamId, round, result);

  /// Create a copy of ScheduledMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduledMatchImplCopyWith<_$ScheduledMatchImpl> get copyWith =>
      __$$ScheduledMatchImplCopyWithImpl<_$ScheduledMatchImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduledMatchImplToJson(this);
  }
}

abstract class _ScheduledMatch implements ScheduledMatch {
  const factory _ScheduledMatch({
    required final String id,
    required final String homeTeamId,
    required final String awayTeamId,
    required final int round,
    final MatchResult? result,
  }) = _$ScheduledMatchImpl;

  factory _ScheduledMatch.fromJson(Map<String, dynamic> json) =
      _$ScheduledMatchImpl.fromJson;

  @override
  String get id;
  @override
  String get homeTeamId;
  @override
  String get awayTeamId;
  @override
  int get round;
  @override
  MatchResult? get result;

  /// Create a copy of ScheduledMatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScheduledMatchImplCopyWith<_$ScheduledMatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlayoffSeries _$PlayoffSeriesFromJson(Map<String, dynamic> json) {
  return _PlayoffSeries.fromJson(json);
}

/// @nodoc
mixin _$PlayoffSeries {
  String get id => throw _privateConstructorUsedError;
  String get higherSeedTeamId => throw _privateConstructorUsedError;
  String get lowerSeedTeamId => throw _privateConstructorUsedError;
  int get winsNeeded => throw _privateConstructorUsedError;
  int get higherSeedWins => throw _privateConstructorUsedError;
  int get lowerSeedWins => throw _privateConstructorUsedError;
  List<MatchResult> get games => throw _privateConstructorUsedError;
  String? get winnerTeamId => throw _privateConstructorUsedError;

  /// Serializes this PlayoffSeries to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlayoffSeries
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayoffSeriesCopyWith<PlayoffSeries> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayoffSeriesCopyWith<$Res> {
  factory $PlayoffSeriesCopyWith(
    PlayoffSeries value,
    $Res Function(PlayoffSeries) then,
  ) = _$PlayoffSeriesCopyWithImpl<$Res, PlayoffSeries>;
  @useResult
  $Res call({
    String id,
    String higherSeedTeamId,
    String lowerSeedTeamId,
    int winsNeeded,
    int higherSeedWins,
    int lowerSeedWins,
    List<MatchResult> games,
    String? winnerTeamId,
  });
}

/// @nodoc
class _$PlayoffSeriesCopyWithImpl<$Res, $Val extends PlayoffSeries>
    implements $PlayoffSeriesCopyWith<$Res> {
  _$PlayoffSeriesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayoffSeries
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? higherSeedTeamId = null,
    Object? lowerSeedTeamId = null,
    Object? winsNeeded = null,
    Object? higherSeedWins = null,
    Object? lowerSeedWins = null,
    Object? games = null,
    Object? winnerTeamId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            higherSeedTeamId: null == higherSeedTeamId
                ? _value.higherSeedTeamId
                : higherSeedTeamId // ignore: cast_nullable_to_non_nullable
                      as String,
            lowerSeedTeamId: null == lowerSeedTeamId
                ? _value.lowerSeedTeamId
                : lowerSeedTeamId // ignore: cast_nullable_to_non_nullable
                      as String,
            winsNeeded: null == winsNeeded
                ? _value.winsNeeded
                : winsNeeded // ignore: cast_nullable_to_non_nullable
                      as int,
            higherSeedWins: null == higherSeedWins
                ? _value.higherSeedWins
                : higherSeedWins // ignore: cast_nullable_to_non_nullable
                      as int,
            lowerSeedWins: null == lowerSeedWins
                ? _value.lowerSeedWins
                : lowerSeedWins // ignore: cast_nullable_to_non_nullable
                      as int,
            games: null == games
                ? _value.games
                : games // ignore: cast_nullable_to_non_nullable
                      as List<MatchResult>,
            winnerTeamId: freezed == winnerTeamId
                ? _value.winnerTeamId
                : winnerTeamId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlayoffSeriesImplCopyWith<$Res>
    implements $PlayoffSeriesCopyWith<$Res> {
  factory _$$PlayoffSeriesImplCopyWith(
    _$PlayoffSeriesImpl value,
    $Res Function(_$PlayoffSeriesImpl) then,
  ) = __$$PlayoffSeriesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String higherSeedTeamId,
    String lowerSeedTeamId,
    int winsNeeded,
    int higherSeedWins,
    int lowerSeedWins,
    List<MatchResult> games,
    String? winnerTeamId,
  });
}

/// @nodoc
class __$$PlayoffSeriesImplCopyWithImpl<$Res>
    extends _$PlayoffSeriesCopyWithImpl<$Res, _$PlayoffSeriesImpl>
    implements _$$PlayoffSeriesImplCopyWith<$Res> {
  __$$PlayoffSeriesImplCopyWithImpl(
    _$PlayoffSeriesImpl _value,
    $Res Function(_$PlayoffSeriesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlayoffSeries
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? higherSeedTeamId = null,
    Object? lowerSeedTeamId = null,
    Object? winsNeeded = null,
    Object? higherSeedWins = null,
    Object? lowerSeedWins = null,
    Object? games = null,
    Object? winnerTeamId = freezed,
  }) {
    return _then(
      _$PlayoffSeriesImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        higherSeedTeamId: null == higherSeedTeamId
            ? _value.higherSeedTeamId
            : higherSeedTeamId // ignore: cast_nullable_to_non_nullable
                  as String,
        lowerSeedTeamId: null == lowerSeedTeamId
            ? _value.lowerSeedTeamId
            : lowerSeedTeamId // ignore: cast_nullable_to_non_nullable
                  as String,
        winsNeeded: null == winsNeeded
            ? _value.winsNeeded
            : winsNeeded // ignore: cast_nullable_to_non_nullable
                  as int,
        higherSeedWins: null == higherSeedWins
            ? _value.higherSeedWins
            : higherSeedWins // ignore: cast_nullable_to_non_nullable
                  as int,
        lowerSeedWins: null == lowerSeedWins
            ? _value.lowerSeedWins
            : lowerSeedWins // ignore: cast_nullable_to_non_nullable
                  as int,
        games: null == games
            ? _value._games
            : games // ignore: cast_nullable_to_non_nullable
                  as List<MatchResult>,
        winnerTeamId: freezed == winnerTeamId
            ? _value.winnerTeamId
            : winnerTeamId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayoffSeriesImpl implements _PlayoffSeries {
  const _$PlayoffSeriesImpl({
    required this.id,
    required this.higherSeedTeamId,
    required this.lowerSeedTeamId,
    required this.winsNeeded,
    this.higherSeedWins = 0,
    this.lowerSeedWins = 0,
    final List<MatchResult> games = const [],
    this.winnerTeamId,
  }) : _games = games;

  factory _$PlayoffSeriesImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayoffSeriesImplFromJson(json);

  @override
  final String id;
  @override
  final String higherSeedTeamId;
  @override
  final String lowerSeedTeamId;
  @override
  final int winsNeeded;
  @override
  @JsonKey()
  final int higherSeedWins;
  @override
  @JsonKey()
  final int lowerSeedWins;
  final List<MatchResult> _games;
  @override
  @JsonKey()
  List<MatchResult> get games {
    if (_games is EqualUnmodifiableListView) return _games;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_games);
  }

  @override
  final String? winnerTeamId;

  @override
  String toString() {
    return 'PlayoffSeries(id: $id, higherSeedTeamId: $higherSeedTeamId, lowerSeedTeamId: $lowerSeedTeamId, winsNeeded: $winsNeeded, higherSeedWins: $higherSeedWins, lowerSeedWins: $lowerSeedWins, games: $games, winnerTeamId: $winnerTeamId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayoffSeriesImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.higherSeedTeamId, higherSeedTeamId) ||
                other.higherSeedTeamId == higherSeedTeamId) &&
            (identical(other.lowerSeedTeamId, lowerSeedTeamId) ||
                other.lowerSeedTeamId == lowerSeedTeamId) &&
            (identical(other.winsNeeded, winsNeeded) ||
                other.winsNeeded == winsNeeded) &&
            (identical(other.higherSeedWins, higherSeedWins) ||
                other.higherSeedWins == higherSeedWins) &&
            (identical(other.lowerSeedWins, lowerSeedWins) ||
                other.lowerSeedWins == lowerSeedWins) &&
            const DeepCollectionEquality().equals(other._games, _games) &&
            (identical(other.winnerTeamId, winnerTeamId) ||
                other.winnerTeamId == winnerTeamId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    higherSeedTeamId,
    lowerSeedTeamId,
    winsNeeded,
    higherSeedWins,
    lowerSeedWins,
    const DeepCollectionEquality().hash(_games),
    winnerTeamId,
  );

  /// Create a copy of PlayoffSeries
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayoffSeriesImplCopyWith<_$PlayoffSeriesImpl> get copyWith =>
      __$$PlayoffSeriesImplCopyWithImpl<_$PlayoffSeriesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayoffSeriesImplToJson(this);
  }
}

abstract class _PlayoffSeries implements PlayoffSeries {
  const factory _PlayoffSeries({
    required final String id,
    required final String higherSeedTeamId,
    required final String lowerSeedTeamId,
    required final int winsNeeded,
    final int higherSeedWins,
    final int lowerSeedWins,
    final List<MatchResult> games,
    final String? winnerTeamId,
  }) = _$PlayoffSeriesImpl;

  factory _PlayoffSeries.fromJson(Map<String, dynamic> json) =
      _$PlayoffSeriesImpl.fromJson;

  @override
  String get id;
  @override
  String get higherSeedTeamId;
  @override
  String get lowerSeedTeamId;
  @override
  int get winsNeeded;
  @override
  int get higherSeedWins;
  @override
  int get lowerSeedWins;
  @override
  List<MatchResult> get games;
  @override
  String? get winnerTeamId;

  /// Create a copy of PlayoffSeries
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayoffSeriesImplCopyWith<_$PlayoffSeriesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
