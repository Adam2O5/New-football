// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draft_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DraftState {

 int get year; List<DraftPick> get order; List<DraftPick> get completedPicks; List<LotteryResult> get lotteryResults; DraftClass get draftClass; int get currentPickIndex;/// Bieżący displayed board (mock wstępny do piątku tyg. 45, potem mock
/// finalny). `null` tylko w testach/legacy save'ach sprzed tej funkcji —
/// produkcyjnie ustawiany razem z `draftClass` w `ProspectService`.
 MockDraftBoard? get mockDraftBoard;
/// Create a copy of DraftState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftStateCopyWith<DraftState> get copyWith => _$DraftStateCopyWithImpl<DraftState>(this as DraftState, _$identity);

  /// Serializes this DraftState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DraftState&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other.order, order)&&const DeepCollectionEquality().equals(other.completedPicks, completedPicks)&&const DeepCollectionEquality().equals(other.lotteryResults, lotteryResults)&&(identical(other.draftClass, draftClass) || other.draftClass == draftClass)&&(identical(other.currentPickIndex, currentPickIndex) || other.currentPickIndex == currentPickIndex)&&(identical(other.mockDraftBoard, mockDraftBoard) || other.mockDraftBoard == mockDraftBoard));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,const DeepCollectionEquality().hash(order),const DeepCollectionEquality().hash(completedPicks),const DeepCollectionEquality().hash(lotteryResults),draftClass,currentPickIndex,mockDraftBoard);

@override
String toString() {
  return 'DraftState(year: $year, order: $order, completedPicks: $completedPicks, lotteryResults: $lotteryResults, draftClass: $draftClass, currentPickIndex: $currentPickIndex, mockDraftBoard: $mockDraftBoard)';
}


}

/// @nodoc
abstract mixin class $DraftStateCopyWith<$Res>  {
  factory $DraftStateCopyWith(DraftState value, $Res Function(DraftState) _then) = _$DraftStateCopyWithImpl;
@useResult
$Res call({
 int year, List<DraftPick> order, List<DraftPick> completedPicks, List<LotteryResult> lotteryResults, DraftClass draftClass, int currentPickIndex, MockDraftBoard? mockDraftBoard
});


$DraftClassCopyWith<$Res> get draftClass;$MockDraftBoardCopyWith<$Res>? get mockDraftBoard;

}
/// @nodoc
class _$DraftStateCopyWithImpl<$Res>
    implements $DraftStateCopyWith<$Res> {
  _$DraftStateCopyWithImpl(this._self, this._then);

  final DraftState _self;
  final $Res Function(DraftState) _then;

/// Create a copy of DraftState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? order = null,Object? completedPicks = null,Object? lotteryResults = null,Object? draftClass = null,Object? currentPickIndex = null,Object? mockDraftBoard = freezed,}) {
  return _then(_self.copyWith(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as List<DraftPick>,completedPicks: null == completedPicks ? _self.completedPicks : completedPicks // ignore: cast_nullable_to_non_nullable
as List<DraftPick>,lotteryResults: null == lotteryResults ? _self.lotteryResults : lotteryResults // ignore: cast_nullable_to_non_nullable
as List<LotteryResult>,draftClass: null == draftClass ? _self.draftClass : draftClass // ignore: cast_nullable_to_non_nullable
as DraftClass,currentPickIndex: null == currentPickIndex ? _self.currentPickIndex : currentPickIndex // ignore: cast_nullable_to_non_nullable
as int,mockDraftBoard: freezed == mockDraftBoard ? _self.mockDraftBoard : mockDraftBoard // ignore: cast_nullable_to_non_nullable
as MockDraftBoard?,
  ));
}
/// Create a copy of DraftState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DraftClassCopyWith<$Res> get draftClass {
  
  return $DraftClassCopyWith<$Res>(_self.draftClass, (value) {
    return _then(_self.copyWith(draftClass: value));
  });
}/// Create a copy of DraftState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MockDraftBoardCopyWith<$Res>? get mockDraftBoard {
    if (_self.mockDraftBoard == null) {
    return null;
  }

  return $MockDraftBoardCopyWith<$Res>(_self.mockDraftBoard!, (value) {
    return _then(_self.copyWith(mockDraftBoard: value));
  });
}
}


