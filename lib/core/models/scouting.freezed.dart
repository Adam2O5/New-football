// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scouting.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScoutingKnowledge {

 String get prospectId; ScoutingTier get tier; EstimatedDraftSlot? get estimatedSlot; int get mockRank; int? get estimatedOvrMin; int? get estimatedOvrMax; double? get estimatedPotentialMin; double? get estimatedPotentialMax; int? get injuryProneMin; int? get injuryProneMax; int? get determinationMin; int? get determinationMax; bool get injuryProneKnown; bool get determinationKnown;
/// Create a copy of ScoutingKnowledge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScoutingKnowledgeCopyWith<ScoutingKnowledge> get copyWith => _$ScoutingKnowledgeCopyWithImpl<ScoutingKnowledge>(this as ScoutingKnowledge, _$identity);

  /// Serializes this ScoutingKnowledge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScoutingKnowledge&&(identical(other.prospectId, prospectId) || other.prospectId == prospectId)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.estimatedSlot, estimatedSlot) || other.estimatedSlot == estimatedSlot)&&(identical(other.mockRank, mockRank) || other.mockRank == mockRank)&&(identical(other.estimatedOvrMin, estimatedOvrMin) || other.estimatedOvrMin == estimatedOvrMin)&&(identical(other.estimatedOvrMax, estimatedOvrMax) || other.estimatedOvrMax == estimatedOvrMax)&&(identical(other.estimatedPotentialMin, estimatedPotentialMin) || other.estimatedPotentialMin == estimatedPotentialMin)&&(identical(other.estimatedPotentialMax, estimatedPotentialMax) || other.estimatedPotentialMax == estimatedPotentialMax)&&(identical(other.injuryProneMin, injuryProneMin) || other.injuryProneMin == injuryProneMin)&&(identical(other.injuryProneMax, injuryProneMax) || other.injuryProneMax == injuryProneMax)&&(identical(other.determinationMin, determinationMin) || other.determinationMin == determinationMin)&&(identical(other.determinationMax, determinationMax) || other.determinationMax == determinationMax)&&(identical(other.injuryProneKnown, injuryProneKnown) || other.injuryProneKnown == injuryProneKnown)&&(identical(other.determinationKnown, determinationKnown) || other.determinationKnown == determinationKnown));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,prospectId,tier,estimatedSlot,mockRank,estimatedOvrMin,estimatedOvrMax,estimatedPotentialMin,estimatedPotentialMax,injuryProneMin,injuryProneMax,determinationMin,determinationMax,injuryProneKnown,determinationKnown);

@override
String toString() {
  return 'ScoutingKnowledge(prospectId: $prospectId, tier: $tier, estimatedSlot: $estimatedSlot, mockRank: $mockRank, estimatedOvrMin: $estimatedOvrMin, estimatedOvrMax: $estimatedOvrMax, estimatedPotentialMin: $estimatedPotentialMin, estimatedPotentialMax: $estimatedPotentialMax, injuryProneMin: $injuryProneMin, injuryProneMax: $injuryProneMax, determinationMin: $determinationMin, determinationMax: $determinationMax, injuryProneKnown: $injuryProneKnown, determinationKnown: $determinationKnown)';
}


}

