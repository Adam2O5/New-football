// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contract.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Contract {

 int get salary; int get yearsRemaining; bool get hasBirdRights; bool get isRookieScale; int get rookiePickSlot; bool get noTradeClause; List<String> get blockedTeamIds;
/// Create a copy of Contract
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContractCopyWith<Contract> get copyWith => _$ContractCopyWithImpl<Contract>(this as Contract, _$identity);

  /// Serializes this Contract to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Contract&&(identical(other.salary, salary) || other.salary == salary)&&(identical(other.yearsRemaining, yearsRemaining) || other.yearsRemaining == yearsRemaining)&&(identical(other.hasBirdRights, hasBirdRights) || other.hasBirdRights == hasBirdRights)&&(identical(other.isRookieScale, isRookieScale) || other.isRookieScale == isRookieScale)&&(identical(other.rookiePickSlot, rookiePickSlot) || other.rookiePickSlot == rookiePickSlot)&&(identical(other.noTradeClause, noTradeClause) || other.noTradeClause == noTradeClause)&&const DeepCollectionEquality().equals(other.blockedTeamIds, blockedTeamIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,salary,yearsRemaining,hasBirdRights,isRookieScale,rookiePickSlot,noTradeClause,const DeepCollectionEquality().hash(blockedTeamIds));

@override
String toString() {
  return 'Contract(salary: $salary, yearsRemaining: $yearsRemaining, hasBirdRights: $hasBirdRights, isRookieScale: $isRookieScale, rookiePickSlot: $rookiePickSlot, noTradeClause: $noTradeClause, blockedTeamIds: $blockedTeamIds)';
}


}

