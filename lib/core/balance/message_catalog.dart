import 'package:new_football/core/models/enums.dart';

/// Conditions used by the Auto notification policy (`messages.md` §5).
enum MessageEscalationPredicate {
  playerInStartingXi,
  majorInjury,
  ownClub,
  leagueSubject,
  payrollAboveSecondApron,
  missingGoalkeeper,
}

class MessageActionTemplate {
  const MessageActionTemplate(this.id, this.labelKey);

  final String id;
  final String labelKey;
}

class DecisionTemplate {
  const DecisionTemplate({
    required this.options,
    required this.defaultOnExpiry,
  });

  final List<MessageActionTemplate> options;
  final String defaultOnExpiry;
}

/// Data-only definition of a message pattern. It deliberately stores l10n
/// keys and reference names, never user-facing text (`messages.md` §7).
class MessageTemplate {
  const MessageTemplate({
    required this.type,
    this.kind,
    required this.domain,
    required this.defaultPriority,
    this.escalateIf = const [],
    required this.titleKey,
    required this.bodyKey,
    this.args = const [],
    this.payload = const [],
    this.actions = const [],
    this.decision,
    this.expiresAt,
    this.groupKey,
    this.dedupKey,
  });

  final MessageType type;
  final String? kind;
  final MessageDomain domain;
  final MessagePriority defaultPriority;
  final List<MessageEscalationPredicate> escalateIf;
  final String titleKey;
  final String bodyKey;
  final List<String> args;
  final List<String> payload;
  final List<MessageActionTemplate> actions;
  final DecisionTemplate? decision;
  final String? expiresAt;
  final String? groupKey;
  final String? dedupKey;
}

/// Central catalog for all message groups A–L and their kind-specific data.
class MessageCatalog {
  static final List<MessageTemplate> templates = [
    for (final type in MessageType.values)
      _template(
        type,
        _domains[type]!,
        _priorities[type]!,
        dedupKey: _dedupKeys[type],
        groupKey: _groupKeys[type],
        escalateIf: _escalations[type] ?? const [],
      ),

    // Player events (C): six decisions and five automatic events.
    ..._playerEventTemplates,
    // Team events (D): five decisions and four automatic events.
    ..._teamEventTemplates,
    // Contract responses (F), staff responses (G), and trade decisions (H).
    ..._contractTemplates,
    _template(
      MessageType.contractOffer,
      MessageDomain.contracts,
      MessagePriority.urgent,
      kind: 'rfaQualifyingOffer',
      decision: _decision(MessageType.contractOffer, const [
        'submit',
        'decline',
      ], 'decline'),
      expiresAt: 'extensionWindowEnd',
    ),
    _template(
      MessageType.trade,
      MessageDomain.trades,
      MessagePriority.urgent,
      kind: 'accepted',
    ),
    _template(
      MessageType.trade,
      MessageDomain.trades,
      MessagePriority.normal,
      kind: 'rejected',
    ),
    _template(
      MessageType.trade,
      MessageDomain.trades,
      MessagePriority.normal,
      kind: 'hardRejected',
    ),
    _template(
      MessageType.trade,
      MessageDomain.trades,
      MessagePriority.urgent,
      kind: 'ntcRefusal',
    ),
    _template(
      MessageType.trade,
      MessageDomain.trades,
      MessagePriority.silenced,
      kind: 'leagueDigest',
      groupKey: 'trade:league:{week}',
      escalateIf: const [MessageEscalationPredicate.leagueSubject],
    ),
    _template(
      MessageType.tradeWindowEvent,
      MessageDomain.trades,
      MessagePriority.normal,
      kind: 'open',
    ),
    _template(
      MessageType.scoutReport,
      MessageDomain.draft,
      MessagePriority.normal,
      kind: 'monthly',
    ),
    _template(
      MessageType.scoutReport,
      MessageDomain.draft,
      MessagePriority.urgent,
      kind: 'event',
      actions: const [
        MessageActionTemplate(
          'openWatchlist',
          'msg_scoutReport_action_openWatchlist',
        ),
      ],
    ),
    _template(
      MessageType.mockDraft,
      MessageDomain.draft,
      MessagePriority.normal,
      kind: 'initial',
    ),
    _template(
      MessageType.mockDraft,
      MessageDomain.draft,
      MessagePriority.normal,
      kind: 'final',
    ),
    _template(
      MessageType.draftPick,
      MessageDomain.draft,
      MessagePriority.urgent,
      kind: 'own',
      actions: const [
        MessageActionTemplate('openDraft', 'msg_draftPick_action_openDraft'),
      ],
    ),
    _template(
      MessageType.draftPickLeague,
      MessageDomain.draft,
      MessagePriority.silenced,
      kind: 'league',
      groupKey: 'draft:round:{round}',
    ),
    _template(
      MessageType.tradeWindowEvent,
      MessageDomain.trades,
      MessagePriority.normal,
      kind: 'deadline',
    ),
    _template(
      MessageType.draftedRightsReminder,
      MessageDomain.draft,
      MessagePriority.normal,
      payload: const ['rightsId', 'playerId', 'teamId'],
      args: const ['playerName', 'rosterCount'],
      dedupKey: 'draftedRightsReminder:{rightsId}',
    ),
    // Explicit digest patterns, including the resolved ovrDigest discrepancy.
    _template(
      MessageType.ovrDigest,
      MessageDomain.playerEvent,
      MessagePriority.silenced,
      groupKey: 'ovr:own:{week}',
      titleKey: 'msg_ovrDigest_digest_title',
      bodyKey: 'msg_ovrDigest_digest_body',
      args: ['count', 'week'],
    ),
  ];

