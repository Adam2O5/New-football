import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/team_event_state.dart';
import 'package:new_football/core/models/trade_models.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';

/// Runtime input for a trade. The serializable history uses
/// [TradeAssetSnapshot] so later roster changes cannot alter the audit trail.
class TradeAsset {
  const TradeAsset.player(this.playerId)
    : draftedRightsId = null,
      pickId = null,
      pickYear = null,
      pickRound = null,
      originalTeamId = null;

  const TradeAsset.draftedRights(this.draftedRightsId)
    : playerId = null,
      pickId = null,
      pickYear = null,
      pickRound = null,
      originalTeamId = null;

  const TradeAsset.pick({
    this.pickId,
    required this.pickYear,
    required this.pickRound,
    required this.originalTeamId,
  }) : playerId = null,
       draftedRightsId = null;

  final String? playerId;
  final String? draftedRightsId;
  final String? pickId;
  final int? pickYear;
  final int? pickRound;
  final String? originalTeamId;

  bool get isPlayer => playerId != null;
  bool get isDraftedRights => draftedRightsId != null;
  bool get isPick =>
      pickYear != null && pickRound != null && originalTeamId != null;

  String get identity {
    if (isPlayer) return 'player:$playerId';
    if (isDraftedRights) return 'rights:$draftedRightsId';
    return 'pick:${pickId ?? '$pickYear:$pickRound:$originalTeamId'}';
  }

  TradeAssetSnapshot toSnapshot() => TradeAssetSnapshot(
    type: isPlayer
        ? 'player'
        : isDraftedRights
        ? 'draftedRights'
        : 'pick',
    playerId: playerId,
    draftedRightsId: draftedRightsId,
    pickId: pickId,
    pickYear: pickYear,
    pickRound: pickRound,
    originalTeamId: originalTeamId,
  );
}

class TradeProposal {
  const TradeProposal({
    required this.teamAId,
    required this.teamBId,
    required this.assetsFromA,
    required this.assetsFromB,
  });

  final String teamAId;
  final String teamBId;
  final List<TradeAsset> assetsFromA;
  final List<TradeAsset> assetsFromB;
}

class TradeValidation {
  const TradeValidation({required this.ok, this.reason, this.code});

  final bool ok;
  final String? reason;
  final String? code;
}

/// Result of the stateful submit path. A structurally valid trade can still
/// end as `rejected` by AI or `ntcRefused` by a player with NTC.
class TradeSubmissionResult {
  const TradeSubmissionResult({
    required this.league,
    required this.validation,
    required this.executed,
    required this.outcome,
  });

  final LeagueState league;
  final TradeValidation validation;
  final bool executed;
  final String outcome;
}

/// Result of a persisted offer/counter lifecycle operation.
class TradeOfferResult {
  const TradeOfferResult({
    required this.league,
    required this.validation,
    required this.changed,
    required this.outcome,
    this.offerId,
  });

  final LeagueState league;
  final TradeValidation validation;
  final bool changed;
  final String outcome;
  final String? offerId;
}

class TradeService {
  TradeService({
    this.balance = BalanceConfig.defaults,
    SalaryCapService? capService,
    CalendarService? calendarService,
    MessageService? messageService,
    Random? random,
  }) : capService = capService ?? SalaryCapService(balance: balance),
       calendarService = calendarService ?? CalendarService(balance: balance),
       messages = messageService ?? MessageService(),
       _random = random;

  final BalanceConfig balance;
  final SalaryCapService capService;
  final CalendarService calendarService;
  final MessageService messages;
  final Random? _random;

  DraftPick? _findOwnedPick(Team team, TradeAsset asset) {
    if (asset.pickId != null) {
      for (final pick in team.ownedPicks) {
        if (pick.id == asset.pickId) return pick;
      }
      return null;
    }
    for (final pick in team.ownedPicks) {
      if (pick.year == asset.pickYear &&
          pick.round == asset.pickRound &&
          pick.originalTeamId == asset.originalTeamId) {
        return pick;
      }
    }
    return null;
  }

  int assetValue(Team team, TradeAsset asset, {required int currentYear}) {
    if (asset.isPlayer) {
      final player = _playerById(team, asset.playerId!);
      if (player == null) return 0;
      var baseValue = player.computePointValue(balance);
      // AI should discount an incoming player whose consent is still needed.
      if (player.contract.noTradeClause) baseValue = (baseValue * 0.75).round();
      return (baseValue * team.eventState.pointValueMultiplierFor(player.id))
          .round();
    }
    // Rights are resolved by assetValueInLeague, where LeagueState owns the
    // rights list. Keep the legacy team-only API safe and deterministic.
    if (asset.isDraftedRights) return 0;
    final owned = _findOwnedPick(team, asset);
    if (owned != null) {
      return owned.computeTradeValue(
        currentYear: currentYear,
        balance: balance,
      );
    }
    if (!asset.isPick) return 0;
    return DraftPick(
      id: 'preview_${asset.originalTeamId}_${asset.pickYear}_r${asset.pickRound}',
      year: asset.pickYear!,
      round: asset.pickRound!,
      teamId: team.id,
      originalTeamId: asset.originalTeamId!,
    ).computeTradeValue(currentYear: currentYear, balance: balance);
  }

  int assetValueInLeague(
    LeagueState league,
    Team team,
    TradeAsset asset, {
    required int currentYear,
  }) {
    if (!asset.isDraftedRights) {
      return assetValue(team, asset, currentYear: currentYear);
    }
    final rights = league.draftedRights.where(
      (right) => right.id == asset.draftedRightsId,
    );
    if (rights.isEmpty) return 0;
    return rightsAssetValue(rights.first, currentYear: currentYear);
  }

  int rightsAssetValue(
    DraftedPlayerRights rights, {
    required int currentYear,
  }) => rights.player.computePointValue(balance);

  /// Returns whether a previous hard reject still blocks this club pair.
  /// The block is reconstructed from persisted history, so no save-schema
  /// field or migration is required.
  bool isPairTradeBlocked(LeagueState league, String teamAId, String teamBId) {
    final now = _logicalDate(league);
    for (final entry in league.tradeHistory.reversed) {
      if (entry.outcome != 'hardRejected' ||
          !_samePair(entry.teamAId, entry.teamBId, teamAId, teamBId)) {
        continue;
      }
      final created = DateTime.utc(
        entry.seasonYear,
        1,
        1,
      ).add(Duration(days: (entry.week - 1) * 7 + (entry.day - 1)));
      if (now.isBefore(created.add(const Duration(days: 30)))) return true;
    }
    return false;
  }

  /// Rehydrates a proposal from the persisted offer snapshot for AI and UI
  /// responders. The conversion stays in TradeService so snapshot parsing has
  /// one canonical implementation.
  TradeProposal? proposalForOffer(LeagueState league, String offerId) {
    final offer = league.tradeOfferById(offerId);
    return offer == null ? null : _proposalFromOffer(offer);
  }

  bool _samePair(String a, String b, String c, String d) =>
      (a == c && b == d) || (a == d && b == c);

  /// Full validation against the persisted league state. [currentWeek] is
  /// optional for backwards-compatible callers that validate an in-memory
  /// proposal without applying the calendar gate.
  TradeValidation validateLeague(
    LeagueState league,
    TradeProposal proposal, {
    int? currentWeek,
    int? currentDay,
  }) {
    final a = league.teamById(proposal.teamAId);
    final b = league.teamById(proposal.teamBId);
    if (a == null || b == null) {
      return const TradeValidation(
        ok: false,
        code: 'unknownTeam',
        reason: 'Nieznana drużyna',
      );
    }
    if (isPairTradeBlocked(league, a.id, b.id)) {
      return const TradeValidation(
        ok: false,
        code: 'tradePairBlocked',
        reason: 'Rozmowy z tym klubem są czasowo zablokowane',
      );
    }
    final basic = _validateLeagueAssets(
      league,
      a,
      b,
      proposal,
      currentYear: league.currentSeason.year,
    );
    if (!basic.ok) return basic;
    return _validateTeams(
      a,
      b,
      proposal,
      currentWeek: currentWeek,
      currentDay: currentDay,
      currentYear: league.currentSeason.year,
      league: league,
      allowNtc: true,
    );
  }

