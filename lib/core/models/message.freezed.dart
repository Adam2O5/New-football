// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MessageAction _$MessageActionFromJson(Map<String, dynamic> json) {
  return _MessageAction.fromJson(json);
}

/// @nodoc
mixin _$MessageAction {
  String get id => throw _privateConstructorUsedError;
  String get labelKey => throw _privateConstructorUsedError;

  /// Serializes this MessageAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageActionCopyWith<MessageAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageActionCopyWith<$Res> {
  factory $MessageActionCopyWith(
    MessageAction value,
    $Res Function(MessageAction) then,
  ) = _$MessageActionCopyWithImpl<$Res, MessageAction>;
  @useResult
  $Res call({String id, String labelKey});
}

/// @nodoc
class _$MessageActionCopyWithImpl<$Res, $Val extends MessageAction>
    implements $MessageActionCopyWith<$Res> {
  _$MessageActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? labelKey = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            labelKey: null == labelKey
                ? _value.labelKey
                : labelKey // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MessageActionImplCopyWith<$Res>
    implements $MessageActionCopyWith<$Res> {
  factory _$$MessageActionImplCopyWith(
    _$MessageActionImpl value,
    $Res Function(_$MessageActionImpl) then,
  ) = __$$MessageActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String labelKey});
}

