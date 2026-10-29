import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/app/utils/staff_presentation.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/negotiation_rules.dart';
import 'package:new_football/core/services/negotiation_service.dart';
import 'package:new_football/core/services/staff_service.dart';

import '../staff_role_ratings_test_helpers.dart';

part 'staff_negotiation_cases.dart';
part 'staff_negotiation_checks.dart';
part 'staff_negotiation_oracle.dart';

const _propertyTag =
    'Feature: staff-role-ratings, Property 9: jeden raw path negocjacji';
const _casesPerRole = 18;
const _propertySeed = staffFixtureSeed + 7099;
const _collisionLowRaw = 3.25;
const _collisionHighRaw = 3.30;

const _phases = <NegotiationPhase>[
  NegotiationPhase.freeAgencyPhaseI,
  NegotiationPhase.freeAgencyPhaseII,
  NegotiationPhase.contractExtension,
];

void verifyStaffMarketScenarios(StaffRole role) {
  final seed = _seedFor(role);
  final scenarios = _scenariosForRole(role, seed);
  expect(scenarios, hasLength(_casesPerRole));
  expect(scenarios.map((s) => s.phase).toSet(), containsAll(_phases));
  expect(
    scenarios.map((s) => s.marketStatus).toSet(),
    containsAll(TeamStatus.values),
  );
  for (var index = 0; index < scenarios.length; index++) {
    final scenario = scenarios[index];
    final reason = _reason(scenario, caseIndex: index, seed: seed);
    final irrelevantName = irrelevantStaffAttributeNames(role).first;
    final irrelevantMember = scenario.member.copyWith(
      attributes: withIrrelevantStaffAttribute(
        scenario.member.attributes,
        role,
        name: irrelevantName,
        value:
            staffAttributeByName(scenario.member.attributes, irrelevantName) ==
                5
            ? 0
            : 5,
      ),
    );
    final irrelevantScenario = scenario.withMember(irrelevantMember);
    final market = _observeMarket(scenario, scenario.member);
    final irrelevantMarket = _observeMarket(
      irrelevantScenario,
      irrelevantMember,
    );
    _expectMarketEqual(
      market,
      irrelevantMarket,
      reason: '$reason: irrelevant subject mutation changed a persisted output',
    );
    expect(
      market.score,
      closeTo(
        _observeService(
          scenario,
          scenario.member,
          offeringStatus: scenario.marketStatus,
          currentStatus: scenario.marketStatus,
          cfo: scenario.marketCfo,
          round: 1,
          reactionSeed: _marketSubmissionSeed(scenario),
        ).score,
        1e-9,
      ),
      reason: '$reason: ContractMarketService persisted a non-canonical score',
    );

    _assertStaleRecompute(scenario, scenario.member, reason: reason);
    _assertWaitingCounter(scenario, scenario.member, reason: reason);
    // Replaying the same market request must not consume process-global/random
    // state: the persisted result is a pure function of the documented seed and
    // explicit offer/status/CFO/phase inputs.
    final replay = _observeMarket(scenario, scenario.member);
    _expectMarketEqual(
      market,
      replay,
      reason: '$reason: same seed/request did not replay identically',
    );
  }
}

void verifyStaffMarketCollision(StaffRole role) {
  final seed = _seedFor(role) + 100000;
  final low = _scenarioForRaw(
    role,
    raw: _collisionLowRaw,
    id: 'p9_collision_low_${role.name}',
    seed: seed,
  );
  final high = _scenarioForRaw(
    role,
    raw: _collisionHighRaw,
    id: 'p9_collision_high_${role.name}',
    seed: seed + 1,
  );
  final lowView = StaffPresentation.viewForMember(low.member).rating!;
  final highView = StaffPresentation.viewForMember(high.member).rating!;

  expect(
    lowView.displayedRating,
    highView.displayedRating,
    reason: _reason(low, caseIndex: -1, seed: seed),
  );
  expect(
    lowView.rawOverall,
    isNot(highView.rawOverall),
    reason:
        '${_reason(low, caseIndex: -1, seed: seed)}\nUI display must not replace RawOverall',
  );

  final lowDirect = _observeService(
    low,
    low.member,
    offeringStatus: low.marketStatus,
    currentStatus: low.marketStatus,
    cfo: low.marketCfo,
    round: 1,
    reactionSeed: low.seed,
  );
  final highDirect = _observeService(
    high,
    high.member,
    offeringStatus: high.marketStatus,
    currentStatus: high.marketStatus,
    cfo: high.marketCfo,
    round: 1,
    reactionSeed: high.seed,
  );
  expect(
    lowDirect.score,
    isNot(highDirect.score),
    reason:
        '${_reason(low, caseIndex: -1, seed: seed)}\nraw/display collision was collapsed by the direct score path',
  );
  _expectOffersDifferent(
    lowDirect.counter,
    highDirect.counter,
    reason:
        '${_reason(low, caseIndex: -1, seed: seed)}\nraw/display collision was collapsed by counter inputs',
    allowNullEquality: true,
  );

  final lowMarket = _observeMarket(low, low.member);
  final highMarket = _observeMarket(high, high.member);
  expect(
    lowMarket.score,
    isNot(highMarket.score),
    reason:
        '${_reason(low, caseIndex: -1, seed: seed)}\nContractMarketService consumed DisplayedRating',
  );
  expect(
    lowMarket.score,
    lowDirect.score,
    reason:
        '${_reason(low, caseIndex: -1, seed: seed)}\npersisted low score diverged from its raw direct path',
  );
  expect(
    highMarket.score,
    highDirect.score,
    reason:
        '${_reason(high, caseIndex: -1, seed: seed + 1)}\npersisted high score diverged from its raw direct path',
  );
}
