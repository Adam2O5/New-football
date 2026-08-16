import 'dart:math';

import 'package:new_football/core/balance/balance_config.dart';
import 'package:new_football/core/models/enums.dart';
import 'package:new_football/core/models/match_models.dart';
import 'package:new_football/core/models/match_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/cohesion_service.dart';
import 'package:new_football/core/services/discipline_service.dart';
import 'package:new_football/core/services/injury_service.dart';
import 'package:new_football/core/tactics/tactics_setup.dart';

class LiveMatch {
  LiveMatch({
    required this.state,
    required this.homeTeamId,
    required this.awayTeamId,
    this.balance = BalanceConfig.defaults,
    List<MatchEvent>? events,
    List<MatchInjury>? injuries,
    List<MatchDiscipline>? disciplines,
    this.homeSubsUsed = 0,
    this.awaySubsUsed = 0,
    this.homeSubWindows = 0,
    this.awaySubWindows = 0,
    this.homeCohesionMult = 1.03,
    this.awayCohesionMult = 1.03,
    this.homeChemistry = 50,
    this.awayChemistry = 50,
    this.homeDoctorCareMult = 1.0,
    this.awayDoctorCareMult = 1.0,
    this.homeDoctorPreventionMult = 1.0,
    this.awayDoctorPreventionMult = 1.0,
  }) : events = events ?? [],
       injuries = injuries ?? [],
       disciplines = disciplines ?? [];

  MatchState state;
  final String homeTeamId;
  final String awayTeamId;
  final BalanceConfig balance;
  final List<MatchEvent> events;
  final List<MatchInjury> injuries;
  final List<MatchDiscipline> disciplines;
  int homeSubsUsed;
  int awaySubsUsed;
  int homeSubWindows;
  int awaySubWindows;

  /// Lineup cohesion multiplier (1.01–1.05 × HC Motivation), frozen at start.
  final double homeCohesionMult;
  final double awayCohesionMult;

  /// Team zgranie (0–100) from Team.chemistry, frozen at start.
  final int homeChemistry;
  final int awayChemistry;
  final double homeDoctorCareMult;
  final double awayDoctorCareMult;
  final double homeDoctorPreventionMult;
  final double awayDoctorPreventionMult;

  bool get isFinished => state.minute >= 90;

  MatchResult toResult() {
    final homeShots = events
        .where(
          (e) =>
              e.teamId == homeTeamId &&
              (e.type == MatchEventType.goal ||
                  e.type == MatchEventType.scoredPenalty),
        )
        .length;
    final awayShots = events
        .where(
          (e) =>
              e.teamId == awayTeamId &&
              (e.type == MatchEventType.goal ||
                  e.type == MatchEventType.scoredPenalty),
        )
        .length;
    return MatchResult(
      homeTeamId: homeTeamId,
      awayTeamId: awayTeamId,
      homeGoals: state.homeGoals,
      awayGoals: state.awayGoals,
      homeStats: TeamMatchStats(
        teamId: homeTeamId,
        goals: state.homeGoals,
        shots: homeShots + state.homeGoals + 4,
        shotsOnTarget: state.homeGoals + 2,
        possession: 50,
        xg: state.homeGoals * 0.9 + 0.4,
        yellowCards: _cardCount(homeTeamId, yellow: true),
        redCards: _cardCount(homeTeamId, yellow: false),
      ),
      awayStats: TeamMatchStats(
        teamId: awayTeamId,
        goals: state.awayGoals,
        shots: awayShots + state.awayGoals + 4,
        shotsOnTarget: state.awayGoals + 2,
        possession: 50,
        xg: state.awayGoals * 0.9 + 0.4,
        yellowCards: _cardCount(awayTeamId, yellow: true),
        redCards: _cardCount(awayTeamId, yellow: false),
      ),
      events: List.unmodifiable(events),
      injuries: List.unmodifiable(injuries),
      disciplines: List.unmodifiable(disciplines),
    );
  }

  int _cardCount(String teamId, {required bool yellow}) {
    return events
        .where(
          (e) =>
              e.teamId == teamId &&
              e.type ==
                  (yellow ? MatchEventType.yellowCard : MatchEventType.redCard),
        )
        .length;
  }
}

/// Minute-by-minute match engine (`docs/matchday_model.md`).
class MatchEngine {
  const MatchEngine({this.balance = BalanceConfig.defaults});

