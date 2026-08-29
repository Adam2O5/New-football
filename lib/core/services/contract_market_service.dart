import 'dart:math';

import 'package:new_football/core/ai/ai_contract_market_service.dart';
import 'package:new_football/core/ai/ai_draft_service.dart';
import 'package:new_football/core/ai/ai_evaluation_models.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/core/services/negotiation_rules.dart';
import 'package:new_football/core/services/negotiation_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/core/services/staff_service.dart';
import 'package:new_football/core/random/seeds.dart';

/// The currently available contract market window.
enum ContractMarketWindow {
  closed,
  extensions,
  freeAgencyPhaseI,
  freeAgencyPhaseII,
}

class ContractMarketService {
  ContractMarketService({
    this.balance = BalanceConfig.defaults,
    CalendarService? calendar,
    ContractService? contracts,
    StaffService? staff,
    SalaryCapService? capService,
    NegotiationService? negotiations,
    MessageService? messages,
    AiContractMarketService? aiPolicy,
    AiDraftService? aiDraftService,
  }) : calendar = calendar ?? CalendarService(balance: balance),
       contracts = contracts ?? ContractService(balance: balance),
       staff = staff ?? StaffService(balance: balance),
       capService = capService ?? SalaryCapService(balance: balance),
       negotiations = negotiations ?? NegotiationService(balance: balance),
       messages = messages ?? MessageService(),
       aiPolicy =
           aiPolicy ??
           AiContractMarketService(
             balance: balance,
             contracts: contracts ?? ContractService(balance: balance),
             staff: staff ?? StaffService(balance: balance),
             capService: capService ?? SalaryCapService(balance: balance),
           ),
       aiDraftService = aiDraftService ?? AiDraftService(balance: balance);

  final BalanceConfig balance;
  final CalendarService calendar;
  final ContractService contracts;
  final StaffService staff;
  final SalaryCapService capService;
  final NegotiationService negotiations;
  final MessageService messages;
  final AiContractMarketService aiPolicy;
  final AiDraftService aiDraftService;

  ContractMarketWindow windowAt(LeagueState league) {
    final week = league.currentWeek;
    final day = league.currentDay;
    if (calendar.isContractExtensionWindow(week, day)) {
      return ContractMarketWindow.extensions;
    }
    if (calendar.isFreeAgencyPhaseI(week, day)) {
      return ContractMarketWindow.freeAgencyPhaseI;
    }
    if (calendar.isFreeAgencyPhaseII(week, day)) {
      return ContractMarketWindow.freeAgencyPhaseII;
    }
    return ContractMarketWindow.closed;
  }

  NegotiationPhase? phaseAt(LeagueState league) {
    return switch (windowAt(league)) {
      ContractMarketWindow.extensions => NegotiationPhase.contractExtension,
      ContractMarketWindow.freeAgencyPhaseI =>
        NegotiationPhase.freeAgencyPhaseI,
      ContractMarketWindow.freeAgencyPhaseII =>
        NegotiationPhase.freeAgencyPhaseII,
      ContractMarketWindow.closed => null,
    };
  }

  /// Submits one user player offer through the same persisted negotiation
  /// state used by the AI resolver. A null result means the date/subject is
  /// outside the market or the offer cannot be created.
  ({LeagueState league, ContractReaction reaction})? submitPlayerOffer({
    required LeagueState league,
    required String playerId,
    required ContractOffer offer,
    required int saveSeed,
  }) {
    final phase = phaseAt(league);
    if (phase == null) return null;
    final team = league.playerTeam;
    if (team == null) return null;

    final isExtension = phase == NegotiationPhase.contractExtension;
    final player = isExtension
        ? team.roster.cast<Player?>().firstWhere(
            (item) => item?.id == playerId,
            orElse: () => null,
          )
        : league.freeAgents.cast<Player?>().firstWhere(
            (item) => item?.id == playerId,
            orElse: () => null,
          );
    if (player == null) return null;
    if (!isExtension && team.roster.length >= balance.roster.maxSize) {
      return null;
    }
    if (isExtension) {
      final isRookieExtensionCandidate =
          player.contract.isRookieScale && player.contract.yearsRemaining <= 1;
      if (isRookieExtensionCandidate &&
          offer.effectiveException != CapExceptionType.rookieExtension) {
        return null;
      }
    }

    final hour = phase == NegotiationPhase.freeAgencyPhaseII
        ? 0
        : (league.currentHour ?? 1);
    if (hour < 1 && phase != NegotiationPhase.freeAgencyPhaseII) return null;
    if (hour > balance.contracts.hoursPerDay) return null;
    final currentStatus =
        league.strengthTable?.entryFor(team.id)?.teamStatus ??
        TeamStatus.pretender;
    final sameDayNegotiation =
        phase != NegotiationPhase.freeAgencyPhaseII &&
        league.negotiations.any(
          (item) =>
              item.subjectId == player.id &&
              item.subjectKind == NegotiationSubjectKind.player &&
              item.teamId == team.id &&
              item.seasonYear == league.currentSeason.year &&
              item.week == league.currentWeek &&
              item.day == league.currentDay &&
              !item.isTerminal,
        );
    if (sameDayNegotiation) return null;
    if (phase == NegotiationPhase.freeAgencyPhaseI &&
        league.hourlyPlayerOfferUsed) {
      return null;
    }
    if (negotiations.isBlocked(
      league: league,
      subjectId: player.id,
      subjectKind: NegotiationSubjectKind.player,
      teamId: team.id,
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      hour: hour,
    )) {
      return null;
    }

    final legal = contracts.validateOffer(
      team: team,
      player: player,
      offer: offer,
    );
    if (!legal.ok) return null;
    final competingOffers = league.negotiations.any(
      (item) =>
          item.subjectId == player.id &&
          item.subjectKind == NegotiationSubjectKind.player &&
          item.teamId != team.id &&
          item.seasonYear == league.currentSeason.year &&
          item.week == league.currentWeek &&
          item.day == league.currentDay &&
          (phase == NegotiationPhase.freeAgencyPhaseII || item.hour == hour) &&
          !item.isTerminal,
    );
    final extensionMinutesAssessment = isExtension
        ? contracts.assessExtensionMinutes(team: team, player: player)
        : null;
    final reaction = extensionMinutesAssessment?.shouldHardReject == true
        ? ContractReaction.hardReject
        : contracts.evaluate(
            player,
            offer,
            phase: phase,
            offeringTeamStatus: currentStatus,
            currentTeamStatus: isExtension
                ? currentStatus
                : TeamStatus.pretender,
            cfo: team.staff.cfo,
            competingOffers: competingOffers,
            belowExpectation:
                offer.salary <
                contracts.expectedSalary(
                  player,
                  currentTeamStatus: isExtension
                      ? currentStatus
                      : TeamStatus.pretender,
                ),
            random: Random(
              _stableSeed(
                '$saveSeed:${league.currentSeason.year}:${league.currentWeek}:${league.currentDay}:$hour:${team.id}:${player.id}:submit:${phase.name}',
              ),
            ),
          );
    final id =
        '${isExtension ? 'extension' : 'player'}:${player.id}:${team.id}:${league.currentSeason.year}:${league.currentWeek}:${league.currentDay}:$hour';
    final initial = negotiations.start(
      id: id,
      subjectId: player.id,
      subjectKind: NegotiationSubjectKind.player,
      teamId: team.id,
      phase: phase,
      offer: NegotiationOffer(
        salary: offer.salary,
        years: offer.years,
        exception: offer.effectiveException,
        rookiePickSlot: offer.rookiePickSlot,
      ),
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      hour: hour,
      offerScore: contracts.playerOfferScore(
        player,
        offer,
        offeringTeamStatus: currentStatus,
        currentTeamStatus: isExtension ? currentStatus : TeamStatus.pretender,
        cfo: team.staff.cfo,
      ),
    );
    final counter = reaction == ContractReaction.counter
        ? contracts.counterOfferForRound(
            player,
            offer,
            round: 1,
            offeringTeamStatus: currentStatus,
            currentTeamStatus: isExtension
                ? currentStatus
                : TeamStatus.pretender,
            cfo: team.staff.cfo,
          )
        : null;
    final decision = switch (reaction) {
      ContractReaction.accept => NegotiationDecision.accept,
      ContractReaction.hardReject => NegotiationDecision.hardReject,
      ContractReaction.reject => NegotiationDecision.reject,
      ContractReaction.waiting => NegotiationDecision.waiting,
      ContractReaction.counter => NegotiationDecision.counter,
    };
    final record = negotiations.applyDecision(
      negotiation: initial,
      decision: decision,
      counterOffer: counter == null
          ? null
          : NegotiationOffer(
              salary: counter.salary,
              years: counter.years,
              exception: counter.effectiveException,
              rookiePickSlot: counter.rookiePickSlot,
            ),
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      hour: hour,
    );
    var state = negotiations.upsert(league, record);
    if (reaction == ContractReaction.hardReject) {
      state = negotiations.upsert(
        state,
        record,
        block: negotiations.blockFor(
          subjectId: player.id,
          subjectKind: NegotiationSubjectKind.player,
          teamId: team.id,
          seasonYear: league.currentSeason.year,
          week: league.currentWeek,
          day: league.currentDay,
          hour: hour,
        ),
      );
    }
    if (phase == NegotiationPhase.freeAgencyPhaseI) {
      state = state.copyWith(hourlyPlayerOfferUsed: true);
    }
    state = messages.send(
      state,
      type: MessageType.contractOfferResponse,
      kind: reaction.name,
      domain: MessageDomain.contracts,
      hour: hour,
      // TODO(subjectName-migration): kind == reject needs {reason} and
      // kind == counter needs {extraTerms}; neither is tracked on
      // ContractNegotiation yet, so resolve() still throws for those two
      // kinds. See chat decision.
      args: {
        'subjectName': player.name,
        'playerName': player.name,
        'salary': record.lastOffer.salary,
        'years': record.lastOffer.years,
        'score': record.offerScore,
        'phase': phase.name,
      },
      payload: {
        'negotiationId': record.id,
        'playerId': player.id,
        'teamId': team.id,
        'counterSalary': record.counterOffer?.salary,
        'counterYears': record.counterOffer?.years,
        if (extensionMinutesAssessment != null)
          ...extensionMinutesAssessment.messagePayload,
      },
    );
    return (league: state, reaction: reaction);
  }

