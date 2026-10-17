import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/ai/ai_matchday_models.dart';
import 'package:new_football/core/ai/ai_matchday_service.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/simulation/match_engine.dart';
import 'package:new_football/core/simulation/matchday_runtime.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

part 'matchday_status_widgets.dart';
part 'matchday_lineup_widgets.dart';
part 'matchday_action_sheets.dart';
part 'matchday_auto_pause_sheet.dart';
part 'matchday_summary_dialog.dart';

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
  AiMatchdayRuntime? _homeAiRuntime;
  AiMatchdayRuntime? _awayAiRuntime;
  bool _paused = true;
  bool _finishing = false;
  bool _finalized = false;
  bool _saveFailed = false;
  int _speed = 1;
  Timer? _timer;
  String? _autoPauseNotice;
  int _lastAutoPauseMinute = -1;
  _AutoPauseConfig _autoPause = const _AutoPauseConfig();

  @override
  void initState() {
    super.initState();
    // The interactive match is the one place a crash would cost the player a
    // whole matchday, so the background autosave is forced to disk first.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _prepareMatch();
    });
  }

  Future<void> _prepareMatch({bool retry = false}) async {
    if (!mounted) return;
    setState(() => _saveFailed = false);
    try {
      final controller = ref.read(gameControllerProvider.notifier);
      if (retry) await controller.persist();
      await controller.flushPendingSave();
      _start();
    } catch (_) {
      if (mounted) setState(() => _saveFailed = true);
    }
  }

  void _start() {
    if (!mounted) return;
    final save = ref.read(gameControllerProvider).value;
    if (save == null) return;
    final league = save.leagueState;
    final home = league.teamById(widget.match.homeTeamId);
    final away = league.teamById(widget.match.awayTeamId);
    if (home == null || away == null) return;

    final engine = ref.read(matchEngineProvider);
    final aiMatchday = ref.read(aiMatchdayServiceProvider);
    final isPostseason =
        widget.match.id.startsWith('playIn:') ||
        widget.match.id.startsWith('playoff:');
    final matchContext = isPostseason
        ? ref
              .read(matchContextFactoryProvider)
              .createForPostseason(
                home: home,
                away: away,
                seasonYear: league.currentSeason.year,
                matchId: widget.match.id,
                saveSeed: save.saveSeed,
                stake: ref
                    .read(seasonServiceProvider)
                    .stakeForPendingMatch(league, widget.match.id),
                week: league.currentWeek,
              )
        : ref
              .read(matchContextFactoryProvider)
              .create(
                league: league,
                match: widget.match,
                saveSeed: save.saveSeed,
              );
    final homeHistory = AiMatchdayService.formationHistoryFromSchedule(
      league.currentSeason.schedule,
      home.id,
      away.id,
    );
    final awayHistory = AiMatchdayService.formationHistoryFromSchedule(
      league.currentSeason.schedule,
      away.id,
      home.id,
    );
    final homePlan = home.ai == null
        ? null
        : aiMatchday.planForTeam(
            aiMatchday.contextForTeam(
              team: home,
              opponent: away,
              matchId: widget.match.id,
              matchContext: matchContext,
              saveSeed: save.saveSeed,
              seasonYear: league.currentSeason.year,
              week: league.currentWeek,
              phase: league.currentSeason.phase,
              opponentFormation: away.tactics.formation,
              opponentFormationHistory: homeHistory,
              nextMatchWithinThreeDays: matchContext.homeMatchInWeek >= 2,
            ),
          );
    final plannedHome = homePlan?.applyTo(home) ?? home;
    final awayPlan = away.ai == null
        ? null
        : aiMatchday.planForTeam(
            aiMatchday.contextForTeam(
              team: away,
              opponent: plannedHome,
              matchId: widget.match.id,
              matchContext: matchContext,
              saveSeed: save.saveSeed,
              seasonYear: league.currentSeason.year,
              week: league.currentWeek,
              phase: league.currentSeason.phase,
              opponentFormation: homePlan?.formation ?? home.tactics.formation,
              opponentFormationHistory: awayHistory,
              nextMatchWithinThreeDays: matchContext.awayMatchInWeek >= 2,
            ),
          );
    final plannedAway = awayPlan?.applyTo(away) ?? away;
    final live = engine.start(
      home: plannedHome,
      away: plannedAway,
      context: matchContext,
      rngSeed: matchContext.seed,
      homeAssignedPositions: homePlan?.assignedPositions ?? const {},
      awayAssignedPositions: awayPlan?.assignedPositions ?? const {},
    );

    setState(() {
      _home = plannedHome;
      _away = plannedAway;
      _homeAiRuntime = homePlan == null
          ? null
          : AiMatchdayRuntime(plan: homePlan);
      _awayAiRuntime = awayPlan == null
          ? null
          : AiMatchdayRuntime(plan: awayPlan);
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
    final aiMatchday = ref.read(aiMatchdayServiceProvider);
    final homeRuntime = _homeAiRuntime;
    if (homeRuntime != null) {
      aiMatchday.applyInMatchDecisions(
        live: live,
        runtime: homeRuntime,
        homeSide: true,
      );
    }
    final awayRuntime = _awayAiRuntime;
    if (awayRuntime != null) {
      aiMatchday.applyInMatchDecisions(
        live: live,
        runtime: awayRuntime,
        homeSide: false,
      );
    }
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
      ref.read(gameControllerProvider).value?.leagueState.playerTeamId;

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
    final aiMatchday = ref.read(aiMatchdayServiceProvider);
    while (!live.isFinished) {
      engine.simulateMinute(live);
      final homeRuntime = _homeAiRuntime;
      if (homeRuntime != null) {
        aiMatchday.applyInMatchDecisions(
          live: live,
          runtime: homeRuntime,
          homeSide: true,
        );
      }
      final awayRuntime = _awayAiRuntime;
      if (awayRuntime != null) {
        aiMatchday.applyInMatchDecisions(
          live: live,
          runtime: awayRuntime,
          homeSide: false,
        );
      }
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
        child: _saveFailed
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.loadGame_writeFailed),
                    FilledButton(
                      onPressed: () => _prepareMatch(retry: true),
                      child: Text(l10n.inbox_retry),
                    ),
                    TextButton(
                      onPressed: () => context.go('/game'),
                      child: Text(l10n.common_cancel),
                    ),
                  ],
                ),
              )
            : live == null || home == null || away == null
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
