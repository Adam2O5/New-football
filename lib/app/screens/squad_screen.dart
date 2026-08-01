import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/tactics/pitch_field.dart';
import 'package:new_football/core/tactics/player_list_tile.dart';
import 'package:new_football/core/tactics/player_sort.dart';
import 'package:new_football/core/tactics/role_picker_sheet.dart';
import 'package:new_football/core/tactics/substitute_sheet.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class SquadScreen extends ConsumerStatefulWidget {
  const SquadScreen({super.key});

  @override
  ConsumerState<SquadScreen> createState() => _SquadScreenState();
}

class _SquadScreenState extends ConsumerState<SquadScreen>
    with SingleTickerProviderStateMixin {
  String? selectedId;
  Formation? formation;
  Tempo? tempo;
  PressingIntensity? pressing;
  DefensiveLine? line;
  AttackWidth? width;
  bool tacticsDirty = false;
  PlayerSortMode sortMode = PlayerSortMode.assignedZone;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    final team = league?.playerTeam;
    if (team == null) {
      return Center(child: Text(l10n.squad_noTeam));
    }

    formation ??= team.tactics.formation;
    tempo ??= team.tactics.tempo;
    pressing ??= team.tactics.pressing;
    line ??= team.tactics.defensiveLine;
    width ??= team.tactics.attackWidth;

    return Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: l10n.squad_rosterTitle),
              Tab(text: l10n.squad_tacticsTitle),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSquadTab(context, l10n, team),
              _buildTacticsTab(context, l10n, team),
            ],
          ),
        ),
      ],
    );
  }

  // -- Zakładka "Skład": pitch (tap → SubstituteSheet) + sortowalna lista.
  Widget _buildSquadTab(
    BuildContext context,
    AppLocalizations l10n,
    Team team,
  ) {
    final min = BalanceConfig.defaults.roster.minSize;
    final max = BalanceConfig.defaults.roster.maxSize;
    final size = team.roster.length;
    final sizeOk = size >= min && size <= max;
    final byId = {for (final p in team.roster) p.id: p};
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
            lineupPlayerIds: team.lineupPlayerIds,
            playersById: byId,
            selectedId: selectedId,
            enableDragDrop: true,
            onAcceptDrop: (draggedId, targetId) =>
                _trySwap(context, team, draggedId, targetId),
            onTap: (p) => _openSubstituteSheet(context, l10n, team, p),
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
              enableDragDrop: true,
              onAcceptDrop: (draggedId) =>
                  _trySwap(context, team, draggedId, p.id),
              onTap: () => _onTapPlayer(context, team, p),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // -- Zakładka "Taktyka": pitch (tap → RolePickerSheet) + formularz taktyki.
  Widget _buildTacticsTab(
    BuildContext context,
    AppLocalizations l10n,
    Team team,
  ) {
    final byId = {for (final p in team.roster) p.id: p};

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.squad_tacticsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        SizedBox(
          height: 340,
          child: PitchField(
            formation: formation!,
            lineupPlayerIds: team.lineupPlayerIds,
            playersById: byId,
            selectedId: null,
            onTap: (p) => showRolePickerSheet(
              context,
              player: p,
              onSelected: (role) => _assignRole(context, team, p, role),
            ),
            onLongPress: (p) => context.push('/game/player/${p.id}'),
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

  Future<void> _assignRole(
    BuildContext context,
    Team team,
    Player player,
    AssignedRole role,
  ) async {
    final updatedRoster = team.roster
        .map(
          (p) => p.id == player.id
              ? p.copyWith(state: p.state.copyWith(role: role))
              : p,
        )
        .toList();
    await ref.read(gameControllerProvider.notifier).updateLeague((league) {
      final currentTeam = league.playerTeam!;
      return league.updateTeam(currentTeam.copyWith(roster: updatedRoster));
    });
    if (!context.mounted) return;
    final info = roleDisplayInfo(role);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${player.name}: ${info.label}')));
  }

  Future<void> _openSubstituteSheet(
    BuildContext context,
    AppLocalizations l10n,
    Team team,
    Player outPlayer,
  ) async {
    final xi = team.lineupPlayerIds.toSet();
    final candidates = team.roster.where((p) => !xi.contains(p.id)).toList();
    await showSubstituteSheet(
      context,
      l10n: l10n,
      outPlayer: outPlayer,
      candidates: candidates,
      onSelected: (candidate) =>
          _trySwap(context, team, outPlayer.id, candidate.id),
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
    if (idA == idB) return;
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
        case RosterZone.bench:
          bench.remove(id);
        case RosterZone.reserve:
          break;
      }
    }

    void addToZone(RosterZone zone, String id) {
      switch (zone) {
        case RosterZone.xi:
          lineup.add(id);
        case RosterZone.bench:
          bench.add(id);
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
