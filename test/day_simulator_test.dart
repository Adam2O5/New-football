import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/day_simulator.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/models/enums.dart';

void main() {
  test('simulateDay advances calendar and plays AI fixtures', () {
    final game = GameFactory().create(
      const NewGameRequest(
        saveName: 'Day',
        playerTeamId: 'team_europe_0',
        seed: 5,
      ),
    );
    final sim = DaySimulator();
    // Jump to Wednesday week 1 (day 3) for midweek slot.
    var league = game.leagueState.copyWith(currentWeek: 1, currentDay: 3);
    final result = sim.simulateDay(league);
    // Player match may pause, or AI matches resolve.
    expect(result.league.currentWeek, anyOf(1, 2));
    if (result.playerMatch == null) {
      expect(result.league.currentDay, 4);
      expect(result.simulatedResults, isNotEmpty);
    } else {
      expect(result.pauseForUrgent, isTrue);
    }
  });

  test('CalendarService phase mapping', () {
    const cal = CalendarService();
    expect(cal.phaseForWeek(1), SeasonPhase.regular);
    expect(cal.phaseForWeek(31), SeasonPhase.playIn);
    expect(cal.phaseForWeek(35), SeasonPhase.playoff);
    expect(cal.phaseForWeek(46), SeasonPhase.draft);
    expect(cal.phaseForWeek(47), SeasonPhase.offseason);
  });

  test('seed generates 30 teams', () {
    final league = SeedDataGenerator(random: null).generateLeague(seed: 1);
    expect(league.teams.length, 30);
  });
}
