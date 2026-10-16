import 'package:new_football/core/balance/ai_balance.dart';
import 'package:new_football/core/balance/events_balance.dart';
import 'package:new_football/core/balance/matchday_balance.dart';
import 'package:new_football/core/balance/messages_balance.dart';
import 'package:new_football/core/balance/tactics_balance.dart';
import 'package:new_football/core/balance/trade_value_balance.dart';
import 'package:new_football/core/balance/player_balance.dart';
import 'package:new_football/core/balance/finance_balance.dart';
import 'package:new_football/core/balance/staff_balance.dart';
import 'package:new_football/core/balance/draft_awards_balance.dart';
import 'package:new_football/core/balance/development_balance.dart';
import 'package:new_football/core/balance/contract_neg_balance.dart';
import 'package:new_football/core/balance/team_calendar_balance.dart';

export 'package:new_football/core/balance/ai_balance.dart';
export 'package:new_football/core/balance/events_balance.dart';
export 'package:new_football/core/balance/matchday_balance.dart';
export 'package:new_football/core/balance/messages_balance.dart';
export 'package:new_football/core/balance/tactics_balance.dart';
export 'package:new_football/core/balance/trade_value_balance.dart';
export 'package:new_football/core/balance/player_balance.dart';
export 'package:new_football/core/balance/finance_balance.dart';
export 'package:new_football/core/balance/staff_balance.dart';
export 'package:new_football/core/balance/draft_awards_balance.dart';
export 'package:new_football/core/balance/development_balance.dart';
export 'package:new_football/core/balance/contract_neg_balance.dart';
export 'package:new_football/core/balance/team_calendar_balance.dart';

/// Immutable game balance knobs for the simulation core.
///
/// Source of numeric defaults: project docs under `/docs`.
/// Inject via constructor / DI; override in tests with `copy`-style
/// constructors on nested groups. Not persisted — save state holds
/// runtime values (payroll, cash), not this config.
class BalanceConfig {
  const BalanceConfig({
    this.roster = const RosterBalance(),
    this.matchday = const MatchdayBalance(),
    this.player = const PlayerBalance(),
    this.salaryCap = const SalaryCapBalance(),
    this.cash = const ClubCashBalance(),
    this.staff = const StaffBalance(),
    this.draft = const DraftBalance(),
    this.awards = const AwardsBalance(),
    this.retirement = const RetirementBalance(),
    this.development = const DevelopmentBalance(),
    this.contracts = const ContractNegBalance(),
    this.calendar = const CalendarBalance(),
    this.chemistry = const ChemistryBalance(),
    this.tactics = const TacticsBalance(),
    this.tradeValue = const TradeValueBalance(),
    this.ai = const AiBalance(),
    this.messages = const MessagesBalance(),
    this.events = const EventsBalance(),
  });

  final RosterBalance roster;
  final MatchdayBalance matchday;
  final PlayerBalance player;
  final SalaryCapBalance salaryCap;
  final ClubCashBalance cash;
  final StaffBalance staff;
  final DraftBalance draft;
  final AwardsBalance awards;
  final RetirementBalance retirement;
  final DevelopmentBalance development;
  final ContractNegBalance contracts;
  final CalendarBalance calendar;
  final ChemistryBalance chemistry;
  final TacticsBalance tactics;
  final TradeValueBalance tradeValue;
  final AiBalance ai;
  final MessagesBalance messages;
  final EventsBalance events;

  static const defaults = BalanceConfig();
}