  /// Submits a user staff offer. Staff uses the same hourly FA-I limit and
  /// persisted response lifecycle as player negotiations.
  ({LeagueState league, StaffReaction reaction})? submitStaffOffer({
    required LeagueState league,
    required StaffMember candidate,
    required StaffOffer offer,
    required int saveSeed,
  }) {
    final phase = phaseAt(league);
    if (phase == null) return null;
    final team = league.playerTeam;
    if (team == null) return null;
    final isExtension = phase == NegotiationPhase.contractExtension;
    final resolvedCandidate = isExtension
        ? _staffMemberForTeam(team, candidate.id)
        : league.canonicalStaffFreeAgents.cast<StaffMember?>().firstWhere(
            (member) => member?.id == candidate.id,
            orElse: () => null,
          );
    if (resolvedCandidate == null) return null;
    final actualCandidate = resolvedCandidate;
    if (isExtension &&
        (actualCandidate.contract == null ||
            actualCandidate.contract!.yearsRemaining > 1)) {
      return null;
    }
    if (!isExtension &&
        team.staff.canonicalMember(actualCandidate.role) != null) {
      return null;
    }
    if (phase == NegotiationPhase.freeAgencyPhaseI &&
        league.hourlyStaffOfferUsed) {
      return null;
    }
    if (offer.years < 1 || offer.years > 4) return null;
    final replacingSalary = isExtension
        ? actualCandidate.contract?.salary ?? 0
        : 0;
    if (staff.hireValidationReason(
          team,
          offer.salary,
          replacingSalary: replacingSalary,
        ) !=
        null) {
      return null;
    }

    final hour = phase == NegotiationPhase.freeAgencyPhaseII
        ? 0
        : (league.currentHour ?? 1);
    if (hour < 1 && phase != NegotiationPhase.freeAgencyPhaseII) return null;
    if (hour > balance.contracts.hoursPerDay) return null;
    final status =
        league.strengthTable?.entryFor(team.id)?.teamStatus ??
        TeamStatus.pretender;
    final sameDayNegotiation =
        phase != NegotiationPhase.freeAgencyPhaseII &&
        league.negotiations.any(
          (item) =>
              item.subjectId == actualCandidate.id &&
              item.subjectKind == NegotiationSubjectKind.staff &&
              item.teamId == team.id &&
              item.seasonYear == league.currentSeason.year &&
              item.week == league.currentWeek &&
              item.day == league.currentDay &&
              !item.isTerminal,
        );
    if (sameDayNegotiation) return null;
    if (negotiations.isBlocked(
      league: league,
      subjectId: actualCandidate.id,
      subjectKind: NegotiationSubjectKind.staff,
      teamId: team.id,
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      hour: hour,
    )) {
      return null;
    }

    final competingOffers = league.negotiations.any(
      (item) =>
          item.subjectId == actualCandidate.id &&
          item.subjectKind == NegotiationSubjectKind.staff &&
          item.teamId != team.id &&
          item.seasonYear == league.currentSeason.year &&
          item.week == league.currentWeek &&
          item.day == league.currentDay &&
          (phase == NegotiationPhase.freeAgencyPhaseII || item.hour == hour) &&
          !item.isTerminal,
    );
    final reaction = staff.evaluateOffer(
      actualCandidate,
      offer,
      phase: phase,
      offeringTeamStatus: status,
      currentTeamStatus: status,
      cfo: actualCandidate.role == StaffRole.cfo ? null : team.staff.cfo,
      competingOffers: competingOffers,
      belowExpectation:
          offer.salary <
          staff.expectedSalary(actualCandidate, currentTeamStatus: status),
      random: Random(
        _stableSeed(
          '$saveSeed:${league.currentSeason.year}:${league.currentWeek}:${league.currentDay}:$hour:${team.id}:${actualCandidate.id}:submit:${phase.name}',
        ),
      ),
    );
    final id =
        'staff:${actualCandidate.id}:${team.id}:${league.currentSeason.year}:${league.currentWeek}:${league.currentDay}:$hour';
    final initial = negotiations.start(
      id: id,
      subjectId: actualCandidate.id,
      subjectKind: NegotiationSubjectKind.staff,
      teamId: team.id,
      phase: phase,
      offer: NegotiationOffer(salary: offer.salary, years: offer.years),
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      hour: hour,
      offerScore: staff.staffOfferScore(
        actualCandidate,
        offer,
        offeringTeamStatus: status,
        currentTeamStatus: status,
        cfo: actualCandidate.role == StaffRole.cfo ? null : team.staff.cfo,
      ),
    );
    final counter = reaction == StaffReaction.counter
        ? staff.counterOfferForRound(
            actualCandidate,
            offer,
            round: 1,
            offeringTeamStatus: status,
            currentTeamStatus: status,
            cfo: actualCandidate.role == StaffRole.cfo ? null : team.staff.cfo,
          )
        : null;
    final decision = switch (reaction) {
      StaffReaction.accept => NegotiationDecision.accept,
      StaffReaction.hardReject => NegotiationDecision.hardReject,
      StaffReaction.reject => NegotiationDecision.reject,
      StaffReaction.waiting => NegotiationDecision.waiting,
      StaffReaction.counter => NegotiationDecision.counter,
    };
    final record = negotiations.applyDecision(
      negotiation: initial,
      decision: decision,
      counterOffer: counter == null
          ? null
          : NegotiationOffer(salary: counter.salary, years: counter.years),
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      hour: hour,
    );
    var state = negotiations.upsert(league, record);
    if (reaction == StaffReaction.hardReject) {
      state = negotiations.upsert(
        state,
        record,
        block: negotiations.blockFor(
          subjectId: actualCandidate.id,
          subjectKind: NegotiationSubjectKind.staff,
          teamId: team.id,
          seasonYear: league.currentSeason.year,
          week: league.currentWeek,
          day: league.currentDay,
          hour: hour,
        ),
      );
    }
    if (phase == NegotiationPhase.freeAgencyPhaseI) {
      state = state.copyWith(hourlyStaffOfferUsed: true);
    }
    state = messages.send(
      state,
      type: MessageType.staffOfferResponse,
      kind: reaction.name,
      domain: MessageDomain.staff,
      hour: hour,
      // TODO(subjectName-migration): kind == reject needs {reason} and
      // kind == counter needs {extraTerms}; see chat decision (same gap as
      // contractOfferResponse above).
      args: {
        'subjectName': actualCandidate.name,
        'staffName': actualCandidate.name,
        'salary': record.lastOffer.salary,
        'years': record.lastOffer.years,
        'score': record.offerScore,
        'phase': phase.name,
      },
      payload: {
        'negotiationId': record.id,
        'staffId': actualCandidate.id,
        'teamId': team.id,
        'counterSalary': record.counterOffer?.salary,
        'counterYears': record.counterOffer?.years,
      },
    );
    return (league: state, reaction: reaction);
  }

  /// Finalizes a user-winning negotiation and performs the deterministic NTC
  /// roll at the actual signing boundary.
  LeagueState? finalizeNegotiation(
    LeagueState league,
    String negotiationId, {
    required int saveSeed,
  }) {
    final negotiation = league.negotiationById(negotiationId);
    if (negotiation == null ||
        negotiation.status != NegotiationStatus.pendingFinalization) {
      return null;
    }
    if (_compareDate(
          league.currentSeason.year,
          league.currentWeek,
          league.currentDay,
          league.currentHour ?? 0,
          negotiation.expirySeasonYear,
          negotiation.expiryWeek,
          negotiation.expiryDay,
          negotiation.expiryHour,
        ) >
        0) {
      return null;
    }
    final team = league.teamById(negotiation.teamId);
    if (team == null) return null;
    final ntcRandom = Random(
      _seed(
        saveSeed,
        league,
        negotiation.teamId,
        negotiation.subjectId,
        'ntc-finalize',
      ),
    );

    if (negotiation.subjectKind == NegotiationSubjectKind.player) {
      final player = _findPlayer(league, negotiation.subjectId);
      if (player == null) return null;
      final signed = contracts.signPlayer(
        team: team,
        player: player,
        offer: ContractOffer(
          salary: negotiation.lastOffer.salary,
          years: negotiation.lastOffer.years,
          exception: negotiation.lastOffer.exception,
          rookiePickSlot: negotiation.lastOffer.rookiePickSlot,
        ),
        ntcRandom: ntcRandom,
      );
      if (signed == null) return null;
      var state = league
          .updateTeam(signed)
          .copyWith(
            freeAgents: league.freeAgents
                .where((item) => item.id != player.id)
                .toList(),
          )
          .upsertNegotiation(
            negotiation.copyWith(
              status: NegotiationStatus.completed,
              requiresFinalization: false,
            ),
          );
      state = _removeFreshUndrafted(state, player.id);
      return messages.send(
        state,
        type: MessageType.contractSigned,
        domain: MessageDomain.contracts,
        args: {
          'subjectName': player.name,
          'playerName': player.name,
          'teamName': team.name,
          'salary': negotiation.lastOffer.salary,
          'years': negotiation.lastOffer.years,
        },
        payload: {
          'playerId': player.id,
          'teamId': team.id,
          'negotiationId': negotiation.id,
        },
      );
    }

    final member = _findStaffForNegotiation(league, negotiation);
    if (member == null) return null;
    final hired = staff.sign(
      team: team,
      member: member,
      offer: StaffOffer(
        salary: negotiation.lastOffer.salary,
        years: negotiation.lastOffer.years,
      ),
    );
    if (hired == null) return null;
    var state = league
        .updateTeam(hired)
        .copyWith(
          staffFreeAgents: league.canonicalStaffFreeAgents
              .where((item) => item.id != member.id)
              .toList(),
        )
        .upsertNegotiation(
          negotiation.copyWith(
            status: NegotiationStatus.completed,
            requiresFinalization: false,
          ),
        );
    return messages.send(
      state,
      type: MessageType.staffSigned,
      domain: MessageDomain.staff,
      args: {
        'subjectName': member.name,
        'staffName': member.name,
        'teamName': team.name,
        'staffRole': member.role.name,
      },
      payload: {
        'staffId': member.id,
        'teamId': team.id,
        'negotiationId': negotiation.id,
      },
    );
  }