  /// Creates a persisted offer without mutating either roster. The proposer
  /// is [offeringTeamId]; the other team becomes the awaiting decision maker.
  TradeOfferResult createOffer(
    LeagueState league,
    TradeProposal proposal, {
    String? offeringTeamId,
    String? threadId,
    String? parentOfferId,
    bool emitMessages = true,
    bool enforceWindow = true,
    int? currentWeek,
    int? currentDay,
    int? currentHour,
  }) {
    final proposer = offeringTeamId ?? proposal.teamAId;
    if (proposer != proposal.teamAId && proposer != proposal.teamBId) {
      return TradeOfferResult(
        league: league,
        validation: const TradeValidation(
          ok: false,
          code: 'offerActor',
          reason: 'Oferent musi być jedną z drużyn wymiany',
        ),
        changed: false,
        outcome: 'hardRejected',
      );
    }
    final week = enforceWindow ? (currentWeek ?? league.currentWeek) : null;
    final day = enforceWindow ? (currentDay ?? league.currentDay) : null;
    final validation = validateLeague(
      league,
      proposal,
      currentWeek: week,
      currentDay: day,
    );
    if (!validation.ok) {
      return TradeOfferResult(
        league: emitMessages
            ? _sendOutcomeMessage(
                league,
                proposal,
                kind: 'hardRejected',
                reason: validation.reason,
              )
            : league,
        validation: validation,
        changed: false,
        outcome: 'hardRejected',
      );
    }

    final awaitingTeamId = proposer == proposal.teamAId
        ? proposal.teamBId
        : proposal.teamAId;
    final offer = _buildTradeOffer(
      league,
      proposal,
      offeringTeamId: proposer,
      awaitingTeamId: awaitingTeamId,
      threadId: threadId,
      parentOfferId: parentOfferId,
      round: parentOfferId == null
          ? 1
          : (league.tradeOfferById(parentOfferId)?.round ?? 1) + 1,
      currentWeek: currentWeek,
      currentDay: currentDay,
      currentHour: currentHour,
    );
    var next = league.upsertTradeOffer(offer);
    if (emitMessages) next = _sendPendingOfferMessage(next, offer);
    return TradeOfferResult(
      league: next,
      validation: validation,
      changed: true,
      outcome: 'pending',
      offerId: offer.id,
    );
  }

  /// Accepts a pending offer and revalidates every hard trade rule before any
  /// asset is moved. NTC consent is rolled only after this second validation.
  TradeOfferResult acceptOffer(
    LeagueState league,
    String offerId, {
    required String actingTeamId,
    bool emitMessages = true,
  }) {
    final offer = league.tradeOfferById(offerId);
    final action = _validateOfferAction(league, offer, actingTeamId);
    if (!action.ok) {
      if (action.code == 'offerExpired' && offer != null) {
        final expired = expireOffers(league);
        return TradeOfferResult(
          league: expired,
          validation: action,
          changed: expired != league,
          outcome: 'expired',
          offerId: offer.id,
        );
      }
      return TradeOfferResult(
        league: league,
        validation: action,
        changed: false,
        outcome: action.code ?? 'rejected',
        offerId: offer?.id,
      );
    }
    final proposal = _proposalFromOffer(offer!);
    if (proposal == null) {
      final next = _closeTradeOffer(
        league,
        offer,
        status: TradeOfferStatus.hardRejected,
        reason: 'Nieprawidłowe assety zapisanej oferty',
        emitMessages: emitMessages,
      );
      return TradeOfferResult(
        league: next,
        validation: const TradeValidation(
          ok: false,
          code: 'invalidOfferAssets',
          reason: 'Nieprawidłowe assety zapisanej oferty',
        ),
        changed: true,
        outcome: 'hardRejected',
        offerId: offer.id,
      );
    }
    final validation = validateLeague(
      league,
      proposal,
      currentWeek: league.currentWeek,
      currentDay: league.currentDay,
    );
    if (!validation.ok) {
      final next = _closeTradeOffer(
        league,
        offer,
        status: TradeOfferStatus.hardRejected,
        reason: validation.reason,
        proposal: proposal,
        emitMessages: emitMessages,
      );
      return TradeOfferResult(
        league: next,
        validation: validation,
        changed: true,
        outcome: 'hardRejected',
        offerId: offer.id,
      );
    }
    final result = _executeValidated(
      league,
      proposal,
      validation,
      emitMessages: emitMessages,
      offer: offer,
    );
    return TradeOfferResult(
      league: result.league,
      validation: result.validation,
      changed: true,
      outcome: result.outcome,
      offerId: offer.id,
    );
  }

  TradeOfferResult rejectOffer(
    LeagueState league,
    String offerId, {
    required String actingTeamId,
    String reason = 'Partner odrzucił propozycję wymiany',
    bool hardReject = false,
    bool emitMessages = true,
  }) {
    final offer = league.tradeOfferById(offerId);
    final action = _validateOfferAction(league, offer, actingTeamId);
    if (!action.ok) {
      if (action.code == 'offerExpired' && offer != null) {
        final expired = expireOffers(league);
        return TradeOfferResult(
          league: expired,
          validation: action,
          changed: expired != league,
          outcome: 'expired',
          offerId: offer.id,
        );
      }
      return TradeOfferResult(
        league: league,
        validation: action,
        changed: false,
        outcome: action.code ?? 'rejected',
        offerId: offer?.id,
      );
    }
    final proposal = _proposalFromOffer(offer!);
    final next = _closeTradeOffer(
      league,
      offer,
      status: hardReject
          ? TradeOfferStatus.hardRejected
          : TradeOfferStatus.rejected,
      reason: reason,
      proposal: proposal,
      emitMessages: emitMessages,
    );
    return TradeOfferResult(
      league: next,
      validation: const TradeValidation(ok: true),
      changed: true,
      outcome: hardReject ? 'hardRejected' : 'rejected',
      offerId: offer.id,
    );
  }

  /// Replaces a pending offer with a new pending counter-offer. The parent
  /// remains in history as [TradeOfferStatus.countered] and no roster state
  /// changes until the newest offer is accepted.
  TradeOfferResult counterOffer(
    LeagueState league,
    String offerId,
    TradeProposal proposal, {
    required String actingTeamId,
    bool emitMessages = true,
  }) {
    final parent = league.tradeOfferById(offerId);
    final action = _validateOfferAction(league, parent, actingTeamId);
    if (!action.ok) {
      return TradeOfferResult(
        league: league,
        validation: action,
        changed: false,
        outcome: action.code ?? 'rejected',
        offerId: parent?.id,
      );
    }
    if (parent!.round > balance.ai.tradeMaxCounters) {
      final closed = _closeTradeOffer(
        league,
        parent,
        status: TradeOfferStatus.hardRejected,
        reason: 'Osiągnięto maksymalną liczbę kontrofert',
        proposal: _proposalFromOffer(parent),
        emitMessages: emitMessages,
      );
      return TradeOfferResult(
        league: closed,
        validation: const TradeValidation(
          ok: false,
          code: 'counterLimit',
          reason: 'Osiągnięto maksymalną liczbę kontrofert',
        ),
        changed: true,
        outcome: 'hardRejected',
        offerId: parent.id,
      );
    }
    if (proposal.teamAId != parent.teamAId ||
        proposal.teamBId != parent.teamBId) {
      return TradeOfferResult(
        league: league,
        validation: const TradeValidation(
          ok: false,
          code: 'offerTeamsMismatch',
          reason: 'Kontroferta musi dotyczyć tych samych drużyn',
        ),
        changed: false,
        outcome: 'hardRejected',
        offerId: parent.id,
      );
    }
    final validation = validateLeague(
      league,
      proposal,
      currentWeek: league.currentWeek,
      currentDay: league.currentDay,
    );
    if (!validation.ok) {
      return TradeOfferResult(
        league: league,
        validation: validation,
        changed: false,
        outcome: 'hardRejected',
        offerId: parent.id,
      );
    }
    final awaitingTeamId = actingTeamId == parent.teamAId
        ? parent.teamBId
        : parent.teamAId;
    final nextOffer = _buildTradeOffer(
      league,
      proposal,
      offeringTeamId: actingTeamId,
      awaitingTeamId: awaitingTeamId,
      threadId: parent.threadId,
      parentOfferId: parent.id,
      round: parent.round + 1,
    );
    var next = league.upsertTradeOffer(
      parent.copyWith(
        status: TradeOfferStatus.countered,
        supersededById: nextOffer.id,
      ),
    );
    next = next.upsertTradeOffer(nextOffer);
    next = _acknowledgeOfferMessages(next, parent.id);
    if (emitMessages) next = _sendCounterOfferMessage(next, nextOffer);
    return TradeOfferResult(
      league: next,
      validation: validation,
      changed: true,
      outcome: 'countered',
      offerId: nextOffer.id,
    );
  }

