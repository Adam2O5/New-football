import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/tactics/pitch_field.dart';
import 'package:new_football/core/tactics/player_list_tile.dart';
import 'package:new_football/core/tactics/player_sort.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class SquadScreen extends ConsumerStatefulWidget {
  const SquadScreen({super.key});

  @override
  ConsumerState<SquadScreen> createState() => _SquadScreenState();
}

class _SquadScreenState extends ConsumerState<SquadScreen> {
  String? selectedId;
  Formation? formation;
  Tempo? tempo;
  PressingIntensity? pressing;
  DefensiveLine? line;
  AttackWidth? width;
  bool tacticsDirty = false;
  PlayerSortMode sortMode = PlayerSortMode.assignedZone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    final team = league?.playerTeam;
    if (team == null) {
      return Center(child: Text(l10n.squad_noTeam));
    }

    final min = BalanceConfig.defaults.roster.minSize;
    final max = BalanceConfig.defaults.roster.maxSize;
    final size = team.roster.length;
    final sizeOk = size >= min && size <= max;

    final byId = {for (final p in team.roster) p.id: p};

    formation ??= team.tactics.formation;
    tempo ??= team.tactics.tempo;
    pressing ??= team.tactics.pressing;
    line ??= team.tactics.defensiveLine;
    width ??= team.tactics.attackWidth;

    final sortedRoster = sortRoster(team, team.roster, sortMode);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Material(
          color: sizeOk
              ? Theme.of(context).colorScheme.surfaceContainerHigh
              : Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(sizeOk ? Icons.check_circle_outline : Icons.warning_amber),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.squad_sizeLabel(size, min, max))),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Text(
            l10n.squad_selectHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        SizedBox(
          height: 340,
          child: PitchField(
            formation: formation!,
            midfieldSlots: team.tactics.midfieldSlots,
            lineupPlayerIds: team.lineupPlayerIds,
            playersById: byId,
            selectedId: selectedId,
            onTap: (p) => _onTapPlayer(context, team, p),
            onLongPress: (p) => context.push('/game/player/${p.id}'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.squad_rosterTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              DropdownButton<PlayerSortMode>(
                value: sortMode,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => sortMode = v);
                },
                items: [
                  DropdownMenuItem(
                    value: PlayerSortMode.overall,
                    child: Text(l10n.squad_sortOverall),
                  ),
                  DropdownMenuItem(
                    value: PlayerSortMode.assignedZone,
                    child: Text(l10n.squad_sortAssignedZone),
                  ),
                  DropdownMenuItem(
                    value: PlayerSortMode.form,
                    child: Text(l10n.squad_sortForm),
                  ),
                  DropdownMenuItem(
                    value: PlayerSortMode.position,
                    child: Text(l10n.squad_sortPosition),
                  ),
                ],
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedRoster.length,
          itemBuilder: (context, i) {
            final p = sortedRoster[i];
            return PlayerListTile(
              l10n: l10n,
              player: p,
              zone: rosterZoneOf(team, p.id),
              selected: selectedId == p.id,
              onTap: () => _onTapPlayer(context, team, p),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.squad_tacticsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<Formation>(
                    value: formation,
                    decoration: InputDecoration(
                      labelText: l10n.tactics_formation,
                    ),
                    items: Formation.values
                        .map(
                          (f) =>
                              DropdownMenuItem(value: f, child: Text(f.label)),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        formation = v;
                        tacticsDirty = true;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Tempo>(
                    value: tempo,
                    decoration: InputDecoration(labelText: l10n.tactics_tempo),
                    items: Tempo.values
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(tempoLabel(context, e)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        tempo = v;
                        tacticsDirty = true;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<PressingIntensity>(
                    value: pressing,
                    decoration: InputDecoration(
                      labelText: l10n.tactics_pressing,
                    ),
                    items: PressingIntensity.values
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(pressingLabel(context, e)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        pressing = v;
                        tacticsDirty = true;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<DefensiveLine>(
                    value: line,
                    decoration: InputDecoration(
                      labelText: l10n.tactics_defensiveLine,
                    ),
                    items: DefensiveLine.values
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(defensiveLineLabel(context, e)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        line = v;
                        tacticsDirty = true;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AttackWidth>(
                    value: width,
                    decoration: InputDecoration(
                      labelText: l10n.tactics_attackWidth,
                    ),
                    items: AttackWidth.values
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(attackWidthLabel(context, e)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        width = v;
                        tacticsDirty = true;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: !tacticsDirty
                        ? null
                        : () async {
                            final newTactics = TacticsSetup(
                              formation: formation!,
                              tempo: tempo!,
                              pressing: pressing!,
                              defensiveLine: line!,
                              attackWidth: width!,
                              midfieldSlots: team.tactics.midfieldSlots,
                              cornersAttack: team.tactics.cornersAttack,
                              cornersDefense: team.tactics.cornersDefense,
                              freeKicks: team.tactics.freeKicks,
                              penalties: team.tactics.penalties,
                            );
                            await ref
                                .read(gameControllerProvider.notifier)
                                .updateLeague((l) {
                                  final t = l.playerTeam!;
                                  return l.updateTeam(
                                    t.copyWith(tactics: newTactics),
                                  );
                                });
                            if (!context.mounted) return;
                            setState(() => tacticsDirty = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.tactics_saved)),
                            );
                          },
                    child: Text(l10n.tactics_save),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onTapPlayer(BuildContext context, Team team, Player player) {
    final current = selectedId;
    if (current == null) {
      setState(() => selectedId = player.id);
      return;
    }
    if (current == player.id) {
      setState(() => selectedId = null);
      return;
    }
    setState(() => selectedId = null);
    _trySwap(context, team, current, player.id);
  }

  void _trySwap(BuildContext context, Team team, String idA, String idB) {
    final l10n = AppLocalizations.of(context)!;
    final playerA = team.roster.where((p) => p.id == idA).firstOrNull;
    final playerB = team.roster.where((p) => p.id == idB).firstOrNull;
    if (playerA == null || playerB == null) return;

    final zoneA = rosterZoneOf(team, idA);
    final zoneB = rosterZoneOf(team, idB);

    bool entersMatchdaySquad(RosterZone zone) =>
        zone == RosterZone.xi || zone == RosterZone.bench;

    if (entersMatchdaySquad(zoneB) && playerA.state.injured) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.squad_cannotFieldInjured)));
      return;
    }
    if (entersMatchdaySquad(zoneA) && playerB.state.injured) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.squad_cannotFieldInjured)));
      return;
    }

    final lineup = [...team.lineupPlayerIds];
    final bench = [...team.benchPlayerIds];

    void removeFromZone(RosterZone zone, String id) {
      switch (zone) {
        case RosterZone.xi:
          lineup.remove(id);
          break;
        case RosterZone.bench:
          bench.remove(id);
          break;
        case RosterZone.reserve:
          break;
      }
    }

    void addToZone(RosterZone zone, String id) {
      switch (zone) {
        case RosterZone.xi:
          lineup.add(id);
          break;
        case RosterZone.bench:
          bench.add(id);
          break;
        case RosterZone.reserve:
          break;
      }
    }

    removeFromZone(zoneA, idA);
    removeFromZone(zoneB, idB);
    addToZone(zoneB, idA);
    addToZone(zoneA, idB);

    final newTeam = team.copyWith(
      lineupPlayerIds: lineup,
      benchPlayerIds: bench,
    );
    ref
        .read(gameControllerProvider.notifier)
        .updateLeague((l) => l.updateTeam(newTeam));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.squad_swappedPlaces)));
  }
}

extension FirstOrNullX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
