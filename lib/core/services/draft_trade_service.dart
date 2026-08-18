import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/trade_models.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/core/services/trade_service.dart';

/// Result of a direct mutation of two active draft slots.
class DraftSlotSwapResult {
  const DraftSlotSwapResult({
    required this.league,
    required this.validation,
    required this.changed,
    required this.outcome,
  });

  final LeagueState league;
  final TradeValidation validation;
  final bool changed;
  final String outcome;
}

/// Owns transactions whose assets are slots in [DraftState.order].
///
/// `Team.ownedPicks` contains only future/unmaterialized picks. Once the
/// lottery builds the current order, the order is the sole source of truth for
/// active slots, so ordinary [TradeService] ownership checks must not be used
/// for these transactions.
class DraftTradeService {
  DraftTradeService({
    this.balance = BalanceConfig.defaults,
    CalendarService? calendar,
    MessageService? messageService,
  }) : calendar = calendar ?? CalendarService(balance: balance),
       messages = messageService ?? MessageService();

  final BalanceConfig balance;
  final CalendarService calendar;
  final MessageService messages;

  /// Returns an active-draft slot by its stable id, including a completed slot
  /// while the current draft state is still retained for audit purposes.
  DraftPick? pickById(LeagueState league, String pickId) {
    final order = league.currentSeason.draftState?.order ?? const <DraftPick>[];
    for (final pick in order) {
      if (pick.id == pickId) return pick;
    }
    return null;
  }

  /// Whether an offer belongs to the active-slot transaction domain.
  ///
  /// The explicit marker covers stale offers after a draft state has been
  /// replaced; the pick-id check keeps old serialized offers readable even if
  /// they were created before the marker was introduced.
  bool isDraftOffer(LeagueState league, String offerId) {
    final offer = league.tradeOfferById(offerId);
    return offer != null && _isDraftOfferRecord(league, offer);
  }

  /// Finds a pending draft offer that already references [pickId].
  /// SeasonService uses this guard before re-running a deterministic AI turn.
  TradeOffer? pendingOfferForPick(LeagueState league, String pickId) {
    for (final offer in league.tradeOffers) {
      if (!offer.isPending || !_isDraftOfferRecord(league, offer)) continue;
      final pair = _pickPairFromOffer(offer);
      if (pair != null && (pair.$1 == pickId || pair.$2 == pickId)) {
        return offer;
      }
    }
    return null;
  }

  bool _isDraftOfferRecord(LeagueState league, TradeOffer offer) {
    if (offer.reason?.startsWith('draftTrade') == true) return true;
    final draft = league.currentSeason.draftState;
    if (draft == null) return false;
    final ids = {for (final pick in draft.order) pick.id};
    final snapshots = [...offer.assetsFromA, ...offer.assetsFromB];
    return snapshots.any(
      (asset) =>
          asset.type == 'pick' &&
          asset.pickId != null &&
          ids.contains(asset.pickId),
    );
  }

