import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// A deterministic in-memory [SharedPreferences] implementation for provider
/// tests.
///
/// The fixture intentionally keeps values outside any game-save fixture, so it
/// can be supplied directly to `sharedPreferencesProvider.overrideWithValue`.
/// [initialValues] may omit a key, contain either boolean, or contain an
/// arbitrary value to exercise invalid stored types. Set [readException] to
/// make reads fail without changing the stored values.
///
/// `setBool` can be controlled independently from reads. Set
/// [setBoolResult] to `false` or provide [setBoolException] to exercise failed
/// writes. [setBoolDelay], [waitForSetBool], and [setBoolRelease] provide a
/// deterministic asynchronous boundary for testing serialized writes.
class PreferencesTestDouble implements SharedPreferences {
  PreferencesTestDouble({
    Map<String, Object?> initialValues = const <String, Object?>{},
    this.readException,
    this.setBoolResult = true,
    this.setBoolException,
    this.setBoolDelay = Duration.zero,
    this.waitForSetBool = false,
    Completer<void>? setBoolRelease,
  }) : _values = Map<String, Object?>.from(initialValues),
       _setBoolRelease = setBoolRelease ?? Completer<void>();

  final Map<String, Object?> _values;
  final Completer<void> _firstSetBoolStarted = Completer<void>();
  final Completer<void> _setBoolRelease;

  /// An exception thrown by every read operation when non-null.
  Object? readException;

  /// The result returned by a successful controlled `setBool` call.
  bool setBoolResult;

  /// An exception thrown by `setBool` when non-null.
  Object? setBoolException;

  /// Optional delay applied before a controlled `setBool` completes.
  Duration setBoolDelay;

  /// Whether controlled `setBool` calls wait for [releaseSetBool].
  bool waitForSetBool;

  /// Number of `setBool` calls received by this fixture.
  int setBoolCallCount = 0;

  /// Values attempted through `setBool`, in call order.
  final List<bool> attemptedSetBoolValues = <bool>[];

  /// Keys attempted through `setBool`, in call order.
  final List<String> attemptedSetBoolKeys = <String>[];

  /// Completes when the first `setBool` call reaches the fixture.
  Future<void> get firstSetBoolStarted => _firstSetBoolStarted.future;

  /// The gate used by calls configured with [waitForSetBool].
  Completer<void> get setBoolRelease => _setBoolRelease;

  /// A snapshot of the values currently considered persisted by this double.
  Map<String, Object?> get values => Map<String, Object?>.unmodifiable(_values);

  /// Returns the raw value currently held for [key], including `null`.
  Object? valueFor(String key) => _values[key];

  /// Adds or replaces a raw value for tests that need to change the backing
  /// store between controller constructions. `null` represents a stored value
  /// that is invalid for a boolean preference, while omitting the key models a
  /// missing preference.
  void seed(String key, Object? value) {
    _values[key] = value;
  }

  /// Removes [key] from the backing store to model a missing preference.
  void removeSeed(String key) {
    _values.remove(key);
  }

  /// Releases all currently waiting controlled `setBool` calls.
  void releaseSetBool() {
    if (!_setBoolRelease.isCompleted) {
      _setBoolRelease.complete();
    }
  }

  /// Alias matching the release terminology used by other test doubles.
  void release() {
    releaseSetBool();
  }

  @override
  Set<String> getKeys() {
    _throwIfReadFails();
    return Set<String>.from(_values.keys);
  }

  @override
  Object? get(String key) {
    _throwIfReadFails();
    return _values[key];
  }

  @override
  bool? getBool(String key) {
    _throwIfReadFails();
    return _values[key] as bool?;
  }

  @override
  int? getInt(String key) {
    _throwIfReadFails();
    return _values[key] as int?;
  }

  @override
  double? getDouble(String key) {
    _throwIfReadFails();
    return _values[key] as double?;
  }

  @override
  String? getString(String key) {
    _throwIfReadFails();
    return _values[key] as String?;
  }

  @override
  bool containsKey(String key) {
    _throwIfReadFails();
    return _values.containsKey(key);
  }

  @override
  List<String>? getStringList(String key) {
    _throwIfReadFails();
    final list = _values[key] as List<dynamic>?;
    return list?.cast<String>().toList();
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    setBoolCallCount++;
    attemptedSetBoolKeys.add(key);
    attemptedSetBoolValues.add(value);
    if (!_firstSetBoolStarted.isCompleted) {
      _firstSetBoolStarted.complete();
    }

    if (setBoolDelay > Duration.zero) {
      await Future<void>.delayed(setBoolDelay);
    }
    if (waitForSetBool) {
      await _setBoolRelease.future;
    }
    final exception = setBoolException;
    if (exception != null) {
      throw exception;
    }
    if (!setBoolResult) {
      return false;
    }

    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _values[key] = value.toList();
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _values.clear();
    return true;
  }

  @override
  Future<void> reload() async {}

  @override
  @Deprecated('This method is now a no-op, and should no longer be called.')
  Future<bool> commit() async => true;

  void _throwIfReadFails() {
    final exception = readException;
    if (exception != null) {
      throw exception;
    }
  }
}

/// Name used by the specification glossary for [PreferencesTestDouble].
// ignore: camel_case_types
typedef Preferences_Test_Double = PreferencesTestDouble;
