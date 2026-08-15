// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TeamAiConfig _$TeamAiConfigFromJson(Map<String, dynamic> json) {
  return _TeamAiConfig.fromJson(json);
}

/// @nodoc
mixin _$TeamAiConfig {
  double get aggressionLevel => throw _privateConstructorUsedError;
  double get riskTolerance => throw _privateConstructorUsedError;
  Map<String, dynamic> get playerPatternMemory =>
      throw _privateConstructorUsedError;

  /// Serializes this TeamAiConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeamAiConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamAiConfigCopyWith<TeamAiConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamAiConfigCopyWith<$Res> {
  factory $TeamAiConfigCopyWith(
    TeamAiConfig value,
    $Res Function(TeamAiConfig) then,
  ) = _$TeamAiConfigCopyWithImpl<$Res, TeamAiConfig>;
  @useResult
  $Res call({
    double aggressionLevel,
    double riskTolerance,
    Map<String, dynamic> playerPatternMemory,
  });
}

/// @nodoc
class _$TeamAiConfigCopyWithImpl<$Res, $Val extends TeamAiConfig>
    implements $TeamAiConfigCopyWith<$Res> {
  _$TeamAiConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeamAiConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? aggressionLevel = null,
    Object? riskTolerance = null,
    Object? playerPatternMemory = null,
  }) {
    return _then(
      _value.copyWith(
            aggressionLevel: null == aggressionLevel
                ? _value.aggressionLevel
                : aggressionLevel // ignore: cast_nullable_to_non_nullable
                      as double,
            riskTolerance: null == riskTolerance
                ? _value.riskTolerance
                : riskTolerance // ignore: cast_nullable_to_non_nullable
                      as double,
            playerPatternMemory: null == playerPatternMemory
                ? _value.playerPatternMemory
                : playerPatternMemory // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeamAiConfigImplCopyWith<$Res>
    implements $TeamAiConfigCopyWith<$Res> {
  factory _$$TeamAiConfigImplCopyWith(
    _$TeamAiConfigImpl value,
    $Res Function(_$TeamAiConfigImpl) then,
  ) = __$$TeamAiConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double aggressionLevel,
    double riskTolerance,
    Map<String, dynamic> playerPatternMemory,
  });
}

/// @nodoc
class __$$TeamAiConfigImplCopyWithImpl<$Res>
    extends _$TeamAiConfigCopyWithImpl<$Res, _$TeamAiConfigImpl>
    implements _$$TeamAiConfigImplCopyWith<$Res> {
  __$$TeamAiConfigImplCopyWithImpl(
    _$TeamAiConfigImpl _value,
    $Res Function(_$TeamAiConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeamAiConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? aggressionLevel = null,
    Object? riskTolerance = null,
    Object? playerPatternMemory = null,
  }) {
    return _then(
      _$TeamAiConfigImpl(
        aggressionLevel: null == aggressionLevel
            ? _value.aggressionLevel
            : aggressionLevel // ignore: cast_nullable_to_non_nullable
                  as double,
        riskTolerance: null == riskTolerance
            ? _value.riskTolerance
            : riskTolerance // ignore: cast_nullable_to_non_nullable
                  as double,
        playerPatternMemory: null == playerPatternMemory
            ? _value._playerPatternMemory
            : playerPatternMemory // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamAiConfigImpl implements _TeamAiConfig {
  const _$TeamAiConfigImpl({
    this.aggressionLevel = 0.5,
    this.riskTolerance = 0.5,
    final Map<String, dynamic> playerPatternMemory = const {},
  }) : _playerPatternMemory = playerPatternMemory;

  factory _$TeamAiConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamAiConfigImplFromJson(json);

  @override
  @JsonKey()
  final double aggressionLevel;
  @override
  @JsonKey()
  final double riskTolerance;
  final Map<String, dynamic> _playerPatternMemory;
  @override
  @JsonKey()
  Map<String, dynamic> get playerPatternMemory {
    if (_playerPatternMemory is EqualUnmodifiableMapView)
      return _playerPatternMemory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_playerPatternMemory);
  }

  @override
  String toString() {
    return 'TeamAiConfig(aggressionLevel: $aggressionLevel, riskTolerance: $riskTolerance, playerPatternMemory: $playerPatternMemory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamAiConfigImpl &&
            (identical(other.aggressionLevel, aggressionLevel) ||
                other.aggressionLevel == aggressionLevel) &&
            (identical(other.riskTolerance, riskTolerance) ||
                other.riskTolerance == riskTolerance) &&
            const DeepCollectionEquality().equals(
              other._playerPatternMemory,
              _playerPatternMemory,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    aggressionLevel,
    riskTolerance,
    const DeepCollectionEquality().hash(_playerPatternMemory),
  );

  /// Create a copy of TeamAiConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamAiConfigImplCopyWith<_$TeamAiConfigImpl> get copyWith =>
      __$$TeamAiConfigImplCopyWithImpl<_$TeamAiConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamAiConfigImplToJson(this);
  }
}

abstract class _TeamAiConfig implements TeamAiConfig {
  const factory _TeamAiConfig({
    final double aggressionLevel,
    final double riskTolerance,
    final Map<String, dynamic> playerPatternMemory,
  }) = _$TeamAiConfigImpl;

  factory _TeamAiConfig.fromJson(Map<String, dynamic> json) =
      _$TeamAiConfigImpl.fromJson;

  @override
  double get aggressionLevel;
  @override
  double get riskTolerance;
  @override
  Map<String, dynamic> get playerPatternMemory;

  /// Create a copy of TeamAiConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamAiConfigImplCopyWith<_$TeamAiConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Team _$TeamFromJson(Map<String, dynamic> json) {
  return _Team.fromJson(json);
}

/// @nodoc
mixin _$Team {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  Conference get conference => throw _privateConstructorUsedError;
  List<Player> get roster => throw _privateConstructorUsedError;
  TeamFinance get finance => throw _privateConstructorUsedError;
  TacticsSetup get tactics => throw _privateConstructorUsedError;
  List<String> get lineupPlayerIds => throw _privateConstructorUsedError;
  List<String> get benchPlayerIds => throw _privateConstructorUsedError;
  int get atmosphere => throw _privateConstructorUsedError;
  int get chemistry => throw _privateConstructorUsedError;
  TeamStaff get staff => throw _privateConstructorUsedError;
  TeamScouting get scouting => throw _privateConstructorUsedError;

  /// Picki draftowe (własne i nabyte) — bieżący rocznik oraz przyszłe,
  /// handlowalne (`docs/trade_rules.md`, `DraftPick`).
  List<DraftPick> get ownedPicks => throw _privateConstructorUsedError;

  /// `null` = drużyna gracza; ustawione = drużyna AI.
  TeamAiConfig? get ai => throw _privateConstructorUsedError;

  /// Serializes this Team to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamCopyWith<Team> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamCopyWith<$Res> {
  factory $TeamCopyWith(Team value, $Res Function(Team) then) =
      _$TeamCopyWithImpl<$Res, Team>;
  @useResult
  $Res call({
    String id,
    String name,
    String city,
    Conference conference,
    List<Player> roster,
    TeamFinance finance,
    TacticsSetup tactics,
    List<String> lineupPlayerIds,
    List<String> benchPlayerIds,
    int atmosphere,
    int chemistry,
    TeamStaff staff,
    TeamScouting scouting,
    List<DraftPick> ownedPicks,
    TeamAiConfig? ai,
  });

  $TeamFinanceCopyWith<$Res> get finance;
  $TacticsSetupCopyWith<$Res> get tactics;
  $TeamStaffCopyWith<$Res> get staff;
  $TeamScoutingCopyWith<$Res> get scouting;
  $TeamAiConfigCopyWith<$Res>? get ai;
}

/// @nodoc
class _$TeamCopyWithImpl<$Res, $Val extends Team>
    implements $TeamCopyWith<$Res> {
  _$TeamCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? city = null,
    Object? conference = null,
    Object? roster = null,
    Object? finance = null,
    Object? tactics = null,
    Object? lineupPlayerIds = null,
    Object? benchPlayerIds = null,
    Object? atmosphere = null,
    Object? chemistry = null,
    Object? staff = null,
    Object? scouting = null,
    Object? ownedPicks = null,
    Object? ai = freezed,
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
            city: null == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String,
            conference: null == conference
                ? _value.conference
                : conference // ignore: cast_nullable_to_non_nullable
                      as Conference,
            roster: null == roster
                ? _value.roster
                : roster // ignore: cast_nullable_to_non_nullable
                      as List<Player>,
            finance: null == finance
                ? _value.finance
                : finance // ignore: cast_nullable_to_non_nullable
                      as TeamFinance,
            tactics: null == tactics
                ? _value.tactics
                : tactics // ignore: cast_nullable_to_non_nullable
                      as TacticsSetup,
            lineupPlayerIds: null == lineupPlayerIds
                ? _value.lineupPlayerIds
                : lineupPlayerIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            benchPlayerIds: null == benchPlayerIds
                ? _value.benchPlayerIds
                : benchPlayerIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            atmosphere: null == atmosphere
                ? _value.atmosphere
                : atmosphere // ignore: cast_nullable_to_non_nullable
                      as int,
            chemistry: null == chemistry
                ? _value.chemistry
                : chemistry // ignore: cast_nullable_to_non_nullable
                      as int,
            staff: null == staff
                ? _value.staff
                : staff // ignore: cast_nullable_to_non_nullable
                      as TeamStaff,
            scouting: null == scouting
                ? _value.scouting
                : scouting // ignore: cast_nullable_to_non_nullable
                      as TeamScouting,
            ownedPicks: null == ownedPicks
                ? _value.ownedPicks
                : ownedPicks // ignore: cast_nullable_to_non_nullable
                      as List<DraftPick>,
            ai: freezed == ai
                ? _value.ai
                : ai // ignore: cast_nullable_to_non_nullable
                      as TeamAiConfig?,
          )
          as $Val,
    );
  }

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamFinanceCopyWith<$Res> get finance {
    return $TeamFinanceCopyWith<$Res>(_value.finance, (value) {
      return _then(_value.copyWith(finance: value) as $Val);
    });
  }

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TacticsSetupCopyWith<$Res> get tactics {
    return $TacticsSetupCopyWith<$Res>(_value.tactics, (value) {
      return _then(_value.copyWith(tactics: value) as $Val);
    });
  }

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamStaffCopyWith<$Res> get staff {
    return $TeamStaffCopyWith<$Res>(_value.staff, (value) {
      return _then(_value.copyWith(staff: value) as $Val);
    });
  }

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamScoutingCopyWith<$Res> get scouting {
    return $TeamScoutingCopyWith<$Res>(_value.scouting, (value) {
      return _then(_value.copyWith(scouting: value) as $Val);
    });
  }

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamAiConfigCopyWith<$Res>? get ai {
    if (_value.ai == null) {
      return null;
    }

    return $TeamAiConfigCopyWith<$Res>(_value.ai!, (value) {
      return _then(_value.copyWith(ai: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TeamImplCopyWith<$Res> implements $TeamCopyWith<$Res> {
  factory _$$TeamImplCopyWith(
    _$TeamImpl value,
    $Res Function(_$TeamImpl) then,
  ) = __$$TeamImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String city,
    Conference conference,
    List<Player> roster,
    TeamFinance finance,
    TacticsSetup tactics,
    List<String> lineupPlayerIds,
    List<String> benchPlayerIds,
    int atmosphere,
    int chemistry,
    TeamStaff staff,
    TeamScouting scouting,
    List<DraftPick> ownedPicks,
    TeamAiConfig? ai,
  });

  @override
  $TeamFinanceCopyWith<$Res> get finance;
  @override
  $TacticsSetupCopyWith<$Res> get tactics;
  @override
  $TeamStaffCopyWith<$Res> get staff;
  @override
  $TeamScoutingCopyWith<$Res> get scouting;
  @override
  $TeamAiConfigCopyWith<$Res>? get ai;
}

/// @nodoc
class __$$TeamImplCopyWithImpl<$Res>
    extends _$TeamCopyWithImpl<$Res, _$TeamImpl>
    implements _$$TeamImplCopyWith<$Res> {
  __$$TeamImplCopyWithImpl(_$TeamImpl _value, $Res Function(_$TeamImpl) _then)
    : super(_value, _then);

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? city = null,
    Object? conference = null,
    Object? roster = null,
    Object? finance = null,
    Object? tactics = null,
    Object? lineupPlayerIds = null,
    Object? benchPlayerIds = null,
    Object? atmosphere = null,
    Object? chemistry = null,
    Object? staff = null,
    Object? scouting = null,
    Object? ownedPicks = null,
    Object? ai = freezed,
  }) {
    return _then(
      _$TeamImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        city: null == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String,
        conference: null == conference
            ? _value.conference
            : conference // ignore: cast_nullable_to_non_nullable
                  as Conference,
        roster: null == roster
            ? _value._roster
            : roster // ignore: cast_nullable_to_non_nullable
                  as List<Player>,
        finance: null == finance
            ? _value.finance
            : finance // ignore: cast_nullable_to_non_nullable
                  as TeamFinance,
        tactics: null == tactics
            ? _value.tactics
            : tactics // ignore: cast_nullable_to_non_nullable
                  as TacticsSetup,
        lineupPlayerIds: null == lineupPlayerIds
            ? _value._lineupPlayerIds
            : lineupPlayerIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        benchPlayerIds: null == benchPlayerIds
            ? _value._benchPlayerIds
            : benchPlayerIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        atmosphere: null == atmosphere
            ? _value.atmosphere
            : atmosphere // ignore: cast_nullable_to_non_nullable
                  as int,
        chemistry: null == chemistry
            ? _value.chemistry
            : chemistry // ignore: cast_nullable_to_non_nullable
                  as int,
        staff: null == staff
            ? _value.staff
            : staff // ignore: cast_nullable_to_non_nullable
                  as TeamStaff,
        scouting: null == scouting
            ? _value.scouting
            : scouting // ignore: cast_nullable_to_non_nullable
                  as TeamScouting,
        ownedPicks: null == ownedPicks
            ? _value._ownedPicks
            : ownedPicks // ignore: cast_nullable_to_non_nullable
                  as List<DraftPick>,
        ai: freezed == ai
            ? _value.ai
            : ai // ignore: cast_nullable_to_non_nullable
                  as TeamAiConfig?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamImpl implements _Team {
  const _$TeamImpl({
    required this.id,
    required this.name,
    required this.city,
    required this.conference,
    required final List<Player> roster,
    required this.finance,
    this.tactics = const TacticsSetup(),
    final List<String> lineupPlayerIds = const [],
    final List<String> benchPlayerIds = const [],
    this.atmosphere = 50,
    this.chemistry = 50,
    this.staff = const TeamStaff(),
    this.scouting = const TeamScouting(),
    final List<DraftPick> ownedPicks = const [],
    this.ai,
  }) : _roster = roster,
       _lineupPlayerIds = lineupPlayerIds,
       _benchPlayerIds = benchPlayerIds,
       _ownedPicks = ownedPicks;

  factory _$TeamImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String city;
  @override
  final Conference conference;
  final List<Player> _roster;
  @override
  List<Player> get roster {
    if (_roster is EqualUnmodifiableListView) return _roster;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_roster);
  }

  @override
  final TeamFinance finance;
  @override
  @JsonKey()
  final TacticsSetup tactics;
  final List<String> _lineupPlayerIds;
  @override
  @JsonKey()
  List<String> get lineupPlayerIds {
    if (_lineupPlayerIds is EqualUnmodifiableListView) return _lineupPlayerIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lineupPlayerIds);
  }

  final List<String> _benchPlayerIds;
  @override
  @JsonKey()
  List<String> get benchPlayerIds {
    if (_benchPlayerIds is EqualUnmodifiableListView) return _benchPlayerIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_benchPlayerIds);
  }

  @override
  @JsonKey()
  final int atmosphere;
  @override
  @JsonKey()
  final int chemistry;
  @override
  @JsonKey()
  final TeamStaff staff;
  @override
  @JsonKey()
  final TeamScouting scouting;

  /// Picki draftowe (własne i nabyte) — bieżący rocznik oraz przyszłe,
  /// handlowalne (`docs/trade_rules.md`, `DraftPick`).
  final List<DraftPick> _ownedPicks;

  /// Picki draftowe (własne i nabyte) — bieżący rocznik oraz przyszłe,
  /// handlowalne (`docs/trade_rules.md`, `DraftPick`).
  @override
  @JsonKey()
  List<DraftPick> get ownedPicks {
    if (_ownedPicks is EqualUnmodifiableListView) return _ownedPicks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ownedPicks);
  }

  /// `null` = drużyna gracza; ustawione = drużyna AI.
  @override
  final TeamAiConfig? ai;

  @override
  String toString() {
    return 'Team(id: $id, name: $name, city: $city, conference: $conference, roster: $roster, finance: $finance, tactics: $tactics, lineupPlayerIds: $lineupPlayerIds, benchPlayerIds: $benchPlayerIds, atmosphere: $atmosphere, chemistry: $chemistry, staff: $staff, scouting: $scouting, ownedPicks: $ownedPicks, ai: $ai)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.conference, conference) ||
                other.conference == conference) &&
            const DeepCollectionEquality().equals(other._roster, _roster) &&
            (identical(other.finance, finance) || other.finance == finance) &&
            (identical(other.tactics, tactics) || other.tactics == tactics) &&
            const DeepCollectionEquality().equals(
              other._lineupPlayerIds,
              _lineupPlayerIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._benchPlayerIds,
              _benchPlayerIds,
            ) &&
            (identical(other.atmosphere, atmosphere) ||
                other.atmosphere == atmosphere) &&
            (identical(other.chemistry, chemistry) ||
                other.chemistry == chemistry) &&
            (identical(other.staff, staff) || other.staff == staff) &&
            (identical(other.scouting, scouting) ||
                other.scouting == scouting) &&
            const DeepCollectionEquality().equals(
              other._ownedPicks,
              _ownedPicks,
            ) &&
            (identical(other.ai, ai) || other.ai == ai));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    city,
    conference,
    const DeepCollectionEquality().hash(_roster),
    finance,
    tactics,
    const DeepCollectionEquality().hash(_lineupPlayerIds),
    const DeepCollectionEquality().hash(_benchPlayerIds),
    atmosphere,
    chemistry,
    staff,
    scouting,
    const DeepCollectionEquality().hash(_ownedPicks),
    ai,
  );

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamImplCopyWith<_$TeamImpl> get copyWith =>
      __$$TeamImplCopyWithImpl<_$TeamImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamImplToJson(this);
  }
}