/// @nodoc
class __$$MessageActionImplCopyWithImpl<$Res>
    extends _$MessageActionCopyWithImpl<$Res, _$MessageActionImpl>
    implements _$$MessageActionImplCopyWith<$Res> {
  __$$MessageActionImplCopyWithImpl(
    _$MessageActionImpl _value,
    $Res Function(_$MessageActionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? labelKey = null}) {
    return _then(
      _$MessageActionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        labelKey: null == labelKey
            ? _value.labelKey
            : labelKey // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageActionImpl implements _MessageAction {
  const _$MessageActionImpl({required this.id, required this.labelKey});

  factory _$MessageActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageActionImplFromJson(json);

  @override
  final String id;
  @override
  final String labelKey;

  @override
  String toString() {
    return 'MessageAction(id: $id, labelKey: $labelKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageActionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.labelKey, labelKey) ||
                other.labelKey == labelKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, labelKey);

  /// Create a copy of MessageAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageActionImplCopyWith<_$MessageActionImpl> get copyWith =>
      __$$MessageActionImplCopyWithImpl<_$MessageActionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageActionImplToJson(this);
  }
}

abstract class _MessageAction implements MessageAction {
  const factory _MessageAction({
    required final String id,
    required final String labelKey,
  }) = _$MessageActionImpl;

  factory _MessageAction.fromJson(Map<String, dynamic> json) =
      _$MessageActionImpl.fromJson;

  @override
  String get id;
  @override
  String get labelKey;

  /// Create a copy of MessageAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageActionImplCopyWith<_$MessageActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DecisionSpec _$DecisionSpecFromJson(Map<String, dynamic> json) {
  return _DecisionSpec.fromJson(json);
}

/// @nodoc
mixin _$DecisionSpec {
  List<MessageAction> get options => throw _privateConstructorUsedError;
  String get defaultOnExpiry => throw _privateConstructorUsedError;

  /// Serializes this DecisionSpec to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DecisionSpec
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DecisionSpecCopyWith<DecisionSpec> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DecisionSpecCopyWith<$Res> {
  factory $DecisionSpecCopyWith(
    DecisionSpec value,
    $Res Function(DecisionSpec) then,
  ) = _$DecisionSpecCopyWithImpl<$Res, DecisionSpec>;
  @useResult
  $Res call({List<MessageAction> options, String defaultOnExpiry});
}

/// @nodoc
class _$DecisionSpecCopyWithImpl<$Res, $Val extends DecisionSpec>
    implements $DecisionSpecCopyWith<$Res> {
  _$DecisionSpecCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DecisionSpec
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? options = null, Object? defaultOnExpiry = null}) {
    return _then(
      _value.copyWith(
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<MessageAction>,
            defaultOnExpiry: null == defaultOnExpiry
                ? _value.defaultOnExpiry
                : defaultOnExpiry // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DecisionSpecImplCopyWith<$Res>
    implements $DecisionSpecCopyWith<$Res> {
  factory _$$DecisionSpecImplCopyWith(
    _$DecisionSpecImpl value,
    $Res Function(_$DecisionSpecImpl) then,
  ) = __$$DecisionSpecImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<MessageAction> options, String defaultOnExpiry});
}

/// @nodoc
class __$$DecisionSpecImplCopyWithImpl<$Res>
    extends _$DecisionSpecCopyWithImpl<$Res, _$DecisionSpecImpl>
    implements _$$DecisionSpecImplCopyWith<$Res> {
  __$$DecisionSpecImplCopyWithImpl(
    _$DecisionSpecImpl _value,
    $Res Function(_$DecisionSpecImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DecisionSpec
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? options = null, Object? defaultOnExpiry = null}) {
    return _then(
      _$DecisionSpecImpl(
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<MessageAction>,
        defaultOnExpiry: null == defaultOnExpiry
            ? _value.defaultOnExpiry
            : defaultOnExpiry // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DecisionSpecImpl implements _DecisionSpec {
  const _$DecisionSpecImpl({
    required final List<MessageAction> options,
    required this.defaultOnExpiry,
  }) : _options = options;

  factory _$DecisionSpecImpl.fromJson(Map<String, dynamic> json) =>
      _$$DecisionSpecImplFromJson(json);

  final List<MessageAction> _options;
  @override
  List<MessageAction> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  final String defaultOnExpiry;

  @override
  String toString() {
    return 'DecisionSpec(options: $options, defaultOnExpiry: $defaultOnExpiry)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DecisionSpecImpl &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.defaultOnExpiry, defaultOnExpiry) ||
                other.defaultOnExpiry == defaultOnExpiry));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_options),
    defaultOnExpiry,
  );

  /// Create a copy of DecisionSpec
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DecisionSpecImplCopyWith<_$DecisionSpecImpl> get copyWith =>
      __$$DecisionSpecImplCopyWithImpl<_$DecisionSpecImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DecisionSpecImplToJson(this);
  }
}

abstract class _DecisionSpec implements DecisionSpec {
  const factory _DecisionSpec({
    required final List<MessageAction> options,
    required final String defaultOnExpiry,
  }) = _$DecisionSpecImpl;

  factory _DecisionSpec.fromJson(Map<String, dynamic> json) =
      _$DecisionSpecImpl.fromJson;

  @override
  List<MessageAction> get options;
  @override
  String get defaultOnExpiry;

  /// Create a copy of DecisionSpec
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DecisionSpecImplCopyWith<_$DecisionSpecImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameMessage _$GameMessageFromJson(Map<String, dynamic> json) {
  return _GameMessage.fromJson(json);
}

/// @nodoc
mixin _$GameMessage {
  String get id => throw _privateConstructorUsedError;
  MessageType get type => throw _privateConstructorUsedError;
  String? get kind => throw _privateConstructorUsedError;
  MessageDomain get domain => throw _privateConstructorUsedError;
  MessagePriority get priority => throw _privateConstructorUsedError;
  int get seasonYear => throw _privateConstructorUsedError;
  int get week => throw _privateConstructorUsedError;
  int get day => throw _privateConstructorUsedError;
  int? get hour => throw _privateConstructorUsedError;
  String get titleKey => throw _privateConstructorUsedError;
  String get bodyKey => throw _privateConstructorUsedError;
  Map<String, dynamic> get args => throw _privateConstructorUsedError;
  Map<String, dynamic> get payload => throw _privateConstructorUsedError;
  List<MessageAction> get actions => throw _privateConstructorUsedError;
  DecisionSpec? get decision => throw _privateConstructorUsedError;
  String? get expiresAt => throw _privateConstructorUsedError;
  String? get groupKey => throw _privateConstructorUsedError;
  String? get dedupKey => throw _privateConstructorUsedError;
  bool get read => throw _privateConstructorUsedError;
  bool get acknowledged => throw _privateConstructorUsedError;

  /// Serializes this GameMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameMessageCopyWith<GameMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameMessageCopyWith<$Res> {
  factory $GameMessageCopyWith(
    GameMessage value,
    $Res Function(GameMessage) then,
  ) = _$GameMessageCopyWithImpl<$Res, GameMessage>;
  @useResult
  $Res call({
    String id,
    MessageType type,
    String? kind,
    MessageDomain domain,
    MessagePriority priority,
    int seasonYear,
    int week,
    int day,
    int? hour,
    String titleKey,
    String bodyKey,
    Map<String, dynamic> args,
    Map<String, dynamic> payload,
    List<MessageAction> actions,
    DecisionSpec? decision,
    String? expiresAt,
    String? groupKey,
    String? dedupKey,
    bool read,
    bool acknowledged,
  });

  $DecisionSpecCopyWith<$Res>? get decision;
}

/// @nodoc
class _$GameMessageCopyWithImpl<$Res, $Val extends GameMessage>
    implements $GameMessageCopyWith<$Res> {
  _$GameMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? kind = freezed,
    Object? domain = null,
    Object? priority = null,
    Object? seasonYear = null,
    Object? week = null,
    Object? day = null,
    Object? hour = freezed,
    Object? titleKey = null,
    Object? bodyKey = null,
    Object? args = null,
    Object? payload = null,
    Object? actions = null,
    Object? decision = freezed,
    Object? expiresAt = freezed,
    Object? groupKey = freezed,
    Object? dedupKey = freezed,
    Object? read = null,
    Object? acknowledged = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as MessageType,
            kind: freezed == kind
                ? _value.kind
                : kind // ignore: cast_nullable_to_non_nullable
                      as String?,
            domain: null == domain
                ? _value.domain
                : domain // ignore: cast_nullable_to_non_nullable
                      as MessageDomain,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as MessagePriority,
            seasonYear: null == seasonYear
                ? _value.seasonYear
                : seasonYear // ignore: cast_nullable_to_non_nullable
                      as int,
            week: null == week
                ? _value.week
                : week // ignore: cast_nullable_to_non_nullable
                      as int,
            day: null == day
                ? _value.day
                : day // ignore: cast_nullable_to_non_nullable
                      as int,
            hour: freezed == hour
                ? _value.hour
                : hour // ignore: cast_nullable_to_non_nullable
                      as int?,
            titleKey: null == titleKey
                ? _value.titleKey
                : titleKey // ignore: cast_nullable_to_non_nullable
                      as String,
            bodyKey: null == bodyKey
                ? _value.bodyKey
                : bodyKey // ignore: cast_nullable_to_non_nullable
                      as String,
            args: null == args
                ? _value.args
                : args // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            payload: null == payload
                ? _value.payload
                : payload // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            actions: null == actions
                ? _value.actions
                : actions // ignore: cast_nullable_to_non_nullable
                      as List<MessageAction>,
            decision: freezed == decision
                ? _value.decision
                : decision // ignore: cast_nullable_to_non_nullable
                      as DecisionSpec?,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            groupKey: freezed == groupKey
                ? _value.groupKey
                : groupKey // ignore: cast_nullable_to_non_nullable
                      as String?,
            dedupKey: freezed == dedupKey
                ? _value.dedupKey
                : dedupKey // ignore: cast_nullable_to_non_nullable
                      as String?,
            read: null == read
                ? _value.read
                : read // ignore: cast_nullable_to_non_nullable
                      as bool,
            acknowledged: null == acknowledged
                ? _value.acknowledged
                : acknowledged // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of GameMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DecisionSpecCopyWith<$Res>? get decision {
    if (_value.decision == null) {
      return null;
    }

    return $DecisionSpecCopyWith<$Res>(_value.decision!, (value) {
      return _then(_value.copyWith(decision: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameMessageImplCopyWith<$Res>
    implements $GameMessageCopyWith<$Res> {
  factory _$$GameMessageImplCopyWith(
    _$GameMessageImpl value,
    $Res Function(_$GameMessageImpl) then,
  ) = __$$GameMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    MessageType type,
    String? kind,
    MessageDomain domain,
    MessagePriority priority,
    int seasonYear,
    int week,
    int day,
    int? hour,
    String titleKey,
    String bodyKey,
    Map<String, dynamic> args,
    Map<String, dynamic> payload,
    List<MessageAction> actions,
    DecisionSpec? decision,
    String? expiresAt,
    String? groupKey,
    String? dedupKey,
    bool read,
    bool acknowledged,
  });

  @override
  $DecisionSpecCopyWith<$Res>? get decision;
}

/// @nodoc
class __$$GameMessageImplCopyWithImpl<$Res>
    extends _$GameMessageCopyWithImpl<$Res, _$GameMessageImpl>
    implements _$$GameMessageImplCopyWith<$Res> {
  __$$GameMessageImplCopyWithImpl(
    _$GameMessageImpl _value,
    $Res Function(_$GameMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? kind = freezed,
    Object? domain = null,
    Object? priority = null,
    Object? seasonYear = null,
    Object? week = null,
    Object? day = null,
    Object? hour = freezed,
    Object? titleKey = null,
    Object? bodyKey = null,
    Object? args = null,
    Object? payload = null,
    Object? actions = null,
    Object? decision = freezed,
    Object? expiresAt = freezed,
    Object? groupKey = freezed,
    Object? dedupKey = freezed,
    Object? read = null,
    Object? acknowledged = null,
  }) {
    return _then(
      _$GameMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as MessageType,
        kind: freezed == kind
            ? _value.kind
            : kind // ignore: cast_nullable_to_non_nullable
                  as String?,
        domain: null == domain
            ? _value.domain
            : domain // ignore: cast_nullable_to_non_nullable
                  as MessageDomain,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as MessagePriority,
        seasonYear: null == seasonYear
            ? _value.seasonYear
            : seasonYear // ignore: cast_nullable_to_non_nullable
                  as int,
        week: null == week
            ? _value.week
            : week // ignore: cast_nullable_to_non_nullable
                  as int,
        day: null == day
            ? _value.day
            : day // ignore: cast_nullable_to_non_nullable
                  as int,
        hour: freezed == hour
            ? _value.hour
            : hour // ignore: cast_nullable_to_non_nullable
                  as int?,
        titleKey: null == titleKey
            ? _value.titleKey
            : titleKey // ignore: cast_nullable_to_non_nullable
                  as String,
        bodyKey: null == bodyKey
            ? _value.bodyKey
            : bodyKey // ignore: cast_nullable_to_non_nullable
                  as String,
        args: null == args
            ? _value._args
            : args // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        payload: null == payload
            ? _value._payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        actions: null == actions
            ? _value._actions
            : actions // ignore: cast_nullable_to_non_nullable
                  as List<MessageAction>,
        decision: freezed == decision
            ? _value.decision
            : decision // ignore: cast_nullable_to_non_nullable
                  as DecisionSpec?,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        groupKey: freezed == groupKey
            ? _value.groupKey
            : groupKey // ignore: cast_nullable_to_non_nullable
                  as String?,
        dedupKey: freezed == dedupKey
            ? _value.dedupKey
            : dedupKey // ignore: cast_nullable_to_non_nullable
                  as String?,
        read: null == read
            ? _value.read
            : read // ignore: cast_nullable_to_non_nullable
                  as bool,
        acknowledged: null == acknowledged
            ? _value.acknowledged
            : acknowledged // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameMessageImpl implements _GameMessage {
  const _$GameMessageImpl({
    required this.id,
    required this.type,
    this.kind,
    this.domain = MessageDomain.system,
    this.priority = MessagePriority.normal,
    required this.seasonYear,
    required this.week,
    this.day = 1,
    this.hour,
    required this.titleKey,
    required this.bodyKey,
    final Map<String, dynamic> args = const {},
    final Map<String, dynamic> payload = const {},
    final List<MessageAction> actions = const [],
    this.decision,
    this.expiresAt,
    this.groupKey,
    this.dedupKey,
    this.read = false,
    this.acknowledged = false,
  }) : _args = args,
       _payload = payload,
       _actions = actions;

  factory _$GameMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameMessageImplFromJson(json);

  @override
  final String id;
  @override
  final MessageType type;
  @override
  final String? kind;
  @override
  @JsonKey()
  final MessageDomain domain;
  @override
  @JsonKey()
  final MessagePriority priority;
  @override
  final int seasonYear;
  @override
  final int week;
  @override
  @JsonKey()
  final int day;
  @override
  final int? hour;
  @override
  final String titleKey;
  @override
  final String bodyKey;
  final Map<String, dynamic> _args;
  @override
  @JsonKey()
  Map<String, dynamic> get args {
    if (_args is EqualUnmodifiableMapView) return _args;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_args);
  }

  final Map<String, dynamic> _payload;
  @override
  @JsonKey()
  Map<String, dynamic> get payload {
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_payload);
  }

  final List<MessageAction> _actions;
  @override
  @JsonKey()
  List<MessageAction> get actions {
    if (_actions is EqualUnmodifiableListView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actions);
  }

  @override
  final DecisionSpec? decision;
  @override
  final String? expiresAt;
  @override
  final String? groupKey;
  @override
  final String? dedupKey;
  @override
  @JsonKey()
  final bool read;
  @override
  @JsonKey()
  final bool acknowledged;

  @override
  String toString() {
    return 'GameMessage(id: $id, type: $type, kind: $kind, domain: $domain, priority: $priority, seasonYear: $seasonYear, week: $week, day: $day, hour: $hour, titleKey: $titleKey, bodyKey: $bodyKey, args: $args, payload: $payload, actions: $actions, decision: $decision, expiresAt: $expiresAt, groupKey: $groupKey, dedupKey: $dedupKey, read: $read, acknowledged: $acknowledged)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.domain, domain) || other.domain == domain) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.seasonYear, seasonYear) ||
                other.seasonYear == seasonYear) &&
            (identical(other.week, week) || other.week == week) &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.titleKey, titleKey) ||
                other.titleKey == titleKey) &&
            (identical(other.bodyKey, bodyKey) || other.bodyKey == bodyKey) &&
            const DeepCollectionEquality().equals(other._args, _args) &&
            const DeepCollectionEquality().equals(other._payload, _payload) &&
            const DeepCollectionEquality().equals(other._actions, _actions) &&
            (identical(other.decision, decision) ||
                other.decision == decision) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.groupKey, groupKey) ||
                other.groupKey == groupKey) &&
            (identical(other.dedupKey, dedupKey) ||
                other.dedupKey == dedupKey) &&
            (identical(other.read, read) || other.read == read) &&
            (identical(other.acknowledged, acknowledged) ||
                other.acknowledged == acknowledged));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    type,
    kind,
    domain,
    priority,
    seasonYear,
    week,
    day,
    hour,
    titleKey,
    bodyKey,
    const DeepCollectionEquality().hash(_args),
    const DeepCollectionEquality().hash(_payload),
    const DeepCollectionEquality().hash(_actions),
    decision,
    expiresAt,
    groupKey,
    dedupKey,
    read,
    acknowledged,
  ]);

  /// Create a copy of GameMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameMessageImplCopyWith<_$GameMessageImpl> get copyWith =>
      __$$GameMessageImplCopyWithImpl<_$GameMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameMessageImplToJson(this);
  }
}

