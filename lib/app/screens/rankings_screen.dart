import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class RankingsScreen extends ConsumerWidget {
  const RankingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    if (league == null) {
      return Scaffold(
        appBar: _appBar(context, l10n),
        body: const Center(child: Text('—')),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.rankings_title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.rankings_power),
              Tab(text: l10n.rankings_expected),
              Tab(text: l10n.rankings_assets),
            ],
          ),
        ),
        body: ScreenBackground(
          child: TabBarView(
            children: [
              _strengthTab(context, l10n, league.strengthTable),
              _expectedTab(context, l10n, league.strengthTable),
              _assetsTab(
                context,
                l10n,
                league.teams,
                league.currentSeason.year,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context, AppLocalizations l10n) =>
      AppBar(title: Text(l10n.rankings_title));

  Widget _strengthTab(
    BuildContext context,
    AppLocalizations l10n,
    LeagueStrengthTable? table,
  ) {
    if (table == null || table.entries.isEmpty) {
      return Center(child: Text(l10n.rankings_noStrength));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.rankings_updated(
            table.lastCalculatedWeek,
            table.lastCalculatedDay,
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        ...table.entries.map(
          (entry) => _strengthCard(context, l10n, table, entry),
        ),
      ],
    );
  }

  Widget _expectedTab(
    BuildContext context,
    AppLocalizations l10n,
    LeagueStrengthTable? table,
  ) {
    if (table == null || table.entries.isEmpty) {
      return Center(child: Text(l10n.rankings_noStrength));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(l10n.rankings_expectedDisclaimer),
          ),
        ),
        ...table.entries.map(
          (entry) =>
              _strengthCard(context, l10n, table, entry, showPower: false),
        ),
      ],
    );
  }

  Widget _strengthCard(
    BuildContext context,
    AppLocalizations l10n,
    LeagueStrengthTable table,
    TeamStrengthEntry entry, {
    bool showPower = true,
  }) {
    final league = ProviderScope.containerOf(
      context,
    ).read(activeLeagueProvider);
    final team = league?.teamById(entry.teamId);
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('${entry.expectedRank}')),
        title: Text(team?.name ?? entry.teamId),
        subtitle: Text(
          showPower
              ? '${l10n.rankings_powerValue}: ${entry.teamPower.toStringAsFixed(2)} · ${_statusLabel(l10n, entry.teamStatus)}'
              : _statusLabel(l10n, entry.teamStatus),
        ),
        trailing: Text('#${entry.expectedRank}'),
      ),
    );
  }

  Widget _assetsTab(
    BuildContext context,
    AppLocalizations l10n,
    List<Team> teams,
    int currentYear,
  ) {
    final assets = <_AssetRow>[];
    for (final team in teams) {
      for (final player in team.roster) {
        assets.add(
          _AssetRow(
            name: player.name,
            owner: team.name,
            type: l10n.rankings_playerAsset,
            value: player.computePointValue(),
            player: player,
          ),
        );
      }
      for (final pick in team.ownedPicks) {
        assets.add(
          _AssetRow(
            name:
                '${pick.year} R${pick.round}${pick.pickNumber == null ? '' : ' #${pick.pickNumber}'}',
            owner: team.name,
            type: l10n.rankings_pickAsset,
            value: pick.computeTradeValue(currentYear: currentYear),
          ),
        );
      }
    }
    assets.sort((a, b) => b.value.compareTo(a.value));
    if (assets.isEmpty) return Center(child: Text(l10n.rankings_noAssets));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: assets
          .map(
            (asset) => Card(
              child: ListTile(
                leading: Icon(
                  asset.player == null ? Icons.style : Icons.person,
                ),
                title: Text(asset.name),
                subtitle: Text('${asset.type} · ${asset.owner}'),
                trailing: Text('${l10n.rankings_assetValue}: ${asset.value}'),
                onTap: asset.player == null
                    ? null
                    : () => context.push('/game/player/${asset.player!.id}'),
              ),
            ),
          )
          .toList(),
    );
  }

  String _statusLabel(AppLocalizations l10n, TeamStatus status) =>
      switch (status) {
        TeamStatus.rebuild => l10n.rankings_statusRebuild,
        TeamStatus.retool => l10n.rankings_statusRetool,
        TeamStatus.pretender => l10n.rankings_statusPretender,
        TeamStatus.contender => l10n.rankings_statusContender,
        TeamStatus.elite => l10n.rankings_statusElite,
      };
}

class _AssetRow {
  const _AssetRow({
    required this.name,
    required this.owner,
    required this.type,
    required this.value,
    this.player,
  });

  final String name;
  final String owner;
  final String type;
  final int value;
  final Player? player;
}
