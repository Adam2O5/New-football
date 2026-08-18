import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/trade_models.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class TradeHistoryScreen extends ConsumerStatefulWidget {
  const TradeHistoryScreen({super.key});

  @override
  ConsumerState<TradeHistoryScreen> createState() => _TradeHistoryScreenState();
}

class _TradeHistoryScreenState extends ConsumerState<TradeHistoryScreen> {
  String? _outcomeFilter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    if (league == null) {
      return Scaffold(
        appBar: _appBar(context, l10n),
        body: ScreenBackground(
          child: Center(child: Text(l10n.tradeHistory_noLeague)),
        ),
      );
    }

    final entries = [...league.tradeHistory]
      ..sort((a, b) {
        final season = b.seasonYear.compareTo(a.seasonYear);
        if (season != 0) return season;
        final week = b.week.compareTo(a.week);
        if (week != 0) return week;
        final day = b.day.compareTo(a.day);
        if (day != 0) return day;
        return b.round.compareTo(a.round);
      });
    final filtered = _outcomeFilter == null
        ? entries
        : entries.where((entry) => entry.outcome == _outcomeFilter).toList();

    return Scaffold(
      appBar: _appBar(context, l10n),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String?>(
              initialValue: _outcomeFilter,
              decoration: InputDecoration(labelText: l10n.tradeHistory_filter),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l10n.tradeHistory_allOutcomes),
                ),
                for (final outcome in _knownOutcomes)
                  DropdownMenuItem<String?>(
                    value: outcome,
                    child: Text(_outcomeLabel(l10n, outcome)),
                  ),
              ],
              onChanged: (value) => setState(() => _outcomeFilter = value),
            ),
            const SizedBox(height: 16),
            if (entries.isEmpty)
              Card(child: ListTile(title: Text(l10n.tradeHistory_empty)))
            else if (filtered.isEmpty)
              Card(child: ListTile(title: Text(l10n.tradeHistory_noMatches)))
            else
              ...filtered.map(
                (entry) => _historyCard(context, l10n, league, entry),
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      title: Text(l10n.tradeHistory_title),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: l10n.common_cancel,
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _historyCard(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    TradeHistoryEntry entry,
  ) {
    final teamA = league.teamById(entry.teamAId)?.name ?? entry.teamAId;
    final teamB = league.teamById(entry.teamBId)?.name ?? entry.teamBId;
    final outcome = _outcomeLabel(l10n, entry.outcome);
    final colorScheme = Theme.of(context).colorScheme;
    final outcomeColor = switch (entry.outcome) {
      'accepted' => colorScheme.primary,
      'ntcRefused' ||
      'rejected' ||
      'hardRejected' ||
      'cancelled' => colorScheme.error,
      _ => colorScheme.onSurfaceVariant,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: Icon(Icons.swap_horiz, color: outcomeColor),
        title: Text('$teamA ↔ $teamB'),
        subtitle: Text(
          '${l10n.tradeHistory_date(entry.seasonYear, entry.week, entry.day)} · '
          '${l10n.tradeHistory_round(entry.round)} · $outcome',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          if (entry.reason != null && entry.reason!.isNotEmpty)
            _detailRow(l10n.tradeHistory_reason, entry.reason!),
          if (entry.ntcConsentProbability != null)
            _detailRow(
              l10n.tradeHistory_ntcProbability,
              '${(entry.ntcConsentProbability! * 100).toStringAsFixed(1)}%',
            ),
          _assetGroup(
            context,
            l10n,
            league,
            l10n.tradeHistory_sentBy(teamA),
            entry.assetsFromA,
          ),
          _assetGroup(
            context,
            l10n,
            league,
            l10n.tradeHistory_sentBy(teamB),
            entry.assetsFromB,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text('$label: $value'),
      ),
    );
  }

  Widget _assetGroup(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    String title,
    List<TradeAssetSnapshot> assets,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          if (assets.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(l10n.tradeHistory_noAssets),
            )
          else
            ...assets.map(
              (asset) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(_assetLabel(l10n, league, asset)),
              ),
            ),
        ],
      ),
    );
  }

  String _assetLabel(
    AppLocalizations l10n,
    LeagueState league,
    TradeAssetSnapshot asset,
  ) {
    return switch (asset.type) {
      'player' => l10n.tradeHistory_player(
        _playerName(league, asset.playerId) ?? asset.playerId ?? '—',
      ),
      'pick' => l10n.tradeHistory_pick(
        asset.pickYear ?? 0,
        asset.pickRound ?? 0,
      ),
      'draftedRights' => l10n.tradeHistory_rights(
        _playerName(league, asset.draftedRightsId) ??
            asset.draftedRightsId ??
            '—',
      ),
      _ => l10n.tradeHistory_unknownAsset(asset.type),
    };
  }

  String? _playerName(LeagueState league, String? id) {
    if (id == null) return null;
    for (final team in league.teams) {
      for (final player in team.roster) {
        if (player.id == id) return player.name;
      }
    }
    for (final player in league.freeAgents) {
      if (player.id == id) return player.name;
    }
    for (final rights in league.draftedRights) {
      if (rights.id == id || rights.player.id == id) return rights.player.name;
    }
    return null;
  }

  String _outcomeLabel(AppLocalizations l10n, String outcome) {
    return switch (outcome) {
      'accepted' => l10n.tradeHistory_outcomeAccepted,
      'rejected' => l10n.tradeHistory_outcomeRejected,
      'hardRejected' => l10n.tradeHistory_outcomeHardRejected,
      'expired' => l10n.tradeHistory_outcomeExpired,
      'ntcRefused' => l10n.tradeHistory_outcomeNtcRefused,
      'cancelled' => l10n.tradeHistory_outcomeCancelled,
      _ => outcome,
    };
  }

  static const _knownOutcomes = [
    'accepted',
    'rejected',
    'hardRejected',
    'expired',
    'ntcRefused',
    'cancelled',
  ];
}
