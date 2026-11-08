import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/simulation/effective_attributes.dart';
import 'package:new_football/core/simulation/team_shape.dart';
import 'package:new_football/core/simulation/unit_ratings.dart';

/// Mutable on-pitch state, frozen pre-match context and per-player accounting.
/// The simulation engine owns progression and the result assembler owns stats.
class LiveMatchState {
  LiveMatchState({
    required this.state,
    required this.homeTeamId,
    required this.awayTeamId,
    List<Player>? startingHomeLineup,
    List<Player>? startingAwayLineup,
    this.balance = BalanceConfig.defaults,
    List<MatchEvent>? events,
    List<MatchInjury>? injuries,
    List<MatchDiscipline>? disciplines,
    this.homeSubsUsed = 0,
    this.awaySubsUsed = 0,
    this.homeSubWindows = 0,
    this.awaySubWindows = 0,
    double? homeChemistry,
    double? awayChemistry,
    int? homeAtmosphere,
    int? awayAtmosphere,
    this.homeDoctorCareMult = 1.0,
    this.awayDoctorCareMult = 1.0,
    this.administrativeResult,
    this.homeSnapshot,
    this.awaySnapshot,
    this.homeNoGkPenalty = false,
    this.awayNoGkPenalty = false,
    this.homeHeadCoach,
    this.awayHeadCoach,
    this.homeTeamShape,
    this.awayTeamShape,
    this.homeUnitRatings,
    this.awayUnitRatings,
    Map<String, EffectivePlayerAttributes>? homeEffectiveAttributes,
    Map<String, EffectivePlayerAttributes>? awayEffectiveAttributes,
  }) : homeChemistry =
           homeChemistry ?? balance.matchday.runtimeFallbackChemistry,
       awayChemistry =
           awayChemistry ?? balance.matchday.runtimeFallbackChemistry,
       homeAtmosphere =
           homeAtmosphere ?? balance.matchday.runtimeFallbackAtmosphere,
       awayAtmosphere =
           awayAtmosphere ?? balance.matchday.runtimeFallbackAtmosphere,
       homeEffectiveAttributes = homeEffectiveAttributes ?? const {},
       awayEffectiveAttributes = awayEffectiveAttributes ?? const {},
       homeStartingLineup = List.unmodifiable(
         startingHomeLineup ?? state.homeLineup,
       ),
       awayStartingLineup = List.unmodifiable(
         startingAwayLineup ?? state.awayLineup,
       ),
       events = events ?? [],
       injuries = injuries ?? [],
       disciplines = disciplines ?? [],
       playersById = _playersFromState(state),
       teamByPlayerId = _teamsFromState(state, homeTeamId, awayTeamId),
       minutesPlayed = {
         for (final player in _playersFromState(state).values) player.id: 0,
       },
       staminaRemaining = {
         for (final player in _playersFromState(state).values)
           player.id: player.state.stamina.toDouble(),
       };

  MatchState state;
  final String homeTeamId;
  final String awayTeamId;
  final List<Player> homeStartingLineup;
  final List<Player> awayStartingLineup;
  final BalanceConfig balance;
  final List<MatchEvent> events;
  final List<MatchInjury> injuries;
  final List<MatchDiscipline> disciplines;
  final Map<String, Player> playersById;
  final Map<String, String> teamByPlayerId;
  final Map<String, int> minutesPlayed;
  final Map<String, double> staminaRemaining;
  int homeSubsUsed;
  int awaySubsUsed;
  int homeSubWindows;
  int awaySubWindows;

  /// Team zgranie (0–100) from Team.chemistry, frozen at start.
  final double homeChemistry;
  final double awayChemistry;
  final int homeAtmosphere;
  final int awayAtmosphere;
  final double homeDoctorCareMult;
  final double awayDoctorCareMult;
  final MatchResult? administrativeResult;
  final MatchTeamSnapshot? homeSnapshot;
  final MatchTeamSnapshot? awaySnapshot;
  bool homeNoGkPenalty;
  bool awayNoGkPenalty;
  final StaffMember? homeHeadCoach;
  final StaffMember? awayHeadCoach;

  /// Latest runtime Task 16 diagnostics. These values are derived and are not
  /// serialized into MatchState or MatchResult.
  TeamShape? homeTeamShape;
  TeamShape? awayTeamShape;
  UnitRatings? homeUnitRatings;
  UnitRatings? awayUnitRatings;
  Map<String, EffectivePlayerAttributes> homeEffectiveAttributes;
  Map<String, EffectivePlayerAttributes> awayEffectiveAttributes;

  /// Keeps the goalkeeper penalty aligned after a dismissal or substitution.
  void syncNoGkPenalty() {
    homeNoGkPenalty = !state.homeLineup.any(
      (player) => player.position == Position.gk,
    );
    awayNoGkPenalty = !state.awayLineup.any(
      (player) => player.position == Position.gk,
    );
  }

  /// Advances the currently selected player by one real match minute.
  /// Fractional consumption is kept in [staminaRemaining]. Match calculations
  /// read that map directly, avoiding a full immutable-player copy every tick.
  List<Player> recordMinute({
    required List<Player> lineup,
    required bool homeSide,
    bool applyShortHanded = false,
    double additionalStaminaMultiplier = 1.0,
  }) {
    final tactics = homeSide ? state.homeTactics : state.awayTactics;
    for (final player in lineup) {
      minutesPlayed[player.id] = (minutesPlayed[player.id] ?? 0) + 1;
      final current = staminaRemaining[player.id] ?? player.state.stamina;
      final loss = balance.player.staminaLossForMinutes(
        player.position,
        1,
        tempo: tactics.tempo,
        pressing: tactics.pressing,
        weather: state.context.weather,
        isDerby: state.context.isDerby,
        additionalMultiplier: additionalStaminaMultiplier,
      );
      final shortHandedMultiplier = applyShortHanded
          ? balance.matchday.shortHandedStaminaMultiplier(lineup.length)
          : 1.0;
      staminaRemaining[player.id] = (current - loss * shortHandedMultiplier)
          .clamp(
            balance.player.staminaMin.toDouble(),
            balance.player.staminaMax.toDouble(),
          );
    }
    return lineup;
  }

  int visibleStamina(Player player) => balance.player.clampStamina(
    (staminaRemaining[player.id] ?? player.state.stamina.toDouble()).round(),
  );

  static Map<String, String> _teamsFromState(
    MatchState state,
    String homeTeamId,
    String awayTeamId,
  ) {
    final teams = <String, String>{};
    for (final player in [...state.homeLineup, ...state.homeBench]) {
      teams[player.id] = homeTeamId;
    }
    for (final player in [...state.awayLineup, ...state.awayBench]) {
      teams[player.id] = awayTeamId;
    }
    return teams;
  }

  static Map<String, Player> _playersFromState(MatchState state) {
    final players = <String, Player>{};
    for (final player in [
      ...state.homeLineup,
      ...state.awayLineup,
      ...state.homeBench,
      ...state.awayBench,
    ]) {
      players[player.id] = player;
    }
    return players;
  }
}
