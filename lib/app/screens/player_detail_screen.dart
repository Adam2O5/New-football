import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class PlayerDetailScreen extends ConsumerWidget {
  const PlayerDetailScreen({super.key, required this.playerId});

  final String playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    Player? player;
    String? teamName;
    if (league != null) {
      for (final t in league.teams) {
        for (final p in t.roster) {
          if (p.id == playerId) {
            player = p;
            teamName = t.name;
            break;
          }
        }
        if (player != null) break;
      }
    }

    if (player == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.playerDetail_title)),
        body: ScreenBackground(
          child: Center(child: Text(l10n.playerDetail_notFound)),
        ),
      );
    }

    final p = player;
    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.playerDetail_headerLine(
                p.position.code,
                p.nationality.label,
                p.age,
              ),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (teamName != null) Text(teamName),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(context, l10n.stat_ovr, '${p.overall().round()}'),
                _chip(context, l10n.stat_form, '${p.state.form}'),
                _chip(context, l10n.stat_cond, '${p.state.stamina}%'),
                _chip(context, l10n.stat_pv, '${p.tradeValue}'),
                _chip(
                  context,
                  l10n.stat_pot,
                  p.potentialStars.toStringAsFixed(1),
                ),
                _chip(context, l10n.stat_height, '${p.heightCm} cm'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.playerDetail_attributes,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ..._attributeRows(p),
            const SizedBox(height: 16),
            Text(
              l10n.playerDetail_contract,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Card(
              child: ListTile(
                title: Text(
                  l10n.playerDetail_salaryLine(
                    formatMoney(context, p.contract.salary),
                  ),
                ),
                subtitle: Text(
                  l10n.playerDetail_contractYears(p.contract.yearsRemaining) +
                      (p.contract.hasBirdRights
                          ? ' · ${l10n.playerDetail_birdRights}'
                          : '') +
                      (p.contract.noTradeClause
                          ? ' · ${l10n.playerDetail_noTradeClause}'
                          : ''),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.playerDetail_personality(p.personality.name),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _attributeRows(Player p) {
    return p.attributes.map(
      outfield: (a) => [
        _bar('Pace', a.stats.pace),
        _bar('Shooting', a.stats.shooting),
        _bar('Passing', a.stats.passing),
        _bar('Dribbling', a.stats.dribbling),
        _bar('Defending', a.stats.defending),
        _bar('Physical', a.stats.physicality),
      ],
      goalkeeper: (a) => [
        _bar('Diving', a.stats.diving),
        _bar('Handling', a.stats.handling),
        _bar('Kicking', a.stats.kicking),
        _bar('Reflexes', a.stats.reflexes),
        _bar('Speed', a.stats.speed),
        _bar('Positioning', a.stats.positioning),
      ],
    );
  }

  Widget _bar(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: (value / 99).clamp(0.0, 1.0),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 28, child: Text('$value', textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, String value) {
    return Chip(label: Text('$label $value'));
  }
}