/// @nodoc
abstract mixin class $ScoutingKnowledgeCopyWith<$Res>  {
  factory $ScoutingKnowledgeCopyWith(ScoutingKnowledge value, $Res Function(ScoutingKnowledge) _then) = _$ScoutingKnowledgeCopyWithImpl;
@useResult
$Res call({
 String prospectId, ScoutingTier tier, EstimatedDraftSlot? estimatedSlot, int mockRank, int? estimatedOvrMin, int? estimatedOvrMax, double? estimatedPotentialMin, double? estimatedPotentialMax, int? injuryProneMin, int? injuryProneMax, int? determinationMin, int? determinationMax, bool injuryProneKnown, bool determinationKnown
});




}
/// @nodoc
class _$ScoutingKnowledgeCopyWithImpl<$Res>
    implements $ScoutingKnowledgeCopyWith<$Res> {
  _$ScoutingKnowledgeCopyWithImpl(this._self, this._then);

  final ScoutingKnowledge _self;
  final $Res Function(ScoutingKnowledge) _then;

/// Create a copy of ScoutingKnowledge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? prospectId = null,Object? tier = null,Object? estimatedSlot = freezed,Object? mockRank = null,Object? estimatedOvrMin = freezed,Object? estimatedOvrMax = freezed,Object? estimatedPotentialMin = freezed,Object? estimatedPotentialMax = freezed,Object? injuryProneMin = freezed,Object? injuryProneMax = freezed,Object? determinationMin = freezed,Object? determinationMax = freezed,Object? injuryProneKnown = null,Object? determinationKnown = null,}) {
  return _then(_self.copyWith(
prospectId: null == prospectId ? _self.prospectId : prospectId // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as ScoutingTier,estimatedSlot: freezed == estimatedSlot ? _self.estimatedSlot : estimatedSlot // ignore: cast_nullable_to_non_nullable
as EstimatedDraftSlot?,mockRank: null == mockRank ? _self.mockRank : mockRank // ignore: cast_nullable_to_non_nullable
as int,estimatedOvrMin: freezed == estimatedOvrMin ? _self.estimatedOvrMin : estimatedOvrMin // ignore: cast_nullable_to_non_nullable
as int?,estimatedOvrMax: freezed == estimatedOvrMax ? _self.estimatedOvrMax : estimatedOvrMax // ignore: cast_nullable_to_non_nullable
as int?,estimatedPotentialMin: freezed == estimatedPotentialMin ? _self.estimatedPotentialMin : estimatedPotentialMin // ignore: cast_nullable_to_non_nullable
as double?,estimatedPotentialMax: freezed == estimatedPotentialMax ? _self.estimatedPotentialMax : estimatedPotentialMax // ignore: cast_nullable_to_non_nullable
as double?,injuryProneMin: freezed == injuryProneMin ? _self.injuryProneMin : injuryProneMin // ignore: cast_nullable_to_non_nullable
as int?,injuryProneMax: freezed == injuryProneMax ? _self.injuryProneMax : injuryProneMax // ignore: cast_nullable_to_non_nullable
as int?,determinationMin: freezed == determinationMin ? _self.determinationMin : determinationMin // ignore: cast_nullable_to_non_nullable
as int?,determinationMax: freezed == determinationMax ? _self.determinationMax : determinationMax // ignore: cast_nullable_to_non_nullable
as int?,injuryProneKnown: null == injuryProneKnown ? _self.injuryProneKnown : injuryProneKnown // ignore: cast_nullable_to_non_nullable
as bool,determinationKnown: null == determinationKnown ? _self.determinationKnown : determinationKnown // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ScoutingKnowledge].
extension ScoutingKnowledgePatterns on ScoutingKnowledge {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScoutingKnowledge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScoutingKnowledge() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScoutingKnowledge value)  $default,){
final _that = this;
switch (_that) {
case _ScoutingKnowledge():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScoutingKnowledge value)?  $default,){
final _that = this;
switch (_that) {
case _ScoutingKnowledge() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String prospectId,  ScoutingTier tier,  EstimatedDraftSlot? estimatedSlot,  int mockRank,  int? estimatedOvrMin,  int? estimatedOvrMax,  double? estimatedPotentialMin,  double? estimatedPotentialMax,  int? injuryProneMin,  int? injuryProneMax,  int? determinationMin,  int? determinationMax,  bool injuryProneKnown,  bool determinationKnown)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScoutingKnowledge() when $default != null:
return $default(_that.prospectId,_that.tier,_that.estimatedSlot,_that.mockRank,_that.estimatedOvrMin,_that.estimatedOvrMax,_that.estimatedPotentialMin,_that.estimatedPotentialMax,_that.injuryProneMin,_that.injuryProneMax,_that.determinationMin,_that.determinationMax,_that.injuryProneKnown,_that.determinationKnown);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String prospectId,  ScoutingTier tier,  EstimatedDraftSlot? estimatedSlot,  int mockRank,  int? estimatedOvrMin,  int? estimatedOvrMax,  double? estimatedPotentialMin,  double? estimatedPotentialMax,  int? injuryProneMin,  int? injuryProneMax,  int? determinationMin,  int? determinationMax,  bool injuryProneKnown,  bool determinationKnown)  $default,) {final _that = this;
switch (_that) {
case _ScoutingKnowledge():
return $default(_that.prospectId,_that.tier,_that.estimatedSlot,_that.mockRank,_that.estimatedOvrMin,_that.estimatedOvrMax,_that.estimatedPotentialMin,_that.estimatedPotentialMax,_that.injuryProneMin,_that.injuryProneMax,_that.determinationMin,_that.determinationMax,_that.injuryProneKnown,_that.determinationKnown);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String prospectId,  ScoutingTier tier,  EstimatedDraftSlot? estimatedSlot,  int mockRank,  int? estimatedOvrMin,  int? estimatedOvrMax,  double? estimatedPotentialMin,  double? estimatedPotentialMax,  int? injuryProneMin,  int? injuryProneMax,  int? determinationMin,  int? determinationMax,  bool injuryProneKnown,  bool determinationKnown)?  $default,) {final _that = this;
switch (_that) {
case _ScoutingKnowledge() when $default != null:
return $default(_that.prospectId,_that.tier,_that.estimatedSlot,_that.mockRank,_that.estimatedOvrMin,_that.estimatedOvrMax,_that.estimatedPotentialMin,_that.estimatedPotentialMax,_that.injuryProneMin,_that.injuryProneMax,_that.determinationMin,_that.determinationMax,_that.injuryProneKnown,_that.determinationKnown);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScoutingKnowledge implements ScoutingKnowledge {
  const _ScoutingKnowledge({required this.prospectId, this.tier = ScoutingTier.tier1, this.estimatedSlot, this.mockRank = 0, this.estimatedOvrMin, this.estimatedOvrMax, this.estimatedPotentialMin, this.estimatedPotentialMax, this.injuryProneMin, this.injuryProneMax, this.determinationMin, this.determinationMax, this.injuryProneKnown = false, this.determinationKnown = false});
  factory _ScoutingKnowledge.fromJson(Map<String, dynamic> json) => _$ScoutingKnowledgeFromJson(json);

@override final  String prospectId;
@override@JsonKey() final  ScoutingTier tier;
@override final  EstimatedDraftSlot? estimatedSlot;
@override@JsonKey() final  int mockRank;
@override final  int? estimatedOvrMin;
@override final  int? estimatedOvrMax;
@override final  double? estimatedPotentialMin;
@override final  double? estimatedPotentialMax;
@override final  int? injuryProneMin;
@override final  int? injuryProneMax;
@override final  int? determinationMin;
@override final  int? determinationMax;
@override@JsonKey() final  bool injuryProneKnown;
@override@JsonKey() final  bool determinationKnown;

/// Create a copy of ScoutingKnowledge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScoutingKnowledgeCopyWith<_ScoutingKnowledge> get copyWith => __$ScoutingKnowledgeCopyWithImpl<_ScoutingKnowledge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScoutingKnowledgeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScoutingKnowledge&&(identical(other.prospectId, prospectId) || other.prospectId == prospectId)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.estimatedSlot, estimatedSlot) || other.estimatedSlot == estimatedSlot)&&(identical(other.mockRank, mockRank) || other.mockRank == mockRank)&&(identical(other.estimatedOvrMin, estimatedOvrMin) || other.estimatedOvrMin == estimatedOvrMin)&&(identical(other.estimatedOvrMax, estimatedOvrMax) || other.estimatedOvrMax == estimatedOvrMax)&&(identical(other.estimatedPotentialMin, estimatedPotentialMin) || other.estimatedPotentialMin == estimatedPotentialMin)&&(identical(other.estimatedPotentialMax, estimatedPotentialMax) || other.estimatedPotentialMax == estimatedPotentialMax)&&(identical(other.injuryProneMin, injuryProneMin) || other.injuryProneMin == injuryProneMin)&&(identical(other.injuryProneMax, injuryProneMax) || other.injuryProneMax == injuryProneMax)&&(identical(other.determinationMin, determinationMin) || other.determinationMin == determinationMin)&&(identical(other.determinationMax, determinationMax) || other.determinationMax == determinationMax)&&(identical(other.injuryProneKnown, injuryProneKnown) || other.injuryProneKnown == injuryProneKnown)&&(identical(other.determinationKnown, determinationKnown) || other.determinationKnown == determinationKnown));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,prospectId,tier,estimatedSlot,mockRank,estimatedOvrMin,estimatedOvrMax,estimatedPotentialMin,estimatedPotentialMax,injuryProneMin,injuryProneMax,determinationMin,determinationMax,injuryProneKnown,determinationKnown);

@override
String toString() {
  return 'ScoutingKnowledge(prospectId: $prospectId, tier: $tier, estimatedSlot: $estimatedSlot, mockRank: $mockRank, estimatedOvrMin: $estimatedOvrMin, estimatedOvrMax: $estimatedOvrMax, estimatedPotentialMin: $estimatedPotentialMin, estimatedPotentialMax: $estimatedPotentialMax, injuryProneMin: $injuryProneMin, injuryProneMax: $injuryProneMax, determinationMin: $determinationMin, determinationMax: $determinationMax, injuryProneKnown: $injuryProneKnown, determinationKnown: $determinationKnown)';
}


}

/// @nodoc
abstract mixin class _$ScoutingKnowledgeCopyWith<$Res> implements $ScoutingKnowledgeCopyWith<$Res> {
  factory _$ScoutingKnowledgeCopyWith(_ScoutingKnowledge value, $Res Function(_ScoutingKnowledge) _then) = __$ScoutingKnowledgeCopyWithImpl;
@override @useResult
$Res call({
 String prospectId, ScoutingTier tier, EstimatedDraftSlot? estimatedSlot, int mockRank, int? estimatedOvrMin, int? estimatedOvrMax, double? estimatedPotentialMin, double? estimatedPotentialMax, int? injuryProneMin, int? injuryProneMax, int? determinationMin, int? determinationMax, bool injuryProneKnown, bool determinationKnown
});




}
/// @nodoc
class __$ScoutingKnowledgeCopyWithImpl<$Res>
    implements _$ScoutingKnowledgeCopyWith<$Res> {
  __$ScoutingKnowledgeCopyWithImpl(this._self, this._then);

  final _ScoutingKnowledge _self;
  final $Res Function(_ScoutingKnowledge) _then;

/// Create a copy of ScoutingKnowledge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? prospectId = null,Object? tier = null,Object? estimatedSlot = freezed,Object? mockRank = null,Object? estimatedOvrMin = freezed,Object? estimatedOvrMax = freezed,Object? estimatedPotentialMin = freezed,Object? estimatedPotentialMax = freezed,Object? injuryProneMin = freezed,Object? injuryProneMax = freezed,Object? determinationMin = freezed,Object? determinationMax = freezed,Object? injuryProneKnown = null,Object? determinationKnown = null,}) {
  return _then(_ScoutingKnowledge(
prospectId: null == prospectId ? _self.prospectId : prospectId // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as ScoutingTier,estimatedSlot: freezed == estimatedSlot ? _self.estimatedSlot : estimatedSlot // ignore: cast_nullable_to_non_nullable
as EstimatedDraftSlot?,mockRank: null == mockRank ? _self.mockRank : mockRank // ignore: cast_nullable_to_non_nullable
as int,estimatedOvrMin: freezed == estimatedOvrMin ? _self.estimatedOvrMin : estimatedOvrMin // ignore: cast_nullable_to_non_nullable
as int?,estimatedOvrMax: freezed == estimatedOvrMax ? _self.estimatedOvrMax : estimatedOvrMax // ignore: cast_nullable_to_non_nullable
as int?,estimatedPotentialMin: freezed == estimatedPotentialMin ? _self.estimatedPotentialMin : estimatedPotentialMin // ignore: cast_nullable_to_non_nullable
as double?,estimatedPotentialMax: freezed == estimatedPotentialMax ? _self.estimatedPotentialMax : estimatedPotentialMax // ignore: cast_nullable_to_non_nullable
as double?,injuryProneMin: freezed == injuryProneMin ? _self.injuryProneMin : injuryProneMin // ignore: cast_nullable_to_non_nullable
as int?,injuryProneMax: freezed == injuryProneMax ? _self.injuryProneMax : injuryProneMax // ignore: cast_nullable_to_non_nullable
as int?,determinationMin: freezed == determinationMin ? _self.determinationMin : determinationMin // ignore: cast_nullable_to_non_nullable
as int?,determinationMax: freezed == determinationMax ? _self.determinationMax : determinationMax // ignore: cast_nullable_to_non_nullable
as int?,injuryProneKnown: null == injuryProneKnown ? _self.injuryProneKnown : injuryProneKnown // ignore: cast_nullable_to_non_nullable
as bool,determinationKnown: null == determinationKnown ? _self.determinationKnown : determinationKnown // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$TeamScouting {

 List<String> get watchlistProspectIds; List<ScoutingKnowledge> get knowledge; List<String> get combineAssignedProspectIds; Map<String, int> get mockRanks;
/// Create a copy of TeamScouting
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamScoutingCopyWith<TeamScouting> get copyWith => _$TeamScoutingCopyWithImpl<TeamScouting>(this as TeamScouting, _$identity);

  /// Serializes this TeamScouting to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamScouting&&const DeepCollectionEquality().equals(other.watchlistProspectIds, watchlistProspectIds)&&const DeepCollectionEquality().equals(other.knowledge, knowledge)&&const DeepCollectionEquality().equals(other.combineAssignedProspectIds, combineAssignedProspectIds)&&const DeepCollectionEquality().equals(other.mockRanks, mockRanks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(watchlistProspectIds),const DeepCollectionEquality().hash(knowledge),const DeepCollectionEquality().hash(combineAssignedProspectIds),const DeepCollectionEquality().hash(mockRanks));

@override
String toString() {
  return 'TeamScouting(watchlistProspectIds: $watchlistProspectIds, knowledge: $knowledge, combineAssignedProspectIds: $combineAssignedProspectIds, mockRanks: $mockRanks)';
}


}

/// @nodoc
abstract mixin class $TeamScoutingCopyWith<$Res>  {
  factory $TeamScoutingCopyWith(TeamScouting value, $Res Function(TeamScouting) _then) = _$TeamScoutingCopyWithImpl;
@useResult
$Res call({
 List<String> watchlistProspectIds, List<ScoutingKnowledge> knowledge, List<String> combineAssignedProspectIds, Map<String, int> mockRanks
});




}
/// @nodoc
class _$TeamScoutingCopyWithImpl<$Res>
    implements $TeamScoutingCopyWith<$Res> {
  _$TeamScoutingCopyWithImpl(this._self, this._then);

  final TeamScouting _self;
  final $Res Function(TeamScouting) _then;

/// Create a copy of TeamScouting
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? watchlistProspectIds = null,Object? knowledge = null,Object? combineAssignedProspectIds = null,Object? mockRanks = null,}) {
  return _then(_self.copyWith(
watchlistProspectIds: null == watchlistProspectIds ? _self.watchlistProspectIds : watchlistProspectIds // ignore: cast_nullable_to_non_nullable
as List<String>,knowledge: null == knowledge ? _self.knowledge : knowledge // ignore: cast_nullable_to_non_nullable
as List<ScoutingKnowledge>,combineAssignedProspectIds: null == combineAssignedProspectIds ? _self.combineAssignedProspectIds : combineAssignedProspectIds // ignore: cast_nullable_to_non_nullable
as List<String>,mockRanks: null == mockRanks ? _self.mockRanks : mockRanks // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamScouting].
extension TeamScoutingPatterns on TeamScouting {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamScouting value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamScouting() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamScouting value)  $default,){
final _that = this;
switch (_that) {
case _TeamScouting():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamScouting value)?  $default,){
final _that = this;
switch (_that) {
case _TeamScouting() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> watchlistProspectIds,  List<ScoutingKnowledge> knowledge,  List<String> combineAssignedProspectIds,  Map<String, int> mockRanks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamScouting() when $default != null:
return $default(_that.watchlistProspectIds,_that.knowledge,_that.combineAssignedProspectIds,_that.mockRanks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> watchlistProspectIds,  List<ScoutingKnowledge> knowledge,  List<String> combineAssignedProspectIds,  Map<String, int> mockRanks)  $default,) {final _that = this;
switch (_that) {
case _TeamScouting():
return $default(_that.watchlistProspectIds,_that.knowledge,_that.combineAssignedProspectIds,_that.mockRanks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> watchlistProspectIds,  List<ScoutingKnowledge> knowledge,  List<String> combineAssignedProspectIds,  Map<String, int> mockRanks)?  $default,) {final _that = this;
switch (_that) {
case _TeamScouting() when $default != null:
return $default(_that.watchlistProspectIds,_that.knowledge,_that.combineAssignedProspectIds,_that.mockRanks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamScouting implements TeamScouting {
  const _TeamScouting({final  List<String> watchlistProspectIds = const [], final  List<ScoutingKnowledge> knowledge = const [], final  List<String> combineAssignedProspectIds = const [], final  Map<String, int> mockRanks = const {}}): _watchlistProspectIds = watchlistProspectIds,_knowledge = knowledge,_combineAssignedProspectIds = combineAssignedProspectIds,_mockRanks = mockRanks;
  factory _TeamScouting.fromJson(Map<String, dynamic> json) => _$TeamScoutingFromJson(json);

 final  List<String> _watchlistProspectIds;
@override@JsonKey() List<String> get watchlistProspectIds {
  if (_watchlistProspectIds is EqualUnmodifiableListView) return _watchlistProspectIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_watchlistProspectIds);
}

 final  List<ScoutingKnowledge> _knowledge;
@override@JsonKey() List<ScoutingKnowledge> get knowledge {
  if (_knowledge is EqualUnmodifiableListView) return _knowledge;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_knowledge);
}

 final  List<String> _combineAssignedProspectIds;
@override@JsonKey() List<String> get combineAssignedProspectIds {
  if (_combineAssignedProspectIds is EqualUnmodifiableListView) return _combineAssignedProspectIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_combineAssignedProspectIds);
}

 final  Map<String, int> _mockRanks;
@override@JsonKey() Map<String, int> get mockRanks {
  if (_mockRanks is EqualUnmodifiableMapView) return _mockRanks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_mockRanks);
}


/// Create a copy of TeamScouting
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamScoutingCopyWith<_TeamScouting> get copyWith => __$TeamScoutingCopyWithImpl<_TeamScouting>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamScoutingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamScouting&&const DeepCollectionEquality().equals(other._watchlistProspectIds, _watchlistProspectIds)&&const DeepCollectionEquality().equals(other._knowledge, _knowledge)&&const DeepCollectionEquality().equals(other._combineAssignedProspectIds, _combineAssignedProspectIds)&&const DeepCollectionEquality().equals(other._mockRanks, _mockRanks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_watchlistProspectIds),const DeepCollectionEquality().hash(_knowledge),const DeepCollectionEquality().hash(_combineAssignedProspectIds),const DeepCollectionEquality().hash(_mockRanks));

@override
String toString() {
  return 'TeamScouting(watchlistProspectIds: $watchlistProspectIds, knowledge: $knowledge, combineAssignedProspectIds: $combineAssignedProspectIds, mockRanks: $mockRanks)';
}


}

/// @nodoc
abstract mixin class _$TeamScoutingCopyWith<$Res> implements $TeamScoutingCopyWith<$Res> {
  factory _$TeamScoutingCopyWith(_TeamScouting value, $Res Function(_TeamScouting) _then) = __$TeamScoutingCopyWithImpl;
@override @useResult
$Res call({
 List<String> watchlistProspectIds, List<ScoutingKnowledge> knowledge, List<String> combineAssignedProspectIds, Map<String, int> mockRanks
});




}
/// @nodoc
class __$TeamScoutingCopyWithImpl<$Res>
    implements _$TeamScoutingCopyWith<$Res> {
  __$TeamScoutingCopyWithImpl(this._self, this._then);

  final _TeamScouting _self;
  final $Res Function(_TeamScouting) _then;

/// Create a copy of TeamScouting
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? watchlistProspectIds = null,Object? knowledge = null,Object? combineAssignedProspectIds = null,Object? mockRanks = null,}) {
  return _then(_TeamScouting(
watchlistProspectIds: null == watchlistProspectIds ? _self._watchlistProspectIds : watchlistProspectIds // ignore: cast_nullable_to_non_nullable
as List<String>,knowledge: null == knowledge ? _self._knowledge : knowledge // ignore: cast_nullable_to_non_nullable
as List<ScoutingKnowledge>,combineAssignedProspectIds: null == combineAssignedProspectIds ? _self._combineAssignedProspectIds : combineAssignedProspectIds // ignore: cast_nullable_to_non_nullable
as List<String>,mockRanks: null == mockRanks ? _self._mockRanks : mockRanks // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}

// dart format on
