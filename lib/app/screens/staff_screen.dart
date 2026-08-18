import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/staff_service.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen> {
  final _staffService = StaffService();
  final _marketService = ContractMarketService();
  final _salaryController = TextEditingController();
  final _yearsController = TextEditingController(text: '3');
  String? _selectedStaffId;
  bool _selectedExtension = false;
  String? _status;
  bool _isAdvancingHour = false;

  @override
  void dispose() {
    _salaryController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    final team = league?.playerTeam;
    if (league == null || team == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.staff_title)),
        body: ScreenBackground(child: Center(child: Text(l10n.staff_noTeam))),
      );
    }

    const balance = BalanceConfig.defaults;
    final cap = balance.staff.salaryCap;
    final used = team.staff.totalSalary;
    final selected = _selectedStaff(league, team);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.staff_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                title: Text(l10n.staff_capLabel),
                trailing: Text(
                  l10n.staff_capUsage(
                    formatMoney(context, used),
                    formatMoney(context, cap),
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: used > cap
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _marketStatusCard(context, l10n, league),
            const SizedBox(height: 12),
            for (final role in StaffRole.values)
              _roleSection(context, l10n, league, team, role),
            if (selected != null) ...[
              const SizedBox(height: 4),
              _offerEditor(context, l10n, league, team, selected),
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
    final label = switch (window) {
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
                Chip(label: Text(label)),
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

  Widget _roleSection(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    Team team,
    StaffRole role,
  ) {
    final member = team.staff.member(role);
    final candidates =
        league.staffFreeAgents.where((staff) => staff.role == role).toList()
          ..sort((a, b) => b.overall.compareTo(a.overall));
    final memberCanExtend =
        member != null && (member.contract?.yearsRemaining ?? 99) <= 1;
    final memberCanFire = member != null && _canFire(member);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              staffRoleLabel(context, role),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            if (member == null)
              Text(l10n.staff_emptySlot)
            else
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(member.name),
                subtitle: Text(
                  l10n.staff_memberSubtitle(
                    member.age,
                    member.overall.toStringAsFixed(1),
                    formatMoney(context, member.contract?.salary ?? 0),
                  ),
                ),
                onTap: () => _selectStaff(league, team, member, true),
                trailing: Wrap(
                  spacing: 4,
                  children: [
                    if (memberCanExtend)
                      TextButton(
                        onPressed: () => _submitDefaultOffer(
                          l10n,
                          league,
                          team,
                          member,
                          true,
                        ),
                        child: Text(l10n.contract_submitOffer),
                      ),
                    if (memberCanFire)
                      TextButton(
                        onPressed: () => _fire(l10n, role),
                        child: Text(l10n.staff_fire),
                      )
                    else
                      Tooltip(
                        message: l10n.staff_fireDisabled,
                        child: Text(
                          l10n.staff_fire,
                          style: TextStyle(
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (member == null) ...[
              const SizedBox(height: 6),
              Text(
                l10n.staff_candidatesHeader,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              if (candidates.isEmpty)
                Text(l10n.staff_noCandidates)
              else
                ...candidates.map((candidate) {
                  final offer = _defaultOffer(league, candidate);
                  final canHire = _canSubmitStaffOffer(
                    league,
                    team,
                    candidate,
                    isExtension: false,
                  );
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(candidate.name),
                    subtitle: Text(
                      l10n.staff_memberSubtitle(
                        candidate.age,
                        candidate.overall.toStringAsFixed(1),
                        formatMoney(context, offer.salary),
                      ),
                    ),
                    onTap: () => _selectStaff(league, team, candidate, false),
                    trailing: FilledButton.tonal(
                      onPressed: canHire
                          ? () => _submitStaffOffer(
                              l10n,
                              league,
                              team,
                              candidate,
                              false,
                              offer,
                            )
                          : null,
                      child: Text(l10n.staff_hire),
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }

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
    final canSubmit = _canSubmitStaffOffer(
      league,
      team,
      member,
      isExtension: _selectedExtension,
    );
    final attributes = _attributes(l10n, member);

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
            ...attributes.map(
              (attribute) => Text(
                '${attribute.key}: ${attribute.value.toStringAsFixed(1)}',
              ),
            ),
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
            if (!canSubmit) ...[
              const SizedBox(height: 6),
              Text(l10n.market_noWindow),
            ],
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
                  item.subjectKind == NegotiationSubjectKind.staff,
            )
            .toList()
          ..sort(
            (a, b) => _negotiationClock(b).compareTo(_negotiationClock(a)),
          );
    if (negotiations.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(top: 4),
        child: ListTile(
          leading: const Icon(Icons.handshake_outlined),
          title: Text(l10n.staff_negotiations),
          subtitle: Text(l10n.staff_noNegotiations),
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.only(top: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.staff_negotiations,
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
                    offer: StaffOffer(salary: offer.salary, years: offer.years),
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

  String _negotiationSubtitle(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    ContractNegotiation negotiation,
  ) {
    final member = _staffById(league, negotiation.subjectId);
    final status = _teamStatus(league, negotiation.teamId);
    final expectedSalary = member == null
        ? null
        : _staffService.expectedSalary(member, currentTeamStatus: status);
    final expectedLength = member == null
        ? null
        : _staffService.expectedLength(member, currentTeamStatus: status);
    final details = <String>[
      l10n.market_round(negotiation.round),
      l10n.market_score(negotiation.offerScore.toStringAsFixed(1)),
      l10n.market_deadline(
        negotiation.expiryDay,
        negotiation.expiryHour,
        negotiation.expiryWeek,
      ),
      if (expectedSalary != null)
        l10n.staff_expectedSalary(formatMoney(context, expectedSalary)),
      if (expectedLength != null) l10n.staff_expectedLength(expectedLength),
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

  Future<void> _submitSelectedOffer(
    AppLocalizations l10n,
    LeagueState league,
    Team team,
    StaffMember member,
  ) async {
    final salary = int.tryParse(_salaryController.text.trim());
    final years = int.tryParse(_yearsController.text.trim());
    if (salary == null || years == null || years < 1 || years > 4) {
      setState(() => _status = l10n.contract_invalidOffer);
      return;
    }
    await _submitStaffOffer(
      l10n,
      league,
      team,
      member,
      _selectedExtension,
      StaffOffer(salary: salary, years: years),
    );
  }

  Future<void> _submitDefaultOffer(
    AppLocalizations l10n,
    LeagueState league,
    Team team,
    StaffMember member,
    bool isExtension,
  ) async {
    await _submitStaffOffer(
      l10n,
      league,
      team,
      member,
      isExtension,
      _defaultOffer(league, member),
    );
  }

  Future<void> _submitStaffOffer(
    AppLocalizations l10n,
    LeagueState league,
    Team team,
    StaffMember member,
    bool isExtension,
    StaffOffer offer,
  ) async {
    if (!_canSubmitStaffOffer(league, team, member, isExtension: isExtension)) {
      if (mounted) setState(() => _status = l10n.market_noWindow);
      return;
    }
    final replacingSalary = isExtension
        ? team.staff.member(member.role)?.contract?.salary ?? 0
        : 0;
    final reason = _staffService.hireValidationReason(
      team,
      offer.salary,
      replacingSalary: replacingSalary,
    );
    if (reason != null) {
      if (mounted) setState(() => _status = l10n.staff_hireRejected);
      return;
    }
    final reaction = await ref
        .read(gameControllerProvider.notifier)
        .offerStaff(member, offer);
    if (!mounted) return;
    setState(() {
      _status = switch (reaction) {
        StaffReaction.accept => l10n.staff_hireAccepted(member.name),
        StaffReaction.hardReject ||
        StaffReaction.reject => l10n.staff_hireRejected,
        StaffReaction.waiting => l10n.contract_waiting,
        StaffReaction.counter => _counterStatus(l10n, member.id),
      };
    });
  }

  String _counterStatus(AppLocalizations l10n, String subjectId) {
    final league = ref.read(activeLeagueProvider);
    ContractNegotiation? negotiation;
    for (final item in league?.negotiations ?? const <ContractNegotiation>[]) {
      if (item.subjectId == subjectId &&
          item.subjectKind == NegotiationSubjectKind.staff &&
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
    StaffOffer? offer,
  }) async {
    final ok = await ref
        .read(gameControllerProvider.notifier)
        .respondToStaffCounter(negotiation.id, accept: accept, offer: offer);
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

  Future<StaffOffer?> _counterDialog(
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
      return await showDialog<StaffOffer>(
        context: context,
        builder: (dialogContext) {
          String? error;
          return StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: Text(l10n.staff_editCounterTitle),
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
                    if (salary == null ||
                        years == null ||
                        years < 1 ||
                        years > 4) {
                      setDialogState(() => error = l10n.contract_invalidOffer);
                      return;
                    }
                    Navigator.of(
                      dialogContext,
                    ).pop(StaffOffer(salary: salary, years: years));
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

  void _selectStaff(
    LeagueState league,
    Team team,
    StaffMember member,
    bool isExtension,
  ) {
    final status = _teamStatus(league, team.id);
    setState(() {
      _selectedStaffId = member.id;
      _selectedExtension = isExtension;
      _salaryController.text = _staffService
          .expectedSalary(member, currentTeamStatus: status)
          .toString();
      _yearsController.text = _staffService
          .expectedLength(member, currentTeamStatus: status)
          .toString();
      _status = null;
    });
  }

  StaffMember? _selectedStaff(LeagueState league, Team team) {
    if (_selectedStaffId == null) return null;
    for (final member in team.staff.members) {
      if (member.id == _selectedStaffId) return member;
    }
    for (final member in league.staffFreeAgents) {
      if (member.id == _selectedStaffId) return member;
    }
    return null;
  }

  StaffMember? _staffById(LeagueState league, String id) {
    for (final member in league.staffFreeAgents) {
      if (member.id == id) return member;
    }
    for (final team in league.teams) {
      final member = team.staff.members.cast<StaffMember?>().firstWhere(
        (item) => item?.id == id,
        orElse: () => null,
      );
      if (member != null) return member;
    }
    return null;
  }

  TeamStatus _teamStatus(LeagueState league, String teamId) =>
      league.strengthTable?.entryFor(teamId)?.teamStatus ??
      TeamStatus.pretender;

  StaffOffer _defaultOffer(LeagueState league, StaffMember member) {
    final status = _teamStatus(league, league.playerTeamId ?? '');
    return StaffOffer(
      salary: _staffService.expectedSalary(member, currentTeamStatus: status),
      years: _staffService.expectedLength(member, currentTeamStatus: status),
    );
  }

  bool _canSubmitStaffOffer(
    LeagueState league,
    Team team,
    StaffMember member, {
    required bool isExtension,
  }) {
    final phase = _marketService.phaseAt(league);
    if (isExtension) {
      return phase == NegotiationPhase.contractExtension &&
          team.staff.member(member.role)?.id == member.id &&
          (member.contract?.yearsRemaining ?? 99) <= 1;
    }
    if (phase != NegotiationPhase.freeAgencyPhaseI &&
        phase != NegotiationPhase.freeAgencyPhaseII) {
      return false;
    }
    if (team.staff.member(member.role) != null) return false;
    if (!league.staffFreeAgents.any((item) => item.id == member.id)) {
      return false;
    }
    return phase != NegotiationPhase.freeAgencyPhaseI ||
        !league.hourlyStaffOfferUsed;
  }

  bool _canFire(StaffMember member) =>
      member.contract == null || member.contract!.yearsRemaining <= 0;

  Future<void> _fire(AppLocalizations l10n, StaffRole role) async {
    await ref.read(gameControllerProvider.notifier).fireStaff(role);
    if (!mounted) return;
    setState(() => _status = l10n.staff_fire);
  }

  List<MapEntry<String, double>> _attributes(
    AppLocalizations l10n,
    StaffMember member,
  ) {
    final attributes = member.attributes;
    return switch (member.role) {
      StaffRole.headCoach => [
        MapEntry(l10n.staff_attrTactics, attributes.tactics),
        MapEntry(l10n.staff_attrMotivation, attributes.motivation),
        MapEntry(l10n.staff_attrDevelopment, attributes.development),
      ],
      StaffRole.youthCoach => [
        MapEntry(l10n.staff_attrDevelopment, attributes.development),
        MapEntry(l10n.staff_attrMentoring, attributes.mentoring),
      ],
      StaffRole.scout => [
        MapEntry(l10n.staff_attrCoverage, attributes.coverage),
        MapEntry(l10n.staff_attrEvaluation, attributes.evaluation),
      ],
      StaffRole.physio => [
        MapEntry(l10n.staff_attrRehabilitation, attributes.rehabilitation),
        MapEntry(l10n.staff_attrRegeneration, attributes.regenaration),
      ],
      StaffRole.doctor => [
        MapEntry(l10n.staff_attrPrevention, attributes.prevention),
        MapEntry(l10n.staff_attrCare, attributes.care),
      ],
      StaffRole.cfo => [
        MapEntry(l10n.staff_attrNegotiation, attributes.negotiation),
      ],
    };
  }

  String _subjectName(LeagueState league, String id) =>
      _staffById(league, id)?.name ?? id;

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
