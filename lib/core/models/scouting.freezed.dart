// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scouting.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ScoutingKnowledge _$ScoutingKnowledgeFromJson(Map<String, dynamic> json) {
  return _ScoutingKnowledge.fromJson(json);
}

/// @nodoc
mixin _$ScoutingKnowledge {
  String get prospectId => throw _privateConstructorUsedError;
  ScoutingTier get tier => throw _privateConstructorUsedError;
  EstimatedDraftSlot? get estimatedSlot => throw _privateConstructorUsedError;
  bool get injuryProneKnown => throw _privateConstructorUsedError;
  bool get determinationKnown => throw _privateConstructorUsedError;

  /// Serializes this ScoutingKnowledge to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScoutingKnowledge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScoutingKnowledgeCopyWith<ScoutingKnowledge> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScoutingKnowledgeCopyWith<$Res> {
  factory $ScoutingKnowledgeCopyWith(
    ScoutingKnowledge value,
    $Res Function(ScoutingKnowledge) then,
  ) = _$ScoutingKnowledgeCopyWithImpl<$Res, ScoutingKnowledge>;
  @useResult
  $Res call({
    String prospectId,
    ScoutingTier tier,
    EstimatedDraftSlot? estimatedSlot,
    bool injuryProneKnown,
    bool determinationKnown,
  });
}

/// @nodoc
class _$ScoutingKnowledgeCopyWithImpl<$Res, $Val extends ScoutingKnowledge>
    implements $ScoutingKnowledgeCopyWith<$Res> {
  _$ScoutingKnowledgeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScoutingKnowledge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prospectId = null,
    Object? tier = null,
    Object? estimatedSlot = freezed,
    Object? injuryProneKnown = null,
    Object? determinationKnown = null,
  }) {
    return _then(
      _value.copyWith(
            prospectId: null == prospectId
                ? _value.prospectId
                : prospectId // ignore: cast_nullable_to_non_nullable
                      as String,
            tier: null == tier
                ? _value.tier
                : tier // ignore: cast_nullable_to_non_nullable
                      as ScoutingTier,
            estimatedSlot: freezed == estimatedSlot
                ? _value.estimatedSlot
                : estimatedSlot // ignore: cast_nullable_to_non_nullable
                      as EstimatedDraftSlot?,
            injuryProneKnown: null == injuryProneKnown
                ? _value.injuryProneKnown
                : injuryProneKnown // ignore: cast_nullable_to_non_nullable
                      as bool,
            determinationKnown: null == determinationKnown
                ? _value.determinationKnown
                : determinationKnown // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScoutingKnowledgeImplCopyWith<$Res>
    implements $ScoutingKnowledgeCopyWith<$Res> {
  factory _$$ScoutingKnowledgeImplCopyWith(
    _$ScoutingKnowledgeImpl value,
    $Res Function(_$ScoutingKnowledgeImpl) then,
  ) = __$$ScoutingKnowledgeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String prospectId,
    ScoutingTier tier,
    EstimatedDraftSlot? estimatedSlot,
    bool injuryProneKnown,
    bool determinationKnown,
  });
}

/// @nodoc
class __$$ScoutingKnowledgeImplCopyWithImpl<$Res>
    extends _$ScoutingKnowledgeCopyWithImpl<$Res, _$ScoutingKnowledgeImpl>
    implements _$$ScoutingKnowledgeImplCopyWith<$Res> {
  __$$ScoutingKnowledgeImplCopyWithImpl(
    _$ScoutingKnowledgeImpl _value,
    $Res Function(_$ScoutingKnowledgeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScoutingKnowledge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prospectId = null,
    Object? tier = null,
    Object? estimatedSlot = freezed,
    Object? injuryProneKnown = null,
    Object? determinationKnown = null,
  }) {
    return _then(
      _$ScoutingKnowledgeImpl(
        prospectId: null == prospectId
            ? _value.prospectId
            : prospectId // ignore: cast_nullable_to_non_nullable
                  as String,
        tier: null == tier
            ? _value.tier
            : tier // ignore: cast_nullable_to_non_nullable
                  as ScoutingTier,
        estimatedSlot: freezed == estimatedSlot
            ? _value.estimatedSlot
            : estimatedSlot // ignore: cast_nullable_to_non_nullable
                  as EstimatedDraftSlot?,
        injuryProneKnown: null == injuryProneKnown
            ? _value.injuryProneKnown
            : injuryProneKnown // ignore: cast_nullable_to_non_nullable
                  as bool,
        determinationKnown: null == determinationKnown
            ? _value.determinationKnown
            : determinationKnown // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScoutingKnowledgeImpl implements _ScoutingKnowledge {
  const _$ScoutingKnowledgeImpl({
    required this.prospectId,
    this.tier = ScoutingTier.tier1,
    this.estimatedSlot,
    this.injuryProneKnown = false,
    this.determinationKnown = false,
  });

  factory _$ScoutingKnowledgeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScoutingKnowledgeImplFromJson(json);

  @override
  final String prospectId;
  @override
  @JsonKey()
  final ScoutingTier tier;
  @override
  final EstimatedDraftSlot? estimatedSlot;
  @override
  @JsonKey()
  final bool injuryProneKnown;
  @override
  @JsonKey()
  final bool determinationKnown;

  @override
  String toString() {
    return 'ScoutingKnowledge(prospectId: $prospectId, tier: $tier, estimatedSlot: $estimatedSlot, injuryProneKnown: $injuryProneKnown, determinationKnown: $determinationKnown)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScoutingKnowledgeImpl &&
            (identical(other.prospectId, prospectId) ||
                other.prospectId == prospectId) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.estimatedSlot, estimatedSlot) ||
                other.estimatedSlot == estimatedSlot) &&
            (identical(other.injuryProneKnown, injuryProneKnown) ||
                other.injuryProneKnown == injuryProneKnown) &&
            (identical(other.determinationKnown, determinationKnown) ||
                other.determinationKnown == determinationKnown));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    prospectId,
    tier,
    estimatedSlot,
    injuryProneKnown,
    determinationKnown,
  );

  /// Create a copy of ScoutingKnowledge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScoutingKnowledgeImplCopyWith<_$ScoutingKnowledgeImpl> get copyWith =>
      __$$ScoutingKnowledgeImplCopyWithImpl<_$ScoutingKnowledgeImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ScoutingKnowledgeImplToJson(this);
  }
}

