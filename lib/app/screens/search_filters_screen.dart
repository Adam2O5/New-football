import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/search_filters_provider.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.searchFilters_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: l10n.searchFilters_reset,
            icon: const Icon(Icons.restore),
            onPressed: notifier.resetAll,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
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
    );
  }
}

class _GroupToggleRow extends StatelessWidget {
  const _GroupToggleRow({
    required this.title,
    required this.groups,
    required this.onChanged,
    required this.l10n,
  });

  final String title;
  final Set<SearchGroup> groups;
  final ValueChanged<Set<SearchGroup>> onChanged;
  final AppLocalizations l10n;

  String _label(SearchGroup group) => switch (group) {
    SearchGroup.players => l10n.search_players,
    SearchGroup.prospects => l10n.search_prospects,
    SearchGroup.picks => l10n.search_picks,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            for (final group in _groupOrder)
              FilterChip(
                label: Text(_label(group)),
                selected: groups.contains(group),
                onSelected: (selected) {
                  final next = Set<SearchGroup>.from(groups);
                  if (selected) {
                    next.add(group);
                  } else {
                    next.remove(group);
                  }
                  if (next.isEmpty) return;
                  onChanged(next);
                },
              ),
          ],
        ),
      ],
    );
  }
}

/// An inclusive range slider bound to a [RangeFilter]. Dragging a handle back
/// to the track's outer edge clears that side back to "unset" rather than
/// pinning it at the numeric bound, matching the unset-by-default contract.
class _RangeFilterTile extends StatelessWidget {
  const _RangeFilterTile({
    required this.label,
    required this.filter,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.formatValue,
  });

  final String label;
  final RangeFilter filter;
  final double min;
  final double max;
  final ValueChanged<RangeFilter> onChanged;
  final int? divisions;
  final String Function(double value)? formatValue;

  @override
  Widget build(BuildContext context) {
    final effectiveMin = (filter.min ?? min).clamp(min, max);
    final effectiveMax = (filter.max ?? max).clamp(min, max);
    final fmt = formatValue ?? (v) => v.round().toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleSmall),
              Text('${fmt(effectiveMin)} - ${fmt(effectiveMax)}'),
            ],
          ),
          RangeSlider(
            min: min,
            max: max,
            divisions: divisions,
            values: RangeValues(effectiveMin, effectiveMax),
            labels: RangeLabels(fmt(effectiveMin), fmt(effectiveMax)),
            onChanged: (values) => onChanged(
              RangeFilter(
                min: values.start <= min ? null : values.start,
                max: values.end >= max ? null : values.end,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Checkbox-driven multi-select behind a summary tile. Empty selection means
/// "no restriction" and is shown as [AppLocalizations.searchFilters_allSelected].
class _MultiSelectTile<T> extends StatelessWidget {
  const _MultiSelectTile({
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.l10n,
  });

  final String label;
  final List<(T value, String label)> options;
  final Set<T> selected;
  final ValueChanged<Set<T>> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final summary = selected.isEmpty
        ? l10n.searchFilters_allSelected
        : l10n.searchFilters_selectedCount(selected.length);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(summary),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final result = await showModalBottomSheet<Set<T>>(
          context: context,
          isScrollControlled: true,
          builder: (sheetContext) => _MultiSelectSheet<T>(
            title: label,
            options: options,
            initialSelected: selected,
            l10n: l10n,
          ),
        );
        if (result != null) onChanged(result);
      },
    );
  }
}

class _MultiSelectSheet<T> extends StatefulWidget {
  const _MultiSelectSheet({
    required this.title,
    required this.options,
    required this.initialSelected,
    required this.l10n,
  });

  final String title;
  final List<(T value, String label)> options;
  final Set<T> initialSelected;
  final AppLocalizations l10n;

  @override
  State<_MultiSelectSheet<T>> createState() => _MultiSelectSheetState<T>();
}

class _MultiSelectSheetState<T> extends State<_MultiSelectSheet<T>> {
  late final Set<T> _selected = Set<T>.from(widget.initialSelected);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, scrollController) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _selected.clear()),
                      child: Text(widget.l10n.searchFilters_allSelected),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    for (final option in widget.options)
                      CheckboxListTile(
                        value: _selected.contains(option.$1),
                        title: Text(option.$2),
                        onChanged: (checked) => setState(() {
                          if (checked ?? false) {
                            _selected.add(option.$1);
                          } else {
                            _selected.remove(option.$1);
                          }
                        }),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, _selected),
                  child: Text(widget.l10n.common_save),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A labelled dropdown row, mirroring the plain `DropdownButton` (not the
/// `FormField` variant) already used by `prospects_screen.dart` — avoids
/// depending on a Flutter-version-specific `DropdownButtonFormField` API.
class _LabeledDropdown<T> extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.titleSmall),
        ),
        DropdownButton<T>(value: value, items: items, onChanged: onChanged),
      ],
    );
  }
}

