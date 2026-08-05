import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

enum _Target { none, ownExpiring, freeAgent }

class ContractScreen extends ConsumerStatefulWidget {
  const ContractScreen({super.key});

  @override
  ConsumerState<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends ConsumerState<ContractScreen> {
  final _salaryCtrl = TextEditingController();
  final _yearsCtrl = TextEditingController(text: '3');
  String? _selectedId;
  _Target _target = _Target.none;
  String? _status;

  @override
  void dispose() {
    _salaryCtrl.dispose();
    _yearsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    final team = league?.playerTeam;
    if (league == null || team == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.contract_title)),
        body: ScreenBackground(
          child: Center(child: Text(l10n.contract_noTeam)),
        ),
      );
    }

    final expiring =
        team.roster.where((p) => p.contract.yearsRemaining <= 1).toList()..sort(
          (a, b) =>
              a.contract.yearsRemaining.compareTo(b.contract.yearsRemaining),
        );

    final freeAgents = [...league.freeAgents]
      ..sort((a, b) => b.overall().compareTo(a.overall()));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.contract_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.contract_expiringHeader,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (expiring.isEmpty)
              Card(child: ListTile(title: Text(l10n.contract_noExpiring)))
            else
              ...expiring.map((p) {
                final selected =
                    _target == _Target.ownExpiring && p.id == _selectedId;
                return Card(
                  color: selected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: ListTile(
                    title: Text(p.name),
                    subtitle: Text(
                      l10n.contract_playerSubtitle(
                        p.position.code,
                        p.overall().round(),
                        p.contract.yearsRemaining,
                        formatMoney(context, p.contract.salary),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _target = _Target.ownExpiring;
                        _selectedId = p.id;
                        final want = ContractService().playerWant(p);
                        _salaryCtrl.text = want.toString();
                      });
                    },
                  ),
                );
              }),
            const SizedBox(height: 16),
            Text(
              l10n.contract_freeAgentsHeader,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (freeAgents.isEmpty)
              Card(child: ListTile(title: Text(l10n.contract_freeAgentsEmpty)))
            else
              ...freeAgents.take(30).map((p) {
                final selected =
                    _target == _Target.freeAgent && p.id == _selectedId;
                return Card(
                  color: selected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: ListTile(
                    title: Text(p.name),
                    subtitle: Text(
                      l10n.contract_playerSubtitle(
                        p.position.code,
                        p.overall().round(),
                        p.contract.yearsRemaining,
                        formatMoney(context, ContractService().playerWant(p)),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _target = _Target.freeAgent;
                        _selectedId = p.id;
                        final want = ContractService().playerWant(p);
                        _salaryCtrl.text = want.toString();
                      });
                    },
                  ),
                );
              }),
            const SizedBox(height: 16),
            TextField(
              controller: _salaryCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.contract_offerSalary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _yearsCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.contract_offerYears),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _offer(l10n, team),
              child: Text(l10n.contract_submitOffer),
            ),
            if (_status != null) ...[
              const SizedBox(height: 12),
              Text(_status!),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _offer(AppLocalizations l10n, Team team) async {
    final id = _selectedId;
    if (id == null || _target == _Target.none) {
      setState(() => _status = l10n.contract_selectPlayer);
      return;
    }
    final salary = int.tryParse(_salaryCtrl.text.trim());
    final years = int.tryParse(_yearsCtrl.text.trim());
    if (salary == null || years == null || years < 1) {
      setState(() => _status = l10n.contract_invalidOffer);
      return;
    }
    final offer = ContractOffer(salary: salary, years: years);

    if (_target == _Target.freeAgent) {
      await _offerFreeAgent(l10n, id, offer);
      return;
    }
    await _offerOwnExpiring(l10n, team, id, offer);
  }

  Future<void> _offerOwnExpiring(
    AppLocalizations l10n,
    Team team,
    String id,
    ContractOffer offer,
  ) async {
    final player = team.roster.firstWhere((p) => p.id == id);
    final service = ContractService();
    final reaction = service.evaluate(player, offer);

    switch (reaction) {
      case ContractReaction.accept:
        await ref.read(gameControllerProvider.notifier).updateLeague((l) {
          final t = l.playerTeam!;
          final updatedRoster = t.roster.map((p) {
            if (p.id != id) return p;
            return p.copyWith(
              contract: p.contract.copyWith(
                salary: offer.salary,
                yearsRemaining: offer.years,
              ),
            );
          }).toList();
          final updated = const SalaryCapService().applyPayroll(
            t.copyWith(roster: updatedRoster),
          );
          return l.updateTeam(updated);
        });
        setState(() => _status = l10n.contract_accepted);
      case ContractReaction.hardReject:
        setState(() => _status = l10n.contract_rejected);
      case ContractReaction.waiting:
        setState(() => _status = l10n.contract_waiting);
      case ContractReaction.counter:
        final counter = service.counterOffer(player, offer);
        setState(
          () => _status = l10n.contract_counter(
            formatMoney(context, counter.salary),
            counter.years,
          ),
        );
    }
  }

  Future<void> _offerFreeAgent(
    AppLocalizations l10n,
    String id,
    ContractOffer offer,
  ) async {
    final reaction = await ref
        .read(gameControllerProvider.notifier)
        .offerFreeAgent(id, offer);
    switch (reaction) {
      case ContractReaction.accept:
        setState(() => _status = l10n.contract_accepted);
      case ContractReaction.hardReject:
        setState(() => _status = l10n.contract_rejected);
      case ContractReaction.waiting:
        setState(() => _status = l10n.contract_waiting);
      case ContractReaction.counter:
        setState(() => _status = l10n.contract_faCounter);
    }
  }
}