  /// Marks offers whose game-time deadline has passed as expired. Expiry is
  /// idempotent and never transfers assets or creates an NTC block.
  LeagueState expireOffers(
    LeagueState league, {
    int? seasonYear,
    int? week,
    int? day,
    int? hour,
    bool emitMessages = true,
  }) {
    final now = _momentFor(
      seasonYear ?? league.currentSeason.year,
      week ?? league.currentWeek,
      day ?? league.currentDay,
      hour ?? league.currentHour ?? 0,
    );
    var next = league;
    for (final offer in league.tradeOffers) {
      if (!offer.isPending) continue;
      final expiry = _momentFor(
        offer.expirySeasonYear,
        offer.expiryWeek,
        offer.expiryDay,
        offer.expiryHour,
      );
      if (now.isBefore(expiry)) continue;
      final proposal = _proposalFromOffer(offer);
      next = _closeTradeOffer(
        next,
        offer,
        status: TradeOfferStatus.expired,
        reason: 'Oferta wygasła',
        proposal: proposal,
        emitMessages: emitMessages,
      );
    }
    return next;
  }

  /// Submits a proposal through the complete stateful lifecycle. Hard rules
  /// run first, AI acceptance is supplied by the caller, and NTC consent is
  /// rolled only after cap/roster/Stepien validation succeeds.
  TradeSubmissionResult submitLeague(
    LeagueState league,
    TradeProposal proposal, {
    bool aiAccepted = true,
    bool emitMessages = true,
    bool enforceWindow = true,
    int? currentWeek,
    int? currentDay,
  }) {
    final week = enforceWindow ? (currentWeek ?? league.currentWeek) : null;
    final day = enforceWindow ? (currentDay ?? league.currentDay) : null;
    final validation = validateLeague(
      league,
      proposal,
      currentWeek: week,
      currentDay: day,
    );
    if (!validation.ok) {
      final next = emitMessages
          ? _sendOutcomeMessage(
              league,
              proposal,
              kind: 'hardRejected',
              reason: validation.reason,
            )
          : league;
      return TradeSubmissionResult(
        league: next,
        validation: validation,
        executed: false,
        outcome: 'hardRejected',
      );
    }

    final offeredLeague = emitMessages
        ? _sendTradeOfferMessage(league, proposal)
        : league;
    if (!aiAccepted) {
      final next = emitMessages
          ? _sendOutcomeMessage(
              offeredLeague,
              proposal,
              kind: 'rejected',
              reason: 'Partner odrzucił propozycję wymiany',
            )
          : offeredLeague;
      return TradeSubmissionResult(
        league: next,
        validation: validation,
        executed: false,
        outcome: 'rejected',
      );
    }

    final a = offeredLeague.teamById(proposal.teamAId);
    final b = offeredLeague.teamById(proposal.teamBId);
    if (a == null || b == null) {
      return TradeSubmissionResult(
        league: league,
        validation: const TradeValidation(
          ok: false,
          code: 'unknownTeam',
          reason: 'Nieznana drużyna',
        ),
        executed: false,
        outcome: 'hardRejected',
      );
    }

    for (final entry in _ntcPlayers(a, proposal.assetsFromA)) {
      final probability = ntcConsentProbability(
        league: offeredLeague,
        source: a,
        destination: b,
        player: entry,
      );
      if (_rollNtc(offeredLeague, proposal, entry, probability)) continue;

      final now = _logicalDate(offeredLeague);
      final block = NtcTradeBlock(
        playerId: entry.id,
        destinationTeamId: b.id,
        createdAt: now,
        expiresAt: now.add(const Duration(days: 30)),
      );
      var next = offeredLeague.copyWith(
        ntcTradeBlocks: [
          ...offeredLeague.ntcTradeBlocks.where(
            (item) =>
                !(item.playerId == block.playerId &&
                    item.destinationTeamId == block.destinationTeamId),
          ),
          block,
        ],
      );
      next = _addHistory(
        next,
        proposal,
        outcome: 'ntcRefused',
        reason: 'NTC: ${entry.name}',
        ntcPlayerId: entry.id,
        ntcConsentProbability: probability,
      );
      if (emitMessages) {
        next = _sendOutcomeMessage(
          next,
          proposal,
          kind: 'ntcRefusal',
          reason: 'NTC: ${entry.name}',
          subjectName: entry.name,
          extraPayload: {
            'playerId': entry.id,
            'consentProbability': probability,
            'blockedUntil': block.expiresAt.toIso8601String(),
          },
        );
      }
      return TradeSubmissionResult(
        league: next,
        validation: TradeValidation(
          ok: false,
          code: 'ntcRefusal',
          reason: 'NTC: ${entry.name}',
        ),
        executed: false,
        outcome: 'ntcRefused',
      );
    }

    for (final entry in _ntcPlayers(b, proposal.assetsFromB)) {
      final probability = ntcConsentProbability(
        league: offeredLeague,
        source: b,
        destination: a,
        player: entry,
      );
      if (_rollNtc(offeredLeague, proposal, entry, probability)) continue;

      final now = _logicalDate(offeredLeague);
      final block = NtcTradeBlock(
        playerId: entry.id,
        destinationTeamId: a.id,
        createdAt: now,
        expiresAt: now.add(const Duration(days: 30)),
      );
      var next = offeredLeague.copyWith(
        ntcTradeBlocks: [
          ...offeredLeague.ntcTradeBlocks.where(
            (item) =>
                !(item.playerId == block.playerId &&
                    item.destinationTeamId == block.destinationTeamId),
          ),
          block,
        ],
      );
      next = _addHistory(
        next,
        proposal,
        outcome: 'ntcRefused',
        reason: 'NTC: ${entry.name}',
        ntcPlayerId: entry.id,
        ntcConsentProbability: probability,
      );
      if (emitMessages) {
        next = _sendOutcomeMessage(
          next,
          proposal,
          kind: 'ntcRefusal',
          reason: 'NTC: ${entry.name}',
          subjectName: entry.name,
          extraPayload: {
            'playerId': entry.id,
            'consentProbability': probability,
            'blockedUntil': block.expiresAt.toIso8601String(),
          },
        );
      }
      return TradeSubmissionResult(
        league: next,
        validation: TradeValidation(
          ok: false,
          code: 'ntcRefusal',
          reason: 'NTC: ${entry.name}',
        ),
        executed: false,
        outcome: 'ntcRefused',
      );
    }

    final result = _applyTeams(a, b, proposal);
    if (result == null) {
      final failed = const TradeValidation(
        ok: false,
        code: 'executionFailed',
        reason: 'Nie udało się wykonać wymiany',
      );
      return TradeSubmissionResult(
        league: offeredLeague,
        validation: failed,
        executed: false,
        outcome: 'hardRejected',
      );
    }

    var next = offeredLeague.copyWith(
      teams: offeredLeague.teams.map((team) {
        if (team.id == result.$1.id) return result.$1;
        if (team.id == result.$2.id) return result.$2;
        return team;
      }).toList(),
      draftedRights: _transferRights(offeredLeague, proposal, a.id, b.id),
    );
    next = _addHistory(next, proposal, outcome: 'accepted');
    if (emitMessages) {
      next = _sendOutcomeMessage(next, proposal, kind: 'accepted');
      next = messages.send(
        next,
        type: MessageType.trade,
        kind: 'leagueDigest',
        domain: MessageDomain.trades,
        payload: {
          'tradeId': _latestTradeId(next),
          'leagueSubject': true,
          'teamAId': a.id,
          'teamBId': b.id,
        },
        args: {
          'teamAName': a.name,
          'teamBName': b.name,
          'week': next.currentWeek,
        },
      );
    }
    return TradeSubmissionResult(
      league: next,
      validation: validation,
      executed: true,
      outcome: 'accepted',
    );
  }

  /// Compatibility wrapper for callers that expect a nullable state after a
  /// successful direct execution. New UI code should use [submitLeague].
  LeagueState? executeLeague(
    LeagueState league,
    TradeProposal proposal, {
    int? currentWeek,
    int? currentDay,
    bool enforceWindow = true,
  }) {
    final result = submitLeague(
      league,
      proposal,
      emitMessages: false,
      enforceWindow: enforceWindow,
      currentWeek: currentWeek,
      currentDay: currentDay,
    );
    return result.executed ? result.league : null;
  }

  /// Team-only validation retained for legacy unit tests and preview callers
  /// that do not have access to LeagueState. League-aware callers should use
  /// [validateLeague] so rights, Stepien and dated NTC blocks are checked.
  TradeValidation validate(
    Team a,
    Team b,
    TradeProposal proposal, {
    int? currentWeek,
    int? currentDay,
  }) {
    return _validateTeams(
      a,
      b,
      proposal,
      currentWeek: currentWeek,
      currentDay: currentDay,
      allowNtc: false,
    );
  }

  /// Low-level transfer used by old callers. It only mutates the two team
  /// objects; LeagueState callers must use [submitLeague] to get rights,
  /// history, NTC and messages.
  (Team, Team)? execute(Team a, Team b, TradeProposal proposal) =>
      _applyTeams(a, b, proposal);

