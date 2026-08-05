import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/scouting.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum DraftPhase { preStart, inProgress, playerTurn, completed }

enum DraftTab { draftOrder, prospects }

// ---------------------------------------------------------------------------
// Fog-of-war helpers (preserved from old implementation)
// ---------------------------------------------------------------------------

String _prospectFogSubtitle(
  AppLocalizations l10n,
  Prospect p,
  ScoutingKnowledge? knowledge,
) {
  final parts = <String>['${p.position.code} · ${p.age}y'];
  if (knowledge == null) return parts.join(' · ');

  final tierIndex = knowledge.tier.index;
  if (tierIndex >= ScoutingTier.tier2.index) {
    parts.add('Combine ${p.combineScore}');
  }
  if (tierIndex >= ScoutingTier.tier3.index) {
    parts.add(l10n.draft_scoutGradeShort(p.scoutGrade));
  }
  if (tierIndex >= ScoutingTier.tier4.index) {
    parts.add(l10n.draft_potentialShort(p.potentialStars.toStringAsFixed(1)));
  }
  if (tierIndex >= ScoutingTier.tier5.index) {
    if (knowledge.injuryProneKnown) {
      parts.add(l10n.draft_injuryProneShort(p.injuryProne));
    }
    if (knowledge.determinationKnown) {
      parts.add(l10n.draft_determinationShort(p.determination));
    }
  }
  if (knowledge.estimatedSlot != null) {
    parts.add(_slotLabel(l10n, knowledge.estimatedSlot!));
  }
  return parts.join(' · ');
}

String _slotLabel(AppLocalizations l10n, EstimatedDraftSlot slot) =>
    switch (slot) {
      EstimatedDraftSlot.top1 => l10n.scouting_slot_top1,
      EstimatedDraftSlot.top3 => l10n.scouting_slot_top3,
      EstimatedDraftSlot.top5 => l10n.scouting_slot_top5,
      EstimatedDraftSlot.top10 => l10n.scouting_slot_top10,
      EstimatedDraftSlot.r1 => l10n.scouting_slot_r1,
      EstimatedDraftSlot.r2 => l10n.scouting_slot_r2,
      EstimatedDraftSlot.r3 => l10n.scouting_slot_r3,
      EstimatedDraftSlot.x => l10n.scouting_slot_x,
    };

String _fogValue(dynamic rawValue, ScoutingTier? tier, ScoutingTier requiredTier, {bool? additionalFlag}) {
  if (tier == null || tier.index < requiredTier.index) return '—';
  if (additionalFlag != null && additionalFlag == false) return '—';
  return rawValue.toString();
}

// ---------------------------------------------------------------------------
// DraftScreen
// ---------------------------------------------------------------------------

class DraftScreen extends ConsumerStatefulWidget {
  const DraftScreen({super.key});

  @override
  ConsumerState<DraftScreen> createState() => _DraftScreenState();
}

class _DraftScreenState extends ConsumerState<DraftScreen> {
  DraftPhase _phase = DraftPhase.preStart;
  DraftTab _activeTab = DraftTab.draftOrder;

  @override
  Widget build(BuildContext context) {
    final league = ref.watch(activeLeagueProvider);

    if (league == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Draft'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('Brak aktywnej ligi')),
      );
    }

