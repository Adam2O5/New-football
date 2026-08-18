import 'dart:math';

import 'package:new_football/core/ai/ai_evaluation_context.dart';
import 'package:new_football/core/ai/ai_evaluation_models.dart';
import 'package:new_football/core/ai/ai_evaluation_service.dart';
import 'package:new_football/core/ai/ai_trade_models.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/team_event_state.dart';
import 'package:new_football/core/models/trade_models.dart';
import 'package:new_football/core/random/seeds.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/core/services/trade_service.dart';

/// Orchestrates AI trade preferences without owning trade legality.
///
/// [AiEvaluationService] answers "what is this package worth?" and
/// [TradeService] answers "can this package exist and execute?". This class
/// only selects targets, applies the documented AI policy and calls the
/// persisted offer lifecycle. It has no mutable save state.
class AiTradeService {
  AiTradeService({
    this.balance = BalanceConfig.defaults,
    AiEvaluationService? evaluator,
    TradeService? tradeService,
    CalendarService? calendar,
  }) : evaluator = evaluator ?? AiEvaluationService(balance: balance),
       tradeService = tradeService ?? TradeService(balance: balance),
       calendar = calendar ?? CalendarService(balance: balance);

  final BalanceConfig balance;
  final AiEvaluationService evaluator;
  final TradeService tradeService;
  final CalendarService calendar;

  /// Returns the exact four-term appetite model from §5.5.
  AiTradeAppetite appetiteForTeam({
    required LeagueState league,
    required Team team,
  }) {
    final context = evaluator.contextForTeam(
      team: team,
      league: league,
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
    );
    final needs = evaluator.rosterNeeds(context);
    var maxNeed = needs.isEmpty
        ? 0.0
        : needs.map((need) => max(0.0, need.needScore)).reduce(max);
    if (team.eventState.transferSituations.any(
      (situation) => situation.weeksRemaining > 0,
    )) {
      // A pending transfer request is a player-specific ×3 appetite signal.
      // Raising the club's maximum need keeps that signal in the same formula
      // while the target selector applies it to the requested player too.
      maxNeed = max(maxNeed, 100.0);
    }
    final surplusPressure = needs.isEmpty
        ? 0.0
        : needs
              .map(
                (need) => max(
                  0.0,
                  (need.count - need.definition.max) /
                      max(1, need.definition.max),
                ),
              )
              .reduce(max)
              .clamp(0.0, 1.0)
              .toDouble();
    final injuryPressure = _injuryPressure(team, needs);
    final deadlineProximity = _deadlineProximity(league.currentWeek);
    var value =
        0.35 * (maxNeed / 100.0) +
        0.25 * surplusPressure +
        0.20 * deadlineProximity +
        0.20 * injuryPressure;
    if (deadlineProximity > 0) {
      value *= balance.ai.tradeDeadlineAppetiteMultiplier;
    }
    final superteam = _isSuperteam(league, team);
    if (superteam) value *= 0.5;
    return AiTradeAppetite(
      maxNeedScore: maxNeed.clamp(0.0, 100.0).toDouble(),
      surplusPositionPressure: surplusPressure,
      deadlineProximity: deadlineProximity,
      injuryPressure: injuryPressure,
      value: value.clamp(0.0, 1.0).toDouble(),
    );
  }

  /// Convenience scalar form used by pair selection and UI diagnostics.
  double tradeAppetite({required LeagueState league, required Team team}) =>
      appetiteForTeam(league: league, team: team).value;

