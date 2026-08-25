@Tags(['property'])
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/services/calendar_simulation_pacer.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/calendar_service.dart';

import '../helpers/preferences_test_double.dart';
import '../helpers/widget_harness.dart';

const _property4Label =
    'Feature: urgent-message-simulation-setting, Property 4: '
    'disabled policy skips only urgent';
const _property4CaseCount = 120;

void main() {
  // **Validates: Requirements 4.1–4.7, 9.3–9.5; Design Property 4**
  test('$_property4Label continues to the first ordinary target for '
      '$_property4CaseCount deterministic plans', () async {
    for (var caseIndex = 0; caseIndex < _property4CaseCount; caseIndex++) {
      final plan = _planFor(caseIndex);
      final base = task41Game(seed: 26000 + caseIndex);
      final game = _withScheduledUrgents(
        base,
        week: plan.startWeek,
        days: plan.urgentDays,
        clearPlayerTeam: true,
      );
      final fixture = _controllerFixture(game);
      final caseLabel =
          '$_property4Label case=$caseIndex '
          'urgentDays=${plan.urgentDays} target=${plan.targetDay}';

      try {
        expect(
          fixture.container.read(urgentInterruptionSettingProvider),
          isFalse,
          reason: '$caseLabel must use the explicit false preference override',
        );

        final result = await fixture.controller.simulateToDate(
          plan.targetWeek,
          plan.targetDay,
          pacer: _instantPacer(),
        );
        final league = fixture.controller.save!.leagueState;

        expect(
          result.stopReason,
          SimulationStopReason.reachedTarget,
          reason: '$caseLabel must skip urgent as a stop reason',
        );
        expect(
          result.stopReason,
          isNot(SimulationStopReason.urgent),
          reason: '$caseLabel ended only because pending urgent was present',
        );
        expect(
          (league.currentWeek, league.currentDay),
          (plan.targetWeek, plan.targetDay),
          reason: '$caseLabel must stop at the ordinary target',
        );
        expect(
          league.currentDay,
          lessThanOrEqualTo(plan.targetDay),
          reason: '$caseLabel must not simulate beyond its target',
        );
        expect(
          result.daysSimulated,
          plan.targetDay - plan.startDay,
          reason:
              '$caseLabel must continue from the next evaluation without '
              'an extra day',
        );
        expect(
          result.lastResult,
          isNotNull,
          reason: '$caseLabel should retain the last ordinary day result',
        );

        _expectPendingUrgents(league, plan.messageIds, reason: caseLabel);
        expect(
          league.inbox.scheduled,
          isEmpty,
          reason:
              '$caseLabel must deliver every scheduled urgent before the '
              'target rather than dropping it',
        );
      } finally {
        fixture.dispose();
      }
    }
  });

  test('$_property4Label preserves the first actionable player match and keeps '
      'delivered urgent messages pending', () async {
    final base = task41Game(seed: 26101);
    final matchDay = _firstRegularMatchDay();
    final game = _withScheduledUrgents(
      base,
      week: 1,
      days: const [1, 2],
      messagePrefix: 'urgent-match',
    );
    final fixture = _controllerFixture(game);
    addTearDown(fixture.dispose);

    final result = await fixture.controller.simulateToEvent();
    final league = fixture.controller.save!.leagueState;

    expect(result.stopReason, SimulationStopReason.playerMatch);
    expect(result.eventId, isNull);
    expect(result.lastResult?.playerMatch, isNotNull);
    expect((league.currentWeek, league.currentDay), (1, matchDay));
    expect(result.daysSimulated, matchDay);
    expect(
      result.stopReason,
      isNot(SimulationStopReason.urgent),
      reason:
          'the player match is the first ordinary stop after urgent '
          'delivery',
    );
    _expectPendingUrgents(league, const [
      'urgent-match-1',
      'urgent-match-2',
    ], reason: 'player-match handoff');
  });

  test('$_property4Label preserves the first actionable draft event after '
      'urgent delivery', () async {
    final base = task41Game(seed: 26102);
    final calendar = const CalendarService();
    final draftWeek = calendar.balance.calendar.draftWeek;
    final currentWeek = draftWeek - 1;
    final season = base.leagueState.currentSeason;
    final game = _withScheduledUrgents(
      base,
      week: currentWeek,
      days: const [1, 1],
      playerTeamId: 'team_europe_0',
      currentWeek: currentWeek,
      messagePrefix: 'urgent-event',
      isolatePeriodicUrgents: true,
      currentSeason: season.copyWith(
        scoutReportDone: true,
        combineDone: true,
        finalMockDone: true,
        draftState: DraftState(
          year: season.year,
          order: [
            const DraftPick(
              id: 'property4-draft-pick',
              year: 2027,
              round: 1,
              pickNumber: 1,
              teamId: 'team_europe_0',
              originalTeamId: 'team_europe_0',
            ),
          ],
          draftClass: DraftClass(year: season.year),
        ),
      ),
    );
    final fixture = _controllerFixture(game);
    addTearDown(fixture.dispose);

    final result = await fixture.controller.simulateToEvent();
    final league = fixture.controller.save!.leagueState;

    expect(result.stopReason, SimulationStopReason.event);
    expect(result.eventId, CalendarEventId.draft);
    expect((league.currentWeek, league.currentDay), (draftWeek, 1));
    expect(result.daysSimulated, 7);
    expect(
      result.stopReason,
      isNot(SimulationStopReason.urgent),
      reason:
          'the draft event is the first ordinary stop after urgent '
          'delivery',
    );
    _expectPendingUrgents(league, const [
      'urgent-event-1',
      'urgent-event-2',
    ], reason: 'draft-event handoff');
  });
}

