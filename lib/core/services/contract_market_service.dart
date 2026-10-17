import 'dart:math';

import 'package:new_football/core/ai/ai_contract_market_service.dart';
import 'package:new_football/core/ai/ai_draft_service.dart';
import 'package:new_football/core/ai/ai_evaluation_models.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/contract_negotiation.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/core/services/negotiation_rules.dart';
import 'package:new_football/core/services/negotiation_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/core/services/staff_service.dart';
import 'package:new_football/core/random/seeds.dart';

part 'contract_market_player_offers.dart';
part 'contract_market_staff_offers.dart';
part 'contract_market_finalization.dart';
part 'contract_market_resolution.dart';
part 'contract_market_rfa.dart';
part 'contract_market_draft_rights.dart';
part 'contract_market_signing.dart';
part 'contract_market_ai_bridge.dart';
part 'contract_market_helpers.dart';

/// The currently available contract market window.
enum ContractMarketWindow {
  closed,
  extensions,
  freeAgencyPhaseI,
  freeAgencyPhaseII,
}

class ContractMarketService
    with
        _ContractMarketShared,
        _ContractMarketPlayerOffers,
        _ContractMarketStaffOffers,
        _ContractMarketFinalization,
        _ContractMarketResolution,
        _ContractMarketRfa,
        _ContractMarketDraftRights,
        _ContractMarketSigning,
        _ContractMarketAiBridge,
        _ContractMarketHelpers {
  ContractMarketService({
    this.balance = BalanceConfig.defaults,
    CalendarService? calendar,
    ContractService? contracts,
    StaffService? staff,
    SalaryCapService? capService,
    NegotiationService? negotiations,
    MessageService? messages,
    AiContractMarketService? aiPolicy,
    AiDraftService? aiDraftService,
  }) : calendar = calendar ?? CalendarService(balance: balance),
       contracts = contracts ?? ContractService(balance: balance),
       staff = staff ?? StaffService(balance: balance),
       capService = capService ?? SalaryCapService(balance: balance),
       negotiations = negotiations ?? NegotiationService(balance: balance),
       messages = messages ?? MessageService(),
       aiPolicy =
           aiPolicy ??
           AiContractMarketService(
             balance: balance,
             contracts: contracts ?? ContractService(balance: balance),
             staff: staff ?? StaffService(balance: balance),
             capService: capService ?? SalaryCapService(balance: balance),
           ),
       aiDraftService = aiDraftService ?? AiDraftService(balance: balance);

  @override
  final BalanceConfig balance;
  @override
  final CalendarService calendar;
  @override
  final ContractService contracts;
  @override
  final StaffService staff;
  final SalaryCapService capService;
  @override
  final NegotiationService negotiations;
  @override
  final MessageService messages;
  @override
  final AiContractMarketService aiPolicy;
  @override
  final AiDraftService aiDraftService;

  @override
  ContractMarketWindow windowAt(LeagueState league) {
    final week = league.currentWeek;
    final day = league.currentDay;
    if (calendar.isContractExtensionWindow(week, day)) {
      return ContractMarketWindow.extensions;
    }
    if (calendar.isFreeAgencyPhaseI(week, day)) {
      return ContractMarketWindow.freeAgencyPhaseI;
    }
    if (calendar.isFreeAgencyPhaseII(week, day)) {
      return ContractMarketWindow.freeAgencyPhaseII;
    }
    return ContractMarketWindow.closed;
  }

  @override
  NegotiationPhase? phaseAt(LeagueState league) {
    return switch (windowAt(league)) {
      ContractMarketWindow.extensions => NegotiationPhase.contractExtension,
      ContractMarketWindow.freeAgencyPhaseI =>
        NegotiationPhase.freeAgencyPhaseI,
      ContractMarketWindow.freeAgencyPhaseII =>
        NegotiationPhase.freeAgencyPhaseII,
      ContractMarketWindow.closed => null,
    };
  }

  @override
  Object? _indexedTeams;
  @override
  Object? _indexedFreeAgents;
  @override
  Object? _indexedDraftedRights;
  @override
  Map<String, Player> _playerIndex = const {};
}

mixin _ContractMarketShared {
  BalanceConfig get balance;

  CalendarService get calendar;

  ContractService get contracts;

  StaffService get staff;

  NegotiationService get negotiations;

  MessageService get messages;

  AiContractMarketService get aiPolicy;

  AiDraftService get aiDraftService;

  ContractMarketWindow windowAt(LeagueState league);

  NegotiationPhase? phaseAt(LeagueState league);

  LeagueState? submitQualifyingOffer({
    required LeagueState league,
    required String ownerTeamId,
    required String playerId,
    int? salary,
    int years = 1,
  });

  LeagueState? matchOfferSheet(
    LeagueState league,
    String sheetId, {
    int saveSeed = 0,
  });

  LeagueState declineOfferSheet(LeagueState league, String sheetId);

  LeagueState _addAiOffers(
    LeagueState league, {
    required NegotiationPhase phase,
    required int hour,
    required int saveSeed,
  });

  LeagueState _resolveAiCounters(
    LeagueState league, {
    required NegotiationPhase phase,
    required int hour,
    required int saveSeed,
  });

  LeagueState? _finalizeAi(
    LeagueState league,
    ContractNegotiation negotiation, {
    required int saveSeed,
  });

  NegotiationOffer? _counterFor(
    LeagueState league,
    ContractNegotiation negotiation,
  );

  double _scoreFor(LeagueState league, ContractNegotiation negotiation);

  LeagueState _upsertAiNegotiation(
    LeagueState league, {
    required ContractNegotiation negotiation,
  });

  LeagueState _expireOfferSheets(LeagueState league, {int? hour});

  bool _isBeforeOrAtDeadline(
    LeagueState league,
    RfaOfferSheet sheet, {
    int? hour,
  });

  LeagueState _removeFreshUndrafted(LeagueState league, String playerId);

  Object? get _indexedTeams;
  set _indexedTeams(Object? value);

  Object? get _indexedFreeAgents;
  set _indexedFreeAgents(Object? value);

  Object? get _indexedDraftedRights;
  set _indexedDraftedRights(Object? value);

  Map<String, Player> get _playerIndex;
  set _playerIndex(Map<String, Player> value);

  Player? _findPlayer(LeagueState league, String playerId);

  StaffMember? _staffMemberForTeam(Team team, String staffId);

  StaffMember? _findStaffForNegotiation(
    LeagueState league,
    ContractNegotiation negotiation,
  );

  String _aiId(
    String kind,
    String subjectId,
    String teamId,
    LeagueState league,
    NegotiationPhase phase,
    int hour,
  );

  int _seed(
    int saveSeed,
    LeagueState league,
    String teamId,
    String subjectId,
    String purpose,
  );

  int _stableSeed(String value);

  int _compareDate(
    int seasonA,
    int weekA,
    int dayA,
    int hourA,
    int seasonB,
    int weekB,
    int dayB,
    int hourB,
  );
}
