import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/screens/calendar_screen.dart';
import 'package:new_football/app/screens/finance_screen.dart';
import 'package:new_football/app/screens/home_screen.dart';
import 'package:new_football/app/screens/inbox_screen.dart';
import 'package:new_football/app/screens/squad_screen.dart';
import 'package:new_football/app/screens/standings_screen.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

final shellTabIndexProvider = StateProvider<int>((ref) => 0);

class ShellScreen extends ConsumerStatefulWidget {
  const ShellScreen({super.key, this.initialTab});

  final int? initialTab;

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  static const _tabs = [
    HomeScreen(),
    CalendarScreen(),
    SquadScreen(),
    StandingsScreen(),
    FinanceScreen(),
    InboxScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final tab = widget.initialTab;
    if (tab != null && tab >= 0 && tab < _tabs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(shellTabIndexProvider.notifier).state = tab;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    if (league == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.shell_noActiveGame),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.go('/'),
                child: Text(l10n.shell_mainMenu),
              ),
            ],
          ),
        ),
      );
    }

    final index = ref.watch(shellTabIndexProvider).clamp(0, _tabs.length - 1);
    final teamName = league.playerTeam?.name ?? l10n.shell_defaultCareerName;

    return Scaffold(
      appBar: AppBar(
        title: Text(teamName),
        actions: [
          IconButton(
            tooltip: l10n.shell_draftTooltip,
            onPressed: () => context.push('/game/draft'),
            icon: const Icon(Icons.how_to_vote_outlined),
          ),
          IconButton(
            tooltip: l10n.shell_menuTooltip,
            onPressed: () {
              ref.read(gameControllerProvider.notifier).clear();
              context.go('/');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(index: index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          ref.read(shellTabIndexProvider.notifier).state = i;
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.shell_tab_home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l10n.shell_tab_calendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.groups_outlined),
            selectedIcon: const Icon(Icons.groups),
            label: l10n.shell_tab_squad,
          ),
          NavigationDestination(
            icon: const Icon(Icons.table_chart_outlined),
            selectedIcon: const Icon(Icons.table_chart),
            label: l10n.shell_tab_standings,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet),
            label: l10n.shell_tab_finance,
          ),
          NavigationDestination(
            icon: const Icon(Icons.mail_outline),
            selectedIcon: const Icon(Icons.mail),
            label: l10n.shell_tab_inbox,
          ),
        ],
      ),
    );
  }
}