  /// Accepting a counter offer signs immediately, as required by the market
  /// rules. A rejected counter ends this negotiation; a failed counter-counter
  /// roll creates the normal subject/club hard-reject block.
  LeagueState? resolveCounterResponse(
    LeagueState league,
    String negotiationId, {
    required bool accept,
    ContractOffer? playerOffer,
    StaffOffer? staffOffer,
    required int saveSeed,
  }) {
    final current = league.negotiationById(negotiationId);
    if (current == null || current.status != NegotiationStatus.counter) {
      return null;
    }
    final phase = phaseAt(league);
    if (phase != current.phase) return null;
    if (!accept) {
      return league.upsertNegotiation(
        current.copyWith(
          status: NegotiationStatus.rejected,
          requiresFinalization: false,
          counterOffer: null,
        ),
      );
    }

    final team = league.teamById(current.teamId);
    if (team == null) return null;
    if (current.subjectKind == NegotiationSubjectKind.player) {
      final player = _findPlayer(league, current.subjectId);
      if (player == null) return null;
      final minutesAssessment =
          current.phase == NegotiationPhase.contractExtension
          ? contracts.assessExtensionMinutes(team: team, player: player)
          : null;
      if (minutesAssessment?.shouldHardReject == true) {
        final hour = league.currentHour ?? 0;
        final updated = current.copyWith(
          status: NegotiationStatus.hardRejected,
          requiresFinalization: false,
          counterOffer: null,
        );
        final state = negotiations.upsert(
          league,
          updated,
          block: negotiations.blockFor(
            subjectId: current.subjectId,
            subjectKind: current.subjectKind,
            teamId: current.teamId,
            seasonYear: league.currentSeason.year,
            week: league.currentWeek,
            day: league.currentDay,
            hour: hour,
          ),
        );
        return messages.send(
          state,
          type: MessageType.contractOfferResponse,
          kind: 'hardReject',
          domain: MessageDomain.contracts,
          hour: hour,
          args: {
            'subjectName': player.name,
            'playerName': player.name,
            'salary': current.lastOffer.salary,
            'years': current.lastOffer.years,
            'score': current.offerScore,
            'phase': current.phase.name,
          },
          payload: {
            'negotiationId': current.id,
            'playerId': player.id,
            'teamId': team.id,
            ...minutesAssessment!.messagePayload,
          },
        );
      }
      final offer =
          playerOffer ??
          ContractOffer(
            salary: current.lastOffer.salary,
            years: current.lastOffer.years,
            exception: current.lastOffer.exception,
            rookiePickSlot: current.lastOffer.rookiePickSlot,
          );
      final validation = contracts.validateOffer(
        team: team,
        player: player,
        offer: offer,
      );
      if (!validation.ok) return null;
      final reaction = contracts.evaluateCounterResponse(
        player,
        offer,
        round: current.round,
        random: Random(
          _stableSeed(
            '$saveSeed:${league.currentSeason.year}:${league.currentWeek}:${league.currentDay}:${current.id}:counter',
          ),
        ),
      );
      final updated = current.copyWith(
        lastOffer: NegotiationOffer(
          salary: offer.salary,
          years: offer.years,
          exception: offer.effectiveException,
          rookiePickSlot: offer.rookiePickSlot,
        ),
        counterOffer: null,
        status: reaction == ContractReaction.accept
            ? NegotiationStatus.pendingFinalization
            : NegotiationStatus.hardRejected,
        requiresFinalization: reaction == ContractReaction.accept,
      );
      if (reaction == ContractReaction.accept) {
        return finalizeNegotiation(
          league.upsertNegotiation(updated),
          negotiationId,
          saveSeed: saveSeed,
        );
      }
      return league
          .upsertNegotiation(updated)
          .addNegotiationBlock(
            negotiations.blockFor(
              subjectId: current.subjectId,
              subjectKind: current.subjectKind,
              teamId: current.teamId,
              seasonYear: league.currentSeason.year,
              week: league.currentWeek,
              day: league.currentDay,
              hour: league.currentHour ?? 0,
            ),
          );
    }

    final member = _findStaffForNegotiation(league, current);
    if (member == null) return null;
    final currentMember = team.staff.canonicalMember(member.role);
    if (currentMember != null &&
        (currentMember.id != member.id || currentMember.role != member.role)) {
      return null;
    }
    final offer =
        staffOffer ??
        StaffOffer(
          salary: current.lastOffer.salary,
          years: current.lastOffer.years,
        );
    final replacingSalary = currentMember?.contract?.salary ?? 0;
    if (staff.hireValidationReason(
              team,
              offer.salary,
              replacingSalary: replacingSalary,
            ) !=
            null ||
        offer.years < 1 ||
        offer.years > 4) {
      return null;
    }
    final reaction = staff.evaluateCounterResponse(
      member,
      offer,
      round: current.round,
      random: Random(
        _stableSeed(
          '$saveSeed:${league.currentSeason.year}:${league.currentWeek}:${league.currentDay}:${current.id}:counter',
        ),
      ),
    );
    final updated = current.copyWith(
      lastOffer: NegotiationOffer(salary: offer.salary, years: offer.years),
      counterOffer: null,
      status: reaction == StaffReaction.accept
          ? NegotiationStatus.pendingFinalization
          : NegotiationStatus.hardRejected,
      requiresFinalization: reaction == StaffReaction.accept,
    );
    if (reaction == StaffReaction.accept) {
      return finalizeNegotiation(
        league.upsertNegotiation(updated),
        negotiationId,
        saveSeed: saveSeed,
      );
    }
    return league
        .upsertNegotiation(updated)
        .addNegotiationBlock(
          negotiations.blockFor(
            subjectId: current.subjectId,
            subjectKind: current.subjectKind,
            teamId: current.teamId,
            seasonYear: league.currentSeason.year,
            week: league.currentWeek,
            day: league.currentDay,
            hour: league.currentHour ?? 0,
          ),
        );
  }

  /// Resolves the current hourly slot. It is intentionally pure: callers can
  /// assign the returned state and decide when to persist it.
  LeagueState resolveHour(LeagueState league, {int? hour, int saveSeed = 0}) {
    final window = windowAt(league);
    if (window != ContractMarketWindow.freeAgencyPhaseI &&
        window != ContractMarketWindow.extensions) {
      return league;
    }
    final slot = hour ?? league.currentHour ?? 1;
    return _resolveSlot(
      league,
      phase: window == ContractMarketWindow.freeAgencyPhaseI
          ? NegotiationPhase.freeAgencyPhaseI
          : NegotiationPhase.contractExtension,
      hour: slot,
      saveSeed: saveSeed,
      includeAi: true,
    );
  }

  /// Resolves a complete calendar day. Direct day simulation uses this method;
  /// the interactive hourly controller uses [resolveHour] instead.
  LeagueState resolveDay(LeagueState league, {int saveSeed = 0}) {
    final window = windowAt(league);
    switch (window) {
      case ContractMarketWindow.freeAgencyPhaseI:
        var state = league;
        final firstHour = (league.currentHour ?? 1).clamp(
          1,
          balance.contracts.hoursPerDay,
        );
        for (
          var hour = firstHour;
          hour <= balance.contracts.hoursPerDay;
          hour++
        ) {
          state = _resolveSlot(
            state,
            phase: NegotiationPhase.freeAgencyPhaseI,
            hour: hour,
            saveSeed: saveSeed,
            includeAi: true,
          );
          if (state.freeAgents.isEmpty &&
              state.canonicalStaffFreeAgents.isEmpty) {
            break;
          }
        }
        return state.copyWith(
          currentHour: balance.contracts.hoursPerDay,
          hourlyPlayerOfferUsed: false,
          hourlyStaffOfferUsed: false,
        );
      case ContractMarketWindow.freeAgencyPhaseII:
        return _resolveSlot(
          league,
          phase: NegotiationPhase.freeAgencyPhaseII,
          hour: league.currentHour ?? 0,
          saveSeed: saveSeed,
          includeAi: true,
        );
      case ContractMarketWindow.extensions:
      case ContractMarketWindow.closed:
        return resolveHour(league, saveSeed: saveSeed);
    }
  }

  /// Runs the draft-specific AI market work once at the Sunday → Monday
  /// boundary. It deliberately lives outside [resolveDay]: the calendar
  /// transition owns the weekly cadence, while this service owns all contract
  /// legality and persisted negotiation mutations.
  LeagueState weeklyTick(LeagueState league, {int saveSeed = 0}) {
    final marketPhase = phaseAt(league);
    if (marketPhase == null ||
        (marketPhase != NegotiationPhase.freeAgencyPhaseI &&
            marketPhase != NegotiationPhase.freeAgencyPhaseII)) {
      return league;
    }
    var state = _resolveDeferredRightsWeekly(league, saveSeed: saveSeed);
    state = _addFreshUndraftedOffersWeekly(
      state,
      phase: marketPhase,
      saveSeed: saveSeed,
    );
    return state;
  }

