// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draft_class.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DraftClass {

 int get year; List<Prospect> get prospects;
/// Create a copy of DraftClass
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftClassCopyWith<DraftClass> get copyWith => _$DraftClassCopyWithImpl<DraftClass>(this as DraftClass, _$identity);

  /// Serializes this DraftClass to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DraftClass&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other.prospects, prospects));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,const DeepCollectionEquality().hash(prospects));

@override
String toString() {
  return 'DraftClass(year: $year, prospects: $prospects)';
}


}

/// @nodoc
abstract mixin class $DraftClassCopyWith<$Res>  {
  factory $DraftClassCopyWith(DraftClass value, $Res Function(DraftClass) _then) = _$DraftClassCopyWithImpl;
@useResult
$Res call({
 int year, List<Prospect> prospects
});




}
/// @nodoc
class _$DraftClassCopyWithImpl<$Res>
    implements $DraftClassCopyWith<$Res> {
  _$DraftClassCopyWithImpl(this._self, this._then);

  final DraftClass _self;
  final $Res Function(DraftClass) _then;

/// Create a copy of DraftClass
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? prospects = null,}) {
  return _then(_self.copyWith(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,prospects: null == prospects ? _self.prospects : prospects // ignore: cast_nullable_to_non_nullable
as List<Prospect>,
  ));
}

}


/// Adds pattern-matching-related methods to [DraftClass].
extension DraftClassPatterns on DraftClass {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DraftClass value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DraftClass() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DraftClass value)  $default,){
final _that = this;
switch (_that) {
case _DraftClass():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DraftClass value)?  $default,){
final _that = this;
switch (_that) {
case _DraftClass() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  List<Prospect> prospects)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DraftClass() when $default != null:
return $default(_that.year,_that.prospects);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  List<Prospect> prospects)  $default,) {final _that = this;
switch (_that) {
case _DraftClass():
return $default(_that.year,_that.prospects);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  List<Prospect> prospects)?  $default,) {final _that = this;
switch (_that) {
case _DraftClass() when $default != null:
return $default(_that.year,_that.prospects);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DraftClass implements DraftClass {
  const _DraftClass({required this.year, final  List<Prospect> prospects = const []}): _prospects = prospects;
  factory _DraftClass.fromJson(Map<String, dynamic> json) => _$DraftClassFromJson(json);

@override final  int year;
 final  List<Prospect> _prospects;
@override@JsonKey() List<Prospect> get prospects {
  if (_prospects is EqualUnmodifiableListView) return _prospects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_prospects);
}


/// Create a copy of DraftClass
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftClassCopyWith<_DraftClass> get copyWith => __$DraftClassCopyWithImpl<_DraftClass>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DraftClassToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DraftClass&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other._prospects, _prospects));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,const DeepCollectionEquality().hash(_prospects));

@override
String toString() {
  return 'DraftClass(year: $year, prospects: $prospects)';
}


}

/// @nodoc
abstract mixin class _$DraftClassCopyWith<$Res> implements $DraftClassCopyWith<$Res> {
  factory _$DraftClassCopyWith(_DraftClass value, $Res Function(_DraftClass) _then) = __$DraftClassCopyWithImpl;
@override @useResult
$Res call({
 int year, List<Prospect> prospects
});




}
/// @nodoc
class __$DraftClassCopyWithImpl<$Res>
    implements _$DraftClassCopyWith<$Res> {
  __$DraftClassCopyWithImpl(this._self, this._then);

  final _DraftClass _self;
  final $Res Function(_DraftClass) _then;

/// Create a copy of DraftClass
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? prospects = null,}) {
  return _then(_DraftClass(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,prospects: null == prospects ? _self._prospects : prospects // ignore: cast_nullable_to_non_nullable
as List<Prospect>,
  ));
}


}


/// @nodoc
mixin _$MockDraftBoard {

 Map<String, int> get displayedRank; Map<String, int> get previousDisplayedRank;
/// Create a copy of MockDraftBoard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MockDraftBoardCopyWith<MockDraftBoard> get copyWith => _$MockDraftBoardCopyWithImpl<MockDraftBoard>(this as MockDraftBoard, _$identity);

  /// Serializes this MockDraftBoard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MockDraftBoard&&const DeepCollectionEquality().equals(other.displayedRank, displayedRank)&&const DeepCollectionEquality().equals(other.previousDisplayedRank, previousDisplayedRank));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(displayedRank),const DeepCollectionEquality().hash(previousDisplayedRank));

@override
String toString() {
  return 'MockDraftBoard(displayedRank: $displayedRank, previousDisplayedRank: $previousDisplayedRank)';
}


}

