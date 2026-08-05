import 'package:flutter/material.dart';
import 'package:new_football/core/models/lottery_models.dart';

/// Displays the lottery odds table with team rankings and percentage chances.
class LotteryOddsTable extends StatelessWidget {
  const LotteryOddsTable({super.key, required this.teams});

  final List<LotteryTeamOdds> teams;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('#')),
        DataColumn(label: Text('Drużyna')),
        DataColumn(label: Text('Szanse (%)')),
      ],
      rows: teams
          .map(
            (t) => DataRow(
              cells: [
                DataCell(Text('${t.rank}')),
                DataCell(Text(t.teamName)),
                DataCell(Text('${t.oddsPercent.toStringAsFixed(1)}%')),
              ],
            ),
          )
          .toList(),
    );
  }
}
