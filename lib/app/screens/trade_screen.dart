import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:new_football/app/widgets/screen_background.dart';
import 'package:new_football/app/providers/game_provider.dart';
import 'package:new_football/core/ai/team_ai_service.dart';
import 'package:new_football/core/models/draft_pick.dart';
import 'package:new_football/core/models/league_state.dart';
import 'package:new_football/core/models/player.dart';
import 'package:new_football/core/models/team.dart';
import 'package:new_football/core/services/trade_service.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class TradeScreen extends ConsumerStatefulWidget {
  const TradeScreen({
    super.key,
    this.initialOwnPlayerId,
    this.initialTargetTeamId,
    this.initialTheirPlayerId,
  });

  final String? initialOwnPlayerId;
  final String? initialTargetTeamId;
  final String? initialTheirPlayerId;

  @override
  ConsumerState<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends ConsumerState<TradeScreen> {
  String? _ownPlayerId;
  String? _ownPickId;
  String? _targetTeamId;
  String? _theirPlayerId;
  String? _theirPickId;
  String? _status;

  @override
  void initState() {
    super.initState();
    _ownPlayerId = widget.initialOwnPlayerId;
    _targetTeamId = widget.initialTargetTeamId;
    _theirPlayerId = widget.initialTheirPlayerId;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final league = ref.watch(activeLeagueProvider);
    final own = league?.playerTeam;
    if (league == null || own == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.trade_title)),
        body: ScreenBackground(child: Center(child: Text(l10n.trade_noTeam))),
      );
    }

    final others = league.teams.where((t) => t.id != own.id).toList();
    final rawTarget = _targetTeamId == null
        ? null
        : league.teamById(_targetTeamId!);
    final target = rawTarget?.id == own.id ? null : rawTarget;
    final ownPlayerId = own.roster.any((p) => p.id == _ownPlayerId)
        ? _ownPlayerId
        : null;
    final ownPickId = own.ownedPicks.any((p) => p.id == _ownPickId)
        ? _ownPickId
        : null;
    final targetId = target?.id;
    final theirPlayerId =
        target?.roster.any((p) => p.id == _theirPlayerId) == true
        ? _theirPlayerId
        : null;
    final theirPickId =
        target?.ownedPicks.any((p) => p.id == _theirPickId) == true
        ? _theirPickId
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trade_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: ownPlayerId,
              decoration: InputDecoration(labelText: l10n.trade_yourPlayer),
              items: own.roster
                  .map(
                    (p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(
                        l10n.trade_playerOption(
                          p.name,
                          p.position.code,
                          p.pointValue,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _ownPlayerId = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: ownPickId,
              decoration: InputDecoration(labelText: l10n.trade_yourPick),
              items: own.ownedPicks
                  .map(
                    (p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(_pickLabel(p)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _ownPickId = v),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: targetId,
              decoration: InputDecoration(labelText: l10n.trade_targetTeam),
              items: others
                  .map(
                    (t) => DropdownMenuItem(value: t.id, child: Text(t.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() {
                _targetTeamId = v;
                _theirPlayerId = null;
                _theirPickId = null;
              }),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: theirPlayerId,
              decoration: InputDecoration(labelText: l10n.trade_theirPlayer),
              items: (target?.roster ?? <Player>[])
                  .map(
                    (p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(
                        l10n.trade_playerOption(
                          p.name,
                          p.position.code,
                          p.pointValue,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: target == null
                  ? null
                  : (v) => setState(() => _theirPlayerId = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: theirPickId,
              decoration: InputDecoration(labelText: l10n.trade_theirPick),
              items: (target?.ownedPicks ?? <DraftPick>[])
                  .map(
                    (p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(_pickLabel(p)),
                    ),
                  )
                  .toList(),
              onChanged: target == null
                  ? null
                  : (v) => setState(() => _theirPickId = v),
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
      ),
    );
  }

  String _pickLabel(DraftPick pick) =>
      '${pick.year} R${pick.round} (TV ${pick.tradeValue})';

  TradeAsset? _pickAsset(Team team, String? pickId) {
    if (pickId == null) return null;
    final match = team.ownedPicks.where((p) => p.id == pickId);
    if (match.isEmpty) return null;
    final p = match.first;
    return TradeAsset.pick(
      pickYear: p.year,
      pickRound: p.round,
      originalTeamId: p.originalTeamId,
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
    final ownPick = _pickAsset(own, _ownPickId);
    final theirPick = target == null ? null : _pickAsset(target, _theirPickId);

    if (target == null ||
        (ownId == null && ownPick == null) ||
        (theirId == null && theirPick == null)) {
      setState(() => _status = l10n.trade_fillAllFields);
      return;
    }

    final assetsFromA = [
      if (ownId != null) TradeAsset.player(ownId),
      if (ownPick != null) ownPick,
    ];
    final assetsFromB = [
      if (theirId != null) TradeAsset.player(theirId),
      if (theirPick != null) theirPick,
    ];

    final service = TradeService();
    final proposal = TradeProposal(
      teamAId: own.id,
      teamBId: target.id,
      assetsFromA: assetsFromA,
      assetsFromB: assetsFromB,
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
    final currentYear = league.currentSeason.year;
    final aiService = TeamAiService();
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
      currentYear: currentYear,
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
      _ownPickId = null;
      _theirPlayerId = null;
      _theirPickId = null;
    });
  }
}
