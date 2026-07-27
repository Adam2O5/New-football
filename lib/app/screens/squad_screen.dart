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
import 'package:new_football/core/tactics/tactics_setup.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

enum _Zone { xi, bench, reserve }

class SquadScreen extends ConsumerStatefulWidget {
  const SquadScreen({super.key});

  @override
  ConsumerState<SquadScreen> createState() => _SquadScreenState();
}

class _SquadScreenState extends ConsumerState<SquadScreen> {
  String? _selectedId;

  Formation? _formation;
  Tempo? _tempo;
  PressingIntensity? _pressing;
  DefensiveLine? _line;
  AttackWidth? _width;
  bool _tacticsDirty = false;

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
    final xi = team.lineupPlayerIds
        .map((id) => byId[id])
        .whereType<Player>()
        .toList();
    final bench = team.benchPlayerIds
        .map((id) => byId[id])
        .whereType<Player>()
        .toList();
    final used = {...team.lineupPlayerIds, ...team.benchPlayerIds};
    final reserves = team.roster.where((p) => !used.contains(p.id)).toList()
      ..sort((a, b) => b.overall().compareTo(a.overall()));

    _formation ??= team.tactics.formation;
    _tempo ??= team.tactics.tempo;
    _pressing ??= team.tactics.pressing;
    _line ??= team.tactics.defensiveLine;
    _width ??= team.tactics.attackWidth;

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
          height: 420,
          child: Column(
            children: [
              Expanded(
                child: _Pitch(
                  players: xi,
                  selectedId: _selectedId,
                  onTap: (p) => _onTapPlayer(context, ref, l10n, team, p),
                ),
              ),
              SizedBox(
                height: 120,
                child: _BenchStrip(
                  l10n: l10n,
                  players: bench,
                  selectedId: _selectedId,
                  onTap: (p) => _onTapPlayer(context, ref, l10n, team, p),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.squad_reserves,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reserves.length,
          itemBuilder: (context, i) {
            final p = reserves[i];
            return _PlayerTile(
              l10n: l10n,
              player: p,
              selected: _selectedId == p.id,
              onTap: () => _onTapPlayer(context, ref, l10n, team, p),
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
                    value: _formation,
                    decoration: InputDecoration(
                      labelText: l10n.tactics_formation,
                    ),
                    items: Formation.values
                        .map(
                          (f) => DropdownMenuItem(value: f, child: Text(f.label)),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _formation = v;
                        _tacticsDirty = true;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Tempo>(
                    value: _tempo,
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
                        _tempo = v;
                        _tacticsDirty = true;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<PressingIntensity>(
                    value: _pressing,
                    decoration:
                        InputDecoration(labelText: l10n.tactics_pressing),
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
                        _pressing = v;
                        _tacticsDirty = true;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<DefensiveLine>(
                    value: _line,
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
                        _line = v;
                        _tacticsDirty = true;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AttackWidth>(
                    value: _width,
                    decoration:
                        InputDecoration(labelText: l10n.tactics_attackWidth),
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
                        _width = v;
                        _tacticsDirty = true;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: !_tacticsDirty
                        ? null
                        : () async {
                            final newTactics = TacticsSetup(
                              formation: _formation!,
                              tempo: _tempo!,
                              pressing: _pressing!,
                              defensiveLine: _line!,
                              attackWidth: _width!,
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
                              return l.updateTeam(t.copyWith(tactics: newTactics));
                            });
                            if (!context.mounted) return;
                            setState(() => _tacticsDirty = false);
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

  _Zone _zoneOf(Team team, String id) {
    if (team.lineupPlayerIds.contains(id)) return _Zone.xi;
    if (team.benchPlayerIds.contains(id)) return _Zone.bench;
    return _Zone.reserve;
  }

  void _onTapPlayer(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Team team,
    Player player,
  ) {
    final current = _selectedId;
    if (current == null) {
      setState(() => _selectedId = player.id);
      return;
    }
    if (current == player.id) {
      setState(() => _selectedId = null);
      return;
    }
    setState(() => _selectedId = null);
    _trySwap(context, ref, l10n, team, current, player.id);
  }

  void _trySwap(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Team team,
    String idA,
    String idB,
  ) {
    final playerA = team.roster.where((p) => p.id == idA).firstOrNull;
    final playerB = team.roster.where((p) => p.id == idB).firstOrNull;
    if (playerA == null || playerB == null) return;

    final zoneA = _zoneOf(team, idA);
    final zoneB = _zoneOf(team, idB);

    bool entersMatchdaySquad(_Zone zone) =>
        zone == _Zone.xi || zone == _Zone.bench;
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

    void removeFrom(_Zone zone, String id) {
      switch (zone) {
        case _Zone.xi:
          lineup.remove(id);
        case _Zone.bench:
          bench.remove(id);
        case _Zone.reserve:
          break;
      }
    }

    void addTo(_Zone zone, String id) {
      switch (zone) {
        case _Zone.xi:
          lineup.add(id);
        case _Zone.bench:
          bench.add(id);
        case _Zone.reserve:
          break;
      }
    }

    removeFrom(zoneA, idA);
    removeFrom(zoneB, idB);
    addTo(zoneB, idA);
    addTo(zoneA, idB);

    final newTeam = team.copyWith(
      lineupPlayerIds: lineup,
      benchPlayerIds: bench,
    );
    ref
        .read(gameControllerProvider.notifier)
        .updateLeague((l) => l.updateTeam(newTeam));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.squad_swapped)));
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

int _lineIndex(Position position) {
  switch (position) {
    case Position.gk:
      return 0;
    case Position.cb:
    case Position.lb:
    case Position.rb:
    case Position.lwb:
    case Position.rwb:
      return 1;
    case Position.cdm:
    case Position.cm:
    case Position.cam:
      return 2;
    case Position.lw:
    case Position.rw:
    case Position.st:
      return 3;
  }
}

class _Pitch extends StatelessWidget {
  const _Pitch({
    required this.players,
    required this.selectedId,
    required this.onTap,
  });

  final List<Player> players;
  final String? selectedId;
  final void Function(Player) onTap;

  @override
  Widget build(BuildContext context) {
    final lines = List.generate(4, (_) => <Player>[]);
    for (final p in players) {
      lines[_lineIndex(p.position)].add(p);
    }

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: _PitchMarkingsPainter(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _lineRow(context, lines[3]),
                _lineRow(context, lines[2]),
                _lineRow(context, lines[1]),
                _lineRow(context, lines[0]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _chipYOffset(Position position) {
    switch (position) {
      case Position.cam:
        return -7;
      case Position.cdm:
        return 7;
      default:
        return 0;
    }
  }

  Widget _lineRow(BuildContext context, List<Player> line) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final p in line)
            Transform.translate(
              offset: Offset(0, _chipYOffset(p.position)),
              child: _PlayerChip(
                player: p,
                selected: p.id == selectedId,
                onTap: () => onTap(p),
                onLongPress: () => context.push('/game/player/${p.id}'),
              ),
            ),
        ],
      ),
    );
  }
}

class _PitchMarkingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.16,
      paint,
    );
    final boxWidth = size.width * 0.5;
    final boxHeight = size.height * 0.12;
    canvas.drawRect(
      Rect.fromLTWH((size.width - boxWidth) / 2, 0, boxWidth, boxHeight),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - boxWidth) / 2,
        size.height - boxHeight,
        boxWidth,
        boxHeight,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlayerChip extends StatelessWidget {
  const _PlayerChip({
    required this.player,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });

  final Player player;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: selected
                ? Colors.amber
                : (player.state.injured ? Colors.red.shade200 : Colors.white),
            child: Text(
              player.position.code,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: 68,
            child: Text(
              player.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenchStrip extends StatelessWidget {
  const _BenchStrip({
    required this.l10n,
    required this.players,
    required this.selectedId,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final List<Player> players;
  final String? selectedId;
  final void Function(Player) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              l10n.squad_bench,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                for (final p in players)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: _PlayerChip(
                      player: p,
                      selected: p.id == selectedId,
                      onTap: () => onTap(p),
                      onLongPress: () => context.push('/game/player/${p.id}'),
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

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({
    required this.l10n,
    required this.player,
    required this.selected,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final Player player;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: selected
          ? Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.4)
          : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: selected
              ? Theme.of(context).colorScheme.primary
              : null,
          child: Text(
            player.position.code,
            style: const TextStyle(fontSize: 11),
          ),
        ),
        title: Text(player.name),
        subtitle: Text(
          '${l10n.stat_ovr} ${player.overall().round()}'
          ' · ${l10n.stat_form} ${player.state.form}'
          ' · ${l10n.stat_cond} ${player.state.stamina}%'
          '${player.state.injured ? ' · ${l10n.squad_injury}' : ''}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => context.push('/game/player/${player.id}'),
        ),
        onTap: onTap,
      ),
    );
  }
}
