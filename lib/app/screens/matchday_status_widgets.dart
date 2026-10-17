part of 'matchday_screen.dart';

class _MatchHeader extends StatelessWidget {
  const _MatchHeader({
    required this.live,
    required this.home,
    required this.away,
  });

  final SimulationLiveMatch live;
  final Team home;
  final Team away;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final matchContext = live.state.context;
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    home.name,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Text(
                        '${live.state.homeGoals}:${live.state.awayGoals}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${live.state.minute}'",
                        key: const ValueKey('matchday-clock'),
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    away.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 4,
              children: [
                Text(
                  '${l10n.matchday_weather}: ${_weatherLabel(context, matchContext.weather)}',
                ),
                Text(l10n.matchday_temperature(matchContext.temperatureC)),
                if (matchContext.isDerby)
                  Text(
                    l10n.matchday_derby,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveStatsBar extends StatelessWidget {
  const _LiveStatsBar({required this.live});

  final SimulationLiveMatch live;

  double get _homePossession {
    if (live.minuteTraces.isEmpty) return 50;
    final sum = live.minuteTraces.fold<double>(
      0,
      (total, trace) => total + trace.homePossessionProbability,
    );
    return (sum / live.minuteTraces.length * 100).clamp(0, 100).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final homePossession = _homePossession;
    final awayPossession = 100 - homePossession;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          children: [
            Text(
              l10n.matchday_liveStats,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _LiveMetric(
                    label: l10n.matchday_possession,
                    homeValue: '${homePossession.round()}%',
                    awayValue: '${awayPossession.round()}%',
                  ),
                ),
                Expanded(
                  child: _LiveMetric(
                    label: l10n.matchday_shots,
                    homeValue:
                        '${live.homeShots} (${l10n.matchday_onTarget(live.homeShotsOnTarget)})',
                    awayValue:
                        '${live.awayShots} (${l10n.matchday_onTarget(live.awayShotsOnTarget)})',
                  ),
                ),
                Expanded(
                  child: _LiveMetric(
                    label: l10n.matchday_xg,
                    homeValue: live.homeXg.toStringAsFixed(2),
                    awayValue: live.awayXg.toStringAsFixed(2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveMetric extends StatelessWidget {
  const _LiveMetric({
    required this.label,
    required this.homeValue,
    required this.awayValue,
  });

  final String label;
  final String homeValue;
  final String awayValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(
          '$homeValue  ·  $awayValue',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
}

class _EventFeed extends StatelessWidget {
  const _EventFeed({
    required this.events,
    required this.home,
    required this.away,
  });

  final List<MatchEvent> events;
  final Team home;
  final Team away;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visible = events.reversed.take(35).toList();
    return Card(
      margin: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Text(
              l10n.matchday_eventFeed,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: visible.isEmpty
                ? Center(child: Text(l10n.matchday_noEvents))
                : ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (_, index) {
                      final event = visible[index];
                      final priority = _eventPriority(event.type);
                      final teamName = event.teamId == home.id
                          ? home.name
                          : event.teamId == away.id
                          ? away.name
                          : null;
                      final player = _playerName(event, home, away);
                      final detail = [
                        matchEventLabel(context, event.type),
                        ?player,
                      ].join(' · ');
                      return ListTile(
                        dense: true,
                        visualDensity: const VisualDensity(vertical: -2),
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${event.minute}'"),
                            Icon(
                              _eventIcon(event.type),
                              size: 15,
                              color: _eventColor(context, priority),
                            ),
                          ],
                        ),
                        title: Text(detail),
                        subtitle: teamName == null ? null : Text(teamName),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MatchControlBar extends StatelessWidget {
  const _MatchControlBar({
    required this.paused,
    required this.finishing,
    required this.finished,
    required this.speed,
    required this.onTogglePause,
    required this.onToEnd,
    required this.onSpeedChanged,
    required this.onChanges,
    required this.onTactics,
    required this.onAutoPause,
    required this.l10n,
  });

  final bool paused;
  final bool finishing;
  final bool finished;
  final int speed;
  final VoidCallback onTogglePause;
  final VoidCallback onToEnd;
  final ValueChanged<int> onSpeedChanged;
  final VoidCallback onChanges;
  final VoidCallback onTactics;
  final VoidCallback onAutoPause;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final disabled = finishing || finished;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: disabled ? null : onTogglePause,
              icon: Icon(paused ? Icons.play_arrow : Icons.pause),
              label: Text(paused ? l10n.matchday_resume : l10n.matchday_pause),
            ),
            FilledButton.icon(
              onPressed: disabled ? null : onToEnd,
              icon: const Icon(Icons.fast_forward),
              label: Text(l10n.matchday_toEnd),
            ),
            _SpeedSelector(
              speed: speed,
              enabled: !disabled,
              onChanged: onSpeedChanged,
              l10n: l10n,
            ),
            OutlinedButton.icon(
              onPressed: disabled ? null : onChanges,
              icon: const Icon(Icons.swap_horiz),
              label: Text(l10n.matchday_substitutions),
            ),
            OutlinedButton.icon(
              onPressed: disabled ? null : onTactics,
              icon: const Icon(Icons.tune),
              label: Text(l10n.matchday_tactics),
            ),
            IconButton(
              onPressed: onAutoPause,
              tooltip: l10n.matchday_autoPause,
              icon: const Icon(Icons.notifications_active_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeedSelector extends StatelessWidget {
  const _SpeedSelector({
    required this.speed,
    required this.enabled,
    required this.onChanged,
    required this.l10n,
  });

  final int speed;
  final bool enabled;
  final ValueChanged<int> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final values = <int, String>{
      1: l10n.matchday_speed1,
      2: l10n.matchday_speed2,
      4: l10n.matchday_speed4,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${l10n.matchday_speed}: '),
        for (final entry in values.entries)
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: speed == entry.key,
              onSelected: enabled ? (_) => onChanged(entry.key) : null,
              visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
            ),
          ),
      ],
    );
  }
}
