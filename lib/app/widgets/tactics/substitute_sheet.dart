import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/utils/squad_tile_metrics.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/tactics/player_sort.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

Future<void> showSubstituteSheet(
  BuildContext context, {
  required AppLocalizations l10n,
  required Team team,
  required Player outPlayer,
  required List<Player> candidates,
  required int totalCandidateCount,
  required SquadTileMetricMode metricMode,
  required ValueChanged<Player> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: false,
    useSafeArea: true,
    builder: (context) => SubstituteSheet(
      l10n: l10n,
      team: team,
      outPlayer: outPlayer,
      candidates: candidates,
      totalCandidateCount: totalCandidateCount,
      metricMode: metricMode,
      onSelected: onSelected,
    ),
  );
}

RosterZone _rosterZoneOf(Team team, String playerId) {
  if (team.lineupPlayerIds.contains(playerId)) {
    return RosterZone.xi;
  }
  if (team.benchPlayerIds.contains(playerId)) {
    return RosterZone.bench;
  }
  return RosterZone.reserve;
}

class SubstituteSheet extends StatelessWidget {
  const SubstituteSheet({
    super.key,
    required this.l10n,
    required this.team,
    required this.outPlayer,
    required this.candidates,
    required this.totalCandidateCount,
    required this.metricMode,
    required this.onSelected,
  });

  final AppLocalizations l10n;
  final Team team;
  final Player outPlayer;
  final List<Player> candidates;
  final int totalCandidateCount;
  final SquadTileMetricMode metricMode;
  final ValueChanged<Player> onSelected;

  @override
  Widget build(BuildContext context) {
    final hasCandidates = candidates.isNotEmpty;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.56;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SubstituteSheetHeader(
              l10n: l10n,
              outPlayer: outPlayer,
              visibleCandidateCount: candidates.length,
              totalCandidateCount: totalCandidateCount,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: hasCandidates
                  ? ListView.separated(
                      shrinkWrap: true,
                      itemCount: candidates.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 2),
                      itemBuilder: (context, index) {
                        final candidate = candidates[index];
                        return PlayerListTile(
                          l10n: l10n,
                          player: candidate,
                          zone: _rosterZoneOf(team, candidate.id),
                          selected: false,
                          metricMode: metricMode,
                          onInfo: () =>
                              context.push('/game/player/${candidate.id}'),
                          onTap: () {
                            Navigator.of(context).pop();
                            onSelected(candidate);
                          },
                        );
                      },
                    )
                  : _EmptyCandidatesState(l10n: l10n),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubstituteSheetHeader extends StatelessWidget {
  const _SubstituteSheetHeader({
    required this.l10n,
    required this.outPlayer,
    required this.visibleCandidateCount,
    required this.totalCandidateCount,
  });

  final AppLocalizations l10n;
  final Player outPlayer;
  final int visibleCandidateCount;
  final int totalCandidateCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final badgeColor = colors.primaryContainer;
    final showingAll = visibleCandidateCount >= totalCandidateCount;
    final subtitle = totalCandidateCount == 0
        ? l10n.substitute_sheetEmpty
        : showingAll
        ? '${l10n.substitute_sheetSubtitle} · ${outPlayer.position.code}'
        : '${l10n.substitute_sheetSubtitle} · $visibleCandidateCount/$totalCandidateCount';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: badgeColor,
            foregroundColor: foregroundForContrast(badgeColor),
            child: Text(
              outPlayer.position.code,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.substitute_sheetTitle(outPlayer.name),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCandidatesState extends StatelessWidget {
  const _EmptyCandidatesState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 12),
      child: Text(
        l10n.substitute_sheetEmpty,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
