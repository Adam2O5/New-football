import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeKey = 'app_locale';
const urgentInterruptionSettingKey = 'urgent_interruption_setting';
const defaultUrgentInterruptionSetting = true;
const defaultLocale = Locale('pl');
const supportedAppLocales = [Locale('pl'), Locale('en')];

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden before use',
  );
});

/// Raised when the urgent-interruption preference cannot be persisted.
///
/// The controller publishes a new state only after [SharedPreferences.setBool]
/// reports success, so callers can use this exception to keep displaying the
/// previous successfully persisted value.
class UrgentInterruptionSettingWriteException implements Exception {
  UrgentInterruptionSettingWriteException({
    required this.value,
    this.cause,
    this.stackTrace,
  });

  final bool value;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() =>
      'UrgentInterruptionSettingWriteException: failed to persist '
      'urgent interruption setting=$value'
      '${cause == null ? '' : ' ($cause)'}';
}

class UrgentInterruptionSettingController extends StateNotifier<bool> {
  UrgentInterruptionSettingController(this._prefs)
    : super(_readInitialSetting(_prefs));

  final SharedPreferences _prefs;

  // Each write waits for the previous one, including a failed write. This
  // keeps I/O order and publication order identical without losing the error
  // returned to the caller of the failed operation.
  Future<void> _writeQueue = Future<void>.value();

  static bool _readInitialSetting(SharedPreferences prefs) {
    try {
      final rawValue = prefs.get(urgentInterruptionSettingKey);
      return rawValue is bool ? rawValue : defaultUrgentInterruptionSetting;
    } catch (_) {
      return defaultUrgentInterruptionSetting;
    }
  }

  Future<void> setUrgentInterruption(bool value) {
    final operation = _writeQueue.then<void>((_) => _persist(value));

    // Keep the queue usable after a failed operation while returning the
    // original failed future to the caller.
    _writeQueue = operation.catchError((Object _) {});
    return operation;
  }

  Future<void> _persist(bool value) async {
    late final bool didWrite;
    try {
      didWrite = await _prefs.setBool(urgentInterruptionSettingKey, value);
    } catch (error, stackTrace) {
      throw UrgentInterruptionSettingWriteException(
        value: value,
        cause: error,
        stackTrace: stackTrace,
      );
    }

    if (!didWrite) {
      throw UrgentInterruptionSettingWriteException(
        value: value,
        cause: StateError('SharedPreferences.setBool returned false'),
        stackTrace: StackTrace.current,
      );
    }

    state = value;
  }
}

final urgentInterruptionSettingProvider =
    StateNotifierProvider<UrgentInterruptionSettingController, bool>((ref) {
      return UrgentInterruptionSettingController(
        ref.watch(sharedPreferencesProvider),
      );
    });

class LocaleController extends StateNotifier<Locale> {
  LocaleController(this._prefs) : super(_readInitialLocale(_prefs));

  final SharedPreferences _prefs;

  static Locale _readInitialLocale(SharedPreferences prefs) {
    final code = prefs.getString(_localeKey);
    return supportedAppLocales.firstWhere(
      (l) => l.languageCode == code,
      orElse: () => defaultLocale,
    );
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedAppLocales.contains(locale)) return;
    state = locale;
    await _prefs.setString(_localeKey, locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController(ref.watch(sharedPreferencesProvider));
});