  /// Evaluates an offer from [evaluatingTeamId]'s point of view.
  ///
  /// `surplusPct` is the canonical evaluator result after converting the
  /// documented threshold shifts into an effective comparison value. A
  /// positive shift makes an offer harder to accept; a negative shift makes it
  /// easier. The underlying package evaluation remains available unchanged.
  AiTradeDecision evaluateOffer({
    required LeagueState league,
    required TradeProposal proposal,
    required String evaluatingTeamId,
    int saveSeed = 0,
    int packageSalt = 0,
    int round = 1,
  }) {
    final self = league.teamById(evaluatingTeamId);
    if (self == null) throw StateError('Unknown evaluating team');
    final partnerId = self.id == proposal.teamAId
        ? proposal.teamBId
        : proposal.teamAId;
    final partner = league.teamById(partnerId);
    if (partner == null) throw StateError('Unknown trade partner');
    final incoming = self.id == proposal.teamAId
        ? proposal.assetsFromB
        : proposal.assetsFromA;
    final outgoing = self.id == proposal.teamAId
        ? proposal.assetsFromA
        : proposal.assetsFromB;
    final evaluation = evaluator.evaluateTradeAssets(
      recipient: self,
      partner: partner,
      incomingAssets: incoming,
      outgoingAssets: outgoing,
      league: league,
      currentYear: league.currentSeason.year,
      saveSeed: saveSeed,
      week: league.currentWeek,
      packageSalt: packageSalt,
    );
    final context = evaluator.contextForTeam(
      team: self,
      league: league,
      saveSeed: saveSeed,
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
    );
    final shift = _thresholdShift(
      league: league,
      self: self,
      partner: partner,
      incoming: incoming,
      outgoing: outgoing,
      context: context,
    );
    final effective = evaluation.surplusPct - shift;
    final contractDump = _containsContractDrag(
      evaluation,
      incoming: incoming,
      outgoing: outgoing,
      source: self,
      partner: partner,
    );

    if (evaluation.hardRejected) {
      return AiTradeDecision(
        action: AiTradeAction.hardReject,
        surplusPct: effective,
        rawSurplusPct: evaluation.rawSurplusPct,
        thresholdShiftPp: shift,
        evaluation: evaluation,
        hardRejectProbability: 1.0,
        contractDump: contractDump,
        reason: 'secondApron',
      );
    }

    // A club that is deliberately unloading a burden may accept a documented
    // negative surplus, provided the first-round hard limit is not broken.
    if (_isDumpFromSelf(
          self: self,
          incoming: incoming,
          outgoing: outgoing,
          evaluation: evaluation,
        ) &&
        !_violatesDumpFirstRoundLimit(
          league: league,
          team: self,
          outgoing: outgoing,
        )) {
      final floor = _dumpFloor(evaluation);
      if (effective >= floor && effective < balance.ai.tradeAcceptLow * 100) {
        return AiTradeDecision(
          action: AiTradeAction.accept,
          surplusPct: effective,
          rawSurplusPct: evaluation.rawSurplusPct,
          thresholdShiftPp: shift,
          evaluation: evaluation,
          acceptProbability: 1.0,
          contractDump: true,
          reason: 'contractDump',
        );
      }
    }

    final random = Random(
      negotiationSeed(
        saveSeed,
        league.currentSeason.year,
        league.currentWeek,
        self.id,
        DecisionType.tradeEval,
        '$partnerId:${_proposalKey(proposal)}',
        'reaction',
        round: round,
        salt: packageSalt,
      ),
    );
    final roll = random.nextDouble();
    final high = balance.ai.tradeAcceptHigh * 100.0;
    final low = balance.ai.tradeAcceptLow * 100.0;
    final hard = balance.ai.tradeHardReject * 100.0;
    late AiTradeAction action;
    var acceptProbability = 0.0;
    var counterProbability = 0.0;
    var rejectProbability = 0.0;
    var hardRejectProbability = 0.0;
    double? counterTarget;

    if (effective >= high) {
      acceptProbability = balance.ai.tradeAcceptProbabilityHigh;
      counterProbability = 1.0 - acceptProbability;
      action = roll < acceptProbability
          ? AiTradeAction.accept
          : AiTradeAction.counter;
      counterTarget = _counterTargetForRound(round);
    } else if (effective >= low) {
      acceptProbability = balance.ai.tradeAcceptProbabilityLow;
      counterProbability = balance.ai.tradeCounterProbabilityHigh;
      action = roll < acceptProbability
          ? AiTradeAction.accept
          : AiTradeAction.counter;
      counterTarget = _counterTargetForRound(round);
    } else if (effective >= -low) {
      counterProbability = balance.ai.tradeCounterProbabilityNearFair;
      rejectProbability = balance.ai.tradeRejectProbabilityNearFair;
      action = roll < counterProbability
          ? AiTradeAction.counter
          : AiTradeAction.reject;
      counterTarget = _counterTargetForRound(round);
    } else if (effective >= -15.0) {
      counterProbability = balance.ai.tradeCounterProbabilityLow;
      rejectProbability = balance.ai.tradeRejectProbabilityLow;
      action = roll < counterProbability
          ? AiTradeAction.counter
          : AiTradeAction.reject;
      counterTarget = _counterTargetForRound(round);
    } else if (effective >= hard) {
      rejectProbability = balance.ai.tradeRejectProbabilityHardBand;
      hardRejectProbability = balance.ai.tradeHardRejectProbabilityHardBand;
      action = roll < hardRejectProbability
          ? AiTradeAction.hardReject
          : AiTradeAction.reject;
    } else {
      hardRejectProbability = 1.0;
      action = AiTradeAction.hardReject;
    }

    if (round > balance.ai.tradeMaxCounters &&
        action == AiTradeAction.counter) {
      action = AiTradeAction.hardReject;
      counterProbability = 0.0;
      hardRejectProbability = 1.0;
      counterTarget = null;
    }
    return AiTradeDecision(
      action: action,
      surplusPct: effective,
      rawSurplusPct: evaluation.rawSurplusPct,
      thresholdShiftPp: shift,
      evaluation: evaluation,
      acceptProbability: acceptProbability,
      counterProbability: counterProbability,
      rejectProbability: rejectProbability,
      hardRejectProbability: hardRejectProbability,
      counterTargetPct: counterTarget,
      contractDump: contractDump,
    );
  }

  /// Compatibility name for callers that use the verb from the design docs.
  AiTradeDecision decideOffer({
    required LeagueState league,
    required TradeProposal proposal,
    required String evaluatingTeamId,
    int saveSeed = 0,
    int packageSalt = 0,
    int round = 1,
  }) => evaluateOffer(
    league: league,
    proposal: proposal,
    evaluatingTeamId: evaluatingTeamId,
    saveSeed: saveSeed,
    packageSalt: packageSalt,
    round: round,
  );

