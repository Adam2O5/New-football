import 'package:uuid/uuid.dart';

import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';

/// Centralized message creation (`messages.md` §4–6).
///
/// Replaces the duplicated `_msg` / `_addMessage` helpers in
/// `DaySimulator`, `SeasonService`, and `StaffService`.
class MessageService {
  MessageService({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  /// Create and deliver a message to the league inbox.
  ///
  /// Respects player notification config: `muted` → silenced priority (skipped
  /// by Inbox.addMessage), `important` → forced urgent.
  ///
  /// Returns updated [LeagueState] with the message added (or unchanged if
  /// silenced by config).
  LeagueState send(
    LeagueState league, {
    required MessageType type,
    String? kind,
    MessageDomain domain = MessageDomain.system,
    MessagePriority priority = MessagePriority.normal,
    required String titleKey,
    required String bodyKey,
    Map<String, dynamic> args = const {},
    Map<String, dynamic> payload = const {},
    List<MessageAction> actions = const [],
    DecisionSpec? decision,
    String? expiresAt,
    String? groupKey,
    String? dedupKey,
    int? hour,
  }) {
    // Player config override (`messages.md` §5).
    final level = league.messageSettings.levelFor(type);
    final MessagePriority effectivePriority;
    if (decision != null) {
      // Decision messages are always urgent — cannot be silenced.
      effectivePriority = MessagePriority.urgent;
    } else if (level == NotificationLevel.muted) {
      effectivePriority = MessagePriority.silenced;
    } else if (level == NotificationLevel.important) {
      effectivePriority = MessagePriority.urgent;
    } else {
      effectivePriority = priority;
    }

    final msg = GameMessage(
      id: _uuid.v4(),
      type: type,
      kind: kind,
      domain: domain,
      priority: effectivePriority,
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      hour: hour,
      titleKey: titleKey,
      bodyKey: bodyKey,
      args: args,
      payload: payload,
      actions: actions,
      decision: decision,
      expiresAt: expiresAt,
      groupKey: groupKey,
      dedupKey: dedupKey,
    );

    return league.copyWith(inbox: league.inbox.addMessage(msg));
  }
}
