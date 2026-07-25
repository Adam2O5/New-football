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

GameMessage _$GameMessageFromJson(Map<String, dynamic> json) {
  return _GameMessage.fromJson(json);
}

/// @nodoc
mixin _$GameMessage {
  String get id => throw _privateConstructorUsedError;
  MessageType get type => throw _privateConstructorUsedError;
  MessagePriority get priority => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  int get week => throw _privateConstructorUsedError;
  bool get read => throw _privateConstructorUsedError;
  Map<String, dynamic>? get payload => throw _privateConstructorUsedError;

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
    MessagePriority priority,
    String title,
    String body,
    int week,
    bool read,
    Map<String, dynamic>? payload,
  });
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
    Object? priority = null,
    Object? title = null,
    Object? body = null,
    Object? week = null,
    Object? read = null,
    Object? payload = freezed,
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
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as MessagePriority,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            week: null == week
                ? _value.week
                : week // ignore: cast_nullable_to_non_nullable
                      as int,
            read: null == read
                ? _value.read
                : read // ignore: cast_nullable_to_non_nullable
                      as bool,
            payload: freezed == payload
                ? _value.payload
                : payload // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
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
    MessagePriority priority,
    String title,
    String body,
    int week,
    bool read,
    Map<String, dynamic>? payload,
  });
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
    Object? priority = null,
    Object? title = null,
    Object? body = null,
    Object? week = null,
    Object? read = null,
    Object? payload = freezed,
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
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as MessagePriority,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        week: null == week
            ? _value.week
            : week // ignore: cast_nullable_to_non_nullable
                  as int,
        read: null == read
            ? _value.read
            : read // ignore: cast_nullable_to_non_nullable
                  as bool,
        payload: freezed == payload
            ? _value._payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
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
    this.priority = MessagePriority.normal,
    required this.title,
    required this.body,
    required this.week,
    this.read = false,
    final Map<String, dynamic>? payload,
  }) : _payload = payload;

  factory _$GameMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameMessageImplFromJson(json);

  @override
  final String id;
  @override
  final MessageType type;
  @override
  @JsonKey()
  final MessagePriority priority;
  @override
  final String title;
  @override
  final String body;
  @override
  final int week;
  @override
  @JsonKey()
  final bool read;
  final Map<String, dynamic>? _payload;
  @override
  Map<String, dynamic>? get payload {
    final value = _payload;
    if (value == null) return null;
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'GameMessage(id: $id, type: $type, priority: $priority, title: $title, body: $body, week: $week, read: $read, payload: $payload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.week, week) || other.week == week) &&
            (identical(other.read, read) || other.read == read) &&
            const DeepCollectionEquality().equals(other._payload, _payload));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    priority,
    title,
    body,
    week,
    read,
    const DeepCollectionEquality().hash(_payload),
  );

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
    final MessagePriority priority,
    required final String title,
    required final String body,
    required final int week,
    final bool read,
    final Map<String, dynamic>? payload,
  }) = _$GameMessageImpl;

  factory _GameMessage.fromJson(Map<String, dynamic> json) =
      _$GameMessageImpl.fromJson;

  @override
  String get id;
  @override
  MessageType get type;
  @override
  MessagePriority get priority;
  @override
  String get title;
  @override
  String get body;
  @override
  int get week;
  @override
  bool get read;
  @override
  Map<String, dynamic>? get payload;

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
