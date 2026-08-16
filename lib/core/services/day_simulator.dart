import 'package:new_football/core/balance/injury_catalog.dart';
import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/engine/match_engine.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/ai/team_ai_service.dart';
import 'package:new_football/core/models/message.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/standing.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/random/seeds.dart';
import 'package:new_football/core/services/calendar_event_registry.dart';
import 'package:new_football/core/services/calendar_service.dart';
import 'package:new_football/core/services/contract_service.dart';
import 'package:new_football/core/services/development_service.dart';
import 'package:new_football/core/services/league_strength_service.dart';
import 'package:new_football/core/services/message_service.dart';
import 'package:new_football/core/services/salary_cap_service.dart';
import 'package:new_football/core/services/schedule_generator.dart';
import 'package:new_football/core/services/scouting_service.dart';

class DaySimulationResult {
  const DaySimulationResult({
    required this.league,
    required this.pauseForUrgent,
    this.playerMatch,
    this.simulatedResults = const [],
    this.eventId,
  });

  final LeagueState league;
  final bool pauseForUrgent;

  /// Non-null when the player's team has a match today — UI should open matchday.
  final ScheduledMatch? playerMatch;
  final List<MatchResult> simulatedResults;

  /// If the simulation stopped because a calendar event needs attention, this
  /// is the event id. `null` when the stop reason is the player's match or
  /// other non-calendar reasons.
  final CalendarEventId? eventId;
}

/// Advances the calendar by one day and resolves non-interactive events.
class DaySimulator {
  DaySimulator({
    this.balance = BalanceConfig.defaults,
    MatchEngine? matchEngine,
    CalendarService? calendar,
    DevelopmentService? development,
    ScoutingService? scouting,
    ContractService? contracts,
    SalaryCapService? capService,
    MessageService? messages,
  }) : matchEngine = matchEngine ?? MatchEngine(balance: balance),
       calendar = calendar ?? CalendarService(balance: balance),
       development = development ?? DevelopmentService(balance: balance),
       scouting = scouting ?? ScoutingService(balance: balance),
       contracts = contracts ?? ContractService(balance: balance),
       capService = capService ?? SalaryCapService(balance: balance),
       messages = messages ?? MessageService();

  final BalanceConfig balance;
  final MatchEngine matchEngine;
  final CalendarService calendar;
  final DevelopmentService development;
  final ScoutingService scouting;
  final ContractService contracts;
  final SalaryCapService capService;
  final MessageService messages;