  final BalanceConfig balance;

  LiveMatch start({
    required Team home,
    required Team away,
    MatchContext context = const MatchContext(),
    required int rngSeed,
  }) {
    final walkover = _precheckWalkover(home, away);
    if (walkover != null) {
      final live = LiveMatch(
        state: MatchState(
          minute: 90,
          homeGoals: walkover.homeGoals,
          awayGoals: walkover.awayGoals,
          homeLineup: home.startingEleven,
          awayLineup: away.startingEleven,
          homeBench: _benchPlayers(home),
          awayBench: _benchPlayers(away),
          homeTactics: home.tactics,
          awayTactics: away.tactics,
          context: context,
          rngSeed: rngSeed,
        ),
        homeTeamId: home.id,
        awayTeamId: away.id,
        balance: balance,
        events: List.of(walkover.events),
      );
      return live;
    }

    final noGk = _precheckNoGk(home, away);
    if (noGk != null) {
      return LiveMatch(
        state: MatchState(
          minute: 90,
          homeGoals: noGk.homeGoals,
          awayGoals: noGk.awayGoals,
          homeLineup: home.startingEleven,
          awayLineup: away.startingEleven,
          homeBench: _benchPlayers(home),
          awayBench: _benchPlayers(away),
          homeTactics: home.tactics,
          awayTactics: away.tactics,
          context: context,
          rngSeed: rngSeed,
        ),
        homeTeamId: home.id,
        awayTeamId: away.id,
        balance: balance,
        events: List.of(noGk.events),
      );
    }

    final cohesionSvc = const CohesionService();
    final homeCohesion = cohesionSvc.computeCohesion(home.startingEleven);
    final awayCohesion = cohesionSvc.computeCohesion(away.startingEleven);

    return LiveMatch(
      state: MatchState(
        minute: 0,
        homeLineup: List.of(home.startingEleven),
        awayLineup: List.of(away.startingEleven),
        homeBench: _benchPlayers(home),
        awayBench: _benchPlayers(away),
        homeTactics: home.tactics,
        awayTactics: away.tactics,
        context: context,
        rngSeed: rngSeed,
      ),
      homeTeamId: home.id,
      awayTeamId: away.id,
      balance: balance,
      homeCohesionMult: cohesionSvc.cohesionMult(
        homeCohesion,
        headCoach: home.staff.headCoach,
      ),
      awayCohesionMult: cohesionSvc.cohesionMult(
        awayCohesion,
        headCoach: away.staff.headCoach,
      ),
      homeChemistry: home.chemistry,
      awayChemistry: away.chemistry,
      homeDoctorCareMult: const InjuryService().doctorCareMult(
        home.staff.doctor,
      ),
      awayDoctorCareMult: const InjuryService().doctorCareMult(
        away.staff.doctor,
      ),
      homeDoctorPreventionMult: const InjuryService().doctorPreventionMult(
        home.staff.doctor,
      ),
      awayDoctorPreventionMult: const InjuryService().doctorPreventionMult(
        away.staff.doctor,
      ),
    );
  }

