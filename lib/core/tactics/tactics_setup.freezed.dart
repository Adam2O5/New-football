// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tactics_setup.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TacticsSetup {

 Formation get formation; Tempo get tempo; AttackWidth get attackWidth; DefensiveLine get defensiveLine; PressingIntensity get pressing; int get cornersAttack; int get cornersDefense; int get freeKicks; int get penalties;
/// Create a copy of TacticsSetup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TacticsSetupCopyWith<TacticsSetup> get copyWith => _$TacticsSetupCopyWithImpl<TacticsSetup>(this as TacticsSetup, _$identity);

  /// Serializes this TacticsSetup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TacticsSetup&&(identical(other.formation, formation) || other.formation == formation)&&(identical(other.tempo, tempo) || other.tempo == tempo)&&(identical(other.attackWidth, attackWidth) || other.attackWidth == attackWidth)&&(identical(other.defensiveLine, defensiveLine) || other.defensiveLine == defensiveLine)&&(identical(other.pressing, pressing) || other.pressing == pressing)&&(identical(other.cornersAttack, cornersAttack) || other.cornersAttack == cornersAttack)&&(identical(other.cornersDefense, cornersDefense) || other.cornersDefense == cornersDefense)&&(identical(other.freeKicks, freeKicks) || other.freeKicks == freeKicks)&&(identical(other.penalties, penalties) || other.penalties == penalties));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,formation,tempo,attackWidth,defensiveLine,pressing,cornersAttack,cornersDefense,freeKicks,penalties);

@override
String toString() {
  return 'TacticsSetup(formation: $formation, tempo: $tempo, attackWidth: $attackWidth, defensiveLine: $defensiveLine, pressing: $pressing, cornersAttack: $cornersAttack, cornersDefense: $cornersDefense, freeKicks: $freeKicks, penalties: $penalties)';
}


}

