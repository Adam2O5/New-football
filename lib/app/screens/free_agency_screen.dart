import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/league_state.dart';
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
    final selected = league.freeAgents.cast<Player?>().firstWhere(
      (player) => player?.id == _selectedId,
      orElse: () => null,
    );
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
                (player) => _playerTile(context, l10n, player, selected?.id),
              ),
            _staffMarketSection(context, l10n, league, team),
            _rfaSection(context, l10n, league, team),
            _draftedRightsSection(context, l10n, league, team),
            if (selected != null) ...[
              const SizedBox(height: 16),
              _offerCard(context, l10n, selected, league),
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
                title: Text(negotiation.subjectId),
                subtitle: Text(
                  '${formatMoney(context, negotiation.lastOffer.salary)} × ${negotiation.lastOffer.years} · '
                  '${l10n.market_round(negotiation.round)} · '
                  '${l10n.market_score(negotiation.offerScore.toStringAsFixed(1))} · '
                  '${l10n.market_deadline(negotiation.expiryWeek, negotiation.expiryDay, negotiation.expiryHour)}',
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

  Widget _summaryCard(
    BuildContext context,
    AppLocalizations l10n,
    Team team,
    CapSnapshot snapshot,
  ) {
    final full = team.roster.length >= 30;
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
    return Card(
      child: ListTile(
        leading: const Icon(Icons.schedule),
        title: Text(l10n.market_status),
        subtitle: Text(
          '${l10n.market_date(league.currentWeek, league.currentDay)} · $label'
          '${hourly ? '\\n${l10n.market_hour(league.currentHour ?? 1, 10)}' : ''}',
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
      ..sort((a, b) => b.overall.compareTo(a.overall));
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
              ...candidates
                  .take(8)
                  .map(
                    (candidate) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(candidate.name),
                      subtitle: Text(
                        '${candidate.role.name} · ${candidate.overall.toStringAsFixed(1)} · '
                        '${formatMoney(context, _staffService.expectedSalary(candidate))}',
                      ),
                      trailing: FilledButton.tonal(
                        onPressed: team.staff.member(candidate.role) == null
                            ? () => _submitStaffMarketOffer(l10n, candidate)
                            : null,
                        child: Text(l10n.market_staffOffer),
                      ),
                    ),
                  ),
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
    final qualifying = league.rfaQualifyingOffers
        .where((offer) => offer.ownerTeamId == team.id && !offer.declined)
        .toList();
    final sheets = league.rfaOfferSheets
        .where((sheet) => sheet.originalTeamId == team.id && !sheet.isTerminal)
        .toList();
    if (qualifying.isEmpty && sheets.isEmpty) return const SizedBox.shrink();
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
            ...qualifying.map((offer) {
              final player = _playerById(league, offer.playerId);
              if (player == null) return const SizedBox.shrink();
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(player.name),
                subtitle: Text(
                  '${formatMoney(context, offer.salary)} × ${offer.years}',
                ),
                trailing: FilledButton.tonal(
                  onPressed: () async {
                    final ok = await ref
                        .read(gameControllerProvider.notifier)
                        .submitQualifyingOffer(player.id);
                    if (mounted) {
                      setState(
                        () => _status = ok
                            ? l10n.market_submitQO
                            : l10n.contract_rejected,
                      );
                    }
                  },
                  child: Text(l10n.market_submitQO),
                ),
              );
            }),
            if (sheets.isNotEmpty) ...[
              const Divider(),
              Text(
                l10n.market_offerSheets,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              ...sheets.map((sheet) {
                final player = _playerById(league, sheet.playerId);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(player?.name ?? sheet.playerId),
                  subtitle: Text(
                    '${formatMoney(context, sheet.salary)} × ${sheet.years} · '
                    '${l10n.market_deadline(sheet.expiryWeek, sheet.expiryDay, sheet.expiryHour)}',
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      TextButton(
                        onPressed: () async {
                          final ok = await ref
                              .read(gameControllerProvider.notifier)
                              .matchRfaOfferSheet(sheet.id);
                          if (mounted) {
                            setState(
                              () => _status = ok
                                  ? l10n.contract_accepted
                                  : l10n.contract_finalizationFailed,
                            );
                          }
                        },
                        child: Text(l10n.market_match),
                      ),
                      TextButton(
                        onPressed: () async {
                          await ref
                              .read(gameControllerProvider.notifier)
                              .declineRfaOfferSheet(sheet.id);
                          if (mounted) {
                            setState(() => _status = l10n.market_release);
                          }
                        },
                        child: Text(l10n.market_release),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
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
    final full = team.roster.length >= 30;
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

  Future<void> _submitStaffMarketOffer(
    AppLocalizations l10n,
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
            formatMoney(context, _contractService.expectedSalary(player)),
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
                .expectedSalary(player)
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
  ) {
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
                formatMoney(context, _contractService.expectedSalary(player)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.freeAgency_offerSalary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _yearsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.freeAgency_offerYears,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _submitOffer(l10n),
                child: Text(l10n.freeAgency_submitOffer),
              ),
            ),
            if (league.rfaQualifyingOffers.any(
              (offer) => offer.playerId == player.id && !offer.declined,
            )) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _submitOfferSheet(l10n),
                  child: Text(l10n.market_offerSheets),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submitOfferSheet(AppLocalizations l10n) async {
    final id = _selectedId;
    final salary = int.tryParse(_salaryController.text.trim());
    final years = int.tryParse(_yearsController.text.trim());
    if (id == null || salary == null || years == null || years < 1) {
      setState(() => _status = l10n.freeAgency_invalidOffer);
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

  Future<void> _submitOffer(AppLocalizations l10n) async {
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

    final reaction = await ref
        .read(gameControllerProvider.notifier)
        .offerFreeAgent(id, ContractOffer(salary: salary, years: years));
    if (!mounted) return;
    setState(() {
      _status = switch (reaction) {
        ContractReaction.accept => l10n.freeAgency_accepted,
        ContractReaction.hardReject => l10n.freeAgency_rejected,
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
}
