import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
class GameMessage with _$GameMessage {
  const factory GameMessage({
    required String id,
    required MessageType type,
    @Default(MessagePriority.normal) MessagePriority priority,
    required String title,
    required String body,
    required int week,
    @Default(false) bool read,
    Map<String, dynamic>? payload,
  }) = _GameMessage;

  factory GameMessage.fromJson(Map<String, dynamic> json) =>
      _$GameMessageFromJson(json);
}

@freezed
class MessageSettings with _$MessageSettings {
  const factory MessageSettings({
    @Default({}) Map<MessageType, NotificationLevel> overrides,
  }) = _MessageSettings;

  factory MessageSettings.fromJson(Map<String, dynamic> json) =>
      _$MessageSettingsFromJson(json);
}

extension MessageSettingsX on MessageSettings {
  NotificationLevel levelFor(MessageType type) =>
      overrides[type] ?? NotificationLevel.normal;
}

@freezed
class Inbox with _$Inbox {
  const factory Inbox({@Default([]) List<GameMessage> messages}) = _Inbox;

  factory Inbox.fromJson(Map<String, dynamic> json) => _$InboxFromJson(json);
}

extension InboxX on Inbox {
  List<GameMessage> get unread => messages.where((m) => !m.read).toList();

  List<GameMessage> get pendingUrgent =>
      messages.where((m) => !m.read && m.priority == MessagePriority.urgent).toList();

  Inbox addMessage(GameMessage message) =>
      copyWith(messages: [...messages, message]);

  Inbox markRead(String id) => copyWith(
    messages: messages
        .map((m) => m.id == id ? m.copyWith(read: true) : m)
        .toList(),
  );
}
