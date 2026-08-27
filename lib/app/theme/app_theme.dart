import 'package:flutter/material.dart';

import 'package:new_football/app/branding/club_color_tokens.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    return _fromScheme(
      ColorScheme.fromSeed(
        seedColor: Colors.green.shade800,
        brightness: Brightness.dark,
      ),
    );
  }

  /// Dark Material theme seeded with a club's exact primary and secondary.
  static ThemeData forClub({
    required Color primary,
    required Color secondary,
  }) {
    final generated = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    );
    final onPrimary = foregroundFor(primary);
    final onSecondary = foregroundFor(secondary);
    final scheme = generated.copyWith(
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      primaryContainer: Color.alphaBlend(
        primary.withValues(alpha: 0.32),
        generated.surfaceContainerHigh,
      ),
      onPrimaryContainer: onPrimary,
      secondaryContainer: Color.alphaBlend(
        secondary.withValues(alpha: 0.28),
        generated.surfaceContainerHigh,
      ),
      onSecondaryContainer: onSecondary,
    );
    return _fromScheme(
      scheme,
      appBarBackground: primary,
      appBarForeground: onPrimary,
      navigationBackground: Color.alphaBlend(
        primary.withValues(alpha: 0.22),
        scheme.surfaceContainerHighest,
      ),
      navigationIndicator: Color.alphaBlend(
        secondary.withValues(alpha: 0.55),
        scheme.surfaceContainerHighest,
      ),
    );
  }

  static ThemeData _fromScheme(
    ColorScheme scheme, {
    Color? appBarBackground,
    Color? appBarForeground,
    Color? navigationBackground,
    Color? navigationIndicator,
  }) {
    final barBackground =
        appBarBackground ?? scheme.surfaceContainerHighest;
    final barForeground = appBarForeground ?? scheme.onSurface;
    final navBackground =
        navigationBackground ?? scheme.surfaceContainerHighest;
    final navIndicator = navigationIndicator ?? scheme.primaryContainer;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF0E1510),
      appBarTheme: AppBarTheme(
        backgroundColor: barBackground,
        foregroundColor: barForeground,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHigh,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.45),
        space: 1,
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: scheme.onSurface,
        unselectedLabelColor: scheme.onSurfaceVariant,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navBackground,
        indicatorColor: navIndicator,
        iconTheme: navigationIndicator == null
            ? null
            : WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return IconThemeData(
                  color: selected
                      ? foregroundFor(navIndicator)
                      : scheme.onSurfaceVariant,
                );
              }),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 11, color: scheme.onSurface),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
