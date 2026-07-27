// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'league_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LeagueState _$LeagueStateFromJson(Map<String, dynamic> json) {
  return _LeagueState.fromJson(json);
}

/// @nodoc
mixin _$LeagueState {
  List<Team> get teams => throw _privateConstructorUsedError;
  Season get currentSeason => throw _privateConstructorUsedError;
  List<SeasonHistory> get history => throw _privateConstructorUsedError;
  Difficulty get difficulty => throw _privateConstructorUsedError;
  String? get playerTeamId => throw _privateConstructorUsedError;
  int get currentRound => throw _privateConstructorUsedError;
  int get currentWeek => throw _privateConstructorUsedError;

  /// 1 = Monday … 7 = Sunday within [currentWeek].
  int get currentDay => throw _privateConstructorUsedError;
  Inbox get inbox => throw _privateConstructorUsedError;
  MessageSettings get messageSettings => throw _privateConstructorUsedError;

  /// Sztab bez klubu — pula dostępna do zatrudnienia (`docs/staff_rules.md`).
  List<StaffMember> get staffFreeAgents => throw _privateConstructorUsedError;

  /// Zawodnicy bez klubu — niedraftowani + wygasłe kontrakty
  /// (`docs/contract_signing.md`, `docs/offseason.md`).
  List<Player> get freeAgents => throw _privateConstructorUsedError;

  /// Serializes this LeagueState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeagueState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeagueStateCopyWith<LeagueState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeagueStateCopyWith<$Res> {
  factory $LeagueStateCopyWith(
    LeagueState value,
    $Res Function(LeagueState) then,
  ) = _$LeagueStateCopyWithImpl<$Res, LeagueState>;
  @useResult
  $Res call({
    List<Team> teams,
    Season currentSeason,
    List<SeasonHistory> history,
    Difficulty difficulty,
    String? playerTeamId,
    int currentRound,
    int currentWeek,
    int currentDay,
    Inbox inbox,
    MessageSettings messageSettings,
    List<StaffMember> staffFreeAgents,
    List<Player> freeAgents,
  });

  $SeasonCopyWith<$Res> get currentSeason;
  $InboxCopyWith<$Res> get inbox;
  $MessageSettingsCopyWith<$Res> get messageSettings;
}

