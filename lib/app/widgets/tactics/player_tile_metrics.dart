part of 'player_list_tile.dart';

/// A clamped, horizontal form track with a compact visible border.
class FormIndicator extends StatelessWidget {
  const FormIndicator({
    super.key,
    required this.form,
    required this.l10n,
    this.width = 34.0,
  });

  final double form;
  final AppLocalizations l10n;
  final double width;

  @override
  Widget build(BuildContext context) {
    final clampedForm = clampedFormValue(form);
    final fill = formFillForValue(clampedForm);
    final fillColor = formColorForClampedValue(clampedForm);
    final colors = Theme.of(context).colorScheme;
    final trackColor = colors.surfaceContainerLow;
    final indicatorWidth = width.clamp(32.0, 36.0).toDouble();

    return Semantics(
      container: true,
      label: l10n.squad_formIndicatorSemantics(_formatForm(clampedForm)),
      child: ExcludeSemantics(
        child: Container(
          key: const ValueKey('squad-form-indicator'),
          width: indicatorWidth,
          height: 10,
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: Border.all(color: colors.outline, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: trackColor),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: fill,
                  child: ColoredBox(color: fillColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A clamped, horizontal stamina track with a compact visible border.
///
/// Mirrors [FormIndicator]'s structure but reads the 0–100 stamina gradient
/// (no blue endpoint) instead of the 0–10 form gradient.
class StaminaIndicator extends StatelessWidget {
  const StaminaIndicator({
    super.key,
    required this.stamina,
    required this.l10n,
    this.width = 34.0,
  });

  final double stamina;
  final AppLocalizations l10n;
  final double width;

  @override
  Widget build(BuildContext context) {
    final clampedStamina = clampedStaminaValue(stamina);
    final fill = staminaFillForValue(clampedStamina);
    final fillColor = staminaColorForClampedValue(clampedStamina);
    final colors = Theme.of(context).colorScheme;
    final trackColor = colors.surfaceContainerLow;
    final indicatorWidth = width.clamp(32.0, 36.0).toDouble();

    return Semantics(
      container: true,
      label: l10n.squad_staminaIndicatorSemantics(
        _formatStamina(clampedStamina),
      ),
      child: ExcludeSemantics(
        child: Container(
          key: const ValueKey('squad-stamina-indicator'),
          width: indicatorWidth,
          height: 10,
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: Border.all(color: colors.outline, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: trackColor),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: fill,
                  child: ColoredBox(color: fillColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small text caption placed under a metric bar (form/stamina) so both
/// tracks are identifiable at a glance. Purely visual: the bar underneath
/// already carries its own [Semantics] label, so the caption is excluded
/// from the accessibility tree to avoid announcing the value twice.
class _MetricBarCaption extends StatelessWidget {
  const _MetricBarCaption({
    required this.label,
    required this.width,
    required this.bar,
  });

  final String label;
  final double width;
  final Widget bar;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          bar,
        ],
      ),
    );
  }
}

String _formatForm(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toString();
}

String _formatStamina(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toString();
}
