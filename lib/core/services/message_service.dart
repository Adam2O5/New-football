import 'package:uuid/uuid.dart';

import 'package:new_football/core/balance/message_catalog.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';

/// Applies a player's choice to a message and returns the updated game state.
typedef MessageDecisionHandler =
    LeagueState Function(
      LeagueState league,
      GameMessage message,
      String optionId,
    );

/// Centralized message creation and lifecycle rules (`messages.md` §4–12).
class MessageService {
  MessageService({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  /// Creates and delivers a message to the league inbox.
  ///
  /// Existing callers may continue supplying [titleKey] and [bodyKey]. When
  /// omitted, the catalog supplies them along with actions, decisions, default
  /// priority, group keys, and deduplication keys.
  LeagueState send(
    LeagueState league, {
    required MessageType type,
    String? kind,
    MessageDomain? domain,
    MessagePriority priority = MessagePriority.normal,
    String? titleKey,
    String? bodyKey,
    Map<String, dynamic> args = const {},
    Map<String, dynamic> payload = const {},
    List<MessageAction> actions = const [],
    DecisionSpec? decision,
    String? expiresAt,
    String? groupKey,
    String? dedupKey,
    int? hour,
    int? deliveryWeek,
    int? deliveryDay,
    int? deliveryHour,
  }) {
    final template = MessageCatalog.resolve(type, kind: kind);
    final messageDomain = domain ?? template.domain;
    final selectedDecision = decision ?? _decisionFromTemplate(template);
    final selectedActions = actions.isNotEmpty
        ? actions
        : _actionsFromTemplate(template);
    final catalogPriority = priority == MessagePriority.normal
        ? _escalatedPriority(template, args, payload)
        : priority;

    // Player config override (`messages.md` §5). Decision messages always win.
    final level = league.messageSettings.levelFor(type, messageDomain);
    final effectivePriority = selectedDecision != null
        ? MessagePriority.urgent
        : switch (level) {
            NotificationLevel.muted => MessagePriority.silenced,
            NotificationLevel.important => MessagePriority.urgent,
            NotificationLevel.normal => MessagePriority.normal,
            NotificationLevel.auto => catalogPriority,
          };

    final targetWeek = deliveryWeek ?? league.currentWeek;
    final targetDay = deliveryDay ?? league.currentDay;
    final targetHour = deliveryHour ?? hour;
    final expandedArgs = Map<String, dynamic>.from(args);
    final expansionValues = <String, dynamic>{
      'week': targetWeek,
      'day': targetDay,
      'year': league.currentSeason.year,
      ...args,
      ...payload,
    };
    final msg = GameMessage(
      id: _uuid.v4(),
      type: type,
      kind: kind,
      domain: messageDomain,
      priority: effectivePriority,
      seasonYear: league.currentSeason.year,
      week: targetWeek,
      day: targetDay,
      hour: targetHour,
      titleKey: titleKey ?? template.titleKey,
      bodyKey: bodyKey ?? template.bodyKey,
      args: expandedArgs,
      payload: payload,
      actions: selectedActions,
      decision: selectedDecision,
      expiresAt: expiresAt,
      groupKey: _expand(groupKey ?? template.groupKey, expansionValues),
      dedupKey: _expand(dedupKey ?? template.dedupKey, expansionValues),
    );

    final isFuture =
        targetWeek > league.currentWeek ||
        (targetWeek == league.currentWeek && targetDay > league.currentDay) ||
        (targetWeek == league.currentWeek &&
            targetDay == league.currentDay &&
            targetHour != null &&
            league.currentHour != null &&
            targetHour > league.currentHour!);

    var inbox = isFuture
        ? league.inbox.scheduleMessage(msg)
        : league.inbox.addMessage(msg);
    inbox = inbox
        .degradeMissingPayload(
          playerIds: {
            for (final team in league.teams) ...team.roster.map((p) => p.id),
            ...league.freeAgents.map((p) => p.id),
          },
          teamIds: {for (final team in league.teams) team.id},
        )
        .retainSeasons(league.currentSeason.year);
    return league.copyWith(inbox: inbox);
  }

  /// Applies a validated player choice and acknowledges the message.
  ///
  /// Domain effects are supplied by [onDecision]; the inbox lifecycle remains
  /// centralized here so every caller preserves the urgent pause semantics.
  LeagueState resolveDecision(
    LeagueState league,
    String messageId,
    String optionId, {
    MessageDecisionHandler? onDecision,
  }) {
    GameMessage? message;
    for (final item in league.inbox.messages) {
      if (item.id == messageId) {
        message = item;
        break;
      }
    }
    if (message == null || message.decision == null) return league;
    if (!message.decision!.options.any((option) => option.id == optionId)) {
      return league;
    }
    final selectedMessage = message;
    final afterEffect =
        onDecision?.call(league, selectedMessage, optionId) ?? league;
    return afterEffect.copyWith(
      inbox: afterEffect.inbox.acknowledge(selectedMessage.id),
    );
  }

  /// decision. The callback is the game-specific effect dispatcher; omitting
  /// it still acknowledges the default option and prevents a permanent pause.
  LeagueState resolveExpiredDecisions(
    LeagueState league,
    DateTime now, {
    MessageDecisionHandler? onDecision,
  }) {
    var state = league;
    for (final message in league.inbox.messages) {
      final expiresAt = message.expiresAt;
      final decision = message.decision;
      if (message.acknowledged || expiresAt == null || decision == null) {
        continue;
      }
      final expiry = DateTime.tryParse(expiresAt);
      if (expiry == null || now.isBefore(expiry)) continue;

      final option = decision.defaultOnExpiry;
      if (onDecision != null) {
        state = onDecision(state, message, option);
      }
      state = state.copyWith(inbox: state.inbox.acknowledge(message.id));
    }
    return state;
  }

  MessagePriority _escalatedPriority(
    MessageTemplate template,
    Map<String, dynamic> args,
    Map<String, dynamic> payload,
  ) {
    var result = template.defaultPriority;
    for (final predicate in template.escalateIf) {
      if (!_matches(predicate, args, payload)) continue;
      if (predicate == MessageEscalationPredicate.leagueSubject) {
        result = switch (result) {
          MessagePriority.urgent => MessagePriority.normal,
          MessagePriority.normal => MessagePriority.silenced,
          MessagePriority.silenced => MessagePriority.silenced,
        };
      } else {
        result = MessagePriority.urgent;
      }
    }
    return result;
  }

  bool _matches(
    MessageEscalationPredicate predicate,
    Map<String, dynamic> args,
    Map<String, dynamic> payload,
  ) {
    final values = {...args, ...payload};
    return switch (predicate) {
      MessageEscalationPredicate.playerInStartingXi =>
        values['playerInStartingXi'] == true || values['inStartingXi'] == true,
      MessageEscalationPredicate.majorInjury =>
        values['injuryType'] == 'major' || values['isMajor'] == true,
      MessageEscalationPredicate.ownClub => values['ownClub'] == true,
      MessageEscalationPredicate.leagueSubject =>
        values['leagueSubject'] == true || values['isLeagueMessage'] == true,
      MessageEscalationPredicate.payrollAboveSecondApron =>
        values['payrollAboveSecondApron'] == true,
      MessageEscalationPredicate.missingGoalkeeper =>
        values['missingGoalkeeper'] == true,
    };
  }

  DecisionSpec? _decisionFromTemplate(MessageTemplate template) {
    final definition = template.decision;
    if (definition == null) return null;
    return DecisionSpec(
      options: [
        for (final option in definition.options)
          MessageAction(id: option.id, labelKey: option.labelKey),
      ],
      defaultOnExpiry: definition.defaultOnExpiry,
    );
  }

  List<MessageAction> _actionsFromTemplate(MessageTemplate template) => [
    for (final action in template.actions)
      MessageAction(id: action.id, labelKey: action.labelKey),
  ];

  String? _expand(String? pattern, Map<String, dynamic> values) {
    if (pattern == null) return null;
    var unresolved = false;
    final expanded = pattern.replaceAllMapped(RegExp(r'\{(\w+)\}'), (match) {
      final value = values[match.group(1)];
      if (value == null) {
        unresolved = true;
        return match.group(0)!;
      }
      return value.toString();
    });
    return unresolved ? null : expanded;
  }
}
