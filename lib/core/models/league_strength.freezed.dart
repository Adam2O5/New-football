// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'league_strength.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TeamStrengthEntry {

 String get teamId;/// Avg overall of top 15 players (missing slots counted as 50).
 double get teamPower;/// Position 1–30 in the league power ranking (1 = strongest).
 int get expectedRank;/// Status tier derived from expectedRank.
 TeamStatus get teamStatus;
/// Create a copy of TeamStrengthEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamStrengthEntryCopyWith<TeamStrengthEntry> get copyWith => _$TeamStrengthEntryCopyWithImpl<TeamStrengthEntry>(this as TeamStrengthEntry, _$identity);

  /// Serializes this TeamStrengthEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamStrengthEntry&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.teamPower, teamPower) || other.teamPower == teamPower)&&(identical(other.expectedRank, expectedRank) || other.expectedRank == expectedRank)&&(identical(other.teamStatus, teamStatus) || other.teamStatus == teamStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamId,teamPower,expectedRank,teamStatus);

@override
String toString() {
  return 'TeamStrengthEntry(teamId: $teamId, teamPower: $teamPower, expectedRank: $expectedRank, teamStatus: $teamStatus)';
}


}

/// @nodoc
abstract mixin class $TeamStrengthEntryCopyWith<$Res>  {
  factory $TeamStrengthEntryCopyWith(TeamStrengthEntry value, $Res Function(TeamStrengthEntry) _then) = _$TeamStrengthEntryCopyWithImpl;
@useResult
$Res call({
 String teamId, double teamPower, int expectedRank, TeamStatus teamStatus
});




}
/// @nodoc
class _$TeamStrengthEntryCopyWithImpl<$Res>
    implements $TeamStrengthEntryCopyWith<$Res> {
  _$TeamStrengthEntryCopyWithImpl(this._self, this._then);

  final TeamStrengthEntry _self;
  final $Res Function(TeamStrengthEntry) _then;

/// Create a copy of TeamStrengthEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? teamId = null,Object? teamPower = null,Object? expectedRank = null,Object? teamStatus = null,}) {
  return _then(_self.copyWith(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,teamPower: null == teamPower ? _self.teamPower : teamPower // ignore: cast_nullable_to_non_nullable
as double,expectedRank: null == expectedRank ? _self.expectedRank : expectedRank // ignore: cast_nullable_to_non_nullable
as int,teamStatus: null == teamStatus ? _self.teamStatus : teamStatus // ignore: cast_nullable_to_non_nullable
as TeamStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamStrengthEntry].
extension TeamStrengthEntryPatterns on TeamStrengthEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamStrengthEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamStrengthEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamStrengthEntry value)  $default,){
final _that = this;
switch (_that) {
case _TeamStrengthEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamStrengthEntry value)?  $default,){
final _that = this;
switch (_that) {
case _TeamStrengthEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String teamId,  double teamPower,  int expectedRank,  TeamStatus teamStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamStrengthEntry() when $default != null:
return $default(_that.teamId,_that.teamPower,_that.expectedRank,_that.teamStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String teamId,  double teamPower,  int expectedRank,  TeamStatus teamStatus)  $default,) {final _that = this;
switch (_that) {
case _TeamStrengthEntry():
return $default(_that.teamId,_that.teamPower,_that.expectedRank,_that.teamStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String teamId,  double teamPower,  int expectedRank,  TeamStatus teamStatus)?  $default,) {final _that = this;
switch (_that) {
case _TeamStrengthEntry() when $default != null:
return $default(_that.teamId,_that.teamPower,_that.expectedRank,_that.teamStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamStrengthEntry implements TeamStrengthEntry {
  const _TeamStrengthEntry({required this.teamId, required this.teamPower, required this.expectedRank, required this.teamStatus});
  factory _TeamStrengthEntry.fromJson(Map<String, dynamic> json) => _$TeamStrengthEntryFromJson(json);

@override final  String teamId;
/// Avg overall of top 15 players (missing slots counted as 50).
@override final  double teamPower;
/// Position 1–30 in the league power ranking (1 = strongest).
@override final  int expectedRank;
/// Status tier derived from expectedRank.
@override final  TeamStatus teamStatus;

/// Create a copy of TeamStrengthEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamStrengthEntryCopyWith<_TeamStrengthEntry> get copyWith => __$TeamStrengthEntryCopyWithImpl<_TeamStrengthEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamStrengthEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamStrengthEntry&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.teamPower, teamPower) || other.teamPower == teamPower)&&(identical(other.expectedRank, expectedRank) || other.expectedRank == expectedRank)&&(identical(other.teamStatus, teamStatus) || other.teamStatus == teamStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamId,teamPower,expectedRank,teamStatus);

@override
String toString() {
  return 'TeamStrengthEntry(teamId: $teamId, teamPower: $teamPower, expectedRank: $expectedRank, teamStatus: $teamStatus)';
}


}

/// @nodoc
abstract mixin class _$TeamStrengthEntryCopyWith<$Res> implements $TeamStrengthEntryCopyWith<$Res> {
  factory _$TeamStrengthEntryCopyWith(_TeamStrengthEntry value, $Res Function(_TeamStrengthEntry) _then) = __$TeamStrengthEntryCopyWithImpl;
@override @useResult
$Res call({
 String teamId, double teamPower, int expectedRank, TeamStatus teamStatus
});




}
/// @nodoc
class __$TeamStrengthEntryCopyWithImpl<$Res>
    implements _$TeamStrengthEntryCopyWith<$Res> {
  __$TeamStrengthEntryCopyWithImpl(this._self, this._then);

  final _TeamStrengthEntry _self;
  final $Res Function(_TeamStrengthEntry) _then;

/// Create a copy of TeamStrengthEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? teamId = null,Object? teamPower = null,Object? expectedRank = null,Object? teamStatus = null,}) {
  return _then(_TeamStrengthEntry(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,teamPower: null == teamPower ? _self.teamPower : teamPower // ignore: cast_nullable_to_non_nullable
as double,expectedRank: null == expectedRank ? _self.expectedRank : expectedRank // ignore: cast_nullable_to_non_nullable
as int,teamStatus: null == teamStatus ? _self.teamStatus : teamStatus // ignore: cast_nullable_to_non_nullable
as TeamStatus,
  ));
}


}


/// @nodoc
mixin _$LeagueStrengthTable {

/// Sorted descending by teamPower (index 0 = rank 1).
 List<TeamStrengthEntry> get entries;/// Week when this table was last calculated.
 int get lastCalculatedWeek;/// Day when this table was last calculated.
 int get lastCalculatedDay;/// Season that owns this snapshot. Zero keeps legacy in-memory fixtures
/// compatible and is treated as unknown by the recalculation guard.
 int get seasonYear;
/// Create a copy of LeagueStrengthTable
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeagueStrengthTableCopyWith<LeagueStrengthTable> get copyWith => _$LeagueStrengthTableCopyWithImpl<LeagueStrengthTable>(this as LeagueStrengthTable, _$identity);

  /// Serializes this LeagueStrengthTable to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeagueStrengthTable&&const DeepCollectionEquality().equals(other.entries, entries)&&(identical(other.lastCalculatedWeek, lastCalculatedWeek) || other.lastCalculatedWeek == lastCalculatedWeek)&&(identical(other.lastCalculatedDay, lastCalculatedDay) || other.lastCalculatedDay == lastCalculatedDay)&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(entries),lastCalculatedWeek,lastCalculatedDay,seasonYear);

@override
String toString() {
  return 'LeagueStrengthTable(entries: $entries, lastCalculatedWeek: $lastCalculatedWeek, lastCalculatedDay: $lastCalculatedDay, seasonYear: $seasonYear)';
}


}

/// @nodoc
abstract mixin class $LeagueStrengthTableCopyWith<$Res>  {
  factory $LeagueStrengthTableCopyWith(LeagueStrengthTable value, $Res Function(LeagueStrengthTable) _then) = _$LeagueStrengthTableCopyWithImpl;
@useResult
$Res call({
 List<TeamStrengthEntry> entries, int lastCalculatedWeek, int lastCalculatedDay, int seasonYear
});




}
/// @nodoc
class _$LeagueStrengthTableCopyWithImpl<$Res>
    implements $LeagueStrengthTableCopyWith<$Res> {
  _$LeagueStrengthTableCopyWithImpl(this._self, this._then);

  final LeagueStrengthTable _self;
  final $Res Function(LeagueStrengthTable) _then;

/// Create a copy of LeagueStrengthTable
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entries = null,Object? lastCalculatedWeek = null,Object? lastCalculatedDay = null,Object? seasonYear = null,}) {
  return _then(_self.copyWith(
entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<TeamStrengthEntry>,lastCalculatedWeek: null == lastCalculatedWeek ? _self.lastCalculatedWeek : lastCalculatedWeek // ignore: cast_nullable_to_non_nullable
as int,lastCalculatedDay: null == lastCalculatedDay ? _self.lastCalculatedDay : lastCalculatedDay // ignore: cast_nullable_to_non_nullable
as int,seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LeagueStrengthTable].
extension LeagueStrengthTablePatterns on LeagueStrengthTable {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeagueStrengthTable value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeagueStrengthTable() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeagueStrengthTable value)  $default,){
final _that = this;
switch (_that) {
case _LeagueStrengthTable():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeagueStrengthTable value)?  $default,){
final _that = this;
switch (_that) {
case _LeagueStrengthTable() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TeamStrengthEntry> entries,  int lastCalculatedWeek,  int lastCalculatedDay,  int seasonYear)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeagueStrengthTable() when $default != null:
return $default(_that.entries,_that.lastCalculatedWeek,_that.lastCalculatedDay,_that.seasonYear);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TeamStrengthEntry> entries,  int lastCalculatedWeek,  int lastCalculatedDay,  int seasonYear)  $default,) {final _that = this;
switch (_that) {
case _LeagueStrengthTable():
return $default(_that.entries,_that.lastCalculatedWeek,_that.lastCalculatedDay,_that.seasonYear);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TeamStrengthEntry> entries,  int lastCalculatedWeek,  int lastCalculatedDay,  int seasonYear)?  $default,) {final _that = this;
switch (_that) {
case _LeagueStrengthTable() when $default != null:
return $default(_that.entries,_that.lastCalculatedWeek,_that.lastCalculatedDay,_that.seasonYear);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LeagueStrengthTable implements LeagueStrengthTable {
  const _LeagueStrengthTable({required final  List<TeamStrengthEntry> entries, required this.lastCalculatedWeek, this.lastCalculatedDay = 1, this.seasonYear = 0}): _entries = entries;
  factory _LeagueStrengthTable.fromJson(Map<String, dynamic> json) => _$LeagueStrengthTableFromJson(json);

/// Sorted descending by teamPower (index 0 = rank 1).
 final  List<TeamStrengthEntry> _entries;
/// Sorted descending by teamPower (index 0 = rank 1).
@override List<TeamStrengthEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

/// Week when this table was last calculated.
@override final  int lastCalculatedWeek;
/// Day when this table was last calculated.
@override@JsonKey() final  int lastCalculatedDay;
/// Season that owns this snapshot. Zero keeps legacy in-memory fixtures
/// compatible and is treated as unknown by the recalculation guard.
@override@JsonKey() final  int seasonYear;

/// Create a copy of LeagueStrengthTable
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeagueStrengthTableCopyWith<_LeagueStrengthTable> get copyWith => __$LeagueStrengthTableCopyWithImpl<_LeagueStrengthTable>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeagueStrengthTableToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeagueStrengthTable&&const DeepCollectionEquality().equals(other._entries, _entries)&&(identical(other.lastCalculatedWeek, lastCalculatedWeek) || other.lastCalculatedWeek == lastCalculatedWeek)&&(identical(other.lastCalculatedDay, lastCalculatedDay) || other.lastCalculatedDay == lastCalculatedDay)&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries),lastCalculatedWeek,lastCalculatedDay,seasonYear);

@override
String toString() {
  return 'LeagueStrengthTable(entries: $entries, lastCalculatedWeek: $lastCalculatedWeek, lastCalculatedDay: $lastCalculatedDay, seasonYear: $seasonYear)';
}


}

/// @nodoc
abstract mixin class _$LeagueStrengthTableCopyWith<$Res> implements $LeagueStrengthTableCopyWith<$Res> {
  factory _$LeagueStrengthTableCopyWith(_LeagueStrengthTable value, $Res Function(_LeagueStrengthTable) _then) = __$LeagueStrengthTableCopyWithImpl;
@override @useResult
$Res call({
 List<TeamStrengthEntry> entries, int lastCalculatedWeek, int lastCalculatedDay, int seasonYear
});




}
/// @nodoc
class __$LeagueStrengthTableCopyWithImpl<$Res>
    implements _$LeagueStrengthTableCopyWith<$Res> {
  __$LeagueStrengthTableCopyWithImpl(this._self, this._then);

  final _LeagueStrengthTable _self;
  final $Res Function(_LeagueStrengthTable) _then;

/// Create a copy of LeagueStrengthTable
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entries = null,Object? lastCalculatedWeek = null,Object? lastCalculatedDay = null,Object? seasonYear = null,}) {
  return _then(_LeagueStrengthTable(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<TeamStrengthEntry>,lastCalculatedWeek: null == lastCalculatedWeek ? _self.lastCalculatedWeek : lastCalculatedWeek // ignore: cast_nullable_to_non_nullable
as int,lastCalculatedDay: null == lastCalculatedDay ? _self.lastCalculatedDay : lastCalculatedDay // ignore: cast_nullable_to_non_nullable
as int,seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
