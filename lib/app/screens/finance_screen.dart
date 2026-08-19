import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

String _capStatusLabel(AppLocalizations l10n, CapStatus s) => switch (s) {
  CapStatus.underCap => l10n.finance_capStatus_under,
  CapStatus.overCap => l10n.finance_capStatus_over,
  CapStatus.firstApron => l10n.finance_firstApron,
  CapStatus.secondApron => l10n.finance_secondApron,
};

class _FinanceMetric {
  const _FinanceMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

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
    final snapshot = capService.snapshot(team);

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
          key: const ValueKey('finance-scroll'),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            _buildTeamHeader(context, l10n, team),
            const SizedBox(height: 12),
            _buildCapOverview(context, l10n, snapshot),
            const SizedBox(height: 12),
            _buildApronOverview(context, l10n, snapshot),
            const SizedBox(height: 12),
            _buildCashOverview(context, l10n, team),
            const SizedBox(height: 12),
            _buildHealthCard(context, l10n, snapshot),
            const SizedBox(height: 12),
            _buildActions(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamHeader(
    BuildContext context,
    AppLocalizations l10n,
    Team team,
  ) {
    final theme = Theme.of(context);
    final initial = team.name.trim().isEmpty
        ? '?'
        : team.name.trim().substring(0, 1).toUpperCase();
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          child: Text(initial),
        ),
        title: Text(team.name, style: theme.textTheme.titleLarge),
        subtitle: Text(l10n.finance_dashboardSubtitle),
      ),
    );
  }

  Widget _buildCapOverview(
    BuildContext context,
    AppLocalizations l10n,
    CapSnapshot snapshot,
  ) {
    final progress = snapshot.cap <= 0
        ? 0.0
        : (snapshot.payroll / snapshot.cap).clamp(0.0, 1.0).toDouble();
    return _sectionCard(
      context,
      title: l10n.finance_capOverview,
      icon: Icons.account_balance_wallet_outlined,
      metrics: [
        _FinanceMetric(
          icon: Icons.payments_outlined,
          label: l10n.finance_payroll,
          value: formatMoney(context, snapshot.payroll),
        ),
        _FinanceMetric(
          icon: Icons.speed_outlined,
          label: l10n.finance_cap,
          value: formatMoney(context, snapshot.cap),
        ),
        _FinanceMetric(
          icon: Icons.savings_outlined,
          label: l10n.finance_capSpace,
          value: formatMoney(context, snapshot.capSpace),
        ),
        _FinanceMetric(
          icon: Icons.flag_outlined,
          label: l10n.finance_status,
          value: _capStatusLabel(l10n, snapshot.status),
        ),
      ],
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            color: snapshot.capSpace >= 0
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
          ),
          const SizedBox(height: 6),
          Text(
            snapshot.capSpace >= 0
                ? l10n.finance_capHealthy
                : l10n.finance_capWarning,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildApronOverview(
    BuildContext context,
    AppLocalizations l10n,
    CapSnapshot snapshot,
  ) {
    return _sectionCard(
      context,
      title: l10n.finance_apronsOverview,
      icon: Icons.layers_outlined,
      metrics: [
        _FinanceMetric(
          icon: Icons.looks_one_outlined,
          label: l10n.finance_firstApron,
          value: formatMoney(context, snapshot.firstApron),
        ),
        _FinanceMetric(
          icon: Icons.looks_two_outlined,
          label: l10n.finance_secondApron,
          value: formatMoney(context, snapshot.secondApron),
        ),
      ],
      footer: Text(
        l10n.finance_apronHeadroom(
          formatMoney(context, snapshot.firstApron - snapshot.payroll),
          formatMoney(context, snapshot.secondApron - snapshot.payroll),
        ),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget _buildCashOverview(
    BuildContext context,
    AppLocalizations l10n,
    Team team,
  ) {
    return _sectionCard(
      context,
      title: l10n.finance_cashOverview,
      icon: Icons.account_balance_outlined,
      metrics: [
        _FinanceMetric(
          icon: Icons.payments_outlined,
          label: l10n.finance_cash,
          value: formatMoney(context, team.finance.cashBalance),
        ),
      ],
    );
  }

  Widget _buildHealthCard(
    BuildContext context,
    AppLocalizations l10n,
    CapSnapshot snapshot,
  ) {
    final healthy = snapshot.capSpace >= 0;
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: healthy ? colors.primaryContainer : colors.errorContainer,
      child: ListTile(
        leading: Icon(
          healthy ? Icons.check_circle_outline : Icons.warning_amber_outlined,
          color: healthy ? colors.onPrimaryContainer : colors.onErrorContainer,
        ),
        title: Text(l10n.finance_financialHealth),
        subtitle: Text(
          healthy ? l10n.finance_capHealthy : l10n.finance_capWarning,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.finance_actions,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => context.push('/game/trade'),
              icon: const Icon(Icons.swap_horiz),
              label: Text(l10n.finance_trade),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.push('/game/contracts'),
              icon: const Icon(Icons.description_outlined),
              label: Text(l10n.finance_contracts),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.push('/game/staff'),
              icon: const Icon(Icons.groups_outlined),
              label: Text(l10n.staff_title),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<_FinanceMetric> metrics,
    Widget? footer,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 14),
            _metricGrid(context, metrics),
            if (footer != null) footer,
          ],
        ),
      ),
    );
  }

  Widget _metricGrid(BuildContext context, List<_FinanceMetric> metrics) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 520 ? 2 : 1;
        final gap = 12.0;
        final width = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - gap) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final metric in metrics)
              SizedBox(width: width, child: _metricTile(context, metric)),
          ],
        );
      },
    );
  }

  Widget _metricTile(BuildContext context, _FinanceMetric metric) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.72,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            metric.icon,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(metric.label, style: theme.textTheme.bodyMedium),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              metric.value,
              textAlign: TextAlign.end,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