  static MessageTemplate resolve(MessageType type, {String? kind}) {
    final exact = templates.where((t) => t.type == type && t.kind == kind);
    if (exact.isNotEmpty) return exact.last;
    return templates.lastWhere((t) => t.type == type && t.kind == null);
  }

  static bool isDecisionType(MessageType type, {String? kind}) => templates.any(
    (t) =>
        t.type == type &&
        (kind == null || t.kind == kind) &&
        t.decision != null,
  );

  static const Map<MessageType, MessageDomain> _domains = {
    MessageType.matchPreview: MessageDomain.matchday,
    MessageType.matchResult: MessageDomain.matchday,
    MessageType.walkover: MessageDomain.matchday,
    MessageType.lineupNoGk: MessageDomain.matchday,
    MessageType.benchIncomplete: MessageDomain.matchday,
    MessageType.suspensionStart: MessageDomain.matchday,
    MessageType.suspensionEnd: MessageDomain.matchday,
    MessageType.injury: MessageDomain.health,
    MessageType.injuryReturn: MessageDomain.health,
    MessageType.injuryRecurrence: MessageDomain.health,
    MessageType.potentialLoss: MessageDomain.health,
    MessageType.playerEvent: MessageDomain.playerEvent,
    MessageType.teamEvent: MessageDomain.teamEvent,
    MessageType.retirementPlayer: MessageDomain.roster,
    MessageType.retirementStaff: MessageDomain.staff,
    MessageType.retirementLeagueDigest: MessageDomain.roster,
    MessageType.rosterWarning: MessageDomain.roster,
    MessageType.contractOffer: MessageDomain.contracts,
    MessageType.contractOfferResponse: MessageDomain.contracts,
    MessageType.contractSigned: MessageDomain.contracts,
    MessageType.contractExpiring: MessageDomain.contracts,
    MessageType.contractLostToRival: MessageDomain.contracts,
    MessageType.contractExpired: MessageDomain.contracts,
    MessageType.declineToExtend: MessageDomain.contracts,
    MessageType.rfaOfferSheet: MessageDomain.contracts,
    MessageType.staffOfferResponse: MessageDomain.staff,
    MessageType.staffSigned: MessageDomain.staff,
    MessageType.staffGrowth: MessageDomain.staff,
    MessageType.staffHired: MessageDomain.staff,
    MessageType.staffFired: MessageDomain.staff,
    MessageType.staffSlotEmpty: MessageDomain.staff,
    MessageType.trade: MessageDomain.trades,
    MessageType.tradeOffer: MessageDomain.trades,
    MessageType.tradeWindowEvent: MessageDomain.trades,
    MessageType.lottery: MessageDomain.draft,
    MessageType.scoutReport: MessageDomain.draft,
    MessageType.combine: MessageDomain.draft,
    MessageType.mockDraft: MessageDomain.draft,
    MessageType.draftPick: MessageDomain.draft,
    MessageType.draftPickLeague: MessageDomain.draft,
    MessageType.draftedRightsReminder: MessageDomain.draft,
    MessageType.apronWarning: MessageDomain.finance,
    MessageType.capUpdateTv: MessageDomain.finance,
    MessageType.staffCapViolation: MessageDomain.finance,
    MessageType.award: MessageDomain.season,
    MessageType.atmosphere: MessageDomain.season,
    MessageType.teamStatusChange: MessageDomain.season,
    MessageType.seasonSummary: MessageDomain.season,
    MessageType.playoffMissed: MessageDomain.season,
    MessageType.calendar: MessageDomain.system,
    MessageType.system: MessageDomain.system,
    MessageType.ovrDigest: MessageDomain.playerEvent,
  };

