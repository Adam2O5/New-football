// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'season.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Season {

 int get year; SeasonPhase get phase; List<ScheduledMatch> get schedule; List<ConferenceStandings> get standings; List<PlayInResult> get playInResults; List<PlayInProgress> get playInProgress; List<PlayoffBracket> get playoffBrackets; String? get championTeamId; bool get championshipAtmosphereApplied; bool get playoffMissAtmosphereApplied; DraftState? get draftState; SeasonAwards? get awards; bool get staffGrowthDone; bool get playerRetirementsDone;/// Persisted TV agreement: the exact reset year and increase are known
/// before the event fires, so loading a save cannot reroll the cap.
 int get nextTvCapResetSeason; int get nextTvCapIncreasePct; bool get capUpdateTvDone; bool get combineDone; bool get finalMockDone; bool get faOpenDone; bool get scoutReportDone; bool get tradeDeadlineAcked; bool get nextClassGenerationDone;/// Play-in/playoff fixtures, populated eagerly as soon as each pairing
/// is known (see `game_calendar.md`) — placeholders for a still-pending
/// play-in seed, replaced with the real team once decided. This is the
/// calendar's sole source for postseason match days, the same way
/// `schedule` is for the regular season. `playInProgress`/`playInResults`
/// /`playoffBrackets` remain the simulation source of truth; entries here
/// are kept in lockstep with them but exist purely for display.
 List<ScheduledMatch> get postseasonFixtures;
/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeasonCopyWith<Season> get copyWith => _$SeasonCopyWithImpl<Season>(this as Season, _$identity);

  /// Serializes this Season to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Season&&(identical(other.year, year) || other.year == year)&&(identical(other.phase, phase) || other.phase == phase)&&const DeepCollectionEquality().equals(other.schedule, schedule)&&const DeepCollectionEquality().equals(other.standings, standings)&&const DeepCollectionEquality().equals(other.playInResults, playInResults)&&const DeepCollectionEquality().equals(other.playInProgress, playInProgress)&&const DeepCollectionEquality().equals(other.playoffBrackets, playoffBrackets)&&(identical(other.championTeamId, championTeamId) || other.championTeamId == championTeamId)&&(identical(other.championshipAtmosphereApplied, championshipAtmosphereApplied) || other.championshipAtmosphereApplied == championshipAtmosphereApplied)&&(identical(other.playoffMissAtmosphereApplied, playoffMissAtmosphereApplied) || other.playoffMissAtmosphereApplied == playoffMissAtmosphereApplied)&&(identical(other.draftState, draftState) || other.draftState == draftState)&&(identical(other.awards, awards) || other.awards == awards)&&(identical(other.staffGrowthDone, staffGrowthDone) || other.staffGrowthDone == staffGrowthDone)&&(identical(other.playerRetirementsDone, playerRetirementsDone) || other.playerRetirementsDone == playerRetirementsDone)&&(identical(other.nextTvCapResetSeason, nextTvCapResetSeason) || other.nextTvCapResetSeason == nextTvCapResetSeason)&&(identical(other.nextTvCapIncreasePct, nextTvCapIncreasePct) || other.nextTvCapIncreasePct == nextTvCapIncreasePct)&&(identical(other.capUpdateTvDone, capUpdateTvDone) || other.capUpdateTvDone == capUpdateTvDone)&&(identical(other.combineDone, combineDone) || other.combineDone == combineDone)&&(identical(other.finalMockDone, finalMockDone) || other.finalMockDone == finalMockDone)&&(identical(other.faOpenDone, faOpenDone) || other.faOpenDone == faOpenDone)&&(identical(other.scoutReportDone, scoutReportDone) || other.scoutReportDone == scoutReportDone)&&(identical(other.tradeDeadlineAcked, tradeDeadlineAcked) || other.tradeDeadlineAcked == tradeDeadlineAcked)&&(identical(other.nextClassGenerationDone, nextClassGenerationDone) || other.nextClassGenerationDone == nextClassGenerationDone)&&const DeepCollectionEquality().equals(other.postseasonFixtures, postseasonFixtures));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,year,phase,const DeepCollectionEquality().hash(schedule),const DeepCollectionEquality().hash(standings),const DeepCollectionEquality().hash(playInResults),const DeepCollectionEquality().hash(playInProgress),const DeepCollectionEquality().hash(playoffBrackets),championTeamId,championshipAtmosphereApplied,playoffMissAtmosphereApplied,draftState,awards,staffGrowthDone,playerRetirementsDone,nextTvCapResetSeason,nextTvCapIncreasePct,capUpdateTvDone,combineDone,finalMockDone,faOpenDone,scoutReportDone,tradeDeadlineAcked,nextClassGenerationDone,const DeepCollectionEquality().hash(postseasonFixtures)]);

