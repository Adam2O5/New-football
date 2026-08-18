import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/contract_service.dart';
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
            _marketStatusCard(context, l10n, league),
            const SizedBox(height: 12),
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
                        final want = ContractService().expectedSalary(p);
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
                        formatMoney(
                          context,
                          ContractService().expectedSalary(p),
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _target = _Target.freeAgent;
                        _selectedId = p.id;
                        final want = ContractService().expectedSalary(p);
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
            ..._pendingFinalizations(context, l10n, league, team.id),
          ],
        ),
      ),
    );
  }

  Widget _marketStatusCard(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
  ) {
    final window = ContractMarketService().windowAt(league);
    final phaseLabel = switch (window) {
      ContractMarketWindow.closed => l10n.market_closed,
      ContractMarketWindow.extensions => l10n.market_extensions,
      ContractMarketWindow.freeAgencyPhaseI => l10n.market_phaseI,
      ContractMarketWindow.freeAgencyPhaseII => l10n.market_phaseII,
    };
    final hourly =
        window == ContractMarketWindow.extensions ||
        window == ContractMarketWindow.freeAgencyPhaseI;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.schedule),
        title: Text(l10n.market_status),
        subtitle: Text(
          '${l10n.market_date(league.currentWeek, league.currentDay)} · $phaseLabel'
          '${hourly ? '\\n${l10n.market_hour(league.currentHour ?? 1, 10)}' : ''}',
        ),
      ),
    );
  }

  String _subjectName(LeagueState league, String id) {
    for (final player in league.freeAgents) {
      if (player.id == id) return player.name;
    }
    final team = league.playerTeam;
    for (final player in team?.roster ?? const []) {
      if (player.id == id) return player.name;
    }
    return id;
  }

  String _negotiationSubtitle(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    ContractNegotiation negotiation,
  ) {
    final player =
        [
          ...league.freeAgents,
          ...(league.playerTeam?.roster ?? const []),
        ].cast<Player?>().firstWhere(
          (item) => item?.id == negotiation.subjectId,
          orElse: () => null,
        );
    final expectedSalary = player == null
        ? null
        : ContractService().expectedSalary(player);
    final expectedLength = player == null
        ? null
        : ContractService().expectedLength(player);
    final details = <String>[
      l10n.market_round(negotiation.round),
      l10n.market_score(negotiation.offerScore.toStringAsFixed(1)),
      l10n.market_deadline(
        negotiation.expiryWeek.toString(),
        negotiation.expiryDay.toString(),
        negotiation.expiryHour.toString(),
      ),
      if (expectedSalary != null)
        l10n.market_expectedSalary(formatMoney(context, expectedSalary)),
      if (expectedLength != null) l10n.market_expectedLength(expectedLength),
      '${formatMoney(context, negotiation.lastOffer.salary)} × ${negotiation.lastOffer.years}',
    ];
    return details.join(' · ');
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
    final reaction = await ref
        .read(gameControllerProvider.notifier)
        .offerContractExtension(id, offer);

    switch (reaction) {
      case ContractReaction.accept:
        setState(() => _status = l10n.contract_pendingFinalization);
      case ContractReaction.hardReject:
      case ContractReaction.reject:
        setState(() => _status = l10n.contract_rejected);
      case ContractReaction.waiting:
        setState(() => _status = l10n.contract_waiting);
      case ContractReaction.counter:
        final player = team.roster.firstWhere((p) => p.id == id);
        final counter = ContractService().counterOffer(player, offer);
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
        setState(() => _status = l10n.contract_pendingFinalization);
      case ContractReaction.hardReject:
      case ContractReaction.reject:
        setState(() => _status = l10n.contract_rejected);
      case ContractReaction.waiting:
        setState(() => _status = l10n.contract_waiting);
      case ContractReaction.counter:
        setState(() => _status = l10n.contract_faCounter);
    }
  }

  List<Widget> _pendingFinalizations(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    String teamId,
  ) {
    final pending = league.negotiations
        .where(
          (item) =>
              item.teamId == teamId &&
              item.subjectKind == NegotiationSubjectKind.player &&
              item.status == NegotiationStatus.pendingFinalization,
        )
        .toList();
    if (pending.isEmpty) return const [];
    return [
      const SizedBox(height: 12),
      Card(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: Text(l10n.contract_pendingFinalization),
            ),
            ...pending.map(
              (negotiation) => ListTile(
                title: Text(_subjectName(league, negotiation.subjectId)),
                subtitle: Text(
                  _negotiationSubtitle(context, l10n, league, negotiation),
                ),
                trailing: FilledButton.tonal(
                  onPressed: () async {
                    final ok = await ref
                        .read(gameControllerProvider.notifier)
                        .finalizeContractNegotiation(negotiation.id);
                    if (!mounted) return;
                    setState(
                      () => _status = ok
                          ? l10n.contract_accepted
                          : l10n.contract_finalizationFailed,
                    );
                  },
                  child: Text(l10n.contract_finalize),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
