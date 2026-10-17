part of 'contract_market_service.dart';

mixin _ContractMarketResolution on _ContractMarketShared {
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
          args: {
            'subjectName': subjectName,
            negotiation.subjectKind == NegotiationSubjectKind.player
                    ? 'playerName'
                    : 'staffName':
                subjectName,
            if (negotiation.subjectKind == NegotiationSubjectKind.staff)
              'staffRole': _findStaffForNegotiation(
                state,
                negotiation,
              )!.role.name,
            'salary': (next.counterOffer ?? next.lastOffer).salary,
            'years': (next.counterOffer ?? next.lastOffer).years,
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
}