  /// Simulate one minute. Returns new events produced this minute.
  List<MatchEvent> simulateMinute(LiveMatch live) {
    if (live.isFinished) return const [];
    final nextMinute = live.state.minute + 1;
    final rng = Random(
      Object.hash(live.state.rngSeed, nextMinute, live.state.homeGoals),
    );

    var state = live.state.copyWith(minute: nextMinute);
    final newEvents = <MatchEvent>[];

    if (nextMinute == 45) {
      final ht = MatchEvent(
        type: MatchEventType.halfTime,
        minute: 45,
        teamId: live.homeTeamId,
        description: 'Przerwa',
      );
      newEvents.add(ht);
    }

    final homePower = _teamPower(
      state.homeLineup,
      state.homeTactics,
      chemistry: live.homeChemistry,
      cohesionMult: live.homeCohesionMult,
      isHome: true,
      momentum: state.momentum,
      morale: state.moraleModHome,
      context: state.context,
      opponentTactics: state.awayTactics,
    );
    final awayPower = _teamPower(
      state.awayLineup,
      state.awayTactics,
      chemistry: live.awayChemistry,
      cohesionMult: live.awayCohesionMult,
      isHome: false,
      momentum: -state.momentum,
      morale: state.moraleModAway,
      context: state.context,
      opponentTactics: state.homeTactics,
    );

    final total = homePower + awayPower;
    final homeChance = (homePower / total) * 0.085;
    final awayChance = (awayPower / total) * 0.085;

    if (rng.nextDouble() < homeChance) {
      final (ev, updated) = _resolveChance(
        live: live,
        state: state,
        attackingHome: true,
        rng: rng,
      );
      state = updated;
      newEvents.addAll(ev);
    } else if (rng.nextDouble() < awayChance) {
      final (ev, updated) = _resolveChance(
        live: live,
        state: state,
        attackingHome: false,
        rng: rng,
      );
      state = updated;
      newEvents.addAll(ev);
    } else if (rng.nextDouble() < 0.012) {
      final homeAttack = rng.nextBool();
      final teamId = homeAttack ? live.homeTeamId : live.awayTeamId;
      final lineup = homeAttack ? state.homeLineup : state.awayLineup;
      if (lineup.isNotEmpty) {
        final player = lineup[rng.nextInt(lineup.length)];
        final playerInStartingXi =
            (homeAttack ? live.state.homeLineup : live.state.awayLineup).any(
              (candidate) => candidate.id == player.id,
            );
        if (rng.nextDouble() < balance.matchday.redDirect) {
          final severity = DisciplineService.rollDirectRedSeverity(rng);
          newEvents.add(
            MatchEvent(
              type: MatchEventType.redCard,
              minute: nextMinute,
              teamId: teamId,
              playerId: player.id,
              description:
                  'Czerwona kartka — ${player.name} (bezpośrednia, poziom $severity)',
            ),
          );
          _recordDiscipline(
            live,
            teamId: teamId,
            playerId: player.id,
            playerInStartingXi: playerInStartingXi,
            redCardKind: RedCardKind.direct,
            directRedSeverity: severity,
          );
          state = _sendOff(state, player.id, homeAttack);
        } else {
          final yellows = Map<String, int>.from(state.yellowCardCounts);
          final count = (yellows[player.id] ?? 0) + 1;
          yellows[player.id] = count;
          if (count >= 2) {
            newEvents.add(
              MatchEvent(
                type: MatchEventType.redCard,
                minute: nextMinute,
                teamId: teamId,
                playerId: player.id,
                description: 'Czerwona kartka — ${player.name} (2× żółta)',
              ),
            );
            _recordDiscipline(
              live,
              teamId: teamId,
              playerId: player.id,
              playerInStartingXi: playerInStartingXi,
              yellowCardsInMatch: 1,
              redCardKind: RedCardKind.secondYellow,
            );
            state = _sendOff(state, player.id, homeAttack, secondYellow: true);
          } else {
            newEvents.add(
              MatchEvent(
                type: MatchEventType.yellowCard,
                minute: nextMinute,
                teamId: teamId,
                playerId: player.id,
                description: 'Żółta kartka — ${player.name}',
              ),
            );
            _recordDiscipline(
              live,
              teamId: teamId,
              playerId: player.id,
              playerInStartingXi: playerInStartingXi,
              yellowCardsInMatch: 1,
            );
            state = state.copyWith(yellowCardCounts: yellows);
          }
        }
      }
    } else {
      final homeSide = rng.nextBool();
      final lineup = homeSide ? state.homeLineup : state.awayLineup;
      final prevention = homeSide
          ? live.homeDoctorPreventionMult
          : live.awayDoctorPreventionMult;
      final injuryChance = 0.004 * prevention;
      if (lineup.length > 1 && rng.nextDouble() < injuryChance) {
        final player = lineup[rng.nextInt(lineup.length)];
        final diagnosis = const InjuryService().diagnose(
          random: rng,
          doctorCareMultiplier: homeSide
              ? live.homeDoctorCareMult
              : live.awayDoctorCareMult,
        );
        final playerInStartingXi =
            (homeSide ? live.state.homeLineup : live.state.awayLineup).any(
              (candidate) => candidate.id == player.id,
            );
        newEvents.add(
          MatchEvent(
            type: diagnosis.injury.type == InjuryType.major
                ? MatchEventType.majorInjury
                : MatchEventType.minorInjury,
            minute: nextMinute,
            teamId: homeSide ? live.homeTeamId : live.awayTeamId,
            playerId: player.id,
            description: '${diagnosis.definition.name} — ${player.name}',
          ),
        );
        live.injuries.add(
          MatchInjury(
            teamId: homeSide ? live.homeTeamId : live.awayTeamId,
            playerId: player.id,
            injury: diagnosis.injury,
            playerInStartingXi: playerInStartingXi,
            potentialLoss: diagnosis.potentialLoss,
          ),
        );
        state = state.copyWith(
          injuriesThisMatch: [...state.injuriesThisMatch, player.id],
        );
        if (diagnosis.injury.type == InjuryType.major) {
          state = _forceInjurySub(live, state, player.id, homeSide, newEvents);
        }
      }
    }

    if (nextMinute == 90) {
      newEvents.add(
        MatchEvent(
          type: MatchEventType.fullTime,
          minute: 90,
          teamId: live.homeTeamId,
          description: 'Koniec meczu ${state.homeGoals}:${state.awayGoals}',
        ),
      );
    }

    live.state = state;
    live.events.addAll(newEvents);
    return newEvents;
  }