/// @nodoc
abstract mixin class $ContractCopyWith<$Res>  {
  factory $ContractCopyWith(Contract value, $Res Function(Contract) _then) = _$ContractCopyWithImpl;
@useResult
$Res call({
 int salary, int yearsRemaining, bool hasBirdRights, bool isRookieScale, int rookiePickSlot, bool noTradeClause, List<String> blockedTeamIds
});




}
/// @nodoc
class _$ContractCopyWithImpl<$Res>
    implements $ContractCopyWith<$Res> {
  _$ContractCopyWithImpl(this._self, this._then);

  final Contract _self;
  final $Res Function(Contract) _then;

/// Create a copy of Contract
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? salary = null,Object? yearsRemaining = null,Object? hasBirdRights = null,Object? isRookieScale = null,Object? rookiePickSlot = null,Object? noTradeClause = null,Object? blockedTeamIds = null,}) {
  return _then(_self.copyWith(
salary: null == salary ? _self.salary : salary // ignore: cast_nullable_to_non_nullable
as int,yearsRemaining: null == yearsRemaining ? _self.yearsRemaining : yearsRemaining // ignore: cast_nullable_to_non_nullable
as int,hasBirdRights: null == hasBirdRights ? _self.hasBirdRights : hasBirdRights // ignore: cast_nullable_to_non_nullable
as bool,isRookieScale: null == isRookieScale ? _self.isRookieScale : isRookieScale // ignore: cast_nullable_to_non_nullable
as bool,rookiePickSlot: null == rookiePickSlot ? _self.rookiePickSlot : rookiePickSlot // ignore: cast_nullable_to_non_nullable
as int,noTradeClause: null == noTradeClause ? _self.noTradeClause : noTradeClause // ignore: cast_nullable_to_non_nullable
as bool,blockedTeamIds: null == blockedTeamIds ? _self.blockedTeamIds : blockedTeamIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Contract].
extension ContractPatterns on Contract {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Contract value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Contract() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Contract value)  $default,){
final _that = this;
switch (_that) {
case _Contract():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Contract value)?  $default,){
final _that = this;
switch (_that) {
case _Contract() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int salary,  int yearsRemaining,  bool hasBirdRights,  bool isRookieScale,  int rookiePickSlot,  bool noTradeClause,  List<String> blockedTeamIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Contract() when $default != null:
return $default(_that.salary,_that.yearsRemaining,_that.hasBirdRights,_that.isRookieScale,_that.rookiePickSlot,_that.noTradeClause,_that.blockedTeamIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int salary,  int yearsRemaining,  bool hasBirdRights,  bool isRookieScale,  int rookiePickSlot,  bool noTradeClause,  List<String> blockedTeamIds)  $default,) {final _that = this;
switch (_that) {
case _Contract():
return $default(_that.salary,_that.yearsRemaining,_that.hasBirdRights,_that.isRookieScale,_that.rookiePickSlot,_that.noTradeClause,_that.blockedTeamIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int salary,  int yearsRemaining,  bool hasBirdRights,  bool isRookieScale,  int rookiePickSlot,  bool noTradeClause,  List<String> blockedTeamIds)?  $default,) {final _that = this;
switch (_that) {
case _Contract() when $default != null:
return $default(_that.salary,_that.yearsRemaining,_that.hasBirdRights,_that.isRookieScale,_that.rookiePickSlot,_that.noTradeClause,_that.blockedTeamIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Contract implements Contract {
  const _Contract({required this.salary, required this.yearsRemaining, this.hasBirdRights = false, this.isRookieScale = false, this.rookiePickSlot = 0, this.noTradeClause = false, final  List<String> blockedTeamIds = const []}): _blockedTeamIds = blockedTeamIds;
  factory _Contract.fromJson(Map<String, dynamic> json) => _$ContractFromJson(json);

@override final  int salary;
@override final  int yearsRemaining;
@override@JsonKey() final  bool hasBirdRights;
@override@JsonKey() final  bool isRookieScale;
@override@JsonKey() final  int rookiePickSlot;
@override@JsonKey() final  bool noTradeClause;
 final  List<String> _blockedTeamIds;
@override@JsonKey() List<String> get blockedTeamIds {
  if (_blockedTeamIds is EqualUnmodifiableListView) return _blockedTeamIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blockedTeamIds);
}


/// Create a copy of Contract
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContractCopyWith<_Contract> get copyWith => __$ContractCopyWithImpl<_Contract>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContractToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Contract&&(identical(other.salary, salary) || other.salary == salary)&&(identical(other.yearsRemaining, yearsRemaining) || other.yearsRemaining == yearsRemaining)&&(identical(other.hasBirdRights, hasBirdRights) || other.hasBirdRights == hasBirdRights)&&(identical(other.isRookieScale, isRookieScale) || other.isRookieScale == isRookieScale)&&(identical(other.rookiePickSlot, rookiePickSlot) || other.rookiePickSlot == rookiePickSlot)&&(identical(other.noTradeClause, noTradeClause) || other.noTradeClause == noTradeClause)&&const DeepCollectionEquality().equals(other._blockedTeamIds, _blockedTeamIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,salary,yearsRemaining,hasBirdRights,isRookieScale,rookiePickSlot,noTradeClause,const DeepCollectionEquality().hash(_blockedTeamIds));

@override
String toString() {
  return 'Contract(salary: $salary, yearsRemaining: $yearsRemaining, hasBirdRights: $hasBirdRights, isRookieScale: $isRookieScale, rookiePickSlot: $rookiePickSlot, noTradeClause: $noTradeClause, blockedTeamIds: $blockedTeamIds)';
}


}

/// @nodoc
abstract mixin class _$ContractCopyWith<$Res> implements $ContractCopyWith<$Res> {
  factory _$ContractCopyWith(_Contract value, $Res Function(_Contract) _then) = __$ContractCopyWithImpl;
@override @useResult
$Res call({
 int salary, int yearsRemaining, bool hasBirdRights, bool isRookieScale, int rookiePickSlot, bool noTradeClause, List<String> blockedTeamIds
});




}
/// @nodoc
class __$ContractCopyWithImpl<$Res>
    implements _$ContractCopyWith<$Res> {
  __$ContractCopyWithImpl(this._self, this._then);

  final _Contract _self;
  final $Res Function(_Contract) _then;

/// Create a copy of Contract
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? salary = null,Object? yearsRemaining = null,Object? hasBirdRights = null,Object? isRookieScale = null,Object? rookiePickSlot = null,Object? noTradeClause = null,Object? blockedTeamIds = null,}) {
  return _then(_Contract(
salary: null == salary ? _self.salary : salary // ignore: cast_nullable_to_non_nullable
as int,yearsRemaining: null == yearsRemaining ? _self.yearsRemaining : yearsRemaining // ignore: cast_nullable_to_non_nullable
as int,hasBirdRights: null == hasBirdRights ? _self.hasBirdRights : hasBirdRights // ignore: cast_nullable_to_non_nullable
as bool,isRookieScale: null == isRookieScale ? _self.isRookieScale : isRookieScale // ignore: cast_nullable_to_non_nullable
as bool,rookiePickSlot: null == rookiePickSlot ? _self.rookiePickSlot : rookiePickSlot // ignore: cast_nullable_to_non_nullable
as int,noTradeClause: null == noTradeClause ? _self.noTradeClause : noTradeClause // ignore: cast_nullable_to_non_nullable
as bool,blockedTeamIds: null == blockedTeamIds ? _self._blockedTeamIds : blockedTeamIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$CapException {

 CapExceptionType get type; int get amountRemaining; String get playerId; int? get expiryYear;
/// Create a copy of CapException
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CapExceptionCopyWith<CapException> get copyWith => _$CapExceptionCopyWithImpl<CapException>(this as CapException, _$identity);

  /// Serializes this CapException to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CapException&&(identical(other.type, type) || other.type == type)&&(identical(other.amountRemaining, amountRemaining) || other.amountRemaining == amountRemaining)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.expiryYear, expiryYear) || other.expiryYear == expiryYear));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,amountRemaining,playerId,expiryYear);

@override
String toString() {
  return 'CapException(type: $type, amountRemaining: $amountRemaining, playerId: $playerId, expiryYear: $expiryYear)';
}


}

/// @nodoc
abstract mixin class $CapExceptionCopyWith<$Res>  {
  factory $CapExceptionCopyWith(CapException value, $Res Function(CapException) _then) = _$CapExceptionCopyWithImpl;
@useResult
$Res call({
 CapExceptionType type, int amountRemaining, String playerId, int? expiryYear
});




}
/// @nodoc
class _$CapExceptionCopyWithImpl<$Res>
    implements $CapExceptionCopyWith<$Res> {
  _$CapExceptionCopyWithImpl(this._self, this._then);

  final CapException _self;
  final $Res Function(CapException) _then;

/// Create a copy of CapException
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? amountRemaining = null,Object? playerId = null,Object? expiryYear = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CapExceptionType,amountRemaining: null == amountRemaining ? _self.amountRemaining : amountRemaining // ignore: cast_nullable_to_non_nullable
as int,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,expiryYear: freezed == expiryYear ? _self.expiryYear : expiryYear // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CapException].
extension CapExceptionPatterns on CapException {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CapException value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CapException() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CapException value)  $default,){
final _that = this;
switch (_that) {
case _CapException():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CapException value)?  $default,){
final _that = this;
switch (_that) {
case _CapException() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CapExceptionType type,  int amountRemaining,  String playerId,  int? expiryYear)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CapException() when $default != null:
return $default(_that.type,_that.amountRemaining,_that.playerId,_that.expiryYear);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CapExceptionType type,  int amountRemaining,  String playerId,  int? expiryYear)  $default,) {final _that = this;
switch (_that) {
case _CapException():
return $default(_that.type,_that.amountRemaining,_that.playerId,_that.expiryYear);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CapExceptionType type,  int amountRemaining,  String playerId,  int? expiryYear)?  $default,) {final _that = this;
switch (_that) {
case _CapException() when $default != null:
return $default(_that.type,_that.amountRemaining,_that.playerId,_that.expiryYear);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CapException implements CapException {
  const _CapException({required this.type, required this.amountRemaining, required this.playerId, this.expiryYear});
  factory _CapException.fromJson(Map<String, dynamic> json) => _$CapExceptionFromJson(json);

@override final  CapExceptionType type;
@override final  int amountRemaining;
@override final  String playerId;
@override final  int? expiryYear;

/// Create a copy of CapException
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CapExceptionCopyWith<_CapException> get copyWith => __$CapExceptionCopyWithImpl<_CapException>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CapExceptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CapException&&(identical(other.type, type) || other.type == type)&&(identical(other.amountRemaining, amountRemaining) || other.amountRemaining == amountRemaining)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.expiryYear, expiryYear) || other.expiryYear == expiryYear));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,amountRemaining,playerId,expiryYear);

@override
String toString() {
  return 'CapException(type: $type, amountRemaining: $amountRemaining, playerId: $playerId, expiryYear: $expiryYear)';
}


}

/// @nodoc
abstract mixin class _$CapExceptionCopyWith<$Res> implements $CapExceptionCopyWith<$Res> {
  factory _$CapExceptionCopyWith(_CapException value, $Res Function(_CapException) _then) = __$CapExceptionCopyWithImpl;
@override @useResult
$Res call({
 CapExceptionType type, int amountRemaining, String playerId, int? expiryYear
});




}
/// @nodoc
class __$CapExceptionCopyWithImpl<$Res>
    implements _$CapExceptionCopyWith<$Res> {
  __$CapExceptionCopyWithImpl(this._self, this._then);

  final _CapException _self;
  final $Res Function(_CapException) _then;

/// Create a copy of CapException
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? amountRemaining = null,Object? playerId = null,Object? expiryYear = freezed,}) {
  return _then(_CapException(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CapExceptionType,amountRemaining: null == amountRemaining ? _self.amountRemaining : amountRemaining // ignore: cast_nullable_to_non_nullable
as int,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,expiryYear: freezed == expiryYear ? _self.expiryYear : expiryYear // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$TeamFinance {

 int get salaryCap; int get totalPayroll; List<CapException> get activeExceptions; int get midLevelExceptionAmount; bool get midLevelExceptionAvailable; int get cashBalance;
/// Create a copy of TeamFinance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamFinanceCopyWith<TeamFinance> get copyWith => _$TeamFinanceCopyWithImpl<TeamFinance>(this as TeamFinance, _$identity);

  /// Serializes this TeamFinance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamFinance&&(identical(other.salaryCap, salaryCap) || other.salaryCap == salaryCap)&&(identical(other.totalPayroll, totalPayroll) || other.totalPayroll == totalPayroll)&&const DeepCollectionEquality().equals(other.activeExceptions, activeExceptions)&&(identical(other.midLevelExceptionAmount, midLevelExceptionAmount) || other.midLevelExceptionAmount == midLevelExceptionAmount)&&(identical(other.midLevelExceptionAvailable, midLevelExceptionAvailable) || other.midLevelExceptionAvailable == midLevelExceptionAvailable)&&(identical(other.cashBalance, cashBalance) || other.cashBalance == cashBalance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,salaryCap,totalPayroll,const DeepCollectionEquality().hash(activeExceptions),midLevelExceptionAmount,midLevelExceptionAvailable,cashBalance);

@override
String toString() {
  return 'TeamFinance(salaryCap: $salaryCap, totalPayroll: $totalPayroll, activeExceptions: $activeExceptions, midLevelExceptionAmount: $midLevelExceptionAmount, midLevelExceptionAvailable: $midLevelExceptionAvailable, cashBalance: $cashBalance)';
}


}

/// @nodoc
abstract mixin class $TeamFinanceCopyWith<$Res>  {
  factory $TeamFinanceCopyWith(TeamFinance value, $Res Function(TeamFinance) _then) = _$TeamFinanceCopyWithImpl;
@useResult
$Res call({
 int salaryCap, int totalPayroll, List<CapException> activeExceptions, int midLevelExceptionAmount, bool midLevelExceptionAvailable, int cashBalance
});




}
/// @nodoc
class _$TeamFinanceCopyWithImpl<$Res>
    implements $TeamFinanceCopyWith<$Res> {
  _$TeamFinanceCopyWithImpl(this._self, this._then);

  final TeamFinance _self;
  final $Res Function(TeamFinance) _then;

/// Create a copy of TeamFinance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? salaryCap = null,Object? totalPayroll = null,Object? activeExceptions = null,Object? midLevelExceptionAmount = null,Object? midLevelExceptionAvailable = null,Object? cashBalance = null,}) {
  return _then(_self.copyWith(
salaryCap: null == salaryCap ? _self.salaryCap : salaryCap // ignore: cast_nullable_to_non_nullable
as int,totalPayroll: null == totalPayroll ? _self.totalPayroll : totalPayroll // ignore: cast_nullable_to_non_nullable
as int,activeExceptions: null == activeExceptions ? _self.activeExceptions : activeExceptions // ignore: cast_nullable_to_non_nullable
as List<CapException>,midLevelExceptionAmount: null == midLevelExceptionAmount ? _self.midLevelExceptionAmount : midLevelExceptionAmount // ignore: cast_nullable_to_non_nullable
as int,midLevelExceptionAvailable: null == midLevelExceptionAvailable ? _self.midLevelExceptionAvailable : midLevelExceptionAvailable // ignore: cast_nullable_to_non_nullable
as bool,cashBalance: null == cashBalance ? _self.cashBalance : cashBalance // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TeamFinance].
extension TeamFinancePatterns on TeamFinance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamFinance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamFinance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamFinance value)  $default,){
final _that = this;
switch (_that) {
case _TeamFinance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamFinance value)?  $default,){
final _that = this;
switch (_that) {
case _TeamFinance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int salaryCap,  int totalPayroll,  List<CapException> activeExceptions,  int midLevelExceptionAmount,  bool midLevelExceptionAvailable,  int cashBalance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamFinance() when $default != null:
return $default(_that.salaryCap,_that.totalPayroll,_that.activeExceptions,_that.midLevelExceptionAmount,_that.midLevelExceptionAvailable,_that.cashBalance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int salaryCap,  int totalPayroll,  List<CapException> activeExceptions,  int midLevelExceptionAmount,  bool midLevelExceptionAvailable,  int cashBalance)  $default,) {final _that = this;
switch (_that) {
case _TeamFinance():
return $default(_that.salaryCap,_that.totalPayroll,_that.activeExceptions,_that.midLevelExceptionAmount,_that.midLevelExceptionAvailable,_that.cashBalance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int salaryCap,  int totalPayroll,  List<CapException> activeExceptions,  int midLevelExceptionAmount,  bool midLevelExceptionAvailable,  int cashBalance)?  $default,) {final _that = this;
switch (_that) {
case _TeamFinance() when $default != null:
return $default(_that.salaryCap,_that.totalPayroll,_that.activeExceptions,_that.midLevelExceptionAmount,_that.midLevelExceptionAvailable,_that.cashBalance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamFinance implements TeamFinance {
  const _TeamFinance({this.salaryCap = 300000000, this.totalPayroll = 0, final  List<CapException> activeExceptions = const [], this.midLevelExceptionAmount = 20400000, this.midLevelExceptionAvailable = true, this.cashBalance = 75000000}): _activeExceptions = activeExceptions;
  factory _TeamFinance.fromJson(Map<String, dynamic> json) => _$TeamFinanceFromJson(json);

@override@JsonKey() final  int salaryCap;
@override@JsonKey() final  int totalPayroll;
 final  List<CapException> _activeExceptions;
@override@JsonKey() List<CapException> get activeExceptions {
  if (_activeExceptions is EqualUnmodifiableListView) return _activeExceptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activeExceptions);
}

@override@JsonKey() final  int midLevelExceptionAmount;
@override@JsonKey() final  bool midLevelExceptionAvailable;
@override@JsonKey() final  int cashBalance;

/// Create a copy of TeamFinance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamFinanceCopyWith<_TeamFinance> get copyWith => __$TeamFinanceCopyWithImpl<_TeamFinance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamFinanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamFinance&&(identical(other.salaryCap, salaryCap) || other.salaryCap == salaryCap)&&(identical(other.totalPayroll, totalPayroll) || other.totalPayroll == totalPayroll)&&const DeepCollectionEquality().equals(other._activeExceptions, _activeExceptions)&&(identical(other.midLevelExceptionAmount, midLevelExceptionAmount) || other.midLevelExceptionAmount == midLevelExceptionAmount)&&(identical(other.midLevelExceptionAvailable, midLevelExceptionAvailable) || other.midLevelExceptionAvailable == midLevelExceptionAvailable)&&(identical(other.cashBalance, cashBalance) || other.cashBalance == cashBalance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,salaryCap,totalPayroll,const DeepCollectionEquality().hash(_activeExceptions),midLevelExceptionAmount,midLevelExceptionAvailable,cashBalance);

@override
String toString() {
  return 'TeamFinance(salaryCap: $salaryCap, totalPayroll: $totalPayroll, activeExceptions: $activeExceptions, midLevelExceptionAmount: $midLevelExceptionAmount, midLevelExceptionAvailable: $midLevelExceptionAvailable, cashBalance: $cashBalance)';
}


}

/// @nodoc
abstract mixin class _$TeamFinanceCopyWith<$Res> implements $TeamFinanceCopyWith<$Res> {
  factory _$TeamFinanceCopyWith(_TeamFinance value, $Res Function(_TeamFinance) _then) = __$TeamFinanceCopyWithImpl;
@override @useResult
$Res call({
 int salaryCap, int totalPayroll, List<CapException> activeExceptions, int midLevelExceptionAmount, bool midLevelExceptionAvailable, int cashBalance
});




}
/// @nodoc
class __$TeamFinanceCopyWithImpl<$Res>
    implements _$TeamFinanceCopyWith<$Res> {
  __$TeamFinanceCopyWithImpl(this._self, this._then);

  final _TeamFinance _self;
  final $Res Function(_TeamFinance) _then;

/// Create a copy of TeamFinance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? salaryCap = null,Object? totalPayroll = null,Object? activeExceptions = null,Object? midLevelExceptionAmount = null,Object? midLevelExceptionAvailable = null,Object? cashBalance = null,}) {
  return _then(_TeamFinance(
salaryCap: null == salaryCap ? _self.salaryCap : salaryCap // ignore: cast_nullable_to_non_nullable
as int,totalPayroll: null == totalPayroll ? _self.totalPayroll : totalPayroll // ignore: cast_nullable_to_non_nullable
as int,activeExceptions: null == activeExceptions ? _self._activeExceptions : activeExceptions // ignore: cast_nullable_to_non_nullable
as List<CapException>,midLevelExceptionAmount: null == midLevelExceptionAmount ? _self.midLevelExceptionAmount : midLevelExceptionAmount // ignore: cast_nullable_to_non_nullable
as int,midLevelExceptionAvailable: null == midLevelExceptionAvailable ? _self.midLevelExceptionAvailable : midLevelExceptionAvailable // ignore: cast_nullable_to_non_nullable
as bool,cashBalance: null == cashBalance ? _self.cashBalance : cashBalance // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