  DaySimulationResult simulateDay(LeagueState league, {int saveSeed = 0}) {
    final week = league.currentWeek;
    final day = league.currentDay;
    var state = league;
    final results = <MatchResult>[];
    ScheduledMatch? playerMatch;

    final phase = calendar.phaseForWeek(week);
    state = state.copyWith(
      currentSeason: state.currentSeason.copyWith(phase: phase),
    );

    if (phase == SeasonPhase.preseason) {
      final (nextWeek, nextDay) = calendar.advanceDay(week, day);
      return DaySimulationResult(
        league: state.copyWith(
          currentWeek: nextWeek,
          currentDay: nextDay,
          currentSeason: state.currentSeason.copyWith(
            phase: calendar.phaseForWeek(nextWeek),
          ),
        ),
        pauseForUrgent: state.inbox.pendingUrgent.isNotEmpty,
      );
    }

    // Periodic strength table recalculation (`team_management.md`).
    const strengthService = LeagueStrengthService();
    if (strengthService.shouldRecalculate(week, day, state.strengthTable)) {
      final table = strengthService.calculate(
        state,
        previousTable: state.strengthTable,
        week: week,
        day: day,
      );
      state = state.copyWith(strengthTable: table);
    }

    if (calendar.isTradeDeadline(week, day)) {
      state = messages.send(
        state,
        type: MessageType.tradeWindowEvent,
        kind: 'deadline',
        domain: MessageDomain.trades,
        priority: MessagePriority.urgent,
        titleKey: 'msg_tradeWindowEvent_deadline_title',
        bodyKey: 'msg_tradeWindowEvent_deadline_body',
      );
    }

    if (calendar.isRegularSeasonWeek(week)) {
      final slot = calendar.regularSeasonSlotForDay(day);
      if (slot != null && calendar.isActualMatchDay(week, day)) {
        final round = scheduleRoundForWeekSlot(week, slot);
        final outcome = _resolveRound(state, round, saveSeed);
        state = outcome.league;
        results.addAll(outcome.results);
        playerMatch = outcome.playerMatch;
        if (playerMatch != null) {
          return DaySimulationResult(
            league: state,
            pauseForUrgent: true,
            playerMatch: playerMatch,
            simulatedResults: results,
          );
        }
      }
    }

    // Recover stamina lightly each day.
    state = _dailyRecovery(state);

    // Free agency (`docs/contract_signing.md`): AI clubs bid on FA players
    // every day of the FA window; highest legal offerScore wins.
    if (week == balance.calendar.freeAgencyWeek) {
      state = _resolveFreeAgencyDay(state);
    }

    final (nextWeek, nextDay) = calendar.advanceDay(week, day);
    final nextPhase = calendar.phaseForWeek(nextWeek);
    state = state.copyWith(
      currentWeek: nextWeek,
      currentDay: nextDay,
      currentSeason: state.currentSeason.copyWith(phase: nextPhase),
    );

    // Week boundary: Sunday → Monday. Player development ticks weekly
    // (`docs/player_management.md`), not just once per season.
    if (day == 7) {
      state = state.copyWith(
        teams: state.teams.map(development.developTeam).toList(),
      );
      // Continuous scouting tick (`docs/staff_rules.md` §5), while a draft
      // class is known (from lottery through draft week).
      if (state.currentSeason.draftState != null) {
        state = state.copyWith(
          teams: state.teams.map((t) {
            final evalStars = t.staff.scout?.attributes.evaluation ?? 0.0;
            return t.copyWith(
              scouting: scouting.tickKnowledge(t.scouting, evalStars),
            );
          }).toList(),
        );
      }
      state = messages.send(
        state,
        type: MessageType.calendar,
        domain: MessageDomain.system,
        titleKey: 'msg_calendar_newWeek_title',
        bodyKey: 'msg_calendar_newWeek_body',
        args: {'week': nextWeek, 'phase': nextPhase.name},
      );
    }

    final urgent = state.inbox.pendingUrgent.isNotEmpty;
    return DaySimulationResult(
      league: state,
      pauseForUrgent: urgent,
      simulatedResults: results,
    );
  }

  /// Apply a finished player match and advance the day. Match-result
  /// messages are created after the date advances, so they are delivered as
  /// part of the next day's start-of-day package.
  LeagueState applyPlayerMatchResult(
    LeagueState league,
    ScheduledMatch match,
    MatchResult result,
  ) {
    var state = _applyResult(league, match, result);
    final (nextWeek, nextDay) = calendar.advanceDay(
      state.currentWeek,
      state.currentDay,
    );
    state = state.copyWith(
      currentWeek: nextWeek,
      currentDay: nextDay,
      currentHour: calendar.initialHourForDate(nextWeek, nextDay),
      hourlyPlayerOfferUsed: false,
      hourlyStaffOfferUsed: false,
      currentSeason: state.currentSeason.copyWith(
        phase: calendar.phaseForWeek(nextWeek),
      ),
    );
    return _notifyMatchResult(state, result);
  }

  ({LeagueState league, List<MatchResult> results, ScheduledMatch? playerMatch})
  _resolveRound(LeagueState league, int round, int saveSeed) {
    final schedule = league.currentSeason.schedule;
    final fixtures = schedule
        .where((m) => m.round == round && m.result == null)
        .toList();
    if (fixtures.isEmpty) {
      return (league: league, results: <MatchResult>[], playerMatch: null);
    }

    final playerId = league.playerTeamId;
    ScheduledMatch? playerFixture;
    final aiFixtures = <ScheduledMatch>[];
    for (final f in fixtures) {
      if (playerId != null &&
          (f.homeTeamId == playerId || f.awayTeamId == playerId)) {
        playerFixture = f;
      } else {
        aiFixtures.add(f);
      }
    }

    var state = league;
    final results = <MatchResult>[];
    for (final f in aiFixtures) {
      final home = state.teamById(f.homeTeamId);
      final away = state.teamById(f.awayTeamId);
      if (home == null || away == null) continue;
      final result = matchEngine.simulateFull(
        home: home,
        away: away,
        context: const MatchContext(stakes: SeasonPhase.regular),
        rngSeed: matchSeed(saveSeed, state.currentSeason.year, f.id),
      );
      state = _applyResult(state, f, result);
      results.add(result);
      if (playerId != null &&
          (f.homeTeamId == playerId || f.awayTeamId == playerId)) {
        state = _notifyMatchResult(state, result);
      }
    }

    return (league: state, results: results, playerMatch: playerFixture);
  }