/// Adds pattern-matching-related methods to [DraftState].
extension DraftStatePatterns on DraftState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DraftState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DraftState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DraftState value)  $default,){
final _that = this;
switch (_that) {
case _DraftState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DraftState value)?  $default,){
final _that = this;
switch (_that) {
case _DraftState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  List<DraftPick> order,  List<DraftPick> completedPicks,  List<LotteryResult> lotteryResults,  DraftClass draftClass,  int currentPickIndex,  MockDraftBoard? mockDraftBoard)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DraftState() when $default != null:
return $default(_that.year,_that.order,_that.completedPicks,_that.lotteryResults,_that.draftClass,_that.currentPickIndex,_that.mockDraftBoard);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  List<DraftPick> order,  List<DraftPick> completedPicks,  List<LotteryResult> lotteryResults,  DraftClass draftClass,  int currentPickIndex,  MockDraftBoard? mockDraftBoard)  $default,) {final _that = this;
switch (_that) {
case _DraftState():
return $default(_that.year,_that.order,_that.completedPicks,_that.lotteryResults,_that.draftClass,_that.currentPickIndex,_that.mockDraftBoard);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  List<DraftPick> order,  List<DraftPick> completedPicks,  List<LotteryResult> lotteryResults,  DraftClass draftClass,  int currentPickIndex,  MockDraftBoard? mockDraftBoard)?  $default,) {final _that = this;
switch (_that) {
case _DraftState() when $default != null:
return $default(_that.year,_that.order,_that.completedPicks,_that.lotteryResults,_that.draftClass,_that.currentPickIndex,_that.mockDraftBoard);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DraftState implements DraftState {
  const _DraftState({required this.year, final  List<DraftPick> order = const [], final  List<DraftPick> completedPicks = const [], final  List<LotteryResult> lotteryResults = const [], required this.draftClass, this.currentPickIndex = 0, this.mockDraftBoard}): _order = order,_completedPicks = completedPicks,_lotteryResults = lotteryResults;
  factory _DraftState.fromJson(Map<String, dynamic> json) => _$DraftStateFromJson(json);

@override final  int year;
 final  List<DraftPick> _order;
@override@JsonKey() List<DraftPick> get order {
  if (_order is EqualUnmodifiableListView) return _order;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_order);
}

 final  List<DraftPick> _completedPicks;
@override@JsonKey() List<DraftPick> get completedPicks {
  if (_completedPicks is EqualUnmodifiableListView) return _completedPicks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_completedPicks);
}

 final  List<LotteryResult> _lotteryResults;
@override@JsonKey() List<LotteryResult> get lotteryResults {
  if (_lotteryResults is EqualUnmodifiableListView) return _lotteryResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lotteryResults);
}

@override final  DraftClass draftClass;
@override@JsonKey() final  int currentPickIndex;
/// Bieżący displayed board (mock wstępny do piątku tyg. 45, potem mock
/// finalny). `null` tylko w testach/legacy save'ach sprzed tej funkcji —
/// produkcyjnie ustawiany razem z `draftClass` w `ProspectService`.
@override final  MockDraftBoard? mockDraftBoard;

/// Create a copy of DraftState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftStateCopyWith<_DraftState> get copyWith => __$DraftStateCopyWithImpl<_DraftState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DraftStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DraftState&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other._order, _order)&&const DeepCollectionEquality().equals(other._completedPicks, _completedPicks)&&const DeepCollectionEquality().equals(other._lotteryResults, _lotteryResults)&&(identical(other.draftClass, draftClass) || other.draftClass == draftClass)&&(identical(other.currentPickIndex, currentPickIndex) || other.currentPickIndex == currentPickIndex)&&(identical(other.mockDraftBoard, mockDraftBoard) || other.mockDraftBoard == mockDraftBoard));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,const DeepCollectionEquality().hash(_order),const DeepCollectionEquality().hash(_completedPicks),const DeepCollectionEquality().hash(_lotteryResults),draftClass,currentPickIndex,mockDraftBoard);

@override
String toString() {
  return 'DraftState(year: $year, order: $order, completedPicks: $completedPicks, lotteryResults: $lotteryResults, draftClass: $draftClass, currentPickIndex: $currentPickIndex, mockDraftBoard: $mockDraftBoard)';
}


}

/// @nodoc
abstract mixin class _$DraftStateCopyWith<$Res> implements $DraftStateCopyWith<$Res> {
  factory _$DraftStateCopyWith(_DraftState value, $Res Function(_DraftState) _then) = __$DraftStateCopyWithImpl;
@override @useResult
$Res call({
 int year, List<DraftPick> order, List<DraftPick> completedPicks, List<LotteryResult> lotteryResults, DraftClass draftClass, int currentPickIndex, MockDraftBoard? mockDraftBoard
});


@override $DraftClassCopyWith<$Res> get draftClass;@override $MockDraftBoardCopyWith<$Res>? get mockDraftBoard;

}
/// @nodoc
class __$DraftStateCopyWithImpl<$Res>
    implements _$DraftStateCopyWith<$Res> {
  __$DraftStateCopyWithImpl(this._self, this._then);

  final _DraftState _self;
  final $Res Function(_DraftState) _then;

/// Create a copy of DraftState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? order = null,Object? completedPicks = null,Object? lotteryResults = null,Object? draftClass = null,Object? currentPickIndex = null,Object? mockDraftBoard = freezed,}) {
  return _then(_DraftState(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,order: null == order ? _self._order : order // ignore: cast_nullable_to_non_nullable
as List<DraftPick>,completedPicks: null == completedPicks ? _self._completedPicks : completedPicks // ignore: cast_nullable_to_non_nullable
as List<DraftPick>,lotteryResults: null == lotteryResults ? _self._lotteryResults : lotteryResults // ignore: cast_nullable_to_non_nullable
as List<LotteryResult>,draftClass: null == draftClass ? _self.draftClass : draftClass // ignore: cast_nullable_to_non_nullable
as DraftClass,currentPickIndex: null == currentPickIndex ? _self.currentPickIndex : currentPickIndex // ignore: cast_nullable_to_non_nullable
as int,mockDraftBoard: freezed == mockDraftBoard ? _self.mockDraftBoard : mockDraftBoard // ignore: cast_nullable_to_non_nullable
as MockDraftBoard?,
  ));
}