  /// Validates two distinct, unconsumed slots and their expected owners.
  ///
  /// [firstOwnerId] and [secondOwnerId] are optional for read-only callers,
  /// but offer acceptance always supplies them. Supplying them makes a saved
  /// offer stale instead of allowing a later transaction to swap different
  /// owners accidentally.
  TradeValidation validateActiveSwap(
    LeagueState league, {
    required String firstPickId,
    required String secondPickId,
    String? firstOwnerId,
    String? secondOwnerId,
  }) {
    final draft = league.currentSeason.draftState;
    if (draft == null) {
      return const TradeValidation(
        ok: false,
        code: 'draftNotFound',
        reason: 'Brak aktywnego draftu',
      );
    }
    if (firstPickId == secondPickId) {
      return const TradeValidation(
        ok: false,
        code: 'sameDraftPick',
        reason: 'Wymiana wymaga dwóch różnych slotów draftu',
      );
    }

    final firstIndex = _indexOf(draft, firstPickId);
    final secondIndex = _indexOf(draft, secondPickId);
    if (firstIndex < 0 || secondIndex < 0) {
      return const TradeValidation(
        ok: false,
        code: 'draftPickNotFound',
        reason: 'Slot draftu nie istnieje w bieżącej kolejności',
      );
    }
    final first = draft.order[firstIndex];
    final second = draft.order[secondIndex];
    if (!_isUnconsumed(draft, firstIndex, first) ||
        !_isUnconsumed(draft, secondIndex, second)) {
      return const TradeValidation(
        ok: false,
        code: 'draftPickConsumed',
        reason: 'Nie można wymienić skonsumowanego slotu draftu',
      );
    }
    if (firstOwnerId != null && first.teamId != firstOwnerId) {
      return const TradeValidation(
        ok: false,
        code: 'staleDraftOffer',
        reason: 'Właściciel pierwszego slotu zmienił się przed rozliczeniem',
      );
    }
    if (secondOwnerId != null && second.teamId != secondOwnerId) {
      return const TradeValidation(
        ok: false,
        code: 'staleDraftOffer',
        reason: 'Właściciel drugiego slotu zmienił się przed rozliczeniem',
      );
    }
    if (first.teamId == second.teamId) {
      return const TradeValidation(
        ok: false,
        code: 'sameTeam',
        reason: 'Wymiana musi obejmować dwie różne drużyny',
      );
    }
    if (league.teamById(first.teamId) == null ||
        league.teamById(second.teamId) == null) {
      return const TradeValidation(
        ok: false,
        code: 'teamNotFound',
        reason: 'Drużyna właściciela slotu nie istnieje',
      );
    }
    return const TradeValidation(ok: true);
  }

  /// Atomically swaps the current owners of two active slots.
  ///
  /// The pick ids, original owners, pick numbers and [currentPickIndex] are
  /// never changed. Replaying the same operation is a no-op when its history
  /// entry is already present, which protects accept/retry paths from a
  /// double transfer.
  DraftSlotSwapResult swapActiveSlots(
    LeagueState league, {
    required String firstPickId,
    required String secondPickId,
    String? firstOwnerId,
    String? secondOwnerId,
    String? operationId,
    String? reason,
    bool recordHistory = true,
  }) {
    if (_hasAcceptedOperation(league, operationId: operationId) ||
        (operationId == null &&
            _hasAcceptedPair(league, firstPickId, secondPickId))) {
      return DraftSlotSwapResult(
        league: league,
        validation: const TradeValidation(ok: true),
        changed: false,
        outcome: 'alreadyApplied',
      );
    }

    final validation = validateActiveSwap(
      league,
      firstPickId: firstPickId,
      secondPickId: secondPickId,
      firstOwnerId: firstOwnerId,
      secondOwnerId: secondOwnerId,
    );
    if (!validation.ok) {
      return DraftSlotSwapResult(
        league: league,
        validation: validation,
        changed: false,
        outcome: validation.code ?? 'hardRejected',
      );
    }

    final draft = league.currentSeason.draftState!;
    final firstIndex = _indexOf(draft, firstPickId);
    final secondIndex = _indexOf(draft, secondPickId);
    final first = draft.order[firstIndex];
    final second = draft.order[secondIndex];
    final order = List<DraftPick>.from(draft.order);
    order[firstIndex] = first.copyWith(teamId: second.teamId);
    order[secondIndex] = second.copyWith(teamId: first.teamId);

    var next = league.copyWith(
      currentSeason: league.currentSeason.copyWith(
        draftState: draft.copyWith(order: order),
      ),
    );
    if (recordHistory) {
      next = _addSwapHistory(
        next,
        first,
        second,
        outcome: 'accepted',
        reason: reason,
        offerId: operationId,
      );
    }
    return DraftSlotSwapResult(
      league: next,
      validation: validation,
      changed: true,
      outcome: 'accepted',
    );
  }

