import 'package:flutter/material.dart';
import 'package:new_football/core/models/draft_models.dart';

/// Displays lottery results table with progressive reveal.
///
/// Picks are revealed from #10 to #1. A position is visible if:
/// `assignedPick >= (11 - revealedCount)`
class LotteryResultsTable extends StatelessWidget {
  const LotteryResultsTable({
    super.key,
    required this.results,
    required this.revealedCount,
    required this.teams,
  });

  /// All 10 lottery results (precomputed).
  final List<LotteryResult> results;

  /// How many picks have been revealed (0–10).
  final int revealedCount;

  /// Map of teamId → team display name.
  final Map<String, String> teams;

  @override
  Widget build(BuildContext context) {
    // Sort results by assignedPick ascending (1–10) for display order
    final sorted = [...results]
      ..sort((a, b) => a.assignedPick.compareTo(b.assignedPick));

    return DataTable(
      columns: const [
        DataColumn(label: Text('Pick')),
        DataColumn(label: Text('Drużyna')),
      ],
      rows: sorted.map((r) {
        final isRevealed = r.assignedPick >= (11 - revealedCount);
        return DataRow(cells: [
          DataCell(Text('#${r.assignedPick}')),
          DataCell(Text(isRevealed ? (teams[r.teamId] ?? r.teamId) : '?')),
        ]);
      }).toList(),
    );
  }
}
