import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/club_branding_provider.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/theme/app_theme.dart';
import 'package:new_football/app/screens/calendar_screen.dart';
import 'package:new_football/app/screens/home_screen.dart';
import 'package:new_football/app/screens/inbox_screen.dart';
import 'package:new_football/app/screens/other_screen.dart';
import 'package:new_football/app/screens/squad_screen.dart';
import 'package:new_football/app/screens/standings_screen.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/message.dart';
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
  bool _leaving = false;
  bool _saving = false;

  Future<void> _leaveGame() async {
    if (_leaving) return;
    setState(() => _leaving = true);
    try {
      await ref.read(gameControllerProvider.notifier).clear();
      if (mounted) context.go('/');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.loadGame_writeFailed),
        ),
      );
    } finally {
      if (mounted) setState(() => _leaving = false);
    }
  }

  Future<void> _saveGame() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(gameControllerProvider.notifier).persist();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.common_save)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.loadGame_writeFailed),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  static const _tabs = [
    HomeScreen(),
    CalendarScreen(),
    SquadScreen(),
    StandingsScreen(),
    OtherScreen(),
    InboxScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final tab = widget.initialTab;
    final normalizedTab = tab != null && tab >= 0 && tab < _tabs.length
        ? tab
        : 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(shellTabIndexProvider.notifier).state = normalizedTab;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    if (league == null) {
      return Scaffold(
        body: ScreenBackground(
          child: Center(
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
        ),
      );
    }

    final index = ref.watch(shellTabIndexProvider).clamp(0, _tabs.length - 1);
    final activeTeamId = league.playerTeamId;
    final activeTeam = activeTeamId == null
        ? null
        : league.teamById(activeTeamId);
    final teamName = activeTeam?.name ?? l10n.shell_defaultCareerName;
    final branding = ref
        .watch(clubBrandingProvider)
        .resolve(activeTeamId ?? '');
    final useLegacyColorTheme = ref.watch(legacyColorThemeSettingProvider);

    final scaffold = Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: _ShellTeamTitle(
          teamName: teamName,
          primaryColor: branding.primaryColor,
          secondaryColor: branding.secondaryColor,
          showClubStripe: !useLegacyColorTheme,
        ),
        actions: [
          IconButton(
            tooltip: l10n.shell_settingsTooltip,
            onPressed: _leaving ? null : () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: l10n.shell_saveTooltip,
            onPressed: _leaving || _saving ? null : _saveGame,
            icon: const Icon(Icons.save_outlined),
          ),
          IconButton(
            tooltip: l10n.shell_menuTooltip,
            onPressed: _leaving ? null : _leaveGame,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ScreenBackground(
        child: AbsorbPointer(
          absorbing: _leaving,
          child: IndexedStack(index: index, children: _tabs),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: _leaving
            ? null
            : (i) {
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
            icon: const Icon(Icons.more_horiz_outlined),
            selectedIcon: const Icon(Icons.more_horiz),
            label: l10n.shell_tab_other,
          ),
          NavigationDestination(
            icon: _InboxBadge(
              unreadCount: league.inbox.unread.length,
              urgent: league.inbox.pendingUrgent.isNotEmpty,
              icon: Icons.mail_outline,
            ),
            selectedIcon: _InboxBadge(
              unreadCount: league.inbox.unread.length,
              urgent: league.inbox.pendingUrgent.isNotEmpty,
              icon: Icons.mail,
            ),
            label: l10n.shell_tab_inbox,
          ),
        ],
      ),
    );

    if (useLegacyColorTheme) return scaffold;
    return Theme(
      data: AppTheme.forClub(
        primary: branding.primaryColor,
        secondary: branding.secondaryColor,
      ),
      child: scaffold,
    );
  }
}

class _ShellTeamTitle extends StatelessWidget {
  const _ShellTeamTitle({
    required this.teamName,
    required this.primaryColor,
    required this.secondaryColor,
    required this.showClubStripe,
  });

  final String teamName;
  final Color primaryColor;
  final Color secondaryColor;
  final bool showClubStripe;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: kToolbarHeight,
      child: Stack(
        key: const ValueKey<String>('shell-team-title'),
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(teamName, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          if (showClubStripe)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 3,
              child: ExcludeSemantics(
                child: IgnorePointer(
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: ColoredBox(color: primaryColor)),
                      Expanded(child: ColoredBox(color: secondaryColor)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InboxBadge extends StatelessWidget {
  const _InboxBadge({
    required this.unreadCount,
    required this.urgent,
    required this.icon,
  });

  final int unreadCount;
  final bool urgent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: unreadCount > 0,
      backgroundColor: urgent ? Theme.of(context).colorScheme.error : null,
      label: Text('$unreadCount'),
      child: Icon(icon),
    );
  }
}
