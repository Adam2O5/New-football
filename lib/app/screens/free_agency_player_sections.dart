part of 'free_agency_screen.dart';

mixin _FreeAgencyPlayerSections
    on ConsumerState<FreeAgencyScreen>, _FreeAgencyScreenShared {
  Widget _filters(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.freeAgency_search,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                DropdownButton<Position?>(
                  value: _positionFilter,
                  hint: Text(l10n.freeAgency_position),
                  items: [
                    DropdownMenuItem<Position?>(
                      value: null,
                      child: Text(l10n.freeAgency_allPositions),
                    ),
                    ...Position.values.map(
                      (position) => DropdownMenuItem<Position?>(
                        value: position,
                        child: Text(position.code),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _positionFilter = value),
                ),
                DropdownButton<int>(
                  value: _minimumOvr,
                  items: [0, 60, 70, 80, 90]
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(
                            value == 0
                                ? '${l10n.freeAgency_minOvr}: ${l10n.freeAgency_any}'
                                : '${l10n.freeAgency_minOvr}: $value',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _minimumOvr = value);
                  },
                ),
                DropdownButton<_FreeAgencySort>(
                  value: _sort,
                  items: [
                    DropdownMenuItem(
                      value: _FreeAgencySort.overall,
                      child: Text(l10n.freeAgency_sortOvr),
                    ),
                    DropdownMenuItem(
                      value: _FreeAgencySort.name,
                      child: Text(l10n.freeAgency_sortName),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _sort = value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Player> _filteredFreeAgents(List<Player> source) {
    final query = _searchController.text.trim().toLowerCase();
    final result = source.where((player) {
      if (query.isNotEmpty && !player.name.toLowerCase().contains(query)) {
        return false;
      }
      if (_positionFilter != null && player.position != _positionFilter) {
        return false;
      }
      if (player.overall().round() < _minimumOvr) return false;
      return true;
    }).toList();

    result.sort((a, b) {
      return switch (_sort) {
        _FreeAgencySort.overall => b.overall().compareTo(a.overall()),
        _FreeAgencySort.name => a.name.compareTo(b.name),
      };
    });
    return result;
  }

  Widget _playerTile(
    BuildContext context,
    AppLocalizations l10n,
    Player player,
    String? selectedId,
    LeagueState league,
    Team team,
  ) {
    final selected = player.id == selectedId;
    return Card(
      color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        leading: CircleAvatar(child: Text(player.position.code)),
        title: Text(player.name),
        subtitle: Text(
          l10n.freeAgency_playerSubtitle(
            player.position.code,
            player.overall().round(),
            formatMoney(
              context,
              _contractService.expectedSalary(
                player,
                currentTeamStatus: TeamStatus.pretender,
              ),
            ),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => context.push('/game/player/${player.id}'),
        ),
        onTap: () {
          setState(() {
            _selectedId = player.id;
            _salaryController.text = _contractService
                .expectedSalary(player, currentTeamStatus: TeamStatus.pretender)
                .toString();
            _yearsController.text = _contractService
                .expectedLength(player, currentTeamStatus: TeamStatus.pretender)
                .toString();
            _status = null;
          });
        },
      ),
    );
  }

  Widget _offerCard(
    BuildContext context,
    AppLocalizations l10n,
    Player player,
    LeagueState league,
    Team team,
  ) {
    final salary = int.tryParse(_salaryController.text.trim());
    final years = int.tryParse(_yearsController.text.trim());
    final score = salary == null || years == null || years < 1
        ? null
        : _contractService.playerOfferScore(
            player,
            ContractOffer(salary: salary, years: years),
            offeringTeamStatus: _teamStatus(league, team.id),
            currentTeamStatus: TeamStatus.pretender,
            cfo: team.staff.cfo,
          );
    final qualifying = _activeQualifyingOffer(league, player.id);
    final isOtherTeamRfa =
        qualifying != null && qualifying.ownerTeamId != team.id;
    final canOffer = _canSubmitPlayerOffer(league, team);
    final canOfferSheet = isOtherTeamRfa && _canSubmitOfferSheet(league, team);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.freeAgency_contractHeader(player.name),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.freeAgency_marketDemand(
                formatMoney(
                  context,
                  _contractService.expectedSalary(
                    player,
                    currentTeamStatus: TeamStatus.pretender,
                  ),
                ),
              ),
            ),
            if (score != null) ...[
              const SizedBox(height: 4),
              Text(l10n.market_score(score.toStringAsFixed(1))),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.freeAgency_offerSalary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _yearsController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.freeAgency_offerYears,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: canOffer
                    ? () => _submitOffer(l10n, league, team)
                    : null,
                child: Text(l10n.freeAgency_submitOffer),
              ),
            ),
            if (canOfferSheet) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _submitOfferSheet(l10n, league, team),
                  child: Text(l10n.market_offerSheets),
                ),
              ),
            ],
            if (!canOffer && _marketService.phaseAt(league) == null) ...[
              const SizedBox(height: 8),
              Text(l10n.market_noWindow),
            ],
          ],
        ),
      ),
    );
  }
}
