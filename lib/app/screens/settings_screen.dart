import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);

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
            color: Theme.of(context)
                .colorScheme
                .surface
                .withValues(alpha: 0.85),
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
            ],
          ),
        ),
      ),
    );
  }
}
