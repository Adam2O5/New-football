// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'league_strength.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TeamStrengthEntry _$TeamStrengthEntryFromJson(Map<String, dynamic> json) {
  return _TeamStrengthEntry.fromJson(json);
}

/// @nodoc
mixin _$TeamStrengthEntry {
  String get teamId => throw _privateConstructorUsedError;

  /// Avg overall of top 15 players (missing slots counted as 50).
  double get teamPower => throw _privateConstructorUsedError;

  /// Position 1–30 in the league power ranking (1 = strongest).
  int get expectedRank => throw _privateConstructorUsedError;

  /// Status tier derived from expectedRank.
  TeamStatus get teamStatus => throw _privateConstructorUsedError;

  /// Serializes this TeamStrengthEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeamStrengthEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamStrengthEntryCopyWith<TeamStrengthEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamStrengthEntryCopyWith<$Res> {
  factory $TeamStrengthEntryCopyWith(
    TeamStrengthEntry value,
    $Res Function(TeamStrengthEntry) then,
  ) = _$TeamStrengthEntryCopyWithImpl<$Res, TeamStrengthEntry>;
  @useResult
  $Res call({
    String teamId,
    double teamPower,
    int expectedRank,
    TeamStatus teamStatus,
  });
}

/// @nodoc
class _$TeamStrengthEntryCopyWithImpl<$Res, $Val extends TeamStrengthEntry>
    implements $TeamStrengthEntryCopyWith<$Res> {
  _$TeamStrengthEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeamStrengthEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teamId = null,
    Object? teamPower = null,
    Object? expectedRank = null,
    Object? teamStatus = null,
  }) {
    return _then(
      _value.copyWith(
            teamId: null == teamId
                ? _value.teamId
                : teamId // ignore: cast_nullable_to_non_nullable
                      as String,
            teamPower: null == teamPower
                ? _value.teamPower
                : teamPower // ignore: cast_nullable_to_non_nullable
                      as double,
            expectedRank: null == expectedRank
                ? _value.expectedRank
                : expectedRank // ignore: cast_nullable_to_non_nullable
                      as int,
            teamStatus: null == teamStatus
                ? _value.teamStatus
                : teamStatus // ignore: cast_nullable_to_non_nullable
                      as TeamStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeamStrengthEntryImplCopyWith<$Res>
    implements $TeamStrengthEntryCopyWith<$Res> {
  factory _$$TeamStrengthEntryImplCopyWith(
    _$TeamStrengthEntryImpl value,
    $Res Function(_$TeamStrengthEntryImpl) then,
  ) = __$$TeamStrengthEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String teamId,
    double teamPower,
    int expectedRank,
    TeamStatus teamStatus,
  });
}

/// @nodoc
class __$$TeamStrengthEntryImplCopyWithImpl<$Res>
    extends _$TeamStrengthEntryCopyWithImpl<$Res, _$TeamStrengthEntryImpl>
    implements _$$TeamStrengthEntryImplCopyWith<$Res> {
  __$$TeamStrengthEntryImplCopyWithImpl(
    _$TeamStrengthEntryImpl _value,
    $Res Function(_$TeamStrengthEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeamStrengthEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teamId = null,
    Object? teamPower = null,
    Object? expectedRank = null,
    Object? teamStatus = null,
  }) {
    return _then(
      _$TeamStrengthEntryImpl(
        teamId: null == teamId
            ? _value.teamId
            : teamId // ignore: cast_nullable_to_non_nullable
                  as String,
        teamPower: null == teamPower
            ? _value.teamPower
            : teamPower // ignore: cast_nullable_to_non_nullable
                  as double,
        expectedRank: null == expectedRank
            ? _value.expectedRank
            : expectedRank // ignore: cast_nullable_to_non_nullable
                  as int,
        teamStatus: null == teamStatus
            ? _value.teamStatus
            : teamStatus // ignore: cast_nullable_to_non_nullable
                  as TeamStatus,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamStrengthEntryImpl implements _TeamStrengthEntry {
  const _$TeamStrengthEntryImpl({
    required this.teamId,
    required this.teamPower,
    required this.expectedRank,
    required this.teamStatus,
  });

  factory _$TeamStrengthEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamStrengthEntryImplFromJson(json);

  @override
  final String teamId;

  /// Avg overall of top 15 players (missing slots counted as 50).
  @override
  final double teamPower;

  /// Position 1–30 in the league power ranking (1 = strongest).
  @override
  final int expectedRank;

  /// Status tier derived from expectedRank.
  @override
  final TeamStatus teamStatus;

  @override
  String toString() {
    return 'TeamStrengthEntry(teamId: $teamId, teamPower: $teamPower, expectedRank: $expectedRank, teamStatus: $teamStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamStrengthEntryImpl &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.teamPower, teamPower) ||
                other.teamPower == teamPower) &&
            (identical(other.expectedRank, expectedRank) ||
                other.expectedRank == expectedRank) &&
            (identical(other.teamStatus, teamStatus) ||
                other.teamStatus == teamStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, teamId, teamPower, expectedRank, teamStatus);

  /// Create a copy of TeamStrengthEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamStrengthEntryImplCopyWith<_$TeamStrengthEntryImpl> get copyWith =>
      __$$TeamStrengthEntryImplCopyWithImpl<_$TeamStrengthEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamStrengthEntryImplToJson(this);
  }
}

abstract class _TeamStrengthEntry implements TeamStrengthEntry {
  const factory _TeamStrengthEntry({
    required final String teamId,
    required final double teamPower,
    required final int expectedRank,
    required final TeamStatus teamStatus,
  }) = _$TeamStrengthEntryImpl;

  factory _TeamStrengthEntry.fromJson(Map<String, dynamic> json) =
      _$TeamStrengthEntryImpl.fromJson;

  @override
  String get teamId;

  /// Avg overall of top 15 players (missing slots counted as 50).
  @override
  double get teamPower;

  /// Position 1–30 in the league power ranking (1 = strongest).
  @override
  int get expectedRank;

  /// Status tier derived from expectedRank.
  @override
  TeamStatus get teamStatus;

  /// Create a copy of TeamStrengthEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamStrengthEntryImplCopyWith<_$TeamStrengthEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeagueStrengthTable _$LeagueStrengthTableFromJson(Map<String, dynamic> json) {
  return _LeagueStrengthTable.fromJson(json);
}

/// @nodoc
mixin _$LeagueStrengthTable {
  /// Sorted descending by teamPower (index 0 = rank 1).
  List<TeamStrengthEntry> get entries => throw _privateConstructorUsedError;

  /// Week when this table was last calculated.
  int get lastCalculatedWeek => throw _privateConstructorUsedError;

  /// Day when this table was last calculated.
  int get lastCalculatedDay => throw _privateConstructorUsedError;

  /// Season that owns this snapshot. Zero keeps legacy in-memory fixtures
  /// compatible and is treated as unknown by the recalculation guard.
  int get seasonYear => throw _privateConstructorUsedError;

  /// Serializes this LeagueStrengthTable to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeagueStrengthTable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeagueStrengthTableCopyWith<LeagueStrengthTable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeagueStrengthTableCopyWith<$Res> {
  factory $LeagueStrengthTableCopyWith(
    LeagueStrengthTable value,
    $Res Function(LeagueStrengthTable) then,
  ) = _$LeagueStrengthTableCopyWithImpl<$Res, LeagueStrengthTable>;
  @useResult
  $Res call({
    List<TeamStrengthEntry> entries,
    int lastCalculatedWeek,
    int lastCalculatedDay,
    int seasonYear,
  });
}

/// @nodoc
class _$LeagueStrengthTableCopyWithImpl<$Res, $Val extends LeagueStrengthTable>
    implements $LeagueStrengthTableCopyWith<$Res> {
  _$LeagueStrengthTableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeagueStrengthTable
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entries = null,
    Object? lastCalculatedWeek = null,
    Object? lastCalculatedDay = null,
    Object? seasonYear = null,
  }) {
    return _then(
      _value.copyWith(
            entries: null == entries
                ? _value.entries
                : entries // ignore: cast_nullable_to_non_nullable
                      as List<TeamStrengthEntry>,
            lastCalculatedWeek: null == lastCalculatedWeek
                ? _value.lastCalculatedWeek
                : lastCalculatedWeek // ignore: cast_nullable_to_non_nullable
                      as int,
            lastCalculatedDay: null == lastCalculatedDay
                ? _value.lastCalculatedDay
                : lastCalculatedDay // ignore: cast_nullable_to_non_nullable
                      as int,
            seasonYear: null == seasonYear
                ? _value.seasonYear
                : seasonYear // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeagueStrengthTableImplCopyWith<$Res>
    implements $LeagueStrengthTableCopyWith<$Res> {
  factory _$$LeagueStrengthTableImplCopyWith(
    _$LeagueStrengthTableImpl value,
    $Res Function(_$LeagueStrengthTableImpl) then,
  ) = __$$LeagueStrengthTableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<TeamStrengthEntry> entries,
    int lastCalculatedWeek,
    int lastCalculatedDay,
    int seasonYear,
  });
}

/// @nodoc
class __$$LeagueStrengthTableImplCopyWithImpl<$Res>
    extends _$LeagueStrengthTableCopyWithImpl<$Res, _$LeagueStrengthTableImpl>
    implements _$$LeagueStrengthTableImplCopyWith<$Res> {
  __$$LeagueStrengthTableImplCopyWithImpl(
    _$LeagueStrengthTableImpl _value,
    $Res Function(_$LeagueStrengthTableImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeagueStrengthTable
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entries = null,
    Object? lastCalculatedWeek = null,
    Object? lastCalculatedDay = null,
    Object? seasonYear = null,
  }) {
    return _then(
      _$LeagueStrengthTableImpl(
        entries: null == entries
            ? _value._entries
            : entries // ignore: cast_nullable_to_non_nullable
                  as List<TeamStrengthEntry>,
        lastCalculatedWeek: null == lastCalculatedWeek
            ? _value.lastCalculatedWeek
            : lastCalculatedWeek // ignore: cast_nullable_to_non_nullable
                  as int,
        lastCalculatedDay: null == lastCalculatedDay
            ? _value.lastCalculatedDay
            : lastCalculatedDay // ignore: cast_nullable_to_non_nullable
                  as int,
        seasonYear: null == seasonYear
            ? _value.seasonYear
            : seasonYear // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeagueStrengthTableImpl implements _LeagueStrengthTable {
  const _$LeagueStrengthTableImpl({
    required final List<TeamStrengthEntry> entries,
    required this.lastCalculatedWeek,
    this.lastCalculatedDay = 1,
    this.seasonYear = 0,
  }) : _entries = entries;

  factory _$LeagueStrengthTableImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeagueStrengthTableImplFromJson(json);

  /// Sorted descending by teamPower (index 0 = rank 1).
  final List<TeamStrengthEntry> _entries;

  /// Sorted descending by teamPower (index 0 = rank 1).
  @override
  List<TeamStrengthEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  /// Week when this table was last calculated.
  @override
  final int lastCalculatedWeek;

  /// Day when this table was last calculated.
  @override
  @JsonKey()
  final int lastCalculatedDay;

  /// Season that owns this snapshot. Zero keeps legacy in-memory fixtures
  /// compatible and is treated as unknown by the recalculation guard.
  @override
  @JsonKey()
  final int seasonYear;

  @override
  String toString() {
    return 'LeagueStrengthTable(entries: $entries, lastCalculatedWeek: $lastCalculatedWeek, lastCalculatedDay: $lastCalculatedDay, seasonYear: $seasonYear)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeagueStrengthTableImpl &&
            const DeepCollectionEquality().equals(other._entries, _entries) &&
            (identical(other.lastCalculatedWeek, lastCalculatedWeek) ||
                other.lastCalculatedWeek == lastCalculatedWeek) &&
            (identical(other.lastCalculatedDay, lastCalculatedDay) ||
                other.lastCalculatedDay == lastCalculatedDay) &&
            (identical(other.seasonYear, seasonYear) ||
                other.seasonYear == seasonYear));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_entries),
    lastCalculatedWeek,
    lastCalculatedDay,
    seasonYear,
  );

  /// Create a copy of LeagueStrengthTable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeagueStrengthTableImplCopyWith<_$LeagueStrengthTableImpl> get copyWith =>
      __$$LeagueStrengthTableImplCopyWithImpl<_$LeagueStrengthTableImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LeagueStrengthTableImplToJson(this);
  }
}

abstract class _LeagueStrengthTable implements LeagueStrengthTable {
  const factory _LeagueStrengthTable({
    required final List<TeamStrengthEntry> entries,
    required final int lastCalculatedWeek,
    final int lastCalculatedDay,
    final int seasonYear,
  }) = _$LeagueStrengthTableImpl;

  factory _LeagueStrengthTable.fromJson(Map<String, dynamic> json) =
      _$LeagueStrengthTableImpl.fromJson;

  /// Sorted descending by teamPower (index 0 = rank 1).
  @override
  List<TeamStrengthEntry> get entries;

  /// Week when this table was last calculated.
  @override
  int get lastCalculatedWeek;

  /// Day when this table was last calculated.
  @override
  int get lastCalculatedDay;

  /// Season that owns this snapshot. Zero keeps legacy in-memory fixtures
  /// compatible and is treated as unknown by the recalculation guard.
  @override
  int get seasonYear;

  /// Create a copy of LeagueStrengthTable
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeagueStrengthTableImplCopyWith<_$LeagueStrengthTableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