/// @nodoc
abstract mixin class $MockDraftBoardCopyWith<$Res>  {
  factory $MockDraftBoardCopyWith(MockDraftBoard value, $Res Function(MockDraftBoard) _then) = _$MockDraftBoardCopyWithImpl;
@useResult
$Res call({
 Map<String, int> displayedRank, Map<String, int> previousDisplayedRank
});




}
/// @nodoc
class _$MockDraftBoardCopyWithImpl<$Res>
    implements $MockDraftBoardCopyWith<$Res> {
  _$MockDraftBoardCopyWithImpl(this._self, this._then);

  final MockDraftBoard _self;
  final $Res Function(MockDraftBoard) _then;

/// Create a copy of MockDraftBoard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayedRank = null,Object? previousDisplayedRank = null,}) {
  return _then(_self.copyWith(
displayedRank: null == displayedRank ? _self.displayedRank : displayedRank // ignore: cast_nullable_to_non_nullable
as Map<String, int>,previousDisplayedRank: null == previousDisplayedRank ? _self.previousDisplayedRank : previousDisplayedRank // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [MockDraftBoard].
extension MockDraftBoardPatterns on MockDraftBoard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MockDraftBoard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MockDraftBoard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MockDraftBoard value)  $default,){
final _that = this;
switch (_that) {
case _MockDraftBoard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MockDraftBoard value)?  $default,){
final _that = this;
switch (_that) {
case _MockDraftBoard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, int> displayedRank,  Map<String, int> previousDisplayedRank)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MockDraftBoard() when $default != null:
return $default(_that.displayedRank,_that.previousDisplayedRank);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, int> displayedRank,  Map<String, int> previousDisplayedRank)  $default,) {final _that = this;
switch (_that) {
case _MockDraftBoard():
return $default(_that.displayedRank,_that.previousDisplayedRank);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, int> displayedRank,  Map<String, int> previousDisplayedRank)?  $default,) {final _that = this;
switch (_that) {
case _MockDraftBoard() when $default != null:
return $default(_that.displayedRank,_that.previousDisplayedRank);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MockDraftBoard implements MockDraftBoard {
  const _MockDraftBoard({final  Map<String, int> displayedRank = const {}, final  Map<String, int> previousDisplayedRank = const {}}): _displayedRank = displayedRank,_previousDisplayedRank = previousDisplayedRank;
  factory _MockDraftBoard.fromJson(Map<String, dynamic> json) => _$MockDraftBoardFromJson(json);

 final  Map<String, int> _displayedRank;
@override@JsonKey() Map<String, int> get displayedRank {
  if (_displayedRank is EqualUnmodifiableMapView) return _displayedRank;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_displayedRank);
}

 final  Map<String, int> _previousDisplayedRank;
@override@JsonKey() Map<String, int> get previousDisplayedRank {
  if (_previousDisplayedRank is EqualUnmodifiableMapView) return _previousDisplayedRank;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_previousDisplayedRank);
}


/// Create a copy of MockDraftBoard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MockDraftBoardCopyWith<_MockDraftBoard> get copyWith => __$MockDraftBoardCopyWithImpl<_MockDraftBoard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MockDraftBoardToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MockDraftBoard&&const DeepCollectionEquality().equals(other._displayedRank, _displayedRank)&&const DeepCollectionEquality().equals(other._previousDisplayedRank, _previousDisplayedRank));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_displayedRank),const DeepCollectionEquality().hash(_previousDisplayedRank));

@override
String toString() {
  return 'MockDraftBoard(displayedRank: $displayedRank, previousDisplayedRank: $previousDisplayedRank)';
}


}

/// @nodoc
abstract mixin class _$MockDraftBoardCopyWith<$Res> implements $MockDraftBoardCopyWith<$Res> {
  factory _$MockDraftBoardCopyWith(_MockDraftBoard value, $Res Function(_MockDraftBoard) _then) = __$MockDraftBoardCopyWithImpl;
@override @useResult
$Res call({
 Map<String, int> displayedRank, Map<String, int> previousDisplayedRank
});




}
/// @nodoc
class __$MockDraftBoardCopyWithImpl<$Res>
    implements _$MockDraftBoardCopyWith<$Res> {
  __$MockDraftBoardCopyWithImpl(this._self, this._then);

  final _MockDraftBoard _self;
  final $Res Function(_MockDraftBoard) _then;

/// Create a copy of MockDraftBoard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayedRank = null,Object? previousDisplayedRank = null,}) {
  return _then(_MockDraftBoard(
displayedRank: null == displayedRank ? _self._displayedRank : displayedRank // ignore: cast_nullable_to_non_nullable
as Map<String, int>,previousDisplayedRank: null == previousDisplayedRank ? _self._previousDisplayedRank : previousDisplayedRank // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}

// dart format on
