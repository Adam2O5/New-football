import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/season_awards.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/game_factory.dart';
import 'package:new_football/core/services/season_service.dart';

void main() {
  const calendar = CalendarService();

  test('maps all canonical season boundaries to the correct phases', () {
    expect(calendar.phaseForWeek(0), SeasonPhase.preseason);
    expect(calendar.phaseForWeek(1), SeasonPhase.regular);
    expect(calendar.phaseForWeek(29), SeasonPhase.regular);
    expect(calendar.phaseForWeek(30), SeasonPhase.regular);
    expect(calendar.phaseForWeek(31), SeasonPhase.playIn);
    expect(calendar.phaseForWeek(32), SeasonPhase.playoff);
    expect(calendar.phaseForWeek(43), SeasonPhase.playoff);
    expect(calendar.phaseForWeek(44), SeasonPhase.offseason);
    expect(calendar.phaseForWeek(47), SeasonPhase.offseason);

    expect(calendar.isRegularSeasonWeek(29), isTrue);
    expect(calendar.isRegularSeasonWeek(30), isFalse);
    expect(calendar.isBreakWeek(30), isTrue);
  });

  test('exposes canonical play-in and playoff slots', () {
    expect(calendar.playInSlotForDay(31, 3), 0);
    expect(calendar.playInSlotForDay(31, 6), 2);
    expect(calendar.playInSlotsForDay(31, 3), [0, 1]);
    expect(calendar.playInSlotsForDay(31, 6), [2]);
    expect(calendar.playInSlotsForDay(31, 2), isEmpty);

    expect(calendar.playoffRoundForWeek(32), 1);
    expect(calendar.playoffRoundForWeek(34), 1);
    expect(calendar.playoffRoundForWeek(35), 2);
    expect(calendar.playoffRoundForWeek(37), 2);
    expect(calendar.playoffRoundForWeek(38), 3);
    expect(calendar.playoffRoundForWeek(40), 3);
    expect(calendar.playoffRoundForWeek(41), 4);
    expect(calendar.playoffRoundForWeek(43), 4);
    expect(calendar.postseasonSlotForDay(32, 3), 0);
    expect(calendar.postseasonSlotForDay(32, 6), 1);

    expect(calendar.higherSeedHomeForGame(0), isTrue);
    expect(calendar.higherSeedHomeForGame(1), isFalse);
    expect(calendar.higherSeedHomeForGame(2), isFalse);
    expect(calendar.higherSeedHomeForGame(3), isTrue);
    expect(calendar.higherSeedHomeForGame(4), isTrue);
  });

  test('registers week 44-47 events on canonical dates', () {
    final slots = CalendarEventRegistry.build(calendar.balance.calendar);
    CalendarEventSlot slot(CalendarEventId id) =>
        slots.firstWhere((event) => event.id == id);

    expect(slot(CalendarEventId.awards).week, 44);
    expect(slot(CalendarEventId.awards).day, 1);
    expect(slot(CalendarEventId.staffGrowth).week, 44);
    expect(slot(CalendarEventId.staffGrowth).day, 2);
    expect(slot(CalendarEventId.retirements).day, 3);
    expect(slot(CalendarEventId.lottery).day, 5);
    expect(slot(CalendarEventId.scoutReport).week, 45);
    expect(slot(CalendarEventId.scoutReport).day, 1);
    expect(slot(CalendarEventId.combine).day, 3);
    expect(slot(CalendarEventId.finalMock).day, 5);
    expect(slot(CalendarEventId.draft).week, 46);
    expect(slot(CalendarEventId.freeAgencyOpen).week, 47);
    expect(slot(CalendarEventId.tradeDeadline).week, 23);
    expect(slot(CalendarEventId.tradeWindowOpen).week, 44);
  });

  test('event windows cover trade, extensions and free agency ranges', () {
    expect(
      calendar.windowsOn(44, 1).map((w) => w.id),
      contains(CalendarEventId.tradeWindowOpen),
    );
    expect(
      calendar.windowsOn(23, 1).map((w) => w.id),
      contains(CalendarEventId.tradeWindowOpen),
    );
    expect(calendar.windowsOn(30, 1), isEmpty);
    expect(
      calendar.windowsOn(46, 2).map((w) => w.id),
      contains(CalendarEventId.contractExtensions),
    );
    expect(
      calendar.windowsOn(46, 7).map((w) => w.id),
      contains(CalendarEventId.contractExtensions),
    );
    expect(
      calendar.windowsOn(47, 1).map((w) => w.id),
      contains(CalendarEventId.freeAgencyOpen),
    );
    expect(
      calendar.windowsOn(52, 7).map((w) => w.id),
      contains(CalendarEventId.freeAgencyOpen),
    );
  });

  test('handles deadline, trade window and phase boundaries', () {
    expect(calendar.isTradeDeadline(23, 1), isTrue);
    expect(calendar.isTradeDeadline(23, 2), isFalse);
    expect(calendar.isTradeWindowOpen(22, day: 7), isTrue);
    expect(calendar.isTradeWindowOpen(23, day: 1), isFalse);
    expect(calendar.isTradeWindowOpen(43, day: 7), isFalse);
    expect(calendar.isTradeWindowOpen(44, day: 1), isTrue);

    expect(calendar.endOfPhase(SeasonPhase.regular), (29, 7));
    expect(calendar.endOfPhase(SeasonPhase.playIn), (31, 7));
    expect(calendar.endOfPhase(SeasonPhase.playoff), (43, 7));
    expect(calendar.endOfPhase(SeasonPhase.offseason), (52, 7));
    expect(calendar.advanceDay(52, 7), (1, 1));
  });

  test('resolves play-in games on Wednesday and Saturday dates', () {
    final game = GameFactory().create(
      const NewGameRequest(
        saveName: 'Play-in calendar',
        playerTeamId: 'team_europe_0',
        seed: 42,
      ),
    );
    final service = SeasonService();

    final afterWednesday = service.advancePlayInForDate(
      game.leagueState,
      week: 31,
      day: 3,
      saveSeed: 42,
    );
    expect(afterWednesday.currentSeason.playInProgress, hasLength(2));
    expect(
      afterWednesday.currentSeason.playInProgress,
      everyElement(
        predicate<PlayInProgress>(
          (progress) => progress.game7v8 != null && progress.game9v10 != null,
        ),
      ),
    );
    expect(afterWednesday.currentSeason.playInResults, isEmpty);

    final afterSaturday = service.advancePlayInForDate(
      afterWednesday,
      week: 31,
      day: 6,
      saveSeed: 42,
    );
    expect(afterSaturday.currentSeason.playInProgress, isEmpty);
    expect(afterSaturday.currentSeason.playInResults, hasLength(2));
    expect(
      afterSaturday.currentSeason.playInResults,
      everyElement(
        predicate<PlayInResult>(
          (result) => result.gameFinal.homeTeamId.isNotEmpty,
        ),
      ),
    );
  });

  test('walks one full calendar cycle and visits each point event once', () {
    var week = 1;
    var day = 1;
    final seen = <CalendarEventId, int>{};

    for (var i = 0; i < 52 * 7; i++) {
      for (final event in calendar.eventsOn(week, day)) {
        seen[event.id] = (seen[event.id] ?? 0) + 1;
      }
      (week, day) = calendar.advanceDay(week, day);
    }

    expect((week, day), (1, 1));
    final registered = CalendarEventRegistry.build(calendar.balance.calendar);
    expect(seen.keys, containsAll(registered.map((event) => event.id)));
    expect(seen.values, everyElement(equals(1)));
  });

  test('nextEvent wraps unresolved events into the next cycle', () {
    final game = GameFactory().create(
      const NewGameRequest(
        saveName: 'Calendar',
        playerTeamId: 'team_europe_0',
        seed: 42,
      ),
    );
    final draft = DraftState(
      year: game.leagueState.currentSeason.year,
      draftClass: DraftClass(year: game.leagueState.currentSeason.year),
    );
    final season = game.leagueState.currentSeason.copyWith(
      awards: SeasonAwards(year: game.leagueState.currentSeason.year),
      staffGrowthDone: true,
      playerRetirementsDone: true,
      combineDone: true,
      finalMockDone: true,
      faOpenDone: true,
      scoutReportDone: true,
      tradeDeadlineAcked: true,
      draftState: draft,
      nextDraftState: draft,
    );
    final league = game.leagueState.copyWith(
      currentWeek: 45,
      currentDay: 7,
      currentSeason: season,
    );

    final next = CalendarEventRegistry.nextEvent(league);
    expect(next?.id, CalendarEventId.lottery);
    // The registry returns the canonical slot week; normalization is used
    // internally to choose the next occurrence after the current date.
    expect(next?.week, 44);
  });
}
