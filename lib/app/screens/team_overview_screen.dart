import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/team_management_service.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class TeamOverviewScreen extends ConsumerWidget {
  const TeamOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    if (league == null) {
      return _messageScaffold(
        context,
        l10n.teamOverview_title,
        l10n.teamOverview_noLeague,
      );
    }

    final playerTeamId = league.playerTeamId;
    final team = playerTeamId == null ? null : league.teamById(playerTeamId);
    if (team == null) {
      return _messageScaffold(
        context,
        l10n.teamOverview_title,
        l10n.teamOverview_invalidTeam,
      );
    }

    final standings = _standingsFor(league, team.id);
    final strengthEntry = league.strengthTable?.entryFor(team.id);
    final weeklyHistory = team.weeklyHistory.reversed.take(8).toList();
    final nextAction = ref.watch(nextGameEventProvider);
    final nextMatchOpponent = _nextMatchOpponent(league, team.id);
    final nextActionLabel = nextAction == null
        ? l10n.teamOverview_noNextAction
        : nextAction.kind == CalendarEventKind.match
        ? '${l10n.teamOverview_nextMatch}: ${nextMatchOpponent ?? l10n.teamOverview_nextMatch}'
        : calendarEventLabel(context, nextAction.calendarEventId!) ??
              nextAction.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.teamOverview_title),
        leading: IconButton(
          tooltip: l10n.common_cancel,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _teamHeader(context, l10n, team),
            const SizedBox(height: 12),
            _sectionCard(
              context,
              title: l10n.teamOverview_standings,
              icon: Icons.leaderboard_outlined,
              children: [
                _valueRow(
                  l10n.teamOverview_record,
                  standings.standing == null
                      ? '—'
                      : '${standings.standing!.wins}-${standings.standing!.draws}-${standings.standing!.losses}',
                ),
                _valueRow(
                  l10n.teamOverview_conferenceRank,
                  standings.conferenceRank == null
                      ? '—'
                      : '#${standings.conferenceRank}',
                ),
                _valueRow(
                  l10n.teamOverview_overallRank,
                  standings.overallRank == null
                      ? '—'
                      : '#${standings.overallRank}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _sectionCard(
              context,
              title: l10n.teamOverview_financials,
              icon: Icons.account_balance_wallet_outlined,
              children: [
                _valueRow(
                  l10n.teamOverview_payroll,
                  formatMoney(context, team.finance.totalPayroll),
                ),
                _valueRow(
                  l10n.teamOverview_cap,
                  formatMoney(context, team.finance.salaryCap),
                ),
                _valueRow(
                  l10n.teamOverview_capSpace,
                  formatMoney(context, team.finance.capSpace),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _sectionCard(
              context,
              title: l10n.teamOverview_teamState,
              icon: Icons.groups_outlined,
              children: [
                _valueRow(l10n.teamOverview_atmosphere, '${team.atmosphere}'),
                _valueRow(
                  l10n.teamOverview_chemistry,
                  team.chemistry.toStringAsFixed(1),
                ),
                _valueRow(
                  l10n.teamOverview_atmosphereMult,
                  TeamManagementService.atmosphereMultiplier(
                    team.atmosphere,
                  ).toStringAsFixed(2),
                ),
                _valueRow(
                  l10n.teamOverview_chemistryMult,
                  TeamManagementService.chemistryMultiplier(
                    team.chemistry,
                  ).toStringAsFixed(2),
                ),
                _valueRow(
                  l10n.teamOverview_teamPower,
                  strengthEntry?.teamPower.toStringAsFixed(2) ?? '—',
                ),
                _valueRow(
                  l10n.teamOverview_expectedRank,
                  strengthEntry == null
                      ? '—'
                      : '#${strengthEntry.expectedRank}',
                ),
                _valueRow(
                  l10n.teamOverview_status,
                  strengthEntry?.teamStatus.name ?? '—',
                ),
                _valueRow(l10n.teamOverview_roster, '${team.roster.length}'),
                _valueRow(
                  l10n.teamOverview_staff,
                  '${team.staff.members.length}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            _sectionCard(
              context,
              title: l10n.teamOverview_weeklyHistory,
              icon: Icons.history,
              children: weeklyHistory.isEmpty
                  ? [Text(l10n.teamOverview_noHistory)]
                  : [
                      for (final entry in weeklyHistory)
                        _valueRow(
                          'Tyg. ${entry.week}',
                          'A ${entry.atmosphereDelta >= 0 ? '+' : ''}${entry.atmosphereDelta} · '
                              'C ${entry.chemistryDelta >= 0 ? '+' : ''}${entry.chemistryDelta.toStringAsFixed(1)}',
                        ),
                    ],
            ),
            const SizedBox(height: 12),
            _sectionCard(
              context,
              title: l10n.teamOverview_nextAction,
              icon: Icons.event_available_outlined,
              children: [
                _valueRow(l10n.teamOverview_action, nextActionLabel),
                if (nextAction != null)
                  _valueRow(
                    l10n.teamOverview_calendarPosition,
                    l10n.teamOverview_weekDay(nextAction.day, nextAction.week),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _sectionCard(
              context,
              title: l10n.teamOverview_navigation,
              icon: Icons.open_in_new,
              children: [
                _linkButton(
                  context,
                  l10n.teamOverview_viewSquad,
                  Icons.groups_outlined,
                  () => context.go('/game', extra: 2),
                ),
                _linkButton(
                  context,
                  l10n.teamOverview_viewStats,
                  Icons.bar_chart,
                  () => context.push('/game/stats'),
                ),
                _linkButton(
                  context,
                  l10n.teamOverview_viewStaff,
                  Icons.badge_outlined,
                  () => context.push('/game/staff'),
                ),
                _linkButton(
                  context,
                  l10n.teamOverview_viewFinance,
                  Icons.account_balance_wallet_outlined,
                  () => context.push('/game/finance'),
                ),
                _linkButton(
                  context,
                  l10n.teamOverview_viewSearch,
                  Icons.search,
                  () => context.push('/game/search'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _teamHeader(BuildContext context, AppLocalizations l10n, Team team) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(team.name.substring(0, 1))),
        title: Text(team.name, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text(
          '${team.city} · ${l10n.teamOverview_conference(_conferenceLabel(l10n, team.conference))}',
        ),
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _valueRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _linkButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }

  Scaffold _messageScaffold(
    BuildContext context,
    String title,
    String message,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          tooltip: AppLocalizations.of(context)!.common_cancel,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ScreenBackground(child: Center(child: Text(message))),
    );
  }

  _TeamStandings _standingsFor(LeagueState league, String teamId) {
    Standing? standing;
    int? conferenceRank;
    for (final conference in league.currentSeason.standings) {
      final found = conference.forTeam(teamId);
      if (found == null) continue;
      standing = found;
      final sorted = conference.sorted;
      final index = sorted.indexWhere((entry) => entry.teamId == teamId);
      conferenceRank = index < 0 ? null : index + 1;
    }

    final overall =
        [
          for (final conference in league.currentSeason.standings)
            ...conference.standings,
        ]..sort((a, b) {
          final byPoints = b.points.compareTo(a.points);
          if (byPoints != 0) return byPoints;
          return b.goalDifference.compareTo(a.goalDifference);
        });
    final overallIndex = overall.indexWhere((entry) => entry.teamId == teamId);
    return _TeamStandings(
      standing: standing,
      conferenceRank: conferenceRank,
      overallRank: overallIndex < 0 ? null : overallIndex + 1,
    );
  }

  String? _nextMatchOpponent(LeagueState league, String teamId) {
    final fixtures =
        league.currentSeason.schedule
            .where(
              (match) =>
                  match.result == null &&
                  (match.homeTeamId == teamId || match.awayTeamId == teamId),
            )
            .toList()
          ..sort((a, b) => a.round.compareTo(b.round));
    if (fixtures.isEmpty) return null;
    final fixture = fixtures.first;
    final opponentId = fixture.homeTeamId == teamId
        ? fixture.awayTeamId
        : fixture.homeTeamId;
    return league.teamById(opponentId)?.name ?? opponentId;
  }

  String _conferenceLabel(AppLocalizations l10n, Conference conference) =>
      switch (conference) {
        Conference.europe => l10n.teamOverview_conferenceEurope,
        Conference.restOfTheWorld => l10n.teamOverview_conferenceRestOfWorld,
      };
}

class _TeamStandings {
  const _TeamStandings({
    required this.standing,
    required this.conferenceRank,
    required this.overallRank,
  });

  final Standing? standing;
  final int? conferenceRank;
  final int? overallRank;
}