abstract class _GameMessage implements GameMessage {
  const factory _GameMessage({
    required final String id,
    required final MessageType type,
    final String? kind,
    final MessageDomain domain,
    final MessagePriority priority,
    required final int seasonYear,
    required final int week,
    final int day,
    final int? hour,
    required final String titleKey,
    required final String bodyKey,
    final Map<String, dynamic> args,
    final Map<String, dynamic> payload,
    final List<MessageAction> actions,
    final DecisionSpec? decision,
    final String? expiresAt,
    final String? groupKey,
    final String? dedupKey,
    final bool read,
    final bool acknowledged,
  }) = _$GameMessageImpl;

  factory _GameMessage.fromJson(Map<String, dynamic> json) =
      _$GameMessageImpl.fromJson;

  @override
  String get id;
  @override
  MessageType get type;
  @override
  String? get kind;
  @override
  MessageDomain get domain;
  @override
  MessagePriority get priority;
  @override
  int get seasonYear;
  @override
  int get week;
  @override
  int get day;
  @override
  int? get hour;
  @override
  String get titleKey;
  @override
  String get bodyKey;
  @override
  Map<String, dynamic> get args;
  @override
  Map<String, dynamic> get payload;
  @override
  List<MessageAction> get actions;
  @override
  DecisionSpec? get decision;
  @override
  String? get expiresAt;
  @override
  String? get groupKey;
  @override
  String? get dedupKey;
  @override
  bool get read;
  @override
  bool get acknowledged;