  /// Run until [untilMinute] (inclusive) or full time.
  List<MatchEvent> runUntil(LiveMatch live, int untilMinute) {
    final all = <MatchEvent>[];
    while (!live.isFinished && live.state.minute < untilMinute) {
      all.addAll(simulateMinute(live));
    }
    return all;
  }

  MatchResult simulateFull({
    required Team home,
    required Team away,
    MatchContext context = const MatchContext(),
    required int rngSeed,
  }) {
    final live = start(
      home: home,
      away: away,
      context: context,
      rngSeed: rngSeed,
    );
    if (!live.isFinished) {
      runUntil(live, 90);
    }
    return live.toResult();
  }

  bool applySubstitution({
    required LiveMatch live,
    required bool homeSide,
    required String playerOutId,
    required String playerInId,
  }) {
    final maxSubs = balance.matchday.maxSubstitutions;
    final maxWindows = balance.matchday.maxSubstitutionWindows;
    final used = homeSide ? live.homeSubsUsed : live.awaySubsUsed;
    final windows = homeSide ? live.homeSubWindows : live.awaySubWindows;
    if (used >= maxSubs || windows >= maxWindows) return false;

    var lineup = List<Player>.from(
      homeSide ? live.state.homeLineup : live.state.awayLineup,
    );
    var bench = List<Player>.from(
      homeSide ? live.state.homeBench : live.state.awayBench,
    );
    final outIdx = lineup.indexWhere((p) => p.id == playerOutId);
    final inIdx = bench.indexWhere((p) => p.id == playerInId);
    if (outIdx < 0 || inIdx < 0) return false;

    final out = lineup[outIdx];
    final incoming = bench[inIdx];
    lineup[outIdx] = incoming;
    bench.removeAt(inIdx);
    bench.add(out);

    live.state = homeSide
        ? live.state.copyWith(homeLineup: lineup, homeBench: bench)
        : live.state.copyWith(awayLineup: lineup, awayBench: bench);

    if (homeSide) {
      live.homeSubsUsed++;
      live.homeSubWindows++;
    } else {
      live.awaySubsUsed++;
      live.awaySubWindows++;
    }

    live.events.add(
      MatchEvent(
        type: MatchEventType.substitution,
        minute: live.state.minute,
        teamId: homeSide ? live.homeTeamId : live.awayTeamId,
        playerId: playerInId,
        description: 'Zmiana: ${out.name} → ${incoming.name}',
      ),
    );
    return true;
  }

  void updateTactics({
    required LiveMatch live,
    required bool homeSide,
    required TacticsSetup tactics,
  }) {
    live.state = homeSide
        ? live.state.copyWith(homeTactics: tactics)
        : live.state.copyWith(awayTactics: tactics);
  }

