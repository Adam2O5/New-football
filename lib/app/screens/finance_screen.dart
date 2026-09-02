import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/club_branding_provider.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/providers/settings_provider.dart';
import 'package:new_football/app/theme/app_theme.dart';
import 'package:new_football/app/utils/color_interpolation.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/league_state.dart';
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

/// Payroll bar for the salary cap card: a filled track from 0 to the second
/// apron, with thin markers at [markerFractions] (used for the salary cap
/// and first apron thresholds).
class _CapProgressBar extends StatelessWidget {
  const _CapProgressBar({
    required this.progress,
    required this.color,
    required this.markerFractions,
    required this.backgroundColor,
  });

  final double progress;
  final Color color;
  final List<double> markerFractions;
  final Color backgroundColor;

  static const double _height = 8;
  static const double _markerWidth = 2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Stack(
            children: [
              LinearProgressIndicator(
                value: progress,
                minHeight: _height,
                borderRadius: BorderRadius.circular(_height / 2),
                color: color,
                backgroundColor: backgroundColor,
              ),
              for (final fraction in markerFractions)
                Positioned(
                  left: (width * fraction).clamp(0.0, width - _markerWidth),
                  top: 0,
                  bottom: 0,
                  child: Container(width: _markerWidth, color: Colors.black45),
                ),
            ],
          );
        },
      ),
    );
  }
}

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    final useLegacyColorTheme = ref.watch(legacyColorThemeSettingProvider);
    final activeTeamId = league?.playerTeamId;
    final branding = ref
        .watch(clubBrandingProvider)
        .resolve(activeTeamId ?? '');
    final team = league?.playerTeam;

    if (team == null) {
      return _themed(
        useLegacyColorTheme,
        branding.primaryColor,
        branding.secondaryColor,
        Scaffold(
          appBar: AppBar(
            title: Text(l10n.finance_title),
            leading: IconButton(
              tooltip: l10n.common_cancel,
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/game'),
            ),
          ),
          body: ScreenBackground(
            child: Center(child: Text(l10n.finance_noTeam)),
          ),
        ),
      );
    }

    const capService = SalaryCapService();
    final snapshot = capService.snapshot(team);

    return _themed(
      useLegacyColorTheme,
      branding.primaryColor,
      branding.secondaryColor,
      Scaffold(
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
              _buildCapOverview(context, l10n, snapshot),
              const SizedBox(height: 12),
              _buildApronOverview(context, l10n, snapshot),
              const SizedBox(height: 12),
              _buildHealthCard(context, l10n, snapshot),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themed(
    bool useLegacyColorTheme,
    Color primary,
    Color secondary,
    Widget child,
  ) {
    if (useLegacyColorTheme) return child;
    return Theme(
      data: AppTheme.forClub(primary: primary, secondary: secondary),
      child: child,
    );
  }

  Widget _buildCapOverview(
    BuildContext context,
    AppLocalizations l10n,
    CapSnapshot snapshot,
  ) {
    // Scale of the bar is 0..secondApron; a second apron of 0 would make the
    // scale degenerate, so it falls back to 1 to keep the fractions finite.
    final maxScale = snapshot.secondApron > 0 ? snapshot.secondApron : 1.0;
    final clampedPayroll = snapshot.payroll.clamp(0.0, maxScale);
    final progress = (clampedPayroll / maxScale).clamp(0.0, 1.0).toDouble();
    final capFraction = (snapshot.cap / maxScale).clamp(0.0, 1.0).toDouble();
    final firstApronFraction = (snapshot.firstApron / maxScale)
        .clamp(0.0, 1.0)
        .toDouble();

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
      footer: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: _CapProgressBar(
          progress: progress,
          color: _capBarColor(snapshot),
          markerFractions: [capFraction, firstApronFraction],
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }

  /// Colour of the payroll bar/health tile for [snapshot], read off a
  /// gradient over the 0..secondApron scale: dark green at 0, light green at
  /// the salary cap, orange at the first apron, red at the second apron.
  Color _capBarColor(CapSnapshot snapshot) {
    final maxScale = snapshot.secondApron > 0 ? snapshot.secondApron : 1.0;
    final clampedPayroll = snapshot.payroll.clamp(0.0, maxScale);
    return interpolateStops(clampedPayroll.toDouble(), [
      const ColorStop(value: 0, color: Color(0xFF2E7D32)),
      ColorStop(value: snapshot.cap.toDouble(), color: Colors.lightGreen),
      ColorStop(value: snapshot.firstApron.toDouble(), color: Colors.orange),
      ColorStop(value: maxScale.toDouble(), color: Colors.red),
    ]);
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
    );
  }

  Widget _buildHealthCard(
    BuildContext context,
    AppLocalizations l10n,
    CapSnapshot snapshot,
  ) {
    final healthy = snapshot.capSpace >= 0;
    final barColor = _capBarColor(snapshot);
    final foreground = foregroundForContrast(barColor);
    return Card(
      color: barColor,
      child: ListTile(
        leading: Icon(
          healthy ? Icons.check_circle_outline : Icons.warning_amber_outlined,
          color: foreground,
        ),
        title: Text(
          l10n.finance_financialHealth,
          style: TextStyle(color: foreground),
        ),
        subtitle: Text(
          healthy ? l10n.finance_capHealthy : l10n.finance_capWarning,
          style: TextStyle(color: foreground),
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
