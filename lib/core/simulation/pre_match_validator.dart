import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';

/// Machine-readable reasons emitted by the pre-match gate.
abstract final class PreMatchReasonCode {
  static const rosterSizeIllegal = 'roster_size_illegal';
  static const bothRostersIllegal = 'both_rosters_illegal';
  static const insufficientAvailablePlayers = 'insufficient_available_players';
  static const invalidStartingXi = 'invalid_starting_xi';
  static const duplicateStartingPlayer = 'duplicate_starting_player';
  static const bothTeamsInvalid = 'both_teams_invalid';
  static const noGoalkeeper = 'no_goalkeeper_in_xi';
  static const incompleteBench = 'incomplete_bench';
}

/// Immutable inspection of one team's matchday eligibility.
class PreMatchTeamReport {
  const PreMatchTeamReport({
    required this.teamId,
    required this.rosterSize,
    required this.rosterSizeLegal,
    required this.availablePlayers,
    required this.startingXi,
    required this.bench,
    required this.hasDuplicateStartingPlayer,
    required this.invalidStartingXi,
    required this.hasGoalkeeper,
    required this.benchWasTrimmed,
    required this.reasonCode,
    required this.benchTarget,
  });

  final String teamId;
  final int rosterSize;
  final bool rosterSizeLegal;
  final List<Player> availablePlayers;
  final List<Player> startingXi;
  final List<Player> bench;
  final bool hasDuplicateStartingPlayer;
  final bool invalidStartingXi;
  final bool hasGoalkeeper;
  final bool benchWasTrimmed;
  final String? reasonCode;
  final int benchTarget;

  int get availablePlayerCount => availablePlayers.length;
  int get startingXiCount => startingXi.length;
  int get benchCount => bench.length;
  bool get isBenchIncomplete => bench.length < benchTarget;
  bool get isRosterLegal => rosterSizeLegal;
  bool get hasEnoughAvailablePlayers =>
      availablePlayerCount >= startingXi.length;
  bool get isHardViolation => !rosterSizeLegal || invalidStartingXi;
  int get missingBenchCount =>
      (benchTarget - bench.length).clamp(0, benchTarget);
}

/// Result of the complete pre-match validation, including playable warnings.
class PreMatchReport {
  const PreMatchReport({
    required this.home,
    required this.away,
    required this.status,
    required this.reasonCode,
    required this.violatingTeamIds,
    required this.noGkPenaltyTeamIds,
    required this.incompleteBenchTeamIds,
  });

  final PreMatchTeamReport home;
  final PreMatchTeamReport away;
  final MatchStatus status;
  final String? reasonCode;
  final List<String> violatingTeamIds;
  final List<String> noGkPenaltyTeamIds;
  final List<String> incompleteBenchTeamIds;

  PreMatchTeamReport get homeTeam => home;
  PreMatchTeamReport get awayTeam => away;
  bool get isPlayable => status == MatchStatus.played;
  bool get isAdministrative => !isPlayable;
  bool get isWalkover => status == MatchStatus.walkover;
  bool get noGkPenalty => noGkPenaltyTeamIds.isNotEmpty;
  bool get hasIncompleteBench => incompleteBenchTeamIds.isNotEmpty;
}