abstract class _Team implements Team {
  const factory _Team({
    required final String id,
    required final String name,
    required final String city,
    required final Conference conference,
    required final List<Player> roster,
    required final TeamFinance finance,
    final TacticsSetup tactics,
    final List<String> lineupPlayerIds,
    final List<String> benchPlayerIds,
    final int atmosphere,
    final int chemistry,
    final TeamStaff staff,
    final TeamScouting scouting,
    final List<DraftPick> ownedPicks,
    final TeamAiConfig? ai,
  }) = _$TeamImpl;

  factory _Team.fromJson(Map<String, dynamic> json) = _$TeamImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get city;
  @override
  Conference get conference;
  @override
  List<Player> get roster;
  @override
  TeamFinance get finance;
  @override
  TacticsSetup get tactics;
  @override
  List<String> get lineupPlayerIds;
  @override
  List<String> get benchPlayerIds;
  @override
  int get atmosphere;
  @override
  int get chemistry;
  @override
  TeamStaff get staff;
  @override
  TeamScouting get scouting;

  /// Picki draftowe (własne i nabyte) — bieżący rocznik oraz przyszłe,
  /// handlowalne (`docs/trade_rules.md`, `DraftPick`).
  @override
  List<DraftPick> get ownedPicks;

  /// `null` = drużyna gracza; ustawione = drużyna AI.
  @override
  TeamAiConfig? get ai;

  /// Create a copy of Team
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamImplCopyWith<_$TeamImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
