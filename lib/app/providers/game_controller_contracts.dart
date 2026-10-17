part of 'game_provider.dart';

mixin _GameControllerContracts {
  ContractMarketService get _market;

  Future<T> _mutateSave<T>(
    T unavailable,
    Future<T> Function(GameSave current) operation,
  );

  Future<void> _publishLeagueInQueue(
    LeagueState Function(LeagueState) transform,
  );

  StaffService get _staff;

  /// Submits a free-agent offer through the central contract-market
  /// resolver. Accept remains pending until explicit finalization.
  Future<ContractReaction> offerFreeAgent(
    String freeAgentId,
    ContractOffer offer,
  ) {
    return _mutateSave<ContractReaction>(ContractReaction.hardReject, (
      current,
    ) async {
      final submission = _market.submitPlayerOffer(
        league: current.leagueState,
        playerId: freeAgentId,
        offer: offer,
        saveSeed: current.saveSeed,
      );
      if (submission == null) return ContractReaction.hardReject;
      await _publishLeagueInQueue((_) => submission.league);
      return submission.reaction;
    });
  }

  /// Submits a player extension through the central contract-market
  /// resolver. The accepted offer remains pending until finalization.
  Future<ContractReaction> offerContractExtension(
    String playerId,
    ContractOffer offer,
  ) {
    return _mutateSave<ContractReaction>(ContractReaction.hardReject, (
      current,
    ) async {
      final submission = _market.submitPlayerOffer(
        league: current.leagueState,
        playerId: playerId,
        offer: offer,
        saveSeed: current.saveSeed,
      );
      if (submission == null) return ContractReaction.hardReject;
      await _publishLeagueInQueue((_) => submission.league);
      return submission.reaction;
    });
  }

  Future<bool> finalizeContractNegotiation(String negotiationId) {
    return _mutateSave<bool>(false, (current) async {
      final next = _market.finalizeNegotiation(
        current.leagueState,
        negotiationId,
        saveSeed: current.saveSeed,
      );
      if (next == null) return false;
      await _publishLeagueInQueue((_) => next);
      return true;
    });
  }

  Future<bool> respondToContractCounter(
    String negotiationId, {
    required bool accept,
    ContractOffer? offer,
  }) {
    return _mutateSave<bool>(false, (current) async {
      final next = _market.resolveCounterResponse(
        current.leagueState,
        negotiationId,
        accept: accept,
        playerOffer: offer,
        saveSeed: current.saveSeed,
      );
      if (next == null) return false;
      await _publishLeagueInQueue((_) => next);
      return true;
    });
  }

  Future<bool> respondToStaffCounter(
    String negotiationId, {
    required bool accept,
    StaffOffer? offer,
  }) {
    return _mutateSave<bool>(false, (current) async {
      final next = _market.resolveCounterResponse(
        current.leagueState,
        negotiationId,
        accept: accept,
        staffOffer: offer,
        saveSeed: current.saveSeed,
      );
      if (next == null) return false;
      await _publishLeagueInQueue((_) => next);
      return true;
    });
  }

  Future<bool> submitQualifyingOffer(
    String playerId, {
    int? salary,
    int years = 1,
  }) {
    return _mutateSave<bool>(false, (current) async {
      final teamId = current.leagueState.playerTeamId;
      if (teamId == null) return false;
      final next = _market.submitQualifyingOffer(
        league: current.leagueState,
        ownerTeamId: teamId,
        playerId: playerId,
        salary: salary,
        years: years,
      );
      if (next == null) return false;
      await _publishLeagueInQueue((_) => next);
      return true;
    });
  }

  Future<bool> declineQualifyingOffer(String playerId) {
    return _mutateSave<bool>(false, (current) async {
      if (current.leagueState.playerTeamId == null) {
        return false;
      }
      await _publishLeagueInQueue(
        (league) => _market.declineQualifyingOffer(league, playerId),
      );
      return true;
    });
  }

  Future<bool> submitRfaOfferSheet(String playerId, ContractOffer offer) {
    return _mutateSave<bool>(false, (current) async {
      final teamId = current.leagueState.playerTeamId;
      if (teamId == null) return false;
      final next = _market.submitOfferSheet(
        league: current.leagueState,
        offeringTeamId: teamId,
        playerId: playerId,
        offer: offer,
        saveSeed: current.saveSeed,
      );
      if (next == null) return false;
      await _publishLeagueInQueue((_) => next);
      return true;
    });
  }

  Future<bool> matchRfaOfferSheet(String sheetId) {
    return _mutateSave<bool>(false, (current) async {
      final next = _market.matchOfferSheet(
        current.leagueState,
        sheetId,
        saveSeed: current.saveSeed,
      );
      if (next == null) return false;
      await _publishLeagueInQueue((_) => next);
      return true;
    });
  }

  Future<bool> declineRfaOfferSheet(String sheetId) {
    return _mutateSave<bool>(false, (current) async {
      await _publishLeagueInQueue(
        (league) => _market.declineOfferSheet(league, sheetId),
      );
      return true;
    });
  }

  Future<bool> signDraftedRight(String rightId) {
    return _mutateSave<bool>(false, (current) async {
      final next = _market.signDraftedRight(
        current.leagueState,
        rightId,
        saveSeed: current.saveSeed,
      );
      if (next == null) return false;
      await _publishLeagueInQueue((_) => next);
      return true;
    });
  }

  /// Submits a staff offer through the central contract-market resolver.
  Future<StaffReaction> offerStaff(StaffMember candidate, StaffOffer offer) {
    return _mutateSave<StaffReaction>(StaffReaction.hardReject, (
      current,
    ) async {
      final submission = _market.submitStaffOffer(
        league: current.leagueState,
        candidate: candidate,
        offer: offer,
        saveSeed: current.saveSeed,
      );
      if (submission == null) return StaffReaction.hardReject;
      await _publishLeagueInQueue((_) => submission.league);
      return submission.reaction;
    });
  }

  /// Compatibility wrapper for callers that only need to know whether the
  /// offer reached Accept. It no longer hires immediately; the returned true
  /// means a pending finalization record was created.
  Future<bool> hireStaff(StaffMember candidate, StaffOffer offer) async {
    final reaction = await offerStaff(candidate, offer);
    return reaction == StaffReaction.accept;
  }

  Future<bool> fireStaff(StaffRole role) {
    return _mutateSave<bool>(false, (current) async {
      final team = current.leagueState.playerTeam;
      if (team == null) return false;
      final updatedTeam = _staff.fire(team, role);
      if (updatedTeam == team) return false;
      await _publishLeagueInQueue((league) => league.updateTeam(updatedTeam));
      return true;
    });
  }
}