  /// Builds a minimal legal counter package near [targetSurplusPct].
  TradeProposal? buildCounterProposal({
    required LeagueState league,
    required TradeProposal proposal,
    required String evaluatingTeamId,
    required double targetSurplusPct,
    int saveSeed = 0,
    int round = 1,
  }) {
    final self = league.teamById(evaluatingTeamId);
    if (self == null) return null;
    final partnerId = self.id == proposal.teamAId
        ? proposal.teamBId
        : proposal.teamAId;
    final partner = league.teamById(partnerId);
    if (partner == null) return null;
    final incoming = self.id == proposal.teamAId
        ? proposal.assetsFromB
        : proposal.assetsFromA;
    final outgoing = self.id == proposal.teamAId
        ? proposal.assetsFromA
        : proposal.assetsFromB;
    final existing = {
      ...incoming.map((asset) => asset.identity),
      ...outgoing.map((asset) => asset.identity),
    };
    final variants = <TradeProposal>[];

    void addVariant(
      List<TradeAsset> nextIncoming,
      List<TradeAsset> nextOutgoing,
    ) {
      final candidate = self.id == proposal.teamAId
          ? TradeProposal(
              teamAId: proposal.teamAId,
              teamBId: proposal.teamBId,
              assetsFromA: nextOutgoing,
              assetsFromB: nextIncoming,
            )
          : TradeProposal(
              teamAId: proposal.teamAId,
              teamBId: proposal.teamBId,
              assetsFromA: nextIncoming,
              assetsFromB: nextOutgoing,
            );
      if (_proposalKey(candidate) != _proposalKey(proposal)) {
        variants.add(candidate);
      }
    }

    for (final asset in outgoing) {
      addVariant(
        List<TradeAsset>.from(incoming),
        outgoing.where((item) => item.identity != asset.identity).toList(),
      );
    }
    for (final asset in _tradableAssets(partner)) {
      if (existing.contains(asset.identity)) continue;
      if (asset.isPlayer &&
          !_passesNtcPlanning(
            league: league,
            source: partner,
            destination: self,
            playerId: asset.playerId!,
          )) {
        continue;
      }
      addVariant([...incoming, asset], List<TradeAsset>.from(outgoing));
      if (variants.length >= 24) break;
    }
    for (final asset in _tradableAssets(self)) {
      if (existing.contains(asset.identity)) continue;
      addVariant(List<TradeAsset>.from(incoming), [...outgoing, asset]);
      if (variants.length >= 36) break;
    }

    TradeProposal? best;
    var bestDistance = double.infinity;
    var bestBelow = -double.infinity;
    for (var index = 0; index < variants.length; index++) {
      final candidate = variants[index];
      final validation = tradeService.validateLeague(
        league,
        candidate,
        currentWeek: league.currentWeek,
        currentDay: league.currentDay,
      );
      if (!validation.ok) continue;
      final decision = evaluateOffer(
        league: league,
        proposal: candidate,
        evaluatingTeamId: self.id,
        saveSeed: saveSeed,
        packageSalt: 1000 + index,
        round: round,
      );
      if (decision.hardRejected) continue;
      final distance = decision.surplusPct - targetSurplusPct;
      if (distance >= 0 && distance < bestDistance) {
        best = candidate;
        bestDistance = distance;
      } else if (best == null && decision.surplusPct > bestBelow) {
        best = candidate;
        bestBelow = decision.surplusPct;
      }
    }
    return best;
  }

  /// Lets an AI answer a pending offer addressed to it. This is used by both
  /// the headless market and the player-facing trade screen.
  TradeOfferResult respondToOffer(
    LeagueState league,
    String offerId, {
    required int saveSeed,
    bool emitMessages = true,
  }) {
    final offer = league.tradeOfferById(offerId);
    if (offer == null) {
      return TradeOfferResult(
        league: league,
        validation: const TradeValidation(
          ok: false,
          code: 'offerNotFound',
          reason: 'Oferta wymiany nie istnieje',
        ),
        changed: false,
        outcome: 'offerNotFound',
      );
    }
    final ai = league.teamById(offer.awaitingTeamId);
    final proposal = tradeService.proposalForOffer(league, offer.id);
    if (ai == null || ai.ai == null || proposal == null) {
      return TradeOfferResult(
        league: league,
        validation: const TradeValidation(
          ok: false,
          code: 'offerActor',
          reason: 'Oferta nie oczekuje decyzji drużyny AI',
        ),
        changed: false,
        outcome: 'offerActor',
        offerId: offer.id,
      );
    }
    final decision = evaluateOffer(
      league: league,
      proposal: proposal,
      evaluatingTeamId: ai.id,
      saveSeed: saveSeed,
      packageSalt: offer.round,
      round: offer.round,
    );
    switch (decision.action) {
      case AiTradeAction.accept:
        return tradeService.acceptOffer(
          league,
          offer.id,
          actingTeamId: ai.id,
          emitMessages: emitMessages,
        );
      case AiTradeAction.reject:
        return tradeService.rejectOffer(
          league,
          offer.id,
          actingTeamId: ai.id,
          emitMessages: emitMessages,
        );
      case AiTradeAction.hardReject:
        return tradeService.rejectOffer(
          league,
          offer.id,
          actingTeamId: ai.id,
          hardReject: true,
          emitMessages: emitMessages,
        );
      case AiTradeAction.counter:
        final target =
            decision.counterTargetPct ?? balance.ai.tradeOfferMinimum;
        final counter = buildCounterProposal(
          league: league,
          proposal: proposal,
          evaluatingTeamId: ai.id,
          targetSurplusPct: target,
          saveSeed: saveSeed,
          round: offer.round,
        );
        if (counter == null) {
          return tradeService.rejectOffer(
            league,
            offer.id,
            actingTeamId: ai.id,
            hardReject: true,
            emitMessages: emitMessages,
          );
        }
        return tradeService.counterOffer(
          league,
          offer.id,
          counter,
          actingTeamId: ai.id,
          emitMessages: emitMessages,
        );
    }
  }