  double _teamPower(
    List<Player> lineup,
    TacticsSetup tactics, {
    required int chemistry,
    required double cohesionMult,
    required bool isHome,
    required double momentum,
    required double morale,
    required MatchContext context,
    required TacticsSetup opponentTactics,
  }) {
    if (lineup.isEmpty) return 1;
    final chem = balance.chemistry;
    final chemMult =
        chem.multMin +
        (chem.multMax - chem.multMin) * (chemistry.clamp(0, 100) / 100);

    var sum = 0.0;
    for (final p in lineup) {
      final roleMult = _roleFitMult(p);
      final contrib =
          p.overall(balance) *
          p.staminaPerformanceMult(balance) *
          (0.85 + p.state.form / 20) *
          roleMult *
          chemMult *
          cohesionMult;
      sum += contrib;
    }
    sum /= lineup.length;

    final tacticsMult = _tacticsMultiplier(tactics, opponentTactics);
    final homeAdv = isHome ? (1.0 + context.homeAdvantage) : 1.0;
    return sum *
        tacticsMult *
        homeAdv *
        (1.0 + momentum * 0.08 + morale * 0.05);
  }

  double _roleFitMult(Player p) {
    final chem = balance.chemistry;
    final role = p.state.role;
    final fits = role.map(
      gk: (_) => p.position == Position.gk,
      cb: (_) => p.position == Position.cb,
      fullBack: (_) => p.position == Position.lb || p.position == Position.rb,
      wingBack: (_) => p.position == Position.lwb || p.position == Position.rwb,
      cdm: (_) => p.position == Position.cdm,
      cm: (_) => p.position == Position.cm,
      cam: (_) => p.position == Position.cam,
      winger: (_) => p.position == Position.lw || p.position == Position.rw,
      striker: (_) => p.position == Position.st,
    );
    if (fits) {
      return (chem.roleMultOkMin + chem.roleMultOkMax) / 2;
    }
    return (chem.roleMultFailMin + chem.roleMultFailMax) / 2;
  }

  double _tacticsMultiplier(TacticsSetup ours, TacticsSetup theirs) {
    final tb = balance.tactics;
    var bonus = 0.0;
    for (final m in tb.formationMatchups) {
      if (m.formationA == ours.formation && m.formationB == theirs.formation) {
        bonus += m.bonusForA;
      }
      if (m.formationA == theirs.formation && m.formationB == ours.formation) {
        bonus -= m.bonusForA;
      }
    }
    final clamp = tb.matchupClamp;
    return 1.0 + bonus.clamp(-clamp, clamp);
  }

  (List<MatchEvent>, MatchState) _resolveChance({
    required LiveMatch live,
    required MatchState state,
    required bool attackingHome,
    required Random rng,
  }) {
    final lineup = attackingHome ? state.homeLineup : state.awayLineup;
    final defense = attackingHome ? state.awayLineup : state.homeLineup;
    if (lineup.isEmpty) return ([], state);

    final attacker = _pickAttacker(lineup, rng);
    final teamId = attackingHome ? live.homeTeamId : live.awayTeamId;
    final atk = attacker.overall(balance);
    final def = defense.isEmpty
        ? 50.0
        : defense.map((p) => p.overall(balance)).reduce((a, b) => a + b) /
              defense.length;
    final finishProb = (0.35 + (atk - def) / 200).clamp(0.15, 0.65);

    if (rng.nextDouble() < 0.08) {
      // Penalty
      final scored = rng.nextDouble() < 0.75;
      final events = <MatchEvent>[
        MatchEvent(
          type: scored
              ? MatchEventType.scoredPenalty
              : MatchEventType.missedPenalty,
          minute: state.minute,
          teamId: teamId,
          playerId: attacker.id,
          description: scored
              ? 'Gol z karnego — ${attacker.name}'
              : 'Niewykorzystany karny — ${attacker.name}',
        ),
      ];
      if (scored) {
        state = attackingHome
            ? state.copyWith(
                homeGoals: state.homeGoals + 1,
                momentum: (state.momentum + 0.3).clamp(-1.0, 1.0),
              )
            : state.copyWith(
                awayGoals: state.awayGoals + 1,
                momentum: (state.momentum - 0.3).clamp(-1.0, 1.0),
              );
      }
      return (events, state);
    }

    if (rng.nextDouble() < finishProb) {
      final events = [
        MatchEvent(
          type: MatchEventType.goal,
          minute: state.minute,
          teamId: teamId,
          playerId: attacker.id,
          description: 'GOL — ${attacker.name}',
        ),
      ];
      state = attackingHome
          ? state.copyWith(
              homeGoals: state.homeGoals + 1,
              momentum: (state.momentum + 0.25).clamp(-1.0, 1.0),
            )
          : state.copyWith(
              awayGoals: state.awayGoals + 1,
              momentum: (state.momentum - 0.25).clamp(-1.0, 1.0),
            );
      return (events, state);
    }

    return ([], state);
  }

