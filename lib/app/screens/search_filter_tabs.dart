part of 'search_filters_screen.dart';

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
        const SizedBox(height: 4),
        _MultiSelectTile<String>(
          label: l10n.searchFilters_club,
          options: teamOptions,
          selected: filters.clubIds,
          onChanged: (v) => onChanged(filters.copyWith(clubIds: v)),
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
    final yearBounds = yearSliderBounds(
      years.cast<int>(),
      fallbackYear: currentYear,
    );

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
          min: yearBounds.min.toDouble(),
          max: yearBounds.max.toDouble(),
          divisions: yearBounds.divisions,
          onChanged: (v) => onChanged(filters.copyWith(year: v)),
        ),
      ],
    );
  }
}