  /// Runs one deterministic AI↔AI and AI→player market tick.
  AiTradeWeeklyResult runWeeklyTick(
    LeagueState league, {
    required int saveSeed,
  }) {
    if (!calendar.isTradeWindowOpen(
      league.currentWeek,
      day: league.currentDay,
    )) {
      return AiTradeWeeklyResult(league: league);
    }
    var state = league;
    final aiTeams = [
      for (final team in state.teams)
        if (team.ai != null && team.id != state.playerTeamId) team,
    ];
    if (aiTeams.length < 2) {
      return _runPlayerOffers(state, aiTeams, saveSeed: saveSeed);
    }
    final appetites = {
      for (final team in aiTeams)
        team.id: appetiteForTeam(league: state, team: team),
    };
    final eligible = aiTeams
        .where((team) => (appetites[team.id]?.value ?? 0) >= 0.30)
        .toList();
    final pairScores = <String, double>{};
    for (var i = 0; i < eligible.length; i++) {
      for (var j = i + 1; j < eligible.length; j++) {
        final a = eligible[i];
        final b = eligible[j];
        final key = '${a.id}|${b.id}';
        pairScores[key] = Random(
          negotiationSeed(
            saveSeed,
            state.currentSeason.year,
            state.currentWeek,
            'league',
            DecisionType.tradeInit,
            key,
            'pair',
          ),
        ).nextDouble();
      }
    }
    final pairs = pairScores.keys.toList()
      ..sort((a, b) => pairScores[b]!.compareTo(pairScores[a]!));
    final selected = pairs.take(balance.ai.aiTradeCandidatePairs).toList();
    var tested = 0;
    var executed = 0;
    var rejected = 0;
    for (final key in selected) {
      final ids = key.split('|');
      if (ids.length != 2) continue;
      final a = state.teamById(ids[0]);
      final b = state.teamById(ids[1]);
      if (a == null || b == null) continue;
      if (!_canTradeThisWeek(state, a.id) || !_canTradeThisWeek(state, b.id)) {
        continue;
      }
      final packages = _packagesForPair(state, a, b, saveSeed: saveSeed);
      var traded = false;
      for (final package in packages) {
        tested++;
        if (!package.isMutuallyBeneficial) continue;
        if (_violatesAiGuardrails(state, package.proposal)) continue;
        final created = tradeService.createOffer(
          state,
          package.proposal,
          offeringTeamId: a.id,
          emitMessages: false,
        );
        if (!created.changed || created.offerId == null) {
          rejected++;
          continue;
        }
        final accepted = tradeService.acceptOffer(
          created.league,
          created.offerId!,
          actingTeamId: b.id,
          emitMessages: false,
        );
        state = accepted.league;
        if (accepted.outcome == 'accepted' && accepted.changed) {
          executed++;
          traded = true;
          break;
        }
        rejected++;
      }
      if (!traded) continue;
    }
    final playerResult = _runPlayerOffers(state, [
      for (final team in aiTeams) state.teamById(team.id) ?? team,
    ], saveSeed: saveSeed);
    state = playerResult.league;
    return AiTradeWeeklyResult(
      league: state,
      candidatePairs: selected.length,
      testedPackages: tested + playerResult.testedPackages,
      executedAiTrades: executed + playerResult.executedAiTrades,
      createdPlayerOffers: playerResult.createdPlayerOffers,
      rejectedCandidates: rejected + playerResult.rejectedCandidates,
      changed: state != league,
    );
  }

  /// Alias used by simulator integrations.
  AiTradeWeeklyResult weeklyTick(LeagueState league, {required int saveSeed}) =>
      runWeeklyTick(league, saveSeed: saveSeed);

  AiTradeWeeklyResult _runPlayerOffers(
    LeagueState league,
    List<Team> aiTeams, {
    required int saveSeed,
  }) {
    final playerId = league.playerTeamId;
    final player = playerId == null ? null : league.teamById(playerId);
    if (player == null) return AiTradeWeeklyResult(league: league);
    var state = league;
    var createdOffers = 0;
    var tested = 0;
    var rejected = 0;
    final order = [...aiTeams]..sort((a, b) => a.id.compareTo(b.id));
    for (final ai in order) {
      if (createdOffers >= 3) break;
      if (_hasOfferCooldown(state, ai.id, player.id)) continue;
      final roll = Random(
        negotiationSeed(
          saveSeed,
          state.currentSeason.year,
          state.currentWeek,
          ai.id,
          DecisionType.tradeInit,
          player.id,
          'player-offer',
        ),
      ).nextDouble();
      if (roll >= _playerOfferProbability(state.currentWeek)) continue;
      final proposal = _buildPlayerOffer(state, ai, player, saveSeed: saveSeed);
      if (proposal == null) continue;
      tested++;
      final created = tradeService.createOffer(
        state,
        proposal,
        offeringTeamId: ai.id,
        emitMessages: true,
      );
      if (!created.changed) {
        rejected++;
        continue;
      }
      state = created.league;
      createdOffers++;
    }
    return AiTradeWeeklyResult(
      league: state,
      testedPackages: tested,
      createdPlayerOffers: createdOffers,
      rejectedCandidates: rejected,
      changed: state != league,
    );
  }

  TradeProposal? _buildPlayerOffer(
    LeagueState league,
    Team ai,
    Team player, {
    required int saveSeed,
  }) {
    final aiContext = evaluator.contextForTeam(
      team: ai,
      league: league,
      saveSeed: saveSeed,
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
    );
    final playerContext = evaluator.contextForTeam(
      team: player,
      league: league,
      saveSeed: saveSeed,
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
    );
    final targets = [...player.roster]
      ..sort((a, b) {
        final av = evaluator.evaluatePlayer(a, aiContext, sourceTeam: player);
        final bv = evaluator.evaluatePlayer(b, aiContext, sourceTeam: player);
        return (bv.value - av.value).compareTo(0);
      });
    final candidates = <({Player player, double gap})>[];
    for (final target in targets) {
      if (!_passesNtcPlanning(
        league: league,
        source: player,
        destination: ai,
        playerId: target.id,
      )) {
        continue;
      }
      final aiValue = evaluator.evaluatePlayer(
        target,
        aiContext,
        sourceTeam: player,
      );
      final playerValue = evaluator.evaluatePlayer(
        target,
        playerContext,
        sourceTeam: player,
      );
      final gap = aiValue.value - playerValue.value;
      if (gap > 0) candidates.add((player: target, gap: gap));
    }
    candidates.sort((a, b) => b.gap.compareTo(a.gap));
    for (final target in candidates.take(8)) {
      final picks = [...ai.ownedPicks]
        ..sort(
          (a, b) => a
              .computeTradeValue(
                currentYear: league.currentSeason.year,
                balance: balance,
              )
              .compareTo(
                b.computeTradeValue(
                  currentYear: league.currentSeason.year,
                  balance: balance,
                ),
              ),
        );
      for (final pick in picks) {
        final proposal = TradeProposal(
          teamAId: ai.id,
          teamBId: player.id,
          assetsFromA: [
            TradeAsset.pick(
              pickId: pick.id,
              pickYear: pick.year,
              pickRound: pick.round,
              originalTeamId: pick.originalTeamId,
            ),
          ],
          assetsFromB: [TradeAsset.player(target.player.id)],
        );
        final validation = tradeService.validateLeague(
          league,
          proposal,
          currentWeek: league.currentWeek,
          currentDay: league.currentDay,
        );
        if (!validation.ok) continue;
        final decision = evaluateOffer(
          league: league,
          proposal: proposal,
          evaluatingTeamId: ai.id,
          saveSeed: saveSeed,
          packageSalt: 5000 + target.player.id.length,
        );
        if (decision.surplusPct < balance.ai.tradeOfferMinimum ||
            decision.surplusPct > balance.ai.tradeOfferTarget + 18.0) {
          continue;
        }
        return proposal;
      }
      // A player-for-player offer is a fallback when the AI has no suitable
      // pick. It still passes through the same legal and valuation filters.
      for (final offered in _tradablePlayers(ai).take(4)) {
        final proposal = TradeProposal(
          teamAId: ai.id,
          teamBId: player.id,
          assetsFromA: [TradeAsset.player(offered.id)],
          assetsFromB: [TradeAsset.player(target.player.id)],
        );
        final validation = tradeService.validateLeague(
          league,
          proposal,
          currentWeek: league.currentWeek,
          currentDay: league.currentDay,
        );
        if (!validation.ok) continue;
        final decision = evaluateOffer(
          league: league,
          proposal: proposal,
          evaluatingTeamId: ai.id,
          saveSeed: saveSeed,
          packageSalt: 7000 + offered.id.length,
        );
        if (decision.surplusPct >= balance.ai.tradeOfferMinimum)
          return proposal;
      }
    }
    return null;
  }

