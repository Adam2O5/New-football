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
import 'package:new_football/core/models/trade_models.dart';
import 'package:new_football/core/services/trade_service.dart';
import 'package:new_football/l10n/generated/app_localizations.dart';

class TradeScreen extends ConsumerStatefulWidget {
  const TradeScreen({
    super.key,
    this.initialOwnPlayerId,
    this.initialTargetTeamId,
    this.initialTheirPlayerId,
    this.initialTradeOfferId,
  });

  final String? initialOwnPlayerId;
  final String? initialTargetTeamId;
  final String? initialTheirPlayerId;
  final String? initialTradeOfferId;

  @override
  ConsumerState<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends ConsumerState<TradeScreen> {
  String? _ownPlayerId;
  String? _ownPickId;
  String? _ownRightsId;
  String? _targetTeamId;
  String? _theirPlayerId;
  String? _theirPickId;
  String? _theirRightsId;
  String? _status;

  @override
  void initState() {
    super.initState();
    _ownPlayerId = widget.initialOwnPlayerId;
    _targetTeamId = widget.initialTargetTeamId;
    _theirPlayerId = widget.initialTheirPlayerId;

    final offerId = widget.initialTradeOfferId;
    final league = offerId == null ? null : ref.read(activeLeagueProvider);
    final offer = offerId == null ? null : league?.tradeOfferById(offerId);
    final own = league?.playerTeam;
    if (offer != null && own != null && offer.awaitingTeamId == own.id) {
      _targetTeamId = offer.teamAId == own.id ? offer.teamBId : offer.teamAId;
      final ownAssets = offer.teamAId == own.id
          ? offer.assetsFromA
          : offer.assetsFromB;
      final theirAssets = offer.teamAId == own.id
          ? offer.assetsFromB
          : offer.assetsFromA;
      _ownPlayerId ??= _firstSnapshotId(ownAssets, 'player');
      _ownPickId ??= _firstSnapshotId(ownAssets, 'pick');
      _ownRightsId ??= _firstSnapshotId(ownAssets, 'draftedRights');
      _theirPlayerId ??= _firstSnapshotId(theirAssets, 'player');
      _theirPickId ??= _firstSnapshotId(theirAssets, 'pick');
      _theirRightsId ??= _firstSnapshotId(theirAssets, 'draftedRights');
    }
  }

  String? _firstSnapshotId(List<TradeAssetSnapshot> assets, String type) {
    for (final asset in assets) {
      if (asset.type != type) continue;
      return switch (type) {
        'player' => asset.playerId,
        'pick' => asset.pickId,
        'draftedRights' => asset.draftedRightsId,
        _ => null,
      };
    }
    return null;
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
    final ownRights = league.draftedRights
        .where((right) => right.ownerTeamId == own.id)
        .toList();
    final ownRightsId = ownRights.any((right) => right.id == _ownRightsId)
        ? _ownRightsId
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
    final targetRights = league.draftedRights
        .where((right) => right.ownerTeamId == target?.id)
        .toList();
    final theirRightsId =
        targetRights.any((right) => right.id == _theirRightsId)
        ? _theirRightsId
        : null;
    final ownPick = _pickAsset(own, ownPickId);
    final theirPick = target == null ? null : _pickAsset(target, theirPickId);
    final previewAssetsFromA = [
      if (ownPlayerId != null) TradeAsset.player(ownPlayerId),
      if (ownPick != null) ownPick,
      if (ownRightsId != null) TradeAsset.draftedRights(ownRightsId),
    ];
    final previewAssetsFromB = [
      if (theirPlayerId != null) TradeAsset.player(theirPlayerId),
      if (theirPick != null) theirPick,
      if (theirRightsId != null) TradeAsset.draftedRights(theirRightsId),
    ];
    TradeValidation? previewValidation;
    if (target != null &&
        (previewAssetsFromA.isNotEmpty || previewAssetsFromB.isNotEmpty)) {
      previewValidation = TradeService().validateLeague(
        league,
        TradeProposal(
          teamAId: own.id,
          teamBId: target.id,
          assetsFromA: previewAssetsFromA,
          assetsFromB: previewAssetsFromB,
        ),
      );
    }
    final previewReason = previewValidation != null && !previewValidation.ok
        ? previewValidation.reason
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
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: ownRightsId,
              decoration: InputDecoration(labelText: l10n.trade_yourRights),
              items: ownRights
                  .map(
                    (right) => DropdownMenuItem(
                      value: right.id,
                      child: Text(right.player.name),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _ownRightsId = v),
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
                _theirRightsId = null;
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
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: theirRightsId,
              decoration: InputDecoration(labelText: l10n.trade_theirRights),
              items: targetRights
                  .map(
                    (right) => DropdownMenuItem(
                      value: right.id,
                      child: Text(right.player.name),
                    ),
                  )
                  .toList(),
              onChanged: target == null
                  ? null
                  : (v) => setState(() => _theirRightsId = v),
            ),
            if (previewReason != null) ...[
              const SizedBox(height: 12),
              Text(previewReason),
            ],
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
      pickId: p.id,
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
    final ownRightsId = _ownRightsId;
    final theirRightsId = _theirRightsId;
    final ownPick = _pickAsset(own, _ownPickId);
    final theirPick = target == null ? null : _pickAsset(target, _theirPickId);

    if (target == null ||
        (ownId == null && ownPick == null && ownRightsId == null) ||
        (theirId == null && theirPick == null && theirRightsId == null)) {
      setState(() => _status = l10n.trade_fillAllFields);
      return;
    }

    final assetsFromA = [
      if (ownId != null) TradeAsset.player(ownId),
      if (ownPick != null) ownPick,
      if (ownRightsId != null) TradeAsset.draftedRights(ownRightsId),
    ];
    final assetsFromB = [
      if (theirId != null) TradeAsset.player(theirId),
      if (theirPick != null) theirPick,
      if (theirRightsId != null) TradeAsset.draftedRights(theirRightsId),
    ];

    final service = TradeService();
    final proposal = TradeProposal(
      teamAId: own.id,
      teamBId: target.id,
      assetsFromA: assetsFromA,
      assetsFromB: assetsFromB,
    );
    final counterOfferId = widget.initialTradeOfferId;
    if (counterOfferId != null) {
      final counter = service.counterOffer(
        league,
        counterOfferId,
        proposal,
        actingTeamId: own.id,
      );
      if (counter.changed) {
        await ref
            .read(gameControllerProvider.notifier)
            .updateLeague((_) => counter.league);
      }
      if (!mounted) return;
      setState(
        () => _status = counter.changed
            ? l10n.trade_success
            : counter.validation.reason ?? l10n.trade_notAllowed,
      );
      return;
    }
    final validation = service.validateLeague(league, proposal);
    if (!validation.ok) {
      final rejected = service.submitLeague(
        league,
        proposal,
        aiAccepted: false,
      );
      await ref
          .read(gameControllerProvider.notifier)
          .updateLeague((_) => rejected.league);
      if (!mounted) return;
      setState(
        () => _status = rejected.validation.reason ?? l10n.trade_notAllowed,
      );
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
      league: league,
      currentYear: currentYear,
      saveSeed: ref.read(gameControllerProvider).value?.saveSeed ?? 0,
      week: league.currentWeek,
    );
    final submission = service.submitLeague(
      league,
      proposal,
      aiAccepted: aiAccepts,
    );
    await ref
        .read(gameControllerProvider.notifier)
        .updateLeague((_) => submission.league);
    if (!mounted) return;
    if (submission.executed) {
      setState(() {
        _status = l10n.trade_success;
        _ownPlayerId = null;
        _ownPickId = null;
        _ownRightsId = null;
        _theirPlayerId = null;
        _theirPickId = null;
        _theirRightsId = null;
      });
    } else {
      setState(
        () => _status = submission.outcome == 'rejected'
            ? l10n.trade_aiRejected
            : submission.validation.reason ?? l10n.trade_executeFailed,
      );
    }
  }
}
