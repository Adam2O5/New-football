import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/game_save.dart';

import 'support/stage_four_snapshot.dart';
import 'support/game_fixtures.dart';

void main() {
  late Map<String, dynamic> baseline;
  late Map<String, dynamic> actual;
  setUpAll(() {
    baseline =
        jsonDecode(File(stageFourBaselinePath).readAsStringSync())
            as Map<String, dynamic>;
    actual = stageFourSnapshot();
  });
  for (final section in ['models', 'conversion', 'balance', 'seeds']) {
    test('split preserves pre-refactor $section', () {
      expect(actual[section], baseline[section]);
    });
  }
  test(
    'all eleven types read JSON recorded before the split via old imports',
    () {
      final models = baseline['models'] as Map<String, dynamic>;
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
        final json = models[entry.key] as Map<String, dynamic>;
        final restored = entry.value(json);
        expect(jsonDecode(jsonEncode(restored)), json, reason: entry.key);
      }
      expect(identical(BalanceConfig.defaults, const BalanceConfig()), isTrue);
      expect(SaveSchema.currentVersion, 26);
    },
  );
  test('complete save reads the model sections recorded before the split', () {
    final json =
        jsonDecode(jsonEncode(controllerSave().toJson()))
            as Map<String, dynamic>;
    final league = json['leagueState'] as Map<String, dynamic>;
    final models = baseline['models'] as Map<String, dynamic>;
    league['currentSeason'] = models['Season'];
    league['history'] = [models['SeasonHistory']];
    league['lastCompletedDraft'] = models['CompletedDraft'];
    final restored = GameSave.fromJson(json);
    expect(jsonDecode(jsonEncode(restored.toJson())), json);
  });
}
