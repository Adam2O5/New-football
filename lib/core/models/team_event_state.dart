import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_event_state.freezed.dart';
part 'team_event_state.g.dart';

/// A temporary team-level modifier. Values are additive to the base
/// multiplier for the named modifier (for example, `0.2` means +20%).
@freezed
abstract class TeamTimedModifier with _$TeamTimedModifier {
  const factory TeamTimedModifier({
    required String type,
    required double value,
    required int weeksRemaining,
  }) = _TeamTimedModifier;

  factory TeamTimedModifier.fromJson(Map<String, dynamic> json) =>
      _$TeamTimedModifierFromJson(json);
}

extension TeamTimedModifierX on TeamTimedModifier {
  bool get isActive => weeksRemaining > 0;

  TeamTimedModifier? decrementWeek() {
    if (weeksRemaining <= 1) return null;
    return copyWith(weeksRemaining: weeksRemaining - 1);
  }
}

/// One player's contribution to one team match in the six-week minutes
/// window. `possibleMinutes` is zero when the player was unavailable.
@freezed
abstract class MinutesHistoryEntry with _$MinutesHistoryEntry {
  const factory MinutesHistoryEntry({
    required String playerId,
    required int seasonYear,
    required int week,
    @Default(0) int minutes,
    @Default(90) int possibleMinutes,
  }) = _MinutesHistoryEntry;

  factory MinutesHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$MinutesHistoryEntryFromJson(json);
}

/// A promise made by the manager to a player after a more-minutes request.
/// Whole-season minutes accumulated for one player in the current club.
///
/// Unlike [MinutesHistoryEntry], this record is intentionally not a rolling
/// window. It is reset at season rollover and is used by season-long contract
/// extension rules.
@freezed
abstract class SeasonMinutesAggregate with _$SeasonMinutesAggregate {
  const factory SeasonMinutesAggregate({
    required String playerId,
    required int seasonYear,
    @Default(0) int actualMinutes,
    @Default(0) int possibleMinutes,
  }) = _SeasonMinutesAggregate;

  factory SeasonMinutesAggregate.fromJson(Map<String, dynamic> json) =>
      _$SeasonMinutesAggregateFromJson(json);
}

@freezed
abstract class TeamPromise with _$TeamPromise {
  const factory TeamPromise({
    required String id,
    required String playerId,
    required String kind,
    required int createdSeasonYear,
    required int createdWeek,
    @Default(0) int weeksElapsed,
    @Default(4) int durationWeeks,
    @Default(0.4) double requiredMinutesShare,
  }) = _TeamPromise;

  factory TeamPromise.fromJson(Map<String, dynamic> json) =>
      _$TeamPromiseFromJson(json);
}

/// An accepted transfer request waiting for the promised trade window to
/// produce a real trade.
@freezed
abstract class TeamTransferSituation with _$TeamTransferSituation {
  const factory TeamTransferSituation({
    required String id,
    required String playerId,
    required String kind,
    required int createdSeasonYear,
    required int createdWeek,
    @Default(4) int weeksRemaining,
  }) = _TeamTransferSituation;

  factory TeamTransferSituation.fromJson(Map<String, dynamic> json) =>
      _$TeamTransferSituationFromJson(json);
}

/// Persisted bookkeeping owned by the team-event system.
///
/// Stable string keys are intentional: old saves can deserialize newly added
/// event kinds without enum migrations.
@freezed
abstract class TeamEventState with _$TeamEventState {
  const factory TeamEventState({
    @Default([]) List<TeamPromise> promises,
    @Default([]) List<TeamTransferSituation> transferSituations,
    @Default([]) List<MinutesHistoryEntry> minutesHistory,
    @Default([]) List<SeasonMinutesAggregate> seasonMinutes,
    @Default([]) List<TeamTimedModifier> modifiers,
    @Default({}) Map<String, int> cooldowns,
    @Default({}) Map<String, int> seasonFlags,
    @Default({}) Map<String, double> pointValueMultipliers,
    @Default(1.0) double publicCriticismRollMultiplier,
    @Default(0) int lowAtmosphereWeeks,
  }) = _TeamEventState;

  factory TeamEventState.fromJson(Map<String, dynamic> json) =>
      _$TeamEventStateFromJson(json);
}

extension TeamEventStateX on TeamEventState {
  double modifierValue(String type) => modifiers
      .where((modifier) => modifier.type == type && modifier.isActive)
      .fold(0.0, (sum, modifier) => sum + modifier.value);

  double get negativeEventMultiplier =>
      (1.0 + modifierValue('negativeEventMultiplier')).clamp(0.5, 2.0);

  bool hasModifier(String type) =>
      modifiers.any((modifier) => modifier.type == type && modifier.isActive);

  TeamTimedModifier? modifierOf(String type) {
    for (final modifier in modifiers.reversed) {
      if (modifier.type == type && modifier.isActive) return modifier;
    }
    return null;
  }

  TeamEventState addModifier({
    required String type,
    required double value,
    required int weeks,
  }) {
    if (weeks <= 0 || value == 0) return this;
    return copyWith(
      modifiers: [
        ...modifiers,
        TeamTimedModifier(type: type, value: value, weeksRemaining: weeks),
      ],
    );
  }

