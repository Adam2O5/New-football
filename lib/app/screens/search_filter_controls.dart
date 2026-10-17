part of 'search_filters_screen.dart';

class _GroupToggleRow extends StatelessWidget {
  const _GroupToggleRow({
    required this.title,
    required this.groups,
    required this.onChanged,
    required this.l10n,
  });

  final String title;
  final Set<SearchGroup> groups;
  final ValueChanged<Set<SearchGroup>> onChanged;
  final AppLocalizations l10n;

  String _label(SearchGroup group) => switch (group) {
    SearchGroup.players => l10n.search_players,
    SearchGroup.prospects => l10n.search_prospects,
    SearchGroup.picks => l10n.search_picks,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: [
            for (final group in _groupOrder)
              FilterChip(
                label: Text(_label(group)),
                selected: groups.contains(group),
                onSelected: (selected) {
                  final next = Set<SearchGroup>.from(groups);
                  if (selected) {
                    next.add(group);
                  } else {
                    next.remove(group);
                  }
                  if (next.isEmpty) return;
                  onChanged(next);
                },
              ),
          ],
        ),
      ],
    );
  }
}

/// An inclusive range slider bound to a [RangeFilter]. Dragging a handle back
/// to the track's outer edge clears that side back to "unset" rather than
/// pinning it at the numeric bound, matching the unset-by-default contract.
/// The minus/plus buttons nudge the lower/upper bound by one slider step
/// (the same granularity as `divisions`, e.g. one whole OVR point or one
/// $1M salary step — not a hardcoded "1", which would be meaningless for a
/// filter stepped in millions).
class _RangeFilterTile extends StatelessWidget {
  const _RangeFilterTile({
    required this.label,
    required this.filter,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.formatValue,
  });

  final String label;
  final RangeFilter filter;
  final double min;
  final double max;
  final ValueChanged<RangeFilter> onChanged;
  final int? divisions;
  final String Function(double value)? formatValue;

  double get _step =>
      (divisions != null && divisions! > 0) ? (max - min) / divisions! : 1.0;

  @override
  Widget build(BuildContext context) {
    final effectiveMin = (filter.min ?? min).clamp(min, max);
    final effectiveMax = (filter.max ?? max).clamp(min, max);
    final fmt = formatValue ?? (v) => v.round().toString();
    final step = _step;

    void applyRange(double newMin, double newMax) {
      onChanged(
        RangeFilter(
          min: newMin <= min ? null : newMin,
          max: newMax >= max ? null : newMax,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleSmall),
              Text('${fmt(effectiveMin)} - ${fmt(effectiveMax)}'),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                visualDensity: VisualDensity.compact,
                onPressed: effectiveMin <= min
                    ? null
                    : () => applyRange(
                        (effectiveMin - step).clamp(min, max),
                        effectiveMax,
                      ),
              ),
              Expanded(
                child: RangeSlider(
                  min: min,
                  max: max,
                  divisions: divisions,
                  values: RangeValues(effectiveMin, effectiveMax),
                  labels: RangeLabels(fmt(effectiveMin), fmt(effectiveMax)),
                  onChanged: (values) => applyRange(values.start, values.end),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                visualDensity: VisualDensity.compact,
                onPressed: effectiveMax >= max
                    ? null
                    : () => applyRange(
                        effectiveMin,
                        (effectiveMax + step).clamp(min, max),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Checkbox-driven multi-select behind a summary tile. Empty selection means
/// "no restriction" and is shown as [AppLocalizations.searchFilters_allSelected].
class _MultiSelectTile<T> extends StatelessWidget {
  const _MultiSelectTile({
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.l10n,
  });

  final String label;
  final List<(T value, String label)> options;
  final Set<T> selected;
  final ValueChanged<Set<T>> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final summary = selected.isEmpty
        ? l10n.searchFilters_allSelected
        : l10n.searchFilters_selectedCount(selected.length);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(summary),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final result = await showModalBottomSheet<Set<T>>(
          context: context,
          isScrollControlled: true,
          builder: (sheetContext) => _MultiSelectSheet<T>(
            title: label,
            options: options,
            initialSelected: selected,
            l10n: l10n,
          ),
        );
        if (result != null) onChanged(result);
      },
    );
  }
}

class _MultiSelectSheet<T> extends StatefulWidget {
  const _MultiSelectSheet({
    required this.title,
    required this.options,
    required this.initialSelected,
    required this.l10n,
  });

  final String title;
  final List<(T value, String label)> options;
  final Set<T> initialSelected;
  final AppLocalizations l10n;

  @override
  State<_MultiSelectSheet<T>> createState() => _MultiSelectSheetState<T>();
}

class _MultiSelectSheetState<T> extends State<_MultiSelectSheet<T>> {
  late final Set<T> _selected = Set<T>.from(widget.initialSelected);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, scrollController) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _selected.clear()),
                      child: Text(widget.l10n.searchFilters_allSelected),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    for (final option in widget.options)
                      CheckboxListTile(
                        value: _selected.contains(option.$1),
                        title: Text(option.$2),
                        onChanged: (checked) => setState(() {
                          if (checked ?? false) {
                            _selected.add(option.$1);
                          } else {
                            _selected.remove(option.$1);
                          }
                        }),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, _selected),
                  child: Text(widget.l10n.common_save),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A labelled dropdown row, mirroring the plain `DropdownButton` (not the
/// `FormField` variant) already used by `prospects_screen.dart` — avoids
/// depending on a Flutter-version-specific `DropdownButtonFormField` API.
class _LabeledDropdown<T> extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.titleSmall),
        ),
        DropdownButton<T>(value: value, items: items, onChanged: onChanged),
      ],
    );
  }
}