  static const Map<MessageType, String> _dedupKeys = {
    MessageType.injury: 'injury:{playerId}:{injuryId}',
    MessageType.contractOffer: 'contractOffer:{negotiationId}:{round}',
    MessageType.tradeOffer: 'tradeOffer:{tradeOfferId}',
  };

  static const Map<MessageType, String> _groupKeys = {
    MessageType.retirementLeagueDigest: 'retire:league:{week}',
    MessageType.draftPickLeague: 'draft:round:{round}',
    MessageType.staffGrowth: 'staff:growth:{year}',
  };

  static const Map<MessageType, List<MessageEscalationPredicate>> _escalations =
      {
        MessageType.injury: [
          MessageEscalationPredicate.playerInStartingXi,
          MessageEscalationPredicate.majorInjury,
        ],
        MessageType.injuryRecurrence: [
          MessageEscalationPredicate.playerInStartingXi,
        ],
        MessageType.suspensionStart: [
          MessageEscalationPredicate.playerInStartingXi,
        ],
        MessageType.retirementPlayer: [MessageEscalationPredicate.ownClub],
        MessageType.rosterWarning: [
          MessageEscalationPredicate.missingGoalkeeper,
        ],
        MessageType.apronWarning: [
          MessageEscalationPredicate.payrollAboveSecondApron,
        ],
        MessageType.award: [MessageEscalationPredicate.ownClub],
      };

  static const Map<MessageType, MessagePriority> _priorities = {
    MessageType.matchPreview: MessagePriority.normal,
    MessageType.matchResult: MessagePriority.normal,
    MessageType.walkover: MessagePriority.urgent,
    MessageType.lineupNoGk: MessagePriority.urgent,
    MessageType.benchIncomplete: MessagePriority.normal,
    MessageType.suspensionStart: MessagePriority.normal,
    MessageType.suspensionEnd: MessagePriority.silenced,
    MessageType.injury: MessagePriority.normal,
    MessageType.injuryReturn: MessagePriority.normal,
    MessageType.injuryRecurrence: MessagePriority.normal,
    MessageType.potentialLoss: MessagePriority.normal,
    MessageType.playerEvent: MessagePriority.normal,
    MessageType.teamEvent: MessagePriority.normal,
    MessageType.retirementPlayer: MessagePriority.normal,
    MessageType.retirementStaff: MessagePriority.normal,
    MessageType.retirementLeagueDigest: MessagePriority.silenced,
    MessageType.rosterWarning: MessagePriority.urgent,
    MessageType.contractOffer: MessagePriority.normal,
    MessageType.contractOfferResponse: MessagePriority.normal,
    MessageType.contractSigned: MessagePriority.normal,
    MessageType.contractExpiring: MessagePriority.normal,
    MessageType.contractLostToRival: MessagePriority.normal,
    MessageType.contractExpired: MessagePriority.normal,
    MessageType.declineToExtend: MessagePriority.normal,
    MessageType.rfaOfferSheet: MessagePriority.urgent,
    MessageType.staffOfferResponse: MessagePriority.normal,
    MessageType.staffSigned: MessagePriority.normal,
    MessageType.staffGrowth: MessagePriority.normal,
    MessageType.staffHired: MessagePriority.normal,
    MessageType.staffFired: MessagePriority.normal,
    MessageType.staffSlotEmpty: MessagePriority.normal,
    MessageType.trade: MessagePriority.normal,
    MessageType.tradeOffer: MessagePriority.urgent,
    MessageType.tradeWindowEvent: MessagePriority.normal,
    MessageType.lottery: MessagePriority.urgent,
    MessageType.scoutReport: MessagePriority.normal,
    MessageType.combine: MessagePriority.normal,
    MessageType.mockDraft: MessagePriority.normal,
    MessageType.draftPick: MessagePriority.urgent,
    MessageType.draftPickLeague: MessagePriority.silenced,
    MessageType.draftedRightsReminder: MessagePriority.normal,
    MessageType.apronWarning: MessagePriority.normal,
    MessageType.capUpdateTv: MessagePriority.urgent,
    MessageType.staffCapViolation: MessagePriority.urgent,
    MessageType.award: MessagePriority.normal,
    MessageType.atmosphere: MessagePriority.normal,
    MessageType.teamStatusChange: MessagePriority.normal,
    MessageType.seasonSummary: MessagePriority.normal,
    MessageType.playoffMissed: MessagePriority.urgent,
    MessageType.calendar: MessagePriority.normal,
    MessageType.system: MessagePriority.normal,
    MessageType.ovrDigest: MessagePriority.silenced,
  };
}