/// Create a copy of DraftState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DraftClassCopyWith<$Res> get draftClass {
  
  return $DraftClassCopyWith<$Res>(_self.draftClass, (value) {
    return _then(_self.copyWith(draftClass: value));
  });
}/// Create a copy of DraftState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MockDraftBoardCopyWith<$Res>? get mockDraftBoard {
    if (_self.mockDraftBoard == null) {
    return null;
  }

  return $MockDraftBoardCopyWith<$Res>(_self.mockDraftBoard!, (value) {
    return _then(_self.copyWith(mockDraftBoard: value));
  });
}
}


/// @nodoc
mixin _$CompletedDraft {

 int get year; List<DraftPick> get completedPicks;
/// Create a copy of CompletedDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompletedDraftCopyWith<CompletedDraft> get copyWith => _$CompletedDraftCopyWithImpl<CompletedDraft>(this as CompletedDraft, _$identity);

  /// Serializes this CompletedDraft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompletedDraft&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other.completedPicks, completedPicks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,const DeepCollectionEquality().hash(completedPicks));

@override
String toString() {
  return 'CompletedDraft(year: $year, completedPicks: $completedPicks)';
}


}

/// @nodoc
abstract mixin class $CompletedDraftCopyWith<$Res>  {
  factory $CompletedDraftCopyWith(CompletedDraft value, $Res Function(CompletedDraft) _then) = _$CompletedDraftCopyWithImpl;
@useResult
$Res call({
 int year, List<DraftPick> completedPicks
});




}
/// @nodoc
class _$CompletedDraftCopyWithImpl<$Res>
    implements $CompletedDraftCopyWith<$Res> {
  _$CompletedDraftCopyWithImpl(this._self, this._then);

  final CompletedDraft _self;
  final $Res Function(CompletedDraft) _then;

/// Create a copy of CompletedDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? completedPicks = null,}) {
  return _then(_self.copyWith(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,completedPicks: null == completedPicks ? _self.completedPicks : completedPicks // ignore: cast_nullable_to_non_nullable
as List<DraftPick>,
  ));
}

}


/// Adds pattern-matching-related methods to [CompletedDraft].
extension CompletedDraftPatterns on CompletedDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompletedDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompletedDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompletedDraft value)  $default,){
final _that = this;
switch (_that) {
case _CompletedDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompletedDraft value)?  $default,){
final _that = this;
switch (_that) {
case _CompletedDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  List<DraftPick> completedPicks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompletedDraft() when $default != null:
return $default(_that.year,_that.completedPicks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  List<DraftPick> completedPicks)  $default,) {final _that = this;
switch (_that) {
case _CompletedDraft():
return $default(_that.year,_that.completedPicks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  List<DraftPick> completedPicks)?  $default,) {final _that = this;
switch (_that) {
case _CompletedDraft() when $default != null:
return $default(_that.year,_that.completedPicks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompletedDraft implements CompletedDraft {
  const _CompletedDraft({required this.year, final  List<DraftPick> completedPicks = const []}): _completedPicks = completedPicks;
  factory _CompletedDraft.fromJson(Map<String, dynamic> json) => _$CompletedDraftFromJson(json);

@override final  int year;
 final  List<DraftPick> _completedPicks;
@override@JsonKey() List<DraftPick> get completedPicks {
  if (_completedPicks is EqualUnmodifiableListView) return _completedPicks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_completedPicks);
}


/// Create a copy of CompletedDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompletedDraftCopyWith<_CompletedDraft> get copyWith => __$CompletedDraftCopyWithImpl<_CompletedDraft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompletedDraftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompletedDraft&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other._completedPicks, _completedPicks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,const DeepCollectionEquality().hash(_completedPicks));

@override
String toString() {
  return 'CompletedDraft(year: $year, completedPicks: $completedPicks)';
}


}

/// @nodoc
abstract mixin class _$CompletedDraftCopyWith<$Res> implements $CompletedDraftCopyWith<$Res> {
  factory _$CompletedDraftCopyWith(_CompletedDraft value, $Res Function(_CompletedDraft) _then) = __$CompletedDraftCopyWithImpl;
@override @useResult
$Res call({
 int year, List<DraftPick> completedPicks
});




}
/// @nodoc
class __$CompletedDraftCopyWithImpl<$Res>
    implements _$CompletedDraftCopyWith<$Res> {
  __$CompletedDraftCopyWithImpl(this._self, this._then);

  final _CompletedDraft _self;
  final $Res Function(_CompletedDraft) _then;

/// Create a copy of CompletedDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? completedPicks = null,}) {
  return _then(_CompletedDraft(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,completedPicks: null == completedPicks ? _self._completedPicks : completedPicks // ignore: cast_nullable_to_non_nullable
as List<DraftPick>,
  ));
}


}

// dart format on
