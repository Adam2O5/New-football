import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/branding/club_color_tokens.dart';
import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/app/providers/club_branding_provider.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/search_filters_provider.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/services/search_filter_matching.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

part 'search_filter_controls.dart';
part 'search_filter_dropdowns.dart';
part 'search_filter_tabs.dart';

/// Ordered so a tab index always lines up with [SearchGroup]'s declaration
/// order — used both for the tab bar and for picking the initial tab from
/// whichever group is selected first.
const List<SearchGroup> _groupOrder = [
  SearchGroup.players,
  SearchGroup.prospects,
  SearchGroup.picks,
];

class SearchFiltersScreen extends ConsumerStatefulWidget {
  const SearchFiltersScreen({super.key});

  @override
  ConsumerState<SearchFiltersScreen> createState() =>
      _SearchFiltersScreenState();
}

class _SearchFiltersScreenState extends ConsumerState<SearchFiltersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final saveKey = ref.read(activeSearchFiltersKeyProvider);
    final groups = ref.read(searchFiltersProvider(saveKey)).groups;
    final initialIndex = _groupOrder.indexWhere(groups.contains).clamp(0, 2);
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final saveKey = ref.watch(activeSearchFiltersKeyProvider);
    final filters = ref.watch(searchFiltersProvider(saveKey));
    final notifier = ref.read(searchFiltersProvider(saveKey).notifier);
    final league = ref.watch(activeLeagueProvider);

    final brandingRegistry = ref.watch(clubBrandingProvider);
    final ownTeam = league?.playerTeam;
    final branding = ownTeam == null
        ? null
        : brandingRegistry.resolve(ownTeam.id);
    final colorScheme = Theme.of(context).colorScheme;
    final headerBackground =
        branding?.primaryColor ?? colorScheme.surfaceContainerHighest;
    final headerForeground = branding == null
        ? colorScheme.onSurface
        : foregroundFor(headerBackground);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.searchFilters_title),
        backgroundColor: headerBackground,
        foregroundColor: headerForeground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: l10n.searchFilters_reset,
            icon: const Icon(Icons.restore),
            onPressed: () => _confirmReset(context, l10n, notifier),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: headerForeground,
          unselectedLabelColor: headerForeground.withValues(alpha: 0.7),
          indicatorColor: headerForeground,
          tabs: [
            Tab(text: l10n.search_players),
            Tab(text: l10n.search_prospects),
            Tab(text: l10n.search_picks),
          ],
        ),
      ),
      body: ScreenBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _GroupToggleRow(
                title: l10n.searchFilters_showTitle,
                groups: filters.groups,
                onChanged: notifier.setGroups,
                l10n: l10n,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PlayersFilterTab(
                    l10n: l10n,
                    league: league,
                    filters: filters.players,
                    onChanged: notifier.updatePlayers,
                  ),
                  _ProspectsFilterTab(
                    l10n: l10n,
                    filters: filters.prospects,
                    onChanged: notifier.updateProspects,
                  ),
                  _PicksFilterTab(
                    l10n: l10n,
                    league: league,
                    filters: filters.picks,
                    onChanged: notifier.updatePicks,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // `bottomNavigationBar` (rather than a trailing item in the scrollable
      // body) keeps the search button pinned above the content and tappable
      // regardless of scroll position, on every tab.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.search),
            label: Text(l10n.searchFilters_searchButton),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    AppLocalizations l10n,
    SearchFiltersNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.searchFilters_resetConfirmTitle),
        content: Text(l10n.searchFilters_resetConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.searchFilters_reset),
          ),
        ],
      ),
    );
    if (confirmed ?? false) notifier.resetAll();
  }
}
