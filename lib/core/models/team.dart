import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_event_state.dart';
import 'package:new_football/core/models/scouting.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

part 'team.freezed.dart';
part 'team.g.dart';

@freezed
abstract class TeamAiConfig with _$TeamAiConfig {
  const factory TeamAiConfig({
    @Default(0.5) double aggressionLevel,
    @Default(0.5) double riskTolerance,
    @Default({}) Map<String, dynamic> playerPatternMemory,
  }) = _TeamAiConfig;

  factory TeamAiConfig.fromJson(Map<String, dynamic> json) =>
      _$TeamAiConfigFromJson(json);
}

@freezed
abstract class TeamWeeklyHistory with _$TeamWeeklyHistory {
  const factory TeamWeeklyHistory({
    required int seasonYear,
    required int week,
    @Default(0) int atmosphereDelta,
    @Default(0.0) double chemistryDelta,
    required int atmosphere,
    required double chemistry,
    @Default(0) int wins,
    @Default(0) int draws,
    @Default(0) int losses,
  }) = _TeamWeeklyHistory;

  factory TeamWeeklyHistory.fromJson(Map<String, dynamic> json) =>
      _$TeamWeeklyHistoryFromJson(json);
}

@freezed
abstract class Team with _$Team {
  const factory Team({
    required String id,
    required String name,
    required String city,
    required Conference conference,
    required List<Player> roster,
    required TeamFinance finance,
    @Default(TacticsSetup()) TacticsSetup tactics,
    @Default([]) List<String> lineupPlayerIds,
    @Default([]) List<String> benchPlayerIds,
    @Default(50) int atmosphere,
    @Default(50.0) double chemistry,
    @Default([]) List<TeamWeeklyHistory> weeklyHistory,
    @Default([]) List<int> recentMatchResults,
    @Default({}) Map<String, int> chemistryAppearances,
    @Default(TeamStaff()) TeamStaff staff,
    @Default(TeamScouting()) TeamScouting scouting,

    /// Picki draftowe (własne i nabyte) — bieżący rocznik oraz przyszłe,
    /// handlowalne (`docs/trade_rules.md`, `DraftPick`).
    @Default([]) List<DraftPick> ownedPicks,

    /// `null` = drużyna gracza; ustawione = drużyna AI.
    TeamAiConfig? ai,
  }) = _Team;

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
}

extension TeamX on Team {
  bool get isPlayerControlled => ai == null;

  List<Player> get availablePlayers =>
      roster.where((p) => p.isAvailable).toList();

  List<Player> get startingEleven {
    final candidates = availablePlayers
        .where((player) => player.isEligibleForStartingEleven)
        .toList();
    final byId = {for (final player in candidates) player.id: player};
    final selected = <Player>[];

    for (final id in lineupPlayerIds) {
      final player = byId[id];
      if (player == null) continue;
      selected.add(player);
      if (selected.length >= 11) break;
    }

    // A motivational event can require a player in the next XI even when the
    // saved lineup was not updated by the UI. Insert the required player and,
    // when necessary, replace the last non-required starter.
    final required = candidates
        .where(
          (player) =>
              player.state.eventState.hasModifier('startingElevenRequired'),
        )
        .toList();
    for (final player in required) {
      if (selected.any((item) => item.id == player.id)) continue;
      if (selected.length < 11) {
        selected.add(player);
        continue;
      }
      final replaceIndex = selected.lastIndexWhere(
        (item) => !item.state.eventState.hasModifier('startingElevenRequired'),
      );
      if (replaceIndex >= 0) selected[replaceIndex] = player;
    }

    for (final player in candidates) {
      if (selected.length >= 11) break;
      if (!selected.any((item) => item.id == player.id)) selected.add(player);
    }
    return selected;
  }

  double get teamStrength {
    final starters = startingEleven;
    if (starters.isEmpty) return 50;
    return starters.map((p) => p.overall()).reduce((a, b) => a + b) /
        starters.length;
  }

  /// Mean height (cm) of the [sampleSize] tallest outfield players on the pitch.
  ///
  /// Defaults to current XI; pass [onPitch] for live match lineup after subs.
  double averageTallestOutfieldHeightCm({
    List<Player>? onPitch,
    BalanceConfig balance = BalanceConfig.defaults,
  }) {
    final sampleSize = balance.player.tallestOutfieldSampleSize;
    final pool =
        (onPitch ?? startingEleven)
            .where((p) => p.position != Position.gk)
            .toList()
          ..sort((a, b) => b.heightCm.compareTo(a.heightCm));
    if (pool.isEmpty) return 0;
    final top = pool.take(sampleSize);
    return top.map((p) => p.heightCm).reduce((a, b) => a + b) / top.length;
  }

  Team updatePayroll() {
    final payroll = roster.fold<int>(0, (sum, p) => sum + p.contract.salary);
    return copyWith(finance: finance.copyWith(totalPayroll: payroll));
  }
}
