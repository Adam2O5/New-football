import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/scouting.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

part 'team.freezed.dart';
part 'team.g.dart';

@freezed
class TeamAiConfig with _$TeamAiConfig {
  const factory TeamAiConfig({
    @Default(ManagerProfile.balanced) ManagerProfile managerProfile,
    @Default(0.5) double aggressionLevel,
    @Default(0.5) double riskTolerance,
    @Default({}) Map<String, dynamic> playerPatternMemory,
  }) = _TeamAiConfig;

  factory TeamAiConfig.fromJson(Map<String, dynamic> json) =>
      _$TeamAiConfigFromJson(json);
}

@freezed
class Team with _$Team {
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
    @Default(50) int chemistry,
    @Default(TeamStaff()) TeamStaff staff,
    @Default(TeamScouting()) TeamScouting scouting,
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
    if (lineupPlayerIds.length >= 11) {
      return lineupPlayerIds
          .map((id) => roster.firstWhere((p) => p.id == id))
          .take(11)
          .toList();
    }
    return availablePlayers.take(11).toList();
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
    final pool = (onPitch ?? startingEleven)
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
