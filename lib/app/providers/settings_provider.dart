import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeKey = 'app_locale';
const defaultLocale = Locale('pl');
const supportedAppLocales = [Locale('pl'), Locale('en')];

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden before use',
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