  List<AiTradePackage> _packagesForPair(
    LeagueState league,
    Team a,
    Team b, {
    required int saveSeed,
  }) {
    final proposals = <TradeProposal>[..._contractDumpProposals(league, a, b)];
    final aPlayers = _tradablePlayers(a).take(3).toList();
    final bPlayers = _tradablePlayers(b).take(3).toList();
    for (final pa in aPlayers) {
      for (final pb in bPlayers) {
        proposals.add(
          TradeProposal(
            teamAId: a.id,
            teamBId: b.id,
            assetsFromA: [TradeAsset.player(pa.id)],
            assetsFromB: [TradeAsset.player(pb.id)],
          ),
        );
      }
    }
    final aPicks = _tradablePicks(a).take(3).toList();
    final bPicks = _tradablePicks(b).take(3).toList();
    for (final pa in aPlayers.take(2)) {
      for (final pick in bPicks.take(2)) {
        proposals.add(
          TradeProposal(
            teamAId: a.id,
            teamBId: b.id,
            assetsFromA: [TradeAsset.player(pa.id)],
            assetsFromB: [_pickAsset(pick)],
          ),
        );
      }
    }
    for (final pb in bPlayers.take(2)) {
      for (final pick in aPicks.take(2)) {
        proposals.add(
          TradeProposal(
            teamAId: a.id,
            teamBId: b.id,
            assetsFromA: [_pickAsset(pick)],
            assetsFromB: [TradeAsset.player(pb.id)],
          ),
        );
      }
    }
    if (aPicks.isNotEmpty && bPicks.isNotEmpty) {
      proposals.add(
        TradeProposal(
          teamAId: a.id,
          teamBId: b.id,
          assetsFromA: [_pickAsset(aPicks.first)],
          assetsFromB: [_pickAsset(bPicks.first)],
        ),
      );
    }
    final packages = <AiTradePackage>[];
    for (var index = 0; index < proposals.length; index++) {
      if (packages.length >= balance.ai.aiTradePackagesPerPair) break;
      final proposal = proposals[index];
      if (!_passesNtcPlanningForProposal(league, proposal)) continue;
      final validation = tradeService.validateLeague(
        league,
        proposal,
        currentWeek: league.currentWeek,
        currentDay: league.currentDay,
      );
      if (!validation.ok) continue;
      if (_violatesAiGuardrails(league, proposal)) continue;
      final aEval = evaluator.evaluateTradeAssets(
        recipient: a,
        partner: b,
        incomingAssets: proposal.assetsFromB,
        outgoingAssets: proposal.assetsFromA,
        league: league,
        currentYear: league.currentSeason.year,
        saveSeed: saveSeed,
        week: league.currentWeek,
        packageSalt: index,
      );
      final bEval = evaluator.evaluateTradeAssets(
        recipient: b,
        partner: a,
        incomingAssets: proposal.assetsFromA,
        outgoingAssets: proposal.assetsFromB,
        league: league,
        currentYear: league.currentSeason.year,
        saveSeed: saveSeed,
        week: league.currentWeek,
        packageSalt: index + 100,
      );
      final contractDump = _isContractDumpProposal(league, proposal);
      final buyerAcceptsContract =
          contractDump &&
          _buyerAcceptsContract(
            league,
            proposal,
            saveSeed: saveSeed,
            packageSalt: index,
          );
      packages.add(
        AiTradePackage(
          proposal: proposal,
          teamAEvaluation: aEval,
          teamBEvaluation: bEval,
          packageIndex: index,
          validation: validation,
          contractDump: contractDump,
          buyerAcceptsContract: buyerAcceptsContract,
        ),
      );
    }
    return packages;
  }

  List<TradeProposal> _contractDumpProposals(
    LeagueState league,
    Team a,
    Team b,
  ) {
    final proposals = <TradeProposal>[];
    void addFor(Team dumper, Team absorber, {required bool dumperIsA}) {
      final status = evaluator
          .contextForTeam(
            team: dumper,
            league: league,
            seasonYear: league.currentSeason.year,
            week: league.currentWeek,
          )
          .teamStatus;
      final dumpPlayers = _tradablePlayers(
        dumper,
      ).where((player) => evaluator.contractDrag(player) >= 10);
      for (final player in dumpPlayers.take(2)) {
        final drag = evaluator.contractDrag(player);
        final pick = _dumpSweetener(
          dumper,
          drag: drag,
          status: status,
          currentYear: league.currentSeason.year,
        );
        if (pick == null) continue;
        final outgoing = [TradeAsset.player(player.id), _pickAsset(pick)];
        proposals.add(
          dumperIsA
              ? TradeProposal(
                  teamAId: a.id,
                  teamBId: b.id,
                  assetsFromA: outgoing,
                  assetsFromB: const [],
                )
              : TradeProposal(
                  teamAId: a.id,
                  teamBId: b.id,
                  assetsFromA: const [],
                  assetsFromB: outgoing,
                ),
        );
      }
    }

    addFor(a, b, dumperIsA: true);
    addFor(b, a, dumperIsA: false);
    return proposals;
  }

