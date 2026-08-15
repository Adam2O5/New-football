// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draft_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Prospect _$ProspectFromJson(Map<String, dynamic> json) {
  return _Prospect.fromJson(json);
}

/// @nodoc
mixin _$Prospect {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  Nationality get nationality => throw _privateConstructorUsedError;
  Position get position => throw _privateConstructorUsedError;
  int get age => throw _privateConstructorUsedError;
  PlayerAttributes get attributes => throw _privateConstructorUsedError;
  int get scoutGrade => throw _privateConstructorUsedError; //unevaluated
  int get combineScore => throw _privateConstructorUsedError; //unevaluated
  double get potentialStars => throw _privateConstructorUsedError;
  int get heightCm => throw _privateConstructorUsedError;
  int get injuryProne => throw _privateConstructorUsedError;
  int get determination => throw _privateConstructorUsedError;
  PlayerPersonality get personality => throw _privateConstructorUsedError;

  /// Optymalna rola taktyczna (`player_management.md`).
  /// Ujawniana przez Combine (`offseason.md` §7).
  AssignedRole get optimalRole => throw _privateConstructorUsedError;

  /// Serializes this Prospect to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Prospect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProspectCopyWith<Prospect> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProspectCopyWith<$Res> {
  factory $ProspectCopyWith(Prospect value, $Res Function(Prospect) then) =
      _$ProspectCopyWithImpl<$Res, Prospect>;
  @useResult
  $Res call({
    String id,
    String name,
    Nationality nationality,
    Position position,
    int age,
    PlayerAttributes attributes,
    int scoutGrade,
    int combineScore,
    double potentialStars,
    int heightCm,
    int injuryProne,
    int determination,
    PlayerPersonality personality,
    AssignedRole optimalRole,
  });

  $PlayerAttributesCopyWith<$Res> get attributes;
  $AssignedRoleCopyWith<$Res> get optimalRole;
}

