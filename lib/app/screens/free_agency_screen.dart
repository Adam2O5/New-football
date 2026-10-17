import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/app/utils/formatters.dart';
import 'package:new_football/app/utils/staff_presentation.dart';
import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/widgets/staff_rating_stars.dart';
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

part 'free_agency_market_sections.dart';
part 'free_agency_rfa_section.dart';
part 'free_agency_player_sections.dart';

enum _FreeAgencySort { overall, name }

class FreeAgencyScreen extends ConsumerStatefulWidget {
  const FreeAgencyScreen({super.key});

  @override
  ConsumerState<FreeAgencyScreen> createState() => _FreeAgencyScreenState();
}

class _FreeAgencyScreenState extends ConsumerState<FreeAgencyScreen>
    with
        _FreeAgencyScreenShared,
        _FreeAgencyMarketSections,
        _FreeAgencyRfaSection,
        _FreeAgencyPlayerSections {
  @override
  final _searchController = TextEditingController();
  @override
  final _salaryController = TextEditingController();
  @override
  final _yearsController = TextEditingController(text: '3');
  @override
  final _contractService = ContractService();
  @override
  final _marketService = ContractMarketService();
  @override
  final _staffService = StaffService();
  @override
  String? _selectedId;
  @override
  Position? _positionFilter;
  @override
  int _minimumOvr = 0;
  @override
  _FreeAgencySort _sort = _FreeAgencySort.overall;
  @override
  String? _status;
  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
  List<Player> _qualifyingCandidates(LeagueState league, Team team) {
    final activeIds = league.rfaQualifyingOffers
        .where((offer) => offer.ownerTeamId == team.id && !offer.declined)
        .map((offer) => offer.playerId)
        .toSet();
    return team.roster
        .where(
          (player) =>
              player.contract.isRookieScale &&
              player.contract.lastSeason == league.currentSeason.year &&
              !activeIds.contains(player.id),
        )
        .toList()
      ..sort((a, b) => b.overall().compareTo(a.overall()));
  }

  @override
  RfaQualifyingOffer? _activeQualifyingOffer(
    LeagueState league,
    String playerId,
  ) {
    for (final offer in league.rfaQualifyingOffers) {
      if (offer.playerId == playerId && !offer.declined) return offer;
    }
    return null;
  }

  @override
  bool _canSubmitQualifyingOffer(LeagueState league) =>
      _marketService.windowAt(league) == ContractMarketWindow.extensions;

  @override
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

  @override
  bool _canSubmitStaffOffer(LeagueState league, Team team) {
    final phase = _marketService.phaseAt(league);
    if (phase != NegotiationPhase.freeAgencyPhaseI &&
        phase != NegotiationPhase.freeAgencyPhaseII) {
      return false;
    }
    return phase != NegotiationPhase.freeAgencyPhaseI ||
        !league.hourlyStaffOfferUsed;
  }

  @override
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

  @override
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

  @override
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

  @override
  String _subjectName(LeagueState league, String id) {
    final player = _playerById(league, id);
    return player?.name ?? id;
  }

  @override
  TeamStatus _teamStatus(LeagueState league, String teamId) =>
      league.strengthTable?.entryFor(teamId)?.teamStatus ??
      TeamStatus.pretender;

  @override
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

  @override
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

mixin _FreeAgencyScreenShared on ConsumerState<FreeAgencyScreen> {
  TextEditingController get _searchController;

  TextEditingController get _salaryController;

  TextEditingController get _yearsController;

  ContractService get _contractService;

  ContractMarketService get _marketService;

  StaffService get _staffService;

  set _selectedId(String? value);

  Position? get _positionFilter;

  set _positionFilter(Position? value);

  int get _minimumOvr;

  set _minimumOvr(int value);

  _FreeAgencySort get _sort;

  set _sort(_FreeAgencySort value);

  set _status(String? value);

  bool get _isAdvancingHour;

  Future<void> _advanceHour(AppLocalizations l10n);

  Future<void> _submitQualifyingOffer(AppLocalizations l10n, Player player);

  Future<void> _declineQualifyingOffer(AppLocalizations l10n, String playerId);

  Future<void> _matchOfferSheet(AppLocalizations l10n, RfaOfferSheet sheet);

  Future<void> _declineOfferSheet(AppLocalizations l10n, RfaOfferSheet sheet);

  Future<void> _submitStaffMarketOffer(
    AppLocalizations l10n,
    LeagueState league,
    StaffMember candidate,
  );

  Future<void> _submitOfferSheet(
    AppLocalizations l10n,
    LeagueState league,
    Team team,
  );

  Future<void> _submitOffer(
    AppLocalizations l10n,
    LeagueState league,
    Team team,
  );

  Future<void> _finalizeNegotiation(
    AppLocalizations l10n,
    String negotiationId,
  );

  List<Player> _qualifyingCandidates(LeagueState league, Team team);

  RfaQualifyingOffer? _activeQualifyingOffer(
    LeagueState league,
    String playerId,
  );

  bool _canSubmitQualifyingOffer(LeagueState league);

  bool _canSubmitPlayerOffer(LeagueState league, Team team);

  bool _canSubmitStaffOffer(LeagueState league, Team team);

  bool _canSubmitOfferSheet(LeagueState league, Team team);

  bool _canActOnOfferSheet(LeagueState league, RfaOfferSheet sheet);

  Player? _playerById(LeagueState league, String id);

  String _subjectName(LeagueState league, String id);

  TeamStatus _teamStatus(LeagueState league, String teamId);

  int _sheetClock(RfaOfferSheet sheet);

  bool _deadlinePassedNegotiation(
    LeagueState league,
    ContractNegotiation negotiation,
  );
}
