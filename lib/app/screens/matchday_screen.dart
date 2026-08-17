import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/simulation/match_engine.dart';
import 'package:new_football/core/simulation/matchday_runtime.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class MatchdayScreen extends ConsumerStatefulWidget {
  const MatchdayScreen({super.key, required this.match});

  final ScheduledMatch match;

  @override
  ConsumerState<MatchdayScreen> createState() => _MatchdayScreenState();
}

class _MatchdayScreenState extends ConsumerState<MatchdayScreen> {
  SimulationLiveMatch? _live;
  Team? _home;
  Team? _away;
  bool _paused = true;
  bool _finishing = false;
  bool _finalized = false;
  int _speed = 1;
  Timer? _timer;
  String? _autoPauseNotice;
  int _lastAutoPauseMinute = -1;
  _AutoPauseConfig _autoPause = const _AutoPauseConfig();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    if (!mounted) return;
    final save = ref.read(gameControllerProvider).valueOrNull;
    if (save == null) return;
    final league = save.leagueState;
    final home = league.teamById(widget.match.homeTeamId);
    final away = league.teamById(widget.match.awayTeamId);
    if (home == null || away == null) return;

    final engine = ref.read(matchEngineProvider);
    final matchContext = ref
        .read(matchContextFactoryProvider)
        .create(league: league, match: widget.match, saveSeed: save.saveSeed);
    final live = engine.start(
      home: home,
      away: away,
      context: matchContext,
      rngSeed: matchContext.seed,
    );