  /// Returns the consent probability before the random roll, useful for UI
  /// explanations and deterministic tests.
  double ntcConsentProbability({
    required LeagueState league,
    required Team source,
    required Team destination,
    required Player player,
  }) {
    final table = league.strengthTable;
    final sourceStatus = table?.statusOf(source.id) ?? TeamStatus.pretender;
    final destinationStatus =
        table?.statusOf(destination.id) ?? TeamStatus.pretender;
    final statusDelta =
        TeamStatus.values.indexOf(destinationStatus) -
        TeamStatus.values.indexOf(sourceStatus);
    var probability = 0.55;
    if (statusDelta > 0) {
      probability += 0.20;
    } else if (statusDelta < 0) {
      probability -= 0.15;
    }

    if (source.eventState.transferSituationFor(player.id) != null) {
      probability += 0.30;
    }
    if (player.personality == PlayerPersonality.loyal) {
      probability -= 0.15;
    }
    if (player.personality == PlayerPersonality.ambitious &&
        (table?.rankOf(destination.id) ?? 15) <
            (table?.rankOf(source.id) ?? 15)) {
      probability += 0.10;
    }
    if (source.atmosphere < 40) probability += 0.10;
    return probability.clamp(0.10, 0.95).toDouble();
  }

  TradeValidation _validateLeagueAssets(
    LeagueState league,
    Team a,
    Team b,
    TradeProposal proposal, {
    required int currentYear,
  }) {
    if (proposal.teamAId != a.id || proposal.teamBId != b.id) {
      return const TradeValidation(
        ok: false,
        code: 'teamIdMismatch',
        reason: 'Niezgodne ID drużyn',
      );
    }
    if (a.id == b.id) {
      return const TradeValidation(
        ok: false,
        code: 'sameTeam',
        reason: 'Wymiana musi obejmować dwie różne drużyny',
      );
    }

    final allAssets = [...proposal.assetsFromA, ...proposal.assetsFromB];
    if (allAssets.isEmpty) {
      return const TradeValidation(
        ok: false,
        code: 'emptyTrade',
        reason: 'Wymiana musi zawierać co najmniej jeden asset',
      );
    }
    final seen = <String>{};
    for (final asset in allAssets) {
      if (!seen.add(asset.identity)) {
        return const TradeValidation(
          ok: false,
          code: 'duplicateAsset',
          reason: 'Ten sam asset nie może wystąpić po obu stronach wymiany',
        );
      }
    }

    final ownershipA = _validateOwnership(
      league,
      a,
      proposal.assetsFromA,
      label: 'A',
    );
    if (!ownershipA.ok) return ownershipA;
    final ownershipB = _validateOwnership(
      league,
      b,
      proposal.assetsFromB,
      label: 'B',
    );
    if (!ownershipB.ok) return ownershipB;

    final pickCount = allAssets.where((asset) => asset.isPick).length;
    if (pickCount > balance.salaryCap.maxPicksPerTrade) {
      return TradeValidation(
        ok: false,
        code: 'pickLimit',
        reason:
            'Maksymalnie ${balance.salaryCap.maxPicksPerTrade} picki w trade',
      );
    }
    final playerCount = allAssets.where((asset) => asset.isPlayer).length;
    if (playerCount > balance.salaryCap.maxPlayersPerTrade) {
      return TradeValidation(
        ok: false,
        code: 'playerLimit',
        reason:
            'Maksymalnie ${balance.salaryCap.maxPlayersPerTrade} zawodników w trade',
      );
    }
    for (final asset in allAssets.where((asset) => asset.isPick)) {
      if (asset.pickRound! < 1 || asset.pickRound! > 3) {
        return const TradeValidation(
          ok: false,
          code: 'pickRound',
          reason: 'Można handlować wyłącznie pickami rund 1–3',
        );
      }
      if (asset.pickYear! < currentYear ||
          asset.pickYear! > currentYear + balance.salaryCap.maxPickYearsAhead) {
        return TradeValidation(
          ok: false,
          code: 'pickHorizon',
          reason:
              'Pick może dotyczyć bieżącego draftu lub maksymalnie ${balance.salaryCap.maxPickYearsAhead} lat do przodu',
        );
      }
    }
    final stepienA = _validateStepien(
      league,
      a,
      proposal.assetsFromA,
      proposal.assetsFromB,
    );
    if (!stepienA.ok) return stepienA;
    final stepienB = _validateStepien(
      league,
      b,
      proposal.assetsFromB,
      proposal.assetsFromA,
    );
    if (!stepienB.ok) return stepienB;
    return const TradeValidation(ok: true);
  }

  TradeValidation _validateOwnership(
    LeagueState league,
    Team team,
    List<TradeAsset> assets, {
    required String label,
  }) {
    for (final asset in assets) {
      if (asset.isPlayer && _playerById(team, asset.playerId!) == null) {
        return TradeValidation(
          ok: false,
          code: 'playerOwnership',
          reason: 'Zawodnik nie należy do drużyny $label',
        );
      }
      if (asset.isPick && _findOwnedPick(team, asset) == null) {
        return TradeValidation(
          ok: false,
          code: 'pickOwnership',
          reason: 'Pick nie należy do drużyny $label',
        );
      }
      if (asset.isDraftedRights) {
        final rights = league.draftedRights.where(
          (right) => right.id == asset.draftedRightsId,
        );
        if (rights.isEmpty || rights.first.ownerTeamId != team.id) {
          return TradeValidation(
            ok: false,
            code: 'rightsOwnership',
            reason: 'Prawa draftowe nie należą do drużyny $label',
          );
        }
      }
    }
    return const TradeValidation(ok: true);
  }

  TradeValidation _validateTeams(
    Team a,
    Team b,
    TradeProposal proposal, {
    int? currentWeek,
    int? currentDay,
    int? currentYear,
    LeagueState? league,
    required bool allowNtc,
  }) {
    if (proposal.teamAId != a.id || proposal.teamBId != b.id) {
      return const TradeValidation(
        ok: false,
        code: 'teamIdMismatch',
        reason: 'Niezgodne ID drużyn',
      );
    }
    if (a.id == b.id) {
      return const TradeValidation(
        ok: false,
        code: 'sameTeam',
        reason: 'Wymiana musi obejmować dwie różne drużyny',
      );
    }
    if (currentWeek != null &&
        !calendarService.isTradeWindowOpen(currentWeek, day: currentDay ?? 1)) {
      return const TradeValidation(
        ok: false,
        code: 'tradeWindowClosed',
        reason: 'Okno wymian jest zamknięte',
      );
    }

    final allAssets = [...proposal.assetsFromA, ...proposal.assetsFromB];
    final seen = <String>{};
    for (final asset in allAssets) {
      if (!seen.add(asset.identity)) {
        return const TradeValidation(
          ok: false,
          code: 'duplicateAsset',
          reason: 'Ten sam asset nie może wystąpić po obu stronach wymiany',
        );
      }
    }
    final pickCount = allAssets.where((asset) => asset.isPick).length;
    if (pickCount > balance.salaryCap.maxPicksPerTrade) {
      return TradeValidation(
        ok: false,
        code: 'pickLimit',
        reason:
            'Maksymalnie ${balance.salaryCap.maxPicksPerTrade} picki w trade',
      );
    }
    final playerCount = allAssets.where((asset) => asset.isPlayer).length;
    if (playerCount > balance.salaryCap.maxPlayersPerTrade) {
      return TradeValidation(
        ok: false,
        code: 'playerLimit',
        reason:
            'Maksymalnie ${balance.salaryCap.maxPlayersPerTrade} zawodników w trade',
      );
    }
    if (currentYear != null) {
      for (final asset in allAssets.where((asset) => asset.isPick)) {
        if (asset.pickRound! < 1 || asset.pickRound! > 3) {
          return const TradeValidation(
            ok: false,
            code: 'pickRound',
            reason: 'Można handlować wyłącznie pickami rund 1–3',
          );
        }
        if (asset.pickYear! < currentYear ||
            asset.pickYear! >
                currentYear + balance.salaryCap.maxPickYearsAhead) {
          return TradeValidation(
            ok: false,
            code: 'pickHorizon',
            reason:
                'Pick może dotyczyć bieżącego draftu lub maksymalnie ${balance.salaryCap.maxPickYearsAhead} lat do przodu',
          );
        }
      }
    }

    final salaryOutA = _salaryOf(a, proposal.assetsFromA);
    final salaryOutB = _salaryOf(b, proposal.assetsFromB);
    final matchA = capService.tradeMatching(
      team: a,
      outgoingSalary: salaryOutA,
      outgoingSalaries: _playerSalaries(a, proposal.assetsFromA),
      incomingSalary: salaryOutB,
      incomingFirstRoundPicks: _firstRoundPicks(proposal.assetsFromB),
    );
    if (!matchA.allowed) {
      return TradeValidation(
        ok: false,
        code: 'salaryMatchingA',
        reason: 'Drużyna A: ${matchA.reason ?? 'salary matching'}',
      );
    }

    final matchB = capService.tradeMatching(
      team: b,
      outgoingSalary: salaryOutB,
      outgoingSalaries: _playerSalaries(b, proposal.assetsFromB),
      incomingSalary: salaryOutA,
      incomingFirstRoundPicks: _firstRoundPicks(proposal.assetsFromA),
    );
    if (!matchB.allowed) {
      return TradeValidation(
        ok: false,
        code: 'salaryMatchingB',
        reason: 'Drużyna B: ${matchB.reason ?? 'salary matching'}',
      );
    }

    final after = _applyTeams(a, b, proposal);
    if (after == null) {
      return const TradeValidation(
        ok: false,
        code: 'executionFailed',
        reason: 'Nie udało się przygotować wymiany',
      );
    }
    final roster = _validateRosterAfter(a, b, after.$1, after.$2);
    if (!roster.ok) return roster;

    if (league != null) {
      final block = _activeNtcBlockFor(league, a, proposal.assetsFromA, b);
      if (block != null) return block;
      final reverseBlock = _activeNtcBlockFor(
        league,
        b,
        proposal.assetsFromB,
        a,
      );
      if (reverseBlock != null) return reverseBlock;
    }

    // The team-only API predates NTC consent state. Keep its old hard-stop
    // behavior; LeagueState validation deliberately leaves NTC for submit.
    if (!allowNtc) {
      for (final player in _ntcPlayers(a, proposal.assetsFromA)) {
        return TradeValidation(
          ok: false,
          code: 'ntcConsentRequired',
          reason: 'NTC: ${player.name}',
        );
      }
      for (final player in _ntcPlayers(b, proposal.assetsFromB)) {
        return TradeValidation(
          ok: false,
          code: 'ntcConsentRequired',
          reason: 'NTC: ${player.name}',
        );
      }
    }
    return const TradeValidation(ok: true);
  }