/// @nodoc
class _$LeagueStateCopyWithImpl<$Res, $Val extends LeagueState>
    implements $LeagueStateCopyWith<$Res> {
  _$LeagueStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeagueState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teams = null,
    Object? currentSeason = null,
    Object? history = null,
    Object? difficulty = null,
    Object? playerTeamId = freezed,
    Object? currentRound = null,
    Object? currentWeek = null,
    Object? currentDay = null,
    Object? inbox = null,
    Object? messageSettings = null,
    Object? staffFreeAgents = null,
    Object? freeAgents = null,
  }) {
    return _then(
      _value.copyWith(
            teams: null == teams
                ? _value.teams
                : teams // ignore: cast_nullable_to_non_nullable
                      as List<Team>,
            currentSeason: null == currentSeason
                ? _value.currentSeason
                : currentSeason // ignore: cast_nullable_to_non_nullable
                      as Season,
            history: null == history
                ? _value.history
                : history // ignore: cast_nullable_to_non_nullable
                      as List<SeasonHistory>,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as Difficulty,
            playerTeamId: freezed == playerTeamId
                ? _value.playerTeamId
                : playerTeamId // ignore: cast_nullable_to_non_nullable
                      as String?,
            currentRound: null == currentRound
                ? _value.currentRound
                : currentRound // ignore: cast_nullable_to_non_nullable
                      as int,
            currentWeek: null == currentWeek
                ? _value.currentWeek
                : currentWeek // ignore: cast_nullable_to_non_nullable
                      as int,
            currentDay: null == currentDay
                ? _value.currentDay
                : currentDay // ignore: cast_nullable_to_non_nullable
                      as int,
            inbox: null == inbox
                ? _value.inbox
                : inbox // ignore: cast_nullable_to_non_nullable
                      as Inbox,
            messageSettings: null == messageSettings
                ? _value.messageSettings
                : messageSettings // ignore: cast_nullable_to_non_nullable
                      as MessageSettings,
            staffFreeAgents: null == staffFreeAgents
                ? _value.staffFreeAgents
                : staffFreeAgents // ignore: cast_nullable_to_non_nullable
                      as List<StaffMember>,
            freeAgents: null == freeAgents
                ? _value.freeAgents
                : freeAgents // ignore: cast_nullable_to_non_nullable
                      as List<Player>,
          )
          as $Val,
    );
  }

  /// Create a copy of LeagueState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SeasonCopyWith<$Res> get currentSeason {
    return $SeasonCopyWith<$Res>(_value.currentSeason, (value) {
      return _then(_value.copyWith(currentSeason: value) as $Val);
    });
  }

  /// Create a copy of LeagueState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InboxCopyWith<$Res> get inbox {
    return $InboxCopyWith<$Res>(_value.inbox, (value) {
      return _then(_value.copyWith(inbox: value) as $Val);
    });
  }

  /// Create a copy of LeagueState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MessageSettingsCopyWith<$Res> get messageSettings {
    return $MessageSettingsCopyWith<$Res>(_value.messageSettings, (value) {
      return _then(_value.copyWith(messageSettings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LeagueStateImplCopyWith<$Res>
    implements $LeagueStateCopyWith<$Res> {
  factory _$$LeagueStateImplCopyWith(
    _$LeagueStateImpl value,
    $Res Function(_$LeagueStateImpl) then,
  ) = __$$LeagueStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Team> teams,
    Season currentSeason,
    List<SeasonHistory> history,
    Difficulty difficulty,
    String? playerTeamId,
    int currentRound,
    int currentWeek,
    int currentDay,
    Inbox inbox,
    MessageSettings messageSettings,
    List<StaffMember> staffFreeAgents,
    List<Player> freeAgents,
  });

  @override
  $SeasonCopyWith<$Res> get currentSeason;
  @override
  $InboxCopyWith<$Res> get inbox;
  @override
  $MessageSettingsCopyWith<$Res> get messageSettings;
}

/// @nodoc
class __$$LeagueStateImplCopyWithImpl<$Res>
    extends _$LeagueStateCopyWithImpl<$Res, _$LeagueStateImpl>
    implements _$$LeagueStateImplCopyWith<$Res> {
  __$$LeagueStateImplCopyWithImpl(
    _$LeagueStateImpl _value,
    $Res Function(_$LeagueStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeagueState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teams = null,
    Object? currentSeason = null,
    Object? history = null,
    Object? difficulty = null,
    Object? playerTeamId = freezed,
    Object? currentRound = null,
    Object? currentWeek = null,
    Object? currentDay = null,
    Object? inbox = null,
    Object? messageSettings = null,
    Object? staffFreeAgents = null,
    Object? freeAgents = null,
  }) {
    return _then(
      _$LeagueStateImpl(
        teams: null == teams
            ? _value._teams
            : teams // ignore: cast_nullable_to_non_nullable
                  as List<Team>,
        currentSeason: null == currentSeason
            ? _value.currentSeason
            : currentSeason // ignore: cast_nullable_to_non_nullable
                  as Season,
        history: null == history
            ? _value._history
            : history // ignore: cast_nullable_to_non_nullable
                  as List<SeasonHistory>,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as Difficulty,
        playerTeamId: freezed == playerTeamId
            ? _value.playerTeamId
            : playerTeamId // ignore: cast_nullable_to_non_nullable
                  as String?,
        currentRound: null == currentRound
            ? _value.currentRound
            : currentRound // ignore: cast_nullable_to_non_nullable
                  as int,
        currentWeek: null == currentWeek
            ? _value.currentWeek
            : currentWeek // ignore: cast_nullable_to_non_nullable
                  as int,
        currentDay: null == currentDay
            ? _value.currentDay
            : currentDay // ignore: cast_nullable_to_non_nullable
                  as int,
        inbox: null == inbox
            ? _value.inbox
            : inbox // ignore: cast_nullable_to_non_nullable
                  as Inbox,
        messageSettings: null == messageSettings
            ? _value.messageSettings
            : messageSettings // ignore: cast_nullable_to_non_nullable
                  as MessageSettings,
        staffFreeAgents: null == staffFreeAgents
            ? _value._staffFreeAgents
            : staffFreeAgents // ignore: cast_nullable_to_non_nullable
                  as List<StaffMember>,
        freeAgents: null == freeAgents
            ? _value._freeAgents
            : freeAgents // ignore: cast_nullable_to_non_nullable
                  as List<Player>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeagueStateImpl implements _LeagueState {
  const _$LeagueStateImpl({
    required final List<Team> teams,
    required this.currentSeason,
    final List<SeasonHistory> history = const [],
    this.difficulty = Difficulty.normal,
    this.playerTeamId,
    this.currentRound = 0,
    this.currentWeek = 1,
    this.currentDay = 1,
    this.inbox = const Inbox(),
    this.messageSettings = const MessageSettings(),
    final List<StaffMember> staffFreeAgents = const [],
    final List<Player> freeAgents = const [],
  }) : _teams = teams,
       _history = history,
       _staffFreeAgents = staffFreeAgents,
       _freeAgents = freeAgents;

  factory _$LeagueStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeagueStateImplFromJson(json);

  final List<Team> _teams;
  @override
  List<Team> get teams {
    if (_teams is EqualUnmodifiableListView) return _teams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_teams);
  }

  @override
  final Season currentSeason;
  final List<SeasonHistory> _history;
  @override
  @JsonKey()
  List<SeasonHistory> get history {
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_history);
  }

  @override
  @JsonKey()
  final Difficulty difficulty;
  @override
  final String? playerTeamId;
  @override
  @JsonKey()
  final int currentRound;
  @override
  @JsonKey()
  final int currentWeek;

  /// 1 = Monday … 7 = Sunday within [currentWeek].
  @override
  @JsonKey()
  final int currentDay;
  @override
  @JsonKey()
  final Inbox inbox;
  @override
  @JsonKey()
  final MessageSettings messageSettings;

  /// Sztab bez klubu — pula dostępna do zatrudnienia (`docs/staff_rules.md`).
  final List<StaffMember> _staffFreeAgents;

  /// Sztab bez klubu — pula dostępna do zatrudnienia (`docs/staff_rules.md`).
  @override
  @JsonKey()
  List<StaffMember> get staffFreeAgents {
    if (_staffFreeAgents is EqualUnmodifiableListView) return _staffFreeAgents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_staffFreeAgents);
  }

  /// Zawodnicy bez klubu — niedraftowani + wygasłe kontrakty
  /// (`docs/contract_signing.md`, `docs/offseason.md`).
  final List<Player> _freeAgents;

  /// Zawodnicy bez klubu — niedraftowani + wygasłe kontrakty
  /// (`docs/contract_signing.md`, `docs/offseason.md`).
  @override
  @JsonKey()
  List<Player> get freeAgents {
    if (_freeAgents is EqualUnmodifiableListView) return _freeAgents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_freeAgents);
  }

  @override
  String toString() {
    return 'LeagueState(teams: $teams, currentSeason: $currentSeason, history: $history, difficulty: $difficulty, playerTeamId: $playerTeamId, currentRound: $currentRound, currentWeek: $currentWeek, currentDay: $currentDay, inbox: $inbox, messageSettings: $messageSettings, staffFreeAgents: $staffFreeAgents, freeAgents: $freeAgents)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeagueStateImpl &&
            const DeepCollectionEquality().equals(other._teams, _teams) &&
            (identical(other.currentSeason, currentSeason) ||
                other.currentSeason == currentSeason) &&
            const DeepCollectionEquality().equals(other._history, _history) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.playerTeamId, playerTeamId) ||
                other.playerTeamId == playerTeamId) &&
            (identical(other.currentRound, currentRound) ||
                other.currentRound == currentRound) &&
            (identical(other.currentWeek, currentWeek) ||
                other.currentWeek == currentWeek) &&
            (identical(other.currentDay, currentDay) ||
                other.currentDay == currentDay) &&
            (identical(other.inbox, inbox) || other.inbox == inbox) &&
            (identical(other.messageSettings, messageSettings) ||
                other.messageSettings == messageSettings) &&
            const DeepCollectionEquality().equals(
              other._staffFreeAgents,
              _staffFreeAgents,
            ) &&
            const DeepCollectionEquality().equals(
              other._freeAgents,
              _freeAgents,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_teams),
    currentSeason,
    const DeepCollectionEquality().hash(_history),
    difficulty,
    playerTeamId,
    currentRound,
    currentWeek,
    currentDay,
    inbox,
    messageSettings,
    const DeepCollectionEquality().hash(_staffFreeAgents),
    const DeepCollectionEquality().hash(_freeAgents),
  );

  /// Create a copy of LeagueState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeagueStateImplCopyWith<_$LeagueStateImpl> get copyWith =>
      __$$LeagueStateImplCopyWithImpl<_$LeagueStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeagueStateImplToJson(this);
  }
}

