import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/scouting.dart';

String _fogValue(dynamic rawValue, ScoutingTier? tier, ScoutingTier requiredTier, {bool? additionalFlag}) {
  if (tier == null || tier.index < requiredTier.index) return '—';
  if (additionalFlag != null && additionalFlag == false) return '—';
  return rawValue.toString();
}

String _slotLabel(EstimatedDraftSlot? slot) {
  if (slot == null) return '—';
  return switch (slot) {
    EstimatedDraftSlot.top1 => 'Top 1',
    EstimatedDraftSlot.top3 => 'Top 3',
    EstimatedDraftSlot.top5 => 'Top 5',
    EstimatedDraftSlot.top10 => 'Top 10',
    EstimatedDraftSlot.r1 => 'R1',
    EstimatedDraftSlot.r2 => 'R2',
    EstimatedDraftSlot.r3 => 'R3',
    EstimatedDraftSlot.x => 'UDFA',
  };
}

class ProspectsScreen extends ConsumerWidget {
  const ProspectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final league = ref.watch(activeLeagueProvider);

    if (league == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Prospects'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('No league available')),
      );
    }

    final nextDraftState = league.currentSeason.nextDraftState;
    final scouting = league.playerTeam?.scouting;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prospects'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
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
          child: nextDraftState == null
              ? const Center(
                  child: Text('Brak dostępnej klasy draftowej'),
                )
              : _buildProspectsTable(context, nextDraftState.draftClass.prospects, scouting),
        ),
      ),
    );
  }

  Widget _buildProspectsTable(BuildContext context, List<Prospect> prospects, TeamScouting? scouting) {
    if (prospects.isEmpty) {
      return const Center(child: Text('Brak prospektów'));
    }

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Nat')),
            DataColumn(label: Text('Age')),
            DataColumn(label: Text('Pos')),
            DataColumn(label: Text('Combine')),
            DataColumn(label: Text('Grade')),
            DataColumn(label: Text('Stars')),
            DataColumn(label: Text('Inj')),
            DataColumn(label: Text('Det')),
            DataColumn(label: Text('Slot')),
          ],
          rows: prospects.map((p) {
            final knowledge = scouting?.forProspect(p.id);
            return DataRow(
              onSelectChanged: (_) => _showProspectDetail(context, p, scouting),
              cells: [
                DataCell(Text(p.name)),
                DataCell(Text(p.nationality.code)),
                DataCell(Text('${p.age}')),
                DataCell(Text(p.position.code)),
                DataCell(Text(_fogValue(p.combineScore, knowledge?.tier, ScoutingTier.tier2))),
                DataCell(Text(_fogValue(p.scoutGrade, knowledge?.tier, ScoutingTier.tier3))),
                DataCell(Text(_fogValue(p.potentialStars.toStringAsFixed(1), knowledge?.tier, ScoutingTier.tier4))),
                DataCell(Text(_fogValue(p.injuryProne, knowledge?.tier, ScoutingTier.tier5, additionalFlag: knowledge?.injuryProneKnown))),
                DataCell(Text(_fogValue(p.determination, knowledge?.tier, ScoutingTier.tier5, additionalFlag: knowledge?.determinationKnown))),
                DataCell(Text(_slotLabel(knowledge?.estimatedSlot))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showProspectDetail(BuildContext context, Prospect prospect, TeamScouting? scouting) {
    final knowledge = scouting?.forProspect(prospect.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => _ProspectDetailContent(
          prospect: prospect,
          knowledge: knowledge,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _ProspectDetailContent extends StatelessWidget {
  const _ProspectDetailContent({
    required this.prospect,
    required this.knowledge,
    required this.scrollController,
  });

  final Prospect prospect;
  final ScoutingKnowledge? knowledge;
  final ScrollController scrollController;

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
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            )
          else ...[
            _detailRow('Combine Score', _fogValue(prospect.combineScore, tier, ScoutingTier.tier2)),
            _detailRow('Scout Grade', _fogValue(prospect.scoutGrade, tier, ScoutingTier.tier3)),
            _detailRow('Potencjał', _fogValue(prospect.potentialStars.toStringAsFixed(1), tier, ScoutingTier.tier4)),
            _detailRow('Podatność na kontuzje', _fogValue(prospect.injuryProne, tier, ScoutingTier.tier5, additionalFlag: knowledge?.injuryProneKnown)),
            _detailRow('Determinacja', _fogValue(prospect.determination, tier, ScoutingTier.tier5, additionalFlag: knowledge?.determinationKnown)),
            _detailRow('Estymowany slot', _slotLabel(knowledge?.estimatedSlot)),
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
