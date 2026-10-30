@Tags(['unit'])
library;

import 'dart:collection';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/season.dart';
import 'package:new_football/core/services/contract_market_service.dart';

import '../helpers/fixtures/presentation_fixtures.dart';

void main() {
  final team = presentationTeam();
  final player = team.roster.first.copyWith(
    contract: team.roster.first.contract.copyWith(
      isRookieScale: true,
      lastSeason: 2026,
    ),
  );
  LeagueState leagueWith(Player value) => LeagueState(
    teams: [
      team.copyWith(roster: [value]),
    ],
    currentSeason: const Season(year: 2026),
    currentWeek: 46,
    currentDay: 2,
  );

  test('repeated lookups of the same snapshot do not scan sources again', () {
    final roster = _ReadCountingList<Player>([player]);
    final freeAgents = _ReadCountingList<Player>([player.copyWith(id: 'fa')]);
    final rights = _ReadCountingList<DraftedPlayerRights>([
      DraftedPlayerRights(
        id: 'rights',
        ownerTeamId: team.id,
        player: player.copyWith(id: 'rights-player'),
        draftYear: 2026,
        pickNumber: 1,
      ),
    ]);
    final league = leagueWith(player).copyWith(
      teams: [team.copyWith(roster: roster)],
      freeAgents: freeAgents,
      draftedRights: rights,
    );
    final market = ContractMarketService();
    void lookup(String id) {
      // A missing owner stops after lookup, before unrelated offer processing.
      expect(
        market.submitQualifyingOffer(
          league: league,
          ownerTeamId: 'missing-owner',
          playerId: id,
        ),
        isNull,
      );
    }

    lookup(player.id);
    final reads = [roster.reads, freeAgents.reads, rights.reads];
    expect(reads.every((count) => count > 0), isTrue);
    for (final id in [player.id, 'fa', 'rights-player', 'missing']) {
      lookup(id);
    }
    expect([roster.reads, freeAgents.reads, rights.reads], reads);
  });

  test('new snapshots and JSON reloads never return a stale player', () {
    final market = _RecordingMarket();
    final initial = leagueWith(player);
    void observe(LeagueState league, Player expected) {
      market.observed = null;
      market.submitQualifyingOffer(
        league: league,
        ownerTeamId: team.id,
        playerId: player.id,
      );
      expect(market.observed, expected);
    }

    observe(initial, player);
    final updated = player.copyWith(
      name: 'Updated',
      contract: player.contract.copyWith(
        salary: player.contract.salary + 1000000,
      ),
    );
    final next = leagueWith(updated);
    observe(next, updated);
    final reloaded = LeagueState.fromJson(
      jsonDecode(jsonEncode(next.toJson())) as Map<String, dynamic>,
    );
    observe(reloaded, updated);
    observe(initial, player);
    market.observed = null;
    expect(
      market.submitQualifyingOffer(
        league: initial.copyWith(teams: [team.copyWith(roster: [])]),
        ownerTeamId: team.id,
        playerId: player.id,
      ),
      isNull,
    );
    expect(market.observed, isNull);
  });

  test('duplicate IDs retain first roster precedence over other sources', () {
    final market = _RecordingMarket();
    final league = leagueWith(player).copyWith(
      teams: [
        team.copyWith(
          roster: [
            player,
            player.copyWith(name: 'Duplicate'),
          ],
        ),
      ],
      freeAgents: [player.copyWith(name: 'Free agent')],
      draftedRights: [
        DraftedPlayerRights(
          id: 'rights',
          ownerTeamId: team.id,
          player: player.copyWith(name: 'Rights'),
          draftYear: 2026,
          pickNumber: 1,
        ),
      ],
    );
    market.submitQualifyingOffer(
      league: league,
      ownerTeamId: team.id,
      playerId: player.id,
    );
    expect(market.observed, same(player));
  });
}

class _RecordingMarket extends ContractMarketService {
  Player? observed;

  @override
  int qualifyingOfferMinimum(Player player) {
    observed = player;
    return super.qualifyingOfferMinimum(player);
  }
}

class _ReadCountingList<T> extends ListBase<T> {
  _ReadCountingList(this.values);
  final List<T> values;
  int reads = 0;

  @override
  int get length => values.length;
  @override
  set length(int value) => throw UnsupportedError('read only');
  @override
  T operator [](int index) {
    reads++;
    return values[index];
  }

  @override
  void operator []=(int index, T value) => throw UnsupportedError('read only');
}