/// @nodoc
abstract mixin class $TacticsSetupCopyWith<$Res>  {
  factory $TacticsSetupCopyWith(TacticsSetup value, $Res Function(TacticsSetup) _then) = _$TacticsSetupCopyWithImpl;
@useResult
$Res call({
 Formation formation, Tempo tempo, AttackWidth attackWidth, DefensiveLine defensiveLine, PressingIntensity pressing, int cornersAttack, int cornersDefense, int freeKicks, int penalties
});




}
/// @nodoc
class _$TacticsSetupCopyWithImpl<$Res>
    implements $TacticsSetupCopyWith<$Res> {
  _$TacticsSetupCopyWithImpl(this._self, this._then);

  final TacticsSetup _self;
  final $Res Function(TacticsSetup) _then;

/// Create a copy of TacticsSetup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? formation = null,Object? tempo = null,Object? attackWidth = null,Object? defensiveLine = null,Object? pressing = null,Object? cornersAttack = null,Object? cornersDefense = null,Object? freeKicks = null,Object? penalties = null,}) {
  return _then(_self.copyWith(
formation: null == formation ? _self.formation : formation // ignore: cast_nullable_to_non_nullable
as Formation,tempo: null == tempo ? _self.tempo : tempo // ignore: cast_nullable_to_non_nullable
as Tempo,attackWidth: null == attackWidth ? _self.attackWidth : attackWidth // ignore: cast_nullable_to_non_nullable
as AttackWidth,defensiveLine: null == defensiveLine ? _self.defensiveLine : defensiveLine // ignore: cast_nullable_to_non_nullable
as DefensiveLine,pressing: null == pressing ? _self.pressing : pressing // ignore: cast_nullable_to_non_nullable
as PressingIntensity,cornersAttack: null == cornersAttack ? _self.cornersAttack : cornersAttack // ignore: cast_nullable_to_non_nullable
as int,cornersDefense: null == cornersDefense ? _self.cornersDefense : cornersDefense // ignore: cast_nullable_to_non_nullable
as int,freeKicks: null == freeKicks ? _self.freeKicks : freeKicks // ignore: cast_nullable_to_non_nullable
as int,penalties: null == penalties ? _self.penalties : penalties // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TacticsSetup].
extension TacticsSetupPatterns on TacticsSetup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TacticsSetup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TacticsSetup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TacticsSetup value)  $default,){
final _that = this;
switch (_that) {
case _TacticsSetup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TacticsSetup value)?  $default,){
final _that = this;
switch (_that) {
case _TacticsSetup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Formation formation,  Tempo tempo,  AttackWidth attackWidth,  DefensiveLine defensiveLine,  PressingIntensity pressing,  int cornersAttack,  int cornersDefense,  int freeKicks,  int penalties)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TacticsSetup() when $default != null:
return $default(_that.formation,_that.tempo,_that.attackWidth,_that.defensiveLine,_that.pressing,_that.cornersAttack,_that.cornersDefense,_that.freeKicks,_that.penalties);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Formation formation,  Tempo tempo,  AttackWidth attackWidth,  DefensiveLine defensiveLine,  PressingIntensity pressing,  int cornersAttack,  int cornersDefense,  int freeKicks,  int penalties)  $default,) {final _that = this;
switch (_that) {
case _TacticsSetup():
return $default(_that.formation,_that.tempo,_that.attackWidth,_that.defensiveLine,_that.pressing,_that.cornersAttack,_that.cornersDefense,_that.freeKicks,_that.penalties);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Formation formation,  Tempo tempo,  AttackWidth attackWidth,  DefensiveLine defensiveLine,  PressingIntensity pressing,  int cornersAttack,  int cornersDefense,  int freeKicks,  int penalties)?  $default,) {final _that = this;
switch (_that) {
case _TacticsSetup() when $default != null:
return $default(_that.formation,_that.tempo,_that.attackWidth,_that.defensiveLine,_that.pressing,_that.cornersAttack,_that.cornersDefense,_that.freeKicks,_that.penalties);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TacticsSetup implements TacticsSetup {
  const _TacticsSetup({this.formation = Formation.f433, this.tempo = Tempo.balanced, this.attackWidth = AttackWidth.balanced, this.defensiveLine = DefensiveLine.normal, this.pressing = PressingIntensity.medium, this.cornersAttack = 50, this.cornersDefense = 50, this.freeKicks = 30, this.penalties = 80});
  factory _TacticsSetup.fromJson(Map<String, dynamic> json) => _$TacticsSetupFromJson(json);

@override@JsonKey() final  Formation formation;
@override@JsonKey() final  Tempo tempo;
@override@JsonKey() final  AttackWidth attackWidth;
@override@JsonKey() final  DefensiveLine defensiveLine;
@override@JsonKey() final  PressingIntensity pressing;
@override@JsonKey() final  int cornersAttack;
@override@JsonKey() final  int cornersDefense;
@override@JsonKey() final  int freeKicks;
@override@JsonKey() final  int penalties;

/// Create a copy of TacticsSetup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TacticsSetupCopyWith<_TacticsSetup> get copyWith => __$TacticsSetupCopyWithImpl<_TacticsSetup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TacticsSetupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TacticsSetup&&(identical(other.formation, formation) || other.formation == formation)&&(identical(other.tempo, tempo) || other.tempo == tempo)&&(identical(other.attackWidth, attackWidth) || other.attackWidth == attackWidth)&&(identical(other.defensiveLine, defensiveLine) || other.defensiveLine == defensiveLine)&&(identical(other.pressing, pressing) || other.pressing == pressing)&&(identical(other.cornersAttack, cornersAttack) || other.cornersAttack == cornersAttack)&&(identical(other.cornersDefense, cornersDefense) || other.cornersDefense == cornersDefense)&&(identical(other.freeKicks, freeKicks) || other.freeKicks == freeKicks)&&(identical(other.penalties, penalties) || other.penalties == penalties));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,formation,tempo,attackWidth,defensiveLine,pressing,cornersAttack,cornersDefense,freeKicks,penalties);

@override
String toString() {
  return 'TacticsSetup(formation: $formation, tempo: $tempo, attackWidth: $attackWidth, defensiveLine: $defensiveLine, pressing: $pressing, cornersAttack: $cornersAttack, cornersDefense: $cornersDefense, freeKicks: $freeKicks, penalties: $penalties)';
}


}

/// @nodoc
abstract mixin class _$TacticsSetupCopyWith<$Res> implements $TacticsSetupCopyWith<$Res> {
  factory _$TacticsSetupCopyWith(_TacticsSetup value, $Res Function(_TacticsSetup) _then) = __$TacticsSetupCopyWithImpl;
@override @useResult
$Res call({
 Formation formation, Tempo tempo, AttackWidth attackWidth, DefensiveLine defensiveLine, PressingIntensity pressing, int cornersAttack, int cornersDefense, int freeKicks, int penalties
});




}
/// @nodoc
class __$TacticsSetupCopyWithImpl<$Res>
    implements _$TacticsSetupCopyWith<$Res> {
  __$TacticsSetupCopyWithImpl(this._self, this._then);

  final _TacticsSetup _self;
  final $Res Function(_TacticsSetup) _then;

/// Create a copy of TacticsSetup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? formation = null,Object? tempo = null,Object? attackWidth = null,Object? defensiveLine = null,Object? pressing = null,Object? cornersAttack = null,Object? cornersDefense = null,Object? freeKicks = null,Object? penalties = null,}) {
  return _then(_TacticsSetup(
formation: null == formation ? _self.formation : formation // ignore: cast_nullable_to_non_nullable
as Formation,tempo: null == tempo ? _self.tempo : tempo // ignore: cast_nullable_to_non_nullable
as Tempo,attackWidth: null == attackWidth ? _self.attackWidth : attackWidth // ignore: cast_nullable_to_non_nullable
as AttackWidth,defensiveLine: null == defensiveLine ? _self.defensiveLine : defensiveLine // ignore: cast_nullable_to_non_nullable
as DefensiveLine,pressing: null == pressing ? _self.pressing : pressing // ignore: cast_nullable_to_non_nullable
as PressingIntensity,cornersAttack: null == cornersAttack ? _self.cornersAttack : cornersAttack // ignore: cast_nullable_to_non_nullable
as int,cornersDefense: null == cornersDefense ? _self.cornersDefense : cornersDefense // ignore: cast_nullable_to_non_nullable
as int,freeKicks: null == freeKicks ? _self.freeKicks : freeKicks // ignore: cast_nullable_to_non_nullable
as int,penalties: null == penalties ? _self.penalties : penalties // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
