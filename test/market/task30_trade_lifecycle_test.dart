import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/trade_models.dart';
import 'package:new_football/core/services/trade_service.dart';

class _AlwaysAcceptRandom implements Random {
  const _AlwaysAcceptRandom();

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) => 0;
}

class _AlwaysRejectRandom implements Random {
  const _AlwaysRejectRandom();

  @override
  bool nextBool() => true;

  @override
  double nextDouble() => 1;

  @override
  int nextInt(int max) => max - 1;
}

void main() {
  LeagueState leagueAt({int week = 1, int day = 1, int hour = 0}) {
    return SeedDataGenerator()
        .generateLeague(seed: 30)
        .copyWith(currentWeek: week, currentDay: day, currentHour: hour);
  }

  TradeProposal oneForOne(LeagueState league) {
    final a = league.teams[0];
    final b = league.teams[1];
    return TradeProposal(
      teamAId: a.id,
      teamBId: b.id,
      assetsFromA: [TradeAsset.player(a.roster.first.id)],
      assetsFromB: [TradeAsset.player(b.roster.first.id)],
    );
  }

  test('TradeOffer and LeagueState serialize pending lifecycle state', () {
    final league = leagueAt();
    final proposal = oneForOne(league);
    final created = TradeService().createOffer(
      league,
      proposal,
      emitMessages: false,
    );
    final offer = created.league.tradeOfferById(created.offerId!);

    expect(offer, isNotNull);
    final restoredOffer = TradeOffer.fromJson(
      jsonDecode(jsonEncode(offer!.toJson())) as Map<String, dynamic>,
    );
    final restoredLeague = LeagueState.fromJson(
      jsonDecode(jsonEncode(created.league.toJson())) as Map<String, dynamic>,
    );

    expect(restoredOffer, offer);
    expect(restoredLeague.tradeOfferById(offer.id), offer);
  });

  test('createOffer persists pending offer and leaves assets untouched', () {
    final league = leagueAt();
    final proposal = oneForOne(league);
    final result = TradeService().createOffer(league, proposal);

    expect(result.outcome, 'pending');
    expect(result.changed, isTrue);
    expect(result.league.tradeHistory, isEmpty);
    expect(result.league.teams, league.teams);
    final offer = result.league.tradeOfferById(result.offerId!);
    expect(offer?.status, TradeOfferStatus.pending);
    expect(offer?.awaitingTeamId, proposal.teamBId);
    expect(
      result.league.inbox.messages.any(
        (message) =>
            message.payload['tradeOfferId'] == result.offerId &&
            message.type.name == 'tradeOffer' &&
            !message.acknowledged,
      ),
      isTrue,
    );
  });

  test('counterOffer supersedes parent without mutating rosters', () {
    final league = leagueAt();
    final proposal = oneForOne(league);
    final service = TradeService();
    final created = service.createOffer(league, proposal, emitMessages: true);
    final counter = service.counterOffer(
      created.league,
      created.offerId!,
      proposal,
      actingTeamId: proposal.teamBId,
    );

    expect(counter.outcome, 'countered');
    expect(counter.changed, isTrue);
    expect(counter.league.teams, league.teams);
    expect(
      counter.league.tradeOfferById(created.offerId!)?.status,
      TradeOfferStatus.countered,
    );
    final next = counter.league.tradeOfferById(counter.offerId!);
    expect(next?.status, TradeOfferStatus.pending);
    expect(next?.parentOfferId, created.offerId);
    expect(
      next?.threadId,
      created.league.tradeOfferById(created.offerId!)!.threadId,
    );
    expect(next?.round, 2);
    expect(
      counter.league.inbox.messages.any(
        (message) =>
            message.payload['tradeOfferId'] == counter.offerId &&
            message.type.name == 'trade' &&
            message.kind == 'counter' &&
            !message.acknowledged,
      ),
      isTrue,
    );
  });

  test('acceptOffer revalidates and executes exactly one transfer', () {
    final league = leagueAt();
    final proposal = oneForOne(league);
    final service = TradeService(random: const _AlwaysAcceptRandom());
    final created = service.createOffer(league, proposal, emitMessages: true);
    final offerMessageId = created.league.inbox.messages
        .firstWhere(
          (message) =>
              message.payload['tradeOfferId'] == created.offerId &&
              message.type.name == 'tradeOffer',
        )
        .id;
    final accepted = service.acceptOffer(
      created.league,
      created.offerId!,
      actingTeamId: proposal.teamBId,
    );

    expect(accepted.outcome, 'accepted');
    expect(accepted.changed, isTrue);
    expect(
      accepted.league.tradeOfferById(created.offerId!)?.status,
      TradeOfferStatus.accepted,
    );
    expect(accepted.league.tradeHistory.last.outcome, 'accepted');
    expect(accepted.league.tradeHistory.last.offerId, created.offerId);
    final teamA = accepted.league.teamById(proposal.teamAId)!;
    final teamB = accepted.league.teamById(proposal.teamBId)!;
    expect(
      teamA.roster.any(
        (player) => player.id == league.teams[1].roster.first.id,
      ),
      isTrue,
    );
    expect(
      teamB.roster.any(
        (player) => player.id == league.teams[0].roster.first.id,
      ),
      isTrue,
    );
    final originalOfferMessage = [
      ...accepted.league.inbox.messages,
      ...accepted.league.inbox.archive,
    ].firstWhere((message) => message.id == offerMessageId);
    expect(originalOfferMessage.acknowledged, isTrue);
  });

  test('rejectOffer and expiry are terminal and do not transfer assets', () {
    final league = leagueAt();
    final proposal = oneForOne(league);
    final service = TradeService();
    final created = service.createOffer(league, proposal, emitMessages: false);
    final rejected = service.rejectOffer(
      created.league,
      created.offerId!,
      actingTeamId: proposal.teamBId,
      emitMessages: false,
    );
    expect(rejected.outcome, 'rejected');
    expect(
      rejected.league.tradeOfferById(created.offerId!)?.status,
      TradeOfferStatus.rejected,
    );
    expect(rejected.league.teams, league.teams);

    final second = service.createOffer(league, proposal, emitMessages: false);
    final pending = second.league.tradeOfferById(second.offerId!)!;
    final expired = service.expireOffers(
      second.league,
      seasonYear: pending.expirySeasonYear,
      week: pending.expiryWeek,
      day: pending.expiryDay,
      hour: pending.expiryHour,
      emitMessages: false,
    );
    expect(
      expired.tradeOfferById(pending.id)?.status,
      TradeOfferStatus.expired,
    );
    expect(expired.teams, league.teams);
  });

  test('counter and accept reject stale or unauthorized actions', () {
    final league = leagueAt();
    final proposal = oneForOne(league);
    final service = TradeService();
    final created = service.createOffer(league, proposal, emitMessages: false);

    final wrongActor = service.acceptOffer(
      created.league,
      created.offerId!,
      actingTeamId: proposal.teamAId,
      emitMessages: false,
    );
    expect(wrongActor.changed, isFalse);
    expect(wrongActor.validation.code, 'offerActor');

    final rejected = service.rejectOffer(
      created.league,
      created.offerId!,
      actingTeamId: proposal.teamBId,
      emitMessages: false,
    );
    final duplicate = service.acceptOffer(
      rejected.league,
      created.offerId!,
      actingTeamId: proposal.teamBId,
      emitMessages: false,
    );
    expect(duplicate.changed, isFalse);
    expect(duplicate.validation.code, 'offerClosed');
  });

  test('Stepien blocks consecutive outgoing first-round picks', () {
    final base = leagueAt();
    final teamA = base.teams[0].copyWith(
      ownedPicks: base.teams[0].ownedPicks
          .where((pick) => pick.year != 2027 && pick.year != 2028)
          .toList(),
    );
    final teamB = base.teams[1];
    final picks = [
      DraftPick(
        id: 'stepien-2027',
        year: 2027,
        round: 1,
        teamId: teamA.id,
        originalTeamId: teamA.id,
      ),
      DraftPick(
        id: 'stepien-2028',
        year: 2028,
        round: 1,
        teamId: teamA.id,
        originalTeamId: teamA.id,
      ),
    ];
    final league = base.copyWith(
      teams: [
        teamA.copyWith(ownedPicks: [...teamA.ownedPicks, ...picks]),
        teamB,
        ...base.teams.skip(2),
      ],
      tradeHistory: [
        TradeHistoryEntry(
          id: 'prior-2027',
          teamAId: teamA.id,
          teamBId: teamB.id,
          seasonYear: 2026,
          week: 1,
          outcome: 'accepted',
          assetsFromA: [
            TradeAsset.pick(
              pickId: 'history-2027',
              pickYear: 2027,
              pickRound: 1,
              originalTeamId: teamA.id,
            ).toSnapshot(),
          ],
        ),
        TradeHistoryEntry(
          id: 'prior-2028',
          teamAId: teamA.id,
          teamBId: teamB.id,
          seasonYear: 2026,
          week: 2,
          outcome: 'accepted',
          assetsFromA: [
            TradeAsset.pick(
              pickId: 'history-2028',
              pickYear: 2028,
              pickRound: 1,
              originalTeamId: teamA.id,
            ).toSnapshot(),
          ],
        ),
      ],
    );
    final proposal = TradeProposal(
      teamAId: teamA.id,
      teamBId: teamB.id,
      assetsFromA: [
        TradeAsset.pick(
          pickId: picks[0].id,
          pickYear: 2027,
          pickRound: 1,
          originalTeamId: teamA.id,
        ),
        TradeAsset.pick(
          pickId: picks[1].id,
          pickYear: 2028,
          pickRound: 1,
          originalTeamId: teamA.id,
        ),
      ],
      assetsFromB: const [],
    );

    final validation = TradeService().validateLeague(league, proposal);
    expect(validation.ok, isFalse);
    expect(validation.code, 'stepien');
  });

  test('roster exception permits an underfilled team only when it grows', () {
    final base = leagueAt();
    final a = base.teams[0].copyWith(
      roster: base.teams[0].roster.take(19).toList(),
    );
    final b = base.teams[1];
    final league = base.copyWith(teams: [a, b, ...base.teams.skip(2)]);
    final proposal = TradeProposal(
      teamAId: a.id,
      teamBId: b.id,
      assetsFromA: [TradeAsset.player(a.roster.first.id)],
      assetsFromB: [
        TradeAsset.player(b.roster[0].id),
        TradeAsset.player(b.roster[1].id),
      ],
    );

    final validation = TradeService().validateLeague(league, proposal);
    expect(validation.ok, isTrue);
  });

  test(
    'both underfilled teams and second-apron payroll increase are blocked',
    () {
      final base = leagueAt();
      final a = base.teams[0].copyWith(
        roster: base.teams[0].roster.take(19).toList(),
      );
      final b = base.teams[1].copyWith(
        roster: base.teams[1].roster.take(19).toList(),
      );
      final underfilled = base.copyWith(teams: [a, b, ...base.teams.skip(2)]);
      final rosterProposal = TradeProposal(
        teamAId: a.id,
        teamBId: b.id,
        assetsFromA: [TradeAsset.player(a.roster.first.id)],
        assetsFromB: [TradeAsset.player(b.roster.first.id)],
      );
      expect(
        TradeService().validateLeague(underfilled, rosterProposal).code,
        'bothRostersUnderMinimum',
      );

      final expensiveA = base.teams[0].copyWith(
        roster: [
          base.teams[0].roster.first.copyWith(
            contract: base.teams[0].roster.first.contract.copyWith(
              salary: 1000000,
            ),
          ),
          for (final player in base.teams[0].roster.skip(1))
            player.copyWith(
              contract: player.contract.copyWith(salary: 20000000),
            ),
        ],
      );
      final expensiveB = base.teams[1].copyWith(
        roster: [
          base.teams[1].roster.first.copyWith(
            contract: base.teams[1].roster.first.contract.copyWith(
              salary: 20000000,
            ),
          ),
          ...base.teams[1].roster.skip(1),
        ],
      );
      final expensiveLeague = base.copyWith(
        teams: [expensiveA, expensiveB, ...base.teams.skip(2)],
      );
      final apronProposal = TradeProposal(
        teamAId: expensiveA.id,
        teamBId: expensiveB.id,
        assetsFromA: [TradeAsset.player(expensiveA.roster.first.id)],
        assetsFromB: [TradeAsset.player(expensiveB.roster.first.id)],
      );
      final apronValidation = TradeService().validateLeague(
        expensiveLeague,
        apronProposal,
      );
      expect(apronValidation.ok, isFalse);
      expect(apronValidation.code, 'salaryMatchingA');
    },
  );

  test(
    'NTC refusal leaves teams untouched and blocks only destination pair',
    () {
      final base = leagueAt();
      final a = base.teams[0];
      final b = base.teams[1];
      final ntcPlayer = a.roster.first.copyWith(
        contract: a.roster.first.contract.copyWith(
          noTradeClause: true,
          blockedTeamIds: const [],
        ),
      );
      final league = base.copyWith(
        teams: [
          a.copyWith(roster: [ntcPlayer, ...a.roster.skip(1)]),
          b,
          ...base.teams.skip(2),
        ],
      );
      final proposal = oneForOne(league);
      final service = TradeService(random: const _AlwaysRejectRandom());
      final created = service.createOffer(
        league,
        proposal,
        emitMessages: false,
      );
      final refused = service.acceptOffer(
        created.league,
        created.offerId!,
        actingTeamId: b.id,
        emitMessages: false,
      );

      expect(refused.outcome, 'ntcRefused');
      expect(refused.league.teams, league.teams);
      expect(
        refused.league.tradeOfferById(created.offerId!)?.status,
        TradeOfferStatus.ntcRefused,
      );
      expect(
        refused.league.ntcTradeBlocks.any(
          (block) =>
              block.playerId == ntcPlayer.id && block.destinationTeamId == b.id,
        ),
        isTrue,
      );
    },
  );

  test(
    'accepted transfer resets team tenure, Bird rights and NTC but keeps stats',
    () {
      final base = leagueAt();
      final a = base.teams[0];
      final b = base.teams[1];
      final source = a.roster.first;
      final prepared = source.copyWith(
        contract: source.contract.copyWith(
          hasBirdRights: true,
          noTradeClause: true,
          blockedTeamIds: const [],
        ),
        state: source.state.copyWith(seasonsWithTeam: 4),
      );
      final league = base.copyWith(
        teams: [
          a.copyWith(roster: [prepared, ...a.roster.skip(1)]),
          b,
          ...base.teams.skip(2),
        ],
      );
      final proposal = oneForOne(league);
      final service = TradeService(random: const _AlwaysAcceptRandom());
      final created = service.createOffer(
        league,
        proposal,
        emitMessages: false,
      );
      final accepted = service.acceptOffer(
        created.league,
        created.offerId!,
        actingTeamId: b.id,
        emitMessages: false,
      );
      final incoming = accepted.league
          .teamById(b.id)!
          .roster
          .firstWhere((player) => player.id == prepared.id);

      expect(accepted.outcome, 'accepted');
      expect(incoming.state.seasonsWithTeam, 0);
      expect(incoming.contract.hasBirdRights, isFalse);
      expect(incoming.contract.noTradeClause, isFalse);
      expect(incoming.seasonStats, prepared.seasonStats);
    },
  );
}
