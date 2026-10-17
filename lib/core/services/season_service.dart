import 'dart:math';
import 'package:new_football/core/services/contract_period_service.dart';

import 'package:uuid/uuid.dart';

import 'package:new_football/core/ai/ai_draft_service.dart';
import 'package:new_football/core/ai/ai_draft_models.dart';
import 'package:new_football/core/ai/ai_matchday_service.dart';
import 'package:new_football/core/ai/ai_roster_management_service.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/simulation/match_engine.dart';
import 'package:new_football/core/simulation/match_context_factory.dart';
import 'package:new_football/core/simulation/match_message_emitter.dart';
import 'package:new_football/core/simulation/pre_match_validator.dart';
import 'package:new_football/core/balance/injury_catalog.dart';
import 'package:new_football/core/models/contract.dart';
import 'package:new_football/core/models/contract_market_models.dart';
import 'package:new_football/core/models/draft_models.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/league_strength.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/season_awards.dart';
import 'package:new_football/core/models/seed_data_generator.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/staff.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/models/team_event_state.dart';
import 'package:new_football/core/random/seeds.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/draft_trade_service.dart';
import 'package:new_football/core/services/contract_market_service.dart';
import 'package:new_football/core/services/negotiation_service.dart';
import 'package:new_football/core/services/lottery_service.dart';
import 'package:new_football/core/services/development_service.dart';
import 'package:new_football/core/services/discipline_service.dart';
import 'package:new_football/core/services/prospect_service.dart';
import 'package:new_football/core/services/match_post_match_service.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/core/services/mock_draft_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/core/services/scouting_service.dart';
import 'package:new_football/core/services/staff_service.dart';
import 'package:new_football/core/services/team_management_service.dart';
import 'package:new_football/core/services/team_event_service.dart';

part 'season_fixtures.dart';
part 'season_play_in.dart';
part 'season_playoffs.dart';
part 'season_post_match.dart';
part 'season_offseason_events.dart';
part 'season_lottery.dart';
part 'season_scouting.dart';
part 'season_draft.dart';
part 'season_rollover.dart';
part 'season_awards.dart';

