import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/services/negotiation_rules.dart';
import 'package:new_football/core/services/calendar_service.dart';

/// State and date helpers shared by player and staff negotiation flows.
class NegotiationService {
  const NegotiationService({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  NegotiationDeadline deadlineFor({
    required NegotiationPhase phase,
    required int seasonYear,
    required int week,
    required int day,
    required int hour,
  }) {
    switch (phase) {
      case NegotiationPhase.freeAgencyPhaseI:
        return NegotiationDeadline(
          seasonYear: seasonYear,
          week: week,
          day: day,
          hour: (hour + balance.contracts.phaseIFinalizationHours).clamp(
            hour,
            balance.contracts.hoursPerDay,
          ),
        );
      case NegotiationPhase.freeAgencyPhaseII:
        return _addDays(
          seasonYear: seasonYear,
          week: week,
          day: day,
          hour: hour,
          days: balance.contracts.phaseIIFinalizationDays,
        );
      case NegotiationPhase.contractExtension:
        return _addDays(
          seasonYear: seasonYear,
          week: week,
          day: day,
          hour: hour,
          days: balance.contracts.extensionFinalizationDays,
        );
    }
  }

  ContractNegotiation start({
    required String id,
    required String subjectId,
    required NegotiationSubjectKind subjectKind,
    required String teamId,
    required NegotiationPhase phase,
    required NegotiationOffer offer,
    required int seasonYear,
    required int week,
    int day = 1,
    int hour = 0,
    double offerScore = 0.0,
    bool isAiOffer = false,
  }) {
    final deadline = deadlineFor(
      phase: phase,
      seasonYear: seasonYear,
      week: week,
      day: day,
      hour: hour,
    );
    return ContractNegotiation(
      id: id,
      subjectId: subjectId,
      subjectKind: subjectKind,
      teamId: teamId,
      phase: phase,
      lastOffer: offer,
      offerScore: offerScore,
      isAiOffer: isAiOffer,
      seasonYear: seasonYear,
      week: week,
      day: day,
      hour: hour,
      expirySeasonYear: deadline.seasonYear,
      expiryWeek: deadline.week,
      expiryDay: deadline.day,
      expiryHour: deadline.hour,
    );
  }

  ContractNegotiation applyDecision({
    required ContractNegotiation negotiation,
    required NegotiationDecision decision,
    NegotiationOffer? counterOffer,
    required int seasonYear,
    required int week,
    int day = 1,
    int hour = 0,
  }) {
    final deadline = deadlineFor(
      phase: negotiation.phase,
      seasonYear: seasonYear,
      week: week,
      day: day,
      hour: hour,
    );
    final waitingUntil = decision == NegotiationDecision.waiting
        ? _addHours(
            seasonYear: seasonYear,
            week: week,
            day: day,
            hour: hour,
            hours: 2,
          )
        : null;
    return negotiation.copyWith(
      // A counter is the offer the next accept/finalization operates on. The
      // original is still retained in counterOffer for UI/history purposes.
      lastOffer: counterOffer ?? negotiation.lastOffer,
      round: decision == NegotiationDecision.counter
          ? negotiation.round + 1
          : negotiation.round,
      counterOffer: counterOffer,
      status: switch (decision) {
        NegotiationDecision.accept => NegotiationStatus.pendingFinalization,
        NegotiationDecision.hardReject => NegotiationStatus.hardRejected,
        NegotiationDecision.reject => NegotiationStatus.rejected,
        NegotiationDecision.waiting => NegotiationStatus.waiting,
        NegotiationDecision.counter => NegotiationStatus.counter,
      },
      requiresFinalization: decision == NegotiationDecision.accept,
      expirySeasonYear: deadline.seasonYear,
      expiryWeek: deadline.week,
      expiryDay: deadline.day,
      expiryHour: deadline.hour,
      waitingUntilSeasonYear: waitingUntil?.seasonYear,
      waitingUntilWeek: waitingUntil?.week,
      waitingUntilDay: waitingUntil?.day,
      waitingUntilHour: waitingUntil?.hour,
    );
  }

  NegotiationBlock blockFor({
    required String subjectId,
    required NegotiationSubjectKind subjectKind,
    required String teamId,
    required int seasonYear,
    required int week,
    required int day,
    int hour = 0,
  }) {
    return _blockAfterDays(
      subjectId: subjectId,
      subjectKind: subjectKind,
      teamId: teamId,
      seasonYear: seasonYear,
      week: week,
      day: day,
      hour: hour,
      days: balance.contracts.negotiationBlockDays,
    );
  }

  bool isBlocked({
    required LeagueState league,
    required String subjectId,
    required NegotiationSubjectKind subjectKind,
    required String teamId,
    required int seasonYear,
    required int week,
    required int day,
    int hour = 0,
  }) {
    return league.negotiationBlocks.any((block) {
      if (block.subjectId != subjectId ||
          block.subjectKind != subjectKind ||
          block.teamId != teamId) {
        return false;
      }
      return _compare(
            seasonYear,
            week,
            day,
            hour,
            block.untilSeasonYear,
            block.untilWeek,
            block.untilDay,
            block.untilHour,
          ) <=
          0;
    });
  }

  LeagueState upsert(
    LeagueState league,
    ContractNegotiation negotiation, {
    NegotiationBlock? block,
  }) {
    final blocks = block == null
        ? league.negotiationBlocks
        : [
            ...league.negotiationBlocks.where(
              (item) =>
                  !(item.subjectId == block.subjectId &&
                      item.subjectKind == block.subjectKind &&
                      item.teamId == block.teamId),
            ),
            block,
          ];
    return league
        .upsertNegotiation(negotiation)
        .copyWith(negotiationBlocks: blocks);
  }

  LeagueState expireAt({
    required LeagueState league,
    required int seasonYear,
    required int week,
    required int day,
    int hour = 0,
    Set<String> skipNegotiationIds = const {},
  }) {
    final next = <ContractNegotiation>[];
    final blocks = [...league.negotiationBlocks];
    for (final negotiation in league.negotiations) {
      final windowEnd = CalendarService(
        balance: balance,
      ).phaseIIWindowEnd(negotiation.seasonYear, negotiation.week);
      final phaseIIWindowEnded =
          negotiation.phase == NegotiationPhase.freeAgencyPhaseII &&
          _compare(
                seasonYear,
                week,
                day,
                hour,
                windowEnd.seasonYear,
                windowEnd.week,
                windowEnd.day,
                windowEnd.hour,
              ) >=
              0;
      if (skipNegotiationIds.contains(negotiation.id) && !phaseIIWindowEnded) {
        next.add(negotiation);
        continue;
      }
      final rivalSelection =
          negotiation.selectedByRival && !negotiation.rivalFinalized;
      final waitingTimerActive =
          negotiation.status == NegotiationStatus.waiting &&
          negotiation.waitingUntilSeasonYear != null &&
          _compare(
                seasonYear,
                week,
                day,
                hour,
                negotiation.waitingUntilSeasonYear!,
                negotiation.waitingUntilWeek!,
                negotiation.waitingUntilDay!,
                negotiation.waitingUntilHour ?? 0,
              ) <
              0;
      final cancelled = phaseIIWindowEnded || rivalSelection;
      final expired =
          phaseIIWindowEnded ||
          (!waitingTimerActive &&
              _compare(
                    seasonYear,
                    week,
                    day,
                    hour,
                    negotiation.expirySeasonYear,
                    negotiation.expiryWeek,
                    negotiation.expiryDay,
                    negotiation.expiryHour,
                  ) >=
                  0);
      if (!expired || negotiation.isTerminal) {
        next.add(negotiation);
        continue;
      }
      final status = cancelled
          ? NegotiationStatus.cancelled
          : NegotiationStatus.hardRejected;
      next.add(
        negotiation.copyWith(status: status, terminalSeasonYear: seasonYear),
      );
      if (!cancelled) {
        blocks.add(
          blockFor(
            subjectId: negotiation.subjectId,
            subjectKind: negotiation.subjectKind,
            teamId: negotiation.teamId,
            seasonYear: seasonYear,
            week: week,
            day: day,
            hour: hour,
          ),
        );
      }
    }
    return pruneHistory(
      league.copyWith(negotiations: next, negotiationBlocks: blocks),
      seasonYear: seasonYear,
      week: week,
      day: day,
      hour: hour,
    );
  }

  /// Keeps terminal records through the next season and for as long as an
  /// inbox entry (including scheduled/archive) or unresolved RFA needs them.
  /// Active/waiting/counter/pending-finalization records are never evicted.
  LeagueState pruneHistory(
    LeagueState league, {
    required int seasonYear,
    required int week,
    required int day,
    int hour = 0,
  }) {
    final referenced = <String>{
      for (final message in [
        ...league.inbox.messages,
        ...league.inbox.scheduled,
        ...league.inbox.archive,
      ])
        if (message.payload['negotiationId'] is String)
          message.payload['negotiationId'] as String,
    };
    final rfaPlayers = {
      for (final sheet in league.rfaOfferSheets)
        if (!sheet.isTerminal) sheet.playerId,
    };
    final retained = <ContractNegotiation>[];
    for (final record in league.negotiations) {
      if (!record.isTerminal) {
        retained.add(record);
        continue;
      }
      // A record without a terminal date starts its retention now; its start
      // date cannot safely stand in for a later completion date.
      final terminalYear = record.terminalSeasonYear ?? seasonYear;
      if (seasonYear <= terminalYear + 1 ||
          referenced.contains(record.id) ||
          rfaPlayers.contains(record.subjectId)) {
        retained.add(record.copyWith(terminalSeasonYear: terminalYear));
      }
    }
    final blocks = league.negotiationBlocks
        .where(
          (block) =>
              _compare(
                seasonYear,
                week,
                day,
                hour,
                block.untilSeasonYear,
                block.untilWeek,
                block.untilDay,
                block.untilHour,
              ) <=
              0,
        )
        .toList();
    return league.copyWith(
      negotiations: retained,
      negotiationBlocks: _deduplicateBlocks(blocks),
    );
  }

  NegotiationDeadline _addHours({
    required int seasonYear,
    required int week,
    required int day,
    required int hour,
    required int hours,
  }) {
    var nextSeason = seasonYear;
    var nextWeek = week;
    var nextDay = day;
    var nextHour = hour + hours;

    // Waiting is resolved inside the current FA-I day. A normal slot gets
    // the full two-hour timer, while the final two slots collapse to the last
    // available slot instead of leaking into the next calendar day.
    if (nextHour > balance.contracts.hoursPerDay) {
      nextHour = balance.contracts.hoursPerDay;
    }

    while (nextDay > 7) {
      nextDay -= 7;
      nextWeek++;
    }
    while (nextWeek > balance.calendar.seasonCycleWeeks) {
      nextWeek -= balance.calendar.seasonCycleWeeks;
      nextSeason++;
    }
    return NegotiationDeadline(
      seasonYear: nextSeason,
      week: nextWeek,
      day: nextDay,
      hour: nextHour,
    );
  }

  NegotiationDeadline _addDays({
    required int seasonYear,
    required int week,
    required int day,
    required int hour,
    required int days,
  }) {
    var nextWeek = week;
    var nextDay = day + days;
    while (nextDay > 7) {
      nextDay -= 7;
      nextWeek++;
    }
    var nextSeason = seasonYear;
    while (nextWeek > balance.calendar.seasonCycleWeeks) {
      nextWeek -= balance.calendar.seasonCycleWeeks;
      nextSeason++;
    }
    return NegotiationDeadline(
      seasonYear: nextSeason,
      week: nextWeek,
      day: nextDay,
      hour: hour,
    );
  }

  NegotiationBlock _blockAfterDays({
    required String subjectId,
    required NegotiationSubjectKind subjectKind,
    required String teamId,
    required int seasonYear,
    required int week,
    required int day,
    required int hour,
    required int days,
  }) {
    final deadline = _addDays(
      seasonYear: seasonYear,
      week: week,
      day: day,
      hour: hour,
      days: days,
    );
    return NegotiationBlock(
      subjectId: subjectId,
      subjectKind: subjectKind,
      teamId: teamId,
      untilSeasonYear: deadline.seasonYear,
      untilWeek: deadline.week,
      untilDay: deadline.day,
      untilHour: deadline.hour,
    );
  }

  List<NegotiationBlock> _deduplicateBlocks(List<NegotiationBlock> blocks) {
    final result = <NegotiationBlock>[];
    for (final block in blocks) {
      result.removeWhere(
        (item) =>
            item.subjectId == block.subjectId &&
            item.subjectKind == block.subjectKind &&
            item.teamId == block.teamId,
      );
      result.add(block);
    }
    return result;
  }

  int _compare(
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
            (balance.contracts.hoursPerDay + 1)) +
        hourA;
    final b =
        (((seasonB * balance.calendar.seasonCycleWeeks + weekB) * 7 + dayB) *
            (balance.contracts.hoursPerDay + 1)) +
        hourB;
    return a.compareTo(b);
  }
}

class NegotiationDeadline {
  const NegotiationDeadline({
    required this.seasonYear,
    required this.week,
    required this.day,
    required this.hour,
  });

  final int seasonYear;
  final int week;
  final int day;
  final int hour;
}
