// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contract_market_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DraftedPlayerRights {

 String get id; String get ownerTeamId; Player get player; int get draftYear; int get pickNumber; bool get reminderSent;
/// Create a copy of DraftedPlayerRights
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftedPlayerRightsCopyWith<DraftedPlayerRights> get copyWith => _$DraftedPlayerRightsCopyWithImpl<DraftedPlayerRights>(this as DraftedPlayerRights, _$identity);

  /// Serializes this DraftedPlayerRights to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DraftedPlayerRights&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerTeamId, ownerTeamId) || other.ownerTeamId == ownerTeamId)&&(identical(other.player, player) || other.player == player)&&(identical(other.draftYear, draftYear) || other.draftYear == draftYear)&&(identical(other.pickNumber, pickNumber) || other.pickNumber == pickNumber)&&(identical(other.reminderSent, reminderSent) || other.reminderSent == reminderSent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerTeamId,player,draftYear,pickNumber,reminderSent);

@override
String toString() {
  return 'DraftedPlayerRights(id: $id, ownerTeamId: $ownerTeamId, player: $player, draftYear: $draftYear, pickNumber: $pickNumber, reminderSent: $reminderSent)';
}


}

/// @nodoc
abstract mixin class $DraftedPlayerRightsCopyWith<$Res>  {
  factory $DraftedPlayerRightsCopyWith(DraftedPlayerRights value, $Res Function(DraftedPlayerRights) _then) = _$DraftedPlayerRightsCopyWithImpl;
@useResult
$Res call({
 String id, String ownerTeamId, Player player, int draftYear, int pickNumber, bool reminderSent
});


$PlayerCopyWith<$Res> get player;

}
/// @nodoc
class _$DraftedPlayerRightsCopyWithImpl<$Res>
    implements $DraftedPlayerRightsCopyWith<$Res> {
  _$DraftedPlayerRightsCopyWithImpl(this._self, this._then);

  final DraftedPlayerRights _self;
  final $Res Function(DraftedPlayerRights) _then;

/// Create a copy of DraftedPlayerRights
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerTeamId = null,Object? player = null,Object? draftYear = null,Object? pickNumber = null,Object? reminderSent = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerTeamId: null == ownerTeamId ? _self.ownerTeamId : ownerTeamId // ignore: cast_nullable_to_non_nullable
as String,player: null == player ? _self.player : player // ignore: cast_nullable_to_non_nullable
as Player,draftYear: null == draftYear ? _self.draftYear : draftYear // ignore: cast_nullable_to_non_nullable
as int,pickNumber: null == pickNumber ? _self.pickNumber : pickNumber // ignore: cast_nullable_to_non_nullable
as int,reminderSent: null == reminderSent ? _self.reminderSent : reminderSent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of DraftedPlayerRights
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerCopyWith<$Res> get player {
  
  return $PlayerCopyWith<$Res>(_self.player, (value) {
    return _then(_self.copyWith(player: value));
  });
}
}


