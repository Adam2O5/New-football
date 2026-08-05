import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/engine/match_engine.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class MatchdayScreen extends ConsumerStatefulWidget {
  const MatchdayScreen({super.key, required this.match});

  final ScheduledMatch match;

  @override
  ConsumerState<MatchdayScreen> createState() => _MatchdayScreenState();
}

class _MatchdayScreenState extends ConsumerState<MatchdayScreen> {
  LiveMatch? _live;
  Team? _home;
  Team? _away;
  bool _paused = true;
  bool _finishing = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    final league = ref.read(activeLeagueProvider);
    if (league == null) return;
    final home = league.teamById(widget.match.homeTeamId);
    final away = league.teamById(widget.match.awayTeamId);
    if (home == null || away == null) return;
    final engine = ref.read(matchEngineProvider);
    setState(() {
      _home = home;
      _away = away;
      _live = engine.start(home: home, away: away);
    });
  }

  void _tick() {
    final live = _live;
    if (live == null || live.isFinished || _finishing) return;
    final engine = ref.read(matchEngineProvider);
    engine.simulateMinute(live);
    setState(() {});
    if (live.isFinished) {
      _timer?.cancel();
      _onFinished();
    }
  }

  void _setPaused(bool paused) {
    setState(() => _paused = paused);
    _timer?.cancel();
    if (!paused) {
      _timer = Timer.periodic(
        const Duration(milliseconds: 350),
        (_) => _tick(),
      );
    }
  }

  Future<void> _toEnd() async {
    final live = _live;
    if (live == null || _finishing) return;
    _timer?.cancel();
    setState(() {
      _paused = true;
      _finishing = true;
    });
    final engine = ref.read(matchEngineProvider);
    while (!live.isFinished) {
      engine.simulateMinute(live);
    }
    setState(() {});
    await _onFinished();
  }

  Future<void> _onFinished() async {
    final live = _live;
    if (live == null) return;
    final result = live.toResult();
    await ref
        .read(gameControllerProvider.notifier)
        .applyPlayerMatch(widget.match, result);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.matchday_finishedSnackbar(result.homeGoals, result.awayGoals),
        ),
      ),
    );
    context.pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final live = _live;
    final home = _home;
    final away = _away;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          live == null
              ? l10n.matchday_defaultTitle
              : '${home?.name ?? '?'} ${live.state.homeGoals}:'
                    '${live.state.awayGoals} ${away?.name ?? '?'}',
        ),
        automaticallyImplyLeading: false,
      ),
      body: ScreenBackground(
        child: live == null || home == null || away == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      "${live.state.minute}'",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _LineupPane(
                            title: home.name,
                            players: live.state.homeLineup
                                .map((p) => '${p.position.code} ${p.name}')
                                .toList(),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: _EventFeed(events: live.events),
                        ),
                        Expanded(
                          flex: 2,
                          child: _LineupPane(
                            title: away.name,
                            players: live.state.awayLineup
                                .map((p) => '${p.position.code} ${p.name}')
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: live.isFinished || _finishing
                                  ? null
                                  : () => _setPaused(!_paused),
                              child: Text(
                                _paused
                                    ? l10n.matchday_resume
                                    : l10n.matchday_pause,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              onPressed: live.isFinished || _finishing
                                  ? null
                                  : _toEnd,
                              child: Text(l10n.matchday_toEnd),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _LineupPane extends StatelessWidget {
  const _LineupPane({required this.title, required this.players});

  final String title;
  final List<String> players;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(players[i], style: const TextStyle(fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventFeed extends StatelessWidget {
  const _EventFeed({required this.events});

  final List<MatchEvent> events;

  @override
  Widget build(BuildContext context) {
    final reversed = events.reversed.toList();
    return Card(
      margin: const EdgeInsets.all(6),
      child: ListView.builder(
        itemCount: reversed.length,
        itemBuilder: (_, i) {
          final e = reversed[i];
          return ListTile(
            dense: true,
            leading: Text("${e.minute}'"),
            title: Text(e.description ?? matchEventLabel(context, e.type)),
          );
        },
      ),
    );
  }
}