  /// Creates a persisted one-slot-for-one-slot offer.
  ///
  /// [offeredPickId] is sent by [offeringTeamId], and the other slot is sent
  /// by its current owner. Existing pending offers with the same orientation
  /// and pair are returned instead of being duplicated.
  TradeOfferResult createOfferForSlots(
    LeagueState league, {
    required String offeredPickId,
    required String targetPickId,
    required String offeringTeamId,
    String? threadId,
    String? parentOfferId,
    bool emitMessages = true,
    bool enforceWindow = true,
  }) {
    final offered = pickById(league, offeredPickId);
    final target = pickById(league, targetPickId);
    if (offered == null || target == null) {
      return _failure(
        league,
        const TradeValidation(
          ok: false,
          code: 'draftPickNotFound',
          reason: 'Slot draftu nie istnieje w bieżącej kolejności',
        ),
      );
    }
    if (offered.teamId != offeringTeamId) {
      return _failure(
        league,
        const TradeValidation(
          ok: false,
          code: 'pickOwnership',
          reason: 'Oferująca drużyna nie jest właścicielem slotu',
        ),
      );
    }
    final validation = validateActiveSwap(
      league,
      firstPickId: offeredPickId,
      secondPickId: targetPickId,
      firstOwnerId: offeringTeamId,
      secondOwnerId: target.teamId,
    );
    if (!validation.ok) return _failure(league, validation);
    if (enforceWindow &&
        !calendar.isTradeWindowOpen(
          league.currentWeek,
          day: league.currentDay,
        )) {
      return _failure(
        league,
        const TradeValidation(
          ok: false,
          code: 'tradeWindowClosed',
          reason: 'Okno wymian jest zamknięte',
        ),
      );
    }

    final existing = _pendingOfferForPair(
      league,
      offeredPickId,
      targetPickId,
      offeringTeamId,
      target.teamId,
    );
    if (existing != null) {
      return TradeOfferResult(
        league: league,
        validation: validation,
        changed: false,
        outcome: 'pending',
        offerId: existing.id,
      );
    }

    final proposal = TradeProposal(
      teamAId: offeringTeamId,
      teamBId: target.teamId,
      assetsFromA: [_assetForPick(offered)],
      assetsFromB: [_assetForPick(target)],
    );
    final round = parentOfferId == null
        ? 1
        : (league.tradeOfferById(parentOfferId)?.round ?? 1) + 1;
    final offer = _buildOffer(
      league,
      proposal,
      offeringTeamId: offeringTeamId,
      awaitingTeamId: target.teamId,
      threadId: threadId,
      parentOfferId: parentOfferId,
      round: round,
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

  /// Accepts a draft-slot offer after revalidating both current owners.
  TradeOfferResult acceptOffer(
    LeagueState league,
    String offerId, {
    required String actingTeamId,
    bool emitMessages = true,
  }) {
    final offer = league.tradeOfferById(offerId);
    if (offer == null || !_isDraftOfferRecord(league, offer)) {
      return _failure(
        league,
        const TradeValidation(
          ok: false,
          code: 'notDraftOffer',
          reason: 'Oferta nie jest ofertą aktywnych slotów draftu',
        ),
        offerId: offer?.id,
      );
    }
    final action = _validateOfferAction(league, offer, actingTeamId);
    if (!action.ok) {
      if (action.code == 'offerExpired') {
        final expired = expireOffers(league, emitMessages: emitMessages);
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
        offerId: offer.id,
      );
    }

    final pair = _pickPairFromOffer(offer);
    if (pair == null) {
      return _closeOfferResult(
        league,
        offer,
        status: TradeOfferStatus.hardRejected,
        validation: const TradeValidation(
          ok: false,
          code: 'invalidOfferAssets',
          reason: 'Oferta draftowa musi zawierać dokładnie dwa sloty',
        ),
        emitMessages: emitMessages,
      );
    }
    final validation = validateActiveSwap(
      league,
      firstPickId: pair.$1,
      secondPickId: pair.$2,
      firstOwnerId: offer.teamAId,
      secondOwnerId: offer.teamBId,
    );
    if (!validation.ok) {
      return _closeOfferResult(
        league,
        offer,
        status: TradeOfferStatus.hardRejected,
        validation: validation,
        emitMessages: emitMessages,
      );
    }

    final swapped = swapActiveSlots(
      league,
      firstPickId: pair.$1,
      secondPickId: pair.$2,
      firstOwnerId: offer.teamAId,
      secondOwnerId: offer.teamBId,
      operationId: offer.id,
      recordHistory: false,
    );
    if (!swapped.changed) {
      return _closeOfferResult(
        league,
        offer,
        status: TradeOfferStatus.hardRejected,
        validation: swapped.validation,
        emitMessages: emitMessages,
      );
    }

    var next = swapped.league.upsertTradeOffer(
      offer.copyWith(status: TradeOfferStatus.accepted),
    );
    next = _addOfferHistory(next, offer, outcome: 'accepted');
    if (emitMessages) {
      next = _sendOutcomeMessage(next, offer, kind: 'accepted');
    }
    next = _acknowledgeOfferMessages(next, offer.id);
    return TradeOfferResult(
      league: next,
      validation: validation,
      changed: true,
      outcome: 'accepted',
      offerId: offer.id,
    );
  }

  TradeOfferResult rejectOffer(
    LeagueState league,
    String offerId, {
    required String actingTeamId,
    String reason = 'Partner odrzucił propozycję wymiany',
    bool emitMessages = true,
  }) {
    final offer = league.tradeOfferById(offerId);
    if (offer == null || !_isDraftOfferRecord(league, offer)) {
      return _failure(
        league,
        const TradeValidation(
          ok: false,
          code: 'notDraftOffer',
          reason: 'Oferta nie jest ofertą aktywnych slotów draftu',
        ),
        offerId: offer?.id,
      );
    }
    final action = _validateOfferAction(league, offer, actingTeamId);
    if (!action.ok) {
      if (action.code == 'offerExpired') {
        final expired = expireOffers(league, emitMessages: emitMessages);
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
        offerId: offer.id,
      );
    }
    return _closeOfferResult(
      league,
      offer,
      status: TradeOfferStatus.rejected,
      validation: const TradeValidation(ok: true),
      reason: reason,
      emitMessages: emitMessages,
    );
  }

  /// Creates a counter only when it remains a legal one-for-one active-slot
  /// exchange. Regular player/pick counters are deliberately left to
  /// [TradeService] rather than being partially interpreted here.
  TradeOfferResult counterOffer(
    LeagueState league,
    String offerId,
    TradeProposal proposal, {
    required String actingTeamId,
    bool emitMessages = true,
  }) {
    final parent = league.tradeOfferById(offerId);
    if (parent == null || !_isDraftOfferRecord(league, parent)) {
      return _failure(
        league,
        const TradeValidation(
          ok: false,
          code: 'notDraftOffer',
          reason: 'Oferta nie jest ofertą aktywnych slotów draftu',
        ),
        offerId: parent?.id,
      );
    }
    final action = _validateOfferAction(league, parent, actingTeamId);
    if (!action.ok) {
      return TradeOfferResult(
        league: league,
        validation: action,
        changed: false,
        outcome: action.code ?? 'rejected',
        offerId: parent.id,
      );
    }
    if (parent.round > balance.ai.tradeMaxCounters) {
      return _closeOfferResult(
        league,
        parent,
        status: TradeOfferStatus.hardRejected,
        validation: const TradeValidation(
          ok: false,
          code: 'counterLimit',
          reason: 'Osiągnięto maksymalną liczbę kontrofert',
        ),
        reason: 'Osiągnięto maksymalną liczbę kontrofert',
        emitMessages: emitMessages,
      );
    }
    if (proposal.teamAId != parent.teamAId ||
        proposal.teamBId != parent.teamBId ||
        actingTeamId != parent.awaitingTeamId) {
      return _failure(
        league,
        const TradeValidation(
          ok: false,
          code: 'offerTeamsMismatch',
          reason: 'Kontroferta musi dotyczyć tych samych drużyn',
        ),
        offerId: parent.id,
      );
    }
    final pair = _pickPairFromProposal(proposal);
    if (pair == null) {
      return _failure(
        league,
        const TradeValidation(
          ok: false,
          code: 'draftCounterAssets',
          reason: 'Kontroferta draftowa musi zawierać dokładnie dwa sloty',
        ),
        offerId: parent.id,
      );
    }
    final validation = validateActiveSwap(
      league,
      firstPickId: pair.$1,
      secondPickId: pair.$2,
      firstOwnerId: proposal.teamAId,
      secondOwnerId: proposal.teamBId,
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

    final nextOffer = _buildOffer(
      league,
      proposal,
      offeringTeamId: actingTeamId,
      awaitingTeamId: actingTeamId == parent.teamAId
          ? parent.teamBId
          : parent.teamAId,
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

  /// Expires only draft-slot offers. The regular trade service can then run
  /// independently for ordinary offers.
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
      if (!offer.isPending || !_isDraftOfferRecord(next, offer)) continue;
      final expiry = _momentFor(
        offer.expirySeasonYear,
        offer.expiryWeek,
        offer.expiryDay,
        offer.expiryHour,
      );
      if (now.isBefore(expiry)) continue;
      next = _closeOffer(
        next,
        offer,
        status: TradeOfferStatus.expired,
        reason: 'Oferta wymiany wygasła',
        emitMessages: emitMessages,
      );
    }
    return next;
  }

  TradeProposal? proposalForOffer(LeagueState league, String offerId) {
    final offer = league.tradeOfferById(offerId);
    if (offer == null || !_isDraftOfferRecord(league, offer)) return null;
    final a = _assetFromSnapshot(offer.assetsFromA);
    final b = _assetFromSnapshot(offer.assetsFromB);
    if (a == null || b == null) return null;
    return TradeProposal(
      teamAId: offer.teamAId,
      teamBId: offer.teamBId,
      assetsFromA: [a],
      assetsFromB: [b],
    );
  }

  int _indexOf(DraftState draft, String pickId) =>
      draft.order.indexWhere((pick) => pick.id == pickId);

  bool _isUnconsumed(DraftState draft, int index, DraftPick pick) =>
      index >= draft.currentPickIndex &&
      pick.prospectId == null &&
      pick.playerName == null;

  TradeAsset _assetForPick(DraftPick pick) => TradeAsset.pick(
    pickId: pick.id,
    pickYear: pick.year,
    pickRound: pick.round,
    originalTeamId: pick.originalTeamId,
  );

  TradeOffer? _pendingOfferForPair(
    LeagueState league,
    String offeredPickId,
    String targetPickId,
    String offeringTeamId,
    String targetTeamId,
  ) {
    for (final offer in league.tradeOffers) {
      if (!offer.isPending || !_isDraftOfferRecord(league, offer)) continue;
      if (offer.teamAId != offeringTeamId ||
          offer.teamBId != targetTeamId ||
          offer.awaitingTeamId != targetTeamId) {
        continue;
      }
      final pair = _pickPairFromOffer(offer);
      if (pair == null) continue;
      if (pair.$1 == offeredPickId && pair.$2 == targetPickId) return offer;
    }
    return null;
  }

  (String, String)? _pickPairFromOffer(TradeOffer offer) {
    if (offer.assetsFromA.length != 1 || offer.assetsFromB.length != 1) {
      return null;
    }
    final a = offer.assetsFromA.single;
    final b = offer.assetsFromB.single;
    if (a.type != 'pick' || b.type != 'pick') return null;
    final first = a.pickId;
    final second = b.pickId;
    if (first == null || second == null) return null;
    return (first, second);
  }

  (String, String)? _pickPairFromProposal(TradeProposal proposal) {
    if (proposal.assetsFromA.length != 1 ||
        proposal.assetsFromB.length != 1 ||
        !proposal.assetsFromA.single.isPick ||
        !proposal.assetsFromB.single.isPick) {
      return null;
    }
    final first = proposal.assetsFromA.single.pickId;
    final second = proposal.assetsFromB.single.pickId;
    if (first == null || second == null) return null;
    return (first, second);
  }

  TradeAsset? _assetFromSnapshot(List<TradeAssetSnapshot> snapshots) {
    if (snapshots.length != 1) return null;
    final snapshot = snapshots.single;
    if (snapshot.type != 'pick' ||
        snapshot.pickId == null ||
        snapshot.pickYear == null ||
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
  }

  TradeOffer _buildOffer(
    LeagueState league,
    TradeProposal proposal, {
    required String offeringTeamId,
    required String awaitingTeamId,
    String? threadId,
    String? parentOfferId,
    required int round,
  }) {
    final year = league.currentSeason.year;
    final week = league.currentWeek;
    final day = league.currentDay;
    final hour = league.currentHour ?? 0;
    final sequence = league.tradeOffers.length;
    final key =
        '${proposal.teamAId}|${proposal.teamBId}|'
        '${proposal.assetsFromA.map((asset) => asset.identity).join(',')}|'
        '${proposal.assetsFromB.map((asset) => asset.identity).join(',')}|'
        '$offeringTeamId|$year|$week|$day|$hour|$sequence|$round';
    final stable = _stableHash(key);
    final resolvedThread =
        threadId ?? 'draftTradeThread:$year:$week:$day:$sequence:$stable';
    final expiry = _offerExpiryMoment(year, week, day, hour);
    final coordinates = _coordinatesForMoment(expiry);
    return TradeOffer(
      id: 'draftTradeOffer:$year:$week:$day:$hour:$sequence:$stable',
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
      expirySeasonYear: coordinates.$1,
      expiryWeek: coordinates.$2,
      expiryDay: coordinates.$3,
      expiryHour: coordinates.$4,
      reason: 'draftTrade',
    );
  }

  TradeValidation _validateOfferAction(
    LeagueState league,
    TradeOffer offer,
    String actingTeamId,
  ) {
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
    final expiry = _momentFor(
      offer.expirySeasonYear,
      offer.expiryWeek,
      offer.expiryDay,
      offer.expiryHour,
    );
    if (!now.isBefore(expiry)) {
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
    if (!calendar.isTradeWindowOpen(
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

  TradeOfferResult _closeOfferResult(
    LeagueState league,
    TradeOffer offer, {
    required TradeOfferStatus status,
    required TradeValidation validation,
    String? reason,
    required bool emitMessages,
  }) {
    final next = _closeOffer(
      league,
      offer,
      status: status,
      reason: reason ?? validation.reason,
      emitMessages: emitMessages,
    );
    return TradeOfferResult(
      league: next,
      validation: validation,
      changed: true,
      outcome: _outcomeFor(status),
      offerId: offer.id,
    );
  }

  TradeOfferResult _failure(
    LeagueState league,
    TradeValidation validation, {
    String? offerId,
  }) => TradeOfferResult(
    league: league,
    validation: validation,
    changed: false,
    outcome: validation.code ?? 'hardRejected',
    offerId: offerId,
  );

  LeagueState _closeOffer(
    LeagueState league,
    TradeOffer offer, {
    required TradeOfferStatus status,
    String? reason,
    bool emitMessages = true,
  }) {
    var next = league.upsertTradeOffer(
      offer.copyWith(status: status, reason: reason ?? offer.reason),
    );
    next = _addOfferHistory(
      next,
      offer,
      outcome: _outcomeFor(status),
      reason: reason,
    );
    if (emitMessages && status != TradeOfferStatus.expired) {
      next = _sendOutcomeMessage(
        next,
        offer,
        kind: _kindFor(status),
        reason: reason,
      );
    }
    return _acknowledgeOfferMessages(next, offer.id);
  }

  String _outcomeFor(TradeOfferStatus status) => switch (status) {
    TradeOfferStatus.accepted => 'accepted',
    TradeOfferStatus.expired => 'expired',
    TradeOfferStatus.hardRejected => 'hardRejected',
    TradeOfferStatus.countered => 'countered',
    _ => 'rejected',
  };

  String _kindFor(TradeOfferStatus status) => switch (status) {
    TradeOfferStatus.accepted => 'accepted',
    TradeOfferStatus.hardRejected => 'hardRejected',
    _ => 'rejected',
  };

  LeagueState _addOfferHistory(
    LeagueState league,
    TradeOffer offer, {
    required String outcome,
    String? reason,
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
      offerId: offer.id,
      threadId: offer.threadId,
      round: offer.round,
    );
    return league.copyWith(tradeHistory: [...league.tradeHistory, entry]);
  }

  LeagueState _addSwapHistory(
    LeagueState league,
    DraftPick first,
    DraftPick second, {
    required String outcome,
    String? reason,
    String? offerId,
  }) {
    final firstAsset = _assetForPick(first).toSnapshot();
    final secondAsset = _assetForPick(second).toSnapshot();
    final entry = TradeHistoryEntry(
      id:
          'draftTrade:${league.currentSeason.year}:${league.currentWeek}:'
          '${league.currentDay}:${league.tradeHistory.length}:${_stableHash('''
${first.id}|${second.id}|${first.teamId}|${second.teamId}
''')}',
      teamAId: first.teamId,
      teamBId: second.teamId,
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      outcome: outcome,
      assetsFromA: [firstAsset],
      assetsFromB: [secondAsset],
      reason: reason,
      offerId: offerId,
    );
    return league.copyWith(tradeHistory: [...league.tradeHistory, entry]);
  }

  bool _hasAcceptedOperation(LeagueState league, {String? operationId}) {
    if (operationId == null) return false;
    return league.tradeHistory.any(
      (entry) =>
          entry.offerId == operationId &&
          entry.outcome == 'accepted' &&
          entry.seasonYear == league.currentSeason.year,
    );
  }

  bool _hasAcceptedPair(
    LeagueState league,
    String firstPickId,
    String secondPickId,
  ) {
    for (final entry in league.tradeHistory.reversed) {
      if (entry.seasonYear != league.currentSeason.year ||
          entry.outcome != 'accepted') {
        continue;
      }
      final ids = [
        ...entry.assetsFromA,
        ...entry.assetsFromB,
      ].where((asset) => asset.type == 'pick').map((asset) => asset.pickId);
      final pickIds = ids.whereType<String>().toSet();
      if (pickIds.length == 2 &&
          pickIds.contains(firstPickId) &&
          pickIds.contains(secondPickId)) {
        return true;
      }
    }
    return false;
  }

  LeagueState _sendPendingOfferMessage(LeagueState league, TradeOffer offer) {
    final a = league.teamById(offer.teamAId);
    final b = league.teamById(offer.teamBId);
    return messages.send(
      league,
      type: MessageType.tradeOffer,
      domain: MessageDomain.trades,
      args: {
        'teamAName': a?.name ?? offer.teamAId,
        'teamBName': b?.name ?? offer.teamBId,
      },
      payload: {
        'tradeOfferId': offer.id,
        'threadId': offer.threadId,
        'round': offer.round,
        'teamAId': offer.teamAId,
        'teamBId': offer.teamBId,
        'awaitingTeamId': offer.awaitingTeamId,
        'draftTrade': true,
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
    return messages.send(
      league,
      type: MessageType.trade,
      kind: 'counter',
      domain: MessageDomain.trades,
      args: {
        'teamAName': a?.name ?? offer.teamAId,
        'teamBName': b?.name ?? offer.teamBId,
      },
      payload: {
        'tradeOfferId': offer.id,
        'threadId': offer.threadId,
        'round': offer.round,
        'teamAId': offer.teamAId,
        'teamBId': offer.teamBId,
        'awaitingTeamId': offer.awaitingTeamId,
        'draftTrade': true,
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

  LeagueState _sendOutcomeMessage(
    LeagueState league,
    TradeOffer offer, {
    required String kind,
    String? reason,
  }) {
    final a = league.teamById(offer.teamAId);
    final b = league.teamById(offer.teamBId);
    return messages.send(
      league,
      type: MessageType.trade,
      kind: kind,
      domain: MessageDomain.trades,
      priority: kind == 'accepted'
          ? MessagePriority.urgent
          : MessagePriority.normal,
      args: {
        'teamAName': a?.name ?? offer.teamAId,
        'teamBName': b?.name ?? offer.teamBId,
      },
      payload: {
        'tradeOfferId': offer.id,
        'threadId': offer.threadId,
        'draftTrade': true,
        if (reason != null) 'reason': reason,
        'assetsFromA': [for (final asset in offer.assetsFromA) asset.toJson()],
        'assetsFromB': [for (final asset in offer.assetsFromB) asset.toJson()],
      },
    );
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

  int _stableHash(String value) {
    var hash = 2166136261;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 16777619) & 0x7fffffff;
    }
    return hash;
  }
}
