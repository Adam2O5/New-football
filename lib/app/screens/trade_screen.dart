import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/ai/team_ai_service.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/trade_service.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class TradeScreen extends ConsumerStatefulWidget {
  const TradeScreen({super.key});

  @override
  ConsumerState<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends ConsumerState<TradeScreen> {
  String? _ownPlayerId;
  String? _targetTeamId;
  String? _theirPlayerId;
  String? _status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    final own = league?.playerTeam;
    if (league == null || own == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.trade_title)),
        body: Center(child: Text(l10n.trade_noTeam)),
      );
    }

    final others = league.teams.where((t) => t.id != own.id).toList();
    final target = _targetTeamId == null
        ? null
        : league.teamById(_targetTeamId!);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trade_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _ownPlayerId,
            decoration: InputDecoration(labelText: l10n.trade_yourPlayer),
            items: own.roster
                .map(
                  (p) => DropdownMenuItem(
                    value: p.id,
                    child: Text(
                      l10n.trade_playerOption(
                        p.name,
                        p.position.code,
                        p.pointValue(),
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _ownPlayerId = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _targetTeamId,
            decoration: InputDecoration(labelText: l10n.trade_targetTeam),
            items: others
                .map(
                  (t) => DropdownMenuItem(value: t.id, child: Text(t.name)),
                )
                .toList(),
            onChanged: (v) => setState(() {
              _targetTeamId = v;
              _theirPlayerId = null;
            }),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _theirPlayerId,
            decoration: InputDecoration(labelText: l10n.trade_theirPlayer),
            items: (target?.roster ?? <Player>[])
                .map(
                  (p) => DropdownMenuItem(
                    value: p.id,
                    child: Text(
                      l10n.trade_playerOption(
                        p.name,
                        p.position.code,
                        p.pointValue(),
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: target == null
                ? null
                : (v) => setState(() => _theirPlayerId = v),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => _execute(l10n, league, own, target),
            child: Text(l10n.trade_confirm),
          ),
          if (_status != null) ...[
            const SizedBox(height: 12),
            Text(_status!),
          ],
        ],
      ),
    );
  }

  Future<void> _execute(
    AppLocalizations l10n,
    LeagueState league,
    Team own,
    Team? target,
  ) async {
    final ownId = _ownPlayerId;
    final theirId = _theirPlayerId;
    if (ownId == null || target == null || theirId == null) {
      setState(() => _status = l10n.trade_fillAllFields);
      return;
    }

    final service = TradeService();
    final proposal = TradeProposal(
      teamAId: own.id,
      teamBId: target.id,
      assetsFromA: [TradeAsset.player(ownId)],
      assetsFromB: [TradeAsset.player(theirId)],
    );
    final validation = service.validate(
      own,
      target,
      proposal,
      currentWeek: league.currentWeek,
    );
    if (!validation.ok) {
      setState(() => _status = validation.reason ?? l10n.trade_notAllowed);
      return;
    }
    final aiService = TeamAiService(difficulty: league.difficulty);
    // shouldAcceptTrade values `assetsFromA` against `self`'s roster and
    // `assetsFromB` against `other`'s — mirror the proposal so `self`
    // (the target) is evaluated on what it actually gives/receives.
    final mirroredProposal = TradeProposal(
      teamAId: target.id,
      teamBId: own.id,
      assetsFromA: proposal.assetsFromB,
      assetsFromB: proposal.assetsFromA,
    );
    final aiAccepts = aiService.shouldAcceptTrade(
      self: target,
      other: own,
      proposal: mirroredProposal,
      tradeService: service,
    );
    if (!aiAccepts) {
      setState(() => _status = l10n.trade_aiRejected);
      return;
    }
    final result = service.execute(own, target, proposal);
    if (result == null) {
      setState(() => _status = l10n.trade_executeFailed);
      return;
    }
    final (newA, newB) = result;
    await ref.read(gameControllerProvider.notifier).updateLeague((l) {
      var next = l.updateTeam(newA);
      next = next.updateTeam(newB);
      return next;
    });
    if (!mounted) return;
    setState(() {
      _status = l10n.trade_success;
      _ownPlayerId = null;
      _theirPlayerId = null;
    });
  }
}
