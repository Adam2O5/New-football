import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/staff.dart';

/// One visual segment in a five-position staff rating.
enum GraphicStar { full, half, empty }

/// Presentation state of a recognized staff slot.
///
/// [empty] is reserved for a known slot without a member. [unavailable] is
/// used when the input cannot be safely represented as a recognized role, such
/// as a slot/member role mismatch. Neither state carries a fabricated rating.
enum StaffSlotState { occupied, empty, unavailable }

/// Alias kept for callers that describe the value as a view state.
typedef StaffSlotViewState = StaffSlotState;

/// Alias kept for callers that describe the value as presentation state.
typedef StaffPresentationState = StaffSlotState;

/// A role-specific rating prepared for visual presentation.
///
/// [rawOverall] is the unrounded domain value. [displayedRating] and [stars]
/// are presentation-only projections of it; neither value should be passed
/// back to domain services.
class StaffRatingView {
  const StaffRatingView({
    required this.rawOverall,
    required this.displayedRating,
    required this.stars,
    required this.accessibilityLabel,
  });

  /// Unrounded role-specific rating supplied by the domain.
  final double rawOverall;

  /// Half-star rounded value used only by the view.
  final double displayedRating;

  /// Exactly five visual segments corresponding to [displayedRating].
  final List<GraphicStar> stars;

  /// Accessibility/diagnostic text derived from [displayedRating].
  final String accessibilityLabel;

  /// Short numeric accessibility value, useful when a widget supplies its own
  /// localized label around the value.
  String get accessibilityValue => displayedRating.toStringAsFixed(1);

  /// Short alias for consumers that call the domain value simply `raw`.
  double get raw => rawOverall;

  /// Short alias for consumers that call the presentation value `displayed`.
  double get displayed => displayedRating;
}

/// One role-relevant attribute prepared for the offer/details presentation.
///
/// The [value] remains the source attribute value. [displayedRating] and
/// [stars] are derived only for presentation with the same five-position rule
/// as the overall rating.
class StaffAttributeView {
  const StaffAttributeView({
    required this.key,
    required this.name,
    required this.value,
    required this.displayedRating,
    required this.stars,
  });

  /// Canonical domain key of the attribute.
  final StaffAttributeKey key;

  /// Stable serialized name of the attribute (for example `tactics`).
  final String name;

  /// Unrounded source value of the attribute.
  final double value;

  /// Half-star rounded value used only by the view.
  final double displayedRating;

  /// Exactly five visual segments for [displayedRating].
  final List<GraphicStar> stars;

  /// Alias for callers that use the explicit serialized-name terminology.
  String get serializedName => name;

  /// Alias for callers that use `attributeKey` terminology.
  StaffAttributeKey get attributeKey => key;

  /// Alias for the unrounded source value.
  double get rawValue => value;

  /// Alias for the unrounded source value.
  double get raw => value;

  /// Alias for the presentation value.
  double get displayedValue => displayedRating;

  /// A rating-shaped view for consumers that want one common renderer for
  /// overall and attribute stars.
  StaffRatingView get rating => StaffRatingView(
    rawOverall: value,
    displayedRating: displayedRating,
    stars: stars,
    accessibilityLabel: 'Rating ${displayedRating.toStringAsFixed(1)} out of 5',
  );
}

/// Presentation DTO for one staff slot.
class StaffSlotView {
  const StaffSlotView({
    required this.state,
    required this.role,
    this.member,
    this.rating,
    this.relevantAttributes = const <StaffAttributeView>[],
  });

  /// Current presentation state of the slot.
  final StaffSlotState state;

  /// Recognized role represented by the slot, or `null` when unavailable.
  final StaffRole? role;

  /// Occupant when one was supplied. Invalid occupants are retained only for
  /// diagnostics; [rating] and [relevantAttributes] stay null/empty when the
  /// state is [StaffSlotState.unavailable].
  final StaffMember? member;

  /// Role-specific overall for an occupied slot; null for empty/unavailable.
  final StaffRatingView? rating;

