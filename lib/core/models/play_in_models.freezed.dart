// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'play_in_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlayInResult {

 Conference get conference; String get seed7TeamId; String get seed8TeamId; MatchResult get game7v8; MatchResult get game9v10; MatchResult get gameFinal; String get playoffSeed7TeamId; String get playoffSeed8TeamId;
/// Create a copy of PlayInResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayInResultCopyWith<PlayInResult> get copyWith => _$PlayInResultCopyWithImpl<PlayInResult>(this as PlayInResult, _$identity);

  /// Serializes this PlayInResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayInResult&&(identical(other.conference, conference) || other.conference == conference)&&(identical(other.seed7TeamId, seed7TeamId) || other.seed7TeamId == seed7TeamId)&&(identical(other.seed8TeamId, seed8TeamId) || other.seed8TeamId == seed8TeamId)&&(identical(other.game7v8, game7v8) || other.game7v8 == game7v8)&&(identical(other.game9v10, game9v10) || other.game9v10 == game9v10)&&(identical(other.gameFinal, gameFinal) || other.gameFinal == gameFinal)&&(identical(other.playoffSeed7TeamId, playoffSeed7TeamId) || other.playoffSeed7TeamId == playoffSeed7TeamId)&&(identical(other.playoffSeed8TeamId, playoffSeed8TeamId) || other.playoffSeed8TeamId == playoffSeed8TeamId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conference,seed7TeamId,seed8TeamId,game7v8,game9v10,gameFinal,playoffSeed7TeamId,playoffSeed8TeamId);

@override
String toString() {
  return 'PlayInResult(conference: $conference, seed7TeamId: $seed7TeamId, seed8TeamId: $seed8TeamId, game7v8: $game7v8, game9v10: $game9v10, gameFinal: $gameFinal, playoffSeed7TeamId: $playoffSeed7TeamId, playoffSeed8TeamId: $playoffSeed8TeamId)';
}


}