  TeamEventState advanceWeek() {
    final nextModifiers = <TeamTimedModifier>[];
    for (final modifier in modifiers) {
      final next = modifier.decrementWeek();
      if (next != null) nextModifiers.add(next);
    }
    final nextCooldowns = <String, int>{};
    for (final entry in cooldowns.entries) {
      if (entry.value > 1) nextCooldowns[entry.key] = entry.value - 1;
    }
    return copyWith(modifiers: nextModifiers, cooldowns: nextCooldowns);
  }

  TeamEventState withCooldown(String event, int weeks) {
    final next = {...cooldowns};
    if (weeks <= 0) {
      next.remove(event);
    } else {
      next[event] = weeks;
    }
    return copyWith(cooldowns: next);
  }

  bool isOnCooldown(String event) => (cooldowns[event] ?? 0) > 0;

  TeamEventState withSeasonFlag(String key, int seasonYear) =>
      copyWith(seasonFlags: {...seasonFlags, key: seasonYear});

  bool hasSeasonFlag(String key, int seasonYear) =>
      seasonFlags[key] == seasonYear;

  double pointValueMultiplierFor(String playerId) =>
      pointValueMultipliers[playerId] ?? 1.0;

  TeamEventState withPointValueMultiplier(String playerId, double multiplier) {
    final next = {...pointValueMultipliers};
    if (multiplier == 1.0) {
      next.remove(playerId);
    } else {
      next[playerId] = multiplier.clamp(0.5, 1.0).toDouble();
    }
    return copyWith(pointValueMultipliers: next);
  }

  TeamEventState clearPointValueMultiplier(String playerId) {
    final next = {...pointValueMultipliers}..remove(playerId);
    return copyWith(pointValueMultipliers: next);
  }

  TeamPromise? promiseFor(String playerId, {String? kind}) {
    for (final promise in promises) {
      if (promise.playerId == playerId &&
          (kind == null || promise.kind == kind)) {
        return promise;
      }
    }
    return null;
  }

  TeamTransferSituation? transferSituationFor(String playerId) {
    for (final situation in transferSituations) {
      if (situation.playerId == playerId) return situation;
    }
    return null;
  }

  /// Adds match entries and retains exactly the current and previous five
  /// calendar weeks. The numeric key also works across a season boundary.
  TeamEventState recordMinutes(
    Iterable<MinutesHistoryEntry> entries, {
    required int currentSeasonYear,
    required int currentWeek,
  }) {
    final entryList = entries.toList();
    final all = [...minutesHistory, ...entryList];
    final currentKey = currentSeasonYear * 52 + currentWeek;
    final retained = all.where((entry) {
      final key = entry.seasonYear * 52 + entry.week;
      return key <= currentKey && key >= currentKey - 5;
    }).toList();

    // Keep the event history rolling, but aggregate the same match entries
    // for the whole current season separately. The map also normalizes any
    // duplicate rows that may have come from an older in-memory state.
    final aggregates = <String, SeasonMinutesAggregate>{
      for (final aggregate in seasonMinutes)
        if (aggregate.seasonYear == currentSeasonYear)
          aggregate.playerId: aggregate,
    };
    for (final entry in entryList.where(
      (entry) => entry.seasonYear == currentSeasonYear,
    )) {
      final previous = aggregates[entry.playerId];
      aggregates[entry.playerId] = previous == null
          ? SeasonMinutesAggregate(
              playerId: entry.playerId,
              seasonYear: entry.seasonYear,
              actualMinutes: entry.minutes,
              possibleMinutes: entry.possibleMinutes,
            )
          : previous.copyWith(
              actualMinutes: previous.actualMinutes + entry.minutes,
              possibleMinutes: previous.possibleMinutes + entry.possibleMinutes,
            );
    }

    return copyWith(
      minutesHistory: retained,
      seasonMinutes: aggregates.values.toList(),
    );
  }

  SeasonMinutesAggregate? seasonMinutesFor(String playerId) {
    for (final aggregate in seasonMinutes.reversed) {
      if (aggregate.playerId == playerId) return aggregate;
    }
    return null;
  }

  TeamEventState clearPlayer(String playerId) => clearPlayers({playerId});

  TeamEventState clearPlayers(Set<String> playerIds) => copyWith(
    promises: promises
        .where((promise) => !playerIds.contains(promise.playerId))
        .toList(),
    transferSituations: transferSituations
        .where((situation) => !playerIds.contains(situation.playerId))
        .toList(),
    minutesHistory: minutesHistory
        .where((entry) => !playerIds.contains(entry.playerId))
        .toList(),
    seasonMinutes: seasonMinutes
        .where((entry) => !playerIds.contains(entry.playerId))
        .toList(),
    pointValueMultipliers: Map<String, double>.from(pointValueMultipliers)
      ..removeWhere((playerId, _) => playerIds.contains(playerId)),
  );

  TeamEventState resetForSeason() => copyWith(
    promises: const [],
    transferSituations: const [],
    minutesHistory: const [],
    seasonMinutes: const [],
    modifiers: const [],
    cooldowns: const {},
    seasonFlags: const {},
    pointValueMultipliers: const {},
    publicCriticismRollMultiplier: 1.0,
    lowAtmosphereWeeks: 0,
  );
}