@override
String toString() {
  return 'Season(year: $year, phase: $phase, schedule: $schedule, standings: $standings, playInResults: $playInResults, playInProgress: $playInProgress, playoffBrackets: $playoffBrackets, championTeamId: $championTeamId, championshipAtmosphereApplied: $championshipAtmosphereApplied, playoffMissAtmosphereApplied: $playoffMissAtmosphereApplied, draftState: $draftState, awards: $awards, staffGrowthDone: $staffGrowthDone, playerRetirementsDone: $playerRetirementsDone, nextTvCapResetSeason: $nextTvCapResetSeason, nextTvCapIncreasePct: $nextTvCapIncreasePct, capUpdateTvDone: $capUpdateTvDone, combineDone: $combineDone, finalMockDone: $finalMockDone, faOpenDone: $faOpenDone, scoutReportDone: $scoutReportDone, tradeDeadlineAcked: $tradeDeadlineAcked, nextClassGenerationDone: $nextClassGenerationDone, postseasonFixtures: $postseasonFixtures)';
}


}

/// @nodoc
abstract mixin class $SeasonCopyWith<$Res>  {
  factory $SeasonCopyWith(Season value, $Res Function(Season) _then) = _$SeasonCopyWithImpl;
@useResult
$Res call({
 int year, SeasonPhase phase, List<ScheduledMatch> schedule, List<ConferenceStandings> standings, List<PlayInResult> playInResults, List<PlayInProgress> playInProgress, List<PlayoffBracket> playoffBrackets, String? championTeamId, bool championshipAtmosphereApplied, bool playoffMissAtmosphereApplied, DraftState? draftState, SeasonAwards? awards, bool staffGrowthDone, bool playerRetirementsDone, int nextTvCapResetSeason, int nextTvCapIncreasePct, bool capUpdateTvDone, bool combineDone, bool finalMockDone, bool faOpenDone, bool scoutReportDone, bool tradeDeadlineAcked, bool nextClassGenerationDone, List<ScheduledMatch> postseasonFixtures
});


$DraftStateCopyWith<$Res>? get draftState;$SeasonAwardsCopyWith<$Res>? get awards;

}
/// @nodoc
class _$SeasonCopyWithImpl<$Res>
    implements $SeasonCopyWith<$Res> {
  _$SeasonCopyWithImpl(this._self, this._then);

  final Season _self;
  final $Res Function(Season) _then;

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? phase = null,Object? schedule = null,Object? standings = null,Object? playInResults = null,Object? playInProgress = null,Object? playoffBrackets = null,Object? championTeamId = freezed,Object? championshipAtmosphereApplied = null,Object? playoffMissAtmosphereApplied = null,Object? draftState = freezed,Object? awards = freezed,Object? staffGrowthDone = null,Object? playerRetirementsDone = null,Object? nextTvCapResetSeason = null,Object? nextTvCapIncreasePct = null,Object? capUpdateTvDone = null,Object? combineDone = null,Object? finalMockDone = null,Object? faOpenDone = null,Object? scoutReportDone = null,Object? tradeDeadlineAcked = null,Object? nextClassGenerationDone = null,Object? postseasonFixtures = null,}) {
  return _then(_self.copyWith(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SeasonPhase,schedule: null == schedule ? _self.schedule : schedule // ignore: cast_nullable_to_non_nullable
as List<ScheduledMatch>,standings: null == standings ? _self.standings : standings // ignore: cast_nullable_to_non_nullable
as List<ConferenceStandings>,playInResults: null == playInResults ? _self.playInResults : playInResults // ignore: cast_nullable_to_non_nullable
as List<PlayInResult>,playInProgress: null == playInProgress ? _self.playInProgress : playInProgress // ignore: cast_nullable_to_non_nullable
as List<PlayInProgress>,playoffBrackets: null == playoffBrackets ? _self.playoffBrackets : playoffBrackets // ignore: cast_nullable_to_non_nullable
as List<PlayoffBracket>,championTeamId: freezed == championTeamId ? _self.championTeamId : championTeamId // ignore: cast_nullable_to_non_nullable
as String?,championshipAtmosphereApplied: null == championshipAtmosphereApplied ? _self.championshipAtmosphereApplied : championshipAtmosphereApplied // ignore: cast_nullable_to_non_nullable
as bool,playoffMissAtmosphereApplied: null == playoffMissAtmosphereApplied ? _self.playoffMissAtmosphereApplied : playoffMissAtmosphereApplied // ignore: cast_nullable_to_non_nullable
as bool,draftState: freezed == draftState ? _self.draftState : draftState // ignore: cast_nullable_to_non_nullable
as DraftState?,awards: freezed == awards ? _self.awards : awards // ignore: cast_nullable_to_non_nullable
as SeasonAwards?,staffGrowthDone: null == staffGrowthDone ? _self.staffGrowthDone : staffGrowthDone // ignore: cast_nullable_to_non_nullable
as bool,playerRetirementsDone: null == playerRetirementsDone ? _self.playerRetirementsDone : playerRetirementsDone // ignore: cast_nullable_to_non_nullable
as bool,nextTvCapResetSeason: null == nextTvCapResetSeason ? _self.nextTvCapResetSeason : nextTvCapResetSeason // ignore: cast_nullable_to_non_nullable
as int,nextTvCapIncreasePct: null == nextTvCapIncreasePct ? _self.nextTvCapIncreasePct : nextTvCapIncreasePct // ignore: cast_nullable_to_non_nullable
as int,capUpdateTvDone: null == capUpdateTvDone ? _self.capUpdateTvDone : capUpdateTvDone // ignore: cast_nullable_to_non_nullable
as bool,combineDone: null == combineDone ? _self.combineDone : combineDone // ignore: cast_nullable_to_non_nullable
as bool,finalMockDone: null == finalMockDone ? _self.finalMockDone : finalMockDone // ignore: cast_nullable_to_non_nullable
as bool,faOpenDone: null == faOpenDone ? _self.faOpenDone : faOpenDone // ignore: cast_nullable_to_non_nullable
as bool,scoutReportDone: null == scoutReportDone ? _self.scoutReportDone : scoutReportDone // ignore: cast_nullable_to_non_nullable
as bool,tradeDeadlineAcked: null == tradeDeadlineAcked ? _self.tradeDeadlineAcked : tradeDeadlineAcked // ignore: cast_nullable_to_non_nullable
as bool,nextClassGenerationDone: null == nextClassGenerationDone ? _self.nextClassGenerationDone : nextClassGenerationDone // ignore: cast_nullable_to_non_nullable
as bool,postseasonFixtures: null == postseasonFixtures ? _self.postseasonFixtures : postseasonFixtures // ignore: cast_nullable_to_non_nullable
as List<ScheduledMatch>,
  ));
}
/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DraftStateCopyWith<$Res>? get draftState {
    if (_self.draftState == null) {
    return null;
  }

  return $DraftStateCopyWith<$Res>(_self.draftState!, (value) {
    return _then(_self.copyWith(draftState: value));
  });
}/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeasonAwardsCopyWith<$Res>? get awards {
    if (_self.awards == null) {
    return null;
  }

  return $SeasonAwardsCopyWith<$Res>(_self.awards!, (value) {
    return _then(_self.copyWith(awards: value));
  });
}
}


