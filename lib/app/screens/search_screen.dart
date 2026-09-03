import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/branding/club_color_tokens.dart';
import 'package:new_football/app/providers/club_branding_provider.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/search_filters_provider.dart';
import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/scouting.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    final saveKey = ref.watch(activeSearchFiltersKeyProvider);
    final filters = ref.watch(searchFiltersProvider(saveKey));

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

    if (league == null) {
      return Scaffold(
        appBar: _appBar(context, l10n, headerBackground, headerForeground),
        body: Center(child: Text(l10n.search_noResults)),
      );
    }

    final results = _results(context, league, filters, l10n);

    return Scaffold(
      appBar: _appBar(context, l10n, headerBackground, headerForeground),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: l10n.search_hint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _controller.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _controller.clear();
                                setState(() {});
                              },
                            ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: l10n.search_optionsButton,
                  icon: const Icon(Icons.tune),
                  onPressed: () => context.push('/game/search/filters'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (results.isEmpty)
              Card(child: ListTile(title: Text(l10n.search_noResults)))
            else
              ...results.map((result) => _resultTile(context, result)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(
    BuildContext context,
    AppLocalizations l10n,
    Color background,
    Color foreground,
  ) {
    return AppBar(
      title: Text(l10n.search_title),
      backgroundColor: background,
      foregroundColor: foreground,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
    );
  }

  String _tradeRoute({
    String? ownPlayerId,
    String? targetTeamId,
    String? theirPlayerId,
    String? theirPickId,
  }) {
    final query = <String, String>{
      if (ownPlayerId != null) 'ownPlayerId': ownPlayerId,
      if (targetTeamId != null) 'targetTeamId': targetTeamId,
      if (theirPlayerId != null) 'theirPlayerId': theirPlayerId,
      if (theirPickId != null) 'theirPickId': theirPickId,
    };
    return Uri(path: '/game/trade', queryParameters: query).toString();
  }

  bool _queryOrFiltersActive(String query, SearchFiltersState filters) {
    if (query.isNotEmpty) return true;
    final p = filters.players;
    final pr = filters.prospects;
    final pk = filters.picks;
    return p.nationality != null ||
        p.position != null ||
        p.optimalRole != null ||
        p.potential.isSet ||
        p.age.isSet ||
        p.ovr.isSet ||
        p.salary.isSet ||
        p.contractLength.isSet ||
        p.clubIds.isNotEmpty ||
        pr.nationality != null ||
        pr.position != null ||
        pr.optimalRole != null ||
        pr.potential.isSet ||
        pr.age.isSet ||
        pr.ovr.isSet ||
        pr.scoutingTiers.isNotEmpty ||
        pk.clubIds.isNotEmpty ||
        pk.originalClubIds.isNotEmpty ||
        pk.rounds.isNotEmpty ||
        pk.year.isSet;
  }

  List<_SearchResult> _results(
    BuildContext context,
    LeagueState league,
    SearchFiltersState filters,
    AppLocalizations l10n,
  ) {
    final query = _controller.text.trim().toLowerCase();
    if (!_queryOrFiltersActive(query, filters)) return const [];

    final players = <_SearchResult>[];
    final prospects = <_SearchResult>[];
    final picks = <_SearchResult>[];

    if (filters.groups.contains(SearchGroup.players)) {
      for (final team in league.teams) {
        for (final player in team.roster) {
          if (!player.name.toLowerCase().contains(query)) continue;
          if (!_matchesPlayerFilters(player, team.id, filters.players)) {
            continue;
          }
          players.add(_playerResult(context, l10n, league, team, player));
        }
      }
      for (final player in league.freeAgents) {
        if (!player.name.toLowerCase().contains(query)) continue;
        if (!_matchesPlayerFilters(player, null, filters.players)) continue;
        players.add(_freeAgentResult(context, l10n, player));
      }
      players.sort((a, b) => b.value.compareTo(a.value));
    }

    if (filters.groups.contains(SearchGroup.prospects)) {
      final draftState =
          league.currentSeason.draftState ??
          league.currentSeason.nextDraftState;
      final scouting = league.playerTeam?.scouting;
      final combineAvailable =
          league.currentSeason.scoutReportDone &&
          !league.currentSeason.combineDone;
      for (final prospect
          in draftState?.draftClass.prospects ?? const <Prospect>[]) {
        if (!prospect.name.toLowerCase().contains(query)) continue;
        final knowledge = scouting?.forProspect(prospect.id);
        final roleKnown =
            !combineAvailable &&
            (scouting?.combineAssignedProspectIds.contains(prospect.id) ??
                false);
        if (!_matchesProspectFilters(
          prospect,
          knowledge,
          roleKnown,
          filters.prospects,
        )) {
          continue;
        }
        prospects.add(
          _prospectResult(context, l10n, prospect, knowledge?.mockRank ?? 0),
        );
      }
      prospects.sort((a, b) {
        final rankA = a.value;
        final rankB = b.value;
        if (rankA == 0 && rankB == 0) return 0;
        if (rankA == 0) return 1;
        if (rankB == 0) return -1;
        return rankA.compareTo(rankB);
      });
    }

    if (filters.groups.contains(SearchGroup.picks)) {
      for (final team in league.teams) {
        for (final pick in team.ownedPicks) {
          final ownerTeam = league.teamById(pick.teamId);
          final originalTeam = league.teamById(pick.originalTeamId);
          final searchable =
              '${ownerTeam?.name ?? ''} ${originalTeam?.name ?? ''} '
                      '${pick.year} r${pick.round}'
                  .toLowerCase();
          if (query.isNotEmpty && !searchable.contains(query)) continue;
          if (!_matchesPickFilters(pick, filters.picks)) continue;
          picks.add(
            _pickResult(context, l10n, league, pick, ownerTeam, originalTeam),
          );
        }
      }
      picks.sort((a, b) => b.value.compareTo(a.value));
    }

    return [...players, ...prospects, ...picks];
  }

  bool _matchesPlayerFilters(
    Player player,
    String? teamId,
    PlayersFilterState f,
  ) {
    if (f.nationality != null && player.nationality != f.nationality) {
      return false;
    }
    if (f.position != null && player.position != f.position) return false;
    if (f.optimalRole != null && player.optimalRole != f.optimalRole) {
      return false;
    }
    if (!f.potential.matches(player.potentialStars)) return false;
    if (!f.age.matches(player.age.toDouble())) return false;
    if (!f.ovr.matches(player.overall())) return false;
    if (!f.salary.matches(player.contract.salary.toDouble())) return false;
    if (!f.contractLength.matches(player.contract.yearsRemaining.toDouble())) {
      return false;
    }
    if (f.clubIds.isNotEmpty) {
      final key = teamId ?? PlayersFilterState.noClubSentinel;
      if (!f.clubIds.contains(key)) return false;
    }
    return true;
  }

  bool _matchesProspectFilters(
    Prospect prospect,
    ScoutingKnowledge? knowledge,
    bool roleKnown,
    ProspectsFilterState f,
  ) {
    if (f.nationality != null && prospect.nationality != f.nationality) {
      return false;
    }
    if (f.position != null && prospect.position != f.position) return false;
    if (f.optimalRole != null) {
      if (!roleKnown || prospect.optimalRole != f.optimalRole) return false;
    }
    if (f.potential.isSet) {
      final min = knowledge?.estimatedPotentialMin;
      final max = knowledge?.estimatedPotentialMax;
      if (min == null || max == null) return false;
      if (!_rangesOverlap(f.potential.min, f.potential.max, min, max)) {
        return false;
      }
    }
    if (!f.age.matches(prospect.age.toDouble())) return false;
    if (f.ovr.isSet) {
      final min = knowledge?.estimatedOvrMin;
      final max = knowledge?.estimatedOvrMax;
      if (min == null || max == null) return false;
      if (!_rangesOverlap(
        f.ovr.min,
        f.ovr.max,
        min.toDouble(),
        max.toDouble(),
      )) {
        return false;
      }
    }
    if (f.scoutingTiers.isNotEmpty) {
      final tier = knowledge?.tier;
      if (tier == null || !f.scoutingTiers.contains(tier.index)) return false;
    }
    return true;
  }

  bool _matchesPickFilters(DraftPick pick, PicksFilterState f) {
    if (f.clubIds.isNotEmpty && !f.clubIds.contains(pick.teamId)) {
      return false;
    }
    if (f.originalClubIds.isNotEmpty &&
        !f.originalClubIds.contains(pick.originalTeamId)) {
      return false;
    }
    if (f.rounds.isNotEmpty && !f.rounds.contains(pick.round)) return false;
    if (!f.year.matches(pick.year.toDouble())) return false;
    return true;
  }

  /// Whether [filterMin]-[filterMax] (either bound may be unset, meaning
  /// unbounded on that side) overlaps the known [knownMin]-[knownMax] range.
  bool _rangesOverlap(
    double? filterMin,
    double? filterMax,
    double knownMin,
    double knownMax,
  ) {
    if (filterMin != null && knownMax < filterMin) return false;
    if (filterMax != null && knownMin > filterMax) return false;
    return true;
  }

  _SearchResult _playerResult(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    Team team,
    Player player,
  ) {
    return _SearchResult(
      title: player.name,
      subtitle: l10n.search_playerResult(team.name, player.position.code),
      value: player.pointValue.toDouble(),
      leading: _ValueBar(value: player.pointValue.toDouble(), l10n: l10n),
      onTap: () => context.push('/game/player/${player.id}'),
      actionLabel: l10n.search_tradeAction,
      action: () => context.push(
        _tradeRoute(
          ownPlayerId: team.id == league.playerTeamId ? player.id : null,
          targetTeamId: team.id == league.playerTeamId ? null : team.id,
          theirPlayerId: team.id == league.playerTeamId ? null : player.id,
        ),
      ),
    );
  }

  _SearchResult _freeAgentResult(
    BuildContext context,
    AppLocalizations l10n,
    Player player,
  ) {
    return _SearchResult(
      title: player.name,
      subtitle: l10n.search_freeAgentResult(
        player.position.code,
        player.overall().round(),
      ),
      value: player.pointValue.toDouble(),
      leading: _ValueBar(value: player.pointValue.toDouble(), l10n: l10n),
      onTap: () => context.push('/game/player/${player.id}'),
    );
  }

  _SearchResult _prospectResult(
    BuildContext context,
    AppLocalizations l10n,
    Prospect prospect,
    int mockRank,
  ) {
    return _SearchResult(
      title: prospect.name,
      subtitle: l10n.search_prospectResult(
        prospect.position.code,
        prospect.age,
      ),
      value: mockRank.toDouble(),
      leading: const SizedBox(width: 48),
      onTap: () => context.push(
        Uri(
          path: '/game/prospects',
          queryParameters: {'highlightProspectId': prospect.id},
        ).toString(),
      ),
    );
  }

  _SearchResult _pickResult(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    DraftPick pick,
    Team? ownerTeam,
    Team? originalTeam,
  ) {
    final isOwnPick = pick.teamId == league.playerTeamId;
    return _SearchResult(
      title: '${pick.year} R${pick.round}',
      subtitle: l10n.search_pickResult(
        ownerTeam?.name ?? '',
        pick.round,
        pick.year,
      ),
      value: pick.tradeValue.toDouble(),
      leading: _ValueBar(value: pick.tradeValue.toDouble(), l10n: l10n),
      onTap: isOwnPick
          ? null
          : () => _showPickDialog(context, l10n, pick, ownerTeam),
    );
  }

  void _showPickDialog(
    BuildContext context,
    AppLocalizations l10n,
    DraftPick pick,
    Team? ownerTeam,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.search_pickDialogTitle),
        content: Text(
          l10n.search_pickDialogMessage(
            pick.year,
            pick.round,
            ownerTeam?.name ?? '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.push(
                _tradeRoute(targetTeamId: pick.teamId, theirPickId: pick.id),
              );
            },
            child: Text(l10n.search_pickDialogGoToTrade),
          ),
        ],
      ),
    );
  }

  Widget _resultTile(BuildContext context, _SearchResult result) {
    return Card(
      child: ListTile(
        leading: result.leading,
        title: Text(result.title),
        subtitle: Text(result.subtitle),
        trailing: result.action == null
            ? (result.onTap == null ? null : const Icon(Icons.chevron_right))
            : TextButton(
                onPressed: result.action,
                child: Text(result.actionLabel!),
              ),
        onTap: result.onTap,
      ),
    );
  }
}