class _NationalityDropdown extends StatelessWidget {
  const _NationalityDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.l10n,
  });

  final String label;
  final Nationality? value;
  final ValueChanged<Nationality?> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _LabeledDropdown<Nationality?>(
      label: label,
      value: value,
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(l10n.searchFilters_allSelected),
        ),
        for (final nationality in Nationality.values)
          DropdownMenuItem(value: nationality, child: Text(nationality.label)),
      ],
      onChanged: onChanged,
    );
  }
}

class _PositionDropdown extends StatelessWidget {
  const _PositionDropdown({
    required this.value,
    required this.onChanged,
    required this.l10n,
  });

  final Position? value;
  final ValueChanged<Position?> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _LabeledDropdown<Position?>(
      label: l10n.prospects_position,
      value: value,
      items: [
        DropdownMenuItem(value: null, child: Text(l10n.prospects_allPositions)),
        for (final position in Position.values)
          DropdownMenuItem(value: position, child: Text(position.code)),
      ],
      onChanged: onChanged,
    );
  }
}

class _OptimalRoleDropdown extends StatelessWidget {
  const _OptimalRoleDropdown({
    required this.position,
    required this.value,
    required this.onChanged,
    required this.l10n,
  });

  final Position? position;
  final AssignedRole? value;
  final ValueChanged<AssignedRole?> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final roles = position == null
        ? const <AssignedRole>[]
        : rolesForPosition(position!);
    return _LabeledDropdown<AssignedRole?>(
      label: l10n.scouting_combineRole,
      value: position == null ? null : value,
      items: [
        DropdownMenuItem(value: null, child: Text(l10n.searchFilters_allRoles)),
        for (final role in roles)
          DropdownMenuItem(
            value: role,
            child: Text(assignedRoleLabel(context, role)),
          ),
      ],
      onChanged: position == null ? null : onChanged,
    );
  }
}

String _formatMoney(double value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
  return value.round().toString();
}

