import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class TacticsScreen extends ConsumerStatefulWidget {
  const TacticsScreen({super.key});

  @override
  ConsumerState<TacticsScreen> createState() => _TacticsScreenState();
}

class _TacticsScreenState extends ConsumerState<TacticsScreen> {
  Formation? _formation;
  Tempo? _tempo;
  PressingIntensity? _pressing;
  DefensiveLine? _line;
  AttackWidth? _width;
  bool _dirty = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final team = ref.watch(activeLeagueProvider)?.playerTeam;
    if (team == null) {
      return Center(child: Text(l10n.tactics_noTeam));
    }

    _formation ??= team.tactics.formation;
    _tempo ??= team.tactics.tempo;
    _pressing ??= team.tactics.pressing;
    _line ??= team.tactics.defensiveLine;
    _width ??= team.tactics.attackWidth;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<Formation>(
          value: _formation,
          decoration: InputDecoration(labelText: l10n.tactics_formation),
          items: Formation.values
              .map(
                (f) => DropdownMenuItem(value: f, child: Text(f.label)),
              )
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            setState(() {
              _formation = v;
              _dirty = true;
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
              _dirty = true;
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<PressingIntensity>(
          value: _pressing,
          decoration: InputDecoration(labelText: l10n.tactics_pressing),
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
              _dirty = true;
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<DefensiveLine>(
          value: _line,
          decoration: InputDecoration(labelText: l10n.tactics_defensiveLine),
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
              _dirty = true;
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<AttackWidth>(
          value: _width,
          decoration: InputDecoration(labelText: l10n.tactics_attackWidth),
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
              _dirty = true;
            });
          },
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: !_dirty
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
                  await ref.read(gameControllerProvider.notifier).updateLeague(
                    (l) {
                      final t = l.playerTeam!;
                      return l.updateTeam(t.copyWith(tactics: newTactics));
                    },
                  );
                  if (!mounted) return;
                  setState(() => _dirty = false);
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text(l10n.tactics_saved)),
                  );
                },
          child: Text(l10n.tactics_save),
        ),
      ],
    );
  }
}
