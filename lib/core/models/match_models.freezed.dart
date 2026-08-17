// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MatchEvent {

 MatchEventType get type; int get minute; String get teamId; String? get playerId; String? get description;
/// Create a copy of MatchEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchEventCopyWith<MatchEvent> get copyWith => _$MatchEventCopyWithImpl<MatchEvent>(this as MatchEvent, _$identity);

  /// Serializes this MatchEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchEvent&&(identical(other.type, type) || other.type == type)&&(identical(other.minute, minute) || other.minute == minute)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,minute,teamId,playerId,description);

@override
String toString() {
  return 'MatchEvent(type: $type, minute: $minute, teamId: $teamId, playerId: $playerId, description: $description)';
}


}

/// @nodoc
abstract mixin class $MatchEventCopyWith<$Res>  {
  factory $MatchEventCopyWith(MatchEvent value, $Res Function(MatchEvent) _then) = _$MatchEventCopyWithImpl;
@useResult
$Res call({
 MatchEventType type, int minute, String teamId, String? playerId, String? description
});




}
/// @nodoc
class _$MatchEventCopyWithImpl<$Res>
    implements $MatchEventCopyWith<$Res> {
  _$MatchEventCopyWithImpl(this._self, this._then);

  final MatchEvent _self;
  final $Res Function(MatchEvent) _then;

/// Create a copy of MatchEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? minute = null,Object? teamId = null,Object? playerId = freezed,Object? description = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MatchEventType,minute: null == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,playerId: freezed == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchEvent].
extension MatchEventPatterns on MatchEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchEvent value)  $default,){
final _that = this;
switch (_that) {
case _MatchEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchEvent value)?  $default,){
final _that = this;
switch (_that) {
case _MatchEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MatchEventType type,  int minute,  String teamId,  String? playerId,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchEvent() when $default != null:
return $default(_that.type,_that.minute,_that.teamId,_that.playerId,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MatchEventType type,  int minute,  String teamId,  String? playerId,  String? description)  $default,) {final _that = this;
switch (_that) {
case _MatchEvent():
return $default(_that.type,_that.minute,_that.teamId,_that.playerId,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MatchEventType type,  int minute,  String teamId,  String? playerId,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _MatchEvent() when $default != null:
return $default(_that.type,_that.minute,_that.teamId,_that.playerId,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatchEvent implements MatchEvent {
  const _MatchEvent({required this.type, required this.minute, required this.teamId, this.playerId, this.description});
  factory _MatchEvent.fromJson(Map<String, dynamic> json) => _$MatchEventFromJson(json);

@override final  MatchEventType type;
@override final  int minute;
@override final  String teamId;
@override final  String? playerId;
@override final  String? description;

/// Create a copy of MatchEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchEventCopyWith<_MatchEvent> get copyWith => __$MatchEventCopyWithImpl<_MatchEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchEvent&&(identical(other.type, type) || other.type == type)&&(identical(other.minute, minute) || other.minute == minute)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,minute,teamId,playerId,description);

@override
String toString() {
  return 'MatchEvent(type: $type, minute: $minute, teamId: $teamId, playerId: $playerId, description: $description)';
}


}

/// @nodoc
abstract mixin class _$MatchEventCopyWith<$Res> implements $MatchEventCopyWith<$Res> {
  factory _$MatchEventCopyWith(_MatchEvent value, $Res Function(_MatchEvent) _then) = __$MatchEventCopyWithImpl;
@override @useResult
$Res call({
 MatchEventType type, int minute, String teamId, String? playerId, String? description
});




}
/// @nodoc
class __$MatchEventCopyWithImpl<$Res>
    implements _$MatchEventCopyWith<$Res> {
  __$MatchEventCopyWithImpl(this._self, this._then);

  final _MatchEvent _self;
  final $Res Function(_MatchEvent) _then;

/// Create a copy of MatchEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? minute = null,Object? teamId = null,Object? playerId = freezed,Object? description = freezed,}) {
  return _then(_MatchEvent(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MatchEventType,minute: null == minute ? _self.minute : minute // ignore: cast_nullable_to_non_nullable
as int,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,playerId: freezed == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MatchInjury {

 String get teamId; String get playerId; Injury get injury; bool get playerInStartingXi; bool get potentialLoss;
/// Create a copy of MatchInjury
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchInjuryCopyWith<MatchInjury> get copyWith => _$MatchInjuryCopyWithImpl<MatchInjury>(this as MatchInjury, _$identity);

  /// Serializes this MatchInjury to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchInjury&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.injury, injury) || other.injury == injury)&&(identical(other.playerInStartingXi, playerInStartingXi) || other.playerInStartingXi == playerInStartingXi)&&(identical(other.potentialLoss, potentialLoss) || other.potentialLoss == potentialLoss));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamId,playerId,injury,playerInStartingXi,potentialLoss);

@override
String toString() {
  return 'MatchInjury(teamId: $teamId, playerId: $playerId, injury: $injury, playerInStartingXi: $playerInStartingXi, potentialLoss: $potentialLoss)';
}


}

/// @nodoc
abstract mixin class $MatchInjuryCopyWith<$Res>  {
  factory $MatchInjuryCopyWith(MatchInjury value, $Res Function(MatchInjury) _then) = _$MatchInjuryCopyWithImpl;
@useResult
$Res call({
 String teamId, String playerId, Injury injury, bool playerInStartingXi, bool potentialLoss
});


$InjuryCopyWith<$Res> get injury;

}
/// @nodoc
class _$MatchInjuryCopyWithImpl<$Res>
    implements $MatchInjuryCopyWith<$Res> {
  _$MatchInjuryCopyWithImpl(this._self, this._then);

  final MatchInjury _self;
  final $Res Function(MatchInjury) _then;

/// Create a copy of MatchInjury
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? teamId = null,Object? playerId = null,Object? injury = null,Object? playerInStartingXi = null,Object? potentialLoss = null,}) {
  return _then(_self.copyWith(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,injury: null == injury ? _self.injury : injury // ignore: cast_nullable_to_non_nullable
as Injury,playerInStartingXi: null == playerInStartingXi ? _self.playerInStartingXi : playerInStartingXi // ignore: cast_nullable_to_non_nullable
as bool,potentialLoss: null == potentialLoss ? _self.potentialLoss : potentialLoss // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of MatchInjury
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InjuryCopyWith<$Res> get injury {
  
  return $InjuryCopyWith<$Res>(_self.injury, (value) {
    return _then(_self.copyWith(injury: value));
  });
}
}


/// Adds pattern-matching-related methods to [MatchInjury].
extension MatchInjuryPatterns on MatchInjury {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchInjury value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchInjury() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchInjury value)  $default,){
final _that = this;
switch (_that) {
case _MatchInjury():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchInjury value)?  $default,){
final _that = this;
switch (_that) {
case _MatchInjury() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String teamId,  String playerId,  Injury injury,  bool playerInStartingXi,  bool potentialLoss)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchInjury() when $default != null:
return $default(_that.teamId,_that.playerId,_that.injury,_that.playerInStartingXi,_that.potentialLoss);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String teamId,  String playerId,  Injury injury,  bool playerInStartingXi,  bool potentialLoss)  $default,) {final _that = this;
switch (_that) {
case _MatchInjury():
return $default(_that.teamId,_that.playerId,_that.injury,_that.playerInStartingXi,_that.potentialLoss);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String teamId,  String playerId,  Injury injury,  bool playerInStartingXi,  bool potentialLoss)?  $default,) {final _that = this;
switch (_that) {
case _MatchInjury() when $default != null:
return $default(_that.teamId,_that.playerId,_that.injury,_that.playerInStartingXi,_that.potentialLoss);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatchInjury implements MatchInjury {
  const _MatchInjury({required this.teamId, required this.playerId, required this.injury, required this.playerInStartingXi, this.potentialLoss = false});
  factory _MatchInjury.fromJson(Map<String, dynamic> json) => _$MatchInjuryFromJson(json);

@override final  String teamId;
@override final  String playerId;
@override final  Injury injury;
@override final  bool playerInStartingXi;
@override@JsonKey() final  bool potentialLoss;

/// Create a copy of MatchInjury
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchInjuryCopyWith<_MatchInjury> get copyWith => __$MatchInjuryCopyWithImpl<_MatchInjury>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchInjuryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchInjury&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.injury, injury) || other.injury == injury)&&(identical(other.playerInStartingXi, playerInStartingXi) || other.playerInStartingXi == playerInStartingXi)&&(identical(other.potentialLoss, potentialLoss) || other.potentialLoss == potentialLoss));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamId,playerId,injury,playerInStartingXi,potentialLoss);

@override
String toString() {
  return 'MatchInjury(teamId: $teamId, playerId: $playerId, injury: $injury, playerInStartingXi: $playerInStartingXi, potentialLoss: $potentialLoss)';
}


}

/// @nodoc
abstract mixin class _$MatchInjuryCopyWith<$Res> implements $MatchInjuryCopyWith<$Res> {
  factory _$MatchInjuryCopyWith(_MatchInjury value, $Res Function(_MatchInjury) _then) = __$MatchInjuryCopyWithImpl;
@override @useResult
$Res call({
 String teamId, String playerId, Injury injury, bool playerInStartingXi, bool potentialLoss
});


@override $InjuryCopyWith<$Res> get injury;

}
/// @nodoc
class __$MatchInjuryCopyWithImpl<$Res>
    implements _$MatchInjuryCopyWith<$Res> {
  __$MatchInjuryCopyWithImpl(this._self, this._then);

  final _MatchInjury _self;
  final $Res Function(_MatchInjury) _then;

/// Create a copy of MatchInjury
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? teamId = null,Object? playerId = null,Object? injury = null,Object? playerInStartingXi = null,Object? potentialLoss = null,}) {
  return _then(_MatchInjury(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,injury: null == injury ? _self.injury : injury // ignore: cast_nullable_to_non_nullable
as Injury,playerInStartingXi: null == playerInStartingXi ? _self.playerInStartingXi : playerInStartingXi // ignore: cast_nullable_to_non_nullable
as bool,potentialLoss: null == potentialLoss ? _self.potentialLoss : potentialLoss // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of MatchInjury
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InjuryCopyWith<$Res> get injury {
  
  return $InjuryCopyWith<$Res>(_self.injury, (value) {
    return _then(_self.copyWith(injury: value));
  });
}
}


/// @nodoc
mixin _$MatchDiscipline {

 String get teamId; String get playerId; int get yellowCardsInMatch; RedCardKind get redCardKind; int get directRedSeverity; bool get playerInStartingXi;
/// Create a copy of MatchDiscipline
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchDisciplineCopyWith<MatchDiscipline> get copyWith => _$MatchDisciplineCopyWithImpl<MatchDiscipline>(this as MatchDiscipline, _$identity);

  /// Serializes this MatchDiscipline to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchDiscipline&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.yellowCardsInMatch, yellowCardsInMatch) || other.yellowCardsInMatch == yellowCardsInMatch)&&(identical(other.redCardKind, redCardKind) || other.redCardKind == redCardKind)&&(identical(other.directRedSeverity, directRedSeverity) || other.directRedSeverity == directRedSeverity)&&(identical(other.playerInStartingXi, playerInStartingXi) || other.playerInStartingXi == playerInStartingXi));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamId,playerId,yellowCardsInMatch,redCardKind,directRedSeverity,playerInStartingXi);

@override
String toString() {
  return 'MatchDiscipline(teamId: $teamId, playerId: $playerId, yellowCardsInMatch: $yellowCardsInMatch, redCardKind: $redCardKind, directRedSeverity: $directRedSeverity, playerInStartingXi: $playerInStartingXi)';
}


}

/// @nodoc
abstract mixin class $MatchDisciplineCopyWith<$Res>  {
  factory $MatchDisciplineCopyWith(MatchDiscipline value, $Res Function(MatchDiscipline) _then) = _$MatchDisciplineCopyWithImpl;
@useResult
$Res call({
 String teamId, String playerId, int yellowCardsInMatch, RedCardKind redCardKind, int directRedSeverity, bool playerInStartingXi
});




}
/// @nodoc
class _$MatchDisciplineCopyWithImpl<$Res>
    implements $MatchDisciplineCopyWith<$Res> {
  _$MatchDisciplineCopyWithImpl(this._self, this._then);

  final MatchDiscipline _self;
  final $Res Function(MatchDiscipline) _then;

/// Create a copy of MatchDiscipline
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? teamId = null,Object? playerId = null,Object? yellowCardsInMatch = null,Object? redCardKind = null,Object? directRedSeverity = null,Object? playerInStartingXi = null,}) {
  return _then(_self.copyWith(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,yellowCardsInMatch: null == yellowCardsInMatch ? _self.yellowCardsInMatch : yellowCardsInMatch // ignore: cast_nullable_to_non_nullable
as int,redCardKind: null == redCardKind ? _self.redCardKind : redCardKind // ignore: cast_nullable_to_non_nullable
as RedCardKind,directRedSeverity: null == directRedSeverity ? _self.directRedSeverity : directRedSeverity // ignore: cast_nullable_to_non_nullable
as int,playerInStartingXi: null == playerInStartingXi ? _self.playerInStartingXi : playerInStartingXi // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchDiscipline].
extension MatchDisciplinePatterns on MatchDiscipline {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchDiscipline value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchDiscipline() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchDiscipline value)  $default,){
final _that = this;
switch (_that) {
case _MatchDiscipline():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchDiscipline value)?  $default,){
final _that = this;
switch (_that) {
case _MatchDiscipline() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String teamId,  String playerId,  int yellowCardsInMatch,  RedCardKind redCardKind,  int directRedSeverity,  bool playerInStartingXi)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchDiscipline() when $default != null:
return $default(_that.teamId,_that.playerId,_that.yellowCardsInMatch,_that.redCardKind,_that.directRedSeverity,_that.playerInStartingXi);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String teamId,  String playerId,  int yellowCardsInMatch,  RedCardKind redCardKind,  int directRedSeverity,  bool playerInStartingXi)  $default,) {final _that = this;
switch (_that) {
case _MatchDiscipline():
return $default(_that.teamId,_that.playerId,_that.yellowCardsInMatch,_that.redCardKind,_that.directRedSeverity,_that.playerInStartingXi);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String teamId,  String playerId,  int yellowCardsInMatch,  RedCardKind redCardKind,  int directRedSeverity,  bool playerInStartingXi)?  $default,) {final _that = this;
switch (_that) {
case _MatchDiscipline() when $default != null:
return $default(_that.teamId,_that.playerId,_that.yellowCardsInMatch,_that.redCardKind,_that.directRedSeverity,_that.playerInStartingXi);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatchDiscipline implements MatchDiscipline {
  const _MatchDiscipline({required this.teamId, required this.playerId, this.yellowCardsInMatch = 0, this.redCardKind = RedCardKind.none, this.directRedSeverity = 0, this.playerInStartingXi = false});
  factory _MatchDiscipline.fromJson(Map<String, dynamic> json) => _$MatchDisciplineFromJson(json);

@override final  String teamId;
@override final  String playerId;
@override@JsonKey() final  int yellowCardsInMatch;
@override@JsonKey() final  RedCardKind redCardKind;
@override@JsonKey() final  int directRedSeverity;
@override@JsonKey() final  bool playerInStartingXi;

/// Create a copy of MatchDiscipline
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchDisciplineCopyWith<_MatchDiscipline> get copyWith => __$MatchDisciplineCopyWithImpl<_MatchDiscipline>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchDisciplineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchDiscipline&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.yellowCardsInMatch, yellowCardsInMatch) || other.yellowCardsInMatch == yellowCardsInMatch)&&(identical(other.redCardKind, redCardKind) || other.redCardKind == redCardKind)&&(identical(other.directRedSeverity, directRedSeverity) || other.directRedSeverity == directRedSeverity)&&(identical(other.playerInStartingXi, playerInStartingXi) || other.playerInStartingXi == playerInStartingXi));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamId,playerId,yellowCardsInMatch,redCardKind,directRedSeverity,playerInStartingXi);

@override
String toString() {
  return 'MatchDiscipline(teamId: $teamId, playerId: $playerId, yellowCardsInMatch: $yellowCardsInMatch, redCardKind: $redCardKind, directRedSeverity: $directRedSeverity, playerInStartingXi: $playerInStartingXi)';
}


}

/// @nodoc
abstract mixin class _$MatchDisciplineCopyWith<$Res> implements $MatchDisciplineCopyWith<$Res> {
  factory _$MatchDisciplineCopyWith(_MatchDiscipline value, $Res Function(_MatchDiscipline) _then) = __$MatchDisciplineCopyWithImpl;
@override @useResult
$Res call({
 String teamId, String playerId, int yellowCardsInMatch, RedCardKind redCardKind, int directRedSeverity, bool playerInStartingXi
});




}
/// @nodoc
class __$MatchDisciplineCopyWithImpl<$Res>
    implements _$MatchDisciplineCopyWith<$Res> {
  __$MatchDisciplineCopyWithImpl(this._self, this._then);

  final _MatchDiscipline _self;
  final $Res Function(_MatchDiscipline) _then;

/// Create a copy of MatchDiscipline
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? teamId = null,Object? playerId = null,Object? yellowCardsInMatch = null,Object? redCardKind = null,Object? directRedSeverity = null,Object? playerInStartingXi = null,}) {
  return _then(_MatchDiscipline(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,yellowCardsInMatch: null == yellowCardsInMatch ? _self.yellowCardsInMatch : yellowCardsInMatch // ignore: cast_nullable_to_non_nullable
as int,redCardKind: null == redCardKind ? _self.redCardKind : redCardKind // ignore: cast_nullable_to_non_nullable
as RedCardKind,directRedSeverity: null == directRedSeverity ? _self.directRedSeverity : directRedSeverity // ignore: cast_nullable_to_non_nullable
as int,playerInStartingXi: null == playerInStartingXi ? _self.playerInStartingXi : playerInStartingXi // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$TeamMatchStats {

 String get teamId; int get goals; int get shots; int get shotsOnTarget; int get possession; double get xg; int get passes; double get passAccuracy; int get duelsWon; int get offsides; int get corners; int get fouls; int get yellowCards; int get redCards; int get saves;
/// Create a copy of TeamMatchStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamMatchStatsCopyWith<TeamMatchStats> get copyWith => _$TeamMatchStatsCopyWithImpl<TeamMatchStats>(this as TeamMatchStats, _$identity);

  /// Serializes this TeamMatchStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamMatchStats&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.goals, goals) || other.goals == goals)&&(identical(other.shots, shots) || other.shots == shots)&&(identical(other.shotsOnTarget, shotsOnTarget) || other.shotsOnTarget == shotsOnTarget)&&(identical(other.possession, possession) || other.possession == possession)&&(identical(other.xg, xg) || other.xg == xg)&&(identical(other.passes, passes) || other.passes == passes)&&(identical(other.passAccuracy, passAccuracy) || other.passAccuracy == passAccuracy)&&(identical(other.duelsWon, duelsWon) || other.duelsWon == duelsWon)&&(identical(other.offsides, offsides) || other.offsides == offsides)&&(identical(other.corners, corners) || other.corners == corners)&&(identical(other.fouls, fouls) || other.fouls == fouls)&&(identical(other.yellowCards, yellowCards) || other.yellowCards == yellowCards)&&(identical(other.redCards, redCards) || other.redCards == redCards)&&(identical(other.saves, saves) || other.saves == saves));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamId,goals,shots,shotsOnTarget,possession,xg,passes,passAccuracy,duelsWon,offsides,corners,fouls,yellowCards,redCards,saves);

@override
String toString() {
  return 'TeamMatchStats(teamId: $teamId, goals: $goals, shots: $shots, shotsOnTarget: $shotsOnTarget, possession: $possession, xg: $xg, passes: $passes, passAccuracy: $passAccuracy, duelsWon: $duelsWon, offsides: $offsides, corners: $corners, fouls: $fouls, yellowCards: $yellowCards, redCards: $redCards, saves: $saves)';
}


}

/// @nodoc
abstract mixin class $TeamMatchStatsCopyWith<$Res>  {
  factory $TeamMatchStatsCopyWith(TeamMatchStats value, $Res Function(TeamMatchStats) _then) = _$TeamMatchStatsCopyWithImpl;
@useResult
$Res call({
 String teamId, int goals, int shots, int shotsOnTarget, int possession, double xg, int passes, double passAccuracy, int duelsWon, int offsides, int corners, int fouls, int yellowCards, int redCards, int saves
});




}
/// @nodoc
class _$TeamMatchStatsCopyWithImpl<$Res>
    implements $TeamMatchStatsCopyWith<$Res> {
  _$TeamMatchStatsCopyWithImpl(this._self, this._then);

  final TeamMatchStats _self;
  final $Res Function(TeamMatchStats) _then;

/// Create a copy of TeamMatchStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? teamId = null,Object? goals = null,Object? shots = null,Object? shotsOnTarget = null,Object? possession = null,Object? xg = null,Object? passes = null,Object? passAccuracy = null,Object? duelsWon = null,Object? offsides = null,Object? corners = null,Object? fouls = null,Object? yellowCards = null,Object? redCards = null,Object? saves = null,}) {
  return _then(_self.copyWith(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as int,shots: null == shots ? _self.shots : shots // ignore: cast_nullable_to_non_nullable
as int,shotsOnTarget: null == shotsOnTarget ? _self.shotsOnTarget : shotsOnTarget // ignore: cast_nullable_to_non_nullable
as int,possession: null == possession ? _self.possession : possession // ignore: cast_nullable_to_non_nullable
as int,xg: null == xg ? _self.xg : xg // ignore: cast_nullable_to_non_nullable
as double,passes: null == passes ? _self.passes : passes // ignore: cast_nullable_to_non_nullable
as int,passAccuracy: null == passAccuracy ? _self.passAccuracy : passAccuracy // ignore: cast_nullable_to_non_nullable
as double,duelsWon: null == duelsWon ? _self.duelsWon : duelsWon // ignore: cast_nullable_to_non_nullable
as int,offsides: null == offsides ? _self.offsides : offsides // ignore: cast_nullable_to_non_nullable
as int,corners: null == corners ? _self.corners : corners // ignore: cast_nullable_to_non_nullable
as int,fouls: null == fouls ? _self.fouls : fouls // ignore: cast_nullable_to_non_nullable
as int,yellowCards: null == yellowCards ? _self.yellowCards : yellowCards // ignore: cast_nullable_to_non_nullable
as int,redCards: null == redCards ? _self.redCards : redCards // ignore: cast_nullable_to_non_nullable
as int,saves: null == saves ? _self.saves : saves // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamMatchStats].
extension TeamMatchStatsPatterns on TeamMatchStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamMatchStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamMatchStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamMatchStats value)  $default,){
final _that = this;
switch (_that) {
case _TeamMatchStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamMatchStats value)?  $default,){
final _that = this;
switch (_that) {
case _TeamMatchStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String teamId,  int goals,  int shots,  int shotsOnTarget,  int possession,  double xg,  int passes,  double passAccuracy,  int duelsWon,  int offsides,  int corners,  int fouls,  int yellowCards,  int redCards,  int saves)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamMatchStats() when $default != null:
return $default(_that.teamId,_that.goals,_that.shots,_that.shotsOnTarget,_that.possession,_that.xg,_that.passes,_that.passAccuracy,_that.duelsWon,_that.offsides,_that.corners,_that.fouls,_that.yellowCards,_that.redCards,_that.saves);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String teamId,  int goals,  int shots,  int shotsOnTarget,  int possession,  double xg,  int passes,  double passAccuracy,  int duelsWon,  int offsides,  int corners,  int fouls,  int yellowCards,  int redCards,  int saves)  $default,) {final _that = this;
switch (_that) {
case _TeamMatchStats():
return $default(_that.teamId,_that.goals,_that.shots,_that.shotsOnTarget,_that.possession,_that.xg,_that.passes,_that.passAccuracy,_that.duelsWon,_that.offsides,_that.corners,_that.fouls,_that.yellowCards,_that.redCards,_that.saves);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String teamId,  int goals,  int shots,  int shotsOnTarget,  int possession,  double xg,  int passes,  double passAccuracy,  int duelsWon,  int offsides,  int corners,  int fouls,  int yellowCards,  int redCards,  int saves)?  $default,) {final _that = this;
switch (_that) {
case _TeamMatchStats() when $default != null:
return $default(_that.teamId,_that.goals,_that.shots,_that.shotsOnTarget,_that.possession,_that.xg,_that.passes,_that.passAccuracy,_that.duelsWon,_that.offsides,_that.corners,_that.fouls,_that.yellowCards,_that.redCards,_that.saves);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamMatchStats implements TeamMatchStats {
  const _TeamMatchStats({required this.teamId, this.goals = 0, this.shots = 0, this.shotsOnTarget = 0, this.possession = 0, this.xg = 0.0, this.passes = 0, this.passAccuracy = 0.0, this.duelsWon = 0, this.offsides = 0, this.corners = 0, this.fouls = 0, this.yellowCards = 0, this.redCards = 0, this.saves = 0});
  factory _TeamMatchStats.fromJson(Map<String, dynamic> json) => _$TeamMatchStatsFromJson(json);

@override final  String teamId;
@override@JsonKey() final  int goals;
@override@JsonKey() final  int shots;
@override@JsonKey() final  int shotsOnTarget;
@override@JsonKey() final  int possession;
@override@JsonKey() final  double xg;
@override@JsonKey() final  int passes;
@override@JsonKey() final  double passAccuracy;
@override@JsonKey() final  int duelsWon;
@override@JsonKey() final  int offsides;
@override@JsonKey() final  int corners;
@override@JsonKey() final  int fouls;
@override@JsonKey() final  int yellowCards;
@override@JsonKey() final  int redCards;
@override@JsonKey() final  int saves;

/// Create a copy of TeamMatchStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamMatchStatsCopyWith<_TeamMatchStats> get copyWith => __$TeamMatchStatsCopyWithImpl<_TeamMatchStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamMatchStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamMatchStats&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.goals, goals) || other.goals == goals)&&(identical(other.shots, shots) || other.shots == shots)&&(identical(other.shotsOnTarget, shotsOnTarget) || other.shotsOnTarget == shotsOnTarget)&&(identical(other.possession, possession) || other.possession == possession)&&(identical(other.xg, xg) || other.xg == xg)&&(identical(other.passes, passes) || other.passes == passes)&&(identical(other.passAccuracy, passAccuracy) || other.passAccuracy == passAccuracy)&&(identical(other.duelsWon, duelsWon) || other.duelsWon == duelsWon)&&(identical(other.offsides, offsides) || other.offsides == offsides)&&(identical(other.corners, corners) || other.corners == corners)&&(identical(other.fouls, fouls) || other.fouls == fouls)&&(identical(other.yellowCards, yellowCards) || other.yellowCards == yellowCards)&&(identical(other.redCards, redCards) || other.redCards == redCards)&&(identical(other.saves, saves) || other.saves == saves));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamId,goals,shots,shotsOnTarget,possession,xg,passes,passAccuracy,duelsWon,offsides,corners,fouls,yellowCards,redCards,saves);

@override
String toString() {
  return 'TeamMatchStats(teamId: $teamId, goals: $goals, shots: $shots, shotsOnTarget: $shotsOnTarget, possession: $possession, xg: $xg, passes: $passes, passAccuracy: $passAccuracy, duelsWon: $duelsWon, offsides: $offsides, corners: $corners, fouls: $fouls, yellowCards: $yellowCards, redCards: $redCards, saves: $saves)';
}


}

/// @nodoc
abstract mixin class _$TeamMatchStatsCopyWith<$Res> implements $TeamMatchStatsCopyWith<$Res> {
  factory _$TeamMatchStatsCopyWith(_TeamMatchStats value, $Res Function(_TeamMatchStats) _then) = __$TeamMatchStatsCopyWithImpl;
@override @useResult
$Res call({
 String teamId, int goals, int shots, int shotsOnTarget, int possession, double xg, int passes, double passAccuracy, int duelsWon, int offsides, int corners, int fouls, int yellowCards, int redCards, int saves
});




}
/// @nodoc
class __$TeamMatchStatsCopyWithImpl<$Res>
    implements _$TeamMatchStatsCopyWith<$Res> {
  __$TeamMatchStatsCopyWithImpl(this._self, this._then);

  final _TeamMatchStats _self;
  final $Res Function(_TeamMatchStats) _then;

/// Create a copy of TeamMatchStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? teamId = null,Object? goals = null,Object? shots = null,Object? shotsOnTarget = null,Object? possession = null,Object? xg = null,Object? passes = null,Object? passAccuracy = null,Object? duelsWon = null,Object? offsides = null,Object? corners = null,Object? fouls = null,Object? yellowCards = null,Object? redCards = null,Object? saves = null,}) {
  return _then(_TeamMatchStats(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,goals: null == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as int,shots: null == shots ? _self.shots : shots // ignore: cast_nullable_to_non_nullable
as int,shotsOnTarget: null == shotsOnTarget ? _self.shotsOnTarget : shotsOnTarget // ignore: cast_nullable_to_non_nullable
as int,possession: null == possession ? _self.possession : possession // ignore: cast_nullable_to_non_nullable
as int,xg: null == xg ? _self.xg : xg // ignore: cast_nullable_to_non_nullable
as double,passes: null == passes ? _self.passes : passes // ignore: cast_nullable_to_non_nullable
as int,passAccuracy: null == passAccuracy ? _self.passAccuracy : passAccuracy // ignore: cast_nullable_to_non_nullable
as double,duelsWon: null == duelsWon ? _self.duelsWon : duelsWon // ignore: cast_nullable_to_non_nullable
as int,offsides: null == offsides ? _self.offsides : offsides // ignore: cast_nullable_to_non_nullable
as int,corners: null == corners ? _self.corners : corners // ignore: cast_nullable_to_non_nullable
as int,fouls: null == fouls ? _self.fouls : fouls // ignore: cast_nullable_to_non_nullable
as int,yellowCards: null == yellowCards ? _self.yellowCards : yellowCards // ignore: cast_nullable_to_non_nullable
as int,redCards: null == redCards ? _self.redCards : redCards // ignore: cast_nullable_to_non_nullable
as int,saves: null == saves ? _self.saves : saves // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MatchTeamSnapshot {

 String get teamId; List<Player> get startingXi; List<Player> get bench; List<Position> get assignedPositions; List<AssignedRole> get assignedRoles; TacticsSetup get tactics; double get chemistry; int get atmosphere; double get cohesionMultiplier; TeamStaff get staff;
/// Create a copy of MatchTeamSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchTeamSnapshotCopyWith<MatchTeamSnapshot> get copyWith => _$MatchTeamSnapshotCopyWithImpl<MatchTeamSnapshot>(this as MatchTeamSnapshot, _$identity);

  /// Serializes this MatchTeamSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchTeamSnapshot&&(identical(other.teamId, teamId) || other.teamId == teamId)&&const DeepCollectionEquality().equals(other.startingXi, startingXi)&&const DeepCollectionEquality().equals(other.bench, bench)&&const DeepCollectionEquality().equals(other.assignedPositions, assignedPositions)&&const DeepCollectionEquality().equals(other.assignedRoles, assignedRoles)&&(identical(other.tactics, tactics) || other.tactics == tactics)&&(identical(other.chemistry, chemistry) || other.chemistry == chemistry)&&(identical(other.atmosphere, atmosphere) || other.atmosphere == atmosphere)&&(identical(other.cohesionMultiplier, cohesionMultiplier) || other.cohesionMultiplier == cohesionMultiplier)&&(identical(other.staff, staff) || other.staff == staff));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamId,const DeepCollectionEquality().hash(startingXi),const DeepCollectionEquality().hash(bench),const DeepCollectionEquality().hash(assignedPositions),const DeepCollectionEquality().hash(assignedRoles),tactics,chemistry,atmosphere,cohesionMultiplier,staff);

@override
String toString() {
  return 'MatchTeamSnapshot(teamId: $teamId, startingXi: $startingXi, bench: $bench, assignedPositions: $assignedPositions, assignedRoles: $assignedRoles, tactics: $tactics, chemistry: $chemistry, atmosphere: $atmosphere, cohesionMultiplier: $cohesionMultiplier, staff: $staff)';
}


}

/// @nodoc
abstract mixin class $MatchTeamSnapshotCopyWith<$Res>  {
  factory $MatchTeamSnapshotCopyWith(MatchTeamSnapshot value, $Res Function(MatchTeamSnapshot) _then) = _$MatchTeamSnapshotCopyWithImpl;
@useResult
$Res call({
 String teamId, List<Player> startingXi, List<Player> bench, List<Position> assignedPositions, List<AssignedRole> assignedRoles, TacticsSetup tactics, double chemistry, int atmosphere, double cohesionMultiplier, TeamStaff staff
});


$TacticsSetupCopyWith<$Res> get tactics;$TeamStaffCopyWith<$Res> get staff;

}
/// @nodoc
class _$MatchTeamSnapshotCopyWithImpl<$Res>
    implements $MatchTeamSnapshotCopyWith<$Res> {
  _$MatchTeamSnapshotCopyWithImpl(this._self, this._then);

  final MatchTeamSnapshot _self;
  final $Res Function(MatchTeamSnapshot) _then;

/// Create a copy of MatchTeamSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? teamId = null,Object? startingXi = null,Object? bench = null,Object? assignedPositions = null,Object? assignedRoles = null,Object? tactics = null,Object? chemistry = null,Object? atmosphere = null,Object? cohesionMultiplier = null,Object? staff = null,}) {
  return _then(_self.copyWith(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,startingXi: null == startingXi ? _self.startingXi : startingXi // ignore: cast_nullable_to_non_nullable
as List<Player>,bench: null == bench ? _self.bench : bench // ignore: cast_nullable_to_non_nullable
as List<Player>,assignedPositions: null == assignedPositions ? _self.assignedPositions : assignedPositions // ignore: cast_nullable_to_non_nullable
as List<Position>,assignedRoles: null == assignedRoles ? _self.assignedRoles : assignedRoles // ignore: cast_nullable_to_non_nullable
as List<AssignedRole>,tactics: null == tactics ? _self.tactics : tactics // ignore: cast_nullable_to_non_nullable
as TacticsSetup,chemistry: null == chemistry ? _self.chemistry : chemistry // ignore: cast_nullable_to_non_nullable
as double,atmosphere: null == atmosphere ? _self.atmosphere : atmosphere // ignore: cast_nullable_to_non_nullable
as int,cohesionMultiplier: null == cohesionMultiplier ? _self.cohesionMultiplier : cohesionMultiplier // ignore: cast_nullable_to_non_nullable
as double,staff: null == staff ? _self.staff : staff // ignore: cast_nullable_to_non_nullable
as TeamStaff,
  ));
}
/// Create a copy of MatchTeamSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TacticsSetupCopyWith<$Res> get tactics {
  
  return $TacticsSetupCopyWith<$Res>(_self.tactics, (value) {
    return _then(_self.copyWith(tactics: value));
  });
}/// Create a copy of MatchTeamSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamStaffCopyWith<$Res> get staff {
  
  return $TeamStaffCopyWith<$Res>(_self.staff, (value) {
    return _then(_self.copyWith(staff: value));
  });
}
}


/// Adds pattern-matching-related methods to [MatchTeamSnapshot].
extension MatchTeamSnapshotPatterns on MatchTeamSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchTeamSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchTeamSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchTeamSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _MatchTeamSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchTeamSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _MatchTeamSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String teamId,  List<Player> startingXi,  List<Player> bench,  List<Position> assignedPositions,  List<AssignedRole> assignedRoles,  TacticsSetup tactics,  double chemistry,  int atmosphere,  double cohesionMultiplier,  TeamStaff staff)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchTeamSnapshot() when $default != null:
return $default(_that.teamId,_that.startingXi,_that.bench,_that.assignedPositions,_that.assignedRoles,_that.tactics,_that.chemistry,_that.atmosphere,_that.cohesionMultiplier,_that.staff);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String teamId,  List<Player> startingXi,  List<Player> bench,  List<Position> assignedPositions,  List<AssignedRole> assignedRoles,  TacticsSetup tactics,  double chemistry,  int atmosphere,  double cohesionMultiplier,  TeamStaff staff)  $default,) {final _that = this;
switch (_that) {
case _MatchTeamSnapshot():
return $default(_that.teamId,_that.startingXi,_that.bench,_that.assignedPositions,_that.assignedRoles,_that.tactics,_that.chemistry,_that.atmosphere,_that.cohesionMultiplier,_that.staff);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String teamId,  List<Player> startingXi,  List<Player> bench,  List<Position> assignedPositions,  List<AssignedRole> assignedRoles,  TacticsSetup tactics,  double chemistry,  int atmosphere,  double cohesionMultiplier,  TeamStaff staff)?  $default,) {final _that = this;
switch (_that) {
case _MatchTeamSnapshot() when $default != null:
return $default(_that.teamId,_that.startingXi,_that.bench,_that.assignedPositions,_that.assignedRoles,_that.tactics,_that.chemistry,_that.atmosphere,_that.cohesionMultiplier,_that.staff);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatchTeamSnapshot implements MatchTeamSnapshot {
  const _MatchTeamSnapshot({this.teamId = '', final  List<Player> startingXi = const [], final  List<Player> bench = const [], final  List<Position> assignedPositions = const [], final  List<AssignedRole> assignedRoles = const [], this.tactics = const TacticsSetup(), this.chemistry = 50.0, this.atmosphere = 50, this.cohesionMultiplier = 1.0, this.staff = const TeamStaff()}): _startingXi = startingXi,_bench = bench,_assignedPositions = assignedPositions,_assignedRoles = assignedRoles;
  factory _MatchTeamSnapshot.fromJson(Map<String, dynamic> json) => _$MatchTeamSnapshotFromJson(json);

@override@JsonKey() final  String teamId;
 final  List<Player> _startingXi;
@override@JsonKey() List<Player> get startingXi {
  if (_startingXi is EqualUnmodifiableListView) return _startingXi;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_startingXi);
}

 final  List<Player> _bench;
@override@JsonKey() List<Player> get bench {
  if (_bench is EqualUnmodifiableListView) return _bench;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bench);
}

 final  List<Position> _assignedPositions;
@override@JsonKey() List<Position> get assignedPositions {
  if (_assignedPositions is EqualUnmodifiableListView) return _assignedPositions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assignedPositions);
}

 final  List<AssignedRole> _assignedRoles;
@override@JsonKey() List<AssignedRole> get assignedRoles {
  if (_assignedRoles is EqualUnmodifiableListView) return _assignedRoles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assignedRoles);
}

@override@JsonKey() final  TacticsSetup tactics;
@override@JsonKey() final  double chemistry;
@override@JsonKey() final  int atmosphere;
@override@JsonKey() final  double cohesionMultiplier;
@override@JsonKey() final  TeamStaff staff;

/// Create a copy of MatchTeamSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchTeamSnapshotCopyWith<_MatchTeamSnapshot> get copyWith => __$MatchTeamSnapshotCopyWithImpl<_MatchTeamSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchTeamSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchTeamSnapshot&&(identical(other.teamId, teamId) || other.teamId == teamId)&&const DeepCollectionEquality().equals(other._startingXi, _startingXi)&&const DeepCollectionEquality().equals(other._bench, _bench)&&const DeepCollectionEquality().equals(other._assignedPositions, _assignedPositions)&&const DeepCollectionEquality().equals(other._assignedRoles, _assignedRoles)&&(identical(other.tactics, tactics) || other.tactics == tactics)&&(identical(other.chemistry, chemistry) || other.chemistry == chemistry)&&(identical(other.atmosphere, atmosphere) || other.atmosphere == atmosphere)&&(identical(other.cohesionMultiplier, cohesionMultiplier) || other.cohesionMultiplier == cohesionMultiplier)&&(identical(other.staff, staff) || other.staff == staff));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,teamId,const DeepCollectionEquality().hash(_startingXi),const DeepCollectionEquality().hash(_bench),const DeepCollectionEquality().hash(_assignedPositions),const DeepCollectionEquality().hash(_assignedRoles),tactics,chemistry,atmosphere,cohesionMultiplier,staff);

@override
String toString() {
  return 'MatchTeamSnapshot(teamId: $teamId, startingXi: $startingXi, bench: $bench, assignedPositions: $assignedPositions, assignedRoles: $assignedRoles, tactics: $tactics, chemistry: $chemistry, atmosphere: $atmosphere, cohesionMultiplier: $cohesionMultiplier, staff: $staff)';
}


}

/// @nodoc
abstract mixin class _$MatchTeamSnapshotCopyWith<$Res> implements $MatchTeamSnapshotCopyWith<$Res> {
  factory _$MatchTeamSnapshotCopyWith(_MatchTeamSnapshot value, $Res Function(_MatchTeamSnapshot) _then) = __$MatchTeamSnapshotCopyWithImpl;
@override @useResult
$Res call({
 String teamId, List<Player> startingXi, List<Player> bench, List<Position> assignedPositions, List<AssignedRole> assignedRoles, TacticsSetup tactics, double chemistry, int atmosphere, double cohesionMultiplier, TeamStaff staff
});


@override $TacticsSetupCopyWith<$Res> get tactics;@override $TeamStaffCopyWith<$Res> get staff;

}
/// @nodoc
class __$MatchTeamSnapshotCopyWithImpl<$Res>
    implements _$MatchTeamSnapshotCopyWith<$Res> {
  __$MatchTeamSnapshotCopyWithImpl(this._self, this._then);

  final _MatchTeamSnapshot _self;
  final $Res Function(_MatchTeamSnapshot) _then;

/// Create a copy of MatchTeamSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? teamId = null,Object? startingXi = null,Object? bench = null,Object? assignedPositions = null,Object? assignedRoles = null,Object? tactics = null,Object? chemistry = null,Object? atmosphere = null,Object? cohesionMultiplier = null,Object? staff = null,}) {
  return _then(_MatchTeamSnapshot(
teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,startingXi: null == startingXi ? _self._startingXi : startingXi // ignore: cast_nullable_to_non_nullable
as List<Player>,bench: null == bench ? _self._bench : bench // ignore: cast_nullable_to_non_nullable
as List<Player>,assignedPositions: null == assignedPositions ? _self._assignedPositions : assignedPositions // ignore: cast_nullable_to_non_nullable
as List<Position>,assignedRoles: null == assignedRoles ? _self._assignedRoles : assignedRoles // ignore: cast_nullable_to_non_nullable
as List<AssignedRole>,tactics: null == tactics ? _self.tactics : tactics // ignore: cast_nullable_to_non_nullable
as TacticsSetup,chemistry: null == chemistry ? _self.chemistry : chemistry // ignore: cast_nullable_to_non_nullable
as double,atmosphere: null == atmosphere ? _self.atmosphere : atmosphere // ignore: cast_nullable_to_non_nullable
as int,cohesionMultiplier: null == cohesionMultiplier ? _self.cohesionMultiplier : cohesionMultiplier // ignore: cast_nullable_to_non_nullable
as double,staff: null == staff ? _self.staff : staff // ignore: cast_nullable_to_non_nullable
as TeamStaff,
  ));
}

/// Create a copy of MatchTeamSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TacticsSetupCopyWith<$Res> get tactics {
  
  return $TacticsSetupCopyWith<$Res>(_self.tactics, (value) {
    return _then(_self.copyWith(tactics: value));
  });
}/// Create a copy of MatchTeamSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamStaffCopyWith<$Res> get staff {
  
  return $TeamStaffCopyWith<$Res>(_self.staff, (value) {
    return _then(_self.copyWith(staff: value));
  });
}
}


