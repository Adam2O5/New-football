part of 'prospects_screen.dart';

class _ProspectDetailContent extends StatelessWidget {
  const _ProspectDetailContent({
    required this.l10n,
    required this.prospect,
    required this.knowledge,
    required this.scrollController,
    required this.showOptimalRole,
  });

  final AppLocalizations l10n;
  final Prospect prospect;
  final ScoutingKnowledge? knowledge;
  final ScrollController scrollController;
  final bool showOptimalRole;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tier = knowledge?.tier;
    final tierIndex = tier?.index ?? -1;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(prospect.name, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${prospect.position.code} · ',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              NationalityFlagIcon(prospect.nationality),
              Text(
                ' · ${prospect.age} · ${prospect.heightCm} cm',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Text(l10n.prospects_scoutingData, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          if (knowledge == null)
            Text(
              l10n.prospects_noScouting,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else ...[
            // Tier 2+: estimated overall range.
            if (tierIndex >= ScoutingTier.tier2.index)
              _detailRow(
                l10n.prospects_overallRange,
                _rangeLabel(
                  knowledge?.estimatedOvrMin,
                  knowledge?.estimatedOvrMax,
                ),
              ),
            // Tier 3+: estimated draft slot.
            if (tierIndex >= ScoutingTier.tier3.index)
              _detailRow(
                l10n.prospects_estimatedSlot,
                _slotLabel(l10n, knowledge?.estimatedSlot),
              ),
            // Tier 4+: estimated potential range.
            if (tierIndex >= ScoutingTier.tier4.index)
              _detailRow(
                l10n.prospects_potential,
                _rangeLabel(
                  knowledge?.estimatedPotentialMin?.round(),
                  knowledge?.estimatedPotentialMax?.round(),
                ),
              ),
            // Injury/determination only become known via Combine, regardless
            // of tier (see `ScoutingService.runCombine`).
            if (knowledge?.injuryProneKnown == true)
              _detailRow(
                l10n.prospects_injuryProne,
                _rangeLabel(
                  knowledge?.injuryProneMin,
                  knowledge?.injuryProneMax,
                ),
              ),
            if (knowledge?.determinationKnown == true)
              _detailRow(
                l10n.prospects_determination,
                _rangeLabel(
                  knowledge?.determinationMin,
                  knowledge?.determinationMax,
                ),
              ),
            if (showOptimalRole)
              _detailRow(
                l10n.scouting_combineRole,
                assignedRoleLabel(context, prospect.optimalRole),
              ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
