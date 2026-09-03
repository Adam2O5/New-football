import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/utils/squad_tile_metrics.dart';
import 'package:new_football/app/widgets/nationality_flag_icon.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/scouting.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

/// Placeholder shown for any scouted attribute the scout has not yet
/// estimated (or, for a range, has not yet narrowed enough to display).
const String _unknownValue = '?';

String _tierLabel(ScoutingTier? tier) =>
    tier == null ? '1' : '${tier.index + 1}';

String _rangeLabel(int? min, int? max) =>
    (min == null || max == null) ? _unknownValue : '$min-$max';

String _slotLabel(AppLocalizations l10n, EstimatedDraftSlot? slot) {
  if (slot == null) return _unknownValue;
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

/// Scout's estimated potential, shown as stars. Only the min/max range is
/// ever known (see `scouting_service.dart` `_evidenceForTier`) — there is no
/// "guessed exactly right" reveal for potential like there is for
/// injuryProne/determination, so the midpoint of the range is what gets
/// rendered.
Widget _buildPotentialEstimate(
  AppLocalizations l10n,
  Prospect prospect,
  ScoutingKnowledge? knowledge,
) {
  final min = knowledge?.estimatedPotentialMin;
  final max = knowledge?.estimatedPotentialMax;
  if (min == null || max == null) {
    return const Text(_unknownValue, textAlign: TextAlign.center);
  }
  final midpoint = (min + max) / 2;
  return PotentialStars(
    playerId: prospect.id,
    stars: displayedPotentialStars(midpoint),
    color: potentialStarColor(prospect.age),
    l10n: l10n,
  );
}

class ProspectsScreen extends ConsumerStatefulWidget {
  const ProspectsScreen({
    super.key,
    this.initialWatchOnly = false,
    this.initialCombine = false,
    this.initialHighlightProspectId,
  });

  final bool initialWatchOnly;
  final bool initialCombine;

  /// When set, the table scrolls to and briefly highlights this prospect's
  /// row on open (see `search_screen.dart`). Any active position/watchlist
  /// filter is cleared on init so the target row is guaranteed to render.
  final String? initialHighlightProspectId;

  @override
  ConsumerState<ProspectsScreen> createState() => _ProspectsScreenState();
}

class _ProspectsScreenState extends ConsumerState<ProspectsScreen> {
  final Set<String> _selectedIds = {};
  final Set<String> _combineIds = {};
  Position? _positionFilter;
  bool _watchOnly = false;
  bool _combineMode = false;
  bool _initialized = false;
  bool _combineInitialized = false;

  // Scroll-to-row support for arriving from the search screen with a
  // specific prospect to highlight.
  final ScrollController _tableScrollController = ScrollController();
  final Map<String, GlobalKey> _rowKeys = {};
  String? _highlightedProspectId;
  bool _didScrollToHighlight = false;

  // `ref.read` is unsafe inside `dispose()` (the widget may already be
  // unmounted by then), so the notifier is cached here on every dependency
  // change while the widget is still alive, and `dispose()` only touches
  // this field. Typed as `dynamic` because the concrete notifier type isn't
  // available here — it only needs to expose `setScoutWatchlist` and
  // `setCombineAssignments`, both already used by the rest of this screen.
  dynamic _gameController;

  // Column widths shared between the header row and data rows so they stay
  // pixel-aligned inside the horizontally scrollable table (styled after
  // development_screen.dart's players tab).
  static const double _colCheckboxWidth = 40;
  static const double _colNameWidth = 110;
  static const double _colFlagWidth = 32;
  static const double _colAgeWidth = 32;
  static const double _colPositionWidth = 32;
  static const double _colTierWidth = 32;
  static const double _colOvrRangeWidth = 64;
  static const double _colProjWidth = 48;
  static const double _colPotentialWidth = 70;
  static const double _colInjWidth = 48;
  static const double _colDetWidth = 48;
  static const double _colRoleWidth = 96;

  double _tableWidth(bool withRoleColumn) =>
      _colCheckboxWidth +
      _colNameWidth +
      _colFlagWidth +
      _colAgeWidth +
      _colPositionWidth +
      _colTierWidth +
      _colOvrRangeWidth +
      _colProjWidth +
      _colPotentialWidth +
      _colInjWidth +
      _colDetWidth +
      (withRoleColumn ? _colRoleWidth : 0) +
      8; //padding

  @override
  void initState() {
    super.initState();
    _watchOnly = widget.initialWatchOnly;
    _combineMode = widget.initialCombine;
    if (widget.initialHighlightProspectId != null) {
      _highlightedProspectId = widget.initialHighlightProspectId;
      _positionFilter = null;
      _watchOnly = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gameController = ref.read(gameControllerProvider.notifier);
  }

  @override
  void dispose() {
    _persistOnExit();
    _tableScrollController.dispose();
    super.dispose();
  }

  /// Autosaves the watchlist (and, in Combine mode, the Combine assignments)
  /// when the screen is left, replacing the old explicit save button. Uses
  /// the cached `_gameController` (see field doc) rather than `ref.read`,
  /// since `ref` is not safe to use during/after disposal.
  void _persistOnExit() {
    _gameController?.setScoutWatchlist(_selectedIds.toList());
    if (_combineMode) {
      _gameController?.setCombineAssignments(_combineIds.toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);

    if (league == null) {
      return Scaffold(
        appBar: _appBar(l10n),
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
    if (!_combineInitialized && scouting != null) {
      _combineIds.addAll(scouting.combineAssignedProspectIds);
      _combineInitialized = true;
    }
    final combineAvailable =
        league.currentSeason.scoutReportDone &&
        !league.currentSeason.combineDone;

    if (_highlightedProspectId != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToHighlighted(),
      );
    }

    return Scaffold(
      appBar: _appBar(l10n),
      body: ScreenBackground(
        child: draftState == null
            ? Center(child: Text(l10n.prospects_noDraftClass))
            : _buildContent(
                context,
                l10n,
                draftState.draftClass.prospects,
                scouting,
                league,
                combineAvailable: combineAvailable,
              ),
      ),
    );
  }

  void _scrollToHighlighted() {
    if (_didScrollToHighlight) return;
    final id = _highlightedProspectId;
    if (id == null) return;
    final rowContext = _rowKeys[id]?.currentContext;
    if (rowContext == null) return;
    _didScrollToHighlight = true;
    Scrollable.ensureVisible(
      rowContext,
      duration: const Duration(milliseconds: 400),
      alignment: 0.3,
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _highlightedProspectId = null);
    });
  }

  GlobalKey _rowKey(String prospectId) =>
      _rowKeys.putIfAbsent(prospectId, () => GlobalKey());

  PreferredSizeWidget _appBar(AppLocalizations l10n) {
    return AppBar(
      title: Text(
        _combineMode ? l10n.scouting_combineTitle : l10n.prospects_title,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    List<Prospect> prospects,
    TeamScouting? scouting,
    LeagueState league, {
    required bool combineAvailable,
  }) {
    final coverage = league.playerTeam?.staff.scout?.attributes.coverage ?? 0.0;
    final scoutingService = ref.read(scoutingServiceProvider);
    final watchlistLimit = scoutingService.maxWatched(coverage);
    final combineLimit = scoutingService.combineAssignLimit(coverage);
    final visible = _filteredProspects(
      prospects,
      scouting,
      forceWatchOnly: _combineMode,
    );
    final noCombineTargets =
        _combineMode && (scouting?.watchlistProspectIds.isEmpty ?? true);

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
                if (_combineMode) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.scouting_combineDescription(combineLimit),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.scouting_combineSelected(
                              _combineIds.length,
                              combineLimit,
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (!combineAvailable) ...[
                            const SizedBox(height: 4),
                            Text(l10n.scouting_combineClosed),
                          ],
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Row(
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
                      const Spacer(),
                      _buildCoverageIndicator(
                        context,
                        coverage,
                        watchlistLimit,
                      ),
                    ],
                  ),
                  if (combineAvailable) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        onPressed: _openCombineMode,
                        icon: const Icon(Icons.science_outlined),
                        label: Text(l10n.scouting_combineOpen),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: visible.isEmpty
                ? Center(
                    child: Text(
                      noCombineTargets
                          ? l10n.scouting_combineNoWatchlist
                          : l10n.prospects_empty,
                    ),
                  )
                : _buildProspectsTable(
                    context,
                    l10n,
                    visible,
                    scouting,
                    watchlistLimit,
                    combineLimit,
                    combineAvailable,
                  ),
          ),
        ],
      ),
    );
  }

  /// Coverage rating (0-5 stars, half-star steps — see `staff.md`) alongside
  /// the current/max watched count. Rendered directly from the raw
  /// `coverage` attribute so a missing scout (coverage 0) always shows an
  /// empty rating rather than the watchlist limit.
  Widget _buildCoverageIndicator(
    BuildContext context,
    double coverage,
    int watchlistLimit,
  ) {
    const starCount = 5;
    final filled = coverage.clamp(0.0, 5.0);
    final color = Theme.of(context).colorScheme.tertiary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < starCount; i++)
          Icon(_starIconFor(filled - i), size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          '${_selectedIds.length}/$watchlistLimit',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  IconData _starIconFor(double remainder) {
    if (remainder >= 1.0) return Icons.star;
    if (remainder >= 0.5) return Icons.star_half;
    return Icons.star_border;
  }

  List<Prospect> _filteredProspects(
    List<Prospect> prospects,
    TeamScouting? scouting, {
    bool forceWatchOnly = false,
  }) {
    final filtered = prospects.where((prospect) {
      if (_positionFilter != null && prospect.position != _positionFilter) {
        return false;
      }
      if ((_watchOnly || forceWatchOnly) &&
          !_selectedIds.contains(prospect.id)) {
        return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }

  Widget _buildProspectsTable(
    BuildContext context,
    AppLocalizations l10n,
    List<Prospect> prospects,
    TeamScouting? scouting,
    int watchlistLimit,
    int combineLimit,
    bool combineAvailable,
  ) {
    final showRoleColumn = _combineIds.isNotEmpty;
    return SingleChildScrollView(
      controller: _tableScrollController,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _tableWidth(showRoleColumn),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderRow(l10n, showRoleColumn),
              const Divider(height: 1),
              for (final prospect in prospects)
                _buildProspectRow(
                  context,
                  l10n,
                  prospect,
                  scouting,
                  watchlistLimit,
                  combineLimit,
                  combineAvailable,
                  showRoleColumn,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(AppLocalizations l10n, bool showRoleColumn) {
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
    Widget cell(double width, String text) => SizedBox(
      width: width,
      child: Text(text, textAlign: TextAlign.center, style: headerStyle),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: [
          SizedBox(width: _colCheckboxWidth),
          SizedBox(
            width: _colNameWidth,
            child: Text(l10n.prospects_name, style: headerStyle),
          ),
          cell(_colFlagWidth, ''),
          cell(_colAgeWidth, l10n.prospects_age),
          cell(_colPositionWidth, l10n.prospects_positionShort),
          cell(_colTierWidth, l10n.prospects_tier),
          cell(_colOvrRangeWidth, l10n.prospects_overallRange),
          cell(_colProjWidth, l10n.prospects_slot),
          cell(_colPotentialWidth, l10n.prospects_stars),
          cell(_colInjWidth, l10n.prospects_injuryShort),
          cell(_colDetWidth, l10n.prospects_determinationShort),
          if (showRoleColumn) cell(_colRoleWidth, l10n.scouting_combineRole),
        ],
      ),
    );
  }

  Widget _buildProspectRow(
    BuildContext context,
    AppLocalizations l10n,
    Prospect prospect,
    TeamScouting? scouting,
    int watchlistLimit,
    int combineLimit,
    bool combineAvailable,
    bool showRoleColumn,
  ) {
    final knowledge = scouting?.forProspect(prospect.id);
    final watched = _selectedIds.contains(prospect.id);
    final assigned = _combineIds.contains(prospect.id);
    final canSelect = _combineMode
        ? assigned || _combineIds.length < combineLimit
        : watched || _selectedIds.length < watchlistLimit;
    final showCombinedRole = !combineAvailable && assigned;
    final textStyle = Theme.of(context).textTheme.bodySmall;
    final isHighlighted = prospect.id == _highlightedProspectId;

    Widget cell(double width, String text) => SizedBox(
      width: width,
      child: Text(text, textAlign: TextAlign.center, style: textStyle),
    );

    return Material(
      key: _rowKey(prospect.id),
      color: isHighlighted
          ? Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.5)
          : Colors.transparent,
      child: InkWell(
        onTap: () => _showProspectDetail(
          context,
          l10n,
          prospect,
          scouting,
          showOptimalRole: showCombinedRole,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Row(
            children: [
              SizedBox(
                width: _colCheckboxWidth,
                child: Checkbox(
                  value: _combineMode ? assigned : watched,
                  onChanged: _combineMode
                      ? (!combineAvailable || !canSelect)
                            ? null
                            : (value) => _toggleCombine(prospect.id, value)
                      : canSelect
                      ? (value) => _toggleWatchlist(prospect.id, value)
                      : null,
                ),
              ),
              SizedBox(
                width: _colNameWidth,
                child: Text(
                  prospect.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(
                width: _colFlagWidth,
                child: Center(child: NationalityFlagIcon(prospect.nationality)),
              ),
              cell(_colAgeWidth, '${prospect.age}'),
              cell(_colPositionWidth, prospect.position.code),
              cell(_colTierWidth, _tierLabel(knowledge?.tier)),
              cell(
                _colOvrRangeWidth,
                _rangeLabel(
                  knowledge?.estimatedOvrMin,
                  knowledge?.estimatedOvrMax,
                ),
              ),
              cell(_colProjWidth, _slotLabel(l10n, knowledge?.estimatedSlot)),
              SizedBox(
                width: _colPotentialWidth,
                child: _buildPotentialEstimate(l10n, prospect, knowledge),
              ),
              cell(
                _colInjWidth,
                knowledge?.injuryProneKnown == true
                    ? _rangeLabel(
                        knowledge?.injuryProneMin,
                        knowledge?.injuryProneMax,
                      )
                    : _unknownValue,
              ),
              cell(
                _colDetWidth,
                knowledge?.determinationKnown == true
                    ? _rangeLabel(
                        knowledge?.determinationMin,
                        knowledge?.determinationMax,
                      )
                    : _unknownValue,
              ),
              if (showRoleColumn)
                cell(
                  _colRoleWidth,
                  showCombinedRole
                      ? assignedRoleLabel(context, prospect.optimalRole)
                      : _unknownValue,
                ),
            ],
          ),
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

  void _toggleCombine(String id, bool? selected) {
    setState(() {
      if (selected == true) {
        _combineIds.add(id);
      } else {
        _combineIds.remove(id);
      }
    });
  }

  Future<void> _openCombineMode() async {
    await ref
        .read(gameControllerProvider.notifier)
        .setScoutWatchlist(_selectedIds.toList());
    if (!mounted) return;
    final savedWatchlist =
        ref
            .read(activeLeagueProvider)
            ?.playerTeam
            ?.scouting
            .watchlistProspectIds ??
        const <String>[];
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(savedWatchlist);
      _combineIds.retainAll(savedWatchlist);
      _combineMode = true;
      _watchOnly = true;
    });
  }

  void _showProspectDetail(
    BuildContext context,
    AppLocalizations l10n,
    Prospect prospect,
    TeamScouting? scouting, {
    required bool showOptimalRole,
  }) {
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
          showOptimalRole: showOptimalRole,
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
    required this.showOptimalRole,
  });

  final AppLocalizations l10n;
  final Prospect prospect;
  final ScoutingKnowledge? knowledge;
  final ScrollController scrollController;
  final bool showOptimalRole;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tier = knowledge?.tier;
    final tierIndex = tier?.index ?? -1;

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
          Row(
            children: [
              Text(
                '${prospect.position.code} · ',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              NationalityFlagIcon(prospect.nationality),
              Text(
                ' · ${prospect.age} · ${prospect.heightCm} cm',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
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
            // Tier 2+: estimated overall range.
            if (tierIndex >= ScoutingTier.tier2.index)
              _detailRow(
                l10n.prospects_overallRange,
                _rangeLabel(
                  knowledge?.estimatedOvrMin,
                  knowledge?.estimatedOvrMax,
                ),
              ),
            // Tier 3+: estimated draft slot.
            if (tierIndex >= ScoutingTier.tier3.index)
              _detailRow(
                l10n.prospects_estimatedSlot,
                _slotLabel(l10n, knowledge?.estimatedSlot),
              ),
            // Tier 4+: estimated potential range.
            if (tierIndex >= ScoutingTier.tier4.index)
              _detailRow(
                l10n.prospects_potential,
                _rangeLabel(
                  knowledge?.estimatedPotentialMin?.round(),
                  knowledge?.estimatedPotentialMax?.round(),
                ),
              ),
            // Injury/determination only become known via Combine, regardless
            // of tier (see `ScoutingService.runCombine`).
            if (knowledge?.injuryProneKnown == true)
              _detailRow(
                l10n.prospects_injuryProne,
                _rangeLabel(
                  knowledge?.injuryProneMin,
                  knowledge?.injuryProneMax,
                ),
              ),
            if (knowledge?.determinationKnown == true)
              _detailRow(
                l10n.prospects_determination,
                _rangeLabel(
                  knowledge?.determinationMin,
                  knowledge?.determinationMax,
                ),
              ),
            if (showOptimalRole)
              _detailRow(
                l10n.scouting_combineRole,
                assignedRoleLabel(context, prospect.optimalRole),
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