/// Adds pattern-matching-related methods to [Season].
extension SeasonPatterns on Season {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Season value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Season value)  $default,){
final _that = this;
switch (_that) {
case _Season():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Season value)?  $default,){
final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  SeasonPhase phase,  List<ScheduledMatch> schedule,  List<ConferenceStandings> standings,  List<PlayInResult> playInResults,  List<PlayInProgress> playInProgress,  List<PlayoffBracket> playoffBrackets,  String? championTeamId,  bool championshipAtmosphereApplied,  bool playoffMissAtmosphereApplied,  DraftState? draftState,  SeasonAwards? awards,  bool staffGrowthDone,  bool playerRetirementsDone,  int nextTvCapResetSeason,  int nextTvCapIncreasePct,  bool capUpdateTvDone,  bool combineDone,  bool finalMockDone,  bool faOpenDone,  bool scoutReportDone,  bool tradeDeadlineAcked,  bool nextClassGenerationDone,  List<ScheduledMatch> postseasonFixtures)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that.year,_that.phase,_that.schedule,_that.standings,_that.playInResults,_that.playInProgress,_that.playoffBrackets,_that.championTeamId,_that.championshipAtmosphereApplied,_that.playoffMissAtmosphereApplied,_that.draftState,_that.awards,_that.staffGrowthDone,_that.playerRetirementsDone,_that.nextTvCapResetSeason,_that.nextTvCapIncreasePct,_that.capUpdateTvDone,_that.combineDone,_that.finalMockDone,_that.faOpenDone,_that.scoutReportDone,_that.tradeDeadlineAcked,_that.nextClassGenerationDone,_that.postseasonFixtures);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  SeasonPhase phase,  List<ScheduledMatch> schedule,  List<ConferenceStandings> standings,  List<PlayInResult> playInResults,  List<PlayInProgress> playInProgress,  List<PlayoffBracket> playoffBrackets,  String? championTeamId,  bool championshipAtmosphereApplied,  bool playoffMissAtmosphereApplied,  DraftState? draftState,  SeasonAwards? awards,  bool staffGrowthDone,  bool playerRetirementsDone,  int nextTvCapResetSeason,  int nextTvCapIncreasePct,  bool capUpdateTvDone,  bool combineDone,  bool finalMockDone,  bool faOpenDone,  bool scoutReportDone,  bool tradeDeadlineAcked,  bool nextClassGenerationDone,  List<ScheduledMatch> postseasonFixtures)  $default,) {final _that = this;
switch (_that) {
case _Season():
return $default(_that.year,_that.phase,_that.schedule,_that.standings,_that.playInResults,_that.playInProgress,_that.playoffBrackets,_that.championTeamId,_that.championshipAtmosphereApplied,_that.playoffMissAtmosphereApplied,_that.draftState,_that.awards,_that.staffGrowthDone,_that.playerRetirementsDone,_that.nextTvCapResetSeason,_that.nextTvCapIncreasePct,_that.capUpdateTvDone,_that.combineDone,_that.finalMockDone,_that.faOpenDone,_that.scoutReportDone,_that.tradeDeadlineAcked,_that.nextClassGenerationDone,_that.postseasonFixtures);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  SeasonPhase phase,  List<ScheduledMatch> schedule,  List<ConferenceStandings> standings,  List<PlayInResult> playInResults,  List<PlayInProgress> playInProgress,  List<PlayoffBracket> playoffBrackets,  String? championTeamId,  bool championshipAtmosphereApplied,  bool playoffMissAtmosphereApplied,  DraftState? draftState,  SeasonAwards? awards,  bool staffGrowthDone,  bool playerRetirementsDone,  int nextTvCapResetSeason,  int nextTvCapIncreasePct,  bool capUpdateTvDone,  bool combineDone,  bool finalMockDone,  bool faOpenDone,  bool scoutReportDone,  bool tradeDeadlineAcked,  bool nextClassGenerationDone,  List<ScheduledMatch> postseasonFixtures)?  $default,) {final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that.year,_that.phase,_that.schedule,_that.standings,_that.playInResults,_that.playInProgress,_that.playoffBrackets,_that.championTeamId,_that.championshipAtmosphereApplied,_that.playoffMissAtmosphereApplied,_that.draftState,_that.awards,_that.staffGrowthDone,_that.playerRetirementsDone,_that.nextTvCapResetSeason,_that.nextTvCapIncreasePct,_that.capUpdateTvDone,_that.combineDone,_that.finalMockDone,_that.faOpenDone,_that.scoutReportDone,_that.tradeDeadlineAcked,_that.nextClassGenerationDone,_that.postseasonFixtures);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Season implements Season {
  const _Season({required this.year, this.phase = SeasonPhase.preseason, final  List<ScheduledMatch> schedule = const [], final  List<ConferenceStandings> standings = const [], final  List<PlayInResult> playInResults = const [], final  List<PlayInProgress> playInProgress = const [], final  List<PlayoffBracket> playoffBrackets = const [], this.championTeamId, this.championshipAtmosphereApplied = false, this.playoffMissAtmosphereApplied = false, this.draftState, this.awards, this.staffGrowthDone = false, this.playerRetirementsDone = false, this.nextTvCapResetSeason = 0, this.nextTvCapIncreasePct = 0, this.capUpdateTvDone = false, this.combineDone = false, this.finalMockDone = false, this.faOpenDone = false, this.scoutReportDone = false, this.tradeDeadlineAcked = false, this.nextClassGenerationDone = false, final  List<ScheduledMatch> postseasonFixtures = const <ScheduledMatch>[]}): _schedule = schedule,_standings = standings,_playInResults = playInResults,_playInProgress = playInProgress,_playoffBrackets = playoffBrackets,_postseasonFixtures = postseasonFixtures;
  factory _Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);

