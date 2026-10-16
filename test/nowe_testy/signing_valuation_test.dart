import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/field_player_attributes.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/services/contract_service.dart';

import 'support/game_fixtures.dart';

class _CountedRoll implements Random {
  int rolls = 0;
  int intRolls = 0;
  @override
  double nextDouble() {
    rolls++;
    return 0;
  }

  @override
  bool nextBool() => false;
  @override
  int nextInt(int max) {
    intRolls++;
    return 0;
  }
}

void main() {
  const balance = BalanceConfig(
    player: PlayerBalance(
      outfieldOverallWeights: {
        Position.lb: OutfieldAttrWeights(
          pace: 1,
          shooting: 0,
          passing: 0,
          dribbling: 0,
          defending: 0,
          physicality: 0,
        ),
      },
    ),
  );
  for (final extension in [false, true]) {
    test(
      'signing updates valuation and payroll with injected balance (extension $extension)',
      () {
        final league = controllerSave().leagueState;
        final player = fullBacks().left.copyWith(
          age: 30,
          pointValue: 300,
          attributes: const PlayerAttributes.outfield(
            stats: FieldPlayerAttributes(
              pace: 90,
              shooting: 50,
              passing: 50,
              dribbling: 50,
              defending: 50,
              physicality: 50,
            ),
          ),
          state: fullBacks().left.state.copyWith(seasonsWithTeam: 4),
        );
        final team = league.playerTeam!.copyWith(
          roster: extension ? [player] : [],
        );
        final random = _CountedRoll();
        final signed = ContractService(balance: balance).signPlayer(
          team: team,
          player: player,
          offer: const ContractOffer(salary: 10000000, years: 3),
          seasonYear: 2026,
          week: 46,
          ntcRandom: random,
        )!;
        final result = signed.roster.single;
        expect(result.pointValue, result.computePointValue(balance));
        expect(result.pointValue, isNot(result.computePointValue()));
        expect(signed.finance.totalPayroll, result.contract.salary);
        expect(random.rolls, 1);
        expect(result.hidden, player.hidden);
      },
    );
  }
  test(
    'prospect conversion uses one balance without repeating development rolls',
    () {
      final prospect = seededLeague()
          .currentSeason
          .draftState!
          .draftClass
          .prospects
          .first
          .copyWith(
            position: Position.lb,
            attributes: const PlayerAttributes.outfield(
              stats: FieldPlayerAttributes(
                pace: 90,
                shooting: 50,
                passing: 50,
                dribbling: 50,
                defending: 50,
                physicality: 50,
              ),
            ),
          );
      final custom = BalanceConfig(
        player: balance.player,
        development: const DevelopmentBalance(
          determinationGrowthRates: [2.75],
          determinationOutcomeTable: [(0, 100)],
        ),
      );
      final random = _CountedRoll();
      final player = prospect.toPlayer(
        contract: const Contract(salary: 1000000, yearsRemaining: 2),
        rng: random,
        balance: custom,
      );
      expect(player.seasonStartOvr, 90);
      expect(player.pointValue, player.computePointValue(custom));
      expect(player.pointValue, isNot(player.computePointValue()));
      expect(player.hidden.growthRate, 2.75);
      expect(player.hidden.developmentOutcome, DevelopmentOutcome.hit);
      expect(player.hidden.developmentCeilingStars, prospect.potentialStars);
      expect(random.intRolls, 3);
      expect(random.rolls, 0);
    },
  );
}
