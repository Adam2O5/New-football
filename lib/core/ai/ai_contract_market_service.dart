import 'dart:math';

import 'package:new_football/core/ai/ai_evaluation_context.dart';
import 'package:new_football/core/ai/ai_evaluation_models.dart';
import 'package:new_football/core/ai/ai_evaluation_service.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/random/seeds.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/core/services/staff_service.dart';

/// A legal, deterministic player offer selected by the contract-market policy.
class AiPlayerOfferPlan {
  const AiPlayerOfferPlan({
    required this.player,
    required this.offer,
    required this.offerScore,
    required this.targetScore,
    this.exception,
    this.emergency = false,
  });

  final Player player;
  final ContractOffer offer;
  final double offerScore;
  final int targetScore;
  final CapExceptionType? exception;
  final bool emergency;
}

/// A legal, deterministic staff offer selected by the contract-market policy.
class AiStaffOfferPlan {
  const AiStaffOfferPlan({
    required this.member,
    required this.offer,
    required this.offerScore,
    required this.targetScore,
    required this.role,
    this.isExtension = false,
  });

  final StaffMember member;
  final StaffOffer offer;
  final double offerScore;
  final int targetScore;
  final StaffRole role;
  final bool isExtension;
}

/// AI policy for extensions, free agency, RFA decisions and staff.
///
/// This class is deliberately stateless. It selects terms and decisions from
/// public league state; [ContractMarketService] remains the only owner of
/// persisted negotiations, signing and salary-cap mutations.
class AiContractMarketService {
  AiContractMarketService({
    this.balance = BalanceConfig.defaults,
    AiEvaluationService? evaluator,
    ContractService? contracts,
    StaffService? staff,
    SalaryCapService? capService,
  }) : evaluator = evaluator ?? AiEvaluationService(balance: balance),
       contracts = contracts ?? ContractService(balance: balance),
       staff = staff ?? StaffService(balance: balance),
       capService = capService ?? SalaryCapService(balance: balance);

  final BalanceConfig balance;
  final AiEvaluationService evaluator;
  final ContractService contracts;
  final StaffService staff;
  final SalaryCapService capService;

  AiEvaluationContext _context(
    LeagueState league,
    Team team, {
    int saveSeed = 0,
    DecisionType decisionType = DecisionType.extension,
  }) => evaluator.contextForTeam(
    team: team,
    league: league,
    saveSeed: saveSeed,
    seasonYear: league.currentSeason.year,
    week: league.currentWeek,
    decisionType: decisionType,
  );

  double playerAssetValue(
    LeagueState league,
    Team team,
    Player player, {
    int saveSeed = 0,
  }) => evaluator
      .evaluatePlayer(
        player,
        _context(league, team, saveSeed: saveSeed),
        sourceTeam: team,
      )
      .assetValue;

  double wishlistPriority(
    LeagueState league,
    Team team,
    Player player, {
    int saveSeed = 0,
  }) {
    final context = _context(
      league,
      team,
      saveSeed: saveSeed,
      decisionType: DecisionType.faOffer,
    );
    final need = evaluator.needForPosition(context, player.position);
    final needScore = need?.needScore ?? 0.0;
    final assetValue = evaluator.evaluatePlayer(player, context).assetValue;
    return needScore * 0.5 + assetValue * 0.5;
  }

  /// Builds the best extension candidate for [team] according to the five
  /// documented exception priorities.
  AiPlayerOfferPlan? extensionPlan({
    required LeagueState league,
    required Team team,
    required Player player,
    required int saveSeed,
  }) {
    if (player.contract.yearsRemaining > 1) return null;
    final minutes = contracts.assessExtensionMinutes(
      team: team,
      player: player,
    );
    if (!minutes.meetsRequirement) return null;
    final value = playerAssetValue(league, team, player, saveSeed: saveSeed);
    if (value < 0) return null;

    final context = _context(league, team, saveSeed: saveSeed);
    final need = evaluator.needForPosition(context, player.position);
    final top11 = _top11(team, player.id);
    final exception = _extensionException(
      player: player,
      assetValue: value,
      top11: top11,
      criticalNeed: need?.isCritical == true,
    );
    if (exception == null) return null;

    final years =
        (player.age >= 33
                ? 1
                : contracts
                      .expectedLength(
                        player,
                        currentTeamStatus: context.teamStatus,
                      )
                      .clamp(1, 5))
            .toInt();
    final offer = _buildPlayerOffer(
      team: team,
      player: player,
      exception: exception,
      years: years,
      targetScore: balance.ai.extTargetOfferScore,
      maxScore: balance.ai.extMaxOfferScore.toDouble(),
      currentTeamStatus: context.teamStatus,
      offeringTeamStatus: context.teamStatus,
    );
    if (offer == null) return null;
    return AiPlayerOfferPlan(
      player: player,
      offer: offer.offer,
      offerScore: offer.score,
      targetScore: balance.ai.extTargetOfferScore,
      exception: exception,
    );
  }

