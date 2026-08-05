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
            for (final role in StaffRole.values)
              _roleSection(context, l10n, league, team, role),
            if (_status != null) ...[
              const SizedBox(height: 12),
              Text(_status!, textAlign: TextAlign.center),
            ],
          ],
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
                trailing: TextButton(
                  onPressed: () async {
                    await ref
                        .read(gameControllerProvider.notifier)
                        .fireStaff(role);
                  },
                  child: Text(l10n.staff_fire),
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

  Future<void> _hire(
    AppLocalizations l10n,
    StaffMember candidate,
    StaffOffer offer,
  ) async {
    final ok = await ref
        .read(gameControllerProvider.notifier)
        .hireStaff(candidate, offer);
    setState(() {
      _status = ok
          ? l10n.staff_hireAccepted(candidate.name)
          : l10n.staff_hireRejected;
    });
  }
}
