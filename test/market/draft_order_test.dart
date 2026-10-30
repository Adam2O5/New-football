@Tags(['unit'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/services/draft_service.dart';
import 'package:new_football/core/services/season_service.dart';

import '../helpers/fixtures/presentation_fixtures.dart';

void main() {
  const year = 2026;
  const draftClass = DraftClass(year: year);
  final template = presentationTeam();
  LeagueState fixture({int count = 30, bool existingClass = true}) =>
      LeagueState(
        teams: [
          for (var i = 0; i < count; i++)
            template.copyWith(id: 'team-$i', roster: [], ownedPicks: []),
        ],
        currentSeason: Season(
          year: year,
          phase: SeasonPhase.regular,
          draftState: existingClass
              ? const DraftState(year: year, draftClass: draftClass)
              : null,
          standings: [
            ConferenceStandings(
              conference: Conference.europe,
              standings: [
                for (var i = 0; i < count; i++)
                  Standing(
                    teamId: 'team-$i',
                    wins: i < 10 ? i : 20,
                    goalsFor: i,
                  ),
              ],
            ),
          ],
        ),
      );
  final lottery = [
    for (var i = 9; i >= 0; i--)
      LotteryResult(
        teamId: 'team-$i',
        originalRank: i + 1,
        assignedPick: 10 - i,
        oddsForFirstPick: 0.1,
      ),
  ];

  test('explicit lottery and tied standings retain all 90 numbered slots', () {
    final input = fixture();
    final result = DraftService().buildDraftOrder(
      input,
      lottery,
      saveSeed: 123,
    );
    final draft = result.currentSeason.draftState!;
    final expectedTeams = [
      for (var i = 9; i >= 0; i--) 'team-$i',
      for (var i = 29; i >= 10; i--) 'team-$i',
    ];
    expect(draft.order, hasLength(90));
    for (var round = 1; round <= 3; round++) {
      final picks = draft.order.skip((round - 1) * 30).take(30).toList();
      expect(picks.map((p) => p.originalTeamId), expectedTeams);
      expect(picks.map((p) => p.pickNumber), [
        for (var i = 1; i <= 30; i++) (round - 1) * 30 + i,
      ]);
      expect(picks.every((p) => p.round == round && p.year == year), isTrue);
      expect(picks.first.id, 'draftpick_2026_${round}_team-9');
    }
    expect(draft.draftClass, same(draftClass));
    expect(result.currentSeason.phase, SeasonPhase.regular);
    expect(input.currentSeason.draftState!.order, isEmpty);
  });

  for (final automatic in [false, true]) {
    test(
      '${automatic ? 'season' : 'interactive'} draft preserves traded picks and future assets',
      () {
        const traded = DraftPick(
          id: 'traded',
          year: year,
          round: 1,
          teamId: 'stale-owner',
          originalTeamId: 'team-0',
        );
        const future = DraftPick(
          id: 'future',
          year: year + 1,
          round: 1,
          teamId: 'team-29',
          originalTeamId: 'team-0',
        );
        final original = fixture();
        final input = original.updateTeam(
          original.teams.last.copyWith(ownedPicks: [traded, future]),
        );
        final result = automatic
            ? SeasonService().runLottery(input, saveSeed: 123)
            : DraftService().buildDraftOrder(input, lottery, saveSeed: 123);
        final draft = result.currentSeason.draftState!;
        final pick = draft.order.singleWhere((p) => p.id == 'traded');
        expect(pick.teamId, 'team-29');
        expect(pick.originalTeamId, 'team-0');
        expect(
          pick.pickNumber,
          draft.lotteryResults.indexWhere((l) => l.teamId == 'team-0') + 1,
        );
        expect(result.teams.last.ownedPicks, [future]);
        expect(input.teams.last.ownedPicks, [traded, future]);
        expect(draft.draftClass, same(draftClass));
        expect(
          result.currentSeason.phase,
          automatic ? SeasonPhase.offseason : SeasonPhase.regular,
        );
        if (automatic) {
          final interactive = DraftService().buildDraftOrder(
            input,
            draft.lotteryResults,
            saveSeed: 123,
          );
          expect(draft, interactive.currentSeason.draftState);
          expect(result.teams, interactive.teams);
          expect(result.inbox.pendingUrgent, isNotEmpty);
        }
      },
    );
  }

  test('missing class is generated identically in both seeded paths', () {
    final input = fixture(existingClass: false);
    final result = SeasonService().runLottery(input, saveSeed: 123);
    final draft = result.currentSeason.draftState!;
    final interactive = DraftService().buildDraftOrder(
      input,
      draft.lotteryResults,
      saveSeed: 123,
    );
    expect(draft.draftClass.prospects, isNotEmpty);
    expect(draft, interactive.currentSeason.draftState);
    expect(
      SeasonService().runLottery(input, saveSeed: 123).currentSeason.draftState,
      draft,
    );
  });

  test(
    'partial fixture retains repeated slots without changing league size',
    () {
      final result = DraftService().buildDraftOrder(
        fixture(count: 2),
        [],
        saveSeed: 123,
      );
      expect(result.teams, hasLength(2));
      final order = result.currentSeason.draftState!.order;
      expect(order, hasLength(90));
      expect(order.take(4).map((p) => p.originalTeamId), [
        'team-1',
        'team-0',
        'team-1',
        'team-0',
      ]);
    },
  );
}