/// Offseason / playoff pipeline (`docs/offseason.md`, play-in, draft).
class SeasonService
    with
        _SeasonServiceShared,
        _SeasonFixtures,
        _SeasonPlayIn,
        _SeasonPlayoffs,
        _SeasonPostMatch,
        _SeasonOffseasonEvents,
        _SeasonLottery,
        _SeasonScouting,
        _SeasonDraft,
        _SeasonRollover,
        _SeasonAwards {
  SeasonService({
    this.balance = BalanceConfig.defaults,
    SimulationMatchEngine? matchEngine,
    AiMatchdayService? aiMatchdayService,
    AiDraftService? aiDraftService,
    AiRosterManagementService? rosterManagement,
    DraftTradeService? draftTrade,
    ContractMarketService? contractMarket,
    CalendarService? calendar,
    MatchContextFactory? contextFactory,
    MatchMessageEmitter? matchMessageEmitter,
    DevelopmentService? development,
    SalaryCapService? capService,
    StaffService? staffService,
    ScoutingService? scoutingService,
    MessageService? messages,
    TeamEventService? teamEvents,
    MockDraftService? mockDraftService,
    Random? random,
  }) : matchEngine = matchEngine ?? SimulationMatchEngine(balance: balance),
       aiMatchdayService =
           aiMatchdayService ??
           AiMatchdayService(
             balance: balance,
             matchEngine:
                 matchEngine ?? SimulationMatchEngine(balance: balance),
           ),
       aiDraftService = aiDraftService ?? AiDraftService(balance: balance),
       rosterManagement =
           rosterManagement ?? AiRosterManagementService(balance: balance),
       draftTrade = draftTrade ?? DraftTradeService(balance: balance),
       contractMarket =
           contractMarket ?? ContractMarketService(balance: balance),
       calendar = calendar ?? CalendarService(balance: balance),
       contextFactory =
           contextFactory ??
           MatchContextFactory(
             calendar: calendar ?? CalendarService(balance: balance),
           ),
       matchMessageEmitter =
           matchMessageEmitter ??
           MatchMessageEmitter(messages: messages ?? MessageService()),
       development = development ?? DevelopmentService(balance: balance),
       capService = capService ?? SalaryCapService(balance: balance),
       staffService = staffService ?? StaffService(balance: balance),
       scoutingService = scoutingService ?? ScoutingService(balance: balance),
       mockDraftService =
           mockDraftService ?? MockDraftService(balance: balance),
       _messages = messages ?? MessageService(),
       teamEvents =
           teamEvents ?? TeamEventService(balance: balance, messages: messages),
       _random = random ?? Random();

  @override
  final BalanceConfig balance;
  final SimulationMatchEngine matchEngine;
  @override
  final AiMatchdayService aiMatchdayService;
  @override
  final AiDraftService aiDraftService;
  @override
  final AiRosterManagementService rosterManagement;
  @override
  final DraftTradeService draftTrade;
  @override
  final ContractMarketService contractMarket;
  @override
  final CalendarService calendar;
  @override
  final MatchContextFactory contextFactory;
  @override
  final MatchMessageEmitter matchMessageEmitter;
  final DevelopmentService development;
  @override
  final SalaryCapService capService;
  @override
  final StaffService staffService;
  @override
  final ScoutingService scoutingService;
  @override
  final MockDraftService mockDraftService;
  @override
  final MessageService _messages;
  @override
  final TeamEventService teamEvents;
  @override
  final Random _random;
  final _uuid = const Uuid();

  /// Finalizes standings only after every regular-season result is stored.
  LeagueState finalizeRegularSeason(LeagueState league) {
    if (league.currentWeek < balance.calendar.regularSeasonWeeks) return league;
    return generatePostseasonFixtures(league);
  }

  @override
  String _winnerId(MatchResult r, String homeId, String awayId) {
    final persistedWinner = r.winnerTeamId;
    if (persistedWinner == homeId || persistedWinner == awayId) {
      return persistedWinner!;
    }
    if (r.wentToShootout && r.shootoutHomeGoals != r.shootoutAwayGoals) {
      return r.shootoutHomeGoals > r.shootoutAwayGoals ? homeId : awayId;
    }
    if (r.homeGoals == r.awayGoals) {
      final seed = matchSeed(0, 0, 'legacy-tiebreak:$homeId:$awayId');
      return seed.isEven ? homeId : awayId;
    }
    return r.homeGoals > r.awayGoals ? homeId : awayId;
  }

  @override
  PlayoffSeries _series(String high, String low) => PlayoffSeries(
    id: _uuid.v4(),
    higherSeedTeamId: high,
    lowerSeedTeamId: low,
    winsNeeded: 3,
  );

  /// Deterministic non-team-id token standing in for a play-in seed that
  /// isn't decided yet, e.g. `'pending:europe:seed8'`. Used as
  /// [PlayoffSeries.lowerSeedTeamId] until the real team is patched in — the
  /// human-readable label lives separately in [PlayoffSeries]'s /
  /// [ScheduledMatch]'s placeholder-label fields.
  @override
  String _placeholderToken(Conference conference, String seedLabel) =>
      'pending:${conference.name}:$seedLabel';

  @override
  MatchStake _stakeForSeries(PlayoffSeries series) {
    final winsNeededForElimination = series.winsNeeded - 1;
    final eliminationGame =
        winsNeededForElimination > 0 &&
        (series.higherSeedWins >= winsNeededForElimination ||
            series.lowerSeedWins >= winsNeededForElimination);
    return eliminationGame ? MatchStake.playoffElimination : MatchStake.playoff;
  }

  /// Determines the [MatchStake] for a pending postseason fixture, given the
  /// `matchId` reported on `playerMatch` by `advancePlayInForDate` /
  /// `advancePlayoffsForDate`. The interactive matchday flow needs this to
  /// build a correct [MatchContext] but has no access to the private
  /// bracket/series lookup it requires.
  MatchStake stakeForPendingMatch(LeagueState league, String matchId) {
    final parts = matchId.split(':');
    if (parts.isEmpty) return MatchStake.regular;
    if (parts[0] == 'playIn') return MatchStake.playIn;
    if (parts[0] != 'playoff' || parts.length < 2) return MatchStake.regular;
    final seriesId = parts[1];
    for (final b in league.currentSeason.playoffBrackets) {
      if (b.leagueFinal?.id == seriesId) return MatchStake.leagueFinal;
      for (final s in [
        ...b.quarterFinals,
        ...b.semiFinals,
        ...b.conferenceFinal,
      ]) {
        if (s.id == seriesId) return _stakeForSeries(s);
      }
    }
    return MatchStake.playoff;
  }

  @override
  String _teamName(LeagueState s, String id) => s.teamById(id)?.name ?? id;

  @override
  LeagueState _msg(
    LeagueState league,
    MessageType type,
    String title,
    String body, {
    bool urgent = false,
    String? kind,
    Map<String, dynamic> args = const {},
  }) {
    final suffix = kind == null ? '' : '_$kind';
    return _messages.send(
      league,
      type: type,
      priority: urgent ? MessagePriority.urgent : MessagePriority.normal,
      kind: kind,
      titleKey: 'msg_${type.name}${suffix}_title',
      bodyKey: 'msg_${type.name}${suffix}_body',
      args: {'_legacyTitle': title, '_legacyBody': body, ...args},
    );
  }
}

