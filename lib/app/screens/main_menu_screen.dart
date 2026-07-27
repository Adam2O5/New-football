import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/l10n/generated/app_localizations.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Text(
                l10n.appTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.mainMenu_subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.push('/new-game'),
                child: Text(l10n.mainMenu_newGame),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push('/load-game'),
                child: Text(l10n.mainMenu_loadGame),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push('/settings'),
                child: Text(l10n.mainMenu_settings),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
