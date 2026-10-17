part of 'contract_screen.dart';

mixin _ContractScreenCounterDialog
    on ConsumerState<ContractScreen>, _ContractScreenShared {
  Future<ContractOffer?> _counterDialog(
    AppLocalizations l10n,
    NegotiationOffer current,
  ) async {
    return showDialog<ContractOffer>(
      context: context,
      builder: (context) =>
          _ContractCounterDialog(l10n: l10n, current: current),
    );
  }
}

class _ContractCounterDialog extends StatefulWidget {
  const _ContractCounterDialog({required this.l10n, required this.current});

  final AppLocalizations l10n;
  final NegotiationOffer current;

  @override
  State<_ContractCounterDialog> createState() => _ContractCounterDialogState();
}

class _ContractCounterDialogState extends State<_ContractCounterDialog> {
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
    final current = widget.current;
    final dialogContext = context;
    return AlertDialog(
      title: Text(l10n.contract_editCounterTitle),
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
            if (salary == null || years == null || years < 1) {
              setState(() => error = l10n.contract_invalidOffer);
              return;
            }
            Navigator.of(dialogContext).pop(
              ContractOffer(
                salary: salary,
                years: years,
                exception: current.exception,
                rookiePickSlot: current.rookiePickSlot,
              ),
            );
          },
          child: Text(l10n.common_save),
        ),
      ],
    );
  }
}