mixin _SeasonServiceShared {
  BalanceConfig get balance;

  AiMatchdayService get aiMatchdayService;

  AiDraftService get aiDraftService;

  AiRosterManagementService get rosterManagement;

  DraftTradeService get draftTrade;

  ContractMarketService get contractMarket;

  CalendarService get calendar;

  MatchContextFactory get contextFactory;

  MatchMessageEmitter get matchMessageEmitter;

  SalaryCapService get capService;

  StaffService get staffService;

  ScoutingService get scoutingService;

  MockDraftService get mockDraftService;

  MessageService get _messages;

  TeamEventService get teamEvents;

  Random get _random;

  LeagueState _maybeRevealPlayInProgress(
    LeagueState league,
    Conference conference,
  );

  LeagueState _sendPlayoffSeedingMessages(
    LeagueState league,
    Iterable<PlayoffBracket> brackets,
  );

  Set<String> _playoffQualifiedTeamIds(LeagueState league);

  ({LeagueState league, MatchResult? result, ScheduledMatch? playerMatch})
  _simPostseason(
    LeagueState league,
    String homeId,
    String awayId, {
    required int saveSeed,
    required String matchId,
    required SeasonPhase phase,
    MatchStake? stake,
    bool simulatePlayerMatch = false,
  });

  String _winnerId(MatchResult r, String homeId, String awayId);

  PlayoffSeries _series(String high, String low);

  String _placeholderToken(Conference conference, String seedLabel);

  List<ScheduledMatch> _eagerFixturesForSeries(
    PlayoffSeries series, {
    required int round,
  });

  LeagueState _recordFixtureResult(
    LeagueState league,
    String matchId,
    MatchResult result,
  );

  LeagueState _scheduleNewlyCreatedRounds(
    LeagueState league,
    PlayoffBracket previous,
    PlayoffBracket next,
    int completedRound,
  );

  MatchStake _stakeForSeries(PlayoffSeries series);

  LeagueState _applyMatchFatigue(LeagueState league, MatchResult result);

  MatchResult _resolvePostseasonTiebreak(
    MatchResult result, {
    required int saveSeed,
    required int seasonYear,
    required String matchId,
  });

  LeagueState _applyPostseasonDiscipline(
    LeagueState league,
    MatchResult result,
    SeasonPhase phase, {
    String? matchId,
  });

  String _teamName(LeagueState s, String id);

  LeagueState _msg(
    LeagueState league,
    MessageType type,
    String title,
    String body, {
    bool urgent = false,
    String? kind,
    Map<String, dynamic> args = const {},
  });
}