/// Adds pattern-matching-related methods to [DraftedPlayerRights].
extension DraftedPlayerRightsPatterns on DraftedPlayerRights {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DraftedPlayerRights value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DraftedPlayerRights() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DraftedPlayerRights value)  $default,){
final _that = this;
switch (_that) {
case _DraftedPlayerRights():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DraftedPlayerRights value)?  $default,){
final _that = this;
switch (_that) {
case _DraftedPlayerRights() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ownerTeamId,  Player player,  int draftYear,  int pickNumber,  bool reminderSent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DraftedPlayerRights() when $default != null:
return $default(_that.id,_that.ownerTeamId,_that.player,_that.draftYear,_that.pickNumber,_that.reminderSent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ownerTeamId,  Player player,  int draftYear,  int pickNumber,  bool reminderSent)  $default,) {final _that = this;
switch (_that) {
case _DraftedPlayerRights():
return $default(_that.id,_that.ownerTeamId,_that.player,_that.draftYear,_that.pickNumber,_that.reminderSent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ownerTeamId,  Player player,  int draftYear,  int pickNumber,  bool reminderSent)?  $default,) {final _that = this;
switch (_that) {
case _DraftedPlayerRights() when $default != null:
return $default(_that.id,_that.ownerTeamId,_that.player,_that.draftYear,_that.pickNumber,_that.reminderSent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DraftedPlayerRights implements DraftedPlayerRights {
  const _DraftedPlayerRights({required this.id, required this.ownerTeamId, required this.player, required this.draftYear, required this.pickNumber, this.reminderSent = false});
  factory _DraftedPlayerRights.fromJson(Map<String, dynamic> json) => _$DraftedPlayerRightsFromJson(json);

@override final  String id;
@override final  String ownerTeamId;
@override final  Player player;
@override final  int draftYear;
@override final  int pickNumber;
@override@JsonKey() final  bool reminderSent;

/// Create a copy of DraftedPlayerRights
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftedPlayerRightsCopyWith<_DraftedPlayerRights> get copyWith => __$DraftedPlayerRightsCopyWithImpl<_DraftedPlayerRights>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DraftedPlayerRightsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DraftedPlayerRights&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerTeamId, ownerTeamId) || other.ownerTeamId == ownerTeamId)&&(identical(other.player, player) || other.player == player)&&(identical(other.draftYear, draftYear) || other.draftYear == draftYear)&&(identical(other.pickNumber, pickNumber) || other.pickNumber == pickNumber)&&(identical(other.reminderSent, reminderSent) || other.reminderSent == reminderSent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ownerTeamId,player,draftYear,pickNumber,reminderSent);

@override
String toString() {
  return 'DraftedPlayerRights(id: $id, ownerTeamId: $ownerTeamId, player: $player, draftYear: $draftYear, pickNumber: $pickNumber, reminderSent: $reminderSent)';
}


}

/// @nodoc
abstract mixin class _$DraftedPlayerRightsCopyWith<$Res> implements $DraftedPlayerRightsCopyWith<$Res> {
  factory _$DraftedPlayerRightsCopyWith(_DraftedPlayerRights value, $Res Function(_DraftedPlayerRights) _then) = __$DraftedPlayerRightsCopyWithImpl;
@override @useResult
$Res call({
 String id, String ownerTeamId, Player player, int draftYear, int pickNumber, bool reminderSent
});


@override $PlayerCopyWith<$Res> get player;

}
/// @nodoc
class __$DraftedPlayerRightsCopyWithImpl<$Res>
    implements _$DraftedPlayerRightsCopyWith<$Res> {
  __$DraftedPlayerRightsCopyWithImpl(this._self, this._then);

  final _DraftedPlayerRights _self;
  final $Res Function(_DraftedPlayerRights) _then;

/// Create a copy of DraftedPlayerRights
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerTeamId = null,Object? player = null,Object? draftYear = null,Object? pickNumber = null,Object? reminderSent = null,}) {
  return _then(_DraftedPlayerRights(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerTeamId: null == ownerTeamId ? _self.ownerTeamId : ownerTeamId // ignore: cast_nullable_to_non_nullable
as String,player: null == player ? _self.player : player // ignore: cast_nullable_to_non_nullable
as Player,draftYear: null == draftYear ? _self.draftYear : draftYear // ignore: cast_nullable_to_non_nullable
as int,pickNumber: null == pickNumber ? _self.pickNumber : pickNumber // ignore: cast_nullable_to_non_nullable
as int,reminderSent: null == reminderSent ? _self.reminderSent : reminderSent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of DraftedPlayerRights
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerCopyWith<$Res> get player {
  
  return $PlayerCopyWith<$Res>(_self.player, (value) {
    return _then(_self.copyWith(player: value));
  });
}
}


/// @nodoc
mixin _$FreshUndraftedPlayer {

 String get playerId; int get draftYear; int get activeFromSeasonYear; int get activeFromWeek; int get activeUntilSeasonYear; int get activeUntilWeek;
/// Create a copy of FreshUndraftedPlayer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FreshUndraftedPlayerCopyWith<FreshUndraftedPlayer> get copyWith => _$FreshUndraftedPlayerCopyWithImpl<FreshUndraftedPlayer>(this as FreshUndraftedPlayer, _$identity);

  /// Serializes this FreshUndraftedPlayer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FreshUndraftedPlayer&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.draftYear, draftYear) || other.draftYear == draftYear)&&(identical(other.activeFromSeasonYear, activeFromSeasonYear) || other.activeFromSeasonYear == activeFromSeasonYear)&&(identical(other.activeFromWeek, activeFromWeek) || other.activeFromWeek == activeFromWeek)&&(identical(other.activeUntilSeasonYear, activeUntilSeasonYear) || other.activeUntilSeasonYear == activeUntilSeasonYear)&&(identical(other.activeUntilWeek, activeUntilWeek) || other.activeUntilWeek == activeUntilWeek));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerId,draftYear,activeFromSeasonYear,activeFromWeek,activeUntilSeasonYear,activeUntilWeek);

@override
String toString() {
  return 'FreshUndraftedPlayer(playerId: $playerId, draftYear: $draftYear, activeFromSeasonYear: $activeFromSeasonYear, activeFromWeek: $activeFromWeek, activeUntilSeasonYear: $activeUntilSeasonYear, activeUntilWeek: $activeUntilWeek)';
}


}

/// @nodoc
abstract mixin class $FreshUndraftedPlayerCopyWith<$Res>  {
  factory $FreshUndraftedPlayerCopyWith(FreshUndraftedPlayer value, $Res Function(FreshUndraftedPlayer) _then) = _$FreshUndraftedPlayerCopyWithImpl;
@useResult
$Res call({
 String playerId, int draftYear, int activeFromSeasonYear, int activeFromWeek, int activeUntilSeasonYear, int activeUntilWeek
});




}
/// @nodoc
class _$FreshUndraftedPlayerCopyWithImpl<$Res>
    implements $FreshUndraftedPlayerCopyWith<$Res> {
  _$FreshUndraftedPlayerCopyWithImpl(this._self, this._then);

  final FreshUndraftedPlayer _self;
  final $Res Function(FreshUndraftedPlayer) _then;

/// Create a copy of FreshUndraftedPlayer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playerId = null,Object? draftYear = null,Object? activeFromSeasonYear = null,Object? activeFromWeek = null,Object? activeUntilSeasonYear = null,Object? activeUntilWeek = null,}) {
  return _then(_self.copyWith(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,draftYear: null == draftYear ? _self.draftYear : draftYear // ignore: cast_nullable_to_non_nullable
as int,activeFromSeasonYear: null == activeFromSeasonYear ? _self.activeFromSeasonYear : activeFromSeasonYear // ignore: cast_nullable_to_non_nullable
as int,activeFromWeek: null == activeFromWeek ? _self.activeFromWeek : activeFromWeek // ignore: cast_nullable_to_non_nullable
as int,activeUntilSeasonYear: null == activeUntilSeasonYear ? _self.activeUntilSeasonYear : activeUntilSeasonYear // ignore: cast_nullable_to_non_nullable
as int,activeUntilWeek: null == activeUntilWeek ? _self.activeUntilWeek : activeUntilWeek // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FreshUndraftedPlayer].
extension FreshUndraftedPlayerPatterns on FreshUndraftedPlayer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FreshUndraftedPlayer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FreshUndraftedPlayer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FreshUndraftedPlayer value)  $default,){
final _that = this;
switch (_that) {
case _FreshUndraftedPlayer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FreshUndraftedPlayer value)?  $default,){
final _that = this;
switch (_that) {
case _FreshUndraftedPlayer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String playerId,  int draftYear,  int activeFromSeasonYear,  int activeFromWeek,  int activeUntilSeasonYear,  int activeUntilWeek)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FreshUndraftedPlayer() when $default != null:
return $default(_that.playerId,_that.draftYear,_that.activeFromSeasonYear,_that.activeFromWeek,_that.activeUntilSeasonYear,_that.activeUntilWeek);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String playerId,  int draftYear,  int activeFromSeasonYear,  int activeFromWeek,  int activeUntilSeasonYear,  int activeUntilWeek)  $default,) {final _that = this;
switch (_that) {
case _FreshUndraftedPlayer():
return $default(_that.playerId,_that.draftYear,_that.activeFromSeasonYear,_that.activeFromWeek,_that.activeUntilSeasonYear,_that.activeUntilWeek);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String playerId,  int draftYear,  int activeFromSeasonYear,  int activeFromWeek,  int activeUntilSeasonYear,  int activeUntilWeek)?  $default,) {final _that = this;
switch (_that) {
case _FreshUndraftedPlayer() when $default != null:
return $default(_that.playerId,_that.draftYear,_that.activeFromSeasonYear,_that.activeFromWeek,_that.activeUntilSeasonYear,_that.activeUntilWeek);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FreshUndraftedPlayer implements FreshUndraftedPlayer {
  const _FreshUndraftedPlayer({required this.playerId, required this.draftYear, required this.activeFromSeasonYear, required this.activeFromWeek, required this.activeUntilSeasonYear, required this.activeUntilWeek});
  factory _FreshUndraftedPlayer.fromJson(Map<String, dynamic> json) => _$FreshUndraftedPlayerFromJson(json);

@override final  String playerId;
@override final  int draftYear;
@override final  int activeFromSeasonYear;
@override final  int activeFromWeek;
@override final  int activeUntilSeasonYear;
@override final  int activeUntilWeek;

/// Create a copy of FreshUndraftedPlayer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FreshUndraftedPlayerCopyWith<_FreshUndraftedPlayer> get copyWith => __$FreshUndraftedPlayerCopyWithImpl<_FreshUndraftedPlayer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FreshUndraftedPlayerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FreshUndraftedPlayer&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.draftYear, draftYear) || other.draftYear == draftYear)&&(identical(other.activeFromSeasonYear, activeFromSeasonYear) || other.activeFromSeasonYear == activeFromSeasonYear)&&(identical(other.activeFromWeek, activeFromWeek) || other.activeFromWeek == activeFromWeek)&&(identical(other.activeUntilSeasonYear, activeUntilSeasonYear) || other.activeUntilSeasonYear == activeUntilSeasonYear)&&(identical(other.activeUntilWeek, activeUntilWeek) || other.activeUntilWeek == activeUntilWeek));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerId,draftYear,activeFromSeasonYear,activeFromWeek,activeUntilSeasonYear,activeUntilWeek);

@override
String toString() {
  return 'FreshUndraftedPlayer(playerId: $playerId, draftYear: $draftYear, activeFromSeasonYear: $activeFromSeasonYear, activeFromWeek: $activeFromWeek, activeUntilSeasonYear: $activeUntilSeasonYear, activeUntilWeek: $activeUntilWeek)';
}


}

/// @nodoc
abstract mixin class _$FreshUndraftedPlayerCopyWith<$Res> implements $FreshUndraftedPlayerCopyWith<$Res> {
  factory _$FreshUndraftedPlayerCopyWith(_FreshUndraftedPlayer value, $Res Function(_FreshUndraftedPlayer) _then) = __$FreshUndraftedPlayerCopyWithImpl;
@override @useResult
$Res call({
 String playerId, int draftYear, int activeFromSeasonYear, int activeFromWeek, int activeUntilSeasonYear, int activeUntilWeek
});




}
/// @nodoc
class __$FreshUndraftedPlayerCopyWithImpl<$Res>
    implements _$FreshUndraftedPlayerCopyWith<$Res> {
  __$FreshUndraftedPlayerCopyWithImpl(this._self, this._then);

  final _FreshUndraftedPlayer _self;
  final $Res Function(_FreshUndraftedPlayer) _then;

/// Create a copy of FreshUndraftedPlayer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playerId = null,Object? draftYear = null,Object? activeFromSeasonYear = null,Object? activeFromWeek = null,Object? activeUntilSeasonYear = null,Object? activeUntilWeek = null,}) {
  return _then(_FreshUndraftedPlayer(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,draftYear: null == draftYear ? _self.draftYear : draftYear // ignore: cast_nullable_to_non_nullable
as int,activeFromSeasonYear: null == activeFromSeasonYear ? _self.activeFromSeasonYear : activeFromSeasonYear // ignore: cast_nullable_to_non_nullable
as int,activeFromWeek: null == activeFromWeek ? _self.activeFromWeek : activeFromWeek // ignore: cast_nullable_to_non_nullable
as int,activeUntilSeasonYear: null == activeUntilSeasonYear ? _self.activeUntilSeasonYear : activeUntilSeasonYear // ignore: cast_nullable_to_non_nullable
as int,activeUntilWeek: null == activeUntilWeek ? _self.activeUntilWeek : activeUntilWeek // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RfaQualifyingOffer {

 String get playerId; String get ownerTeamId; int get salary; int get years; int get seasonYear; bool get declined;
/// Create a copy of RfaQualifyingOffer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RfaQualifyingOfferCopyWith<RfaQualifyingOffer> get copyWith => _$RfaQualifyingOfferCopyWithImpl<RfaQualifyingOffer>(this as RfaQualifyingOffer, _$identity);

  /// Serializes this RfaQualifyingOffer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RfaQualifyingOffer&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.ownerTeamId, ownerTeamId) || other.ownerTeamId == ownerTeamId)&&(identical(other.salary, salary) || other.salary == salary)&&(identical(other.years, years) || other.years == years)&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear)&&(identical(other.declined, declined) || other.declined == declined));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerId,ownerTeamId,salary,years,seasonYear,declined);

@override
String toString() {
  return 'RfaQualifyingOffer(playerId: $playerId, ownerTeamId: $ownerTeamId, salary: $salary, years: $years, seasonYear: $seasonYear, declined: $declined)';
}


}

/// @nodoc
abstract mixin class $RfaQualifyingOfferCopyWith<$Res>  {
  factory $RfaQualifyingOfferCopyWith(RfaQualifyingOffer value, $Res Function(RfaQualifyingOffer) _then) = _$RfaQualifyingOfferCopyWithImpl;
@useResult
$Res call({
 String playerId, String ownerTeamId, int salary, int years, int seasonYear, bool declined
});




}
/// @nodoc
class _$RfaQualifyingOfferCopyWithImpl<$Res>
    implements $RfaQualifyingOfferCopyWith<$Res> {
  _$RfaQualifyingOfferCopyWithImpl(this._self, this._then);

  final RfaQualifyingOffer _self;
  final $Res Function(RfaQualifyingOffer) _then;

/// Create a copy of RfaQualifyingOffer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playerId = null,Object? ownerTeamId = null,Object? salary = null,Object? years = null,Object? seasonYear = null,Object? declined = null,}) {
  return _then(_self.copyWith(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,ownerTeamId: null == ownerTeamId ? _self.ownerTeamId : ownerTeamId // ignore: cast_nullable_to_non_nullable
as String,salary: null == salary ? _self.salary : salary // ignore: cast_nullable_to_non_nullable
as int,years: null == years ? _self.years : years // ignore: cast_nullable_to_non_nullable
as int,seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,declined: null == declined ? _self.declined : declined // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RfaQualifyingOffer].
extension RfaQualifyingOfferPatterns on RfaQualifyingOffer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RfaQualifyingOffer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RfaQualifyingOffer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RfaQualifyingOffer value)  $default,){
final _that = this;
switch (_that) {
case _RfaQualifyingOffer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RfaQualifyingOffer value)?  $default,){
final _that = this;
switch (_that) {
case _RfaQualifyingOffer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String playerId,  String ownerTeamId,  int salary,  int years,  int seasonYear,  bool declined)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RfaQualifyingOffer() when $default != null:
return $default(_that.playerId,_that.ownerTeamId,_that.salary,_that.years,_that.seasonYear,_that.declined);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String playerId,  String ownerTeamId,  int salary,  int years,  int seasonYear,  bool declined)  $default,) {final _that = this;
switch (_that) {
case _RfaQualifyingOffer():
return $default(_that.playerId,_that.ownerTeamId,_that.salary,_that.years,_that.seasonYear,_that.declined);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String playerId,  String ownerTeamId,  int salary,  int years,  int seasonYear,  bool declined)?  $default,) {final _that = this;
switch (_that) {
case _RfaQualifyingOffer() when $default != null:
return $default(_that.playerId,_that.ownerTeamId,_that.salary,_that.years,_that.seasonYear,_that.declined);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RfaQualifyingOffer implements RfaQualifyingOffer {
  const _RfaQualifyingOffer({required this.playerId, required this.ownerTeamId, required this.salary, this.years = 1, required this.seasonYear, this.declined = false});
  factory _RfaQualifyingOffer.fromJson(Map<String, dynamic> json) => _$RfaQualifyingOfferFromJson(json);

@override final  String playerId;
@override final  String ownerTeamId;
@override final  int salary;
@override@JsonKey() final  int years;
@override final  int seasonYear;
@override@JsonKey() final  bool declined;

/// Create a copy of RfaQualifyingOffer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RfaQualifyingOfferCopyWith<_RfaQualifyingOffer> get copyWith => __$RfaQualifyingOfferCopyWithImpl<_RfaQualifyingOffer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RfaQualifyingOfferToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RfaQualifyingOffer&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.ownerTeamId, ownerTeamId) || other.ownerTeamId == ownerTeamId)&&(identical(other.salary, salary) || other.salary == salary)&&(identical(other.years, years) || other.years == years)&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear)&&(identical(other.declined, declined) || other.declined == declined));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerId,ownerTeamId,salary,years,seasonYear,declined);

@override
String toString() {
  return 'RfaQualifyingOffer(playerId: $playerId, ownerTeamId: $ownerTeamId, salary: $salary, years: $years, seasonYear: $seasonYear, declined: $declined)';
}


}

/// @nodoc
abstract mixin class _$RfaQualifyingOfferCopyWith<$Res> implements $RfaQualifyingOfferCopyWith<$Res> {
  factory _$RfaQualifyingOfferCopyWith(_RfaQualifyingOffer value, $Res Function(_RfaQualifyingOffer) _then) = __$RfaQualifyingOfferCopyWithImpl;
@override @useResult
$Res call({
 String playerId, String ownerTeamId, int salary, int years, int seasonYear, bool declined
});




}
/// @nodoc
class __$RfaQualifyingOfferCopyWithImpl<$Res>
    implements _$RfaQualifyingOfferCopyWith<$Res> {
  __$RfaQualifyingOfferCopyWithImpl(this._self, this._then);

  final _RfaQualifyingOffer _self;
  final $Res Function(_RfaQualifyingOffer) _then;

/// Create a copy of RfaQualifyingOffer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playerId = null,Object? ownerTeamId = null,Object? salary = null,Object? years = null,Object? seasonYear = null,Object? declined = null,}) {
  return _then(_RfaQualifyingOffer(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,ownerTeamId: null == ownerTeamId ? _self.ownerTeamId : ownerTeamId // ignore: cast_nullable_to_non_nullable
as String,salary: null == salary ? _self.salary : salary // ignore: cast_nullable_to_non_nullable
as int,years: null == years ? _self.years : years // ignore: cast_nullable_to_non_nullable
as int,seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,declined: null == declined ? _self.declined : declined // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$RfaOfferSheet {

 String get id; String get playerId; String get originalTeamId; String get offeringTeamId; int get salary; int get years; NegotiationPhase get phase; int get seasonYear; int get week; int get day; int get hour; int get expirySeasonYear; int get expiryWeek; int get expiryDay; int get expiryHour; bool get matched; bool get declined;
/// Create a copy of RfaOfferSheet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RfaOfferSheetCopyWith<RfaOfferSheet> get copyWith => _$RfaOfferSheetCopyWithImpl<RfaOfferSheet>(this as RfaOfferSheet, _$identity);

  /// Serializes this RfaOfferSheet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RfaOfferSheet&&(identical(other.id, id) || other.id == id)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.originalTeamId, originalTeamId) || other.originalTeamId == originalTeamId)&&(identical(other.offeringTeamId, offeringTeamId) || other.offeringTeamId == offeringTeamId)&&(identical(other.salary, salary) || other.salary == salary)&&(identical(other.years, years) || other.years == years)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear)&&(identical(other.week, week) || other.week == week)&&(identical(other.day, day) || other.day == day)&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.expirySeasonYear, expirySeasonYear) || other.expirySeasonYear == expirySeasonYear)&&(identical(other.expiryWeek, expiryWeek) || other.expiryWeek == expiryWeek)&&(identical(other.expiryDay, expiryDay) || other.expiryDay == expiryDay)&&(identical(other.expiryHour, expiryHour) || other.expiryHour == expiryHour)&&(identical(other.matched, matched) || other.matched == matched)&&(identical(other.declined, declined) || other.declined == declined));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,playerId,originalTeamId,offeringTeamId,salary,years,phase,seasonYear,week,day,hour,expirySeasonYear,expiryWeek,expiryDay,expiryHour,matched,declined);

@override
String toString() {
  return 'RfaOfferSheet(id: $id, playerId: $playerId, originalTeamId: $originalTeamId, offeringTeamId: $offeringTeamId, salary: $salary, years: $years, phase: $phase, seasonYear: $seasonYear, week: $week, day: $day, hour: $hour, expirySeasonYear: $expirySeasonYear, expiryWeek: $expiryWeek, expiryDay: $expiryDay, expiryHour: $expiryHour, matched: $matched, declined: $declined)';
}


}

/// @nodoc
abstract mixin class $RfaOfferSheetCopyWith<$Res>  {
  factory $RfaOfferSheetCopyWith(RfaOfferSheet value, $Res Function(RfaOfferSheet) _then) = _$RfaOfferSheetCopyWithImpl;
@useResult
$Res call({
 String id, String playerId, String originalTeamId, String offeringTeamId, int salary, int years, NegotiationPhase phase, int seasonYear, int week, int day, int hour, int expirySeasonYear, int expiryWeek, int expiryDay, int expiryHour, bool matched, bool declined
});




}
/// @nodoc
class _$RfaOfferSheetCopyWithImpl<$Res>
    implements $RfaOfferSheetCopyWith<$Res> {
  _$RfaOfferSheetCopyWithImpl(this._self, this._then);

  final RfaOfferSheet _self;
  final $Res Function(RfaOfferSheet) _then;

/// Create a copy of RfaOfferSheet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? playerId = null,Object? originalTeamId = null,Object? offeringTeamId = null,Object? salary = null,Object? years = null,Object? phase = null,Object? seasonYear = null,Object? week = null,Object? day = null,Object? hour = null,Object? expirySeasonYear = null,Object? expiryWeek = null,Object? expiryDay = null,Object? expiryHour = null,Object? matched = null,Object? declined = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,originalTeamId: null == originalTeamId ? _self.originalTeamId : originalTeamId // ignore: cast_nullable_to_non_nullable
as String,offeringTeamId: null == offeringTeamId ? _self.offeringTeamId : offeringTeamId // ignore: cast_nullable_to_non_nullable
as String,salary: null == salary ? _self.salary : salary // ignore: cast_nullable_to_non_nullable
as int,years: null == years ? _self.years : years // ignore: cast_nullable_to_non_nullable
as int,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as NegotiationPhase,seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,week: null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as int,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,expirySeasonYear: null == expirySeasonYear ? _self.expirySeasonYear : expirySeasonYear // ignore: cast_nullable_to_non_nullable
as int,expiryWeek: null == expiryWeek ? _self.expiryWeek : expiryWeek // ignore: cast_nullable_to_non_nullable
as int,expiryDay: null == expiryDay ? _self.expiryDay : expiryDay // ignore: cast_nullable_to_non_nullable
as int,expiryHour: null == expiryHour ? _self.expiryHour : expiryHour // ignore: cast_nullable_to_non_nullable
as int,matched: null == matched ? _self.matched : matched // ignore: cast_nullable_to_non_nullable
as bool,declined: null == declined ? _self.declined : declined // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RfaOfferSheet].
extension RfaOfferSheetPatterns on RfaOfferSheet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RfaOfferSheet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RfaOfferSheet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RfaOfferSheet value)  $default,){
final _that = this;
switch (_that) {
case _RfaOfferSheet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RfaOfferSheet value)?  $default,){
final _that = this;
switch (_that) {
case _RfaOfferSheet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String playerId,  String originalTeamId,  String offeringTeamId,  int salary,  int years,  NegotiationPhase phase,  int seasonYear,  int week,  int day,  int hour,  int expirySeasonYear,  int expiryWeek,  int expiryDay,  int expiryHour,  bool matched,  bool declined)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RfaOfferSheet() when $default != null:
return $default(_that.id,_that.playerId,_that.originalTeamId,_that.offeringTeamId,_that.salary,_that.years,_that.phase,_that.seasonYear,_that.week,_that.day,_that.hour,_that.expirySeasonYear,_that.expiryWeek,_that.expiryDay,_that.expiryHour,_that.matched,_that.declined);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String playerId,  String originalTeamId,  String offeringTeamId,  int salary,  int years,  NegotiationPhase phase,  int seasonYear,  int week,  int day,  int hour,  int expirySeasonYear,  int expiryWeek,  int expiryDay,  int expiryHour,  bool matched,  bool declined)  $default,) {final _that = this;
switch (_that) {
case _RfaOfferSheet():
return $default(_that.id,_that.playerId,_that.originalTeamId,_that.offeringTeamId,_that.salary,_that.years,_that.phase,_that.seasonYear,_that.week,_that.day,_that.hour,_that.expirySeasonYear,_that.expiryWeek,_that.expiryDay,_that.expiryHour,_that.matched,_that.declined);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String playerId,  String originalTeamId,  String offeringTeamId,  int salary,  int years,  NegotiationPhase phase,  int seasonYear,  int week,  int day,  int hour,  int expirySeasonYear,  int expiryWeek,  int expiryDay,  int expiryHour,  bool matched,  bool declined)?  $default,) {final _that = this;
switch (_that) {
case _RfaOfferSheet() when $default != null:
return $default(_that.id,_that.playerId,_that.originalTeamId,_that.offeringTeamId,_that.salary,_that.years,_that.phase,_that.seasonYear,_that.week,_that.day,_that.hour,_that.expirySeasonYear,_that.expiryWeek,_that.expiryDay,_that.expiryHour,_that.matched,_that.declined);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RfaOfferSheet implements RfaOfferSheet {
  const _RfaOfferSheet({required this.id, required this.playerId, required this.originalTeamId, required this.offeringTeamId, required this.salary, required this.years, required this.phase, required this.seasonYear, required this.week, this.day = 1, this.hour = 1, required this.expirySeasonYear, required this.expiryWeek, this.expiryDay = 1, this.expiryHour = 0, this.matched = false, this.declined = false});
  factory _RfaOfferSheet.fromJson(Map<String, dynamic> json) => _$RfaOfferSheetFromJson(json);

@override final  String id;
@override final  String playerId;
@override final  String originalTeamId;
@override final  String offeringTeamId;
@override final  int salary;
@override final  int years;
@override final  NegotiationPhase phase;
@override final  int seasonYear;
@override final  int week;
@override@JsonKey() final  int day;
@override@JsonKey() final  int hour;
@override final  int expirySeasonYear;
@override final  int expiryWeek;
@override@JsonKey() final  int expiryDay;
@override@JsonKey() final  int expiryHour;
@override@JsonKey() final  bool matched;
@override@JsonKey() final  bool declined;

/// Create a copy of RfaOfferSheet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RfaOfferSheetCopyWith<_RfaOfferSheet> get copyWith => __$RfaOfferSheetCopyWithImpl<_RfaOfferSheet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RfaOfferSheetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RfaOfferSheet&&(identical(other.id, id) || other.id == id)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.originalTeamId, originalTeamId) || other.originalTeamId == originalTeamId)&&(identical(other.offeringTeamId, offeringTeamId) || other.offeringTeamId == offeringTeamId)&&(identical(other.salary, salary) || other.salary == salary)&&(identical(other.years, years) || other.years == years)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear)&&(identical(other.week, week) || other.week == week)&&(identical(other.day, day) || other.day == day)&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.expirySeasonYear, expirySeasonYear) || other.expirySeasonYear == expirySeasonYear)&&(identical(other.expiryWeek, expiryWeek) || other.expiryWeek == expiryWeek)&&(identical(other.expiryDay, expiryDay) || other.expiryDay == expiryDay)&&(identical(other.expiryHour, expiryHour) || other.expiryHour == expiryHour)&&(identical(other.matched, matched) || other.matched == matched)&&(identical(other.declined, declined) || other.declined == declined));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,playerId,originalTeamId,offeringTeamId,salary,years,phase,seasonYear,week,day,hour,expirySeasonYear,expiryWeek,expiryDay,expiryHour,matched,declined);

@override
String toString() {
  return 'RfaOfferSheet(id: $id, playerId: $playerId, originalTeamId: $originalTeamId, offeringTeamId: $offeringTeamId, salary: $salary, years: $years, phase: $phase, seasonYear: $seasonYear, week: $week, day: $day, hour: $hour, expirySeasonYear: $expirySeasonYear, expiryWeek: $expiryWeek, expiryDay: $expiryDay, expiryHour: $expiryHour, matched: $matched, declined: $declined)';
}


}

/// @nodoc
abstract mixin class _$RfaOfferSheetCopyWith<$Res> implements $RfaOfferSheetCopyWith<$Res> {
  factory _$RfaOfferSheetCopyWith(_RfaOfferSheet value, $Res Function(_RfaOfferSheet) _then) = __$RfaOfferSheetCopyWithImpl;
@override @useResult
$Res call({
 String id, String playerId, String originalTeamId, String offeringTeamId, int salary, int years, NegotiationPhase phase, int seasonYear, int week, int day, int hour, int expirySeasonYear, int expiryWeek, int expiryDay, int expiryHour, bool matched, bool declined
});




}
/// @nodoc
class __$RfaOfferSheetCopyWithImpl<$Res>
    implements _$RfaOfferSheetCopyWith<$Res> {
  __$RfaOfferSheetCopyWithImpl(this._self, this._then);

  final _RfaOfferSheet _self;
  final $Res Function(_RfaOfferSheet) _then;

/// Create a copy of RfaOfferSheet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? playerId = null,Object? originalTeamId = null,Object? offeringTeamId = null,Object? salary = null,Object? years = null,Object? phase = null,Object? seasonYear = null,Object? week = null,Object? day = null,Object? hour = null,Object? expirySeasonYear = null,Object? expiryWeek = null,Object? expiryDay = null,Object? expiryHour = null,Object? matched = null,Object? declined = null,}) {
  return _then(_RfaOfferSheet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,originalTeamId: null == originalTeamId ? _self.originalTeamId : originalTeamId // ignore: cast_nullable_to_non_nullable
as String,offeringTeamId: null == offeringTeamId ? _self.offeringTeamId : offeringTeamId // ignore: cast_nullable_to_non_nullable
as String,salary: null == salary ? _self.salary : salary // ignore: cast_nullable_to_non_nullable
as int,years: null == years ? _self.years : years // ignore: cast_nullable_to_non_nullable
as int,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as NegotiationPhase,seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,week: null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as int,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,expirySeasonYear: null == expirySeasonYear ? _self.expirySeasonYear : expirySeasonYear // ignore: cast_nullable_to_non_nullable
as int,expiryWeek: null == expiryWeek ? _self.expiryWeek : expiryWeek // ignore: cast_nullable_to_non_nullable
as int,expiryDay: null == expiryDay ? _self.expiryDay : expiryDay // ignore: cast_nullable_to_non_nullable
as int,expiryHour: null == expiryHour ? _self.expiryHour : expiryHour // ignore: cast_nullable_to_non_nullable
as int,matched: null == matched ? _self.matched : matched // ignore: cast_nullable_to_non_nullable
as bool,declined: null == declined ? _self.declined : declined // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