  TradeValidation _validateRosterAfter(
    Team beforeA,
    Team beforeB,
    Team afterA,
    Team afterB,
  ) {
    final min = balance.roster.minSize;
    final max = balance.roster.maxSize;
    final aWasUnder = beforeA.roster.length < min;
    final bWasUnder = beforeB.roster.length < min;
    if (aWasUnder && bWasUnder) {
      return const TradeValidation(
        ok: false,
        code: 'bothRostersUnderMinimum',
        reason: 'Obie drużyny poniżej 20 zawodników nie mogą się wymieniać',
      );
    }
    if (aWasUnder) {
      if (afterA.roster.length <= beforeA.roster.length ||
          afterB.roster.length < min ||
          afterB.roster.length > max ||
          afterA.roster.length > max) {
        return const TradeValidation(
          ok: false,
          code: 'rosterExceptionA',
          reason:
              'Drużyna poniżej minimum musi zwiększyć roster, a druga pozostać w limicie 20–30',
        );
      }
      return const TradeValidation(ok: true);
    }
    if (bWasUnder) {
      if (afterB.roster.length <= beforeB.roster.length ||
          afterA.roster.length < min ||
          afterA.roster.length > max ||
          afterB.roster.length > max) {
        return const TradeValidation(
          ok: false,
          code: 'rosterExceptionB',
          reason:
              'Drużyna poniżej minimum musi zwiększyć roster, a druga pozostać w limicie 20–30',
        );
      }
      return const TradeValidation(ok: true);
    }
    if (afterA.roster.length < min ||
        afterA.roster.length > max ||
        afterB.roster.length < min ||
        afterB.roster.length > max) {
      return const TradeValidation(
        ok: false,
        code: 'rosterLimit',
        reason: 'Roster poza limitem 20–30 po trade',
      );
    }
    return const TradeValidation(ok: true);
  }

  TradeValidation _validateStepien(
    LeagueState league,
    Team team,
    List<TradeAsset> outgoing,
    List<TradeAsset> incoming,
  ) {
    final years = <int>{};
    for (final entry in league.tradeHistory) {
      if (entry.outcome != 'accepted') continue;
      final sent = entry.teamAId == team.id
          ? entry.assetsFromA
          : entry.teamBId == team.id
          ? entry.assetsFromB
          : const <TradeAssetSnapshot>[];
      for (final asset in sent) {
        if (asset.type == 'pick' &&
            asset.pickRound == 1 &&
            asset.pickYear != null) {
          years.add(asset.pickYear!);
        }
      }
    }
    for (final asset in outgoing.where(
      (item) => item.isPick && item.pickRound == 1,
    )) {
      years.add(asset.pickYear!);
    }
    if (years.isEmpty) return const TradeValidation(ok: true);

    final resulting = <int, int>{};
    for (final pick in team.ownedPicks.where((pick) => pick.round == 1)) {
      resulting[pick.year] = (resulting[pick.year] ?? 0) + 1;
    }
    for (final asset in outgoing.where(
      (item) => item.isPick && item.pickRound == 1,
    )) {
      final count = resulting[asset.pickYear!] ?? 0;
      if (count > 0) {
        resulting[asset.pickYear!] = count - 1;
      }
    }
    for (final asset in incoming.where(
      (item) => item.isPick && item.pickRound == 1,
    )) {
      resulting[asset.pickYear!] = (resulting[asset.pickYear!] ?? 0) + 1;
    }

    final sortedYears = years.toList()..sort();
    for (final year in sortedYears) {
      if (!years.contains(year + 1)) continue;
      if ((resulting[year] ?? 0) == 0 && (resulting[year + 1] ?? 0) == 0) {
        return TradeValidation(
          ok: false,
          code: 'stepien',
          reason:
              'Reguła Stepiena blokuje oddanie picków R1 w latach $year i ${year + 1}',
        );
      }
    }
    return const TradeValidation(ok: true);
  }

  TradeValidation? _activeNtcBlockFor(
    LeagueState league,
    Team source,
    List<TradeAsset> assets,
    Team destination,
  ) {
    final now = _logicalDate(league);
    for (final asset in assets.where((item) => item.isPlayer)) {
      final player = _playerById(source, asset.playerId!);
      if (player == null) continue;
      final block = league.ntcTradeBlocks.where(
        (item) =>
            item.playerId == player.id &&
            item.destinationTeamId == destination.id &&
            item.isActiveAt(now),
      );
      if (block.isNotEmpty ||
          player.contract.blockedTeamIds.contains(destination.id)) {
        return TradeValidation(
          ok: false,
          code: 'ntcBlock',
          reason: 'Zawodnik ${player.name} ma blokadę na ${destination.name}',
        );
      }
    }
    return null;
  }

  List<Player> _ntcPlayers(Team team, List<TradeAsset> assets) {
    final result = <Player>[];
    for (final asset in assets) {
      if (!asset.isPlayer) continue;
      final player = _playerById(team, asset.playerId!);
      if (player != null && player.contract.noTradeClause) result.add(player);
    }
    return result;
  }

