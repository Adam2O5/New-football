part of 'home_screen.dart';

Widget _buildNextActionSection(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
  LeagueState league,
  UpcomingAction? action,
) {
  final calendar = ref.read(calendarServiceProvider);
  final hourly = calendar.isHourlyContractMode(
    league.currentWeek,
    league.currentDay,
  );
  final blockedByUrgent = league.inbox.pendingUrgent.isNotEmpty;

  if (blockedByUrgent) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: null,
        icon: const Icon(Icons.lock_outline),
        label: Text(l10n.home_readUrgent),
      ),
    );
  }

  if (hourly) {
    final hour = league.currentHour ?? 1;
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _advanceOneHour(context, ref, l10n),
        icon: const Icon(Icons.schedule),
        label: Text(l10n.home_simulateHour(hour)),
      ),
    );
  }

  String actionLabel(UpcomingAction? upcoming) {
    if (upcoming == null) return l10n.home_nextEvent;
    final eventId = upcoming.calendarEventId;
    return eventId == null
        ? upcoming.id
        : calendarEventLabel(context, eventId) ?? upcoming.id;
  }

  final actionIsToday =
      action != null &&
      action.week == league.currentWeek &&
      action.day == league.currentDay;

  if (!actionIsToday) {
    final secondaryLabel = switch (action?.kind) {
      CalendarEventKind.match => l10n.home_simulateToNextMatch,
      CalendarEventKind.playerAction ||
      CalendarEventKind.automatic ||
      CalendarEventKind.informational =>
        action != null
            ? l10n.home_simulateToEvent(actionLabel(action))
            : l10n.home_simulateUntilEvent,
      null => l10n.home_simulateUntilEvent,
    };

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _simulateDay(context, ref, l10n),
            icon: const Icon(Icons.skip_next_outlined),
            label: Text(l10n.home_simulateDay),
            style: OutlinedButton.styleFrom(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.85),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: action == null
                ? null
                : () =>
                      _goToEvent(context, ref, l10n, action, openRoute: false),
            icon: const Icon(Icons.fast_forward),
            label: Text(secondaryLabel),
          ),
        ),
      ],
    );
  }

  if (action.kind == CalendarEventKind.match) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _simulateMatch(context, ref, l10n),
        icon: const Icon(Icons.sports_soccer),
        label: Text(l10n.home_simulateMatch),
      ),
    );
  }

  final label = actionLabel(action);
  final goToOnly =
      action.calendarEventId != null &&
      _isGoToOnlyEvent(action.calendarEventId!);
  final simulateOnly =
      action.calendarEventId != null &&
      _isSimulateOnlyEvent(action.calendarEventId!);

  if (goToOnly) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _goToEvent(context, ref, l10n, action),
        icon: const Icon(Icons.event_available_outlined),
        label: Text(l10n.home_goToEvent(label)),
      ),
    );
  }

  if (simulateOnly) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _simulateEvent(context, ref, l10n, action),
        icon: const Icon(Icons.fast_forward),
        label: Text(l10n.home_simulateEvent(label)),
      ),
    );
  }

  return Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () => _goToEvent(context, ref, l10n, action),
          style: OutlinedButton.styleFrom(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.85),
          ),
          child: Text(l10n.home_goToEvent(label)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: FilledButton(
          onPressed: () => _simulateEvent(context, ref, l10n, action),
          child: Text(l10n.home_simulateEvent(label)),
        ),
      ),
    ],
  );
}

class _HomeDashboardHeader extends StatelessWidget {
  const _HomeDashboardHeader({
    required this.teamName,
    required this.logoAsset,
    required this.fallbackLogoAsset,
    this.seasonLines,
  });

  final String teamName;
  final String logoAsset;
  final String fallbackLogoAsset;
  final SeasonContextLines? seasonLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lines = seasonLines;

    return Card(
      key: const ValueKey('home-dashboard-header'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Semantics(
                  container: true,
                  excludeSemantics: true,
                  label: teamName,
                  sortKey: const OrdinalSortKey(0),
                  child: Text(
                    teamName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Semantics(
                container: true,
                excludeSemantics: true,
                sortKey: const OrdinalSortKey(1),
                child: ClubLogo(
                  assetPath: logoAsset,
                  fallbackAssetPath: fallbackLogoAsset,
                ),
              ),
              if (lines != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: SeasonContext(
                    lines: lines,
                    sortKey: const OrdinalSortKey(2),
                    textStyle: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