  LeagueState _resolveDeferredRightsWeekly(
    LeagueState league, {
    required int saveSeed,
  }) {
    final rights = [...league.draftedRights]
      ..sort((a, b) {
        final owner = a.ownerTeamId.compareTo(b.ownerTeamId);
        if (owner != 0) return owner;
        final player = a.player.id.compareTo(b.player.id);
        return player != 0 ? player : a.id.compareTo(b.id);
      });
    var state = league;
    for (final right in rights) {
      if (!state.draftedRights.any((item) => item.id == right.id)) continue;
      final team = state.teamById(right.ownerTeamId);
      if (team == null || team.isPlayerControlled) continue;
      final decision = aiDraftService.deferredRightsSigningDecision(
        team: team,
        prospectId: right.player.id,
        saveSeed: saveSeed,
        seasonYear: state.currentSeason.year,
        week: state.currentWeek,
      );
      if (!decision.sign) continue;
      state = signDraftedRight(state, right.id, saveSeed: saveSeed) ?? state;
    }
    return state;
  }

  LeagueState _addFreshUndraftedOffersWeekly(
    LeagueState league, {
    required NegotiationPhase phase,
    required int saveSeed,
  }) {
    final active = [...league.freshUndraftedPlayers]
      ..removeWhere(
        (record) =>
            !record.isActiveAt(
              seasonYear: league.currentSeason.year,
              week: league.currentWeek,
            ) ||
            !league.freeAgents.any((player) => player.id == record.playerId),
      )
      ..sort((a, b) {
        final year = a.draftYear.compareTo(b.draftYear);
        return year != 0 ? year : a.playerId.compareTo(b.playerId);
      });
    var state = league.copyWith(freshUndraftedPlayers: active);

    final aiTeamIds = [
      for (final team in state.teams)
        if (!team.isPlayerControlled) team.id,
    ]..sort();
    final hour = phase == NegotiationPhase.freeAgencyPhaseII
        ? 0
        : (state.currentHour ?? 1).clamp(1, balance.contracts.hoursPerDay);

    for (final teamId in aiTeamIds) {
      final currentTeam = state.teamById(teamId);
      if (currentTeam == null ||
          currentTeam.roster.length >= balance.roster.maxSize) {
        continue;
      }

      var remaining = phase == NegotiationPhase.freeAgencyPhaseII
          ? balance.ai.faPhaseTwoWeeklyOfferLimit -
                _aiPlayerOfferCountForWeek(state, teamId: teamId, phase: phase)
          : _aiPlayerOfferCountForSlot(
                  state,
                  teamId: teamId,
                  phase: phase,
                  day: state.currentDay,
                  hour: hour,
                ) ==
                0
          ? 1
          : 0;
      if (remaining <= 0) continue;

      final context = aiDraftService.evaluator.contextForTeam(
        team: currentTeam,
        league: state,
        saveSeed: saveSeed,
        seasonYear: state.currentSeason.year,
        week: state.currentWeek,
        decisionType: DecisionType.faOffer,
      );
      for (final record in active) {
        if (remaining <= 0) break;
        final player = state.freeAgents.cast<Player?>().firstWhere(
          (candidate) => candidate?.id == record.playerId,
          orElse: () => null,
        );
        if (player == null ||
            _hasAiPlayerNegotiationThisWeek(
              state,
              teamId: teamId,
              playerId: player.id,
              phase: phase,
            )) {
          continue;
        }

        final needBand =
            aiDraftService.evaluator
                .needForPosition(context, player.position)
                ?.band ??
            AiNeedBand.target;
        final decision = aiDraftService.undraftedSigningDecision(
          team: currentTeam,
          prospectId: player.id,
          needBand: needBand,
          saveSeed: saveSeed,
          seasonYear: state.currentSeason.year,
          week: state.currentWeek,
        );
        if (!decision.offer) continue;

        final offer = ContractOffer(
          salary: balance.salaryCap.minSalary,
          years: 2,
        );
        final legal = contracts.validateOffer(
          team: currentTeam,
          player: player,
          offer: offer,
        );
        if (!legal.ok) continue;

        final negotiation = negotiations
            .start(
              id: 'ai:undrafted:${player.id}:$teamId:${state.currentSeason.year}:${state.currentWeek}:${phase.name}',
              subjectId: player.id,
              subjectKind: NegotiationSubjectKind.player,
              teamId: teamId,
              phase: phase,
              offer: NegotiationOffer(
                salary: offer.salary,
                years: offer.years,
                exception: offer.effectiveException,
                rookiePickSlot: offer.rookiePickSlot,
              ),
              seasonYear: state.currentSeason.year,
              week: state.currentWeek,
              day: state.currentDay,
              hour: hour,
              offerScore: contracts.playerOfferScore(
                player,
                offer,
                offeringTeamStatus: context.teamStatus,
                currentTeamStatus: TeamStatus.pretender,
                cfo: currentTeam.staff.cfo,
              ),
              isAiOffer: true,
            )
            .copyWith(
              status: NegotiationStatus.pendingFinalization,
              requiresFinalization: true,
            );
        state = state.upsertNegotiation(negotiation);
        remaining--;
      }
    }
    return state;
  }

  int _aiPlayerOfferCountForWeek(
    LeagueState league, {
    required String teamId,
    required NegotiationPhase phase,
  }) => league.negotiations
      .where(
        (item) =>
            item.isAiOffer &&
            item.subjectKind == NegotiationSubjectKind.player &&
            item.teamId == teamId &&
            item.phase == phase &&
            item.seasonYear == league.currentSeason.year &&
            item.week == league.currentWeek,
      )
      .length;

  int _aiPlayerOfferCountForSlot(
    LeagueState league, {
    required String teamId,
    required NegotiationPhase phase,
    required int day,
    required int hour,
  }) => league.negotiations
      .where(
        (item) =>
            item.isAiOffer &&
            item.subjectKind == NegotiationSubjectKind.player &&
            item.teamId == teamId &&
            item.phase == phase &&
            item.seasonYear == league.currentSeason.year &&
            item.week == league.currentWeek &&
            item.day == day &&
            item.hour == hour,
      )
      .length;

  bool _hasAiPlayerNegotiationThisWeek(
    LeagueState league, {
    required String teamId,
    required String playerId,
    required NegotiationPhase phase,
  }) => league.negotiations.any(
    (item) =>
        item.isAiOffer &&
        item.subjectKind == NegotiationSubjectKind.player &&
        item.teamId == teamId &&
        item.subjectId == playerId &&
        item.phase == phase &&
        item.seasonYear == league.currentSeason.year &&
        item.week == league.currentWeek,
  );

  /// Computes the documented RFA floor independently of the cap validator.
  int qualifyingOfferMinimum(Player player) => max(
    balance.salaryCap.qualifyingOfferMin,
    (player.contract.salary * balance.salaryCap.qualifyingOfferMultiplier)
        .ceil(),
  );

  /// Records a QO. No QO record means the expired rookie is an unrestricted FA.
  LeagueState? submitQualifyingOffer({
    required LeagueState league,
    required String ownerTeamId,
    required String playerId,
    int? salary,
    int years = 1,
  }) {
    final team = league.teamById(ownerTeamId);
    final player = _findPlayer(league, playerId);
    if (team == null || player == null || !player.contract.isRookieScale) {
      return null;
    }
    if (player.contract.yearsRemaining > 0) return null;
    final amount = salary ?? qualifyingOfferMinimum(player);
    final validation = contracts.validateOffer(
      team: team,
      player: player,
      offer: ContractOffer(
        salary: amount,
        years: years,
        exception: CapExceptionType.qualifyingOffer,
      ),
    );
    if (!validation.ok) return null;

    final nextOffer = RfaQualifyingOffer(
      playerId: player.id,
      ownerTeamId: ownerTeamId,
      salary: amount,
      years: years,
      seasonYear: league.currentSeason.year,
    );
    var state = league.copyWith(
      rfaQualifyingOffers: [
        ...league.rfaQualifyingOffers.where(
          (item) => item.playerId != player.id,
        ),
        nextOffer,
      ],
    );
    return messages.send(
      state,
      type: MessageType.contractOffer,
      kind: 'rfaQualifyingOffer',
      domain: MessageDomain.contracts,
      args: {
        'subjectName': player.name,
        'playerName': player.name,
        'salary': amount,
        'years': years,
        // TODO(subjectName-migration): {extensionWindowEnd} still unresolved -
        // no deadline is computed at this call site yet. See chat decision.
      },
      payload: {
        'playerId': player.id,
        'teamId': ownerTeamId,
        'salary': amount,
        'years': years,
      },
    );
  }

  LeagueState declineQualifyingOffer(LeagueState league, String playerId) {
    return league.copyWith(
      rfaQualifyingOffers: league.rfaQualifyingOffers
          .map(
            (offer) => offer.playerId == playerId
                ? offer.copyWith(declined: true)
                : offer,
          )
          .toList(),
    );
  }