  /// Canonical role-relevant attributes for an occupied slot.
  final List<StaffAttributeView> relevantAttributes;

  /// Alias used by offer-preview consumers.
  List<StaffAttributeView> get attributes => relevantAttributes;

  /// Alias used by callers that refer to the slot state as a status.
  StaffSlotState get status => state;

  bool get isOccupied => state == StaffSlotState.occupied;
  bool get isEmpty => state == StaffSlotState.empty;
  bool get isUnavailable => state == StaffSlotState.unavailable;

  /// Forwarding accessors make an occupied slot convenient to render while
  /// retaining the explicit [rating] DTO for callers that need the state.
  double? get rawOverall => rating?.rawOverall;
  double? get displayedRating => rating?.displayedRating;
  List<GraphicStar> get stars => rating?.stars ?? const <GraphicStar>[];
  String? get accessibilityLabel => rating?.accessibilityLabel;
}

/// Flutter-free transformations used by staff screens and widgets.
///
/// This class is deliberately limited to RawOverall → presentation mapping,
/// role-relevant attribute projection, slot state, and candidate ordering. It
/// does not import Flutter or calculate salaries, negotiation scores, payroll,
/// or AI decisions.
abstract final class StaffPresentation {
  /// Converts an unrounded raw value to the displayed half-star value.
  ///
  /// The input is first clamped to the inclusive 0–5 scale. Rounding uses
  /// half-up tie breaking, so 2.25 becomes 2.5 and 2.75 becomes 3.0.
  static double displayedRatingForRaw(double raw) {
    final bounded = _boundedRating(raw);
    return ((bounded * 2.0) + 0.5).floorToDouble() / 2.0;
  }

  /// Projects [raw] into exactly five ordered visual segments.
  ///
  /// The order is all full segments, at most one half segment, then empty
  /// segments. The result is always five elements, including at 0.0 and 5.0.
  static List<GraphicStar> starsForRaw(double raw) {
    final displayed = displayedRatingForRaw(raw);
    final fullCount = displayed.floor();
    final hasHalf = displayed - fullCount >= 0.5;
    final emptyCount = 5 - fullCount - (hasHalf ? 1 : 0);
    return List<GraphicStar>.unmodifiable([
      for (var i = 0; i < fullCount; i++) GraphicStar.full,
      if (hasHalf) GraphicStar.half,
      for (var i = 0; i < emptyCount; i++) GraphicStar.empty,
    ]);
  }

  /// Builds the occupied-slot view for a recognized [member].
  static StaffSlotView viewForMember(StaffMember member) {
    final keys = StaffRatingSystem.roleRelevantAttributes[member.role];
    if (keys == null || keys.isEmpty) {
      return StaffSlotView(
        state: StaffSlotState.unavailable,
        role: member.role,
        member: member,
      );
    }

    final attributes = keys
        .map((key) => _attributeView(member.attributes, key))
        .toList(growable: false);
    final raw = member.overall;
    return StaffSlotView(
      state: StaffSlotState.occupied,
      role: member.role,
      member: member,
      rating: _ratingView(raw),
      relevantAttributes: attributes,
    );
  }

  /// Builds a view for [member] in the recognized [slotRole].
  ///
  /// A null member in a recognized role is an [StaffSlotState.empty] slot and
  /// deliberately has no rating. A null role or a member whose declared role
  /// does not match the slot is [StaffSlotState.unavailable], never a fallback
  /// rating from another role.
  ///
  /// The role is optional so a known empty slot can be represented with
  /// `viewForSlot(null, StaffRole.scout)`. A missing role is unavailable.
  static StaffSlotView viewForSlot(StaffMember? member, [StaffRole? role]) {
    final resolvedMember = member;
    final resolvedRole = role;
    if (resolvedRole == null ||
        !StaffRatingSystem.roleRelevantAttributes.containsKey(resolvedRole)) {
      return StaffSlotView(
        state: StaffSlotState.unavailable,
        role: resolvedRole,
        member: resolvedMember,
      );
    }

    if (resolvedMember == null) {
      return StaffSlotView(state: StaffSlotState.empty, role: resolvedRole);
    }

    if (resolvedMember.role != resolvedRole) {
      return StaffSlotView(
        state: StaffSlotState.unavailable,
        role: resolvedRole,
        member: resolvedMember,
      );
    }

    return viewForMember(resolvedMember);
  }