abstract class _LeagueState implements LeagueState {
  const factory _LeagueState({
    required final List<Team> teams,
    required final Season currentSeason,
    final List<SeasonHistory> history,
    final Difficulty difficulty,
    final String? playerTeamId,
    final int currentRound,
    final int currentWeek,
    final int currentDay,
    final Inbox inbox,
    final MessageSettings messageSettings,
    final List<StaffMember> staffFreeAgents,
    final List<Player> freeAgents,
  }) = _$LeagueStateImpl;

  factory _LeagueState.fromJson(Map<String, dynamic> json) =
      _$LeagueStateImpl.fromJson;

  @override
  List<Team> get teams;
  @override
  Season get currentSeason;
  @override
  List<SeasonHistory> get history;
  @override
  Difficulty get difficulty;
  @override
  String? get playerTeamId;
  @override
  int get currentRound;
  @override
  int get currentWeek;

  /// 1 = Monday … 7 = Sunday within [currentWeek].
  @override
  int get currentDay;
  @override
  Inbox get inbox;
  @override
  MessageSettings get messageSettings;

  /// Sztab bez klubu — pula dostępna do zatrudnienia (`docs/staff_rules.md`).
  @override
  List<StaffMember> get staffFreeAgents;

  /// Zawodnicy bez klubu — niedraftowani + wygasłe kontrakty
  /// (`docs/contract_signing.md`, `docs/offseason.md`).
  @override
  List<Player> get freeAgents;

  /// Create a copy of LeagueState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeagueStateImplCopyWith<_$LeagueStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