  /// Submits a rival sheet only when it fits the offering club's own cap and
  /// roster. The original club receives a separate, exact-match deadline.
  LeagueState? submitOfferSheet({
    required LeagueState league,
    required String offeringTeamId,
    required String playerId,
    required ContractOffer offer,
    int saveSeed = 0,
  }) {
    final phase = phaseAt(league);
    if (phase == null || phase == NegotiationPhase.contractExtension) {
      return null;
    }
    final offeringTeam = league.teamById(offeringTeamId);
    final player = _findPlayer(league, playerId);
    final qualifying = league.rfaQualifyingOffers
        .cast<RfaQualifyingOffer?>()
        .firstWhere(
          (item) => item?.playerId == playerId && item?.declined == false,
          orElse: () => null,
        );
    if (offeringTeam == null || player == null || qualifying == null) {
      return null;
    }
    if (qualifying.ownerTeamId == offeringTeamId ||
        offeringTeam.roster.length >= balance.roster.maxSize) {
      return null;
    }
    final legal = contracts.validateOffer(
      team: offeringTeam,
      player: player,
      offer: offer,
    );
    if (!legal.ok) return null;

    final hour = phase == NegotiationPhase.freeAgencyPhaseI
        ? (league.currentHour ?? 1)
        : 0;
    final deadline = negotiations.deadlineFor(
      phase: phase,
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      hour: hour,
    );
    final sheet = RfaOfferSheet(
      id: 'rfa:${player.id}:$offeringTeamId:${league.currentSeason.year}:${league.currentWeek}:${league.currentDay}:$hour',
      playerId: player.id,
      originalTeamId: qualifying.ownerTeamId,
      offeringTeamId: offeringTeamId,
      salary: offer.salary,
      years: offer.years,
      phase: phase,
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      hour: hour,
      expirySeasonYear: deadline.seasonYear,
      expiryWeek: deadline.week,
      expiryDay: deadline.day,
      expiryHour: deadline.hour,
    );
    var state = league.copyWith(
      rfaOfferSheets: [
        ...league.rfaOfferSheets.where((item) => item.id != sheet.id),
        sheet,
      ],
    );
    return messages.send(
      state,
      type: MessageType.rfaOfferSheet,
      domain: MessageDomain.contracts,
      args: {
        'subjectName': player.name,
        'playerName': player.name,
        'rivalTeamName': offeringTeam.name,
        'salary': offer.salary,
        'years': offer.years,
      },
      payload: {
        'offerSheetId': sheet.id,
        'playerId': player.id,
        'offeringTeamId': offeringTeamId,
        'originalTeamId': qualifying.ownerTeamId,
      },
    );
  }

  LeagueState? matchOfferSheet(
    LeagueState league,
    String sheetId, {
    int saveSeed = 0,
  }) {
    final sheet = league.rfaOfferSheets.cast<RfaOfferSheet?>().firstWhere(
      (item) => item?.id == sheetId,
      orElse: () => null,
    );
    if (sheet == null ||
        sheet.isTerminal ||
        !_isBeforeOrAtDeadline(league, sheet)) {
      return null;
    }
    if (league.currentWeek != sheet.week &&
        !calendar.isActiveContractWindow(
          league.currentWeek,
          league.currentDay,
        )) {
      return null;
    }
    final team = league.teamById(sheet.originalTeamId);
    final player = _findPlayer(league, sheet.playerId);
    if (team == null || player == null) return null;
    final signed = contracts.signPlayer(
      team: team,
      player: player,
      offer: ContractOffer(
        salary: sheet.salary,
        years: sheet.years,
        exception: CapExceptionType.qualifyingOffer,
      ),
      ntcRandom: Random(
        _seed(saveSeed, league, team.id, player.id, 'rfa-match'),
      ),
    );
    if (signed == null) return null;
    var state = league
        .updateTeam(signed)
        .copyWith(
          freeAgents: league.freeAgents
              .where((item) => item.id != player.id)
              .toList(),
          rfaOfferSheets: league.rfaOfferSheets
              .map(
                (item) =>
                    item.id == sheet.id ? item.copyWith(matched: true) : item,
              )
              .toList(),
          rfaQualifyingOffers: league.rfaQualifyingOffers
              .where((item) => item.playerId != player.id)
              .toList(),
        );
    state = _removeFreshUndrafted(state, player.id);
    return messages.send(
      state,
      type: MessageType.contractSigned,
      domain: MessageDomain.contracts,
      args: {
        'subjectName': player.name,
        'playerName': player.name,
        'teamName': team.name,
        'salary': sheet.salary,
        'years': sheet.years,
      },
      payload: {
        'playerId': player.id,
        'teamId': team.id,
        'offerSheetId': sheet.id,
      },
    );
  }

  LeagueState declineOfferSheet(LeagueState league, String sheetId) {
    return league.copyWith(
      rfaOfferSheets: league.rfaOfferSheets
          .map(
            (sheet) =>
                sheet.id == sheetId ? sheet.copyWith(declined: true) : sheet,
          )
          .toList(),
    );
  }

  /// Signs one emergency free agent for an AI roster outside the normal FA
  /// window. It is intentionally a thin orchestration layer: cap legality,
  /// roster limits, payroll and NTC creation remain owned by [ContractService].
  /// A null result means no legal candidate/offer was available.
  LeagueState? signEmergencyFreeAgent(
    LeagueState league, {
    required String teamId,
    Position? preferredPosition,
    bool requireAvailable = false,
    int? years,
    int saveSeed = 0,
  }) {
    final team = league.teamById(teamId);
    if (team == null || team.roster.length >= balance.roster.maxSize) {
      return null;
    }
    final candidates = [...league.freeAgents]
      ..removeWhere(
        (player) =>
            team.roster.any((rostered) => rostered.id == player.id) ||
            (requireAvailable && !player.isAvailable),
      )
      ..sort((a, b) {
        final aPosition =
            preferredPosition != null && a.position == preferredPosition;
        final bPosition =
            preferredPosition != null && b.position == preferredPosition;
        if (aPosition != bPosition) return aPosition ? -1 : 1;
        if (a.isAvailable != b.isAvailable) return a.isAvailable ? -1 : 1;
        final byValue = b.pointValue.compareTo(a.pointValue);
        return byValue != 0 ? byValue : a.id.compareTo(b.id);
      });
    if (candidates.isEmpty) return null;

    final contractYears = (years ?? balance.ai.rosterEmergencyOfferYears)
        .clamp(1, 5)
        .toInt();
    final offers = <ContractOffer>[
      ContractOffer(salary: balance.salaryCap.minSalary, years: contractYears),
      if (team.finance.midLevelExceptionAvailable)
        ContractOffer(
          salary: balance.salaryCap.minSalary,
          years: contractYears,
          exception: CapExceptionType.midLevelException,
        ),
    ];

    for (final player in candidates) {
      for (final offer in offers) {
        final validation = contracts.validateOffer(
          team: team,
          player: player,
          offer: offer,
        );
        if (!validation.ok) continue;
        final signed = contracts.signPlayer(
          team: team,
          player: player,
          offer: offer,
          ntcRandom: Random(
            _seed(saveSeed, league, team.id, player.id, 'emergency'),
          ),
        );
        if (signed == null) continue;
        var state = league
            .updateTeam(signed)
            .copyWith(
              freeAgents: league.freeAgents
                  .where((candidate) => candidate.id != player.id)
                  .toList(),
              rfaQualifyingOffers: league.rfaQualifyingOffers
                  .where((candidate) => candidate.playerId != player.id)
                  .toList(),
              rfaOfferSheets: league.rfaOfferSheets
                  .where((candidate) => candidate.playerId != player.id)
                  .toList(),
            );
        state = _removeFreshUndrafted(state, player.id);
        return state;
      }
    }
    return null;
  }

  /// Compatibility alias used by roster-safety callers.
  LeagueState? emergencyRosterSigning(
    LeagueState league, {
    required String teamId,
    Position? preferredPosition,
    bool requireAvailable = false,
    int? years,
    int saveSeed = 0,
  }) => signEmergencyFreeAgent(
    league,
    teamId: teamId,
    preferredPosition: preferredPosition,
    requireAvailable: requireAvailable,
    years: years,
    saveSeed: saveSeed,
  );

  /// Signs a draft right without counting the right as a roster slot before
  /// this call. The operation is available whenever the destination has room.
  LeagueState? signDraftedRight(
    LeagueState league,
    String rightId, {
    int saveSeed = 0,
  }) {
    final right = league.draftedRights.cast<DraftedPlayerRights?>().firstWhere(
      (item) => item?.id == rightId,
      orElse: () => null,
    );
    if (right == null) return null;
    final team = league.teamById(right.ownerTeamId);
    if (team == null || team.roster.length >= balance.roster.maxSize) {
      return null;
    }
    final offer = ContractOffer(
      salary: right.player.contract.salary,
      years: right.player.contract.yearsRemaining,
      exception: CapExceptionType.rookieScale,
      rookiePickSlot: right.pickNumber,
    );
    final signed = contracts.signPlayer(
      team: team,
      player: right.player,
      offer: offer,
      ntcRandom: Random(
        _seed(saveSeed, league, team.id, right.player.id, 'rights'),
      ),
    );
    if (signed == null) return null;
    var state = league
        .updateTeam(signed)
        .copyWith(
          draftedRights: league.draftedRights
              .where((item) => item.id != right.id)
              .toList(),
        );
    return messages.send(
      state,
      type: MessageType.contractSigned,
      domain: MessageDomain.contracts,
      args: {
        'subjectName': right.player.name,
        'playerName': right.player.name,
        'teamName': team.name,
        'salary': offer.salary,
        'years': offer.years,
      },
      payload: {
        'playerId': right.player.id,
        'teamId': team.id,
        'rightsId': right.id,
      },
    );
  }

  /// Adds deterministic AI bids to the same slot as user bids and resolves
  /// each subject by offer score. AI winners sign now; user winners remain
  /// pending so the controller can present the finalization CTA.
  LeagueState _resolveSlot(
    LeagueState league, {
    required NegotiationPhase phase,
    required int hour,
    required int saveSeed,
    required bool includeAi,
  }) {
    var state = league;
    final resolvedWaitingIds = <String>{};
    if (includeAi) {
      state = _addAiOffers(state, phase: phase, hour: hour, saveSeed: saveSeed);
    }
    state = _resolveWaiting(
      state,
      phase: phase,
      hour: hour,
      saveSeed: saveSeed,
      resolvedWaitingIds: resolvedWaitingIds,
    );
    state = _resolveAiCounters(
      state,
      phase: phase,
      hour: hour,
      saveSeed: saveSeed,
    );
    state = _resolveSubjectOffers(
      state,
      phase: phase,
      hour: hour,
      saveSeed: saveSeed,
    );
    final expiryHour = phase == NegotiationPhase.freeAgencyPhaseII && hour == 0
        ? balance.contracts.hoursPerDay
        : hour;
    state = negotiations.expireAt(
      league: state,
      seasonYear: state.currentSeason.year,
      week: state.currentWeek,
      day: state.currentDay,
      hour: expiryHour,
      skipNegotiationIds: resolvedWaitingIds,
    );
    return _expireOfferSheets(state, hour: expiryHour);
  }

