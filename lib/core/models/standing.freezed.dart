// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'standing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Standing _$StandingFromJson(Map<String, dynamic> json) {
  return _Standing.fromJson(json);
}

/// @nodoc
mixin _$Standing {
  String get teamId => throw _privateConstructorUsedError;
  int get wins => throw _privateConstructorUsedError;
  int get losses => throw _privateConstructorUsedError;
  int get draws => throw _privateConstructorUsedError;
  int get goalsFor => throw _privateConstructorUsedError;
  int get goalsAgainst => throw _privateConstructorUsedError;
  int get conferenceRank => throw _privateConstructorUsedError;

  /// Serializes this Standing to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Standing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StandingCopyWith<Standing> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StandingCopyWith<$Res> {
  factory $StandingCopyWith(Standing value, $Res Function(Standing) then) =
      _$StandingCopyWithImpl<$Res, Standing>;
  @useResult
  $Res call({
    String teamId,
    int wins,
    int losses,
    int draws,
    int goalsFor,
    int goalsAgainst,
    int conferenceRank,
  });
}

/// @nodoc
class _$StandingCopyWithImpl<$Res, $Val extends Standing>
    implements $StandingCopyWith<$Res> {
  _$StandingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Standing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teamId = null,
    Object? wins = null,
    Object? losses = null,
    Object? draws = null,
    Object? goalsFor = null,
    Object? goalsAgainst = null,
    Object? conferenceRank = null,
  }) {
    return _then(
      _value.copyWith(
            teamId: null == teamId
                ? _value.teamId
                : teamId // ignore: cast_nullable_to_non_nullable
                      as String,
            wins: null == wins
                ? _value.wins
                : wins // ignore: cast_nullable_to_non_nullable
                      as int,
            losses: null == losses
                ? _value.losses
                : losses // ignore: cast_nullable_to_non_nullable
                      as int,
            draws: null == draws
                ? _value.draws
                : draws // ignore: cast_nullable_to_non_nullable
                      as int,
            goalsFor: null == goalsFor
                ? _value.goalsFor
                : goalsFor // ignore: cast_nullable_to_non_nullable
                      as int,
            goalsAgainst: null == goalsAgainst
                ? _value.goalsAgainst
                : goalsAgainst // ignore: cast_nullable_to_non_nullable
                      as int,
            conferenceRank: null == conferenceRank
                ? _value.conferenceRank
                : conferenceRank // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StandingImplCopyWith<$Res>
    implements $StandingCopyWith<$Res> {
  factory _$$StandingImplCopyWith(
    _$StandingImpl value,
    $Res Function(_$StandingImpl) then,
  ) = __$$StandingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String teamId,
    int wins,
    int losses,
    int draws,
    int goalsFor,
    int goalsAgainst,
    int conferenceRank,
  });
}

/// @nodoc
class __$$StandingImplCopyWithImpl<$Res>
    extends _$StandingCopyWithImpl<$Res, _$StandingImpl>
    implements _$$StandingImplCopyWith<$Res> {
  __$$StandingImplCopyWithImpl(
    _$StandingImpl _value,
    $Res Function(_$StandingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Standing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teamId = null,
    Object? wins = null,
    Object? losses = null,
    Object? draws = null,
    Object? goalsFor = null,
    Object? goalsAgainst = null,
    Object? conferenceRank = null,
  }) {
    return _then(
      _$StandingImpl(
        teamId: null == teamId
            ? _value.teamId
            : teamId // ignore: cast_nullable_to_non_nullable
                  as String,
        wins: null == wins
            ? _value.wins
            : wins // ignore: cast_nullable_to_non_nullable
                  as int,
        losses: null == losses
            ? _value.losses
            : losses // ignore: cast_nullable_to_non_nullable
                  as int,
        draws: null == draws
            ? _value.draws
            : draws // ignore: cast_nullable_to_non_nullable
                  as int,
        goalsFor: null == goalsFor
            ? _value.goalsFor
            : goalsFor // ignore: cast_nullable_to_non_nullable
                  as int,
        goalsAgainst: null == goalsAgainst
            ? _value.goalsAgainst
            : goalsAgainst // ignore: cast_nullable_to_non_nullable
                  as int,
        conferenceRank: null == conferenceRank
            ? _value.conferenceRank
            : conferenceRank // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StandingImpl implements _Standing {
  const _$StandingImpl({
    required this.teamId,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
    this.conferenceRank = 0,
  });

  factory _$StandingImpl.fromJson(Map<String, dynamic> json) =>
      _$$StandingImplFromJson(json);

  @override
  final String teamId;
  @override
  @JsonKey()
  final int wins;
  @override
  @JsonKey()
  final int losses;
  @override
  @JsonKey()
  final int draws;
  @override
  @JsonKey()
  final int goalsFor;
  @override
  @JsonKey()
  final int goalsAgainst;
  @override
  @JsonKey()
  final int conferenceRank;

  @override
  String toString() {
    return 'Standing(teamId: $teamId, wins: $wins, losses: $losses, draws: $draws, goalsFor: $goalsFor, goalsAgainst: $goalsAgainst, conferenceRank: $conferenceRank)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StandingImpl &&
            (identical(other.teamId, teamId) || other.teamId == teamId) &&
            (identical(other.wins, wins) || other.wins == wins) &&
            (identical(other.losses, losses) || other.losses == losses) &&
            (identical(other.draws, draws) || other.draws == draws) &&
            (identical(other.goalsFor, goalsFor) ||
                other.goalsFor == goalsFor) &&
            (identical(other.goalsAgainst, goalsAgainst) ||
                other.goalsAgainst == goalsAgainst) &&
            (identical(other.conferenceRank, conferenceRank) ||
                other.conferenceRank == conferenceRank));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    teamId,
    wins,
    losses,
    draws,
    goalsFor,
    goalsAgainst,
    conferenceRank,
  );

  /// Create a copy of Standing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StandingImplCopyWith<_$StandingImpl> get copyWith =>
      __$$StandingImplCopyWithImpl<_$StandingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StandingImplToJson(this);
  }
}

abstract class _Standing implements Standing {
  const factory _Standing({
    required final String teamId,
    final int wins,
    final int losses,
    final int draws,
    final int goalsFor,
    final int goalsAgainst,
    final int conferenceRank,
  }) = _$StandingImpl;

  factory _Standing.fromJson(Map<String, dynamic> json) =
      _$StandingImpl.fromJson;

  @override
  String get teamId;
  @override
  int get wins;
  @override
  int get losses;
  @override
  int get draws;
  @override
  int get goalsFor;
  @override
  int get goalsAgainst;
  @override
  int get conferenceRank;

  /// Create a copy of Standing
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StandingImplCopyWith<_$StandingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConferenceStandings _$ConferenceStandingsFromJson(Map<String, dynamic> json) {
  return _ConferenceStandings.fromJson(json);
}

/// @nodoc
mixin _$ConferenceStandings {
  Conference get conference => throw _privateConstructorUsedError;
  List<Standing> get standings => throw _privateConstructorUsedError;

  /// Serializes this ConferenceStandings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConferenceStandings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConferenceStandingsCopyWith<ConferenceStandings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConferenceStandingsCopyWith<$Res> {
  factory $ConferenceStandingsCopyWith(
    ConferenceStandings value,
    $Res Function(ConferenceStandings) then,
  ) = _$ConferenceStandingsCopyWithImpl<$Res, ConferenceStandings>;
  @useResult
  $Res call({Conference conference, List<Standing> standings});
}

/// @nodoc
class _$ConferenceStandingsCopyWithImpl<$Res, $Val extends ConferenceStandings>
    implements $ConferenceStandingsCopyWith<$Res> {
  _$ConferenceStandingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConferenceStandings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? conference = null, Object? standings = null}) {
    return _then(
      _value.copyWith(
            conference: null == conference
                ? _value.conference
                : conference // ignore: cast_nullable_to_non_nullable
                      as Conference,
            standings: null == standings
                ? _value.standings
                : standings // ignore: cast_nullable_to_non_nullable
                      as List<Standing>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConferenceStandingsImplCopyWith<$Res>
    implements $ConferenceStandingsCopyWith<$Res> {
  factory _$$ConferenceStandingsImplCopyWith(
    _$ConferenceStandingsImpl value,
    $Res Function(_$ConferenceStandingsImpl) then,
  ) = __$$ConferenceStandingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Conference conference, List<Standing> standings});
}

/// @nodoc
class __$$ConferenceStandingsImplCopyWithImpl<$Res>
    extends _$ConferenceStandingsCopyWithImpl<$Res, _$ConferenceStandingsImpl>
    implements _$$ConferenceStandingsImplCopyWith<$Res> {
  __$$ConferenceStandingsImplCopyWithImpl(
    _$ConferenceStandingsImpl _value,
    $Res Function(_$ConferenceStandingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConferenceStandings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? conference = null, Object? standings = null}) {
    return _then(
      _$ConferenceStandingsImpl(
        conference: null == conference
            ? _value.conference
            : conference // ignore: cast_nullable_to_non_nullable
                  as Conference,
        standings: null == standings
            ? _value._standings
            : standings // ignore: cast_nullable_to_non_nullable
                  as List<Standing>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConferenceStandingsImpl implements _ConferenceStandings {
  const _$ConferenceStandingsImpl({
    required this.conference,
    final List<Standing> standings = const [],
  }) : _standings = standings;

  factory _$ConferenceStandingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConferenceStandingsImplFromJson(json);

  @override
  final Conference conference;
  final List<Standing> _standings;
  @override
  @JsonKey()
  List<Standing> get standings {
    if (_standings is EqualUnmodifiableListView) return _standings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_standings);
  }

  @override
  String toString() {
    return 'ConferenceStandings(conference: $conference, standings: $standings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConferenceStandingsImpl &&
            (identical(other.conference, conference) ||
                other.conference == conference) &&
            const DeepCollectionEquality().equals(
              other._standings,
              _standings,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    conference,
    const DeepCollectionEquality().hash(_standings),
  );

  /// Create a copy of ConferenceStandings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConferenceStandingsImplCopyWith<_$ConferenceStandingsImpl> get copyWith =>
      __$$ConferenceStandingsImplCopyWithImpl<_$ConferenceStandingsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConferenceStandingsImplToJson(this);
  }
}

abstract class _ConferenceStandings implements ConferenceStandings {
  const factory _ConferenceStandings({
    required final Conference conference,
    final List<Standing> standings,
  }) = _$ConferenceStandingsImpl;

  factory _ConferenceStandings.fromJson(Map<String, dynamic> json) =
      _$ConferenceStandingsImpl.fromJson;

  @override
  Conference get conference;
  @override
  List<Standing> get standings;

  /// Create a copy of ConferenceStandings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConferenceStandingsImplCopyWith<_$ConferenceStandingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
