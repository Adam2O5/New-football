import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

enum _SearchType { all, players, teams, prospects, freeAgents }

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  _SearchType _type = _SearchType.all;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    if (league == null) {
      return Scaffold(
        appBar: _appBar(context, l10n),
        body: Center(child: Text(l10n.search_noResults)),
      );
    }
    final results = _results(context, league, l10n);
    return Scaffold(
      appBar: _appBar(context, l10n),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
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
            const SizedBox(height: 8),
            DropdownButton<_SearchType>(
              value: _type,
              items: [
                DropdownMenuItem(
                  value: _SearchType.all,
                  child: Text(l10n.search_allTypes),
                ),
                DropdownMenuItem(
                  value: _SearchType.players,
                  child: Text(l10n.search_players),
                ),
                DropdownMenuItem(
                  value: _SearchType.teams,
                  child: Text(l10n.search_teams),
                ),
                DropdownMenuItem(
                  value: _SearchType.prospects,
                  child: Text(l10n.search_prospects),
                ),
                DropdownMenuItem(
                  value: _SearchType.freeAgents,
                  child: Text(l10n.search_freeAgents),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
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

  PreferredSizeWidget _appBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      title: Text(l10n.search_title),
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
  }) {
    final query = <String, String>{
      if (ownPlayerId != null) 'ownPlayerId': ownPlayerId,
      if (targetTeamId != null) 'targetTeamId': targetTeamId,
      if (theirPlayerId != null) 'theirPlayerId': theirPlayerId,
    };
    return Uri(path: '/game/trade', queryParameters: query).toString();
  }

  List<_SearchResult> _results(
    BuildContext context,
    LeagueState league,
    AppLocalizations l10n,
  ) {
    final query = _controller.text.trim().toLowerCase();
    if (query.isEmpty) return const [];
    final result = <_SearchResult>[];
    bool include(_SearchType type) => _type == _SearchType.all || _type == type;

    if (include(_SearchType.teams)) {
      for (final team in league.teams) {
        if (team.name.toLowerCase().contains(query)) {
          result.add(
            _SearchResult(
              icon: Icons.groups_outlined,
              title: team.name,
              subtitle: l10n.search_teamResult(team.conference.label),
              onTap: () => context.push('/game/stats'),
              actionLabel: l10n.search_tradeAction,
              action: () => context.push(
                _tradeRoute(
                  targetTeamId: team.id == league.playerTeamId ? null : team.id,
                ),
              ),
            ),
          );
        }
      }
    }
    if (include(_SearchType.players)) {
      for (final team in league.teams) {
        for (final player in team.roster) {
          if (player.name.toLowerCase().contains(query)) {
            result.add(
              _SearchResult(
                icon: Icons.person_outline,
                title: player.name,
                subtitle: l10n.search_playerResult(
                  team.name,
                  player.position.code,
                ),
                onTap: () => context.push('/game/player/${player.id}'),
                actionLabel: l10n.search_tradeAction,
                action: () => context.push(
                  _tradeRoute(
                    ownPlayerId: team.id == league.playerTeamId
                        ? player.id
                        : null,
                    targetTeamId: team.id == league.playerTeamId
                        ? null
                        : team.id,
                    theirPlayerId: team.id == league.playerTeamId
                        ? null
                        : player.id,
                  ),
                ),
              ),
            );
          }
        }
      }
    }
    if (include(_SearchType.freeAgents)) {
      for (final player in league.freeAgents) {
        if (player.name.toLowerCase().contains(query)) {
          result.add(
            _SearchResult(
              icon: Icons.person_search_outlined,
              title: player.name,
              subtitle: l10n.search_freeAgentResult(
                player.position.code,
                player.overall().round(),
              ),
              onTap: () => context.push('/game/free-agency'),
            ),
          );
        }
      }
    }
    if (include(_SearchType.prospects)) {
      final draft =
          league.currentSeason.nextDraftState ??
          league.currentSeason.draftState;
      for (final prospect
          in draft?.draftClass.prospects ?? const <Prospect>[]) {
        if (prospect.name.toLowerCase().contains(query)) {
          result.add(
            _SearchResult(
              icon: Icons.school_outlined,
              title: prospect.name,
              subtitle: l10n.search_prospectResult(
                prospect.position.code,
                prospect.age,
              ),
              onTap: () => context.push('/game/prospects'),
            ),
          );
        }
      }
    }
    return result;
  }

  Widget _resultTile(BuildContext context, _SearchResult result) {
    return Card(
      child: ListTile(
        leading: Icon(result.icon),
        title: Text(result.title),
        subtitle: Text(result.subtitle),
        trailing: result.action == null
            ? const Icon(Icons.chevron_right)
            : TextButton(
                onPressed: result.action,
                child: Text(result.actionLabel!),
              ),
        onTap: result.onTap,
      ),
    );
  }
}

class _SearchResult {
  const _SearchResult({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.actionLabel,
    this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? actionLabel;
  final VoidCallback? action;
}
