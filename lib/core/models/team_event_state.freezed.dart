// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_event_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TeamTimedModifier {

 String get type; double get value; int get weeksRemaining;
/// Create a copy of TeamTimedModifier
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamTimedModifierCopyWith<TeamTimedModifier> get copyWith => _$TeamTimedModifierCopyWithImpl<TeamTimedModifier>(this as TeamTimedModifier, _$identity);

  /// Serializes this TeamTimedModifier to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamTimedModifier&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value)&&(identical(other.weeksRemaining, weeksRemaining) || other.weeksRemaining == weeksRemaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,value,weeksRemaining);

@override
String toString() {
  return 'TeamTimedModifier(type: $type, value: $value, weeksRemaining: $weeksRemaining)';
}


}

/// @nodoc
abstract mixin class $TeamTimedModifierCopyWith<$Res>  {
  factory $TeamTimedModifierCopyWith(TeamTimedModifier value, $Res Function(TeamTimedModifier) _then) = _$TeamTimedModifierCopyWithImpl;
@useResult
$Res call({
 String type, double value, int weeksRemaining
});




}
/// @nodoc
class _$TeamTimedModifierCopyWithImpl<$Res>
    implements $TeamTimedModifierCopyWith<$Res> {
  _$TeamTimedModifierCopyWithImpl(this._self, this._then);

  final TeamTimedModifier _self;
  final $Res Function(TeamTimedModifier) _then;

/// Create a copy of TeamTimedModifier
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? value = null,Object? weeksRemaining = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,weeksRemaining: null == weeksRemaining ? _self.weeksRemaining : weeksRemaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamTimedModifier].
extension TeamTimedModifierPatterns on TeamTimedModifier {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamTimedModifier value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamTimedModifier() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamTimedModifier value)  $default,){
final _that = this;
switch (_that) {
case _TeamTimedModifier():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamTimedModifier value)?  $default,){
final _that = this;
switch (_that) {
case _TeamTimedModifier() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  double value,  int weeksRemaining)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamTimedModifier() when $default != null:
return $default(_that.type,_that.value,_that.weeksRemaining);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  double value,  int weeksRemaining)  $default,) {final _that = this;
switch (_that) {
case _TeamTimedModifier():
return $default(_that.type,_that.value,_that.weeksRemaining);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  double value,  int weeksRemaining)?  $default,) {final _that = this;
switch (_that) {
case _TeamTimedModifier() when $default != null:
return $default(_that.type,_that.value,_that.weeksRemaining);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamTimedModifier implements TeamTimedModifier {
  const _TeamTimedModifier({required this.type, required this.value, required this.weeksRemaining});
  factory _TeamTimedModifier.fromJson(Map<String, dynamic> json) => _$TeamTimedModifierFromJson(json);

@override final  String type;
@override final  double value;
@override final  int weeksRemaining;

/// Create a copy of TeamTimedModifier
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamTimedModifierCopyWith<_TeamTimedModifier> get copyWith => __$TeamTimedModifierCopyWithImpl<_TeamTimedModifier>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamTimedModifierToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamTimedModifier&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value)&&(identical(other.weeksRemaining, weeksRemaining) || other.weeksRemaining == weeksRemaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,value,weeksRemaining);

@override
String toString() {
  return 'TeamTimedModifier(type: $type, value: $value, weeksRemaining: $weeksRemaining)';
}


}

/// @nodoc
abstract mixin class _$TeamTimedModifierCopyWith<$Res> implements $TeamTimedModifierCopyWith<$Res> {
  factory _$TeamTimedModifierCopyWith(_TeamTimedModifier value, $Res Function(_TeamTimedModifier) _then) = __$TeamTimedModifierCopyWithImpl;
@override @useResult
$Res call({
 String type, double value, int weeksRemaining
});




}
/// @nodoc
class __$TeamTimedModifierCopyWithImpl<$Res>
    implements _$TeamTimedModifierCopyWith<$Res> {
  __$TeamTimedModifierCopyWithImpl(this._self, this._then);

  final _TeamTimedModifier _self;
  final $Res Function(_TeamTimedModifier) _then;

/// Create a copy of TeamTimedModifier
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? value = null,Object? weeksRemaining = null,}) {
  return _then(_TeamTimedModifier(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,weeksRemaining: null == weeksRemaining ? _self.weeksRemaining : weeksRemaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MinutesHistoryEntry {

 String get playerId; int get seasonYear; int get week; int get minutes; int get possibleMinutes;
/// Create a copy of MinutesHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MinutesHistoryEntryCopyWith<MinutesHistoryEntry> get copyWith => _$MinutesHistoryEntryCopyWithImpl<MinutesHistoryEntry>(this as MinutesHistoryEntry, _$identity);

  /// Serializes this MinutesHistoryEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MinutesHistoryEntry&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear)&&(identical(other.week, week) || other.week == week)&&(identical(other.minutes, minutes) || other.minutes == minutes)&&(identical(other.possibleMinutes, possibleMinutes) || other.possibleMinutes == possibleMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerId,seasonYear,week,minutes,possibleMinutes);

@override
String toString() {
  return 'MinutesHistoryEntry(playerId: $playerId, seasonYear: $seasonYear, week: $week, minutes: $minutes, possibleMinutes: $possibleMinutes)';
}


}

/// @nodoc
abstract mixin class $MinutesHistoryEntryCopyWith<$Res>  {
  factory $MinutesHistoryEntryCopyWith(MinutesHistoryEntry value, $Res Function(MinutesHistoryEntry) _then) = _$MinutesHistoryEntryCopyWithImpl;
@useResult
$Res call({
 String playerId, int seasonYear, int week, int minutes, int possibleMinutes
});




}
/// @nodoc
class _$MinutesHistoryEntryCopyWithImpl<$Res>
    implements $MinutesHistoryEntryCopyWith<$Res> {
  _$MinutesHistoryEntryCopyWithImpl(this._self, this._then);

  final MinutesHistoryEntry _self;
  final $Res Function(MinutesHistoryEntry) _then;

/// Create a copy of MinutesHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playerId = null,Object? seasonYear = null,Object? week = null,Object? minutes = null,Object? possibleMinutes = null,}) {
  return _then(_self.copyWith(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,week: null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as int,minutes: null == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int,possibleMinutes: null == possibleMinutes ? _self.possibleMinutes : possibleMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MinutesHistoryEntry].
extension MinutesHistoryEntryPatterns on MinutesHistoryEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MinutesHistoryEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MinutesHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MinutesHistoryEntry value)  $default,){
final _that = this;
switch (_that) {
case _MinutesHistoryEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MinutesHistoryEntry value)?  $default,){
final _that = this;
switch (_that) {
case _MinutesHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String playerId,  int seasonYear,  int week,  int minutes,  int possibleMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MinutesHistoryEntry() when $default != null:
return $default(_that.playerId,_that.seasonYear,_that.week,_that.minutes,_that.possibleMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String playerId,  int seasonYear,  int week,  int minutes,  int possibleMinutes)  $default,) {final _that = this;
switch (_that) {
case _MinutesHistoryEntry():
return $default(_that.playerId,_that.seasonYear,_that.week,_that.minutes,_that.possibleMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String playerId,  int seasonYear,  int week,  int minutes,  int possibleMinutes)?  $default,) {final _that = this;
switch (_that) {
case _MinutesHistoryEntry() when $default != null:
return $default(_that.playerId,_that.seasonYear,_that.week,_that.minutes,_that.possibleMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MinutesHistoryEntry implements MinutesHistoryEntry {
  const _MinutesHistoryEntry({required this.playerId, required this.seasonYear, required this.week, this.minutes = 0, this.possibleMinutes = 90});
  factory _MinutesHistoryEntry.fromJson(Map<String, dynamic> json) => _$MinutesHistoryEntryFromJson(json);

@override final  String playerId;
@override final  int seasonYear;
@override final  int week;
@override@JsonKey() final  int minutes;
@override@JsonKey() final  int possibleMinutes;

/// Create a copy of MinutesHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MinutesHistoryEntryCopyWith<_MinutesHistoryEntry> get copyWith => __$MinutesHistoryEntryCopyWithImpl<_MinutesHistoryEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MinutesHistoryEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MinutesHistoryEntry&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear)&&(identical(other.week, week) || other.week == week)&&(identical(other.minutes, minutes) || other.minutes == minutes)&&(identical(other.possibleMinutes, possibleMinutes) || other.possibleMinutes == possibleMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerId,seasonYear,week,minutes,possibleMinutes);

@override
String toString() {
  return 'MinutesHistoryEntry(playerId: $playerId, seasonYear: $seasonYear, week: $week, minutes: $minutes, possibleMinutes: $possibleMinutes)';
}


}

/// @nodoc
abstract mixin class _$MinutesHistoryEntryCopyWith<$Res> implements $MinutesHistoryEntryCopyWith<$Res> {
  factory _$MinutesHistoryEntryCopyWith(_MinutesHistoryEntry value, $Res Function(_MinutesHistoryEntry) _then) = __$MinutesHistoryEntryCopyWithImpl;
@override @useResult
$Res call({
 String playerId, int seasonYear, int week, int minutes, int possibleMinutes
});




}
/// @nodoc
class __$MinutesHistoryEntryCopyWithImpl<$Res>
    implements _$MinutesHistoryEntryCopyWith<$Res> {
  __$MinutesHistoryEntryCopyWithImpl(this._self, this._then);

  final _MinutesHistoryEntry _self;
  final $Res Function(_MinutesHistoryEntry) _then;

/// Create a copy of MinutesHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playerId = null,Object? seasonYear = null,Object? week = null,Object? minutes = null,Object? possibleMinutes = null,}) {
  return _then(_MinutesHistoryEntry(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,week: null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as int,minutes: null == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int,possibleMinutes: null == possibleMinutes ? _self.possibleMinutes : possibleMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SeasonMinutesAggregate {

 String get playerId; int get seasonYear; int get actualMinutes; int get possibleMinutes;
/// Create a copy of SeasonMinutesAggregate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeasonMinutesAggregateCopyWith<SeasonMinutesAggregate> get copyWith => _$SeasonMinutesAggregateCopyWithImpl<SeasonMinutesAggregate>(this as SeasonMinutesAggregate, _$identity);

  /// Serializes this SeasonMinutesAggregate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeasonMinutesAggregate&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear)&&(identical(other.actualMinutes, actualMinutes) || other.actualMinutes == actualMinutes)&&(identical(other.possibleMinutes, possibleMinutes) || other.possibleMinutes == possibleMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerId,seasonYear,actualMinutes,possibleMinutes);

@override
String toString() {
  return 'SeasonMinutesAggregate(playerId: $playerId, seasonYear: $seasonYear, actualMinutes: $actualMinutes, possibleMinutes: $possibleMinutes)';
}


}

/// @nodoc
abstract mixin class $SeasonMinutesAggregateCopyWith<$Res>  {
  factory $SeasonMinutesAggregateCopyWith(SeasonMinutesAggregate value, $Res Function(SeasonMinutesAggregate) _then) = _$SeasonMinutesAggregateCopyWithImpl;
@useResult
$Res call({
 String playerId, int seasonYear, int actualMinutes, int possibleMinutes
});




}
/// @nodoc
class _$SeasonMinutesAggregateCopyWithImpl<$Res>
    implements $SeasonMinutesAggregateCopyWith<$Res> {
  _$SeasonMinutesAggregateCopyWithImpl(this._self, this._then);

  final SeasonMinutesAggregate _self;
  final $Res Function(SeasonMinutesAggregate) _then;

/// Create a copy of SeasonMinutesAggregate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playerId = null,Object? seasonYear = null,Object? actualMinutes = null,Object? possibleMinutes = null,}) {
  return _then(_self.copyWith(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,actualMinutes: null == actualMinutes ? _self.actualMinutes : actualMinutes // ignore: cast_nullable_to_non_nullable
as int,possibleMinutes: null == possibleMinutes ? _self.possibleMinutes : possibleMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SeasonMinutesAggregate].
extension SeasonMinutesAggregatePatterns on SeasonMinutesAggregate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SeasonMinutesAggregate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SeasonMinutesAggregate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SeasonMinutesAggregate value)  $default,){
final _that = this;
switch (_that) {
case _SeasonMinutesAggregate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SeasonMinutesAggregate value)?  $default,){
final _that = this;
switch (_that) {
case _SeasonMinutesAggregate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String playerId,  int seasonYear,  int actualMinutes,  int possibleMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SeasonMinutesAggregate() when $default != null:
return $default(_that.playerId,_that.seasonYear,_that.actualMinutes,_that.possibleMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String playerId,  int seasonYear,  int actualMinutes,  int possibleMinutes)  $default,) {final _that = this;
switch (_that) {
case _SeasonMinutesAggregate():
return $default(_that.playerId,_that.seasonYear,_that.actualMinutes,_that.possibleMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String playerId,  int seasonYear,  int actualMinutes,  int possibleMinutes)?  $default,) {final _that = this;
switch (_that) {
case _SeasonMinutesAggregate() when $default != null:
return $default(_that.playerId,_that.seasonYear,_that.actualMinutes,_that.possibleMinutes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SeasonMinutesAggregate implements SeasonMinutesAggregate {
  const _SeasonMinutesAggregate({required this.playerId, required this.seasonYear, this.actualMinutes = 0, this.possibleMinutes = 0});
  factory _SeasonMinutesAggregate.fromJson(Map<String, dynamic> json) => _$SeasonMinutesAggregateFromJson(json);

@override final  String playerId;
@override final  int seasonYear;
@override@JsonKey() final  int actualMinutes;
@override@JsonKey() final  int possibleMinutes;

/// Create a copy of SeasonMinutesAggregate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeasonMinutesAggregateCopyWith<_SeasonMinutesAggregate> get copyWith => __$SeasonMinutesAggregateCopyWithImpl<_SeasonMinutesAggregate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeasonMinutesAggregateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SeasonMinutesAggregate&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear)&&(identical(other.actualMinutes, actualMinutes) || other.actualMinutes == actualMinutes)&&(identical(other.possibleMinutes, possibleMinutes) || other.possibleMinutes == possibleMinutes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerId,seasonYear,actualMinutes,possibleMinutes);

@override
String toString() {
  return 'SeasonMinutesAggregate(playerId: $playerId, seasonYear: $seasonYear, actualMinutes: $actualMinutes, possibleMinutes: $possibleMinutes)';
}


}

/// @nodoc
abstract mixin class _$SeasonMinutesAggregateCopyWith<$Res> implements $SeasonMinutesAggregateCopyWith<$Res> {
  factory _$SeasonMinutesAggregateCopyWith(_SeasonMinutesAggregate value, $Res Function(_SeasonMinutesAggregate) _then) = __$SeasonMinutesAggregateCopyWithImpl;
@override @useResult
$Res call({
 String playerId, int seasonYear, int actualMinutes, int possibleMinutes
});




}
/// @nodoc
class __$SeasonMinutesAggregateCopyWithImpl<$Res>
    implements _$SeasonMinutesAggregateCopyWith<$Res> {
  __$SeasonMinutesAggregateCopyWithImpl(this._self, this._then);

  final _SeasonMinutesAggregate _self;
  final $Res Function(_SeasonMinutesAggregate) _then;

/// Create a copy of SeasonMinutesAggregate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playerId = null,Object? seasonYear = null,Object? actualMinutes = null,Object? possibleMinutes = null,}) {
  return _then(_SeasonMinutesAggregate(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,actualMinutes: null == actualMinutes ? _self.actualMinutes : actualMinutes // ignore: cast_nullable_to_non_nullable
as int,possibleMinutes: null == possibleMinutes ? _self.possibleMinutes : possibleMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TeamPromise {

 String get id; String get playerId; String get kind; int get createdSeasonYear; int get createdWeek; int get weeksElapsed; int get durationWeeks; double get requiredMinutesShare;
/// Create a copy of TeamPromise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamPromiseCopyWith<TeamPromise> get copyWith => _$TeamPromiseCopyWithImpl<TeamPromise>(this as TeamPromise, _$identity);

  /// Serializes this TeamPromise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamPromise&&(identical(other.id, id) || other.id == id)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.createdSeasonYear, createdSeasonYear) || other.createdSeasonYear == createdSeasonYear)&&(identical(other.createdWeek, createdWeek) || other.createdWeek == createdWeek)&&(identical(other.weeksElapsed, weeksElapsed) || other.weeksElapsed == weeksElapsed)&&(identical(other.durationWeeks, durationWeeks) || other.durationWeeks == durationWeeks)&&(identical(other.requiredMinutesShare, requiredMinutesShare) || other.requiredMinutesShare == requiredMinutesShare));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,playerId,kind,createdSeasonYear,createdWeek,weeksElapsed,durationWeeks,requiredMinutesShare);

@override
String toString() {
  return 'TeamPromise(id: $id, playerId: $playerId, kind: $kind, createdSeasonYear: $createdSeasonYear, createdWeek: $createdWeek, weeksElapsed: $weeksElapsed, durationWeeks: $durationWeeks, requiredMinutesShare: $requiredMinutesShare)';
}


}

/// @nodoc
abstract mixin class $TeamPromiseCopyWith<$Res>  {
  factory $TeamPromiseCopyWith(TeamPromise value, $Res Function(TeamPromise) _then) = _$TeamPromiseCopyWithImpl;
@useResult
$Res call({
 String id, String playerId, String kind, int createdSeasonYear, int createdWeek, int weeksElapsed, int durationWeeks, double requiredMinutesShare
});




}
/// @nodoc
class _$TeamPromiseCopyWithImpl<$Res>
    implements $TeamPromiseCopyWith<$Res> {
  _$TeamPromiseCopyWithImpl(this._self, this._then);

  final TeamPromise _self;
  final $Res Function(TeamPromise) _then;

/// Create a copy of TeamPromise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? playerId = null,Object? kind = null,Object? createdSeasonYear = null,Object? createdWeek = null,Object? weeksElapsed = null,Object? durationWeeks = null,Object? requiredMinutesShare = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,createdSeasonYear: null == createdSeasonYear ? _self.createdSeasonYear : createdSeasonYear // ignore: cast_nullable_to_non_nullable
as int,createdWeek: null == createdWeek ? _self.createdWeek : createdWeek // ignore: cast_nullable_to_non_nullable
as int,weeksElapsed: null == weeksElapsed ? _self.weeksElapsed : weeksElapsed // ignore: cast_nullable_to_non_nullable
as int,durationWeeks: null == durationWeeks ? _self.durationWeeks : durationWeeks // ignore: cast_nullable_to_non_nullable
as int,requiredMinutesShare: null == requiredMinutesShare ? _self.requiredMinutesShare : requiredMinutesShare // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamPromise].
extension TeamPromisePatterns on TeamPromise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamPromise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamPromise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamPromise value)  $default,){
final _that = this;
switch (_that) {
case _TeamPromise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamPromise value)?  $default,){
final _that = this;
switch (_that) {
case _TeamPromise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String playerId,  String kind,  int createdSeasonYear,  int createdWeek,  int weeksElapsed,  int durationWeeks,  double requiredMinutesShare)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamPromise() when $default != null:
return $default(_that.id,_that.playerId,_that.kind,_that.createdSeasonYear,_that.createdWeek,_that.weeksElapsed,_that.durationWeeks,_that.requiredMinutesShare);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String playerId,  String kind,  int createdSeasonYear,  int createdWeek,  int weeksElapsed,  int durationWeeks,  double requiredMinutesShare)  $default,) {final _that = this;
switch (_that) {
case _TeamPromise():
return $default(_that.id,_that.playerId,_that.kind,_that.createdSeasonYear,_that.createdWeek,_that.weeksElapsed,_that.durationWeeks,_that.requiredMinutesShare);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String playerId,  String kind,  int createdSeasonYear,  int createdWeek,  int weeksElapsed,  int durationWeeks,  double requiredMinutesShare)?  $default,) {final _that = this;
switch (_that) {
case _TeamPromise() when $default != null:
return $default(_that.id,_that.playerId,_that.kind,_that.createdSeasonYear,_that.createdWeek,_that.weeksElapsed,_that.durationWeeks,_that.requiredMinutesShare);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamPromise implements TeamPromise {
  const _TeamPromise({required this.id, required this.playerId, required this.kind, required this.createdSeasonYear, required this.createdWeek, this.weeksElapsed = 0, this.durationWeeks = 4, this.requiredMinutesShare = 0.4});
  factory _TeamPromise.fromJson(Map<String, dynamic> json) => _$TeamPromiseFromJson(json);

@override final  String id;
@override final  String playerId;
@override final  String kind;
@override final  int createdSeasonYear;
@override final  int createdWeek;
@override@JsonKey() final  int weeksElapsed;
@override@JsonKey() final  int durationWeeks;
@override@JsonKey() final  double requiredMinutesShare;

/// Create a copy of TeamPromise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamPromiseCopyWith<_TeamPromise> get copyWith => __$TeamPromiseCopyWithImpl<_TeamPromise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamPromiseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamPromise&&(identical(other.id, id) || other.id == id)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.createdSeasonYear, createdSeasonYear) || other.createdSeasonYear == createdSeasonYear)&&(identical(other.createdWeek, createdWeek) || other.createdWeek == createdWeek)&&(identical(other.weeksElapsed, weeksElapsed) || other.weeksElapsed == weeksElapsed)&&(identical(other.durationWeeks, durationWeeks) || other.durationWeeks == durationWeeks)&&(identical(other.requiredMinutesShare, requiredMinutesShare) || other.requiredMinutesShare == requiredMinutesShare));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,playerId,kind,createdSeasonYear,createdWeek,weeksElapsed,durationWeeks,requiredMinutesShare);

@override
String toString() {
  return 'TeamPromise(id: $id, playerId: $playerId, kind: $kind, createdSeasonYear: $createdSeasonYear, createdWeek: $createdWeek, weeksElapsed: $weeksElapsed, durationWeeks: $durationWeeks, requiredMinutesShare: $requiredMinutesShare)';
}


}

/// @nodoc
abstract mixin class _$TeamPromiseCopyWith<$Res> implements $TeamPromiseCopyWith<$Res> {
  factory _$TeamPromiseCopyWith(_TeamPromise value, $Res Function(_TeamPromise) _then) = __$TeamPromiseCopyWithImpl;
@override @useResult
$Res call({
 String id, String playerId, String kind, int createdSeasonYear, int createdWeek, int weeksElapsed, int durationWeeks, double requiredMinutesShare
});




}
/// @nodoc
class __$TeamPromiseCopyWithImpl<$Res>
    implements _$TeamPromiseCopyWith<$Res> {
  __$TeamPromiseCopyWithImpl(this._self, this._then);

  final _TeamPromise _self;
  final $Res Function(_TeamPromise) _then;

/// Create a copy of TeamPromise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? playerId = null,Object? kind = null,Object? createdSeasonYear = null,Object? createdWeek = null,Object? weeksElapsed = null,Object? durationWeeks = null,Object? requiredMinutesShare = null,}) {
  return _then(_TeamPromise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,createdSeasonYear: null == createdSeasonYear ? _self.createdSeasonYear : createdSeasonYear // ignore: cast_nullable_to_non_nullable
as int,createdWeek: null == createdWeek ? _self.createdWeek : createdWeek // ignore: cast_nullable_to_non_nullable
as int,weeksElapsed: null == weeksElapsed ? _self.weeksElapsed : weeksElapsed // ignore: cast_nullable_to_non_nullable
as int,durationWeeks: null == durationWeeks ? _self.durationWeeks : durationWeeks // ignore: cast_nullable_to_non_nullable
as int,requiredMinutesShare: null == requiredMinutesShare ? _self.requiredMinutesShare : requiredMinutesShare // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$TeamTransferSituation {

 String get id; String get playerId; String get kind; int get createdSeasonYear; int get createdWeek; int get weeksRemaining;
/// Create a copy of TeamTransferSituation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamTransferSituationCopyWith<TeamTransferSituation> get copyWith => _$TeamTransferSituationCopyWithImpl<TeamTransferSituation>(this as TeamTransferSituation, _$identity);

  /// Serializes this TeamTransferSituation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamTransferSituation&&(identical(other.id, id) || other.id == id)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.createdSeasonYear, createdSeasonYear) || other.createdSeasonYear == createdSeasonYear)&&(identical(other.createdWeek, createdWeek) || other.createdWeek == createdWeek)&&(identical(other.weeksRemaining, weeksRemaining) || other.weeksRemaining == weeksRemaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,playerId,kind,createdSeasonYear,createdWeek,weeksRemaining);

@override
String toString() {
  return 'TeamTransferSituation(id: $id, playerId: $playerId, kind: $kind, createdSeasonYear: $createdSeasonYear, createdWeek: $createdWeek, weeksRemaining: $weeksRemaining)';
}


}

/// @nodoc
abstract mixin class $TeamTransferSituationCopyWith<$Res>  {
  factory $TeamTransferSituationCopyWith(TeamTransferSituation value, $Res Function(TeamTransferSituation) _then) = _$TeamTransferSituationCopyWithImpl;
@useResult
$Res call({
 String id, String playerId, String kind, int createdSeasonYear, int createdWeek, int weeksRemaining
});




}
/// @nodoc
class _$TeamTransferSituationCopyWithImpl<$Res>
    implements $TeamTransferSituationCopyWith<$Res> {
  _$TeamTransferSituationCopyWithImpl(this._self, this._then);

  final TeamTransferSituation _self;
  final $Res Function(TeamTransferSituation) _then;

/// Create a copy of TeamTransferSituation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? playerId = null,Object? kind = null,Object? createdSeasonYear = null,Object? createdWeek = null,Object? weeksRemaining = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,createdSeasonYear: null == createdSeasonYear ? _self.createdSeasonYear : createdSeasonYear // ignore: cast_nullable_to_non_nullable
as int,createdWeek: null == createdWeek ? _self.createdWeek : createdWeek // ignore: cast_nullable_to_non_nullable
as int,weeksRemaining: null == weeksRemaining ? _self.weeksRemaining : weeksRemaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamTransferSituation].
extension TeamTransferSituationPatterns on TeamTransferSituation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamTransferSituation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamTransferSituation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamTransferSituation value)  $default,){
final _that = this;
switch (_that) {
case _TeamTransferSituation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamTransferSituation value)?  $default,){
final _that = this;
switch (_that) {
case _TeamTransferSituation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String playerId,  String kind,  int createdSeasonYear,  int createdWeek,  int weeksRemaining)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamTransferSituation() when $default != null:
return $default(_that.id,_that.playerId,_that.kind,_that.createdSeasonYear,_that.createdWeek,_that.weeksRemaining);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String playerId,  String kind,  int createdSeasonYear,  int createdWeek,  int weeksRemaining)  $default,) {final _that = this;
switch (_that) {
case _TeamTransferSituation():
return $default(_that.id,_that.playerId,_that.kind,_that.createdSeasonYear,_that.createdWeek,_that.weeksRemaining);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String playerId,  String kind,  int createdSeasonYear,  int createdWeek,  int weeksRemaining)?  $default,) {final _that = this;
switch (_that) {
case _TeamTransferSituation() when $default != null:
return $default(_that.id,_that.playerId,_that.kind,_that.createdSeasonYear,_that.createdWeek,_that.weeksRemaining);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamTransferSituation implements TeamTransferSituation {
  const _TeamTransferSituation({required this.id, required this.playerId, required this.kind, required this.createdSeasonYear, required this.createdWeek, this.weeksRemaining = 4});
  factory _TeamTransferSituation.fromJson(Map<String, dynamic> json) => _$TeamTransferSituationFromJson(json);

@override final  String id;
@override final  String playerId;
@override final  String kind;
@override final  int createdSeasonYear;
@override final  int createdWeek;
@override@JsonKey() final  int weeksRemaining;

/// Create a copy of TeamTransferSituation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamTransferSituationCopyWith<_TeamTransferSituation> get copyWith => __$TeamTransferSituationCopyWithImpl<_TeamTransferSituation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamTransferSituationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamTransferSituation&&(identical(other.id, id) || other.id == id)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.createdSeasonYear, createdSeasonYear) || other.createdSeasonYear == createdSeasonYear)&&(identical(other.createdWeek, createdWeek) || other.createdWeek == createdWeek)&&(identical(other.weeksRemaining, weeksRemaining) || other.weeksRemaining == weeksRemaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,playerId,kind,createdSeasonYear,createdWeek,weeksRemaining);

@override
String toString() {
  return 'TeamTransferSituation(id: $id, playerId: $playerId, kind: $kind, createdSeasonYear: $createdSeasonYear, createdWeek: $createdWeek, weeksRemaining: $weeksRemaining)';
}


}

/// @nodoc
abstract mixin class _$TeamTransferSituationCopyWith<$Res> implements $TeamTransferSituationCopyWith<$Res> {
  factory _$TeamTransferSituationCopyWith(_TeamTransferSituation value, $Res Function(_TeamTransferSituation) _then) = __$TeamTransferSituationCopyWithImpl;
@override @useResult
$Res call({
 String id, String playerId, String kind, int createdSeasonYear, int createdWeek, int weeksRemaining
});




}
/// @nodoc
class __$TeamTransferSituationCopyWithImpl<$Res>
    implements _$TeamTransferSituationCopyWith<$Res> {
  __$TeamTransferSituationCopyWithImpl(this._self, this._then);

  final _TeamTransferSituation _self;
  final $Res Function(_TeamTransferSituation) _then;

/// Create a copy of TeamTransferSituation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? playerId = null,Object? kind = null,Object? createdSeasonYear = null,Object? createdWeek = null,Object? weeksRemaining = null,}) {
  return _then(_TeamTransferSituation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,createdSeasonYear: null == createdSeasonYear ? _self.createdSeasonYear : createdSeasonYear // ignore: cast_nullable_to_non_nullable
as int,createdWeek: null == createdWeek ? _self.createdWeek : createdWeek // ignore: cast_nullable_to_non_nullable
as int,weeksRemaining: null == weeksRemaining ? _self.weeksRemaining : weeksRemaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TeamEventState {

 List<TeamPromise> get promises; List<TeamTransferSituation> get transferSituations; List<MinutesHistoryEntry> get minutesHistory; List<SeasonMinutesAggregate> get seasonMinutes; List<TeamTimedModifier> get modifiers; Map<String, int> get cooldowns; Map<String, int> get seasonFlags; Map<String, double> get pointValueMultipliers; double get publicCriticismRollMultiplier; int get lowAtmosphereWeeks;
/// Create a copy of TeamEventState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamEventStateCopyWith<TeamEventState> get copyWith => _$TeamEventStateCopyWithImpl<TeamEventState>(this as TeamEventState, _$identity);

  /// Serializes this TeamEventState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamEventState&&const DeepCollectionEquality().equals(other.promises, promises)&&const DeepCollectionEquality().equals(other.transferSituations, transferSituations)&&const DeepCollectionEquality().equals(other.minutesHistory, minutesHistory)&&const DeepCollectionEquality().equals(other.seasonMinutes, seasonMinutes)&&const DeepCollectionEquality().equals(other.modifiers, modifiers)&&const DeepCollectionEquality().equals(other.cooldowns, cooldowns)&&const DeepCollectionEquality().equals(other.seasonFlags, seasonFlags)&&const DeepCollectionEquality().equals(other.pointValueMultipliers, pointValueMultipliers)&&(identical(other.publicCriticismRollMultiplier, publicCriticismRollMultiplier) || other.publicCriticismRollMultiplier == publicCriticismRollMultiplier)&&(identical(other.lowAtmosphereWeeks, lowAtmosphereWeeks) || other.lowAtmosphereWeeks == lowAtmosphereWeeks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(promises),const DeepCollectionEquality().hash(transferSituations),const DeepCollectionEquality().hash(minutesHistory),const DeepCollectionEquality().hash(seasonMinutes),const DeepCollectionEquality().hash(modifiers),const DeepCollectionEquality().hash(cooldowns),const DeepCollectionEquality().hash(seasonFlags),const DeepCollectionEquality().hash(pointValueMultipliers),publicCriticismRollMultiplier,lowAtmosphereWeeks);

@override
String toString() {
  return 'TeamEventState(promises: $promises, transferSituations: $transferSituations, minutesHistory: $minutesHistory, seasonMinutes: $seasonMinutes, modifiers: $modifiers, cooldowns: $cooldowns, seasonFlags: $seasonFlags, pointValueMultipliers: $pointValueMultipliers, publicCriticismRollMultiplier: $publicCriticismRollMultiplier, lowAtmosphereWeeks: $lowAtmosphereWeeks)';
}


}

/// @nodoc
abstract mixin class $TeamEventStateCopyWith<$Res>  {
  factory $TeamEventStateCopyWith(TeamEventState value, $Res Function(TeamEventState) _then) = _$TeamEventStateCopyWithImpl;
@useResult
$Res call({
 List<TeamPromise> promises, List<TeamTransferSituation> transferSituations, List<MinutesHistoryEntry> minutesHistory, List<SeasonMinutesAggregate> seasonMinutes, List<TeamTimedModifier> modifiers, Map<String, int> cooldowns, Map<String, int> seasonFlags, Map<String, double> pointValueMultipliers, double publicCriticismRollMultiplier, int lowAtmosphereWeeks
});




}
/// @nodoc
class _$TeamEventStateCopyWithImpl<$Res>
    implements $TeamEventStateCopyWith<$Res> {
  _$TeamEventStateCopyWithImpl(this._self, this._then);

  final TeamEventState _self;
  final $Res Function(TeamEventState) _then;

/// Create a copy of TeamEventState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? promises = null,Object? transferSituations = null,Object? minutesHistory = null,Object? seasonMinutes = null,Object? modifiers = null,Object? cooldowns = null,Object? seasonFlags = null,Object? pointValueMultipliers = null,Object? publicCriticismRollMultiplier = null,Object? lowAtmosphereWeeks = null,}) {
  return _then(_self.copyWith(
promises: null == promises ? _self.promises : promises // ignore: cast_nullable_to_non_nullable
as List<TeamPromise>,transferSituations: null == transferSituations ? _self.transferSituations : transferSituations // ignore: cast_nullable_to_non_nullable
as List<TeamTransferSituation>,minutesHistory: null == minutesHistory ? _self.minutesHistory : minutesHistory // ignore: cast_nullable_to_non_nullable
as List<MinutesHistoryEntry>,seasonMinutes: null == seasonMinutes ? _self.seasonMinutes : seasonMinutes // ignore: cast_nullable_to_non_nullable
as List<SeasonMinutesAggregate>,modifiers: null == modifiers ? _self.modifiers : modifiers // ignore: cast_nullable_to_non_nullable
as List<TeamTimedModifier>,cooldowns: null == cooldowns ? _self.cooldowns : cooldowns // ignore: cast_nullable_to_non_nullable
as Map<String, int>,seasonFlags: null == seasonFlags ? _self.seasonFlags : seasonFlags // ignore: cast_nullable_to_non_nullable
as Map<String, int>,pointValueMultipliers: null == pointValueMultipliers ? _self.pointValueMultipliers : pointValueMultipliers // ignore: cast_nullable_to_non_nullable
as Map<String, double>,publicCriticismRollMultiplier: null == publicCriticismRollMultiplier ? _self.publicCriticismRollMultiplier : publicCriticismRollMultiplier // ignore: cast_nullable_to_non_nullable
as double,lowAtmosphereWeeks: null == lowAtmosphereWeeks ? _self.lowAtmosphereWeeks : lowAtmosphereWeeks // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamEventState].
extension TeamEventStatePatterns on TeamEventState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamEventState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamEventState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamEventState value)  $default,){
final _that = this;
switch (_that) {
case _TeamEventState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamEventState value)?  $default,){
final _that = this;
switch (_that) {
case _TeamEventState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TeamPromise> promises,  List<TeamTransferSituation> transferSituations,  List<MinutesHistoryEntry> minutesHistory,  List<SeasonMinutesAggregate> seasonMinutes,  List<TeamTimedModifier> modifiers,  Map<String, int> cooldowns,  Map<String, int> seasonFlags,  Map<String, double> pointValueMultipliers,  double publicCriticismRollMultiplier,  int lowAtmosphereWeeks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamEventState() when $default != null:
return $default(_that.promises,_that.transferSituations,_that.minutesHistory,_that.seasonMinutes,_that.modifiers,_that.cooldowns,_that.seasonFlags,_that.pointValueMultipliers,_that.publicCriticismRollMultiplier,_that.lowAtmosphereWeeks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TeamPromise> promises,  List<TeamTransferSituation> transferSituations,  List<MinutesHistoryEntry> minutesHistory,  List<SeasonMinutesAggregate> seasonMinutes,  List<TeamTimedModifier> modifiers,  Map<String, int> cooldowns,  Map<String, int> seasonFlags,  Map<String, double> pointValueMultipliers,  double publicCriticismRollMultiplier,  int lowAtmosphereWeeks)  $default,) {final _that = this;
switch (_that) {
case _TeamEventState():
return $default(_that.promises,_that.transferSituations,_that.minutesHistory,_that.seasonMinutes,_that.modifiers,_that.cooldowns,_that.seasonFlags,_that.pointValueMultipliers,_that.publicCriticismRollMultiplier,_that.lowAtmosphereWeeks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TeamPromise> promises,  List<TeamTransferSituation> transferSituations,  List<MinutesHistoryEntry> minutesHistory,  List<SeasonMinutesAggregate> seasonMinutes,  List<TeamTimedModifier> modifiers,  Map<String, int> cooldowns,  Map<String, int> seasonFlags,  Map<String, double> pointValueMultipliers,  double publicCriticismRollMultiplier,  int lowAtmosphereWeeks)?  $default,) {final _that = this;
switch (_that) {
case _TeamEventState() when $default != null:
return $default(_that.promises,_that.transferSituations,_that.minutesHistory,_that.seasonMinutes,_that.modifiers,_that.cooldowns,_that.seasonFlags,_that.pointValueMultipliers,_that.publicCriticismRollMultiplier,_that.lowAtmosphereWeeks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamEventState implements TeamEventState {
  const _TeamEventState({final  List<TeamPromise> promises = const [], final  List<TeamTransferSituation> transferSituations = const [], final  List<MinutesHistoryEntry> minutesHistory = const [], final  List<SeasonMinutesAggregate> seasonMinutes = const [], final  List<TeamTimedModifier> modifiers = const [], final  Map<String, int> cooldowns = const {}, final  Map<String, int> seasonFlags = const {}, final  Map<String, double> pointValueMultipliers = const {}, this.publicCriticismRollMultiplier = 1.0, this.lowAtmosphereWeeks = 0}): _promises = promises,_transferSituations = transferSituations,_minutesHistory = minutesHistory,_seasonMinutes = seasonMinutes,_modifiers = modifiers,_cooldowns = cooldowns,_seasonFlags = seasonFlags,_pointValueMultipliers = pointValueMultipliers;
  factory _TeamEventState.fromJson(Map<String, dynamic> json) => _$TeamEventStateFromJson(json);

 final  List<TeamPromise> _promises;
@override@JsonKey() List<TeamPromise> get promises {
  if (_promises is EqualUnmodifiableListView) return _promises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_promises);
}

 final  List<TeamTransferSituation> _transferSituations;
@override@JsonKey() List<TeamTransferSituation> get transferSituations {
  if (_transferSituations is EqualUnmodifiableListView) return _transferSituations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transferSituations);
}

 final  List<MinutesHistoryEntry> _minutesHistory;
@override@JsonKey() List<MinutesHistoryEntry> get minutesHistory {
  if (_minutesHistory is EqualUnmodifiableListView) return _minutesHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_minutesHistory);
}

 final  List<SeasonMinutesAggregate> _seasonMinutes;
@override@JsonKey() List<SeasonMinutesAggregate> get seasonMinutes {
  if (_seasonMinutes is EqualUnmodifiableListView) return _seasonMinutes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_seasonMinutes);
}

 final  List<TeamTimedModifier> _modifiers;
@override@JsonKey() List<TeamTimedModifier> get modifiers {
  if (_modifiers is EqualUnmodifiableListView) return _modifiers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_modifiers);
}

 final  Map<String, int> _cooldowns;
@override@JsonKey() Map<String, int> get cooldowns {
  if (_cooldowns is EqualUnmodifiableMapView) return _cooldowns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_cooldowns);
}

 final  Map<String, int> _seasonFlags;
@override@JsonKey() Map<String, int> get seasonFlags {
  if (_seasonFlags is EqualUnmodifiableMapView) return _seasonFlags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_seasonFlags);
}

 final  Map<String, double> _pointValueMultipliers;
@override@JsonKey() Map<String, double> get pointValueMultipliers {
  if (_pointValueMultipliers is EqualUnmodifiableMapView) return _pointValueMultipliers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_pointValueMultipliers);
}

@override@JsonKey() final  double publicCriticismRollMultiplier;
@override@JsonKey() final  int lowAtmosphereWeeks;

/// Create a copy of TeamEventState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamEventStateCopyWith<_TeamEventState> get copyWith => __$TeamEventStateCopyWithImpl<_TeamEventState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamEventStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamEventState&&const DeepCollectionEquality().equals(other._promises, _promises)&&const DeepCollectionEquality().equals(other._transferSituations, _transferSituations)&&const DeepCollectionEquality().equals(other._minutesHistory, _minutesHistory)&&const DeepCollectionEquality().equals(other._seasonMinutes, _seasonMinutes)&&const DeepCollectionEquality().equals(other._modifiers, _modifiers)&&const DeepCollectionEquality().equals(other._cooldowns, _cooldowns)&&const DeepCollectionEquality().equals(other._seasonFlags, _seasonFlags)&&const DeepCollectionEquality().equals(other._pointValueMultipliers, _pointValueMultipliers)&&(identical(other.publicCriticismRollMultiplier, publicCriticismRollMultiplier) || other.publicCriticismRollMultiplier == publicCriticismRollMultiplier)&&(identical(other.lowAtmosphereWeeks, lowAtmosphereWeeks) || other.lowAtmosphereWeeks == lowAtmosphereWeeks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_promises),const DeepCollectionEquality().hash(_transferSituations),const DeepCollectionEquality().hash(_minutesHistory),const DeepCollectionEquality().hash(_seasonMinutes),const DeepCollectionEquality().hash(_modifiers),const DeepCollectionEquality().hash(_cooldowns),const DeepCollectionEquality().hash(_seasonFlags),const DeepCollectionEquality().hash(_pointValueMultipliers),publicCriticismRollMultiplier,lowAtmosphereWeeks);

@override
String toString() {
  return 'TeamEventState(promises: $promises, transferSituations: $transferSituations, minutesHistory: $minutesHistory, seasonMinutes: $seasonMinutes, modifiers: $modifiers, cooldowns: $cooldowns, seasonFlags: $seasonFlags, pointValueMultipliers: $pointValueMultipliers, publicCriticismRollMultiplier: $publicCriticismRollMultiplier, lowAtmosphereWeeks: $lowAtmosphereWeeks)';
}


}

/// @nodoc
abstract mixin class _$TeamEventStateCopyWith<$Res> implements $TeamEventStateCopyWith<$Res> {
  factory _$TeamEventStateCopyWith(_TeamEventState value, $Res Function(_TeamEventState) _then) = __$TeamEventStateCopyWithImpl;
@override @useResult
$Res call({
 List<TeamPromise> promises, List<TeamTransferSituation> transferSituations, List<MinutesHistoryEntry> minutesHistory, List<SeasonMinutesAggregate> seasonMinutes, List<TeamTimedModifier> modifiers, Map<String, int> cooldowns, Map<String, int> seasonFlags, Map<String, double> pointValueMultipliers, double publicCriticismRollMultiplier, int lowAtmosphereWeeks
});




}
/// @nodoc
class __$TeamEventStateCopyWithImpl<$Res>
    implements _$TeamEventStateCopyWith<$Res> {
  __$TeamEventStateCopyWithImpl(this._self, this._then);

  final _TeamEventState _self;
  final $Res Function(_TeamEventState) _then;

/// Create a copy of TeamEventState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? promises = null,Object? transferSituations = null,Object? minutesHistory = null,Object? seasonMinutes = null,Object? modifiers = null,Object? cooldowns = null,Object? seasonFlags = null,Object? pointValueMultipliers = null,Object? publicCriticismRollMultiplier = null,Object? lowAtmosphereWeeks = null,}) {
  return _then(_TeamEventState(
promises: null == promises ? _self._promises : promises // ignore: cast_nullable_to_non_nullable
as List<TeamPromise>,transferSituations: null == transferSituations ? _self._transferSituations : transferSituations // ignore: cast_nullable_to_non_nullable
as List<TeamTransferSituation>,minutesHistory: null == minutesHistory ? _self._minutesHistory : minutesHistory // ignore: cast_nullable_to_non_nullable
as List<MinutesHistoryEntry>,seasonMinutes: null == seasonMinutes ? _self._seasonMinutes : seasonMinutes // ignore: cast_nullable_to_non_nullable
as List<SeasonMinutesAggregate>,modifiers: null == modifiers ? _self._modifiers : modifiers // ignore: cast_nullable_to_non_nullable
as List<TeamTimedModifier>,cooldowns: null == cooldowns ? _self._cooldowns : cooldowns // ignore: cast_nullable_to_non_nullable
as Map<String, int>,seasonFlags: null == seasonFlags ? _self._seasonFlags : seasonFlags // ignore: cast_nullable_to_non_nullable
as Map<String, int>,pointValueMultipliers: null == pointValueMultipliers ? _self._pointValueMultipliers : pointValueMultipliers // ignore: cast_nullable_to_non_nullable
as Map<String, double>,publicCriticismRollMultiplier: null == publicCriticismRollMultiplier ? _self.publicCriticismRollMultiplier : publicCriticismRollMultiplier // ignore: cast_nullable_to_non_nullable
as double,lowAtmosphereWeeks: null == lowAtmosphereWeeks ? _self.lowAtmosphereWeeks : lowAtmosphereWeeks // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