  DraftPick? _dumpSweetener(
    Team team, {
    required double drag,
    required TeamStatus status,
    required int currentYear,
  }) {
    final picks = [...team.ownedPicks];
    if (drag >= balance.ai.contractDragToxic &&
        (status == TeamStatus.elite || status == TeamStatus.contender)) {
      final protectedR1 = picks.where(
        (pick) => pick.round == 1 && pick.year >= currentYear + 4,
      );
      if (protectedR1.isNotEmpty) return protectedR1.first;
    }
    final desiredRound = drag >= balance.ai.contractDragToxic
        ? 2
        : drag >= balance.ai.contractDragAnchor
        ? 3
        : 3;
    final matching = picks.where((pick) => pick.round == desiredRound).toList();
    if (matching.isNotEmpty) return matching.first;
    return picks
        .where((pick) => pick.round == 2 || pick.round == 3)
        .firstOrNull;
  }

  bool _isContractDumpProposal(LeagueState league, TradeProposal proposal) {
    final a = league.teamById(proposal.teamAId);
    final b = league.teamById(proposal.teamBId);
    if (a == null || b == null) return false;

    bool hasDrag(Team source, List<TradeAsset> assets) =>
        assets.where((asset) => asset.isPlayer).any((asset) {
          final player = source.roster
              .where((candidate) => candidate.id == asset.playerId)
              .firstOrNull;
          return player != null && evaluator.contractDrag(player) >= 10;
        });

    return hasDrag(a, proposal.assetsFromA) || hasDrag(b, proposal.assetsFromB);
  }

  bool _buyerAcceptsContract(
    LeagueState league,
    TradeProposal proposal, {
    required int saveSeed,
    required int packageSalt,
  }) {
    final a = league.teamById(proposal.teamAId);
    final b = league.teamById(proposal.teamBId);
    if (a == null || b == null) return false;
    final dumpFromA = proposal.assetsFromA.any((asset) => asset.isPlayer);
    final buyer = dumpFromA ? b : a;
    final source = dumpFromA ? a : b;
    final incoming = dumpFromA ? proposal.assetsFromA : proposal.assetsFromB;
    final incomingPlayer = incoming
        .where((asset) => asset.isPlayer)
        .map(
          (asset) => source.roster
              .where((player) => player.id == asset.playerId)
              .firstOrNull,
        )
        .whereType<Player>()
        .firstOrNull;
    if (incomingPlayer == null) return false;
    final drag = evaluator.contractDrag(incomingPlayer);
    if (drag < 10) return false;
    final capSpace = SalaryCapService(
      balance: balance,
    ).snapshot(buyer).capSpace;
    final sweetenerRound = incoming
        .where((asset) => asset.isPick)
        .map((asset) => asset.pickRound!)
        .firstOrNull;
    final buyerStatus = evaluator
        .contextForTeam(
          team: buyer,
          league: league,
          seasonYear: league.currentSeason.year,
          week: league.currentWeek,
        )
        .teamStatus;
    double probability;
    if (buyerStatus == TeamStatus.rebuild &&
        capSpace > 60000000 &&
        sweetenerRound == 1) {
      probability = balance.ai.tradeRebuildR1ContractProbability;
    } else if (buyerStatus == TeamStatus.rebuild &&
        capSpace > 40000000 &&
        sweetenerRound == 2) {
      probability = balance.ai.tradeRebuildR2ContractProbability;
    } else if (buyerStatus == TeamStatus.retool &&
        capSpace > 40000000 &&
        sweetenerRound == 2) {
      probability = balance.ai.tradeRetoolR2ContractProbability;
    } else {
      probability = 0.0;
    }
    if (probability <= 0) return false;
    final roll = Random(
      negotiationSeed(
        saveSeed,
        league.currentSeason.year,
        league.currentWeek,
        buyer.id,
        DecisionType.tradeEval,
        '${source.id}:${_proposalKey(proposal)}',
        'contract-dump-buyer',
        salt: packageSalt,
      ),
    ).nextDouble();
    return roll < probability;
  }

  double _thresholdShift({
    required LeagueState league,
    required Team self,
    required Team partner,
    required List<TradeAsset> incoming,
    required List<TradeAsset> outgoing,
    required AiEvaluationContext context,
  }) {
    var shift = 0.0;
    final incomingPlayers = _playersFromAssets(league, partner, incoming);
    final outgoingPlayers = _playersFromAssets(league, self, outgoing);
    if (incomingPlayers.any(
      (player) =>
          (evaluator.needForPosition(context, player.position)?.needScore ??
              0) >=
          balance.ai.minGapThreshold,
    )) {
      shift += balance.ai.tradeNeedShift;
      if (_deadlineProximity(league.currentWeek) > 0) {
        shift += balance.ai.tradeDeadlineNeedShift;
      }
    }
    if (outgoingPlayers.any((player) {
      final need = evaluator.needForPosition(context, player.position);
      if (need == null) return false;
      final remaining = self.roster
          .where(
            (candidate) =>
                candidate.position == player.position &&
                candidate.contract.salary > 0 &&
                candidate.contract.yearsRemaining > 0,
          )
          .length;
      return remaining <= need.definition.min;
    })) {
      shift += balance.ai.tradeLastAtPositionShift;
    }
    final selfContext = evaluator.contextForTeam(
      team: self,
      league: league,
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
    );
    final partnerContext = evaluator.contextForTeam(
      team: partner,
      league: league,
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
    );
    final selfStatus = selfContext.teamStatus;
    final partnerStatus = partnerContext.teamStatus;
    if (self.conference == partner.conference &&
        _isContenderOrBetter(selfStatus) &&
        _isContenderOrBetter(partnerStatus)) {
      shift += balance.ai.tradeSameConferenceContenderShift;
    }
    if (outgoingPlayers.any(
      (player) =>
          self.eventState.transferSituationFor(player.id)?.weeksRemaining !=
          null,
    )) {
      shift += balance.ai.tradeTransferRequestShift;
    }
    return shift;
  }