  CapExceptionType? _extensionException({
    required Player player,
    required double assetValue,
    required bool top11,
    required bool criticalNeed,
  }) {
    if (player.contract.isRookieScale &&
        player.contract.yearsRemaining <= 1 &&
        player.potentialStars >= 3.5) {
      return CapExceptionType.rookieExtension;
    }
    if (player.state.seasonsWithTeam >= 3 && top11) {
      return CapExceptionType.fullBirdRights;
    }
    if (player.state.seasonsWithTeam == 2 && assetValue > 150) {
      return CapExceptionType.earlyBirdRights;
    }
    if (!player.contract.isRookieScale && assetValue > 0 && player.age <= 32) {
      return CapExceptionType.veteranExtensionRaiseCap;
    }
    if (criticalNeed && player.state.seasonsWithTeam < 2) {
      return CapExceptionType.nonBirdRights;
    }
    return null;
  }

  /// Returns whether an AI club raises a player counter in an extension.
  bool shouldRaiseExtensionCounter({
    required LeagueState league,
    required Team team,
    required Player player,
    required int saveSeed,
    required int round,
  }) {
    final value = playerAssetValue(league, team, player, saveSeed: saveSeed);
    if (value < 0) return false;
    final probability = value > 200
        ? balance.ai.extensionCounterRaiseHighProbability
        : balance.ai.extensionCounterRaiseNormalProbability;
    final roll = Random(
      negotiationSeed(
        saveSeed,
        league.currentSeason.year,
        league.currentWeek,
        team.id,
        DecisionType.extension,
        player.id,
        'extension-counter',
        round: round,
      ),
    ).nextDouble();
    return roll < probability;
  }

  /// Builds the AI's raised terms after a player counters an extension offer.
  ContractOffer? extensionCounterOffer({
    required LeagueState league,
    required Team team,
    required Player player,
    required ContractOffer original,
    required ContractOffer playerCounter,
    required int saveSeed,
  }) {
    final context = _context(league, team, saveSeed: saveSeed);
    final years =
        (player.age >= 33 ? 1 : min(original.years, playerCounter.years))
            .clamp(1, 5)
            .toInt();
    final salary = max(
      original.salary,
      ((original.salary + playerCounter.salary) / 2).round(),
    );
    final candidate = ContractOffer(
      salary: salary,
      years: years,
      exception: original.effectiveException,
      rookiePickSlot: original.rookiePickSlot,
    );
    final legal = contracts.validateOffer(
      team: team,
      player: player,
      offer: candidate,
    );
    if (!legal.ok) return null;
    final score = contracts.playerOfferScore(
      player,
      candidate,
      offeringTeamStatus: context.teamStatus,
      currentTeamStatus: context.teamStatus,
      cfo: team.staff.cfo,
    );
    if (score > balance.ai.extMaxOfferScore) return null;
    return candidate;
  }