/// @nodoc
abstract mixin class $PlayInResultCopyWith<$Res>  {
  factory $PlayInResultCopyWith(PlayInResult value, $Res Function(PlayInResult) _then) = _$PlayInResultCopyWithImpl;
@useResult
$Res call({
 Conference conference, String seed7TeamId, String seed8TeamId, MatchResult game7v8, MatchResult game9v10, MatchResult gameFinal, String playoffSeed7TeamId, String playoffSeed8TeamId
});


$MatchResultCopyWith<$Res> get game7v8;$MatchResultCopyWith<$Res> get game9v10;$MatchResultCopyWith<$Res> get gameFinal;

}
/// @nodoc
class _$PlayInResultCopyWithImpl<$Res>
    implements $PlayInResultCopyWith<$Res> {
  _$PlayInResultCopyWithImpl(this._self, this._then);

  final PlayInResult _self;
  final $Res Function(PlayInResult) _then;

/// Create a copy of PlayInResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conference = null,Object? seed7TeamId = null,Object? seed8TeamId = null,Object? game7v8 = null,Object? game9v10 = null,Object? gameFinal = null,Object? playoffSeed7TeamId = null,Object? playoffSeed8TeamId = null,}) {
  return _then(_self.copyWith(
conference: null == conference ? _self.conference : conference // ignore: cast_nullable_to_non_nullable
as Conference,seed7TeamId: null == seed7TeamId ? _self.seed7TeamId : seed7TeamId // ignore: cast_nullable_to_non_nullable
as String,seed8TeamId: null == seed8TeamId ? _self.seed8TeamId : seed8TeamId // ignore: cast_nullable_to_non_nullable
as String,game7v8: null == game7v8 ? _self.game7v8 : game7v8 // ignore: cast_nullable_to_non_nullable
as MatchResult,game9v10: null == game9v10 ? _self.game9v10 : game9v10 // ignore: cast_nullable_to_non_nullable
as MatchResult,gameFinal: null == gameFinal ? _self.gameFinal : gameFinal // ignore: cast_nullable_to_non_nullable
as MatchResult,playoffSeed7TeamId: null == playoffSeed7TeamId ? _self.playoffSeed7TeamId : playoffSeed7TeamId // ignore: cast_nullable_to_non_nullable
as String,playoffSeed8TeamId: null == playoffSeed8TeamId ? _self.playoffSeed8TeamId : playoffSeed8TeamId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of PlayInResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res> get game7v8 {
  
  return $MatchResultCopyWith<$Res>(_self.game7v8, (value) {
    return _then(_self.copyWith(game7v8: value));
  });
}/// Create a copy of PlayInResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res> get game9v10 {
  
  return $MatchResultCopyWith<$Res>(_self.game9v10, (value) {
    return _then(_self.copyWith(game9v10: value));
  });
}/// Create a copy of PlayInResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res> get gameFinal {
  
  return $MatchResultCopyWith<$Res>(_self.gameFinal, (value) {
    return _then(_self.copyWith(gameFinal: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayInResult].
extension PlayInResultPatterns on PlayInResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayInResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayInResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayInResult value)  $default,){
final _that = this;
switch (_that) {
case _PlayInResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayInResult value)?  $default,){
final _that = this;
switch (_that) {
case _PlayInResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Conference conference,  String seed7TeamId,  String seed8TeamId,  MatchResult game7v8,  MatchResult game9v10,  MatchResult gameFinal,  String playoffSeed7TeamId,  String playoffSeed8TeamId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayInResult() when $default != null:
return $default(_that.conference,_that.seed7TeamId,_that.seed8TeamId,_that.game7v8,_that.game9v10,_that.gameFinal,_that.playoffSeed7TeamId,_that.playoffSeed8TeamId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Conference conference,  String seed7TeamId,  String seed8TeamId,  MatchResult game7v8,  MatchResult game9v10,  MatchResult gameFinal,  String playoffSeed7TeamId,  String playoffSeed8TeamId)  $default,) {final _that = this;
switch (_that) {
case _PlayInResult():
return $default(_that.conference,_that.seed7TeamId,_that.seed8TeamId,_that.game7v8,_that.game9v10,_that.gameFinal,_that.playoffSeed7TeamId,_that.playoffSeed8TeamId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Conference conference,  String seed7TeamId,  String seed8TeamId,  MatchResult game7v8,  MatchResult game9v10,  MatchResult gameFinal,  String playoffSeed7TeamId,  String playoffSeed8TeamId)?  $default,) {final _that = this;
switch (_that) {
case _PlayInResult() when $default != null:
return $default(_that.conference,_that.seed7TeamId,_that.seed8TeamId,_that.game7v8,_that.game9v10,_that.gameFinal,_that.playoffSeed7TeamId,_that.playoffSeed8TeamId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayInResult implements PlayInResult {
  const _PlayInResult({required this.conference, required this.seed7TeamId, required this.seed8TeamId, required this.game7v8, required this.game9v10, required this.gameFinal, required this.playoffSeed7TeamId, required this.playoffSeed8TeamId});
  factory _PlayInResult.fromJson(Map<String, dynamic> json) => _$PlayInResultFromJson(json);

@override final  Conference conference;
@override final  String seed7TeamId;
@override final  String seed8TeamId;
@override final  MatchResult game7v8;
@override final  MatchResult game9v10;
@override final  MatchResult gameFinal;
@override final  String playoffSeed7TeamId;
@override final  String playoffSeed8TeamId;

/// Create a copy of PlayInResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayInResultCopyWith<_PlayInResult> get copyWith => __$PlayInResultCopyWithImpl<_PlayInResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayInResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayInResult&&(identical(other.conference, conference) || other.conference == conference)&&(identical(other.seed7TeamId, seed7TeamId) || other.seed7TeamId == seed7TeamId)&&(identical(other.seed8TeamId, seed8TeamId) || other.seed8TeamId == seed8TeamId)&&(identical(other.game7v8, game7v8) || other.game7v8 == game7v8)&&(identical(other.game9v10, game9v10) || other.game9v10 == game9v10)&&(identical(other.gameFinal, gameFinal) || other.gameFinal == gameFinal)&&(identical(other.playoffSeed7TeamId, playoffSeed7TeamId) || other.playoffSeed7TeamId == playoffSeed7TeamId)&&(identical(other.playoffSeed8TeamId, playoffSeed8TeamId) || other.playoffSeed8TeamId == playoffSeed8TeamId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conference,seed7TeamId,seed8TeamId,game7v8,game9v10,gameFinal,playoffSeed7TeamId,playoffSeed8TeamId);

@override
String toString() {
  return 'PlayInResult(conference: $conference, seed7TeamId: $seed7TeamId, seed8TeamId: $seed8TeamId, game7v8: $game7v8, game9v10: $game9v10, gameFinal: $gameFinal, playoffSeed7TeamId: $playoffSeed7TeamId, playoffSeed8TeamId: $playoffSeed8TeamId)';
}


}

/// @nodoc
abstract mixin class _$PlayInResultCopyWith<$Res> implements $PlayInResultCopyWith<$Res> {
  factory _$PlayInResultCopyWith(_PlayInResult value, $Res Function(_PlayInResult) _then) = __$PlayInResultCopyWithImpl;
@override @useResult
$Res call({
 Conference conference, String seed7TeamId, String seed8TeamId, MatchResult game7v8, MatchResult game9v10, MatchResult gameFinal, String playoffSeed7TeamId, String playoffSeed8TeamId
});


@override $MatchResultCopyWith<$Res> get game7v8;@override $MatchResultCopyWith<$Res> get game9v10;@override $MatchResultCopyWith<$Res> get gameFinal;

}
/// @nodoc
class __$PlayInResultCopyWithImpl<$Res>
    implements _$PlayInResultCopyWith<$Res> {
  __$PlayInResultCopyWithImpl(this._self, this._then);

  final _PlayInResult _self;
  final $Res Function(_PlayInResult) _then;

/// Create a copy of PlayInResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conference = null,Object? seed7TeamId = null,Object? seed8TeamId = null,Object? game7v8 = null,Object? game9v10 = null,Object? gameFinal = null,Object? playoffSeed7TeamId = null,Object? playoffSeed8TeamId = null,}) {
  return _then(_PlayInResult(
conference: null == conference ? _self.conference : conference // ignore: cast_nullable_to_non_nullable
as Conference,seed7TeamId: null == seed7TeamId ? _self.seed7TeamId : seed7TeamId // ignore: cast_nullable_to_non_nullable
as String,seed8TeamId: null == seed8TeamId ? _self.seed8TeamId : seed8TeamId // ignore: cast_nullable_to_non_nullable
as String,game7v8: null == game7v8 ? _self.game7v8 : game7v8 // ignore: cast_nullable_to_non_nullable
as MatchResult,game9v10: null == game9v10 ? _self.game9v10 : game9v10 // ignore: cast_nullable_to_non_nullable
as MatchResult,gameFinal: null == gameFinal ? _self.gameFinal : gameFinal // ignore: cast_nullable_to_non_nullable
as MatchResult,playoffSeed7TeamId: null == playoffSeed7TeamId ? _self.playoffSeed7TeamId : playoffSeed7TeamId // ignore: cast_nullable_to_non_nullable
as String,playoffSeed8TeamId: null == playoffSeed8TeamId ? _self.playoffSeed8TeamId : playoffSeed8TeamId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of PlayInResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res> get game7v8 {
  
  return $MatchResultCopyWith<$Res>(_self.game7v8, (value) {
    return _then(_self.copyWith(game7v8: value));
  });
}/// Create a copy of PlayInResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res> get game9v10 {
  
  return $MatchResultCopyWith<$Res>(_self.game9v10, (value) {
    return _then(_self.copyWith(game9v10: value));
  });
}/// Create a copy of PlayInResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res> get gameFinal {
  
  return $MatchResultCopyWith<$Res>(_self.gameFinal, (value) {
    return _then(_self.copyWith(gameFinal: value));
  });
}
}


/// @nodoc
mixin _$PlayInProgress {

 Conference get conference; String get seed7TeamId; String get seed8TeamId; String get seed9TeamId; String get seed10TeamId; MatchResult? get game7v8; MatchResult? get game9v10; MatchResult? get gameFinal;
/// Create a copy of PlayInProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayInProgressCopyWith<PlayInProgress> get copyWith => _$PlayInProgressCopyWithImpl<PlayInProgress>(this as PlayInProgress, _$identity);

  /// Serializes this PlayInProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayInProgress&&(identical(other.conference, conference) || other.conference == conference)&&(identical(other.seed7TeamId, seed7TeamId) || other.seed7TeamId == seed7TeamId)&&(identical(other.seed8TeamId, seed8TeamId) || other.seed8TeamId == seed8TeamId)&&(identical(other.seed9TeamId, seed9TeamId) || other.seed9TeamId == seed9TeamId)&&(identical(other.seed10TeamId, seed10TeamId) || other.seed10TeamId == seed10TeamId)&&(identical(other.game7v8, game7v8) || other.game7v8 == game7v8)&&(identical(other.game9v10, game9v10) || other.game9v10 == game9v10)&&(identical(other.gameFinal, gameFinal) || other.gameFinal == gameFinal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conference,seed7TeamId,seed8TeamId,seed9TeamId,seed10TeamId,game7v8,game9v10,gameFinal);

@override
String toString() {
  return 'PlayInProgress(conference: $conference, seed7TeamId: $seed7TeamId, seed8TeamId: $seed8TeamId, seed9TeamId: $seed9TeamId, seed10TeamId: $seed10TeamId, game7v8: $game7v8, game9v10: $game9v10, gameFinal: $gameFinal)';
}


}

/// @nodoc
abstract mixin class $PlayInProgressCopyWith<$Res>  {
  factory $PlayInProgressCopyWith(PlayInProgress value, $Res Function(PlayInProgress) _then) = _$PlayInProgressCopyWithImpl;
@useResult
$Res call({
 Conference conference, String seed7TeamId, String seed8TeamId, String seed9TeamId, String seed10TeamId, MatchResult? game7v8, MatchResult? game9v10, MatchResult? gameFinal
});


$MatchResultCopyWith<$Res>? get game7v8;$MatchResultCopyWith<$Res>? get game9v10;$MatchResultCopyWith<$Res>? get gameFinal;

}
/// @nodoc
class _$PlayInProgressCopyWithImpl<$Res>
    implements $PlayInProgressCopyWith<$Res> {
  _$PlayInProgressCopyWithImpl(this._self, this._then);

  final PlayInProgress _self;
  final $Res Function(PlayInProgress) _then;

/// Create a copy of PlayInProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conference = null,Object? seed7TeamId = null,Object? seed8TeamId = null,Object? seed9TeamId = null,Object? seed10TeamId = null,Object? game7v8 = freezed,Object? game9v10 = freezed,Object? gameFinal = freezed,}) {
  return _then(_self.copyWith(
conference: null == conference ? _self.conference : conference // ignore: cast_nullable_to_non_nullable
as Conference,seed7TeamId: null == seed7TeamId ? _self.seed7TeamId : seed7TeamId // ignore: cast_nullable_to_non_nullable
as String,seed8TeamId: null == seed8TeamId ? _self.seed8TeamId : seed8TeamId // ignore: cast_nullable_to_non_nullable
as String,seed9TeamId: null == seed9TeamId ? _self.seed9TeamId : seed9TeamId // ignore: cast_nullable_to_non_nullable
as String,seed10TeamId: null == seed10TeamId ? _self.seed10TeamId : seed10TeamId // ignore: cast_nullable_to_non_nullable
as String,game7v8: freezed == game7v8 ? _self.game7v8 : game7v8 // ignore: cast_nullable_to_non_nullable
as MatchResult?,game9v10: freezed == game9v10 ? _self.game9v10 : game9v10 // ignore: cast_nullable_to_non_nullable
as MatchResult?,gameFinal: freezed == gameFinal ? _self.gameFinal : gameFinal // ignore: cast_nullable_to_non_nullable
as MatchResult?,
  ));
}
/// Create a copy of PlayInProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res>? get game7v8 {
    if (_self.game7v8 == null) {
    return null;
  }

  return $MatchResultCopyWith<$Res>(_self.game7v8!, (value) {
    return _then(_self.copyWith(game7v8: value));
  });
}/// Create a copy of PlayInProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res>? get game9v10 {
    if (_self.game9v10 == null) {
    return null;
  }

  return $MatchResultCopyWith<$Res>(_self.game9v10!, (value) {
    return _then(_self.copyWith(game9v10: value));
  });
}/// Create a copy of PlayInProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res>? get gameFinal {
    if (_self.gameFinal == null) {
    return null;
  }

  return $MatchResultCopyWith<$Res>(_self.gameFinal!, (value) {
    return _then(_self.copyWith(gameFinal: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayInProgress].
extension PlayInProgressPatterns on PlayInProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayInProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayInProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayInProgress value)  $default,){
final _that = this;
switch (_that) {
case _PlayInProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayInProgress value)?  $default,){
final _that = this;
switch (_that) {
case _PlayInProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Conference conference,  String seed7TeamId,  String seed8TeamId,  String seed9TeamId,  String seed10TeamId,  MatchResult? game7v8,  MatchResult? game9v10,  MatchResult? gameFinal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayInProgress() when $default != null:
return $default(_that.conference,_that.seed7TeamId,_that.seed8TeamId,_that.seed9TeamId,_that.seed10TeamId,_that.game7v8,_that.game9v10,_that.gameFinal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Conference conference,  String seed7TeamId,  String seed8TeamId,  String seed9TeamId,  String seed10TeamId,  MatchResult? game7v8,  MatchResult? game9v10,  MatchResult? gameFinal)  $default,) {final _that = this;
switch (_that) {
case _PlayInProgress():
return $default(_that.conference,_that.seed7TeamId,_that.seed8TeamId,_that.seed9TeamId,_that.seed10TeamId,_that.game7v8,_that.game9v10,_that.gameFinal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Conference conference,  String seed7TeamId,  String seed8TeamId,  String seed9TeamId,  String seed10TeamId,  MatchResult? game7v8,  MatchResult? game9v10,  MatchResult? gameFinal)?  $default,) {final _that = this;
switch (_that) {
case _PlayInProgress() when $default != null:
return $default(_that.conference,_that.seed7TeamId,_that.seed8TeamId,_that.seed9TeamId,_that.seed10TeamId,_that.game7v8,_that.game9v10,_that.gameFinal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayInProgress implements PlayInProgress {
  const _PlayInProgress({required this.conference, required this.seed7TeamId, required this.seed8TeamId, required this.seed9TeamId, required this.seed10TeamId, this.game7v8, this.game9v10, this.gameFinal});
  factory _PlayInProgress.fromJson(Map<String, dynamic> json) => _$PlayInProgressFromJson(json);

@override final  Conference conference;
@override final  String seed7TeamId;
@override final  String seed8TeamId;
@override final  String seed9TeamId;
@override final  String seed10TeamId;
@override final  MatchResult? game7v8;
@override final  MatchResult? game9v10;
@override final  MatchResult? gameFinal;

/// Create a copy of PlayInProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayInProgressCopyWith<_PlayInProgress> get copyWith => __$PlayInProgressCopyWithImpl<_PlayInProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayInProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayInProgress&&(identical(other.conference, conference) || other.conference == conference)&&(identical(other.seed7TeamId, seed7TeamId) || other.seed7TeamId == seed7TeamId)&&(identical(other.seed8TeamId, seed8TeamId) || other.seed8TeamId == seed8TeamId)&&(identical(other.seed9TeamId, seed9TeamId) || other.seed9TeamId == seed9TeamId)&&(identical(other.seed10TeamId, seed10TeamId) || other.seed10TeamId == seed10TeamId)&&(identical(other.game7v8, game7v8) || other.game7v8 == game7v8)&&(identical(other.game9v10, game9v10) || other.game9v10 == game9v10)&&(identical(other.gameFinal, gameFinal) || other.gameFinal == gameFinal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conference,seed7TeamId,seed8TeamId,seed9TeamId,seed10TeamId,game7v8,game9v10,gameFinal);

@override
String toString() {
  return 'PlayInProgress(conference: $conference, seed7TeamId: $seed7TeamId, seed8TeamId: $seed8TeamId, seed9TeamId: $seed9TeamId, seed10TeamId: $seed10TeamId, game7v8: $game7v8, game9v10: $game9v10, gameFinal: $gameFinal)';
}


}

/// @nodoc
abstract mixin class _$PlayInProgressCopyWith<$Res> implements $PlayInProgressCopyWith<$Res> {
  factory _$PlayInProgressCopyWith(_PlayInProgress value, $Res Function(_PlayInProgress) _then) = __$PlayInProgressCopyWithImpl;
@override @useResult
$Res call({
 Conference conference, String seed7TeamId, String seed8TeamId, String seed9TeamId, String seed10TeamId, MatchResult? game7v8, MatchResult? game9v10, MatchResult? gameFinal
});


@override $MatchResultCopyWith<$Res>? get game7v8;@override $MatchResultCopyWith<$Res>? get game9v10;@override $MatchResultCopyWith<$Res>? get gameFinal;

}
/// @nodoc
class __$PlayInProgressCopyWithImpl<$Res>
    implements _$PlayInProgressCopyWith<$Res> {
  __$PlayInProgressCopyWithImpl(this._self, this._then);

  final _PlayInProgress _self;
  final $Res Function(_PlayInProgress) _then;

/// Create a copy of PlayInProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conference = null,Object? seed7TeamId = null,Object? seed8TeamId = null,Object? seed9TeamId = null,Object? seed10TeamId = null,Object? game7v8 = freezed,Object? game9v10 = freezed,Object? gameFinal = freezed,}) {
  return _then(_PlayInProgress(
conference: null == conference ? _self.conference : conference // ignore: cast_nullable_to_non_nullable
as Conference,seed7TeamId: null == seed7TeamId ? _self.seed7TeamId : seed7TeamId // ignore: cast_nullable_to_non_nullable
as String,seed8TeamId: null == seed8TeamId ? _self.seed8TeamId : seed8TeamId // ignore: cast_nullable_to_non_nullable
as String,seed9TeamId: null == seed9TeamId ? _self.seed9TeamId : seed9TeamId // ignore: cast_nullable_to_non_nullable
as String,seed10TeamId: null == seed10TeamId ? _self.seed10TeamId : seed10TeamId // ignore: cast_nullable_to_non_nullable
as String,game7v8: freezed == game7v8 ? _self.game7v8 : game7v8 // ignore: cast_nullable_to_non_nullable
as MatchResult?,game9v10: freezed == game9v10 ? _self.game9v10 : game9v10 // ignore: cast_nullable_to_non_nullable
as MatchResult?,gameFinal: freezed == gameFinal ? _self.gameFinal : gameFinal // ignore: cast_nullable_to_non_nullable
as MatchResult?,
  ));
}

/// Create a copy of PlayInProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res>? get game7v8 {
    if (_self.game7v8 == null) {
    return null;
  }

  return $MatchResultCopyWith<$Res>(_self.game7v8!, (value) {
    return _then(_self.copyWith(game7v8: value));
  });
}/// Create a copy of PlayInProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res>? get game9v10 {
    if (_self.game9v10 == null) {
    return null;
  }

  return $MatchResultCopyWith<$Res>(_self.game9v10!, (value) {
    return _then(_self.copyWith(game9v10: value));
  });
}/// Create a copy of PlayInProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MatchResultCopyWith<$Res>? get gameFinal {
    if (_self.gameFinal == null) {
    return null;
  }

  return $MatchResultCopyWith<$Res>(_self.gameFinal!, (value) {
    return _then(_self.copyWith(gameFinal: value));
  });
}
}

// dart format on
