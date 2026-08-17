// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StaffAttributes {

 double get tactics; double get motivation; double get development; double get mentoring; double get coverage; double get evaluation; double get rehabilitation; double get regenaration; double get prevention; double get care; double get negotiation;
/// Create a copy of StaffAttributes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffAttributesCopyWith<StaffAttributes> get copyWith => _$StaffAttributesCopyWithImpl<StaffAttributes>(this as StaffAttributes, _$identity);

  /// Serializes this StaffAttributes to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffAttributes&&(identical(other.tactics, tactics) || other.tactics == tactics)&&(identical(other.motivation, motivation) || other.motivation == motivation)&&(identical(other.development, development) || other.development == development)&&(identical(other.mentoring, mentoring) || other.mentoring == mentoring)&&(identical(other.coverage, coverage) || other.coverage == coverage)&&(identical(other.evaluation, evaluation) || other.evaluation == evaluation)&&(identical(other.rehabilitation, rehabilitation) || other.rehabilitation == rehabilitation)&&(identical(other.regenaration, regenaration) || other.regenaration == regenaration)&&(identical(other.prevention, prevention) || other.prevention == prevention)&&(identical(other.care, care) || other.care == care)&&(identical(other.negotiation, negotiation) || other.negotiation == negotiation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tactics,motivation,development,mentoring,coverage,evaluation,rehabilitation,regenaration,prevention,care,negotiation);

@override
String toString() {
  return 'StaffAttributes(tactics: $tactics, motivation: $motivation, development: $development, mentoring: $mentoring, coverage: $coverage, evaluation: $evaluation, rehabilitation: $rehabilitation, regenaration: $regenaration, prevention: $prevention, care: $care, negotiation: $negotiation)';
}


}

