import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/core/services/staff_service.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

enum _FreeAgencySort { overall, name }

class FreeAgencyScreen extends ConsumerStatefulWidget {
  const FreeAgencyScreen({super.key});

  @override
  ConsumerState<FreeAgencyScreen> createState() => _FreeAgencyScreenState();
}

class _FreeAgencyScreenState extends ConsumerState<FreeAgencyScreen> {
  final _searchController = TextEditingController();
  final _salaryController = TextEditingController();
  final _yearsController = TextEditingController(text: '3');
  final _contractService = ContractService();
  final _marketService = ContractMarketService();
  final _staffService = StaffService();
  String? _selectedId;
  Position? _positionFilter;
  int _minimumOvr = 0;
  _FreeAgencySort _sort = _FreeAgencySort.overall;
  String? _status;
  bool _isAdvancingHour = false;

  @override
  void dispose() {
    _searchController.dispose();
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
        appBar: _appBar(context, l10n),
        body: ScreenBackground(
          child: Center(child: Text(l10n.freeAgency_noTeam)),
        ),
      );
    }

    final freeAgents = _filteredFreeAgents(league.freeAgents);
    final selected = _playerByIdFromList(league.freeAgents, _selectedId);
    final capSnapshot = const SalaryCapService().snapshot(team);

    return Scaffold(
      appBar: _appBar(context, l10n),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _summaryCard(context, l10n, team, capSnapshot),
            const SizedBox(height: 12),
            _marketStatusCard(context, l10n, league),
            const SizedBox(height: 12),
            _filters(context, l10n),
            const SizedBox(height: 12),
            Text(
              l10n.freeAgency_poolCount(freeAgents.length),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (freeAgents.isEmpty)
              Card(child: ListTile(title: Text(l10n.freeAgency_empty)))
            else
              ...freeAgents.map(
                (player) => _playerTile(
                  context,
                  l10n,
                  player,
                  selected?.id,
                  league,
                  team,
                ),
              ),
            _staffMarketSection(context, l10n, league, team),
            _rfaSection(context, l10n, league, team),
            _draftedRightsSection(context, l10n, league, team),
            if (selected != null) ...[
              const SizedBox(height: 16),
              _offerCard(context, l10n, selected, league, team),
            ],
            if (_status != null) ...[
              const SizedBox(height: 12),
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.mark_email_read_outlined),
                  title: Text(l10n.freeAgency_status),
                  subtitle: Text(_status!),
                ),
              ),
            ],
            ..._pendingFinalizations(context, l10n, league, team.id),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      title: Text(l10n.freeAgency_title),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
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
    final hourly = window == ContractMarketWindow.freeAgencyPhaseI;
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

  Widget _summaryCard(
    BuildContext context,
    AppLocalizations l10n,
    Team team,
    CapSnapshot snapshot,
  ) {
    final full = team.roster.length >= BalanceConfig.defaults.roster.maxSize;
    return Card(
      color: full
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.freeAgency_title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.freeAgency_capSpace(formatMoney(context, snapshot.capSpace)),
            ),
            Text(l10n.freeAgency_rosterUsage(team.roster.length)),
            if (snapshot.capSpace < 0) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.warning_amber, size: 18),
                  const SizedBox(width: 6),
                  Expanded(child: Text(l10n.finance_capWarning)),
                ],
              ),
            ],
            if (full) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.warning_amber, size: 18),
                  const SizedBox(width: 6),
                  Expanded(child: Text(l10n.freeAgency_rosterFull)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _staffMarketSection(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    Team team,
  ) {
    final candidates = [...league.staffFreeAgents]
      ..sort((a, b) {
        final roleOrder = a.role.index.compareTo(b.role.index);
        return roleOrder == 0 ? b.overall.compareTo(a.overall) : roleOrder;
      });
    final canOffer = _canSubmitStaffOffer(league, team);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.market_staffCandidates,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (candidates.isEmpty)
              Text(l10n.staff_noCandidates)
            else
              ...candidates.map(
                (candidate) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(candidate.name),
                  subtitle: Text(
                    '${candidate.role.name} · ${candidate.overall.toStringAsFixed(1)} · '
                    '${formatMoney(context, _staffService.expectedSalary(candidate))}',
                  ),
                  trailing: FilledButton.tonal(
                    onPressed:
                        team.staff.member(candidate.role) == null && canOffer
                        ? () => _submitStaffMarketOffer(l10n, league, candidate)
                        : null,
                    child: Text(l10n.market_staffOffer),
                  ),
                ),
              ),
            if (!canOffer &&
                _marketService.phaseAt(league) ==
                    NegotiationPhase.freeAgencyPhaseI &&
                league.hourlyStaffOfferUsed)
              Text(l10n.market_noWindow),
          ],
        ),
      ),
    );
  }

  Widget _rfaSection(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    Team team,
  ) {
    final activeOffers = league.rfaQualifyingOffers
        .where((offer) => offer.ownerTeamId == team.id && !offer.declined)
        .toList();
    final candidates = _qualifyingCandidates(league, team);
    final sheets =
        league.rfaOfferSheets
            .where((sheet) => sheet.originalTeamId == team.id)
            .toList()
          ..sort((a, b) => _sheetClock(a).compareTo(_sheetClock(b)));
    if (activeOffers.isEmpty && candidates.isEmpty && sheets.isEmpty) {
      return const SizedBox.shrink();
    }

    final canSubmitQO = _canSubmitQualifyingOffer(league);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.market_qo,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (candidates.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(l10n.market_qoEligible),
              ...candidates.map(
                (player) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(player.name),
                  subtitle: Text(
                    l10n.market_qoMinimum(
                      formatMoney(
                        context,
                        _marketService.qualifyingOfferMinimum(player),
                      ),
                    ),
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: canSubmitQO
                        ? () => _submitQualifyingOffer(l10n, player)
                        : null,
                    child: Text(l10n.market_submitQO),
                  ),
                ),
              ),
            ],
            if (activeOffers.isNotEmpty) ...[
              const Divider(),
              Text(
                l10n.market_qoSubmitted,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              ...activeOffers.map((offer) {
                final player = _playerById(league, offer.playerId);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(player?.name ?? offer.playerId),
                  subtitle: Text(
                    '${formatMoney(context, offer.salary)} × ${offer.years}',
                  ),
                  trailing: TextButton(
                    onPressed: canSubmitQO
                        ? () => _declineQualifyingOffer(l10n, offer.playerId)
                        : null,
                    child: Text(l10n.market_release),
                  ),
                );
              }),
            ],
            if (sheets.isNotEmpty) ...[
              const Divider(),
              Text(
                l10n.market_offerSheets,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              ...sheets.map(
                (sheet) => _offerSheetTile(context, l10n, league, sheet),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _offerSheetTile(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    RfaOfferSheet sheet,
  ) {
    final player = _playerById(league, sheet.playerId);
    final offeringTeam = league.teamById(sheet.offeringTeamId);
    final canAct = _canActOnOfferSheet(league, sheet);
    final status = sheet.matched
        ? l10n.contract_accepted
        : sheet.declined
        ? l10n.market_release
        : null;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(player?.name ?? sheet.playerId),
      subtitle: Text(
        '${formatMoney(context, sheet.salary)} × ${sheet.years} · '
        '${l10n.market_deadline(sheet.expiryDay, sheet.expiryHour, sheet.expiryWeek)}'
        '${offeringTeam == null ? '' : '\n${l10n.market_offerSheetFrom(offeringTeam.name)}'}',
      ),
      trailing: status != null
          ? Chip(label: Text(status))
          : canAct
          ? Wrap(
              spacing: 4,
              children: [
                FilledButton.tonal(
                  onPressed: () => _matchOfferSheet(l10n, sheet),
                  child: Text(l10n.market_match),
                ),
                TextButton(
                  onPressed: () => _declineOfferSheet(l10n, sheet),
                  child: Text(l10n.market_release),
                ),
              ],
            )
          : Text(l10n.market_noWindow),
    );
  }

  Widget _draftedRightsSection(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    Team team,
  ) {
    final rights = league.draftedRights
        .where((right) => right.ownerTeamId == team.id)
        .toList();
    if (rights.isEmpty) return const SizedBox.shrink();
    final full = team.roster.length >= BalanceConfig.defaults.roster.maxSize;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.market_draftedRights,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ...rights.map(
              (right) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(right.player.name),
                subtitle: Text(
                  '${formatMoney(context, right.player.contract.salary)} · pick ${right.pickNumber}',
                ),
                trailing: FilledButton.tonal(
                  onPressed: full
                      ? null
                      : () async {
                          final ok = await ref
                              .read(gameControllerProvider.notifier)
                              .signDraftedRight(right.id);
                          if (mounted) {
                            setState(
                              () => _status = ok
                                  ? l10n.contract_accepted
                                  : l10n.market_rosterFull,
                            );
                          }
                        },
                  child: Text(l10n.market_signRights),
                ),
              ),
            ),
            if (full) Text(l10n.market_rosterFull),
          ],
        ),
      ),
    );
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
              (item.phase == NegotiationPhase.freeAgencyPhaseI ||
                  item.phase == NegotiationPhase.freeAgencyPhaseII) &&
              item.status == NegotiationStatus.pendingFinalization,
        )
        .toList();
    if (pending.isEmpty) return const [];
    return [
      const SizedBox(height: 12),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.pending_actions),
                title: Text(l10n.contract_pendingFinalization),
              ),
              ...pending.map((negotiation) {
                final canFinalize = !_deadlinePassedNegotiation(
                  league,
                  negotiation,
                );
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_subjectName(league, negotiation.subjectId)),
                  subtitle: Text(
                    '${formatMoney(context, negotiation.lastOffer.salary)} × ${negotiation.lastOffer.years} · '
                    '${l10n.market_round(negotiation.round)} · '
                    '${l10n.market_score(negotiation.offerScore.toStringAsFixed(1))} · '
                    '${l10n.market_deadline(negotiation.expiryDay, negotiation.expiryHour, negotiation.expiryWeek)}',
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: canFinalize
                        ? () => _finalizeNegotiation(l10n, negotiation.id)
                        : null,
                    child: Text(l10n.contract_finalize),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    ];
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

  Future<void> _submitQualifyingOffer(
    AppLocalizations l10n,
    Player player,
  ) async {
    final ok = await ref
        .read(gameControllerProvider.notifier)
        .submitQualifyingOffer(player.id);
    if (!mounted) return;
    setState(() {
      _status = ok ? l10n.market_submitQO : l10n.freeAgency_rejected;
    });
  }

  Future<void> _declineQualifyingOffer(
    AppLocalizations l10n,
    String playerId,
  ) async {
    final ok = await ref
        .read(gameControllerProvider.notifier)
        .declineQualifyingOffer(playerId);
    if (!mounted) return;
    setState(() {
      _status = ok ? l10n.market_release : l10n.freeAgency_rejected;
    });
  }

  Future<void> _matchOfferSheet(
    AppLocalizations l10n,
    RfaOfferSheet sheet,
  ) async {
    final ok = await ref
        .read(gameControllerProvider.notifier)
        .matchRfaOfferSheet(sheet.id);
    if (!mounted) return;
    setState(() {
      _status = ok ? l10n.contract_accepted : l10n.contract_finalizationFailed;
    });
  }

  Future<void> _declineOfferSheet(
    AppLocalizations l10n,
    RfaOfferSheet sheet,
  ) async {
    final ok = await ref
        .read(gameControllerProvider.notifier)
        .declineRfaOfferSheet(sheet.id);
    if (!mounted) return;
    setState(() {
      _status = ok ? l10n.market_release : l10n.freeAgency_rejected;
    });
  }

  Future<void> _submitStaffMarketOffer(
    AppLocalizations l10n,
    LeagueState league,
    StaffMember candidate,
  ) async {
    final reaction = await ref
        .read(gameControllerProvider.notifier)
        .offerStaff(
          candidate,
          StaffOffer(
            salary: _staffService.expectedSalary(candidate),
            years: _staffService.expectedLength(candidate),
          ),
        );
    if (!mounted) return;
    setState(() {
      _status = switch (reaction) {
        StaffReaction.accept => l10n.staff_hireAccepted(candidate.name),
        StaffReaction.hardReject ||
        StaffReaction.reject => l10n.staff_hireRejected,
        StaffReaction.waiting => l10n.contract_waiting,
        StaffReaction.counter => l10n.contract_faCounter,
      };
    });
  }

  Widget _filters(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.freeAgency_search,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                DropdownButton<Position?>(
                  value: _positionFilter,
                  hint: Text(l10n.freeAgency_position),
                  items: [
                    DropdownMenuItem<Position?>(
                      value: null,
                      child: Text(l10n.freeAgency_allPositions),
                    ),
                    ...Position.values.map(
                      (position) => DropdownMenuItem<Position?>(
                        value: position,
                        child: Text(position.code),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _positionFilter = value),
                ),
                DropdownButton<int>(
                  value: _minimumOvr,
                  items: [0, 60, 70, 80, 90]
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(
                            value == 0
                                ? '${l10n.freeAgency_minOvr}: ${l10n.freeAgency_any}'
                                : '${l10n.freeAgency_minOvr}: $value',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _minimumOvr = value);
                  },
                ),
                DropdownButton<_FreeAgencySort>(
                  value: _sort,
                  items: [
                    DropdownMenuItem(
                      value: _FreeAgencySort.overall,
                      child: Text(l10n.freeAgency_sortOvr),
                    ),
                    DropdownMenuItem(
                      value: _FreeAgencySort.name,
                      child: Text(l10n.freeAgency_sortName),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _sort = value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Player> _filteredFreeAgents(List<Player> source) {
    final query = _searchController.text.trim().toLowerCase();
    final result = source.where((player) {
      if (query.isNotEmpty && !player.name.toLowerCase().contains(query)) {
        return false;
      }
      if (_positionFilter != null && player.position != _positionFilter) {
        return false;
      }
      if (player.overall().round() < _minimumOvr) return false;
      return true;
    }).toList();

    result.sort((a, b) {
      return switch (_sort) {
        _FreeAgencySort.overall => b.overall().compareTo(a.overall()),
        _FreeAgencySort.name => a.name.compareTo(b.name),
      };
    });
    return result;
  }

  Widget _playerTile(
    BuildContext context,
    AppLocalizations l10n,
    Player player,
    String? selectedId,
    LeagueState league,
    Team team,
  ) {
    final selected = player.id == selectedId;
    return Card(
      color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        leading: CircleAvatar(child: Text(player.position.code)),
        title: Text(player.name),
        subtitle: Text(
          l10n.freeAgency_playerSubtitle(
            player.position.code,
            player.overall().round(),
            formatMoney(
              context,
              _contractService.expectedSalary(
                player,
                currentTeamStatus: TeamStatus.pretender,
              ),
            ),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => context.push('/game/player/${player.id}'),
        ),
        onTap: () {
          setState(() {
            _selectedId = player.id;
            _salaryController.text = _contractService
                .expectedSalary(player, currentTeamStatus: TeamStatus.pretender)
                .toString();
            _yearsController.text = _contractService
                .expectedLength(player, currentTeamStatus: TeamStatus.pretender)
                .toString();
            _status = null;
          });
        },
      ),
    );
  }

  Widget _offerCard(
    BuildContext context,
    AppLocalizations l10n,
    Player player,
    LeagueState league,
    Team team,
  ) {
    final salary = int.tryParse(_salaryController.text.trim());
    final years = int.tryParse(_yearsController.text.trim());
    final score = salary == null || years == null || years < 1
        ? null
        : _contractService.playerOfferScore(
            player,
            ContractOffer(salary: salary, years: years),
            offeringTeamStatus: _teamStatus(league, team.id),
            currentTeamStatus: TeamStatus.pretender,
            cfo: team.staff.cfo,
          );
    final qualifying = _activeQualifyingOffer(league, player.id);
    final isOtherTeamRfa =
        qualifying != null && qualifying.ownerTeamId != team.id;
    final canOffer = _canSubmitPlayerOffer(league, team);
    final canOfferSheet = isOtherTeamRfa && _canSubmitOfferSheet(league, team);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.freeAgency_contractHeader(player.name),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.freeAgency_marketDemand(
                formatMoney(
                  context,
                  _contractService.expectedSalary(
                    player,
                    currentTeamStatus: TeamStatus.pretender,
                  ),
                ),
              ),
            ),
            if (score != null) ...[
              const SizedBox(height: 4),
              Text(l10n.market_score(score.toStringAsFixed(1))),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.freeAgency_offerSalary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _yearsController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.freeAgency_offerYears,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: canOffer
                    ? () => _submitOffer(l10n, league, team)
                    : null,
                child: Text(l10n.freeAgency_submitOffer),
              ),
            ),
            if (canOfferSheet) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _submitOfferSheet(l10n, league, team),
                  child: Text(l10n.market_offerSheets),
                ),
              ),
            ],
            if (!canOffer && _marketService.phaseAt(league) == null) ...[
              const SizedBox(height: 8),
              Text(l10n.market_noWindow),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submitOfferSheet(
    AppLocalizations l10n,
    LeagueState league,
    Team team,
  ) async {
    final id = _selectedId;
    final salary = int.tryParse(_salaryController.text.trim());
    final years = int.tryParse(_yearsController.text.trim());
    if (id == null || salary == null || years == null || years < 1) {
      setState(() => _status = l10n.freeAgency_invalidOffer);
      return;
    }
    if (!_canSubmitOfferSheet(league, team)) {
      setState(() => _status = l10n.market_noWindow);
      return;
    }
    final ok = await ref
        .read(gameControllerProvider.notifier)
        .submitRfaOfferSheet(id, ContractOffer(salary: salary, years: years));
    if (!mounted) return;
    setState(
      () => _status = ok ? l10n.market_offerSheets : l10n.freeAgency_rejected,
    );
  }

  Future<void> _submitOffer(
    AppLocalizations l10n,
    LeagueState league,
    Team team,
  ) async {
    final id = _selectedId;
    if (id == null) {
      setState(() => _status = l10n.freeAgency_selectPlayer);
      return;
    }
    final salary = int.tryParse(_salaryController.text.trim());
    final years = int.tryParse(_yearsController.text.trim());
    if (salary == null ||
        salary <= 0 ||
        years == null ||
        years < 1 ||
        years > 5) {
      setState(() => _status = l10n.freeAgency_invalidOffer);
      return;
    }
    if (!_canSubmitPlayerOffer(league, team)) {
      setState(() => _status = l10n.market_noWindow);
      return;
    }

    final reaction = await ref
        .read(gameControllerProvider.notifier)
        .offerFreeAgent(id, ContractOffer(salary: salary, years: years));
    if (!mounted) return;
    setState(() {
      _status = switch (reaction) {
        ContractReaction.accept => l10n.freeAgency_accepted,
        ContractReaction.hardReject ||
        ContractReaction.reject => l10n.freeAgency_rejected,
        ContractReaction.waiting => l10n.freeAgency_waiting,
        ContractReaction.counter => l10n.freeAgency_counter(
          _salaryController.text,
          years,
        ),
      };
      if (reaction == ContractReaction.accept) _selectedId = null;
    });
  }

  Future<void> _finalizeNegotiation(
    AppLocalizations l10n,
    String negotiationId,
  ) async {
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

  List<Player> _qualifyingCandidates(LeagueState league, Team team) {
    final activeIds = league.rfaQualifyingOffers
        .where((offer) => offer.ownerTeamId == team.id && !offer.declined)
        .map((offer) => offer.playerId)
        .toSet();
    return team.roster
        .where(
          (player) =>
              player.contract.isRookieScale &&
              player.contract.yearsRemaining <= 0 &&
              !activeIds.contains(player.id),
        )
        .toList()
      ..sort((a, b) => b.overall().compareTo(a.overall()));
  }

  RfaQualifyingOffer? _activeQualifyingOffer(
    LeagueState league,
    String playerId,
  ) {
    for (final offer in league.rfaQualifyingOffers) {
      if (offer.playerId == playerId && !offer.declined) return offer;
    }
    return null;
  }

  bool _canSubmitQualifyingOffer(LeagueState league) =>
      _marketService.windowAt(league) == ContractMarketWindow.extensions;

  bool _canSubmitPlayerOffer(LeagueState league, Team team) {
    final phase = _marketService.phaseAt(league);
    if (phase != NegotiationPhase.freeAgencyPhaseI &&
        phase != NegotiationPhase.freeAgencyPhaseII) {
      return false;
    }
    if (team.roster.length >= BalanceConfig.defaults.roster.maxSize) {
      return false;
    }
    return phase != NegotiationPhase.freeAgencyPhaseI ||
        !league.hourlyPlayerOfferUsed;
  }

  bool _canSubmitStaffOffer(LeagueState league, Team team) {
    final phase = _marketService.phaseAt(league);
    if (phase != NegotiationPhase.freeAgencyPhaseI &&
        phase != NegotiationPhase.freeAgencyPhaseII) {
      return false;
    }
    return phase != NegotiationPhase.freeAgencyPhaseI ||
        !league.hourlyStaffOfferUsed;
  }

  bool _canSubmitOfferSheet(LeagueState league, Team team) {
    final phase = _marketService.phaseAt(league);
    if (phase != NegotiationPhase.freeAgencyPhaseI &&
        phase != NegotiationPhase.freeAgencyPhaseII) {
      return false;
    }
    if (team.roster.length >= BalanceConfig.defaults.roster.maxSize) {
      return false;
    }
    final qualifying = _activeQualifyingOffer(league, _selectedId ?? '');
    return qualifying != null && qualifying.ownerTeamId != team.id;
  }

  bool _canActOnOfferSheet(LeagueState league, RfaOfferSheet sheet) =>
      !sheet.isTerminal &&
      _marketService.phaseAt(league) == sheet.phase &&
      !_deadlinePassed(league, sheet);

  Player? _playerByIdFromList(List<Player> players, String? id) {
    if (id == null) return null;
    for (final player in players) {
      if (player.id == id) return player;
    }
    return null;
  }

  Player? _playerById(LeagueState league, String id) {
    for (final player in league.freeAgents) {
      if (player.id == id) return player;
    }
    for (final team in league.teams) {
      for (final player in team.roster) {
        if (player.id == id) return player;
      }
    }
    return null;
  }

  String _subjectName(LeagueState league, String id) {
    final player = _playerById(league, id);
    return player?.name ?? id;
  }

  TeamStatus _teamStatus(LeagueState league, String teamId) =>
      league.strengthTable?.entryFor(teamId)?.teamStatus ??
      TeamStatus.pretender;

  int _sheetClock(RfaOfferSheet sheet) =>
      (((sheet.seasonYear * 60 + sheet.week) * 7 + sheet.day) *
          BalanceConfig.defaults.contracts.hoursPerDay) +
      sheet.hour;

  bool _deadlinePassed(LeagueState league, RfaOfferSheet sheet) {
    final current =
        (((league.currentSeason.year * 60 + league.currentWeek) * 7 +
                league.currentDay) *
            BalanceConfig.defaults.contracts.hoursPerDay) +
        (league.currentHour ?? 0);
    final deadline =
        (((sheet.expirySeasonYear * 60 + sheet.expiryWeek) * 7 +
                sheet.expiryDay) *
            BalanceConfig.defaults.contracts.hoursPerDay) +
        sheet.expiryHour;
    return current > deadline;
  }

  bool _deadlinePassedNegotiation(
    LeagueState league,
    ContractNegotiation negotiation,
  ) {
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
