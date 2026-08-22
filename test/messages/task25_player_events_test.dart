import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/field_player_attributes.dart';
import 'package:new_football/core/models/injury.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/models/player_event_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/development_service.dart';
import 'package:new_football/core/services/player_event_service.dart';

void main() {
  final baseLeague = SeedDataGenerator(
    random: null,
  ).generateLeague(year: 2026, seed: 2501);

  EventsBalance eventBalance({
    double breakthroughChance = 0,
    double coldStreakChance = 0,
    double injuryComplicationChance = 0,
    double veteranMotivationChance = 0,
    double extraTrainingChance = 0,
    double personalProblemsChance = 0,
    double professionalPersonalProblemsChance = 0,
    double lateBloomerChance = 0,
    double recurringInjuryChance = 0,
    double personalSupportChance = 0,
  }) => EventsBalance(
    breakthroughChance: breakthroughChance,
    coldStreakChance: coldStreakChance,
    majorInjuryComplicationChance: injuryComplicationChance,
    veteranMotivationChance: veteranMotivationChance,
    extraTrainingChance: extraTrainingChance,
    personalProblemsChance: personalProblemsChance,
    professionalPersonalProblemsChance: professionalPersonalProblemsChance,
    lateBloomerChance: lateBloomerChance,
    recurringInjuryChance: recurringInjuryChance,
    personalSupportChance: personalSupportChance,
  );

  Player fixture({
    String? id,
    int age = 20,
    int determination = 5,
    int injuryProne = 5,
    double progress = 50,
    double form = 6,
    PlayerPersonality personality = PlayerPersonality.balanced,
    int seasonsWithTeam = 0,
    int lastDevelopmentOvrDelta = 1,
    PlayerEventState eventState = const PlayerEventState(),
  }) {
    final source = baseLeague.teams.first.roster.firstWhere(
      (player) => player.position != Position.gk,
    );
    return source.copyWith(
      id: id ?? source.id,
      age: age,
      personality: personality,
      attributes: const PlayerAttributes.outfield(
        stats: FieldPlayerAttributes(
          pace: 70,
          shooting: 70,
          passing: 70,
          dribbling: 70,
          defending: 70,
          physicality: 70,
        ),
      ),
      hidden: source.hidden.copyWith(
        determination: determination,
        injuryProne: injuryProne,
        overallProgress: progress,
      ),
      state: source.state.copyWith(
        form: form,
        seasonsWithTeam: seasonsWithTeam,
        lastDevelopmentOvrDelta: lastDevelopmentOvrDelta,
        injury: null,
        eventState: eventState,
      ),
    );
  }

  LeagueState leagueFor(
    Player player, {
    SeasonPhase phase = SeasonPhase.regular,
    List<Player>? roster,
    List<ConferenceStandings>? standings,
  }) {
    final sourceTeam = baseLeague.teams.first;
    final team = sourceTeam.copyWith(
      lineupPlayerIds: const [],
      roster: roster ?? [player],
    );
    return baseLeague.copyWith(
      teams: [team],
      playerTeamId: team.id,
      currentWeek: 1,
      currentDay: 1,
      currentSeason: baseLeague.currentSeason.copyWith(
        phase: phase,
        standings: standings ?? const [],
      ),
      inbox: const Inbox(),
    );
  }

  GameMessage messageOf(LeagueState league, String kind) =>
      league.inbox.messages.lastWhere((message) => message.kind == kind);

  test('TimedModifier round-trips and expires after exactly its duration', () {
    const initial = PlayerEventState(
      modifiers: [
        TimedModifier(type: 'growthRate', value: 0.3, weeksRemaining: 2),
      ],
      cooldowns: {'extraTraining': 2},
    );
    final restored = PlayerEventState.fromJson(
      jsonDecode(jsonEncode(initial.toJson())) as Map<String, dynamic>,
    );

    final afterOneWeek = restored.advanceWeek();
    expect(afterOneWeek.modifierOf('growthRate')?.weeksRemaining, 1);
    expect(afterOneWeek.cooldowns['extraTraining'], 1);

    final afterTwoWeeks = afterOneWeek.advanceWeek();
    expect(afterTwoWeeks.hasModifier('growthRate'), isFalse);
    expect(afterTwoWeeks.cooldowns, isEmpty);
  });

  test(
    'breakthrough requires the streak and respects one-per-season cooldown',
    () {
      final player = fixture(age: 20, progress: 80, form: 8).copyWith(
        state: fixture(age: 20, progress: 80, form: 8).state.copyWith(
          eventState: const PlayerEventState(counters: {'highFormWeeks': 3}),
        ),
      );
      final service = PlayerEventService(
        balance: BalanceConfig(events: eventBalance(breakthroughChance: 1)),
      );

      final first = service.weeklyTick(leagueFor(player), saveSeed: 25);
      final firstPlayer = first.playerTeam!.roster.first;
      expect(firstPlayer.state.eventState.modifierValue('growthRate'), 0.3);
      expect(first.inbox.messages.any((m) => m.kind == 'breakthrough'), isTrue);

      final second = service.weeklyTick(first, saveSeed: 25);
      final secondPlayer = second.playerTeam!.roster.first;
      expect(
        secondPlayer.state.eventState.counterValue('breakthroughYear'),
        2026,
      );
      expect(
        second.inbox.messages.where((m) => m.kind == 'breakthrough').length,
        1,
      );
    },
  );

  test('professional players do not receive coldStreak', () {
    final player = fixture(
      form: 3,
      personality: PlayerPersonality.professional,
      eventState: const PlayerEventState(counters: {'lowFormWeeks': 3}),
    );
    final service = PlayerEventService(
      balance: BalanceConfig(events: eventBalance(coldStreakChance: 1)),
    );

    final result = service.weeklyTick(leagueFor(player), saveSeed: 25);
    expect(result.inbox.messages.where((m) => m.kind == 'coldStreak'), isEmpty);
  });

  test('coldStreak decline adds the form floor and blocks the next XI', () {
    final player = fixture(
      form: 3,
      eventState: const PlayerEventState(counters: {'lowFormWeeks': 3}),
    );
    final service = PlayerEventService(
      balance: BalanceConfig(events: eventBalance(coldStreakChance: 1)),
    );
    final pending = service.weeklyTick(leagueFor(player), saveSeed: 25);
    final decision = messageOf(pending, 'coldStreak');
    final resolved = service.resolveDecision(
      pending,
      decision,
      'decline',
      saveSeed: 25,
    );
    final resolvedPlayer = resolved.playerTeam!.roster.first;

    expect(resolvedPlayer.state.form, 3);
    expect(resolvedPlayer.state.eventState.hasModifier('formFloor'), isTrue);
    expect(
      resolvedPlayer.state.eventState.hasModifier('startingElevenBlock'),
      isTrue,
    );
    expect(resolvedPlayer.isEligibleForStartingEleven, isFalse);
    expect(resolved.playerTeam!.startingEleven, isEmpty);
  });

  test('growth modifiers are included before the development clamp', () {
    final player = fixture(
      determination: 5,
      eventState: const PlayerEventState(
        modifiers: [
          TimedModifier(type: 'growthRate', value: 0.3, weeksRemaining: 3),
        ],
      ),
    );
    final service = DevelopmentService();
    expect(
      service.calculateGrowthRate(player, atmosphere: 50),
      closeTo(
        service.calculateGrowthRate(
              player.copyWith(
                state: player.state.copyWith(
                  eventState: const PlayerEventState(),
                ),
              ),
              atmosphere: 50,
            ) +
            0.3,
        1e-9,
      ),
    );
  });

  test(
    'extraTraining accept applies growth, stamina and injury-risk effects',
    () {
      final player = fixture(determination: 8, form: 7);
      final service = PlayerEventService(
        balance: BalanceConfig(events: eventBalance(extraTrainingChance: 1)),
      );
      final pending = service.weeklyTick(leagueFor(player), saveSeed: 25);
      final resolved = service.resolveDecision(
        pending,
        messageOf(pending, 'extraTraining'),
        'accept',
      );
      final next = resolved.playerTeam!.roster.first;
      expect(next.state.eventState.modifierValue('growthRate'), 0.2);
      expect(next.state.eventState.modifierValue('weeklyStaminaPenalty'), -5);
      expect(
        next.state.eventState.modifierValue('injuryRiskMultiplier'),
        closeTo(0.15, 1e-12),
      );
      expect(next.state.eventState.cooldowns['extraTraining'], 12);
    },
  );

  test('personal problems can be shortened by the support follow-up', () {
    final service = PlayerEventService(
      balance: BalanceConfig(
        events: eventBalance(
          personalProblemsChance: 1,
          personalSupportChance: 1,
        ),
      ),
    );
    final first = service.weeklyTick(leagueFor(fixture(form: 7)), saveSeed: 25);
    final affected = first.playerTeam!.roster.first;
    expect(affected.state.form, 5);
    expect(affected.state.eventState.modifierValue('personalProblems'), 1);

    final second = service.weeklyTick(first, saveSeed: 25);
    final support = messageOf(second, 'personalSupport');
    final resolved = service.resolveDecision(second, support, 'accept');
    final next = resolved.playerTeam!.roster.first;
    expect(
      next.state.eventState.modifierOf('personalProblems')?.weeksRemaining,
      1,
    );
    expect(
      next.state.eventState
          .modifierOf('personalProblemsGrowth')
          ?.weeksRemaining,
      1,
    );
  });

  test('lateBloomer is offseason-only and one-time', () {
    final player = fixture(age: 23, progress: 20);
    final service = PlayerEventService(
      balance: BalanceConfig(events: eventBalance(lateBloomerChance: 1)),
    );
    final offseason = service.weeklyTick(
      leagueFor(player, phase: SeasonPhase.offseason),
      saveSeed: 25,
      offseason: true,
    );
    final next = offseason.playerTeam!.roster.first;
    final attributes = next.attributes.map(
      outfield: (value) => value.stats.physicality,
      goalkeeper: (value) => value.stats.speed,
    );
    expect(attributes, 72);
    expect(next.state.eventState.lateBloomerTriggered, isTrue);

    final again = service.weeklyTick(offseason, saveSeed: 25, offseason: true);
    expect(
      again.inbox.messages.where((m) => m.kind == 'lateBloomer').length,
      1,
    );
  });

  test('recurringInjury creates a minor injury in the old Major group', () {
    final oldMajor = Injury(
      id: 'acl_tear',
      group: InjuryGroup.knees,
      type: InjuryType.major,
      daysTotal: 200,
      daysRemaining: 0,
    );
    final player = fixture(
      injuryProne: 8,
      eventState: PlayerEventState(
        lastMajorInjury: oldMajor,
        weeksSinceMajorInjury: 4,
      ),
    );
    final service = PlayerEventService(
      balance: BalanceConfig(events: eventBalance(recurringInjuryChance: 1)),
    );
    final result = service.weeklyTick(leagueFor(player), saveSeed: 25);
    final next = result.playerTeam!.roster.first;
    expect(next.state.injury?.type, InjuryType.minor);
    expect(next.state.injury?.group, InjuryGroup.knees);
    expect(
      result.inbox.messages.any((m) => m.type == MessageType.injuryRecurrence),
      isTrue,
    );
  });

  test(
    'nationalTeam trigger applies the documented form and stamina deltas',
    () {
      final player = fixture(form: 6);
      final service = PlayerEventService();
      final result = service.triggerNationalTeam(leagueFor(player), player.id);
      final next = result.playerTeam!.roster.first;

      expect(next.state.form, 7);
      expect(next.state.stamina, player.state.stamina - 15);
      expect(
        result.inbox.messages.any((m) => m.kind == 'nationalTeam'),
        isTrue,
      );
    },
  );

  test(
    'plateau is emitted after eight no-OVR weeks and accepts a growth effect',
    () {
      final player = fixture(
        lastDevelopmentOvrDelta: 0,
        eventState: const PlayerEventState(counters: {'plateauWeeks': 7}),
      );
      final service = PlayerEventService(
        balance: BalanceConfig(events: eventBalance()),
      );
      final pending = service.weeklyTick(leagueFor(player), saveSeed: 25);
      final decision = messageOf(pending, 'plateau');
      final resolved = service.resolveDecision(pending, decision, 'accept');

      expect(
        resolved.playerTeam!.roster.first.state.eventState.modifierValue(
          'growthRate',
        ),
        0.15,
      );
      expect(
        resolved.playerTeam!.roster.first.state.eventState.counterValue(
          'plateauWeeks',
        ),
        0,
      );
    },
  );

  test('injuryComplication cautious path adds rehabilitation days', () {
    final oldMajor = Injury(
      id: 'hamstring_tear',
      group: InjuryGroup.legMuscles,
      type: InjuryType.major,
      daysTotal: 70,
      daysRemaining: 0,
    );
    final player = fixture(
      eventState: PlayerEventState(
        lastMajorInjury: oldMajor,
        majorInjuryActiveLastTick: true,
      ),
    );
    final service = PlayerEventService(
      balance: BalanceConfig(events: eventBalance(injuryComplicationChance: 1)),
    );
    final pending = service.weeklyTick(leagueFor(player), saveSeed: 25);
    final resolved = service.resolveDecision(
      pending,
      messageOf(pending, 'injuryComplication'),
      'cautious',
      saveSeed: 25,
    );
    final injury = resolved.playerTeam!.roster.first.state.injury;

    expect(injury?.type, InjuryType.major);
    expect(injury?.daysRemaining, inInclusiveRange(7, 14));
    expect(injury?.group, InjuryGroup.legMuscles);
  });
}
