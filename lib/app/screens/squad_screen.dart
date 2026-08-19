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
import 'package:new_football/app/widgets/tactics/pitch_field.dart';
import 'package:new_football/app/widgets/tactics/player_list_tile.dart';
import 'package:new_football/core/tactics/player_sort.dart';
import 'package:new_football/app/widgets/tactics/role_picker_sheet.dart';
import 'package:new_football/app/widgets/tactics/substitute_sheet.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

enum _RosterAvailabilityFilter { all, available, injured }

enum _RosterZoneFilter { all, xi, bench, reserve }

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
  PlayerSortMode sortMode = PlayerSortMode.assignedZone;
  final _rosterSearchController = TextEditingController();
  String _positionFilterCode = '';
  _RosterZoneFilter _zoneFilter = _RosterZoneFilter.all;
  _RosterAvailabilityFilter _availabilityFilter = _RosterAvailabilityFilter.all;
  int _minimumOvr = 0;
  int _minimumForm = 0;

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
    _rosterSearchController.dispose();
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

  List<Player> _filteredRoster(Team team) {
    final query = _rosterSearchController.text.trim().toLowerCase();
    return team.roster.where((player) {
      if (query.isNotEmpty && !player.name.toLowerCase().contains(query)) {
        return false;
      }
      if (_positionFilterCode.isNotEmpty &&
          player.position.code != _positionFilterCode) {
        return false;
      }
      final zone = rosterZoneOf(team, player.id);
      if (_zoneFilter != _RosterZoneFilter.all &&
          ((_zoneFilter == _RosterZoneFilter.xi && zone != RosterZone.xi) ||
              (_zoneFilter == _RosterZoneFilter.bench &&
                  zone != RosterZone.bench) ||
              (_zoneFilter == _RosterZoneFilter.reserve &&
                  zone != RosterZone.reserve))) {
        return false;
      }
      if (_availabilityFilter == _RosterAvailabilityFilter.available &&
          !player.isAvailable) {
        return false;
      }
      if (_availabilityFilter == _RosterAvailabilityFilter.injured &&
          player.isAvailable) {
        return false;
      }
      if (player.overall().round() < _minimumOvr ||
          player.state.form < _minimumForm) {
        return false;
      }
      return true;
    }).toList();
  }

  Widget _buildRosterFilters(BuildContext context, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.squad_filters,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                TextButton(
                  onPressed: () {
                    _rosterSearchController.clear();
                    setState(() {
                      _positionFilterCode = '';
                      _zoneFilter = _RosterZoneFilter.all;
                      _availabilityFilter = _RosterAvailabilityFilter.all;
                      _minimumOvr = 0;
                      _minimumForm = 0;
                    });
                  },
                  child: Text(l10n.squad_clearFilters),
                ),
              ],
            ),
            TextField(
              controller: _rosterSearchController,
              decoration: InputDecoration(
                labelText: l10n.squad_search,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                DropdownButton<String>(
                  value: _positionFilterCode,
                  hint: Text(l10n.squad_position),
                  items: [
                    DropdownMenuItem(
                      value: '',
                      child: Text(l10n.squad_allPositions),
                    ),
                    ...Position.values.map(
                      (position) => DropdownMenuItem(
                        value: position.code,
                        child: Text(position.code),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _positionFilterCode = value);
                    }
                  },
                ),
                DropdownButton<_RosterZoneFilter>(
                  value: _zoneFilter,
                  hint: Text(l10n.squad_zone),
                  items: [
                    DropdownMenuItem(
                      value: _RosterZoneFilter.all,
                      child: Text(l10n.squad_allZones),
                    ),
                    DropdownMenuItem(
                      value: _RosterZoneFilter.xi,
                      child: Text(l10n.squad_zoneXi),
                    ),
                    DropdownMenuItem(
                      value: _RosterZoneFilter.bench,
                      child: Text(l10n.squad_zoneBench),
                    ),
                    DropdownMenuItem(
                      value: _RosterZoneFilter.reserve,
                      child: Text(l10n.squad_zoneReserves),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _zoneFilter = value);
                  },
                ),
                DropdownButton<_RosterAvailabilityFilter>(
                  value: _availabilityFilter,
                  hint: Text(l10n.squad_availability),
                  items: [
                    DropdownMenuItem(
                      value: _RosterAvailabilityFilter.all,
                      child: Text(l10n.squad_allPlayers),
                    ),
                    DropdownMenuItem(
                      value: _RosterAvailabilityFilter.available,
                      child: Text(l10n.squad_available),
                    ),
                    DropdownMenuItem(
                      value: _RosterAvailabilityFilter.injured,
                      child: Text(l10n.squad_injuredOnly),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _availabilityFilter = value);
                    }
                  },
                ),
                DropdownButton<int>(
                  value: _minimumOvr,
                  hint: Text(l10n.squad_minOvr),
                  items: [0, 60, 70, 80, 90]
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(
                            value == 0
                                ? '${l10n.squad_minOvr}: ${l10n.squad_any}'
                                : '${l10n.squad_minOvr}: $value',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _minimumOvr = value);
                  },
                ),
                DropdownButton<int>(
                  value: _minimumForm,
                  hint: Text(l10n.squad_minForm),
                  items: [0, 4, 6, 8, 10]
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(
                            value == 0
                                ? '${l10n.squad_minForm}: ${l10n.squad_any}'
                                : '${l10n.squad_minForm}: $value',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _minimumForm = value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchdaySummary(
    BuildContext context,
    AppLocalizations l10n,
    Team team,
  ) {
    final healthy = team.availablePlayers.length;
    final belowXi = healthy < 11;
    return Card(
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      color: belowXi
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.squad_matchday,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                Text(l10n.squad_xiCount(team.lineupPlayerIds.length)),
                Text(l10n.squad_benchCount(team.benchPlayerIds.length)),
                Text(
                  l10n.squad_reserveCount(
                    team.roster.length -
                        team.lineupPlayerIds.length -
                        team.benchPlayerIds.length,
                  ),
                ),
                Text(l10n.squad_healthy(healthy)),
              ],
            ),
            if (belowXi) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.warning_amber, size: 18),
                  const SizedBox(width: 6),
                  Expanded(child: Text(l10n.squad_belowXi)),
                ],
              ),
            ],
          ],
        ),
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
    final size = team.roster.length;
    final sizeOk = size >= min && size <= max;
    final byId = {for (final p in team.roster) p.id: p};
    final filteredRoster = _filteredRoster(team);
    final sortedRoster = sortRoster(team, filteredRoster, sortMode);

    return ListView(
      key: const ValueKey('squad-roster-scroll'),
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
        _buildMatchdaySummary(context, l10n, team),
        _buildRosterFilters(context, l10n),
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
                    Material(
                      color: Colors.transparent,
                      child: DropdownButton<PlayerSortMode>(
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
                    ),
                  ],
                ),
              ),
              if (sortedRoster.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l10n.squad_noPlayers),
                )
              else
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
            ],
          ),
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
