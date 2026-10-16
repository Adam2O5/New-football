// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playoff_bracket.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlayoffBracket {

 Conference get conference; List<PlayoffSeries> get quarterFinals; List<PlayoffSeries> get semiFinals; List<PlayoffSeries> get conferenceFinal; PlayoffSeries? get leagueFinal;
/// Create a copy of PlayoffBracket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayoffBracketCopyWith<PlayoffBracket> get copyWith => _$PlayoffBracketCopyWithImpl<PlayoffBracket>(this as PlayoffBracket, _$identity);

  /// Serializes this PlayoffBracket to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayoffBracket&&(identical(other.conference, conference) || other.conference == conference)&&const DeepCollectionEquality().equals(other.quarterFinals, quarterFinals)&&const DeepCollectionEquality().equals(other.semiFinals, semiFinals)&&const DeepCollectionEquality().equals(other.conferenceFinal, conferenceFinal)&&(identical(other.leagueFinal, leagueFinal) || other.leagueFinal == leagueFinal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conference,const DeepCollectionEquality().hash(quarterFinals),const DeepCollectionEquality().hash(semiFinals),const DeepCollectionEquality().hash(conferenceFinal),leagueFinal);

@override
String toString() {
  return 'PlayoffBracket(conference: $conference, quarterFinals: $quarterFinals, semiFinals: $semiFinals, conferenceFinal: $conferenceFinal, leagueFinal: $leagueFinal)';
}


}

