import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/ai/ai_evaluation_models.dart';
import 'package:new_football/core/ai/ai_evaluation_service.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class RankingsScreen extends ConsumerStatefulWidget {
  const RankingsScreen({super.key});

  @override
  ConsumerState<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends ConsumerState<RankingsScreen> {
  String? _selectedValuationTeamId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    if (league == null) {
      return Scaffold(
        appBar: _appBar(context, l10n),
        body: const Center(child: Text('—')),
      );
    }

    final defaultValuationTeamId =
        league.playerTeamId ??
        (league.teams.isEmpty ? null : league.teams.first.id);
    final valuationTeamId =
        league.teams.any((team) => team.id == _selectedValuationTeamId)
        ? _selectedValuationTeamId
        : defaultValuationTeamId;

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
                league,
                valuationTeamId: valuationTeamId,
                currentYear: league.currentSeason.year,
                onTeamChanged: (teamId) =>
                    setState(() => _selectedValuationTeamId = teamId),
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
    LeagueState league, {
    required String? valuationTeamId,
    required int currentYear,
    required ValueChanged<String> onTeamChanged,
  }) {
    final recipient = valuationTeamId == null
        ? null
        : league.teamById(valuationTeamId);
    final evaluator = const AiEvaluationService();
    final recipientContext = recipient == null
        ? null
        : evaluator.contextForTeam(team: recipient, league: league);
    final assets = <_AssetRow>[];

    for (final team in league.teams) {
      for (final player in team.roster) {
        final valuation = recipientContext == null
            ? AiAssetValuation(
                kind: AiAssetKind.player,
                assetId: player.id,
                value: player.computePointValue().toDouble(),
                pointValue: player.computePointValue().toDouble(),
              )
            : evaluator.evaluatePlayer(
                player,
                recipientContext,
                sourceTeam: team,
              );
        assets.add(
          _AssetRow(
            name: player.name,
            owner: team.name,
            type: l10n.rankings_playerAsset,
            value: valuation.value,
            valuation: valuation,
            player: player,
          ),
        );
      }
      for (final pick in team.ownedPicks) {
        final valuation = recipientContext == null
            ? AiAssetValuation(
                kind: AiAssetKind.pick,
                assetId: pick.id,
                value: pick
                    .computeTradeValue(currentYear: currentYear)
                    .toDouble(),
                pointValue: pick
                    .computeTradeValue(currentYear: currentYear)
                    .toDouble(),
              )
            : evaluator.evaluatePick(
                pick,
                recipientContext,
                currentYear: currentYear,
              );
        assets.add(
          _AssetRow(
            name:
                '${pick.year} R${pick.round}${pick.pickNumber == null ? '' : ' #${pick.pickNumber}'}',
            owner: team.name,
            type: l10n.rankings_pickAsset,
            value: valuation.value,
            valuation: valuation,
          ),
        );
      }
      if (recipientContext != null) {
        for (final rights in league.draftedRights.where(
          (rights) => rights.ownerTeamId == team.id,
        )) {
          final valuation = evaluator.evaluateRights(
            rights,
            recipientContext,
            currentYear: currentYear,
          );
          assets.add(
            _AssetRow(
              name: rights.player.name,
              owner: team.name,
              type: l10n.rankings_rightsAsset,
              value: valuation.value,
              valuation: valuation,
              player: rights.player,
            ),
          );
        }
      }
    }
    assets.sort((a, b) => b.value.compareTo(a.value));
    if (assets.isEmpty) return Center(child: Text(l10n.rankings_noAssets));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          initialValue: valuationTeamId,
          decoration: InputDecoration(
            labelText: l10n.rankings_aiValuationTeam,
            border: const OutlineInputBorder(),
          ),
          items: league.teams
              .map(
                (team) => DropdownMenuItem<String>(
                  value: team.id,
                  child: Text(team.name),
                ),
              )
              .toList(),
          onChanged: (teamId) {
            if (teamId != null) onTeamChanged(teamId);
          },
        ),
        const SizedBox(height: 12),
        if (recipient != null)
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(l10n.rankings_aiValuationDisclaimer(recipient.name)),
            ),
          ),
        ...assets.map(
          (asset) => Card(
            child: ExpansionTile(
              leading: Icon(asset.player == null ? Icons.style : Icons.person),
              title: Text(asset.name),
              subtitle: Text('${asset.type} · ${asset.owner}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${l10n.rankings_assetValue}: ${asset.value.round()}'),
                  if (asset.player != null)
                    IconButton(
                      tooltip: l10n.rankings_openPlayer,
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () =>
                          context.push('/game/player/${asset.player!.id}'),
                    ),
                ],
              ),
              children: [_valuationBreakdown(l10n, asset.valuation)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _valuationBreakdown(
    AppLocalizations l10n,
    AiAssetValuation valuation,
  ) {
    final rows = <Widget>[
      Text('${l10n.rankings_aiBaseValue}: ${valuation.pointValue.round()}'),
      Text(
        '${l10n.rankings_aiStatusAge}: ${valuation.statusAgeMult.toStringAsFixed(2)}',
      ),
      Text(
        '${l10n.rankings_aiNeedMultiplier}: ${valuation.needMult.toStringAsFixed(2)}',
      ),
      Text(
        '${l10n.rankings_aiContextMultiplier}: ${valuation.contextMult.toStringAsFixed(2)}',
      ),
    ];
    if (valuation.projectedSlot != null) {
      rows.add(
        Text(
          '${l10n.rankings_aiProjectedSlot}: ${valuation.projectedSlot!.toStringAsFixed(1)}',
        ),
      );
      rows.add(
        Text(
          '${l10n.rankings_aiFutureDiscount}: ${valuation.futureDiscount.toStringAsFixed(2)} · ${l10n.rankings_aiUncertainty}: ${valuation.uncertaintyMult.toStringAsFixed(2)}',
        ),
      );
    }
    if (valuation.rightsMult != 1.0) {
      rows.add(
        Text(
          '${l10n.rankings_aiRightsMultiplier}: ${valuation.rightsMult.toStringAsFixed(2)}',
        ),
      );
    }
    if (valuation.contractDrag != 0.0) {
      rows.add(
        Text(
          '${l10n.rankings_aiContractDrag}: ${valuation.contractDrag.toStringAsFixed(1)}',
        ),
      );
    }
    if (valuation.contextFactors.isNotEmpty) {
      rows.add(
        Text(
          '${l10n.rankings_aiFactors}: ${valuation.contextFactors.join(', ')}',
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows
            .map(
              (row) =>
                  Padding(padding: const EdgeInsets.only(top: 4), child: row),
            )
            .toList(),
      ),
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
    required this.valuation,
    this.player,
  });

  final String name;
  final String owner;
  final String type;
  final double value;
  final AiAssetValuation valuation;
  final Player? player;
}