@override final  int year;
@override@JsonKey() final  SeasonPhase phase;
 final  List<ScheduledMatch> _schedule;
@override@JsonKey() List<ScheduledMatch> get schedule {
  if (_schedule is EqualUnmodifiableListView) return _schedule;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_schedule);
}

 final  List<ConferenceStandings> _standings;
@override@JsonKey() List<ConferenceStandings> get standings {
  if (_standings is EqualUnmodifiableListView) return _standings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_standings);
}

 final  List<PlayInResult> _playInResults;
@override@JsonKey() List<PlayInResult> get playInResults {
  if (_playInResults is EqualUnmodifiableListView) return _playInResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playInResults);
}

 final  List<PlayInProgress> _playInProgress;
@override@JsonKey() List<PlayInProgress> get playInProgress {
  if (_playInProgress is EqualUnmodifiableListView) return _playInProgress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playInProgress);
}

 final  List<PlayoffBracket> _playoffBrackets;
@override@JsonKey() List<PlayoffBracket> get playoffBrackets {
  if (_playoffBrackets is EqualUnmodifiableListView) return _playoffBrackets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playoffBrackets);
}

@override final  String? championTeamId;
@override@JsonKey() final  bool championshipAtmosphereApplied;
@override@JsonKey() final  bool playoffMissAtmosphereApplied;
@override final  DraftState? draftState;
@override final  SeasonAwards? awards;
@override@JsonKey() final  bool staffGrowthDone;
@override@JsonKey() final  bool playerRetirementsDone;
/// Persisted TV agreement: the exact reset year and increase are known
/// before the event fires, so loading a save cannot reroll the cap.
@override@JsonKey() final  int nextTvCapResetSeason;
@override@JsonKey() final  int nextTvCapIncreasePct;
@override@JsonKey() final  bool capUpdateTvDone;
@override@JsonKey() final  bool combineDone;
@override@JsonKey() final  bool finalMockDone;
@override@JsonKey() final  bool faOpenDone;
@override@JsonKey() final  bool scoutReportDone;
@override@JsonKey() final  bool tradeDeadlineAcked;
@override@JsonKey() final  bool nextClassGenerationDone;
/// Play-in/playoff fixtures, populated eagerly as soon as each pairing
/// is known (see `game_calendar.md`) — placeholders for a still-pending
/// play-in seed, replaced with the real team once decided. This is the
/// calendar's sole source for postseason match days, the same way
/// `schedule` is for the regular season. `playInProgress`/`playInResults`
/// /`playoffBrackets` remain the simulation source of truth; entries here
/// are kept in lockstep with them but exist purely for display.
 final  List<ScheduledMatch> _postseasonFixtures;