  /// Selects one FA-I player offer for an AI club/hour.
  AiPlayerOfferPlan? phaseOnePlayerPlan({
    required LeagueState league,
    required Team team,
    required int hour,
    required int saveSeed,
  }) {
    if (team.roster.length >= balance.roster.maxSize ||
        league.freeAgents.isEmpty) {
      return null;
    }
    final probability =
        balance.ai.faPhaseOneOfferProbabilities[(hour - 1).clamp(
          0,
          balance.ai.faPhaseOneOfferProbabilities.length - 1,
        )];
    final probabilityRoll = Random(
      negotiationSeed(
        saveSeed,
        league.currentSeason.year,
        league.currentWeek,
        team.id,
        DecisionType.faOffer,
        'phase-one',
        'probability',
        round: hour,
      ),
    ).nextDouble();
    final rosterUnder20 = team.roster.length < balance.ai.faRosterRepairSize;
    final effectiveProbability = hour >= 10
        ? (rosterUnder20
              ? balance.ai.faPhaseOneFinalHourUnderRosterProbability
              : balance.ai.faPhaseOneFinalHourProbability)
        : probability;
    if (probabilityRoll >= effectiveProbability) return null;

    final candidates = [...league.freeAgents]
      ..sort((a, b) {
        final priority = wishlistPriority(
          league,
          team,
          b,
          saveSeed: saveSeed,
        ).compareTo(wishlistPriority(league, team, a, saveSeed: saveSeed));
        return priority != 0 ? priority : a.id.compareTo(b.id);
      });
    final context = _context(
      league,
      team,
      saveSeed: saveSeed,
      decisionType: DecisionType.faOffer,
    );
    for (final player in candidates) {
      if (_hasActiveQualifyingOffer(league, player.id)) continue;
      final need = evaluator.needForPosition(context, player.position);
      final overMax = (need?.count ?? 0) >= (need?.definition.max ?? 0);
      if (overMax &&
          !_roll(
            saveSeed,
            league,
            team.id,
            player.id,
            'fa-position-max',
            salt: hour,
            probability: balance.ai.faPositionMaxProbability,
          )) {
        continue;
      }
      final competing = _hasPlayerCompetition(league, player.id);
      var target =
          balance.ai.faPhaseOneTargetScores[(hour - 1).clamp(
            0,
            balance.ai.faPhaseOneTargetScores.length - 1,
          )];
      if (competing &&
          _roll(
            saveSeed,
            league,
            team.id,
            player.id,
            'fa-competition',
            salt: hour,
            probability: balance.ai.pFaCompete,
          )) {
        target += balance.ai.faCompeteBump;
      }
      final years = _faYears(player, phaseOne: true);
      final expected = contracts.expectedSalary(
        player,
        currentTeamStatus: context.teamStatus,
      );
      final salaryLimit = min(
        balance.salaryCap.maxSalary,
        (expected * balance.ai.faMaxSalaryMult).round(),
      );
      final offer = _buildPlayerOffer(
        team: team,
        player: player,
        years: years,
        targetScore: target,
        maxScore: balance.salaryCap.maxSalary.toDouble(),
        salaryLimit: salaryLimit,
        currentTeamStatus: TeamStatus.pretender,
        offeringTeamStatus: context.teamStatus,
      );
      if (offer == null) continue;
      return AiPlayerOfferPlan(
        player: player,
        offer: offer.offer,
        offerScore: offer.score,
        targetScore: target,
      );
    }
    return null;
  }

