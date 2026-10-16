import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/negotiation_service.dart';

import 'support/game_fixtures.dart';

void main() {
  const service = NegotiationService();
  const calendar = CalendarService();
  for (final week in [45, 46, 47, 48, 52, 1]) {
    test('FA II availability week $week', () {
      expect(calendar.isFreeAgencyPhaseII(week), ![46, 47].contains(week));
    });
  }
  for (final origin in [(2026, 48), (2026, 52), (2027, 1), (2027, 45)]) {
    test(
      'FA II origin $origin survives until final daily slot and then closes despite waiting',
      () {
        final initial = phaseTwoNegotiation();
        final record = initial.negotiations.single.copyWith(
          seasonYear: origin.$1,
          week: origin.$2,
          status: NegotiationStatus.waiting,
          expirySeasonYear: 2027,
          expiryWeek: 46,
          expiryDay: 5,
          waitingUntilSeasonYear: 2027,
          waitingUntilWeek: 46,
          waitingUntilDay: 5,
          waitingUntilHour: 0,
        );
        final league = initial.copyWith(negotiations: [record]);
        final finalSlot = service.expireAt(
          league: league,
          seasonYear: 2027,
          week: 45,
          day: 7,
          hour: 10,
        );
        expect(finalSlot.negotiations.single.status, NegotiationStatus.waiting);
        final closed = service.expireAt(
          league: finalSlot,
          seasonYear: 2027,
          week: 46,
          day: 1,
          skipNegotiationIds: {record.id},
        );
        expect(closed.negotiations.single.status, NegotiationStatus.cancelled);
        expect(closed.negotiationBlocks, isEmpty);
        expect(
          service.expireAt(league: closed, seasonYear: 2027, week: 47, day: 1),
          closed,
        );
      },
    );
  }
  test('week 48 start does not cancel; individual deadline still expires', () {
    final league = phaseTwoNegotiation();
    expect(
      service
          .expireAt(league: league, seasonYear: 2026, week: 48, day: 1)
          .negotiations
          .single
          .status,
      NegotiationStatus.active,
    );
    final expired = service.expireAt(
      league: league,
      seasonYear: 2026,
      week: 48,
      day: 4,
    );
    expect(expired.negotiations.single.status, NegotiationStatus.hardRejected);
    expect(expired.negotiationBlocks, hasLength(1));
  });
}
