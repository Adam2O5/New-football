// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trade_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TradeAssetSnapshot {

 String get type; String? get playerId; String? get draftedRightsId; String? get pickId; int? get pickYear; int? get pickRound; String? get originalTeamId;
/// Create a copy of TradeAssetSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TradeAssetSnapshotCopyWith<TradeAssetSnapshot> get copyWith => _$TradeAssetSnapshotCopyWithImpl<TradeAssetSnapshot>(this as TradeAssetSnapshot, _$identity);

  /// Serializes this TradeAssetSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TradeAssetSnapshot&&(identical(other.type, type) || other.type == type)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.draftedRightsId, draftedRightsId) || other.draftedRightsId == draftedRightsId)&&(identical(other.pickId, pickId) || other.pickId == pickId)&&(identical(other.pickYear, pickYear) || other.pickYear == pickYear)&&(identical(other.pickRound, pickRound) || other.pickRound == pickRound)&&(identical(other.originalTeamId, originalTeamId) || other.originalTeamId == originalTeamId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,playerId,draftedRightsId,pickId,pickYear,pickRound,originalTeamId);

@override
String toString() {
  return 'TradeAssetSnapshot(type: $type, playerId: $playerId, draftedRightsId: $draftedRightsId, pickId: $pickId, pickYear: $pickYear, pickRound: $pickRound, originalTeamId: $originalTeamId)';
}


}

