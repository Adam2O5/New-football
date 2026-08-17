import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/enums.dart';

part 'standing.freezed.dart';
part 'standing.g.dart';

@freezed
abstract class Standing with _$Standing {
  const factory Standing({
    required String teamId,
    @Default(0) int wins,
    @Default(0) int losses,
    @Default(0) int draws,
    @Default(0) int goalsFor,
    @Default(0) int goalsAgainst,
    @Default(0) int conferenceRank,
  }) = _Standing;

  factory Standing.fromJson(Map<String, dynamic> json) =>
      _$StandingFromJson(json);
}

extension StandingX on Standing {
  int get points => wins * 3 + draws;
  int get goalDifference => goalsFor - goalsAgainst;
  int get gamesPlayed => wins + losses + draws;

  Standing applyResult({required int goalsFor, required int goalsAgainst}) {
    if (goalsFor > goalsAgainst) {
      return copyWith(
        wins: wins + 1,
        goalsFor: this.goalsFor + goalsFor,
        goalsAgainst: this.goalsAgainst + goalsAgainst,
      );
    }
    if (goalsFor < goalsAgainst) {
      return copyWith(
        losses: losses + 1,
        goalsFor: this.goalsFor + goalsFor,
        goalsAgainst: this.goalsAgainst + goalsAgainst,
      );
    }
    return copyWith(
      draws: draws + 1,
      goalsFor: this.goalsFor + goalsFor,
      goalsAgainst: this.goalsAgainst + goalsAgainst,
    );
  }
}

@freezed
abstract class ConferenceStandings with _$ConferenceStandings {
  const factory ConferenceStandings({
    required Conference conference,
    @Default([]) List<Standing> standings,
  }) = _ConferenceStandings;

  factory ConferenceStandings.fromJson(Map<String, dynamic> json) =>
      _$ConferenceStandingsFromJson(json);
}

extension ConferenceStandingsX on ConferenceStandings {
  List<Standing> get sorted {
    final copy = List<Standing>.from(standings);
    copy.sort((a, b) {
      final pts = b.points.compareTo(a.points);
      if (pts != 0) return pts;
      return b.goalDifference.compareTo(a.goalDifference);
    });
    return copy
        .asMap()
        .entries
        .map((e) => e.value.copyWith(conferenceRank: e.key + 1))
        .toList();
  }

  Standing? forTeam(String teamId) {
    try {
      return standings.firstWhere((s) => s.teamId == teamId);
    } catch (_) {
      return null;
    }
  }
}
