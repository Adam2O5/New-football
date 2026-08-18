import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';

part 'message.freezed.dart';
part 'message.g.dart';

/// A single option in a decision message (`messages.md` §12).
@freezed
abstract class MessageAction with _$MessageAction {
  const factory MessageAction({required String id, required String labelKey}) =
      _MessageAction;

  factory MessageAction.fromJson(Map<String, dynamic> json) =>
      _$MessageActionFromJson(json);
}

/// Decision spec for messages requiring player choice (`messages.md` §12).
@freezed
abstract class DecisionSpec with _$DecisionSpec {
  const factory DecisionSpec({
    required List<MessageAction> options,
    required String defaultOnExpiry,
  }) = _DecisionSpec;

  factory DecisionSpec.fromJson(Map<String, dynamic> json) =>
      _$DecisionSpecFromJson(json);
}

/// Full message model (`messages.md` §4).
@freezed
abstract class GameMessage with _$GameMessage {
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
abstract class MessageSettings with _$MessageSettings {
  const factory MessageSettings({
    /// Type-level settings take precedence over domain-level settings.
    @Default({}) Map<MessageType, NotificationLevel> overrides,
    @Default({}) Map<MessageDomain, NotificationLevel> domainOverrides,
  }) = _MessageSettings;

  factory MessageSettings.fromJson(Map<String, dynamic> json) =>
      _$MessageSettingsFromJson(json);
}

extension MessageSettingsX on MessageSettings {
  NotificationLevel levelFor(MessageType type, [MessageDomain? domain]) {
    return overrides[type] ??
        (domain == null ? null : domainOverrides[domain]) ??
        NotificationLevel.auto;
  }

  /// Updates a type setting while rejecting an attempt to mute a decision type.
  ///
  /// The message service also enforces this rule at delivery time, so direct
  /// construction of legacy settings cannot silence a decision accidentally.
  MessageSettings withTypeLevel(MessageType type, NotificationLevel level) {
    if (level == NotificationLevel.muted && _hasDecisionType(type)) {
      throw ArgumentError('Decision messages cannot be muted: ${type.name}');
    }
    return copyWith(overrides: {...overrides, type: level});
  }

  MessageSettings withDomainLevel(
    MessageDomain domain,
    NotificationLevel level,
  ) {
    return copyWith(domainOverrides: {...domainOverrides, domain: level});
  }

  bool _hasDecisionType(MessageType type) {
    // Kept local to avoid making the serialized model depend on catalog data.
    return type == MessageType.playerEvent ||
        type == MessageType.teamEvent ||
        type == MessageType.contractOffer ||
        type == MessageType.contractOfferResponse ||
        type == MessageType.rfaOfferSheet ||
        type == MessageType.trade ||
        type == MessageType.tradeOffer;
  }
}

@freezed
abstract class Inbox with _$Inbox {
  const factory Inbox({
    @Default([]) List<GameMessage> messages,
    @Default([]) List<GameMessage> scheduled,
    @Default([]) List<GameMessage> archive,
  }) = _Inbox;

  factory Inbox.fromJson(Map<String, dynamic> json) => _$InboxFromJson(json);
}

extension InboxX on Inbox {
  static const digestMinItems = 3;
  static const maxUnreadInbox = 50;
  static const retentionSeasons = 2;

  List<GameMessage> get unread => messages.where((m) => !m.read).toList();

  List<GameMessage> get pendingUrgent => messages
      .where((m) => !m.acknowledged && m.priority == MessagePriority.urgent)
      .toList();

  /// Adds a message, applying deduplication, archive routing, digest folding,
  /// and the unread inbox cap.
  Inbox addMessage(
    GameMessage message, {
    int digestMinItems = InboxX.digestMinItems,
    int maxUnread = InboxX.maxUnreadInbox,
  }) {
    if (_containsDedup(message)) return this;
    if (message.priority == MessagePriority.silenced) {
      return copyWith(archive: [...archive, message]);
    }

    final active = [...messages, message];
    final compacted = _compactDigest(active, archive, digestMinItems);
    return copyWith(
      messages: _capUnread(compacted.$1, maxUnread),
      archive: compacted.$2,
    );
  }

