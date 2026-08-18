import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/staff_service.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen> {
  final _staffService = StaffService();
  String? _status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    final team = league?.playerTeam;
    if (league == null || team == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.staff_title)),
        body: ScreenBackground(child: Center(child: Text(l10n.staff_noTeam))),
      );
    }

    const balance = BalanceConfig.defaults;
    final cap = balance.staff.salaryCap;
    final used = team.staff.totalSalary;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.staff_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                title: Text(l10n.staff_capLabel),
                trailing: Text(
                  l10n.staff_capUsage(
                    formatMoney(context, used),
                    formatMoney(context, cap),
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: used > cap
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _marketStatusCard(context, l10n, league),
            const SizedBox(height: 12),
            for (final role in StaffRole.values)
              _roleSection(context, l10n, league, team, role),
            if (_status != null) ...[
              const SizedBox(height: 12),
              Text(_status!, textAlign: TextAlign.center),
            ],
            if (league.negotiations.any(
              (item) =>
                  item.teamId == team.id &&
                  item.subjectKind.name == 'staff' &&
                  item.status.name == 'pendingFinalization',
            )) ...[
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.pending_actions),
                      title: Text(l10n.contract_pendingFinalization),
                    ),
                    ...league.negotiations
                        .where(
                          (item) =>
                              item.teamId == team.id &&
                              item.subjectKind.name == 'staff' &&
                              item.status.name == 'pendingFinalization',
                        )
                        .map(
                          (negotiation) => ListTile(
                            title: Text(negotiation.subjectId),
                            subtitle: Text(
                              '${formatMoney(context, negotiation.lastOffer.salary)} × ${negotiation.lastOffer.years} · '
                              '${l10n.market_round(negotiation.round)} · '
                              '${l10n.market_score(negotiation.offerScore.toStringAsFixed(1))} · '
                              '${l10n.market_deadline(negotiation.expiryWeek, negotiation.expiryDay, negotiation.expiryHour)}',
                            ),
                            trailing: FilledButton.tonal(
                              onPressed: () async {
                                final ok = await ref
                                    .read(gameControllerProvider.notifier)
                                    .finalizeContractNegotiation(
                                      negotiation.id,
                                    );
                                if (!mounted) return;
                                setState(
                                  () => _status = ok
                                      ? l10n.contract_accepted
                                      : l10n.contract_finalizationFailed,
                                );
                              },
                              child: Text(l10n.contract_finalize),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _marketStatusCard(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
  ) {
    final window = ContractMarketService().windowAt(league);
    final label = switch (window) {
      ContractMarketWindow.closed => l10n.market_closed,
      ContractMarketWindow.extensions => l10n.market_extensions,
      ContractMarketWindow.freeAgencyPhaseI => l10n.market_phaseI,
      ContractMarketWindow.freeAgencyPhaseII => l10n.market_phaseII,
    };
    final hourly =
        window == ContractMarketWindow.extensions ||
        window == ContractMarketWindow.freeAgencyPhaseI;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.schedule),
        title: Text(l10n.market_status),
        subtitle: Text(
          '${l10n.market_date(league.currentWeek, league.currentDay)} · $label'
          '${hourly ? '\\n${l10n.market_hour(league.currentHour ?? 1, 10)}' : ''}',
        ),
      ),
    );
  }

  Widget _roleSection(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    Team team,
    StaffRole role,
  ) {
    final member = team.staff.member(role);
    final candidates =
        league.staffFreeAgents.where((m) => m.role == role).toList()
          ..sort((a, b) => b.overall.compareTo(a.overall));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              staffRoleLabel(context, role),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            if (member == null)
              Text(l10n.staff_emptySlot)
            else
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(member.name),
                subtitle: Text(
                  l10n.staff_memberSubtitle(
                    member.age,
                    member.overall.toStringAsFixed(1),
                    formatMoney(context, member.contract?.salary ?? 0),
                  ),
                ),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    if ((member.contract?.yearsRemaining ?? 99) <= 1)
                      TextButton(
                        onPressed: () => _extend(l10n, member),
                        child: Text(l10n.contract_submitOffer),
                      ),
                    TextButton(
                      onPressed: () async {
                        await ref
                            .read(gameControllerProvider.notifier)
                            .fireStaff(role);
                      },
                      child: Text(l10n.staff_fire),
                    ),
                  ],
                ),
              ),
            if (member == null) ...[
              const SizedBox(height: 6),
              Text(
                l10n.staff_candidatesHeader,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              if (candidates.isEmpty)
                Text(l10n.staff_noCandidates)
              else
                ...candidates.take(5).map((c) {
                  final offer = StaffOffer(
                    salary: _staffService.marketSalary(c).round(),
                    years: 3,
                  );
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(c.name),
                    subtitle: Text(
                      l10n.staff_memberSubtitle(
                        c.age,
                        c.overall.toStringAsFixed(1),
                        formatMoney(context, offer.salary),
                      ),
                    ),
                    trailing: FilledButton.tonal(
                      onPressed: () => _hire(l10n, c, offer),
                      child: Text(l10n.staff_hire),
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _extend(AppLocalizations l10n, StaffMember member) async {
    final reaction = await ref
        .read(gameControllerProvider.notifier)
        .offerStaff(
          member,
          StaffOffer(
            salary: _staffService.expectedSalary(member),
            years: _staffService.expectedLength(member),
          ),
        );
    if (!mounted) return;
    setState(() {
      _status = switch (reaction) {
        StaffReaction.accept => l10n.staff_hireAccepted(member.name),
        StaffReaction.hardReject ||
        StaffReaction.reject => l10n.staff_hireRejected,
        StaffReaction.waiting => l10n.contract_waiting,
        StaffReaction.counter => l10n.contract_faCounter,
      };
    });
  }

  Future<void> _hire(
    AppLocalizations l10n,
    StaffMember candidate,
    StaffOffer offer,
  ) async {
    final reaction = await ref
        .read(gameControllerProvider.notifier)
        .offerStaff(candidate, offer);
    setState(() {
      _status = switch (reaction) {
        StaffReaction.accept => l10n.staff_hireAccepted(candidate.name),
        StaffReaction.hardReject ||
        StaffReaction.reject => l10n.staff_hireRejected,
        StaffReaction.waiting => l10n.contract_waiting,
        StaffReaction.counter => l10n.contract_faCounter,
      };
    });
  }
}
