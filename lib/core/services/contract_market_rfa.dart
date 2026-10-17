part of 'contract_market_service.dart';

mixin _ContractMarketRfa on _ContractMarketShared {
  /// Computes the documented RFA floor independently of the cap validator.
  int qualifyingOfferMinimum(Player player) => max(
    balance.salaryCap.qualifyingOfferMin,
    (player.contract.salary * balance.salaryCap.qualifyingOfferMultiplier)
        .ceil(),
  );

  /// Records a QO. No QO record means the expired rookie is an unrestricted FA.
  @override
  LeagueState? submitQualifyingOffer({
    required LeagueState league,
    required String ownerTeamId,
    required String playerId,
    int? salary,
    int years = 1,
  }) {
    final team = league.teamById(ownerTeamId);
    final player = _findPlayer(league, playerId);
    if (team == null ||
        player == null ||
        !player.contract.isRookieScale ||
        !calendar.isContractExtensionWindow(
          league.currentWeek,
          league.currentDay,
        ) ||
        !team.roster.any((p) => p.id == player.id) ||
        player.contract.lastSeason != league.currentSeason.year) {
      return null;
    }
    final amount = salary ?? qualifyingOfferMinimum(player);
    final validation = contracts.validateOffer(
      team: team,
      // QO is a conditional rights proposal, effective after this scale ends.
      player: player.copyWith(
        contract: player.contract.copyWith(yearsRemaining: 0),
      ),
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

  @override
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
      seasonYear: league.currentSeason.year,
      week: league.currentWeek,
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

  @override
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

  @override
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
}