/// @nodoc
abstract mixin class $TradeAssetSnapshotCopyWith<$Res>  {
  factory $TradeAssetSnapshotCopyWith(TradeAssetSnapshot value, $Res Function(TradeAssetSnapshot) _then) = _$TradeAssetSnapshotCopyWithImpl;
@useResult
$Res call({
 String type, String? playerId, String? draftedRightsId, String? pickId, int? pickYear, int? pickRound, String? originalTeamId
});




}
/// @nodoc
class _$TradeAssetSnapshotCopyWithImpl<$Res>
    implements $TradeAssetSnapshotCopyWith<$Res> {
  _$TradeAssetSnapshotCopyWithImpl(this._self, this._then);

  final TradeAssetSnapshot _self;
  final $Res Function(TradeAssetSnapshot) _then;

/// Create a copy of TradeAssetSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? playerId = freezed,Object? draftedRightsId = freezed,Object? pickId = freezed,Object? pickYear = freezed,Object? pickRound = freezed,Object? originalTeamId = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,playerId: freezed == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String?,draftedRightsId: freezed == draftedRightsId ? _self.draftedRightsId : draftedRightsId // ignore: cast_nullable_to_non_nullable
as String?,pickId: freezed == pickId ? _self.pickId : pickId // ignore: cast_nullable_to_non_nullable
as String?,pickYear: freezed == pickYear ? _self.pickYear : pickYear // ignore: cast_nullable_to_non_nullable
as int?,pickRound: freezed == pickRound ? _self.pickRound : pickRound // ignore: cast_nullable_to_non_nullable
as int?,originalTeamId: freezed == originalTeamId ? _self.originalTeamId : originalTeamId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TradeAssetSnapshot].
extension TradeAssetSnapshotPatterns on TradeAssetSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TradeAssetSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TradeAssetSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TradeAssetSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _TradeAssetSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TradeAssetSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _TradeAssetSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String? playerId,  String? draftedRightsId,  String? pickId,  int? pickYear,  int? pickRound,  String? originalTeamId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TradeAssetSnapshot() when $default != null:
return $default(_that.type,_that.playerId,_that.draftedRightsId,_that.pickId,_that.pickYear,_that.pickRound,_that.originalTeamId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String? playerId,  String? draftedRightsId,  String? pickId,  int? pickYear,  int? pickRound,  String? originalTeamId)  $default,) {final _that = this;
switch (_that) {
case _TradeAssetSnapshot():
return $default(_that.type,_that.playerId,_that.draftedRightsId,_that.pickId,_that.pickYear,_that.pickRound,_that.originalTeamId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String? playerId,  String? draftedRightsId,  String? pickId,  int? pickYear,  int? pickRound,  String? originalTeamId)?  $default,) {final _that = this;
switch (_that) {
case _TradeAssetSnapshot() when $default != null:
return $default(_that.type,_that.playerId,_that.draftedRightsId,_that.pickId,_that.pickYear,_that.pickRound,_that.originalTeamId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TradeAssetSnapshot implements TradeAssetSnapshot {
  const _TradeAssetSnapshot({required this.type, this.playerId, this.draftedRightsId, this.pickId, this.pickYear, this.pickRound, this.originalTeamId});
  factory _TradeAssetSnapshot.fromJson(Map<String, dynamic> json) => _$TradeAssetSnapshotFromJson(json);

@override final  String type;
@override final  String? playerId;
@override final  String? draftedRightsId;
@override final  String? pickId;
@override final  int? pickYear;
@override final  int? pickRound;
@override final  String? originalTeamId;

/// Create a copy of TradeAssetSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TradeAssetSnapshotCopyWith<_TradeAssetSnapshot> get copyWith => __$TradeAssetSnapshotCopyWithImpl<_TradeAssetSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TradeAssetSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TradeAssetSnapshot&&(identical(other.type, type) || other.type == type)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.draftedRightsId, draftedRightsId) || other.draftedRightsId == draftedRightsId)&&(identical(other.pickId, pickId) || other.pickId == pickId)&&(identical(other.pickYear, pickYear) || other.pickYear == pickYear)&&(identical(other.pickRound, pickRound) || other.pickRound == pickRound)&&(identical(other.originalTeamId, originalTeamId) || other.originalTeamId == originalTeamId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,playerId,draftedRightsId,pickId,pickYear,pickRound,originalTeamId);

@override
String toString() {
  return 'TradeAssetSnapshot(type: $type, playerId: $playerId, draftedRightsId: $draftedRightsId, pickId: $pickId, pickYear: $pickYear, pickRound: $pickRound, originalTeamId: $originalTeamId)';
}


}

/// @nodoc
abstract mixin class _$TradeAssetSnapshotCopyWith<$Res> implements $TradeAssetSnapshotCopyWith<$Res> {
  factory _$TradeAssetSnapshotCopyWith(_TradeAssetSnapshot value, $Res Function(_TradeAssetSnapshot) _then) = __$TradeAssetSnapshotCopyWithImpl;
@override @useResult
$Res call({
 String type, String? playerId, String? draftedRightsId, String? pickId, int? pickYear, int? pickRound, String? originalTeamId
});




}
/// @nodoc
class __$TradeAssetSnapshotCopyWithImpl<$Res>
    implements _$TradeAssetSnapshotCopyWith<$Res> {
  __$TradeAssetSnapshotCopyWithImpl(this._self, this._then);

  final _TradeAssetSnapshot _self;
  final $Res Function(_TradeAssetSnapshot) _then;

/// Create a copy of TradeAssetSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? playerId = freezed,Object? draftedRightsId = freezed,Object? pickId = freezed,Object? pickYear = freezed,Object? pickRound = freezed,Object? originalTeamId = freezed,}) {
  return _then(_TradeAssetSnapshot(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,playerId: freezed == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String?,draftedRightsId: freezed == draftedRightsId ? _self.draftedRightsId : draftedRightsId // ignore: cast_nullable_to_non_nullable
as String?,pickId: freezed == pickId ? _self.pickId : pickId // ignore: cast_nullable_to_non_nullable
as String?,pickYear: freezed == pickYear ? _self.pickYear : pickYear // ignore: cast_nullable_to_non_nullable
as int?,pickRound: freezed == pickRound ? _self.pickRound : pickRound // ignore: cast_nullable_to_non_nullable
as int?,originalTeamId: freezed == originalTeamId ? _self.originalTeamId : originalTeamId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TradeHistoryEntry {

 String get id; String get teamAId; String get teamBId; int get seasonYear; int get week; int get day; String get outcome; List<TradeAssetSnapshot> get assetsFromA; List<TradeAssetSnapshot> get assetsFromB; String? get reason; String? get ntcPlayerId; double? get ntcConsentProbability; String? get offerId; String? get threadId; int get round;
/// Create a copy of TradeHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TradeHistoryEntryCopyWith<TradeHistoryEntry> get copyWith => _$TradeHistoryEntryCopyWithImpl<TradeHistoryEntry>(this as TradeHistoryEntry, _$identity);

  /// Serializes this TradeHistoryEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TradeHistoryEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.teamAId, teamAId) || other.teamAId == teamAId)&&(identical(other.teamBId, teamBId) || other.teamBId == teamBId)&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear)&&(identical(other.week, week) || other.week == week)&&(identical(other.day, day) || other.day == day)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&const DeepCollectionEquality().equals(other.assetsFromA, assetsFromA)&&const DeepCollectionEquality().equals(other.assetsFromB, assetsFromB)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.ntcPlayerId, ntcPlayerId) || other.ntcPlayerId == ntcPlayerId)&&(identical(other.ntcConsentProbability, ntcConsentProbability) || other.ntcConsentProbability == ntcConsentProbability)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.round, round) || other.round == round));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,teamAId,teamBId,seasonYear,week,day,outcome,const DeepCollectionEquality().hash(assetsFromA),const DeepCollectionEquality().hash(assetsFromB),reason,ntcPlayerId,ntcConsentProbability,offerId,threadId,round);

@override
String toString() {
  return 'TradeHistoryEntry(id: $id, teamAId: $teamAId, teamBId: $teamBId, seasonYear: $seasonYear, week: $week, day: $day, outcome: $outcome, assetsFromA: $assetsFromA, assetsFromB: $assetsFromB, reason: $reason, ntcPlayerId: $ntcPlayerId, ntcConsentProbability: $ntcConsentProbability, offerId: $offerId, threadId: $threadId, round: $round)';
}


}

/// @nodoc
abstract mixin class $TradeHistoryEntryCopyWith<$Res>  {
  factory $TradeHistoryEntryCopyWith(TradeHistoryEntry value, $Res Function(TradeHistoryEntry) _then) = _$TradeHistoryEntryCopyWithImpl;
@useResult
$Res call({
 String id, String teamAId, String teamBId, int seasonYear, int week, int day, String outcome, List<TradeAssetSnapshot> assetsFromA, List<TradeAssetSnapshot> assetsFromB, String? reason, String? ntcPlayerId, double? ntcConsentProbability, String? offerId, String? threadId, int round
});




}
/// @nodoc
class _$TradeHistoryEntryCopyWithImpl<$Res>
    implements $TradeHistoryEntryCopyWith<$Res> {
  _$TradeHistoryEntryCopyWithImpl(this._self, this._then);

  final TradeHistoryEntry _self;
  final $Res Function(TradeHistoryEntry) _then;

/// Create a copy of TradeHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? teamAId = null,Object? teamBId = null,Object? seasonYear = null,Object? week = null,Object? day = null,Object? outcome = null,Object? assetsFromA = null,Object? assetsFromB = null,Object? reason = freezed,Object? ntcPlayerId = freezed,Object? ntcConsentProbability = freezed,Object? offerId = freezed,Object? threadId = freezed,Object? round = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,teamAId: null == teamAId ? _self.teamAId : teamAId // ignore: cast_nullable_to_non_nullable
as String,teamBId: null == teamBId ? _self.teamBId : teamBId // ignore: cast_nullable_to_non_nullable
as String,seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,week: null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as int,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as String,assetsFromA: null == assetsFromA ? _self.assetsFromA : assetsFromA // ignore: cast_nullable_to_non_nullable
as List<TradeAssetSnapshot>,assetsFromB: null == assetsFromB ? _self.assetsFromB : assetsFromB // ignore: cast_nullable_to_non_nullable
as List<TradeAssetSnapshot>,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,ntcPlayerId: freezed == ntcPlayerId ? _self.ntcPlayerId : ntcPlayerId // ignore: cast_nullable_to_non_nullable
as String?,ntcConsentProbability: freezed == ntcConsentProbability ? _self.ntcConsentProbability : ntcConsentProbability // ignore: cast_nullable_to_non_nullable
as double?,offerId: freezed == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String?,threadId: freezed == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String?,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TradeHistoryEntry].
extension TradeHistoryEntryPatterns on TradeHistoryEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TradeHistoryEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TradeHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TradeHistoryEntry value)  $default,){
final _that = this;
switch (_that) {
case _TradeHistoryEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TradeHistoryEntry value)?  $default,){
final _that = this;
switch (_that) {
case _TradeHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String teamAId,  String teamBId,  int seasonYear,  int week,  int day,  String outcome,  List<TradeAssetSnapshot> assetsFromA,  List<TradeAssetSnapshot> assetsFromB,  String? reason,  String? ntcPlayerId,  double? ntcConsentProbability,  String? offerId,  String? threadId,  int round)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TradeHistoryEntry() when $default != null:
return $default(_that.id,_that.teamAId,_that.teamBId,_that.seasonYear,_that.week,_that.day,_that.outcome,_that.assetsFromA,_that.assetsFromB,_that.reason,_that.ntcPlayerId,_that.ntcConsentProbability,_that.offerId,_that.threadId,_that.round);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String teamAId,  String teamBId,  int seasonYear,  int week,  int day,  String outcome,  List<TradeAssetSnapshot> assetsFromA,  List<TradeAssetSnapshot> assetsFromB,  String? reason,  String? ntcPlayerId,  double? ntcConsentProbability,  String? offerId,  String? threadId,  int round)  $default,) {final _that = this;
switch (_that) {
case _TradeHistoryEntry():
return $default(_that.id,_that.teamAId,_that.teamBId,_that.seasonYear,_that.week,_that.day,_that.outcome,_that.assetsFromA,_that.assetsFromB,_that.reason,_that.ntcPlayerId,_that.ntcConsentProbability,_that.offerId,_that.threadId,_that.round);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String teamAId,  String teamBId,  int seasonYear,  int week,  int day,  String outcome,  List<TradeAssetSnapshot> assetsFromA,  List<TradeAssetSnapshot> assetsFromB,  String? reason,  String? ntcPlayerId,  double? ntcConsentProbability,  String? offerId,  String? threadId,  int round)?  $default,) {final _that = this;
switch (_that) {
case _TradeHistoryEntry() when $default != null:
return $default(_that.id,_that.teamAId,_that.teamBId,_that.seasonYear,_that.week,_that.day,_that.outcome,_that.assetsFromA,_that.assetsFromB,_that.reason,_that.ntcPlayerId,_that.ntcConsentProbability,_that.offerId,_that.threadId,_that.round);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TradeHistoryEntry implements TradeHistoryEntry {
  const _TradeHistoryEntry({required this.id, required this.teamAId, required this.teamBId, required this.seasonYear, required this.week, this.day = 1, this.outcome = 'accepted', final  List<TradeAssetSnapshot> assetsFromA = const [], final  List<TradeAssetSnapshot> assetsFromB = const [], this.reason, this.ntcPlayerId, this.ntcConsentProbability, this.offerId, this.threadId, this.round = 1}): _assetsFromA = assetsFromA,_assetsFromB = assetsFromB;
  factory _TradeHistoryEntry.fromJson(Map<String, dynamic> json) => _$TradeHistoryEntryFromJson(json);

@override final  String id;
@override final  String teamAId;
@override final  String teamBId;
@override final  int seasonYear;
@override final  int week;
@override@JsonKey() final  int day;
@override@JsonKey() final  String outcome;
 final  List<TradeAssetSnapshot> _assetsFromA;
@override@JsonKey() List<TradeAssetSnapshot> get assetsFromA {
  if (_assetsFromA is EqualUnmodifiableListView) return _assetsFromA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assetsFromA);
}

 final  List<TradeAssetSnapshot> _assetsFromB;
@override@JsonKey() List<TradeAssetSnapshot> get assetsFromB {
  if (_assetsFromB is EqualUnmodifiableListView) return _assetsFromB;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assetsFromB);
}

@override final  String? reason;
@override final  String? ntcPlayerId;
@override final  double? ntcConsentProbability;
@override final  String? offerId;
@override final  String? threadId;
@override@JsonKey() final  int round;

/// Create a copy of TradeHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TradeHistoryEntryCopyWith<_TradeHistoryEntry> get copyWith => __$TradeHistoryEntryCopyWithImpl<_TradeHistoryEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TradeHistoryEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TradeHistoryEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.teamAId, teamAId) || other.teamAId == teamAId)&&(identical(other.teamBId, teamBId) || other.teamBId == teamBId)&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear)&&(identical(other.week, week) || other.week == week)&&(identical(other.day, day) || other.day == day)&&(identical(other.outcome, outcome) || other.outcome == outcome)&&const DeepCollectionEquality().equals(other._assetsFromA, _assetsFromA)&&const DeepCollectionEquality().equals(other._assetsFromB, _assetsFromB)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.ntcPlayerId, ntcPlayerId) || other.ntcPlayerId == ntcPlayerId)&&(identical(other.ntcConsentProbability, ntcConsentProbability) || other.ntcConsentProbability == ntcConsentProbability)&&(identical(other.offerId, offerId) || other.offerId == offerId)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.round, round) || other.round == round));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,teamAId,teamBId,seasonYear,week,day,outcome,const DeepCollectionEquality().hash(_assetsFromA),const DeepCollectionEquality().hash(_assetsFromB),reason,ntcPlayerId,ntcConsentProbability,offerId,threadId,round);

@override
String toString() {
  return 'TradeHistoryEntry(id: $id, teamAId: $teamAId, teamBId: $teamBId, seasonYear: $seasonYear, week: $week, day: $day, outcome: $outcome, assetsFromA: $assetsFromA, assetsFromB: $assetsFromB, reason: $reason, ntcPlayerId: $ntcPlayerId, ntcConsentProbability: $ntcConsentProbability, offerId: $offerId, threadId: $threadId, round: $round)';
}


}

/// @nodoc
abstract mixin class _$TradeHistoryEntryCopyWith<$Res> implements $TradeHistoryEntryCopyWith<$Res> {
  factory _$TradeHistoryEntryCopyWith(_TradeHistoryEntry value, $Res Function(_TradeHistoryEntry) _then) = __$TradeHistoryEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String teamAId, String teamBId, int seasonYear, int week, int day, String outcome, List<TradeAssetSnapshot> assetsFromA, List<TradeAssetSnapshot> assetsFromB, String? reason, String? ntcPlayerId, double? ntcConsentProbability, String? offerId, String? threadId, int round
});




}
/// @nodoc
class __$TradeHistoryEntryCopyWithImpl<$Res>
    implements _$TradeHistoryEntryCopyWith<$Res> {
  __$TradeHistoryEntryCopyWithImpl(this._self, this._then);

  final _TradeHistoryEntry _self;
  final $Res Function(_TradeHistoryEntry) _then;

/// Create a copy of TradeHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? teamAId = null,Object? teamBId = null,Object? seasonYear = null,Object? week = null,Object? day = null,Object? outcome = null,Object? assetsFromA = null,Object? assetsFromB = null,Object? reason = freezed,Object? ntcPlayerId = freezed,Object? ntcConsentProbability = freezed,Object? offerId = freezed,Object? threadId = freezed,Object? round = null,}) {
  return _then(_TradeHistoryEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,teamAId: null == teamAId ? _self.teamAId : teamAId // ignore: cast_nullable_to_non_nullable
as String,teamBId: null == teamBId ? _self.teamBId : teamBId // ignore: cast_nullable_to_non_nullable
as String,seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,week: null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as int,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,outcome: null == outcome ? _self.outcome : outcome // ignore: cast_nullable_to_non_nullable
as String,assetsFromA: null == assetsFromA ? _self._assetsFromA : assetsFromA // ignore: cast_nullable_to_non_nullable
as List<TradeAssetSnapshot>,assetsFromB: null == assetsFromB ? _self._assetsFromB : assetsFromB // ignore: cast_nullable_to_non_nullable
as List<TradeAssetSnapshot>,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,ntcPlayerId: freezed == ntcPlayerId ? _self.ntcPlayerId : ntcPlayerId // ignore: cast_nullable_to_non_nullable
as String?,ntcConsentProbability: freezed == ntcConsentProbability ? _self.ntcConsentProbability : ntcConsentProbability // ignore: cast_nullable_to_non_nullable
as double?,offerId: freezed == offerId ? _self.offerId : offerId // ignore: cast_nullable_to_non_nullable
as String?,threadId: freezed == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String?,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$NtcTradeBlock {

 String get playerId; String get destinationTeamId; DateTime get createdAt; DateTime get expiresAt;
/// Create a copy of NtcTradeBlock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NtcTradeBlockCopyWith<NtcTradeBlock> get copyWith => _$NtcTradeBlockCopyWithImpl<NtcTradeBlock>(this as NtcTradeBlock, _$identity);

  /// Serializes this NtcTradeBlock to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NtcTradeBlock&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.destinationTeamId, destinationTeamId) || other.destinationTeamId == destinationTeamId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerId,destinationTeamId,createdAt,expiresAt);

@override
String toString() {
  return 'NtcTradeBlock(playerId: $playerId, destinationTeamId: $destinationTeamId, createdAt: $createdAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $NtcTradeBlockCopyWith<$Res>  {
  factory $NtcTradeBlockCopyWith(NtcTradeBlock value, $Res Function(NtcTradeBlock) _then) = _$NtcTradeBlockCopyWithImpl;
@useResult
$Res call({
 String playerId, String destinationTeamId, DateTime createdAt, DateTime expiresAt
});




}
/// @nodoc
class _$NtcTradeBlockCopyWithImpl<$Res>
    implements $NtcTradeBlockCopyWith<$Res> {
  _$NtcTradeBlockCopyWithImpl(this._self, this._then);

  final NtcTradeBlock _self;
  final $Res Function(NtcTradeBlock) _then;

/// Create a copy of NtcTradeBlock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playerId = null,Object? destinationTeamId = null,Object? createdAt = null,Object? expiresAt = null,}) {
  return _then(_self.copyWith(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,destinationTeamId: null == destinationTeamId ? _self.destinationTeamId : destinationTeamId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [NtcTradeBlock].
extension NtcTradeBlockPatterns on NtcTradeBlock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NtcTradeBlock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NtcTradeBlock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NtcTradeBlock value)  $default,){
final _that = this;
switch (_that) {
case _NtcTradeBlock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NtcTradeBlock value)?  $default,){
final _that = this;
switch (_that) {
case _NtcTradeBlock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String playerId,  String destinationTeamId,  DateTime createdAt,  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NtcTradeBlock() when $default != null:
return $default(_that.playerId,_that.destinationTeamId,_that.createdAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String playerId,  String destinationTeamId,  DateTime createdAt,  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _NtcTradeBlock():
return $default(_that.playerId,_that.destinationTeamId,_that.createdAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String playerId,  String destinationTeamId,  DateTime createdAt,  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _NtcTradeBlock() when $default != null:
return $default(_that.playerId,_that.destinationTeamId,_that.createdAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NtcTradeBlock implements NtcTradeBlock {
  const _NtcTradeBlock({required this.playerId, required this.destinationTeamId, required this.createdAt, required this.expiresAt});
  factory _NtcTradeBlock.fromJson(Map<String, dynamic> json) => _$NtcTradeBlockFromJson(json);

@override final  String playerId;
@override final  String destinationTeamId;
@override final  DateTime createdAt;
@override final  DateTime expiresAt;

/// Create a copy of NtcTradeBlock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NtcTradeBlockCopyWith<_NtcTradeBlock> get copyWith => __$NtcTradeBlockCopyWithImpl<_NtcTradeBlock>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NtcTradeBlockToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NtcTradeBlock&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.destinationTeamId, destinationTeamId) || other.destinationTeamId == destinationTeamId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerId,destinationTeamId,createdAt,expiresAt);

@override
String toString() {
  return 'NtcTradeBlock(playerId: $playerId, destinationTeamId: $destinationTeamId, createdAt: $createdAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$NtcTradeBlockCopyWith<$Res> implements $NtcTradeBlockCopyWith<$Res> {
  factory _$NtcTradeBlockCopyWith(_NtcTradeBlock value, $Res Function(_NtcTradeBlock) _then) = __$NtcTradeBlockCopyWithImpl;
@override @useResult
$Res call({
 String playerId, String destinationTeamId, DateTime createdAt, DateTime expiresAt
});




}
/// @nodoc
class __$NtcTradeBlockCopyWithImpl<$Res>
    implements _$NtcTradeBlockCopyWith<$Res> {
  __$NtcTradeBlockCopyWithImpl(this._self, this._then);

  final _NtcTradeBlock _self;
  final $Res Function(_NtcTradeBlock) _then;

/// Create a copy of NtcTradeBlock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playerId = null,Object? destinationTeamId = null,Object? createdAt = null,Object? expiresAt = null,}) {
  return _then(_NtcTradeBlock(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,destinationTeamId: null == destinationTeamId ? _self.destinationTeamId : destinationTeamId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$TradeOffer {

 String get id; String get threadId; String? get parentOfferId; String get teamAId; String get teamBId; List<TradeAssetSnapshot> get assetsFromA; List<TradeAssetSnapshot> get assetsFromB; int get round; TradeOfferStatus get status; String get awaitingTeamId; int get seasonYear; int get week; int get day; int get hour; int get expirySeasonYear; int get expiryWeek; int get expiryDay; int get expiryHour; String? get supersededById; String? get reason;
/// Create a copy of TradeOffer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TradeOfferCopyWith<TradeOffer> get copyWith => _$TradeOfferCopyWithImpl<TradeOffer>(this as TradeOffer, _$identity);

  /// Serializes this TradeOffer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TradeOffer&&(identical(other.id, id) || other.id == id)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.parentOfferId, parentOfferId) || other.parentOfferId == parentOfferId)&&(identical(other.teamAId, teamAId) || other.teamAId == teamAId)&&(identical(other.teamBId, teamBId) || other.teamBId == teamBId)&&const DeepCollectionEquality().equals(other.assetsFromA, assetsFromA)&&const DeepCollectionEquality().equals(other.assetsFromB, assetsFromB)&&(identical(other.round, round) || other.round == round)&&(identical(other.status, status) || other.status == status)&&(identical(other.awaitingTeamId, awaitingTeamId) || other.awaitingTeamId == awaitingTeamId)&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear)&&(identical(other.week, week) || other.week == week)&&(identical(other.day, day) || other.day == day)&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.expirySeasonYear, expirySeasonYear) || other.expirySeasonYear == expirySeasonYear)&&(identical(other.expiryWeek, expiryWeek) || other.expiryWeek == expiryWeek)&&(identical(other.expiryDay, expiryDay) || other.expiryDay == expiryDay)&&(identical(other.expiryHour, expiryHour) || other.expiryHour == expiryHour)&&(identical(other.supersededById, supersededById) || other.supersededById == supersededById)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,threadId,parentOfferId,teamAId,teamBId,const DeepCollectionEquality().hash(assetsFromA),const DeepCollectionEquality().hash(assetsFromB),round,status,awaitingTeamId,seasonYear,week,day,hour,expirySeasonYear,expiryWeek,expiryDay,expiryHour,supersededById,reason]);

@override
String toString() {
  return 'TradeOffer(id: $id, threadId: $threadId, parentOfferId: $parentOfferId, teamAId: $teamAId, teamBId: $teamBId, assetsFromA: $assetsFromA, assetsFromB: $assetsFromB, round: $round, status: $status, awaitingTeamId: $awaitingTeamId, seasonYear: $seasonYear, week: $week, day: $day, hour: $hour, expirySeasonYear: $expirySeasonYear, expiryWeek: $expiryWeek, expiryDay: $expiryDay, expiryHour: $expiryHour, supersededById: $supersededById, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $TradeOfferCopyWith<$Res>  {
  factory $TradeOfferCopyWith(TradeOffer value, $Res Function(TradeOffer) _then) = _$TradeOfferCopyWithImpl;
@useResult
$Res call({
 String id, String threadId, String? parentOfferId, String teamAId, String teamBId, List<TradeAssetSnapshot> assetsFromA, List<TradeAssetSnapshot> assetsFromB, int round, TradeOfferStatus status, String awaitingTeamId, int seasonYear, int week, int day, int hour, int expirySeasonYear, int expiryWeek, int expiryDay, int expiryHour, String? supersededById, String? reason
});




}
/// @nodoc
class _$TradeOfferCopyWithImpl<$Res>
    implements $TradeOfferCopyWith<$Res> {
  _$TradeOfferCopyWithImpl(this._self, this._then);

  final TradeOffer _self;
  final $Res Function(TradeOffer) _then;

/// Create a copy of TradeOffer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? threadId = null,Object? parentOfferId = freezed,Object? teamAId = null,Object? teamBId = null,Object? assetsFromA = null,Object? assetsFromB = null,Object? round = null,Object? status = null,Object? awaitingTeamId = null,Object? seasonYear = null,Object? week = null,Object? day = null,Object? hour = null,Object? expirySeasonYear = null,Object? expiryWeek = null,Object? expiryDay = null,Object? expiryHour = null,Object? supersededById = freezed,Object? reason = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,parentOfferId: freezed == parentOfferId ? _self.parentOfferId : parentOfferId // ignore: cast_nullable_to_non_nullable
as String?,teamAId: null == teamAId ? _self.teamAId : teamAId // ignore: cast_nullable_to_non_nullable
as String,teamBId: null == teamBId ? _self.teamBId : teamBId // ignore: cast_nullable_to_non_nullable
as String,assetsFromA: null == assetsFromA ? _self.assetsFromA : assetsFromA // ignore: cast_nullable_to_non_nullable
as List<TradeAssetSnapshot>,assetsFromB: null == assetsFromB ? _self.assetsFromB : assetsFromB // ignore: cast_nullable_to_non_nullable
as List<TradeAssetSnapshot>,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TradeOfferStatus,awaitingTeamId: null == awaitingTeamId ? _self.awaitingTeamId : awaitingTeamId // ignore: cast_nullable_to_non_nullable
as String,seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,week: null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as int,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,expirySeasonYear: null == expirySeasonYear ? _self.expirySeasonYear : expirySeasonYear // ignore: cast_nullable_to_non_nullable
as int,expiryWeek: null == expiryWeek ? _self.expiryWeek : expiryWeek // ignore: cast_nullable_to_non_nullable
as int,expiryDay: null == expiryDay ? _self.expiryDay : expiryDay // ignore: cast_nullable_to_non_nullable
as int,expiryHour: null == expiryHour ? _self.expiryHour : expiryHour // ignore: cast_nullable_to_non_nullable
as int,supersededById: freezed == supersededById ? _self.supersededById : supersededById // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TradeOffer].
extension TradeOfferPatterns on TradeOffer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TradeOffer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TradeOffer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TradeOffer value)  $default,){
final _that = this;
switch (_that) {
case _TradeOffer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TradeOffer value)?  $default,){
final _that = this;
switch (_that) {
case _TradeOffer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String threadId,  String? parentOfferId,  String teamAId,  String teamBId,  List<TradeAssetSnapshot> assetsFromA,  List<TradeAssetSnapshot> assetsFromB,  int round,  TradeOfferStatus status,  String awaitingTeamId,  int seasonYear,  int week,  int day,  int hour,  int expirySeasonYear,  int expiryWeek,  int expiryDay,  int expiryHour,  String? supersededById,  String? reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TradeOffer() when $default != null:
return $default(_that.id,_that.threadId,_that.parentOfferId,_that.teamAId,_that.teamBId,_that.assetsFromA,_that.assetsFromB,_that.round,_that.status,_that.awaitingTeamId,_that.seasonYear,_that.week,_that.day,_that.hour,_that.expirySeasonYear,_that.expiryWeek,_that.expiryDay,_that.expiryHour,_that.supersededById,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String threadId,  String? parentOfferId,  String teamAId,  String teamBId,  List<TradeAssetSnapshot> assetsFromA,  List<TradeAssetSnapshot> assetsFromB,  int round,  TradeOfferStatus status,  String awaitingTeamId,  int seasonYear,  int week,  int day,  int hour,  int expirySeasonYear,  int expiryWeek,  int expiryDay,  int expiryHour,  String? supersededById,  String? reason)  $default,) {final _that = this;
switch (_that) {
case _TradeOffer():
return $default(_that.id,_that.threadId,_that.parentOfferId,_that.teamAId,_that.teamBId,_that.assetsFromA,_that.assetsFromB,_that.round,_that.status,_that.awaitingTeamId,_that.seasonYear,_that.week,_that.day,_that.hour,_that.expirySeasonYear,_that.expiryWeek,_that.expiryDay,_that.expiryHour,_that.supersededById,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String threadId,  String? parentOfferId,  String teamAId,  String teamBId,  List<TradeAssetSnapshot> assetsFromA,  List<TradeAssetSnapshot> assetsFromB,  int round,  TradeOfferStatus status,  String awaitingTeamId,  int seasonYear,  int week,  int day,  int hour,  int expirySeasonYear,  int expiryWeek,  int expiryDay,  int expiryHour,  String? supersededById,  String? reason)?  $default,) {final _that = this;
switch (_that) {
case _TradeOffer() when $default != null:
return $default(_that.id,_that.threadId,_that.parentOfferId,_that.teamAId,_that.teamBId,_that.assetsFromA,_that.assetsFromB,_that.round,_that.status,_that.awaitingTeamId,_that.seasonYear,_that.week,_that.day,_that.hour,_that.expirySeasonYear,_that.expiryWeek,_that.expiryDay,_that.expiryHour,_that.supersededById,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TradeOffer implements TradeOffer {
  const _TradeOffer({required this.id, required this.threadId, this.parentOfferId, required this.teamAId, required this.teamBId, final  List<TradeAssetSnapshot> assetsFromA = const [], final  List<TradeAssetSnapshot> assetsFromB = const [], this.round = 1, this.status = TradeOfferStatus.pending, required this.awaitingTeamId, required this.seasonYear, required this.week, this.day = 1, this.hour = 0, required this.expirySeasonYear, required this.expiryWeek, this.expiryDay = 1, this.expiryHour = 0, this.supersededById, this.reason}): _assetsFromA = assetsFromA,_assetsFromB = assetsFromB;
  factory _TradeOffer.fromJson(Map<String, dynamic> json) => _$TradeOfferFromJson(json);

@override final  String id;
@override final  String threadId;
@override final  String? parentOfferId;
@override final  String teamAId;
@override final  String teamBId;
 final  List<TradeAssetSnapshot> _assetsFromA;
@override@JsonKey() List<TradeAssetSnapshot> get assetsFromA {
  if (_assetsFromA is EqualUnmodifiableListView) return _assetsFromA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assetsFromA);
}

 final  List<TradeAssetSnapshot> _assetsFromB;
@override@JsonKey() List<TradeAssetSnapshot> get assetsFromB {
  if (_assetsFromB is EqualUnmodifiableListView) return _assetsFromB;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assetsFromB);
}

@override@JsonKey() final  int round;
@override@JsonKey() final  TradeOfferStatus status;
@override final  String awaitingTeamId;
@override final  int seasonYear;
@override final  int week;
@override@JsonKey() final  int day;
@override@JsonKey() final  int hour;
@override final  int expirySeasonYear;
@override final  int expiryWeek;
@override@JsonKey() final  int expiryDay;
@override@JsonKey() final  int expiryHour;
@override final  String? supersededById;
@override final  String? reason;

/// Create a copy of TradeOffer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TradeOfferCopyWith<_TradeOffer> get copyWith => __$TradeOfferCopyWithImpl<_TradeOffer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TradeOfferToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TradeOffer&&(identical(other.id, id) || other.id == id)&&(identical(other.threadId, threadId) || other.threadId == threadId)&&(identical(other.parentOfferId, parentOfferId) || other.parentOfferId == parentOfferId)&&(identical(other.teamAId, teamAId) || other.teamAId == teamAId)&&(identical(other.teamBId, teamBId) || other.teamBId == teamBId)&&const DeepCollectionEquality().equals(other._assetsFromA, _assetsFromA)&&const DeepCollectionEquality().equals(other._assetsFromB, _assetsFromB)&&(identical(other.round, round) || other.round == round)&&(identical(other.status, status) || other.status == status)&&(identical(other.awaitingTeamId, awaitingTeamId) || other.awaitingTeamId == awaitingTeamId)&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear)&&(identical(other.week, week) || other.week == week)&&(identical(other.day, day) || other.day == day)&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.expirySeasonYear, expirySeasonYear) || other.expirySeasonYear == expirySeasonYear)&&(identical(other.expiryWeek, expiryWeek) || other.expiryWeek == expiryWeek)&&(identical(other.expiryDay, expiryDay) || other.expiryDay == expiryDay)&&(identical(other.expiryHour, expiryHour) || other.expiryHour == expiryHour)&&(identical(other.supersededById, supersededById) || other.supersededById == supersededById)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,threadId,parentOfferId,teamAId,teamBId,const DeepCollectionEquality().hash(_assetsFromA),const DeepCollectionEquality().hash(_assetsFromB),round,status,awaitingTeamId,seasonYear,week,day,hour,expirySeasonYear,expiryWeek,expiryDay,expiryHour,supersededById,reason]);

@override
String toString() {
  return 'TradeOffer(id: $id, threadId: $threadId, parentOfferId: $parentOfferId, teamAId: $teamAId, teamBId: $teamBId, assetsFromA: $assetsFromA, assetsFromB: $assetsFromB, round: $round, status: $status, awaitingTeamId: $awaitingTeamId, seasonYear: $seasonYear, week: $week, day: $day, hour: $hour, expirySeasonYear: $expirySeasonYear, expiryWeek: $expiryWeek, expiryDay: $expiryDay, expiryHour: $expiryHour, supersededById: $supersededById, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$TradeOfferCopyWith<$Res> implements $TradeOfferCopyWith<$Res> {
  factory _$TradeOfferCopyWith(_TradeOffer value, $Res Function(_TradeOffer) _then) = __$TradeOfferCopyWithImpl;
@override @useResult
$Res call({
 String id, String threadId, String? parentOfferId, String teamAId, String teamBId, List<TradeAssetSnapshot> assetsFromA, List<TradeAssetSnapshot> assetsFromB, int round, TradeOfferStatus status, String awaitingTeamId, int seasonYear, int week, int day, int hour, int expirySeasonYear, int expiryWeek, int expiryDay, int expiryHour, String? supersededById, String? reason
});




}
/// @nodoc
class __$TradeOfferCopyWithImpl<$Res>
    implements _$TradeOfferCopyWith<$Res> {
  __$TradeOfferCopyWithImpl(this._self, this._then);

  final _TradeOffer _self;
  final $Res Function(_TradeOffer) _then;

/// Create a copy of TradeOffer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? threadId = null,Object? parentOfferId = freezed,Object? teamAId = null,Object? teamBId = null,Object? assetsFromA = null,Object? assetsFromB = null,Object? round = null,Object? status = null,Object? awaitingTeamId = null,Object? seasonYear = null,Object? week = null,Object? day = null,Object? hour = null,Object? expirySeasonYear = null,Object? expiryWeek = null,Object? expiryDay = null,Object? expiryHour = null,Object? supersededById = freezed,Object? reason = freezed,}) {
  return _then(_TradeOffer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,threadId: null == threadId ? _self.threadId : threadId // ignore: cast_nullable_to_non_nullable
as String,parentOfferId: freezed == parentOfferId ? _self.parentOfferId : parentOfferId // ignore: cast_nullable_to_non_nullable
as String?,teamAId: null == teamAId ? _self.teamAId : teamAId // ignore: cast_nullable_to_non_nullable
as String,teamBId: null == teamBId ? _self.teamBId : teamBId // ignore: cast_nullable_to_non_nullable
as String,assetsFromA: null == assetsFromA ? _self._assetsFromA : assetsFromA // ignore: cast_nullable_to_non_nullable
as List<TradeAssetSnapshot>,assetsFromB: null == assetsFromB ? _self._assetsFromB : assetsFromB // ignore: cast_nullable_to_non_nullable
as List<TradeAssetSnapshot>,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TradeOfferStatus,awaitingTeamId: null == awaitingTeamId ? _self.awaitingTeamId : awaitingTeamId // ignore: cast_nullable_to_non_nullable
as String,seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,week: null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as int,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,expirySeasonYear: null == expirySeasonYear ? _self.expirySeasonYear : expirySeasonYear // ignore: cast_nullable_to_non_nullable
as int,expiryWeek: null == expiryWeek ? _self.expiryWeek : expiryWeek // ignore: cast_nullable_to_non_nullable
as int,expiryDay: null == expiryDay ? _self.expiryDay : expiryDay // ignore: cast_nullable_to_non_nullable
as int,expiryHour: null == expiryHour ? _self.expiryHour : expiryHour // ignore: cast_nullable_to_non_nullable
as int,supersededById: freezed == supersededById ? _self.supersededById : supersededById // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
