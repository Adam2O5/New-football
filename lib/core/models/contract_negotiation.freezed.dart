// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contract_negotiation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NegotiationOffer {

 int get salary; int get years; CapExceptionType? get exception; int? get rookiePickSlot;
/// Create a copy of NegotiationOffer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NegotiationOfferCopyWith<NegotiationOffer> get copyWith => _$NegotiationOfferCopyWithImpl<NegotiationOffer>(this as NegotiationOffer, _$identity);

  /// Serializes this NegotiationOffer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NegotiationOffer&&(identical(other.salary, salary) || other.salary == salary)&&(identical(other.years, years) || other.years == years)&&(identical(other.exception, exception) || other.exception == exception)&&(identical(other.rookiePickSlot, rookiePickSlot) || other.rookiePickSlot == rookiePickSlot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,salary,years,exception,rookiePickSlot);

@override
String toString() {
  return 'NegotiationOffer(salary: $salary, years: $years, exception: $exception, rookiePickSlot: $rookiePickSlot)';
}


}

/// @nodoc
abstract mixin class $NegotiationOfferCopyWith<$Res>  {
  factory $NegotiationOfferCopyWith(NegotiationOffer value, $Res Function(NegotiationOffer) _then) = _$NegotiationOfferCopyWithImpl;
@useResult
$Res call({
 int salary, int years, CapExceptionType? exception, int? rookiePickSlot
});




}
/// @nodoc
class _$NegotiationOfferCopyWithImpl<$Res>
    implements $NegotiationOfferCopyWith<$Res> {
  _$NegotiationOfferCopyWithImpl(this._self, this._then);

  final NegotiationOffer _self;
  final $Res Function(NegotiationOffer) _then;

/// Create a copy of NegotiationOffer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? salary = null,Object? years = null,Object? exception = freezed,Object? rookiePickSlot = freezed,}) {
  return _then(_self.copyWith(
salary: null == salary ? _self.salary : salary // ignore: cast_nullable_to_non_nullable
as int,years: null == years ? _self.years : years // ignore: cast_nullable_to_non_nullable
as int,exception: freezed == exception ? _self.exception : exception // ignore: cast_nullable_to_non_nullable
as CapExceptionType?,rookiePickSlot: freezed == rookiePickSlot ? _self.rookiePickSlot : rookiePickSlot // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [NegotiationOffer].
extension NegotiationOfferPatterns on NegotiationOffer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NegotiationOffer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NegotiationOffer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NegotiationOffer value)  $default,){
final _that = this;
switch (_that) {
case _NegotiationOffer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NegotiationOffer value)?  $default,){
final _that = this;
switch (_that) {
case _NegotiationOffer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int salary,  int years,  CapExceptionType? exception,  int? rookiePickSlot)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NegotiationOffer() when $default != null:
return $default(_that.salary,_that.years,_that.exception,_that.rookiePickSlot);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int salary,  int years,  CapExceptionType? exception,  int? rookiePickSlot)  $default,) {final _that = this;
switch (_that) {
case _NegotiationOffer():
return $default(_that.salary,_that.years,_that.exception,_that.rookiePickSlot);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int salary,  int years,  CapExceptionType? exception,  int? rookiePickSlot)?  $default,) {final _that = this;
switch (_that) {
case _NegotiationOffer() when $default != null:
return $default(_that.salary,_that.years,_that.exception,_that.rookiePickSlot);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NegotiationOffer implements NegotiationOffer {
  const _NegotiationOffer({required this.salary, required this.years, this.exception, this.rookiePickSlot});
  factory _NegotiationOffer.fromJson(Map<String, dynamic> json) => _$NegotiationOfferFromJson(json);

@override final  int salary;
@override final  int years;
@override final  CapExceptionType? exception;
@override final  int? rookiePickSlot;

/// Create a copy of NegotiationOffer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NegotiationOfferCopyWith<_NegotiationOffer> get copyWith => __$NegotiationOfferCopyWithImpl<_NegotiationOffer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NegotiationOfferToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NegotiationOffer&&(identical(other.salary, salary) || other.salary == salary)&&(identical(other.years, years) || other.years == years)&&(identical(other.exception, exception) || other.exception == exception)&&(identical(other.rookiePickSlot, rookiePickSlot) || other.rookiePickSlot == rookiePickSlot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,salary,years,exception,rookiePickSlot);

@override
String toString() {
  return 'NegotiationOffer(salary: $salary, years: $years, exception: $exception, rookiePickSlot: $rookiePickSlot)';
}


}

/// @nodoc
abstract mixin class _$NegotiationOfferCopyWith<$Res> implements $NegotiationOfferCopyWith<$Res> {
  factory _$NegotiationOfferCopyWith(_NegotiationOffer value, $Res Function(_NegotiationOffer) _then) = __$NegotiationOfferCopyWithImpl;
@override @useResult
$Res call({
 int salary, int years, CapExceptionType? exception, int? rookiePickSlot
});




}
/// @nodoc
class __$NegotiationOfferCopyWithImpl<$Res>
    implements _$NegotiationOfferCopyWith<$Res> {
  __$NegotiationOfferCopyWithImpl(this._self, this._then);

  final _NegotiationOffer _self;
  final $Res Function(_NegotiationOffer) _then;

/// Create a copy of NegotiationOffer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? salary = null,Object? years = null,Object? exception = freezed,Object? rookiePickSlot = freezed,}) {
  return _then(_NegotiationOffer(
salary: null == salary ? _self.salary : salary // ignore: cast_nullable_to_non_nullable
as int,years: null == years ? _self.years : years // ignore: cast_nullable_to_non_nullable
as int,exception: freezed == exception ? _self.exception : exception // ignore: cast_nullable_to_non_nullable
as CapExceptionType?,rookiePickSlot: freezed == rookiePickSlot ? _self.rookiePickSlot : rookiePickSlot // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$ContractNegotiation {

 String get id; String get subjectId; NegotiationSubjectKind get subjectKind; String get teamId; NegotiationPhase get phase; int get round; NegotiationOffer get lastOffer; NegotiationOffer? get counterOffer; NegotiationStatus get status; int get seasonYear; int get week; int get day; int get hour; int get expirySeasonYear; int get expiryWeek; int get expiryDay; int get expiryHour; bool get requiresFinalization; bool get selectedByRival; bool get rivalFinalized;/// Score used by the central market resolver to rank simultaneous bids.
 double get offerScore;/// AI bids are finalized automatically when they win a market slot;
/// player-controlled bids remain pending until the user confirms them.
 bool get isAiOffer;/// Waiting is a persisted timer rather than an implicit UI state. The
/// nullable date fields keep the timer correct across a day boundary.
 int? get waitingUntilSeasonYear; int? get waitingUntilWeek; int? get waitingUntilDay; int? get waitingUntilHour;
/// Create a copy of ContractNegotiation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContractNegotiationCopyWith<ContractNegotiation> get copyWith => _$ContractNegotiationCopyWithImpl<ContractNegotiation>(this as ContractNegotiation, _$identity);

  /// Serializes this ContractNegotiation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContractNegotiation&&(identical(other.id, id) || other.id == id)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.subjectKind, subjectKind) || other.subjectKind == subjectKind)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.round, round) || other.round == round)&&(identical(other.lastOffer, lastOffer) || other.lastOffer == lastOffer)&&(identical(other.counterOffer, counterOffer) || other.counterOffer == counterOffer)&&(identical(other.status, status) || other.status == status)&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear)&&(identical(other.week, week) || other.week == week)&&(identical(other.day, day) || other.day == day)&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.expirySeasonYear, expirySeasonYear) || other.expirySeasonYear == expirySeasonYear)&&(identical(other.expiryWeek, expiryWeek) || other.expiryWeek == expiryWeek)&&(identical(other.expiryDay, expiryDay) || other.expiryDay == expiryDay)&&(identical(other.expiryHour, expiryHour) || other.expiryHour == expiryHour)&&(identical(other.requiresFinalization, requiresFinalization) || other.requiresFinalization == requiresFinalization)&&(identical(other.selectedByRival, selectedByRival) || other.selectedByRival == selectedByRival)&&(identical(other.rivalFinalized, rivalFinalized) || other.rivalFinalized == rivalFinalized)&&(identical(other.offerScore, offerScore) || other.offerScore == offerScore)&&(identical(other.isAiOffer, isAiOffer) || other.isAiOffer == isAiOffer)&&(identical(other.waitingUntilSeasonYear, waitingUntilSeasonYear) || other.waitingUntilSeasonYear == waitingUntilSeasonYear)&&(identical(other.waitingUntilWeek, waitingUntilWeek) || other.waitingUntilWeek == waitingUntilWeek)&&(identical(other.waitingUntilDay, waitingUntilDay) || other.waitingUntilDay == waitingUntilDay)&&(identical(other.waitingUntilHour, waitingUntilHour) || other.waitingUntilHour == waitingUntilHour));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,subjectId,subjectKind,teamId,phase,round,lastOffer,counterOffer,status,seasonYear,week,day,hour,expirySeasonYear,expiryWeek,expiryDay,expiryHour,requiresFinalization,selectedByRival,rivalFinalized,offerScore,isAiOffer,waitingUntilSeasonYear,waitingUntilWeek,waitingUntilDay,waitingUntilHour]);

@override
String toString() {
  return 'ContractNegotiation(id: $id, subjectId: $subjectId, subjectKind: $subjectKind, teamId: $teamId, phase: $phase, round: $round, lastOffer: $lastOffer, counterOffer: $counterOffer, status: $status, seasonYear: $seasonYear, week: $week, day: $day, hour: $hour, expirySeasonYear: $expirySeasonYear, expiryWeek: $expiryWeek, expiryDay: $expiryDay, expiryHour: $expiryHour, requiresFinalization: $requiresFinalization, selectedByRival: $selectedByRival, rivalFinalized: $rivalFinalized, offerScore: $offerScore, isAiOffer: $isAiOffer, waitingUntilSeasonYear: $waitingUntilSeasonYear, waitingUntilWeek: $waitingUntilWeek, waitingUntilDay: $waitingUntilDay, waitingUntilHour: $waitingUntilHour)';
}


}

/// @nodoc
abstract mixin class $ContractNegotiationCopyWith<$Res>  {
  factory $ContractNegotiationCopyWith(ContractNegotiation value, $Res Function(ContractNegotiation) _then) = _$ContractNegotiationCopyWithImpl;
@useResult
$Res call({
 String id, String subjectId, NegotiationSubjectKind subjectKind, String teamId, NegotiationPhase phase, int round, NegotiationOffer lastOffer, NegotiationOffer? counterOffer, NegotiationStatus status, int seasonYear, int week, int day, int hour, int expirySeasonYear, int expiryWeek, int expiryDay, int expiryHour, bool requiresFinalization, bool selectedByRival, bool rivalFinalized, double offerScore, bool isAiOffer, int? waitingUntilSeasonYear, int? waitingUntilWeek, int? waitingUntilDay, int? waitingUntilHour
});


$NegotiationOfferCopyWith<$Res> get lastOffer;$NegotiationOfferCopyWith<$Res>? get counterOffer;

}
/// @nodoc
class _$ContractNegotiationCopyWithImpl<$Res>
    implements $ContractNegotiationCopyWith<$Res> {
  _$ContractNegotiationCopyWithImpl(this._self, this._then);

  final ContractNegotiation _self;
  final $Res Function(ContractNegotiation) _then;

/// Create a copy of ContractNegotiation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? subjectId = null,Object? subjectKind = null,Object? teamId = null,Object? phase = null,Object? round = null,Object? lastOffer = null,Object? counterOffer = freezed,Object? status = null,Object? seasonYear = null,Object? week = null,Object? day = null,Object? hour = null,Object? expirySeasonYear = null,Object? expiryWeek = null,Object? expiryDay = null,Object? expiryHour = null,Object? requiresFinalization = null,Object? selectedByRival = null,Object? rivalFinalized = null,Object? offerScore = null,Object? isAiOffer = null,Object? waitingUntilSeasonYear = freezed,Object? waitingUntilWeek = freezed,Object? waitingUntilDay = freezed,Object? waitingUntilHour = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,subjectKind: null == subjectKind ? _self.subjectKind : subjectKind // ignore: cast_nullable_to_non_nullable
as NegotiationSubjectKind,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as NegotiationPhase,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as int,lastOffer: null == lastOffer ? _self.lastOffer : lastOffer // ignore: cast_nullable_to_non_nullable
as NegotiationOffer,counterOffer: freezed == counterOffer ? _self.counterOffer : counterOffer // ignore: cast_nullable_to_non_nullable
as NegotiationOffer?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NegotiationStatus,seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,week: null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as int,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,expirySeasonYear: null == expirySeasonYear ? _self.expirySeasonYear : expirySeasonYear // ignore: cast_nullable_to_non_nullable
as int,expiryWeek: null == expiryWeek ? _self.expiryWeek : expiryWeek // ignore: cast_nullable_to_non_nullable
as int,expiryDay: null == expiryDay ? _self.expiryDay : expiryDay // ignore: cast_nullable_to_non_nullable
as int,expiryHour: null == expiryHour ? _self.expiryHour : expiryHour // ignore: cast_nullable_to_non_nullable
as int,requiresFinalization: null == requiresFinalization ? _self.requiresFinalization : requiresFinalization // ignore: cast_nullable_to_non_nullable
as bool,selectedByRival: null == selectedByRival ? _self.selectedByRival : selectedByRival // ignore: cast_nullable_to_non_nullable
as bool,rivalFinalized: null == rivalFinalized ? _self.rivalFinalized : rivalFinalized // ignore: cast_nullable_to_non_nullable
as bool,offerScore: null == offerScore ? _self.offerScore : offerScore // ignore: cast_nullable_to_non_nullable
as double,isAiOffer: null == isAiOffer ? _self.isAiOffer : isAiOffer // ignore: cast_nullable_to_non_nullable
as bool,waitingUntilSeasonYear: freezed == waitingUntilSeasonYear ? _self.waitingUntilSeasonYear : waitingUntilSeasonYear // ignore: cast_nullable_to_non_nullable
as int?,waitingUntilWeek: freezed == waitingUntilWeek ? _self.waitingUntilWeek : waitingUntilWeek // ignore: cast_nullable_to_non_nullable
as int?,waitingUntilDay: freezed == waitingUntilDay ? _self.waitingUntilDay : waitingUntilDay // ignore: cast_nullable_to_non_nullable
as int?,waitingUntilHour: freezed == waitingUntilHour ? _self.waitingUntilHour : waitingUntilHour // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of ContractNegotiation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NegotiationOfferCopyWith<$Res> get lastOffer {
  
  return $NegotiationOfferCopyWith<$Res>(_self.lastOffer, (value) {
    return _then(_self.copyWith(lastOffer: value));
  });
}/// Create a copy of ContractNegotiation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NegotiationOfferCopyWith<$Res>? get counterOffer {
    if (_self.counterOffer == null) {
    return null;
  }

  return $NegotiationOfferCopyWith<$Res>(_self.counterOffer!, (value) {
    return _then(_self.copyWith(counterOffer: value));
  });
}
}


/// Adds pattern-matching-related methods to [ContractNegotiation].
extension ContractNegotiationPatterns on ContractNegotiation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContractNegotiation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContractNegotiation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContractNegotiation value)  $default,){
final _that = this;
switch (_that) {
case _ContractNegotiation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContractNegotiation value)?  $default,){
final _that = this;
switch (_that) {
case _ContractNegotiation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String subjectId,  NegotiationSubjectKind subjectKind,  String teamId,  NegotiationPhase phase,  int round,  NegotiationOffer lastOffer,  NegotiationOffer? counterOffer,  NegotiationStatus status,  int seasonYear,  int week,  int day,  int hour,  int expirySeasonYear,  int expiryWeek,  int expiryDay,  int expiryHour,  bool requiresFinalization,  bool selectedByRival,  bool rivalFinalized,  double offerScore,  bool isAiOffer,  int? waitingUntilSeasonYear,  int? waitingUntilWeek,  int? waitingUntilDay,  int? waitingUntilHour)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContractNegotiation() when $default != null:
return $default(_that.id,_that.subjectId,_that.subjectKind,_that.teamId,_that.phase,_that.round,_that.lastOffer,_that.counterOffer,_that.status,_that.seasonYear,_that.week,_that.day,_that.hour,_that.expirySeasonYear,_that.expiryWeek,_that.expiryDay,_that.expiryHour,_that.requiresFinalization,_that.selectedByRival,_that.rivalFinalized,_that.offerScore,_that.isAiOffer,_that.waitingUntilSeasonYear,_that.waitingUntilWeek,_that.waitingUntilDay,_that.waitingUntilHour);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String subjectId,  NegotiationSubjectKind subjectKind,  String teamId,  NegotiationPhase phase,  int round,  NegotiationOffer lastOffer,  NegotiationOffer? counterOffer,  NegotiationStatus status,  int seasonYear,  int week,  int day,  int hour,  int expirySeasonYear,  int expiryWeek,  int expiryDay,  int expiryHour,  bool requiresFinalization,  bool selectedByRival,  bool rivalFinalized,  double offerScore,  bool isAiOffer,  int? waitingUntilSeasonYear,  int? waitingUntilWeek,  int? waitingUntilDay,  int? waitingUntilHour)  $default,) {final _that = this;
switch (_that) {
case _ContractNegotiation():
return $default(_that.id,_that.subjectId,_that.subjectKind,_that.teamId,_that.phase,_that.round,_that.lastOffer,_that.counterOffer,_that.status,_that.seasonYear,_that.week,_that.day,_that.hour,_that.expirySeasonYear,_that.expiryWeek,_that.expiryDay,_that.expiryHour,_that.requiresFinalization,_that.selectedByRival,_that.rivalFinalized,_that.offerScore,_that.isAiOffer,_that.waitingUntilSeasonYear,_that.waitingUntilWeek,_that.waitingUntilDay,_that.waitingUntilHour);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String subjectId,  NegotiationSubjectKind subjectKind,  String teamId,  NegotiationPhase phase,  int round,  NegotiationOffer lastOffer,  NegotiationOffer? counterOffer,  NegotiationStatus status,  int seasonYear,  int week,  int day,  int hour,  int expirySeasonYear,  int expiryWeek,  int expiryDay,  int expiryHour,  bool requiresFinalization,  bool selectedByRival,  bool rivalFinalized,  double offerScore,  bool isAiOffer,  int? waitingUntilSeasonYear,  int? waitingUntilWeek,  int? waitingUntilDay,  int? waitingUntilHour)?  $default,) {final _that = this;
switch (_that) {
case _ContractNegotiation() when $default != null:
return $default(_that.id,_that.subjectId,_that.subjectKind,_that.teamId,_that.phase,_that.round,_that.lastOffer,_that.counterOffer,_that.status,_that.seasonYear,_that.week,_that.day,_that.hour,_that.expirySeasonYear,_that.expiryWeek,_that.expiryDay,_that.expiryHour,_that.requiresFinalization,_that.selectedByRival,_that.rivalFinalized,_that.offerScore,_that.isAiOffer,_that.waitingUntilSeasonYear,_that.waitingUntilWeek,_that.waitingUntilDay,_that.waitingUntilHour);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContractNegotiation implements ContractNegotiation {
  const _ContractNegotiation({required this.id, required this.subjectId, required this.subjectKind, required this.teamId, required this.phase, this.round = 1, required this.lastOffer, this.counterOffer, this.status = NegotiationStatus.active, required this.seasonYear, required this.week, this.day = 1, this.hour = 0, required this.expirySeasonYear, required this.expiryWeek, this.expiryDay = 1, this.expiryHour = 0, this.requiresFinalization = false, this.selectedByRival = false, this.rivalFinalized = false, this.offerScore = 0.0, this.isAiOffer = false, this.waitingUntilSeasonYear, this.waitingUntilWeek, this.waitingUntilDay, this.waitingUntilHour});
  factory _ContractNegotiation.fromJson(Map<String, dynamic> json) => _$ContractNegotiationFromJson(json);

@override final  String id;
@override final  String subjectId;
@override final  NegotiationSubjectKind subjectKind;
@override final  String teamId;
@override final  NegotiationPhase phase;
@override@JsonKey() final  int round;
@override final  NegotiationOffer lastOffer;
@override final  NegotiationOffer? counterOffer;
@override@JsonKey() final  NegotiationStatus status;
@override final  int seasonYear;
@override final  int week;
@override@JsonKey() final  int day;
@override@JsonKey() final  int hour;
@override final  int expirySeasonYear;
@override final  int expiryWeek;
@override@JsonKey() final  int expiryDay;
@override@JsonKey() final  int expiryHour;
@override@JsonKey() final  bool requiresFinalization;
@override@JsonKey() final  bool selectedByRival;
@override@JsonKey() final  bool rivalFinalized;
/// Score used by the central market resolver to rank simultaneous bids.
@override@JsonKey() final  double offerScore;
/// AI bids are finalized automatically when they win a market slot;
/// player-controlled bids remain pending until the user confirms them.
@override@JsonKey() final  bool isAiOffer;
/// Waiting is a persisted timer rather than an implicit UI state. The
/// nullable date fields keep the timer correct across a day boundary.
@override final  int? waitingUntilSeasonYear;
@override final  int? waitingUntilWeek;
@override final  int? waitingUntilDay;
@override final  int? waitingUntilHour;

/// Create a copy of ContractNegotiation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContractNegotiationCopyWith<_ContractNegotiation> get copyWith => __$ContractNegotiationCopyWithImpl<_ContractNegotiation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContractNegotiationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContractNegotiation&&(identical(other.id, id) || other.id == id)&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.subjectKind, subjectKind) || other.subjectKind == subjectKind)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.round, round) || other.round == round)&&(identical(other.lastOffer, lastOffer) || other.lastOffer == lastOffer)&&(identical(other.counterOffer, counterOffer) || other.counterOffer == counterOffer)&&(identical(other.status, status) || other.status == status)&&(identical(other.seasonYear, seasonYear) || other.seasonYear == seasonYear)&&(identical(other.week, week) || other.week == week)&&(identical(other.day, day) || other.day == day)&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.expirySeasonYear, expirySeasonYear) || other.expirySeasonYear == expirySeasonYear)&&(identical(other.expiryWeek, expiryWeek) || other.expiryWeek == expiryWeek)&&(identical(other.expiryDay, expiryDay) || other.expiryDay == expiryDay)&&(identical(other.expiryHour, expiryHour) || other.expiryHour == expiryHour)&&(identical(other.requiresFinalization, requiresFinalization) || other.requiresFinalization == requiresFinalization)&&(identical(other.selectedByRival, selectedByRival) || other.selectedByRival == selectedByRival)&&(identical(other.rivalFinalized, rivalFinalized) || other.rivalFinalized == rivalFinalized)&&(identical(other.offerScore, offerScore) || other.offerScore == offerScore)&&(identical(other.isAiOffer, isAiOffer) || other.isAiOffer == isAiOffer)&&(identical(other.waitingUntilSeasonYear, waitingUntilSeasonYear) || other.waitingUntilSeasonYear == waitingUntilSeasonYear)&&(identical(other.waitingUntilWeek, waitingUntilWeek) || other.waitingUntilWeek == waitingUntilWeek)&&(identical(other.waitingUntilDay, waitingUntilDay) || other.waitingUntilDay == waitingUntilDay)&&(identical(other.waitingUntilHour, waitingUntilHour) || other.waitingUntilHour == waitingUntilHour));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,subjectId,subjectKind,teamId,phase,round,lastOffer,counterOffer,status,seasonYear,week,day,hour,expirySeasonYear,expiryWeek,expiryDay,expiryHour,requiresFinalization,selectedByRival,rivalFinalized,offerScore,isAiOffer,waitingUntilSeasonYear,waitingUntilWeek,waitingUntilDay,waitingUntilHour]);

@override
String toString() {
  return 'ContractNegotiation(id: $id, subjectId: $subjectId, subjectKind: $subjectKind, teamId: $teamId, phase: $phase, round: $round, lastOffer: $lastOffer, counterOffer: $counterOffer, status: $status, seasonYear: $seasonYear, week: $week, day: $day, hour: $hour, expirySeasonYear: $expirySeasonYear, expiryWeek: $expiryWeek, expiryDay: $expiryDay, expiryHour: $expiryHour, requiresFinalization: $requiresFinalization, selectedByRival: $selectedByRival, rivalFinalized: $rivalFinalized, offerScore: $offerScore, isAiOffer: $isAiOffer, waitingUntilSeasonYear: $waitingUntilSeasonYear, waitingUntilWeek: $waitingUntilWeek, waitingUntilDay: $waitingUntilDay, waitingUntilHour: $waitingUntilHour)';
}


}

/// @nodoc
abstract mixin class _$ContractNegotiationCopyWith<$Res> implements $ContractNegotiationCopyWith<$Res> {
  factory _$ContractNegotiationCopyWith(_ContractNegotiation value, $Res Function(_ContractNegotiation) _then) = __$ContractNegotiationCopyWithImpl;
@override @useResult
$Res call({
 String id, String subjectId, NegotiationSubjectKind subjectKind, String teamId, NegotiationPhase phase, int round, NegotiationOffer lastOffer, NegotiationOffer? counterOffer, NegotiationStatus status, int seasonYear, int week, int day, int hour, int expirySeasonYear, int expiryWeek, int expiryDay, int expiryHour, bool requiresFinalization, bool selectedByRival, bool rivalFinalized, double offerScore, bool isAiOffer, int? waitingUntilSeasonYear, int? waitingUntilWeek, int? waitingUntilDay, int? waitingUntilHour
});


@override $NegotiationOfferCopyWith<$Res> get lastOffer;@override $NegotiationOfferCopyWith<$Res>? get counterOffer;

}
/// @nodoc
class __$ContractNegotiationCopyWithImpl<$Res>
    implements _$ContractNegotiationCopyWith<$Res> {
  __$ContractNegotiationCopyWithImpl(this._self, this._then);

  final _ContractNegotiation _self;
  final $Res Function(_ContractNegotiation) _then;

/// Create a copy of ContractNegotiation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? subjectId = null,Object? subjectKind = null,Object? teamId = null,Object? phase = null,Object? round = null,Object? lastOffer = null,Object? counterOffer = freezed,Object? status = null,Object? seasonYear = null,Object? week = null,Object? day = null,Object? hour = null,Object? expirySeasonYear = null,Object? expiryWeek = null,Object? expiryDay = null,Object? expiryHour = null,Object? requiresFinalization = null,Object? selectedByRival = null,Object? rivalFinalized = null,Object? offerScore = null,Object? isAiOffer = null,Object? waitingUntilSeasonYear = freezed,Object? waitingUntilWeek = freezed,Object? waitingUntilDay = freezed,Object? waitingUntilHour = freezed,}) {
  return _then(_ContractNegotiation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,subjectKind: null == subjectKind ? _self.subjectKind : subjectKind // ignore: cast_nullable_to_non_nullable
as NegotiationSubjectKind,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as NegotiationPhase,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as int,lastOffer: null == lastOffer ? _self.lastOffer : lastOffer // ignore: cast_nullable_to_non_nullable
as NegotiationOffer,counterOffer: freezed == counterOffer ? _self.counterOffer : counterOffer // ignore: cast_nullable_to_non_nullable
as NegotiationOffer?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NegotiationStatus,seasonYear: null == seasonYear ? _self.seasonYear : seasonYear // ignore: cast_nullable_to_non_nullable
as int,week: null == week ? _self.week : week // ignore: cast_nullable_to_non_nullable
as int,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,expirySeasonYear: null == expirySeasonYear ? _self.expirySeasonYear : expirySeasonYear // ignore: cast_nullable_to_non_nullable
as int,expiryWeek: null == expiryWeek ? _self.expiryWeek : expiryWeek // ignore: cast_nullable_to_non_nullable
as int,expiryDay: null == expiryDay ? _self.expiryDay : expiryDay // ignore: cast_nullable_to_non_nullable
as int,expiryHour: null == expiryHour ? _self.expiryHour : expiryHour // ignore: cast_nullable_to_non_nullable
as int,requiresFinalization: null == requiresFinalization ? _self.requiresFinalization : requiresFinalization // ignore: cast_nullable_to_non_nullable
as bool,selectedByRival: null == selectedByRival ? _self.selectedByRival : selectedByRival // ignore: cast_nullable_to_non_nullable
as bool,rivalFinalized: null == rivalFinalized ? _self.rivalFinalized : rivalFinalized // ignore: cast_nullable_to_non_nullable
as bool,offerScore: null == offerScore ? _self.offerScore : offerScore // ignore: cast_nullable_to_non_nullable
as double,isAiOffer: null == isAiOffer ? _self.isAiOffer : isAiOffer // ignore: cast_nullable_to_non_nullable
as bool,waitingUntilSeasonYear: freezed == waitingUntilSeasonYear ? _self.waitingUntilSeasonYear : waitingUntilSeasonYear // ignore: cast_nullable_to_non_nullable
as int?,waitingUntilWeek: freezed == waitingUntilWeek ? _self.waitingUntilWeek : waitingUntilWeek // ignore: cast_nullable_to_non_nullable
as int?,waitingUntilDay: freezed == waitingUntilDay ? _self.waitingUntilDay : waitingUntilDay // ignore: cast_nullable_to_non_nullable
as int?,waitingUntilHour: freezed == waitingUntilHour ? _self.waitingUntilHour : waitingUntilHour // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of ContractNegotiation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NegotiationOfferCopyWith<$Res> get lastOffer {
  
  return $NegotiationOfferCopyWith<$Res>(_self.lastOffer, (value) {
    return _then(_self.copyWith(lastOffer: value));
  });
}/// Create a copy of ContractNegotiation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NegotiationOfferCopyWith<$Res>? get counterOffer {
    if (_self.counterOffer == null) {
    return null;
  }

  return $NegotiationOfferCopyWith<$Res>(_self.counterOffer!, (value) {
    return _then(_self.copyWith(counterOffer: value));
  });
}
}


/// @nodoc
mixin _$NegotiationBlock {

 String get subjectId; NegotiationSubjectKind get subjectKind; String get teamId; int get untilSeasonYear; int get untilWeek; int get untilDay; int get untilHour;
/// Create a copy of NegotiationBlock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NegotiationBlockCopyWith<NegotiationBlock> get copyWith => _$NegotiationBlockCopyWithImpl<NegotiationBlock>(this as NegotiationBlock, _$identity);

  /// Serializes this NegotiationBlock to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NegotiationBlock&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.subjectKind, subjectKind) || other.subjectKind == subjectKind)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.untilSeasonYear, untilSeasonYear) || other.untilSeasonYear == untilSeasonYear)&&(identical(other.untilWeek, untilWeek) || other.untilWeek == untilWeek)&&(identical(other.untilDay, untilDay) || other.untilDay == untilDay)&&(identical(other.untilHour, untilHour) || other.untilHour == untilHour));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subjectId,subjectKind,teamId,untilSeasonYear,untilWeek,untilDay,untilHour);

@override
String toString() {
  return 'NegotiationBlock(subjectId: $subjectId, subjectKind: $subjectKind, teamId: $teamId, untilSeasonYear: $untilSeasonYear, untilWeek: $untilWeek, untilDay: $untilDay, untilHour: $untilHour)';
}


}

/// @nodoc
abstract mixin class $NegotiationBlockCopyWith<$Res>  {
  factory $NegotiationBlockCopyWith(NegotiationBlock value, $Res Function(NegotiationBlock) _then) = _$NegotiationBlockCopyWithImpl;
@useResult
$Res call({
 String subjectId, NegotiationSubjectKind subjectKind, String teamId, int untilSeasonYear, int untilWeek, int untilDay, int untilHour
});




}
/// @nodoc
class _$NegotiationBlockCopyWithImpl<$Res>
    implements $NegotiationBlockCopyWith<$Res> {
  _$NegotiationBlockCopyWithImpl(this._self, this._then);

  final NegotiationBlock _self;
  final $Res Function(NegotiationBlock) _then;

/// Create a copy of NegotiationBlock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? subjectId = null,Object? subjectKind = null,Object? teamId = null,Object? untilSeasonYear = null,Object? untilWeek = null,Object? untilDay = null,Object? untilHour = null,}) {
  return _then(_self.copyWith(
subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,subjectKind: null == subjectKind ? _self.subjectKind : subjectKind // ignore: cast_nullable_to_non_nullable
as NegotiationSubjectKind,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,untilSeasonYear: null == untilSeasonYear ? _self.untilSeasonYear : untilSeasonYear // ignore: cast_nullable_to_non_nullable
as int,untilWeek: null == untilWeek ? _self.untilWeek : untilWeek // ignore: cast_nullable_to_non_nullable
as int,untilDay: null == untilDay ? _self.untilDay : untilDay // ignore: cast_nullable_to_non_nullable
as int,untilHour: null == untilHour ? _self.untilHour : untilHour // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [NegotiationBlock].
extension NegotiationBlockPatterns on NegotiationBlock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NegotiationBlock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NegotiationBlock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NegotiationBlock value)  $default,){
final _that = this;
switch (_that) {
case _NegotiationBlock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NegotiationBlock value)?  $default,){
final _that = this;
switch (_that) {
case _NegotiationBlock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String subjectId,  NegotiationSubjectKind subjectKind,  String teamId,  int untilSeasonYear,  int untilWeek,  int untilDay,  int untilHour)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NegotiationBlock() when $default != null:
return $default(_that.subjectId,_that.subjectKind,_that.teamId,_that.untilSeasonYear,_that.untilWeek,_that.untilDay,_that.untilHour);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String subjectId,  NegotiationSubjectKind subjectKind,  String teamId,  int untilSeasonYear,  int untilWeek,  int untilDay,  int untilHour)  $default,) {final _that = this;
switch (_that) {
case _NegotiationBlock():
return $default(_that.subjectId,_that.subjectKind,_that.teamId,_that.untilSeasonYear,_that.untilWeek,_that.untilDay,_that.untilHour);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String subjectId,  NegotiationSubjectKind subjectKind,  String teamId,  int untilSeasonYear,  int untilWeek,  int untilDay,  int untilHour)?  $default,) {final _that = this;
switch (_that) {
case _NegotiationBlock() when $default != null:
return $default(_that.subjectId,_that.subjectKind,_that.teamId,_that.untilSeasonYear,_that.untilWeek,_that.untilDay,_that.untilHour);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NegotiationBlock implements NegotiationBlock {
  const _NegotiationBlock({required this.subjectId, required this.subjectKind, required this.teamId, required this.untilSeasonYear, required this.untilWeek, required this.untilDay, this.untilHour = 0});
  factory _NegotiationBlock.fromJson(Map<String, dynamic> json) => _$NegotiationBlockFromJson(json);

@override final  String subjectId;
@override final  NegotiationSubjectKind subjectKind;
@override final  String teamId;
@override final  int untilSeasonYear;
@override final  int untilWeek;
@override final  int untilDay;
@override@JsonKey() final  int untilHour;

/// Create a copy of NegotiationBlock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NegotiationBlockCopyWith<_NegotiationBlock> get copyWith => __$NegotiationBlockCopyWithImpl<_NegotiationBlock>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NegotiationBlockToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NegotiationBlock&&(identical(other.subjectId, subjectId) || other.subjectId == subjectId)&&(identical(other.subjectKind, subjectKind) || other.subjectKind == subjectKind)&&(identical(other.teamId, teamId) || other.teamId == teamId)&&(identical(other.untilSeasonYear, untilSeasonYear) || other.untilSeasonYear == untilSeasonYear)&&(identical(other.untilWeek, untilWeek) || other.untilWeek == untilWeek)&&(identical(other.untilDay, untilDay) || other.untilDay == untilDay)&&(identical(other.untilHour, untilHour) || other.untilHour == untilHour));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subjectId,subjectKind,teamId,untilSeasonYear,untilWeek,untilDay,untilHour);

@override
String toString() {
  return 'NegotiationBlock(subjectId: $subjectId, subjectKind: $subjectKind, teamId: $teamId, untilSeasonYear: $untilSeasonYear, untilWeek: $untilWeek, untilDay: $untilDay, untilHour: $untilHour)';
}


}

/// @nodoc
abstract mixin class _$NegotiationBlockCopyWith<$Res> implements $NegotiationBlockCopyWith<$Res> {
  factory _$NegotiationBlockCopyWith(_NegotiationBlock value, $Res Function(_NegotiationBlock) _then) = __$NegotiationBlockCopyWithImpl;
@override @useResult
$Res call({
 String subjectId, NegotiationSubjectKind subjectKind, String teamId, int untilSeasonYear, int untilWeek, int untilDay, int untilHour
});




}
/// @nodoc
class __$NegotiationBlockCopyWithImpl<$Res>
    implements _$NegotiationBlockCopyWith<$Res> {
  __$NegotiationBlockCopyWithImpl(this._self, this._then);

  final _NegotiationBlock _self;
  final $Res Function(_NegotiationBlock) _then;

/// Create a copy of NegotiationBlock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? subjectId = null,Object? subjectKind = null,Object? teamId = null,Object? untilSeasonYear = null,Object? untilWeek = null,Object? untilDay = null,Object? untilHour = null,}) {
  return _then(_NegotiationBlock(
subjectId: null == subjectId ? _self.subjectId : subjectId // ignore: cast_nullable_to_non_nullable
as String,subjectKind: null == subjectKind ? _self.subjectKind : subjectKind // ignore: cast_nullable_to_non_nullable
as NegotiationSubjectKind,teamId: null == teamId ? _self.teamId : teamId // ignore: cast_nullable_to_non_nullable
as String,untilSeasonYear: null == untilSeasonYear ? _self.untilSeasonYear : untilSeasonYear // ignore: cast_nullable_to_non_nullable
as int,untilWeek: null == untilWeek ? _self.untilWeek : untilWeek // ignore: cast_nullable_to_non_nullable
as int,untilDay: null == untilDay ? _self.untilDay : untilDay // ignore: cast_nullable_to_non_nullable
as int,untilHour: null == untilHour ? _self.untilHour : untilHour // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
