import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/random/seeds.dart';

/// Immutable, explicit input to the AI evaluator.
///
/// [leagueTeams] is used only for public roster/OVR medians. The evaluator
/// never reads hidden player traits from those teams. [strengthTable] is the
/// canonical source for status and expected rank when future picks are valued.
class AiEvaluationContext {
  const AiEvaluationContext({
    required this.team,
    required this.teamStatus,
    required this.expectedRank,
    this.teamPower = 0.0,
    this.leagueTeams = const [],
    this.strengthTable,
    this.saveSeed = 0,
    this.seasonYear = 0,
    this.week = 1,
    this.decisionType = DecisionType.tradeEval,
  });

  final Team team;
  final TeamStatus teamStatus;
  final int expectedRank;
  final double teamPower;
  final List<Team> leagueTeams;
  final LeagueStrengthTable? strengthTable;
  final int saveSeed;
  final int seasonYear;
  final int week;
  final DecisionType decisionType;

  int expectedRankFor(String teamId) {
    final fromTable = strengthTable?.entryFor(teamId)?.expectedRank;
    if (fromTable != null) return fromTable;
    if (teamId == team.id) return expectedRank;
    return 15;
  }

  AiEvaluationContext withDecision({
    int? saveSeed,
    int? seasonYear,
    int? week,
    DecisionType? decisionType,
  }) => AiEvaluationContext(
    team: team,
    teamStatus: teamStatus,
    expectedRank: expectedRank,
    teamPower: teamPower,
    leagueTeams: leagueTeams,
    strengthTable: strengthTable,
    saveSeed: saveSeed ?? this.saveSeed,
    seasonYear: seasonYear ?? this.seasonYear,
    week: week ?? this.week,
    decisionType: decisionType ?? this.decisionType,
  );
}
