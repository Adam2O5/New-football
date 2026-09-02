import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/branding/club_asset_registry.dart';
import 'package:new_football/app/branding/club_color_tokens.dart';
import 'package:new_football/app/providers/club_branding_provider.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/app/utils/squad_tile_metrics.dart';
import 'package:new_football/app/widgets/branding/club_logo.dart';
import 'package:new_football/app/widgets/nationality_flag_icon.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/player_attributes.dart';
import 'package:new_football/core/models/team.dart';
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
    Team? playerTeam;
    if (league != null) {
      for (final team in league.teams) {
        for (final candidate in team.roster) {
          if (candidate.id == playerId) {
            player = candidate;
            teamName = team.name;
            playerTeam = team;
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
    final brandingRegistry = ref.watch(clubBrandingProvider);
    final branding = playerTeam == null
        ? null
        : brandingRegistry.resolve(playerTeam.id);
    final colorScheme = Theme.of(context).colorScheme;
    final headerBackground =
        branding?.primaryColor ?? colorScheme.surfaceContainerHighest;
    final headerForeground = branding == null
        ? colorScheme.onSurface
        : foregroundFor(headerBackground);
    final logoAsset =
        branding?.logoAsset ?? ClubAssetRegistry.production.fallbackLogoAsset;
    final fallbackLogoAsset = ClubAssetRegistry.production.fallbackLogoAsset;
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
        backgroundColor: headerBackground,
        foregroundColor: headerForeground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    Text(
                      p.position.code,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(' • ', style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      p.nationality.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 4),
                    NationalityFlagIcon(p.nationality),
                    Text(' • ', style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      '${p.age}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: _labeledMetric(
                      context,
                      l10n.stat_ovr,
                      OvrBadge(
                        ovr: roundedOvrForDisplay(p.overall()),
                        size: 36,
                        l10n: l10n,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _labeledMetric(
                      context,
                      l10n.stat_form,
                      FormIndicator(form: p.state.form, l10n: l10n, width: 40),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _labeledMetric(
                      context,
                      l10n.stat_pot,
                      PotentialStars(
                        playerId: p.id,
                        stars: displayedPotentialStars(p.potentialStars),
                        color: potentialStarColor(p.age),
                        l10n: l10n,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _labeledMetric(
                      context,
                      l10n.stat_pv,
                      _PvIndicator(pv: p.pointValue.toDouble(), l10n: l10n),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _chip(context, l10n.stat_height, '${p.heightCm} cm'),
                Chip(
                  label: Text(
                    l10n.playerDetail_personality(p.personality.name),
                  ),
                ),
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
                    leading: ClubLogo(
                      assetPath: logoAsset,
                      fallbackAssetPath: fallbackLogoAsset,
                      size: 32,
                    ),
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
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  Text(
                    '${l10n.playerDetail_appearances}: ${stats.appearances}',
                  ),
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
                    _StatLine(
                      l10n.stats_shotsOnTarget,
                      '${stats.shotsOnTarget}',
                    ),
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
                    _StatLine(
                      l10n.stats_interceptions,
                      '${stats.interceptions}',
                    ),
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

  /// Stacks a small caption above a squad-style metric widget (badge, bar,
  /// or stars) so it reads consistently with the plain [_chip] entries in
  /// the same [Wrap].
  Widget _labeledMetric(BuildContext context, String label, Widget metric) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        metric,
      ],
    );
  }
}

/// A clamped, horizontal point-value track with a compact visible border.
///
/// Mirrors `FormIndicator`'s structure (`player_list_tile.dart`) but reads
/// the -1000–1000 point-value gradient from `color_interpolation.dart`
/// instead of the 0–10 form gradient. Kept local to this screen since no
/// other screen currently shows a PV metric.
class _PvIndicator extends StatelessWidget {
  const _PvIndicator({required this.pv, required this.l10n});

  final double pv;
  final AppLocalizations l10n;
  static const double _width = 56.0;

  @override
  Widget build(BuildContext context) {
    final clampedPv = clampedPvValue(pv);
    final fill = pvFillForValue(clampedPv);
    final fillColor = pvColorForClampedValue(clampedPv);
    final colors = Theme.of(context).colorScheme;
    final trackColor = colors.surfaceContainerLow;

    return Semantics(
      container: true,
      label: '${l10n.stat_pv} ${clampedPv.round()}',
      child: ExcludeSemantics(
        child: Container(
          key: const ValueKey('player-detail-pv-indicator'),
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

class _StatLine {
  const _StatLine(this.label, this.value);

  final String label;
  final String value;
}
