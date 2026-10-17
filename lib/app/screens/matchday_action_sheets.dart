part of 'matchday_screen.dart';

class _LiveSubstitutionSheet extends StatefulWidget {
  const _LiveSubstitutionSheet({
    required this.teamName,
    required this.lineup,
    required this.bench,
    required this.used,
    required this.hint,
    required this.onSubmit,
  });

  final String teamName;
  final List<Player> lineup;
  final List<Player> bench;
  final int used;
  final String hint;
  final Future<bool> Function(String playerOutId, String playerInId) onSubmit;

  @override
  State<_LiveSubstitutionSheet> createState() => _LiveSubstitutionSheetState();
}

class _LiveSubstitutionSheetState extends State<_LiveSubstitutionSheet> {
  String? _outId;
  String? _inId;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${l10n.matchday_substitutions}: ${widget.teamName}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(widget.hint),
              const SizedBox(height: 4),
              Text(l10n.matchday_subsUsed(widget.used)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _outId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.matchday_selectOutgoing,
                ),
                items: [
                  for (final player in widget.lineup)
                    DropdownMenuItem(
                      value: player.id,
                      child: Text('${player.position.code} · ${player.name}'),
                    ),
                ],
                onChanged: widget.lineup.isEmpty || _submitting
                    ? null
                    : (value) => setState(() => _outId = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _inId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.matchday_selectIncoming,
                ),
                items: [
                  for (final player in widget.bench)
                    DropdownMenuItem(
                      value: player.id,
                      child: Text('${player.position.code} · ${player.name}'),
                    ),
                ],
                onChanged: widget.bench.isEmpty || _submitting
                    ? null
                    : (value) => setState(() => _inId = value),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _outId == null || _inId == null || _submitting
                    ? null
                    : () async {
                        setState(() => _submitting = true);
                        final accepted = await widget.onSubmit(_outId!, _inId!);
                        if (mounted && !accepted) {
                          setState(() => _submitting = false);
                        }
                        if (accepted && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                icon: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(l10n.matchday_confirmSubstitution),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveTacticsSheet extends StatefulWidget {
  const _LiveTacticsSheet({
    required this.initial,
    required this.formationEnabled,
    required this.onSubmit,
  });

  final TacticsSetup initial;
  final bool formationEnabled;
  final Future<bool> Function(TacticsSetup tactics) onSubmit;

  @override
  State<_LiveTacticsSheet> createState() => _LiveTacticsSheetState();
}

class _LiveTacticsSheetState extends State<_LiveTacticsSheet> {
  late Formation _formation;
  late Tempo _tempo;
  late PressingIntensity _pressing;
  late DefensiveLine _defensiveLine;
  late AttackWidth _attackWidth;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _formation = widget.initial.formation;
    _tempo = widget.initial.tempo;
    _pressing = widget.initial.pressing;
    _defensiveLine = widget.initial.defensiveLine;
    _attackWidth = widget.initial.attackWidth;
  }

  TacticsSetup get _current => widget.initial.copyWith(
    formation: _formation,
    tempo: _tempo,
    pressing: _pressing,
    defensiveLine: _defensiveLine,
    attackWidth: _attackWidth,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.matchday_tactics,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                widget.formationEnabled
                    ? l10n.matchday_tacticsHint
                    : l10n.matchday_formationLocked,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Formation>(
                initialValue: _formation,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.tactics_formation),
                items: [
                  for (final value in Formation.values)
                    DropdownMenuItem(value: value, child: Text(value.label)),
                ],
                onChanged: !widget.formationEnabled || _submitting
                    ? null
                    : (value) {
                        if (value != null) setState(() => _formation = value);
                      },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<Tempo>(
                initialValue: _tempo,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.tactics_tempo),
                items: [
                  for (final value in Tempo.values)
                    DropdownMenuItem(
                      value: value,
                      child: Text(tempoLabel(context, value)),
                    ),
                ],
                onChanged: _submitting
                    ? null
                    : (value) {
                        if (value != null) setState(() => _tempo = value);
                      },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<PressingIntensity>(
                initialValue: _pressing,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.tactics_pressing),
                items: [
                  for (final value in PressingIntensity.values)
                    DropdownMenuItem(
                      value: value,
                      child: Text(pressingLabel(context, value)),
                    ),
                ],
                onChanged: _submitting
                    ? null
                    : (value) {
                        if (value != null) setState(() => _pressing = value);
                      },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<DefensiveLine>(
                initialValue: _defensiveLine,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.tactics_defensiveLine,
                ),
                items: [
                  for (final value in DefensiveLine.values)
                    DropdownMenuItem(
                      value: value,
                      child: Text(defensiveLineLabel(context, value)),
                    ),
                ],
                onChanged: _submitting
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _defensiveLine = value);
                        }
                      },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<AttackWidth>(
                initialValue: _attackWidth,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.tactics_attackWidth,
                ),
                items: [
                  for (final value in AttackWidth.values)
                    DropdownMenuItem(
                      value: value,
                      child: Text(attackWidthLabel(context, value)),
                    ),
                ],
                onChanged: _submitting
                    ? null
                    : (value) {
                        if (value != null) setState(() => _attackWidth = value);
                      },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _submitting
                    ? null
                    : () async {
                        setState(() => _submitting = true);
                        final accepted = await widget.onSubmit(_current);
                        if (accepted && context.mounted) {
                          Navigator.of(context).pop();
                        }
                        if (!accepted && mounted) {
                          setState(() => _submitting = false);
                        }
                      },
                icon: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(l10n.matchday_tacticsSuccess),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
