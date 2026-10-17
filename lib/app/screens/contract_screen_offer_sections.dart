part of 'contract_screen.dart';

mixin _ContractScreenOfferSections
    on ConsumerState<ContractScreen>, _ContractScreenShared {
  Widget _marketStatusCard(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
  ) {
    final window = _marketService.windowAt(league);
    final phaseLabel = switch (window) {
      ContractMarketWindow.closed => l10n.market_closed,
      ContractMarketWindow.extensions => l10n.market_extensions,
      ContractMarketWindow.freeAgencyPhaseI => l10n.market_phaseI,
      ContractMarketWindow.freeAgencyPhaseII => l10n.market_phaseII,
    };
    final hourly =
        window == ContractMarketWindow.extensions ||
        window == ContractMarketWindow.freeAgencyPhaseI;
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
                Chip(label: Text(phaseLabel)),
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

  Widget _offerPreviewCard(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    Team team,
    Player player,
  ) {
    final isExtension = _target == _Target.ownExpiring;
    final currentStatus = _teamStatus(league, team.id);
    final expectedSalary = _expectedSalary(
      league,
      team,
      player,
      isExtension: isExtension,
    );
    final expectedLength = _contractService.expectedLength(
      player,
      currentTeamStatus: isExtension ? currentStatus : TeamStatus.pretender,
    );
    final salary = int.tryParse(_salaryCtrl.text.trim());
    final years = int.tryParse(_yearsCtrl.text.trim());
    final score = salary == null || years == null || years < 1
        ? null
        : _contractService.playerOfferScore(
            player,
            ContractOffer(salary: salary, years: years),
            offeringTeamStatus: currentStatus,
            currentTeamStatus: isExtension
                ? currentStatus
                : TeamStatus.pretender,
            cfo: team.staff.cfo,
          );

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.market_offerPreview}: ${player.name}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.market_expectedSalary(formatMoney(context, expectedSalary)),
            ),
            Text(l10n.market_expectedLength(expectedLength)),
            Text(
              score == null
                  ? l10n.contract_invalidOffer
                  : l10n.market_score(score.toStringAsFixed(1)),
            ),
          ],
        ),
      ),
    );
  }
}