  Player _pickAttacker(List<Player> lineup, Random rng) {
    final attackers = lineup
        .where(
          (p) =>
              p.position == Position.st ||
              p.position == Position.lw ||
              p.position == Position.rw ||
              p.position == Position.cam,
        )
        .toList();
    final pool = attackers.isNotEmpty ? attackers : lineup;
    return pool[rng.nextInt(pool.length)];
  }

  void _recordDiscipline(
    LiveMatch live, {
    required String teamId,
    required String playerId,
    required bool playerInStartingXi,
    int yellowCardsInMatch = 0,
    RedCardKind redCardKind = RedCardKind.none,
    int directRedSeverity = 0,
  }) {
    final index = live.disciplines.indexWhere(
      (discipline) =>
          discipline.teamId == teamId && discipline.playerId == playerId,
    );
    final item = MatchDiscipline(
      teamId: teamId,
      playerId: playerId,
      yellowCardsInMatch: yellowCardsInMatch,
      redCardKind: redCardKind,
      directRedSeverity: directRedSeverity,
      playerInStartingXi: playerInStartingXi,
    );
    if (index < 0) {
      live.disciplines.add(item);
      return;
    }
    final previous = live.disciplines[index];
    live.disciplines[index] = previous.copyWith(
      yellowCardsInMatch: previous.yellowCardsInMatch + item.yellowCardsInMatch,
      redCardKind:
          item.redCardKind == RedCardKind.direct ||
              previous.redCardKind == RedCardKind.direct
          ? RedCardKind.direct
          : item.redCardKind == RedCardKind.secondYellow ||
                previous.redCardKind == RedCardKind.secondYellow
          ? RedCardKind.secondYellow
          : RedCardKind.none,
      directRedSeverity: item.directRedSeverity > 0
          ? item.directRedSeverity
          : previous.directRedSeverity,
      playerInStartingXi:
          previous.playerInStartingXi || item.playerInStartingXi,
    );
  }

  MatchState _sendOff(
    MatchState state,
    String playerId,
    bool homeSide, {
    bool secondYellow = false,
  }) {
    final lineup = List<Player>.from(
      homeSide ? state.homeLineup : state.awayLineup,
    );
    lineup.removeWhere((p) => p.id == playerId);
    return homeSide
        ? state.copyWith(
            homeLineup: lineup,
            sentOffPlayerIds: [...state.sentOffPlayerIds, playerId],
            yellowCardCounts: secondYellow
                ? {...state.yellowCardCounts, playerId: 2}
                : state.yellowCardCounts,
            momentum: (state.momentum - 0.2).clamp(-1.0, 1.0),
          )
        : state.copyWith(
            awayLineup: lineup,
            sentOffPlayerIds: [...state.sentOffPlayerIds, playerId],
            yellowCardCounts: secondYellow
                ? {...state.yellowCardCounts, playerId: 2}
                : state.yellowCardCounts,
            momentum: (state.momentum + 0.2).clamp(-1.0, 1.0),
          );
  }

  MatchState _forceInjurySub(
    LiveMatch live,
    MatchState state,
    String playerId,
    bool homeSide,
    List<MatchEvent> events,
  ) {
    final bench = homeSide ? state.homeBench : state.awayBench;
    if (bench.isEmpty) {
      return _sendOff(state, playerId, homeSide);
    }
    final incoming = bench.first;
    applySubstitution(
      live: live..state = state,
      homeSide: homeSide,
      playerOutId: playerId,
      playerInId: incoming.id,
    );
    return live.state;
  }

  List<Player> _benchPlayers(Team team) {
    if (team.benchPlayerIds.isNotEmpty) {
      return team.benchPlayerIds
          .map((id) {
            try {
              return team.roster.firstWhere((p) => p.id == id);
            } catch (_) {
              return null;
            }
          })
          .whereType<Player>()
          .where((p) => p.isAvailable)
          .toList();
    }
    final xi = team.lineupPlayerIds.toSet();
    return team.availablePlayers
        .where((p) => !xi.contains(p.id))
        .take(balance.roster.benchSize)
        .toList();
  }

