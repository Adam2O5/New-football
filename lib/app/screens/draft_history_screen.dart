import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class DraftHistoryScreen extends ConsumerStatefulWidget {
  const DraftHistoryScreen({super.key});

  @override
  ConsumerState<DraftHistoryScreen> createState() => _DraftHistoryScreenState();
}

class _DraftHistoryScreenState extends ConsumerState<DraftHistoryScreen> {
  int? _selectedYear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    if (league == null) {
      return Scaffold(
        appBar: _appBar(context, l10n),
        body: Center(child: Text(l10n.draftHistory_noDraftData)),
      );
    }

    final years = <int>{
      league.currentSeason.year,
      ...league.history.map((history) => history.year),
    }.toList()..sort((a, b) => b.compareTo(a));
    if (years.isEmpty) {
      return Scaffold(
        appBar: _appBar(context, l10n),
        body: Center(child: Text(l10n.draftHistory_noDraftData)),
      );
    }
    final year = years.contains(_selectedYear) ? _selectedYear! : years.first;
    final isCurrent = year == league.currentSeason.year;
    final history = league.history
        .where((item) => item.year == year)
        .firstOrNull;
    final picks = isCurrent
        ? league.currentSeason.draftState?.completedPicks ?? const <DraftPick>[]
        : history?.draftPicks ?? const <DraftPick>[];
    final lottery = isCurrent
        ? league.currentSeason.draftState?.lotteryResults ?? const []
        : const [];

    return Scaffold(
      appBar: _appBar(context, l10n),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<int>(
              initialValue: year,
              decoration: InputDecoration(
                labelText: l10n.draftHistory_season(year),
              ),
              items: years
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text('$value')),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedYear = value),
            ),
            const SizedBox(height: 16),
            if (isCurrent)
              Text(
                l10n.draftHistory_currentDraft,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            if (picks.isEmpty)
              Card(child: ListTile(title: Text(l10n.draftHistory_noPicks)))
            else
              ...picks.map((pick) => _pickCard(context, l10n, league, pick)),
            if (lottery.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n.draftHistory_lottery,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ...lottery.map(
                (result) => ListTile(
                  leading: CircleAvatar(child: Text('${result.assignedPick}')),
                  title: Text(
                    league.teamById(result.teamId)?.name ?? result.teamId,
                  ),
                  subtitle: Text('Original rank: ${result.originalRank}'),
                ),
              ),
            ] else if (isCurrent)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(l10n.draftHistory_noLottery),
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      title: Text(l10n.draftHistory_title),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _pickCard(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    DraftPick pick,
  ) {
    final team = league.teamById(pick.teamId);
    final originalTeam = league.teamById(pick.originalTeamId);
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('${pick.pickNumber ?? '—'}')),
        title: Text(pick.playerName ?? pick.prospectId ?? '—'),
        subtitle: Text(
          '${l10n.draftHistory_round(pick.round)} · '
          '${l10n.draftHistory_team}: ${team?.name ?? pick.teamId}\n'
          '${l10n.draftHistory_originalTeam}: ${originalTeam?.name ?? pick.originalTeamId}',
        ),
        isThreeLine: true,
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
