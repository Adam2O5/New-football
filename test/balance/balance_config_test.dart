import 'package:flutter_test/flutter_test.dart';
import 'package:new_football/core/balance/balance_config.dart';

void main() {
  const config = BalanceConfig.defaults;

  test('defaults expose the four Task 3 balance sections', () {
    expect(config.matchday, isA<MatchdayBalance>());
    expect(config.ai, isA<AiBalance>());
    expect(config.messages, isA<MessagesBalance>());
    expect(config.events, isA<EventsBalance>());
  });

  test('matchday defaults satisfy probability and range constraints', () {
    final matchday = config.matchday;
    for (final probability in <double>[
      matchday.shapeWeight,
      matchday.foulBase,
      matchday.yellowFromFoul,
      matchday.redDirect,
      matchday.injuryBase,
    ]) {
      _expectProbability(probability);
    }

    expect(matchday.duelSigma, greaterThan(0));
    expect(matchday.momentumDecay, greaterThan(0));
    expect(matchday.aerialClampMin, lessThan(matchday.aerialClampMax));
    expect(matchday.maxSubstitutions, greaterThan(0));
    expect(matchday.maxSubstitutionWindows, greaterThan(0));
  });

  test('AI defaults satisfy probability and range constraints', () {
    final ai = config.ai;
    for (final probability in <double>[
      ai.pSecondApronEntry,
      ai.pCounterFormation,
      ai.pTacticalMatchupAdjust,
      ai.pRoleOverride,
      ai.pOfferToUserRegular,
      ai.pOfferToUserOffseason,
      ai.pOfferToUserDeadline,
      ai.pDraftTradeUp,
      ai.scoutCoverageUsage,
      ai.pFaCompete,
      ai.staffCapUsageTargetMin,
      ai.staffCapUsageTargetMax,
      ai.pMatchOfferSheetTop11,
      ai.pRebuildAbsorbsContract,
    ]) {
      _expectProbability(probability);
    }

    expect(
      ai.staffCapUsageTargetMin,
      lessThanOrEqualTo(ai.staffCapUsageTargetMax),
    );
    expect(ai.evaluationNoiseSd, greaterThan(0));
    expect(ai.pickFutureDiscount, greaterThan(0));
  });

  test('message and event defaults satisfy range constraints', () {
    final messages = config.messages;
    expect(messages.digestMinItems, greaterThanOrEqualTo(1));
    expect(messages.maxUnreadInbox, greaterThanOrEqualTo(1));
    expect(messages.playerEventExpiryDaysMin, greaterThanOrEqualTo(1));
    expect(
      messages.playerEventExpiryDaysMin,
      lessThanOrEqualTo(messages.playerEventExpiryDaysMax),
    );
    expect(messages.teamEventExpiry, TeamEventExpiryMode.endOfDay);

    final events = config.events;
    for (final probability in <double>[
      events.minutesRequestChance,
      events.minutesRequestAmbitiousChance,
      events.transferRequestChance,
      events.lockerRoomConflictChance,
      events.leaderSupportChance,
      events.publicCriticismChance,
      events.breakthroughChance,
      events.coldStreakChance,
      events.majorInjuryComplicationChance,
      events.veteranMotivationChance,
      events.extraTrainingChance,
      events.personalProblemsChance,
      events.professionalPersonalProblemsChance,
      events.lateBloomerChance,
      events.recurringInjuryChance,
      events.inspiringPerformanceChance,
      events.majorInjuryPotentialLossChance,
    ]) {
      _expectProbability(probability);
    }

    expect(events.lowAtmosphereThreshold, inInclusiveRange(0, 100));
    expect(events.publicCriticismAtmosphereThreshold, inInclusiveRange(0, 100));
    expect(events.breakthroughProgressMin, inInclusiveRange(0, 100));
    expect(events.breakthroughFormMin, inInclusiveRange(1, 10));
    expect(events.coldStreakFormMax, inInclusiveRange(1, 10));
  });
}

void _expectProbability(double value) {
  expect(value, inInclusiveRange(0.0, 1.0));
}

Matcher inInclusiveRange(num min, num max) =>
    allOf(greaterThanOrEqualTo(min), lessThanOrEqualTo(max));