  (Team, Team)? _applyTeams(Team a, Team b, TradeProposal proposal) {
    final leaveA = proposal.assetsFromA
        .where((asset) => asset.isPlayer)
        .map((asset) => asset.playerId!)
        .toSet();
    final leaveB = proposal.assetsFromB
        .where((asset) => asset.isPlayer)
        .map((asset) => asset.playerId!)
        .toSet();
    final movingToB = <Player>[];
    for (final id in leaveA) {
      final player = _playerById(a, id);
      if (player == null) return null;
      movingToB.add(_resetForTrade(player));
    }
    final movingToA = <Player>[];
    for (final id in leaveB) {
      final player = _playerById(b, id);
      if (player == null) return null;
      movingToA.add(_resetForTrade(player));
    }

    final remainingA = List<DraftPick>.from(a.ownedPicks);
    final movingPicksToB = <DraftPick>[];
    for (final asset in proposal.assetsFromA.where((item) => item.isPick)) {
      final pick = _removePick(remainingA, asset);
      if (pick == null) return null;
      movingPicksToB.add(pick.copyWith(teamId: b.id));
    }
    final remainingB = List<DraftPick>.from(b.ownedPicks);
    final movingPicksToA = <DraftPick>[];
    for (final asset in proposal.assetsFromB.where((item) => item.isPick)) {
      final pick = _removePick(remainingB, asset);
      if (pick == null) return null;
      movingPicksToA.add(pick.copyWith(teamId: a.id));
    }

    final chemistryA = Map<String, int>.from(a.chemistryAppearances)
      ..removeWhere((id, _) => leaveA.contains(id));
    final chemistryB = Map<String, int>.from(b.chemistryAppearances)
      ..removeWhere((id, _) => leaveB.contains(id));
    for (final player in movingToA) {
      chemistryA[player.id] = 0;
    }
    for (final player in movingToB) {
      chemistryB[player.id] = 0;
    }

    var newA = a.copyWith(
      roster: [
        ...a.roster.where((player) => !leaveA.contains(player.id)),
        ...movingToA,
      ],
      lineupPlayerIds: a.lineupPlayerIds
          .where((id) => !leaveA.contains(id))
          .toList(),
      benchPlayerIds: a.benchPlayerIds
          .where((id) => !leaveA.contains(id))
          .toList(),
      ownedPicks: [...remainingA, ...movingPicksToA],
      chemistryAppearances: chemistryA,
      eventState: a.eventState.clearPlayers(leaveA),
    );
    var newB = b.copyWith(
      roster: [
        ...b.roster.where((player) => !leaveB.contains(player.id)),
        ...movingToB,
      ],
      lineupPlayerIds: b.lineupPlayerIds
          .where((id) => !leaveB.contains(id))
          .toList(),
      benchPlayerIds: b.benchPlayerIds
          .where((id) => !leaveB.contains(id))
          .toList(),
      ownedPicks: [...remainingB, ...movingPicksToB],
      chemistryAppearances: chemistryB,
      eventState: b.eventState.clearPlayers(leaveB),
    );
    newA = capService.applyPayroll(newA);
    newB = capService.applyPayroll(newB);
    return (newA, newB);
  }

  Player _resetForTrade(Player player) => player.copyWith(
    contract: player.contract.copyWith(
      hasBirdRights: false,
      noTradeClause: false,
      blockedTeamIds: const [],
    ),
    state: player.state.copyWith(seasonsWithTeam: 0),
  );

  DraftPick? _removePick(List<DraftPick> picks, TradeAsset asset) {
    final index = asset.pickId == null
        ? picks.indexWhere(
            (pick) =>
                pick.year == asset.pickYear &&
                pick.round == asset.pickRound &&
                pick.originalTeamId == asset.originalTeamId,
          )
        : picks.indexWhere((pick) => pick.id == asset.pickId);
    if (index < 0) return null;
    return picks.removeAt(index);
  }

  List<DraftedPlayerRights> _transferRights(
    LeagueState league,
    TradeProposal proposal,
    String teamAId,
    String teamBId,
  ) => [
    for (final right in league.draftedRights)
      if (_containsRights(proposal.assetsFromA, right.id) &&
          right.ownerTeamId == teamAId)
        right.copyWith(ownerTeamId: teamBId)
      else if (_containsRights(proposal.assetsFromB, right.id) &&
          right.ownerTeamId == teamBId)
        right.copyWith(ownerTeamId: teamAId)
      else
        right,
  ];

  bool _containsRights(List<TradeAsset> assets, String id) => assets.any(
    (asset) => asset.isDraftedRights && asset.draftedRightsId == id,
  );

  Player? _playerById(Team team, String id) {
    for (final player in team.roster) {
      if (player.id == id) return player;
    }
    return null;
  }

  int _salaryOf(Team team, List<TradeAsset> assets) =>
      _playerSalaries(team, assets).fold(0, (sum, salary) => sum + salary);

  List<int> _playerSalaries(Team team, List<TradeAsset> assets) {
    final result = <int>[];
    for (final asset in assets) {
      if (!asset.isPlayer) continue;
      final player = _playerById(team, asset.playerId!);
      if (player != null) result.add(player.contract.salary);
    }
    return result;
  }

  int _firstRoundPicks(List<TradeAsset> assets) =>
      assets.where((asset) => asset.isPick && asset.pickRound == 1).length;

  bool _rollNtc(
    LeagueState league,
    TradeProposal proposal,
    Player player,
    double probability,
  ) {
    final injected = _random;
    if (injected != null) return injected.nextDouble() < probability;
    final seed = _stableHash(
      '${league.currentSeason.year}:${league.currentWeek}:${league.currentDay}:${proposal.teamAId}:${proposal.teamBId}:${proposal.assetsFromA.map((a) => a.identity).join(',')}:${proposal.assetsFromB.map((a) => a.identity).join(',')}:${player.id}',
    );
    return Random(seed).nextDouble() < probability;
  }

  TradeSubmissionResult _executeValidated(
    LeagueState league,
    TradeProposal proposal,
    TradeValidation validation, {
    required bool emitMessages,
    TradeOffer? offer,
  }) {
    final a = league.teamById(proposal.teamAId);
    final b = league.teamById(proposal.teamBId);
    if (a == null || b == null) {
      return TradeSubmissionResult(
        league: league,
        validation: const TradeValidation(
          ok: false,
          code: 'unknownTeam',
          reason: 'Nieznana drużyna',
        ),
        executed: false,
        outcome: 'hardRejected',
      );
    }

    for (final entry in _ntcPlayers(a, proposal.assetsFromA)) {
      final probability = ntcConsentProbability(
        league: league,
        source: a,
        destination: b,
        player: entry,
      );
      if (!_rollNtc(league, proposal, entry, probability)) {
        return _ntcRefusalResult(
          league,
          proposal,
          validation,
          source: a,
          destination: b,
          player: entry,
          probability: probability,
          offer: offer,
          emitMessages: emitMessages,
        );
      }
    }
    for (final entry in _ntcPlayers(b, proposal.assetsFromB)) {
      final probability = ntcConsentProbability(
        league: league,
        source: b,
        destination: a,
        player: entry,
      );
      if (!_rollNtc(league, proposal, entry, probability)) {
        return _ntcRefusalResult(
          league,
          proposal,
          validation,
          source: b,
          destination: a,
          player: entry,
          probability: probability,
          offer: offer,
          emitMessages: emitMessages,
        );
      }
    }

    final result = _applyTeams(a, b, proposal);
    if (result == null) {
      final failed = const TradeValidation(
        ok: false,
        code: 'executionFailed',
        reason: 'Nie udało się wykonać wymiany',
      );
      final next = offer == null
          ? league
          : _closeTradeOffer(
              league,
              offer,
              status: TradeOfferStatus.hardRejected,
              reason: failed.reason,
              proposal: proposal,
              emitMessages: emitMessages,
            );
      return TradeSubmissionResult(
        league: next,
        validation: failed,
        executed: false,
        outcome: 'hardRejected',
      );
    }

    var next = league.copyWith(
      teams: league.teams.map((team) {
        if (team.id == result.$1.id) return result.$1;
        if (team.id == result.$2.id) return result.$2;
        return team;
      }).toList(),
      draftedRights: _transferRights(league, proposal, a.id, b.id),
    );
    if (offer != null) {
      next = next.upsertTradeOffer(
        offer.copyWith(status: TradeOfferStatus.accepted),
      );
    }
    next = _addHistory(
      next,
      proposal,
      outcome: 'accepted',
      offerId: offer?.id,
      threadId: offer?.threadId,
      round: offer?.round ?? 1,
    );
    if (offer != null) next = _acknowledgeOfferMessages(next, offer.id);
    if (emitMessages) {
      next = _sendOutcomeMessage(
        next,
        proposal,
        kind: 'accepted',
        extraPayload: {
          if (offer != null) 'tradeOfferId': offer.id,
          if (offer != null) 'threadId': offer.threadId,
        },
      );
      next = messages.send(
        next,
        type: MessageType.trade,
        kind: 'leagueDigest',
        domain: MessageDomain.trades,
        payload: {
          'tradeId': _latestTradeId(next),
          'leagueSubject': true,
          'teamAId': a.id,
          'teamBId': b.id,
          if (offer != null) 'tradeOfferId': offer.id,
        },
        args: {
          'teamAName': a.name,
          'teamBName': b.name,
          'week': next.currentWeek,
        },
      );
    }
    return TradeSubmissionResult(
      league: next,
      validation: validation,
      executed: true,
      outcome: 'accepted',
    );
  }

