part of 'contract_market_service.dart';

mixin _ContractMarketHelpers on _ContractMarketShared {
  @override
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

  @override
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

  @override
  LeagueState _upsertAiNegotiation(
    LeagueState league, {
    required ContractNegotiation negotiation,
  }) {
    final existing = league.negotiationById(negotiation.id);
    if (existing != null && !existing.isTerminal) return league;
    return league.upsertNegotiation(negotiation);
  }

  @override
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

  @override
  LeagueState _removeFreshUndrafted(LeagueState league, String playerId) =>
      league.copyWith(
        freshUndraftedPlayers: league.freshUndraftedPlayers
            .where((record) => record.playerId != playerId)
            .toList(),
      );

  /// An hourly free-agency day looks players up dozens of times per team, and
  /// a linear lookup walks every roster before reaching the free agents.
  ///
  /// The index is a function of exactly three immutable lists, so it stays
  /// valid while all three keep their identity — which is the case across the
  /// many states an hour produces by touching only negotiations and the inbox.
  @override
  Player? _findPlayer(LeagueState league, String playerId) {
    if (!identical(_indexedTeams, league.teams) ||
        !identical(_indexedFreeAgents, league.freeAgents) ||
        !identical(_indexedDraftedRights, league.draftedRights)) {
      // putIfAbsent, not assignment: the first roster to hold an id wins, as
      // it did when this walked the rosters in order.
      final index = <String, Player>{};
      for (final team in league.teams) {
        for (final player in team.roster) {
          index.putIfAbsent(player.id, () => player);
        }
      }
      for (final player in league.freeAgents) {
        index.putIfAbsent(player.id, () => player);
      }
      for (final right in league.draftedRights) {
        index.putIfAbsent(right.player.id, () => right.player);
      }
      _playerIndex = index;
      _indexedTeams = league.teams;
      _indexedFreeAgents = league.freeAgents;
      _indexedDraftedRights = league.draftedRights;
    }
    return _playerIndex[playerId];
  }

  /// Returns a member only when its declared role matches the occupied slot.
  /// A typed [TeamStaff] can still contain legacy/mismatched slot data, and a
  /// negotiation must never migrate that record into another role.
  @override
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
  @override
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

  @override
  String _aiId(
    String kind,
    String subjectId,
    String teamId,
    LeagueState league,
    NegotiationPhase phase,
    int hour,
  ) =>
      'ai:$kind:$subjectId:$teamId:${league.currentSeason.year}:${league.currentWeek}:${league.currentDay}:${phase.name}:$hour';

  @override
  int _seed(
    int saveSeed,
    LeagueState league,
    String teamId,
    String subjectId,
    String purpose,
  ) => _stableSeed(
    '$saveSeed:${league.currentSeason.year}:${league.currentWeek}:${league.currentDay}:${league.currentHour ?? 0}:$teamId:$subjectId:$purpose',
  );

  @override
  int _stableSeed(String value) {
    var result = 0x45d9f3b;
    for (final code in value.codeUnits) {
      result = ((result * 33) ^ code) & 0x7fffffff;
    }
    return result == 0 ? 1 : result;
  }

  @override
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
            (balance.contracts.hoursPerDay + 1)) +
        hourA;
    final b =
        (((seasonB * balance.calendar.seasonCycleWeeks + weekB) * 7 + dayB) *
            (balance.contracts.hoursPerDay + 1)) +
        hourB;
    return a.compareTo(b);
  }
}