  bool _violatesAiGuardrails(LeagueState league, TradeProposal proposal) {
    final a = league.teamById(proposal.teamAId);
    final b = league.teamById(proposal.teamBId);
    if (a == null || b == null) return true;
    if (_violatesFirstRoundLimit(league, a, proposal.assetsFromA)) return true;
    if (_violatesFirstRoundLimit(league, b, proposal.assetsFromB)) return true;
    final aContext = evaluator.contextForTeam(team: a, league: league);
    final bContext = evaluator.contextForTeam(team: b, league: league);
    if (_forbidsVeteranForFirstRound(
      aContext,
      proposal.assetsFromA,
      proposal.assetsFromB,
      b,
    ))
      return true;
    if (_forbidsVeteranForFirstRound(
      bContext,
      proposal.assetsFromB,
      proposal.assetsFromA,
      a,
    ))
      return true;
    return false;
  }

  bool _violatesFirstRoundLimit(
    LeagueState league,
    Team team,
    List<TradeAsset> outgoing,
  ) {
    final outgoingR1 = outgoing.where(
      (asset) => asset.isPick && asset.pickRound == 1,
    );
    if (outgoingR1.isEmpty) return false;
    final start = league.currentSeason.year;
    final end = start + balance.ai.tradeFirstRoundWindowYears - 1;
    var sent = 0;
    for (final entry in league.tradeHistory) {
      if (entry.outcome != 'accepted' ||
          entry.seasonYear < start ||
          entry.seasonYear > end)
        continue;
      final assets = entry.teamAId == team.id
          ? entry.assetsFromA
          : entry.teamBId == team.id
          ? entry.assetsFromB
          : const <TradeAssetSnapshot>[];
      sent += assets
          .where((asset) => asset.type == 'pick' && asset.pickRound == 1)
          .length;
    }
    return sent + outgoingR1.length > balance.ai.tradeFirstRoundLimit;
  }

  bool _forbidsVeteranForFirstRound(
    AiEvaluationContext context,
    List<TradeAsset> outgoing,
    List<TradeAsset> incoming,
    Team incomingSource,
  ) {
    if (context.teamStatus != TeamStatus.rebuild &&
        context.teamStatus != TeamStatus.retool)
      return false;
    final getsVeteran = _playersFromAssets(
      null,
      incomingSource,
      incoming,
    ).any((player) => player.age >= 30);
    final givesR1 = outgoing.any(
      (asset) => asset.isPick && asset.pickRound == 1,
    );
    return getsVeteran && givesR1;
  }

  bool _violatesDumpFirstRoundLimit({
    required LeagueState league,
    required Team team,
    required List<TradeAsset> outgoing,
  }) {
    final hasDrag = outgoing.any((asset) {
      if (!asset.isPlayer) return false;
      final player = team.roster
          .where((p) => p.id == asset.playerId)
          .firstOrNull;
      return player != null && evaluator.contractDrag(player) >= 10;
    });
    if (!hasDrag) return false;
    final nearR1 = outgoing.where(
      (asset) =>
          asset.isPick &&
          asset.pickRound == 1 &&
          asset.pickYear != null &&
          asset.pickYear! <
              league.currentSeason.year + balance.ai.tradeFirstRoundWindowYears,
    );
    return nearR1.isNotEmpty;
  }

  bool _isDumpFromSelf({
    required Team self,
    required List<TradeAsset> incoming,
    required List<TradeAsset> outgoing,
    required AiPackageEvaluation evaluation,
  }) {
    return evaluation.outgoing.any((asset) => asset.contractDrag >= 10) &&
        outgoing.any((asset) => asset.isPlayer);
  }

  bool _containsContractDrag(
    AiPackageEvaluation evaluation, {
    required List<TradeAsset> incoming,
    required List<TradeAsset> outgoing,
    required Team source,
    required Team partner,
  }) =>
      evaluation.incoming.any((asset) => asset.contractDrag >= 10) ||
      evaluation.outgoing.any((asset) => asset.contractDrag >= 10);

  double _dumpFloor(AiPackageEvaluation evaluation) {
    final drag = evaluation.outgoing
        .map((asset) => asset.contractDrag)
        .fold<double>(0.0, max);
    if (drag >= balance.ai.contractDragToxic) {
      return balance.ai.tradeDumpToxicMaxNegative;
    }
    if (drag >= balance.ai.contractDragAnchor) {
      return balance.ai.tradeDumpAnchorMaxNegative;
    }
    return balance.ai.tradeDumpBurdenMaxNegative;
  }

  double _counterTargetForRound(int round) => switch (round) {
    1 => balance.ai.tradeCounterTargetRound1,
    2 => balance.ai.tradeCounterTargetRound2,
    3 => balance.ai.tradeCounterTargetRound3,
    _ => balance.ai.tradeOfferMinimum,
  };

  bool _passesNtcPlanning({
    required LeagueState league,
    required Team source,
    required Team destination,
    required String playerId,
  }) {
    final player = source.roster
        .where((item) => item.id == playerId)
        .firstOrNull;
    if (player == null || !player.contract.noTradeClause) return true;
    final probability = tradeService.ntcConsentProbability(
      league: league,
      source: source,
      destination: destination,
      player: player,
    );
    return probability >= balance.ai.tradeNtcPlanningMinConsent;
  }