MessageTemplate _template(
  MessageType type,
  MessageDomain domain,
  MessagePriority priority, {
  String? kind,
  List<MessageEscalationPredicate> escalateIf = const [],
  String? titleKey,
  String? bodyKey,
  List<String> args = const [],
  List<String> payload = const [],
  List<MessageActionTemplate> actions = const [],
  DecisionTemplate? decision,
  String? expiresAt,
  String? groupKey,
  String? dedupKey,
}) {
  return MessageTemplate(
    type: type,
    kind: kind,
    domain: domain,
    defaultPriority: priority,
    escalateIf: escalateIf,
    titleKey:
        titleKey ?? 'msg_${type.name}${kind == null ? '' : '_$kind'}_title',
    bodyKey: bodyKey ?? 'msg_${type.name}${kind == null ? '' : '_$kind'}_body',
    args: args,
    payload: payload,
    actions: actions,
    decision: decision,
    expiresAt: expiresAt,
    groupKey: groupKey,
    dedupKey: dedupKey,
  );
}

MessageActionTemplate _action(MessageType type, String id) =>
    MessageActionTemplate(id, 'msg_${type.name}_action_$id');

DecisionTemplate _decision(
  MessageType type,
  List<String> options,
  String defaultOnExpiry,
) => DecisionTemplate(
  options: [for (final option in options) _action(type, option)],
  defaultOnExpiry: defaultOnExpiry,
);

final _playerEventTemplates = <MessageTemplate>[
  for (final kind in [
    'plateau',
    'coldStreak',
    'injuryComplication',
    'veteranMotivation',
    'extraTraining',
    'personalSupport',
  ])
    _template(
      MessageType.playerEvent,
      MessageDomain.playerEvent,
      MessagePriority.urgent,
      kind: kind,
      payload: const ['playerId'],
      escalateIf: const [MessageEscalationPredicate.playerInStartingXi],
      decision: _decision(
        MessageType.playerEvent,
        kind == 'injuryComplication'
            ? const ['cautious', 'full']
            : const ['accept', 'decline'],
        kind == 'injuryComplication' ? 'full' : 'decline',
      ),
      expiresAt: 'playerEventExpiry',
    ),
  for (final kind in [
    'breakthrough',
    'personalProblems',
    'lateBloomer',
    'nationalTeam',
    'inspiredPerformance',
  ])
    _template(
      MessageType.playerEvent,
      MessageDomain.playerEvent,
      MessagePriority.normal,
      kind: kind,
      payload: const ['playerId'],
    ),
];

final _teamEventTemplates = <MessageTemplate>[
  _template(
    MessageType.teamEvent,
    MessageDomain.teamEvent,
    MessagePriority.urgent,
    kind: 'moreMinutesRequest',
    decision: _decision(MessageType.teamEvent, const [
      'accept',
      'decline',
    ], 'decline'),
    expiresAt: 'teamEventExpiry',
  ),
  _template(
    MessageType.teamEvent,
    MessageDomain.teamEvent,
    MessagePriority.urgent,
    kind: 'transferRequestI',
    decision: _decision(MessageType.teamEvent, const [
      'accept',
      'decline',
    ], 'decline'),
    expiresAt: 'teamEventExpiry',
  ),
  _template(
    MessageType.teamEvent,
    MessageDomain.teamEvent,
    MessagePriority.urgent,
    kind: 'transferRequestII',
    decision: _decision(MessageType.teamEvent, const [
      'accept',
      'decline',
    ], 'decline'),
    expiresAt: 'teamEventExpiry',
  ),
  _template(
    MessageType.teamEvent,
    MessageDomain.teamEvent,
    MessagePriority.urgent,
    kind: 'dressingRoomConflict',
    decision: _decision(MessageType.teamEvent, const [
      'intervene',
      'ignore',
    ], 'ignore'),
    expiresAt: 'teamEventExpiry',
  ),
  _template(
    MessageType.teamEvent,
    MessageDomain.teamEvent,
    MessagePriority.urgent,
    kind: 'publicCriticism',
    decision: _decision(MessageType.teamEvent, const [
      'response',
      'punish',
      'ignore',
    ], 'ignore'),
    expiresAt: 'teamEventExpiry',
  ),
  for (final kind in [
    'declineToExtend',
    'leaderSupport',
    'promiseBroken',
    'atmosphereShift',
  ])
    _template(
      MessageType.teamEvent,
      MessageDomain.teamEvent,
      kind == 'promiseBroken' ? MessagePriority.urgent : MessagePriority.normal,
      kind: kind,
    ),
];