  TradeSubmissionResult _ntcRefusalResult(
    LeagueState league,
    TradeProposal proposal,
    TradeValidation validation, {
    required Team source,
    required Team destination,
    required Player player,
    required double probability,
    required bool emitMessages,
    TradeOffer? offer,
  }) {
    final now = _logicalDate(league);
    final block = NtcTradeBlock(
      playerId: player.id,
      destinationTeamId: destination.id,
      createdAt: now,
      expiresAt: now.add(const Duration(days: 30)),
    );
    var next = league.copyWith(
      ntcTradeBlocks: [
        ...league.ntcTradeBlocks.where(
          (item) =>
              !(item.playerId == block.playerId &&
                  item.destinationTeamId == block.destinationTeamId),
        ),
        block,
      ],
    );
    if (offer != null) {
      next = next.upsertTradeOffer(
        offer.copyWith(
          status: TradeOfferStatus.ntcRefused,
          reason: 'NTC: ${player.name}',
        ),
      );
    }
    next = _addHistory(
      next,
      proposal,
      outcome: 'ntcRefused',
      reason: 'NTC: ${player.name}',
      ntcPlayerId: player.id,
      ntcConsentProbability: probability,
      offerId: offer?.id,
      threadId: offer?.threadId,
      round: offer?.round ?? 1,
    );
    if (offer != null) next = _acknowledgeOfferMessages(next, offer.id);
    if (emitMessages) {
      next = _sendOutcomeMessage(
        next,
        proposal,
        kind: 'ntcRefusal',
        reason: 'NTC: ${player.name}',
        subjectName: player.name,
        extraPayload: {
          if (offer != null) 'tradeOfferId': offer.id,
          'playerId': player.id,
          'consentProbability': probability,
          'blockedUntil': block.expiresAt.toIso8601String(),
        },
      );
    }
    return TradeSubmissionResult(
      league: next,
      validation: TradeValidation(
        ok: false,
        code: 'ntcRefusal',
        reason: 'NTC: ${player.name}',
      ),
      executed: false,
      outcome: 'ntcRefused',
    );
  }

  TradeValidation _validateOfferAction(
    LeagueState league,
    TradeOffer? offer,
    String actingTeamId,
  ) {
    if (offer == null) {
      return const TradeValidation(
        ok: false,
        code: 'offerNotFound',
        reason: 'Oferta wymiany nie istnieje',
      );
    }
    if (!offer.isPending) {
      return TradeValidation(
        ok: false,
        code: 'offerClosed',
        reason: 'Oferta wymiany jest już zamknięta',
      );
    }
    final now = _momentFor(
      league.currentSeason.year,
      league.currentWeek,
      league.currentDay,
      league.currentHour ?? 0,
    );
    if (!now.isBefore(
      _momentFor(
        offer.expirySeasonYear,
        offer.expiryWeek,
        offer.expiryDay,
        offer.expiryHour,
      ),
    )) {
      return const TradeValidation(
        ok: false,
        code: 'offerExpired',
        reason: 'Oferta wymiany wygasła',
      );
    }
    if (offer.awaitingTeamId != actingTeamId) {
      return const TradeValidation(
        ok: false,
        code: 'offerActor',
        reason: 'Ta drużyna nie może odpowiedzieć na tę ofertę',
      );
    }
    if (!calendarService.isTradeWindowOpen(
      league.currentWeek,
      day: league.currentDay,
    )) {
      return const TradeValidation(
        ok: false,
        code: 'tradeWindowClosed',
        reason: 'Okno wymian jest zamknięte',
      );
    }
    return const TradeValidation(ok: true);
  }

  TradeOffer _buildTradeOffer(
    LeagueState league,
    TradeProposal proposal, {
    required String offeringTeamId,
    required String awaitingTeamId,
    String? threadId,
    String? parentOfferId,
    required int round,
    int? currentWeek,
    int? currentDay,
    int? currentHour,
  }) {
    final year = league.currentSeason.year;
    final week = currentWeek ?? league.currentWeek;
    final day = currentDay ?? league.currentDay;
    final hour = currentHour ?? league.currentHour ?? 0;
    final sequence = league.tradeOffers.length;
    final stable = _stableHash(
      '${_proposalKey(proposal)}|$offeringTeamId|$year|$week|$day|$hour|$sequence|$round',
    );
    final resolvedThread =
        threadId ?? 'tradeThread:$year:$week:$day:$sequence:$stable';
    final id = 'tradeOffer:$year:$week:$day:$hour:$sequence:$stable';
    final expiry = _offerExpiryMoment(year, week, day, hour);
    final expiryCoordinates = _coordinatesForMoment(expiry);
    return TradeOffer(
      id: id,
      threadId: resolvedThread,
      parentOfferId: parentOfferId,
      teamAId: proposal.teamAId,
      teamBId: proposal.teamBId,
      assetsFromA: [
        for (final asset in proposal.assetsFromA) asset.toSnapshot(),
      ],
      assetsFromB: [
        for (final asset in proposal.assetsFromB) asset.toSnapshot(),
      ],
      round: round,
      awaitingTeamId: awaitingTeamId,
      seasonYear: year,
      week: week,
      day: day,
      hour: hour,
      expirySeasonYear: expiryCoordinates.$1,
      expiryWeek: expiryCoordinates.$2,
      expiryDay: expiryCoordinates.$3,
      expiryHour: expiryCoordinates.$4,
    );
  }

  TradeProposal? _proposalFromOffer(TradeOffer offer) {
    final assetsA = <TradeAsset>[];
    final assetsB = <TradeAsset>[];
    for (final snapshot in offer.assetsFromA) {
      final asset = _assetFromSnapshot(snapshot);
      if (asset == null) return null;
      assetsA.add(asset);
    }
    for (final snapshot in offer.assetsFromB) {
      final asset = _assetFromSnapshot(snapshot);
      if (asset == null) return null;
      assetsB.add(asset);
    }
    return TradeProposal(
      teamAId: offer.teamAId,
      teamBId: offer.teamBId,
      assetsFromA: assetsA,
      assetsFromB: assetsB,
    );
  }

  TradeAsset? _assetFromSnapshot(TradeAssetSnapshot snapshot) {
    switch (snapshot.type) {
      case 'player':
        final id = snapshot.playerId;
        return id == null ? null : TradeAsset.player(id);
      case 'draftedRights':
        final id = snapshot.draftedRightsId;
        return id == null ? null : TradeAsset.draftedRights(id);
      case 'pick':
        if (snapshot.pickYear == null ||
            snapshot.pickRound == null ||
            snapshot.originalTeamId == null) {
          return null;
        }
        return TradeAsset.pick(
          pickId: snapshot.pickId,
          pickYear: snapshot.pickYear!,
          pickRound: snapshot.pickRound!,
          originalTeamId: snapshot.originalTeamId!,
        );
      default:
        return null;
    }
  }

  LeagueState _closeTradeOffer(
    LeagueState league,
    TradeOffer offer, {
    required TradeOfferStatus status,
    required String? reason,
    TradeProposal? proposal,
    bool emitMessages = true,
  }) {
    var next = league.upsertTradeOffer(
      offer.copyWith(status: status, reason: reason),
    );
    final historyOutcome = switch (status) {
      TradeOfferStatus.ntcRefused => 'ntcRefused',
      TradeOfferStatus.hardRejected => 'hardRejected',
      TradeOfferStatus.expired => 'expired',
      TradeOfferStatus.cancelled => 'cancelled',
      TradeOfferStatus.rejected => 'rejected',
      TradeOfferStatus.accepted => 'accepted',
      TradeOfferStatus.pending || TradeOfferStatus.countered => 'pending',
    };
    next = _addOfferHistory(
      next,
      offer,
      outcome: historyOutcome,
      reason: reason,
    );
    if (emitMessages && proposal != null) {
      final kind = switch (status) {
        TradeOfferStatus.hardRejected => 'hardRejected',
        TradeOfferStatus.ntcRefused => 'ntcRefusal',
        TradeOfferStatus.accepted => 'accepted',
        _ => 'rejected',
      };
      next = _sendOutcomeMessage(
        next,
        proposal,
        kind: kind,
        reason: reason,
        extraPayload: {'tradeOfferId': offer.id, 'threadId': offer.threadId},
      );
    }
    return _acknowledgeOfferMessages(next, offer.id);
  }

  LeagueState _addOfferHistory(
    LeagueState league,
    TradeOffer offer, {
    required String outcome,
    String? reason,
    String? ntcPlayerId,
    double? ntcConsentProbability,
  }) {
    final entry = TradeHistoryEntry(
      id: 'trade:${offer.id}:${league.tradeHistory.length}',
      teamAId: offer.teamAId,
      teamBId: offer.teamBId,
      seasonYear: offer.seasonYear,
      week: offer.week,
      day: offer.day,
      outcome: outcome,
      assetsFromA: offer.assetsFromA,
      assetsFromB: offer.assetsFromB,
      reason: reason,
      ntcPlayerId: ntcPlayerId,
      ntcConsentProbability: ntcConsentProbability,
      offerId: offer.id,
      threadId: offer.threadId,
      round: offer.round,
    );
    return league.copyWith(tradeHistory: [...league.tradeHistory, entry]);
  }