/// Play-in/playoff fixtures, populated eagerly as soon as each pairing
/// is known (see `game_calendar.md`) — placeholders for a still-pending
/// play-in seed, replaced with the real team once decided. This is the
/// calendar's sole source for postseason match days, the same way
/// `schedule` is for the regular season. `playInProgress`/`playInResults`
/// /`playoffBrackets` remain the simulation source of truth; entries here
/// are kept in lockstep with them but exist purely for display.
@override@JsonKey() List<ScheduledMatch> get postseasonFixtures {
  if (_postseasonFixtures is EqualUnmodifiableListView) return _postseasonFixtures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_postseasonFixtures);
}


/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeasonCopyWith<_Season> get copyWith => __$SeasonCopyWithImpl<_Season>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeasonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Season&&(identical(other.year, year) || other.year == year)&&(identical(other.phase, phase) || other.phase == phase)&&const DeepCollectionEquality().equals(other._schedule, _schedule)&&const DeepCollectionEquality().equals(other._standings, _standings)&&const DeepCollectionEquality().equals(other._playInResults, _playInResults)&&const DeepCollectionEquality().equals(other._playInProgress, _playInProgress)&&const DeepCollectionEquality().equals(other._playoffBrackets, _playoffBrackets)&&(identical(other.championTeamId, championTeamId) || other.championTeamId == championTeamId)&&(identical(other.championshipAtmosphereApplied, championshipAtmosphereApplied) || other.championshipAtmosphereApplied == championshipAtmosphereApplied)&&(identical(other.playoffMissAtmosphereApplied, playoffMissAtmosphereApplied) || other.playoffMissAtmosphereApplied == playoffMissAtmosphereApplied)&&(identical(other.draftState, draftState) || other.draftState == draftState)&&(identical(other.awards, awards) || other.awards == awards)&&(identical(other.staffGrowthDone, staffGrowthDone) || other.staffGrowthDone == staffGrowthDone)&&(identical(other.playerRetirementsDone, playerRetirementsDone) || other.playerRetirementsDone == playerRetirementsDone)&&(identical(other.nextTvCapResetSeason, nextTvCapResetSeason) || other.nextTvCapResetSeason == nextTvCapResetSeason)&&(identical(other.nextTvCapIncreasePct, nextTvCapIncreasePct) || other.nextTvCapIncreasePct == nextTvCapIncreasePct)&&(identical(other.capUpdateTvDone, capUpdateTvDone) || other.capUpdateTvDone == capUpdateTvDone)&&(identical(other.combineDone, combineDone) || other.combineDone == combineDone)&&(identical(other.finalMockDone, finalMockDone) || other.finalMockDone == finalMockDone)&&(identical(other.faOpenDone, faOpenDone) || other.faOpenDone == faOpenDone)&&(identical(other.scoutReportDone, scoutReportDone) || other.scoutReportDone == scoutReportDone)&&(identical(other.tradeDeadlineAcked, tradeDeadlineAcked) || other.tradeDeadlineAcked == tradeDeadlineAcked)&&(identical(other.nextClassGenerationDone, nextClassGenerationDone) || other.nextClassGenerationDone == nextClassGenerationDone)&&const DeepCollectionEquality().equals(other._postseasonFixtures, _postseasonFixtures));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,year,phase,const DeepCollectionEquality().hash(_schedule),const DeepCollectionEquality().hash(_standings),const DeepCollectionEquality().hash(_playInResults),const DeepCollectionEquality().hash(_playInProgress),const DeepCollectionEquality().hash(_playoffBrackets),championTeamId,championshipAtmosphereApplied,playoffMissAtmosphereApplied,draftState,awards,staffGrowthDone,playerRetirementsDone,nextTvCapResetSeason,nextTvCapIncreasePct,capUpdateTvDone,combineDone,finalMockDone,faOpenDone,scoutReportDone,tradeDeadlineAcked,nextClassGenerationDone,const DeepCollectionEquality().hash(_postseasonFixtures)]);