class _PlayersFilterTab extends StatelessWidget {
  const _PlayersFilterTab({
    required this.l10n,
    required this.league,
    required this.filters,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final LeagueState? league;
  final PlayersFilterState filters;
  final ValueChanged<PlayersFilterState> onChanged;

  @override
  Widget build(BuildContext context) {
    final teamOptions = <(String, String)>[
      (PlayersFilterState.noClubSentinel, l10n.searchFilters_noClub),
      for (final team in league?.teams ?? const []) (team.id, team.name),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _NationalityDropdown(
          label: l10n.searchFilters_nationality,
          value: filters.nationality,
          onChanged: (v) => onChanged(filters.copyWith(nationality: () => v)),
          l10n: l10n,
        ),
        const SizedBox(height: 12),
        _PositionDropdown(
          value: filters.position,
          onChanged: (v) => onChanged(
            filters.copyWith(position: () => v, optimalRole: () => null),
          ),
          l10n: l10n,
        ),
        const SizedBox(height: 12),
        _OptimalRoleDropdown(
          position: filters.position,
          value: filters.optimalRole,
          onChanged: (v) => onChanged(filters.copyWith(optimalRole: () => v)),
          l10n: l10n,
        ),
        _RangeFilterTile(
          label: l10n.prospects_potential,
          filter: filters.potential,
          min: 0,
          max: 5,
          divisions: 10,
          formatValue: (v) => v.toStringAsFixed(1),
          onChanged: (v) => onChanged(filters.copyWith(potential: v)),
        ),
        _RangeFilterTile(
          label: l10n.prospects_age,
          filter: filters.age,
          min: 15,
          max: 45,
          divisions: 30,
          onChanged: (v) => onChanged(filters.copyWith(age: v)),
        ),
        _RangeFilterTile(
          label: l10n.stat_ovr,
          filter: filters.ovr,
          min: 30,
          max: 99,
          divisions: 69,
          onChanged: (v) => onChanged(filters.copyWith(ovr: v)),
        ),
        _RangeFilterTile(
          label: l10n.searchFilters_salary,
          filter: filters.salary,
          min: 0,
          max: 60000000,
          divisions: 60,
          formatValue: _formatMoney,
          onChanged: (v) => onChanged(filters.copyWith(salary: v)),
        ),
        _RangeFilterTile(
          label: l10n.searchFilters_contractLength,
          filter: filters.contractLength,
          min: 0,
          max: 6,
          divisions: 6,
          onChanged: (v) => onChanged(filters.copyWith(contractLength: v)),
        ),
        const SizedBox(height: 4),
        _MultiSelectTile<String>(
          label: l10n.searchFilters_club,
          options: teamOptions,
          selected: filters.clubIds,
          onChanged: (v) => onChanged(filters.copyWith(clubIds: v)),
          l10n: l10n,
        ),
      ],
    );
  }
}

class _ProspectsFilterTab extends StatelessWidget {
  const _ProspectsFilterTab({
    required this.l10n,
    required this.filters,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final ProspectsFilterState filters;
  final ValueChanged<ProspectsFilterState> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _NationalityDropdown(
          label: l10n.searchFilters_nationality,
          value: filters.nationality,
          onChanged: (v) => onChanged(filters.copyWith(nationality: () => v)),
          l10n: l10n,
        ),
        const SizedBox(height: 12),
        _PositionDropdown(
          value: filters.position,
          onChanged: (v) => onChanged(
            filters.copyWith(position: () => v, optimalRole: () => null),
          ),
          l10n: l10n,
        ),
        const SizedBox(height: 12),
        _OptimalRoleDropdown(
          position: filters.position,
          value: filters.optimalRole,
          onChanged: (v) => onChanged(filters.copyWith(optimalRole: () => v)),
          l10n: l10n,
        ),
        _RangeFilterTile(
          label: l10n.prospects_potential,
          filter: filters.potential,
          min: 0,
          max: 5,
          divisions: 10,
          formatValue: (v) => v.toStringAsFixed(1),
          onChanged: (v) => onChanged(filters.copyWith(potential: v)),
        ),
        _RangeFilterTile(
          label: l10n.prospects_age,
          filter: filters.age,
          min: 16,
          max: 25,
          divisions: 9,
          onChanged: (v) => onChanged(filters.copyWith(age: v)),
        ),
        _RangeFilterTile(
          label: l10n.stat_ovr,
          filter: filters.ovr,
          min: 30,
          max: 99,
          divisions: 69,
          onChanged: (v) => onChanged(filters.copyWith(ovr: v)),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.prospects_tier,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            for (final tier in ScoutingTier.values)
              FilterChip(
                label: Text('${tier.index + 1}'),
                selected: filters.scoutingTiers.contains(tier.index),
                onSelected: (selected) {
                  final next = Set<int>.from(filters.scoutingTiers);
                  if (selected) {
                    next.add(tier.index);
                  } else {
                    next.remove(tier.index);
                  }
                  onChanged(filters.copyWith(scoutingTiers: next));
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _PicksFilterTab extends StatelessWidget {
  const _PicksFilterTab({
    required this.l10n,
    required this.league,
    required this.filters,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final LeagueState? league;
  final PicksFilterState filters;
  final ValueChanged<PicksFilterState> onChanged;

  @override
  Widget build(BuildContext context) {
    final teamOptions = <(String, String)>[
      for (final team in league?.teams ?? const []) (team.id, team.name),
    ];
    final years = [
      for (final team in league?.teams ?? const [])
        for (final pick in team.ownedPicks) pick.year,
    ];
    final currentYear = league?.currentSeason.year ?? DateTime.now().year;
    final minYear = years.isEmpty
        ? currentYear
        : years.reduce((a, b) => a < b ? a : b);
    final maxYear = years.isEmpty
        ? currentYear + 3
        : years.reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MultiSelectTile<String>(
          label: l10n.searchFilters_club,
          options: teamOptions,
          selected: filters.clubIds,
          onChanged: (v) => onChanged(filters.copyWith(clubIds: v)),
          l10n: l10n,
        ),
        _MultiSelectTile<String>(
          label: l10n.searchFilters_originalClub,
          options: teamOptions,
          selected: filters.originalClubIds,
          onChanged: (v) => onChanged(filters.copyWith(originalClubIds: v)),
          l10n: l10n,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.searchFilters_round,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            for (final round in [1, 2, 3])
              FilterChip(
                label: Text('$round'),
                selected: filters.rounds.contains(round),
                onSelected: (selected) {
                  final next = Set<int>.from(filters.rounds);
                  if (selected) {
                    next.add(round);
                  } else {
                    next.remove(round);
                  }
                  onChanged(filters.copyWith(rounds: next));
                },
              ),
          ],
        ),
        _RangeFilterTile(
          label: l10n.searchFilters_year,
          filter: filters.year,
          min: minYear.toDouble(),
          max: (maxYear < minYear ? minYear : maxYear).toDouble() + 0.001,
          divisions: (maxYear - minYear).clamp(1, 100),
          onChanged: (v) => onChanged(filters.copyWith(year: v)),
        ),
      ],
    );
  }
}
