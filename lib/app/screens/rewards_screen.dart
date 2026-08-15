import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/season_awards.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    if (league == null) {
      return Scaffold(
        appBar: _appBar(context, l10n),
        body: Center(child: Text(l10n.rewards_noAwards)),
      );
    }
    final awards = league.currentSeason.awards;
    return Scaffold(
      appBar: _appBar(context, l10n),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.draftHistory_season(league.currentSeason.year),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (awards == null)
              Card(child: ListTile(title: Text(l10n.rewards_noAwards)))
            else
              ..._awardCards(context, l10n, league, awards),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      title: Text(l10n.rewards_title),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
    );
  }

  List<Widget> _awardCards(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    SeasonAwards awards,
  ) {
    String playerName(String? id) {
      if (id == null) return l10n.rewards_notAwarded;
      for (final team in league.teams) {
        final matches = team.roster.where((player) => player.id == id);
        if (matches.isNotEmpty) return matches.first.name;
      }
      return id;
    }

    String teamName(String? id) =>
        id == null ? l10n.rewards_notAwarded : league.teamById(id)?.name ?? id;

    final items = <(String, String, String?, bool)>[
      (
        l10n.rewards_mvp,
        playerName(awards.mvpPlayerId),
        awards.mvpPlayerId,
        true,
      ),
      (
        l10n.rewards_roty,
        playerName(awards.rotyPlayerId),
        awards.rotyPlayerId,
        true,
      ),
      (
        l10n.rewards_dpoy,
        playerName(awards.dpoyPlayerId),
        awards.dpoyPlayerId,
        true,
      ),
      (
        l10n.rewards_topScorer,
        playerName(awards.topScorerPlayerId),
        awards.topScorerPlayerId,
        true,
      ),
      (
        l10n.rewards_topAssist,
        playerName(awards.topAssistPlayerId),
        awards.topAssistPlayerId,
        true,
      ),
      (
        l10n.rewards_bestGk,
        playerName(awards.bestGkPlayerId),
        awards.bestGkPlayerId,
        true,
      ),
      (
        l10n.rewards_coachOfYear,
        teamName(awards.coachOfYearTeamId),
        awards.coachOfYearTeamId,
        false,
      ),
      (
        l10n.rewards_champion,
        teamName(awards.championTeamId),
        awards.championTeamId,
        false,
      ),
    ];
    final widgets = <Widget>[
      ...items.map(
        (item) => Card(
          child: ListTile(
            leading: const Icon(Icons.emoji_events_outlined),
            title: Text(item.$1),
            subtitle: Text(item.$2),
            onTap: item.$3 == null || !item.$4
                ? null
                : () => context.push('/game/player/${item.$3}'),
          ),
        ),
      ),
    ];
    if (awards.teamOfSeason.isEmpty) {
      widgets.add(
        Card(
          child: ListTile(
            leading: const Icon(Icons.groups_outlined),
            title: Text(l10n.rewards_teamOfSeason),
            subtitle: Text(l10n.rewards_notAwarded),
          ),
        ),
      );
    } else {
      widgets.add(
        Card(
          child: ExpansionTile(
            title: Text(l10n.rewards_teamOfSeason),
            children: awards.teamOfSeason.entries
                .map(
                  (entry) => ListTile(
                    title: Text(entry.key.name),
                    subtitle: Text(playerName(entry.value)),
                  ),
                )
                .toList(),
          ),
        ),
      );
    }
    return widgets;
  }
}
