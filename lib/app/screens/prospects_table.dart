part of 'prospects_screen.dart';

mixin _ProspectsTable
    on ConsumerState<ProspectsScreen>, _ProspectsScreenShared {
  // Column widths shared between the header row and data rows so they stay
  // pixel-aligned inside the horizontally scrollable table (styled after
  // development_screen.dart's players tab).
  static const double _colCheckboxWidth = 40;
  static const double _colNameWidth = 110;
  static const double _colFlagWidth = 32;
  static const double _colAgeWidth = 32;
  static const double _colPositionWidth = 32;
  static const double _colMockRankWidth = 40;
  static const double _colTierWidth = 32;
  static const double _colOvrRangeWidth = 64;
  static const double _colProjWidth = 48;
  static const double _colPotentialWidth = 70;
  static const double _colInjWidth = 48;
  static const double _colDetWidth = 48;
  static const double _colRoleWidth = 96;

  double _tableWidth(bool withRoleColumn) =>
      _colCheckboxWidth +
      _colNameWidth +
      _colFlagWidth +
      _colAgeWidth +
      _colPositionWidth +
      _colMockRankWidth +
      _colTierWidth +
      _colOvrRangeWidth +
      _colProjWidth +
      _colPotentialWidth +
      _colInjWidth +
      _colDetWidth +
      (withRoleColumn ? _colRoleWidth : 0) +
      8; //padding

  Widget _buildProspectsTable(
    BuildContext context,
    AppLocalizations l10n,
    List<Prospect> prospects,
    TeamScouting? scouting,
    MockDraftBoard? mockBoard,
    int watchlistLimit,
    int combineLimit,
    bool combineAvailable,
  ) {
    final showRoleColumn = _combineIds.isNotEmpty;
    return SingleChildScrollView(
      controller: _tableScrollController,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _tableWidth(showRoleColumn),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderRow(l10n, showRoleColumn),
              const Divider(height: 1),
              for (final prospect in prospects)
                _buildProspectRow(
                  context,
                  l10n,
                  prospect,
                  scouting,
                  mockBoard,
                  watchlistLimit,
                  combineLimit,
                  combineAvailable,
                  showRoleColumn,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(AppLocalizations l10n, bool showRoleColumn) {
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
    Widget cell(double width, String text) => SizedBox(
      width: width,
      child: Text(text, textAlign: TextAlign.center, style: headerStyle),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: [
          const SizedBox(width: _colCheckboxWidth),
          SizedBox(
            width: _colNameWidth,
            child: Text(l10n.prospects_name, style: headerStyle),
          ),
          cell(_colFlagWidth, ''),
          cell(_colAgeWidth, l10n.prospects_age),
          cell(_colPositionWidth, l10n.prospects_positionShort),
          cell(_colMockRankWidth, l10n.prospects_mockRank),
          cell(_colTierWidth, l10n.prospects_tier),
          cell(_colOvrRangeWidth, l10n.prospects_overallRange),
          cell(_colProjWidth, l10n.prospects_slot),
          cell(_colPotentialWidth, l10n.prospects_stars),
          cell(_colInjWidth, l10n.prospects_injuryShort),
          cell(_colDetWidth, l10n.prospects_determinationShort),
          if (showRoleColumn) cell(_colRoleWidth, l10n.scouting_combineRole),
        ],
      ),
    );
  }

  Widget _buildProspectRow(
    BuildContext context,
    AppLocalizations l10n,
    Prospect prospect,
    TeamScouting? scouting,
    MockDraftBoard? mockBoard,
    int watchlistLimit,
    int combineLimit,
    bool combineAvailable,
    bool showRoleColumn,
  ) {
    final knowledge = scouting?.forProspect(prospect.id);
    final mockRank = mockBoard?.displayedRank[prospect.id];
    final previousMockRank = mockBoard?.previousDisplayedRank[prospect.id];
    final watched = _selectedIds.contains(prospect.id);
    final assigned = _combineIds.contains(prospect.id);
    final canSelect = _combineMode
        ? assigned || _combineIds.length < combineLimit
        : watched || _selectedIds.length < watchlistLimit;
    final showCombinedRole = !combineAvailable && assigned;
    final textStyle = Theme.of(context).textTheme.bodySmall;
    final isHighlighted = prospect.id == _highlightedProspectId;

    Widget cell(double width, String text) => SizedBox(
      width: width,
      child: Text(text, textAlign: TextAlign.center, style: textStyle),
    );

    return Material(
      key: _rowKey(prospect.id),
      color: isHighlighted
          ? Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.5)
          : Colors.transparent,
      child: InkWell(
        onTap: () => _showProspectDetail(
          context,
          l10n,
          prospect,
          scouting,
          showOptimalRole: showCombinedRole,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Row(
            children: [
              SizedBox(
                width: _colCheckboxWidth,
                child: Checkbox(
                  value: _combineMode ? assigned : watched,
                  onChanged: _combineMode
                      ? (!combineAvailable || !canSelect)
                            ? null
                            : (value) => _toggleCombine(prospect.id, value)
                      : canSelect
                      ? (value) => _toggleWatchlist(prospect.id, value)
                      : null,
                ),
              ),
              SizedBox(
                width: _colNameWidth,
                child: Text(
                  prospect.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(
                width: _colFlagWidth,
                child: Center(child: NationalityFlagIcon(prospect.nationality)),
              ),
              cell(_colAgeWidth, '${prospect.age}'),
              cell(_colPositionWidth, prospect.position.code),
              SizedBox(
                width: _colMockRankWidth,
                child: _buildMockRankCell(mockRank, previousMockRank),
              ),
              cell(_colTierWidth, _tierLabel(knowledge?.tier)),
              cell(
                _colOvrRangeWidth,
                _rangeLabel(
                  knowledge?.estimatedOvrMin,
                  knowledge?.estimatedOvrMax,
                ),
              ),
              cell(_colProjWidth, _slotLabel(l10n, knowledge?.estimatedSlot)),
              SizedBox(
                width: _colPotentialWidth,
                child: _buildPotentialEstimate(l10n, prospect, knowledge),
              ),
              cell(
                _colInjWidth,
                knowledge?.injuryProneKnown == true
                    ? _rangeLabel(
                        knowledge?.injuryProneMin,
                        knowledge?.injuryProneMax,
                      )
                    : _unknownValue,
              ),
              cell(
                _colDetWidth,
                knowledge?.determinationKnown == true
                    ? _rangeLabel(
                        knowledge?.determinationMin,
                        knowledge?.determinationMax,
                      )
                    : _unknownValue,
              ),
              if (showRoleColumn)
                cell(
                  _colRoleWidth,
                  showCombinedRole
                      ? assignedRoleLabel(context, prospect.optimalRole)
                      : _unknownValue,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
