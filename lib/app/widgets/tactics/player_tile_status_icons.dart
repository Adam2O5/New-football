part of 'player_list_tile.dart';

/// A single reserved status slot for injury and suspension meanings.
class StatusIcons extends StatelessWidget {
  const StatusIcons({
    super.key,
    required this.hasActiveInjury,
    required this.hasActiveSuspension,
    required this.l10n,
    this.iconSize = 20,
  });

  final bool hasActiveInjury;
  final bool hasActiveSuspension;
  final AppLocalizations l10n;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final presentation = statusSlotPresentation(
      SquadStatus(
        hasActiveInjury: hasActiveInjury,
        hasActiveSuspension: hasActiveSuspension,
      ),
    );
    final semanticLabels = presentation.semanticStatuses
        .map(_localizedStatusLabel)
        .toList(growable: false);
    final labelsForSlot = semanticLabels.isEmpty
        ? <String>[l10n.squad_statusSlotEmpty]
        : semanticLabels;
    final tooltipMessage = labelsForSlot.join('. ');
    final slotWidth = math.max(25.0, iconSize + 5.0).toDouble();

    IconData? icon;
    Color? color;
    switch (presentation.visual) {
      case StatusVisualKind.none:
        break;
      case StatusVisualKind.injury:
        icon = Icons.healing_outlined;
        color = colors.error;
      case StatusVisualKind.suspension:
        icon = Icons.gavel_outlined;
        color = colors.tertiary;
    }

    return Tooltip(
      message: tooltipMessage,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: SizedBox(
          width: slotWidth,
          height: 32,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (final label in labelsForSlot)
                Semantics(
                  container: true,
                  label: label,
                  child: const SizedBox.expand(),
                ),
              if (icon != null)
                ExcludeSemantics(
                  child: Icon(icon, color: color, size: iconSize),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _localizedStatusLabel(StatusVisualKind status) {
    switch (status) {
      case StatusVisualKind.none:
        return l10n.squad_statusSlotEmpty;
      case StatusVisualKind.injury:
        return l10n.squad_statusInjury;
      case StatusVisualKind.suspension:
        return l10n.squad_statusSuspension;
    }
  }
}
