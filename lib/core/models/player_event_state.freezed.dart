// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_event_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimedModifier {

 String get type; double get value; int get weeksRemaining;
/// Create a copy of TimedModifier
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimedModifierCopyWith<TimedModifier> get copyWith => _$TimedModifierCopyWithImpl<TimedModifier>(this as TimedModifier, _$identity);

  /// Serializes this TimedModifier to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimedModifier&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value)&&(identical(other.weeksRemaining, weeksRemaining) || other.weeksRemaining == weeksRemaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,value,weeksRemaining);

@override
String toString() {
  return 'TimedModifier(type: $type, value: $value, weeksRemaining: $weeksRemaining)';
}


}

/// @nodoc
abstract mixin class $TimedModifierCopyWith<$Res>  {
  factory $TimedModifierCopyWith(TimedModifier value, $Res Function(TimedModifier) _then) = _$TimedModifierCopyWithImpl;
@useResult
$Res call({
 String type, double value, int weeksRemaining
});




}
/// @nodoc
class _$TimedModifierCopyWithImpl<$Res>
    implements $TimedModifierCopyWith<$Res> {
  _$TimedModifierCopyWithImpl(this._self, this._then);

  final TimedModifier _self;
  final $Res Function(TimedModifier) _then;

/// Create a copy of TimedModifier
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


/// Adds pattern-matching-related methods to [TimedModifier].
extension TimedModifierPatterns on TimedModifier {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimedModifier value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimedModifier() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimedModifier value)  $default,){
final _that = this;
switch (_that) {
case _TimedModifier():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimedModifier value)?  $default,){
final _that = this;
switch (_that) {
case _TimedModifier() when $default != null:
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
case _TimedModifier() when $default != null:
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
case _TimedModifier():
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
case _TimedModifier() when $default != null:
return $default(_that.type,_that.value,_that.weeksRemaining);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimedModifier implements TimedModifier {
  const _TimedModifier({required this.type, required this.value, required this.weeksRemaining});
  factory _TimedModifier.fromJson(Map<String, dynamic> json) => _$TimedModifierFromJson(json);

@override final  String type;
@override final  double value;
@override final  int weeksRemaining;

/// Create a copy of TimedModifier
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimedModifierCopyWith<_TimedModifier> get copyWith => __$TimedModifierCopyWithImpl<_TimedModifier>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimedModifierToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimedModifier&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value)&&(identical(other.weeksRemaining, weeksRemaining) || other.weeksRemaining == weeksRemaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,value,weeksRemaining);

@override
String toString() {
  return 'TimedModifier(type: $type, value: $value, weeksRemaining: $weeksRemaining)';
}


}

/// @nodoc
abstract mixin class _$TimedModifierCopyWith<$Res> implements $TimedModifierCopyWith<$Res> {
  factory _$TimedModifierCopyWith(_TimedModifier value, $Res Function(_TimedModifier) _then) = __$TimedModifierCopyWithImpl;
@override @useResult
$Res call({
 String type, double value, int weeksRemaining
});




}
/// @nodoc
class __$TimedModifierCopyWithImpl<$Res>
    implements _$TimedModifierCopyWith<$Res> {
  __$TimedModifierCopyWithImpl(this._self, this._then);

  final _TimedModifier _self;
  final $Res Function(_TimedModifier) _then;

/// Create a copy of TimedModifier
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? value = null,Object? weeksRemaining = null,}) {
  return _then(_TimedModifier(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,weeksRemaining: null == weeksRemaining ? _self.weeksRemaining : weeksRemaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PlayerEventState {

 List<TimedModifier> get modifiers; Map<String, int> get cooldowns; Map<String, int> get counters; bool get lateBloomerTriggered; Injury? get lastMajorInjury; bool get majorInjuryActiveLastTick; int get weeksSinceMajorInjury; bool get personalProblemsFollowUpPending;
/// Create a copy of PlayerEventState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerEventStateCopyWith<PlayerEventState> get copyWith => _$PlayerEventStateCopyWithImpl<PlayerEventState>(this as PlayerEventState, _$identity);

  /// Serializes this PlayerEventState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerEventState&&const DeepCollectionEquality().equals(other.modifiers, modifiers)&&const DeepCollectionEquality().equals(other.cooldowns, cooldowns)&&const DeepCollectionEquality().equals(other.counters, counters)&&(identical(other.lateBloomerTriggered, lateBloomerTriggered) || other.lateBloomerTriggered == lateBloomerTriggered)&&(identical(other.lastMajorInjury, lastMajorInjury) || other.lastMajorInjury == lastMajorInjury)&&(identical(other.majorInjuryActiveLastTick, majorInjuryActiveLastTick) || other.majorInjuryActiveLastTick == majorInjuryActiveLastTick)&&(identical(other.weeksSinceMajorInjury, weeksSinceMajorInjury) || other.weeksSinceMajorInjury == weeksSinceMajorInjury)&&(identical(other.personalProblemsFollowUpPending, personalProblemsFollowUpPending) || other.personalProblemsFollowUpPending == personalProblemsFollowUpPending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(modifiers),const DeepCollectionEquality().hash(cooldowns),const DeepCollectionEquality().hash(counters),lateBloomerTriggered,lastMajorInjury,majorInjuryActiveLastTick,weeksSinceMajorInjury,personalProblemsFollowUpPending);

@override
String toString() {
  return 'PlayerEventState(modifiers: $modifiers, cooldowns: $cooldowns, counters: $counters, lateBloomerTriggered: $lateBloomerTriggered, lastMajorInjury: $lastMajorInjury, majorInjuryActiveLastTick: $majorInjuryActiveLastTick, weeksSinceMajorInjury: $weeksSinceMajorInjury, personalProblemsFollowUpPending: $personalProblemsFollowUpPending)';
}


}

/// @nodoc
abstract mixin class $PlayerEventStateCopyWith<$Res>  {
  factory $PlayerEventStateCopyWith(PlayerEventState value, $Res Function(PlayerEventState) _then) = _$PlayerEventStateCopyWithImpl;
@useResult
$Res call({
 List<TimedModifier> modifiers, Map<String, int> cooldowns, Map<String, int> counters, bool lateBloomerTriggered, Injury? lastMajorInjury, bool majorInjuryActiveLastTick, int weeksSinceMajorInjury, bool personalProblemsFollowUpPending
});


$InjuryCopyWith<$Res>? get lastMajorInjury;

}
/// @nodoc
class _$PlayerEventStateCopyWithImpl<$Res>
    implements $PlayerEventStateCopyWith<$Res> {
  _$PlayerEventStateCopyWithImpl(this._self, this._then);

  final PlayerEventState _self;
  final $Res Function(PlayerEventState) _then;

/// Create a copy of PlayerEventState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? modifiers = null,Object? cooldowns = null,Object? counters = null,Object? lateBloomerTriggered = null,Object? lastMajorInjury = freezed,Object? majorInjuryActiveLastTick = null,Object? weeksSinceMajorInjury = null,Object? personalProblemsFollowUpPending = null,}) {
  return _then(_self.copyWith(
modifiers: null == modifiers ? _self.modifiers : modifiers // ignore: cast_nullable_to_non_nullable
as List<TimedModifier>,cooldowns: null == cooldowns ? _self.cooldowns : cooldowns // ignore: cast_nullable_to_non_nullable
as Map<String, int>,counters: null == counters ? _self.counters : counters // ignore: cast_nullable_to_non_nullable
as Map<String, int>,lateBloomerTriggered: null == lateBloomerTriggered ? _self.lateBloomerTriggered : lateBloomerTriggered // ignore: cast_nullable_to_non_nullable
as bool,lastMajorInjury: freezed == lastMajorInjury ? _self.lastMajorInjury : lastMajorInjury // ignore: cast_nullable_to_non_nullable
as Injury?,majorInjuryActiveLastTick: null == majorInjuryActiveLastTick ? _self.majorInjuryActiveLastTick : majorInjuryActiveLastTick // ignore: cast_nullable_to_non_nullable
as bool,weeksSinceMajorInjury: null == weeksSinceMajorInjury ? _self.weeksSinceMajorInjury : weeksSinceMajorInjury // ignore: cast_nullable_to_non_nullable
as int,personalProblemsFollowUpPending: null == personalProblemsFollowUpPending ? _self.personalProblemsFollowUpPending : personalProblemsFollowUpPending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of PlayerEventState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InjuryCopyWith<$Res>? get lastMajorInjury {
    if (_self.lastMajorInjury == null) {
    return null;
  }

  return $InjuryCopyWith<$Res>(_self.lastMajorInjury!, (value) {
    return _then(_self.copyWith(lastMajorInjury: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayerEventState].
extension PlayerEventStatePatterns on PlayerEventState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerEventState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerEventState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerEventState value)  $default,){
final _that = this;
switch (_that) {
case _PlayerEventState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerEventState value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerEventState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TimedModifier> modifiers,  Map<String, int> cooldowns,  Map<String, int> counters,  bool lateBloomerTriggered,  Injury? lastMajorInjury,  bool majorInjuryActiveLastTick,  int weeksSinceMajorInjury,  bool personalProblemsFollowUpPending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerEventState() when $default != null:
return $default(_that.modifiers,_that.cooldowns,_that.counters,_that.lateBloomerTriggered,_that.lastMajorInjury,_that.majorInjuryActiveLastTick,_that.weeksSinceMajorInjury,_that.personalProblemsFollowUpPending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TimedModifier> modifiers,  Map<String, int> cooldowns,  Map<String, int> counters,  bool lateBloomerTriggered,  Injury? lastMajorInjury,  bool majorInjuryActiveLastTick,  int weeksSinceMajorInjury,  bool personalProblemsFollowUpPending)  $default,) {final _that = this;
switch (_that) {
case _PlayerEventState():
return $default(_that.modifiers,_that.cooldowns,_that.counters,_that.lateBloomerTriggered,_that.lastMajorInjury,_that.majorInjuryActiveLastTick,_that.weeksSinceMajorInjury,_that.personalProblemsFollowUpPending);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TimedModifier> modifiers,  Map<String, int> cooldowns,  Map<String, int> counters,  bool lateBloomerTriggered,  Injury? lastMajorInjury,  bool majorInjuryActiveLastTick,  int weeksSinceMajorInjury,  bool personalProblemsFollowUpPending)?  $default,) {final _that = this;
switch (_that) {
case _PlayerEventState() when $default != null:
return $default(_that.modifiers,_that.cooldowns,_that.counters,_that.lateBloomerTriggered,_that.lastMajorInjury,_that.majorInjuryActiveLastTick,_that.weeksSinceMajorInjury,_that.personalProblemsFollowUpPending);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayerEventState implements PlayerEventState {
  const _PlayerEventState({final  List<TimedModifier> modifiers = const [], final  Map<String, int> cooldowns = const {}, final  Map<String, int> counters = const {}, this.lateBloomerTriggered = false, this.lastMajorInjury, this.majorInjuryActiveLastTick = false, this.weeksSinceMajorInjury = 0, this.personalProblemsFollowUpPending = false}): _modifiers = modifiers,_cooldowns = cooldowns,_counters = counters;
  factory _PlayerEventState.fromJson(Map<String, dynamic> json) => _$PlayerEventStateFromJson(json);

 final  List<TimedModifier> _modifiers;
@override@JsonKey() List<TimedModifier> get modifiers {
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

 final  Map<String, int> _counters;
@override@JsonKey() Map<String, int> get counters {
  if (_counters is EqualUnmodifiableMapView) return _counters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_counters);
}

@override@JsonKey() final  bool lateBloomerTriggered;
@override final  Injury? lastMajorInjury;
@override@JsonKey() final  bool majorInjuryActiveLastTick;
@override@JsonKey() final  int weeksSinceMajorInjury;
@override@JsonKey() final  bool personalProblemsFollowUpPending;

/// Create a copy of PlayerEventState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerEventStateCopyWith<_PlayerEventState> get copyWith => __$PlayerEventStateCopyWithImpl<_PlayerEventState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerEventStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerEventState&&const DeepCollectionEquality().equals(other._modifiers, _modifiers)&&const DeepCollectionEquality().equals(other._cooldowns, _cooldowns)&&const DeepCollectionEquality().equals(other._counters, _counters)&&(identical(other.lateBloomerTriggered, lateBloomerTriggered) || other.lateBloomerTriggered == lateBloomerTriggered)&&(identical(other.lastMajorInjury, lastMajorInjury) || other.lastMajorInjury == lastMajorInjury)&&(identical(other.majorInjuryActiveLastTick, majorInjuryActiveLastTick) || other.majorInjuryActiveLastTick == majorInjuryActiveLastTick)&&(identical(other.weeksSinceMajorInjury, weeksSinceMajorInjury) || other.weeksSinceMajorInjury == weeksSinceMajorInjury)&&(identical(other.personalProblemsFollowUpPending, personalProblemsFollowUpPending) || other.personalProblemsFollowUpPending == personalProblemsFollowUpPending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_modifiers),const DeepCollectionEquality().hash(_cooldowns),const DeepCollectionEquality().hash(_counters),lateBloomerTriggered,lastMajorInjury,majorInjuryActiveLastTick,weeksSinceMajorInjury,personalProblemsFollowUpPending);

@override
String toString() {
  return 'PlayerEventState(modifiers: $modifiers, cooldowns: $cooldowns, counters: $counters, lateBloomerTriggered: $lateBloomerTriggered, lastMajorInjury: $lastMajorInjury, majorInjuryActiveLastTick: $majorInjuryActiveLastTick, weeksSinceMajorInjury: $weeksSinceMajorInjury, personalProblemsFollowUpPending: $personalProblemsFollowUpPending)';
}


}

/// @nodoc
abstract mixin class _$PlayerEventStateCopyWith<$Res> implements $PlayerEventStateCopyWith<$Res> {
  factory _$PlayerEventStateCopyWith(_PlayerEventState value, $Res Function(_PlayerEventState) _then) = __$PlayerEventStateCopyWithImpl;
@override @useResult
$Res call({
 List<TimedModifier> modifiers, Map<String, int> cooldowns, Map<String, int> counters, bool lateBloomerTriggered, Injury? lastMajorInjury, bool majorInjuryActiveLastTick, int weeksSinceMajorInjury, bool personalProblemsFollowUpPending
});


@override $InjuryCopyWith<$Res>? get lastMajorInjury;

}
/// @nodoc
class __$PlayerEventStateCopyWithImpl<$Res>
    implements _$PlayerEventStateCopyWith<$Res> {
  __$PlayerEventStateCopyWithImpl(this._self, this._then);

  final _PlayerEventState _self;
  final $Res Function(_PlayerEventState) _then;

/// Create a copy of PlayerEventState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? modifiers = null,Object? cooldowns = null,Object? counters = null,Object? lateBloomerTriggered = null,Object? lastMajorInjury = freezed,Object? majorInjuryActiveLastTick = null,Object? weeksSinceMajorInjury = null,Object? personalProblemsFollowUpPending = null,}) {
  return _then(_PlayerEventState(
modifiers: null == modifiers ? _self._modifiers : modifiers // ignore: cast_nullable_to_non_nullable
as List<TimedModifier>,cooldowns: null == cooldowns ? _self._cooldowns : cooldowns // ignore: cast_nullable_to_non_nullable
as Map<String, int>,counters: null == counters ? _self._counters : counters // ignore: cast_nullable_to_non_nullable
as Map<String, int>,lateBloomerTriggered: null == lateBloomerTriggered ? _self.lateBloomerTriggered : lateBloomerTriggered // ignore: cast_nullable_to_non_nullable
as bool,lastMajorInjury: freezed == lastMajorInjury ? _self.lastMajorInjury : lastMajorInjury // ignore: cast_nullable_to_non_nullable
as Injury?,majorInjuryActiveLastTick: null == majorInjuryActiveLastTick ? _self.majorInjuryActiveLastTick : majorInjuryActiveLastTick // ignore: cast_nullable_to_non_nullable
as bool,weeksSinceMajorInjury: null == weeksSinceMajorInjury ? _self.weeksSinceMajorInjury : weeksSinceMajorInjury // ignore: cast_nullable_to_non_nullable
as int,personalProblemsFollowUpPending: null == personalProblemsFollowUpPending ? _self.personalProblemsFollowUpPending : personalProblemsFollowUpPending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PlayerEventState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InjuryCopyWith<$Res>? get lastMajorInjury {
    if (_self.lastMajorInjury == null) {
    return null;
  }

  return $InjuryCopyWith<$Res>(_self.lastMajorInjury!, (value) {
    return _then(_self.copyWith(lastMajorInjury: value));
  });
}
}

// dart format on
