library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/models/calendar_simulation_feedback.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/services/calendar_simulation_pacer.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/data/save_repository.dart';

import '../helpers/preferences_test_double.dart';

const _calendar = CalendarService();

/// The four public call-site shapes covered by Property 3. The Home event and
/// match actions both intentionally call [GameController.simulateToEvent], so
/// they are kept as separate cases to prove that neither caller gets a second
/// urgent policy.
enum _BatchCaller {
  simulateToDate,
  sharedSimulateToEvent,
  homeEvent,
  homeMatch,
}

enum _UrgentPlacement { alreadyPending, deliveredOnNextDate }

class _PropertyCase {
  const _PropertyCase({
    required this.index,
    required this.caller,
    required this.placement,
    required this.seed,
  });

  final int index;
  final _BatchCaller caller;
  final _UrgentPlacement placement;
  final int seed;

  bool get isCalendarBatch => caller == _BatchCaller.simulateToDate;
  bool get isHomeMatch => caller == _BatchCaller.homeMatch;
  bool get urgentAlreadyPending => placement == _UrgentPlacement.alreadyPending;

  int get startWeek => isCalendarBatch || isHomeMatch
      ? 1
      : _calendar.balance.calendar.awardsWeek - 1;

  int get startDay => isCalendarBatch || isHomeMatch ? 1 : 6;

  int get urgentWeek => startWeek;

  int get urgentDay => urgentAlreadyPending ? startDay : startDay + 1;

  int get targetWeek => 1;

  int get targetDay => 4;

  String get messageId => 'property-3-urgent-$index';

  String get label =>
      'Feature: urgent-message-simulation-setting, Property 3: '
      'caller=${caller.name}, placement=${placement.name}, seed=$seed';
}

void main() {
  test('Feature: urgent-message-simulation-setting, Property 3: enabled policy '
      'stops every shared batch', () async {
    final cases = _propertyCases();
    expect(cases, hasLength(greaterThanOrEqualTo(100)));

    for (final scenario in cases) {
      final preferences = PreferencesTestDouble(
        initialValues: <String, Object?>{urgentInterruptionSettingKey: true},
      );
      final container = ProviderContainer(
        overrides: [
          // The policy must be supplied through the same global provider the
          // controller reads; no active save is used to configure it.
          sharedPreferencesProvider.overrideWithValue(preferences),
          saveRepositoryProvider.overrideWithValue(_NoopSaveRepository()),
        ],
      );

      try {
        final controller = container.read(gameControllerProvider.notifier);
        final game = _gameFor(scenario);
        controller.state = AsyncValue.data(game);

        expect(
          container.read(urgentInterruptionSettingProvider),
          isTrue,
          reason: scenario.label,
        );

        final ordinaryAction = scenario.isCalendarBatch
            ? null
            : controller.nextEvent();
        if (scenario.caller == _BatchCaller.homeMatch) {
          expect(
            ordinaryAction?.kind,
            CalendarEventKind.match,
            reason:
                '${scenario.label}: fixture must have a match stop '
                'after the urgent boundary',
          );
        } else if (!scenario.isCalendarBatch) {
          expect(
            ordinaryAction,
            isNotNull,
            reason:
                '${scenario.label}: fixture must have an ordinary '
                'Home event stop after the urgent boundary',
          );
          expect(
            ordinaryAction!.kind,
            isNot(CalendarEventKind.match),
            reason:
                '${scenario.label}: event caller must not use the '
                'player-match fixture',
          );
        }

        final feedback = <CalendarDaySimulationFeedback>[];
        final result = await _runBatch(controller, scenario, feedback);
        final after = controller.save!.leagueState;
        final expectedStopDate = (scenario.urgentWeek, scenario.urgentDay);

        // True preserves the existing urgent stop and the exact boundary:
        // an already-pending message stops before day one, while a message
        // delivered at the next date stops before day two can start.
        expect(
          result.stopReason,
          SimulationStopReason.urgent,
          reason: scenario.label,
        );
        expect(
          (after.currentWeek, after.currentDay),
          expectedStopDate,
          reason:
              '${scenario.label}: urgent stop moved past its existing '
              'delivery boundary',
        );
        expect(
          result.daysSimulated,
          scenario.urgentAlreadyPending ? 0 : 1,
          reason:
              '${scenario.label}: urgent stop occurred after an '
              'unexpected extra simulation step',
        );

        if (scenario.urgentAlreadyPending) {
          expect(
            result.lastResult,
            isNull,
            reason:
                '${scenario.label}: no day may be simulated before '
                'an urgent message already pending at batch start',
          );
        } else {
          expect(
            result.lastResult,
            isNotNull,
            reason:
                '${scenario.label}: the completed preceding day must '
                'remain available as lastResult',
          );
          expect(
            (
              result.lastResult!.league.currentWeek,
              result.lastResult!.league.currentDay,
            ),
            expectedStopDate,
            reason:
                '${scenario.label}: lastResult date disagrees with '
                'the persisted urgent stop date',
          );
        }

        if (scenario.isCalendarBatch) {
          expect(
            (after.currentWeek, after.currentDay),
            isNot((scenario.targetWeek, scenario.targetDay)),
            reason:
                '${scenario.label}: calendar batch reached the ordinary '
                'target instead of stopping at urgent',
          );
          expect(
            feedback.map((item) => (item.week, item.day)),
            scenario.urgentAlreadyPending
                ? isEmpty
                : orderedEquals([(scenario.startWeek, scenario.startDay)]),
            reason:
                '${scenario.label}: calendar presentation crossed the '
                'urgent boundary',
          );
        } else {
          final actionDate = (ordinaryAction!.week, ordinaryAction.day);
          expect(
            _dateOrdinal(after.currentWeek, after.currentDay),
            lessThan(_dateOrdinal(actionDate.$1, actionDate.$2)),
            reason:
                '${scenario.label}: urgent stop happened after the '
                'ordinary Home action became due',
          );
        }

        // Existing Inbox behavior remains the source of truth for the
        // result response: stopping does not read, acknowledge, or remove
        // the urgent message.
        final pending = after.inbox.pendingUrgent;
        expect(
          pending.map((message) => message.id),
          contains(scenario.messageId),
          reason:
              '${scenario.label}: Inbox no longer exposes the urgent '
              'message after the batch stop',
        );
        final message = after.inbox.messages.firstWhere(
          (item) => item.id == scenario.messageId,
        );
        expect(message.read, isFalse, reason: scenario.label);
        expect(message.acknowledged, isFalse, reason: scenario.label);
        expect(
          after.inbox.scheduled.any((item) => item.id == scenario.messageId),
          isFalse,
          reason:
              '${scenario.label}: delivered urgent must be in Inbox '
              'before the result is returned',
        );
      } finally {
        container.dispose();
      }
    }
  });
}

