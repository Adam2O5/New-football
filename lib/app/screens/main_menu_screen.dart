import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

import 'package:new_football/app/widgets/screen_background.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                ExcludeSemantics(
                  child: Image.asset(
                    'assets/images/New-Football-Logo-bg-removed.png',
                    height: 148,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
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
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton(
                      onPressed: () => context.push('/new-game'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface.withValues(
                          alpha: 0.85,
                        ),
                      ),
                      child: Text(l10n.mainMenu_newGame),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.push('/load-game'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface.withValues(
                          alpha: 0.85,
                        ),
                      ),
                      child: Text(l10n.mainMenu_loadGame),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.push('/settings'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface.withValues(
                          alpha: 0.85,
                        ),
                      ),
                      child: Text(l10n.mainMenu_settings),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => SystemNavigator.pop(),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface.withValues(
                          alpha: 0.85,
                        ),
                      ),
                      child: Text(l10n.mainMenu_exitGame),
                    ),
                  ],
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