  LeagueState _addAiOffers(
    LeagueState league, {
    required NegotiationPhase phase,
    required int hour,
    required int saveSeed,
  }) {
    var state = _applyAiRfaDecisions(league, phase: phase, saveSeed: saveSeed);
    final aiTeamIds = [
      for (final team in state.teams)
        if (!team.isPlayerControlled) team.id,
    ];
    for (final teamId in aiTeamIds) {
      final team = state.teamById(teamId);
      if (team == null) continue;

      if (phase == NegotiationPhase.contractExtension) {
        final extension = _bestAiExtensionPlan(state, team, saveSeed: saveSeed);
        if (extension != null &&
            !_hasAiNegotiation(
              state,
              team.id,
              extension.player.id,
              NegotiationSubjectKind.player,
              phase,
              hour,
              onePerDay: true,
            )) {
          state = _insertAiPlayerPlan(
            state,
            team: team,
            plan: extension,
            phase: phase,
            hour: hour,
          );
        }
        final currentTeam = state.teamById(team.id) ?? team;
        final staffPlan = aiPolicy.staffExtensionPlan(
          league: state,
          team: currentTeam,
          saveSeed: saveSeed,
        );
        if (staffPlan != null &&
            !_hasAiNegotiation(
              state,
              currentTeam.id,
              staffPlan.member.id,
              NegotiationSubjectKind.staff,
              phase,
              hour,
              onePerDay: true,
            )) {
          state = _insertAiStaffPlan(
            state,
            team: currentTeam,
            plan: staffPlan,
            phase: phase,
            hour: hour,
          );
        }
        continue;
      }

      final playerPlan = phase == NegotiationPhase.freeAgencyPhaseI
          ? aiPolicy.phaseOnePlayerPlan(
              league: state,
              team: team,
              hour: hour,
              saveSeed: saveSeed,
            )
          : aiPolicy.phaseTwoPlayerPlan(
              league: state,
              team: team,
              saveSeed: saveSeed,
            );
      if (playerPlan != null &&
          !_hasAiNegotiation(
            state,
            team.id,
            playerPlan.player.id,
            NegotiationSubjectKind.player,
            phase,
            hour,
          )) {
        state = _insertAiPlayerPlan(
          state,
          team: team,
          plan: playerPlan,
          phase: phase,
          hour: hour,
        );
      }

      final currentTeam = state.teamById(team.id) ?? team;
      final staffPlan = aiPolicy.staffFreeAgentPlan(
        league: state,
        team: currentTeam,
        saveSeed: saveSeed,
      );
      if (staffPlan != null &&
          !_hasAiNegotiation(
            state,
            currentTeam.id,
            staffPlan.member.id,
            NegotiationSubjectKind.staff,
            phase,
            hour,
          )) {
        state = _insertAiStaffPlan(
          state,
          team: currentTeam,
          plan: staffPlan,
          phase: phase,
          hour: hour,
        );
      }
    }
    return state;
  }

  AiPlayerOfferPlan? _bestAiExtensionPlan(
    LeagueState league,
    Team team, {
    required int saveSeed,
  }) {
    final plans = <AiPlayerOfferPlan>[];
    for (final player in team.roster) {
      if (_hasAiNegotiation(
        league,
        team.id,
        player.id,
        NegotiationSubjectKind.player,
        NegotiationPhase.contractExtension,
        league.currentHour ?? 1,
        onePerDay: true,
      )) {
        continue;
      }
      final plan = aiPolicy.extensionPlan(
        league: league,
        team: team,
        player: player,
        saveSeed: saveSeed,
      );
      if (plan != null) plans.add(plan);
    }
    plans.sort((a, b) {
      final priority = _extensionPriority(
        a.exception,
      ).compareTo(_extensionPriority(b.exception));
      if (priority != 0) return priority;
      final score = b.offerScore.compareTo(a.offerScore);
      return score != 0 ? score : a.player.id.compareTo(b.player.id);
    });
    return plans.isEmpty ? null : plans.first;
  }

  int _extensionPriority(CapExceptionType? exception) => switch (exception) {
    CapExceptionType.rookieExtension => 1,
    CapExceptionType.fullBirdRights => 2,
    CapExceptionType.earlyBirdRights => 3,
    CapExceptionType.veteranExtensionRaiseCap => 4,
    CapExceptionType.nonBirdRights => 5,
    _ => 99,
  };

  LeagueState _insertAiPlayerPlan(
    LeagueState league, {
    required Team team,
    required AiPlayerOfferPlan plan,
    required NegotiationPhase phase,
    required int hour,
  }) {
    final initial = negotiations.start(
      id: _aiId('player', plan.player.id, team.id, league, phase, hour),
      subjectId: plan.player.id,
      subjectKind: NegotiationSubjectKind.player,
      teamId: team.id,
      phase: phase,
      offer: NegotiationOffer(
        salary: plan.offer.salary,
        years: plan.offer.years,
        exception: plan.offer.effectiveException,
        rookiePickSlot: plan.offer.rookiePickSlot,
      ),
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      hour: hour,
      offerScore: plan.offerScore,
      isAiOffer: true,
    );
    return _upsertAiNegotiation(
      league,
      negotiation: initial.copyWith(
        status: NegotiationStatus.pendingFinalization,
        requiresFinalization: true,
      ),
    );
  }

  LeagueState _insertAiStaffPlan(
    LeagueState league, {
    required Team team,
    required AiStaffOfferPlan plan,
    required NegotiationPhase phase,
    required int hour,
  }) {
    final initial = negotiations.start(
      id: _aiId('staff', plan.member.id, team.id, league, phase, hour),
      subjectId: plan.member.id,
      subjectKind: NegotiationSubjectKind.staff,
      teamId: team.id,
      phase: phase,
      offer: NegotiationOffer(
        salary: plan.offer.salary,
        years: plan.offer.years,
      ),
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      hour: hour,
      offerScore: plan.offerScore,
      isAiOffer: true,
    );
    return _upsertAiNegotiation(
      league,
      negotiation: initial.copyWith(
        status: NegotiationStatus.pendingFinalization,
        requiresFinalization: true,
      ),
    );
  }

  bool _hasAiNegotiation(
    LeagueState league,
    String teamId,
    String subjectId,
    NegotiationSubjectKind subjectKind,
    NegotiationPhase phase,
    int hour, {
    bool onePerDay = false,
  }) => league.negotiations.any(
    (item) =>
        item.isAiOffer &&
        item.teamId == teamId &&
        item.subjectId == subjectId &&
        item.subjectKind == subjectKind &&
        item.phase == phase &&
        item.seasonYear == league.currentSeason.year &&
        item.week == league.currentWeek &&
        item.day == league.currentDay &&
        (onePerDay || item.hour == hour),
  );

  LeagueState _applyAiRfaDecisions(
    LeagueState league, {
    required NegotiationPhase phase,
    required int saveSeed,
  }) {
    if (phase == NegotiationPhase.contractExtension) return league;
    var state = league;
    final aiTeams = [
      for (final team in state.teams)
        if (!team.isPlayerControlled) team.id,
    ];
    for (final teamId in aiTeams) {
      final team = state.teamById(teamId);
      if (team == null) continue;
      for (final player in team.roster) {
        if (!aiPolicy.shouldSubmitQualifyingOffer(
          league: state,
          team: team,
          player: player,
          saveSeed: saveSeed,
        )) {
          continue;
        }
        final next = submitQualifyingOffer(
          league: state,
          ownerTeamId: team.id,
          playerId: player.id,
        );
        if (next != null) state = next;
      }
    }
    final sheets = [
      for (final sheet in state.rfaOfferSheets)
        if (!sheet.isTerminal &&
            sheet.phase == phase &&
            state.teamById(sheet.originalTeamId)?.isPlayerControlled == false)
          sheet,
    ];
    for (final sheet in sheets) {
      if (aiPolicy.shouldMatchOfferSheet(
        league: state,
        sheet: sheet,
        saveSeed: saveSeed,
      )) {
        state = matchOfferSheet(state, sheet.id, saveSeed: saveSeed) ?? state;
      } else {
        state = declineOfferSheet(state, sheet.id);
      }
    }
    return state;
  }

