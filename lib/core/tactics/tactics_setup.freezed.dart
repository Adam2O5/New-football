// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tactics_setup.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MidfieldSlots _$MidfieldSlotsFromJson(Map<String, dynamic> json) {
  return _MidfieldSlots.fromJson(json);
}

/// @nodoc
mixin _$MidfieldSlots {
  int get cdm => throw _privateConstructorUsedError;
  int get cm => throw _privateConstructorUsedError;
  int get cam => throw _privateConstructorUsedError;

  /// Serializes this MidfieldSlots to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MidfieldSlots
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MidfieldSlotsCopyWith<MidfieldSlots> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MidfieldSlotsCopyWith<$Res> {
  factory $MidfieldSlotsCopyWith(
    MidfieldSlots value,
    $Res Function(MidfieldSlots) then,
  ) = _$MidfieldSlotsCopyWithImpl<$Res, MidfieldSlots>;
  @useResult
  $Res call({int cdm, int cm, int cam});
}

/// @nodoc
class _$MidfieldSlotsCopyWithImpl<$Res, $Val extends MidfieldSlots>
    implements $MidfieldSlotsCopyWith<$Res> {
  _$MidfieldSlotsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MidfieldSlots
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? cdm = null, Object? cm = null, Object? cam = null}) {
    return _then(
      _value.copyWith(
            cdm: null == cdm
                ? _value.cdm
                : cdm // ignore: cast_nullable_to_non_nullable
                      as int,
            cm: null == cm
                ? _value.cm
                : cm // ignore: cast_nullable_to_non_nullable
                      as int,
            cam: null == cam
                ? _value.cam
                : cam // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MidfieldSlotsImplCopyWith<$Res>
    implements $MidfieldSlotsCopyWith<$Res> {
  factory _$$MidfieldSlotsImplCopyWith(
    _$MidfieldSlotsImpl value,
    $Res Function(_$MidfieldSlotsImpl) then,
  ) = __$$MidfieldSlotsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int cdm, int cm, int cam});
}

/// @nodoc
class __$$MidfieldSlotsImplCopyWithImpl<$Res>
    extends _$MidfieldSlotsCopyWithImpl<$Res, _$MidfieldSlotsImpl>
    implements _$$MidfieldSlotsImplCopyWith<$Res> {
  __$$MidfieldSlotsImplCopyWithImpl(
    _$MidfieldSlotsImpl _value,
    $Res Function(_$MidfieldSlotsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MidfieldSlots
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? cdm = null, Object? cm = null, Object? cam = null}) {
    return _then(
      _$MidfieldSlotsImpl(
        cdm: null == cdm
            ? _value.cdm
            : cdm // ignore: cast_nullable_to_non_nullable
                  as int,
        cm: null == cm
            ? _value.cm
            : cm // ignore: cast_nullable_to_non_nullable
                  as int,
        cam: null == cam
            ? _value.cam
            : cam // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MidfieldSlotsImpl implements _MidfieldSlots {
  const _$MidfieldSlotsImpl({this.cdm = 1, this.cm = 1, this.cam = 1});

  factory _$MidfieldSlotsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MidfieldSlotsImplFromJson(json);

  @override
  @JsonKey()
  final int cdm;
  @override
  @JsonKey()
  final int cm;
  @override
  @JsonKey()
  final int cam;

  @override
  String toString() {
    return 'MidfieldSlots(cdm: $cdm, cm: $cm, cam: $cam)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MidfieldSlotsImpl &&
            (identical(other.cdm, cdm) || other.cdm == cdm) &&
            (identical(other.cm, cm) || other.cm == cm) &&
            (identical(other.cam, cam) || other.cam == cam));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, cdm, cm, cam);

  /// Create a copy of MidfieldSlots
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MidfieldSlotsImplCopyWith<_$MidfieldSlotsImpl> get copyWith =>
      __$$MidfieldSlotsImplCopyWithImpl<_$MidfieldSlotsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MidfieldSlotsImplToJson(this);
  }
}

abstract class _MidfieldSlots implements MidfieldSlots {
  const factory _MidfieldSlots({final int cdm, final int cm, final int cam}) =
      _$MidfieldSlotsImpl;

  factory _MidfieldSlots.fromJson(Map<String, dynamic> json) =
      _$MidfieldSlotsImpl.fromJson;

  @override
  int get cdm;
  @override
  int get cm;
  @override
  int get cam;

  /// Create a copy of MidfieldSlots
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MidfieldSlotsImplCopyWith<_$MidfieldSlotsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TacticsSetup _$TacticsSetupFromJson(Map<String, dynamic> json) {
  return _TacticsSetup.fromJson(json);
}

/// @nodoc
mixin _$TacticsSetup {
  Formation get formation => throw _privateConstructorUsedError;
  MidfieldSlots? get midfieldSlots => throw _privateConstructorUsedError;
  Tempo get tempo => throw _privateConstructorUsedError;
  AttackWidth get attackWidth => throw _privateConstructorUsedError;
  DefensiveLine get defensiveLine => throw _privateConstructorUsedError;
  PressingIntensity get pressing => throw _privateConstructorUsedError;
  int get cornersAttack => throw _privateConstructorUsedError;
  int get cornersDefense => throw _privateConstructorUsedError;
  int get freeKicks => throw _privateConstructorUsedError;
  int get penalties => throw _privateConstructorUsedError;

  /// Serializes this TacticsSetup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TacticsSetup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TacticsSetupCopyWith<TacticsSetup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TacticsSetupCopyWith<$Res> {
  factory $TacticsSetupCopyWith(
    TacticsSetup value,
    $Res Function(TacticsSetup) then,
  ) = _$TacticsSetupCopyWithImpl<$Res, TacticsSetup>;
  @useResult
  $Res call({
    Formation formation,
    MidfieldSlots? midfieldSlots,
    Tempo tempo,
    AttackWidth attackWidth,
    DefensiveLine defensiveLine,
    PressingIntensity pressing,
    int cornersAttack,
    int cornersDefense,
    int freeKicks,
    int penalties,
  });

  $MidfieldSlotsCopyWith<$Res>? get midfieldSlots;
}

/// @nodoc
class _$TacticsSetupCopyWithImpl<$Res, $Val extends TacticsSetup>
    implements $TacticsSetupCopyWith<$Res> {
  _$TacticsSetupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TacticsSetup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? formation = null,
    Object? midfieldSlots = freezed,
    Object? tempo = null,
    Object? attackWidth = null,
    Object? defensiveLine = null,
    Object? pressing = null,
    Object? cornersAttack = null,
    Object? cornersDefense = null,
    Object? freeKicks = null,
    Object? penalties = null,
  }) {
    return _then(
      _value.copyWith(
            formation: null == formation
                ? _value.formation
                : formation // ignore: cast_nullable_to_non_nullable
                      as Formation,
            midfieldSlots: freezed == midfieldSlots
                ? _value.midfieldSlots
                : midfieldSlots // ignore: cast_nullable_to_non_nullable
                      as MidfieldSlots?,
            tempo: null == tempo
                ? _value.tempo
                : tempo // ignore: cast_nullable_to_non_nullable
                      as Tempo,
            attackWidth: null == attackWidth
                ? _value.attackWidth
                : attackWidth // ignore: cast_nullable_to_non_nullable
                      as AttackWidth,
            defensiveLine: null == defensiveLine
                ? _value.defensiveLine
                : defensiveLine // ignore: cast_nullable_to_non_nullable
                      as DefensiveLine,
            pressing: null == pressing
                ? _value.pressing
                : pressing // ignore: cast_nullable_to_non_nullable
                      as PressingIntensity,
            cornersAttack: null == cornersAttack
                ? _value.cornersAttack
                : cornersAttack // ignore: cast_nullable_to_non_nullable
                      as int,
            cornersDefense: null == cornersDefense
                ? _value.cornersDefense
                : cornersDefense // ignore: cast_nullable_to_non_nullable
                      as int,
            freeKicks: null == freeKicks
                ? _value.freeKicks
                : freeKicks // ignore: cast_nullable_to_non_nullable
                      as int,
            penalties: null == penalties
                ? _value.penalties
                : penalties // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of TacticsSetup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MidfieldSlotsCopyWith<$Res>? get midfieldSlots {
    if (_value.midfieldSlots == null) {
      return null;
    }

    return $MidfieldSlotsCopyWith<$Res>(_value.midfieldSlots!, (value) {
      return _then(_value.copyWith(midfieldSlots: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TacticsSetupImplCopyWith<$Res>
    implements $TacticsSetupCopyWith<$Res> {
  factory _$$TacticsSetupImplCopyWith(
    _$TacticsSetupImpl value,
    $Res Function(_$TacticsSetupImpl) then,
  ) = __$$TacticsSetupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Formation formation,
    MidfieldSlots? midfieldSlots,
    Tempo tempo,
    AttackWidth attackWidth,
    DefensiveLine defensiveLine,
    PressingIntensity pressing,
    int cornersAttack,
    int cornersDefense,
    int freeKicks,
    int penalties,
  });

  @override
  $MidfieldSlotsCopyWith<$Res>? get midfieldSlots;
}

/// @nodoc
class __$$TacticsSetupImplCopyWithImpl<$Res>
    extends _$TacticsSetupCopyWithImpl<$Res, _$TacticsSetupImpl>
    implements _$$TacticsSetupImplCopyWith<$Res> {
  __$$TacticsSetupImplCopyWithImpl(
    _$TacticsSetupImpl _value,
    $Res Function(_$TacticsSetupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TacticsSetup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? formation = null,
    Object? midfieldSlots = freezed,
    Object? tempo = null,
    Object? attackWidth = null,
    Object? defensiveLine = null,
    Object? pressing = null,
    Object? cornersAttack = null,
    Object? cornersDefense = null,
    Object? freeKicks = null,
    Object? penalties = null,
  }) {
    return _then(
      _$TacticsSetupImpl(
        formation: null == formation
            ? _value.formation
            : formation // ignore: cast_nullable_to_non_nullable
                  as Formation,
        midfieldSlots: freezed == midfieldSlots
            ? _value.midfieldSlots
            : midfieldSlots // ignore: cast_nullable_to_non_nullable
                  as MidfieldSlots?,
        tempo: null == tempo
            ? _value.tempo
            : tempo // ignore: cast_nullable_to_non_nullable
                  as Tempo,
        attackWidth: null == attackWidth
            ? _value.attackWidth
            : attackWidth // ignore: cast_nullable_to_non_nullable
                  as AttackWidth,
        defensiveLine: null == defensiveLine
            ? _value.defensiveLine
            : defensiveLine // ignore: cast_nullable_to_non_nullable
                  as DefensiveLine,
        pressing: null == pressing
            ? _value.pressing
            : pressing // ignore: cast_nullable_to_non_nullable
                  as PressingIntensity,
        cornersAttack: null == cornersAttack
            ? _value.cornersAttack
            : cornersAttack // ignore: cast_nullable_to_non_nullable
                  as int,
        cornersDefense: null == cornersDefense
            ? _value.cornersDefense
            : cornersDefense // ignore: cast_nullable_to_non_nullable
                  as int,
        freeKicks: null == freeKicks
            ? _value.freeKicks
            : freeKicks // ignore: cast_nullable_to_non_nullable
                  as int,
        penalties: null == penalties
            ? _value.penalties
            : penalties // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TacticsSetupImpl implements _TacticsSetup {
  const _$TacticsSetupImpl({
    this.formation = Formation.f433,
    this.midfieldSlots,
    this.tempo = Tempo.balanced,
    this.attackWidth = AttackWidth.balanced,
    this.defensiveLine = DefensiveLine.normal,
    this.pressing = PressingIntensity.medium,
    this.cornersAttack = 50,
    this.cornersDefense = 50,
    this.freeKicks = 30,
    this.penalties = 80,
  });

  factory _$TacticsSetupImpl.fromJson(Map<String, dynamic> json) =>
      _$$TacticsSetupImplFromJson(json);

  @override
  @JsonKey()
  final Formation formation;
  @override
  final MidfieldSlots? midfieldSlots;
  @override
  @JsonKey()
  final Tempo tempo;
  @override
  @JsonKey()
  final AttackWidth attackWidth;
  @override
  @JsonKey()
  final DefensiveLine defensiveLine;
  @override
  @JsonKey()
  final PressingIntensity pressing;
  @override
  @JsonKey()
  final int cornersAttack;
  @override
  @JsonKey()
  final int cornersDefense;
  @override
  @JsonKey()
  final int freeKicks;
  @override
  @JsonKey()
  final int penalties;

  @override
  String toString() {
    return 'TacticsSetup(formation: $formation, midfieldSlots: $midfieldSlots, tempo: $tempo, attackWidth: $attackWidth, defensiveLine: $defensiveLine, pressing: $pressing, cornersAttack: $cornersAttack, cornersDefense: $cornersDefense, freeKicks: $freeKicks, penalties: $penalties)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TacticsSetupImpl &&
            (identical(other.formation, formation) ||
                other.formation == formation) &&
            (identical(other.midfieldSlots, midfieldSlots) ||
                other.midfieldSlots == midfieldSlots) &&
            (identical(other.tempo, tempo) || other.tempo == tempo) &&
            (identical(other.attackWidth, attackWidth) ||
                other.attackWidth == attackWidth) &&
            (identical(other.defensiveLine, defensiveLine) ||
                other.defensiveLine == defensiveLine) &&
            (identical(other.pressing, pressing) ||
                other.pressing == pressing) &&
            (identical(other.cornersAttack, cornersAttack) ||
                other.cornersAttack == cornersAttack) &&
            (identical(other.cornersDefense, cornersDefense) ||
                other.cornersDefense == cornersDefense) &&
            (identical(other.freeKicks, freeKicks) ||
                other.freeKicks == freeKicks) &&
            (identical(other.penalties, penalties) ||
                other.penalties == penalties));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    formation,
    midfieldSlots,
    tempo,
    attackWidth,
    defensiveLine,
    pressing,
    cornersAttack,
    cornersDefense,
    freeKicks,
    penalties,
  );

  /// Create a copy of TacticsSetup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TacticsSetupImplCopyWith<_$TacticsSetupImpl> get copyWith =>
      __$$TacticsSetupImplCopyWithImpl<_$TacticsSetupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TacticsSetupImplToJson(this);
  }
}

abstract class _TacticsSetup implements TacticsSetup {
  const factory _TacticsSetup({
    final Formation formation,
    final MidfieldSlots? midfieldSlots,
    final Tempo tempo,
    final AttackWidth attackWidth,
    final DefensiveLine defensiveLine,
    final PressingIntensity pressing,
    final int cornersAttack,
    final int cornersDefense,
    final int freeKicks,
    final int penalties,
  }) = _$TacticsSetupImpl;

  factory _TacticsSetup.fromJson(Map<String, dynamic> json) =
      _$TacticsSetupImpl.fromJson;

  @override
  Formation get formation;
  @override
  MidfieldSlots? get midfieldSlots;
  @override
  Tempo get tempo;
  @override
  AttackWidth get attackWidth;
  @override
  DefensiveLine get defensiveLine;
  @override
  PressingIntensity get pressing;
  @override
  int get cornersAttack;
  @override
  int get cornersDefense;
  @override
  int get freeKicks;
  @override
  int get penalties;

  /// Create a copy of TacticsSetup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TacticsSetupImplCopyWith<_$TacticsSetupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
