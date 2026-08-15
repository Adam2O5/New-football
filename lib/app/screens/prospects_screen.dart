import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/scouting.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

String _fogValue(
  dynamic rawValue,
  ScoutingTier? tier,
  ScoutingTier requiredTier, {
  bool? additionalFlag,
}) {
  if (tier == null || tier.index < requiredTier.index) return '—';
  if (additionalFlag != null && additionalFlag == false) return '—';
  return rawValue.toString();
}

String _slotLabel(AppLocalizations l10n, EstimatedDraftSlot? slot) {
  if (slot == null) return '—';
  return switch (slot) {
    EstimatedDraftSlot.top1 => l10n.scouting_slot_top1,
    EstimatedDraftSlot.top3 => l10n.scouting_slot_top3,
    EstimatedDraftSlot.top5 => l10n.scouting_slot_top5,
    EstimatedDraftSlot.top10 => l10n.scouting_slot_top10,
    EstimatedDraftSlot.r1 => l10n.scouting_slot_r1,
    EstimatedDraftSlot.r2 => l10n.scouting_slot_r2,
    EstimatedDraftSlot.r3 => l10n.scouting_slot_r3,
    EstimatedDraftSlot.x => l10n.scouting_slot_x,
  };
}

enum _ProspectSort { name, projectedOvr, scoutGrade, potential }

class ProspectsScreen extends ConsumerStatefulWidget {
  const ProspectsScreen({super.key, this.initialWatchOnly = false});

  final bool initialWatchOnly;

  @override
  ConsumerState<ProspectsScreen> createState() => _ProspectsScreenState();
}

