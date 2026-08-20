import 'package:flutter/material.dart';
import 'package:new_football/app/utils/staff_presentation.dart';

/// Renders a role-specific staff rating prepared by [StaffPresentation].
///
/// The widget is intentionally a renderer only: [StaffRatingView.stars] is
/// already the five-position GraphicStar projection, so no rating or rounding
/// calculation is performed here. Pass [slot] when the rating belongs to a
/// slot that may be empty or unavailable; those states render no star icons.
class StaffRatingStars extends StatelessWidget {
  const StaffRatingStars({
    super.key,
    this.view,
    this.rating,
    this.slot,
    this.state = StaffSlotState.occupied,
    this.iconSize = 18,
    this.spacing = 0,
    this.color,
    this.keyPrefix = 'staff-rating-stars',
    this.emptyLabel = 'Staff slot empty',
    this.unavailableLabel = 'Staff rating unavailable',
  }) : assert(
         view == null || rating == null,
         'Provide either view or rating, not both.',
       );

  /// Rating DTO supplied by [StaffPresentation].
  final StaffRatingView? view;

  /// Alias for [view] that reads naturally at rating call sites.
  final StaffRatingView? rating;

  /// Optional slot DTO. Its state takes precedence over [view]/[rating].
  final StaffSlotView? slot;

  /// State used when [slot] is not supplied.
  final StaffSlotState state;

  /// Size of each star icon.
  final double iconSize;

  /// Horizontal gap between adjacent star icons.
  final double spacing;

  /// Optional icon color; the ambient icon theme is used when omitted.
  final Color? color;

  /// Stable prefix for the renderer and its five icon keys.
  final String keyPrefix;

  /// Semantics label used for an explicit empty slot.
  final String emptyLabel;

  /// Semantics label used for unavailable or missing rating input.
  final String unavailableLabel;

  @override
  Widget build(BuildContext context) {
    final slotView = slot;
    if (slotView != null) {
      if (slotView.state != StaffSlotState.occupied) {
        return _StaffGraphicStars.neutral(
          keyPrefix: keyPrefix,
          label: _slotStateLabel(slotView.state),
        );
      }

      final slotRating = slotView.rating;
      if (slotRating == null) {
        return _StaffGraphicStars.neutral(
          keyPrefix: keyPrefix,
          label: unavailableLabel,
        );
      }
      return _StaffGraphicStars(
        keyPrefix: keyPrefix,
        stars: slotRating.stars,
        displayedRating: slotRating.displayedRating,
        iconSize: iconSize,
        spacing: spacing,
        color: color,
      );
    }

    final resolvedRating = view ?? rating;
    if (state != StaffSlotState.occupied || resolvedRating == null) {
      return _StaffGraphicStars.neutral(
        keyPrefix: keyPrefix,
        label: state == StaffSlotState.empty ? emptyLabel : unavailableLabel,
      );
    }

    return _StaffGraphicStars(
      keyPrefix: keyPrefix,
      stars: resolvedRating.stars,
      displayedRating: resolvedRating.displayedRating,
      iconSize: iconSize,
      spacing: spacing,
      color: color,
    );
  }

  String _slotStateLabel(StaffSlotState slotState) => switch (slotState) {
    StaffSlotState.empty => emptyLabel,
    StaffSlotState.unavailable => unavailableLabel,
    StaffSlotState.occupied => unavailableLabel,
  };
}

/// Renders one role-relevant attribute using the same five-position rule as
/// [StaffRatingStars].
///
/// [StaffAttributeView.stars] and [StaffAttributeView.displayedRating] are
/// presentation outputs, so this widget does not recalculate or round the
/// attribute value. A missing view is rendered as an unavailable state rather
/// than as five empty stars for an occupied attribute.
class StaffAttributeStars extends StatelessWidget {
  const StaffAttributeStars({
    super.key,
    this.view,
    this.attribute,
    this.rating,
    this.iconSize = 18,
    this.spacing = 0,
    this.color,
    this.keyPrefix = 'staff-attribute-stars',
    this.unavailableLabel = 'Staff attribute unavailable',
  }) : assert(
         view == null || attribute == null,
         'Provide either view or attribute, not both.',
       );