/// Validates the matchday roster before the engine is allowed to simulate a
/// minute. The validator is public so UI/orchestration can show warnings
/// before calling [MatchEngine].
class PreMatchValidator {
  const PreMatchValidator({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  PreMatchReport validate({required Team home, required Team away}) {
    final homeReport = inspect(home);
    final awayReport = inspect(away);

    // Roster size is the first gate and takes precedence over all later
    // checks, exactly as documented in squad_management.md.
    final rosterViolators = [
      if (!homeReport.rosterSizeLegal) home.id,
      if (!awayReport.rosterSizeLegal) away.id,
    ];
    if (rosterViolators.length == 2) {
      return PreMatchReport(
        home: homeReport,
        away: awayReport,
        status: MatchStatus.dsq,
        reasonCode: PreMatchReasonCode.bothRostersIllegal,
        violatingTeamIds: rosterViolators,
        noGkPenaltyTeamIds: const [],
        incompleteBenchTeamIds: const [],
      );
    }
    if (rosterViolators.length == 1) {
      return PreMatchReport(
        home: homeReport,
        away: awayReport,
        status: MatchStatus.walkover,
        reasonCode: PreMatchReasonCode.rosterSizeIllegal,
        violatingTeamIds: rosterViolators,
        noGkPenaltyTeamIds: const [],
        incompleteBenchTeamIds: const [],
      );
    }

    // A legal roster still forfeits when it cannot provide a valid XI.
    final xiViolators = [
      if (homeReport.invalidStartingXi) home.id,
      if (awayReport.invalidStartingXi) away.id,
    ];
    if (xiViolators.length == 2) {
      return PreMatchReport(
        home: homeReport,
        away: awayReport,
        status: MatchStatus.dsq,
        reasonCode: _bothInvalidReason(homeReport, awayReport),
        violatingTeamIds: xiViolators,
        noGkPenaltyTeamIds: const [],
        incompleteBenchTeamIds: const [],
      );
    }
    if (xiViolators.length == 1) {
      final report = xiViolators.first == home.id ? homeReport : awayReport;
      return PreMatchReport(
        home: homeReport,
        away: awayReport,
        status: MatchStatus.walkover,
        reasonCode: report.reasonCode ?? PreMatchReasonCode.invalidStartingXi,
        violatingTeamIds: xiViolators,
        noGkPenaltyTeamIds: const [],
        incompleteBenchTeamIds: const [],
      );
    }

    final noGkTeamIds = [
      if (!homeReport.hasGoalkeeper) home.id,
      if (!awayReport.hasGoalkeeper) away.id,
    ];
    final incompleteBenchTeamIds = [
      if (homeReport.isBenchIncomplete) home.id,
      if (awayReport.isBenchIncomplete) away.id,
    ];

    return PreMatchReport(
      home: homeReport,
      away: awayReport,
      status: MatchStatus.played,
      reasonCode: noGkTeamIds.isNotEmpty
          ? PreMatchReasonCode.noGoalkeeper
          : incompleteBenchTeamIds.isNotEmpty
          ? PreMatchReasonCode.incompleteBench
          : null,
      violatingTeamIds: const [],
      noGkPenaltyTeamIds: noGkTeamIds,
      incompleteBenchTeamIds: incompleteBenchTeamIds,
    );
  }

  PreMatchTeamReport inspect(Team team) {
    final availablePlayers = team.availablePlayers;
    final availableIds = availablePlayers.map((player) => player.id).toSet();
    final startingXi = List<Player>.unmodifiable(team.startingEleven);
    final startingIds = <String>{};
    var hasDuplicateStartingPlayer = false;
    for (final player in startingXi) {
      if (!startingIds.add(player.id)) hasDuplicateStartingPlayer = true;
    }

    final invalidStartingXi =
        startingXi.length != balance.roster.startingXi ||
        hasDuplicateStartingPlayer ||
        startingXi.any((player) => !availableIds.contains(player.id));

    final startingIdSet = startingXi.map((player) => player.id).toSet();
    final benchCandidates = <Player>[];
    final seenBenchIds = <String>{};
    if (team.benchPlayerIds.isNotEmpty) {
      for (final playerId in team.benchPlayerIds) {
        if (!seenBenchIds.add(playerId) || startingIdSet.contains(playerId)) {
          continue;
        }
        final player = availablePlayers.where((p) => p.id == playerId);
        if (player.isNotEmpty) benchCandidates.add(player.first);
      }
    } else {
      benchCandidates.addAll(
        availablePlayers.where((player) => !startingIdSet.contains(player.id)),
      );
    }

    final benchWasTrimmed = benchCandidates.length > balance.roster.benchSize;
    final bench = List<Player>.unmodifiable(
      benchCandidates.take(balance.roster.benchSize),
    );
    final reasonCode = !teamRosterSizeLegal(team)
        ? PreMatchReasonCode.rosterSizeIllegal
        : availablePlayers.length < balance.roster.startingXi
        ? PreMatchReasonCode.insufficientAvailablePlayers
        : hasDuplicateStartingPlayer
        ? PreMatchReasonCode.duplicateStartingPlayer
        : startingXi.length != balance.roster.startingXi
        ? PreMatchReasonCode.invalidStartingXi
        : null;

    return PreMatchTeamReport(
      teamId: team.id,
      rosterSize: team.roster.length,
      rosterSizeLegal: teamRosterSizeLegal(team),
      availablePlayers: List<Player>.unmodifiable(availablePlayers),
      startingXi: startingXi,
      bench: bench,
      hasDuplicateStartingPlayer: hasDuplicateStartingPlayer,
      invalidStartingXi: invalidStartingXi,
      hasGoalkeeper: startingXi.any((player) => player.position == Position.gk),
      benchWasTrimmed: benchWasTrimmed,
      reasonCode: reasonCode,
      benchTarget: balance.roster.benchSize,
    );
  }

  bool teamRosterSizeLegal(Team team) {
    final size = team.roster.length;
    return size >= balance.roster.minSize && size <= balance.roster.maxSize;
  }

  String _bothInvalidReason(PreMatchTeamReport home, PreMatchTeamReport away) {
    if (home.hasDuplicateStartingPlayer || away.hasDuplicateStartingPlayer) {
      return PreMatchReasonCode.duplicateStartingPlayer;
    }
    if (home.reasonCode == PreMatchReasonCode.insufficientAvailablePlayers &&
        away.reasonCode == PreMatchReasonCode.insufficientAvailablePlayers) {
      return PreMatchReasonCode.insufficientAvailablePlayers;
    }
    return PreMatchReasonCode.bothTeamsInvalid;
  }
}