  Inbox scheduleMessage(GameMessage message) {
    if (_containsDedup(message)) return this;
    if (message.priority == MessagePriority.silenced) {
      return copyWith(archive: [...archive, message]);
    }
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

    var result = copyWith(scheduled: waiting);
    for (final message in due) {
      result = result.addMessage(message);
    }
    return result;
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

  /// Moves messages older than the active plus previous season to archive.
  Inbox retainSeasons(
    int currentSeasonYear, {
    int retentionSeasons = InboxX.retentionSeasons,
  }) {
    final firstKeptSeason = currentSeasonYear - retentionSeasons + 1;
    final oldMessages = messages
        .where((m) => m.seasonYear < firstKeptSeason)
        .toList();
    final oldScheduled = scheduled
        .where((m) => m.seasonYear < firstKeptSeason)
        .toList();
    return copyWith(
      messages: messages.where((m) => m.seasonYear >= firstKeptSeason).toList(),
      scheduled: scheduled
          .where((m) => m.seasonYear >= firstKeptSeason)
          .toList(),
      archive: [...archive, ...oldMessages, ...oldScheduled],
    );
  }

  /// Removes CTAs when a referenced entity no longer exists.
  Inbox degradeMissingPayload({
    Set<String>? playerIds,
    Set<String>? teamIds,
    Set<String>? tradeOfferIds,
    Set<String>? negotiationIds,
    Set<String>? prospectIds,
    Set<String>? matchIds,
  }) {
    GameMessage degrade(GameMessage message) => message.degradeMissingPayload(
      playerIds: playerIds,
      teamIds: teamIds,
      tradeOfferIds: tradeOfferIds,
      negotiationIds: negotiationIds,
      prospectIds: prospectIds,
      matchIds: matchIds,
    );
    return copyWith(
      messages: messages.map(degrade).toList(),
      scheduled: scheduled.map(degrade).toList(),
      archive: archive.map(degrade).toList(),
    );
  }

  bool _containsDedup(GameMessage message) {
    final key = message.dedupKey;
    if (key == null || key.isEmpty) return false;
    return [
      ...messages,
      ...scheduled,
      ...archive,
    ].any((existing) => existing.dedupKey == key);
  }

  (List<GameMessage>, List<GameMessage>) _compactDigest(
    List<GameMessage> active,
    List<GameMessage> currentArchive,
    int minimum,
  ) {
    var result = [...active];
    var history = [...currentArchive];
    final groups = result
        .where(
          (m) =>
              m.groupKey != null &&
              m.priority != MessagePriority.urgent &&
              m.kind != 'digest',
        )
        .map(
          (m) => (
            key: m.groupKey!,
            season: m.seasonYear,
            week: m.week,
            day: m.day,
          ),
        )
        .toSet();

    for (final group in groups) {
      final key = group.key;
      final week = group.week;
      final day = group.day;

      final members = result
          .where(
            (m) =>
                m.groupKey == key &&
                m.seasonYear == group.season &&
                m.week == week &&
                m.day == day &&
                m.kind != 'digest' &&
                m.priority != MessagePriority.urgent,
          )
          .toList();
      final existingDigest = result.where(
        (m) =>
            m.groupKey == key &&
            m.week == week &&
            m.day == day &&
            m.kind == 'digest',
      );
      final digest = existingDigest.isEmpty ? null : existingDigest.first;
      final existingCount = (digest?.args['count'] as num?)?.toInt() ?? 0;
      if (members.length + existingCount < minimum) continue;

      final base = members.isNotEmpty ? members.first : digest!;
      final digestType = key.startsWith('ovr:')
          ? MessageType.ovrDigest
          : base.type;
      final ids = <String>[
        ...((digest?.payload['messageIds'] as List<dynamic>?) ?? const []).map(
          (id) => id.toString(),
        ),
        ...members.map((m) => m.id),
      ];
      final folded = GameMessage(
        id: digest?.id ?? '${base.id}:digest',
        type: digestType,
        kind: 'digest',
        domain: digestType == MessageType.ovrDigest
            ? MessageDomain.playerEvent
            : base.domain,
        priority: MessagePriority.normal,
        seasonYear: base.seasonYear,
        week: base.week,
        day: base.day,
        hour: base.hour,
        titleKey: 'msg_${digestType.name}_digest_title',
        bodyKey: 'msg_${digestType.name}_digest_body',
        args: {'count': existingCount + members.length},
        payload: {'messageIds': ids},
        groupKey: key,
      );
      result.removeWhere(
        (m) =>
            (members.any((member) => member.id == m.id)) ||
            (digest != null && m.id == digest.id),
      );
      history.addAll(members);
      result.add(folded);
    }
    return (result, history);
  }

  List<GameMessage> _capUnread(List<GameMessage> input, int maximum) {
    final result = [...input];
    var unreadCount = result.where((m) => !m.read).length;
    for (var i = 0; i < result.length && unreadCount > maximum; i++) {
      if (!result[i].read) {
        result[i] = result[i].copyWith(read: true);
        unreadCount--;
      }
    }
    return result;
  }
}

extension GameMessagePayloadX on GameMessage {
  GameMessage degradeMissingPayload({
    Set<String>? playerIds,
    Set<String>? teamIds,
    Set<String>? tradeOfferIds,
    Set<String>? negotiationIds,
    Set<String>? prospectIds,
    Set<String>? matchIds,
  }) {
    bool missing(String key, Set<String>? known) {
      final value = payload[key];
      return value != null &&
          known != null &&
          !known.contains(value.toString());
    }

    final invalid =
        missing('playerId', playerIds) ||
        missing('teamId', teamIds) ||
        missing('tradeOfferId', tradeOfferIds) ||
        missing('negotiationId', negotiationIds) ||
        missing('prospectId', prospectIds) ||
        missing('matchId', matchIds);
    return invalid ? copyWith(actions: const [], decision: null) : this;
  }
}
