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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final urgentInterruptionEnabled = ref.watch(
      urgentInterruptionSettingProvider,
    );
    final urgentInterruptionDescription = urgentInterruptionEnabled
        ? l10n.settings_urgentInterruptionEnabledDescription
        : l10n.settings_urgentInterruptionDisabledDescription;
    final urgentInterruptionState = urgentInterruptionEnabled
        ? l10n.settings_urgentInterruptionEnabledLabel
        : l10n.settings_urgentInterruptionDisabledLabel;

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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(urgentInterruptionDescription),
                    const SizedBox(height: 4),
                    Text(
                      urgentInterruptionState,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                value: urgentInterruptionEnabled,
                onChanged: _isSavingUrgentInterruption
                    ? null
                    : _setUrgentInterruption,
                secondary: _isSavingUrgentInterruption
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
