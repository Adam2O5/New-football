import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/services/negotiation_service.dart';

import 'support/game_fixtures.dart';

const _service = NegotiationService();

ContractNegotiation _record(String id, {int startYear = 2026}) =>
    _service.start(
      id: id,
      subjectId: id,
      subjectKind: NegotiationSubjectKind.player,
      teamId: 'team',
      phase: NegotiationPhase.contractExtension,
      offer: const NegotiationOffer(salary: 1000000, years: 1),
      seasonYear: startYear,
      week: 1,
      day: 1,
    );

GameMessage _message(String id) => GameMessage(
  id: id,
  type: MessageType.contractSigned,
  seasonYear: 2026,
  week: 1,
  titleKey: 'history',
  bodyKey: 'history',
  payload: {'negotiationId': id},
);

void main() {
  test(
    'terminal retention starts at completion and survives save decoding',
    () {
      var league = controllerSave().leagueState;
      league = league.copyWith(
        currentSeason: league.currentSeason.copyWith(year: 2028),
      );
      league = league.upsertNegotiation(
        _record('late').copyWith(status: NegotiationStatus.completed),
      );
      expect(league.negotiations.single.terminalSeasonYear, 2028);
      league = GameSave.fromJson(
        jsonDecode(jsonEncode(saveForLeague(league).toJson()))
            as Map<String, dynamic>,
      ).leagueState;
      expect(league.negotiations.single.terminalSeasonYear, 2028);
      league = _service.pruneHistory(
        league,
        seasonYear: 2029,
        week: 52,
        day: 7,
      );
      expect(league.negotiations, hasLength(1));
      league = _service.pruneHistory(league, seasonYear: 2030, week: 1, day: 1);
      expect(league.negotiations, isEmpty);
    },
  );

  test(
    'inbox, scheduled, archive, RFA and pending work protect old records',
    () {
      var league = controllerSave().leagueState;
      league = league.copyWith(
        negotiations: [
          _record('drop-rival').copyWith(
            status: NegotiationStatus.cancelled,
            selectedByRival: true,
            terminalSeasonYear: 2026,
          ),
          for (final id in ['inbox', 'scheduled', 'archive', 'rfa', 'drop'])
            _record(id).copyWith(
              status: NegotiationStatus.completed,
              terminalSeasonYear: 2026,
            ),
          for (final status in [
            NegotiationStatus.active,
            NegotiationStatus.waiting,
            NegotiationStatus.counter,
            NegotiationStatus.pendingFinalization,
          ])
            _record(status.name).copyWith(status: status),
        ],
        inbox: Inbox(
          messages: [_message('inbox')],
          scheduled: [_message('scheduled')],
          archive: [_message('archive')],
        ),
        rfaOfferSheets: [
          const RfaOfferSheet(
            id: 'rfa-sheet',
            playerId: 'rfa',
            originalTeamId: 'original',
            offeringTeamId: 'rival',
            salary: 1,
            years: 1,
            phase: NegotiationPhase.freeAgencyPhaseII,
            seasonYear: 2030,
            week: 48,
            expirySeasonYear: 2030,
            expiryWeek: 48,
          ),
        ],
      );
      final inbox = league.inbox;
      league = _service.pruneHistory(league, seasonYear: 2030, week: 1, day: 1);
      expect(league.negotiations.map((n) => n.id), isNot(contains('drop')));
      expect(
        league.negotiations.map((n) => n.id),
        isNot(contains('drop-rival')),
      );
      expect(league.negotiations, hasLength(8));
      expect(league.inbox, same(inbox));
      expect(league.inbox.messages.single.payload['negotiationId'], 'inbox');
      league = league.copyWith(inbox: const Inbox(), rfaOfferSheets: []);
      league = _service.pruneHistory(league, seasonYear: 2030, week: 1, day: 1);
      expect(league.negotiations, hasLength(4));
      expect(league.negotiations.every((n) => !n.isTerminal), isTrue);
    },
  );

  test('blocks remain effective at the exact inclusive deadline', () {
    var league = controllerSave().leagueState.copyWith(
      negotiationBlocks: [
        const NegotiationBlock(
          subjectId: 'player',
          subjectKind: NegotiationSubjectKind.player,
          teamId: 'team',
          untilSeasonYear: 2026,
          untilWeek: 2,
          untilDay: 1,
          untilHour: 3,
        ),
      ],
    );
    league = _service.pruneHistory(
      league,
      seasonYear: 2026,
      week: 2,
      day: 1,
      hour: 3,
    );
    expect(league.negotiationBlocks, hasLength(1));
    expect(
      _service.isBlocked(
        league: league,
        subjectId: 'player',
        subjectKind: NegotiationSubjectKind.player,
        teamId: 'team',
        seasonYear: 2026,
        week: 2,
        day: 1,
        hour: 3,
      ),
      isTrue,
    );
    league = _service.pruneHistory(
      league,
      seasonYear: 2026,
      week: 2,
      day: 1,
      hour: 4,
    );
    expect(league.negotiationBlocks, isEmpty);
  });

  test('expiry stamps terminal year and maintenance does not reset it', () {
    var league = controllerSave().leagueState.copyWith(
      negotiations: [_record('expires')],
    );
    league = _service.expireAt(
      league: league,
      seasonYear: 2027,
      week: 1,
      day: 1,
    );
    expect(league.negotiations.single.terminalSeasonYear, 2027);
    league = _service.expireAt(
      league: league,
      seasonYear: 2028,
      week: 1,
      day: 1,
    );
    expect(league.negotiations.single.terminalSeasonYear, 2027);
    league = _service.expireAt(
      league: league,
      seasonYear: 2029,
      week: 1,
      day: 1,
    );
    expect(league.negotiations, isEmpty);
  });

  test('controlled 1/5/10-season market growth, no AI or match engine', () {
    var before = controllerSave().leagueState;
    var after = before;
    final samples = <Map<String, int>>[];
    for (var season = 1; season <= 10; season++) {
      final year = 2025 + season;
      before = before.copyWith(
        currentSeason: before.currentSeason.copyWith(year: year),
      );
      after = after.copyWith(
        currentSeason: after.currentSeason.copyWith(year: year),
      );
      for (var i = 0; i < 100; i++) {
        final record = _record(
          'neg-$year-$i',
          startYear: year,
        ).copyWith(status: NegotiationStatus.completed);
        final block = _service.blockFor(
          subjectId: record.subjectId,
          subjectKind: record.subjectKind,
          teamId: record.teamId,
          seasonYear: year,
          week: 1,
          day: 1,
        );
        before = before.upsertNegotiation(record).addNegotiationBlock(block);
        after = after.upsertNegotiation(record).addNegotiationBlock(block);
      }
      after = _service.pruneHistory(after, seasonYear: year, week: 52, day: 7);
      if ([1, 5, 10].contains(season)) {
        samples.add({
          'seasons': season,
          'before_negotiations': before.negotiations.length,
          'after_negotiations': after.negotiations.length,
          'before_blocks': before.negotiationBlocks.length,
          'after_blocks': after.negotiationBlocks.length,
          'before_payload_bytes': utf8
              .encode(jsonEncode(before.toJson()))
              .length,
          'after_payload_bytes': utf8.encode(jsonEncode(after.toJson())).length,
        });
      }
    }
    expect(after.negotiations, hasLength(200));
    expect(after.negotiationBlocks, isEmpty);
    expect(before.negotiations, hasLength(1000));
    debugPrint(
      jsonEncode({
        'controlled_market': samples,
        'annual_input':
            '100 distinct terminal negotiations and blocks; no messages',
        'retention':
            'completion season + following season; referenced records exempt',
      }),
    );
  });
}
