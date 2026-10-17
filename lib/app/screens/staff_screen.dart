import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/l10n/enum_labels.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/app/utils/staff_presentation.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/widgets/staff_rating_stars.dart';
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

part 'staff_screen_slots.dart';
part 'staff_screen_offer_editor.dart';
part 'staff_screen_negotiations.dart';

class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen>
    with
        _StaffScreenShared,
        _StaffScreenSlots,
        _StaffScreenOfferEditor,
        _StaffScreenNegotiations {
  @override
  final _staffService = StaffService();
  @override
  final _marketService = ContractMarketService();
  @override
  final _salaryController = TextEditingController();
  @override
  final _yearsController = TextEditingController(text: '3');
  String? _selectedStaffId;
  @override
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

  @override
  Future<void> _submitSelectedOffer(
    AppLocalizations l10n,
    LeagueState league,
    Team team,
    StaffMember member,
  ) async {
    final salary = int.tryParse(_salaryController.text.trim());
    final years = int.tryParse(_yearsController.text.trim());
    final validationError = _offerValidationError(
      l10n,
      team,
      member,
      StaffOffer(salary: salary ?? 0, years: years ?? 0),
      isExtension: _selectedExtension,
      salary: salary,
      years: years,
    );
    if (validationError != null) {
      setState(() => _status = validationError);
      return;
    }
    await _submitStaffOffer(
      l10n,
      league,
      team,
      member,
      _selectedExtension,
      StaffOffer(salary: salary!, years: years!),
    );
  }

  @override
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

  @override
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
    final validationError = _offerValidationError(
      l10n,
      team,
      member,
      offer,
      isExtension: isExtension,
    );
    if (validationError != null) {
      if (mounted) setState(() => _status = validationError);
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

  @override
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
    for (final member in league.canonicalStaffFreeAgents) {
      if (member.id == _selectedStaffId) return member;
    }
    return null;
  }

  @override
  StaffMember? _staffById(LeagueState league, String id) {
    for (final member in league.canonicalStaffFreeAgents) {
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

  @override
  TeamStatus _teamStatus(LeagueState league, String teamId) =>
      league.strengthTable?.entryFor(teamId)?.teamStatus ??
      TeamStatus.pretender;

  @override
  StaffOffer _defaultOffer(LeagueState league, StaffMember member) {
    final status = _teamStatus(league, league.playerTeamId ?? '');
    return StaffOffer(
      salary: _staffService.expectedSalary(member, currentTeamStatus: status),
      years: _staffService.expectedLength(member, currentTeamStatus: status),
    );
  }

  @override
  String? _offerValidationError(
    AppLocalizations l10n,
    Team team,
    StaffMember member,
    StaffOffer offer, {
    required bool isExtension,
    int? salary,
    int? years,
  }) {
    final parsedSalary = salary ?? offer.salary;
    final parsedYears = years ?? offer.years;
    if ((salary == null) != (years == null)) {
      return l10n.contract_invalidOffer;
    }
    if (!_staffService.isSalaryInRange(parsedSalary)) {
      return l10n.staff_salaryRange(
        formatMoney(context, _staffService.balance.staff.minSalary),
        formatMoney(context, _staffService.balance.staff.maxSalary),
      );
    }
    if (parsedYears < 1 || parsedYears > 4) return l10n.staff_yearsRange;
    final replacingSalary = isExtension
        ? team.staff.canonicalMember(member.role)?.contract?.salary ?? 0
        : 0;
    if (!_staffService.canHire(
      team,
      parsedSalary,
      replacingSalary: replacingSalary,
    )) {
      return l10n.staff_capExceeded;
    }
    return null;
  }

  @override
  bool _canSubmitStaffOffer(
    LeagueState league,
    Team team,
    StaffMember member, {
    required bool isExtension,
  }) {
    final phase = _marketService.phaseAt(league);
    if (isExtension) {
      return phase == NegotiationPhase.contractExtension &&
          team.staff.canonicalMember(member.role)?.id == member.id &&
          (member.contract?.yearsRemaining ?? 99) <= 1;
    }
    if (phase != NegotiationPhase.freeAgencyPhaseI &&
        phase != NegotiationPhase.freeAgencyPhaseII) {
      return false;
    }
    if (team.staff.canonicalMember(member.role) != null) return false;
    if (!league.canonicalStaffFreeAgents.any((item) => item.id == member.id)) {
      return false;
    }
    return phase != NegotiationPhase.freeAgencyPhaseI ||
        !league.hourlyStaffOfferUsed;
  }

  @override
  bool _canFire(StaffMember member) =>
      member.contract == null || member.contract!.yearsRemaining <= 0;

  @override
  Future<void> _fire(AppLocalizations l10n, StaffRole role) async {
    final league = ref.read(activeLeagueProvider);
    final member = league?.playerTeam?.staff.canonicalMember(role);
    if (member == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.staff_fireConfirmTitle),
        content: Text(l10n.staff_fireConfirm(member.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.staff_fire),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final removed = await ref
        .read(gameControllerProvider.notifier)
        .fireStaff(role);
    if (!mounted) return;
    setState(
      () => _status = removed
          ? l10n.staff_fireSuccess(member.name)
          : l10n.staff_fireFailed,
    );
  }
}

mixin _StaffScreenShared on ConsumerState<StaffScreen> {
  StaffService get _staffService;

  ContractMarketService get _marketService;

  TextEditingController get _salaryController;

  TextEditingController get _yearsController;

  bool get _selectedExtension;

  Future<void> _submitSelectedOffer(
    AppLocalizations l10n,
    LeagueState league,
    Team team,
    StaffMember member,
  );

  Future<void> _submitDefaultOffer(
    AppLocalizations l10n,
    LeagueState league,
    Team team,
    StaffMember member,
    bool isExtension,
  );

  Future<void> _submitStaffOffer(
    AppLocalizations l10n,
    LeagueState league,
    Team team,
    StaffMember member,
    bool isExtension,
    StaffOffer offer,
  );

  Future<void> _finalize(AppLocalizations l10n, String negotiationId);

  Future<void> _respondToCounter(
    AppLocalizations l10n,
    ContractNegotiation negotiation, {
    required bool accept,
    StaffOffer? offer,
  });

  Future<void> _editCounter(
    AppLocalizations l10n,
    ContractNegotiation negotiation,
  );

  void _selectStaff(
    LeagueState league,
    Team team,
    StaffMember member,
    bool isExtension,
  );

  StaffMember? _staffById(LeagueState league, String id);

  TeamStatus _teamStatus(LeagueState league, String teamId);

  StaffOffer _defaultOffer(LeagueState league, StaffMember member);

  String? _offerValidationError(
    AppLocalizations l10n,
    Team team,
    StaffMember member,
    StaffOffer offer, {
    required bool isExtension,
    int? salary,
    int? years,
  });

  bool _canSubmitStaffOffer(
    LeagueState league,
    Team team,
    StaffMember member, {
    required bool isExtension,
  });

  bool _canFire(StaffMember member);

  Future<void> _fire(AppLocalizations l10n, StaffRole role);

  List<StaffAttributeView> _attributes(StaffSlotView view);

  String _attributeLabel(AppLocalizations l10n, StaffAttributeKey key);
}
