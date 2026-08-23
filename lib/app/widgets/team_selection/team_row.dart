import 'package:flutter/material.dart';

import 'package:new_football/app/widgets/team_selection/team_selection_assets.dart';

/// A single selectable team preview row.
///
/// The screen owns the selected-team state and supplies the localized
/// semantics label. This widget only renders the supplied snapshot and
/// delegates both visual and accessibility activation to [onActivate].
class TeamRow extends StatelessWidget {
  const TeamRow({
    super.key,
    required this.teamId,
    required this.name,
    required this.city,
    required this.conferenceLabel,
    required this.selected,
    required this.placeholderAsset,
    required this.localizedSemanticsLabel,
    required this.onActivate,
  });

  final String teamId;
  final String name;
  final String city;
  final String conferenceLabel;
  final bool selected;
  final String placeholderAsset;
  final String localizedSemanticsLabel;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      key: ValueKey<String>('team-row-semantics-$teamId'),
      container: true,
      excludeSemantics: true,
      button: true,
      selected: selected,
      label: localizedSemanticsLabel,
      onTap: onActivate,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: SizedBox(
          width: double.infinity,
          child: Card(
            margin: EdgeInsets.zero,
            color: selected
                ? colorScheme.primaryContainer.withValues(alpha: 0.55)
                : null,
            child: InkWell(
              excludeFromSemantics: true,
              onTap: onActivate,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ExcludeSemantics(
                      child: SizedBox(
                        width: TeamSelectionAssets.iconSize,
                        height: TeamSelectionAssets.iconSize,
                        child: Image.asset(
                          placeholderAsset,
                          width: TeamSelectionAssets.iconSize,
                          height: TeamSelectionAssets.iconSize,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const SizedBox(
                            width: TeamSelectionAssets.iconSize,
                            height: TeamSelectionAssets.iconSize,
                            child: SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            softWrap: true,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '$city · $conferenceLabel',
                            softWrap: true,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle,
                        color: colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