/// @nodoc
class _$ProspectCopyWithImpl<$Res, $Val extends Prospect>
    implements $ProspectCopyWith<$Res> {
  _$ProspectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Prospect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nationality = null,
    Object? position = null,
    Object? age = null,
    Object? attributes = null,
    Object? scoutGrade = null,
    Object? combineScore = null,
    Object? potentialStars = null,
    Object? heightCm = null,
    Object? injuryProne = null,
    Object? determination = null,
    Object? personality = null,
    Object? optimalRole = null,
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
            nationality: null == nationality
                ? _value.nationality
                : nationality // ignore: cast_nullable_to_non_nullable
                      as Nationality,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as Position,
            age: null == age
                ? _value.age
                : age // ignore: cast_nullable_to_non_nullable
                      as int,
            attributes: null == attributes
                ? _value.attributes
                : attributes // ignore: cast_nullable_to_non_nullable
                      as PlayerAttributes,
            scoutGrade: null == scoutGrade
                ? _value.scoutGrade
                : scoutGrade // ignore: cast_nullable_to_non_nullable
                      as int,
            combineScore: null == combineScore
                ? _value.combineScore
                : combineScore // ignore: cast_nullable_to_non_nullable
                      as int,
            potentialStars: null == potentialStars
                ? _value.potentialStars
                : potentialStars // ignore: cast_nullable_to_non_nullable
                      as double,
            heightCm: null == heightCm
                ? _value.heightCm
                : heightCm // ignore: cast_nullable_to_non_nullable
                      as int,
            injuryProne: null == injuryProne
                ? _value.injuryProne
                : injuryProne // ignore: cast_nullable_to_non_nullable
                      as int,
            determination: null == determination
                ? _value.determination
                : determination // ignore: cast_nullable_to_non_nullable
                      as int,
            personality: null == personality
                ? _value.personality
                : personality // ignore: cast_nullable_to_non_nullable
                      as PlayerPersonality,
            optimalRole: null == optimalRole
                ? _value.optimalRole
                : optimalRole // ignore: cast_nullable_to_non_nullable
                      as AssignedRole,
          )
          as $Val,
    );
  }

  /// Create a copy of Prospect
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlayerAttributesCopyWith<$Res> get attributes {
    return $PlayerAttributesCopyWith<$Res>(_value.attributes, (value) {
      return _then(_value.copyWith(attributes: value) as $Val);
    });
  }

  /// Create a copy of Prospect
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AssignedRoleCopyWith<$Res> get optimalRole {
    return $AssignedRoleCopyWith<$Res>(_value.optimalRole, (value) {
      return _then(_value.copyWith(optimalRole: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProspectImplCopyWith<$Res>
    implements $ProspectCopyWith<$Res> {
  factory _$$ProspectImplCopyWith(
    _$ProspectImpl value,
    $Res Function(_$ProspectImpl) then,
  ) = __$$ProspectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    Nationality nationality,
    Position position,
    int age,
    PlayerAttributes attributes,
    int scoutGrade,
    int combineScore,
    double potentialStars,
    int heightCm,
    int injuryProne,
    int determination,
    PlayerPersonality personality,
    AssignedRole optimalRole,
  });

  @override
  $PlayerAttributesCopyWith<$Res> get attributes;
  @override
  $AssignedRoleCopyWith<$Res> get optimalRole;
}

/// @nodoc
class __$$ProspectImplCopyWithImpl<$Res>
    extends _$ProspectCopyWithImpl<$Res, _$ProspectImpl>
    implements _$$ProspectImplCopyWith<$Res> {
  __$$ProspectImplCopyWithImpl(
    _$ProspectImpl _value,
    $Res Function(_$ProspectImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Prospect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nationality = null,
    Object? position = null,
    Object? age = null,
    Object? attributes = null,
    Object? scoutGrade = null,
    Object? combineScore = null,
    Object? potentialStars = null,
    Object? heightCm = null,
    Object? injuryProne = null,
    Object? determination = null,
    Object? personality = null,
    Object? optimalRole = null,
  }) {
    return _then(
      _$ProspectImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        nationality: null == nationality
            ? _value.nationality
            : nationality // ignore: cast_nullable_to_non_nullable
                  as Nationality,
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as Position,
        age: null == age
            ? _value.age
            : age // ignore: cast_nullable_to_non_nullable
                  as int,
        attributes: null == attributes
            ? _value.attributes
            : attributes // ignore: cast_nullable_to_non_nullable
                  as PlayerAttributes,
        scoutGrade: null == scoutGrade
            ? _value.scoutGrade
            : scoutGrade // ignore: cast_nullable_to_non_nullable
                  as int,
        combineScore: null == combineScore
            ? _value.combineScore
            : combineScore // ignore: cast_nullable_to_non_nullable
                  as int,
        potentialStars: null == potentialStars
            ? _value.potentialStars
            : potentialStars // ignore: cast_nullable_to_non_nullable
                  as double,
        heightCm: null == heightCm
            ? _value.heightCm
            : heightCm // ignore: cast_nullable_to_non_nullable
                  as int,
        injuryProne: null == injuryProne
            ? _value.injuryProne
            : injuryProne // ignore: cast_nullable_to_non_nullable
                  as int,
        determination: null == determination
            ? _value.determination
            : determination // ignore: cast_nullable_to_non_nullable
                  as int,
        personality: null == personality
            ? _value.personality
            : personality // ignore: cast_nullable_to_non_nullable
                  as PlayerPersonality,
        optimalRole: null == optimalRole
            ? _value.optimalRole
            : optimalRole // ignore: cast_nullable_to_non_nullable
                  as AssignedRole,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProspectImpl implements _Prospect {
  const _$ProspectImpl({
    required this.id,
    required this.name,
    required this.nationality,
    required this.position,
    required this.age,
    required this.attributes,
    this.scoutGrade = 0,
    this.combineScore = 0,
    required this.potentialStars,
    required this.heightCm,
    required this.injuryProne,
    required this.determination,
    required this.personality,
    required this.optimalRole,
  });

  factory _$ProspectImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProspectImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final Nationality nationality;
  @override
  final Position position;
  @override
  final int age;
  @override
  final PlayerAttributes attributes;
  @override
  @JsonKey()
  final int scoutGrade;
  //unevaluated
  @override
  @JsonKey()
  final int combineScore;
  //unevaluated
  @override
  final double potentialStars;
  @override
  final int heightCm;
  @override
  final int injuryProne;
  @override
  final int determination;
  @override
  final PlayerPersonality personality;

  /// Optymalna rola taktyczna (`player_management.md`).
  /// Ujawniana przez Combine (`offseason.md` §7).
  @override
  final AssignedRole optimalRole;

  @override
  String toString() {
    return 'Prospect(id: $id, name: $name, nationality: $nationality, position: $position, age: $age, attributes: $attributes, scoutGrade: $scoutGrade, combineScore: $combineScore, potentialStars: $potentialStars, heightCm: $heightCm, injuryProne: $injuryProne, determination: $determination, personality: $personality, optimalRole: $optimalRole)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProspectImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nationality, nationality) ||
                other.nationality == nationality) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.attributes, attributes) ||
                other.attributes == attributes) &&
            (identical(other.scoutGrade, scoutGrade) ||
                other.scoutGrade == scoutGrade) &&
            (identical(other.combineScore, combineScore) ||
                other.combineScore == combineScore) &&
            (identical(other.potentialStars, potentialStars) ||
                other.potentialStars == potentialStars) &&
            (identical(other.heightCm, heightCm) ||
                other.heightCm == heightCm) &&
            (identical(other.injuryProne, injuryProne) ||
                other.injuryProne == injuryProne) &&
            (identical(other.determination, determination) ||
                other.determination == determination) &&
            (identical(other.personality, personality) ||
                other.personality == personality) &&
            (identical(other.optimalRole, optimalRole) ||
                other.optimalRole == optimalRole));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    nationality,
    position,
    age,
    attributes,
    scoutGrade,
    combineScore,
    potentialStars,
    heightCm,
    injuryProne,
    determination,
    personality,
    optimalRole,
  );

  /// Create a copy of Prospect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProspectImplCopyWith<_$ProspectImpl> get copyWith =>
      __$$ProspectImplCopyWithImpl<_$ProspectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProspectImplToJson(this);
  }
}

abstract class _Prospect implements Prospect {
  const factory _Prospect({
    required final String id,
    required final String name,
    required final Nationality nationality,
    required final Position position,
    required final int age,
    required final PlayerAttributes attributes,
    final int scoutGrade,
    final int combineScore,
    required final double potentialStars,
    required final int heightCm,
    required final int injuryProne,
    required final int determination,
    required final PlayerPersonality personality,
    required final AssignedRole optimalRole,
  }) = _$ProspectImpl;

  factory _Prospect.fromJson(Map<String, dynamic> json) =
      _$ProspectImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  Nationality get nationality;
  @override
  Position get position;
  @override
  int get age;
  @override
  PlayerAttributes get attributes;
  @override
  int get scoutGrade; //unevaluated
  @override
  int get combineScore; //unevaluated
  @override
  double get potentialStars;
  @override
  int get heightCm;
  @override
  int get injuryProne;
  @override
  int get determination;
  @override
  PlayerPersonality get personality;

  /// Optymalna rola taktyczna (`player_management.md`).
  /// Ujawniana przez Combine (`offseason.md` §7).
  @override
  AssignedRole get optimalRole;

  /// Create a copy of Prospect
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProspectImplCopyWith<_$ProspectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LotteryResult _$LotteryResultFromJson(Map<String, dynamic> json) {
  return _LotteryResult.fromJson(json);
}

/// @nodoc
mixin _$LotteryResult {
  String get teamId => throw _privateConstructorUsedError;
  int get originalRank => throw _privateConstructorUsedError;
  int get assignedPick => throw _privateConstructorUsedError;
  double get oddsForFirstPick => throw _privateConstructorUsedError;

  /// Serializes this LotteryResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LotteryResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LotteryResultCopyWith<LotteryResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LotteryResultCopyWith<$Res> {
  factory $LotteryResultCopyWith(
    LotteryResult value,
    $Res Function(LotteryResult) then,
  ) = _$LotteryResultCopyWithImpl<$Res, LotteryResult>;
  @useResult
  $Res call({
    String teamId,
    int originalRank,
    int assignedPick,
    double oddsForFirstPick,
  });
}

/// @nodoc
class _$LotteryResultCopyWithImpl<$Res, $Val extends LotteryResult>
    implements $LotteryResultCopyWith<$Res> {
  _$LotteryResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LotteryResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teamId = null,
    Object? originalRank = null,
    Object? assignedPick = null,
    Object? oddsForFirstPick = null,
  }) {
    return _then(
      _value.copyWith(
            teamId: null == teamId
                ? _value.teamId
                : teamId // ignore: cast_nullable_to_non_nullable
                      as String,
            originalRank: null == originalRank
                ? _value.originalRank
                : originalRank // ignore: cast_nullable_to_non_nullable
                      as int,
            assignedPick: null == assignedPick
                ? _value.assignedPick
                : assignedPick // ignore: cast_nullable_to_non_nullable
                      as int,
            oddsForFirstPick: null == oddsForFirstPick
                ? _value.oddsForFirstPick
                : oddsForFirstPick // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LotteryResultImplCopyWith<$Res>
    implements $LotteryResultCopyWith<$Res> {
  factory _$$LotteryResultImplCopyWith(
    _$LotteryResultImpl value,
    $Res Function(_$LotteryResultImpl) then,
  ) = __$$LotteryResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String teamId,
    int originalRank,
    int assignedPick,
    double oddsForFirstPick,
  });
}

/// @nodoc
class __$$LotteryResultImplCopyWithImpl<$Res>
    extends _$LotteryResultCopyWithImpl<$Res, _$LotteryResultImpl>
    implements _$$LotteryResultImplCopyWith<$Res> {
  __$$LotteryResultImplCopyWithImpl(
    _$LotteryResultImpl _value,
    $Res Function(_$LotteryResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LotteryResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teamId = null,
    Object? originalRank = null,
    Object? assignedPick = null,
    Object? oddsForFirstPick = null,
  }) {
    return _then(
      _$LotteryResultImpl(
        teamId: null == teamId
            ? _value.teamId
            : teamId // ignore: cast_nullable_to_non_nullable
                  as String,
        originalRank: null == originalRank
            ? _value.originalRank
            : originalRank // ignore: cast_nullable_to_non_nullable
                  as int,
        assignedPick: null == assignedPick
            ? _value.assignedPick
            : assignedPick // ignore: cast_nullable_to_non_nullable
                  as int,
        oddsForFirstPick: null == oddsForFirstPick
            ? _value.oddsForFirstPick
            : oddsForFirstPick // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LotteryResultImpl implements _LotteryResult {
  const _$LotteryResultImpl({
    required this.teamId,
    required this.originalRank,
    required this.assignedPick,
    required this.oddsForFirstPick,
  });

  factory _$LotteryResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$LotteryResultImplFromJson(json);

  @override
  final String teamId;
  @override
  final int originalRank;
  @override
  final int assignedPick;
  @override
  final double oddsForFirstPick;

  @override
  String toString() {
    return 'LotteryResult(teamId: $teamId, originalRank: $originalRank, assignedPick: $assignedPick, oddsForFirstPick: $oddsForFirstPick)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LotteryResultImpl &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.originalRank, originalRank) ||
                other.originalRank == originalRank) &&
            (identical(other.assignedPick, assignedPick) ||
                other.assignedPick == assignedPick) &&
            (identical(other.oddsForFirstPick, oddsForFirstPick) ||
                other.oddsForFirstPick == oddsForFirstPick));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    teamId,
    originalRank,
    assignedPick,
    oddsForFirstPick,
  );

  /// Create a copy of LotteryResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LotteryResultImplCopyWith<_$LotteryResultImpl> get copyWith =>
      __$$LotteryResultImplCopyWithImpl<_$LotteryResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LotteryResultImplToJson(this);
  }
}

abstract class _LotteryResult implements LotteryResult {
  const factory _LotteryResult({
    required final String teamId,
    required final int originalRank,
    required final int assignedPick,
    required final double oddsForFirstPick,
  }) = _$LotteryResultImpl;

  factory _LotteryResult.fromJson(Map<String, dynamic> json) =
      _$LotteryResultImpl.fromJson;

  @override
  String get teamId;
  @override
  int get originalRank;
  @override
  int get assignedPick;
  @override
  double get oddsForFirstPick;

  /// Create a copy of LotteryResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LotteryResultImplCopyWith<_$LotteryResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DraftClass _$DraftClassFromJson(Map<String, dynamic> json) {
  return _DraftClass.fromJson(json);
}

/// @nodoc
mixin _$DraftClass {
  int get year => throw _privateConstructorUsedError;
  List<Prospect> get prospects => throw _privateConstructorUsedError;

  /// Serializes this DraftClass to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DraftClass
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DraftClassCopyWith<DraftClass> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DraftClassCopyWith<$Res> {
  factory $DraftClassCopyWith(
    DraftClass value,
    $Res Function(DraftClass) then,
  ) = _$DraftClassCopyWithImpl<$Res, DraftClass>;
  @useResult
  $Res call({int year, List<Prospect> prospects});
}

/// @nodoc
class _$DraftClassCopyWithImpl<$Res, $Val extends DraftClass>
    implements $DraftClassCopyWith<$Res> {
  _$DraftClassCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DraftClass
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? year = null, Object? prospects = null}) {
    return _then(
      _value.copyWith(
            year: null == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int,
            prospects: null == prospects
                ? _value.prospects
                : prospects // ignore: cast_nullable_to_non_nullable
                      as List<Prospect>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DraftClassImplCopyWith<$Res>
    implements $DraftClassCopyWith<$Res> {
  factory _$$DraftClassImplCopyWith(
    _$DraftClassImpl value,
    $Res Function(_$DraftClassImpl) then,
  ) = __$$DraftClassImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int year, List<Prospect> prospects});
}

/// @nodoc
class __$$DraftClassImplCopyWithImpl<$Res>
    extends _$DraftClassCopyWithImpl<$Res, _$DraftClassImpl>
    implements _$$DraftClassImplCopyWith<$Res> {
  __$$DraftClassImplCopyWithImpl(
    _$DraftClassImpl _value,
    $Res Function(_$DraftClassImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DraftClass
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? year = null, Object? prospects = null}) {
    return _then(
      _$DraftClassImpl(
        year: null == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int,
        prospects: null == prospects
            ? _value._prospects
            : prospects // ignore: cast_nullable_to_non_nullable
                  as List<Prospect>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DraftClassImpl implements _DraftClass {
  const _$DraftClassImpl({
    required this.year,
    final List<Prospect> prospects = const [],
  }) : _prospects = prospects;

  factory _$DraftClassImpl.fromJson(Map<String, dynamic> json) =>
      _$$DraftClassImplFromJson(json);

  @override
  final int year;
  final List<Prospect> _prospects;
  @override
  @JsonKey()
  List<Prospect> get prospects {
    if (_prospects is EqualUnmodifiableListView) return _prospects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_prospects);
  }

  @override
  String toString() {
    return 'DraftClass(year: $year, prospects: $prospects)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DraftClassImpl &&
            (identical(other.year, year) || other.year == year) &&
            const DeepCollectionEquality().equals(
              other._prospects,
              _prospects,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    year,
    const DeepCollectionEquality().hash(_prospects),
  );

  /// Create a copy of DraftClass
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DraftClassImplCopyWith<_$DraftClassImpl> get copyWith =>
      __$$DraftClassImplCopyWithImpl<_$DraftClassImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DraftClassImplToJson(this);
  }
}

abstract class _DraftClass implements DraftClass {
  const factory _DraftClass({
    required final int year,
    final List<Prospect> prospects,
  }) = _$DraftClassImpl;

  factory _DraftClass.fromJson(Map<String, dynamic> json) =
      _$DraftClassImpl.fromJson;

  @override
  int get year;
  @override
  List<Prospect> get prospects;

  /// Create a copy of DraftClass
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DraftClassImplCopyWith<_$DraftClassImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DraftState _$DraftStateFromJson(Map<String, dynamic> json) {
  return _DraftState.fromJson(json);
}

/// @nodoc
mixin _$DraftState {
  int get year => throw _privateConstructorUsedError;
  List<DraftPick> get order => throw _privateConstructorUsedError;
  List<DraftPick> get completedPicks => throw _privateConstructorUsedError;
  List<LotteryResult> get lotteryResults => throw _privateConstructorUsedError;
  DraftClass get draftClass => throw _privateConstructorUsedError;
  int get currentPickIndex => throw _privateConstructorUsedError;

  /// Serializes this DraftState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DraftState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DraftStateCopyWith<DraftState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DraftStateCopyWith<$Res> {
  factory $DraftStateCopyWith(
    DraftState value,
    $Res Function(DraftState) then,
  ) = _$DraftStateCopyWithImpl<$Res, DraftState>;
  @useResult
  $Res call({
    int year,
    List<DraftPick> order,
    List<DraftPick> completedPicks,
    List<LotteryResult> lotteryResults,
    DraftClass draftClass,
    int currentPickIndex,
  });

  $DraftClassCopyWith<$Res> get draftClass;
}

/// @nodoc
class _$DraftStateCopyWithImpl<$Res, $Val extends DraftState>
    implements $DraftStateCopyWith<$Res> {
  _$DraftStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DraftState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? order = null,
    Object? completedPicks = null,
    Object? lotteryResults = null,
    Object? draftClass = null,
    Object? currentPickIndex = null,
  }) {
    return _then(
      _value.copyWith(
            year: null == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int,
            order: null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                      as List<DraftPick>,
            completedPicks: null == completedPicks
                ? _value.completedPicks
                : completedPicks // ignore: cast_nullable_to_non_nullable
                      as List<DraftPick>,
            lotteryResults: null == lotteryResults
                ? _value.lotteryResults
                : lotteryResults // ignore: cast_nullable_to_non_nullable
                      as List<LotteryResult>,
            draftClass: null == draftClass
                ? _value.draftClass
                : draftClass // ignore: cast_nullable_to_non_nullable
                      as DraftClass,
            currentPickIndex: null == currentPickIndex
                ? _value.currentPickIndex
                : currentPickIndex // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of DraftState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DraftClassCopyWith<$Res> get draftClass {
    return $DraftClassCopyWith<$Res>(_value.draftClass, (value) {
      return _then(_value.copyWith(draftClass: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DraftStateImplCopyWith<$Res>
    implements $DraftStateCopyWith<$Res> {
  factory _$$DraftStateImplCopyWith(
    _$DraftStateImpl value,
    $Res Function(_$DraftStateImpl) then,
  ) = __$$DraftStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int year,
    List<DraftPick> order,
    List<DraftPick> completedPicks,
    List<LotteryResult> lotteryResults,
    DraftClass draftClass,
    int currentPickIndex,
  });

  @override
  $DraftClassCopyWith<$Res> get draftClass;
}

/// @nodoc
class __$$DraftStateImplCopyWithImpl<$Res>
    extends _$DraftStateCopyWithImpl<$Res, _$DraftStateImpl>
    implements _$$DraftStateImplCopyWith<$Res> {
  __$$DraftStateImplCopyWithImpl(
    _$DraftStateImpl _value,
    $Res Function(_$DraftStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DraftState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? order = null,
    Object? completedPicks = null,
    Object? lotteryResults = null,
    Object? draftClass = null,
    Object? currentPickIndex = null,
  }) {
    return _then(
      _$DraftStateImpl(
        year: null == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int,
        order: null == order
            ? _value._order
            : order // ignore: cast_nullable_to_non_nullable
                  as List<DraftPick>,
        completedPicks: null == completedPicks
            ? _value._completedPicks
            : completedPicks // ignore: cast_nullable_to_non_nullable
                  as List<DraftPick>,
        lotteryResults: null == lotteryResults
            ? _value._lotteryResults
            : lotteryResults // ignore: cast_nullable_to_non_nullable
                  as List<LotteryResult>,
        draftClass: null == draftClass
            ? _value.draftClass
            : draftClass // ignore: cast_nullable_to_non_nullable
                  as DraftClass,
        currentPickIndex: null == currentPickIndex
            ? _value.currentPickIndex
            : currentPickIndex // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DraftStateImpl implements _DraftState {
  const _$DraftStateImpl({
    required this.year,
    final List<DraftPick> order = const [],
    final List<DraftPick> completedPicks = const [],
    final List<LotteryResult> lotteryResults = const [],
    required this.draftClass,
    this.currentPickIndex = 0,
  }) : _order = order,
       _completedPicks = completedPicks,
       _lotteryResults = lotteryResults;

  factory _$DraftStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$DraftStateImplFromJson(json);

  @override
  final int year;
  final List<DraftPick> _order;
  @override
  @JsonKey()
  List<DraftPick> get order {
    if (_order is EqualUnmodifiableListView) return _order;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_order);
  }

  final List<DraftPick> _completedPicks;
  @override
  @JsonKey()
  List<DraftPick> get completedPicks {
    if (_completedPicks is EqualUnmodifiableListView) return _completedPicks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedPicks);
  }

  final List<LotteryResult> _lotteryResults;
  @override
  @JsonKey()
  List<LotteryResult> get lotteryResults {
    if (_lotteryResults is EqualUnmodifiableListView) return _lotteryResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lotteryResults);
  }

  @override
  final DraftClass draftClass;
  @override
  @JsonKey()
  final int currentPickIndex;

  @override
  String toString() {
    return 'DraftState(year: $year, order: $order, completedPicks: $completedPicks, lotteryResults: $lotteryResults, draftClass: $draftClass, currentPickIndex: $currentPickIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DraftStateImpl &&
            (identical(other.year, year) || other.year == year) &&
            const DeepCollectionEquality().equals(other._order, _order) &&
            const DeepCollectionEquality().equals(
              other._completedPicks,
              _completedPicks,
            ) &&
            const DeepCollectionEquality().equals(
              other._lotteryResults,
              _lotteryResults,
            ) &&
            (identical(other.draftClass, draftClass) ||
                other.draftClass == draftClass) &&
            (identical(other.currentPickIndex, currentPickIndex) ||
                other.currentPickIndex == currentPickIndex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    year,
    const DeepCollectionEquality().hash(_order),
    const DeepCollectionEquality().hash(_completedPicks),
    const DeepCollectionEquality().hash(_lotteryResults),
    draftClass,
    currentPickIndex,
  );

  /// Create a copy of DraftState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DraftStateImplCopyWith<_$DraftStateImpl> get copyWith =>
      __$$DraftStateImplCopyWithImpl<_$DraftStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DraftStateImplToJson(this);
  }
}

abstract class _DraftState implements DraftState {
  const factory _DraftState({
    required final int year,
    final List<DraftPick> order,
    final List<DraftPick> completedPicks,
    final List<LotteryResult> lotteryResults,
    required final DraftClass draftClass,
    final int currentPickIndex,
  }) = _$DraftStateImpl;

  factory _DraftState.fromJson(Map<String, dynamic> json) =
      _$DraftStateImpl.fromJson;

  @override
  int get year;
  @override
  List<DraftPick> get order;
  @override
  List<DraftPick> get completedPicks;
  @override
  List<LotteryResult> get lotteryResults;
  @override
  DraftClass get draftClass;
  @override
  int get currentPickIndex;

  /// Create a copy of DraftState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DraftStateImplCopyWith<_$DraftStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlayInResult _$PlayInResultFromJson(Map<String, dynamic> json) {
  return _PlayInResult.fromJson(json);
}

/// @nodoc
mixin _$PlayInResult {
  Conference get conference => throw _privateConstructorUsedError;
  String get seed7TeamId => throw _privateConstructorUsedError;
  String get seed8TeamId => throw _privateConstructorUsedError;
  MatchResult get game7v8 => throw _privateConstructorUsedError;
  MatchResult get game9v10 => throw _privateConstructorUsedError;
  MatchResult get gameFinal => throw _privateConstructorUsedError;
  String get playoffSeed7TeamId => throw _privateConstructorUsedError;
  String get playoffSeed8TeamId => throw _privateConstructorUsedError;

  /// Serializes this PlayInResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlayInResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayInResultCopyWith<PlayInResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayInResultCopyWith<$Res> {
  factory $PlayInResultCopyWith(
    PlayInResult value,
    $Res Function(PlayInResult) then,
  ) = _$PlayInResultCopyWithImpl<$Res, PlayInResult>;
  @useResult
  $Res call({
    Conference conference,
    String seed7TeamId,
    String seed8TeamId,
    MatchResult game7v8,
    MatchResult game9v10,
    MatchResult gameFinal,
    String playoffSeed7TeamId,
    String playoffSeed8TeamId,
  });

  $MatchResultCopyWith<$Res> get game7v8;
  $MatchResultCopyWith<$Res> get game9v10;
  $MatchResultCopyWith<$Res> get gameFinal;
}

/// @nodoc
class _$PlayInResultCopyWithImpl<$Res, $Val extends PlayInResult>
    implements $PlayInResultCopyWith<$Res> {
  _$PlayInResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayInResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conference = null,
    Object? seed7TeamId = null,
    Object? seed8TeamId = null,
    Object? game7v8 = null,
    Object? game9v10 = null,
    Object? gameFinal = null,
    Object? playoffSeed7TeamId = null,
    Object? playoffSeed8TeamId = null,
  }) {
    return _then(
      _value.copyWith(
            conference: null == conference
                ? _value.conference
                : conference // ignore: cast_nullable_to_non_nullable
                      as Conference,
            seed7TeamId: null == seed7TeamId
                ? _value.seed7TeamId
                : seed7TeamId // ignore: cast_nullable_to_non_nullable
                      as String,
            seed8TeamId: null == seed8TeamId
                ? _value.seed8TeamId
                : seed8TeamId // ignore: cast_nullable_to_non_nullable
                      as String,
            game7v8: null == game7v8
                ? _value.game7v8
                : game7v8 // ignore: cast_nullable_to_non_nullable
                      as MatchResult,
            game9v10: null == game9v10
                ? _value.game9v10
                : game9v10 // ignore: cast_nullable_to_non_nullable
                      as MatchResult,
            gameFinal: null == gameFinal
                ? _value.gameFinal
                : gameFinal // ignore: cast_nullable_to_non_nullable
                      as MatchResult,
            playoffSeed7TeamId: null == playoffSeed7TeamId
                ? _value.playoffSeed7TeamId
                : playoffSeed7TeamId // ignore: cast_nullable_to_non_nullable
                      as String,
            playoffSeed8TeamId: null == playoffSeed8TeamId
                ? _value.playoffSeed8TeamId
                : playoffSeed8TeamId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of PlayInResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchResultCopyWith<$Res> get game7v8 {
    return $MatchResultCopyWith<$Res>(_value.game7v8, (value) {
      return _then(_value.copyWith(game7v8: value) as $Val);
    });
  }

  /// Create a copy of PlayInResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchResultCopyWith<$Res> get game9v10 {
    return $MatchResultCopyWith<$Res>(_value.game9v10, (value) {
      return _then(_value.copyWith(game9v10: value) as $Val);
    });
  }

  /// Create a copy of PlayInResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchResultCopyWith<$Res> get gameFinal {
    return $MatchResultCopyWith<$Res>(_value.gameFinal, (value) {
      return _then(_value.copyWith(gameFinal: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlayInResultImplCopyWith<$Res>
    implements $PlayInResultCopyWith<$Res> {
  factory _$$PlayInResultImplCopyWith(
    _$PlayInResultImpl value,
    $Res Function(_$PlayInResultImpl) then,
  ) = __$$PlayInResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Conference conference,
    String seed7TeamId,
    String seed8TeamId,
    MatchResult game7v8,
    MatchResult game9v10,
    MatchResult gameFinal,
    String playoffSeed7TeamId,
    String playoffSeed8TeamId,
  });

  @override
  $MatchResultCopyWith<$Res> get game7v8;
  @override
  $MatchResultCopyWith<$Res> get game9v10;
  @override
  $MatchResultCopyWith<$Res> get gameFinal;
}

/// @nodoc
class __$$PlayInResultImplCopyWithImpl<$Res>
    extends _$PlayInResultCopyWithImpl<$Res, _$PlayInResultImpl>
    implements _$$PlayInResultImplCopyWith<$Res> {
  __$$PlayInResultImplCopyWithImpl(
    _$PlayInResultImpl _value,
    $Res Function(_$PlayInResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlayInResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conference = null,
    Object? seed7TeamId = null,
    Object? seed8TeamId = null,
    Object? game7v8 = null,
    Object? game9v10 = null,
    Object? gameFinal = null,
    Object? playoffSeed7TeamId = null,
    Object? playoffSeed8TeamId = null,
  }) {
    return _then(
      _$PlayInResultImpl(
        conference: null == conference
            ? _value.conference
            : conference // ignore: cast_nullable_to_non_nullable
                  as Conference,
        seed7TeamId: null == seed7TeamId
            ? _value.seed7TeamId
            : seed7TeamId // ignore: cast_nullable_to_non_nullable
                  as String,
        seed8TeamId: null == seed8TeamId
            ? _value.seed8TeamId
            : seed8TeamId // ignore: cast_nullable_to_non_nullable
                  as String,
        game7v8: null == game7v8
            ? _value.game7v8
            : game7v8 // ignore: cast_nullable_to_non_nullable
                  as MatchResult,
        game9v10: null == game9v10
            ? _value.game9v10
            : game9v10 // ignore: cast_nullable_to_non_nullable
                  as MatchResult,
        gameFinal: null == gameFinal
            ? _value.gameFinal
            : gameFinal // ignore: cast_nullable_to_non_nullable
                  as MatchResult,
        playoffSeed7TeamId: null == playoffSeed7TeamId
            ? _value.playoffSeed7TeamId
            : playoffSeed7TeamId // ignore: cast_nullable_to_non_nullable
                  as String,
        playoffSeed8TeamId: null == playoffSeed8TeamId
            ? _value.playoffSeed8TeamId
            : playoffSeed8TeamId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayInResultImpl implements _PlayInResult {
  const _$PlayInResultImpl({
    required this.conference,
    required this.seed7TeamId,
    required this.seed8TeamId,
    required this.game7v8,
    required this.game9v10,
    required this.gameFinal,
    required this.playoffSeed7TeamId,
    required this.playoffSeed8TeamId,
  });

  factory _$PlayInResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayInResultImplFromJson(json);

  @override
  final Conference conference;
  @override
  final String seed7TeamId;
  @override
  final String seed8TeamId;
  @override
  final MatchResult game7v8;
  @override
  final MatchResult game9v10;
  @override
  final MatchResult gameFinal;
  @override
  final String playoffSeed7TeamId;
  @override
  final String playoffSeed8TeamId;

  @override
  String toString() {
    return 'PlayInResult(conference: $conference, seed7TeamId: $seed7TeamId, seed8TeamId: $seed8TeamId, game7v8: $game7v8, game9v10: $game9v10, gameFinal: $gameFinal, playoffSeed7TeamId: $playoffSeed7TeamId, playoffSeed8TeamId: $playoffSeed8TeamId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayInResultImpl &&
            (identical(other.conference, conference) ||
                other.conference == conference) &&
            (identical(other.seed7TeamId, seed7TeamId) ||
                other.seed7TeamId == seed7TeamId) &&
            (identical(other.seed8TeamId, seed8TeamId) ||
                other.seed8TeamId == seed8TeamId) &&
            (identical(other.game7v8, game7v8) || other.game7v8 == game7v8) &&
            (identical(other.game9v10, game9v10) ||
                other.game9v10 == game9v10) &&
            (identical(other.gameFinal, gameFinal) ||
                other.gameFinal == gameFinal) &&
            (identical(other.playoffSeed7TeamId, playoffSeed7TeamId) ||
                other.playoffSeed7TeamId == playoffSeed7TeamId) &&
            (identical(other.playoffSeed8TeamId, playoffSeed8TeamId) ||
                other.playoffSeed8TeamId == playoffSeed8TeamId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    conference,
    seed7TeamId,
    seed8TeamId,
    game7v8,
    game9v10,
    gameFinal,
    playoffSeed7TeamId,
    playoffSeed8TeamId,
  );

  /// Create a copy of PlayInResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayInResultImplCopyWith<_$PlayInResultImpl> get copyWith =>
      __$$PlayInResultImplCopyWithImpl<_$PlayInResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayInResultImplToJson(this);
  }
}

abstract class _PlayInResult implements PlayInResult {
  const factory _PlayInResult({
    required final Conference conference,
    required final String seed7TeamId,
    required final String seed8TeamId,
    required final MatchResult game7v8,
    required final MatchResult game9v10,
    required final MatchResult gameFinal,
    required final String playoffSeed7TeamId,
    required final String playoffSeed8TeamId,
  }) = _$PlayInResultImpl;

  factory _PlayInResult.fromJson(Map<String, dynamic> json) =
      _$PlayInResultImpl.fromJson;

  @override
  Conference get conference;
  @override
  String get seed7TeamId;
  @override
  String get seed8TeamId;
  @override
  MatchResult get game7v8;
  @override
  MatchResult get game9v10;
  @override
  MatchResult get gameFinal;
  @override
  String get playoffSeed7TeamId;
  @override
  String get playoffSeed8TeamId;

  /// Create a copy of PlayInResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayInResultImplCopyWith<_$PlayInResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlayoffBracket _$PlayoffBracketFromJson(Map<String, dynamic> json) {
  return _PlayoffBracket.fromJson(json);
}

/// @nodoc
mixin _$PlayoffBracket {
  Conference get conference => throw _privateConstructorUsedError;
  List<PlayoffSeries> get quarterFinals => throw _privateConstructorUsedError;
  List<PlayoffSeries> get semiFinals => throw _privateConstructorUsedError;
  List<PlayoffSeries> get conferenceFinal => throw _privateConstructorUsedError;
  PlayoffSeries? get leagueFinal => throw _privateConstructorUsedError;

  /// Serializes this PlayoffBracket to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlayoffBracket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayoffBracketCopyWith<PlayoffBracket> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayoffBracketCopyWith<$Res> {
  factory $PlayoffBracketCopyWith(
    PlayoffBracket value,
    $Res Function(PlayoffBracket) then,
  ) = _$PlayoffBracketCopyWithImpl<$Res, PlayoffBracket>;
  @useResult
  $Res call({
    Conference conference,
    List<PlayoffSeries> quarterFinals,
    List<PlayoffSeries> semiFinals,
    List<PlayoffSeries> conferenceFinal,
    PlayoffSeries? leagueFinal,
  });

  $PlayoffSeriesCopyWith<$Res>? get leagueFinal;
}

/// @nodoc
class _$PlayoffBracketCopyWithImpl<$Res, $Val extends PlayoffBracket>
    implements $PlayoffBracketCopyWith<$Res> {
  _$PlayoffBracketCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayoffBracket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conference = null,
    Object? quarterFinals = null,
    Object? semiFinals = null,
    Object? conferenceFinal = null,
    Object? leagueFinal = freezed,
  }) {
    return _then(
      _value.copyWith(
            conference: null == conference
                ? _value.conference
                : conference // ignore: cast_nullable_to_non_nullable
                      as Conference,
            quarterFinals: null == quarterFinals
                ? _value.quarterFinals
                : quarterFinals // ignore: cast_nullable_to_non_nullable
                      as List<PlayoffSeries>,
            semiFinals: null == semiFinals
                ? _value.semiFinals
                : semiFinals // ignore: cast_nullable_to_non_nullable
                      as List<PlayoffSeries>,
            conferenceFinal: null == conferenceFinal
                ? _value.conferenceFinal
                : conferenceFinal // ignore: cast_nullable_to_non_nullable
                      as List<PlayoffSeries>,
            leagueFinal: freezed == leagueFinal
                ? _value.leagueFinal
                : leagueFinal // ignore: cast_nullable_to_non_nullable
                      as PlayoffSeries?,
          )
          as $Val,
    );
  }

  /// Create a copy of PlayoffBracket
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlayoffSeriesCopyWith<$Res>? get leagueFinal {
    if (_value.leagueFinal == null) {
      return null;
    }

    return $PlayoffSeriesCopyWith<$Res>(_value.leagueFinal!, (value) {
      return _then(_value.copyWith(leagueFinal: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlayoffBracketImplCopyWith<$Res>
    implements $PlayoffBracketCopyWith<$Res> {
  factory _$$PlayoffBracketImplCopyWith(
    _$PlayoffBracketImpl value,
    $Res Function(_$PlayoffBracketImpl) then,
  ) = __$$PlayoffBracketImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Conference conference,
    List<PlayoffSeries> quarterFinals,
    List<PlayoffSeries> semiFinals,
    List<PlayoffSeries> conferenceFinal,
    PlayoffSeries? leagueFinal,
  });

  @override
  $PlayoffSeriesCopyWith<$Res>? get leagueFinal;
}

/// @nodoc
class __$$PlayoffBracketImplCopyWithImpl<$Res>
    extends _$PlayoffBracketCopyWithImpl<$Res, _$PlayoffBracketImpl>
    implements _$$PlayoffBracketImplCopyWith<$Res> {
  __$$PlayoffBracketImplCopyWithImpl(
    _$PlayoffBracketImpl _value,
    $Res Function(_$PlayoffBracketImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlayoffBracket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conference = null,
    Object? quarterFinals = null,
    Object? semiFinals = null,
    Object? conferenceFinal = null,
    Object? leagueFinal = freezed,
  }) {
    return _then(
      _$PlayoffBracketImpl(
        conference: null == conference
            ? _value.conference
            : conference // ignore: cast_nullable_to_non_nullable
                  as Conference,
        quarterFinals: null == quarterFinals
            ? _value._quarterFinals
            : quarterFinals // ignore: cast_nullable_to_non_nullable
                  as List<PlayoffSeries>,
        semiFinals: null == semiFinals
            ? _value._semiFinals
            : semiFinals // ignore: cast_nullable_to_non_nullable
                  as List<PlayoffSeries>,
        conferenceFinal: null == conferenceFinal
            ? _value._conferenceFinal
            : conferenceFinal // ignore: cast_nullable_to_non_nullable
                  as List<PlayoffSeries>,
        leagueFinal: freezed == leagueFinal
            ? _value.leagueFinal
            : leagueFinal // ignore: cast_nullable_to_non_nullable
                  as PlayoffSeries?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayoffBracketImpl implements _PlayoffBracket {
  const _$PlayoffBracketImpl({
    required this.conference,
    final List<PlayoffSeries> quarterFinals = const [],
    final List<PlayoffSeries> semiFinals = const [],
    final List<PlayoffSeries> conferenceFinal = const [],
    this.leagueFinal,
  }) : _quarterFinals = quarterFinals,
       _semiFinals = semiFinals,
       _conferenceFinal = conferenceFinal;

  factory _$PlayoffBracketImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayoffBracketImplFromJson(json);

  @override
  final Conference conference;
  final List<PlayoffSeries> _quarterFinals;
  @override
  @JsonKey()
  List<PlayoffSeries> get quarterFinals {
    if (_quarterFinals is EqualUnmodifiableListView) return _quarterFinals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_quarterFinals);
  }

  final List<PlayoffSeries> _semiFinals;
  @override
  @JsonKey()
  List<PlayoffSeries> get semiFinals {
    if (_semiFinals is EqualUnmodifiableListView) return _semiFinals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_semiFinals);
  }

  final List<PlayoffSeries> _conferenceFinal;
  @override
  @JsonKey()
  List<PlayoffSeries> get conferenceFinal {
    if (_conferenceFinal is EqualUnmodifiableListView) return _conferenceFinal;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conferenceFinal);
  }

  @override
  final PlayoffSeries? leagueFinal;

  @override
  String toString() {
    return 'PlayoffBracket(conference: $conference, quarterFinals: $quarterFinals, semiFinals: $semiFinals, conferenceFinal: $conferenceFinal, leagueFinal: $leagueFinal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayoffBracketImpl &&
            (identical(other.conference, conference) ||
                other.conference == conference) &&
            const DeepCollectionEquality().equals(
              other._quarterFinals,
              _quarterFinals,
            ) &&
            const DeepCollectionEquality().equals(
              other._semiFinals,
              _semiFinals,
            ) &&
            const DeepCollectionEquality().equals(
              other._conferenceFinal,
              _conferenceFinal,
            ) &&
            (identical(other.leagueFinal, leagueFinal) ||
                other.leagueFinal == leagueFinal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    conference,
    const DeepCollectionEquality().hash(_quarterFinals),
    const DeepCollectionEquality().hash(_semiFinals),
    const DeepCollectionEquality().hash(_conferenceFinal),
    leagueFinal,
  );

  /// Create a copy of PlayoffBracket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayoffBracketImplCopyWith<_$PlayoffBracketImpl> get copyWith =>
      __$$PlayoffBracketImplCopyWithImpl<_$PlayoffBracketImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayoffBracketImplToJson(this);
  }
}

abstract class _PlayoffBracket implements PlayoffBracket {
  const factory _PlayoffBracket({
    required final Conference conference,
    final List<PlayoffSeries> quarterFinals,
    final List<PlayoffSeries> semiFinals,
    final List<PlayoffSeries> conferenceFinal,
    final PlayoffSeries? leagueFinal,
  }) = _$PlayoffBracketImpl;

  factory _PlayoffBracket.fromJson(Map<String, dynamic> json) =
      _$PlayoffBracketImpl.fromJson;

  @override
  Conference get conference;
  @override
  List<PlayoffSeries> get quarterFinals;
  @override
  List<PlayoffSeries> get semiFinals;
  @override
  List<PlayoffSeries> get conferenceFinal;
  @override
  PlayoffSeries? get leagueFinal;

  /// Create a copy of PlayoffBracket
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayoffBracketImplCopyWith<_$PlayoffBracketImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Season _$SeasonFromJson(Map<String, dynamic> json) {
  return _Season.fromJson(json);
}

/// @nodoc
mixin _$Season {
  int get year => throw _privateConstructorUsedError;
  SeasonPhase get phase => throw _privateConstructorUsedError;
  List<ScheduledMatch> get schedule => throw _privateConstructorUsedError;
  List<ConferenceStandings> get standings => throw _privateConstructorUsedError;
  List<PlayInResult> get playInResults => throw _privateConstructorUsedError;
  List<PlayoffBracket> get playoffBrackets =>
      throw _privateConstructorUsedError;
  String? get championTeamId => throw _privateConstructorUsedError;
  DraftState? get draftState => throw _privateConstructorUsedError;
  SeasonAwards? get awards => throw _privateConstructorUsedError;
  bool get staffGrowthDone => throw _privateConstructorUsedError;
  bool get playerRetirementsDone => throw _privateConstructorUsedError;
  bool get combineDone => throw _privateConstructorUsedError;
  bool get finalMockDone => throw _privateConstructorUsedError;
  bool get faOpenDone => throw _privateConstructorUsedError;
  bool get scoutReportDone => throw _privateConstructorUsedError;
  bool get tradeDeadlineAcked => throw _privateConstructorUsedError;
  DraftState? get nextDraftState => throw _privateConstructorUsedError;

  /// Serializes this Season to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Season
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SeasonCopyWith<Season> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeasonCopyWith<$Res> {
  factory $SeasonCopyWith(Season value, $Res Function(Season) then) =
      _$SeasonCopyWithImpl<$Res, Season>;
  @useResult
  $Res call({
    int year,
    SeasonPhase phase,
    List<ScheduledMatch> schedule,
    List<ConferenceStandings> standings,
    List<PlayInResult> playInResults,
    List<PlayoffBracket> playoffBrackets,
    String? championTeamId,
    DraftState? draftState,
    SeasonAwards? awards,
    bool staffGrowthDone,
    bool playerRetirementsDone,
    bool combineDone,
    bool finalMockDone,
    bool faOpenDone,
    bool scoutReportDone,
    bool tradeDeadlineAcked,
    DraftState? nextDraftState,
  });

  $DraftStateCopyWith<$Res>? get draftState;
  $SeasonAwardsCopyWith<$Res>? get awards;
  $DraftStateCopyWith<$Res>? get nextDraftState;
}

/// @nodoc
class _$SeasonCopyWithImpl<$Res, $Val extends Season>
    implements $SeasonCopyWith<$Res> {
  _$SeasonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Season
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? phase = null,
    Object? schedule = null,
    Object? standings = null,
    Object? playInResults = null,
    Object? playoffBrackets = null,
    Object? championTeamId = freezed,
    Object? draftState = freezed,
    Object? awards = freezed,
    Object? staffGrowthDone = null,
    Object? playerRetirementsDone = null,
    Object? combineDone = null,
    Object? finalMockDone = null,
    Object? faOpenDone = null,
    Object? scoutReportDone = null,
    Object? tradeDeadlineAcked = null,
    Object? nextDraftState = freezed,
  }) {
    return _then(
      _value.copyWith(
            year: null == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int,
            phase: null == phase
                ? _value.phase
                : phase // ignore: cast_nullable_to_non_nullable
                      as SeasonPhase,
            schedule: null == schedule
                ? _value.schedule
                : schedule // ignore: cast_nullable_to_non_nullable
                      as List<ScheduledMatch>,
            standings: null == standings
                ? _value.standings
                : standings // ignore: cast_nullable_to_non_nullable
                      as List<ConferenceStandings>,
            playInResults: null == playInResults
                ? _value.playInResults
                : playInResults // ignore: cast_nullable_to_non_nullable
                      as List<PlayInResult>,
            playoffBrackets: null == playoffBrackets
                ? _value.playoffBrackets
                : playoffBrackets // ignore: cast_nullable_to_non_nullable
                      as List<PlayoffBracket>,
            championTeamId: freezed == championTeamId
                ? _value.championTeamId
                : championTeamId // ignore: cast_nullable_to_non_nullable
                      as String?,
            draftState: freezed == draftState
                ? _value.draftState
                : draftState // ignore: cast_nullable_to_non_nullable
                      as DraftState?,
            awards: freezed == awards
                ? _value.awards
                : awards // ignore: cast_nullable_to_non_nullable
                      as SeasonAwards?,
            staffGrowthDone: null == staffGrowthDone
                ? _value.staffGrowthDone
                : staffGrowthDone // ignore: cast_nullable_to_non_nullable
                      as bool,
            playerRetirementsDone: null == playerRetirementsDone
                ? _value.playerRetirementsDone
                : playerRetirementsDone // ignore: cast_nullable_to_non_nullable
                      as bool,
            combineDone: null == combineDone
                ? _value.combineDone
                : combineDone // ignore: cast_nullable_to_non_nullable
                      as bool,
            finalMockDone: null == finalMockDone
                ? _value.finalMockDone
                : finalMockDone // ignore: cast_nullable_to_non_nullable
                      as bool,
            faOpenDone: null == faOpenDone
                ? _value.faOpenDone
                : faOpenDone // ignore: cast_nullable_to_non_nullable
                      as bool,
            scoutReportDone: null == scoutReportDone
                ? _value.scoutReportDone
                : scoutReportDone // ignore: cast_nullable_to_non_nullable
                      as bool,
            tradeDeadlineAcked: null == tradeDeadlineAcked
                ? _value.tradeDeadlineAcked
                : tradeDeadlineAcked // ignore: cast_nullable_to_non_nullable
                      as bool,
            nextDraftState: freezed == nextDraftState
                ? _value.nextDraftState
                : nextDraftState // ignore: cast_nullable_to_non_nullable
                      as DraftState?,
          )
          as $Val,
    );
  }

  /// Create a copy of Season
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DraftStateCopyWith<$Res>? get draftState {
    if (_value.draftState == null) {
      return null;
    }

    return $DraftStateCopyWith<$Res>(_value.draftState!, (value) {
      return _then(_value.copyWith(draftState: value) as $Val);
    });
  }

  /// Create a copy of Season
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SeasonAwardsCopyWith<$Res>? get awards {
    if (_value.awards == null) {
      return null;
    }

    return $SeasonAwardsCopyWith<$Res>(_value.awards!, (value) {
      return _then(_value.copyWith(awards: value) as $Val);
    });
  }

  /// Create a copy of Season
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DraftStateCopyWith<$Res>? get nextDraftState {
    if (_value.nextDraftState == null) {
      return null;
    }

    return $DraftStateCopyWith<$Res>(_value.nextDraftState!, (value) {
      return _then(_value.copyWith(nextDraftState: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SeasonImplCopyWith<$Res> implements $SeasonCopyWith<$Res> {
  factory _$$SeasonImplCopyWith(
    _$SeasonImpl value,
    $Res Function(_$SeasonImpl) then,
  ) = __$$SeasonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int year,
    SeasonPhase phase,
    List<ScheduledMatch> schedule,
    List<ConferenceStandings> standings,
    List<PlayInResult> playInResults,
    List<PlayoffBracket> playoffBrackets,
    String? championTeamId,
    DraftState? draftState,
    SeasonAwards? awards,
    bool staffGrowthDone,
    bool playerRetirementsDone,
    bool combineDone,
    bool finalMockDone,
    bool faOpenDone,
    bool scoutReportDone,
    bool tradeDeadlineAcked,
    DraftState? nextDraftState,
  });

  @override
  $DraftStateCopyWith<$Res>? get draftState;
  @override
  $SeasonAwardsCopyWith<$Res>? get awards;
  @override
  $DraftStateCopyWith<$Res>? get nextDraftState;
}

/// @nodoc
class __$$SeasonImplCopyWithImpl<$Res>
    extends _$SeasonCopyWithImpl<$Res, _$SeasonImpl>
    implements _$$SeasonImplCopyWith<$Res> {
  __$$SeasonImplCopyWithImpl(
    _$SeasonImpl _value,
    $Res Function(_$SeasonImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Season
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? phase = null,
    Object? schedule = null,
    Object? standings = null,
    Object? playInResults = null,
    Object? playoffBrackets = null,
    Object? championTeamId = freezed,
    Object? draftState = freezed,
    Object? awards = freezed,
    Object? staffGrowthDone = null,
    Object? playerRetirementsDone = null,
    Object? combineDone = null,
    Object? finalMockDone = null,
    Object? faOpenDone = null,
    Object? scoutReportDone = null,
    Object? tradeDeadlineAcked = null,
    Object? nextDraftState = freezed,
  }) {
    return _then(
      _$SeasonImpl(
        year: null == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int,
        phase: null == phase
            ? _value.phase
            : phase // ignore: cast_nullable_to_non_nullable
                  as SeasonPhase,
        schedule: null == schedule
            ? _value._schedule
            : schedule // ignore: cast_nullable_to_non_nullable
                  as List<ScheduledMatch>,
        standings: null == standings
            ? _value._standings
            : standings // ignore: cast_nullable_to_non_nullable
                  as List<ConferenceStandings>,
        playInResults: null == playInResults
            ? _value._playInResults
            : playInResults // ignore: cast_nullable_to_non_nullable
                  as List<PlayInResult>,
        playoffBrackets: null == playoffBrackets
            ? _value._playoffBrackets
            : playoffBrackets // ignore: cast_nullable_to_non_nullable
                  as List<PlayoffBracket>,
        championTeamId: freezed == championTeamId
            ? _value.championTeamId
            : championTeamId // ignore: cast_nullable_to_non_nullable
                  as String?,
        draftState: freezed == draftState
            ? _value.draftState
            : draftState // ignore: cast_nullable_to_non_nullable
                  as DraftState?,
        awards: freezed == awards
            ? _value.awards
            : awards // ignore: cast_nullable_to_non_nullable
                  as SeasonAwards?,
        staffGrowthDone: null == staffGrowthDone
            ? _value.staffGrowthDone
            : staffGrowthDone // ignore: cast_nullable_to_non_nullable
                  as bool,
        playerRetirementsDone: null == playerRetirementsDone
            ? _value.playerRetirementsDone
            : playerRetirementsDone // ignore: cast_nullable_to_non_nullable
                  as bool,
        combineDone: null == combineDone
            ? _value.combineDone
            : combineDone // ignore: cast_nullable_to_non_nullable
                  as bool,
        finalMockDone: null == finalMockDone
            ? _value.finalMockDone
            : finalMockDone // ignore: cast_nullable_to_non_nullable
                  as bool,
        faOpenDone: null == faOpenDone
            ? _value.faOpenDone
            : faOpenDone // ignore: cast_nullable_to_non_nullable
                  as bool,
        scoutReportDone: null == scoutReportDone
            ? _value.scoutReportDone
            : scoutReportDone // ignore: cast_nullable_to_non_nullable
                  as bool,
        tradeDeadlineAcked: null == tradeDeadlineAcked
            ? _value.tradeDeadlineAcked
            : tradeDeadlineAcked // ignore: cast_nullable_to_non_nullable
                  as bool,
        nextDraftState: freezed == nextDraftState
            ? _value.nextDraftState
            : nextDraftState // ignore: cast_nullable_to_non_nullable
                  as DraftState?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SeasonImpl implements _Season {
  const _$SeasonImpl({
    required this.year,
    this.phase = SeasonPhase.preseason,
    final List<ScheduledMatch> schedule = const [],
    final List<ConferenceStandings> standings = const [],
    final List<PlayInResult> playInResults = const [],
    final List<PlayoffBracket> playoffBrackets = const [],
    this.championTeamId,
    this.draftState,
    this.awards,
    this.staffGrowthDone = false,
    this.playerRetirementsDone = false,
    this.combineDone = false,
    this.finalMockDone = false,
    this.faOpenDone = false,
    this.scoutReportDone = false,
    this.tradeDeadlineAcked = false,
    this.nextDraftState,
  }) : _schedule = schedule,
       _standings = standings,
       _playInResults = playInResults,
       _playoffBrackets = playoffBrackets;

  factory _$SeasonImpl.fromJson(Map<String, dynamic> json) =>
      _$$SeasonImplFromJson(json);

  @override
  final int year;
  @override
  @JsonKey()
  final SeasonPhase phase;
  final List<ScheduledMatch> _schedule;
  @override
  @JsonKey()
  List<ScheduledMatch> get schedule {
    if (_schedule is EqualUnmodifiableListView) return _schedule;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_schedule);
  }

  final List<ConferenceStandings> _standings;
  @override
  @JsonKey()
  List<ConferenceStandings> get standings {
    if (_standings is EqualUnmodifiableListView) return _standings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_standings);
  }

  final List<PlayInResult> _playInResults;
  @override
  @JsonKey()
  List<PlayInResult> get playInResults {
    if (_playInResults is EqualUnmodifiableListView) return _playInResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playInResults);
  }

  final List<PlayoffBracket> _playoffBrackets;
  @override
  @JsonKey()
  List<PlayoffBracket> get playoffBrackets {
    if (_playoffBrackets is EqualUnmodifiableListView) return _playoffBrackets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playoffBrackets);
  }

  @override
  final String? championTeamId;
  @override
  final DraftState? draftState;
  @override
  final SeasonAwards? awards;
  @override
  @JsonKey()
  final bool staffGrowthDone;
  @override
  @JsonKey()
  final bool playerRetirementsDone;
  @override
  @JsonKey()
  final bool combineDone;
  @override
  @JsonKey()
  final bool finalMockDone;
  @override
  @JsonKey()
  final bool faOpenDone;
  @override
  @JsonKey()
  final bool scoutReportDone;
  @override
  @JsonKey()
  final bool tradeDeadlineAcked;
  @override
  final DraftState? nextDraftState;

  @override
  String toString() {
    return 'Season(year: $year, phase: $phase, schedule: $schedule, standings: $standings, playInResults: $playInResults, playoffBrackets: $playoffBrackets, championTeamId: $championTeamId, draftState: $draftState, awards: $awards, staffGrowthDone: $staffGrowthDone, playerRetirementsDone: $playerRetirementsDone, combineDone: $combineDone, finalMockDone: $finalMockDone, faOpenDone: $faOpenDone, scoutReportDone: $scoutReportDone, tradeDeadlineAcked: $tradeDeadlineAcked, nextDraftState: $nextDraftState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeasonImpl &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.phase, phase) || other.phase == phase) &&
            const DeepCollectionEquality().equals(other._schedule, _schedule) &&
            const DeepCollectionEquality().equals(
              other._standings,
              _standings,
            ) &&
            const DeepCollectionEquality().equals(
              other._playInResults,
              _playInResults,
            ) &&
            const DeepCollectionEquality().equals(
              other._playoffBrackets,
              _playoffBrackets,
            ) &&
            (identical(other.championTeamId, championTeamId) ||
                other.championTeamId == championTeamId) &&
            (identical(other.draftState, draftState) ||
                other.draftState == draftState) &&
            (identical(other.awards, awards) || other.awards == awards) &&
            (identical(other.staffGrowthDone, staffGrowthDone) ||
                other.staffGrowthDone == staffGrowthDone) &&
            (identical(other.playerRetirementsDone, playerRetirementsDone) ||
                other.playerRetirementsDone == playerRetirementsDone) &&
            (identical(other.combineDone, combineDone) ||
                other.combineDone == combineDone) &&
            (identical(other.finalMockDone, finalMockDone) ||
                other.finalMockDone == finalMockDone) &&
            (identical(other.faOpenDone, faOpenDone) ||
                other.faOpenDone == faOpenDone) &&
            (identical(other.scoutReportDone, scoutReportDone) ||
                other.scoutReportDone == scoutReportDone) &&
            (identical(other.tradeDeadlineAcked, tradeDeadlineAcked) ||
                other.tradeDeadlineAcked == tradeDeadlineAcked) &&
            (identical(other.nextDraftState, nextDraftState) ||
                other.nextDraftState == nextDraftState));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    year,
    phase,
    const DeepCollectionEquality().hash(_schedule),
    const DeepCollectionEquality().hash(_standings),
    const DeepCollectionEquality().hash(_playInResults),
    const DeepCollectionEquality().hash(_playoffBrackets),
    championTeamId,
    draftState,
    awards,
    staffGrowthDone,
    playerRetirementsDone,
    combineDone,
    finalMockDone,
    faOpenDone,
    scoutReportDone,
    tradeDeadlineAcked,
    nextDraftState,
  );

  /// Create a copy of Season
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SeasonImplCopyWith<_$SeasonImpl> get copyWith =>
      __$$SeasonImplCopyWithImpl<_$SeasonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SeasonImplToJson(this);
  }
}

abstract class _Season implements Season {
  const factory _Season({
    required final int year,
    final SeasonPhase phase,
    final List<ScheduledMatch> schedule,
    final List<ConferenceStandings> standings,
    final List<PlayInResult> playInResults,
    final List<PlayoffBracket> playoffBrackets,
    final String? championTeamId,
    final DraftState? draftState,
    final SeasonAwards? awards,
    final bool staffGrowthDone,
    final bool playerRetirementsDone,
    final bool combineDone,
    final bool finalMockDone,
    final bool faOpenDone,
    final bool scoutReportDone,
    final bool tradeDeadlineAcked,
    final DraftState? nextDraftState,
  }) = _$SeasonImpl;

  factory _Season.fromJson(Map<String, dynamic> json) = _$SeasonImpl.fromJson;

  @override
  int get year;
  @override
  SeasonPhase get phase;
  @override
  List<ScheduledMatch> get schedule;
  @override
  List<ConferenceStandings> get standings;
  @override
  List<PlayInResult> get playInResults;
  @override
  List<PlayoffBracket> get playoffBrackets;
  @override
  String? get championTeamId;
  @override
  DraftState? get draftState;
  @override
  SeasonAwards? get awards;
  @override
  bool get staffGrowthDone;
  @override
  bool get playerRetirementsDone;
  @override
  bool get combineDone;
  @override
  bool get finalMockDone;
  @override
  bool get faOpenDone;
  @override
  bool get scoutReportDone;
  @override
  bool get tradeDeadlineAcked;
  @override
  DraftState? get nextDraftState;

  /// Create a copy of Season
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SeasonImplCopyWith<_$SeasonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SeasonHistory _$SeasonHistoryFromJson(Map<String, dynamic> json) {
  return _SeasonHistory.fromJson(json);
}

/// @nodoc
mixin _$SeasonHistory {
  int get year => throw _privateConstructorUsedError;
  List<ConferenceStandings> get finalStandings =>
      throw _privateConstructorUsedError;
  String? get championTeamId => throw _privateConstructorUsedError;
  List<DraftPick> get draftPicks => throw _privateConstructorUsedError;

  /// Serializes this SeasonHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SeasonHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SeasonHistoryCopyWith<SeasonHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeasonHistoryCopyWith<$Res> {
  factory $SeasonHistoryCopyWith(
    SeasonHistory value,
    $Res Function(SeasonHistory) then,
  ) = _$SeasonHistoryCopyWithImpl<$Res, SeasonHistory>;
  @useResult
  $Res call({
    int year,
    List<ConferenceStandings> finalStandings,
    String? championTeamId,
    List<DraftPick> draftPicks,
  });
}

/// @nodoc
class _$SeasonHistoryCopyWithImpl<$Res, $Val extends SeasonHistory>
    implements $SeasonHistoryCopyWith<$Res> {
  _$SeasonHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SeasonHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? finalStandings = null,
    Object? championTeamId = freezed,
    Object? draftPicks = null,
  }) {
    return _then(
      _value.copyWith(
            year: null == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int,
            finalStandings: null == finalStandings
                ? _value.finalStandings
                : finalStandings // ignore: cast_nullable_to_non_nullable
                      as List<ConferenceStandings>,
            championTeamId: freezed == championTeamId
                ? _value.championTeamId
                : championTeamId // ignore: cast_nullable_to_non_nullable
                      as String?,
            draftPicks: null == draftPicks
                ? _value.draftPicks
                : draftPicks // ignore: cast_nullable_to_non_nullable
                      as List<DraftPick>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SeasonHistoryImplCopyWith<$Res>
    implements $SeasonHistoryCopyWith<$Res> {
  factory _$$SeasonHistoryImplCopyWith(
    _$SeasonHistoryImpl value,
    $Res Function(_$SeasonHistoryImpl) then,
  ) = __$$SeasonHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int year,
    List<ConferenceStandings> finalStandings,
    String? championTeamId,
    List<DraftPick> draftPicks,
  });
}

/// @nodoc
class __$$SeasonHistoryImplCopyWithImpl<$Res>
    extends _$SeasonHistoryCopyWithImpl<$Res, _$SeasonHistoryImpl>
    implements _$$SeasonHistoryImplCopyWith<$Res> {
  __$$SeasonHistoryImplCopyWithImpl(
    _$SeasonHistoryImpl _value,
    $Res Function(_$SeasonHistoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SeasonHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? finalStandings = null,
    Object? championTeamId = freezed,
    Object? draftPicks = null,
  }) {
    return _then(
      _$SeasonHistoryImpl(
        year: null == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int,
        finalStandings: null == finalStandings
            ? _value._finalStandings
            : finalStandings // ignore: cast_nullable_to_non_nullable
                  as List<ConferenceStandings>,
        championTeamId: freezed == championTeamId
            ? _value.championTeamId
            : championTeamId // ignore: cast_nullable_to_non_nullable
                  as String?,
        draftPicks: null == draftPicks
            ? _value._draftPicks
            : draftPicks // ignore: cast_nullable_to_non_nullable
                  as List<DraftPick>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SeasonHistoryImpl implements _SeasonHistory {
  const _$SeasonHistoryImpl({
    required this.year,
    required final List<ConferenceStandings> finalStandings,
    this.championTeamId,
    final List<DraftPick> draftPicks = const [],
  }) : _finalStandings = finalStandings,
       _draftPicks = draftPicks;

  factory _$SeasonHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$SeasonHistoryImplFromJson(json);

  @override
  final int year;
  final List<ConferenceStandings> _finalStandings;
  @override
  List<ConferenceStandings> get finalStandings {
    if (_finalStandings is EqualUnmodifiableListView) return _finalStandings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_finalStandings);
  }

  @override
  final String? championTeamId;
  final List<DraftPick> _draftPicks;
  @override
  @JsonKey()
  List<DraftPick> get draftPicks {
    if (_draftPicks is EqualUnmodifiableListView) return _draftPicks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_draftPicks);
  }

  @override
  String toString() {
    return 'SeasonHistory(year: $year, finalStandings: $finalStandings, championTeamId: $championTeamId, draftPicks: $draftPicks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeasonHistoryImpl &&
            (identical(other.year, year) || other.year == year) &&
            const DeepCollectionEquality().equals(
              other._finalStandings,
              _finalStandings,
            ) &&
            (identical(other.championTeamId, championTeamId) ||
                other.championTeamId == championTeamId) &&
            const DeepCollectionEquality().equals(
              other._draftPicks,
              _draftPicks,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    year,
    const DeepCollectionEquality().hash(_finalStandings),
    championTeamId,
    const DeepCollectionEquality().hash(_draftPicks),
  );

  /// Create a copy of SeasonHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SeasonHistoryImplCopyWith<_$SeasonHistoryImpl> get copyWith =>
      __$$SeasonHistoryImplCopyWithImpl<_$SeasonHistoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SeasonHistoryImplToJson(this);
  }
}

abstract class _SeasonHistory implements SeasonHistory {
  const factory _SeasonHistory({
    required final int year,
    required final List<ConferenceStandings> finalStandings,
    final String? championTeamId,
    final List<DraftPick> draftPicks,
  }) = _$SeasonHistoryImpl;

  factory _SeasonHistory.fromJson(Map<String, dynamic> json) =
      _$SeasonHistoryImpl.fromJson;

  @override
  int get year;
  @override
  List<ConferenceStandings> get finalStandings;
  @override
  String? get championTeamId;
  @override
  List<DraftPick> get draftPicks;

  /// Create a copy of SeasonHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SeasonHistoryImplCopyWith<_$SeasonHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
