import 'dart:async';

import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/services/day_pipeline.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/simulation_worker.dart';

/// Advances only the date, without invoking the match engine or AI.
class ControlledSimulationRunner extends InlineSimulationRunner {
  final dayStarted = Completer<void>();
  Completer<void>? dayGate;
  var daysCalled = 0;

  @override
  Future<DayStepOutput> advanceDay(
    LeagueState league, {
    required int saveSeed,
    bool blockOnPendingUrgent = true,
    bool resolveContractMarket = true,
  }) async {
    daysCalled++;
    if (!dayStarted.isCompleted) dayStarted.complete();
    await dayGate?.future;
    final next = league.copyWith(currentDay: league.currentDay + 1);
    return DayStepOutput(
      league: next,
      result: DaySimulationResult(league: next, pauseForUrgent: false),
    );
  }
}
