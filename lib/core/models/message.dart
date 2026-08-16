import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';

part 'message.freezed.dart';
part 'message.g.dart';

/// A single option in a decision message (`messages.md` §12).
@freezed
class MessageAction with _$MessageAction {
  const factory MessageAction({required String id, required String labelKey}) =
      _MessageAction;

  factory MessageAction.fromJson(Map<String, dynamic> json) =>
      _$MessageActionFromJson(json);
}

/// Decision spec for messages requiring player choice (`messages.md` §12).
@freezed
class DecisionSpec with _$DecisionSpec {
  const factory DecisionSpec({
    required List<MessageAction> options,
    required String defaultOnExpiry,
  }) = _DecisionSpec;

  factory DecisionSpec.fromJson(Map<String, dynamic> json) =>
      _$DecisionSpecFromJson(json);
}

/// Full message model (`messages.md` §4).
@freezed
class GameMessage with _$GameMessage {
  const factory GameMessage({
    required String id,
    required MessageType type,
    String? kind,
    @Default(MessageDomain.system) MessageDomain domain,
    @Default(MessagePriority.normal) MessagePriority priority,
    required int seasonYear,
    required int week,
    @Default(1) int day,
    int? hour,
    required String titleKey,
    required String bodyKey,
    @Default({}) Map<String, dynamic> args,
    @Default({}) Map<String, dynamic> payload,
    @Default([]) List<MessageAction> actions,
    DecisionSpec? decision,
    String? expiresAt,
    String? groupKey,
    String? dedupKey,
    @Default(false) bool read,
    @Default(false) bool acknowledged,
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
  const factory Inbox({
    @Default([]) List<GameMessage> messages,
    @Default([]) List<GameMessage> scheduled,
  }) = _Inbox;

  factory Inbox.fromJson(Map<String, dynamic> json) => _$InboxFromJson(json);
}

extension InboxX on Inbox {
  List<GameMessage> get unread => messages.where((m) => !m.read).toList();

  List<GameMessage> get pendingUrgent => messages
      .where((m) => !m.acknowledged && m.priority == MessagePriority.urgent)
      .toList();

  Inbox addMessage(GameMessage message) {
    // Silenced messages go to archive only (not inbox) — `messages.md` §5.
    if (message.priority == MessagePriority.silenced) return this;
    return copyWith(messages: [...messages, message]);
  }

  Inbox scheduleMessage(GameMessage message) {
    if (message.priority == MessagePriority.silenced) return this;
    return copyWith(scheduled: [...scheduled, message]);
  }

  /// Delivers the complete package due at the beginning of a calendar
  /// day/hour. Future messages remain hidden until their delivery slot.
  Inbox deliverScheduled(int week, int day, {int? hour}) {
    final due = <GameMessage>[];
    final waiting = <GameMessage>[];
    for (final message in scheduled) {
      final dateBefore =
          message.week < week || (message.week == week && message.day < day);
      final sameDate = message.week == week && message.day == day;
      final hourDue =
          message.hour == null || hour == null || message.hour! <= hour;
      if (dateBefore || (sameDate && hourDue)) {
        due.add(message);
      } else {
        waiting.add(message);
      }
    }
    return copyWith(messages: [...messages, ...due], scheduled: waiting);
  }

  Inbox markRead(String id) => copyWith(
    messages: messages
        .map((m) => m.id == id ? m.copyWith(read: true) : m)
        .toList(),
  );

  Inbox acknowledge(String id) => copyWith(
    messages: messages
        .map((m) => m.id == id ? m.copyWith(read: true, acknowledged: true) : m)
        .toList(),
  );
}