  LeagueState _acknowledgeOfferMessages(LeagueState league, String offerId) {
    var inbox = league.inbox;
    for (final message in league.inbox.messages) {
      if (message.payload['tradeOfferId'] == offerId) {
        inbox = inbox.acknowledge(message.id);
      }
    }
    return league.copyWith(inbox: inbox);
  }

  LeagueState _sendPendingOfferMessage(LeagueState league, TradeOffer offer) {
    final a = league.teamById(offer.teamAId);
    final b = league.teamById(offer.teamBId);
    final otherTeam = league.playerTeamId == offer.teamAId ? b : a;
    return messages.send(
      league,
      type: MessageType.tradeOffer,
      domain: MessageDomain.trades,
      args: {
        'teamAName': a?.name ?? offer.teamAId,
        'teamBName': b?.name ?? offer.teamBId,
        'otherTeamName': otherTeam?.name ?? offer.teamBId,
        'tradeOfferExpiry':
            '${offer.expirySeasonYear}-W${offer.expiryWeek}-D${offer.expiryDay}',
      },
      payload: {
        'tradeOfferId': offer.id,
        'threadId': offer.threadId,
        'round': offer.round,
        'teamAId': offer.teamAId,
        'teamBId': offer.teamBId,
        'awaitingTeamId': offer.awaitingTeamId,
        'assetsFromA': [for (final asset in offer.assetsFromA) asset.toJson()],
        'assetsFromB': [for (final asset in offer.assetsFromB) asset.toJson()],
      },
      expiresAt: _momentFor(
        offer.expirySeasonYear,
        offer.expiryWeek,
        offer.expiryDay,
        offer.expiryHour,
      ).toIso8601String(),
    );
  }

  LeagueState _sendCounterOfferMessage(LeagueState league, TradeOffer offer) {
    final a = league.teamById(offer.teamAId);
    final b = league.teamById(offer.teamBId);
    final otherTeam = league.playerTeamId == offer.teamAId ? b : a;
    return messages.send(
      league,
      type: MessageType.trade,
      kind: 'counter',
      domain: MessageDomain.trades,
      args: {
        'teamAName': a?.name ?? offer.teamAId,
        'teamBName': b?.name ?? offer.teamBId,
        'otherTeamName': otherTeam?.name ?? offer.teamBId,
      },
      payload: {
        'tradeOfferId': offer.id,
        'threadId': offer.threadId,
        'round': offer.round,
        'teamAId': offer.teamAId,
        'teamBId': offer.teamBId,
        'awaitingTeamId': offer.awaitingTeamId,
        'assetsFromA': [for (final asset in offer.assetsFromA) asset.toJson()],
        'assetsFromB': [for (final asset in offer.assetsFromB) asset.toJson()],
      },
      expiresAt: _momentFor(
        offer.expirySeasonYear,
        offer.expiryWeek,
        offer.expiryDay,
        offer.expiryHour,
      ).toIso8601String(),
    );
  }

  DateTime _offerExpiryMoment(int year, int week, int day, int hour) {
    final now = _momentFor(year, week, day, hour);
    final deadlineYear = week >= 23 ? year + 1 : year;
    final deadline = _momentFor(deadlineYear, 23, 1, 0);
    final sevenDays = now.add(const Duration(days: 7));
    return sevenDays.isBefore(deadline) ? sevenDays : deadline;
  }

  DateTime _momentFor(int year, int week, int day, int hour) => DateTime.utc(
    year,
    1,
    1,
  ).add(Duration(days: (week - 1) * 7 + (day - 1), hours: hour));

  (int, int, int, int) _coordinatesForMoment(DateTime moment) {
    final yearStart = DateTime.utc(moment.year, 1, 1);
    final dayOfYear = moment.difference(yearStart).inDays;
    return (moment.year, dayOfYear ~/ 7 + 1, dayOfYear % 7 + 1, moment.hour);
  }

  LeagueState _addHistory(
    LeagueState league,
    TradeProposal proposal, {
    required String outcome,
    String? reason,
    String? ntcPlayerId,
    double? ntcConsentProbability,
    String? offerId,
    String? threadId,
    int round = 1,
  }) {
    final entry = TradeHistoryEntry(
      id: 'trade:${league.currentSeason.year}:${league.currentWeek}:${league.currentDay}:${league.tradeHistory.length}:${_stableHash(_proposalKey(proposal))}',
      teamAId: proposal.teamAId,
      teamBId: proposal.teamBId,
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      outcome: outcome,
      assetsFromA: [
        for (final asset in proposal.assetsFromA) asset.toSnapshot(),
      ],
      assetsFromB: [
        for (final asset in proposal.assetsFromB) asset.toSnapshot(),
      ],
      reason: reason,
      ntcPlayerId: ntcPlayerId,
      ntcConsentProbability: ntcConsentProbability,
      offerId: offerId,
      threadId: threadId,
      round: round,
    );
    return league.copyWith(tradeHistory: [...league.tradeHistory, entry]);
  }

  LeagueState _sendTradeOfferMessage(
    LeagueState league,
    TradeProposal proposal,
  ) {
    final tradeOfferId =
        'offer:${league.currentSeason.year}:${league.currentWeek}:${league.currentDay}:${_stableHash(_proposalKey(proposal))}';
    var next = messages.send(
      league,
      type: MessageType.tradeOffer,
      domain: MessageDomain.trades,
      args: {
        'teamAName':
            league.teamById(proposal.teamAId)?.name ?? proposal.teamAId,
        'teamBName':
            league.teamById(proposal.teamBId)?.name ?? proposal.teamBId,
      },
      payload: {
        'tradeOfferId': tradeOfferId,
        'teamAId': proposal.teamAId,
        'teamBId': proposal.teamBId,
        'assetsFromA': [
          for (final asset in proposal.assetsFromA) asset.toSnapshot().toJson(),
        ],
        'assetsFromB': [
          for (final asset in proposal.assetsFromB) asset.toSnapshot().toJson(),
        ],
      },
      expiresAt: _logicalDate(
        league,
      ).add(const Duration(days: 1)).toIso8601String(),
    );
    String? offerMessageId;
    for (final message in next.inbox.messages.reversed) {
      if (message.payload['tradeOfferId'] == tradeOfferId) {
        offerMessageId = message.id;
        break;
      }
    }
    if (offerMessageId != null) {
      next = next.copyWith(inbox: next.inbox.acknowledge(offerMessageId));
    }
    return next;
  }

  LeagueState _sendOutcomeMessage(
    LeagueState league,
    TradeProposal proposal, {
    required String kind,
    String? reason,
    String? subjectName,
    Map<String, dynamic> extraPayload = const {},
  }) {
    final a = league.teamById(proposal.teamAId);
    final b = league.teamById(proposal.teamBId);
    final otherTeam = league.playerTeamId == proposal.teamAId ? b : a;
    return messages.send(
      league,
      type: MessageType.trade,
      kind: kind,
      domain: MessageDomain.trades,
      priority: kind == 'accepted' || kind == 'ntcRefusal'
          ? MessagePriority.urgent
          : MessagePriority.normal,
      args: {
        'teamAName': a?.name ?? proposal.teamAId,
        'teamBName': b?.name ?? proposal.teamBId,
        'otherTeamName': otherTeam?.name ?? proposal.teamBId,
        if (subjectName != null) 'subjectName': subjectName,
      },
      payload: {
        'tradeId':
            'trade:${league.currentSeason.year}:${league.currentWeek}:${league.currentDay}',
        'teamAId': proposal.teamAId,
        'teamBId': proposal.teamBId,
        if (reason != null) 'reason': reason,
        'assetsFromA': [
          for (final asset in proposal.assetsFromA) asset.toSnapshot().toJson(),
        ],
        'assetsFromB': [
          for (final asset in proposal.assetsFromB) asset.toSnapshot().toJson(),
        ],
        ...extraPayload,
      },
    );
  }

  String _latestTradeId(LeagueState league) =>
      league.tradeHistory.isEmpty ? '' : league.tradeHistory.last.id;

  String _proposalKey(TradeProposal proposal) =>
      '${proposal.teamAId}|${proposal.teamBId}|${proposal.assetsFromA.map((a) => a.identity).join(',')}|${proposal.assetsFromB.map((a) => a.identity).join(',')}';

  DateTime _logicalDate(LeagueState league) => DateTime.utc(
    league.currentSeason.year,
    1,
    1,
  ).add(Duration(days: (league.currentWeek - 1) * 7 + (league.currentDay - 1)));

  int _stableHash(String value) {
    var hash = 2166136261;
    for (final unit in value.codeUnits) {
      hash = ((hash ^ unit) * 16777619) & 0x7fffffff;
    }
    return hash;
  }
}