@override
String toString() {
  return 'Season(year: $year, phase: $phase, schedule: $schedule, standings: $standings, playInResults: $playInResults, playInProgress: $playInProgress, playoffBrackets: $playoffBrackets, championTeamId: $championTeamId, championshipAtmosphereApplied: $championshipAtmosphereApplied, playoffMissAtmosphereApplied: $playoffMissAtmosphereApplied, draftState: $draftState, awards: $awards, staffGrowthDone: $staffGrowthDone, playerRetirementsDone: $playerRetirementsDone, nextTvCapResetSeason: $nextTvCapResetSeason, nextTvCapIncreasePct: $nextTvCapIncreasePct, capUpdateTvDone: $capUpdateTvDone, combineDone: $combineDone, finalMockDone: $finalMockDone, faOpenDone: $faOpenDone, scoutReportDone: $scoutReportDone, tradeDeadlineAcked: $tradeDeadlineAcked, nextClassGenerationDone: $nextClassGenerationDone, postseasonFixtures: $postseasonFixtures)';
}


}

/// @nodoc
abstract mixin class _$SeasonCopyWith<$Res> implements $SeasonCopyWith<$Res> {
  factory _$SeasonCopyWith(_Season value, $Res Function(_Season) _then) = __$SeasonCopyWithImpl;
@override @useResult
$Res call({
 int year, SeasonPhase phase, List<ScheduledMatch> schedule, List<ConferenceStandings> standings, List<PlayInResult> playInResults, List<PlayInProgress> playInProgress, List<PlayoffBracket> playoffBrackets, String? championTeamId, bool championshipAtmosphereApplied, bool playoffMissAtmosphereApplied, DraftState? draftState, SeasonAwards? awards, bool staffGrowthDone, bool playerRetirementsDone, int nextTvCapResetSeason, int nextTvCapIncreasePct, bool capUpdateTvDone, bool combineDone, bool finalMockDone, bool faOpenDone, bool scoutReportDone, bool tradeDeadlineAcked, bool nextClassGenerationDone, List<ScheduledMatch> postseasonFixtures
});


@override $DraftStateCopyWith<$Res>? get draftState;@override $SeasonAwardsCopyWith<$Res>? get awards;

}
/// @nodoc
class __$SeasonCopyWithImpl<$Res>
    implements _$SeasonCopyWith<$Res> {
  __$SeasonCopyWithImpl(this._self, this._then);

  final _Season _self;
  final $Res Function(_Season) _then;

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? phase = null,Object? schedule = null,Object? standings = null,Object? playInResults = null,Object? playInProgress = null,Object? playoffBrackets = null,Object? championTeamId = freezed,Object? championshipAtmosphereApplied = null,Object? playoffMissAtmosphereApplied = null,Object? draftState = freezed,Object? awards = freezed,Object? staffGrowthDone = null,Object? playerRetirementsDone = null,Object? nextTvCapResetSeason = null,Object? nextTvCapIncreasePct = null,Object? capUpdateTvDone = null,Object? combineDone = null,Object? finalMockDone = null,Object? faOpenDone = null,Object? scoutReportDone = null,Object? tradeDeadlineAcked = null,Object? nextClassGenerationDone = null,Object? postseasonFixtures = null,}) {
  return _then(_Season(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SeasonPhase,schedule: null == schedule ? _self._schedule : schedule // ignore: cast_nullable_to_non_nullable
as List<ScheduledMatch>,standings: null == standings ? _self._standings : standings // ignore: cast_nullable_to_non_nullable
as List<ConferenceStandings>,playInResults: null == playInResults ? _self._playInResults : playInResults // ignore: cast_nullable_to_non_nullable
as List<PlayInResult>,playInProgress: null == playInProgress ? _self._playInProgress : playInProgress // ignore: cast_nullable_to_non_nullable
as List<PlayInProgress>,playoffBrackets: null == playoffBrackets ? _self._playoffBrackets : playoffBrackets // ignore: cast_nullable_to_non_nullable
as List<PlayoffBracket>,championTeamId: freezed == championTeamId ? _self.championTeamId : championTeamId // ignore: cast_nullable_to_non_nullable
as String?,championshipAtmosphereApplied: null == championshipAtmosphereApplied ? _self.championshipAtmosphereApplied : championshipAtmosphereApplied // ignore: cast_nullable_to_non_nullable
as bool,playoffMissAtmosphereApplied: null == playoffMissAtmosphereApplied ? _self.playoffMissAtmosphereApplied : playoffMissAtmosphereApplied // ignore: cast_nullable_to_non_nullable
as bool,draftState: freezed == draftState ? _self.draftState : draftState // ignore: cast_nullable_to_non_nullable
as DraftState?,awards: freezed == awards ? _self.awards : awards // ignore: cast_nullable_to_non_nullable
as SeasonAwards?,staffGrowthDone: null == staffGrowthDone ? _self.staffGrowthDone : staffGrowthDone // ignore: cast_nullable_to_non_nullable
as bool,playerRetirementsDone: null == playerRetirementsDone ? _self.playerRetirementsDone : playerRetirementsDone // ignore: cast_nullable_to_non_nullable
as bool,nextTvCapResetSeason: null == nextTvCapResetSeason ? _self.nextTvCapResetSeason : nextTvCapResetSeason // ignore: cast_nullable_to_non_nullable
as int,nextTvCapIncreasePct: null == nextTvCapIncreasePct ? _self.nextTvCapIncreasePct : nextTvCapIncreasePct // ignore: cast_nullable_to_non_nullable
as int,capUpdateTvDone: null == capUpdateTvDone ? _self.capUpdateTvDone : capUpdateTvDone // ignore: cast_nullable_to_non_nullable
as bool,combineDone: null == combineDone ? _self.combineDone : combineDone // ignore: cast_nullable_to_non_nullable
as bool,finalMockDone: null == finalMockDone ? _self.finalMockDone : finalMockDone // ignore: cast_nullable_to_non_nullable
as bool,faOpenDone: null == faOpenDone ? _self.faOpenDone : faOpenDone // ignore: cast_nullable_to_non_nullable
as bool,scoutReportDone: null == scoutReportDone ? _self.scoutReportDone : scoutReportDone // ignore: cast_nullable_to_non_nullable
as bool,tradeDeadlineAcked: null == tradeDeadlineAcked ? _self.tradeDeadlineAcked : tradeDeadlineAcked // ignore: cast_nullable_to_non_nullable
as bool,nextClassGenerationDone: null == nextClassGenerationDone ? _self.nextClassGenerationDone : nextClassGenerationDone // ignore: cast_nullable_to_non_nullable
as bool,postseasonFixtures: null == postseasonFixtures ? _self._postseasonFixtures : postseasonFixtures // ignore: cast_nullable_to_non_nullable
as List<ScheduledMatch>,
  ));
}

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DraftStateCopyWith<$Res>? get draftState {
    if (_self.draftState == null) {
    return null;
  }

  return $DraftStateCopyWith<$Res>(_self.draftState!, (value) {
    return _then(_self.copyWith(draftState: value));
  });
}/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SeasonAwardsCopyWith<$Res>? get awards {
    if (_self.awards == null) {
    return null;
  }

  return $SeasonAwardsCopyWith<$Res>(_self.awards!, (value) {
    return _then(_self.copyWith(awards: value));
  });
}
}

// dart format on
