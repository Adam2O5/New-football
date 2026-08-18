import 'dart:math';

import 'package:new_football/core/ai/team_ai_service.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/random/seeds.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/core/services/negotiation_rules.dart';
import 'package:new_football/core/services/negotiation_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/core/services/staff_service.dart';

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
  }) : calendar = calendar ?? CalendarService(balance: balance),
       contracts = contracts ?? ContractService(balance: balance),
       staff = staff ?? StaffService(balance: balance),
       capService = capService ?? SalaryCapService(balance: balance),
       negotiations = negotiations ?? NegotiationService(balance: balance),
       messages = messages ?? MessageService();

  final BalanceConfig balance;
  final CalendarService calendar;
  final ContractService contracts;
  final StaffService staff;
  final SalaryCapService capService;
  final NegotiationService negotiations;
  final MessageService messages;

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
      args: {
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
        ? team.staff.members.cast<StaffMember?>().firstWhere(
            (member) => member?.id == candidate.id,
            orElse: () => null,
          )
        : league.staffFreeAgents.cast<StaffMember?>().firstWhere(
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
    if (!isExtension && team.staff.member(actualCandidate.role) != null) {
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
      subjectId: candidate.id,
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
      candidate,
      offer,
      phase: phase,
      offeringTeamStatus: status,
      currentTeamStatus: status,
      cfo: team.staff.cfo,
      competingOffers: competingOffers,
      belowExpectation:
          offer.salary <
          staff.expectedSalary(candidate, currentTeamStatus: status),
      random: Random(
        _stableSeed(
          '$saveSeed:${league.currentSeason.year}:${league.currentWeek}:${league.currentDay}:$hour:${team.id}:${candidate.id}:submit:${phase.name}',
        ),
      ),
    );
    final id =
        'staff:${candidate.id}:${team.id}:${league.currentSeason.year}:${league.currentWeek}:${league.currentDay}:$hour';
    final initial = negotiations.start(
      id: id,
      subjectId: candidate.id,
      subjectKind: NegotiationSubjectKind.staff,
      teamId: team.id,
      phase: phase,
      offer: NegotiationOffer(salary: offer.salary, years: offer.years),
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
      day: league.currentDay,
      hour: hour,
      offerScore: staff.staffOfferScore(
        candidate,
        offer,
        offeringTeamStatus: status,
        currentTeamStatus: status,
        cfo: team.staff.cfo,
      ),
    );
    final counter = reaction == StaffReaction.counter
        ? staff.counterOfferForRound(
            candidate,
            offer,
            round: 1,
            offeringTeamStatus: status,
            currentTeamStatus: status,
            cfo: team.staff.cfo,
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
          subjectId: candidate.id,
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
      args: {
        'staffName': candidate.name,
        'salary': record.lastOffer.salary,
        'years': record.lastOffer.years,
        'score': record.offerScore,
        'phase': phase.name,
      },
      payload: {
        'negotiationId': record.id,
        'staffId': candidate.id,
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
      return messages.send(
        state,
        type: MessageType.contractSigned,
        domain: MessageDomain.contracts,
        args: {'playerName': player.name, 'teamName': team.name},
        payload: {
          'playerId': player.id,
          'teamId': team.id,
          'negotiationId': negotiation.id,
        },
      );
    }

    final member = _findStaff(league, negotiation.subjectId);
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
          staffFreeAgents: league.staffFreeAgents
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
      args: {'staffName': member.name, 'teamName': team.name},
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

    final member = _findStaff(league, current.subjectId);
    if (member == null) return null;
    final currentMember = team.staff.member(member.role);
    if (currentMember != null && currentMember.id != member.id) return null;
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
      includeAi: window == ContractMarketWindow.freeAgencyPhaseI,
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
          if (state.freeAgents.isEmpty && state.staffFreeAgents.isEmpty) break;
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
      args: {'playerName': player.name, 'salary': amount, 'years': years},
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
        'playerName': player.name,
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
    return messages.send(
      state,
      type: MessageType.contractSigned,
      domain: MessageDomain.contracts,
      args: {'playerName': player.name, 'teamName': team.name},
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
      args: {'playerName': right.player.name, 'teamName': team.name},
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
    var state = league;
    final aiTeams = state.teams.where((team) => !team.isPlayerControlled);
    for (final team in aiTeams) {
      if (team.roster.length < balance.roster.maxSize &&
          state.freeAgents.isNotEmpty) {
        final players = [...state.freeAgents]
          ..sort((a, b) => b.overall(balance).compareTo(a.overall(balance)));
        final index =
            negotiationSeed(
              saveSeed,
              state.currentSeason.year,
              state.currentWeek,
              team.id,
              DecisionType.faOffer,
              'player-selection',
              'hour',
              round: hour,
            ) %
            players.length;
        final player = players[index];
        final offer = TeamAiService(balance: balance).makeFaOffer(
          player,
          contracts,
          saveSeed: saveSeed,
          seasonYear: state.currentSeason.year,
          week: state.currentWeek,
          teamId: team.id,
        );
        final legal = contracts.validateOffer(
          team: team,
          player: player,
          offer: offer,
        );
        if (legal.ok) {
          final status =
              state.strengthTable?.entryFor(team.id)?.teamStatus ??
              TeamStatus.pretender;
          final score = contracts.playerOfferScore(
            player,
            offer,
            offeringTeamStatus: status,
            cfo: team.staff.cfo,
          );
          state = _upsertAiNegotiation(
            state,
            negotiation: negotiations
                .start(
                  id: _aiId('player', player.id, team.id, state, phase, hour),
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
                  seasonYear: state.currentSeason.year,
                  week: state.currentWeek,
                  day: state.currentDay,
                  hour: hour,
                  offerScore: score,
                  isAiOffer: true,
                )
                .copyWith(
                  status: NegotiationStatus.pendingFinalization,
                  requiresFinalization: true,
                ),
          );
        }
      }

      final staffCandidates =
          state.staffFreeAgents
              .where((member) => team.staff.member(member.role) == null)
              .toList()
            ..sort((a, b) => b.overall.compareTo(a.overall));
      if (staffCandidates.isEmpty) continue;
      final member =
          staffCandidates[_stableSeed(
                '$saveSeed:${state.currentSeason.year}:${state.currentWeek}:$hour:${team.id}:staff',
              ) %
              staffCandidates.length];
      final random = Random(
        _stableSeed(
          '$saveSeed:${state.currentSeason.year}:${state.currentWeek}:${state.currentDay}:$hour:${team.id}:${member.id}:staff',
        ),
      );
      final expected = staff.expectedSalary(member);
      final offer = StaffOffer(
        salary: (expected * (0.97 + random.nextDouble() * 0.08)).round().clamp(
          balance.staff.minSalary,
          balance.staff.maxSalary,
        ),
        years: staff.expectedLength(member).clamp(1, 4),
      );
      if (staff.hireValidationReason(team, offer.salary) != null) continue;
      final status =
          state.strengthTable?.entryFor(team.id)?.teamStatus ??
          TeamStatus.pretender;
      final score = staff.staffOfferScore(
        member,
        offer,
        offeringTeamStatus: status,
        cfo: team.staff.cfo,
      );
      state = _upsertAiNegotiation(
        state,
        negotiation: negotiations
            .start(
              id: _aiId('staff', member.id, team.id, state, phase, hour),
              subjectId: member.id,
              subjectKind: NegotiationSubjectKind.staff,
              teamId: team.id,
              phase: phase,
              offer: NegotiationOffer(salary: offer.salary, years: offer.years),
              seasonYear: state.currentSeason.year,
              week: state.currentWeek,
              day: state.currentDay,
              hour: hour,
              offerScore: score,
              isAiOffer: true,
            )
            .copyWith(
              status: NegotiationStatus.pendingFinalization,
              requiresFinalization: true,
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
            : _findStaff(state, negotiation.subjectId)?.name ??
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
          args: {
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
              : _findStaff(state, current.subjectId)?.name ?? current.subjectId;
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
      return messages.send(
        state,
        type: MessageType.contractSigned,
        domain: MessageDomain.contracts,
        args: {'playerName': player.name, 'teamName': team.name},
        payload: {'playerId': player.id, 'teamId': team.id},
      );
    }

    final member = _findStaff(league, negotiation.subjectId);
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
          staffFreeAgents: league.staffFreeAgents
              .where((item) => item.id != member.id)
              .toList(),
        );
    return messages.send(
      state,
      type: MessageType.staffSigned,
      domain: MessageDomain.staff,
      args: {'staffName': member.name, 'teamName': team.name},
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
    final member = _findStaff(league, negotiation.subjectId);
    if (member == null) return null;
    final counter = staff.counterOfferForRound(
      member,
      StaffOffer(salary: offer.salary, years: offer.years),
      round: negotiation.round,
    );
    return counter == null
        ? null
        : NegotiationOffer(salary: counter.salary, years: counter.years);
  }

  double _scoreFor(LeagueState league, ContractNegotiation negotiation) {
    if (negotiation.offerScore > 0) return negotiation.offerScore;
    final team = league.teamById(negotiation.teamId);
    if (team == null) return negotiation.offerScore;
    final status =
        league.strengthTable?.entryFor(team.id)?.teamStatus ??
        TeamStatus.pretender;
    if (negotiation.subjectKind == NegotiationSubjectKind.player) {
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
    final member = _findStaff(league, negotiation.subjectId);
    if (member == null) return 0;
    return staff.staffOfferScore(
      member,
      StaffOffer(
        salary: negotiation.lastOffer.salary,
        years: negotiation.lastOffer.years,
      ),
      offeringTeamStatus: status,
      currentTeamStatus: status,
      cfo: team.staff.cfo,
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

  StaffMember? _findStaff(LeagueState league, String staffId) {
    for (final member in league.staffFreeAgents) {
      if (member.id == staffId) return member;
    }
    for (final team in league.teams) {
      for (final member in team.staff.members) {
        if (member.id == staffId) return member;
      }
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
