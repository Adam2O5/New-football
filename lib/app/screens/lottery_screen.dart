import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/widgets/envelope_animation.dart';
import 'package:new_football/app/widgets/lottery_odds_table.dart';
import 'package:new_football/app/widgets/lottery_results_table.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/lottery_models.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/services/lottery_service.dart';

enum LotteryPhase { projected, inProgress, revealing, completed }

class LotteryScreen extends ConsumerStatefulWidget {
  const LotteryScreen({super.key});

  @override
  ConsumerState<LotteryScreen> createState() => _LotteryScreenState();
}

class _LotteryScreenState extends ConsumerState<LotteryScreen> {
  LotteryPhase _phase = LotteryPhase.projected;
  List<LotteryResult> _results = [];
  int _revealedCount = 0;
  bool _animating = false;

  @override
  Widget build(BuildContext context) {
    final league = ref.watch(activeLeagueProvider);

    if (league == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loteria draftowa'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('Brak aktywnej ligi')),
      );
    }

    return PopScope(
      canPop: _phase == LotteryPhase.projected,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showExitDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Loteria draftowa'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_phase == LotteryPhase.projected) {
                context.pop();
              } else {
                _showExitDialog();
              }
            },
          ),
        ),
        body: ScreenBackground(
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildContent(league),
              ),
              // Envelope animation overlay
              if (_phase == LotteryPhase.revealing && _animating)
                _buildAnimationOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(LeagueState league) {
    switch (_phase) {
      case LotteryPhase.projected:
        return _buildProjectedPhase(league);
      case LotteryPhase.inProgress:
      case LotteryPhase.revealing:
        return _buildInProgressPhase(league);
      case LotteryPhase.completed:
        return _buildCompletedPhase(league);
    }
  }

  Widget _buildProjectedPhase(LeagueState league) {
    final lotteryTeams = _getLotteryTeams(league);
    final weights = DraftBalance.lotteryWeights;
    final odds = LotteryService.computeOddsPercentages(weights);

    final teamOdds = lotteryTeams.asMap().entries.map((e) {
      final standing = e.value;
      final teamName =
          league.teamById(standing.teamId)?.name ?? standing.teamId;
      return LotteryTeamOdds(
        rank: e.key + 1,
        teamId: standing.teamId,
        teamName: teamName,
        oddsPercent: odds[e.key],
      );
    }).toList();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: LotteryOddsTable(teams: teamOdds),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () => _startLottery(league),
            icon: const Icon(Icons.casino),
            label: const Text('Rozpocznij losowanie'),
          ),
        ),
      ],
    );
  }

  Widget _buildInProgressPhase(LeagueState league) {
    final teamNames = _buildTeamNamesMap(league);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: LotteryResultsTable(
              results: _results,
              revealedCount: _revealedCount,
              teams: teamNames,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _animating ? null : _revealNextPick,
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('Pokaż kolejny pick'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.85),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _animating ? null : _skipToResults,
                  icon: const Icon(Icons.fast_forward),
                  label: const Text('Przejdź do wyników'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedPhase(LeagueState league) {
    final teamNames = _buildTeamNamesMap(league);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: LotteryResultsTable(
              results: _results,
              revealedCount: 10,
              teams: teamNames,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _finishLottery,
            icon: const Icon(Icons.check),
            label: const Text('Zakończ losowanie'),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimationOverlay() {
    final currentPick = 10 - _revealedCount; // pick being revealed NOW
    final result = _results.firstWhere((r) => r.assignedPick == currentPick);
    final league = ref.read(activeLeagueProvider)!;
    final teamName = league.teamById(result.teamId)?.name ?? result.teamId;

    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: EnvelopeAnimation(
        teamName: teamName,
        onComplete: _onAnimationComplete,
      ),
    );
  }

  // --- Logic methods ---

  List<Standing> _getLotteryTeams(LeagueState league) {
    final all = <Standing>[];
    for (final cs in league.currentSeason.standings) {
      all.addAll(cs.standings);
    }
    all.sort((a, b) {
      final pts = a.points.compareTo(b.points);
      if (pts != 0) return pts;
      return a.goalDifference.compareTo(b.goalDifference);
    });
    return all.take(10).toList();
  }

  Map<String, String> _buildTeamNamesMap(LeagueState league) {
    return {for (final t in league.teams) t.id: t.name};
  }

  void _startLottery(LeagueState league) {
    final lotteryTeams = _getLotteryTeams(league);
    final results = LotteryService.computeResults(lotteryTeams);
    setState(() {
      _results = results;
      _phase = LotteryPhase.inProgress;
      _revealedCount = 0;
    });
  }

  void _revealNextPick() {
    setState(() {
      _phase = LotteryPhase.revealing;
      _animating = true;
    });
  }

  void _onAnimationComplete() {
    setState(() {
      _revealedCount++;
      _animating = false;
      if (_revealedCount >= 10) {
        _phase = LotteryPhase.completed;
        _persistResults();
      } else {
        _phase = LotteryPhase.inProgress;
      }
    });
  }

  void _skipToResults() {
    // Show animation only for pick #1
    setState(() {
      _revealedCount = 9; // After this animation, it will become 10
      _phase = LotteryPhase.revealing;
      _animating = true;
    });
  }

  Future<void> _persistResults() async {
    try {
      final draftService = ref.read(draftServiceProvider);
      await ref.read(gameControllerProvider.notifier).updateLeague((league) {
        // Zapisz wyniki loterii i zbuduj pełną kolejność draftu
        return draftService.buildDraftOrder(league, _results);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd zapisu: $e')),
      );
    }
  }

  /// Kończy losowanie: zapisuje wyniki, przesuwa kalendarz o jeden dzień
  /// i wraca do ekranu głównego.
  Future<void> _finishLottery() async {
    await _persistResults();
    if (!mounted) return;
    // Przesuń kalendarz o jeden dzień (dzień po loterii)
    await ref.read(gameControllerProvider.notifier).advanceOneDay();
    if (!mounted) return;
    context.pop();
  }

  Future<void> _showExitDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Opuść losowanie'),
        content: const Text(
          'Czy na pewno chcesz opuścić losowanie? '
          'Pozostała część zostanie przesymulowana.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Nie'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tak'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _persistResults();
      if (mounted) context.pop();
    }
  }
}
