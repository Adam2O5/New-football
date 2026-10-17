part of 'free_agency_screen.dart';

mixin _FreeAgencyMarketSections
    on ConsumerState<FreeAgencyScreen>, _FreeAgencyScreenShared {
  Widget _marketStatusCard(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
  ) {
    final window = _marketService.windowAt(league);
    final label = switch (window) {
      ContractMarketWindow.closed => l10n.market_closed,
      ContractMarketWindow.extensions => l10n.market_extensions,
      ContractMarketWindow.freeAgencyPhaseI => l10n.market_phaseI,
      ContractMarketWindow.freeAgencyPhaseII => l10n.market_phaseII,
    };
    final hourly = window == ContractMarketWindow.freeAgencyPhaseI;
    final hour = (league.currentHour ?? 1).clamp(
      1,
      BalanceConfig.defaults.contracts.hoursPerDay,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.market_status,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(label: Text(label)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${l10n.market_date(league.currentDay, league.currentWeek)}'
              '${hourly ? '\n${l10n.market_hour(hour, BalanceConfig.defaults.contracts.hoursPerDay)}' : ''}',
            ),
            if (hourly) ...[
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: _isAdvancingHour ? null : () => _advanceHour(l10n),
                icon: _isAdvancingHour
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.skip_next),
                label: Text(l10n.market_advanceHour),
              ),
            ] else if (window == ContractMarketWindow.closed) ...[
              const SizedBox(height: 6),
              Text(
                l10n.market_noWindow,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(
    BuildContext context,
    AppLocalizations l10n,
    Team team,
    CapSnapshot snapshot,
  ) {
    final full = team.roster.length >= BalanceConfig.defaults.roster.maxSize;
    return Card(
      color: full
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.freeAgency_title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.freeAgency_capSpace(formatMoney(context, snapshot.capSpace)),
            ),
            Text(l10n.freeAgency_rosterUsage(team.roster.length)),
            if (snapshot.capSpace < 0) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.warning_amber, size: 18),
                  const SizedBox(width: 6),
                  Expanded(child: Text(l10n.finance_capWarning)),
                ],
              ),
            ],
            if (full) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.warning_amber, size: 18),
                  const SizedBox(width: 6),
                  Expanded(child: Text(l10n.freeAgency_rosterFull)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _staffMarketSection(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    Team team,
  ) {
    // Keep the existing role order, while delegating ordering inside each role
    // to the shared raw-rating sorter. This also filters unsupported records.
    final candidates = <StaffMember>[
      for (final role in StaffRole.values)
        ...StaffPresentation.sortStaffCandidates(
          league.canonicalStaffFreeAgents,
          role,
        ),
    ];
    final canOffer = _canSubmitStaffOffer(league, team);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.market_staffCandidates,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (candidates.isEmpty)
              Text(l10n.staff_noCandidates)
            else
              ...candidates.map((candidate) {
                final candidateView = StaffPresentation.viewForMember(
                  candidate,
                );
                final slotView = StaffPresentation.viewForSlot(
                  team.staff.member(candidate.role),
                  candidate.role,
                );
                final expectedSalary = _staffService.expectedSalary(candidate);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(candidate.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${candidate.role.name} · '
                        '${formatMoney(context, expectedSalary)}',
                      ),
                      StaffRatingStars(
                        key: ValueKey<String>(
                          'staff-candidate-rating-${candidate.id}',
                        ),
                        slot: candidateView,
                        keyPrefix: 'staff-candidate-rating-${candidate.id}',
                      ),
                    ],
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: slotView.isEmpty && canOffer
                        ? () => _submitStaffMarketOffer(l10n, league, candidate)
                        : null,
                    child: Text(l10n.market_staffOffer),
                  ),
                );
              }),
            if (!canOffer &&
                _marketService.phaseAt(league) ==
                    NegotiationPhase.freeAgencyPhaseI &&
                league.hourlyStaffOfferUsed)
              Text(l10n.market_noWindow),
          ],
        ),
      ),
    );
  }

  Widget _draftedRightsSection(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    Team team,
  ) {
    final rights = league.draftedRights
        .where((right) => right.ownerTeamId == team.id)
        .toList();
    if (rights.isEmpty) return const SizedBox.shrink();
    final full = team.roster.length >= BalanceConfig.defaults.roster.maxSize;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.market_draftedRights,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ...rights.map(
              (right) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(right.player.name),
                subtitle: Text(
                  '${formatMoney(context, right.player.contract.salary)} · pick ${right.pickNumber}',
                ),
                trailing: FilledButton.tonal(
                  onPressed: full
                      ? null
                      : () async {
                          final ok = await ref
                              .read(gameControllerProvider.notifier)
                              .signDraftedRight(right.id);
                          if (mounted) {
                            setState(
                              () => _status = ok
                                  ? l10n.contract_accepted
                                  : l10n.market_rosterFull,
                            );
                          }
                        },
                  child: Text(l10n.market_signRights),
                ),
              ),
            ),
            if (full) Text(l10n.market_rosterFull),
          ],
        ),
      ),
    );
  }

  List<Widget> _pendingFinalizations(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    String teamId,
  ) {
    final pending = league.negotiations
        .where(
          (item) =>
              item.teamId == teamId &&
              item.subjectKind == NegotiationSubjectKind.player &&
              (item.phase == NegotiationPhase.freeAgencyPhaseI ||
                  item.phase == NegotiationPhase.freeAgencyPhaseII) &&
              item.status == NegotiationStatus.pendingFinalization,
        )
        .toList();
    if (pending.isEmpty) return const [];
    return [
      const SizedBox(height: 12),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.pending_actions),
                title: Text(l10n.contract_pendingFinalization),
              ),
              ...pending.map((negotiation) {
                final canFinalize = !_deadlinePassedNegotiation(
                  league,
                  negotiation,
                );
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_subjectName(league, negotiation.subjectId)),
                  subtitle: Text(
                    '${formatMoney(context, negotiation.lastOffer.salary)} × ${negotiation.lastOffer.years} · '
                    '${l10n.market_round(negotiation.round)} · '
                    '${l10n.market_score(negotiation.offerScore.toStringAsFixed(1))} · '
                    '${l10n.market_deadline(negotiation.expiryDay, negotiation.expiryHour, negotiation.expiryWeek)}',
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: canFinalize
                        ? () => _finalizeNegotiation(l10n, negotiation.id)
                        : null,
                    child: Text(l10n.contract_finalize),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    ];
  }
}