/// @nodoc
mixin _$MatchResult {

 String get homeTeamId; String get awayTeamId; int get homeGoals; int get awayGoals; TeamMatchStats get homeStats; TeamMatchStats get awayStats; MatchStatus get status; String? get reasonCode; List<String> get violatingTeamIds; bool get isWalkover; bool get noGkPenalty; List<String> get noGkPenaltyTeamIds; MatchContext get context; TacticsSetup get homeTactics; TacticsSetup get awayTactics; List<Player> get homeLineup; List<Player> get awayLineup; List<Position> get homeLineupPositions; List<Position> get awayLineupPositions; MatchTeamSnapshot get homeSnapshot; MatchTeamSnapshot get awaySnapshot; List<PlayerMatchStats> get playerStats; List<MatchEvent> get events; List<MatchInjury> get injuries; List<MatchDiscipline> get disciplines; String? get manOfTheMatchPlayerId; String? get inspiredPerformancePlayerId; int get matchEndMinute; int get stoppageTime;
/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchResultCopyWith<MatchResult> get copyWith => _$MatchResultCopyWithImpl<MatchResult>(this as MatchResult, _$identity);

  /// Serializes this MatchResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchResult&&(identical(other.homeTeamId, homeTeamId) || other.homeTeamId == homeTeamId)&&(identical(other.awayTeamId, awayTeamId) || other.awayTeamId == awayTeamId)&&(identical(other.homeGoals, homeGoals) || other.homeGoals == homeGoals)&&(identical(other.awayGoals, awayGoals) || other.awayGoals == awayGoals)&&(identical(other.homeStats, homeStats) || other.homeStats == homeStats)&&(identical(other.awayStats, awayStats) || other.awayStats == awayStats)&&(identical(other.status, status) || other.status == status)&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode)&&const DeepCollectionEquality().equals(other.violatingTeamIds, violatingTeamIds)&&(identical(other.isWalkover, isWalkover) || other.isWalkover == isWalkover)&&(identical(other.noGkPenalty, noGkPenalty) || other.noGkPenalty == noGkPenalty)&&const DeepCollectionEquality().equals(other.noGkPenaltyTeamIds, noGkPenaltyTeamIds)&&(identical(other.context, context) || other.context == context)&&(identical(other.homeTactics, homeTactics) || other.homeTactics == homeTactics)&&(identical(other.awayTactics, awayTactics) || other.awayTactics == awayTactics)&&const DeepCollectionEquality().equals(other.homeLineup, homeLineup)&&const DeepCollectionEquality().equals(other.awayLineup, awayLineup)&&const DeepCollectionEquality().equals(other.homeLineupPositions, homeLineupPositions)&&const DeepCollectionEquality().equals(other.awayLineupPositions, awayLineupPositions)&&(identical(other.homeSnapshot, homeSnapshot) || other.homeSnapshot == homeSnapshot)&&(identical(other.awaySnapshot, awaySnapshot) || other.awaySnapshot == awaySnapshot)&&const DeepCollectionEquality().equals(other.playerStats, playerStats)&&const DeepCollectionEquality().equals(other.events, events)&&const DeepCollectionEquality().equals(other.injuries, injuries)&&const DeepCollectionEquality().equals(other.disciplines, disciplines)&&(identical(other.manOfTheMatchPlayerId, manOfTheMatchPlayerId) || other.manOfTheMatchPlayerId == manOfTheMatchPlayerId)&&(identical(other.inspiredPerformancePlayerId, inspiredPerformancePlayerId) || other.inspiredPerformancePlayerId == inspiredPerformancePlayerId)&&(identical(other.matchEndMinute, matchEndMinute) || other.matchEndMinute == matchEndMinute)&&(identical(other.stoppageTime, stoppageTime) || other.stoppageTime == stoppageTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,homeTeamId,awayTeamId,homeGoals,awayGoals,homeStats,awayStats,status,reasonCode,const DeepCollectionEquality().hash(violatingTeamIds),isWalkover,noGkPenalty,const DeepCollectionEquality().hash(noGkPenaltyTeamIds),context,homeTactics,awayTactics,const DeepCollectionEquality().hash(homeLineup),const DeepCollectionEquality().hash(awayLineup),const DeepCollectionEquality().hash(homeLineupPositions),const DeepCollectionEquality().hash(awayLineupPositions),homeSnapshot,awaySnapshot,const DeepCollectionEquality().hash(playerStats),const DeepCollectionEquality().hash(events),const DeepCollectionEquality().hash(injuries),const DeepCollectionEquality().hash(disciplines),manOfTheMatchPlayerId,inspiredPerformancePlayerId,matchEndMinute,stoppageTime]);

@override
String toString() {
  return 'MatchResult(homeTeamId: $homeTeamId, awayTeamId: $awayTeamId, homeGoals: $homeGoals, awayGoals: $awayGoals, homeStats: $homeStats, awayStats: $awayStats, status: $status, reasonCode: $reasonCode, violatingTeamIds: $violatingTeamIds, isWalkover: $isWalkover, noGkPenalty: $noGkPenalty, noGkPenaltyTeamIds: $noGkPenaltyTeamIds, context: $context, homeTactics: $homeTactics, awayTactics: $awayTactics, homeLineup: $homeLineup, awayLineup: $awayLineup, homeLineupPositions: $homeLineupPositions, awayLineupPositions: $awayLineupPositions, homeSnapshot: $homeSnapshot, awaySnapshot: $awaySnapshot, playerStats: $playerStats, events: $events, injuries: $injuries, disciplines: $disciplines, manOfTheMatchPlayerId: $manOfTheMatchPlayerId, inspiredPerformancePlayerId: $inspiredPerformancePlayerId, matchEndMinute: $matchEndMinute, stoppageTime: $stoppageTime)';
}


}