  /// Returns a new candidate list ordered by raw role rating and stable ID.
  ///
  /// Unsupported role records are excluded. When [role] is supplied, records
  /// declared for a different role are excluded rather than reassigned. The
  /// optional positional role filters the candidates to that role.
  static List<StaffMember> sortStaffCandidates(
    Iterable<StaffMember> candidates, [
    StaffRole? role,
  ]) {
    final requestedRole = role;
    final sortable = <_IndexedStaffCandidate>[];
    final canonical = candidates.canonicalStaffMembers(role: requestedRole);
    for (var index = 0; index < canonical.length; index++) {
      sortable.add(_IndexedStaffCandidate(canonical[index], index));
    }

    sortable.sort((a, b) {
      final rawOrder = b.member.overall.compareTo(a.member.overall);
      if (rawOrder != 0) return rawOrder;

      final idOrder = a.member.id.compareTo(b.member.id);
      if (idOrder != 0) return idOrder;

      // IDs should be unique, but retaining source order makes the helper
      // deterministic even for malformed duplicate records.
      return a.sourceIndex.compareTo(b.sourceIndex);
    });

    return List<StaffMember>.unmodifiable(
      sortable.map((entry) => entry.member),
    );
  }

  static StaffRatingView _ratingView(double raw) {
    final displayed = displayedRatingForRaw(raw);
    return StaffRatingView(
      rawOverall: raw,
      displayedRating: displayed,
      stars: starsForRaw(raw),
      accessibilityLabel: 'Rating ${displayed.toStringAsFixed(1)} out of 5',
    );
  }

  static StaffAttributeView _attributeView(
    StaffAttributes attributes,
    StaffAttributeKey key,
  ) {
    final value = StaffRatingSystem.attributeValue(attributes, key);
    final displayed = displayedRatingForRaw(value);
    return StaffAttributeView(
      key: key,
      name: key.name,
      value: value,
      displayedRating: displayed,
      stars: starsForRaw(value),
    );
  }

  static double _boundedRating(double value) {
    // Domain values are finite, but treating NaN as the neutral lower bound
    // keeps presentation deterministic for malformed external input. +/-
    // infinity continue through clamp to the nearest scale boundary.
    if (value.isNaN) return StaffRatingSystem.minRating;
    return value
        .clamp(StaffRatingSystem.minRating, StaffRatingSystem.maxRating)
        .toDouble();
  }
}

/// Top-level façade for callers that prefer function-style utility imports.
double displayedRatingForRaw(double raw) =>
    StaffPresentation.displayedRatingForRaw(raw);

/// Top-level façade for callers that prefer function-style utility imports.
List<GraphicStar> starsForRaw(double raw) => StaffPresentation.starsForRaw(raw);

/// Top-level façade for callers that prefer function-style utility imports.
StaffSlotView viewForMember(StaffMember member) =>
    StaffPresentation.viewForMember(member);

/// Top-level façade for callers that prefer function-style utility imports.
StaffSlotView viewForSlot(StaffMember? member, [StaffRole? role]) =>
    StaffPresentation.viewForSlot(member, role);

/// Top-level façade for callers that prefer function-style utility imports.
List<StaffMember> sortStaffCandidates(
  Iterable<StaffMember> candidates, [
  StaffRole? role,
]) => StaffPresentation.sortStaffCandidates(candidates, role);

class _IndexedStaffCandidate {
  const _IndexedStaffCandidate(this.member, this.sourceIndex);

  final StaffMember member;
  final int sourceIndex;
}