  LeagueState _resolveAiCounters(
    LeagueState league, {
    required NegotiationPhase phase,
    required int hour,
    required int saveSeed,
  }) {
    if (phase != NegotiationPhase.contractExtension) return league;
    var state = league;
    for (final current in [...league.negotiations]) {
      if (!current.isAiOffer ||
          current.phase != phase ||
          current.status != NegotiationStatus.counter ||
          current.week != league.currentWeek ||
          current.day != league.currentDay) {
        continue;
      }
      final team = state.teamById(current.teamId);
      final player = _findPlayer(state, current.subjectId);
      if (team == null || player == null) continue;
      final shouldRaise = aiPolicy.shouldRaiseExtensionCounter(
        league: state,
        team: team,
        player: player,
        saveSeed: saveSeed,
        round: current.round,
      );
      if (!shouldRaise) {
        state = state.upsertNegotiation(
          current.copyWith(
            status: NegotiationStatus.rejected,
            counterOffer: null,
            requiresFinalization: false,
          ),
        );
        continue;
      }
      final playerCounter = ContractOffer(
        salary: current.lastOffer.salary,
        years: current.lastOffer.years,
        exception: current.lastOffer.exception,
        rookiePickSlot: current.lastOffer.rookiePickSlot,
      );
      final original = ContractOffer(
        salary: max(
          balance.salaryCap.minSalary,
          (playerCounter.salary * 0.90).round(),
        ),
        years: playerCounter.years,
        exception: playerCounter.exception,
        rookiePickSlot: playerCounter.rookiePickSlot,
      );
      final raised = aiPolicy.extensionCounterOffer(
        league: state,
        team: team,
        player: player,
        original: original,
        playerCounter: playerCounter,
        saveSeed: saveSeed,
      );
      if (raised == null) {
        state = state.upsertNegotiation(
          current.copyWith(
            status: NegotiationStatus.rejected,
            counterOffer: null,
            requiresFinalization: false,
          ),
        );
        continue;
      }
      state = state.upsertNegotiation(
        current.copyWith(
          lastOffer: NegotiationOffer(
            salary: raised.salary,
            years: raised.years,
            exception: raised.effectiveException,
            rookiePickSlot: raised.rookiePickSlot,
          ),
          counterOffer: null,
          status: NegotiationStatus.pendingFinalization,
          requiresFinalization: true,
          offerScore: contracts.playerOfferScore(
            player,
            raised,
            offeringTeamStatus:
                league.strengthTable?.entryFor(team.id)?.teamStatus ??
                TeamStatus.pretender,
            currentTeamStatus:
                league.strengthTable?.entryFor(team.id)?.teamStatus ??
                TeamStatus.pretender,
            cfo: team.staff.cfo,
          ),
        ),
      );
    }
    return state;
  }

  LeagueState _resolveWaiting(
    LeagueState league, {
    required NegotiationPhase phase,
    required int hour,
    required int saveSeed,
    required Set<String> resolvedWaitingIds,
  }) {
    var state = league;
    final records = [...state.negotiations];
    for (final negotiation in records) {
      if (negotiation.phase != phase ||
          negotiation.status != NegotiationStatus.waiting) {
        continue;
      }
      final due =
          negotiation.waitingUntilSeasonYear != null &&
          _compareDate(
                state.currentSeason.year,
                state.currentWeek,
                state.currentDay,
                hour,
                negotiation.waitingUntilSeasonYear!,
                negotiation.waitingUntilWeek!,
                negotiation.waitingUntilDay!,
                negotiation.waitingUntilHour ?? 0,
              ) >=
              0;
      if (!due) continue;
      final score = _scoreFor(state, negotiation);
      final random = Random(
        _seed(
          saveSeed,
          state,
          negotiation.teamId,
          negotiation.subjectId,
          'waiting:${negotiation.round}',
        ),
      );
      ContractNegotiation next;
      if (score >= 70 ||
          (score >= 55 &&
              random.nextDouble() <
                  (0.50 + (score - 62) * 0.03).clamp(0.0, 1.0))) {
        next = negotiation.copyWith(
          status: NegotiationStatus.pendingFinalization,
          requiresFinalization: true,
          offerScore: score,
          waitingUntilSeasonYear: null,
          waitingUntilWeek: null,
          waitingUntilDay: null,
          waitingUntilHour: null,
        );
      } else if (score >= 40) {
        final counter = _counterFor(state, negotiation);
        next = negotiation.copyWith(
          status: counter == null
              ? NegotiationStatus.counter
              : NegotiationStatus.counter,
          lastOffer: counter ?? negotiation.lastOffer,
          counterOffer: counter,
          round: negotiation.round + 1,
          offerScore: score,
          requiresFinalization: false,
          waitingUntilSeasonYear: null,
          waitingUntilWeek: null,
          waitingUntilDay: null,
          waitingUntilHour: null,
        );
      } else {
        next = negotiation.copyWith(
          status: score <= 24
              ? NegotiationStatus.hardRejected
              : NegotiationStatus.rejected,
          offerScore: score,
          requiresFinalization: false,
          waitingUntilSeasonYear: null,
          waitingUntilWeek: null,
          waitingUntilDay: null,
          waitingUntilHour: null,
        );
      }
      next = next.copyWith(
        seasonYear: state.currentSeason.year,
        week: state.currentWeek,
        day: state.currentDay,
        hour: hour,
      );
      state = state.upsertNegotiation(next);
      if (next.status == NegotiationStatus.pendingFinalization) {
        resolvedWaitingIds.add(next.id);
      }
      if (state.playerTeamId == negotiation.teamId) {
        final kind = switch (next.status) {
          NegotiationStatus.pendingFinalization => 'accept',
          NegotiationStatus.counter => 'counter',
          NegotiationStatus.hardRejected => 'hardReject',
          _ => 'reject',
        };
        final subjectName =
            negotiation.subjectKind == NegotiationSubjectKind.player
            ? _findPlayer(state, negotiation.subjectId)?.name ??
                  negotiation.subjectId
            : _findStaffForNegotiation(state, negotiation)?.name ??
                  negotiation.subjectId;
        state = messages.send(
          state,
          type: negotiation.subjectKind == NegotiationSubjectKind.player
              ? MessageType.contractOfferResponse
              : MessageType.staffOfferResponse,
          kind: kind,
          domain: negotiation.subjectKind == NegotiationSubjectKind.player
              ? MessageDomain.contracts
              : MessageDomain.staff,
          hour: hour,
          // TODO(subjectName-migration): kind == reject needs {reason} and
          // kind == counter needs {extraTerms}; see chat decision (same gap
          // as the two call sites above).
          args: {
            'subjectName': subjectName,
            negotiation.subjectKind == NegotiationSubjectKind.player
                    ? 'playerName'
                    : 'staffName':
                subjectName,
            'salary': next.lastOffer.salary,
            'years': next.lastOffer.years,
            'score': next.offerScore,
            'phase': phase.name,
          },
          payload: {
            'negotiationId': next.id,
            'subjectId': next.subjectId,
            'teamId': next.teamId,
            'counterSalary': next.counterOffer?.salary,
            'counterYears': next.counterOffer?.years,
          },
        );
      }
    }
    return state;
  }

  LeagueState _resolveSubjectOffers(
    LeagueState league, {
    required NegotiationPhase phase,
    required int hour,
    required int saveSeed,
  }) {
    var state = league;
    final groups = <String, List<ContractNegotiation>>{};
    for (final negotiation in state.negotiations) {
      final isSameMarketSlot = phase == NegotiationPhase.freeAgencyPhaseII
          ? negotiation.hour == hour
          : negotiation.hour <= hour;
      if (negotiation.phase != phase ||
          negotiation.week != state.currentWeek ||
          negotiation.day != state.currentDay ||
          !isSameMarketSlot ||
          negotiation.isTerminal ||
          negotiation.status != NegotiationStatus.pendingFinalization) {
        continue;
      }
      groups
          .putIfAbsent(
            '${negotiation.subjectKind.name}:${negotiation.subjectId}',
            () => <ContractNegotiation>[],
          )
          .add(negotiation.copyWith(offerScore: _scoreFor(state, negotiation)));
    }

    for (final group in groups.values) {
      final subject = group.first;
      final waitingActive = state.negotiations.any((item) {
        if (item.subjectKind != subject.subjectKind ||
            item.subjectId != subject.subjectId ||
            item.phase != phase ||
            item.status != NegotiationStatus.waiting ||
            item.waitingUntilSeasonYear == null) {
          return false;
        }
        return _compareDate(
              state.currentSeason.year,
              state.currentWeek,
              state.currentDay,
              hour,
              item.waitingUntilSeasonYear!,
              item.waitingUntilWeek!,
              item.waitingUntilDay!,
              item.waitingUntilHour ?? 0,
            ) <
            0;
      });
      if (waitingActive) continue;
      group.sort((a, b) {
        final score = b.offerScore.compareTo(a.offerScore);
        return score != 0 ? score : a.teamId.compareTo(b.teamId);
      });
      ContractNegotiation? winner;
      for (final candidate in group) {
        if (!candidate.isAiOffer) {
          winner = candidate;
          break;
        }
        final signed = _finalizeAi(state, candidate, saveSeed: saveSeed);
        if (signed != null) {
          state = signed;
          winner = candidate.copyWith(
            status: NegotiationStatus.completed,
            requiresFinalization: false,
            rivalFinalized: true,
          );
          state = state.upsertNegotiation(winner);
          break;
        }
        state = state.upsertNegotiation(
          candidate.copyWith(status: NegotiationStatus.hardRejected),
        );
      }
      if (winner == null) continue;
      for (final candidate in group) {
        if (candidate.id == winner.id) continue;
        final current = state.negotiationById(candidate.id);
        if (current == null || current.isTerminal) continue;
        state = state.upsertNegotiation(
          current.copyWith(
            status: NegotiationStatus.cancelled,
            selectedByRival: true,
            requiresFinalization: false,
          ),
        );
        if (state.playerTeamId == current.teamId) {
          final subjectName =
              current.subjectKind == NegotiationSubjectKind.player
              ? _findPlayer(state, current.subjectId)?.name ?? current.subjectId
              : _findStaffForNegotiation(state, current)?.name ??
                    current.subjectId;
          final rivalName =
              state.teamById(winner.teamId)?.name ?? winner.teamId;
          state = messages.send(
            state,
            type: current.subjectKind == NegotiationSubjectKind.player
                ? MessageType.contractLostToRival
                : MessageType.staffOfferResponse,
            kind: 'lostToRival',
            domain: current.subjectKind == NegotiationSubjectKind.player
                ? MessageDomain.contracts
                : MessageDomain.staff,
            args: {
              'subjectName': subjectName,
              'playerName': subjectName,
              'staffName': subjectName,
              'winnerTeamName': rivalName,
              'rivalTeam': rivalName,
              'winnerTeam': rivalName,
            },
            payload: {
              'negotiationId': current.id,
              'subjectId': current.subjectId,
              'winnerTeamId': winner.teamId,
              'teamId': current.teamId,
            },
            dedupKey:
                'contractLostToRival:${current.subjectKind.name}:${current.id}:${winner.teamId}',
          );
        }
      }
      if (!winner.isAiOffer) {
        state = state.upsertNegotiation(winner);
      }
    }
    return state;
  }