/// @nodoc
abstract mixin class $MatchResultCopyWith<$Res>  {
  factory $MatchResultCopyWith(MatchResult value, $Res Function(MatchResult) _then) = _$MatchResultCopyWithImpl;
@useResult
$Res call({
 String homeTeamId, String awayTeamId, int homeGoals, int awayGoals, TeamMatchStats homeStats, TeamMatchStats awayStats, MatchStatus status, String? reasonCode, List<String> violatingTeamIds, bool isWalkover, bool noGkPenalty, List<String> noGkPenaltyTeamIds, MatchContext context, TacticsSetup homeTactics, TacticsSetup awayTactics, List<Player> homeLineup, List<Player> awayLineup, List<Position> homeLineupPositions, List<Position> awayLineupPositions, MatchTeamSnapshot homeSnapshot, MatchTeamSnapshot awaySnapshot, List<PlayerMatchStats> playerStats, List<MatchEvent> events, List<MatchInjury> injuries, List<MatchDiscipline> disciplines, String? manOfTheMatchPlayerId, String? inspiredPerformancePlayerId, int matchEndMinute, int stoppageTime
});


$TeamMatchStatsCopyWith<$Res> get homeStats;$TeamMatchStatsCopyWith<$Res> get awayStats;$MatchContextCopyWith<$Res> get context;$TacticsSetupCopyWith<$Res> get homeTactics;$TacticsSetupCopyWith<$Res> get awayTactics;$MatchTeamSnapshotCopyWith<$Res> get homeSnapshot;$MatchTeamSnapshotCopyWith<$Res> get awaySnapshot;

}
/// @nodoc
class _$MatchResultCopyWithImpl<$Res>
    implements $MatchResultCopyWith<$Res> {
  _$MatchResultCopyWithImpl(this._self, this._then);

  final MatchResult _self;
  final $Res Function(MatchResult) _then;

/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? homeTeamId = null,Object? awayTeamId = null,Object? homeGoals = null,Object? awayGoals = null,Object? homeStats = null,Object? awayStats = null,Object? status = null,Object? reasonCode = freezed,Object? violatingTeamIds = null,Object? isWalkover = null,Object? noGkPenalty = null,Object? noGkPenaltyTeamIds = null,Object? context = null,Object? homeTactics = null,Object? awayTactics = null,Object? homeLineup = null,Object? awayLineup = null,Object? homeLineupPositions = null,Object? awayLineupPositions = null,Object? homeSnapshot = null,Object? awaySnapshot = null,Object? playerStats = null,Object? events = null,Object? injuries = null,Object? disciplines = null,Object? manOfTheMatchPlayerId = freezed,Object? inspiredPerformancePlayerId = freezed,Object? matchEndMinute = null,Object? stoppageTime = null,}) {
  return _then(_self.copyWith(
homeTeamId: null == homeTeamId ? _self.homeTeamId : homeTeamId // ignore: cast_nullable_to_non_nullable
as String,awayTeamId: null == awayTeamId ? _self.awayTeamId : awayTeamId // ignore: cast_nullable_to_non_nullable
as String,homeGoals: null == homeGoals ? _self.homeGoals : homeGoals // ignore: cast_nullable_to_non_nullable
as int,awayGoals: null == awayGoals ? _self.awayGoals : awayGoals // ignore: cast_nullable_to_non_nullable
as int,homeStats: null == homeStats ? _self.homeStats : homeStats // ignore: cast_nullable_to_non_nullable
as TeamMatchStats,awayStats: null == awayStats ? _self.awayStats : awayStats // ignore: cast_nullable_to_non_nullable
as TeamMatchStats,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MatchStatus,reasonCode: freezed == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as String?,violatingTeamIds: null == violatingTeamIds ? _self.violatingTeamIds : violatingTeamIds // ignore: cast_nullable_to_non_nullable
as List<String>,isWalkover: null == isWalkover ? _self.isWalkover : isWalkover // ignore: cast_nullable_to_non_nullable
as bool,noGkPenalty: null == noGkPenalty ? _self.noGkPenalty : noGkPenalty // ignore: cast_nullable_to_non_nullable
as bool,noGkPenaltyTeamIds: null == noGkPenaltyTeamIds ? _self.noGkPenaltyTeamIds : noGkPenaltyTeamIds // ignore: cast_nullable_to_non_nullable
as List<String>,context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as MatchContext,homeTactics: null == homeTactics ? _self.homeTactics : homeTactics // ignore: cast_nullable_to_non_nullable
as TacticsSetup,awayTactics: null == awayTactics ? _self.awayTactics : awayTactics // ignore: cast_nullable_to_non_nullable
as TacticsSetup,homeLineup: null == homeLineup ? _self.homeLineup : homeLineup // ignore: cast_nullable_to_non_nullable
as List<Player>,awayLineup: null == awayLineup ? _self.awayLineup : awayLineup // ignore: cast_nullable_to_non_nullable
as List<Player>,homeLineupPositions: null == homeLineupPositions ? _self.homeLineupPositions : homeLineupPositions // ignore: cast_nullable_to_non_nullable
as List<Position>,awayLineupPositions: null == awayLineupPositions ? _self.awayLineupPositions : awayLineupPositions // ignore: cast_nullable_to_non_nullable
as List<Position>,homeSnapshot: null == homeSnapshot ? _self.homeSnapshot : homeSnapshot // ignore: cast_nullable_to_non_nullable
as MatchTeamSnapshot,awaySnapshot: null == awaySnapshot ? _self.awaySnapshot : awaySnapshot // ignore: cast_nullable_to_non_nullable
as MatchTeamSnapshot,playerStats: null == playerStats ? _self.playerStats : playerStats // ignore: cast_nullable_to_non_nullable
as List<PlayerMatchStats>,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<MatchEvent>,injuries: null == injuries ? _self.injuries : injuries // ignore: cast_nullable_to_non_nullable
as List<MatchInjury>,disciplines: null == disciplines ? _self.disciplines : disciplines // ignore: cast_nullable_to_non_nullable
as List<MatchDiscipline>,manOfTheMatchPlayerId: freezed == manOfTheMatchPlayerId ? _self.manOfTheMatchPlayerId : manOfTheMatchPlayerId // ignore: cast_nullable_to_non_nullable
as String?,inspiredPerformancePlayerId: freezed == inspiredPerformancePlayerId ? _self.inspiredPerformancePlayerId : inspiredPerformancePlayerId // ignore: cast_nullable_to_non_nullable
as String?,matchEndMinute: null == matchEndMinute ? _self.matchEndMinute : matchEndMinute // ignore: cast_nullable_to_non_nullable
as int,stoppageTime: null == stoppageTime ? _self.stoppageTime : stoppageTime // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamMatchStatsCopyWith<$Res> get homeStats {
  
  return $TeamMatchStatsCopyWith<$Res>(_self.homeStats, (value) {
    return _then(_self.copyWith(homeStats: value));
  });
}/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamMatchStatsCopyWith<$Res> get awayStats {
  
  return $TeamMatchStatsCopyWith<$Res>(_self.awayStats, (value) {
    return _then(_self.copyWith(awayStats: value));
  });
}/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchContextCopyWith<$Res> get context {
  
  return $MatchContextCopyWith<$Res>(_self.context, (value) {
    return _then(_self.copyWith(context: value));
  });
}/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TacticsSetupCopyWith<$Res> get homeTactics {
  
  return $TacticsSetupCopyWith<$Res>(_self.homeTactics, (value) {
    return _then(_self.copyWith(homeTactics: value));
  });
}/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TacticsSetupCopyWith<$Res> get awayTactics {
  
  return $TacticsSetupCopyWith<$Res>(_self.awayTactics, (value) {
    return _then(_self.copyWith(awayTactics: value));
  });
}/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchTeamSnapshotCopyWith<$Res> get homeSnapshot {
  
  return $MatchTeamSnapshotCopyWith<$Res>(_self.homeSnapshot, (value) {
    return _then(_self.copyWith(homeSnapshot: value));
  });
}/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchTeamSnapshotCopyWith<$Res> get awaySnapshot {
  
  return $MatchTeamSnapshotCopyWith<$Res>(_self.awaySnapshot, (value) {
    return _then(_self.copyWith(awaySnapshot: value));
  });
}
}


/// Adds pattern-matching-related methods to [MatchResult].
extension MatchResultPatterns on MatchResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchResult value)  $default,){
final _that = this;
switch (_that) {
case _MatchResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchResult value)?  $default,){
final _that = this;
switch (_that) {
case _MatchResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String homeTeamId,  String awayTeamId,  int homeGoals,  int awayGoals,  TeamMatchStats homeStats,  TeamMatchStats awayStats,  MatchStatus status,  String? reasonCode,  List<String> violatingTeamIds,  bool isWalkover,  bool noGkPenalty,  List<String> noGkPenaltyTeamIds,  MatchContext context,  TacticsSetup homeTactics,  TacticsSetup awayTactics,  List<Player> homeLineup,  List<Player> awayLineup,  List<Position> homeLineupPositions,  List<Position> awayLineupPositions,  MatchTeamSnapshot homeSnapshot,  MatchTeamSnapshot awaySnapshot,  List<PlayerMatchStats> playerStats,  List<MatchEvent> events,  List<MatchInjury> injuries,  List<MatchDiscipline> disciplines,  String? manOfTheMatchPlayerId,  String? inspiredPerformancePlayerId,  int matchEndMinute,  int stoppageTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchResult() when $default != null:
return $default(_that.homeTeamId,_that.awayTeamId,_that.homeGoals,_that.awayGoals,_that.homeStats,_that.awayStats,_that.status,_that.reasonCode,_that.violatingTeamIds,_that.isWalkover,_that.noGkPenalty,_that.noGkPenaltyTeamIds,_that.context,_that.homeTactics,_that.awayTactics,_that.homeLineup,_that.awayLineup,_that.homeLineupPositions,_that.awayLineupPositions,_that.homeSnapshot,_that.awaySnapshot,_that.playerStats,_that.events,_that.injuries,_that.disciplines,_that.manOfTheMatchPlayerId,_that.inspiredPerformancePlayerId,_that.matchEndMinute,_that.stoppageTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String homeTeamId,  String awayTeamId,  int homeGoals,  int awayGoals,  TeamMatchStats homeStats,  TeamMatchStats awayStats,  MatchStatus status,  String? reasonCode,  List<String> violatingTeamIds,  bool isWalkover,  bool noGkPenalty,  List<String> noGkPenaltyTeamIds,  MatchContext context,  TacticsSetup homeTactics,  TacticsSetup awayTactics,  List<Player> homeLineup,  List<Player> awayLineup,  List<Position> homeLineupPositions,  List<Position> awayLineupPositions,  MatchTeamSnapshot homeSnapshot,  MatchTeamSnapshot awaySnapshot,  List<PlayerMatchStats> playerStats,  List<MatchEvent> events,  List<MatchInjury> injuries,  List<MatchDiscipline> disciplines,  String? manOfTheMatchPlayerId,  String? inspiredPerformancePlayerId,  int matchEndMinute,  int stoppageTime)  $default,) {final _that = this;
switch (_that) {
case _MatchResult():
return $default(_that.homeTeamId,_that.awayTeamId,_that.homeGoals,_that.awayGoals,_that.homeStats,_that.awayStats,_that.status,_that.reasonCode,_that.violatingTeamIds,_that.isWalkover,_that.noGkPenalty,_that.noGkPenaltyTeamIds,_that.context,_that.homeTactics,_that.awayTactics,_that.homeLineup,_that.awayLineup,_that.homeLineupPositions,_that.awayLineupPositions,_that.homeSnapshot,_that.awaySnapshot,_that.playerStats,_that.events,_that.injuries,_that.disciplines,_that.manOfTheMatchPlayerId,_that.inspiredPerformancePlayerId,_that.matchEndMinute,_that.stoppageTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String homeTeamId,  String awayTeamId,  int homeGoals,  int awayGoals,  TeamMatchStats homeStats,  TeamMatchStats awayStats,  MatchStatus status,  String? reasonCode,  List<String> violatingTeamIds,  bool isWalkover,  bool noGkPenalty,  List<String> noGkPenaltyTeamIds,  MatchContext context,  TacticsSetup homeTactics,  TacticsSetup awayTactics,  List<Player> homeLineup,  List<Player> awayLineup,  List<Position> homeLineupPositions,  List<Position> awayLineupPositions,  MatchTeamSnapshot homeSnapshot,  MatchTeamSnapshot awaySnapshot,  List<PlayerMatchStats> playerStats,  List<MatchEvent> events,  List<MatchInjury> injuries,  List<MatchDiscipline> disciplines,  String? manOfTheMatchPlayerId,  String? inspiredPerformancePlayerId,  int matchEndMinute,  int stoppageTime)?  $default,) {final _that = this;
switch (_that) {
case _MatchResult() when $default != null:
return $default(_that.homeTeamId,_that.awayTeamId,_that.homeGoals,_that.awayGoals,_that.homeStats,_that.awayStats,_that.status,_that.reasonCode,_that.violatingTeamIds,_that.isWalkover,_that.noGkPenalty,_that.noGkPenaltyTeamIds,_that.context,_that.homeTactics,_that.awayTactics,_that.homeLineup,_that.awayLineup,_that.homeLineupPositions,_that.awayLineupPositions,_that.homeSnapshot,_that.awaySnapshot,_that.playerStats,_that.events,_that.injuries,_that.disciplines,_that.manOfTheMatchPlayerId,_that.inspiredPerformancePlayerId,_that.matchEndMinute,_that.stoppageTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatchResult implements MatchResult {
  const _MatchResult({required this.homeTeamId, required this.awayTeamId, required this.homeGoals, required this.awayGoals, required this.homeStats, required this.awayStats, this.status = MatchStatus.played, this.reasonCode, final  List<String> violatingTeamIds = const [], this.isWalkover = false, this.noGkPenalty = false, final  List<String> noGkPenaltyTeamIds = const [], this.context = const MatchContext(), this.homeTactics = const TacticsSetup(), this.awayTactics = const TacticsSetup(), final  List<Player> homeLineup = const [], final  List<Player> awayLineup = const [], final  List<Position> homeLineupPositions = const [], final  List<Position> awayLineupPositions = const [], this.homeSnapshot = const MatchTeamSnapshot(), this.awaySnapshot = const MatchTeamSnapshot(), final  List<PlayerMatchStats> playerStats = const [], final  List<MatchEvent> events = const [], final  List<MatchInjury> injuries = const [], final  List<MatchDiscipline> disciplines = const [], this.manOfTheMatchPlayerId, this.inspiredPerformancePlayerId, this.matchEndMinute = 90, this.stoppageTime = 0}): _violatingTeamIds = violatingTeamIds,_noGkPenaltyTeamIds = noGkPenaltyTeamIds,_homeLineup = homeLineup,_awayLineup = awayLineup,_homeLineupPositions = homeLineupPositions,_awayLineupPositions = awayLineupPositions,_playerStats = playerStats,_events = events,_injuries = injuries,_disciplines = disciplines;
  factory _MatchResult.fromJson(Map<String, dynamic> json) => _$MatchResultFromJson(json);

@override final  String homeTeamId;
@override final  String awayTeamId;
@override final  int homeGoals;
@override final  int awayGoals;
@override final  TeamMatchStats homeStats;
@override final  TeamMatchStats awayStats;
@override@JsonKey() final  MatchStatus status;
@override final  String? reasonCode;
 final  List<String> _violatingTeamIds;
@override@JsonKey() List<String> get violatingTeamIds {
  if (_violatingTeamIds is EqualUnmodifiableListView) return _violatingTeamIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_violatingTeamIds);
}

@override@JsonKey() final  bool isWalkover;
@override@JsonKey() final  bool noGkPenalty;
 final  List<String> _noGkPenaltyTeamIds;
@override@JsonKey() List<String> get noGkPenaltyTeamIds {
  if (_noGkPenaltyTeamIds is EqualUnmodifiableListView) return _noGkPenaltyTeamIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_noGkPenaltyTeamIds);
}

@override@JsonKey() final  MatchContext context;
@override@JsonKey() final  TacticsSetup homeTactics;
@override@JsonKey() final  TacticsSetup awayTactics;
 final  List<Player> _homeLineup;
@override@JsonKey() List<Player> get homeLineup {
  if (_homeLineup is EqualUnmodifiableListView) return _homeLineup;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_homeLineup);
}

 final  List<Player> _awayLineup;
@override@JsonKey() List<Player> get awayLineup {
  if (_awayLineup is EqualUnmodifiableListView) return _awayLineup;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_awayLineup);
}

 final  List<Position> _homeLineupPositions;
@override@JsonKey() List<Position> get homeLineupPositions {
  if (_homeLineupPositions is EqualUnmodifiableListView) return _homeLineupPositions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_homeLineupPositions);
}

 final  List<Position> _awayLineupPositions;
@override@JsonKey() List<Position> get awayLineupPositions {
  if (_awayLineupPositions is EqualUnmodifiableListView) return _awayLineupPositions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_awayLineupPositions);
}

