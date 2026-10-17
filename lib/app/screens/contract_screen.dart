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

part 'contract_screen_offer_sections.dart';
part 'contract_screen_negotiations.dart';
part 'contract_screen_counter_dialog.dart';

enum _Target { none, ownExpiring, freeAgent }

class ContractScreen extends ConsumerStatefulWidget {
  const ContractScreen({super.key});

  @override
  ConsumerState<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends ConsumerState<ContractScreen>
    with
        _ContractScreenShared,
        _ContractScreenOfferSections,
        _ContractScreenNegotiations,
        _ContractScreenCounterDialog {
  @override
  final _salaryCtrl = TextEditingController();
  @override
  final _yearsCtrl = TextEditingController(text: '3');
  @override
  final _contractService = ContractService();
  @override
  final _marketService = ContractMarketService();
  String? _selectedId;
  @override
  _Target _target = _Target.none;
  String? _status;
  @override
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

  @override
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

  @override
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

  @override
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

  @override
  Future<void> _editCounter(
    AppLocalizations l10n,
    ContractNegotiation negotiation,
  ) async {
    final current = negotiation.counterOffer ?? negotiation.lastOffer;
    final offer = await _counterDialog(l10n, current);
    if (offer == null || !mounted) return;
    await _respondToCounter(l10n, negotiation, accept: true, offer: offer);
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

  @override
  Player? _playerById(LeagueState league, String id) {
    for (final player in league.freeAgents) {
      if (player.id == id) return player;
    }
    for (final player in league.playerTeam?.roster ?? const <Player>[]) {
      if (player.id == id) return player;
    }
    return null;
  }

  @override
  TeamStatus _teamStatus(LeagueState league, String teamId) =>
      league.strengthTable?.entryFor(teamId)?.teamStatus ??
      TeamStatus.pretender;

  @override
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
}

mixin _ContractScreenShared on ConsumerState<ContractScreen> {
  TextEditingController get _salaryCtrl;

  TextEditingController get _yearsCtrl;

  ContractService get _contractService;

  ContractMarketService get _marketService;

  _Target get _target;

  bool get _isAdvancingHour;

  Future<void> _advanceHour(AppLocalizations l10n);

  Future<void> _finalize(AppLocalizations l10n, String negotiationId);

  Future<void> _respondToCounter(
    AppLocalizations l10n,
    ContractNegotiation negotiation, {
    required bool accept,
    ContractOffer? offer,
  });

  Future<void> _editCounter(
    AppLocalizations l10n,
    ContractNegotiation negotiation,
  );

  Player? _playerById(LeagueState league, String id);

  TeamStatus _teamStatus(LeagueState league, String teamId);

  int _expectedSalary(
    LeagueState league,
    Team team,
    Player player, {
    required bool isExtension,
  });
}
