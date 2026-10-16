import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/day_pipeline.dart';
import 'package:new_football/core/services/negotiation_service.dart';

import 'support/game_fixtures.dart';

void main() {
  const service = NegotiationService();
  const calendar = CalendarService();
  test(
    'FA II final daily slot resolves waiting before the next morning closes it',
    () {
      final base = controllerSave().leagueState.copyWith(
        currentWeek: 45,
        currentDay: 7,
      );
      final market = ContractMarketService();
      final offered = market.submitPlayerOffer(
        league: base,
        playerId: base.freeAgents.single.id,
        offer: const ContractOffer(salary: 60000000, years: 2),
        saveSeed: fixtureSeed,
      )!;
      final record = offered.league.negotiations.single.copyWith(
        status: NegotiationStatus.waiting,
        waitingUntilSeasonYear: 2026,
        waitingUntilWeek: 45,
        waitingUntilDay: 7,
        waitingUntilHour: 0,
      );
      final resolved = market.resolveDay(
        offered.league.copyWith(negotiations: [record]),
        saveSeed: fixtureSeed,
      );
      expect(
        resolved.negotiations.single.status,
        NegotiationStatus.pendingFinalization,
      );
      expect(
        market.finalizeNegotiation(resolved, record.id, saveSeed: fixtureSeed),
        isNotNull,
      );
      final closed = DayPipeline().deliverStartOfDay(
        resolved.copyWith(currentWeek: 46, currentDay: 1),
      );
      expect(closed.negotiations.single.status, NegotiationStatus.cancelled);
    },
  );
  test('an individual FA II deadline crosses year 52/7 to 1/3', () {
    final base = phaseTwoNegotiation();
    final record = service.start(
      id: 'year-boundary',
      subjectId: fixtureFreeAgentId,
      subjectKind: NegotiationSubjectKind.player,
      teamId: base.playerTeamId!,
      phase: NegotiationPhase.freeAgencyPhaseII,
      offer: base.negotiations.single.lastOffer,
      seasonYear: 2026,
      week: 52,
      day: 7,
    );
    expect(
      (record.expirySeasonYear, record.expiryWeek, record.expiryDay),
      (2027, 1, 3),
    );
    final league = base.copyWith(negotiations: [record]);
    expect(
      service
          .expireAt(league: league, seasonYear: 2027, week: 1, day: 1)
          .negotiations
          .single
          .status,
      NegotiationStatus.active,
    );
    expect(
      service
          .expireAt(league: league, seasonYear: 2027, week: 1, day: 3)
          .negotiations
          .single
          .status,
      NegotiationStatus.hardRejected,
    );
  });
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