    final draft = league.currentSeason.draftState;
    if (draft == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Draft'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('Draft niedostępny')),
      );
    }

    return PopScope(
      canPop: _phase == DraftPhase.preStart,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showExitDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Draft'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_phase == DraftPhase.preStart) {
                context.pop();
              } else {
                _showExitDialog();
              }
            },
          ),
        ),
        body: ScreenBackground(
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surface
                  .withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Player turn banner
                if (_phase == DraftPhase.playerTurn)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Twoja kolej! Wybierz prospekta z zakładki Prospekty.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // Tab switcher
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SegmentedButton<DraftTab>(
                    segments: const [
                      ButtonSegment(
                        value: DraftTab.draftOrder,
                        label: Text('Draft Order'),
                      ),
                      ButtonSegment(
                        value: DraftTab.prospects,
                        label: Text('Prospekty'),
                      ),
                    ],
                    selected: {_activeTab},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _activeTab = selection.first;
                      });
                    },
                  ),
                ),

                // Tab content
                Expanded(
                  child: _activeTab == DraftTab.draftOrder
                      ? _buildDraftOrderTab(league, draft)
                      : _buildProspectsTab(league, draft),
                ),

                // Bottom buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildBottomButtons(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Draft Order Tab
  // -------------------------------------------------------------------------

  Widget _buildDraftOrderTab(LeagueState league, DraftState draft) {
    if (_phase == DraftPhase.completed) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              'Draft zakończony!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: draft.order.length,
      itemBuilder: (context, index) {
        final pick = draft.order[index];
        final teamName = league.teamById(pick.teamId)?.name ?? pick.teamId;
        final isCurrent = index == draft.currentPickIndex &&
            _phase != DraftPhase.preStart;
        final isPlayerTeam = pick.teamId == league.playerTeamId;
        final isCompleted = pick.prospectId != null;

        // Find prospect name if picked
        String? prospectName;
        if (isCompleted) {
          prospectName = pick.playerName ?? pick.prospectId;
        }

        return Container(
          decoration: BoxDecoration(
            color: isCurrent
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            border: isCurrent
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: isPlayerTeam
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Text(
                '${pick.pickNumber ?? (index + 1)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isPlayerTeam
                      ? Theme.of(context).colorScheme.onPrimary
                      : null,
                ),
              ),
            ),
            title: Text(
              teamName,
              style: TextStyle(
                fontWeight: isPlayerTeam ? FontWeight.bold : FontWeight.normal,
                color: isCompleted && !isPlayerTeam
                    ? Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6)
                    : null,
              ),
            ),
            subtitle: Text('Runda ${pick.round}'),
            trailing: prospectName != null
                ? Text(
                    prospectName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Prospects Tab
  // -------------------------------------------------------------------------

  Widget _buildProspectsTab(LeagueState league, DraftState draft) {
    final l10n = AppLocalizations.of(context)!;
    final scouting = league.playerTeam?.scouting;

    // Filter out already-picked prospects
    final pickedIds = draft.completedPicks
        .map((p) => p.prospectId)
        .whereType<String>()
        .toSet();
    final remaining = draft.draftClass.prospects
        .where((p) => !pickedIds.contains(p.id))
        .toList()
      ..sort((a, b) => b.scoutGrade.compareTo(a.scoutGrade));

    if (remaining.isEmpty) {
      return const Center(child: Text('Brak dostępnych prospektów'));
    }

    return ListView.builder(
      itemCount: remaining.length,
      itemBuilder: (context, index) {
        final p = remaining[index];
        final knowledge = scouting?.forProspect(p.id);

        return ListTile(
          title: Text(p.name),
          subtitle: Text(_prospectFogSubtitle(l10n, p, knowledge)),
          onTap: () => _showProspectDetail(p, scouting),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Bottom Buttons
  // -------------------------------------------------------------------------

  Widget _buildBottomButtons(BuildContext context) {
    switch (_phase) {
      case DraftPhase.preStart:
        return SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _startDraft,
            child: const Text('Rozpocznij draft'),
          ),
        );

      case DraftPhase.inProgress:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _simulateOnePick,
                child: const Text('Symuluj wybór'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _simulateToMyPick,
                child: const Text('Symuluj do mojego wyboru'),
              ),
            ),
          ],
        );

      case DraftPhase.playerTurn:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: null, // disabled
                child: const Text('Symuluj wybór'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: null, // disabled
                child: const Text('Symuluj do mojego wyboru'),
              ),
            ),
          ],
        );

      case DraftPhase.completed:
        return SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => context.pop(),
            child: const Text('Zakończ'),
          ),
        );
    }
  }

  // -------------------------------------------------------------------------
  // Logic Methods
  // -------------------------------------------------------------------------

  void _startDraft() {
    setState(() {
      _phase = DraftPhase.inProgress;
    });
  }

  Future<void> _simulateOnePick() async {
    await ref.read(gameControllerProvider.notifier).simulateOneDraftPick();
    _updatePhase();
  }

  Future<void> _simulateToMyPick() async {
    await ref.read(gameControllerProvider.notifier).simulateDraftToPlayerTurn();
    _updatePhase();
  }

  Future<void> _makePlayerPick(String prospectId) async {
    await ref.read(gameControllerProvider.notifier).makeDraftPick(prospectId);
    _updatePhase();
    if (!mounted) return;
    final prospect = ref
        .read(activeLeagueProvider)
        ?.currentSeason
        .draftState
        ?.draftClass
        .prospects
        .where((p) => p.id == prospectId)
        .firstOrNull;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Wybrano: ${prospect?.name ?? prospectId}'),
      ),
    );
  }

  void _updatePhase() {
    final league = ref.read(activeLeagueProvider);
    final draft = league?.currentSeason.draftState;
    if (draft == null) return;

    setState(() {
      if (draft.currentPickIndex >= draft.order.length) {
        _phase = DraftPhase.completed;
      } else if (draft.order[draft.currentPickIndex].teamId ==
          league?.playerTeamId) {
        _phase = DraftPhase.playerTurn;
      } else {
        _phase = DraftPhase.inProgress;
      }
    });
  }

  // -------------------------------------------------------------------------
  // Exit Dialog (LotteryScreen pattern)
  // -------------------------------------------------------------------------

  Future<void> _showExitDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Opuść draft'),
        content: const Text(
          'Czy na pewno chcesz opuścić draft? '
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
      // Simulate all remaining picks
      await ref
          .read(gameControllerProvider.notifier)
          .simulateDraftToPlayerTurn();
      // If there are still picks remaining (player turn hit), keep simulating
      var league = ref.read(activeLeagueProvider);
      var draft = league?.currentSeason.draftState;
      while (draft != null && draft.currentPickIndex < draft.order.length) {
        // Make auto-pick for player's turn then continue
        final currentPick = draft.order[draft.currentPickIndex];
        if (currentPick.teamId == league?.playerTeamId) {
          // Auto-pick best available for player
          final pickedIds = draft.completedPicks
              .map((p) => p.prospectId)
              .whereType<String>()
              .toSet();
          final remaining = draft.draftClass.prospects
              .where((p) => !pickedIds.contains(p.id))
              .toList()
            ..sort((a, b) => b.scoutGrade.compareTo(a.scoutGrade));
          if (remaining.isNotEmpty) {
            await ref
                .read(gameControllerProvider.notifier)
                .makeDraftPick(remaining.first.id);
          } else {
            break;
          }
        }
        await ref
            .read(gameControllerProvider.notifier)
            .simulateDraftToPlayerTurn();
        league = ref.read(activeLeagueProvider);
        draft = league?.currentSeason.draftState;
      }
      if (mounted) context.pop();
    }
  }

  // -------------------------------------------------------------------------
  // Prospect Detail Bottom Sheet
  // -------------------------------------------------------------------------

  void _showProspectDetail(Prospect prospect, TeamScouting? scouting) {
    final knowledge = scouting?.forProspect(prospect.id);
    final showPickButton = _phase == DraftPhase.playerTurn;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (sheetContext, scrollController) => _ProspectDetailSheet(
          prospect: prospect,
          knowledge: knowledge,
          scrollController: scrollController,
          showPickButton: showPickButton,
          onPick: () {
            Navigator.pop(sheetContext);
            _makePlayerPick(prospect.id);
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Prospect Detail Sheet (reuses pattern from ProspectsScreen)
// ---------------------------------------------------------------------------

class _ProspectDetailSheet extends StatelessWidget {
  const _ProspectDetailSheet({
    required this.prospect,
    required this.knowledge,
    required this.scrollController,
    required this.showPickButton,
    required this.onPick,
  });

  final Prospect prospect;
  final ScoutingKnowledge? knowledge;
  final ScrollController scrollController;
  final bool showPickButton;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tier = knowledge?.tier;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Name & basic info header
          Text(prospect.name, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            '${prospect.position.code} · ${prospect.nationality.code} · ${prospect.age} lat · ${prospect.heightCm} cm',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Scouting data section
          Text('Dane skautingowe', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          if (knowledge == null)
            Text(
              'Brak danych skautingowych. Dodaj prospekta do listy obserwowanych.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else ...[
            _detailRow('Combine Score',
                _fogValue(prospect.combineScore, tier, ScoutingTier.tier2)),
            _detailRow('Scout Grade',
                _fogValue(prospect.scoutGrade, tier, ScoutingTier.tier3)),
            _detailRow('Potencjał',
                _fogValue(prospect.potentialStars.toStringAsFixed(1), tier, ScoutingTier.tier4)),
            _detailRow(
                'Podatność na kontuzje',
                _fogValue(prospect.injuryProne, tier, ScoutingTier.tier5,
                    additionalFlag: knowledge?.injuryProneKnown)),
            _detailRow(
                'Determinacja',
                _fogValue(prospect.determination, tier, ScoutingTier.tier5,
                    additionalFlag: knowledge?.determinationKnown)),
            _detailRow('Estymowany slot',
                knowledge!.estimatedSlot != null
                    ? _slotLabel(AppLocalizations.of(context)!, knowledge!.estimatedSlot!)
                    : '—'),
          ],

          // Pick button
          if (showPickButton) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onPick,
                child: const Text('Wybierz gracza'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