  /// Selects one FA-II offer, enforcing the two attempts per team/week rule.
  AiPlayerOfferPlan? phaseTwoPlayerPlan({
    required LeagueState league,
    required Team team,
    required int saveSeed,
  }) {
    if (team.roster.length >= balance.roster.maxSize ||
        league.freeAgents.isEmpty ||
        phaseTwoOfferCount(league, team.id) >=
            balance.ai.faPhaseTwoWeeklyOfferLimit) {
      return null;
    }
    final context = _context(
      league,
      team,
      saveSeed: saveSeed,
      decisionType: DecisionType.faOffer,
    );
    final needs = evaluator.rosterNeeds(context);
    final active =
        team.roster.length < balance.ai.faPhaseTwoNeedRosterThreshold ||
        needs.any(
          (need) => need.needScore >= balance.ai.faPhaseTwoNeedThreshold,
        );
    if (!active) return null;
    final candidates = [...league.freeAgents]
      ..sort((a, b) {
        final priority = wishlistPriority(
          league,
          team,
          b,
          saveSeed: saveSeed,
        ).compareTo(wishlistPriority(league, team, a, saveSeed: saveSeed));
        return priority != 0 ? priority : a.id.compareTo(b.id);
      });
    for (final player in candidates) {
      if (_hasActiveQualifyingOffer(league, player.id)) continue;
      final years = team.roster.length < balance.ai.faRosterRepairSize
          ? 1
          : _faYears(player, phaseOne: false);
      final target = balance.ai.faPhaseTwoTargetScore;
      final offer = team.roster.length < balance.ai.faRosterRepairSize
          ? ContractOffer(salary: balance.salaryCap.minSalary, years: years)
          : _buildPlayerOffer(
              team: team,
              player: player,
              years: years,
              targetScore: target,
              maxScore: balance.salaryCap.maxSalary.toDouble(),
              salaryLimit: min(
                balance.salaryCap.maxSalary,
                (contracts.expectedSalary(
                          player,
                          currentTeamStatus: context.teamStatus,
                        ) *
                        balance.ai.faMaxSalaryMult)
                    .round(),
              ),
              currentTeamStatus: TeamStatus.pretender,
              offeringTeamStatus: context.teamStatus,
            )?.offer;
      if (offer == null) continue;
      final legal = contracts.validateOffer(
        team: team,
        player: player,
        offer: offer,
      );
      if (!legal.ok) continue;
      return AiPlayerOfferPlan(
        player: player,
        offer: offer,
        offerScore: contracts.playerOfferScore(
          player,
          offer,
          offeringTeamStatus: context.teamStatus,
          currentTeamStatus: TeamStatus.pretender,
          cfo: team.staff.cfo,
        ),
        targetScore: target,
        emergency: team.roster.length < balance.ai.faRosterRepairSize,
      );
    }
    return null;
  }

  int phaseTwoOfferCount(LeagueState league, String teamId) => league
      .negotiations
      .where(
        (item) =>
            item.isAiOffer &&
            item.subjectKind == NegotiationSubjectKind.player &&
            item.teamId == teamId &&
            item.phase == NegotiationPhase.freeAgencyPhaseII &&
            item.seasonYear == league.currentSeason.year &&
            item.week == league.currentWeek,
      )
      .length;

  /// Selects a staff free-agent offer using the status-specific role order.
  AiStaffOfferPlan? staffFreeAgentPlan({
    required LeagueState league,
    required Team team,
    required int saveSeed,
  }) {
    final context = _context(
      league,
      team,
      saveSeed: saveSeed,
      decisionType: DecisionType.faOffer,
    );
    final order = staffRolePriority(context.teamStatus);
    for (var index = 0; index < order.length; index++) {
      final role = order[index];
      if (team.staff.canonicalMember(role) != null) continue;
      final candidates = _staffCandidatesForRole(
        league.canonicalStaffFreeAgents,
        role,
      );
      for (final member in candidates) {
        final offer = _buildStaffOffer(
          team: team,
          member: member,
          roleIndex: index,
          currentTeamStatus: context.teamStatus,
          replacingSalary: 0,
        );
        if (offer == null) continue;
        return AiStaffOfferPlan(
          member: member,
          offer: offer.offer,
          offerScore: offer.score,
          targetScore: balance.ai.staffTargetOfferScore,
          role: role,
        );
      }
    }
    return null;
  }

  /// Selects one expiring staff member for an AI renewal.
  AiStaffOfferPlan? staffExtensionPlan({
    required LeagueState league,
    required Team team,
    required int saveSeed,
  }) {
    final context = _context(
      league,
      team,
      saveSeed: saveSeed,
      decisionType: DecisionType.extension,
    );
    final order = staffRolePriority(context.teamStatus);
    for (final role in order) {
      final member = team.staff.canonicalMember(role);
      if (member == null || !_isCanonicalStaffMember(member, role)) {
        continue;
      }
      final contract = member.contract;
      if (contract == null || contract.yearsRemaining > 1) {
        continue;
      }
      final rawOverall = _staffRawOverall(member);
      final probability =
          rawOverall >= balance.ai.staffRenewalQualityHigh &&
              member.age <= balance.ai.staffRenewalMaxAge
          ? balance.ai.staffRenewalHighProbability
          : rawOverall < balance.ai.staffRenewalQualityLow
          ? balance.ai.staffRenewalLowProbability
          : 0.50;
      if (!_roll(
        saveSeed,
        league,
        team.id,
        member.id,
        'staff-renewal',
        probability: probability,
      )) {
        continue;
      }
      final offer = _buildStaffOffer(
        team: team,
        member: member,
        roleIndex: order.indexOf(role),
        currentTeamStatus: context.teamStatus,
        replacingSalary: contract.salary,
      );
      if (offer == null) continue;
      return AiStaffOfferPlan(
        member: member,
        offer: offer.offer,
        offerScore: offer.score,
        targetScore: balance.ai.staffTargetOfferScore,
        role: role,
        isExtension: true,
      );
    }
    return null;
  }

