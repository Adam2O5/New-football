import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_attributes.dart';
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
      for (final team in league.teams) {
        for (final candidate in team.roster) {
          if (candidate.id == playerId) {
            player = candidate;
            teamName = team.name;
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
    final currentRole = roleDisplayInfo(p.state.role).label;
    final optimalRole = roleDisplayInfo(p.optimalRole).label;
    final injuryLabel = switch (p.state.injuryType) {
      InjuryType.minor => l10n.matchEvent_minorInjury,
      InjuryType.major => l10n.matchEvent_majorInjury,
      null => l10n.playerDetail_health,
    };

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
                _chip(context, l10n.stat_pv, '${p.pointValue}'),
                _chip(
                  context,
                  l10n.stat_pot,
                  p.potentialStars.toStringAsFixed(1),
                ),
                _chip(context, l10n.stat_height, '${p.heightCm} cm'),
              ],
            ),
            const SizedBox(height: 16),
            _sectionTitle(context, l10n.playerDetail_health),
            Card(
              child: ListTile(
                leading: Icon(
                  p.isAvailable ? Icons.check_circle : Icons.healing,
                  color: p.isAvailable ? Colors.green : Colors.orange,
                ),
                title: Text(
                  p.isAvailable
                      ? l10n.playerDetail_available
                      : l10n.playerDetail_injury(injuryLabel),
                ),
                subtitle: p.state.injured
                    ? Text(
                        l10n.playerDetail_injuryDays(
                          p.state.injuryDaysRemaining,
                        ),
                      )
                    : Text('${l10n.stat_cond}: ${p.state.stamina}%'),
              ),
            ),
            const SizedBox(height: 16),
            _sectionTitle(context, l10n.playerDetail_roleTeam),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.sports_soccer),
                    title: Text(l10n.playerDetail_currentRole(currentRole)),
                    subtitle: Text(l10n.playerDetail_optimalRole(optimalRole)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.groups_outlined),
                    title: Text(teamName ?? l10n.playerDetail_notFound),
                    subtitle: Text(
                      l10n.playerDetail_seasonsWithTeam(
                        p.state.seasonsWithTeam,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sectionTitle(context, l10n.playerDetail_attributes),
            ..._attributeRows(p),
            const SizedBox(height: 16),
            _sectionTitle(context, l10n.playerDetail_contract),
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
            const SizedBox(height: 16),
            _sectionTitle(context, l10n.playerDetail_history),
            _historySection(context, l10n, p, league?.currentSeason.year),
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

  Widget _historySection(
    BuildContext context,
    AppLocalizations l10n,
    Player p,
    int? currentSeasonYear,
  ) {
    if (p.seasonStats.isEmpty) {
      return Text(l10n.playerDetail_noHistory);
    }

    final seasons = [...p.seasonStats]
      ..sort((a, b) => b.year.compareTo(a.year));
    final career = p.careerSeasonStats;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statsCard(context, l10n.playerDetail_career, career, l10n),
        const SizedBox(height: 8),
        ...seasons.map(
          (season) => _statsCard(
            context,
            '${l10n.playerDetail_season} ${season.year}',
            season,
            l10n,
            showFullBoxScore: season.year == currentSeasonYear,
          ),
        ),
      ],
    );
  }

  Widget _statsCard(
    BuildContext context,
    String title,
    PlayerSeasonStats stats,
    AppLocalizations l10n, {
    bool showFullBoxScore = false,
  }) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                Text('${l10n.playerDetail_appearances}: ${stats.appearances}'),
                Text('${l10n.playerDetail_minutes}: ${stats.minutes}'),
                Text('${l10n.playerDetail_goals}: ${stats.goals}'),
                Text('${l10n.playerDetail_assists}: ${stats.assists}'),
                Text(
                  '${l10n.playerDetail_rating}: ${stats.ratingAvg.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
          if (showFullBoxScore)
            ExpansionTile(
              title: Text(l10n.stats_boxScore),
              children: [
                _statGrid([
                  _StatLine(l10n.stats_shots, '${stats.shots}'),
                  _StatLine(l10n.stats_shotsOnTarget, '${stats.shotsOnTarget}'),
                  _StatLine(l10n.stats_xg, stats.xg.toStringAsFixed(2)),
                  _StatLine(l10n.stats_passes, '${stats.passes}'),
                  _StatLine(
                    l10n.stats_passAccuracy,
                    '${stats.passAccuracy.toStringAsFixed(1)}%',
                  ),
                  _StatLine(l10n.stats_duelsWon, '${stats.duelsWon}'),
                  _StatLine(l10n.stats_offsides, '${stats.offsides}'),
                  _StatLine(l10n.stats_corners, '${stats.corners}'),
                  _StatLine(l10n.stats_tackles, '${stats.tackles}'),
                  _StatLine(l10n.stats_interceptions, '${stats.interceptions}'),
                  _StatLine(l10n.stats_cleanSheets, '${stats.cleanSheets}'),
                  _StatLine(l10n.stats_saves, '${stats.saves}'),
                  _StatLine(l10n.stats_shotsFaced, '${stats.shotsFaced}'),
                  _StatLine(l10n.stats_yellowCards, '${stats.yellowCards}'),
                  _StatLine(l10n.stats_redCards, '${stats.redCards}'),
                ]),
              ],
            ),
        ],
      ),
    );
  }

  Widget _statGrid(List<_StatLine> lines) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columnCount = constraints.maxWidth >= 520 ? 3 : 2;
          final width =
              (constraints.maxWidth - (columnCount - 1) * 12) / columnCount;
          return Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              for (final line in lines)
                SizedBox(
                  width: width,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          line.label,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        line.value,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
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

class _StatLine {
  const _StatLine(this.label, this.value);

  final String label;
  final String value;
}
