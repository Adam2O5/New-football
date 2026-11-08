import 'package:new_football/core/balance/messages_balance.dart';
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
  List<GameMessage> get unread => messages.where((m) => !m.read).toList();

  List<GameMessage> get pendingUrgent => messages
      .where((m) => !m.acknowledged && m.priority == MessagePriority.urgent)
      .toList();

  /// Adds a message, applying deduplication, archive routing, digest folding,
  /// and the unread inbox cap.
  Inbox addMessage(
    GameMessage message, {
    MessagesBalance balance = const MessagesBalance(),
    int? digestMinItems,
    int? maxUnread,
  }) {
    if (_containsDedup(message)) return this;
    if (message.priority == MessagePriority.silenced) {
      return copyWith(
        archive: _capArchive([
          ...archive,
          message,
        ], maximum: balance.maxArchiveMessages),
      );
    }

    final active = [...messages, message];
    final compacted = _compactDigest(
      active,
      archive,
      digestMinItems ?? balance.digestMinItems,
    );
    return copyWith(
      messages: _capMessages(
        _capUnread(compacted.$1, maxUnread ?? balance.maxUnreadInbox),
        maximum: balance.maxInboxMessages,
      ),
      archive: _capArchive(compacted.$2, maximum: balance.maxArchiveMessages),
    );
  }

  Inbox scheduleMessage(
    GameMessage message, {
    MessagesBalance balance = const MessagesBalance(),
  }) {
    if (_containsDedup(message)) return this;
    if (message.priority == MessagePriority.silenced) {
      return copyWith(
        archive: _capArchive([
          ...archive,
          message,
        ], maximum: balance.maxArchiveMessages),
      );
    }
    return copyWith(scheduled: [...scheduled, message]);
  }

  /// Delivers the complete package due at the beginning of a calendar
  /// day/hour. Future messages remain hidden until their delivery slot.
  Inbox deliverScheduled(
    int week,
    int day, {
    int? hour,
    MessagesBalance balance = const MessagesBalance(),
  }) {
    final due = <GameMessage>[];
    final waiting = <GameMessage>[];
    for (final message in scheduled) {
      final dateBefore =
          message.week < week || (message.week == week && message.day < day);
      final sameDate = message.week == week && message.day == day;
      if (dateBefore || sameDate) {
        due.add(message);
      } else {
        waiting.add(message);
      }
    }

    var result = copyWith(scheduled: waiting);
    for (final message in due) {
      result = result.addMessage(message, balance: balance);
    }
    return result;
  }

  Inbox markRead(String id) {
    final index = messages.indexWhere((message) => message.id == id);
    if (index < 0 || messages[index].read) return this;
    return copyWith(
      messages: messages
          .map((m) => m.id == id ? m.copyWith(read: true) : m)
          .toList(),
    );
  }

  Inbox acknowledge(String id) {
    final index = messages.indexWhere((message) => message.id == id);
    if (index < 0 || (messages[index].read && messages[index].acknowledged)) {
      return this;
    }
    return copyWith(
      messages: messages
          .map(
            (m) => m.id == id ? m.copyWith(read: true, acknowledged: true) : m,
          )
          .toList(),
    );
  }

  /// Moves messages outside the configured retained seasons to archive.
  Inbox retainSeasons(
    int currentSeasonYear, {
    MessagesBalance balance = const MessagesBalance(),
    int? retentionSeasons,
  }) {
    final firstKeptSeason =
        currentSeasonYear -
        (retentionSeasons ?? balance.inboxRetentionSeasons) +
        1;
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
      archive: _capArchive([
        ...archive,
        ...oldMessages,
        ...oldScheduled,
      ], maximum: balance.maxArchiveMessages),
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
    bool matches(GameMessage existing) => existing.dedupKey == key;
    return messages.any(matches) ||
        scheduled.any(matches) ||
        archive.any(matches);
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
        titleKey: 'msg_${digestType.name}_digest_title',
        bodyKey: 'msg_${digestType.name}_digest_body',
        args: {'count': existingCount + members.length, 'week': week},
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

  /// Drops the oldest evictable messages down to [MessagesBalance.maxInboxMessages].
  ///
  /// The cap is a soft ceiling: game logic reads the inbox, so a message is
  /// only evictable once losing it cannot change behaviour. Protected are
  /// unread messages (the player has not seen them), everything urgent
  /// (`pendingUrgent` blocks the day from advancing) and any unanswered
  /// decision (`MessageService.resolveExpiredDecisions` still owes it a
  /// default outcome). If nothing qualifies, the list is left over the limit.
  List<GameMessage> _capMessages(
    List<GameMessage> input, {
    required int maximum,
  }) {
    if (input.length <= maximum) return input;
    var toDrop = input.length - maximum;
    final dropped = <int>{};
    for (var i = 0; i < input.length && toDrop > 0; i++) {
      final message = input[i];
      final evictable =
          message.read &&
          message.priority != MessagePriority.urgent &&
          (message.decision == null || message.acknowledged);
      if (!evictable) continue;
      dropped.add(i);
      toDrop--;
    }
    if (dropped.isEmpty) return input;
    return [
      for (var i = 0; i < input.length; i++)
        if (!dropped.contains(i)) input[i],
    ];
  }

  /// Keeps the newest [MessagesBalance.maxArchiveMessages] entries. Nothing in the game logic
  /// reads the archive, so this needs no exemptions; the only consequence is
  /// that `dedupKey` matches older than the window stop suppressing repeats,
  /// and those keys are scoped to a single match or season anyway.
  List<GameMessage> _capArchive(
    List<GameMessage> input, {
    required int maximum,
  }) => input.length <= maximum ? input : input.sublist(input.length - maximum);

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
