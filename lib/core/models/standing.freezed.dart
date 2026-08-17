// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'standing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Standing {

 String get teamId; int get wins; int get losses; int get draws; int get goalsFor; int get goalsAgainst; int get conferenceRank;
/// Create a copy of Standing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StandingCopyWith<Standing> get copyWith => _$StandingCopyWithImpl<Standing>(this as Standing, _$identity);

  /// Serializes this Standing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Standing&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.losses, losses) || other.losses == losses)&&(identical(other.draws, draws) || other.draws == draws)&&(identical(other.goalsFor, goalsFor) || other.goalsFor == goalsFor)&&(identical(other.goalsAgainst, goalsAgainst) || other.goalsAgainst == goalsAgainst)&&(identical(other.conferenceRank, conferenceRank) || other.conferenceRank == conferenceRank));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamId,wins,losses,draws,goalsFor,goalsAgainst,conferenceRank);

@override
String toString() {
  return 'Standing(teamId: $teamId, wins: $wins, losses: $losses, draws: $draws, goalsFor: $goalsFor, goalsAgainst: $goalsAgainst, conferenceRank: $conferenceRank)';
}


}

/// @nodoc
abstract mixin class $StandingCopyWith<$Res>  {
  factory $StandingCopyWith(Standing value, $Res Function(Standing) _then) = _$StandingCopyWithImpl;
@useResult
$Res call({
 String teamId, int wins, int losses, int draws, int goalsFor, int goalsAgainst, int conferenceRank
});




}
/// @nodoc
class _$StandingCopyWithImpl<$Res>
    implements $StandingCopyWith<$Res> {
  _$StandingCopyWithImpl(this._self, this._then);

  final Standing _self;
  final $Res Function(Standing) _then;

/// Create a copy of Standing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? teamId = null,Object? wins = null,Object? losses = null,Object? draws = null,Object? goalsFor = null,Object? goalsAgainst = null,Object? conferenceRank = null,}) {
  return _then(_self.copyWith(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,losses: null == losses ? _self.losses : losses // ignore: cast_nullable_to_non_nullable
as int,draws: null == draws ? _self.draws : draws // ignore: cast_nullable_to_non_nullable
as int,goalsFor: null == goalsFor ? _self.goalsFor : goalsFor // ignore: cast_nullable_to_non_nullable
as int,goalsAgainst: null == goalsAgainst ? _self.goalsAgainst : goalsAgainst // ignore: cast_nullable_to_non_nullable
as int,conferenceRank: null == conferenceRank ? _self.conferenceRank : conferenceRank // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Standing].
extension StandingPatterns on Standing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Standing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Standing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Standing value)  $default,){
final _that = this;
switch (_that) {
case _Standing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Standing value)?  $default,){
final _that = this;
switch (_that) {
case _Standing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String teamId,  int wins,  int losses,  int draws,  int goalsFor,  int goalsAgainst,  int conferenceRank)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Standing() when $default != null:
return $default(_that.teamId,_that.wins,_that.losses,_that.draws,_that.goalsFor,_that.goalsAgainst,_that.conferenceRank);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String teamId,  int wins,  int losses,  int draws,  int goalsFor,  int goalsAgainst,  int conferenceRank)  $default,) {final _that = this;
switch (_that) {
case _Standing():
return $default(_that.teamId,_that.wins,_that.losses,_that.draws,_that.goalsFor,_that.goalsAgainst,_that.conferenceRank);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String teamId,  int wins,  int losses,  int draws,  int goalsFor,  int goalsAgainst,  int conferenceRank)?  $default,) {final _that = this;
switch (_that) {
case _Standing() when $default != null:
return $default(_that.teamId,_that.wins,_that.losses,_that.draws,_that.goalsFor,_that.goalsAgainst,_that.conferenceRank);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Standing implements Standing {
  const _Standing({required this.teamId, this.wins = 0, this.losses = 0, this.draws = 0, this.goalsFor = 0, this.goalsAgainst = 0, this.conferenceRank = 0});
  factory _Standing.fromJson(Map<String, dynamic> json) => _$StandingFromJson(json);

@override final  String teamId;
@override@JsonKey() final  int wins;
@override@JsonKey() final  int losses;
@override@JsonKey() final  int draws;
@override@JsonKey() final  int goalsFor;
@override@JsonKey() final  int goalsAgainst;
@override@JsonKey() final  int conferenceRank;

/// Create a copy of Standing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StandingCopyWith<_Standing> get copyWith => __$StandingCopyWithImpl<_Standing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StandingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Standing&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.wins, wins) || other.wins == wins)&&(identical(other.losses, losses) || other.losses == losses)&&(identical(other.draws, draws) || other.draws == draws)&&(identical(other.goalsFor, goalsFor) || other.goalsFor == goalsFor)&&(identical(other.goalsAgainst, goalsAgainst) || other.goalsAgainst == goalsAgainst)&&(identical(other.conferenceRank, conferenceRank) || other.conferenceRank == conferenceRank));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamId,wins,losses,draws,goalsFor,goalsAgainst,conferenceRank);

@override
String toString() {
  return 'Standing(teamId: $teamId, wins: $wins, losses: $losses, draws: $draws, goalsFor: $goalsFor, goalsAgainst: $goalsAgainst, conferenceRank: $conferenceRank)';
}


}

/// @nodoc
abstract mixin class _$StandingCopyWith<$Res> implements $StandingCopyWith<$Res> {
  factory _$StandingCopyWith(_Standing value, $Res Function(_Standing) _then) = __$StandingCopyWithImpl;
@override @useResult
$Res call({
 String teamId, int wins, int losses, int draws, int goalsFor, int goalsAgainst, int conferenceRank
});




}
/// @nodoc
class __$StandingCopyWithImpl<$Res>
    implements _$StandingCopyWith<$Res> {
  __$StandingCopyWithImpl(this._self, this._then);

  final _Standing _self;
  final $Res Function(_Standing) _then;

/// Create a copy of Standing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? teamId = null,Object? wins = null,Object? losses = null,Object? draws = null,Object? goalsFor = null,Object? goalsAgainst = null,Object? conferenceRank = null,}) {
  return _then(_Standing(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,wins: null == wins ? _self.wins : wins // ignore: cast_nullable_to_non_nullable
as int,losses: null == losses ? _self.losses : losses // ignore: cast_nullable_to_non_nullable
as int,draws: null == draws ? _self.draws : draws // ignore: cast_nullable_to_non_nullable
as int,goalsFor: null == goalsFor ? _self.goalsFor : goalsFor // ignore: cast_nullable_to_non_nullable
as int,goalsAgainst: null == goalsAgainst ? _self.goalsAgainst : goalsAgainst // ignore: cast_nullable_to_non_nullable
as int,conferenceRank: null == conferenceRank ? _self.conferenceRank : conferenceRank // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ConferenceStandings {

 Conference get conference; List<Standing> get standings;
/// Create a copy of ConferenceStandings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConferenceStandingsCopyWith<ConferenceStandings> get copyWith => _$ConferenceStandingsCopyWithImpl<ConferenceStandings>(this as ConferenceStandings, _$identity);

  /// Serializes this ConferenceStandings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConferenceStandings&&(identical(other.conference, conference) || other.conference == conference)&&const DeepCollectionEquality().equals(other.standings, standings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conference,const DeepCollectionEquality().hash(standings));

@override
String toString() {
  return 'ConferenceStandings(conference: $conference, standings: $standings)';
}


}

/// @nodoc
abstract mixin class $ConferenceStandingsCopyWith<$Res>  {
  factory $ConferenceStandingsCopyWith(ConferenceStandings value, $Res Function(ConferenceStandings) _then) = _$ConferenceStandingsCopyWithImpl;
@useResult
$Res call({
 Conference conference, List<Standing> standings
});




}
/// @nodoc
class _$ConferenceStandingsCopyWithImpl<$Res>
    implements $ConferenceStandingsCopyWith<$Res> {
  _$ConferenceStandingsCopyWithImpl(this._self, this._then);

  final ConferenceStandings _self;
  final $Res Function(ConferenceStandings) _then;

/// Create a copy of ConferenceStandings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conference = null,Object? standings = null,}) {
  return _then(_self.copyWith(
conference: null == conference ? _self.conference : conference // ignore: cast_nullable_to_non_nullable
as Conference,standings: null == standings ? _self.standings : standings // ignore: cast_nullable_to_non_nullable
as List<Standing>,
  ));
}

}


/// Adds pattern-matching-related methods to [ConferenceStandings].
extension ConferenceStandingsPatterns on ConferenceStandings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConferenceStandings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConferenceStandings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConferenceStandings value)  $default,){
final _that = this;
switch (_that) {
case _ConferenceStandings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConferenceStandings value)?  $default,){
final _that = this;
switch (_that) {
case _ConferenceStandings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Conference conference,  List<Standing> standings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConferenceStandings() when $default != null:
return $default(_that.conference,_that.standings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Conference conference,  List<Standing> standings)  $default,) {final _that = this;
switch (_that) {
case _ConferenceStandings():
return $default(_that.conference,_that.standings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Conference conference,  List<Standing> standings)?  $default,) {final _that = this;
switch (_that) {
case _ConferenceStandings() when $default != null:
return $default(_that.conference,_that.standings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConferenceStandings implements ConferenceStandings {
  const _ConferenceStandings({required this.conference, final  List<Standing> standings = const []}): _standings = standings;
  factory _ConferenceStandings.fromJson(Map<String, dynamic> json) => _$ConferenceStandingsFromJson(json);

@override final  Conference conference;
 final  List<Standing> _standings;
@override@JsonKey() List<Standing> get standings {
  if (_standings is EqualUnmodifiableListView) return _standings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_standings);
}


/// Create a copy of ConferenceStandings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConferenceStandingsCopyWith<_ConferenceStandings> get copyWith => __$ConferenceStandingsCopyWithImpl<_ConferenceStandings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConferenceStandingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConferenceStandings&&(identical(other.conference, conference) || other.conference == conference)&&const DeepCollectionEquality().equals(other._standings, _standings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conference,const DeepCollectionEquality().hash(_standings));

@override
String toString() {
  return 'ConferenceStandings(conference: $conference, standings: $standings)';
}


}

/// @nodoc
abstract mixin class _$ConferenceStandingsCopyWith<$Res> implements $ConferenceStandingsCopyWith<$Res> {
  factory _$ConferenceStandingsCopyWith(_ConferenceStandings value, $Res Function(_ConferenceStandings) _then) = __$ConferenceStandingsCopyWithImpl;
@override @useResult
$Res call({
 Conference conference, List<Standing> standings
});




}
/// @nodoc
class __$ConferenceStandingsCopyWithImpl<$Res>
    implements _$ConferenceStandingsCopyWith<$Res> {
  __$ConferenceStandingsCopyWithImpl(this._self, this._then);

  final _ConferenceStandings _self;
  final $Res Function(_ConferenceStandings) _then;

/// Create a copy of ConferenceStandings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conference = null,Object? standings = null,}) {
  return _then(_ConferenceStandings(
conference: null == conference ? _self.conference : conference // ignore: cast_nullable_to_non_nullable
as Conference,standings: null == standings ? _self._standings : standings // ignore: cast_nullable_to_non_nullable
as List<Standing>,
  ));
}


}

// dart format on