  MatchResult? _precheckWalkover(Team home, Team away) {
    final homeOk = _legalRoster(home);
    final awayOk = _legalRoster(away);
    if (homeOk && awayOk) return null;
    final b = balance.matchday;
    if (!homeOk && !awayOk) {
      return MatchResult(
        homeTeamId: home.id,
        awayTeamId: away.id,
        homeGoals: 0,
        awayGoals: 0,
        homeStats: TeamMatchStats(teamId: home.id),
        awayStats: TeamMatchStats(teamId: away.id),
        events: [
          MatchEvent(
            type: MatchEventType.fullTime,
            minute: 0,
            teamId: home.id,
            description: 'Walkower — obie drużyny, nielegalny roster',
          ),
        ],
      );
    }
    if (!homeOk) {
      return MatchResult(
        homeTeamId: home.id,
        awayTeamId: away.id,
        homeGoals: b.walkoverGoalsFor,
        awayGoals: b.walkoverGoalsAgainst,
        homeStats: TeamMatchStats(teamId: home.id, goals: b.walkoverGoalsFor),
        awayStats: TeamMatchStats(
          teamId: away.id,
          goals: b.walkoverGoalsAgainst,
        ),
        events: [
          MatchEvent(
            type: MatchEventType.fullTime,
            minute: 0,
            teamId: home.id,
            description: 'Walkower — nielegalny roster gospodarzy',
          ),
        ],
      );
    }
    return MatchResult(
      homeTeamId: home.id,
      awayTeamId: away.id,
      homeGoals: b.walkoverGoalsAgainst,
      awayGoals: b.walkoverGoalsFor,
      homeStats: TeamMatchStats(teamId: home.id, goals: b.walkoverGoalsAgainst),
      awayStats: TeamMatchStats(teamId: away.id, goals: b.walkoverGoalsFor),
      events: [
        MatchEvent(
          type: MatchEventType.fullTime,
          minute: 0,
          teamId: away.id,
          description: 'Walkower — nielegalny roster gości',
        ),
      ],
    );
  }

  MatchResult? _precheckNoGk(Team home, Team away) {
    final homeGk = home.startingEleven.any((p) => p.position == Position.gk);
    final awayGk = away.startingEleven.any((p) => p.position == Position.gk);
    if (homeGk && awayGk) return null;
    final b = balance.matchday;
    if (!homeGk && !awayGk) {
      return MatchResult(
        homeTeamId: home.id,
        awayTeamId: away.id,
        homeGoals: 0,
        awayGoals: 0,
        homeStats: TeamMatchStats(teamId: home.id),
        awayStats: TeamMatchStats(teamId: away.id),
        events: [
          MatchEvent(
            type: MatchEventType.fullTime,
            minute: 0,
            teamId: home.id,
            description: 'Obie drużyny bez BR — 0:0',
          ),
        ],
      );
    }
    if (!homeGk) {
      return MatchResult(
        homeTeamId: home.id,
        awayTeamId: away.id,
        homeGoals: b.noGkGoalsFor,
        awayGoals: b.noGkGoalsAgainst,
        homeStats: TeamMatchStats(teamId: home.id, goals: b.noGkGoalsFor),
        awayStats: TeamMatchStats(teamId: away.id, goals: b.noGkGoalsAgainst),
        events: [
          MatchEvent(
            type: MatchEventType.fullTime,
            minute: 0,
            teamId: home.id,
            description: 'Brak bramkarza gospodarzy — kara',
          ),
        ],
      );
    }
    return MatchResult(
      homeTeamId: home.id,
      awayTeamId: away.id,
      homeGoals: b.noGkGoalsAgainst,
      awayGoals: b.noGkGoalsFor,
      homeStats: TeamMatchStats(teamId: home.id, goals: b.noGkGoalsAgainst),
      awayStats: TeamMatchStats(teamId: away.id, goals: b.noGkGoalsFor),
      events: [
        MatchEvent(
          type: MatchEventType.fullTime,
          minute: 0,
          teamId: away.id,
          description: 'Brak bramkarza gości — kara',
        ),
      ],
    );
  }

  bool _legalRoster(Team team) {
    final n = team.roster.length;
    final available = team.roster.where((p) => p.isAvailable).length;
    return n >= balance.roster.minSize &&
        n <= balance.roster.maxSize &&
        available >= 11;
  }
}