  List<StaffRole> staffRolePriority(TeamStatus status) => switch (status) {
    TeamStatus.rebuild => const [
      StaffRole.youthCoach,
      StaffRole.scout,
      StaffRole.headCoach,
      StaffRole.doctor,
      StaffRole.physio,
      StaffRole.cfo,
    ],
    TeamStatus.retool => const [
      StaffRole.youthCoach,
      StaffRole.headCoach,
      StaffRole.scout,
      StaffRole.doctor,
      StaffRole.physio,
      StaffRole.cfo,
    ],
    TeamStatus.pretender => const [
      StaffRole.headCoach,
      StaffRole.doctor,
      StaffRole.youthCoach,
      StaffRole.physio,
      StaffRole.scout,
      StaffRole.cfo,
    ],
    TeamStatus.contender || TeamStatus.elite => const [
      StaffRole.headCoach,
      StaffRole.doctor,
      StaffRole.physio,
      StaffRole.cfo,
      StaffRole.youthCoach,
      StaffRole.scout,
    ],
  };

  bool shouldSubmitQualifyingOffer({
    required LeagueState league,
    required Team team,
    required Player player,
    required int saveSeed,
  }) {
    if (!player.contract.isRookieScale ||
        player.contract.yearsRemaining > 0 ||
        _hasActiveQualifyingOffer(league, player.id)) {
      return false;
    }
    final context = _context(league, team, saveSeed: saveSeed);
    final need = evaluator.needForPosition(context, player.position);
    final minGap = need != null && need.count < need.definition.min;
    final probability = player.pointValue >= 120 || minGap
        ? balance.ai.rfaQualifyingHighProbability
        : balance.ai.rfaQualifyingDefaultProbability;
    return _roll(
      saveSeed,
      league,
      team.id,
      player.id,
      'rfa-qualifying-offer',
      probability: probability,
    );
  }

  bool shouldMatchOfferSheet({
    required LeagueState league,
    required RfaOfferSheet sheet,
    required int saveSeed,
  }) {
    final team = league.teamById(sheet.originalTeamId);
    final player = _findPlayer(league, sheet.playerId);
    if (team == null || player == null || team.ai == null) return false;
    final context = _context(
      league,
      team,
      saveSeed: saveSeed,
      decisionType: DecisionType.faOffer,
    );
    final value = evaluator
        .evaluatePlayer(player, context, sourceTeam: team)
        .assetValue;
    final normalizedCost =
        (sheet.salary / 1000000.0) *
        max(1, sheet.years) *
        balance.ai.rfaCostScale;
    if (value <= 0 ||
        normalizedCost > balance.ai.rfaMatchCostMultiplier * value) {
      return false;
    }
    final need = evaluator.needForPosition(context, player.position);
    final surplus =
        need?.band == AiNeedBand.surplus ||
        (need != null && need.count >= need.definition.max);
    final rank = _rosterRank(team, player.id);
    final probability = surplus
        ? balance.ai.rfaMatchSurplusProbability
        : rank <= 11
        ? balance.ai.pMatchOfferSheetTop11
        : rank <= 18
        ? balance.ai.rfaMatchDepthProbability
        : balance.ai.rfaMatchSurplusProbability;
    return _roll(
      saveSeed,
      league,
      team.id,
      '${player.id}:${sheet.id}',
      'rfa-match',
      probability: probability,
    );
  }