    setState(() {
      _home = home;
      _away = away;
      _live = live;
    });
    if (live.isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_onFinished());
      });
    }
  }

  void _tick() {
    final live = _live;
    if (live == null || live.isFinished || _finishing || _paused) return;

    final previousMinute = live.state.minute;
    final previousEventCount = live.events.length;
    final engine = ref.read(matchEngineProvider);
    engine.simulateMinute(live);
    final newEvents = live.events.skip(previousEventCount).toList();
    final pauseReason = _autoPauseReason(
      live,
      previousMinute: previousMinute,
      newEvents: newEvents,
    );

    if (mounted) {
      setState(() {});
    }
    if (pauseReason != null) {
      _setPaused(true);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() => _autoPauseNotice = pauseReason);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.matchday_autoPaused(pauseReason))),
        );
      }
    }

    if (live.isFinished) {
      _timer?.cancel();
      unawaited(_onFinished());
    }
  }

  String? _autoPauseReason(
    SimulationLiveMatch live, {
    required int previousMinute,
    required List<MatchEvent> newEvents,
  }) {
    final ownTeamId = _playerTeamId;
    if (ownTeamId != null) {
      if (_autoPause.injury &&
          newEvents.any(
            (event) =>
                event.teamId == ownTeamId &&
                (event.type == MatchEventType.minorInjury ||
                    event.type == MatchEventType.majorInjury),
          )) {
        return AppLocalizations.of(context)!.matchday_autoPauseInjury;
      }
      if (_autoPause.redCard &&
          newEvents.any(
            (event) =>
                event.teamId == ownTeamId &&
                event.type == MatchEventType.redCard,
          )) {
        return AppLocalizations.of(context)!.matchday_autoPauseRed;
      }
      // Keep this forward-compatible with a future domain event without
      // treating scored/missed penalties as an awarded penalty.
      if (_autoPause.penaltyForUs &&
          newEvents.any(
            (event) =>
                event.teamId == ownTeamId &&
                event.type.name == 'penaltyAwarded',
          )) {
        return AppLocalizations.of(context)!.matchday_autoPausePenalty;
      }
    }
    if (_autoPause.halfTime &&
        live.isHalfTime &&
        previousMinute < live.state.minute &&
        _lastAutoPauseMinute != live.state.minute) {
      _lastAutoPauseMinute = live.state.minute;
      return AppLocalizations.of(context)!.matchday_autoPauseHalfTime;
    }
    return null;
  }

  String? get _playerTeamId =>
      ref.read(gameControllerProvider).valueOrNull?.leagueState.playerTeamId;

  bool get _homeIsPlayerTeam => _home?.id == _playerTeamId;

  void _setPaused(bool paused) {
    _timer?.cancel();
    if (!mounted) return;
    setState(() => _paused = paused);
    if (!paused && _live != null && !_live!.isFinished && !_finishing) {
      _timer = Timer.periodic(_cadence, (_) => _tick());
    }
  }

  Duration get _cadence => switch (_speed) {
    1 => const Duration(milliseconds: 350),
    2 => const Duration(milliseconds: 175),
    _ => const Duration(milliseconds: 88),
  };

  void _setSpeed(int speed) {
    if (speed == _speed) return;
    setState(() => _speed = speed);
    if (!_paused) {
      _timer?.cancel();
      _timer = Timer.periodic(_cadence, (_) => _tick());
    }
  }

  Future<void> _toEnd() async {
    final live = _live;
    if (live == null || _finishing || _finalized) return;
    _timer?.cancel();
    setState(() {
      _paused = true;
      _finishing = true;
      _autoPauseNotice = null;
    });

    final engine = ref.read(matchEngineProvider);
    while (!live.isFinished) {
      engine.simulateMinute(live);
      if (!mounted) return;
      setState(() {});
      // Yield after each minute so progress and the final state are rendered;
      // the engine call itself remains exactly one minute per iteration.
      await Future<void>.delayed(Duration.zero);
    }
    await _onFinished();
  }

  Future<void> _onFinished() async {
    final live = _live;
    final home = _home;
    final away = _away;
    if (live == null || home == null || away == null || _finalized) return;

    _finalized = true;
    _finishing = true;
    _timer?.cancel();
    final engine = ref.read(matchEngineProvider);
    final result = engine.toMatchResult(live: live, home: home, away: away);
    await ref
        .read(gameControllerProvider.notifier)
        .applyPlayerMatch(widget.match, result);
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _MatchSummaryDialog(
        result: result,
        home: home,
        away: away,
        onClose: () => Navigator.of(dialogContext).pop(),
      ),
    );
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

  Future<void> _showSubstitutionPanel() async {
    final live = _live;
    if (live == null || live.isFinished || _finishing) return;
    _setPaused(true);
    final homeSide = _homeIsPlayerTeam;
    final lineup = homeSide ? live.state.homeLineup : live.state.awayLineup;
    final bench = homeSide ? live.state.homeBench : live.state.awayBench;
    final teamName = homeSide ? _home?.name : _away?.name;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _LiveSubstitutionSheet(
        teamName: teamName ?? '',
        lineup: lineup,
        bench: bench,
        used: homeSide ? live.homeSubsUsed : live.awaySubsUsed,
        hint: AppLocalizations.of(context)!.matchday_changesHint,
        onSubmit: (playerOutId, playerInId) => _submitSubstitution(
          homeSide: homeSide,
          playerOutId: playerOutId,
          playerInId: playerInId,
        ),
      ),
    );
  }

  Future<bool> _submitSubstitution({
    required bool homeSide,
    required String playerOutId,
    required String playerInId,
  }) async {
    final live = _live;
    if (live == null) return false;
    final result = ref
        .read(matchEngineProvider)
        .applySubstitutionResult(
          live: live,
          homeSide: homeSide,
          playerOutId: playerOutId,
          playerInId: playerInId,
        );
    if (mounted) setState(() {});
    if (!result.accepted && mounted) {
      _showActionFailure(result.failure);
    }
    return result.accepted;
  }

  Future<void> _showTacticsPanel() async {
    final live = _live;
    if (live == null || live.isFinished || _finishing) return;
    _setPaused(true);
    final homeSide = _homeIsPlayerTeam;
    final tactics = homeSide ? live.state.homeTactics : live.state.awayTactics;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _LiveTacticsSheet(
        initial: tactics,
        formationEnabled: live.isHalfTime,
        onSubmit: (next) => _submitTactics(homeSide: homeSide, tactics: next),
      ),
    );
  }

  Future<bool> _submitTactics({
    required bool homeSide,
    required TacticsSetup tactics,
  }) async {
    final live = _live;
    if (live == null) return false;
    final result = ref
        .read(matchEngineProvider)
        .updateTacticsResult(live: live, homeSide: homeSide, tactics: tactics);
    if (mounted) setState(() {});
    if (!result.accepted && mounted) {
      _showActionFailure(result.failure);
    }
    return result.accepted;
  }

  void _showActionFailure(SimulationActionFailure? failure) {
    final l10n = AppLocalizations.of(context)!;
    final text = switch (failure) {
      SimulationActionFailure.matchFinished =>
        l10n.matchday_failureMatchFinished,
      SimulationActionFailure.playerNotOnPitch =>
        l10n.matchday_failurePlayerNotOnPitch,
      SimulationActionFailure.playerNotOnBench =>
        l10n.matchday_failurePlayerNotOnBench,
      SimulationActionFailure.playerUnavailable =>
        l10n.matchday_failurePlayerUnavailable,
      SimulationActionFailure.playerCannotReenter =>
        l10n.matchday_failurePlayerCannotReenter,
      SimulationActionFailure.substitutionsLimit =>
        l10n.matchday_failureSubstitutionsLimit,
      SimulationActionFailure.substitutionWindowsLimit =>
        l10n.matchday_failureSubstitutionWindowsLimit,
      SimulationActionFailure.formationChangeOutsideHalfTime =>
        l10n.matchday_failureFormationOutsideHalfTime,
      SimulationActionFailure.invalidHalfTimePhase =>
        l10n.matchday_failureInvalidHalfTime,
      SimulationActionFailure.noAvailableSubstitute =>
        l10n.matchday_failureNoAvailableSubstitute,
      null => l10n.matchday_actionRejected,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _showAutoPauseSettings() async {
    final next = await showModalBottomSheet<_AutoPauseConfig>(
      context: context,
      builder: (_) => _AutoPauseSheet(initial: _autoPause),
    );
    if (next == null || !mounted) return;
    setState(() => _autoPause = next);
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
          live == null ? l10n.matchday_defaultTitle : l10n.matchday_liveStats,
        ),
        automaticallyImplyLeading: false,
      ),
      body: ScreenBackground(
        child: live == null || home == null || away == null
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 760;
                  return Column(
                    children: [
                      _MatchHeader(live: live, home: home, away: away),
                      _LiveStatsBar(live: live),
                      if (_autoPauseNotice != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              l10n.matchday_autoPaused(_autoPauseNotice!),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: narrow
                            ? Column(
                                children: [
                                  Expanded(
                                    child: _EventFeed(
                                      events: live.events,
                                      home: home,
                                      away: away,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 210,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _LineupPane(
                                            team: home,
                                            homeSide: true,
                                            live: live,
                                          ),
                                        ),
                                        Expanded(
                                          child: _LineupPane(
                                            team: away,
                                            homeSide: false,
                                            live: live,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: _LineupPane(
                                      team: home,
                                      homeSide: true,
                                      live: live,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: _EventFeed(
                                      events: live.events,
                                      home: home,
                                      away: away,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: _LineupPane(
                                      team: away,
                                      homeSide: false,
                                      live: live,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      _MatchControlBar(
                        paused: _paused,
                        finishing: _finishing,
                        finished: live.isFinished,
                        speed: _speed,
                        onTogglePause: () => _setPaused(!_paused),
                        onToEnd: _toEnd,
                        onSpeedChanged: _setSpeed,
                        onChanges: _showSubstitutionPanel,
                        onTactics: _showTacticsPanel,
                        onAutoPause: _showAutoPauseSettings,
                        l10n: l10n,
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

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

class _LineupPane extends StatelessWidget {
  const _LineupPane({
    required this.team,
    required this.homeSide,
    required this.live,
  });

  final Team team;
  final bool homeSide;
  final SimulationLiveMatch live;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lineup = homeSide ? live.state.homeLineup : live.state.awayLineup;
    final bench = homeSide ? live.state.homeBench : live.state.awayBench;
    final used = homeSide ? live.homeSubsUsed : live.awaySubsUsed;
    final players = <Widget>[
      _LineupSectionHeader(
        title: l10n.matchday_lineup,
        trailing: l10n.matchday_subsUsed(used),
      ),
      ...lineup.map((player) => _LivePlayerTile(player: player, live: live)),
      const Divider(height: 1),
      _LineupSectionHeader(title: l10n.matchday_bench),
      if (bench.isEmpty)
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(l10n.matchday_noPlayers),
        )
      else
        ...bench.map(
          (player) => _LivePlayerTile(player: player, live: live, bench: true),
        ),
    ];

    return Card(
      margin: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Text(
              team.name,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(padding: EdgeInsets.zero, children: players),
          ),
        ],
      ),
    );
  }
}

class _LineupSectionHeader extends StatelessWidget {
  const _LineupSectionHeader({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.labelMedium),
          ),
          if (trailing != null)
            Text(trailing!, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _LivePlayerTile extends StatelessWidget {
  const _LivePlayerTile({
    required this.player,
    required this.live,
    this.bench = false,
  });

  final Player player;
  final SimulationLiveMatch live;
  final bool bench;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final condition = live.legacyMatch.visibleStamina(player);
    final discipline = live.disciplines.where(
      (item) => item.playerId == player.id,
    );
    final yellow =
        (live.state.yellowCardCounts[player.id] ?? 0) > 0 ||
        discipline.any((item) => item.yellowCardsInMatch > 0);
    final sentOff =
        live.state.sentOffPlayerIds.contains(player.id) ||
        discipline.any((item) => item.redCardKind != RedCardKind.none);
    final injured = player.state.injured;
    final suspended = player.state.suspensionGamesRemaining > 0;
    final attention = condition <= 35 || yellow || sentOff || injured;
    final status = sentOff
        ? l10n.matchday_sentOff
        : injured
        ? l10n.matchday_injured
        : suspended
        ? l10n.matchday_suspended
        : yellow
        ? l10n.matchday_yellowCard
        : attention
        ? l10n.matchday_attention
        : l10n.matchday_available;
    final statusColor = sentOff || injured
        ? Theme.of(context).colorScheme.error
        : yellow || attention
        ? Colors.orange.shade800
        : Theme.of(context).colorScheme.onSurfaceVariant;
    final ovr = player.overall().round();

    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: CircleAvatar(
        radius: 15,
        child: Text(player.position.code, style: const TextStyle(fontSize: 9)),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              player.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: bench ? FontWeight.normal : FontWeight.w600,
              ),
            ),
          ),
          if (attention)
            Tooltip(
              message: l10n.matchday_attention,
              child: Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: statusColor,
              ),
            ),
        ],
      ),
      subtitle: Text(
        l10n.matchday_playerMeta(player.position.code, ovr, condition),
        style: const TextStyle(fontSize: 10),
      ),
      trailing: Text(
        status,
        textAlign: TextAlign.right,
        style: TextStyle(fontSize: 9, color: statusColor),
      ),
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
                        if (player != null) player,
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
                value: _outId,
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
                value: _inId,
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
                        if (accepted && mounted) {
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
                value: _formation,
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
                value: _tempo,
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
                value: _pressing,
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
                value: _defensiveLine,
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
                value: _attackWidth,
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
                        if (accepted && mounted) Navigator.of(context).pop();
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

class _AutoPauseConfig {
  const _AutoPauseConfig({
    this.injury = true,
    this.redCard = true,
    this.halfTime = true,
    this.penaltyForUs = true,
  });

  final bool injury;
  final bool redCard;
  final bool halfTime;
  final bool penaltyForUs;

  _AutoPauseConfig copyWith({
    bool? injury,
    bool? redCard,
    bool? halfTime,
    bool? penaltyForUs,
  }) => _AutoPauseConfig(
    injury: injury ?? this.injury,
    redCard: redCard ?? this.redCard,
    halfTime: halfTime ?? this.halfTime,
    penaltyForUs: penaltyForUs ?? this.penaltyForUs,
  );
}

class _AutoPauseSheet extends StatefulWidget {
  const _AutoPauseSheet({required this.initial});

  final _AutoPauseConfig initial;

  @override
  State<_AutoPauseSheet> createState() => _AutoPauseSheetState();
}

class _AutoPauseSheetState extends State<_AutoPauseSheet> {
  late _AutoPauseConfig _config = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.matchday_autoPauseTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            SwitchListTile(
              title: Text(l10n.matchday_autoPauseInjury),
              value: _config.injury,
              onChanged: (value) =>
                  setState(() => _config = _config.copyWith(injury: value)),
            ),
            SwitchListTile(
              title: Text(l10n.matchday_autoPauseRed),
              value: _config.redCard,
              onChanged: (value) =>
                  setState(() => _config = _config.copyWith(redCard: value)),
            ),
            SwitchListTile(
              title: Text(l10n.matchday_autoPauseHalfTime),
              value: _config.halfTime,
              onChanged: (value) =>
                  setState(() => _config = _config.copyWith(halfTime: value)),
            ),
            SwitchListTile(
              title: Text(l10n.matchday_autoPausePenalty),
              subtitle: Text(l10n.matchday_penaltyPauseUnavailable),
              value: _config.penaltyForUs,
              onChanged: (value) => setState(
                () => _config = _config.copyWith(penaltyForUs: value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_config),
                child: Text(l10n.common_save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchSummaryDialog extends StatelessWidget {
  const _MatchSummaryDialog({
    required this.result,
    required this.home,
    required this.away,
    required this.onClose,
  });

  final MatchResult result;
  final Team home;
  final Team away;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final players = <String, Player>{
      for (final player in [...home.roster, ...away.roster]) player.id: player,
    };
    final playerStats = [...result.playerStats]
      ..sort((a, b) {
        final rating = b.rating.compareTo(a.rating);
        if (rating != 0) return rating;
        return b.minutes.compareTo(a.minutes);
      });
    final motm = result.manOfTheMatchPlayerId == null
        ? null
        : players[result.manOfTheMatchPlayerId!]?.name;
    final inspired = result.inspiredPerformancePlayerId == null
        ? null
        : players[result.inspiredPerformancePlayerId!]?.name;

    return AlertDialog(
      title: Text(l10n.matchday_summaryTitle),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${home.name} ${result.homeGoals}:${result.awayGoals} ${away.name}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.matchday_summaryTeamStats,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            _SummaryTeamStats(home: result.homeStats, away: result.awayStats),
            const SizedBox(height: 16),
            _SummaryHighlight(
              label: l10n.matchday_summaryMOTM,
              value: motm ?? l10n.matchday_summaryNone,
            ),
            _SummaryHighlight(
              label: l10n.matchday_summaryInspired,
              value: inspired ?? l10n.matchday_summaryNone,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.matchday_summaryPlayerStats,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            if (playerStats.isEmpty)
              Text(l10n.matchday_summaryNoPlayerStats)
            else
              for (final stat in playerStats)
                _SummaryPlayerRow(
                  stat: stat,
                  player: players[stat.playerId],
                  l10n: l10n,
                ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: onClose,
          child: Text(l10n.matchday_summaryClose),
        ),
      ],
    );
  }
}

class _SummaryTeamStats extends StatelessWidget {
  const _SummaryTeamStats({required this.home, required this.away});

  final TeamMatchStats home;
  final TeamMatchStats away;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rows = <(String, String, String)>[
      (l10n.stats_possession, '${home.possession}%', '${away.possession}%'),
      (
        l10n.stats_shots,
        '${home.shots} (${home.shotsOnTarget})',
        '${away.shots} (${away.shotsOnTarget})',
      ),
      (l10n.stats_xg, home.xg.toStringAsFixed(2), away.xg.toStringAsFixed(2)),
      (l10n.stats_corners, '${home.corners}', '${away.corners}'),
      (l10n.stats_fouls, '${home.fouls}', '${away.fouls}'),
      (l10n.stats_yellowCards, '${home.yellowCards}', '${away.yellowCards}'),
      (l10n.stats_redCards, '${home.redCards}', '${away.redCards}'),
    ];
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.6),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
      },
      children: [
        for (final row in rows)
          TableRow(
            children: [
              _SummaryCell(row.$1),
              _SummaryCell(row.$2, center: true),
              _SummaryCell(row.$3, center: true),
            ],
          ),
      ],
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell(this.text, {this.center = false});

  final String text;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(text, textAlign: center ? TextAlign.center : TextAlign.left),
    );
  }
}

class _SummaryHighlight extends StatelessWidget {
  const _SummaryHighlight({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _SummaryPlayerRow extends StatelessWidget {
  const _SummaryPlayerRow({
    required this.stat,
    required this.player,
    required this.l10n,
  });

  final PlayerMatchStats stat;
  final Player? player;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final name = player?.name ?? stat.playerId;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Expanded(
            child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Text(
            '${l10n.matchday_summaryRating}: ${stat.rating.toStringAsFixed(1)}',
          ),
        ],
      ),
      subtitle: Text(
        '${stat.minutes}\' · ${l10n.stats_goals}: ${stat.goals} · '
        '${l10n.stats_assists}: ${stat.assists} · ${l10n.stats_shots}: ${stat.shots} · '
        '${l10n.matchday_summaryStamina}: ${stat.staminaAfterMatch < 0 ? l10n.matchday_summaryNone : stat.staminaAfterMatch}',
      ),
    );
  }
}

String _weatherLabel(BuildContext context, Weather weather) {
  final l10n = AppLocalizations.of(context)!;
  return switch (weather) {
    Weather.clear => l10n.matchday_weather_clear,
    Weather.overcast => l10n.matchday_weather_overcast,
    Weather.rain => l10n.matchday_weather_rain,
    Weather.heavyRain => l10n.matchday_weather_heavyRain,
    Weather.wind => l10n.matchday_weather_wind,
    Weather.snow => l10n.matchday_weather_snow,
    Weather.heat => l10n.matchday_weather_heat,
    Weather.cold => l10n.matchday_weather_cold,
  };
}

String? _playerName(MatchEvent event, Team home, Team away) {
  if (event.playerId == null) return null;
  for (final player in [...home.roster, ...away.roster]) {
    if (player.id == event.playerId) return player.name;
  }
  return event.playerId;
}

int _eventPriority(MatchEventType type) => switch (type) {
  MatchEventType.goal => 100,
  MatchEventType.scoredPenalty => 100,
  MatchEventType.redCard => 90,
  MatchEventType.majorInjury => 85,
  MatchEventType.minorInjury => 75,
  MatchEventType.halfTime => 70,
  MatchEventType.fullTime => 70,
  MatchEventType.yellowCard => 60,
  MatchEventType.substitution => 40,
  MatchEventType.foul => 20,
  MatchEventType.missedPenalty => 80,
};

IconData _eventIcon(MatchEventType type) => switch (type) {
  MatchEventType.goal || MatchEventType.scoredPenalty => Icons.sports_soccer,
  MatchEventType.yellowCard => Icons.crop_square,
  MatchEventType.redCard => Icons.square,
  MatchEventType.minorInjury || MatchEventType.majorInjury => Icons.healing,
  MatchEventType.substitution => Icons.swap_horiz,
  MatchEventType.halfTime || MatchEventType.fullTime => Icons.flag,
  MatchEventType.foul => Icons.warning_amber,
  MatchEventType.missedPenalty => Icons.block,
};

Color _eventColor(BuildContext context, int priority) {
  final scheme = Theme.of(context).colorScheme;
  if (priority >= 90) return scheme.error;
  if (priority >= 70) return Colors.orange.shade800;
  if (priority >= 50) return Colors.amber.shade800;
  return scheme.onSurfaceVariant;
}