_FalsePolicyPlan _planFor(int caseIndex) {
  final multiple = caseIndex.isOdd;
  final urgentDays = multiple ? const [1, 2] : const [1];
  return _FalsePolicyPlan(
    startWeek: 1,
    startDay: 1,
    targetWeek: 1,
    targetDay: multiple ? 4 : 3,
    urgentDays: urgentDays,
  );
}

GameSave _withScheduledUrgents(
  GameSave game, {
  required int week,
  required List<int> days,
  String? playerTeamId,
  bool clearPlayerTeam = false,
  int? currentWeek,
  Season? currentSeason,
  String messagePrefix = 'urgent-property',
  bool isolatePeriodicUrgents = false,
}) {
  final seasonYear = game.leagueState.currentSeason.year;
  final effectivePlayerTeamId = clearPlayerTeam
      ? null
      : (playerTeamId ?? game.leagueState.playerTeamId);
  final teams = isolatePeriodicUrgents && effectivePlayerTeamId != null
      ? game.leagueState.teams
            .map(
              (team) => team.id == effectivePlayerTeamId
                  ? team.copyWith(
                      roster: const [],
                      lineupPlayerIds: const [],
                      benchPlayerIds: const [],
                    )
                  : team,
            )
            .toList()
      : game.leagueState.teams;
  final messages = [
    for (var index = 0; index < days.length; index++)
      _scheduledUrgent(
        id: '$messagePrefix-${index + 1}',
        seasonYear: seasonYear,
        week: week,
        day: days[index],
      ),
  ];
  final league = game.leagueState.copyWith(
    teams: teams,
    playerTeamId: clearPlayerTeam
        ? null
        : (playerTeamId ?? game.leagueState.playerTeamId),
    currentWeek: currentWeek ?? game.leagueState.currentWeek,
    currentDay: 1,
    currentSeason: currentSeason ?? game.leagueState.currentSeason,
    inbox: Inbox(scheduled: messages),
  );
  return game.copyWith(leagueState: league);
}

GameMessage _scheduledUrgent({
  required String id,
  required int seasonYear,
  required int week,
  required int day,
}) {
  return GameMessage(
    id: id,
    type: MessageType.playerEvent,
    domain: MessageDomain.playerEvent,
    priority: MessagePriority.urgent,
    seasonYear: seasonYear,
    week: week,
    day: day,
    titleKey: 'msg_playerEvent_title',
    bodyKey: 'msg_playerEvent_body',
    args: const {
      '_legacyTitle': 'Property 4 urgent',
      '_legacyBody': 'Pending urgent message for the false-policy test.',
    },
  );
}

void _expectPendingUrgents(
  LeagueState league,
  List<String> expectedIds, {
  required String reason,
}) {
  final pending = league.inbox.pendingUrgent;
  expect(
    pending.map((message) => message.id),
    orderedEquals(expectedIds),
    reason: '$reason must preserve every delivered urgent in pendingUrgent',
  );
  for (final message in pending) {
    expect(
      message.priority,
      MessagePriority.urgent,
      reason: '$reason changed an urgent message priority',
    );
    expect(
      message.read,
      isFalse,
      reason: '$reason must not mark the message read automatically',
    );
    expect(
      message.acknowledged,
      isFalse,
      reason: '$reason must not acknowledge the message automatically',
    );
  }
}

int _firstRegularMatchDay() {
  const calendar = CalendarService();
  for (final day in [3, 4, 6, 7]) {
    if (calendar.isActualMatchDay(1, day)) return day;
  }
  throw StateError('No regular-season match day found for week 1');
}

CalendarSimulationPacer _instantPacer() {
  return CalendarSimulationPacer(target: Duration.zero, delay: (_) async {});
}

_ControllerFixture _controllerFixture(GameSave game) {
  final preferences = PreferencesTestDouble(
    initialValues: <String, Object?>{urgentInterruptionSettingKey: false},
  );
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      saveRepositoryProvider.overrideWithValue(Task41NoopSaveRepository()),
    ],
  );
  final controller = container.read(gameControllerProvider.notifier);
  controller.state = AsyncValue.data(game);
  return _ControllerFixture(container, controller);
}

class _ControllerFixture {
  _ControllerFixture(this.container, this.controller);

  final ProviderContainer container;
  final GameController controller;

  void dispose() {
    container.dispose();
  }
}

class _FalsePolicyPlan {
  const _FalsePolicyPlan({
    required this.startWeek,
    required this.startDay,
    required this.targetWeek,
    required this.targetDay,
    required this.urgentDays,
  });

  final int startWeek;
  final int startDay;
  final int targetWeek;
  final int targetDay;
  final List<int> urgentDays;

  List<String> get messageIds => [
    for (var index = 0; index < urgentDays.length; index++)
      'urgent-property-${index + 1}',
  ];
}