abstract class _ScoutingKnowledge implements ScoutingKnowledge {
  const factory _ScoutingKnowledge({
    required final String prospectId,
    final ScoutingTier tier,
    final EstimatedDraftSlot? estimatedSlot,
    final bool injuryProneKnown,
    final bool determinationKnown,
  }) = _$ScoutingKnowledgeImpl;

  factory _ScoutingKnowledge.fromJson(Map<String, dynamic> json) =
      _$ScoutingKnowledgeImpl.fromJson;

  @override
  String get prospectId;
  @override
  ScoutingTier get tier;
  @override
  EstimatedDraftSlot? get estimatedSlot;
  @override
  bool get injuryProneKnown;
  @override
  bool get determinationKnown;

  /// Create a copy of ScoutingKnowledge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScoutingKnowledgeImplCopyWith<_$ScoutingKnowledgeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TeamScouting _$TeamScoutingFromJson(Map<String, dynamic> json) {
  return _TeamScouting.fromJson(json);
}

/// @nodoc
mixin _$TeamScouting {
  List<String> get watchlistProspectIds => throw _privateConstructorUsedError;
  List<ScoutingKnowledge> get knowledge => throw _privateConstructorUsedError;
  List<String> get combineAssignedProspectIds =>
      throw _privateConstructorUsedError;

  /// Serializes this TeamScouting to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeamScouting
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamScoutingCopyWith<TeamScouting> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamScoutingCopyWith<$Res> {
  factory $TeamScoutingCopyWith(
    TeamScouting value,
    $Res Function(TeamScouting) then,
  ) = _$TeamScoutingCopyWithImpl<$Res, TeamScouting>;
  @useResult
  $Res call({
    List<String> watchlistProspectIds,
    List<ScoutingKnowledge> knowledge,
    List<String> combineAssignedProspectIds,
  });
}

/// @nodoc
class _$TeamScoutingCopyWithImpl<$Res, $Val extends TeamScouting>
    implements $TeamScoutingCopyWith<$Res> {
  _$TeamScoutingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeamScouting
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? watchlistProspectIds = null,
    Object? knowledge = null,
    Object? combineAssignedProspectIds = null,
  }) {
    return _then(
      _value.copyWith(
            watchlistProspectIds: null == watchlistProspectIds
                ? _value.watchlistProspectIds
                : watchlistProspectIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            knowledge: null == knowledge
                ? _value.knowledge
                : knowledge // ignore: cast_nullable_to_non_nullable
                      as List<ScoutingKnowledge>,
            combineAssignedProspectIds: null == combineAssignedProspectIds
                ? _value.combineAssignedProspectIds
                : combineAssignedProspectIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeamScoutingImplCopyWith<$Res>
    implements $TeamScoutingCopyWith<$Res> {
  factory _$$TeamScoutingImplCopyWith(
    _$TeamScoutingImpl value,
    $Res Function(_$TeamScoutingImpl) then,
  ) = __$$TeamScoutingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<String> watchlistProspectIds,
    List<ScoutingKnowledge> knowledge,
    List<String> combineAssignedProspectIds,
  });
}

/// @nodoc
class __$$TeamScoutingImplCopyWithImpl<$Res>
    extends _$TeamScoutingCopyWithImpl<$Res, _$TeamScoutingImpl>
    implements _$$TeamScoutingImplCopyWith<$Res> {
  __$$TeamScoutingImplCopyWithImpl(
    _$TeamScoutingImpl _value,
    $Res Function(_$TeamScoutingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeamScouting
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? watchlistProspectIds = null,
    Object? knowledge = null,
    Object? combineAssignedProspectIds = null,
  }) {
    return _then(
      _$TeamScoutingImpl(
        watchlistProspectIds: null == watchlistProspectIds
            ? _value._watchlistProspectIds
            : watchlistProspectIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        knowledge: null == knowledge
            ? _value._knowledge
            : knowledge // ignore: cast_nullable_to_non_nullable
                  as List<ScoutingKnowledge>,
        combineAssignedProspectIds: null == combineAssignedProspectIds
            ? _value._combineAssignedProspectIds
            : combineAssignedProspectIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamScoutingImpl implements _TeamScouting {
  const _$TeamScoutingImpl({
    final List<String> watchlistProspectIds = const [],
    final List<ScoutingKnowledge> knowledge = const [],
    final List<String> combineAssignedProspectIds = const [],
  }) : _watchlistProspectIds = watchlistProspectIds,
       _knowledge = knowledge,
       _combineAssignedProspectIds = combineAssignedProspectIds;

  factory _$TeamScoutingImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamScoutingImplFromJson(json);

  final List<String> _watchlistProspectIds;
  @override
  @JsonKey()
  List<String> get watchlistProspectIds {
    if (_watchlistProspectIds is EqualUnmodifiableListView)
      return _watchlistProspectIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_watchlistProspectIds);
  }

  final List<ScoutingKnowledge> _knowledge;
  @override
  @JsonKey()
  List<ScoutingKnowledge> get knowledge {
    if (_knowledge is EqualUnmodifiableListView) return _knowledge;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_knowledge);
  }

  final List<String> _combineAssignedProspectIds;
  @override
  @JsonKey()
  List<String> get combineAssignedProspectIds {
    if (_combineAssignedProspectIds is EqualUnmodifiableListView)
      return _combineAssignedProspectIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_combineAssignedProspectIds);
  }

  @override
  String toString() {
    return 'TeamScouting(watchlistProspectIds: $watchlistProspectIds, knowledge: $knowledge, combineAssignedProspectIds: $combineAssignedProspectIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamScoutingImpl &&
            const DeepCollectionEquality().equals(
              other._watchlistProspectIds,
              _watchlistProspectIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._knowledge,
              _knowledge,
            ) &&
            const DeepCollectionEquality().equals(
              other._combineAssignedProspectIds,
              _combineAssignedProspectIds,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_watchlistProspectIds),
    const DeepCollectionEquality().hash(_knowledge),
    const DeepCollectionEquality().hash(_combineAssignedProspectIds),
  );

  /// Create a copy of TeamScouting
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamScoutingImplCopyWith<_$TeamScoutingImpl> get copyWith =>
      __$$TeamScoutingImplCopyWithImpl<_$TeamScoutingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamScoutingImplToJson(this);
  }
}

abstract class _TeamScouting implements TeamScouting {
  const factory _TeamScouting({
    final List<String> watchlistProspectIds,
    final List<ScoutingKnowledge> knowledge,
    final List<String> combineAssignedProspectIds,
  }) = _$TeamScoutingImpl;

  factory _TeamScouting.fromJson(Map<String, dynamic> json) =
      _$TeamScoutingImpl.fromJson;

  @override
  List<String> get watchlistProspectIds;
  @override
  List<ScoutingKnowledge> get knowledge;
  @override
  List<String> get combineAssignedProspectIds;

  /// Create a copy of TeamScouting
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamScoutingImplCopyWith<_$TeamScoutingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