@override@JsonKey() final  MatchTeamSnapshot homeSnapshot;
@override@JsonKey() final  MatchTeamSnapshot awaySnapshot;
 final  List<PlayerMatchStats> _playerStats;
@override@JsonKey() List<PlayerMatchStats> get playerStats {
  if (_playerStats is EqualUnmodifiableListView) return _playerStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playerStats);
}

 final  List<MatchEvent> _events;
@override@JsonKey() List<MatchEvent> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}

 final  List<MatchInjury> _injuries;
@override@JsonKey() List<MatchInjury> get injuries {
  if (_injuries is EqualUnmodifiableListView) return _injuries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_injuries);
}

 final  List<MatchDiscipline> _disciplines;
@override@JsonKey() List<MatchDiscipline> get disciplines {
  if (_disciplines is EqualUnmodifiableListView) return _disciplines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_disciplines);
}

@override final  String? manOfTheMatchPlayerId;
@override final  String? inspiredPerformancePlayerId;
@override@JsonKey() final  int matchEndMinute;
@override@JsonKey() final  int stoppageTime;

/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchResultCopyWith<_MatchResult> get copyWith => __$MatchResultCopyWithImpl<_MatchResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchResult&&(identical(other.homeTeamId, homeTeamId) || other.homeTeamId == homeTeamId)&&(identical(other.awayTeamId, awayTeamId) || other.awayTeamId == awayTeamId)&&(identical(other.homeGoals, homeGoals) || other.homeGoals == homeGoals)&&(identical(other.awayGoals, awayGoals) || other.awayGoals == awayGoals)&&(identical(other.homeStats, homeStats) || other.homeStats == homeStats)&&(identical(other.awayStats, awayStats) || other.awayStats == awayStats)&&(identical(other.status, status) || other.status == status)&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode)&&const DeepCollectionEquality().equals(other._violatingTeamIds, _violatingTeamIds)&&(identical(other.isWalkover, isWalkover) || other.isWalkover == isWalkover)&&(identical(other.noGkPenalty, noGkPenalty) || other.noGkPenalty == noGkPenalty)&&const DeepCollectionEquality().equals(other._noGkPenaltyTeamIds, _noGkPenaltyTeamIds)&&(identical(other.context, context) || other.context == context)&&(identical(other.homeTactics, homeTactics) || other.homeTactics == homeTactics)&&(identical(other.awayTactics, awayTactics) || other.awayTactics == awayTactics)&&const DeepCollectionEquality().equals(other._homeLineup, _homeLineup)&&const DeepCollectionEquality().equals(other._awayLineup, _awayLineup)&&const DeepCollectionEquality().equals(other._homeLineupPositions, _homeLineupPositions)&&const DeepCollectionEquality().equals(other._awayLineupPositions, _awayLineupPositions)&&(identical(other.homeSnapshot, homeSnapshot) || other.homeSnapshot == homeSnapshot)&&(identical(other.awaySnapshot, awaySnapshot) || other.awaySnapshot == awaySnapshot)&&const DeepCollectionEquality().equals(other._playerStats, _playerStats)&&const DeepCollectionEquality().equals(other._events, _events)&&const DeepCollectionEquality().equals(other._injuries, _injuries)&&const DeepCollectionEquality().equals(other._disciplines, _disciplines)&&(identical(other.manOfTheMatchPlayerId, manOfTheMatchPlayerId) || other.manOfTheMatchPlayerId == manOfTheMatchPlayerId)&&(identical(other.inspiredPerformancePlayerId, inspiredPerformancePlayerId) || other.inspiredPerformancePlayerId == inspiredPerformancePlayerId)&&(identical(other.matchEndMinute, matchEndMinute) || other.matchEndMinute == matchEndMinute)&&(identical(other.stoppageTime, stoppageTime) || other.stoppageTime == stoppageTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,homeTeamId,awayTeamId,homeGoals,awayGoals,homeStats,awayStats,status,reasonCode,const DeepCollectionEquality().hash(_violatingTeamIds),isWalkover,noGkPenalty,const DeepCollectionEquality().hash(_noGkPenaltyTeamIds),context,homeTactics,awayTactics,const DeepCollectionEquality().hash(_homeLineup),const DeepCollectionEquality().hash(_awayLineup),const DeepCollectionEquality().hash(_homeLineupPositions),const DeepCollectionEquality().hash(_awayLineupPositions),homeSnapshot,awaySnapshot,const DeepCollectionEquality().hash(_playerStats),const DeepCollectionEquality().hash(_events),const DeepCollectionEquality().hash(_injuries),const DeepCollectionEquality().hash(_disciplines),manOfTheMatchPlayerId,inspiredPerformancePlayerId,matchEndMinute,stoppageTime]);

