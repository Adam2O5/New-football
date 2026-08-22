import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/simulation/match_bootstrap.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';
import 'package:new_football/core/services/day_simulator.dart';

void main() {
  final balance = BalanceConfig.defaults.player;

  test('performance and injury multipliers follow every documented band', () {
    expect(balance.performanceMult(100), 1.00);
    expect(balance.performanceMult(80), 1.00);
    expect(balance.performanceMult(79), 0.97);
    expect(balance.performanceMult(60), 0.97);
    expect(balance.performanceMult(59), 0.90);
    expect(balance.performanceMult(40), 0.90);
    expect(balance.performanceMult(39), 0.75);
    expect(balance.performanceMult(20), 0.75);
    expect(balance.performanceMult(19), 0.50);
    expect(balance.performanceMult(0), 0.50);

    expect(balance.injuryRiskMult(100), 0.90);
    expect(balance.injuryRiskMult(80), 0.90);
    expect(balance.injuryRiskMult(79), 1.00);
    expect(balance.injuryRiskMult(60), 1.00);
    expect(balance.injuryRiskMult(59), 1.20);
    expect(balance.injuryRiskMult(40), 1.20);
    expect(balance.injuryRiskMult(39), 1.40);
    expect(balance.injuryRiskMult(20), 1.40);
    expect(balance.injuryRiskMult(19), 1.67);
    expect(balance.injuryRiskMult(0), 1.67);
  });

  test('form multiplier table and effective contribution are exact', () {
    const expected = [
      0.90,
      0.92,
      0.95,
      0.97,
      0.99,
      1.00,
      1.04,
      1.07,
      1.09,
      1.12,
    ];
    for (var i = 0; i < expected.length; i++) {
      expect(balance.formMult((i + 1).toDouble()), expected[i]);
    }

    // 85 OVR × form 2 × stamina 30 = 85 × .92 × .75 = 58.65.
    final effective = 85 * balance.formMult(2) * balance.performanceMult(30);
    expect(effective, closeTo(58.65, 0.001));
  });

  test('positional stamina loss and all match modifiers are applied', () {
    expect(balance.staminaLossForMinutes(Position.gk, 90), 15);
    expect(balance.staminaLossForMinutes(Position.cb, 90), 65);
    expect(balance.staminaLossForMinutes(Position.lb, 90), 75);
    expect(balance.staminaLossForMinutes(Position.rb, 90), 75);
    expect(balance.staminaLossForMinutes(Position.lwb, 90), 85);
    expect(balance.staminaLossForMinutes(Position.rwb, 90), 85);
    expect(balance.staminaLossForMinutes(Position.cdm, 90), 70);
    expect(balance.staminaLossForMinutes(Position.cm, 90), 70);
    expect(balance.staminaLossForMinutes(Position.cam, 90), 70);
    expect(balance.staminaLossForMinutes(Position.lw, 90), 80);
    expect(balance.staminaLossForMinutes(Position.rw, 90), 80);
    expect(balance.staminaLossForMinutes(Position.st, 90), 70);
    expect(balance.staminaLossForMinutes(Position.lwb, 45), 42.5);

    final modified = balance.staminaLossForMinutes(
      Position.lwb,
      90,
      tempo: Tempo.fast,
      pressing: PressingIntensity.gegenpressing,
      weather: Weather.heat,
      isDerby: true,
    );
    expect(modified, closeTo(85 * 1.15 * 1.20 * 1.15 * 1.05, 0.0001));
    expect(
      balance.staminaLossForMinutes(
        Position.gk,
        90,
        tempo: Tempo.slow,
        pressing: PressingIntensity.low,
      ),
      closeTo(15 * 0.90 * 0.90, 0.0001),
    );
  });

  test(
    'form changes use rating bands, temperamental losses and no-appearance drift',
    () {
      final league = SeedDataGenerator(
        random: null,
      ).generateLeague(year: 2026, seed: 12);
      final source = league.teams.first.roster.first;

      Player withForm(
        double form, {
        PlayerPersonality personality = PlayerPersonality.balanced,
      }) => source.copyWith(
        personality: personality,
        state: source.state.copyWith(form: form),
      );

      expect(
        withForm(
          5,
        ).withMatchForm(minutesPlayed: 90, rating: 8.5, lost: false).state.form,
        7,
      );
      expect(
        withForm(
          5,
        ).withMatchForm(minutesPlayed: 90, rating: 7.5, lost: false).state.form,
        6,
      );
      expect(
        withForm(
          5,
        ).withMatchForm(minutesPlayed: 90, rating: 6.0, lost: false).state.form,
        5,
      );
      expect(
        withForm(
          5,
        ).withMatchForm(minutesPlayed: 90, rating: 5.0, lost: false).state.form,
        4,
      );
      expect(
        withForm(
          5,
        ).withMatchForm(minutesPlayed: 90, rating: 4.4, lost: false).state.form,
        3,
      );
      expect(
        withForm(
          5,
          personality: PlayerPersonality.temperamental,
        ).withMatchForm(minutesPlayed: 90, rating: 5.0, lost: true).state.form,
        3.5,
      );
      expect(
        withForm(
          5,
        ).withMatchForm(minutesPlayed: 0, rating: 0, lost: true).state.form,
        5.2,
      );
      expect(
        withForm(
          7,
        ).withMatchForm(minutesPlayed: 0, rating: 0, lost: true).state.form,
        6.8,
      );
      expect(
        withForm(
          1,
        ).withMatchForm(minutesPlayed: 0, rating: 0, lost: true).state.form,
        1.2,
      );
      expect(
        withForm(
          10,
        ).withMatchForm(minutesPlayed: 0, rating: 0, lost: true).state.form,
        9.8,
      );
    },
  );

  test(
    'LiveMatch reports actual minutes, including a 45-minute substitution',
    () {
      final league = SeedDataGenerator(
        random: null,
      ).generateLeague(year: 2026, seed: 13);
      final home = league.teams.first;
      final away = league.teams[1];
      final engine = const MatchEngine();
      final live = engine.start(home: home, away: away, rngSeed: 13);
      final outgoing = live.state.homeLineup.first;
      final incoming = live.state.homeBench.first;

      for (var i = 0; i < 45; i++) {
        live.state = live.state.copyWith(
          minute: live.state.minute + 1,
          homeLineup: live.recordMinute(
            lineup: live.state.homeLineup,
            homeSide: true,
          ),
        );
      }
      expect(
        engine.applySubstitution(
          live: live,
          homeSide: true,
          playerOutId: outgoing.id,
          playerInId: incoming.id,
        ),
        isTrue,
      );
      for (var i = 0; i < 45; i++) {
        live.state = live.state.copyWith(
          minute: live.state.minute + 1,
          homeLineup: live.recordMinute(
            lineup: live.state.homeLineup,
            homeSide: true,
          ),
        );
      }

      final result = live.toResult();
      final outgoingStats = result.playerStats.firstWhere(
        (s) => s.playerId == outgoing.id,
      );
      final incomingStats = result.playerStats.firstWhere(
        (s) => s.playerId == incoming.id,
      );
      expect(outgoingStats.minutes, 45);
      expect(incomingStats.minutes, 45);
      expect(result.playerStats.any((stats) => stats.minutes == 0), isTrue);
    },
  );

  test(
    'DaySimulator applies proportional loss, post-match recovery and daily recovery',
    () {
      final league = SeedDataGenerator(
        random: null,
      ).generateLeague(year: 2026, seed: 14);
      final home = league.teams.first;
      final away = league.teams[1];
      final match = ScheduledMatch(
        id: 'task12-match',
        homeTeamId: home.id,
        awayTeamId: away.id,
        round: 1,
      );
      final selected = home.roster.first;
      final changedSelected = selected.copyWith(
        position: Position.st,
        state: selected.state.copyWith(stamina: 100),
      );
      final changedHome = home.copyWith(
        roster: home.roster
            .map(
              (player) => player.id == selected.id ? changedSelected : player,
            )
            .toList(),
      );
      final changedLeague = league.copyWith(
        teams: league.teams
            .map<Team>((team) => team.id == changedHome.id ? changedHome : team)
            .toList(),
        currentSeason: league.currentSeason.copyWith(schedule: [match]),
      );
      final result = MatchResult(
        homeTeamId: match.homeTeamId,
        awayTeamId: match.awayTeamId,
        homeGoals: 0,
        awayGoals: 1,
        homeStats: TeamMatchStats(teamId: match.homeTeamId),
        awayStats: TeamMatchStats(teamId: match.awayTeamId),
        playerStats: [
          PlayerMatchStats(playerId: selected.id, minutes: 90, rating: 6.0),
        ],
      );

      final afterOne = DaySimulator().applyPlayerMatchResult(
        changedLeague,
        match,
        result,
      );
      final afterOnePlayer = afterOne
          .teamById(home.id)!
          .roster
          .firstWhere((player) => player.id == selected.id);
      // ST/CM/etc. loss is 70–80 per full match; +20 immediate +20 daily.
      expect(afterOnePlayer.state.stamina, lessThan(90));

      final secondMatch = afterOne.currentSeason.schedule.first;
      final afterTwo = DaySimulator().applyPlayerMatchResult(
        afterOne,
        secondMatch,
        result,
      );
      final afterTwoPlayer = afterTwo
          .teamById(home.id)!
          .roster
          .firstWhere((player) => player.id == selected.id);
      expect(
        afterTwoPlayer.state.stamina,
        lessThan(afterOnePlayer.state.stamina),
      );
    },
  );

  test('fractional form and match context survive JSON serialization', () {
    final league = SeedDataGenerator(
      random: null,
    ).generateLeague(year: 2026, seed: 15);
    final player = league.teams.first.roster.first.copyWith(
      state: league.teams.first.roster.first.state.copyWith(form: 5.2),
    );
    final playerJson =
        jsonDecode(jsonEncode(player.toJson())) as Map<String, dynamic>;
    expect(Player.fromJson(playerJson).state.form, 5.2);

    final result = MatchResult(
      homeTeamId: 'home',
      awayTeamId: 'away',
      homeGoals: 1,
      awayGoals: 0,
      homeStats: const TeamMatchStats(teamId: 'home'),
      awayStats: const TeamMatchStats(teamId: 'away'),
      context: const MatchContext(isDerby: true, weather: Weather.heat),
      homeTactics: const TacticsSetup(
        tempo: Tempo.fast,
        pressing: PressingIntensity.high,
      ),
    );
    final restored = MatchResult.fromJson(
      jsonDecode(jsonEncode(result.toJson())) as Map<String, dynamic>,
    );
    expect(restored.context.isDerby, isTrue);
    expect(restored.context.weather, Weather.heat);
    expect(restored.homeTactics.tempo, Tempo.fast);
    expect(restored.homeTactics.pressing, PressingIntensity.high);
  });
}
