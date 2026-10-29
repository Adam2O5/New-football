@Tags(['unit'])
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/game_save.dart';
import '../../helpers/fixtures/game_fixtures.dart';

void main() {
  final examples =
      jsonDecode(
            File(
              'test/helpers/fixtures/model_examples.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  final models = examples['models'] as Map<String, dynamic>;
  final readers = <String, Object Function(Map<String, dynamic>)>{
    'Prospect': Prospect.fromJson,
    'DraftClass': DraftClass.fromJson,
    'MockDraftBoard': MockDraftBoard.fromJson,
    'LotteryResult': LotteryResult.fromJson,
    'DraftState': DraftState.fromJson,
    'CompletedDraft': CompletedDraft.fromJson,
    'PlayInProgress': PlayInProgress.fromJson,
    'PlayInResult': PlayInResult.fromJson,
    'PlayoffBracket': PlayoffBracket.fromJson,
    'Season': Season.fromJson,
    'SeasonHistory': SeasonHistory.fromJson,
  };
  for (final entry in readers.entries) {
    test('${entry.key}: representative JSON preserves every field', () {
      final json = models[entry.key] as Map<String, dynamic>;
      final original = jsonDecode(jsonEncode(json));
      final restored = entry.value(json);
      expect(jsonDecode(jsonEncode(restored)), original);
      expect(json, original, reason: 'Decoding must not mutate the fixture.');
    });
  }

  test(
    'prospect conversion preserves its recorded fields and RNG consumption',
    () {
      final prospect = Prospect.fromJson(
        models['Prospect'] as Map<String, dynamic>,
      );
      final random = Random(456);
      final converted = prospect.toPlayer(
        contract: const Contract(salary: 8000000, yearsRemaining: 2),
        rng: random,
        draftYear: 2026,
      );
      final expected = examples['conversion'] as Map<String, dynamic>;
      expect(jsonDecode(jsonEncode(converted)), expected['player']);
      expect(random.nextInt(1000000), expected['nextRandom']);
      expect(converted.name, prospect.name);
      expect(converted.position, prospect.position);
      expect(converted.draftYear, 2026);
    },
  );

  test(
    'missing optional fields start a fresh season and draft without stale state',
    () {
      final season = Season.fromJson({'year': 2030});
      expect(season.phase, SeasonPhase.preseason);
      expect(season.schedule, isEmpty);
      expect(season.playInResults, isEmpty);
      expect(season.draftState, isNull);
      expect(season.staffGrowthDone, isFalse);
      expect(season.scoutReportDone, isFalse);
      final draft = DraftState.fromJson({
        'year': 2030,
        'draftClass': {'year': 2030},
      });
      expect(draft.currentPickIndex, 0);
      expect(draft.order, isEmpty);
      expect(draft.completedPicks, isEmpty);
      expect(draft.mockDraftBoard, isNull);
      expect(draft.draftClass.prospects, isEmpty);
      final board = MockDraftBoard.fromJson({});
      expect(board.displayedRank, isEmpty);
      expect(board.previousDisplayedRank, isEmpty);
    },
  );

  test(
    'draft order, completed picks and lottery preserve their identities',
    () {
      final draft = DraftState.fromJson(
        models['DraftState'] as Map<String, dynamic>,
      );
      expect(draft.currentPickIndex, 1);
      expect(draft.order.single.id, 'split-pick');
      expect(draft.completedPicks.single.id, 'split-pick');
      expect(draft.order.single.teamId, 'club-a');
      expect(draft.order.single.originalTeamId, 'club-b');
      expect(draft.order.single.protectedTopN, 3);
      expect(draft.lotteryResults.single.originalRank, 4);
      expect(draft.lotteryResults.single.assignedPick, 2);
      expect(draft.lotteryResults.single.oddsForFirstPick, 0.125);
      final prospectId = draft.draftClass.prospects.single.id;
      expect(draft.mockDraftBoard!.displayedRank[prospectId], 1);
      expect(draft.mockDraftBoard!.previousDisplayedRank[prospectId], 2);
    },
  );

  test(
    'complete save preserves season, history and completed draft sections',
    () {
      final json =
          jsonDecode(jsonEncode(controllerSave().toJson()))
              as Map<String, dynamic>;
      final league = json['leagueState'] as Map<String, dynamic>;
      league['currentSeason'] = models['Season'];
      league['history'] = [models['SeasonHistory']];
      league['lastCompletedDraft'] = models['CompletedDraft'];
      final restored = GameSave.fromJson(json);
      expect(restored.schemaVersion, SaveSchema.currentVersion);
      expect(restored.leagueState.currentSeason.championTeamId, 'club-a');
      expect(restored.leagueState.history.single.championTeamId, 'club-a');
      expect(
        restored.leagueState.lastCompletedDraft!.completedPicks.single.id,
        'split-pick',
      );
      expect(jsonDecode(jsonEncode(restored.toJson())), json);
    },
  );
}