@override
String toString() {
  return 'MatchResult(homeTeamId: $homeTeamId, awayTeamId: $awayTeamId, homeGoals: $homeGoals, awayGoals: $awayGoals, homeStats: $homeStats, awayStats: $awayStats, status: $status, reasonCode: $reasonCode, violatingTeamIds: $violatingTeamIds, isWalkover: $isWalkover, noGkPenalty: $noGkPenalty, noGkPenaltyTeamIds: $noGkPenaltyTeamIds, context: $context, homeTactics: $homeTactics, awayTactics: $awayTactics, homeLineup: $homeLineup, awayLineup: $awayLineup, homeLineupPositions: $homeLineupPositions, awayLineupPositions: $awayLineupPositions, homeSnapshot: $homeSnapshot, awaySnapshot: $awaySnapshot, playerStats: $playerStats, events: $events, injuries: $injuries, disciplines: $disciplines, manOfTheMatchPlayerId: $manOfTheMatchPlayerId, inspiredPerformancePlayerId: $inspiredPerformancePlayerId, matchEndMinute: $matchEndMinute, stoppageTime: $stoppageTime)';
}


}

/// @nodoc
abstract mixin class _$MatchResultCopyWith<$Res> implements $MatchResultCopyWith<$Res> {
  factory _$MatchResultCopyWith(_MatchResult value, $Res Function(_MatchResult) _then) = __$MatchResultCopyWithImpl;
@override @useResult
$Res call({
 String homeTeamId, String awayTeamId, int homeGoals, int awayGoals, TeamMatchStats homeStats, TeamMatchStats awayStats, MatchStatus status, String? reasonCode, List<String> violatingTeamIds, bool isWalkover, bool noGkPenalty, List<String> noGkPenaltyTeamIds, MatchContext context, TacticsSetup homeTactics, TacticsSetup awayTactics, List<Player> homeLineup, List<Player> awayLineup, List<Position> homeLineupPositions, List<Position> awayLineupPositions, MatchTeamSnapshot homeSnapshot, MatchTeamSnapshot awaySnapshot, List<PlayerMatchStats> playerStats, List<MatchEvent> events, List<MatchInjury> injuries, List<MatchDiscipline> disciplines, String? manOfTheMatchPlayerId, String? inspiredPerformancePlayerId, int matchEndMinute, int stoppageTime
});


@override $TeamMatchStatsCopyWith<$Res> get homeStats;@override $TeamMatchStatsCopyWith<$Res> get awayStats;@override $MatchContextCopyWith<$Res> get context;@override $TacticsSetupCopyWith<$Res> get homeTactics;@override $TacticsSetupCopyWith<$Res> get awayTactics;@override $MatchTeamSnapshotCopyWith<$Res> get homeSnapshot;@override $MatchTeamSnapshotCopyWith<$Res> get awaySnapshot;

}
/// @nodoc
class __$MatchResultCopyWithImpl<$Res>
    implements _$MatchResultCopyWith<$Res> {
  __$MatchResultCopyWithImpl(this._self, this._then);

  final _MatchResult _self;
  final $Res Function(_MatchResult) _then;

/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? homeTeamId = null,Object? awayTeamId = null,Object? homeGoals = null,Object? awayGoals = null,Object? homeStats = null,Object? awayStats = null,Object? status = null,Object? reasonCode = freezed,Object? violatingTeamIds = null,Object? isWalkover = null,Object? noGkPenalty = null,Object? noGkPenaltyTeamIds = null,Object? context = null,Object? homeTactics = null,Object? awayTactics = null,Object? homeLineup = null,Object? awayLineup = null,Object? homeLineupPositions = null,Object? awayLineupPositions = null,Object? homeSnapshot = null,Object? awaySnapshot = null,Object? playerStats = null,Object? events = null,Object? injuries = null,Object? disciplines = null,Object? manOfTheMatchPlayerId = freezed,Object? inspiredPerformancePlayerId = freezed,Object? matchEndMinute = null,Object? stoppageTime = null,}) {
  return _then(_MatchResult(
homeTeamId: null == homeTeamId ? _self.homeTeamId : homeTeamId // ignore: cast_nullable_to_non_nullable
as String,awayTeamId: null == awayTeamId ? _self.awayTeamId : awayTeamId // ignore: cast_nullable_to_non_nullable
as String,homeGoals: null == homeGoals ? _self.homeGoals : homeGoals // ignore: cast_nullable_to_non_nullable
as int,awayGoals: null == awayGoals ? _self.awayGoals : awayGoals // ignore: cast_nullable_to_non_nullable
as int,homeStats: null == homeStats ? _self.homeStats : homeStats // ignore: cast_nullable_to_non_nullable
as TeamMatchStats,awayStats: null == awayStats ? _self.awayStats : awayStats // ignore: cast_nullable_to_non_nullable
as TeamMatchStats,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MatchStatus,reasonCode: freezed == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as String?,violatingTeamIds: null == violatingTeamIds ? _self._violatingTeamIds : violatingTeamIds // ignore: cast_nullable_to_non_nullable
as List<String>,isWalkover: null == isWalkover ? _self.isWalkover : isWalkover // ignore: cast_nullable_to_non_nullable
as bool,noGkPenalty: null == noGkPenalty ? _self.noGkPenalty : noGkPenalty // ignore: cast_nullable_to_non_nullable
as bool,noGkPenaltyTeamIds: null == noGkPenaltyTeamIds ? _self._noGkPenaltyTeamIds : noGkPenaltyTeamIds // ignore: cast_nullable_to_non_nullable
as List<String>,context: null == context ? _self.context : context // ignore: cast_nullable_to_non_nullable
as MatchContext,homeTactics: null == homeTactics ? _self.homeTactics : homeTactics // ignore: cast_nullable_to_non_nullable
as TacticsSetup,awayTactics: null == awayTactics ? _self.awayTactics : awayTactics // ignore: cast_nullable_to_non_nullable
as TacticsSetup,homeLineup: null == homeLineup ? _self._homeLineup : homeLineup // ignore: cast_nullable_to_non_nullable
as List<Player>,awayLineup: null == awayLineup ? _self._awayLineup : awayLineup // ignore: cast_nullable_to_non_nullable
as List<Player>,homeLineupPositions: null == homeLineupPositions ? _self._homeLineupPositions : homeLineupPositions // ignore: cast_nullable_to_non_nullable
as List<Position>,awayLineupPositions: null == awayLineupPositions ? _self._awayLineupPositions : awayLineupPositions // ignore: cast_nullable_to_non_nullable
as List<Position>,homeSnapshot: null == homeSnapshot ? _self.homeSnapshot : homeSnapshot // ignore: cast_nullable_to_non_nullable
as MatchTeamSnapshot,awaySnapshot: null == awaySnapshot ? _self.awaySnapshot : awaySnapshot // ignore: cast_nullable_to_non_nullable
as MatchTeamSnapshot,playerStats: null == playerStats ? _self._playerStats : playerStats // ignore: cast_nullable_to_non_nullable
as List<PlayerMatchStats>,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<MatchEvent>,injuries: null == injuries ? _self._injuries : injuries // ignore: cast_nullable_to_non_nullable
as List<MatchInjury>,disciplines: null == disciplines ? _self._disciplines : disciplines // ignore: cast_nullable_to_non_nullable
as List<MatchDiscipline>,manOfTheMatchPlayerId: freezed == manOfTheMatchPlayerId ? _self.manOfTheMatchPlayerId : manOfTheMatchPlayerId // ignore: cast_nullable_to_non_nullable
as String?,inspiredPerformancePlayerId: freezed == inspiredPerformancePlayerId ? _self.inspiredPerformancePlayerId : inspiredPerformancePlayerId // ignore: cast_nullable_to_non_nullable
as String?,matchEndMinute: null == matchEndMinute ? _self.matchEndMinute : matchEndMinute // ignore: cast_nullable_to_non_nullable
as int,stoppageTime: null == stoppageTime ? _self.stoppageTime : stoppageTime // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamMatchStatsCopyWith<$Res> get homeStats {
  
  return $TeamMatchStatsCopyWith<$Res>(_self.homeStats, (value) {
    return _then(_self.copyWith(homeStats: value));
  });
}/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TeamMatchStatsCopyWith<$Res> get awayStats {
  
  return $TeamMatchStatsCopyWith<$Res>(_self.awayStats, (value) {
    return _then(_self.copyWith(awayStats: value));
  });
}/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchContextCopyWith<$Res> get context {
  
  return $MatchContextCopyWith<$Res>(_self.context, (value) {
    return _then(_self.copyWith(context: value));
  });
}/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TacticsSetupCopyWith<$Res> get homeTactics {
  
  return $TacticsSetupCopyWith<$Res>(_self.homeTactics, (value) {
    return _then(_self.copyWith(homeTactics: value));
  });
}/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TacticsSetupCopyWith<$Res> get awayTactics {
  
  return $TacticsSetupCopyWith<$Res>(_self.awayTactics, (value) {
    return _then(_self.copyWith(awayTactics: value));
  });
}/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchTeamSnapshotCopyWith<$Res> get homeSnapshot {
  
  return $MatchTeamSnapshotCopyWith<$Res>(_self.homeSnapshot, (value) {
    return _then(_self.copyWith(homeSnapshot: value));
  });
}/// Create a copy of MatchResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchTeamSnapshotCopyWith<$Res> get awaySnapshot {
  
  return $MatchTeamSnapshotCopyWith<$Res>(_self.awaySnapshot, (value) {
    return _then(_self.copyWith(awaySnapshot: value));
  });
}
}