/// @nodoc
abstract mixin class $StaffAttributesCopyWith<$Res>  {
  factory $StaffAttributesCopyWith(StaffAttributes value, $Res Function(StaffAttributes) _then) = _$StaffAttributesCopyWithImpl;
@useResult
$Res call({
 double tactics, double motivation, double development, double mentoring, double coverage, double evaluation, double rehabilitation, double regenaration, double prevention, double care, double negotiation
});




}
/// @nodoc
class _$StaffAttributesCopyWithImpl<$Res>
    implements $StaffAttributesCopyWith<$Res> {
  _$StaffAttributesCopyWithImpl(this._self, this._then);

  final StaffAttributes _self;
  final $Res Function(StaffAttributes) _then;

/// Create a copy of StaffAttributes
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tactics = null,Object? motivation = null,Object? development = null,Object? mentoring = null,Object? coverage = null,Object? evaluation = null,Object? rehabilitation = null,Object? regenaration = null,Object? prevention = null,Object? care = null,Object? negotiation = null,}) {
  return _then(_self.copyWith(
tactics: null == tactics ? _self.tactics : tactics // ignore: cast_nullable_to_non_nullable
as double,motivation: null == motivation ? _self.motivation : motivation // ignore: cast_nullable_to_non_nullable
as double,development: null == development ? _self.development : development // ignore: cast_nullable_to_non_nullable
as double,mentoring: null == mentoring ? _self.mentoring : mentoring // ignore: cast_nullable_to_non_nullable
as double,coverage: null == coverage ? _self.coverage : coverage // ignore: cast_nullable_to_non_nullable
as double,evaluation: null == evaluation ? _self.evaluation : evaluation // ignore: cast_nullable_to_non_nullable
as double,rehabilitation: null == rehabilitation ? _self.rehabilitation : rehabilitation // ignore: cast_nullable_to_non_nullable
as double,regenaration: null == regenaration ? _self.regenaration : regenaration // ignore: cast_nullable_to_non_nullable
as double,prevention: null == prevention ? _self.prevention : prevention // ignore: cast_nullable_to_non_nullable
as double,care: null == care ? _self.care : care // ignore: cast_nullable_to_non_nullable
as double,negotiation: null == negotiation ? _self.negotiation : negotiation // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffAttributes].
extension StaffAttributesPatterns on StaffAttributes {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffAttributes value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffAttributes() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffAttributes value)  $default,){
final _that = this;
switch (_that) {
case _StaffAttributes():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffAttributes value)?  $default,){
final _that = this;
switch (_that) {
case _StaffAttributes() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double tactics,  double motivation,  double development,  double mentoring,  double coverage,  double evaluation,  double rehabilitation,  double regenaration,  double prevention,  double care,  double negotiation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffAttributes() when $default != null:
return $default(_that.tactics,_that.motivation,_that.development,_that.mentoring,_that.coverage,_that.evaluation,_that.rehabilitation,_that.regenaration,_that.prevention,_that.care,_that.negotiation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double tactics,  double motivation,  double development,  double mentoring,  double coverage,  double evaluation,  double rehabilitation,  double regenaration,  double prevention,  double care,  double negotiation)  $default,) {final _that = this;
switch (_that) {
case _StaffAttributes():
return $default(_that.tactics,_that.motivation,_that.development,_that.mentoring,_that.coverage,_that.evaluation,_that.rehabilitation,_that.regenaration,_that.prevention,_that.care,_that.negotiation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double tactics,  double motivation,  double development,  double mentoring,  double coverage,  double evaluation,  double rehabilitation,  double regenaration,  double prevention,  double care,  double negotiation)?  $default,) {final _that = this;
switch (_that) {
case _StaffAttributes() when $default != null:
return $default(_that.tactics,_that.motivation,_that.development,_that.mentoring,_that.coverage,_that.evaluation,_that.rehabilitation,_that.regenaration,_that.prevention,_that.care,_that.negotiation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StaffAttributes implements StaffAttributes {
  const _StaffAttributes({this.tactics = 0.0, this.motivation = 0.0, this.development = 0.0, this.mentoring = 0.0, this.coverage = 0.0, this.evaluation = 0.0, this.rehabilitation = 0.0, this.regenaration = 0.0, this.prevention = 0.0, this.care = 0.0, this.negotiation = 0.0});
  factory _StaffAttributes.fromJson(Map<String, dynamic> json) => _$StaffAttributesFromJson(json);

@override@JsonKey() final  double tactics;
@override@JsonKey() final  double motivation;
@override@JsonKey() final  double development;
@override@JsonKey() final  double mentoring;
@override@JsonKey() final  double coverage;
@override@JsonKey() final  double evaluation;
@override@JsonKey() final  double rehabilitation;
@override@JsonKey() final  double regenaration;
@override@JsonKey() final  double prevention;
@override@JsonKey() final  double care;
@override@JsonKey() final  double negotiation;

/// Create a copy of StaffAttributes
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffAttributesCopyWith<_StaffAttributes> get copyWith => __$StaffAttributesCopyWithImpl<_StaffAttributes>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StaffAttributesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffAttributes&&(identical(other.tactics, tactics) || other.tactics == tactics)&&(identical(other.motivation, motivation) || other.motivation == motivation)&&(identical(other.development, development) || other.development == development)&&(identical(other.mentoring, mentoring) || other.mentoring == mentoring)&&(identical(other.coverage, coverage) || other.coverage == coverage)&&(identical(other.evaluation, evaluation) || other.evaluation == evaluation)&&(identical(other.rehabilitation, rehabilitation) || other.rehabilitation == rehabilitation)&&(identical(other.regenaration, regenaration) || other.regenaration == regenaration)&&(identical(other.prevention, prevention) || other.prevention == prevention)&&(identical(other.care, care) || other.care == care)&&(identical(other.negotiation, negotiation) || other.negotiation == negotiation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tactics,motivation,development,mentoring,coverage,evaluation,rehabilitation,regenaration,prevention,care,negotiation);

@override
String toString() {
  return 'StaffAttributes(tactics: $tactics, motivation: $motivation, development: $development, mentoring: $mentoring, coverage: $coverage, evaluation: $evaluation, rehabilitation: $rehabilitation, regenaration: $regenaration, prevention: $prevention, care: $care, negotiation: $negotiation)';
}


}

/// @nodoc
abstract mixin class _$StaffAttributesCopyWith<$Res> implements $StaffAttributesCopyWith<$Res> {
  factory _$StaffAttributesCopyWith(_StaffAttributes value, $Res Function(_StaffAttributes) _then) = __$StaffAttributesCopyWithImpl;
@override @useResult
$Res call({
 double tactics, double motivation, double development, double mentoring, double coverage, double evaluation, double rehabilitation, double regenaration, double prevention, double care, double negotiation
});




}
/// @nodoc
class __$StaffAttributesCopyWithImpl<$Res>
    implements _$StaffAttributesCopyWith<$Res> {
  __$StaffAttributesCopyWithImpl(this._self, this._then);

  final _StaffAttributes _self;
  final $Res Function(_StaffAttributes) _then;

/// Create a copy of StaffAttributes
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tactics = null,Object? motivation = null,Object? development = null,Object? mentoring = null,Object? coverage = null,Object? evaluation = null,Object? rehabilitation = null,Object? regenaration = null,Object? prevention = null,Object? care = null,Object? negotiation = null,}) {
  return _then(_StaffAttributes(
tactics: null == tactics ? _self.tactics : tactics // ignore: cast_nullable_to_non_nullable
as double,motivation: null == motivation ? _self.motivation : motivation // ignore: cast_nullable_to_non_nullable
as double,development: null == development ? _self.development : development // ignore: cast_nullable_to_non_nullable
as double,mentoring: null == mentoring ? _self.mentoring : mentoring // ignore: cast_nullable_to_non_nullable
as double,coverage: null == coverage ? _self.coverage : coverage // ignore: cast_nullable_to_non_nullable
as double,evaluation: null == evaluation ? _self.evaluation : evaluation // ignore: cast_nullable_to_non_nullable
as double,rehabilitation: null == rehabilitation ? _self.rehabilitation : rehabilitation // ignore: cast_nullable_to_non_nullable
as double,regenaration: null == regenaration ? _self.regenaration : regenaration // ignore: cast_nullable_to_non_nullable
as double,prevention: null == prevention ? _self.prevention : prevention // ignore: cast_nullable_to_non_nullable
as double,care: null == care ? _self.care : care // ignore: cast_nullable_to_non_nullable
as double,negotiation: null == negotiation ? _self.negotiation : negotiation // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$StaffContract {

 int get salary; int get yearsRemaining;
/// Create a copy of StaffContract
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffContractCopyWith<StaffContract> get copyWith => _$StaffContractCopyWithImpl<StaffContract>(this as StaffContract, _$identity);

  /// Serializes this StaffContract to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffContract&&(identical(other.salary, salary) || other.salary == salary)&&(identical(other.yearsRemaining, yearsRemaining) || other.yearsRemaining == yearsRemaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,salary,yearsRemaining);

@override
String toString() {
  return 'StaffContract(salary: $salary, yearsRemaining: $yearsRemaining)';
}


}

/// @nodoc
abstract mixin class $StaffContractCopyWith<$Res>  {
  factory $StaffContractCopyWith(StaffContract value, $Res Function(StaffContract) _then) = _$StaffContractCopyWithImpl;
@useResult
$Res call({
 int salary, int yearsRemaining
});




}
/// @nodoc
class _$StaffContractCopyWithImpl<$Res>
    implements $StaffContractCopyWith<$Res> {
  _$StaffContractCopyWithImpl(this._self, this._then);

  final StaffContract _self;
  final $Res Function(StaffContract) _then;

/// Create a copy of StaffContract
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? salary = null,Object? yearsRemaining = null,}) {
  return _then(_self.copyWith(
salary: null == salary ? _self.salary : salary // ignore: cast_nullable_to_non_nullable
as int,yearsRemaining: null == yearsRemaining ? _self.yearsRemaining : yearsRemaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffContract].
extension StaffContractPatterns on StaffContract {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffContract value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffContract() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffContract value)  $default,){
final _that = this;
switch (_that) {
case _StaffContract():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffContract value)?  $default,){
final _that = this;
switch (_that) {
case _StaffContract() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int salary,  int yearsRemaining)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffContract() when $default != null:
return $default(_that.salary,_that.yearsRemaining);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int salary,  int yearsRemaining)  $default,) {final _that = this;
switch (_that) {
case _StaffContract():
return $default(_that.salary,_that.yearsRemaining);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int salary,  int yearsRemaining)?  $default,) {final _that = this;
switch (_that) {
case _StaffContract() when $default != null:
return $default(_that.salary,_that.yearsRemaining);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StaffContract implements StaffContract {
  const _StaffContract({required this.salary, required this.yearsRemaining});
  factory _StaffContract.fromJson(Map<String, dynamic> json) => _$StaffContractFromJson(json);

@override final  int salary;
@override final  int yearsRemaining;

/// Create a copy of StaffContract
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffContractCopyWith<_StaffContract> get copyWith => __$StaffContractCopyWithImpl<_StaffContract>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StaffContractToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffContract&&(identical(other.salary, salary) || other.salary == salary)&&(identical(other.yearsRemaining, yearsRemaining) || other.yearsRemaining == yearsRemaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,salary,yearsRemaining);

@override
String toString() {
  return 'StaffContract(salary: $salary, yearsRemaining: $yearsRemaining)';
}


}

/// @nodoc
abstract mixin class _$StaffContractCopyWith<$Res> implements $StaffContractCopyWith<$Res> {
  factory _$StaffContractCopyWith(_StaffContract value, $Res Function(_StaffContract) _then) = __$StaffContractCopyWithImpl;
@override @useResult
$Res call({
 int salary, int yearsRemaining
});




}
/// @nodoc
class __$StaffContractCopyWithImpl<$Res>
    implements _$StaffContractCopyWith<$Res> {
  __$StaffContractCopyWithImpl(this._self, this._then);

  final _StaffContract _self;
  final $Res Function(_StaffContract) _then;

/// Create a copy of StaffContract
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? salary = null,Object? yearsRemaining = null,}) {
  return _then(_StaffContract(
salary: null == salary ? _self.salary : salary // ignore: cast_nullable_to_non_nullable
as int,yearsRemaining: null == yearsRemaining ? _self.yearsRemaining : yearsRemaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$StaffMember {

 String get id; String get name; Nationality get nationality; int get age; StaffRole get role; StaffAttributes get attributes; StaffContract? get contract;/// Previous attributes captured before the last growth tick.
/// Used by the Development screen to compute growth deltas.
 StaffAttributes? get previousAttributes;
/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffMemberCopyWith<StaffMember> get copyWith => _$StaffMemberCopyWithImpl<StaffMember>(this as StaffMember, _$identity);

  /// Serializes this StaffMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffMember&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nationality, nationality) || other.nationality == nationality)&&(identical(other.age, age) || other.age == age)&&(identical(other.role, role) || other.role == role)&&(identical(other.attributes, attributes) || other.attributes == attributes)&&(identical(other.contract, contract) || other.contract == contract)&&(identical(other.previousAttributes, previousAttributes) || other.previousAttributes == previousAttributes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nationality,age,role,attributes,contract,previousAttributes);

@override
String toString() {
  return 'StaffMember(id: $id, name: $name, nationality: $nationality, age: $age, role: $role, attributes: $attributes, contract: $contract, previousAttributes: $previousAttributes)';
}


}

/// @nodoc
abstract mixin class $StaffMemberCopyWith<$Res>  {
  factory $StaffMemberCopyWith(StaffMember value, $Res Function(StaffMember) _then) = _$StaffMemberCopyWithImpl;
@useResult
$Res call({
 String id, String name, Nationality nationality, int age, StaffRole role, StaffAttributes attributes, StaffContract? contract, StaffAttributes? previousAttributes
});


$StaffAttributesCopyWith<$Res> get attributes;$StaffContractCopyWith<$Res>? get contract;$StaffAttributesCopyWith<$Res>? get previousAttributes;

}
/// @nodoc
class _$StaffMemberCopyWithImpl<$Res>
    implements $StaffMemberCopyWith<$Res> {
  _$StaffMemberCopyWithImpl(this._self, this._then);

  final StaffMember _self;
  final $Res Function(StaffMember) _then;

/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? nationality = null,Object? age = null,Object? role = null,Object? attributes = null,Object? contract = freezed,Object? previousAttributes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nationality: null == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as Nationality,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as StaffRole,attributes: null == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as StaffAttributes,contract: freezed == contract ? _self.contract : contract // ignore: cast_nullable_to_non_nullable
as StaffContract?,previousAttributes: freezed == previousAttributes ? _self.previousAttributes : previousAttributes // ignore: cast_nullable_to_non_nullable
as StaffAttributes?,
  ));
}
/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffAttributesCopyWith<$Res> get attributes {
  
  return $StaffAttributesCopyWith<$Res>(_self.attributes, (value) {
    return _then(_self.copyWith(attributes: value));
  });
}/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffContractCopyWith<$Res>? get contract {
    if (_self.contract == null) {
    return null;
  }

  return $StaffContractCopyWith<$Res>(_self.contract!, (value) {
    return _then(_self.copyWith(contract: value));
  });
}/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffAttributesCopyWith<$Res>? get previousAttributes {
    if (_self.previousAttributes == null) {
    return null;
  }

  return $StaffAttributesCopyWith<$Res>(_self.previousAttributes!, (value) {
    return _then(_self.copyWith(previousAttributes: value));
  });
}
}


/// Adds pattern-matching-related methods to [StaffMember].
extension StaffMemberPatterns on StaffMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffMember value)  $default,){
final _that = this;
switch (_that) {
case _StaffMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffMember value)?  $default,){
final _that = this;
switch (_that) {
case _StaffMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  Nationality nationality,  int age,  StaffRole role,  StaffAttributes attributes,  StaffContract? contract,  StaffAttributes? previousAttributes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffMember() when $default != null:
return $default(_that.id,_that.name,_that.nationality,_that.age,_that.role,_that.attributes,_that.contract,_that.previousAttributes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  Nationality nationality,  int age,  StaffRole role,  StaffAttributes attributes,  StaffContract? contract,  StaffAttributes? previousAttributes)  $default,) {final _that = this;
switch (_that) {
case _StaffMember():
return $default(_that.id,_that.name,_that.nationality,_that.age,_that.role,_that.attributes,_that.contract,_that.previousAttributes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  Nationality nationality,  int age,  StaffRole role,  StaffAttributes attributes,  StaffContract? contract,  StaffAttributes? previousAttributes)?  $default,) {final _that = this;
switch (_that) {
case _StaffMember() when $default != null:
return $default(_that.id,_that.name,_that.nationality,_that.age,_that.role,_that.attributes,_that.contract,_that.previousAttributes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StaffMember implements StaffMember {
  const _StaffMember({required this.id, required this.name, required this.nationality, required this.age, required this.role, this.attributes = const StaffAttributes(), this.contract, this.previousAttributes});
  factory _StaffMember.fromJson(Map<String, dynamic> json) => _$StaffMemberFromJson(json);

@override final  String id;
@override final  String name;
@override final  Nationality nationality;
@override final  int age;
@override final  StaffRole role;
@override@JsonKey() final  StaffAttributes attributes;
@override final  StaffContract? contract;
/// Previous attributes captured before the last growth tick.
/// Used by the Development screen to compute growth deltas.
@override final  StaffAttributes? previousAttributes;

/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffMemberCopyWith<_StaffMember> get copyWith => __$StaffMemberCopyWithImpl<_StaffMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StaffMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffMember&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nationality, nationality) || other.nationality == nationality)&&(identical(other.age, age) || other.age == age)&&(identical(other.role, role) || other.role == role)&&(identical(other.attributes, attributes) || other.attributes == attributes)&&(identical(other.contract, contract) || other.contract == contract)&&(identical(other.previousAttributes, previousAttributes) || other.previousAttributes == previousAttributes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nationality,age,role,attributes,contract,previousAttributes);

@override
String toString() {
  return 'StaffMember(id: $id, name: $name, nationality: $nationality, age: $age, role: $role, attributes: $attributes, contract: $contract, previousAttributes: $previousAttributes)';
}


}

/// @nodoc
abstract mixin class _$StaffMemberCopyWith<$Res> implements $StaffMemberCopyWith<$Res> {
  factory _$StaffMemberCopyWith(_StaffMember value, $Res Function(_StaffMember) _then) = __$StaffMemberCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, Nationality nationality, int age, StaffRole role, StaffAttributes attributes, StaffContract? contract, StaffAttributes? previousAttributes
});


@override $StaffAttributesCopyWith<$Res> get attributes;@override $StaffContractCopyWith<$Res>? get contract;@override $StaffAttributesCopyWith<$Res>? get previousAttributes;

}
/// @nodoc
class __$StaffMemberCopyWithImpl<$Res>
    implements _$StaffMemberCopyWith<$Res> {
  __$StaffMemberCopyWithImpl(this._self, this._then);

  final _StaffMember _self;
  final $Res Function(_StaffMember) _then;

/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? nationality = null,Object? age = null,Object? role = null,Object? attributes = null,Object? contract = freezed,Object? previousAttributes = freezed,}) {
  return _then(_StaffMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nationality: null == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as Nationality,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as StaffRole,attributes: null == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as StaffAttributes,contract: freezed == contract ? _self.contract : contract // ignore: cast_nullable_to_non_nullable
as StaffContract?,previousAttributes: freezed == previousAttributes ? _self.previousAttributes : previousAttributes // ignore: cast_nullable_to_non_nullable
as StaffAttributes?,
  ));
}

/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffAttributesCopyWith<$Res> get attributes {
  
  return $StaffAttributesCopyWith<$Res>(_self.attributes, (value) {
    return _then(_self.copyWith(attributes: value));
  });
}/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffContractCopyWith<$Res>? get contract {
    if (_self.contract == null) {
    return null;
  }

  return $StaffContractCopyWith<$Res>(_self.contract!, (value) {
    return _then(_self.copyWith(contract: value));
  });
}/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffAttributesCopyWith<$Res>? get previousAttributes {
    if (_self.previousAttributes == null) {
    return null;
  }

  return $StaffAttributesCopyWith<$Res>(_self.previousAttributes!, (value) {
    return _then(_self.copyWith(previousAttributes: value));
  });
}
}


/// @nodoc
mixin _$TeamStaff {

 StaffMember? get headCoach; StaffMember? get youthCoach; StaffMember? get scout; StaffMember? get physio; StaffMember? get doctor; StaffMember? get cfo;
/// Create a copy of TeamStaff
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TeamStaffCopyWith<TeamStaff> get copyWith => _$TeamStaffCopyWithImpl<TeamStaff>(this as TeamStaff, _$identity);

  /// Serializes this TeamStaff to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TeamStaff&&(identical(other.headCoach, headCoach) || other.headCoach == headCoach)&&(identical(other.youthCoach, youthCoach) || other.youthCoach == youthCoach)&&(identical(other.scout, scout) || other.scout == scout)&&(identical(other.physio, physio) || other.physio == physio)&&(identical(other.doctor, doctor) || other.doctor == doctor)&&(identical(other.cfo, cfo) || other.cfo == cfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,headCoach,youthCoach,scout,physio,doctor,cfo);

@override
String toString() {
  return 'TeamStaff(headCoach: $headCoach, youthCoach: $youthCoach, scout: $scout, physio: $physio, doctor: $doctor, cfo: $cfo)';
}


}

/// @nodoc
abstract mixin class $TeamStaffCopyWith<$Res>  {
  factory $TeamStaffCopyWith(TeamStaff value, $Res Function(TeamStaff) _then) = _$TeamStaffCopyWithImpl;
@useResult
$Res call({
 StaffMember? headCoach, StaffMember? youthCoach, StaffMember? scout, StaffMember? physio, StaffMember? doctor, StaffMember? cfo
});


$StaffMemberCopyWith<$Res>? get headCoach;$StaffMemberCopyWith<$Res>? get youthCoach;$StaffMemberCopyWith<$Res>? get scout;$StaffMemberCopyWith<$Res>? get physio;$StaffMemberCopyWith<$Res>? get doctor;$StaffMemberCopyWith<$Res>? get cfo;

}
/// @nodoc
class _$TeamStaffCopyWithImpl<$Res>
    implements $TeamStaffCopyWith<$Res> {
  _$TeamStaffCopyWithImpl(this._self, this._then);

  final TeamStaff _self;
  final $Res Function(TeamStaff) _then;

/// Create a copy of TeamStaff
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? headCoach = freezed,Object? youthCoach = freezed,Object? scout = freezed,Object? physio = freezed,Object? doctor = freezed,Object? cfo = freezed,}) {
  return _then(_self.copyWith(
headCoach: freezed == headCoach ? _self.headCoach : headCoach // ignore: cast_nullable_to_non_nullable
as StaffMember?,youthCoach: freezed == youthCoach ? _self.youthCoach : youthCoach // ignore: cast_nullable_to_non_nullable
as StaffMember?,scout: freezed == scout ? _self.scout : scout // ignore: cast_nullable_to_non_nullable
as StaffMember?,physio: freezed == physio ? _self.physio : physio // ignore: cast_nullable_to_non_nullable
as StaffMember?,doctor: freezed == doctor ? _self.doctor : doctor // ignore: cast_nullable_to_non_nullable
as StaffMember?,cfo: freezed == cfo ? _self.cfo : cfo // ignore: cast_nullable_to_non_nullable
as StaffMember?,
  ));
}
/// Create a copy of TeamStaff
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffMemberCopyWith<$Res>? get headCoach {
    if (_self.headCoach == null) {
    return null;
  }

  return $StaffMemberCopyWith<$Res>(_self.headCoach!, (value) {
    return _then(_self.copyWith(headCoach: value));
  });
}/// Create a copy of TeamStaff
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffMemberCopyWith<$Res>? get youthCoach {
    if (_self.youthCoach == null) {
    return null;
  }

  return $StaffMemberCopyWith<$Res>(_self.youthCoach!, (value) {
    return _then(_self.copyWith(youthCoach: value));
  });
}/// Create a copy of TeamStaff
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffMemberCopyWith<$Res>? get scout {
    if (_self.scout == null) {
    return null;
  }

  return $StaffMemberCopyWith<$Res>(_self.scout!, (value) {
    return _then(_self.copyWith(scout: value));
  });
}/// Create a copy of TeamStaff
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffMemberCopyWith<$Res>? get physio {
    if (_self.physio == null) {
    return null;
  }

  return $StaffMemberCopyWith<$Res>(_self.physio!, (value) {
    return _then(_self.copyWith(physio: value));
  });
}/// Create a copy of TeamStaff
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffMemberCopyWith<$Res>? get doctor {
    if (_self.doctor == null) {
    return null;
  }

  return $StaffMemberCopyWith<$Res>(_self.doctor!, (value) {
    return _then(_self.copyWith(doctor: value));
  });
}/// Create a copy of TeamStaff
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffMemberCopyWith<$Res>? get cfo {
    if (_self.cfo == null) {
    return null;
  }

  return $StaffMemberCopyWith<$Res>(_self.cfo!, (value) {
    return _then(_self.copyWith(cfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [TeamStaff].
extension TeamStaffPatterns on TeamStaff {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TeamStaff value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TeamStaff() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TeamStaff value)  $default,){
final _that = this;
switch (_that) {
case _TeamStaff():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TeamStaff value)?  $default,){
final _that = this;
switch (_that) {
case _TeamStaff() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StaffMember? headCoach,  StaffMember? youthCoach,  StaffMember? scout,  StaffMember? physio,  StaffMember? doctor,  StaffMember? cfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TeamStaff() when $default != null:
return $default(_that.headCoach,_that.youthCoach,_that.scout,_that.physio,_that.doctor,_that.cfo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StaffMember? headCoach,  StaffMember? youthCoach,  StaffMember? scout,  StaffMember? physio,  StaffMember? doctor,  StaffMember? cfo)  $default,) {final _that = this;
switch (_that) {
case _TeamStaff():
return $default(_that.headCoach,_that.youthCoach,_that.scout,_that.physio,_that.doctor,_that.cfo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StaffMember? headCoach,  StaffMember? youthCoach,  StaffMember? scout,  StaffMember? physio,  StaffMember? doctor,  StaffMember? cfo)?  $default,) {final _that = this;
switch (_that) {
case _TeamStaff() when $default != null:
return $default(_that.headCoach,_that.youthCoach,_that.scout,_that.physio,_that.doctor,_that.cfo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TeamStaff implements TeamStaff {
  const _TeamStaff({this.headCoach, this.youthCoach, this.scout, this.physio, this.doctor, this.cfo});
  factory _TeamStaff.fromJson(Map<String, dynamic> json) => _$TeamStaffFromJson(json);

@override final  StaffMember? headCoach;
@override final  StaffMember? youthCoach;
@override final  StaffMember? scout;
@override final  StaffMember? physio;
@override final  StaffMember? doctor;
@override final  StaffMember? cfo;

/// Create a copy of TeamStaff
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TeamStaffCopyWith<_TeamStaff> get copyWith => __$TeamStaffCopyWithImpl<_TeamStaff>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TeamStaffToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TeamStaff&&(identical(other.headCoach, headCoach) || other.headCoach == headCoach)&&(identical(other.youthCoach, youthCoach) || other.youthCoach == youthCoach)&&(identical(other.scout, scout) || other.scout == scout)&&(identical(other.physio, physio) || other.physio == physio)&&(identical(other.doctor, doctor) || other.doctor == doctor)&&(identical(other.cfo, cfo) || other.cfo == cfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,headCoach,youthCoach,scout,physio,doctor,cfo);

@override
String toString() {
  return 'TeamStaff(headCoach: $headCoach, youthCoach: $youthCoach, scout: $scout, physio: $physio, doctor: $doctor, cfo: $cfo)';
}


}

/// @nodoc
abstract mixin class _$TeamStaffCopyWith<$Res> implements $TeamStaffCopyWith<$Res> {
  factory _$TeamStaffCopyWith(_TeamStaff value, $Res Function(_TeamStaff) _then) = __$TeamStaffCopyWithImpl;
@override @useResult
$Res call({
 StaffMember? headCoach, StaffMember? youthCoach, StaffMember? scout, StaffMember? physio, StaffMember? doctor, StaffMember? cfo
});


@override $StaffMemberCopyWith<$Res>? get headCoach;@override $StaffMemberCopyWith<$Res>? get youthCoach;@override $StaffMemberCopyWith<$Res>? get scout;@override $StaffMemberCopyWith<$Res>? get physio;@override $StaffMemberCopyWith<$Res>? get doctor;@override $StaffMemberCopyWith<$Res>? get cfo;

}
/// @nodoc
class __$TeamStaffCopyWithImpl<$Res>
    implements _$TeamStaffCopyWith<$Res> {
  __$TeamStaffCopyWithImpl(this._self, this._then);

  final _TeamStaff _self;
  final $Res Function(_TeamStaff) _then;

/// Create a copy of TeamStaff
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? headCoach = freezed,Object? youthCoach = freezed,Object? scout = freezed,Object? physio = freezed,Object? doctor = freezed,Object? cfo = freezed,}) {
  return _then(_TeamStaff(
headCoach: freezed == headCoach ? _self.headCoach : headCoach // ignore: cast_nullable_to_non_nullable
as StaffMember?,youthCoach: freezed == youthCoach ? _self.youthCoach : youthCoach // ignore: cast_nullable_to_non_nullable
as StaffMember?,scout: freezed == scout ? _self.scout : scout // ignore: cast_nullable_to_non_nullable
as StaffMember?,physio: freezed == physio ? _self.physio : physio // ignore: cast_nullable_to_non_nullable
as StaffMember?,doctor: freezed == doctor ? _self.doctor : doctor // ignore: cast_nullable_to_non_nullable
as StaffMember?,cfo: freezed == cfo ? _self.cfo : cfo // ignore: cast_nullable_to_non_nullable
as StaffMember?,
  ));
}

/// Create a copy of TeamStaff
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffMemberCopyWith<$Res>? get headCoach {
    if (_self.headCoach == null) {
    return null;
  }

  return $StaffMemberCopyWith<$Res>(_self.headCoach!, (value) {
    return _then(_self.copyWith(headCoach: value));
  });
}/// Create a copy of TeamStaff
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffMemberCopyWith<$Res>? get youthCoach {
    if (_self.youthCoach == null) {
    return null;
  }

  return $StaffMemberCopyWith<$Res>(_self.youthCoach!, (value) {
    return _then(_self.copyWith(youthCoach: value));
  });
}/// Create a copy of TeamStaff
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffMemberCopyWith<$Res>? get scout {
    if (_self.scout == null) {
    return null;
  }

  return $StaffMemberCopyWith<$Res>(_self.scout!, (value) {
    return _then(_self.copyWith(scout: value));
  });
}/// Create a copy of TeamStaff
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffMemberCopyWith<$Res>? get physio {
    if (_self.physio == null) {
    return null;
  }

  return $StaffMemberCopyWith<$Res>(_self.physio!, (value) {
    return _then(_self.copyWith(physio: value));
  });
}/// Create a copy of TeamStaff
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffMemberCopyWith<$Res>? get doctor {
    if (_self.doctor == null) {
    return null;
  }

  return $StaffMemberCopyWith<$Res>(_self.doctor!, (value) {
    return _then(_self.copyWith(doctor: value));
  });
}/// Create a copy of TeamStaff
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StaffMemberCopyWith<$Res>? get cfo {
    if (_self.cfo == null) {
    return null;
  }

  return $StaffMemberCopyWith<$Res>(_self.cfo!, (value) {
    return _then(_self.copyWith(cfo: value));
  });
}
}

// dart format on