class _ProspectsScreenState extends ConsumerState<ProspectsScreen> {
  final _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  Position? _positionFilter;
  bool _watchOnly = false;
  _ProspectSort _sort = _ProspectSort.name;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _watchOnly = widget.initialWatchOnly;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);

    if (league == null) {
      return Scaffold(
        appBar: _appBar(context, l10n),
        body: Center(child: Text(l10n.prospects_noDraftClass)),
      );
    }

    final draftState =
        league.currentSeason.draftState ?? league.currentSeason.nextDraftState;
    final scouting = league.playerTeam?.scouting;
    if (!_initialized && scouting != null) {
      _selectedIds.addAll(scouting.watchlistProspectIds);
      _initialized = true;
    }

    return Scaffold(
      appBar: _appBar(context, l10n),
      body: ScreenBackground(
        child: draftState == null
            ? Center(child: Text(l10n.prospects_noDraftClass))
            : _buildContent(
                context,
                l10n,
                draftState.draftClass.prospects,
                scouting,
                league,
              ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      title: Text(l10n.prospects_title),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          tooltip: l10n.prospects_saveWatchlist,
          icon: const Icon(Icons.save_outlined),
          onPressed: _saveWatchlist,
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    List<Prospect> prospects,
    TeamScouting? scouting,
    LeagueState league,
  ) {
    final coverage = league.playerTeam?.staff.scout?.attributes.coverage ?? 0.0;
    final limit = ref.read(scoutingServiceProvider).maxWatched(coverage);
    final visible = _filteredProspects(prospects, scouting);

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: l10n.prospects_search,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DropdownButton<Position?>(
                      value: _positionFilter,
                      hint: Text(l10n.prospects_position),
                      items: [
                        DropdownMenuItem<Position?>(
                          value: null,
                          child: Text(l10n.prospects_allPositions),
                        ),
                        ...Position.values.map(
                          (position) => DropdownMenuItem<Position?>(
                            value: position,
                            child: Text(position.code),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _positionFilter = value),
                    ),
                    DropdownButton<_ProspectSort>(
                      value: _sort,
                      hint: Text(l10n.prospects_sort),
                      items: [
                        DropdownMenuItem(
                          value: _ProspectSort.name,
                          child: Text(l10n.prospects_sortName),
                        ),
                        DropdownMenuItem(
                          value: _ProspectSort.projectedOvr,
                          child: Text(l10n.prospects_sortOvr),
                        ),
                        DropdownMenuItem(
                          value: _ProspectSort.scoutGrade,
                          child: Text(l10n.prospects_sortGrade),
                        ),
                        DropdownMenuItem(
                          value: _ProspectSort.potential,
                          child: Text(l10n.prospects_sortPotential),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _sort = value);
                      },
                    ),
                    FilterChip(
                      label: Text(l10n.prospects_watchOnly),
                      selected: _watchOnly,
                      onSelected: (value) => setState(() => _watchOnly = value),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.prospects_coverage(
                      coverage.toStringAsFixed(1),
                      _selectedIds.length,
                      limit,
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: visible.isEmpty
                ? Center(child: Text(l10n.prospects_empty))
                : _buildProspectsTable(context, l10n, visible, scouting, limit),
          ),
        ],
      ),
    );
  }

  List<Prospect> _filteredProspects(
    List<Prospect> prospects,
    TeamScouting? scouting,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = prospects.where((prospect) {
      if (query.isNotEmpty && !prospect.name.toLowerCase().contains(query)) {
        return false;
      }
      if (_positionFilter != null && prospect.position != _positionFilter) {
        return false;
      }
      if (_watchOnly && !_selectedIds.contains(prospect.id)) return false;
      return true;
    }).toList();

    filtered.sort((a, b) {
      return switch (_sort) {
        _ProspectSort.name => a.name.compareTo(b.name),
        _ProspectSort.projectedOvr => b.projectedOverall().compareTo(
          a.projectedOverall(),
        ),
        _ProspectSort.scoutGrade => b.scoutGrade.compareTo(a.scoutGrade),
        _ProspectSort.potential => b.potentialStars.compareTo(a.potentialStars),
      };
    });
    return filtered;
  }

  Widget _buildProspectsTable(
    BuildContext context,
    AppLocalizations l10n,
    List<Prospect> prospects,
    TeamScouting? scouting,
    int limit,
  ) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          showCheckboxColumn: false,
          columns: [
            DataColumn(label: Text(l10n.prospects_watchlist)),
            DataColumn(label: Text(l10n.prospects_name)),
            DataColumn(label: Text(l10n.prospects_nationality)),
            DataColumn(label: Text(l10n.prospects_age)),
            DataColumn(label: Text(l10n.prospects_positionShort)),
            DataColumn(label: Text(l10n.prospects_combine)),
            DataColumn(label: Text(l10n.prospects_grade)),
            DataColumn(label: Text(l10n.prospects_stars)),
            DataColumn(label: Text(l10n.prospects_injuryShort)),
            DataColumn(label: Text(l10n.prospects_determinationShort)),
            DataColumn(label: Text(l10n.prospects_slot)),
          ],
          rows: prospects.map((prospect) {
            final knowledge = scouting?.forProspect(prospect.id);
            final watched = _selectedIds.contains(prospect.id);
            final canSelect = watched || _selectedIds.length < limit;
            return DataRow(
              onSelectChanged: (_) =>
                  _showProspectDetail(context, l10n, prospect, scouting),
              cells: [
                DataCell(
                  Checkbox(
                    value: watched,
                    onChanged: canSelect
                        ? (value) => _toggleWatchlist(prospect.id, value)
                        : null,
                  ),
                ),
                DataCell(Text(prospect.name)),
                DataCell(Text(prospect.nationality.code)),
                DataCell(Text('${prospect.age}')),
                DataCell(Text(prospect.position.code)),
                DataCell(
                  Text(
                    _fogValue(
                      prospect.combineScore,
                      knowledge?.tier,
                      ScoutingTier.tier2,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    _fogValue(
                      prospect.scoutGrade,
                      knowledge?.tier,
                      ScoutingTier.tier3,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    _fogValue(
                      prospect.potentialStars.toStringAsFixed(1),
                      knowledge?.tier,
                      ScoutingTier.tier4,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    _fogValue(
                      prospect.injuryProne,
                      knowledge?.tier,
                      ScoutingTier.tier5,
                      additionalFlag: knowledge?.injuryProneKnown,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    _fogValue(
                      prospect.determination,
                      knowledge?.tier,
                      ScoutingTier.tier5,
                      additionalFlag: knowledge?.determinationKnown,
                    ),
                  ),
                ),
                DataCell(Text(_slotLabel(l10n, knowledge?.estimatedSlot))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _toggleWatchlist(String id, bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  Future<void> _saveWatchlist() async {
    await ref
        .read(gameControllerProvider.notifier)
        .setScoutWatchlist(_selectedIds.toList());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.common_save)),
    );
  }

  void _showProspectDetail(
    BuildContext context,
    AppLocalizations l10n,
    Prospect prospect,
    TeamScouting? scouting,
  ) {
    final knowledge = scouting?.forProspect(prospect.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => _ProspectDetailContent(
          l10n: l10n,
          prospect: prospect,
          knowledge: knowledge,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _ProspectDetailContent extends StatelessWidget {
  const _ProspectDetailContent({
    required this.l10n,
    required this.prospect,
    required this.knowledge,
    required this.scrollController,
  });

  final AppLocalizations l10n;
  final Prospect prospect;
  final ScoutingKnowledge? knowledge;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tier = knowledge?.tier;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(prospect.name, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '${prospect.position.code} · ${prospect.nationality.code} · ${prospect.age} · ${prospect.heightCm} cm',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Text(l10n.prospects_scoutingData, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          if (knowledge == null)
            Text(
              l10n.prospects_noScouting,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else ...[
            _detailRow(
              l10n.prospects_combineScore,
              _fogValue(prospect.combineScore, tier, ScoutingTier.tier2),
            ),
            _detailRow(
              l10n.prospects_scoutGrade,
              _fogValue(prospect.scoutGrade, tier, ScoutingTier.tier3),
            ),
            _detailRow(
              l10n.prospects_potential,
              _fogValue(
                prospect.potentialStars.toStringAsFixed(1),
                tier,
                ScoutingTier.tier4,
              ),
            ),
            _detailRow(
              l10n.prospects_injuryProne,
              _fogValue(
                prospect.injuryProne,
                tier,
                ScoutingTier.tier5,
                additionalFlag: knowledge?.injuryProneKnown,
              ),
            ),
            _detailRow(
              l10n.prospects_determination,
              _fogValue(
                prospect.determination,
                tier,
                ScoutingTier.tier5,
                additionalFlag: knowledge?.determinationKnown,
              ),
            ),
            _detailRow(
              l10n.prospects_estimatedSlot,
              _slotLabel(l10n, knowledge?.estimatedSlot),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