  LeagueState _applyResult(
    LeagueState league,
    ScheduledMatch match,
    MatchResult result,
  ) {
    final newSchedule = league.currentSeason.schedule.map((m) {
      if (m.id != match.id) return m;
      return m.copyWith(result: result);
    }).toList();

    var standings = league.currentSeason.standings.map((cs) {
      final updated = cs.standings.map((s) {
        if (s.teamId == result.homeTeamId) {
          return s.applyResult(
            goalsFor: result.homeGoals,
            goalsAgainst: result.awayGoals,
          );
        }
        if (s.teamId == result.awayTeamId) {
          return s.applyResult(
            goalsFor: result.awayGoals,
            goalsAgainst: result.homeGoals,
          );
        }
        return s;
      }).toList();
      return cs.copyWith(standings: updated);
    }).toList();

    // Re-rank conferences.
    standings = standings
        .map((cs) => cs.copyWith(standings: cs.sorted))
        .toList();

    var teams = league.teams;
    final recoveryReturns =
        <({Player player, String injuryId, String teamId})>[];
    teams = teams.map((t) {
      final next = t.id == result.homeTeamId || t.id == result.awayTeamId
          ? _applyFatigue(t, result)
          : _recoverTeam(t);
      for (final oldPlayer in t.roster) {
        final nextPlayer = next.roster.firstWhere(
          (p) => p.id == oldPlayer.id,
          orElse: () => oldPlayer,
        );
        if (oldPlayer.state.injured && !nextPlayer.state.injured) {
          recoveryReturns.add((
            player: oldPlayer,
            injuryId: oldPlayer.state.injury?.id ?? '',
            teamId: t.id,
          ));
        }
      }
      return next;
    }).toList();

    var state = league.copyWith(
      teams: teams,
      currentSeason: league.currentSeason.copyWith(
        schedule: newSchedule,
        standings: standings,
      ),
      currentRound: match.round,
    );

    for (final injury in result.injuries) {
      final team = state.teamById(injury.teamId);
      final player = team?.roster.firstWhere(
        (p) => p.id == injury.playerId,
        orElse: () => throw StateError('Missing injured player'),
      );
      if (team == null || player == null) continue;
      if (state.playerTeamId != team.id) continue;
      final definition = InjuryCatalog.byId(injury.injury.id);
      state = messages.send(
        state,
        type: MessageType.injury,
        domain: MessageDomain.health,
        args: {
          'playerName': player.name,
          'injuryName': definition.name,
          'injuryType': injury.injury.type.name,
          'days': injury.injury.daysTotal,
        },
        payload: {
          'playerId': player.id,
          'teamId': team.id,
          'injuryId': injury.injury.id,
          'injuryType': injury.injury.type.name,
          'playerInStartingXi': injury.playerInStartingXi,
        },
        dedupKey: 'injury:${player.id}:${injury.injury.id}',
      );
      if (injury.potentialLoss) {
        state = messages.send(
          state,
          type: MessageType.potentialLoss,
          domain: MessageDomain.health,
          args: {'playerName': player.name},
          payload: {'playerId': player.id, 'injuryId': injury.injury.id},
          dedupKey: 'potentialLoss:${player.id}:${injury.injury.id}',
        );
      }
    }

    for (final returned in recoveryReturns) {
      if (state.playerTeamId != returned.teamId) continue;
      final definition = InjuryCatalog.byId(returned.injuryId);
      state = messages.send(
        state,
        type: MessageType.injuryReturn,
        domain: MessageDomain.health,
        args: {
          'playerName': returned.player.name,
          'injuryName': definition.name,
        },
        payload: {
          'playerId': returned.player.id,
          'injuryId': returned.injuryId,
        },
      );
    }
    return state;
  }

  Team _applyFatigue(Team team, MatchResult result) {
    final onPitch = {...team.lineupPlayerIds, ...team.benchPlayerIds};
    final injuries = {
      for (final injury in result.injuries.where((i) => i.teamId == team.id))
        injury.playerId: injury,
    };
    final roster = team.roster.map((p) {
      var next = onPitch.contains(p.id)
          ? p.withMatchFatigue(90, balance)
          : p.recoverBetweenMatches(balance);
      final matchInjury = injuries[p.id];
      if (matchInjury != null) {
        next = next.copyWith(
          state: next.state.copyWith(injury: matchInjury.injury),
        );
        if (matchInjury.potentialLoss) {
          next = next
              .copyWith(
                potentialStars: (next.potentialStars - 0.5)
                    .clamp(0.5, 5.0)
                    .toDouble(),
              )
              .recalculatePointValue(balance);
        }
      }
      return next;
    }).toList();
    return team.copyWith(roster: roster);
  }

