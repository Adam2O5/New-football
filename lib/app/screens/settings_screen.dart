import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isSavingUrgentInterruption = false;
  bool _isSavingLegacyColorTheme = false;

  Future<void> _setUrgentInterruption(bool value) async {
    if (_isSavingUrgentInterruption) return;

    setState(() => _isSavingUrgentInterruption = true);
    try {
      await ref
          .read(urgentInterruptionSettingProvider.notifier)
          .setUrgentInterruption(value);
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.settings_urgentInterruptionWriteError)),
        );
    } finally {
      if (mounted) {
        setState(() => _isSavingUrgentInterruption = false);
      }
    }
  }

  Future<void> _setLegacyColorTheme(bool value) async {
    if (_isSavingLegacyColorTheme) return;

    setState(() => _isSavingLegacyColorTheme = true);
    try {
      await ref
          .read(legacyColorThemeSettingProvider.notifier)
          .setLegacyColorTheme(value);
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.settings_legacyColorThemeWriteError)),
        );
    } finally {
      if (mounted) {
        setState(() => _isSavingLegacyColorTheme = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final urgentInterruptionEnabled = ref.watch(
      urgentInterruptionSettingProvider,
    );
    final legacyColorThemeEnabled = ref.watch(legacyColorThemeSettingProvider);
    final urgentInterruptionDescription = urgentInterruptionEnabled
        ? l10n.settings_urgentInterruptionEnabledDescription
        : l10n.settings_urgentInterruptionDisabledDescription;
    final urgentInterruptionState = urgentInterruptionEnabled
        ? l10n.settings_urgentInterruptionEnabledLabel
        : l10n.settings_urgentInterruptionDisabledLabel;
    final legacyColorThemeDescription = legacyColorThemeEnabled
        ? l10n.settings_legacyColorThemeEnabledDescription
        : l10n.settings_legacyColorThemeDisabledDescription;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ScreenBackground(
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.settings_language,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SegmentedButton<Locale>(
                segments: [
                  ButtonSegment(
                    value: const Locale('pl'),
                    label: Text(l10n.settings_language_polish),
                  ),
                  ButtonSegment(
                    value: const Locale('en'),
                    label: Text(l10n.settings_language_english),
                  ),
                ],
                selected: {locale},
                onSelectionChanged: (selection) {
                  ref.read(localeProvider.notifier).setLocale(selection.first);
                },
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                key: const ValueKey<String>('settings-urgent-interruption'),
                title: Text(l10n.settings_urgentInterruptionTitle),
                subtitle: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topLeft,
                  child: Column(
                    key: ValueKey<bool>(urgentInterruptionEnabled),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(urgentInterruptionDescription),
                      const SizedBox(height: 4),
                      Text(urgentInterruptionState),
                    ],
                  ),
                ),
                value: urgentInterruptionEnabled,
                onChanged: _isSavingUrgentInterruption
                    ? null
                    : _setUrgentInterruption,
                secondary: SizedBox(
                  width: 20,
                  height: 20,
                  child: _isSavingUrgentInterruption
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                key: const ValueKey<String>('settings-legacy-color-theme'),
                title: Text(l10n.settings_legacyColorThemeTitle),
                subtitle: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topLeft,
                  child: Column(
                    key: ValueKey<bool>(legacyColorThemeEnabled),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(legacyColorThemeDescription),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                value: legacyColorThemeEnabled,
                onChanged: _isSavingLegacyColorTheme
                    ? null
                    : _setLegacyColorTheme,
                secondary: SizedBox(
                  width: 20,
                  height: 20,
                  child: _isSavingLegacyColorTheme
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
