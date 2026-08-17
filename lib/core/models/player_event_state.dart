import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:new_football/core/models/injury.dart';

part 'player_event_state.freezed.dart';
part 'player_event_state.g.dart';

/// A temporary individual-player effect.
///
/// Values are additive unless the consuming service documents a different
/// interpretation for a modifier type. The duration is measured in weekly
/// ticks and is decremented by [PlayerEventState.advanceWeek].
@freezed
abstract class TimedModifier with _$TimedModifier {
  const factory TimedModifier({
    required String type,
    required double value,
    required int weeksRemaining,
  }) = _TimedModifier;

  factory TimedModifier.fromJson(Map<String, dynamic> json) =>
      _$TimedModifierFromJson(json);
}

extension TimedModifierX on TimedModifier {
  bool get isActive => weeksRemaining > 0;

  /// Returns the modifier after one weekly tick, or `null` when it expires.
  TimedModifier? decrementWeek() {
    if (weeksRemaining <= 1) return null;
    return copyWith(weeksRemaining: weeksRemaining - 1);
  }
}

/// Persisted per-player bookkeeping for the individual event system.
///
/// The maps intentionally use stable event/modifier keys instead of enums so
/// that adding a new event does not make older JSON saves unreadable.
@freezed
abstract class PlayerEventState with _$PlayerEventState {
  const factory PlayerEventState({
    @Default([]) List<TimedModifier> modifiers,
    @Default({}) Map<String, int> cooldowns,
    @Default({}) Map<String, int> counters,
    @Default(false) bool lateBloomerTriggered,
    Injury? lastMajorInjury,
    @Default(false) bool majorInjuryActiveLastTick,
    @Default(0) int weeksSinceMajorInjury,
    @Default(false) bool personalProblemsFollowUpPending,
  }) = _PlayerEventState;

  factory PlayerEventState.fromJson(Map<String, dynamic> json) =>
      _$PlayerEventStateFromJson(json);
}

extension PlayerEventStateX on PlayerEventState {
  /// Sum of all active modifiers with [type].
  double modifierValue(String type) => modifiers
      .where((modifier) => modifier.type == type && modifier.isActive)
      .fold(0.0, (sum, modifier) => sum + modifier.value);

  bool hasModifier(String type) =>
      modifiers.any((modifier) => modifier.type == type && modifier.isActive);

  TimedModifier? modifierOf(String type) {
    for (final modifier in modifiers.reversed) {
      if (modifier.type == type && modifier.isActive) return modifier;
    }
    return null;
  }

  /// Adds one independent effect. Independent entries make event history
  /// deterministic and allow overlapping effects to stack additively.
  PlayerEventState addModifier({
    required String type,
    required double value,
    required int weeks,
  }) {
    if (weeks <= 0 || value == 0) return this;
    return copyWith(
      modifiers: [
        ...modifiers,
        TimedModifier(type: type, value: value, weeksRemaining: weeks),
      ],
    );
  }

  PlayerEventState withCooldown(String event, int weeks) {
    final next = {...cooldowns};
    if (weeks <= 0) {
      next.remove(event);
    } else {
      next[event] = weeks;
    }
    return copyWith(cooldowns: next);
  }

  PlayerEventState withCounter(String counter, int value) {
    final next = {...counters};
    if (value == 0) {
      next.remove(counter);
    } else {
      next[counter] = value;
    }
    return copyWith(counters: next);
  }

  int counterValue(String counter) => counters[counter] ?? 0;

  PlayerEventState shortenModifiers(String type, int maxWeeks) => copyWith(
    modifiers: [
      for (final modifier in modifiers)
        modifier.type == type && modifier.weeksRemaining > maxWeeks
            ? modifier.copyWith(weeksRemaining: maxWeeks)
            : modifier,
    ],
  );

  bool isOnCooldown(String event) => (cooldowns[event] ?? 0) > 0;

  /// Decrements all timed modifiers and cooldowns exactly once.
  PlayerEventState advanceWeek() {
    final nextModifiers = <TimedModifier>[];
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

  /// Explicit alias used by callers that only want to express expiry.
  PlayerEventState expireModifiers() => advanceWeek();
}