final _contractTemplates = <MessageTemplate>[
  _template(
    MessageType.contractOffer,
    MessageDomain.contracts,
    MessagePriority.urgent,
    kind: 'accept',
    decision: _decision(MessageType.contractOffer, const [
      'finalize',
      'cancel',
    ], 'cancel'),
    expiresAt: 'contractAcceptExpiry',
  ),
  _template(
    MessageType.contractOffer,
    MessageDomain.contracts,
    MessagePriority.normal,
    kind: 'reject',
  ),
  _template(
    MessageType.contractOffer,
    MessageDomain.contracts,
    MessagePriority.urgent,
    kind: 'hardReject',
  ),
  _template(
    MessageType.contractOffer,
    MessageDomain.contracts,
    MessagePriority.normal,
    kind: 'waiting',
  ),
  _template(
    MessageType.contractOffer,
    MessageDomain.contracts,
    MessagePriority.urgent,
    kind: 'counter',
    decision: _decision(MessageType.contractOffer, const [
      'accept',
      'counter',
      'decline',
    ], 'decline'),
    expiresAt: 'contractCounterExpiry',
  ),
  for (final kind in ['accept', 'reject', 'hardReject', 'waiting', 'counter'])
    _template(
      MessageType.contractOfferResponse,
      MessageDomain.contracts,
      kind == 'hardReject' || kind == 'counter'
          ? MessagePriority.urgent
          : MessagePriority.normal,
      kind: kind,
    ),
  for (final kind in ['accept', 'reject', 'hardReject', 'waiting', 'counter'])
    _template(
      MessageType.staffOfferResponse,
      MessageDomain.staff,
      kind == 'hardReject' || kind == 'counter'
          ? MessagePriority.urgent
          : MessagePriority.normal,
      kind: kind,
    ),
  _template(
    MessageType.staffOfferResponse,
    MessageDomain.staff,
    MessagePriority.normal,
    kind: 'lostToRival',
    payload: const ['negotiationId', 'subjectId', 'winnerTeamId'],
  ),
  _template(
    MessageType.contractLostToRival,
    MessageDomain.contracts,
    MessagePriority.normal,
    kind: 'lostToRival',
    payload: const ['negotiationId', 'subjectId', 'winnerTeamId'],
  ),
  _template(
    MessageType.contractExpiring,
    MessageDomain.contracts,
    MessagePriority.normal,
    kind: 'player',
    payload: const ['playerId', 'teamId'],
  ),
  _template(
    MessageType.contractExpiring,
    MessageDomain.contracts,
    MessagePriority.normal,
    kind: 'staff',
    payload: const ['staffId', 'teamId'],
  ),
  _template(
    MessageType.contractExpired,
    MessageDomain.contracts,
    MessagePriority.normal,
    kind: 'player',
    payload: const ['playerId', 'teamId'],
  ),
  _template(
    MessageType.contractExpired,
    MessageDomain.staff,
    MessagePriority.normal,
    kind: 'staff',
    payload: const ['staffId', 'teamId'],
  ),
  _template(
    MessageType.tradeOffer,
    MessageDomain.trades,
    MessagePriority.urgent,
    decision: _decision(MessageType.tradeOffer, const [
      'accept',
      'counter',
      'reject',
    ], 'reject'),
    expiresAt: 'tradeOfferExpiry',
    payload: const ['tradeOfferId'],
    dedupKey: 'tradeOffer:{tradeOfferId}',
  ),
  _template(
    MessageType.trade,
    MessageDomain.trades,
    MessagePriority.urgent,
    kind: 'counter',
    decision: _decision(MessageType.trade, const [
      'accept',
      'counter',
      'reject',
    ], 'reject'),
  ),
  _template(
    MessageType.trade,
    MessageDomain.trades,
    MessagePriority.normal,
    kind: 'leagueDigest',
    groupKey: 'trade:league:{week}',
  ),
];
