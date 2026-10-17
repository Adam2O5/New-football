part of 'search_filters_screen.dart';

class _NationalityDropdown extends StatelessWidget {
  const _NationalityDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.l10n,
  });

  final String label;
  final Nationality? value;
  final ValueChanged<Nationality?> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _LabeledDropdown<Nationality?>(
      label: label,
      value: value,
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(l10n.searchFilters_allSelected),
        ),
        for (final nationality in Nationality.values)
          DropdownMenuItem(value: nationality, child: Text(nationality.label)),
      ],
      onChanged: onChanged,
    );
  }
}

class _PositionDropdown extends StatelessWidget {
  const _PositionDropdown({
    required this.value,
    required this.onChanged,
    required this.l10n,
  });

  final Position? value;
  final ValueChanged<Position?> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _LabeledDropdown<Position?>(
      label: l10n.prospects_position,
      value: value,
      items: [
        DropdownMenuItem(value: null, child: Text(l10n.prospects_allPositions)),
        for (final position in Position.values)
          DropdownMenuItem(value: position, child: Text(position.code)),
      ],
      onChanged: onChanged,
    );
  }
}

class _OptimalRoleDropdown extends StatelessWidget {
  const _OptimalRoleDropdown({
    required this.position,
    required this.value,
    required this.onChanged,
    required this.l10n,
  });

  final Position? position;
  final AssignedRole? value;
  final ValueChanged<AssignedRole?> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final roles = position == null
        ? const <AssignedRole>[]
        : rolesForPosition(position!);
    return _LabeledDropdown<AssignedRole?>(
      label: l10n.scouting_combineRole,
      value: position == null ? null : value,
      items: [
        DropdownMenuItem(value: null, child: Text(l10n.searchFilters_allRoles)),
        for (final role in roles)
          DropdownMenuItem(
            value: role,
            child: Text(assignedRoleLabel(context, role)),
          ),
      ],
      onChanged: position == null ? null : onChanged,
    );
  }
}
