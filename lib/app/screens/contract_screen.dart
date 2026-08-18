import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/models/league_strength.dart';
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
  final _contractService = ContractService();
  final _marketService = ContractMarketService();
  String? _selectedId;
  _Target _target = _Target.none;
  String? _status;
  bool _isAdvancingHour = false;

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
    final selected = _selectedPlayer(league, team);

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
              ...expiring.map((player) {
                final isSelected =
                    _target == _Target.ownExpiring && player.id == _selectedId;
                return Card(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: ListTile(
                    title: Text(player.name),
                    subtitle: Text(
                      l10n.contract_playerSubtitle(
                        player.position.code,
                        player.overall().round(),
                        player.contract.yearsRemaining,
                        formatMoney(context, player.contract.salary),
                      ),
                    ),
                    onTap: () => _selectPlayer(
                      league,
                      team,
                      player,
                      _Target.ownExpiring,
                    ),
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
              ...freeAgents.take(30).map((player) {
                final isSelected =
                    _target == _Target.freeAgent && player.id == _selectedId;
                return Card(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: ListTile(
                    title: Text(player.name),
                    subtitle: Text(
                      l10n.contract_playerSubtitle(
                        player.position.code,
                        player.overall().round(),
                        player.contract.yearsRemaining,
                        formatMoney(
                          context,
                          _expectedSalary(
                            league,
                            team,
                            player,
                            isExtension: false,
                          ),
                        ),
                      ),
                    ),
                    onTap: () =>
                        _selectPlayer(league, team, player, _Target.freeAgent),
                  ),
                );
              }),
            if (selected != null) ...[
              const SizedBox(height: 16),
              _offerPreviewCard(context, l10n, league, team, selected),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: _salaryCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: l10n.contract_offerSalary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _yearsCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: l10n.contract_offerYears),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _canSubmit(league, team)
                  ? () => _offer(l10n, league, team)
                  : null,
              child: Text(
                _target == _Target.freeAgent
                    ? l10n.freeAgency_submitOffer
                    : l10n.contract_submitOffer,
              ),
            ),
            if (_marketService.phaseAt(league) == null) ...[
              const SizedBox(height: 8),
              Text(
                l10n.market_noWindow,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (_status != null) ...[
              const SizedBox(height: 12),
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(_status!),
                ),
              ),
            ],
            _negotiationsSection(context, l10n, league, team.id),
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
    final window = _marketService.windowAt(league);
    final phaseLabel = switch (window) {
      ContractMarketWindow.closed => l10n.market_closed,
      ContractMarketWindow.extensions => l10n.market_extensions,
      ContractMarketWindow.freeAgencyPhaseI => l10n.market_phaseI,
      ContractMarketWindow.freeAgencyPhaseII => l10n.market_phaseII,
    };
    final hourly =
        window == ContractMarketWindow.extensions ||
        window == ContractMarketWindow.freeAgencyPhaseI;
    final hour = (league.currentHour ?? 1).clamp(
      1,
      BalanceConfig.defaults.contracts.hoursPerDay,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.market_status,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(label: Text(phaseLabel)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${l10n.market_date(league.currentDay, league.currentWeek)}'
              '${hourly ? '\n${l10n.market_hour(hour, BalanceConfig.defaults.contracts.hoursPerDay)}' : ''}',
            ),
            if (hourly) ...[
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: _isAdvancingHour ? null : () => _advanceHour(l10n),
                icon: _isAdvancingHour
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.skip_next),
                label: Text(l10n.market_advanceHour),
              ),
            ] else if (window == ContractMarketWindow.closed) ...[
              const SizedBox(height: 6),
              Text(
                l10n.market_noWindow,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _offerPreviewCard(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    Team team,
    Player player,
  ) {
    final isExtension = _target == _Target.ownExpiring;
    final currentStatus = _teamStatus(league, team.id);
    final expectedSalary = _expectedSalary(
      league,
      team,
      player,
      isExtension: isExtension,
    );
    final expectedLength = _contractService.expectedLength(
      player,
      currentTeamStatus: isExtension ? currentStatus : TeamStatus.pretender,
    );
    final salary = int.tryParse(_salaryCtrl.text.trim());
    final years = int.tryParse(_yearsCtrl.text.trim());
    final score = salary == null || years == null || years < 1
        ? null
        : _contractService.playerOfferScore(
            player,
            ContractOffer(salary: salary, years: years),
            offeringTeamStatus: currentStatus,
            currentTeamStatus: isExtension
                ? currentStatus
                : TeamStatus.pretender,
            cfo: team.staff.cfo,
          );

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.market_offerPreview}: ${player.name}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.market_expectedSalary(formatMoney(context, expectedSalary)),
            ),
            Text(l10n.market_expectedLength(expectedLength)),
            Text(
              score == null
                  ? l10n.contract_invalidOffer
                  : l10n.market_score(score.toStringAsFixed(1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _negotiationsSection(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    String teamId,
  ) {
    final negotiations =
        league.negotiations
            .where(
              (item) =>
                  item.teamId == teamId &&
                  item.subjectKind == NegotiationSubjectKind.player,
            )
            .toList()
          ..sort(
            (a, b) => _negotiationClock(b).compareTo(_negotiationClock(a)),
          );
    if (negotiations.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(top: 12),
        child: ListTile(
          leading: const Icon(Icons.handshake_outlined),
          title: Text(l10n.market_negotiations),
          subtitle: Text(l10n.market_noNegotiations),
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.market_negotiations,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...negotiations.map(
              (negotiation) =>
                  _negotiationCard(context, l10n, league, negotiation),
            ),
          ],
        ),
      ),
    );
  }

  Widget _negotiationCard(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    ContractNegotiation negotiation,
  ) {
    final deadlinePassed = _deadlinePassed(league, negotiation);
    final canFinalize =
        negotiation.status == NegotiationStatus.pendingFinalization &&
        !deadlinePassed;
    final canRespond =
        negotiation.status == NegotiationStatus.counter &&
        !deadlinePassed &&
        _marketService.phaseAt(league) == negotiation.phase;
    final offer = negotiation.counterOffer ?? negotiation.lastOffer;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _subjectName(league, negotiation.subjectId),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Chip(label: Text(_statusLabel(l10n, negotiation.status))),
            ],
          ),
          const SizedBox(height: 4),
          Text(_negotiationSubtitle(context, l10n, league, negotiation)),
          if (negotiation.status == NegotiationStatus.waiting &&
              negotiation.waitingUntilWeek != null &&
              negotiation.waitingUntilDay != null) ...[
            const SizedBox(height: 4),
            Text(
              '${l10n.contract_waiting} · ${l10n.market_deadline(negotiation.waitingUntilDay!, negotiation.waitingUntilHour ?? 0, negotiation.waitingUntilWeek!)}',
            ),
          ],
          if (deadlinePassed && !negotiation.isTerminal) ...[
            const SizedBox(height: 4),
            Text(
              l10n.market_statusExpired,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (canFinalize) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: () => _finalize(l10n, negotiation.id),
                child: Text(l10n.contract_finalize),
              ),
            ),
          ],
          if (canRespond) ...[
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed: () =>
                      _respondToCounter(l10n, negotiation, accept: false),
                  child: Text(l10n.inbox_actionReject),
                ),
                OutlinedButton(
                  onPressed: () => _editCounter(l10n, negotiation),
                  child: Text(l10n.contract_counterEdit),
                ),
                FilledButton.tonal(
                  onPressed: () => _respondToCounter(
                    l10n,
                    negotiation,
                    accept: true,
                    offer: ContractOffer(
                      salary: offer.salary,
                      years: offer.years,
                      exception: offer.exception,
                      rookiePickSlot: offer.rookiePickSlot,
                    ),
                  ),
                  child: Text(l10n.inbox_actionAccept),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, NegotiationStatus status) {
    return switch (status) {
      NegotiationStatus.active => l10n.market_statusActive,
      NegotiationStatus.waiting => l10n.contract_waiting,
      NegotiationStatus.pendingFinalization =>
        l10n.contract_pendingFinalization,
      NegotiationStatus.counter => l10n.market_statusCounter,
      NegotiationStatus.rejected => l10n.contract_rejected,
      NegotiationStatus.hardRejected => l10n.market_statusHardRejected,
      NegotiationStatus.completed => l10n.market_statusCompleted,
      NegotiationStatus.cancelled => l10n.market_statusCancelled,
    };
  }

  String _subjectName(LeagueState league, String id) {
    for (final player in league.freeAgents) {
      if (player.id == id) return player.name;
    }
    for (final player in league.playerTeam?.roster ?? const <Player>[]) {
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
    final player = _playerById(league, negotiation.subjectId);
    final expectedSalary = player == null
        ? null
        : _contractService.expectedSalary(
            player,
            currentTeamStatus:
                negotiation.phase == NegotiationPhase.contractExtension
                ? _teamStatus(league, negotiation.teamId)
                : TeamStatus.pretender,
          );
    final expectedLength = player == null
        ? null
        : _contractService.expectedLength(
            player,
            currentTeamStatus:
                negotiation.phase == NegotiationPhase.contractExtension
                ? _teamStatus(league, negotiation.teamId)
                : TeamStatus.pretender,
          );
    final details = <String>[
      l10n.market_round(negotiation.round),
      l10n.market_score(negotiation.offerScore.toStringAsFixed(1)),
      l10n.market_deadline(
        negotiation.expiryDay,
        negotiation.expiryHour,
        negotiation.expiryWeek,
      ),
      if (expectedSalary != null)
        l10n.market_expectedSalary(formatMoney(context, expectedSalary)),
      if (expectedLength != null) l10n.market_expectedLength(expectedLength),
      '${l10n.market_currentOffer}: ${formatMoney(context, negotiation.lastOffer.salary)} × ${negotiation.lastOffer.years}',
    ];
    return details.join(' · ');
  }

  Future<void> _advanceHour(AppLocalizations l10n) async {
    if (_isAdvancingHour) return;
    setState(() => _isAdvancingHour = true);
    final result = await ref
        .read(gameControllerProvider.notifier)
        .advanceOneHour();
    if (!mounted) return;
    setState(() {
      _isAdvancingHour = false;
      _status = result == null
          ? l10n.market_noWindow
          : l10n.market_hourAdvanced;
    });
  }

  Future<void> _offer(
    AppLocalizations l10n,
    LeagueState league,
    Team team,
  ) async {
    final id = _selectedId;
    if (id == null || _target == _Target.none) {
      setState(() => _status = l10n.contract_selectPlayer);
      return;
    }
    if (!_canSubmit(league, team)) {
      setState(() => _status = l10n.market_noWindow);
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
    if (!mounted) return;
    setState(() => _status = _statusForReaction(l10n, reaction, id));
  }

  Future<void> _offerFreeAgent(
    AppLocalizations l10n,
    String id,
    ContractOffer offer,
  ) async {
    final reaction = await ref
        .read(gameControllerProvider.notifier)
        .offerFreeAgent(id, offer);
    if (!mounted) return;
    setState(() => _status = _statusForReaction(l10n, reaction, id));
  }

  String _statusForReaction(
    AppLocalizations l10n,
    ContractReaction reaction,
    String subjectId,
  ) {
    return switch (reaction) {
      ContractReaction.accept => l10n.contract_pendingFinalization,
      ContractReaction.hardReject ||
      ContractReaction.reject => l10n.contract_rejected,
      ContractReaction.waiting => l10n.contract_waiting,
      ContractReaction.counter => _counterStatus(l10n, subjectId),
    };
  }

  String _counterStatus(AppLocalizations l10n, String subjectId) {
    final league = ref.read(activeLeagueProvider);
    ContractNegotiation? negotiation;
    for (final item in league?.negotiations ?? const <ContractNegotiation>[]) {
      if (item.subjectId == subjectId &&
          item.subjectKind == NegotiationSubjectKind.player &&
          item.teamId == league?.playerTeamId &&
          item.status == NegotiationStatus.counter) {
        negotiation = item;
      }
    }
    final counter = negotiation?.counterOffer ?? negotiation?.lastOffer;
    if (counter == null) return l10n.contract_faCounter;
    return l10n.contract_counter(
      formatMoney(context, counter.salary),
      counter.years,
    );
  }

  Future<void> _finalize(AppLocalizations l10n, String negotiationId) async {
    final ok = await ref
        .read(gameControllerProvider.notifier)
        .finalizeContractNegotiation(negotiationId);
    if (!mounted) return;
    setState(
      () => _status = ok
          ? l10n.contract_accepted
          : l10n.contract_finalizationFailed,
    );
  }

  Future<void> _respondToCounter(
    AppLocalizations l10n,
    ContractNegotiation negotiation, {
    required bool accept,
    ContractOffer? offer,
  }) async {
    final ok = await ref
        .read(gameControllerProvider.notifier)
        .respondToContractCounter(negotiation.id, accept: accept, offer: offer);
    if (!mounted) return;
    setState(
      () => _status = ok
          ? (accept ? l10n.contract_accepted : l10n.contract_rejected)
          : l10n.contract_finalizationFailed,
    );
  }

  Future<void> _editCounter(
    AppLocalizations l10n,
    ContractNegotiation negotiation,
  ) async {
    final current = negotiation.counterOffer ?? negotiation.lastOffer;
    final offer = await _counterDialog(l10n, current);
    if (offer == null || !mounted) return;
    await _respondToCounter(l10n, negotiation, accept: true, offer: offer);
  }

  Future<ContractOffer?> _counterDialog(
    AppLocalizations l10n,
    NegotiationOffer current,
  ) async {
    final salaryController = TextEditingController(
      text: current.salary.toString(),
    );
    final yearsController = TextEditingController(
      text: current.years.toString(),
    );
    try {
      return await showDialog<ContractOffer>(
        context: context,
        builder: (dialogContext) {
          String? error;
          return StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: Text(l10n.contract_editCounterTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: salaryController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.contract_offerSalary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: yearsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.contract_offerYears,
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
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
                      setDialogState(() => error = l10n.contract_invalidOffer);
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
            ),
          );
        },
      );
    } finally {
      salaryController.dispose();
      yearsController.dispose();
    }
  }

  void _selectPlayer(
    LeagueState league,
    Team team,
    Player player,
    _Target target,
  ) {
    final isExtension = target == _Target.ownExpiring;
    setState(() {
      _target = target;
      _selectedId = player.id;
      _salaryCtrl.text = _expectedSalary(
        league,
        team,
        player,
        isExtension: isExtension,
      ).toString();
      _yearsCtrl.text = _contractService
          .expectedLength(
            player,
            currentTeamStatus: isExtension
                ? _teamStatus(league, team.id)
                : TeamStatus.pretender,
          )
          .toString();
    });
  }

  Player? _selectedPlayer(LeagueState league, Team team) {
    if (_selectedId == null) return null;
    final pool = _target == _Target.ownExpiring
        ? team.roster
        : _target == _Target.freeAgent
        ? league.freeAgents
        : const <Player>[];
    for (final player in pool) {
      if (player.id == _selectedId) return player;
    }
    return null;
  }

  Player? _playerById(LeagueState league, String id) {
    for (final player in league.freeAgents) {
      if (player.id == id) return player;
    }
    for (final player in league.playerTeam?.roster ?? const <Player>[]) {
      if (player.id == id) return player;
    }
    return null;
  }

  TeamStatus _teamStatus(LeagueState league, String teamId) =>
      league.strengthTable?.entryFor(teamId)?.teamStatus ??
      TeamStatus.pretender;

  int _expectedSalary(
    LeagueState league,
    Team team,
    Player player, {
    required bool isExtension,
  }) => _contractService.expectedSalary(
    player,
    currentTeamStatus: isExtension
        ? _teamStatus(league, team.id)
        : TeamStatus.pretender,
  );

  bool _canSubmit(LeagueState league, Team team) {
    final phase = _marketService.phaseAt(league);
    if (phase == null || _target == _Target.none) return false;
    if (_target == _Target.ownExpiring &&
        phase != NegotiationPhase.contractExtension) {
      return false;
    }
    if (_target == _Target.freeAgent &&
        phase != NegotiationPhase.freeAgencyPhaseI &&
        phase != NegotiationPhase.freeAgencyPhaseII) {
      return false;
    }
    if (_target == _Target.freeAgent &&
        team.roster.length >= BalanceConfig.defaults.roster.maxSize) {
      return false;
    }
    if (phase == NegotiationPhase.freeAgencyPhaseI &&
        league.hourlyPlayerOfferUsed) {
      return false;
    }
    return !_isAdvancingHour;
  }

  int _negotiationClock(ContractNegotiation negotiation) =>
      (((negotiation.seasonYear * 60 + negotiation.week) * 7 +
              negotiation.day) *
          BalanceConfig.defaults.contracts.hoursPerDay) +
      negotiation.hour;

  bool _deadlinePassed(LeagueState league, ContractNegotiation negotiation) {
    final current =
        (((league.currentSeason.year * 60 + league.currentWeek) * 7 +
                league.currentDay) *
            BalanceConfig.defaults.contracts.hoursPerDay) +
        (league.currentHour ?? 0);
    final deadline =
        (((negotiation.expirySeasonYear * 60 + negotiation.expiryWeek) * 7 +
                negotiation.expiryDay) *
            BalanceConfig.defaults.contracts.hoursPerDay) +
        negotiation.expiryHour;
    return current > deadline;
  }
}
