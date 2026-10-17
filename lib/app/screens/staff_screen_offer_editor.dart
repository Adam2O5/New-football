part of 'staff_screen.dart';

mixin _StaffScreenOfferEditor
    on ConsumerState<StaffScreen>, _StaffScreenShared {
  Widget _offerEditor(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    Team team,
    StaffMember member,
  ) {
    final status = _teamStatus(league, team.id);
    final expectedSalary = _staffService.expectedSalary(
      member,
      currentTeamStatus: status,
    );
    final expectedLength = _staffService.expectedLength(
      member,
      currentTeamStatus: status,
    );
    final salary = int.tryParse(_salaryController.text.trim());
    final years = int.tryParse(_yearsController.text.trim());
    final score = salary == null || years == null || years < 1
        ? null
        : _staffService.staffOfferScore(
            member,
            StaffOffer(salary: salary, years: years),
            offeringTeamStatus: status,
            currentTeamStatus: status,
            cfo: team.staff.cfo,
          );
    final validationError = _offerValidationError(
      l10n,
      team,
      member,
      StaffOffer(salary: salary ?? 0, years: years ?? 0),
      isExtension: _selectedExtension,
      salary: salary,
      years: years,
    );
    final canSubmit =
        validationError == null &&
        _canSubmitStaffOffer(
          league,
          team,
          member,
          isExtension: _selectedExtension,
        );
    final staffView = StaffPresentation.viewForMember(member);
    final attributes = _attributes(staffView);

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.staff_offerPreview}: ${member.name}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.staff_profileLine(
                staffRoleLabel(context, member.role),
                member.age,
                member.nationality.name,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.staff_attributes,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            if (staffView.isOccupied)
              ...attributes.map(
                (attribute) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(_attributeLabel(l10n, attribute.key)),
                      ),
                      StaffAttributeStars(
                        key: ValueKey<String>(
                          'staff-attribute-${member.id}-${attribute.key.name}',
                        ),
                        view: attribute,
                        keyPrefix:
                            'staff-attribute-${member.id}-${attribute.key.name}',
                      ),
                    ],
                  ),
                ),
              )
            else
              const Text('—'),
            const SizedBox(height: 6),
            Text(
              l10n.staff_expectedSalary(formatMoney(context, expectedSalary)),
            ),
            Text(l10n.staff_expectedLength(expectedLength)),
            Text(
              score == null
                  ? l10n.contract_invalidOffer
                  : l10n.staff_offerScore(score.toStringAsFixed(1)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: l10n.contract_offerSalary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _yearsController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: l10n.contract_offerYears),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: canSubmit
                    ? () => _submitSelectedOffer(l10n, league, team, member)
                    : null,
                child: Text(
                  _selectedExtension
                      ? l10n.contract_submitOffer
                      : l10n.staff_hire,
                ),
              ),
            ),
            if (validationError != null) ...[
              const SizedBox(height: 6),
              Text(
                validationError,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ] else if (!canSubmit) ...[
              const SizedBox(height: 6),
              Text(l10n.market_noWindow),
            ],
          ],
        ),
      ),
    );
  }

  Future<StaffOffer?> _counterDialog(
    AppLocalizations l10n,
    NegotiationOffer current,
  ) async {
    return showDialog<StaffOffer>(
      context: context,
      builder: (context) => _StaffCounterDialog(l10n: l10n, current: current),
    );
  }
}

class _StaffCounterDialog extends StatefulWidget {
  const _StaffCounterDialog({required this.l10n, required this.current});

  final AppLocalizations l10n;
  final NegotiationOffer current;

  @override
  State<_StaffCounterDialog> createState() => _StaffCounterDialogState();
}

class _StaffCounterDialogState extends State<_StaffCounterDialog> {
  late final TextEditingController salaryController;
  late final TextEditingController yearsController;
  String? error;

  @override
  void initState() {
    super.initState();
    salaryController = TextEditingController(
      text: widget.current.salary.toString(),
    );
    yearsController = TextEditingController(
      text: widget.current.years.toString(),
    );
  }

  @override
  void dispose() {
    salaryController.dispose();
    yearsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final dialogContext = context;
    return AlertDialog(
      title: Text(l10n.staff_editCounterTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: salaryController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.contract_offerSalary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: yearsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.contract_offerYears),
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          onPressed: () {
            final salary = int.tryParse(salaryController.text.trim());
            final years = int.tryParse(yearsController.text.trim());
            if (salary == null || years == null || years < 1 || years > 4) {
              setState(() => error = l10n.contract_invalidOffer);
              return;
            }
            Navigator.of(
              dialogContext,
            ).pop(StaffOffer(salary: salary, years: years));
          },
          child: Text(l10n.common_save),
        ),
      ],
    );
  }
}
