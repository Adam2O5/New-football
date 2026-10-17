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

part 'prospect_detail_content.dart';
part 'prospects_table.dart';

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

/// Displayed mock draft slot (`draft.md` §"Dwa mock drafty"), with the
/// position-change indicator vs. the previous mock. The indicator only
/// renders once a previous board exists — i.e. after the mock finalny, never
/// after the mock wstępny, since there's nothing yet to compare it to.
Widget _buildMockRankCell(int? mockRank, int? previousMockRank) {
  if (mockRank == null) {
    return const Text(_unknownValue, textAlign: TextAlign.center);
  }
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('$mockRank', textAlign: TextAlign.center),
      if (previousMockRank != null)
        _buildMockRankDelta(previousMockRank - mockRank),
    ],
  );
}

/// Delta > 0: prospect climbed the board (lower slot number) → green ▲.
/// Delta < 0: prospect fell → red ▼. Delta == 0: unchanged → blue ⏸.
Widget _buildMockRankDelta(int delta) {
  if (delta == 0) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.pause, size: 10, color: Colors.blue),
        Text('0', style: TextStyle(fontSize: 9, color: Colors.blue)),
      ],
    );
  }
  final rising = delta > 0;
  final color = rising ? Colors.green : Colors.red;
  final icon = rising ? Icons.arrow_drop_up : Icons.arrow_drop_down;
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: color),
      Text('${delta.abs()}', style: TextStyle(fontSize: 9, color: color)),
    ],
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

class _ProspectsScreenState extends ConsumerState<ProspectsScreen>
    with _ProspectsScreenShared, _ProspectsTable {
  @override
  final Set<String> _selectedIds = {};
  @override
  final Set<String> _combineIds = {};
  Position? _positionFilter;
  bool _watchOnly = false;
  @override
  bool _combineMode = false;
  bool _initialized = false;
  bool _combineInitialized = false;

  // Scroll-to-row support for arriving from the search screen with a
  // specific prospect to highlight.
  @override
  final ScrollController _tableScrollController = ScrollController();
  final Map<String, GlobalKey> _rowKeys = {};
  @override
  String? _highlightedProspectId;
  bool _didScrollToHighlight = false;

  // `ref.read` is unsafe inside `dispose()` (the widget may already be
  // unmounted by then), so the notifier is cached here on every dependency
  // change while the widget is still alive, and `dispose()` only touches
  // this field. Typed as `dynamic` because the concrete notifier type isn't
  // available here — it only needs to expose `setScoutWatchlist` and
  // `setCombineAssignments`, both already used by the rest of this screen.
  dynamic _gameController;

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

    final draftState = league.currentSeason.draftState;
    final mockBoard = draftState?.mockDraftBoard;
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
                mockBoard,
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

  @override
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
    LeagueState league,
    MockDraftBoard? mockBoard, {
    required bool combineAvailable,
  }) {
    final coverage = league.playerTeam?.staff.scout?.attributes.coverage ?? 0.0;
    final scoutingService = ref.read(scoutingServiceProvider);
    final watchlistLimit = scoutingService.maxWatched(coverage);
    final combineLimit = scoutingService.combineAssignLimit(coverage);
    final visible = _filteredProspects(
      prospects,
      scouting,
      mockBoard,
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
                    mockBoard,
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
    TeamScouting? scouting,
    MockDraftBoard? mockBoard, {
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

    // Ordered by the current displayed mock draft board (`draft.md`
    // §"Dwa mock drafty"), not by name. Prospects missing from the board
    // (shouldn't happen once a class has been generated, but guards against
    // stale saves) sort after everyone with a known slot, alphabetically.
    final ranks = mockBoard?.displayedRank ?? const <String, int>{};
    filtered.sort((a, b) {
      final rankA = ranks[a.id];
      final rankB = ranks[b.id];
      if (rankA == null && rankB == null) return a.name.compareTo(b.name);
      if (rankA == null) return 1;
      if (rankB == null) return -1;
      return rankA.compareTo(rankB);
    });
    return filtered;
  }

  @override
  void _toggleWatchlist(String id, bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  @override
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

  @override
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

mixin _ProspectsScreenShared on ConsumerState<ProspectsScreen> {
  Set<String> get _selectedIds;

  Set<String> get _combineIds;

  bool get _combineMode;

  ScrollController get _tableScrollController;

  String? get _highlightedProspectId;

  GlobalKey _rowKey(String prospectId);

  void _toggleWatchlist(String id, bool? selected);

  void _toggleCombine(String id, bool? selected);

  void _showProspectDetail(
    BuildContext context,
    AppLocalizations l10n,
    Prospect prospect,
    TeamScouting? scouting, {
    required bool showOptimalRole,
  });
}
