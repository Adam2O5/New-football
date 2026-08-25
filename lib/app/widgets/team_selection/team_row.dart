import 'package:flutter/material.dart';

import 'package:new_football/app/branding/club_asset_registry.dart';
import 'package:new_football/app/branding/club_branding_types.dart';
import 'package:new_football/app/branding/club_color_tokens.dart';
import 'package:new_football/app/widgets/branding/club_logo.dart';
import 'package:new_football/app/widgets/team_selection/team_selection_assets.dart';

/// A single selectable club tile.
///
/// The screen owns the selected-team state and supplies the localized
/// semantics label. This widget renders the supplied preview snapshot and
/// delegates both visual and accessibility activation to [onActivate].
class TeamRow extends StatelessWidget {
  const TeamRow({
    super.key,
    required this.teamId,
    required this.name,
    required this.city,
    required this.conferenceLabel,
    this.branding,
    required this.selected,
    this.placeholderAsset,
    required this.localizedSemanticsLabel,
    required this.onActivate,
  });

  final String teamId;
  final String name;
  final String city;
  final String conferenceLabel;
  final ClubBrandingResolution? branding;
  final bool selected;
  final String? placeholderAsset;
  final String localizedSemanticsLabel;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isBranded = branding != null;
    final primaryColor = branding?.primaryColor ?? colorScheme.surface;
    final secondaryColor =
        branding?.secondaryColor ?? colorScheme.outlineVariant;
    final foregroundColor = branding == null
        ? colorScheme.onSurface
        : foregroundFor(primaryColor);
    final logoAsset =
        branding?.logoAsset ??
        placeholderAsset ??
        ClubAssetRegistry.production.fallbackLogoAsset;
    final fallbackLogoAsset = ClubAssetRegistry.production.fallbackLogoAsset;
    final cardColor = isBranded
        ? primaryColor
        : selected
        ? colorScheme.primaryContainer.withValues(alpha: 0.55)
        : null;

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
            color: cardColor,
            // Keep the primary surface equal to the resolved branding color;
            // Material 3 must not blend its surface tint over the club color.
            surfaceTintColor: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: selected
                    ? foregroundColor
                    : isBranded
                    ? secondaryColor
                    : Colors.transparent,
                width: selected ? 2 : 1,
              ),
            ),
            child: InkWell(
              excludeFromSemantics: true,
              onTap: onActivate,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClubLogo(
                          assetPath: logoAsset,
                          fallbackAssetPath: fallbackLogoAsset,
                          size: TeamSelectionAssets.iconSize,
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
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: foregroundColor),
                              ),
                              Text(
                                '$city · $conferenceLabel',
                                softWrap: true,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: foregroundColor),
                              ),
                            ],
                          ),
                        ),
                        if (selected) ...[
                          const SizedBox(width: 8),
                          ExcludeSemantics(
                            child: Icon(
                              Icons.check_circle,
                              color: foregroundColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isBranded)
                    SizedBox(
                      key: ValueKey<String>('team-row-secondary-$teamId'),
                      width: double.infinity,
                      height: 4,
                      child: ColoredBox(color: secondaryColor),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
