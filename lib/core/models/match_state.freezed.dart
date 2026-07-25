// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MatchContext _$MatchContextFromJson(Map<String, dynamic> json) {
  return _MatchContext.fromJson(json);
}

/// @nodoc
mixin _$MatchContext {
  bool get isDerby => throw _privateConstructorUsedError;
  Weather get weather => throw _privateConstructorUsedError;
  SeasonPhase get stakes => throw _privateConstructorUsedError;
  double get homeAdvantage => throw _privateConstructorUsedError;

  /// Serializes this MatchContext to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchContext
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchContextCopyWith<MatchContext> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchContextCopyWith<$Res> {
  factory $MatchContextCopyWith(
    MatchContext value,
    $Res Function(MatchContext) then,
  ) = _$MatchContextCopyWithImpl<$Res, MatchContext>;
  @useResult
  $Res call({
    bool isDerby,
    Weather weather,
    SeasonPhase stakes,
    double homeAdvantage,
  });
}

/// @nodoc
class _$MatchContextCopyWithImpl<$Res, $Val extends MatchContext>
    implements $MatchContextCopyWith<$Res> {
  _$MatchContextCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchContext
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isDerby = null,
    Object? weather = null,
    Object? stakes = null,
    Object? homeAdvantage = null,
  }) {
    return _then(
      _value.copyWith(
            isDerby: null == isDerby
                ? _value.isDerby
                : isDerby // ignore: cast_nullable_to_non_nullable
                      as bool,
            weather: null == weather
                ? _value.weather
                : weather // ignore: cast_nullable_to_non_nullable
                      as Weather,
            stakes: null == stakes
                ? _value.stakes
                : stakes // ignore: cast_nullable_to_non_nullable
                      as SeasonPhase,
            homeAdvantage: null == homeAdvantage
                ? _value.homeAdvantage
                : homeAdvantage // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchContextImplCopyWith<$Res>
    implements $MatchContextCopyWith<$Res> {
  factory _$$MatchContextImplCopyWith(
    _$MatchContextImpl value,
    $Res Function(_$MatchContextImpl) then,
  ) = __$$MatchContextImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isDerby,
    Weather weather,
    SeasonPhase stakes,
    double homeAdvantage,
  });
}

/// @nodoc
class __$$MatchContextImplCopyWithImpl<$Res>
    extends _$MatchContextCopyWithImpl<$Res, _$MatchContextImpl>
    implements _$$MatchContextImplCopyWith<$Res> {
  __$$MatchContextImplCopyWithImpl(
    _$MatchContextImpl _value,
    $Res Function(_$MatchContextImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchContext
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isDerby = null,
    Object? weather = null,
    Object? stakes = null,
    Object? homeAdvantage = null,
  }) {
    return _then(
      _$MatchContextImpl(
        isDerby: null == isDerby
            ? _value.isDerby
            : isDerby // ignore: cast_nullable_to_non_nullable
                  as bool,
        weather: null == weather
            ? _value.weather
            : weather // ignore: cast_nullable_to_non_nullable
                  as Weather,
        stakes: null == stakes
            ? _value.stakes
            : stakes // ignore: cast_nullable_to_non_nullable
                  as SeasonPhase,
        homeAdvantage: null == homeAdvantage
            ? _value.homeAdvantage
            : homeAdvantage // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchContextImpl implements _MatchContext {
  const _$MatchContextImpl({
    this.isDerby = false,
    this.weather = Weather.clear,
    this.stakes = SeasonPhase.regular,
    this.homeAdvantage = 0.05,
  });

  factory _$MatchContextImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchContextImplFromJson(json);

  @override
  @JsonKey()
  final bool isDerby;
  @override
  @JsonKey()
  final Weather weather;
  @override
  @JsonKey()
  final SeasonPhase stakes;
  @override
  @JsonKey()
  final double homeAdvantage;

  @override
  String toString() {
    return 'MatchContext(isDerby: $isDerby, weather: $weather, stakes: $stakes, homeAdvantage: $homeAdvantage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchContextImpl &&
            (identical(other.isDerby, isDerby) || other.isDerby == isDerby) &&
            (identical(other.weather, weather) || other.weather == weather) &&
            (identical(other.stakes, stakes) || other.stakes == stakes) &&
            (identical(other.homeAdvantage, homeAdvantage) ||
                other.homeAdvantage == homeAdvantage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, isDerby, weather, stakes, homeAdvantage);

  /// Create a copy of MatchContext
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchContextImplCopyWith<_$MatchContextImpl> get copyWith =>
      __$$MatchContextImplCopyWithImpl<_$MatchContextImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchContextImplToJson(this);
  }
}

abstract class _MatchContext implements MatchContext {
  const factory _MatchContext({
    final bool isDerby,
    final Weather weather,
    final SeasonPhase stakes,
    final double homeAdvantage,
  }) = _$MatchContextImpl;

  factory _MatchContext.fromJson(Map<String, dynamic> json) =
      _$MatchContextImpl.fromJson;

  @override
  bool get isDerby;
  @override
  Weather get weather;
  @override
  SeasonPhase get stakes;
  @override
  double get homeAdvantage;

  /// Create a copy of MatchContext
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchContextImplCopyWith<_$MatchContextImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchState _$MatchStateFromJson(Map<String, dynamic> json) {
  return _MatchState.fromJson(json);
}

/// @nodoc
mixin _$MatchState {
  int get minute => throw _privateConstructorUsedError;
  int get homeGoals => throw _privateConstructorUsedError;
  int get awayGoals => throw _privateConstructorUsedError;
  List<Player> get homeLineup => throw _privateConstructorUsedError;
  List<Player> get awayLineup => throw _privateConstructorUsedError;
  List<Player> get homeBench => throw _privateConstructorUsedError;
  List<Player> get awayBench => throw _privateConstructorUsedError;
  TacticsSetup get homeTactics => throw _privateConstructorUsedError;
  TacticsSetup get awayTactics => throw _privateConstructorUsedError;
  Map<String, int> get yellowCardCounts => throw _privateConstructorUsedError;
  List<String> get sentOffPlayerIds => throw _privateConstructorUsedError;
  List<String> get injuriesThisMatch => throw _privateConstructorUsedError;
  double get momentum => throw _privateConstructorUsedError;
  double get moraleModHome => throw _privateConstructorUsedError;
  double get moraleModAway => throw _privateConstructorUsedError;
  MatchContext get context => throw _privateConstructorUsedError;
  int? get rngSeed => throw _privateConstructorUsedError;

  /// Serializes this MatchState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchStateCopyWith<MatchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchStateCopyWith<$Res> {
  factory $MatchStateCopyWith(
    MatchState value,
    $Res Function(MatchState) then,
  ) = _$MatchStateCopyWithImpl<$Res, MatchState>;
  @useResult
  $Res call({
    int minute,
    int homeGoals,
    int awayGoals,
    List<Player> homeLineup,
    List<Player> awayLineup,
    List<Player> homeBench,
    List<Player> awayBench,
    TacticsSetup homeTactics,
    TacticsSetup awayTactics,
    Map<String, int> yellowCardCounts,
    List<String> sentOffPlayerIds,
    List<String> injuriesThisMatch,
    double momentum,
    double moraleModHome,
    double moraleModAway,
    MatchContext context,
    int? rngSeed,
  });

  $TacticsSetupCopyWith<$Res> get homeTactics;
  $TacticsSetupCopyWith<$Res> get awayTactics;
  $MatchContextCopyWith<$Res> get context;
}

/// @nodoc
class _$MatchStateCopyWithImpl<$Res, $Val extends MatchState>
    implements $MatchStateCopyWith<$Res> {
  _$MatchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minute = null,
    Object? homeGoals = null,
    Object? awayGoals = null,
    Object? homeLineup = null,
    Object? awayLineup = null,
    Object? homeBench = null,
    Object? awayBench = null,
    Object? homeTactics = null,
    Object? awayTactics = null,
    Object? yellowCardCounts = null,
    Object? sentOffPlayerIds = null,
    Object? injuriesThisMatch = null,
    Object? momentum = null,
    Object? moraleModHome = null,
    Object? moraleModAway = null,
    Object? context = null,
    Object? rngSeed = freezed,
  }) {
    return _then(
      _value.copyWith(
            minute: null == minute
                ? _value.minute
                : minute // ignore: cast_nullable_to_non_nullable
                      as int,
            homeGoals: null == homeGoals
                ? _value.homeGoals
                : homeGoals // ignore: cast_nullable_to_non_nullable
                      as int,
            awayGoals: null == awayGoals
                ? _value.awayGoals
                : awayGoals // ignore: cast_nullable_to_non_nullable
                      as int,
            homeLineup: null == homeLineup
                ? _value.homeLineup
                : homeLineup // ignore: cast_nullable_to_non_nullable
                      as List<Player>,
            awayLineup: null == awayLineup
                ? _value.awayLineup
                : awayLineup // ignore: cast_nullable_to_non_nullable
                      as List<Player>,
            homeBench: null == homeBench
                ? _value.homeBench
                : homeBench // ignore: cast_nullable_to_non_nullable
                      as List<Player>,
            awayBench: null == awayBench
                ? _value.awayBench
                : awayBench // ignore: cast_nullable_to_non_nullable
                      as List<Player>,
            homeTactics: null == homeTactics
                ? _value.homeTactics
                : homeTactics // ignore: cast_nullable_to_non_nullable
                      as TacticsSetup,
            awayTactics: null == awayTactics
                ? _value.awayTactics
                : awayTactics // ignore: cast_nullable_to_non_nullable
                      as TacticsSetup,
            yellowCardCounts: null == yellowCardCounts
                ? _value.yellowCardCounts
                : yellowCardCounts // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            sentOffPlayerIds: null == sentOffPlayerIds
                ? _value.sentOffPlayerIds
                : sentOffPlayerIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            injuriesThisMatch: null == injuriesThisMatch
                ? _value.injuriesThisMatch
                : injuriesThisMatch // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            momentum: null == momentum
                ? _value.momentum
                : momentum // ignore: cast_nullable_to_non_nullable
                      as double,
            moraleModHome: null == moraleModHome
                ? _value.moraleModHome
                : moraleModHome // ignore: cast_nullable_to_non_nullable
                      as double,
            moraleModAway: null == moraleModAway
                ? _value.moraleModAway
                : moraleModAway // ignore: cast_nullable_to_non_nullable
                      as double,
            context: null == context
                ? _value.context
                : context // ignore: cast_nullable_to_non_nullable
                      as MatchContext,
            rngSeed: freezed == rngSeed
                ? _value.rngSeed
                : rngSeed // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }

  /// Create a copy of MatchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TacticsSetupCopyWith<$Res> get homeTactics {
    return $TacticsSetupCopyWith<$Res>(_value.homeTactics, (value) {
      return _then(_value.copyWith(homeTactics: value) as $Val);
    });
  }

  /// Create a copy of MatchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TacticsSetupCopyWith<$Res> get awayTactics {
    return $TacticsSetupCopyWith<$Res>(_value.awayTactics, (value) {
      return _then(_value.copyWith(awayTactics: value) as $Val);
    });
  }

  /// Create a copy of MatchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchContextCopyWith<$Res> get context {
    return $MatchContextCopyWith<$Res>(_value.context, (value) {
      return _then(_value.copyWith(context: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchStateImplCopyWith<$Res>
    implements $MatchStateCopyWith<$Res> {
  factory _$$MatchStateImplCopyWith(
    _$MatchStateImpl value,
    $Res Function(_$MatchStateImpl) then,
  ) = __$$MatchStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int minute,
    int homeGoals,
    int awayGoals,
    List<Player> homeLineup,
    List<Player> awayLineup,
    List<Player> homeBench,
    List<Player> awayBench,
    TacticsSetup homeTactics,
    TacticsSetup awayTactics,
    Map<String, int> yellowCardCounts,
    List<String> sentOffPlayerIds,
    List<String> injuriesThisMatch,
    double momentum,
    double moraleModHome,
    double moraleModAway,
    MatchContext context,
    int? rngSeed,
  });

  @override
  $TacticsSetupCopyWith<$Res> get homeTactics;
  @override
  $TacticsSetupCopyWith<$Res> get awayTactics;
  @override
  $MatchContextCopyWith<$Res> get context;
}

/// @nodoc
class __$$MatchStateImplCopyWithImpl<$Res>
    extends _$MatchStateCopyWithImpl<$Res, _$MatchStateImpl>
    implements _$$MatchStateImplCopyWith<$Res> {
  __$$MatchStateImplCopyWithImpl(
    _$MatchStateImpl _value,
    $Res Function(_$MatchStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minute = null,
    Object? homeGoals = null,
    Object? awayGoals = null,
    Object? homeLineup = null,
    Object? awayLineup = null,
    Object? homeBench = null,
    Object? awayBench = null,
    Object? homeTactics = null,
    Object? awayTactics = null,
    Object? yellowCardCounts = null,
    Object? sentOffPlayerIds = null,
    Object? injuriesThisMatch = null,
    Object? momentum = null,
    Object? moraleModHome = null,
    Object? moraleModAway = null,
    Object? context = null,
    Object? rngSeed = freezed,
  }) {
    return _then(
      _$MatchStateImpl(
        minute: null == minute
            ? _value.minute
            : minute // ignore: cast_nullable_to_non_nullable
                  as int,
        homeGoals: null == homeGoals
            ? _value.homeGoals
            : homeGoals // ignore: cast_nullable_to_non_nullable
                  as int,
        awayGoals: null == awayGoals
            ? _value.awayGoals
            : awayGoals // ignore: cast_nullable_to_non_nullable
                  as int,
        homeLineup: null == homeLineup
            ? _value._homeLineup
            : homeLineup // ignore: cast_nullable_to_non_nullable
                  as List<Player>,
        awayLineup: null == awayLineup
            ? _value._awayLineup
            : awayLineup // ignore: cast_nullable_to_non_nullable
                  as List<Player>,
        homeBench: null == homeBench
            ? _value._homeBench
            : homeBench // ignore: cast_nullable_to_non_nullable
                  as List<Player>,
        awayBench: null == awayBench
            ? _value._awayBench
            : awayBench // ignore: cast_nullable_to_non_nullable
                  as List<Player>,
        homeTactics: null == homeTactics
            ? _value.homeTactics
            : homeTactics // ignore: cast_nullable_to_non_nullable
                  as TacticsSetup,
        awayTactics: null == awayTactics
            ? _value.awayTactics
            : awayTactics // ignore: cast_nullable_to_non_nullable
                  as TacticsSetup,
        yellowCardCounts: null == yellowCardCounts
            ? _value._yellowCardCounts
            : yellowCardCounts // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        sentOffPlayerIds: null == sentOffPlayerIds
            ? _value._sentOffPlayerIds
            : sentOffPlayerIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        injuriesThisMatch: null == injuriesThisMatch
            ? _value._injuriesThisMatch
            : injuriesThisMatch // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        momentum: null == momentum
            ? _value.momentum
            : momentum // ignore: cast_nullable_to_non_nullable
                  as double,
        moraleModHome: null == moraleModHome
            ? _value.moraleModHome
            : moraleModHome // ignore: cast_nullable_to_non_nullable
                  as double,
        moraleModAway: null == moraleModAway
            ? _value.moraleModAway
            : moraleModAway // ignore: cast_nullable_to_non_nullable
                  as double,
        context: null == context
            ? _value.context
            : context // ignore: cast_nullable_to_non_nullable
                  as MatchContext,
        rngSeed: freezed == rngSeed
            ? _value.rngSeed
            : rngSeed // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchStateImpl implements _MatchState {
  const _$MatchStateImpl({
    this.minute = 0,
    this.homeGoals = 0,
    this.awayGoals = 0,
    final List<Player> homeLineup = const [],
    final List<Player> awayLineup = const [],
    final List<Player> homeBench = const [],
    final List<Player> awayBench = const [],
    this.homeTactics = const TacticsSetup(),
    this.awayTactics = const TacticsSetup(),
    final Map<String, int> yellowCardCounts = const {},
    final List<String> sentOffPlayerIds = const [],
    final List<String> injuriesThisMatch = const [],
    this.momentum = 0.0,
    this.moraleModHome = 0.0,
    this.moraleModAway = 0.0,
    this.context = const MatchContext(),
    this.rngSeed,
  }) : _homeLineup = homeLineup,
       _awayLineup = awayLineup,
       _homeBench = homeBench,
       _awayBench = awayBench,
       _yellowCardCounts = yellowCardCounts,
       _sentOffPlayerIds = sentOffPlayerIds,
       _injuriesThisMatch = injuriesThisMatch;

  factory _$MatchStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchStateImplFromJson(json);

  @override
  @JsonKey()
  final int minute;
  @override
  @JsonKey()
  final int homeGoals;
  @override
  @JsonKey()
  final int awayGoals;
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

  final List<Player> _homeBench;
  @override
  @JsonKey()
  List<Player> get homeBench {
    if (_homeBench is EqualUnmodifiableListView) return _homeBench;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_homeBench);
  }

  final List<Player> _awayBench;
  @override
  @JsonKey()
  List<Player> get awayBench {
    if (_awayBench is EqualUnmodifiableListView) return _awayBench;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_awayBench);
  }

  @override
  @JsonKey()
  final TacticsSetup homeTactics;
  @override
  @JsonKey()
  final TacticsSetup awayTactics;
  final Map<String, int> _yellowCardCounts;
  @override
  @JsonKey()
  Map<String, int> get yellowCardCounts {
    if (_yellowCardCounts is EqualUnmodifiableMapView) return _yellowCardCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_yellowCardCounts);
  }

  final List<String> _sentOffPlayerIds;
  @override
  @JsonKey()
  List<String> get sentOffPlayerIds {
    if (_sentOffPlayerIds is EqualUnmodifiableListView)
      return _sentOffPlayerIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sentOffPlayerIds);
  }

  final List<String> _injuriesThisMatch;
  @override
  @JsonKey()
  List<String> get injuriesThisMatch {
    if (_injuriesThisMatch is EqualUnmodifiableListView)
      return _injuriesThisMatch;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_injuriesThisMatch);
  }

  @override
  @JsonKey()
  final double momentum;
  @override
  @JsonKey()
  final double moraleModHome;
  @override
  @JsonKey()
  final double moraleModAway;
  @override
  @JsonKey()
  final MatchContext context;
  @override
  final int? rngSeed;

  @override
  String toString() {
    return 'MatchState(minute: $minute, homeGoals: $homeGoals, awayGoals: $awayGoals, homeLineup: $homeLineup, awayLineup: $awayLineup, homeBench: $homeBench, awayBench: $awayBench, homeTactics: $homeTactics, awayTactics: $awayTactics, yellowCardCounts: $yellowCardCounts, sentOffPlayerIds: $sentOffPlayerIds, injuriesThisMatch: $injuriesThisMatch, momentum: $momentum, moraleModHome: $moraleModHome, moraleModAway: $moraleModAway, context: $context, rngSeed: $rngSeed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchStateImpl &&
            (identical(other.minute, minute) || other.minute == minute) &&
            (identical(other.homeGoals, homeGoals) ||
                other.homeGoals == homeGoals) &&
            (identical(other.awayGoals, awayGoals) ||
                other.awayGoals == awayGoals) &&
            const DeepCollectionEquality().equals(
              other._homeLineup,
              _homeLineup,
            ) &&
            const DeepCollectionEquality().equals(
              other._awayLineup,
              _awayLineup,
            ) &&
            const DeepCollectionEquality().equals(
              other._homeBench,
              _homeBench,
            ) &&
            const DeepCollectionEquality().equals(
              other._awayBench,
              _awayBench,
            ) &&
            (identical(other.homeTactics, homeTactics) ||
                other.homeTactics == homeTactics) &&
            (identical(other.awayTactics, awayTactics) ||
                other.awayTactics == awayTactics) &&
            const DeepCollectionEquality().equals(
              other._yellowCardCounts,
              _yellowCardCounts,
            ) &&
            const DeepCollectionEquality().equals(
              other._sentOffPlayerIds,
              _sentOffPlayerIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._injuriesThisMatch,
              _injuriesThisMatch,
            ) &&
            (identical(other.momentum, momentum) ||
                other.momentum == momentum) &&
            (identical(other.moraleModHome, moraleModHome) ||
                other.moraleModHome == moraleModHome) &&
            (identical(other.moraleModAway, moraleModAway) ||
                other.moraleModAway == moraleModAway) &&
            (identical(other.context, context) || other.context == context) &&
            (identical(other.rngSeed, rngSeed) || other.rngSeed == rngSeed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    minute,
    homeGoals,
    awayGoals,
    const DeepCollectionEquality().hash(_homeLineup),
    const DeepCollectionEquality().hash(_awayLineup),
    const DeepCollectionEquality().hash(_homeBench),
    const DeepCollectionEquality().hash(_awayBench),
    homeTactics,
    awayTactics,
    const DeepCollectionEquality().hash(_yellowCardCounts),
    const DeepCollectionEquality().hash(_sentOffPlayerIds),
    const DeepCollectionEquality().hash(_injuriesThisMatch),
    momentum,
    moraleModHome,
    moraleModAway,
    context,
    rngSeed,
  );

  /// Create a copy of MatchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchStateImplCopyWith<_$MatchStateImpl> get copyWith =>
      __$$MatchStateImplCopyWithImpl<_$MatchStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchStateImplToJson(this);
  }
}

abstract class _MatchState implements MatchState {
  const factory _MatchState({
    final int minute,
    final int homeGoals,
    final int awayGoals,
    final List<Player> homeLineup,
    final List<Player> awayLineup,
    final List<Player> homeBench,
    final List<Player> awayBench,
    final TacticsSetup homeTactics,
    final TacticsSetup awayTactics,
    final Map<String, int> yellowCardCounts,
    final List<String> sentOffPlayerIds,
    final List<String> injuriesThisMatch,
    final double momentum,
    final double moraleModHome,
    final double moraleModAway,
    final MatchContext context,
    final int? rngSeed,
  }) = _$MatchStateImpl;

  factory _MatchState.fromJson(Map<String, dynamic> json) =
      _$MatchStateImpl.fromJson;

  @override
  int get minute;
  @override
  int get homeGoals;
  @override
  int get awayGoals;
  @override
  List<Player> get homeLineup;
  @override
  List<Player> get awayLineup;
  @override
  List<Player> get homeBench;
  @override
  List<Player> get awayBench;
  @override
  TacticsSetup get homeTactics;
  @override
  TacticsSetup get awayTactics;
  @override
  Map<String, int> get yellowCardCounts;
  @override
  List<String> get sentOffPlayerIds;
  @override
  List<String> get injuriesThisMatch;
  @override
  double get momentum;
  @override
  double get moraleModHome;
  @override
  double get moraleModAway;
  @override
  MatchContext get context;
  @override
  int? get rngSeed;

  /// Create a copy of MatchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchStateImplCopyWith<_$MatchStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
