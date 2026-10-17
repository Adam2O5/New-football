part of 'contract_screen.dart';

mixin _ContractScreenNegotiations
    on ConsumerState<ContractScreen>, _ContractScreenShared {
  Widget _negotiationsSection(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    String teamId,
  ) {
    final negotiations =
        league.negotiations
            .where(
              (item) =>
                  item.teamId == teamId &&
                  item.subjectKind == NegotiationSubjectKind.player,
            )
            .toList()
          ..sort(
            (a, b) => _negotiationClock(b).compareTo(_negotiationClock(a)),
          );
    if (negotiations.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(top: 12),
        child: ListTile(
          leading: const Icon(Icons.handshake_outlined),
          title: Text(l10n.market_negotiations),
          subtitle: Text(l10n.market_noNegotiations),
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.market_negotiations,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...negotiations.map(
              (negotiation) =>
                  _negotiationCard(context, l10n, league, negotiation),
            ),
          ],
        ),
      ),
    );
  }

  Widget _negotiationCard(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    ContractNegotiation negotiation,
  ) {
    final deadlinePassed = _deadlinePassed(league, negotiation);
    final canFinalize =
        negotiation.status == NegotiationStatus.pendingFinalization &&
        !deadlinePassed;
    final canRespond =
        negotiation.status == NegotiationStatus.counter &&
        !deadlinePassed &&
        _marketService.phaseAt(league) == negotiation.phase;
    final offer = negotiation.counterOffer ?? negotiation.lastOffer;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _subjectName(league, negotiation.subjectId),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Chip(label: Text(_statusLabel(l10n, negotiation.status))),
            ],
          ),
          const SizedBox(height: 4),
          Text(_negotiationSubtitle(context, l10n, league, negotiation)),
          if (negotiation.status == NegotiationStatus.waiting &&
              negotiation.waitingUntilWeek != null &&
              negotiation.waitingUntilDay != null) ...[
            const SizedBox(height: 4),
            Text(
              '${l10n.contract_waiting} · ${l10n.market_deadline(negotiation.waitingUntilDay!, negotiation.waitingUntilHour ?? 0, negotiation.waitingUntilWeek!)}',
            ),
          ],
          if (deadlinePassed && !negotiation.isTerminal) ...[
            const SizedBox(height: 4),
            Text(
              l10n.market_statusExpired,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (canFinalize) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: () => _finalize(l10n, negotiation.id),
                child: Text(l10n.contract_finalize),
              ),
            ),
          ],
          if (canRespond) ...[
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed: () =>
                      _respondToCounter(l10n, negotiation, accept: false),
                  child: Text(l10n.inbox_actionReject),
                ),
                OutlinedButton(
                  onPressed: () => _editCounter(l10n, negotiation),
                  child: Text(l10n.contract_counterEdit),
                ),
                FilledButton.tonal(
                  onPressed: () => _respondToCounter(
                    l10n,
                    negotiation,
                    accept: true,
                    offer: ContractOffer(
                      salary: offer.salary,
                      years: offer.years,
                      exception: offer.exception,
                      rookiePickSlot: offer.rookiePickSlot,
                    ),
                  ),
                  child: Text(l10n.inbox_actionAccept),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, NegotiationStatus status) {
    return switch (status) {
      NegotiationStatus.active => l10n.market_statusActive,
      NegotiationStatus.waiting => l10n.contract_waiting,
      NegotiationStatus.pendingFinalization =>
        l10n.contract_pendingFinalization,
      NegotiationStatus.counter => l10n.market_statusCounter,
      NegotiationStatus.rejected => l10n.contract_rejected,
      NegotiationStatus.hardRejected => l10n.market_statusHardRejected,
      NegotiationStatus.completed => l10n.market_statusCompleted,
      NegotiationStatus.cancelled => l10n.market_statusCancelled,
    };
  }

  String _subjectName(LeagueState league, String id) {
    for (final player in league.freeAgents) {
      if (player.id == id) return player.name;
    }
    for (final player in league.playerTeam?.roster ?? const <Player>[]) {
      if (player.id == id) return player.name;
    }
    return id;
  }

  String _negotiationSubtitle(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    ContractNegotiation negotiation,
  ) {
    final player = _playerById(league, negotiation.subjectId);
    final expectedSalary = player == null
        ? null
        : _contractService.expectedSalary(
            player,
            currentTeamStatus:
                negotiation.phase == NegotiationPhase.contractExtension
                ? _teamStatus(league, negotiation.teamId)
                : TeamStatus.pretender,
          );
    final expectedLength = player == null
        ? null
        : _contractService.expectedLength(
            player,
            currentTeamStatus:
                negotiation.phase == NegotiationPhase.contractExtension
                ? _teamStatus(league, negotiation.teamId)
                : TeamStatus.pretender,
          );
    final details = <String>[
      l10n.market_round(negotiation.round),
      l10n.market_score(negotiation.offerScore.toStringAsFixed(1)),
      l10n.market_deadline(
        negotiation.expiryDay,
        negotiation.expiryHour,
        negotiation.expiryWeek,
      ),
      if (expectedSalary != null)
        l10n.market_expectedSalary(formatMoney(context, expectedSalary)),
      if (expectedLength != null) l10n.market_expectedLength(expectedLength),
      '${l10n.market_currentOffer}: ${formatMoney(context, negotiation.lastOffer.salary)} × ${negotiation.lastOffer.years}',
    ];
    return details.join(' · ');
  }

  int _negotiationClock(ContractNegotiation negotiation) =>
      (((negotiation.seasonYear * 60 + negotiation.week) * 7 +
              negotiation.day) *
          BalanceConfig.defaults.contracts.hoursPerDay) +
      negotiation.hour;

  bool _deadlinePassed(LeagueState league, ContractNegotiation negotiation) {
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