  bool _passesNtcPlanningForProposal(
    LeagueState league,
    TradeProposal proposal,
  ) {
    final a = league.teamById(proposal.teamAId);
    final b = league.teamById(proposal.teamBId);
    if (a == null || b == null) return false;
    for (final asset in proposal.assetsFromA.where((asset) => asset.isPlayer)) {
      if (!_passesNtcPlanning(
        league: league,
        source: a,
        destination: b,
        playerId: asset.playerId!,
      ))
        return false;
    }
    for (final asset in proposal.assetsFromB.where((asset) => asset.isPlayer)) {
      if (!_passesNtcPlanning(
        league: league,
        source: b,
        destination: a,
        playerId: asset.playerId!,
      ))
        return false;
    }
    return true;
  }

  bool _canTradeThisWeek(LeagueState league, String teamId) {
    final weekly = league.tradeHistory.where(
      (entry) =>
          entry.outcome == 'accepted' &&
          entry.seasonYear == league.currentSeason.year &&
          entry.week == league.currentWeek &&
          (entry.teamAId == teamId || entry.teamBId == teamId),
    );
    final season = league.tradeHistory.where(
      (entry) =>
          entry.outcome == 'accepted' &&
          entry.seasonYear == league.currentSeason.year &&
          (entry.teamAId == teamId || entry.teamBId == teamId),
    );
    return weekly.length < balance.ai.aiTradeWeeklyTeamLimit &&
        season.length < balance.ai.aiTradeSeasonLimit;
  }

  bool _hasOfferCooldown(LeagueState league, String aiId, String playerId) {
    final now = _weekIndex(league.currentSeason.year, league.currentWeek);
    for (final offer in league.tradeOffers) {
      if (!offer.isPending ||
          !_samePair(offer.teamAId, offer.teamBId, aiId, playerId)) {
        continue;
      }
      return true;
    }
    for (final entry in league.tradeHistory.reversed) {
      if (!_samePair(entry.teamAId, entry.teamBId, aiId, playerId)) continue;
      final age = now - _weekIndex(entry.seasonYear, entry.week);
      if (age < 0) continue;
      final weeks = entry.outcome == 'hardRejected'
          ? balance.ai.tradeHardRejectCooldownWeeks
          : balance.ai.userOfferCooldownWeeks;
      if (age <= weeks) return true;
    }
    return false;
  }

  double _playerOfferProbability(int week) {
    if (week >= 20 && week <= 23) return balance.ai.pOfferToUserDeadline;
    if (week >= 44 && week <= 47) return balance.ai.pOfferToUserOffseason;
    return balance.ai.pOfferToUserRegular;
  }

  double _deadlineProximity(int week) {
    final remaining = balance.calendar.tradeDeadlineWeek - week;
    return remaining >= 0 && remaining <= 2 ? 1.0 : 0.0;
  }

  double _injuryPressure(Team team, List<AiPositionNeed> needs) {
    var pressure = 0.0;
    for (final need in needs) {
      final injured = team.roster
          .where(
            (player) =>
                need.definition.contains(player.position) &&
                player.state.injury?.isActive == true,
          )
          .length;
      pressure = max(
        pressure,
        (injured / max(1, need.definition.min)).clamp(0.0, 1.0),
      );
    }
    return pressure.clamp(0.0, 1.0).toDouble();
  }

  bool _isSuperteam(LeagueState league, Team team) {
    final powers = <double>[
      for (final item in league.teams)
        (league.strengthTable?.entryFor(item.id)?.teamPower ??
                item.teamStrength)
            .toDouble(),
    ];
    if (powers.isEmpty) return false;
    final average = powers.reduce((a, b) => a + b) / powers.length;
    final own =
        (league.strengthTable?.entryFor(team.id)?.teamPower ??
                team.teamStrength)
            .toDouble();
    return own > average + balance.ai.superteamBrakeThreshold;
  }

  bool _isContenderOrBetter(TeamStatus status) =>
      status == TeamStatus.contender || status == TeamStatus.elite;

  List<Player> _tradablePlayers(Team team) {
    final players = team.roster
        .where(
          (player) =>
              player.contract.salary > 0 && player.contract.yearsRemaining > 0,
        )
        .toList();
    players.sort((a, b) => b.overall(balance).compareTo(a.overall(balance)));
    return players;
  }

  List<DraftPick> _tradablePicks(Team team) {
    final picks = [...team.ownedPicks]
      ..sort(
        (a, b) => b
            .computeTradeValue(currentYear: 0, balance: balance)
            .compareTo(a.computeTradeValue(currentYear: 0, balance: balance)),
      );
    return picks;
  }

  List<TradeAsset> _tradableAssets(Team team) => [
    for (final player in _tradablePlayers(team)) TradeAsset.player(player.id),
    for (final pick in _tradablePicks(team)) _pickAsset(pick),
  ];

  TradeAsset _pickAsset(DraftPick pick) => TradeAsset.pick(
    pickId: pick.id,
    pickYear: pick.year,
    pickRound: pick.round,
    originalTeamId: pick.originalTeamId,
  );

  List<Player> _playersFromAssets(
    LeagueState? league,
    Team source,
    List<TradeAsset> assets,
  ) => [
    for (final asset in assets.where((asset) => asset.isPlayer))
      for (final player in source.roster.where((p) => p.id == asset.playerId))
        player,
  ];

  bool _samePair(String a, String b, String c, String d) =>
      (a == c && b == d) || (a == d && b == c);

  int _weekIndex(int year, int week) => year * 52 + week;

  String _proposalKey(TradeProposal proposal) =>
      '${proposal.teamAId}|${proposal.teamBId}|${proposal.assetsFromA.map((a) => a.identity).join(',')}|${proposal.assetsFromB.map((a) => a.identity).join(',')}';
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