  _ScoredPlayerOffer? _buildPlayerOffer({
    required Team team,
    required Player player,
    required int years,
    required int targetScore,
    required double maxScore,
    required TeamStatus currentTeamStatus,
    required TeamStatus offeringTeamStatus,
    CapExceptionType? exception,
    int? salaryLimit,
  }) {
    final minimum = balance.salaryCap.minSalary;
    final maximum = (salaryLimit ?? balance.salaryCap.maxSalary).clamp(
      minimum,
      balance.salaryCap.maxSalary,
    );
    _ScoredPlayerOffer? best;
    for (var index = 0; index <= 80; index++) {
      final salary = minimum + (((maximum - minimum) * index) / 80.0).round();
      final offer = ContractOffer(
        salary: salary,
        years: years,
        exception: exception,
      );
      final legal = contracts.validateOffer(
        team: team,
        player: player,
        offer: offer,
      );
      if (!legal.ok) continue;
      final score = contracts.playerOfferScore(
        player,
        offer,
        offeringTeamStatus: offeringTeamStatus,
        currentTeamStatus: currentTeamStatus,
        cfo: team.staff.cfo,
      );
      if (score > maxScore) continue;
      final candidate = _ScoredPlayerOffer(offer: offer, score: score);
      if (best == null ||
          (score - targetScore).abs() < (best.score - targetScore).abs()) {
        best = candidate;
      }
    }
    return best;
  }

  bool _isCanonicalStaffMember(StaffMember member, StaffRole role) {
    final keys = StaffRatingSystem.roleRelevantAttributes[member.role];
    return member.role == role && keys != null && keys.isNotEmpty;
  }

  double _staffRawOverall(StaffMember member) {
    final raw = StaffRatingSystem.rawOverall(member.attributes, member.role);
    if (raw.isNaN || raw == double.negativeInfinity) {
      return StaffRatingSystem.minRating;
    }
    if (raw == double.infinity) return StaffRatingSystem.maxRating;
    return raw
        .clamp(StaffRatingSystem.minRating, StaffRatingSystem.maxRating)
        .toDouble();
  }

  /// Returns only canonical records for [role], ordered by unrounded quality.
  ///
  /// AI deliberately keeps this helper in the domain layer instead of using
  /// the presentation sorter: DisplayedRating must never influence a market
  /// decision, and the role mapping must come from StaffRatingSystem.
  List<StaffMember> _staffCandidatesForRole(
    Iterable<StaffMember> candidates,
    StaffRole role,
  ) {
    if (StaffRatingSystem.roleRelevantAttributes[role]?.isNotEmpty != true) {
      return const <StaffMember>[];
    }

    final sortable = <_IndexedStaffCandidate>[];
    final canonical = candidates.canonicalStaffMembers(role: role);
    for (var sourceIndex = 0; sourceIndex < canonical.length; sourceIndex++) {
      sortable.add(_IndexedStaffCandidate(canonical[sourceIndex], sourceIndex));
    }
    sortable.sort((a, b) {
      final rawOrder = _staffRawOverall(
        b.member,
      ).compareTo(_staffRawOverall(a.member));
      if (rawOrder != 0) return rawOrder;

      final idOrder = a.member.id.compareTo(b.member.id);
      if (idOrder != 0) return idOrder;
      return a.sourceIndex.compareTo(b.sourceIndex);
    });
    return sortable.map((entry) => entry.member).toList(growable: false);
  }