  /// Attribute DTO supplied by [StaffPresentation].
  final StaffAttributeView? view;

  /// Alias for [view] that reads naturally at attribute call sites.
  final StaffAttributeView? attribute;

  /// Optional rating-shaped view, useful when rendering [StaffAttributeView]
  /// through its [StaffAttributeView.rating] adapter.
  final StaffRatingView? rating;

  /// Size of each star icon.
  final double iconSize;

  /// Horizontal gap between adjacent star icons.
  final double spacing;

  /// Optional icon color; the ambient icon theme is used when omitted.
  final Color? color;

  /// Stable prefix for the renderer and its five icon keys.
  final String keyPrefix;

  /// Semantics label used when the attribute view is unavailable.
  final String unavailableLabel;

  @override
  Widget build(BuildContext context) {
    final attributeView = view ?? attribute;
    if (attributeView != null) {
      return _StaffGraphicStars(
        keyPrefix: keyPrefix,
        stars: attributeView.stars,
        displayedRating: attributeView.displayedRating,
        iconSize: iconSize,
        spacing: spacing,
        color: color,
      );
    }

    final ratingView = rating;
    if (ratingView != null) {
      return _StaffGraphicStars(
        keyPrefix: keyPrefix,
        stars: ratingView.stars,
        displayedRating: ratingView.displayedRating,
        iconSize: iconSize,
        spacing: spacing,
        color: color,
      );
    }

    return _StaffGraphicStars.neutral(
      keyPrefix: keyPrefix,
      label: unavailableLabel,
    );
  }
}

/// Shared Flutter renderer for the two public staff-star widgets.
class _StaffGraphicStars extends StatelessWidget {
  const _StaffGraphicStars({
    required this.keyPrefix,
    required this.stars,
    required this.displayedRating,
    required this.iconSize,
    required this.spacing,
    required this.color,
  }) : label = null;

  const _StaffGraphicStars.neutral({
    required this.keyPrefix,
    required this.label,
  }) : stars = null,
       displayedRating = null,
       iconSize = 0,
       spacing = 0,
       color = null;

  final String keyPrefix;
  final List<GraphicStar>? stars;
  final double? displayedRating;
  final double iconSize;
  final double spacing;
  final Color? color;
  final String? label;

  bool get isNeutral => stars == null || displayedRating == null;

  @override
  Widget build(BuildContext context) {
    if (isNeutral) {
      return Semantics(
        key: ValueKey<String>('$keyPrefix-semantics'),
        container: true,
        excludeSemantics: true,
        label: label,
        child: SizedBox(key: ValueKey<String>('$keyPrefix-empty')),
      );
    }

    final segments = stars!;
    if (segments.length != 5) {
      return Semantics(
        key: ValueKey<String>('$keyPrefix-semantics'),
        container: true,
        excludeSemantics: true,
        label: 'Staff rating unavailable',
        child: SizedBox(key: ValueKey<String>('$keyPrefix-empty')),
      );
    }

    return Semantics(
      key: ValueKey<String>('$keyPrefix-semantics'),
      container: true,
      excludeSemantics: true,
      label: _ratingSemanticsLabel(displayedRating!),
      child: ExcludeSemantics(
        child: Row(
          key: ValueKey<String>(keyPrefix),
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < segments.length; index++) ...[
              if (index > 0) SizedBox(width: spacing),
              Icon(
                _iconFor(segments[index]),
                key: ValueKey<String>('$keyPrefix-star-$index'),
                size: iconSize,
                color: color,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static IconData _iconFor(GraphicStar star) => switch (star) {
    GraphicStar.full => Icons.star,
    GraphicStar.half => Icons.star_half,
    GraphicStar.empty => Icons.star_border,
  };

  static String _ratingSemanticsLabel(double displayedRating) =>
      'Rating ${displayedRating.toStringAsFixed(1)} out of 5';
}
