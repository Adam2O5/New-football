import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/scouting.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class DraftScreen extends ConsumerWidget {
  const DraftScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    final draft = league?.currentSeason.draftState;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.draft_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (draft != null)
            IconButton(
              tooltip: l10n.scouting_watchlistTitle,
              icon: const Icon(Icons.visibility_outlined),
              onPressed: () => _openWatchlistDialog(context, ref, draft),
            ),
        ],
      ),
      body: draft == null
          ? Center(child: Text(l10n.draft_notActive))
          : ScreenBackground(
              child: _DraftBody(
                draft: draft,
                playerTeamId: league!.playerTeamId,
              ),
            ),
    );
  }

  Future<void> _openWatchlistDialog(
    BuildContext context,
    WidgetRef ref,
    DraftState draft,
  ) async {
    final league = ref.read(activeLeagueProvider)!;
    final team = league.playerTeam;
    if (team == null) return;
    final coverage = team.staff.scout?.attributes.coverage ?? 0.0;
    final limit = BalanceConfig.defaults.staff.maxWatched(coverage);
    var selected = team.scouting.watchlistProspectIds.toSet();
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.scouting_watchlistTitle),
              content: SizedBox(
                width: 400,
                height: 480,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.scouting_watchlistLimit(selected.length, limit)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        children: draft.draftClass.prospects.map((p) {
                          final checked = selected.contains(p.id);
                          return CheckboxListTile(
                            value: checked,
                            title: Text(p.name),
                            subtitle: Text(p.position.code),
                            onChanged: (v) {
                              setState(() {
                                if (v == true) {
                                  if (selected.length < limit) {
                                    selected = {...selected, p.id};
                                  }
                                } else {
                                  selected = {...selected}..remove(p.id);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.scouting_cancel),
                ),
                FilledButton(
                  onPressed: () async {
                    await ref
                        .read(gameControllerProvider.notifier)
                        .setScoutWatchlist(selected.toList());
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: Text(l10n.scouting_save),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

String _prospectFogSubtitle(
  AppLocalizations l10n,
  Prospect p,
  ScoutingKnowledge? knowledge,
) {
  final parts = <String>['${p.position.code} · ${p.age}y'];
  if (knowledge == null) return parts.join(' · ');

  final tierIndex = knowledge.tier.index;
  if (tierIndex >= ScoutingTier.tier2.index) {
    parts.add('Combine ${p.combineScore}');
  }
  if (tierIndex >= ScoutingTier.tier3.index) {
    parts.add(l10n.draft_scoutGradeShort(p.scoutGrade));
  }
  if (tierIndex >= ScoutingTier.tier4.index) {
    parts.add(l10n.draft_potentialShort(p.potentialStars.toStringAsFixed(1)));
  }
  if (tierIndex >= ScoutingTier.tier5.index) {
    if (knowledge.injuryProneKnown) {
      parts.add(l10n.draft_injuryProneShort(p.injuryProne));
    }
    if (knowledge.determinationKnown) {
      parts.add(l10n.draft_determinationShort(p.determination));
    }
  }
  if (knowledge.estimatedSlot != null) {
    parts.add(_slotLabel(l10n, knowledge.estimatedSlot!));
  }
  return parts.join(' · ');
}

String _slotLabel(AppLocalizations l10n, EstimatedDraftSlot slot) =>
    switch (slot) {
      EstimatedDraftSlot.top1 => l10n.scouting_slot_top1,
      EstimatedDraftSlot.top3 => l10n.scouting_slot_top3,
      EstimatedDraftSlot.top5 => l10n.scouting_slot_top5,
      EstimatedDraftSlot.top10 => l10n.scouting_slot_top10,
      EstimatedDraftSlot.r1 => l10n.scouting_slot_r1,
      EstimatedDraftSlot.r2 => l10n.scouting_slot_r2,
      EstimatedDraftSlot.r3 => l10n.scouting_slot_r3,
      EstimatedDraftSlot.x => l10n.scouting_slot_x,
    };

class _DraftBody extends ConsumerWidget {
  const _DraftBody({required this.draft, required this.playerTeamId});

  final DraftState draft;
  final String? playerTeamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider)!;
    final idx = draft.currentPickIndex;
    final current = idx < draft.order.length ? draft.order[idx] : null;
    final pickedIds = draft.completedPicks
        .map((p) => p.prospectId)
        .whereType<String>()
        .toSet();
    final remaining =
        draft.draftClass.prospects
            .where((p) => !pickedIds.contains(p.id))
            .toList()
          ..sort((a, b) => b.scoutGrade.compareTo(a.scoutGrade));

    final isPlayerTurn =
        current != null &&
        playerTeamId != null &&
        current.teamId == playerTeamId;
    final playerScouting = league.playerTeam?.scouting;

    final teamName = current == null
        ? '—'
        : (league.teamById(current.teamId)?.name ?? current.teamId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  current == null
                      ? l10n.draft_finished
                      : l10n.draft_pickLabel(
                          current.pickNumber ?? 0,
                          current.round,
                        ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(l10n.draft_teamLabel(teamName)),
                if (isPlayerTurn)
                  Text(
                    l10n.draft_yourTurn,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.draft_remainingProspects(remaining.length),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: remaining.length,
            itemBuilder: (context, i) {
              final p = remaining[i];
              final knowledge = playerScouting?.forProspect(p.id);
              return ListTile(
                title: Text(p.name),
                subtitle: Text(_prospectFogSubtitle(l10n, p, knowledge)),
                trailing: isPlayerTurn
                    ? FilledButton(
                        onPressed: () async {
                          await ref
                              .read(gameControllerProvider.notifier)
                              .makeDraftPick(p.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.draft_selected(p.name)),
                            ),
                          );
                        },
                        child: Text(l10n.draft_select),
                      )
                    : Text(
                        knowledge != null &&
                                knowledge.tier.index >= ScoutingTier.tier3.index
                            ? '${p.scoutGrade}'
                            : '—',
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}
