part of 'free_agency_screen.dart';

mixin _FreeAgencyRfaSection
    on ConsumerState<FreeAgencyScreen>, _FreeAgencyScreenShared {
  Widget _rfaSection(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    Team team,
  ) {
    final activeOffers = league.rfaQualifyingOffers
        .where((offer) => offer.ownerTeamId == team.id && !offer.declined)
        .toList();
    final candidates = _qualifyingCandidates(league, team);
    final sheets =
        league.rfaOfferSheets
            .where((sheet) => sheet.originalTeamId == team.id)
            .toList()
          ..sort((a, b) => _sheetClock(a).compareTo(_sheetClock(b)));
    if (activeOffers.isEmpty && candidates.isEmpty && sheets.isEmpty) {
      return const SizedBox.shrink();
    }

    final canSubmitQO = _canSubmitQualifyingOffer(league);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.market_qo,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (candidates.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(l10n.market_qoEligible),
              ...candidates.map(
                (player) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(player.name),
                  subtitle: Text(
                    l10n.market_qoMinimum(
                      formatMoney(
                        context,
                        _marketService.qualifyingOfferMinimum(player),
                      ),
                    ),
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: canSubmitQO
                        ? () => _submitQualifyingOffer(l10n, player)
                        : null,
                    child: Text(l10n.market_submitQO),
                  ),
                ),
              ),
            ],
            if (activeOffers.isNotEmpty) ...[
              const Divider(),
              Text(
                l10n.market_qoSubmitted,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              ...activeOffers.map((offer) {
                final player = _playerById(league, offer.playerId);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(player?.name ?? offer.playerId),
                  subtitle: Text(
                    '${formatMoney(context, offer.salary)} × ${offer.years}',
                  ),
                  trailing: TextButton(
                    onPressed: canSubmitQO
                        ? () => _declineQualifyingOffer(l10n, offer.playerId)
                        : null,
                    child: Text(l10n.market_release),
                  ),
                );
              }),
            ],
            if (sheets.isNotEmpty) ...[
              const Divider(),
              Text(
                l10n.market_offerSheets,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              ...sheets.map(
                (sheet) => _offerSheetTile(context, l10n, league, sheet),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _offerSheetTile(
    BuildContext context,
    AppLocalizations l10n,
    LeagueState league,
    RfaOfferSheet sheet,
  ) {
    final player = _playerById(league, sheet.playerId);
    final offeringTeam = league.teamById(sheet.offeringTeamId);
    final canAct = _canActOnOfferSheet(league, sheet);
    final status = sheet.matched
        ? l10n.contract_accepted
        : sheet.declined
        ? l10n.market_release
        : null;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(player?.name ?? sheet.playerId),
      subtitle: Text(
        '${formatMoney(context, sheet.salary)} × ${sheet.years} · '
        '${l10n.market_deadline(sheet.expiryDay, sheet.expiryHour, sheet.expiryWeek)}'
        '${offeringTeam == null ? '' : '\n${l10n.market_offerSheetFrom(offeringTeam.name)}'}',
      ),
      trailing: status != null
          ? Chip(label: Text(status))
          : canAct
          ? Wrap(
              spacing: 4,
              children: [
                FilledButton.tonal(
                  onPressed: () => _matchOfferSheet(l10n, sheet),
                  child: Text(l10n.market_match),
                ),
                TextButton(
                  onPressed: () => _declineOfferSheet(l10n, sheet),
                  child: Text(l10n.market_release),
                ),
              ],
            )
          : Text(l10n.market_noWindow),
    );
  }
}