/// @nodoc
mixin _$MatchSetup {

 String get homeTeamId; String get awayTeamId; List<Player> get homeLineup; List<Player> get awayLineup; TacticsSetup get homeTactics; TacticsSetup get awayTactics; bool get isHomeAdvantage; int get roundNumber;
/// Create a copy of MatchSetup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchSetupCopyWith<MatchSetup> get copyWith => _$MatchSetupCopyWithImpl<MatchSetup>(this as MatchSetup, _$identity);

  /// Serializes this MatchSetup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchSetup&&(identical(other.homeTeamId, homeTeamId) || other.homeTeamId == homeTeamId)&&(identical(other.awayTeamId, awayTeamId) || other.awayTeamId == awayTeamId)&&const DeepCollectionEquality().equals(other.homeLineup, homeLineup)&&const DeepCollectionEquality().equals(other.awayLineup, awayLineup)&&(identical(other.homeTactics, homeTactics) || other.homeTactics == homeTactics)&&(identical(other.awayTactics, awayTactics) || other.awayTactics == awayTactics)&&(identical(other.isHomeAdvantage, isHomeAdvantage) || other.isHomeAdvantage == isHomeAdvantage)&&(identical(other.roundNumber, roundNumber) || other.roundNumber == roundNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,homeTeamId,awayTeamId,const DeepCollectionEquality().hash(homeLineup),const DeepCollectionEquality().hash(awayLineup),homeTactics,awayTactics,isHomeAdvantage,roundNumber);

@override
String toString() {
  return 'MatchSetup(homeTeamId: $homeTeamId, awayTeamId: $awayTeamId, homeLineup: $homeLineup, awayLineup: $awayLineup, homeTactics: $homeTactics, awayTactics: $awayTactics, isHomeAdvantage: $isHomeAdvantage, roundNumber: $roundNumber)';
}


}