  LeagueState? _finalizeAi(
    LeagueState league,
    ContractNegotiation negotiation, {
    required int saveSeed,
  }) {
    final team = league.teamById(negotiation.teamId);
    if (team == null) return null;
    final ntcRandom = Random(
      _seed(saveSeed, league, negotiation.teamId, negotiation.subjectId, 'ntc'),
    );
    if (negotiation.subjectKind == NegotiationSubjectKind.player) {
      final player = _findPlayer(league, negotiation.subjectId);
      if (player == null) return null;
      final signed = contracts.signPlayer(
        team: team,
        player: player,
        offer: ContractOffer(
          salary: negotiation.lastOffer.salary,
          years: negotiation.lastOffer.years,
          exception: negotiation.lastOffer.exception,
          rookiePickSlot: negotiation.lastOffer.rookiePickSlot,
        ),
        ntcRandom: ntcRandom,
      );
      if (signed == null) return null;
      var state = league
          .updateTeam(signed)
          .copyWith(
            freeAgents: league.freeAgents
                .where((item) => item.id != player.id)
                .toList(),
          );
      state = _removeFreshUndrafted(state, player.id);
      return messages.send(
        state,
        type: MessageType.contractSigned,
        domain: MessageDomain.contracts,
        args: {
          'subjectName': player.name,
          'playerName': player.name,
          'teamName': team.name,
          'salary': negotiation.lastOffer.salary,
          'years': negotiation.lastOffer.years,
        },
        payload: {'playerId': player.id, 'teamId': team.id},
      );
    }

    final member = _findStaffForNegotiation(league, negotiation);
    if (member == null) return null;
    final hired = staff.sign(
      team: team,
      member: member,
      offer: StaffOffer(
        salary: negotiation.lastOffer.salary,
        years: negotiation.lastOffer.years,
      ),
    );
    if (hired == null) return null;
    var state = league
        .updateTeam(hired)
        .copyWith(
          staffFreeAgents: league.canonicalStaffFreeAgents
              .where((item) => item.id != member.id)
              .toList(),
        );
    return messages.send(
      state,
      type: MessageType.staffSigned,
      domain: MessageDomain.staff,
      args: {
        'subjectName': member.name,
        'staffName': member.name,
        'teamName': team.name,
        'staffRole': member.role.name,
      },
      payload: {'staffId': member.id, 'teamId': team.id},
    );
  }

  NegotiationOffer? _counterFor(
    LeagueState league,
    ContractNegotiation negotiation,
  ) {
    final offer = ContractOffer(
      salary: negotiation.lastOffer.salary,
      years: negotiation.lastOffer.years,
      exception: negotiation.lastOffer.exception,
      rookiePickSlot: negotiation.lastOffer.rookiePickSlot,
    );
    if (negotiation.subjectKind == NegotiationSubjectKind.player) {
      final player = _findPlayer(league, negotiation.subjectId);
      if (player == null) return null;
      final counter = contracts.counterOfferForRound(
        player,
        offer,
        round: negotiation.round,
      );
      return counter == null
          ? null
          : NegotiationOffer(
              salary: counter.salary,
              years: counter.years,
              exception: counter.effectiveException,
              rookiePickSlot: counter.rookiePickSlot,
            );
    }
    final member = _findStaffForNegotiation(league, negotiation);
    if (member == null) return null;
    final team = league.teamById(negotiation.teamId);
    if (team == null) return null;
    final status =
        league.strengthTable?.entryFor(team.id)?.teamStatus ??
        TeamStatus.pretender;
    final counter = staff.counterOfferForRound(
      member,
      StaffOffer(salary: offer.salary, years: offer.years),
      round: negotiation.round,
      offeringTeamStatus: status,
      currentTeamStatus: status,
      cfo: member.role == StaffRole.cfo ? null : team.staff.cfo,
    );
    return counter == null
        ? null
        : NegotiationOffer(salary: counter.salary, years: counter.years);
  }

  double _scoreFor(LeagueState league, ContractNegotiation negotiation) {
    final team = league.teamById(negotiation.teamId);
    if (team == null) return negotiation.offerScore;
    final status =
        league.strengthTable?.entryFor(team.id)?.teamStatus ??
        TeamStatus.pretender;
    if (negotiation.subjectKind == NegotiationSubjectKind.player) {
      // Preserve the existing player-market score lifecycle. Staff scores are
      // deliberately recomputed below from the current verified member.
      if (negotiation.offerScore > 0) return negotiation.offerScore;
      final player = _findPlayer(league, negotiation.subjectId);
      if (player == null) return 0;
      return contracts.playerOfferScore(
        player,
        ContractOffer(
          salary: negotiation.lastOffer.salary,
          years: negotiation.lastOffer.years,
          exception: negotiation.lastOffer.exception,
          rookiePickSlot: negotiation.lastOffer.rookiePickSlot,
        ),
        offeringTeamStatus: status,
        currentTeamStatus: status,
        cfo: team.staff.cfo,
      );
    }
    final member = _findStaffForNegotiation(league, negotiation);
    if (member == null) return 0;
    return staff.staffOfferScore(
      member,
      StaffOffer(
        salary: negotiation.lastOffer.salary,
        years: negotiation.lastOffer.years,
      ),
      offeringTeamStatus: status,
      currentTeamStatus: status,
      cfo: member.role == StaffRole.cfo ? null : team.staff.cfo,
    );
  }

  LeagueState _upsertAiNegotiation(
    LeagueState league, {
    required ContractNegotiation negotiation,
  }) {
    final existing = league.negotiationById(negotiation.id);
    if (existing != null && !existing.isTerminal) return league;
    return league.upsertNegotiation(negotiation);
  }

  LeagueState _expireOfferSheets(LeagueState league, {int? hour}) {
    final sheets = league.rfaOfferSheets
        .map(
          (sheet) =>
              !_isBeforeOrAtDeadline(league, sheet, hour: hour) &&
                  !sheet.isTerminal
              ? sheet.copyWith(declined: true)
              : sheet,
        )
        .toList();
    return league.copyWith(rfaOfferSheets: sheets);
  }

  bool _isBeforeOrAtDeadline(
    LeagueState league,
    RfaOfferSheet sheet, {
    int? hour,
  }) =>
      _compareDate(
        league.currentSeason.year,
        league.currentWeek,
        league.currentDay,
        hour ?? league.currentHour ?? 0,
        sheet.expirySeasonYear,
        sheet.expiryWeek,
        sheet.expiryDay,
        sheet.expiryHour,
      ) <=
      0;

  LeagueState _removeFreshUndrafted(LeagueState league, String playerId) =>
      league.copyWith(
        freshUndraftedPlayers: league.freshUndraftedPlayers
            .where((record) => record.playerId != playerId)
            .toList(),
      );

  Player? _findPlayer(LeagueState league, String playerId) {
    for (final team in league.teams) {
      for (final player in team.roster) {
        if (player.id == playerId) return player;
      }
    }
    for (final player in league.freeAgents) {
      if (player.id == playerId) return player;
    }
    for (final right in league.draftedRights) {
      if (right.player.id == playerId) return right.player;
    }
    return null;
  }

  /// Returns a member only when its declared role matches the occupied slot.
  /// A typed [TeamStaff] can still contain legacy/mismatched slot data, and a
  /// negotiation must never migrate that record into another role.
  StaffMember? _staffMemberForTeam(Team team, String staffId) {
    for (final role in StaffRole.values) {
      final member = team.staff.canonicalMember(role);
      if (member?.id == staffId && member?.role == role) return member;
    }
    return null;
  }

  /// Resolves a staff negotiation from the collection that owns its subject.
  /// Extensions belong to the offering team's matching slot; both free-agent
  /// phases belong to [LeagueState.staffFreeAgents]. This prevents stale UI
  /// records, duplicate IDs in another team, and mismatched slots from
  /// entering scoring, counters, or signing.
  StaffMember? _findStaffForNegotiation(
    LeagueState league,
    ContractNegotiation negotiation,
  ) {
    final team = league.teamById(negotiation.teamId);
    if (team == null) return null;
    if (negotiation.phase == NegotiationPhase.contractExtension) {
      return _staffMemberForTeam(team, negotiation.subjectId);
    }
    for (final member in league.canonicalStaffFreeAgents) {
      if (member.id == negotiation.subjectId) return member;
    }
    return null;
  }

  String _aiId(
    String kind,
    String subjectId,
    String teamId,
    LeagueState league,
    NegotiationPhase phase,
    int hour,
  ) =>
      'ai:$kind:$subjectId:$teamId:${league.currentSeason.year}:${league.currentWeek}:${league.currentDay}:${phase.name}:$hour';

  int _seed(
    int saveSeed,
    LeagueState league,
    String teamId,
    String subjectId,
    String purpose,
  ) => _stableSeed(
    '$saveSeed:${league.currentSeason.year}:${league.currentWeek}:${league.currentDay}:${league.currentHour ?? 0}:$teamId:$subjectId:$purpose',
  );

  int _stableSeed(String value) {
    var result = 0x45d9f3b;
    for (final code in value.codeUnits) {
      result = ((result * 33) ^ code) & 0x7fffffff;
    }
    return result == 0 ? 1 : result;
  }

  int _compareDate(
    int seasonA,
    int weekA,
    int dayA,
    int hourA,
    int seasonB,
    int weekB,
    int dayB,
    int hourB,
  ) {
    final a =
        (((seasonA * balance.calendar.seasonCycleWeeks + weekA) * 7 + dayA) *
            balance.contracts.hoursPerDay) +
        hourA;
    final b =
        (((seasonB * balance.calendar.seasonCycleWeeks + weekB) * 7 + dayB) *
            balance.contracts.hoursPerDay) +
        hourB;
    return a.compareTo(b);
  }
}
