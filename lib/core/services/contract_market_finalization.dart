part of 'contract_market_service.dart';

mixin _ContractMarketFinalization on _ContractMarketShared {
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
        seasonYear: league.currentSeason.year,
        week: league.currentWeek,
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
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
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
}