List<_PropertyCase> _propertyCases() {
  return [
    for (var index = 0; index < 120; index++)
      _PropertyCase(
        index: index,
        caller: _BatchCaller.values[index % _BatchCaller.values.length],
        placement: index.isEven
            ? _UrgentPlacement.alreadyPending
            : _UrgentPlacement.deliveredOnNextDate,
        seed: 7300 + index,
      ),
  ];
}

GameSave _gameFor(_PropertyCase scenario) {
  final base = GameFactory().create(
    NewGameRequest(
      saveName: 'Property 3 ${scenario.index}',
      playerTeamId: 'team_europe_0',
      seed: scenario.seed,
    ),
  );
  final playerTeamId = scenario.isHomeMatch ? 'team_europe_0' : null;
  final urgent = GameMessage(
    id: scenario.messageId,
    type: MessageType.playerEvent,
    domain: MessageDomain.playerEvent,
    priority: MessagePriority.urgent,
    seasonYear: base.leagueState.currentSeason.year,
    week: scenario.urgentWeek,
    day: scenario.urgentDay,
    titleKey: 'property_3_urgent_title',
    bodyKey: 'property_3_urgent_body',
  );
  final inbox = scenario.urgentAlreadyPending
      ? Inbox(messages: [urgent])
      : Inbox(scheduled: [urgent]);
  final league = base.leagueState.copyWith(
    playerTeamId: playerTeamId,
    currentWeek: scenario.startWeek,
    currentDay: scenario.startDay,
    currentHour: _calendar.initialHourForDate(
      scenario.startWeek,
      scenario.startDay,
    ),
    currentSeason: base.leagueState.currentSeason.copyWith(
      phase: _calendar.phaseForWeek(scenario.startWeek),
    ),
    inbox: inbox,
  );
  return base.copyWith(leagueState: league);
}

Future<BatchSimulationResult> _runBatch(
  GameController controller,
  _PropertyCase scenario,
  List<CalendarDaySimulationFeedback> feedback,
) {
  switch (scenario.caller) {
    case _BatchCaller.simulateToDate:
      return controller.simulateToDate(
        scenario.targetWeek,
        scenario.targetDay,
        observer: feedback.add,
        pacer: CalendarSimulationPacer(
          elapsedSource: () => Duration.zero,
          delay: (_) async {},
        ),
      );
    case _BatchCaller.sharedSimulateToEvent:
    case _BatchCaller.homeEvent:
    case _BatchCaller.homeMatch:
      // Home's event and match actions intentionally share this public batch
      // method; separate matrix entries make the shared policy explicit.
      return controller.simulateToEvent();
  }
}

int _dateOrdinal(int week, int day) => week * 8 + day;

final class _NoopSaveRepository extends SaveRepository {
  @override
  Future<void> save(GameSave gameSave) async {}
}