  /// Create a copy of GameMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameMessageImplCopyWith<_$GameMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MessageSettings _$MessageSettingsFromJson(Map<String, dynamic> json) {
  return _MessageSettings.fromJson(json);
}

/// @nodoc
mixin _$MessageSettings {
  Map<MessageType, NotificationLevel> get overrides =>
      throw _privateConstructorUsedError;

  /// Serializes this MessageSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageSettingsCopyWith<MessageSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageSettingsCopyWith<$Res> {
  factory $MessageSettingsCopyWith(
    MessageSettings value,
    $Res Function(MessageSettings) then,
  ) = _$MessageSettingsCopyWithImpl<$Res, MessageSettings>;
  @useResult
  $Res call({Map<MessageType, NotificationLevel> overrides});
}

/// @nodoc
class _$MessageSettingsCopyWithImpl<$Res, $Val extends MessageSettings>
    implements $MessageSettingsCopyWith<$Res> {
  _$MessageSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? overrides = null}) {
    return _then(
      _value.copyWith(
            overrides: null == overrides
                ? _value.overrides
                : overrides // ignore: cast_nullable_to_non_nullable
                      as Map<MessageType, NotificationLevel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MessageSettingsImplCopyWith<$Res>
    implements $MessageSettingsCopyWith<$Res> {
  factory _$$MessageSettingsImplCopyWith(
    _$MessageSettingsImpl value,
    $Res Function(_$MessageSettingsImpl) then,
  ) = __$$MessageSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<MessageType, NotificationLevel> overrides});
}

/// @nodoc
class __$$MessageSettingsImplCopyWithImpl<$Res>
    extends _$MessageSettingsCopyWithImpl<$Res, _$MessageSettingsImpl>
    implements _$$MessageSettingsImplCopyWith<$Res> {
  __$$MessageSettingsImplCopyWithImpl(
    _$MessageSettingsImpl _value,
    $Res Function(_$MessageSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? overrides = null}) {
    return _then(
      _$MessageSettingsImpl(
        overrides: null == overrides
            ? _value._overrides
            : overrides // ignore: cast_nullable_to_non_nullable
                  as Map<MessageType, NotificationLevel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageSettingsImpl implements _MessageSettings {
  const _$MessageSettingsImpl({
    final Map<MessageType, NotificationLevel> overrides = const {},
  }) : _overrides = overrides;

  factory _$MessageSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageSettingsImplFromJson(json);

  final Map<MessageType, NotificationLevel> _overrides;
  @override
  @JsonKey()
  Map<MessageType, NotificationLevel> get overrides {
    if (_overrides is EqualUnmodifiableMapView) return _overrides;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_overrides);
  }

  @override
  String toString() {
    return 'MessageSettings(overrides: $overrides)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageSettingsImpl &&
            const DeepCollectionEquality().equals(
              other._overrides,
              _overrides,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_overrides));

  /// Create a copy of MessageSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageSettingsImplCopyWith<_$MessageSettingsImpl> get copyWith =>
      __$$MessageSettingsImplCopyWithImpl<_$MessageSettingsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageSettingsImplToJson(this);
  }
}

abstract class _MessageSettings implements MessageSettings {
  const factory _MessageSettings({
    final Map<MessageType, NotificationLevel> overrides,
  }) = _$MessageSettingsImpl;

  factory _MessageSettings.fromJson(Map<String, dynamic> json) =
      _$MessageSettingsImpl.fromJson;

  @override
  Map<MessageType, NotificationLevel> get overrides;

  /// Create a copy of MessageSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageSettingsImplCopyWith<_$MessageSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Inbox _$InboxFromJson(Map<String, dynamic> json) {
  return _Inbox.fromJson(json);
}

/// @nodoc
mixin _$Inbox {
  List<GameMessage> get messages => throw _privateConstructorUsedError;

  /// Serializes this Inbox to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Inbox
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InboxCopyWith<Inbox> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InboxCopyWith<$Res> {
  factory $InboxCopyWith(Inbox value, $Res Function(Inbox) then) =
      _$InboxCopyWithImpl<$Res, Inbox>;
  @useResult
  $Res call({List<GameMessage> messages});
}

/// @nodoc
class _$InboxCopyWithImpl<$Res, $Val extends Inbox>
    implements $InboxCopyWith<$Res> {
  _$InboxCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Inbox
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? messages = null}) {
    return _then(
      _value.copyWith(
            messages: null == messages
                ? _value.messages
                : messages // ignore: cast_nullable_to_non_nullable
                      as List<GameMessage>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InboxImplCopyWith<$Res> implements $InboxCopyWith<$Res> {
  factory _$$InboxImplCopyWith(
    _$InboxImpl value,
    $Res Function(_$InboxImpl) then,
  ) = __$$InboxImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<GameMessage> messages});
}

/// @nodoc
class __$$InboxImplCopyWithImpl<$Res>
    extends _$InboxCopyWithImpl<$Res, _$InboxImpl>
    implements _$$InboxImplCopyWith<$Res> {
  __$$InboxImplCopyWithImpl(
    _$InboxImpl _value,
    $Res Function(_$InboxImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Inbox
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? messages = null}) {
    return _then(
      _$InboxImpl(
        messages: null == messages
            ? _value._messages
            : messages // ignore: cast_nullable_to_non_nullable
                  as List<GameMessage>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InboxImpl implements _Inbox {
  const _$InboxImpl({final List<GameMessage> messages = const []})
    : _messages = messages;

  factory _$InboxImpl.fromJson(Map<String, dynamic> json) =>
      _$$InboxImplFromJson(json);

  final List<GameMessage> _messages;
  @override
  @JsonKey()
  List<GameMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  String toString() {
    return 'Inbox(messages: $messages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InboxImpl &&
            const DeepCollectionEquality().equals(other._messages, _messages));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_messages));

  /// Create a copy of Inbox
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InboxImplCopyWith<_$InboxImpl> get copyWith =>
      __$$InboxImplCopyWithImpl<_$InboxImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InboxImplToJson(this);
  }
}

abstract class _Inbox implements Inbox {
  const factory _Inbox({final List<GameMessage> messages}) = _$InboxImpl;

  factory _Inbox.fromJson(Map<String, dynamic> json) = _$InboxImpl.fromJson;

  @override
  List<GameMessage> get messages;

  /// Create a copy of Inbox
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InboxImplCopyWith<_$InboxImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