  Team _recoverTeam(Team team) {
    return team.copyWith(
      roster: team.roster.map((p) => p.recoverBetweenMatches(balance)).toList(),
    );
  }

  LeagueState _resolveFreeAgencyDay(LeagueState league) {
    if (league.freeAgents.isEmpty) return league;
    final ai = TeamAiService(balance: balance);
    var state = league;
    final remaining = <Player>[];

    for (final player in state.freeAgents) {
      ({String teamId, ContractOffer offer, double score})? best;
      for (final team in state.teams) {
        // Player's own offers are submitted via the UI, not auto-bid here.
        if (team.id == state.playerTeamId) continue;
        if (team.roster.length >= balance.roster.maxSize) continue;
        final offer = ai.makeFaOffer(player, contracts);
        if (!capService.canSign(team: team, salary: offer.salary)) continue;
        if (contracts.evaluate(player, offer) != ContractReaction.accept) {
          continue;
        }
        final score = contracts.playerOfferScore(player, offer);
        if (best == null || score > best.score) {
          best = (teamId: team.id, offer: offer, score: score);
        }
      }

      if (best == null) {
        remaining.add(player);
        continue;
      }
      final winningTeam = state.teamById(best.teamId)!;
      final signed = contracts.signPlayer(
        team: winningTeam,
        player: player,
        offer: best.offer,
      );
      if (signed == null) {
        remaining.add(player);
        continue;
      }
      state = state.updateTeam(signed);
      state = messages.send(
        state,
        type: MessageType.contractSigned,
        domain: MessageDomain.contracts,
        titleKey: 'msg_contractSigned_fa_title',
        bodyKey: 'msg_contractSigned_fa_body',
        args: {'playerName': player.name, 'teamName': winningTeam.name},
      );
    }

    return state.copyWith(freeAgents: remaining);
  }

  LeagueState _dailyRecovery(LeagueState league) {
    var state = league;
    for (final team in league.teams) {
      var updatedTeam = team;
      for (final player in team.roster) {
        if (!player.state.injured) continue;
        final recovered = player.recoverBetweenMatches(balance);
        updatedTeam = updatedTeam.copyWith(
          roster: updatedTeam.roster
              .map(
                (candidate) =>
                    candidate.id == player.id ? recovered : candidate,
              )
              .toList(),
        );
        if (recovered.state.injured || state.playerTeamId != team.id) continue;
        final injuryId = player.state.injury?.id;
        if (injuryId == null) continue;
        final definition = InjuryCatalog.byId(injuryId);
        state = messages.send(
          state.copyWith(
            teams: state.teams
                .map(
                  (candidate) =>
                      candidate.id == team.id ? updatedTeam : candidate,
                )
                .toList(),
          ),
          type: MessageType.injuryReturn,
          domain: MessageDomain.health,
          args: {'playerName': player.name, 'injuryName': definition.name},
          payload: {'playerId': player.id, 'injuryId': injuryId},
        );
      }
      state = state.copyWith(
        teams: state.teams
            .map(
              (candidate) => candidate.id == team.id ? updatedTeam : candidate,
            )
            .toList(),
      );
    }
    return state;
  }

  LeagueState _notifyMatchResult(LeagueState league, MatchResult result) {
    return messages.send(
      league,
      type: MessageType.matchResult,
      domain: MessageDomain.matchday,
      titleKey: 'msg_matchResult_title',
      bodyKey: 'msg_matchResult_body',
      args: {
        'homeTeam':
            league.teamById(result.homeTeamId)?.name ?? result.homeTeamId,
        'awayTeam':
            league.teamById(result.awayTeamId)?.name ?? result.awayTeamId,
        'homeGoals': result.homeGoals,
        'awayGoals': result.awayGoals,
      },
      payload: {
        'homeTeamId': result.homeTeamId,
        'awayTeamId': result.awayTeamId,
        'homeGoals': result.homeGoals,
        'awayGoals': result.awayGoals,
      },
    );
  }
}