/// A clamped, horizontal point-value track — leading widget for every search
/// result tile, replacing the old per-type icon. Mirrors `_PvIndicator` from
/// `player_detail_screen.dart` (same -1000-1000 gradient), duplicated locally
/// since that widget is private to its screen.
class _ValueBar extends StatelessWidget {
  const _ValueBar({required this.value, required this.l10n});

  final double value;
  final AppLocalizations l10n;
  static const double _width = 48.0;

  @override
  Widget build(BuildContext context) {
    final clampedValue = clampedPvValue(value);
    final fill = pvFillForValue(clampedValue);
    final fillColor = pvColorForClampedValue(clampedValue);
    final colors = Theme.of(context).colorScheme;
    final trackColor = colors.surfaceContainerLow;

    return Semantics(
      container: true,
      label: '${l10n.stat_pv} ${clampedValue.round()}',
      child: ExcludeSemantics(
        child: Container(
          width: _width,
          height: 10,
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: Border.all(color: colors.outline, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: trackColor),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: fill,
                  child: ColoredBox(color: fillColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchResult {
  const _SearchResult({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.leading,
    required this.onTap,
    this.actionLabel,
    this.action,
  });

  final String title;
  final String subtitle;

  /// Sort key within this result's group (pointValue / tradeValue / mock
  /// rank — see call sites).
  final double value;
  final Widget leading;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? action;
}
