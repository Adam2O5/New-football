import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

String _capStatusLabel(AppLocalizations l10n, CapStatus s) => switch (s) {
  CapStatus.underCap => l10n.finance_capStatus_under,
  CapStatus.overCap => l10n.finance_capStatus_over,
  CapStatus.firstApron => l10n.finance_firstApron,
  CapStatus.secondApron => l10n.finance_secondApron,
};

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final team = ref.watch(activeLeagueProvider)?.playerTeam;
    if (team == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.finance_title),
          leading: IconButton(
            tooltip: l10n.common_cancel,
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/game'),
          ),
        ),
        body: ScreenBackground(child: Center(child: Text(l10n.finance_noTeam))),
      );
    }

    const capService = SalaryCapService();
    final snap = capService.snapshot(team);
    final cash = team.finance.cashBalance;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.finance_title),
        leading: IconButton(
          tooltip: l10n.common_cancel,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/game'),
        ),
      ),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.finance_title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            _tile(
              context,
              l10n.finance_payroll,
              formatMoney(context, snap.payroll),
            ),
            _tile(context, l10n.finance_cap, formatMoney(context, snap.cap)),
            _tile(
              context,
              l10n.finance_capSpace,
              formatMoney(context, snap.capSpace),
            ),
            _tile(
              context,
              l10n.finance_firstApron,
              formatMoney(context, snap.firstApron),
            ),
            _tile(
              context,
              l10n.finance_secondApron,
              formatMoney(context, snap.secondApron),
            ),
            _tile(context, l10n.finance_cash, formatMoney(context, cash)),
            _tile(
              context,
              l10n.finance_status,
              _capStatusLabel(l10n, snap.status),
            ),
            Card(
              color: snap.capSpace >= 0
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                leading: Icon(
                  snap.capSpace >= 0
                      ? Icons.check_circle_outline
                      : Icons.warning_amber,
                ),
                title: Text(
                  snap.capSpace >= 0
                      ? l10n.finance_capHealthy
                      : l10n.finance_capWarning,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: () => context.push('/game/trade'),
              child: Text(l10n.finance_trade),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => context.push('/game/contracts'),
              child: Text(l10n.finance_contracts),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => context.push('/game/staff'),
              child: Text(l10n.staff_title),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