/// @nodoc
abstract mixin class $PlayoffBracketCopyWith<$Res>  {
  factory $PlayoffBracketCopyWith(PlayoffBracket value, $Res Function(PlayoffBracket) _then) = _$PlayoffBracketCopyWithImpl;
@useResult
$Res call({
 Conference conference, List<PlayoffSeries> quarterFinals, List<PlayoffSeries> semiFinals, List<PlayoffSeries> conferenceFinal, PlayoffSeries? leagueFinal
});


$PlayoffSeriesCopyWith<$Res>? get leagueFinal;

}
/// @nodoc
class _$PlayoffBracketCopyWithImpl<$Res>
    implements $PlayoffBracketCopyWith<$Res> {
  _$PlayoffBracketCopyWithImpl(this._self, this._then);

  final PlayoffBracket _self;
  final $Res Function(PlayoffBracket) _then;

/// Create a copy of PlayoffBracket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conference = null,Object? quarterFinals = null,Object? semiFinals = null,Object? conferenceFinal = null,Object? leagueFinal = freezed,}) {
  return _then(_self.copyWith(
conference: null == conference ? _self.conference : conference // ignore: cast_nullable_to_non_nullable
as Conference,quarterFinals: null == quarterFinals ? _self.quarterFinals : quarterFinals // ignore: cast_nullable_to_non_nullable
as List<PlayoffSeries>,semiFinals: null == semiFinals ? _self.semiFinals : semiFinals // ignore: cast_nullable_to_non_nullable
as List<PlayoffSeries>,conferenceFinal: null == conferenceFinal ? _self.conferenceFinal : conferenceFinal // ignore: cast_nullable_to_non_nullable
as List<PlayoffSeries>,leagueFinal: freezed == leagueFinal ? _self.leagueFinal : leagueFinal // ignore: cast_nullable_to_non_nullable
as PlayoffSeries?,
  ));
}
/// Create a copy of PlayoffBracket
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayoffSeriesCopyWith<$Res>? get leagueFinal {
    if (_self.leagueFinal == null) {
    return null;
  }

  return $PlayoffSeriesCopyWith<$Res>(_self.leagueFinal!, (value) {
    return _then(_self.copyWith(leagueFinal: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayoffBracket].
extension PlayoffBracketPatterns on PlayoffBracket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayoffBracket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayoffBracket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayoffBracket value)  $default,){
final _that = this;
switch (_that) {
case _PlayoffBracket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayoffBracket value)?  $default,){
final _that = this;
switch (_that) {
case _PlayoffBracket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Conference conference,  List<PlayoffSeries> quarterFinals,  List<PlayoffSeries> semiFinals,  List<PlayoffSeries> conferenceFinal,  PlayoffSeries? leagueFinal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayoffBracket() when $default != null:
return $default(_that.conference,_that.quarterFinals,_that.semiFinals,_that.conferenceFinal,_that.leagueFinal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Conference conference,  List<PlayoffSeries> quarterFinals,  List<PlayoffSeries> semiFinals,  List<PlayoffSeries> conferenceFinal,  PlayoffSeries? leagueFinal)  $default,) {final _that = this;
switch (_that) {
case _PlayoffBracket():
return $default(_that.conference,_that.quarterFinals,_that.semiFinals,_that.conferenceFinal,_that.leagueFinal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Conference conference,  List<PlayoffSeries> quarterFinals,  List<PlayoffSeries> semiFinals,  List<PlayoffSeries> conferenceFinal,  PlayoffSeries? leagueFinal)?  $default,) {final _that = this;
switch (_that) {
case _PlayoffBracket() when $default != null:
return $default(_that.conference,_that.quarterFinals,_that.semiFinals,_that.conferenceFinal,_that.leagueFinal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayoffBracket implements PlayoffBracket {
  const _PlayoffBracket({required this.conference, final  List<PlayoffSeries> quarterFinals = const [], final  List<PlayoffSeries> semiFinals = const [], final  List<PlayoffSeries> conferenceFinal = const [], this.leagueFinal}): _quarterFinals = quarterFinals,_semiFinals = semiFinals,_conferenceFinal = conferenceFinal;
  factory _PlayoffBracket.fromJson(Map<String, dynamic> json) => _$PlayoffBracketFromJson(json);

@override final  Conference conference;
 final  List<PlayoffSeries> _quarterFinals;
@override@JsonKey() List<PlayoffSeries> get quarterFinals {
  if (_quarterFinals is EqualUnmodifiableListView) return _quarterFinals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_quarterFinals);
}

 final  List<PlayoffSeries> _semiFinals;
@override@JsonKey() List<PlayoffSeries> get semiFinals {
  if (_semiFinals is EqualUnmodifiableListView) return _semiFinals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_semiFinals);
}

 final  List<PlayoffSeries> _conferenceFinal;
@override@JsonKey() List<PlayoffSeries> get conferenceFinal {
  if (_conferenceFinal is EqualUnmodifiableListView) return _conferenceFinal;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conferenceFinal);
}

@override final  PlayoffSeries? leagueFinal;

/// Create a copy of PlayoffBracket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayoffBracketCopyWith<_PlayoffBracket> get copyWith => __$PlayoffBracketCopyWithImpl<_PlayoffBracket>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayoffBracketToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayoffBracket&&(identical(other.conference, conference) || other.conference == conference)&&const DeepCollectionEquality().equals(other._quarterFinals, _quarterFinals)&&const DeepCollectionEquality().equals(other._semiFinals, _semiFinals)&&const DeepCollectionEquality().equals(other._conferenceFinal, _conferenceFinal)&&(identical(other.leagueFinal, leagueFinal) || other.leagueFinal == leagueFinal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,conference,const DeepCollectionEquality().hash(_quarterFinals),const DeepCollectionEquality().hash(_semiFinals),const DeepCollectionEquality().hash(_conferenceFinal),leagueFinal);

@override
String toString() {
  return 'PlayoffBracket(conference: $conference, quarterFinals: $quarterFinals, semiFinals: $semiFinals, conferenceFinal: $conferenceFinal, leagueFinal: $leagueFinal)';
}


}

/// @nodoc
abstract mixin class _$PlayoffBracketCopyWith<$Res> implements $PlayoffBracketCopyWith<$Res> {
  factory _$PlayoffBracketCopyWith(_PlayoffBracket value, $Res Function(_PlayoffBracket) _then) = __$PlayoffBracketCopyWithImpl;
@override @useResult
$Res call({
 Conference conference, List<PlayoffSeries> quarterFinals, List<PlayoffSeries> semiFinals, List<PlayoffSeries> conferenceFinal, PlayoffSeries? leagueFinal
});


@override $PlayoffSeriesCopyWith<$Res>? get leagueFinal;

}
/// @nodoc
class __$PlayoffBracketCopyWithImpl<$Res>
    implements _$PlayoffBracketCopyWith<$Res> {
  __$PlayoffBracketCopyWithImpl(this._self, this._then);

  final _PlayoffBracket _self;
  final $Res Function(_PlayoffBracket) _then;

/// Create a copy of PlayoffBracket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conference = null,Object? quarterFinals = null,Object? semiFinals = null,Object? conferenceFinal = null,Object? leagueFinal = freezed,}) {
  return _then(_PlayoffBracket(
conference: null == conference ? _self.conference : conference // ignore: cast_nullable_to_non_nullable
as Conference,quarterFinals: null == quarterFinals ? _self._quarterFinals : quarterFinals // ignore: cast_nullable_to_non_nullable
as List<PlayoffSeries>,semiFinals: null == semiFinals ? _self._semiFinals : semiFinals // ignore: cast_nullable_to_non_nullable
as List<PlayoffSeries>,conferenceFinal: null == conferenceFinal ? _self._conferenceFinal : conferenceFinal // ignore: cast_nullable_to_non_nullable
as List<PlayoffSeries>,leagueFinal: freezed == leagueFinal ? _self.leagueFinal : leagueFinal // ignore: cast_nullable_to_non_nullable
as PlayoffSeries?,
  ));
}

/// Create a copy of PlayoffBracket
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayoffSeriesCopyWith<$Res>? get leagueFinal {
    if (_self.leagueFinal == null) {
    return null;
  }

  return $PlayoffSeriesCopyWith<$Res>(_self.leagueFinal!, (value) {
    return _then(_self.copyWith(leagueFinal: value));
  });
}
}

// dart format on