/// @nodoc
abstract mixin class $MatchSetupCopyWith<$Res>  {
  factory $MatchSetupCopyWith(MatchSetup value, $Res Function(MatchSetup) _then) = _$MatchSetupCopyWithImpl;
@useResult
$Res call({
 String homeTeamId, String awayTeamId, List<Player> homeLineup, List<Player> awayLineup, TacticsSetup homeTactics, TacticsSetup awayTactics, bool isHomeAdvantage, int roundNumber
});


$TacticsSetupCopyWith<$Res> get homeTactics;$TacticsSetupCopyWith<$Res> get awayTactics;

}
/// @nodoc
class _$MatchSetupCopyWithImpl<$Res>
    implements $MatchSetupCopyWith<$Res> {
  _$MatchSetupCopyWithImpl(this._self, this._then);

  final MatchSetup _self;
  final $Res Function(MatchSetup) _then;

/// Create a copy of MatchSetup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? homeTeamId = null,Object? awayTeamId = null,Object? homeLineup = null,Object? awayLineup = null,Object? homeTactics = null,Object? awayTactics = null,Object? isHomeAdvantage = null,Object? roundNumber = null,}) {
  return _then(_self.copyWith(
homeTeamId: null == homeTeamId ? _self.homeTeamId : homeTeamId // ignore: cast_nullable_to_non_nullable
as String,awayTeamId: null == awayTeamId ? _self.awayTeamId : awayTeamId // ignore: cast_nullable_to_non_nullable
as String,homeLineup: null == homeLineup ? _self.homeLineup : homeLineup // ignore: cast_nullable_to_non_nullable
as List<Player>,awayLineup: null == awayLineup ? _self.awayLineup : awayLineup // ignore: cast_nullable_to_non_nullable
as List<Player>,homeTactics: null == homeTactics ? _self.homeTactics : homeTactics // ignore: cast_nullable_to_non_nullable
as TacticsSetup,awayTactics: null == awayTactics ? _self.awayTactics : awayTactics // ignore: cast_nullable_to_non_nullable
as TacticsSetup,isHomeAdvantage: null == isHomeAdvantage ? _self.isHomeAdvantage : isHomeAdvantage // ignore: cast_nullable_to_non_nullable
as bool,roundNumber: null == roundNumber ? _self.roundNumber : roundNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of MatchSetup
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TacticsSetupCopyWith<$Res> get homeTactics {
  
  return $TacticsSetupCopyWith<$Res>(_self.homeTactics, (value) {
    return _then(_self.copyWith(homeTactics: value));
  });
}/// Create a copy of MatchSetup
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TacticsSetupCopyWith<$Res> get awayTactics {
  
  return $TacticsSetupCopyWith<$Res>(_self.awayTactics, (value) {
    return _then(_self.copyWith(awayTactics: value));
  });
}
}


/// Adds pattern-matching-related methods to [MatchSetup].
extension MatchSetupPatterns on MatchSetup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchSetup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchSetup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchSetup value)  $default,){
final _that = this;
switch (_that) {
case _MatchSetup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchSetup value)?  $default,){
final _that = this;
switch (_that) {
case _MatchSetup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String homeTeamId,  String awayTeamId,  List<Player> homeLineup,  List<Player> awayLineup,  TacticsSetup homeTactics,  TacticsSetup awayTactics,  bool isHomeAdvantage,  int roundNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchSetup() when $default != null:
return $default(_that.homeTeamId,_that.awayTeamId,_that.homeLineup,_that.awayLineup,_that.homeTactics,_that.awayTactics,_that.isHomeAdvantage,_that.roundNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String homeTeamId,  String awayTeamId,  List<Player> homeLineup,  List<Player> awayLineup,  TacticsSetup homeTactics,  TacticsSetup awayTactics,  bool isHomeAdvantage,  int roundNumber)  $default,) {final _that = this;
switch (_that) {
case _MatchSetup():
return $default(_that.homeTeamId,_that.awayTeamId,_that.homeLineup,_that.awayLineup,_that.homeTactics,_that.awayTactics,_that.isHomeAdvantage,_that.roundNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String homeTeamId,  String awayTeamId,  List<Player> homeLineup,  List<Player> awayLineup,  TacticsSetup homeTactics,  TacticsSetup awayTactics,  bool isHomeAdvantage,  int roundNumber)?  $default,) {final _that = this;
switch (_that) {
case _MatchSetup() when $default != null:
return $default(_that.homeTeamId,_that.awayTeamId,_that.homeLineup,_that.awayLineup,_that.homeTactics,_that.awayTactics,_that.isHomeAdvantage,_that.roundNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatchSetup implements MatchSetup {
  const _MatchSetup({required this.homeTeamId, required this.awayTeamId, required final  List<Player> homeLineup, required final  List<Player> awayLineup, required this.homeTactics, required this.awayTactics, this.isHomeAdvantage = false, this.roundNumber = 0}): _homeLineup = homeLineup,_awayLineup = awayLineup;
  factory _MatchSetup.fromJson(Map<String, dynamic> json) => _$MatchSetupFromJson(json);

@override final  String homeTeamId;
@override final  String awayTeamId;
 final  List<Player> _homeLineup;
@override List<Player> get homeLineup {
  if (_homeLineup is EqualUnmodifiableListView) return _homeLineup;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_homeLineup);
}

 final  List<Player> _awayLineup;
@override List<Player> get awayLineup {
  if (_awayLineup is EqualUnmodifiableListView) return _awayLineup;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_awayLineup);
}

@override final  TacticsSetup homeTactics;
@override final  TacticsSetup awayTactics;
@override@JsonKey() final  bool isHomeAdvantage;
@override@JsonKey() final  int roundNumber;

/// Create a copy of MatchSetup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchSetupCopyWith<_MatchSetup> get copyWith => __$MatchSetupCopyWithImpl<_MatchSetup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchSetupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchSetup&&(identical(other.homeTeamId, homeTeamId) || other.homeTeamId == homeTeamId)&&(identical(other.awayTeamId, awayTeamId) || other.awayTeamId == awayTeamId)&&const DeepCollectionEquality().equals(other._homeLineup, _homeLineup)&&const DeepCollectionEquality().equals(other._awayLineup, _awayLineup)&&(identical(other.homeTactics, homeTactics) || other.homeTactics == homeTactics)&&(identical(other.awayTactics, awayTactics) || other.awayTactics == awayTactics)&&(identical(other.isHomeAdvantage, isHomeAdvantage) || other.isHomeAdvantage == isHomeAdvantage)&&(identical(other.roundNumber, roundNumber) || other.roundNumber == roundNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,homeTeamId,awayTeamId,const DeepCollectionEquality().hash(_homeLineup),const DeepCollectionEquality().hash(_awayLineup),homeTactics,awayTactics,isHomeAdvantage,roundNumber);

@override
String toString() {
  return 'MatchSetup(homeTeamId: $homeTeamId, awayTeamId: $awayTeamId, homeLineup: $homeLineup, awayLineup: $awayLineup, homeTactics: $homeTactics, awayTactics: $awayTactics, isHomeAdvantage: $isHomeAdvantage, roundNumber: $roundNumber)';
}


}

/// @nodoc
abstract mixin class _$MatchSetupCopyWith<$Res> implements $MatchSetupCopyWith<$Res> {
  factory _$MatchSetupCopyWith(_MatchSetup value, $Res Function(_MatchSetup) _then) = __$MatchSetupCopyWithImpl;
@override @useResult
$Res call({
 String homeTeamId, String awayTeamId, List<Player> homeLineup, List<Player> awayLineup, TacticsSetup homeTactics, TacticsSetup awayTactics, bool isHomeAdvantage, int roundNumber
});


@override $TacticsSetupCopyWith<$Res> get homeTactics;@override $TacticsSetupCopyWith<$Res> get awayTactics;

}
/// @nodoc
class __$MatchSetupCopyWithImpl<$Res>
    implements _$MatchSetupCopyWith<$Res> {
  __$MatchSetupCopyWithImpl(this._self, this._then);

  final _MatchSetup _self;
  final $Res Function(_MatchSetup) _then;

/// Create a copy of MatchSetup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? homeTeamId = null,Object? awayTeamId = null,Object? homeLineup = null,Object? awayLineup = null,Object? homeTactics = null,Object? awayTactics = null,Object? isHomeAdvantage = null,Object? roundNumber = null,}) {
  return _then(_MatchSetup(
homeTeamId: null == homeTeamId ? _self.homeTeamId : homeTeamId // ignore: cast_nullable_to_non_nullable
as String,awayTeamId: null == awayTeamId ? _self.awayTeamId : awayTeamId // ignore: cast_nullable_to_non_nullable
as String,homeLineup: null == homeLineup ? _self._homeLineup : homeLineup // ignore: cast_nullable_to_non_nullable
as List<Player>,awayLineup: null == awayLineup ? _self._awayLineup : awayLineup // ignore: cast_nullable_to_non_nullable
as List<Player>,homeTactics: null == homeTactics ? _self.homeTactics : homeTactics // ignore: cast_nullable_to_non_nullable
as TacticsSetup,awayTactics: null == awayTactics ? _self.awayTactics : awayTactics // ignore: cast_nullable_to_non_nullable
as TacticsSetup,isHomeAdvantage: null == isHomeAdvantage ? _self.isHomeAdvantage : isHomeAdvantage // ignore: cast_nullable_to_non_nullable
as bool,roundNumber: null == roundNumber ? _self.roundNumber : roundNumber // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of MatchSetup
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TacticsSetupCopyWith<$Res> get homeTactics {
  
  return $TacticsSetupCopyWith<$Res>(_self.homeTactics, (value) {
    return _then(_self.copyWith(homeTactics: value));
  });
}/// Create a copy of MatchSetup
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TacticsSetupCopyWith<$Res> get awayTactics {
  
  return $TacticsSetupCopyWith<$Res>(_self.awayTactics, (value) {
    return _then(_self.copyWith(awayTactics: value));
  });
}
}


/// @nodoc
mixin _$ScheduledMatch {

 String get id; String get homeTeamId; String get awayTeamId; int get round; MatchResult? get result;
/// Create a copy of ScheduledMatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduledMatchCopyWith<ScheduledMatch> get copyWith => _$ScheduledMatchCopyWithImpl<ScheduledMatch>(this as ScheduledMatch, _$identity);

  /// Serializes this ScheduledMatch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduledMatch&&(identical(other.id, id) || other.id == id)&&(identical(other.homeTeamId, homeTeamId) || other.homeTeamId == homeTeamId)&&(identical(other.awayTeamId, awayTeamId) || other.awayTeamId == awayTeamId)&&(identical(other.round, round) || other.round == round)&&(identical(other.result, result) || other.result == result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,homeTeamId,awayTeamId,round,result);

@override
String toString() {
  return 'ScheduledMatch(id: $id, homeTeamId: $homeTeamId, awayTeamId: $awayTeamId, round: $round, result: $result)';
}


}

/// @nodoc
abstract mixin class $ScheduledMatchCopyWith<$Res>  {
  factory $ScheduledMatchCopyWith(ScheduledMatch value, $Res Function(ScheduledMatch) _then) = _$ScheduledMatchCopyWithImpl;
@useResult
$Res call({
 String id, String homeTeamId, String awayTeamId, int round, MatchResult? result
});


$MatchResultCopyWith<$Res>? get result;

}
/// @nodoc
class _$ScheduledMatchCopyWithImpl<$Res>
    implements $ScheduledMatchCopyWith<$Res> {
  _$ScheduledMatchCopyWithImpl(this._self, this._then);

  final ScheduledMatch _self;
  final $Res Function(ScheduledMatch) _then;

/// Create a copy of ScheduledMatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? homeTeamId = null,Object? awayTeamId = null,Object? round = null,Object? result = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,homeTeamId: null == homeTeamId ? _self.homeTeamId : homeTeamId // ignore: cast_nullable_to_non_nullable
as String,awayTeamId: null == awayTeamId ? _self.awayTeamId : awayTeamId // ignore: cast_nullable_to_non_nullable
as String,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as int,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as MatchResult?,
  ));
}
/// Create a copy of ScheduledMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $MatchResultCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// Adds pattern-matching-related methods to [ScheduledMatch].
extension ScheduledMatchPatterns on ScheduledMatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduledMatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduledMatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduledMatch value)  $default,){
final _that = this;
switch (_that) {
case _ScheduledMatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduledMatch value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduledMatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String homeTeamId,  String awayTeamId,  int round,  MatchResult? result)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduledMatch() when $default != null:
return $default(_that.id,_that.homeTeamId,_that.awayTeamId,_that.round,_that.result);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String homeTeamId,  String awayTeamId,  int round,  MatchResult? result)  $default,) {final _that = this;
switch (_that) {
case _ScheduledMatch():
return $default(_that.id,_that.homeTeamId,_that.awayTeamId,_that.round,_that.result);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String homeTeamId,  String awayTeamId,  int round,  MatchResult? result)?  $default,) {final _that = this;
switch (_that) {
case _ScheduledMatch() when $default != null:
return $default(_that.id,_that.homeTeamId,_that.awayTeamId,_that.round,_that.result);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduledMatch implements ScheduledMatch {
  const _ScheduledMatch({required this.id, required this.homeTeamId, required this.awayTeamId, required this.round, this.result});
  factory _ScheduledMatch.fromJson(Map<String, dynamic> json) => _$ScheduledMatchFromJson(json);

@override final  String id;
@override final  String homeTeamId;
@override final  String awayTeamId;
@override final  int round;
@override final  MatchResult? result;

/// Create a copy of ScheduledMatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduledMatchCopyWith<_ScheduledMatch> get copyWith => __$ScheduledMatchCopyWithImpl<_ScheduledMatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduledMatchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduledMatch&&(identical(other.id, id) || other.id == id)&&(identical(other.homeTeamId, homeTeamId) || other.homeTeamId == homeTeamId)&&(identical(other.awayTeamId, awayTeamId) || other.awayTeamId == awayTeamId)&&(identical(other.round, round) || other.round == round)&&(identical(other.result, result) || other.result == result));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,homeTeamId,awayTeamId,round,result);

@override
String toString() {
  return 'ScheduledMatch(id: $id, homeTeamId: $homeTeamId, awayTeamId: $awayTeamId, round: $round, result: $result)';
}


}

/// @nodoc
abstract mixin class _$ScheduledMatchCopyWith<$Res> implements $ScheduledMatchCopyWith<$Res> {
  factory _$ScheduledMatchCopyWith(_ScheduledMatch value, $Res Function(_ScheduledMatch) _then) = __$ScheduledMatchCopyWithImpl;
@override @useResult
$Res call({
 String id, String homeTeamId, String awayTeamId, int round, MatchResult? result
});


@override $MatchResultCopyWith<$Res>? get result;

}
/// @nodoc
class __$ScheduledMatchCopyWithImpl<$Res>
    implements _$ScheduledMatchCopyWith<$Res> {
  __$ScheduledMatchCopyWithImpl(this._self, this._then);

  final _ScheduledMatch _self;
  final $Res Function(_ScheduledMatch) _then;

/// Create a copy of ScheduledMatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? homeTeamId = null,Object? awayTeamId = null,Object? round = null,Object? result = freezed,}) {
  return _then(_ScheduledMatch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,homeTeamId: null == homeTeamId ? _self.homeTeamId : homeTeamId // ignore: cast_nullable_to_non_nullable
as String,awayTeamId: null == awayTeamId ? _self.awayTeamId : awayTeamId // ignore: cast_nullable_to_non_nullable
as String,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as int,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as MatchResult?,
  ));
}

/// Create a copy of ScheduledMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $MatchResultCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// @nodoc
mixin _$PlayoffSeries {

 String get id; String get higherSeedTeamId; String get lowerSeedTeamId; int get winsNeeded; int get higherSeedWins; int get lowerSeedWins; List<MatchResult> get games; String? get winnerTeamId;
/// Create a copy of PlayoffSeries
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayoffSeriesCopyWith<PlayoffSeries> get copyWith => _$PlayoffSeriesCopyWithImpl<PlayoffSeries>(this as PlayoffSeries, _$identity);

  /// Serializes this PlayoffSeries to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayoffSeries&&(identical(other.id, id) || other.id == id)&&(identical(other.higherSeedTeamId, higherSeedTeamId) || other.higherSeedTeamId == higherSeedTeamId)&&(identical(other.lowerSeedTeamId, lowerSeedTeamId) || other.lowerSeedTeamId == lowerSeedTeamId)&&(identical(other.winsNeeded, winsNeeded) || other.winsNeeded == winsNeeded)&&(identical(other.higherSeedWins, higherSeedWins) || other.higherSeedWins == higherSeedWins)&&(identical(other.lowerSeedWins, lowerSeedWins) || other.lowerSeedWins == lowerSeedWins)&&const DeepCollectionEquality().equals(other.games, games)&&(identical(other.winnerTeamId, winnerTeamId) || other.winnerTeamId == winnerTeamId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,higherSeedTeamId,lowerSeedTeamId,winsNeeded,higherSeedWins,lowerSeedWins,const DeepCollectionEquality().hash(games),winnerTeamId);

@override
String toString() {
  return 'PlayoffSeries(id: $id, higherSeedTeamId: $higherSeedTeamId, lowerSeedTeamId: $lowerSeedTeamId, winsNeeded: $winsNeeded, higherSeedWins: $higherSeedWins, lowerSeedWins: $lowerSeedWins, games: $games, winnerTeamId: $winnerTeamId)';
}


}

/// @nodoc
abstract mixin class $PlayoffSeriesCopyWith<$Res>  {
  factory $PlayoffSeriesCopyWith(PlayoffSeries value, $Res Function(PlayoffSeries) _then) = _$PlayoffSeriesCopyWithImpl;
@useResult
$Res call({
 String id, String higherSeedTeamId, String lowerSeedTeamId, int winsNeeded, int higherSeedWins, int lowerSeedWins, List<MatchResult> games, String? winnerTeamId
});




}
/// @nodoc
class _$PlayoffSeriesCopyWithImpl<$Res>
    implements $PlayoffSeriesCopyWith<$Res> {
  _$PlayoffSeriesCopyWithImpl(this._self, this._then);

  final PlayoffSeries _self;
  final $Res Function(PlayoffSeries) _then;

/// Create a copy of PlayoffSeries
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? higherSeedTeamId = null,Object? lowerSeedTeamId = null,Object? winsNeeded = null,Object? higherSeedWins = null,Object? lowerSeedWins = null,Object? games = null,Object? winnerTeamId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,higherSeedTeamId: null == higherSeedTeamId ? _self.higherSeedTeamId : higherSeedTeamId // ignore: cast_nullable_to_non_nullable
as String,lowerSeedTeamId: null == lowerSeedTeamId ? _self.lowerSeedTeamId : lowerSeedTeamId // ignore: cast_nullable_to_non_nullable
as String,winsNeeded: null == winsNeeded ? _self.winsNeeded : winsNeeded // ignore: cast_nullable_to_non_nullable
as int,higherSeedWins: null == higherSeedWins ? _self.higherSeedWins : higherSeedWins // ignore: cast_nullable_to_non_nullable
as int,lowerSeedWins: null == lowerSeedWins ? _self.lowerSeedWins : lowerSeedWins // ignore: cast_nullable_to_non_nullable
as int,games: null == games ? _self.games : games // ignore: cast_nullable_to_non_nullable
as List<MatchResult>,winnerTeamId: freezed == winnerTeamId ? _self.winnerTeamId : winnerTeamId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayoffSeries].
extension PlayoffSeriesPatterns on PlayoffSeries {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayoffSeries value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayoffSeries() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayoffSeries value)  $default,){
final _that = this;
switch (_that) {
case _PlayoffSeries():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayoffSeries value)?  $default,){
final _that = this;
switch (_that) {
case _PlayoffSeries() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String higherSeedTeamId,  String lowerSeedTeamId,  int winsNeeded,  int higherSeedWins,  int lowerSeedWins,  List<MatchResult> games,  String? winnerTeamId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayoffSeries() when $default != null:
return $default(_that.id,_that.higherSeedTeamId,_that.lowerSeedTeamId,_that.winsNeeded,_that.higherSeedWins,_that.lowerSeedWins,_that.games,_that.winnerTeamId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String higherSeedTeamId,  String lowerSeedTeamId,  int winsNeeded,  int higherSeedWins,  int lowerSeedWins,  List<MatchResult> games,  String? winnerTeamId)  $default,) {final _that = this;
switch (_that) {
case _PlayoffSeries():
return $default(_that.id,_that.higherSeedTeamId,_that.lowerSeedTeamId,_that.winsNeeded,_that.higherSeedWins,_that.lowerSeedWins,_that.games,_that.winnerTeamId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String higherSeedTeamId,  String lowerSeedTeamId,  int winsNeeded,  int higherSeedWins,  int lowerSeedWins,  List<MatchResult> games,  String? winnerTeamId)?  $default,) {final _that = this;
switch (_that) {
case _PlayoffSeries() when $default != null:
return $default(_that.id,_that.higherSeedTeamId,_that.lowerSeedTeamId,_that.winsNeeded,_that.higherSeedWins,_that.lowerSeedWins,_that.games,_that.winnerTeamId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayoffSeries implements PlayoffSeries {
  const _PlayoffSeries({required this.id, required this.higherSeedTeamId, required this.lowerSeedTeamId, required this.winsNeeded, this.higherSeedWins = 0, this.lowerSeedWins = 0, final  List<MatchResult> games = const [], this.winnerTeamId}): _games = games;
  factory _PlayoffSeries.fromJson(Map<String, dynamic> json) => _$PlayoffSeriesFromJson(json);

@override final  String id;
@override final  String higherSeedTeamId;
@override final  String lowerSeedTeamId;
@override final  int winsNeeded;
@override@JsonKey() final  int higherSeedWins;
@override@JsonKey() final  int lowerSeedWins;
 final  List<MatchResult> _games;
@override@JsonKey() List<MatchResult> get games {
  if (_games is EqualUnmodifiableListView) return _games;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_games);
}

@override final  String? winnerTeamId;

/// Create a copy of PlayoffSeries
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayoffSeriesCopyWith<_PlayoffSeries> get copyWith => __$PlayoffSeriesCopyWithImpl<_PlayoffSeries>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayoffSeriesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayoffSeries&&(identical(other.id, id) || other.id == id)&&(identical(other.higherSeedTeamId, higherSeedTeamId) || other.higherSeedTeamId == higherSeedTeamId)&&(identical(other.lowerSeedTeamId, lowerSeedTeamId) || other.lowerSeedTeamId == lowerSeedTeamId)&&(identical(other.winsNeeded, winsNeeded) || other.winsNeeded == winsNeeded)&&(identical(other.higherSeedWins, higherSeedWins) || other.higherSeedWins == higherSeedWins)&&(identical(other.lowerSeedWins, lowerSeedWins) || other.lowerSeedWins == lowerSeedWins)&&const DeepCollectionEquality().equals(other._games, _games)&&(identical(other.winnerTeamId, winnerTeamId) || other.winnerTeamId == winnerTeamId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,higherSeedTeamId,lowerSeedTeamId,winsNeeded,higherSeedWins,lowerSeedWins,const DeepCollectionEquality().hash(_games),winnerTeamId);

@override
String toString() {
  return 'PlayoffSeries(id: $id, higherSeedTeamId: $higherSeedTeamId, lowerSeedTeamId: $lowerSeedTeamId, winsNeeded: $winsNeeded, higherSeedWins: $higherSeedWins, lowerSeedWins: $lowerSeedWins, games: $games, winnerTeamId: $winnerTeamId)';
}


}

/// @nodoc
abstract mixin class _$PlayoffSeriesCopyWith<$Res> implements $PlayoffSeriesCopyWith<$Res> {
  factory _$PlayoffSeriesCopyWith(_PlayoffSeries value, $Res Function(_PlayoffSeries) _then) = __$PlayoffSeriesCopyWithImpl;
@override @useResult
$Res call({
 String id, String higherSeedTeamId, String lowerSeedTeamId, int winsNeeded, int higherSeedWins, int lowerSeedWins, List<MatchResult> games, String? winnerTeamId
});




}
/// @nodoc
class __$PlayoffSeriesCopyWithImpl<$Res>
    implements _$PlayoffSeriesCopyWith<$Res> {
  __$PlayoffSeriesCopyWithImpl(this._self, this._then);

  final _PlayoffSeries _self;
  final $Res Function(_PlayoffSeries) _then;

/// Create a copy of PlayoffSeries
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? higherSeedTeamId = null,Object? lowerSeedTeamId = null,Object? winsNeeded = null,Object? higherSeedWins = null,Object? lowerSeedWins = null,Object? games = null,Object? winnerTeamId = freezed,}) {
  return _then(_PlayoffSeries(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,higherSeedTeamId: null == higherSeedTeamId ? _self.higherSeedTeamId : higherSeedTeamId // ignore: cast_nullable_to_non_nullable
as String,lowerSeedTeamId: null == lowerSeedTeamId ? _self.lowerSeedTeamId : lowerSeedTeamId // ignore: cast_nullable_to_non_nullable
as String,winsNeeded: null == winsNeeded ? _self.winsNeeded : winsNeeded // ignore: cast_nullable_to_non_nullable
as int,higherSeedWins: null == higherSeedWins ? _self.higherSeedWins : higherSeedWins // ignore: cast_nullable_to_non_nullable
as int,lowerSeedWins: null == lowerSeedWins ? _self.lowerSeedWins : lowerSeedWins // ignore: cast_nullable_to_non_nullable
as int,games: null == games ? _self._games : games // ignore: cast_nullable_to_non_nullable
as List<MatchResult>,winnerTeamId: freezed == winnerTeamId ? _self.winnerTeamId : winnerTeamId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