  _ScoredStaffOffer? _buildStaffOffer({
    required Team team,
    required StaffMember member,
    required int roleIndex,
    required TeamStatus currentTeamStatus,
    required int replacingSalary,
  }) {
    final lower = roleIndex == 0
        ? balance.staff.minSalary
        : roleIndex <= 2
        ? balance.ai.staffPriorityRoleMinSalary
        : balance.ai.staffOtherRoleMinSalary;
    final upper = roleIndex == 0
        ? min(balance.staff.maxSalary, balance.ai.staffHeadCoachMaxSalary)
        : roleIndex <= 2
        ? min(balance.staff.maxSalary, balance.ai.staffPriorityRoleMaxSalary)
        : min(balance.staff.maxSalary, balance.ai.staffOtherRoleMaxSalary);
    final expectedSalary = staff.expectedSalary(
      member,
      currentTeamStatus: currentTeamStatus,
    );
    final expectedLength = staff.expectedLength(
      member,
      currentTeamStatus: currentTeamStatus,
    );
    final years = member.age >= balance.ai.staffAge60MaxAge
        ? balance.ai.staffAge60MaxYears
        : expectedLength.clamp(1, 4).toInt();
    _ScoredStaffOffer? best;
    for (var index = 0; index <= 60; index++) {
      final salary = lower + (((upper - lower) * index) / 60.0).round();
      if (staff.hireValidationReason(
            team,
            salary,
            replacingSalary: replacingSalary,
          ) !=
          null) {
        continue;
      }
      final offer = StaffOffer(salary: salary, years: years);
      final score = staff.staffOfferScore(
        member,
        offer,
        offeringTeamStatus: currentTeamStatus,
        currentTeamStatus: currentTeamStatus,
        // A CFO subject is not an assisting CFO for its own negotiation.
        cfo: member.role == StaffRole.cfo ? null : team.staff.cfo,
      );
      if (score > balance.ai.staffMaxOfferScore) continue;
      final candidate = _ScoredStaffOffer(offer: offer, score: score);
      final targetDistance = (score - balance.ai.staffTargetOfferScore).abs();
      final bestTargetDistance = best == null
          ? double.infinity
          : (best.score - balance.ai.staffTargetOfferScore).abs();
      final expectedSalaryDistance = (salary - expectedSalary).abs();
      final bestExpectedSalaryDistance = best == null
          ? double.infinity
          : (best.offer.salary - expectedSalary).abs();
      if (best == null ||
          targetDistance < bestTargetDistance ||
          (targetDistance == bestTargetDistance &&
              expectedSalaryDistance < bestExpectedSalaryDistance)) {
        best = candidate;
      }
    }
    return best;
  }

  int _faYears(Player player, {required bool phaseOne}) {
    final expected = contracts.expectedLength(player).clamp(1, 5).toInt();
    final maxYears = player.age >= 33
        ? balance.ai.faAge33MaxYears
        : phaseOne
        ? expected + 1
        : expected + 1;
    return min(expected + 1, maxYears).clamp(1, 5).toInt();
  }

  bool _hasPlayerCompetition(LeagueState league, String playerId) =>
      league.negotiations.any(
        (item) =>
            item.subjectKind == NegotiationSubjectKind.player &&
            item.subjectId == playerId &&
            item.teamId == league.playerTeamId &&
            !item.isTerminal,
      );

  bool _hasActiveQualifyingOffer(LeagueState league, String playerId) => league
      .rfaQualifyingOffers
      .any((offer) => offer.playerId == playerId && !offer.declined);

  bool _top11(Team team, String playerId) => _rosterRank(team, playerId) <= 11;

  int _rosterRank(Team team, String playerId) {
    final players = [...team.roster]
      ..sort((a, b) {
        final score = b.overall(balance).compareTo(a.overall(balance));
        return score != 0 ? score : a.id.compareTo(b.id);
      });
    final index = players.indexWhere((player) => player.id == playerId);
    return index < 0 ? 999 : index + 1;
  }

  Player? _findPlayer(LeagueState league, String playerId) {
    for (final team in league.teams) {
      for (final player in team.roster) {
        if (player.id == playerId) return player;
      }
    }
    for (final player in league.freeAgents) {
      if (player.id == playerId) return player;
    }
    return null;
  }

  bool _roll(
    int saveSeed,
    LeagueState league,
    String teamId,
    String subjectId,
    String phase, {
    required double probability,
    int round = 0,
    int salt = 0,
  }) =>
      Random(
        negotiationSeed(
          saveSeed,
          league.currentSeason.year,
          league.currentWeek,
          teamId,
          phase == 'extension-counter' || phase == 'staff-renewal'
              ? DecisionType.extension
              : DecisionType.faOffer,
          subjectId,
          phase,
          round: round,
          salt: salt,
        ),
      ).nextDouble() <
      probability;
}

class _ScoredPlayerOffer {
  const _ScoredPlayerOffer({required this.offer, required this.score});

  final ContractOffer offer;
  final double score;
}

class _IndexedStaffCandidate {
  const _IndexedStaffCandidate(this.member, this.sourceIndex);

  final StaffMember member;
  final int sourceIndex;
}

class _ScoredStaffOffer {
  const _ScoredStaffOffer({required this.offer, required this.score});

  final StaffOffer offer;
  final double score;
}
