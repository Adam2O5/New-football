import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/assigned_role.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/utils/squad_presentation.dart';
import 'package:new_football/app/utils/squad_tile_metrics.dart';
import 'package:new_football/app/widgets/tactics/pitch_field.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/app/widgets/squad/squad_indicators.dart';
import 'package:new_football/core/services/cohesion_service.dart';
import 'package:new_football/core/tactics/formation_layout.dart';
import 'package:new_football/core/tactics/player_sort.dart';
import 'package:new_football/core/tactics/substitute_candidates.dart';
import 'package:new_football/app/widgets/tactics/role_picker_sheet.dart';
import 'package:new_football/app/widgets/tactics/substitute_sheet.dart';
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
  Timer? _tacticsSaveTimer;
  Future<void> _tacticsSaveQueue = Future<void>.value();
  TacticsSetup? _pendingTactics;
  int _tacticsRevision = 0;
  bool _tacticsAutosavePending = false;
  bool _tacticsAutosaveSaved = false;
  GameController? _gameController;
  SquadTileMetricMode metricMode = SquadTileMetricMode.staminaForm;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tacticsSaveTimer?.cancel();
    final pending = _pendingTactics;
    if (pending != null) {
      _enqueueTacticsSave(pending, _tacticsRevision);
    }
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    final team = league?.playerTeam;
    if (team == null) {
      return ScreenBackground(child: Center(child: Text(l10n.squad_noTeam)));
    }
    _gameController ??= ref.read(gameControllerProvider.notifier);

    formation ??= team.tactics.formation;
    tempo ??= team.tactics.tempo;
    pressing ??= team.tactics.pressing;
    line ??= team.tactics.defensiveLine;
    width ??= team.tactics.attackWidth;

    return ScreenBackground(
      child: Column(
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
      ),
    );
  }

  void _onTacticsChanged(Team team, VoidCallback update) {
    setState(() {
      update();
      _tacticsRevision++;
      _tacticsAutosavePending = true;
      _tacticsAutosaveSaved = false;
    });

    final snapshot = TacticsSetup(
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
    _pendingTactics = snapshot;
    _tacticsSaveTimer?.cancel();
    final revision = _tacticsRevision;
    _tacticsSaveTimer = Timer(const Duration(milliseconds: 250), () {
      _pendingTactics = null;
      _enqueueTacticsSave(snapshot, revision);
    });
  }

  void _enqueueTacticsSave(TacticsSetup tactics, int revision) {
    _tacticsSaveQueue = _tacticsSaveQueue.then<void>(
      (_) => _persistTactics(tactics, revision),
    );
  }

  Future<void> _persistTactics(TacticsSetup tactics, int revision) async {
    final controller = _gameController;
    if (controller == null) return;

    try {
      await controller.updateLeague((league) {
        final currentTeam = league.playerTeam;
        if (currentTeam == null) return league;
        return league.updateTeam(currentTeam.copyWith(tactics: tactics));
      }, autosave: true);
      if (!mounted || revision != _tacticsRevision) return;
      setState(() {
        _tacticsAutosavePending = false;
        _tacticsAutosaveSaved = true;
      });
    } catch (_) {
      if (!mounted || revision != _tacticsRevision) return;
      setState(() {
        _tacticsAutosavePending = false;
        _tacticsAutosaveSaved = false;
      });
    }
  }

  // -- Zakładka "Skład": pitch (tap → SubstituteSheet) + sortowalna lista.
  Widget _buildSquadTab(
    BuildContext context,
    AppLocalizations l10n,
    Team team,
  ) {
    final min = BalanceConfig.defaults.roster.minSize;
    final max = BalanceConfig.defaults.roster.maxSize;
    final playersById = <String, Player>{
      for (final player in team.roster) player.id: player,
    };
    final lineupPlayers = team.lineupPlayerIds
        .map((id) => playersById[id])
        .whereType<Player>()
        .toList();
    final lineupCohesion = const CohesionService().computeCohesion(
      lineupPlayers,
    );
    final formationLayout = FormationLayout.of(formation!);
    final placements = placePlayersOnSlots(
      slots: formationLayout.slots,
      lineupPlayerIds: team.lineupPlayerIds,
      playersById: playersById,
    );
    final assignmentIndex = PositionAssignmentIndex.fromPlacements(placements);
    final sortedRoster = sortRoster(
      team,
      team.roster,
      PlayerSortMode.assignedZone,
    );

    return SingleChildScrollView(
      key: const ValueKey('squad-roster-scroll'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RosterSizeIndicator(
                        l10n: l10n,
                        count: team.roster.length,
                        min: min,
                        max: max,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SquadValueBar(
                        label: l10n.squad_lineupCohesionLabel,
                        value: lineupCohesion,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SquadValueBar(
                        label: l10n.squad_chemistryLabel,
                        value: team.chemistry,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SquadValueBar(
                        label: l10n.squad_atmosphereLabel,
                        value: team.atmosphere,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.sizeOf(context).height < 500
                ? (MediaQuery.sizeOf(context).height * 0.45)
                      .clamp(160.0, 220.0)
                      .toDouble()
                : 340,
            child: PitchField(
              key: const ValueKey('squad-pitch-field'),
              formation: formation!,
              lineupPlayerIds: team.lineupPlayerIds,
              playersById: playersById,
              precomputedPlacements: placements,
              selectedId: selectedId,
              enableDragDrop: true,
              onAcceptDrop: (draggedId, targetId) =>
                  _trySwap(context, team, draggedId, targetId),
              onTap: (p) => _openSubstituteSheet(context, l10n, team, p),
              onLongPress: (p) => context.push('/game/player/${p.id}'),
              markerStyleBuilder: (context, placement) {
                final player = placement.player!;
                final status = statusFor(player, placement.slot);
                final statusLabels = <String>[
                  if (status.hasActiveInjury) l10n.squad_statusInjury,
                  if (status.hasActiveSuspension) l10n.squad_statusSuspension,
                  if (status.hasPositionMismatch) l10n.squad_positionMismatch,
                ];
                final statusLabel = statusLabels.join(', ');

                return PitchMarkerStyle(
                  backgroundColor: status.color,
                  foregroundColor: foregroundForContrast(status.color),
                  selectedRingColor: Theme.of(context).colorScheme.primary,
                  selectedRingWidth: 2,
                  semanticLabel: l10n.squad_playerMarkerSemantics(
                    player.name,
                    player.position.code,
                    statusLabel,
                  ),
                  statusLabel: statusLabel.isEmpty ? null : statusLabel,
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final textScale = MediaQuery.textScalerOf(
                        context,
                      ).scale(1);
                      final compact =
                          constraints.maxWidth < 430 || textScale > 1.15;
                      final metricControl = Material(
                        color: Colors.transparent,
                        child: DropdownButton<SquadTileMetricMode>(
                          isExpanded: true,
                          isDense: true,
                          itemHeight: null,
                          value: metricMode,
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => metricMode = v);
                          },
                          items: [
                            DropdownMenuItem(
                              value: SquadTileMetricMode.staminaForm,
                              child: Text(
                                l10n.squad_metricStaminaForm,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: SquadTileMetricMode.potential,
                              child: Text(
                                l10n.squad_metricPotential,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: SquadTileMetricMode.optimalRole,
                              child: Text(
                                l10n.squad_metricOptimalRole,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                      final title = Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.squad_rosterTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      );

                      if (compact) {
                        return Row(
                          children: [
                            Expanded(child: title),
                            const SizedBox(width: 8),
                            Expanded(child: metricControl),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: title),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: constraints.maxWidth.clamp(0.0, 260.0),
                            child: metricControl,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                if (team.roster.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.squad_emptyRoster),
                  )
                else
                  Column(
                    key: const ValueKey('squad-roster-list'),
                    children: [
                      for (final p in sortedRoster)
                        PlayerListTile(
                          l10n: l10n,
                          player: p,
                          zone: rosterZoneOf(team, p.id),
                          positionAssignment: assignmentIndex[p.id],
                          selected: selectedId == p.id,
                          enableDragDrop: true,
                          onAcceptDrop: (draggedId) =>
                              _trySwap(context, team, draggedId, p.id),
                          onInfo: () => context.push('/game/player/${p.id}'),
                          onTap: () => _onTapPlayer(context, team, p),
                          metricMode: metricMode,
                        ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
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
      key: const ValueKey('squad-tactics-scroll'),
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
                      _onTacticsChanged(team, () => formation = v);
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
                      _onTacticsChanged(team, () => tempo = v);
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
                      _onTacticsChanged(team, () => pressing = v);
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
                      _onTacticsChanged(team, () => line = v);
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
                      _onTacticsChanged(team, () => width = v);
                    },
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Icon(
                          _tacticsAutosavePending
                              ? Icons.sync
                              : _tacticsAutosaveSaved
                              ? Icons.check_circle_outline
                              : Icons.cloud_outlined,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _tacticsAutosavePending
                                ? l10n.tactics_autosaving
                                : _tacticsAutosaveSaved
                                ? l10n.tactics_autosaved
                                : l10n.tactics_autosaveHint,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
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
    final allCandidates = allSubstituteCandidatesFor(
      team: team,
      outPlayer: outPlayer,
    );
    final visibleCandidates = substituteCandidatesFor(
      team: team,
      outPlayer: outPlayer,
    );

    await showSubstituteSheet(
      context,
      l10n: l10n,
      team: team,
      outPlayer: outPlayer,
      candidates: visibleCandidates,
      totalCandidateCount: allCandidates.length,
      metricMode: metricMode,
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

    String unavailableMessage(Player player) =>
        (player.state.injury?.daysRemaining ?? 0) > 0
        ? l10n.squad_cannotFieldInjured
        : l10n.matchday_failurePlayerUnavailable;

    if (entersMatchdaySquad(zoneB) && !playerA.isAvailable) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(unavailableMessage(playerA))));
      return;
    }
    if (entersMatchdaySquad(zoneA) && !playerB.isAvailable) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(unavailableMessage(playerB))));
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
