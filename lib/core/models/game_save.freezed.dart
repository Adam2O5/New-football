// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_save.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameSaveMeta {

 String get id; String get name; DateTime get createdAt; DateTime get updatedAt; int get seasonYear; SeasonPhase get phase; String? get playerTeamName; int get schemaVersion;
/// Create a copy of GameSaveMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameSaveMetaCopyWith<GameSaveMeta> get copyWith => _$GameSaveMetaCopyWithImpl<GameSaveMeta>(this as GameSaveMeta, _$identity);

  /// Serializes this GameSaveMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameSaveMeta&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.playerTeamName, playerTeamName) || other.playerTeamName == playerTeamName)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,createdAt,updatedAt,seasonYear,phase,playerTeamName,schemaVersion);

@override
String toString() {
  return 'GameSaveMeta(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt, seasonYear: $seasonYear, phase: $phase, playerTeamName: $playerTeamName, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class $GameSaveMetaCopyWith<$Res>  {
  factory $GameSaveMetaCopyWith(GameSaveMeta value, $Res Function(GameSaveMeta) _then) = _$GameSaveMetaCopyWithImpl;
@useResult
$Res call({
 String id, String name, DateTime createdAt, DateTime updatedAt, int seasonYear, SeasonPhase phase, String? playerTeamName, int schemaVersion
});




}
/// @nodoc
class _$GameSaveMetaCopyWithImpl<$Res>
    implements $GameSaveMetaCopyWith<$Res> {
  _$GameSaveMetaCopyWithImpl(this._self, this._then);

  final GameSaveMeta _self;
  final $Res Function(GameSaveMeta) _then;

/// Create a copy of GameSaveMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? createdAt = null,Object? updatedAt = null,Object? seasonYear = null,Object? phase = null,Object? playerTeamName = freezed,Object? schemaVersion = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SeasonPhase,playerTeamName: freezed == playerTeamName ? _self.playerTeamName : playerTeamName // ignore: cast_nullable_to_non_nullable
as String?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GameSaveMeta].
extension GameSaveMetaPatterns on GameSaveMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameSaveMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameSaveMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameSaveMeta value)  $default,){
final _that = this;
switch (_that) {
case _GameSaveMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameSaveMeta value)?  $default,){
final _that = this;
switch (_that) {
case _GameSaveMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  DateTime createdAt,  DateTime updatedAt,  int seasonYear,  SeasonPhase phase,  String? playerTeamName,  int schemaVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameSaveMeta() when $default != null:
return $default(_that.id,_that.name,_that.createdAt,_that.updatedAt,_that.seasonYear,_that.phase,_that.playerTeamName,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  DateTime createdAt,  DateTime updatedAt,  int seasonYear,  SeasonPhase phase,  String? playerTeamName,  int schemaVersion)  $default,) {final _that = this;
switch (_that) {
case _GameSaveMeta():
return $default(_that.id,_that.name,_that.createdAt,_that.updatedAt,_that.seasonYear,_that.phase,_that.playerTeamName,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  DateTime createdAt,  DateTime updatedAt,  int seasonYear,  SeasonPhase phase,  String? playerTeamName,  int schemaVersion)?  $default,) {final _that = this;
switch (_that) {
case _GameSaveMeta() when $default != null:
return $default(_that.id,_that.name,_that.createdAt,_that.updatedAt,_that.seasonYear,_that.phase,_that.playerTeamName,_that.schemaVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameSaveMeta implements GameSaveMeta {
  const _GameSaveMeta({required this.id, required this.name, required this.createdAt, required this.updatedAt, required this.seasonYear, required this.phase, this.playerTeamName, this.schemaVersion = SaveSchema.unknownVersion});
  factory _GameSaveMeta.fromJson(Map<String, dynamic> json) => _$GameSaveMetaFromJson(json);

@override final  String id;
@override final  String name;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  int seasonYear;
@override final  SeasonPhase phase;
@override final  String? playerTeamName;
@override@JsonKey() final  int schemaVersion;

/// Create a copy of GameSaveMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameSaveMetaCopyWith<_GameSaveMeta> get copyWith => __$GameSaveMetaCopyWithImpl<_GameSaveMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameSaveMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameSaveMeta&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.playerTeamName, playerTeamName) || other.playerTeamName == playerTeamName)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,createdAt,updatedAt,seasonYear,phase,playerTeamName,schemaVersion);

@override
String toString() {
  return 'GameSaveMeta(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt, seasonYear: $seasonYear, phase: $phase, playerTeamName: $playerTeamName, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class _$GameSaveMetaCopyWith<$Res> implements $GameSaveMetaCopyWith<$Res> {
  factory _$GameSaveMetaCopyWith(_GameSaveMeta value, $Res Function(_GameSaveMeta) _then) = __$GameSaveMetaCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, DateTime createdAt, DateTime updatedAt, int seasonYear, SeasonPhase phase, String? playerTeamName, int schemaVersion
});




}
/// @nodoc
class __$GameSaveMetaCopyWithImpl<$Res>
    implements _$GameSaveMetaCopyWith<$Res> {
  __$GameSaveMetaCopyWithImpl(this._self, this._then);

  final _GameSaveMeta _self;
  final $Res Function(_GameSaveMeta) _then;

/// Create a copy of GameSaveMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? createdAt = null,Object? updatedAt = null,Object? seasonYear = null,Object? phase = null,Object? playerTeamName = freezed,Object? schemaVersion = null,}) {
  return _then(_GameSaveMeta(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as SeasonPhase,playerTeamName: freezed == playerTeamName ? _self.playerTeamName : playerTeamName // ignore: cast_nullable_to_non_nullable
as String?,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$GameSave {

 GameSaveMeta get meta; LeagueState get leagueState; int get saveSeed; int get schemaVersion;
/// Create a copy of GameSave
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameSaveCopyWith<GameSave> get copyWith => _$GameSaveCopyWithImpl<GameSave>(this as GameSave, _$identity);

  /// Serializes this GameSave to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameSave&&(identical(other.meta, meta) || other.meta == meta)&&(identical(other.leagueState, leagueState) || other.leagueState == leagueState)&&(identical(other.saveSeed, saveSeed) || other.saveSeed == saveSeed)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,meta,leagueState,saveSeed,schemaVersion);

@override
String toString() {
  return 'GameSave(meta: $meta, leagueState: $leagueState, saveSeed: $saveSeed, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class $GameSaveCopyWith<$Res>  {
  factory $GameSaveCopyWith(GameSave value, $Res Function(GameSave) _then) = _$GameSaveCopyWithImpl;
@useResult
$Res call({
 GameSaveMeta meta, LeagueState leagueState, int saveSeed, int schemaVersion
});


$GameSaveMetaCopyWith<$Res> get meta;$LeagueStateCopyWith<$Res> get leagueState;

}
/// @nodoc
class _$GameSaveCopyWithImpl<$Res>
    implements $GameSaveCopyWith<$Res> {
  _$GameSaveCopyWithImpl(this._self, this._then);

  final GameSave _self;
  final $Res Function(GameSave) _then;

/// Create a copy of GameSave
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? meta = null,Object? leagueState = null,Object? saveSeed = null,Object? schemaVersion = null,}) {
  return _then(_self.copyWith(
meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as GameSaveMeta,leagueState: null == leagueState ? _self.leagueState : leagueState // ignore: cast_nullable_to_non_nullable
as LeagueState,saveSeed: null == saveSeed ? _self.saveSeed : saveSeed // ignore: cast_nullable_to_non_nullable
as int,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of GameSave
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GameSaveMetaCopyWith<$Res> get meta {
  
  return $GameSaveMetaCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}/// Create a copy of GameSave
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LeagueStateCopyWith<$Res> get leagueState {
  
  return $LeagueStateCopyWith<$Res>(_self.leagueState, (value) {
    return _then(_self.copyWith(leagueState: value));
  });
}
}


/// Adds pattern-matching-related methods to [GameSave].
extension GameSavePatterns on GameSave {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameSave value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameSave() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameSave value)  $default,){
final _that = this;
switch (_that) {
case _GameSave():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameSave value)?  $default,){
final _that = this;
switch (_that) {
case _GameSave() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GameSaveMeta meta,  LeagueState leagueState,  int saveSeed,  int schemaVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameSave() when $default != null:
return $default(_that.meta,_that.leagueState,_that.saveSeed,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GameSaveMeta meta,  LeagueState leagueState,  int saveSeed,  int schemaVersion)  $default,) {final _that = this;
switch (_that) {
case _GameSave():
return $default(_that.meta,_that.leagueState,_that.saveSeed,_that.schemaVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GameSaveMeta meta,  LeagueState leagueState,  int saveSeed,  int schemaVersion)?  $default,) {final _that = this;
switch (_that) {
case _GameSave() when $default != null:
return $default(_that.meta,_that.leagueState,_that.saveSeed,_that.schemaVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameSave implements GameSave {
  const _GameSave({required this.meta, required this.leagueState, required this.saveSeed, this.schemaVersion = SaveSchema.unknownVersion});
  factory _GameSave.fromJson(Map<String, dynamic> json) => _$GameSaveFromJson(json);

@override final  GameSaveMeta meta;
@override final  LeagueState leagueState;
@override final  int saveSeed;
@override@JsonKey() final  int schemaVersion;

/// Create a copy of GameSave
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameSaveCopyWith<_GameSave> get copyWith => __$GameSaveCopyWithImpl<_GameSave>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameSaveToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameSave&&(identical(other.meta, meta) || other.meta == meta)&&(identical(other.leagueState, leagueState) || other.leagueState == leagueState)&&(identical(other.saveSeed, saveSeed) || other.saveSeed == saveSeed)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,meta,leagueState,saveSeed,schemaVersion);

@override
String toString() {
  return 'GameSave(meta: $meta, leagueState: $leagueState, saveSeed: $saveSeed, schemaVersion: $schemaVersion)';
}


}

/// @nodoc
abstract mixin class _$GameSaveCopyWith<$Res> implements $GameSaveCopyWith<$Res> {
  factory _$GameSaveCopyWith(_GameSave value, $Res Function(_GameSave) _then) = __$GameSaveCopyWithImpl;
@override @useResult
$Res call({
 GameSaveMeta meta, LeagueState leagueState, int saveSeed, int schemaVersion
});


@override $GameSaveMetaCopyWith<$Res> get meta;@override $LeagueStateCopyWith<$Res> get leagueState;

}
/// @nodoc
class __$GameSaveCopyWithImpl<$Res>
    implements _$GameSaveCopyWith<$Res> {
  __$GameSaveCopyWithImpl(this._self, this._then);

  final _GameSave _self;
  final $Res Function(_GameSave) _then;

/// Create a copy of GameSave
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? meta = null,Object? leagueState = null,Object? saveSeed = null,Object? schemaVersion = null,}) {
  return _then(_GameSave(
meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as GameSaveMeta,leagueState: null == leagueState ? _self.leagueState : leagueState // ignore: cast_nullable_to_non_nullable
as LeagueState,saveSeed: null == saveSeed ? _self.saveSeed : saveSeed // ignore: cast_nullable_to_non_nullable
as int,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of GameSave
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GameSaveMetaCopyWith<$Res> get meta {
  
  return $GameSaveMetaCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}/// Create a copy of GameSave
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LeagueStateCopyWith<$Res> get leagueState {
  
  return $LeagueStateCopyWith<$Res>(_self.leagueState, (value) {
    return _then(_self.copyWith(leagueState: value));
  });
}
}

// dart format on
