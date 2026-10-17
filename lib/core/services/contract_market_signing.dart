part of 'contract_market_service.dart';

mixin _ContractMarketSigning on _ContractMarketShared {
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
          seasonYear: league.currentSeason.year,
          week: league.currentWeek,
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

  @override
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
}
