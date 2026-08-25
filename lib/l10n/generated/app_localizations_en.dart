// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'New Football';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get stat_ovr => 'OVR';

  @override
  String get stat_form => 'Form';

  @override
  String get stat_cond => 'Cond';

  @override
  String get stat_pv => 'PV';

  @override
  String get stat_pot => 'Pot.';

  @override
  String get stat_height => 'Height';

  @override
  String money_million(String value) {
    return '${value}M';
  }

  @override
  String money_thousand(String value) {
    return '${value}K';
  }

  @override
  String get day_mon => 'Mon';

  @override
  String get day_tue => 'Tue';

  @override
  String get day_wed => 'Wed';

  @override
  String get day_thu => 'Thu';

  @override
  String get day_fri => 'Fri';

  @override
  String get day_sat => 'Sat';

  @override
  String get day_sun => 'Sun';

  @override
  String get seasonPhase_preseason => 'Preseason';

  @override
  String get seasonPhase_regular => 'Regular season';

  @override
  String get seasonPhase_playIn => 'Play-in';

  @override
  String get seasonPhase_playoff => 'Playoffs';

  @override
  String get seasonPhase_draft => 'Draft';

  @override
  String get seasonPhase_offseason => 'Offseason';

  @override
  String get matchEvent_goal => 'Goal';

  @override
  String get matchEvent_yellowCard => 'Yellow card';

  @override
  String get matchEvent_redCard => 'Red card';

  @override
  String get matchEvent_minorInjury => 'Minor injury';

  @override
  String get matchEvent_majorInjury => 'Major injury';

  @override
  String get matchEvent_substitution => 'Substitution';

  @override
  String get matchEvent_scoredPenalty => 'Penalty scored';

  @override
  String get matchEvent_missedPenalty => 'Penalty missed';

  @override
  String get matchEvent_halfTime => 'Half-time';

  @override
  String get matchEvent_fullTime => 'Full-time';

  @override
  String get matchEvent_foul => 'Foul';

  @override
  String get messageType_injury => 'Injury';

  @override
  String get messageType_retirementPlayer => 'Player retirement';

  @override
  String get messageType_retirementStaff => 'Staff departure';

  @override
  String get messageType_staffGrowth => 'Staff growth';

  @override
  String get messageType_award => 'Award';

  @override
  String get messageType_lottery => 'Draft lottery';

  @override
  String get messageType_scoutReport => 'Scout report';

  @override
  String get messageType_combine => 'Combine';

  @override
  String get messageType_mockDraft => 'Mock draft';

  @override
  String get messageType_draftPick => 'Draft pick';

  @override
  String get messageType_contractOffer => 'Contract offer';

  @override
  String get messageType_contractSigned => 'Contract signed';

  @override
  String get messageType_trade => 'Trade';

  @override
  String get messageType_walkover => 'Walkover';

  @override
  String get messageType_matchPreview => 'Match preview';

  @override
  String get messageType_matchResult => 'Match result';

  @override
  String get messageType_atmosphere => 'Team atmosphere';

  @override
  String get messageType_calendar => 'Calendar';

  @override
  String get messageType_system => 'System';

  @override
  String get notificationLevel_auto => 'Automatic';

  @override
  String get notificationLevel_important => 'Important';

  @override
  String get notificationLevel_normal => 'Normal';

  @override
  String get notificationLevel_muted => 'Muted';

  @override
  String get tempo_slow => 'Slow';

  @override
  String get tempo_balanced => 'Balanced';

  @override
  String get tempo_fast => 'Fast';

  @override
  String get pressing_low => 'Low';

  @override
  String get pressing_medium => 'Medium';

  @override
  String get pressing_high => 'High';

  @override
  String get pressing_gegenpressing => 'Gegenpressing';

  @override
  String get defensiveLine_deep => 'Deep';

  @override
  String get defensiveLine_normal => 'Normal';

  @override
  String get defensiveLine_high => 'High';

  @override
  String get attackWidth_narrow => 'Narrow';

  @override
  String get attackWidth_balanced => 'Balanced';

  @override
  String get attackWidth_wide => 'Wide';

  @override
  String get mainMenu_subtitle => 'NBA-style league manager';

  @override
  String get mainMenu_newGame => 'New game';

  @override
  String get mainMenu_loadGame => 'Load';

  @override
  String get mainMenu_settings => 'Settings';

  @override
  String get mainMenu_exitGame => 'Exit game';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_language_polish => 'Polski';

  @override
  String get settings_language_english => 'English';

  @override
  String get newGame_title => 'New game';

  @override
  String get newGame_defaultSaveName => 'My career';

  @override
  String get newGame_missingFields => 'Enter a save name and select a team';

  @override
  String get newGame_createFailed => 'Failed to create the game';

  @override
  String get newGame_saveName => 'Save name';

  @override
  String get newGame_difficulty => 'Difficulty';

  @override
  String get newGame_difficultyNormal => 'Normal';

  @override
  String get newGame_difficultyHard => 'Hard';

  @override
  String get newGame_chooseTeam => 'Choose your team';

  @override
  String get newGame_start => 'Start career';

  @override
  String get newGame_teamSelected => 'Selected';

  @override
  String get newGame_teamNotSelected => 'Not selected';

  @override
  String newGame_teamSemantics(
    String name,
    String city,
    String conference,
    String state,
  ) {
    return '$name, $city, $conference, $state';
  }

  @override
  String get loadGame_title => 'Load game';

  @override
  String loadGame_error(String error) {
    return 'Error: $error';
  }

  @override
  String get loadGame_empty => 'No saves found';

  @override
  String loadGame_subtitle(String teamName, int year, String phase) {
    return '$teamName · Season $year · $phase';
  }

  @override
  String get loadGame_loadFailed => 'Failed to load save';

  @override
  String loadGame_incompatibleOlder(Object currentVersion, Object version) {
    return 'This save is from an older version ($version); version $currentVersion is required.';
  }

  @override
  String loadGame_incompatibleNewer(Object currentVersion, Object version) {
    return 'This save is from a newer version ($version); version $currentVersion is supported.';
  }

  @override
  String get loadGame_delete => 'Delete';

  @override
  String get loadGame_deleteConfirmTitle => 'Delete save?';

  @override
  String loadGame_deleteConfirmMessage(String name) {
    return 'Save \"$name\" will be permanently deleted.';
  }

  @override
  String get loadGame_deleteFailed => 'Failed to delete save';

  @override
  String get loadGame_load => 'Load';

  @override
  String get loadGame_loadTooltip => 'Load save';

  @override
  String get loadGame_deleteTooltip => 'Delete save';

  @override
  String get loadGame_duplicate => 'Duplicate';

  @override
  String get loadGame_duplicateTooltip => 'Create a copy of this save';

  @override
  String get loadGame_rename => 'Rename';

  @override
  String get loadGame_renameTooltip => 'Rename save';

  @override
  String get loadGame_renameTitle => 'Rename save';

  @override
  String loadGame_renameMessage(String name) {
    return 'Enter a new name for the save \"$name\".';
  }

  @override
  String get loadGame_renameLabel => 'Save name';

  @override
  String get loadGame_renameHint => 'Enter a name';

  @override
  String get loadGame_renameConfirm => 'Rename';

  @override
  String get loadGame_nameEmpty => 'The save name cannot be empty.';

  @override
  String get loadGame_nameTaken => 'That save name is already in use.';

  @override
  String get loadGame_nameSame =>
      'Choose a different name from the current one.';

  @override
  String loadGame_duplicateSuccess(String name) {
    return 'Save copy \"$name\" created.';
  }

  @override
  String loadGame_renameSuccess(String name) {
    return 'Save renamed to \"$name\".';
  }

  @override
  String get loadGame_duplicateFailed => 'Could not create a copy of the save.';

  @override
  String get loadGame_renameFailed => 'Could not rename the save.';

  @override
  String get loadGame_readFailed => 'Could not read the saves. Try again.';

  @override
  String get loadGame_indexReadFailed =>
      'Could not read the save list. Try again.';

  @override
  String get loadGame_sourceUnavailable => 'The save file is unavailable.';

  @override
  String get loadGame_invalidSerializedSave => 'The save file is invalid.';

  @override
  String get loadGame_writeFailed => 'Could not save the changes.';

  @override
  String get loadGame_sizeUnavailable => 'Size unavailable';

  @override
  String get loadGame_ambiguousWrite =>
      'The operation result could not be confirmed. Check the save list and try again.';

  @override
  String get loadGame_lastSaveDate => 'Last saved';

  @override
  String get loadGame_saveSize => 'Save size';

  @override
  String get loadGame_schemaCompatible => 'Compatible schema';

  @override
  String get loadGame_schemaOlder => 'Older schema version';

  @override
  String get loadGame_schemaNewer => 'Newer schema version';

  @override
  String loadGame_loadSemantics(String name) {
    return 'Load save \"$name\"';
  }

  @override
  String loadGame_deleteSemantics(String name) {
    return 'Delete save \"$name\"';
  }

  @override
  String loadGame_duplicateSemantics(String name) {
    return 'Create a copy of save \"$name\"';
  }

  @override
  String loadGame_renameSemantics(String name) {
    return 'Rename save \"$name\"';
  }

  @override
  String get shell_noActiveGame => 'No active game';

  @override
  String get shell_mainMenu => 'Main menu';

  @override
  String get shell_defaultCareerName => 'Career';

  @override
  String get shell_draftTooltip => 'Draft';

  @override
  String get shell_menuTooltip => 'Menu';

  @override
  String get shell_tab_calendar => 'Calendar';

  @override
  String get shell_tab_squad => 'Squad';

  @override
  String get shell_tab_tactics => 'Tactics';

  @override
  String get shell_tab_standings => 'Standings';

  @override
  String get shell_tab_finance => 'Finance';

  @override
  String get shell_tab_inbox => 'Inbox';

  @override
  String get shell_tab_home => 'Home';

  @override
  String get shell_tab_other => 'Other';

  @override
  String get shell_settingsTooltip => 'Settings';

  @override
  String get shell_saveTooltip => 'Save';

  @override
  String get other_title => 'Other';

  @override
  String get other_workInProgress => 'Work in progress';

  @override
  String get other_tradeHistory => 'Trade history';

  @override
  String get tradeHistory_title => 'Trade history';

  @override
  String get tradeHistory_noLeague => 'No active league';

  @override
  String get tradeHistory_empty => 'No trade history recorded.';

  @override
  String get tradeHistory_noMatches => 'No trades match the selected filter.';

  @override
  String get tradeHistory_filter => 'Outcome filter';

  @override
  String get tradeHistory_allOutcomes => 'All outcomes';

  @override
  String get tradeHistory_outcomeAccepted => 'Accepted';

  @override
  String get tradeHistory_outcomeRejected => 'Rejected';

  @override
  String get tradeHistory_outcomeHardRejected => 'Blocked';

  @override
  String get tradeHistory_outcomeExpired => 'Expired';

  @override
  String get tradeHistory_outcomeNtcRefused => 'NTC refused';

  @override
  String get tradeHistory_outcomeCancelled => 'Cancelled';

  @override
  String tradeHistory_date(int season, int week, int day) {
    return 'Season $season, week $week, day $day';
  }

  @override
  String tradeHistory_round(int round) {
    return 'Round $round';
  }

  @override
  String get tradeHistory_reason => 'Reason';

  @override
  String get tradeHistory_ntcProbability => 'NTC consent probability';

  @override
  String tradeHistory_sentBy(String team) {
    return 'Assets from $team';
  }

  @override
  String get tradeHistory_noAssets => 'No assets';

  @override
  String tradeHistory_player(String name) {
    return 'Player: $name';
  }

  @override
  String tradeHistory_pick(int year, int round) {
    return 'Pick: $year, round $round';
  }

  @override
  String tradeHistory_rights(String name) {
    return 'Drafted rights: $name';
  }

  @override
  String tradeHistory_unknownAsset(String type) {
    return 'Asset: $type';
  }

  @override
  String get other_teamOverview => 'Team overview';

  @override
  String get other_finances => 'Finances';

  @override
  String get teamOverview_title => 'Team overview';

  @override
  String get teamOverview_noLeague => 'No active league';

  @override
  String get teamOverview_invalidTeam => 'Player team is not available';

  @override
  String teamOverview_conference(Object conference) {
    return 'Conference: $conference';
  }

  @override
  String get teamOverview_conferenceEurope => 'Europe';

  @override
  String get teamOverview_conferenceRestOfWorld => 'Rest of World';

  @override
  String get teamOverview_standings => 'Standings';

  @override
  String get teamOverview_record => 'Record';

  @override
  String get teamOverview_conferenceRank => 'Conference rank';

  @override
  String get teamOverview_overallRank => 'Overall rank';

  @override
  String get teamOverview_financials => 'Financials';

  @override
  String get teamOverview_payroll => 'Payroll';

  @override
  String get teamOverview_cap => 'Salary cap';

  @override
  String get teamOverview_capSpace => 'Cap space';

  @override
  String get teamOverview_teamState => 'Team state';

  @override
  String get teamOverview_atmosphere => 'Atmosphere';

  @override
  String get teamOverview_chemistry => 'Chemistry';

  @override
  String get teamOverview_atmosphereMult => 'Atmosphere multiplier';

  @override
  String get teamOverview_chemistryMult => 'Chemistry multiplier';

  @override
  String get teamOverview_teamPower => 'Team power';

  @override
  String get teamOverview_expectedRank => 'Expected rank';

  @override
  String get teamOverview_status => 'Status';

  @override
  String get teamOverview_weeklyHistory => 'Weekly history';

  @override
  String get teamOverview_noHistory => 'No history recorded';

  @override
  String get teamOverview_roster => 'Roster';

  @override
  String get teamOverview_staff => 'Staff';

  @override
  String get teamOverview_nextAction => 'Next action';

  @override
  String get teamOverview_action => 'Action';

  @override
  String get teamOverview_nextMatch => 'Next match';

  @override
  String get teamOverview_noNextAction => 'No upcoming action';

  @override
  String get teamOverview_calendarPosition => 'Calendar';

  @override
  String teamOverview_weekDay(Object day, Object week) {
    return 'Week $week, day $day';
  }

  @override
  String get teamOverview_navigation => 'Open screens';

  @override
  String get teamOverview_viewSquad => 'Squad';

  @override
  String get teamOverview_viewStats => 'Statistics';

  @override
  String get teamOverview_viewStaff => 'Staff';

  @override
  String get teamOverview_viewFinance => 'Finance';

  @override
  String get teamOverview_viewSearch => 'Search';

  @override
  String get other_contracts => 'Contracts';

  @override
  String get other_freeAgency => 'Free Agency';

  @override
  String get other_prospects => 'Prospects';

  @override
  String get other_staff => 'Staff';

  @override
  String get other_development => 'Development';

  @override
  String get other_playerStats => 'Player stats';

  @override
  String get other_rewards => 'Rewards';

  @override
  String get other_search => 'Search';

  @override
  String get other_draftHistory => 'Draft history';

  @override
  String get other_rankings => 'Rankings';

  @override
  String get other_watchlist => 'Watchlist';

  @override
  String get home_title => 'Home';

  @override
  String get home_next7days => 'Next 7 days';

  @override
  String get home_conferenceRankLabel => 'Conference rank';

  @override
  String get home_overallRankLabel => 'Overall rank';

  @override
  String get home_record => 'Team record';

  @override
  String get home_lastMatchTitle => 'Last match';

  @override
  String get home_nextMatchTitle => 'Next match';

  @override
  String get home_noPreviousMatch => 'No matches played yet';

  @override
  String get home_noNextMatch => 'No matches scheduled';

  @override
  String get home_simulateUntilNextEvent => 'To next event';

  @override
  String get home_nextActionTitle => 'Next action';

  @override
  String get home_nextEvent => 'event';

  @override
  String get home_readUrgent => 'Read urgent message';

  @override
  String home_simulateHour(int hour) {
    return 'Simulate hour · $hour/10';
  }

  @override
  String get home_simulateToNextMatch => 'Simulate to next match';

  @override
  String get home_simulateUntilEvent => 'Simulate to event';

  @override
  String home_simulateToEvent(String label) {
    return 'Simulate to: $label';
  }

  @override
  String get home_simulateDay => 'Simulate day';

  @override
  String get home_simulateMatch => 'Simulate match';

  @override
  String home_goToEvent(String label) {
    return 'Go to: $label';
  }

  @override
  String home_simulateEvent(String label) {
    return 'Simulate: $label';
  }

  @override
  String home_actionExecuted(String label) {
    return 'Completed: $label';
  }

  @override
  String home_context(int season, String phase, int week, int day) {
    return 'Season $season · $phase · Week $week, day $day';
  }

  @override
  String home_seasonLine(int year) {
    return 'Season $year';
  }

  @override
  String home_phaseLine(String phase) {
    return 'Phase: $phase';
  }

  @override
  String home_weekDayLine(int week, int day) {
    return 'Week $week, day $day';
  }

  @override
  String get squad_noTeam => 'No player team';

  @override
  String squad_sizeLabel(int size, int min, int max) {
    return 'Squad: $size / $min–$max';
  }

  @override
  String squad_rosterCount(int count) {
    return 'Roster count: $count';
  }

  @override
  String squad_rosterMinimum(int minimum) {
    return 'Minimum: $minimum';
  }

  @override
  String squad_rosterMaximum(int maximum) {
    return 'Maximum: $maximum';
  }

  @override
  String get squad_rosterStateInRange => 'In range';

  @override
  String get squad_rosterStateOutOfRange => 'Out of range';

  @override
  String squad_rosterSizeSemantics(
    int count,
    int minimum,
    int maximum,
    String state,
  ) {
    return 'Roster count: $count; minimum: $minimum; maximum: $maximum; state: $state.';
  }

  @override
  String get squad_emptyRoster => 'No players in the roster.';

  @override
  String get squad_statusInjury => 'Active injury';

  @override
  String get squad_statusSuspension => 'Active suspension';

  @override
  String get squad_positionMismatch => 'Position mismatch';

  @override
  String squad_playerRowSemantics(
    String name,
    String position,
    int ovr,
    String form,
    String zone,
  ) {
    return '$name, position $position, OVR $ovr, form $form out of 10, zone $zone';
  }

  @override
  String squad_playerMarkerSemantics(
    String name,
    String position,
    String status,
  ) {
    return '$name, position $position. $status';
  }

  @override
  String squad_zoneFrameSemantics(String zone) {
    return 'Zone: $zone';
  }

  @override
  String squad_positionBadgeSemantics(String position) {
    return 'Position: $position';
  }

  @override
  String squad_ovrBadgeSemantics(int ovr) {
    return 'OVR: $ovr';
  }

  @override
  String squad_formIndicatorSemantics(String form) {
    return 'Form: $form out of 10';
  }

  @override
  String squad_profileAction(String name) {
    return 'Open player profile for $name';
  }

  @override
  String get squad_injury => 'INJURY';

  @override
  String get squad_xiBadge => 'XI';

  @override
  String get squad_bench => 'Bench';

  @override
  String get squad_reserves => 'Reserves';

  @override
  String get squad_tacticsTitle => 'Tactics';

  @override
  String get squad_selectHint =>
      'Select a player, then tap another to swap places';

  @override
  String get squad_cannotFieldInjured => 'An injured player can\'t be fielded';

  @override
  String get squad_swappedPlaces => 'Swapped player places';

  @override
  String get squad_rosterTitle => 'Roster';

  @override
  String get squad_zoneXi => 'XI';

  @override
  String get squad_zoneBench => 'Bench';

  @override
  String get squad_zoneReserves => 'Reserves';

  @override
  String get squad_sortOverall => 'Overall';

  @override
  String get squad_sortAssignedZone => 'Assigned zone';

  @override
  String get squad_sortForm => 'Form';

  @override
  String get squad_sortPosition => 'Position';

  @override
  String substitute_sheetTitle(String name) {
    return 'Substitute for $name';
  }

  @override
  String get substitute_sheetSubtitle => 'Choose a player to swap places with';

  @override
  String get substitute_sheetEmpty => 'No available players to substitute';

  @override
  String get standings_noLeague => 'No league';

  @override
  String get standings_tabEast => 'Europe';

  @override
  String get standings_tabWest => 'Rest of World';

  @override
  String get standings_empty => 'No table';

  @override
  String get standings_col_team => 'Team';

  @override
  String get standings_col_record => 'W-D-L';

  @override
  String get standings_col_points => 'Pts';

  @override
  String get standings_col_diff => '+/−';

  @override
  String get standings_tabPostseason => 'Postseason';

  @override
  String get standings_playIn => 'Play-in';

  @override
  String get standings_playoffs => 'Playoffs';

  @override
  String get standings_notStarted => 'Not started';

  @override
  String get standings_noPostseasonData => 'No postseason data available';

  @override
  String get standings_match7v8 => '7th vs 8th';

  @override
  String get standings_match9v10 => '9th vs 10th';

  @override
  String get standings_playInFinal => 'Play-in final';

  @override
  String get standings_quarterFinals => 'Quarter-finals';

  @override
  String get standings_semiFinals => 'Semi-finals';

  @override
  String get standings_conferenceFinals => 'Conference final';

  @override
  String get standings_leagueFinal => 'League final';

  @override
  String get standings_seriesInProgress => 'Series in progress';

  @override
  String get standings_extraTime => ' (ET)';

  @override
  String standings_shootout(int home, int away) {
    return ' (shootout $home-$away)';
  }

  @override
  String standings_seriesWinner(String team) {
    return 'Winner: $team';
  }

  @override
  String standings_champion(String team) {
    return 'Champion: $team';
  }

  @override
  String get finance_noTeam => 'No player team';

  @override
  String get finance_title => 'Finance';

  @override
  String get finance_dashboardSubtitle =>
      'Salary cap and available funds overview';

  @override
  String get finance_capOverview => 'Salary cap and payroll';

  @override
  String get finance_apronsOverview => 'Aprons';

  @override
  String get finance_cashOverview => 'Club cash';

  @override
  String finance_apronHeadroom(String first, String second) {
    return 'To first apron: $first; to second: $second';
  }

  @override
  String get finance_financialHealth => 'Financial health';

  @override
  String get finance_actions => 'Financial actions';

  @override
  String get finance_payroll => 'Payroll';

  @override
  String get finance_cap => 'Salary cap';

  @override
  String get finance_capSpace => 'Cap space';

  @override
  String get finance_firstApron => 'First apron';

  @override
  String get finance_secondApron => 'Second apron';

  @override
  String get finance_tax => 'Luxury tax';

  @override
  String get finance_cash => 'Cash';

  @override
  String get finance_status => 'Status';

  @override
  String get finance_capStatus_under => 'Under the cap';

  @override
  String get finance_capStatus_over => 'Over the cap';

  @override
  String get finance_trade => 'Trades';

  @override
  String get finance_contracts => 'Contracts / extensions';

  @override
  String get finance_capWarning => 'Payroll is above the salary cap';

  @override
  String get finance_capHealthy => 'Payroll is within the salary cap';

  @override
  String get freeAgency_title => 'Free Agency';

  @override
  String get freeAgency_noTeam => 'No player team';

  @override
  String get freeAgency_search => 'Search by name';

  @override
  String get freeAgency_position => 'Position';

  @override
  String get freeAgency_allPositions => 'All positions';

  @override
  String get freeAgency_minOvr => 'Min OVR';

  @override
  String get freeAgency_any => 'Any';

  @override
  String get freeAgency_sort => 'Sort';

  @override
  String get freeAgency_sortOvr => 'Overall';

  @override
  String get freeAgency_sortName => 'Name';

  @override
  String freeAgency_poolCount(Object count) {
    return 'Available free agents: $count';
  }

  @override
  String freeAgency_rosterUsage(Object count) {
    return 'Roster: $count/30';
  }

  @override
  String get freeAgency_empty => 'No free agents match the filters';

  @override
  String freeAgency_playerSubtitle(Object ovr, Object position, Object salary) {
    return '$position · OVR $ovr · Market salary: $salary';
  }

  @override
  String freeAgency_contractHeader(Object name) {
    return 'Offer for $name';
  }

  @override
  String freeAgency_marketDemand(Object salary) {
    return 'Estimated market salary: $salary';
  }

  @override
  String get freeAgency_offerSalary => 'Salary offer';

  @override
  String get freeAgency_offerYears => 'Contract years';

  @override
  String get freeAgency_submitOffer => 'Submit offer';

  @override
  String get freeAgency_selectPlayer => 'Select a free agent first';

  @override
  String get freeAgency_invalidOffer =>
      'Enter a valid salary and 1–5 contract years';

  @override
  String get freeAgency_accepted => 'Offer accepted — confirm finalization';

  @override
  String get freeAgency_rejected => 'Offer rejected';

  @override
  String get freeAgency_waiting => 'Player is considering the offer';

  @override
  String freeAgency_counter(Object salary, Object years) {
    return 'Player made a counter offer: $salary × $years years';
  }

  @override
  String get freeAgency_rosterFull => 'Roster is full';

  @override
  String get freeAgency_status => 'Offer status';

  @override
  String freeAgency_capSpace(Object amount) {
    return 'Cap space: $amount';
  }

  @override
  String get market_status => 'Contract market';

  @override
  String get market_negotiations => 'Negotiations';

  @override
  String get market_noNegotiations => 'No saved negotiations.';

  @override
  String get market_offerPreview => 'Offer preview';

  @override
  String get market_currentOffer => 'Current offer';

  @override
  String get market_advanceHour => 'Advance one hour';

  @override
  String get market_hourAdvanced => 'The market advanced by one hour.';

  @override
  String get market_statusActive => 'Active';

  @override
  String get market_statusCounter => 'Counter offer awaiting response';

  @override
  String get market_statusHardRejected => 'Rejected and blocked';

  @override
  String get market_statusCompleted => 'Completed';

  @override
  String get market_statusCancelled => 'Cancelled';

  @override
  String get market_statusExpired => 'Negotiation deadline has passed';

  @override
  String get market_closed => 'Closed';

  @override
  String get market_extensions => 'Extensions';

  @override
  String get market_phaseI => 'Free agency phase I';

  @override
  String get market_phaseII => 'Free agency phase II';

  @override
  String market_date(Object day, Object week) {
    return 'Week $week · day $day';
  }

  @override
  String market_hour(Object hour, Object total) {
    return 'Offer hour: $hour/$total';
  }

  @override
  String market_round(Object round) {
    return 'Round $round';
  }

  @override
  String market_deadline(Object day, Object hour, Object week) {
    return 'Deadline: week $week, day $day, hour $hour';
  }

  @override
  String market_score(Object score) {
    return 'Offer score: $score';
  }

  @override
  String market_expectedSalary(Object salary) {
    return 'Expected salary: $salary';
  }

  @override
  String market_expectedLength(Object years) {
    return 'Expected length: $years years';
  }

  @override
  String get market_staffCandidates => 'Available staff';

  @override
  String get market_staffOffer => 'Offer staff contract';

  @override
  String get market_qo => 'Qualifying offers';

  @override
  String get market_qoEligible => 'Players eligible for a QO';

  @override
  String get market_qoSubmitted => 'Active QOs';

  @override
  String market_qoMinimum(Object salary) {
    return 'Minimum QO: $salary';
  }

  @override
  String market_offerSheetFrom(Object team) {
    return 'Offer from: $team';
  }

  @override
  String get market_submitQO => 'Submit QO';

  @override
  String get market_offerSheets => 'RFA offer sheets';

  @override
  String get market_match => 'Match';

  @override
  String get market_release => 'Decline';

  @override
  String get market_draftedRights => 'Drafted rights';

  @override
  String get market_signRights => 'Sign rights';

  @override
  String get market_rosterFull => 'No roster space available';

  @override
  String get market_noWindow => 'No contract market is open today.';

  @override
  String get tactics_noTeam => 'No player team';

  @override
  String get tactics_formation => 'Formation';

  @override
  String get tactics_tempo => 'Tempo';

  @override
  String get tactics_pressing => 'Pressing';

  @override
  String get tactics_defensiveLine => 'Defensive line';

  @override
  String get tactics_attackWidth => 'Attack width';

  @override
  String get tactics_save => 'Save tactics';

  @override
  String get tactics_saved => 'Tactics saved';

  @override
  String get tactics_autosaving => 'Saving tactics…';

  @override
  String get tactics_autosaved => 'Tactics saved automatically';

  @override
  String get tactics_autosaveHint => 'Changes are saved automatically';

  @override
  String get inbox_title => 'Inbox';

  @override
  String get inbox_notifications => 'Notifications';

  @override
  String get inbox_empty => 'Inbox is empty';

  @override
  String inbox_messageSubtitle(int week, String body) {
    return 'Week $week\n$body';
  }

  @override
  String get inbox_settingsTitle => 'Notification levels';

  @override
  String get inbox_tabInbox => 'Inbox';

  @override
  String get inbox_tabArchive => 'Archive';

  @override
  String get inbox_filterAll => 'All';

  @override
  String get inbox_sectionUrgent => 'Urgent';

  @override
  String get inbox_sectionUnread => 'Unread';

  @override
  String get inbox_sectionRead => 'Read';

  @override
  String get inbox_emptyArchive => 'Archive is empty';

  @override
  String get inbox_detailTitle => 'Message details';

  @override
  String inbox_bodyFallback(String type) {
    return 'New information about: $type.';
  }

  @override
  String inbox_metadata(int week, int day, String domain) {
    return 'Week $week · day $day · $domain';
  }

  @override
  String inbox_deadline(String value) {
    return 'Deadline: $value';
  }

  @override
  String inbox_defaultOnExpiry(String value) {
    return 'After deadline: $value';
  }

  @override
  String get inbox_decisionOptions => 'Choose an option';

  @override
  String get inbox_actions => 'Actions';

  @override
  String get inbox_acknowledge => 'Acknowledge';

  @override
  String get inbox_operationSaving => 'Saving confirmation…';

  @override
  String get inbox_confirmationError =>
      'We couldn\'t acknowledge this message. Try again.';

  @override
  String get inbox_markReadError =>
      'We couldn\'t open this message. Try again.';

  @override
  String get inbox_actionError =>
      'We couldn\'t complete this action. Try again.';

  @override
  String get inbox_retry => 'Try again';

  @override
  String get inbox_saveUncertain =>
      'The save result could not be confirmed. Try again.';

  @override
  String get inbox_close => 'Close';

  @override
  String inbox_digestMembers(int count) {
    return 'Included messages ($count)';
  }

  @override
  String get inbox_actionAccept => 'Accept';

  @override
  String get inbox_actionDecline => 'Decline';

  @override
  String get inbox_actionCounter => 'Counter';

  @override
  String get inbox_actionReject => 'Reject';

  @override
  String get inbox_actionOpen => 'Open';

  @override
  String get inbox_actionFallback => 'Run action';

  @override
  String get inbox_settingsDomain => 'Domain settings';

  @override
  String get inbox_settingsType => 'Type settings';

  @override
  String get inbox_settingsDecisionMuted => 'Decision types cannot be muted.';

  @override
  String get inbox_settingsDomainDecisionMuted =>
      'This domain contains decisions and cannot be muted.';

  @override
  String get messageDomain_matchday => 'Matchday';

  @override
  String get messageDomain_health => 'Health';

  @override
  String get messageDomain_playerEvent => 'Players';

  @override
  String get messageDomain_teamEvent => 'Team';

  @override
  String get messageDomain_roster => 'Roster';

  @override
  String get messageDomain_contracts => 'Contracts';

  @override
  String get messageDomain_staff => 'Staff';

  @override
  String get messageDomain_trades => 'Trades';

  @override
  String get messageDomain_draft => 'Draft and scouting';

  @override
  String get messageDomain_finance => 'Finance';

  @override
  String get messageDomain_season => 'Season';

  @override
  String get messageDomain_system => 'System';

  @override
  String get draft_title => 'Draft';

  @override
  String get draft_notActive => 'Draft is not active yet';

  @override
  String get draft_finished => 'Draft finished';

  @override
  String draft_pickLabel(int number, int round) {
    return 'Pick #$number (R$round)';
  }

  @override
  String draft_teamLabel(String name) {
    return 'Team: $name';
  }

  @override
  String get draft_yourTurn => 'Your turn!';

  @override
  String draft_remainingProspects(int count) {
    return 'Remaining prospects ($count)';
  }

  @override
  String get draft_select => 'Select';

  @override
  String draft_selected(String name) {
    return 'Selected: $name';
  }

  @override
  String get calendar_noLeague => 'No league';

  @override
  String calendar_weekDayHeader(int week, String dayName, int day) {
    return 'Week $week · $dayName (day $day)';
  }

  @override
  String calendar_phaseLine(String phase, int year) {
    return 'Phase: $phase · Season $year';
  }

  @override
  String get calendar_homeLabel => 'Home';

  @override
  String get calendar_event_tradeDeadline => 'Trade deadline';

  @override
  String get calendar_event_tradeWindowOpen => 'Trade window opens';

  @override
  String get calendar_event_contractExtensions => 'Contract extensions';

  @override
  String get calendar_event_awards => 'Awards';

  @override
  String get calendar_event_retirements => 'Retirements';

  @override
  String get calendar_event_draftLottery => 'Draft lottery';

  @override
  String get calendar_event_scoutReport => 'Scout report';

  @override
  String get calendar_event_combine => 'Draft Combine';

  @override
  String get calendar_event_mockDraft => 'Mock Draft (final)';

  @override
  String get calendar_event_draft => 'Draft';

  @override
  String get calendar_event_freeAgency => 'Free agency';

  @override
  String get calendar_draft => 'Draft';

  @override
  String calendar_pickProgress(int current, int total) {
    return 'Pick $current/$total';
  }

  @override
  String get calendar_weekEvents => 'This week\'s events';

  @override
  String get calendar_noMatches => 'No matches this week';

  @override
  String get calendar_simulateDay => 'Simulate day';

  @override
  String get calendar_urgentMessage => 'Urgent message in your inbox';

  @override
  String get calendar_fastForward => 'Fast-forward';

  @override
  String get calendar_simulateUntilNextMatch => 'To next match';

  @override
  String get calendar_simulateUntilDate => 'To chosen date';

  @override
  String get calendar_simulateUntilPhaseEnd => 'To end of phase';

  @override
  String get calendar_chooseDateTitle => 'Choose simulation target';

  @override
  String get calendar_weekLabel => 'Week';

  @override
  String get calendar_dayLabel => 'Day';

  @override
  String get calendar_simulating => 'Simulating…';

  @override
  String calendar_daysSimulated(int count) {
    return 'Days simulated: $count';
  }

  @override
  String get calendar_cancel => 'Cancel';

  @override
  String get calendar_stopReason_reachedTarget => 'Target reached';

  @override
  String get calendar_stopReason_cancelled => 'Simulation cancelled';

  @override
  String get calendar_stopReason_draftPick => 'Your draft turn';

  @override
  String get calendar_stopReason_noSave => 'No active save';

  @override
  String get calendar_selectedDay_title => 'Selected day';

  @override
  String get calendar_selectedDay_noEvent => 'No events on this day';

  @override
  String calendar_selectedDay_matchUpcoming(String opponent) {
    return 'Upcoming match: $opponent';
  }

  @override
  String calendar_selectedDay_matchResult(
    String home,
    String away,
    int homeGoals,
    int awayGoals,
  ) {
    return '$home $homeGoals:$awayGoals $away';
  }

  @override
  String calendar_selectedDay_offseasonEvent(String name) {
    return 'Event: $name';
  }

  @override
  String calendar_simulationResults_title(int week, int day) {
    return 'Match results · Week $week, day $day';
  }

  @override
  String calendar_simulationResults_match(
    String home,
    String away,
    int homeGoals,
    int awayGoals,
  ) {
    return '$home $homeGoals:$awayGoals $away';
  }

  @override
  String get trade_title => 'Trade';

  @override
  String get trade_noTeam => 'No team';

  @override
  String get trade_yourPlayer => 'Your player';

  @override
  String get trade_yourPick => 'Your draft pick';

  @override
  String get trade_yourRights => 'Your drafted rights';

  @override
  String get trade_targetTeam => 'Target team';

  @override
  String get trade_theirPlayer => 'Their player';

  @override
  String get trade_theirPick => 'Their draft pick';

  @override
  String get trade_theirRights => 'Their drafted rights';

  @override
  String get trade_confirm => 'Confirm trade';

  @override
  String get trade_fillAllFields => 'Fill in all fields';

  @override
  String get trade_notAllowed => 'Trade not allowed';

  @override
  String get trade_aiRejected => 'The other team rejected the trade proposal';

  @override
  String get trade_executeFailed => 'Failed to execute the trade';

  @override
  String get trade_success => 'Trade completed successfully';

  @override
  String trade_playerOption(String name, String position, int pv) {
    return '$name ($position, PV $pv)';
  }

  @override
  String get contract_title => 'Contracts';

  @override
  String get contract_noTeam => 'No team';

  @override
  String get contract_expiringHeader => 'Expiring / up for renewal';

  @override
  String get contract_noExpiring => 'No players to renew';

  @override
  String contract_playerSubtitle(
    String position,
    int ovr,
    int years,
    String salary,
  ) {
    return '$position · OVR $ovr · Years: $years · $salary';
  }

  @override
  String get contract_freeAgentsHeader =>
      'Free agents (0 years left in league)';

  @override
  String get contract_freeAgentsEmpty =>
      'FA pool empty / simplified — focus on extensions.';

  @override
  String contract_freeAgentsCount(int count) {
    return '$count players with yearsRemaining=0';
  }

  @override
  String get contract_offerSalary => 'Salary offer';

  @override
  String get contract_offerYears => 'Contract years';

  @override
  String get contract_submitOffer => 'Submit extension offer';

  @override
  String get contract_selectPlayer => 'Select a player';

  @override
  String get contract_invalidOffer => 'Invalid salary or years';

  @override
  String get contract_accepted => 'Contract accepted!';

  @override
  String get contract_pendingFinalization =>
      'Offer accepted — confirm finalization';

  @override
  String get contract_finalize => 'Confirm and sign';

  @override
  String get contract_finalizationFailed => 'Contract finalization failed';

  @override
  String get contract_rejected => 'Offer rejected';

  @override
  String get contract_waiting => 'Player is considering the offer…';

  @override
  String contract_counter(String salary, int years) {
    return 'Counter offer: $salary × $years years';
  }

  @override
  String get contract_counterEdit => 'Edit';

  @override
  String get contract_editCounterTitle => 'Edit counter offer';

  @override
  String get staff_title => 'Staff';

  @override
  String get staff_noTeam => 'No team';

  @override
  String get staffRole_headCoach => 'Head Coach';

  @override
  String get staffRole_youthCoach => 'Youth Coach';

  @override
  String get staffRole_scout => 'Scout';

  @override
  String get staffRole_physio => 'Physio';

  @override
  String get staffRole_doctor => 'Doctor';

  @override
  String get staffRole_cfo => 'CFO';

  @override
  String get staff_emptySlot => 'Slot empty';

  @override
  String get staff_fire => 'Fire';

  @override
  String get staff_fireConfirmTitle => 'Fire staff member?';

  @override
  String staff_fireConfirm(String name) {
    return 'Are you sure you want to fire $name?';
  }

  @override
  String staff_fireSuccess(String name) {
    return 'Fired: $name';
  }

  @override
  String get staff_fireFailed => 'The staff member could not be fired.';

  @override
  String staff_contractRemaining(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: 'Contract: # years',
      one: 'Contract: 1 year',
    );
    return '$_temp0';
  }

  @override
  String get staff_contractExpired => 'Contract expired';

  @override
  String staff_salaryRange(String min, String max) {
    return 'Salary must be between $min and $max';
  }

  @override
  String get staff_yearsRange =>
      'Contract length must be between 1 and 4 years';

  @override
  String get staff_capExceeded => 'The offer exceeds the available staff cap';

  @override
  String get staff_candidatesHeader => 'Hiring candidates';

  @override
  String get staff_noCandidates => 'No free candidates for this role';

  @override
  String staff_overallStars(String stars) {
    return '★ $stars';
  }

  @override
  String staff_memberSubtitle(int age, String stars, String salary) {
    return '$age y/o · ★ $stars · $salary/yr';
  }

  @override
  String get staff_hire => 'Hire';

  @override
  String staff_hireAccepted(String name) {
    return 'Offer accepted for $name — confirm finalization';
  }

  @override
  String get staff_hireRejected =>
      'Candidate rejected the offer or staff cap exceeded';

  @override
  String get staff_capLabel => 'Staff cap';

  @override
  String staff_capUsage(String used, String cap) {
    return '$used / $cap';
  }

  @override
  String get staff_fireDisabled => 'Active contracts cannot be fired yet';

  @override
  String get staff_offerPreview => 'Offer preview';

  @override
  String staff_profileLine(String role, int age, String nationality) {
    return '$role · $age y/o · $nationality';
  }

  @override
  String get staff_attributes => 'Attributes';

  @override
  String staff_expectedSalary(String salary) {
    return 'Expected salary: $salary';
  }

  @override
  String staff_expectedLength(int years) {
    return 'Expected length: $years years';
  }

  @override
  String staff_offerScore(String score) {
    return 'Offer score: $score';
  }

  @override
  String get staff_negotiations => 'Staff negotiations';

  @override
  String get staff_noNegotiations => 'No saved staff negotiations.';

  @override
  String get staff_editCounterTitle => 'Edit staff counter offer';

  @override
  String get staff_attrTactics => 'Tactics';

  @override
  String get staff_attrMotivation => 'Motivation';

  @override
  String get staff_attrDevelopment => 'Development';

  @override
  String get staff_attrMentoring => 'Mentoring';

  @override
  String get staff_attrCoverage => 'Coverage';

  @override
  String get staff_attrEvaluation => 'Evaluation';

  @override
  String get staff_attrRehabilitation => 'Rehabilitation';

  @override
  String get staff_attrRegeneration => 'Regeneration';

  @override
  String get staff_attrPrevention => 'Prevention';

  @override
  String get staff_attrCare => 'Care';

  @override
  String get staff_attrNegotiation => 'Negotiation';

  @override
  String get scouting_watchlistTitle => 'Scout watchlist';

  @override
  String scouting_watchlistLimit(int selected, int limit) {
    return 'Selected $selected / $limit';
  }

  @override
  String get scouting_cancel => 'Cancel';

  @override
  String get scouting_save => 'Save';

  @override
  String get scouting_combineTitle => 'Draft Combine';

  @override
  String get scouting_combineColumn => 'Combine';

  @override
  String scouting_combineDescription(int limit) {
    return 'Choose watched prospects for the Combine. Limit: $limit.';
  }

  @override
  String scouting_combineSelected(int selected, int limit) {
    return 'Assigned to Combine: $selected / $limit';
  }

  @override
  String get scouting_combineAssign => 'Choose Combine targets';

  @override
  String get scouting_combineSave => 'Save Combine assignments';

  @override
  String get scouting_combineSaved => 'Combine assignments saved.';

  @override
  String get scouting_combineClosed =>
      'The Combine is complete — results are read-only.';

  @override
  String get scouting_combineRole => 'Optimal role';

  @override
  String get scouting_combineOpen => 'Open Combine target selection';

  @override
  String get scouting_combineNoWatchlist =>
      'Add prospects to the watchlist first.';

  @override
  String get scouting_role_standard => 'Standard';

  @override
  String get scouting_role_sweeperKeeper => 'Sweeper keeper';

  @override
  String get scouting_role_ballPlayingDefender => 'Ball-playing defender';

  @override
  String get scouting_role_noNonsenseCentreBack => 'No-nonsense centre-back';

  @override
  String get scouting_role_defensiveFullBack => 'Defensive full-back';

  @override
  String get scouting_role_attackingFullBack => 'Attacking full-back';

  @override
  String get scouting_role_wingBack => 'Wing-back';

  @override
  String get scouting_role_invertedWingBack => 'Inverted wing-back';

  @override
  String get scouting_role_regista => 'Regista';

  @override
  String get scouting_role_deepLyingPlaymaker => 'Deep-lying playmaker';

  @override
  String get scouting_role_anchorMan => 'Anchor man';

  @override
  String get scouting_role_ballWinning => 'Ball-winning midfielder';

  @override
  String get scouting_role_playmaker => 'Playmaker';

  @override
  String get scouting_role_boxToBox => 'Box-to-box midfielder';

  @override
  String get scouting_role_mezzala => 'Mezzala';

  @override
  String get scouting_role_shadowStriker => 'Shadow striker';

  @override
  String get scouting_role_invertedWinger => 'Inverted winger';

  @override
  String get scouting_role_winger => 'Winger';

  @override
  String get scouting_role_falseNine => 'False nine';

  @override
  String get scouting_role_deepLyingForward => 'Deep-lying forward';

  @override
  String get scouting_role_pressingForward => 'Pressing forward';

  @override
  String get scouting_role_completeForward => 'Complete forward';

  @override
  String get scouting_slot_top1 => 'Proj: TOP 1';

  @override
  String get scouting_slot_top3 => 'Proj: TOP 3';

  @override
  String get scouting_slot_top5 => 'Proj: TOP 5';

  @override
  String get scouting_slot_top10 => 'Proj: TOP 10';

  @override
  String get scouting_slot_r1 => 'Proj: R1';

  @override
  String get scouting_slot_r2 => 'Proj: R2';

  @override
  String get scouting_slot_r3 => 'Proj: R3';

  @override
  String get scouting_slot_x => 'Proj: X';

  @override
  String draft_scoutGradeShort(int grade) {
    return 'Scout $grade';
  }

  @override
  String draft_potentialShort(String stars) {
    return 'Pot. $stars';
  }

  @override
  String draft_injuryProneShort(int value) {
    return 'Injury $value/10';
  }

  @override
  String draft_determinationShort(int value) {
    return 'Determination $value/10';
  }

  @override
  String get contract_faCounter =>
      'FA counter offer — try again with a higher bid';

  @override
  String get playerDetail_title => 'Player';

  @override
  String get playerDetail_notFound => 'Player not found';

  @override
  String playerDetail_headerLine(String position, String nationality, int age) {
    return '$position · $nationality · $age y.o.';
  }

  @override
  String get playerDetail_attributes => 'Attributes';

  @override
  String get playerDetail_contract => 'Contract';

  @override
  String playerDetail_salaryLine(String salary) {
    return 'Salary: $salary / year';
  }

  @override
  String playerDetail_contractYears(int years) {
    return 'Years: $years';
  }

  @override
  String get playerDetail_birdRights => 'Bird rights';

  @override
  String get playerDetail_noTradeClause => 'NTC';

  @override
  String playerDetail_personality(String personality) {
    return 'Personality: $personality';
  }

  @override
  String get matchday_defaultTitle => 'Match';

  @override
  String matchday_finishedSnackbar(int home, int away) {
    return 'Final: $home:$away';
  }

  @override
  String get matchday_resume => 'Resume';

  @override
  String get matchday_pause => 'Pause';

  @override
  String get matchday_toEnd => 'Skip to end';

  @override
  String get matchday_weather => 'Weather';

  @override
  String get matchday_weather_clear => 'Clear';

  @override
  String get matchday_weather_overcast => 'Overcast';

  @override
  String get matchday_weather_rain => 'Rain';

  @override
  String get matchday_weather_heavyRain => 'Heavy rain';

  @override
  String get matchday_weather_wind => 'Wind';

  @override
  String get matchday_weather_snow => 'Snow';

  @override
  String get matchday_weather_heat => 'Heat';

  @override
  String get matchday_weather_cold => 'Cold';

  @override
  String matchday_temperature(int value) {
    return '$value°C';
  }

  @override
  String get matchday_liveStats => 'Live stats';

  @override
  String get matchday_eventFeed => 'Match feed';

  @override
  String get matchday_noEvents => 'No events';

  @override
  String get matchday_derby => 'Derby';

  @override
  String get matchday_possession => 'Possession';

  @override
  String get matchday_shots => 'Shots';

  @override
  String get matchday_xg => 'xG';

  @override
  String matchday_onTarget(int value) {
    return '$value on target';
  }

  @override
  String get matchday_lineup => 'Starting eleven';

  @override
  String get matchday_bench => 'Bench';

  @override
  String get matchday_noPlayers => 'No players';

  @override
  String get matchday_substitutions => 'Substitutions';

  @override
  String get matchday_tactics => 'Match tactics';

  @override
  String get matchday_autoPause => 'Auto-pause';

  @override
  String get matchday_autoPauseTitle => 'Auto-pause settings';

  @override
  String get matchday_autoPauseInjury => 'Injury to my player';

  @override
  String get matchday_autoPauseRed => 'Red card for my player';

  @override
  String get matchday_autoPauseHalfTime => 'Half-time';

  @override
  String get matchday_autoPausePenalty => 'Penalty for my team';

  @override
  String get matchday_penaltyPauseUnavailable =>
      'This engine does not yet expose a penalty-awarded event.';

  @override
  String get matchday_speed => 'Speed';

  @override
  String get matchday_speed1 => '×1';

  @override
  String get matchday_speed2 => '×2';

  @override
  String get matchday_speed4 => '×4';

  @override
  String matchday_subsUsed(int used) {
    return 'Substitutions: $used';
  }

  @override
  String matchday_playerMeta(String position, int ovr, int condition) {
    return '$position · OVR $ovr · Cond $condition';
  }

  @override
  String get matchday_injured => 'Injured';

  @override
  String get matchday_sentOff => 'Sent off';

  @override
  String get matchday_suspended => 'Suspended';

  @override
  String get matchday_yellowCard => 'Yellow card';

  @override
  String get matchday_attention => 'Needs attention';

  @override
  String get matchday_available => 'Available';

  @override
  String get matchday_formationLocked =>
      'Formation can only change at half-time';

  @override
  String get matchday_changesHint =>
      'Choose the player coming off and the substitute';

  @override
  String get matchday_tacticsHint =>
      'Non-formation tactics can change during play';

  @override
  String get matchday_selectOutgoing => 'Player coming off';

  @override
  String get matchday_selectIncoming => 'Player coming on';

  @override
  String get matchday_confirmSubstitution => 'Make substitution';

  @override
  String get matchday_substitutionSuccess => 'Substitution made';

  @override
  String get matchday_tacticsSuccess => 'Tactics updated';

  @override
  String get matchday_actionRejected => 'This action cannot be performed';

  @override
  String get matchday_failureMatchFinished => 'The match is finished';

  @override
  String get matchday_failurePlayerNotOnPitch =>
      'The player is not on the pitch';

  @override
  String get matchday_failurePlayerNotOnBench =>
      'The player is not on the bench';

  @override
  String get matchday_failurePlayerUnavailable => 'The player is unavailable';

  @override
  String get matchday_failurePlayerCannotReenter =>
      'This player cannot re-enter the pitch';

  @override
  String get matchday_failureSubstitutionsLimit =>
      'The substitution limit has been reached';

  @override
  String get matchday_failureSubstitutionWindowsLimit =>
      'The substitution-window limit has been reached';

  @override
  String get matchday_failureFormationOutsideHalfTime =>
      'Formation can only change at half-time';

  @override
  String get matchday_failureInvalidHalfTime =>
      'This action is only available at half-time';

  @override
  String get matchday_failureNoAvailableSubstitute => 'No available substitute';

  @override
  String matchday_autoPaused(String reason) {
    return 'Auto-pause: $reason';
  }

  @override
  String matchday_matchProgress(int minute) {
    return 'Simulation: $minute\'';
  }

  @override
  String get matchday_summaryTitle => 'Match summary';

  @override
  String get matchday_summaryTeamStats => 'Team statistics';

  @override
  String get matchday_summaryPlayerStats => 'Player statistics';

  @override
  String get matchday_summaryMOTM => 'Man of the match';

  @override
  String get matchday_summaryInspired => 'Inspired performance';

  @override
  String get matchday_summaryNone => 'None';

  @override
  String get matchday_summaryClose => 'Close summary';

  @override
  String get matchday_summaryNoPlayerStats => 'No player statistics';

  @override
  String get matchday_summaryRating => 'Rating';

  @override
  String get matchday_summaryStamina => 'Condition';

  @override
  String get matchday_summaryStatus => 'Status';

  @override
  String get router_noMatchData => 'No match data';

  @override
  String get dev_title => 'Development';

  @override
  String get dev_tabPlayers => 'Players';

  @override
  String get dev_tabStaff => 'Staff';

  @override
  String get dev_noTeam => 'No team data available';

  @override
  String get dev_noPlayers => 'No players available';

  @override
  String get dev_vacant => 'Vacant';

  @override
  String get dev_colName => 'Name';

  @override
  String get dev_colAge => 'Age';

  @override
  String get dev_colPotential => 'Pot.';

  @override
  String get dev_colOvr => 'OVR';

  @override
  String get dev_colChange => '+/-';

  @override
  String get dev_progress => 'Progress';

  @override
  String get dev_growth => 'Rate';

  @override
  String get dev_weeklyOvr => 'Weekly OVR';

  @override
  String get staffAttr_tactics => 'Tactics';

  @override
  String get staffAttr_motivation => 'Motivation';

  @override
  String get staffAttr_development => 'Development';

  @override
  String get staffAttr_mentoring => 'Mentoring';

  @override
  String get staffAttr_coverage => 'Coverage';

  @override
  String get staffAttr_evaluation => 'Evaluation';

  @override
  String get staffAttr_rehabilitation => 'Rehabilitation';

  @override
  String get staffAttr_regenaration => 'Regeneration';

  @override
  String get staffAttr_prevention => 'Prevention';

  @override
  String get staffAttr_care => 'Care';

  @override
  String get staffAttr_negotiation => 'Negotiation';

  @override
  String get prospects_title => 'Prospects';

  @override
  String get prospects_name => 'Name';

  @override
  String get prospects_nationality => 'Nat';

  @override
  String get prospects_age => 'Age';

  @override
  String get prospects_positionShort => 'Pos';

  @override
  String get prospects_combine => 'Combine';

  @override
  String get prospects_grade => 'Grade';

  @override
  String get prospects_stars => 'Stars';

  @override
  String get prospects_injuryShort => 'Inj';

  @override
  String get prospects_determinationShort => 'Det';

  @override
  String get prospects_slot => 'Slot';

  @override
  String get prospects_noDraftClass => 'No draft class available';

  @override
  String get prospects_empty => 'No prospects match the filters';

  @override
  String get prospects_search => 'Search by name';

  @override
  String get prospects_position => 'Position';

  @override
  String get prospects_allPositions => 'All positions';

  @override
  String get prospects_watchOnly => 'Watchlist only';

  @override
  String get prospects_sort => 'Sort';

  @override
  String get prospects_sortName => 'Name';

  @override
  String get prospects_sortOvr => 'Projected OVR';

  @override
  String get prospects_sortGrade => 'Scout grade';

  @override
  String get prospects_sortPotential => 'Potential';

  @override
  String get prospects_watchlist => 'Watchlist';

  @override
  String get prospects_watched => 'Watched';

  @override
  String get prospects_saveWatchlist => 'Save watchlist';

  @override
  String prospects_coverage(Object limit, Object selected, Object stars) {
    return 'Coverage: $stars★ · $selected/$limit';
  }

  @override
  String get prospects_scoutingData => 'Scouting data';

  @override
  String get prospects_noScouting =>
      'No scouting data. Add this prospect to the watchlist.';

  @override
  String get prospects_combineScore => 'Combine score';

  @override
  String get prospects_scoutGrade => 'Scout grade';

  @override
  String get prospects_potential => 'Potential';

  @override
  String get prospects_injuryProne => 'Injury proneness';

  @override
  String get prospects_determination => 'Determination';

  @override
  String get prospects_estimatedSlot => 'Estimated slot';

  @override
  String get prospects_unknown => 'Unknown';

  @override
  String get playerDetail_health => 'Health';

  @override
  String get playerDetail_available => 'Available';

  @override
  String playerDetail_injury(Object type) {
    return 'Injured: $type';
  }

  @override
  String playerDetail_injuryDays(Object days) {
    return 'Days remaining: $days';
  }

  @override
  String get playerDetail_roleTeam => 'Role and team';

  @override
  String playerDetail_currentRole(Object role) {
    return 'Current role: $role';
  }

  @override
  String playerDetail_optimalRole(Object role) {
    return 'Optimal role: $role';
  }

  @override
  String playerDetail_seasonsWithTeam(Object seasons) {
    return 'Seasons with team: $seasons';
  }

  @override
  String get playerDetail_history => 'Season history';

  @override
  String get playerDetail_career => 'Career totals';

  @override
  String get playerDetail_season => 'Season';

  @override
  String get playerDetail_appearances => 'Apps';

  @override
  String get playerDetail_minutes => 'Minutes';

  @override
  String get playerDetail_goals => 'Goals';

  @override
  String get playerDetail_assists => 'Assists';

  @override
  String get playerDetail_rating => 'Rating';

  @override
  String get playerDetail_noHistory => 'No season statistics available';

  @override
  String get squad_filters => 'Roster filters';

  @override
  String get squad_search => 'Search by name';

  @override
  String get squad_position => 'Position';

  @override
  String get squad_allPositions => 'All positions';

  @override
  String get squad_zone => 'Zone';

  @override
  String get squad_allZones => 'All zones';

  @override
  String get squad_availability => 'Availability';

  @override
  String get squad_allPlayers => 'All players';

  @override
  String get squad_available => 'Available';

  @override
  String get squad_injuredOnly => 'Injured';

  @override
  String get squad_minOvr => 'Min OVR';

  @override
  String get squad_minForm => 'Min form';

  @override
  String get squad_any => 'Any';

  @override
  String get squad_clearFilters => 'Clear filters';

  @override
  String get squad_noPlayers => 'No players match the filters';

  @override
  String get squad_matchday => 'Matchday squad';

  @override
  String squad_healthy(Object count) {
    return 'Healthy: $count';
  }

  @override
  String get squad_belowXi => 'Fewer than 11 healthy players are available';

  @override
  String squad_xiCount(Object count) {
    return 'XI: $count';
  }

  @override
  String squad_benchCount(Object count) {
    return 'Bench: $count';
  }

  @override
  String squad_reserveCount(Object count) {
    return 'Reserves: $count';
  }

  @override
  String get draftHistory_title => 'Draft history';

  @override
  String get draftHistory_noDraftData => 'No draft data available';

  @override
  String get draftHistory_currentDraft => 'Current draft';

  @override
  String draftHistory_season(Object year) {
    return 'Season $year';
  }

  @override
  String draftHistory_pick(Object number) {
    return 'Pick $number';
  }

  @override
  String draftHistory_round(Object round) {
    return 'Round $round';
  }

  @override
  String get draftHistory_team => 'Team';

  @override
  String get draftHistory_originalTeam => 'Original team';

  @override
  String get draftHistory_player => 'Player';

  @override
  String get draftHistory_noPicks => 'No completed picks';

  @override
  String get draftHistory_lottery => 'Lottery results';

  @override
  String get draftHistory_noLottery =>
      'Lottery results are not available for this season';

  @override
  String get rankings_title => 'Rankings';

  @override
  String get rankings_power => 'Power ranking';

  @override
  String get rankings_expected => 'Expected rank';

  @override
  String get rankings_assets => 'Trade assets';

  @override
  String get rankings_noStrength => 'Power ranking is not calculated yet';

  @override
  String get rankings_rank => 'Rank';

  @override
  String get rankings_team => 'Team';

  @override
  String get rankings_powerValue => 'Power';

  @override
  String get rankings_status => 'Status';

  @override
  String rankings_updated(Object day, Object week) {
    return 'Updated: week $week, day $day';
  }

  @override
  String get rankings_expectedDisclaimer =>
      'Expected rank reflects roster strength, not a simulated final table.';

  @override
  String get rankings_assetValue => 'Value';

  @override
  String get rankings_assetType => 'Type';

  @override
  String get rankings_owner => 'Owner';

  @override
  String get rankings_noAssets => 'No trade assets available';

  @override
  String get rankings_playerAsset => 'Player';

  @override
  String get rankings_pickAsset => 'Draft pick';

  @override
  String get rankings_statusRebuild => 'Rebuild';

  @override
  String get rankings_statusRetool => 'Retool';

  @override
  String get rankings_statusPretender => 'Pretender';

  @override
  String get rankings_statusContender => 'Contender';

  @override
  String get rankings_statusElite => 'Elite';

  @override
  String get rankings_rightsAsset => 'Draft rights';

  @override
  String get rankings_aiValuationTeam => 'Valuation from team perspective';

  @override
  String rankings_aiValuationDisclaimer(String team) {
    return 'Asset values are calculated from: $team perspective.';
  }

  @override
  String get rankings_openPlayer => 'Open player profile';

  @override
  String get rankings_aiBaseValue => 'pointValue base';

  @override
  String get rankings_aiStatusAge => 'Status/age multiplier';

  @override
  String get rankings_aiNeedMultiplier => 'Need multiplier';

  @override
  String get rankings_aiContextMultiplier => 'Context multiplier';

  @override
  String get rankings_aiProjectedSlot => 'Projected slot';

  @override
  String get rankings_aiFutureDiscount => 'Future discount';

  @override
  String get rankings_aiUncertainty => 'Uncertainty';

  @override
  String get rankings_aiRightsMultiplier => 'Rights multiplier';

  @override
  String get rankings_aiContractDrag => 'contractDrag';

  @override
  String get rankings_aiFactors => 'Active factors';

  @override
  String get stats_title => 'Statistics';

  @override
  String get stats_players => 'Player stats';

  @override
  String get stats_teamOverview => 'Team overview';

  @override
  String get stats_noStats => 'No recorded match statistics';

  @override
  String get stats_search => 'Search player';

  @override
  String get stats_sort => 'Sort';

  @override
  String get stats_sortOvr => 'OVR';

  @override
  String get stats_sortGoals => 'Goals';

  @override
  String get stats_sortAssists => 'Assists';

  @override
  String get stats_sortRating => 'Rating';

  @override
  String get stats_player => 'Player';

  @override
  String get stats_team => 'Team';

  @override
  String get stats_appearances => 'Apps';

  @override
  String get stats_minutes => 'Minutes';

  @override
  String get stats_goals => 'Goals';

  @override
  String get stats_assists => 'Assists';

  @override
  String get stats_rating => 'Rating';

  @override
  String get stats_boxScore => 'Full box score';

  @override
  String get stats_shots => 'Shots';

  @override
  String get stats_shotsOnTarget => 'Shots on target';

  @override
  String get stats_xg => 'xG';

  @override
  String get stats_passes => 'Passes';

  @override
  String get stats_passAccuracy => 'Pass accuracy';

  @override
  String get stats_duelsWon => 'Duels won';

  @override
  String get stats_offsides => 'Offsides';

  @override
  String get stats_corners => 'Corners';

  @override
  String get stats_fouls => 'Fouls';

  @override
  String get stats_yellowCards => 'Yellow cards';

  @override
  String get stats_redCards => 'Red cards';

  @override
  String get stats_tackles => 'Tackles';

  @override
  String get stats_interceptions => 'Interceptions';

  @override
  String get stats_cleanSheets => 'Clean sheets';

  @override
  String get stats_saves => 'Saves';

  @override
  String get stats_shotsFaced => 'Shots faced';

  @override
  String get stats_possession => 'Possession';

  @override
  String get stats_record => 'Record';

  @override
  String get stats_roster => 'Roster';

  @override
  String get stats_averageOvr => 'Average OVR';

  @override
  String get stats_injured => 'Injured';

  @override
  String get stats_payroll => 'Payroll';

  @override
  String get stats_atmosphere => 'Atmosphere';

  @override
  String get stats_chemistry => 'Chemistry';

  @override
  String get stats_status => 'Status';

  @override
  String get stats_noStandings => 'No standings available';

  @override
  String get rewards_title => 'Rewards';

  @override
  String get rewards_noAwards => 'Awards have not been calculated yet';

  @override
  String get rewards_notAwarded => 'Not awarded';

  @override
  String get rewards_mvp => 'MVP';

  @override
  String get rewards_roty => 'Rookie of the year';

  @override
  String get rewards_dpoy => 'Defensive player of the year';

  @override
  String get rewards_topScorer => 'Top scorer';

  @override
  String get rewards_topAssist => 'Top assist provider';

  @override
  String get rewards_bestGk => 'Best goalkeeper';

  @override
  String get rewards_coachOfYear => 'Coach of the year';

  @override
  String get rewards_champion => 'Champion';

  @override
  String get rewards_teamOfSeason => 'Team of the season';

  @override
  String get search_title => 'Search';

  @override
  String get search_hint => 'Search teams, players and prospects';

  @override
  String get search_allTypes => 'All types';

  @override
  String get search_players => 'Players';

  @override
  String get search_teams => 'Teams';

  @override
  String get search_prospects => 'Prospects';

  @override
  String get search_freeAgents => 'Free agents';

  @override
  String get search_noResults => 'No results';

  @override
  String get search_tradeAction => 'Trade';

  @override
  String search_teamResult(Object conference) {
    return 'Team · $conference';
  }

  @override
  String search_playerResult(Object position, Object team) {
    return 'Player · $team · $position';
  }

  @override
  String search_prospectResult(Object age, Object position) {
    return 'Prospect · $position · age $age';
  }

  @override
  String search_freeAgentResult(Object ovr, Object position) {
    return 'Free agent · $position · OVR $ovr';
  }

  @override
  String get msg_matchPreview_title => 'Match preview';

  @override
  String get msg_matchPreview_body => 'An upcoming league match.';

  @override
  String get msg_matchResult_title => 'Match result';

  @override
  String msg_matchResult_body(
    String homeTeam,
    int homeGoals,
    int awayGoals,
    String awayTeam,
  ) {
    return 'The match ended $homeTeam $homeGoals:$awayGoals $awayTeam.';
  }

  @override
  String get msg_walkover_title => 'Walkover';

  @override
  String msg_walkover_body(Object reason) {
    return 'The match was decided by a walkover. Reason: $reason.';
  }

  @override
  String get msg_lineupNoGk_title => 'No goalkeeper in XI';

  @override
  String get msg_lineupNoGk_body =>
      'The team has no goalkeeper in the starting lineup.';

  @override
  String get msg_benchIncomplete_title => 'Incomplete bench';

  @override
  String msg_benchIncomplete_body(Object missingCount) {
    return 'The bench is missing $missingCount players.';
  }

  @override
  String get msg_suspensionStart_title => 'Suspension started';

  @override
  String msg_suspensionStart_body(Object games, Object playerName) {
    return '$playerName is suspended for $games games.';
  }

  @override
  String get msg_suspensionEnd_title => 'Suspension ended';

  @override
  String msg_suspensionEnd_body(Object playerName) {
    return '$playerName is available again.';
  }

  @override
  String get msg_injury_title => 'Injury';

  @override
  String msg_injury_body(
    Object days,
    Object injuryName,
    Object injuryType,
    Object playerName,
  ) {
    return '$playerName: $injuryName ($injuryType), out for about $days days.';
  }

  @override
  String get msg_injuryReturn_title => 'Return from injury';

  @override
  String msg_injuryReturn_body(Object injuryName, Object playerName) {
    return '$playerName returns after $injuryName.';
  }

  @override
  String get msg_injuryRecurrence_title => 'Recurring injury';

  @override
  String msg_injuryRecurrence_body(Object injuryName, Object playerName) {
    return '$playerName feels the $injuryName injury again.';
  }

  @override
  String get msg_potentialLoss_title => 'Potential decline';

  @override
  String get msg_potentialLoss_body => 'The player\'s potential has decreased.';

  @override
  String get msg_playerEvent_title => 'Player event';

  @override
  String get msg_playerEvent_body => 'The manager\'s attention is required.';

  @override
  String get msg_teamEvent_title => 'Team event';

  @override
  String get msg_teamEvent_body => 'An event affecting the team has occurred.';

  @override
  String get msg_retirementPlayer_title => 'Player retirement';

  @override
  String msg_retirementPlayer_body(Object playerName) {
    return '$playerName is retiring.';
  }

  @override
  String get msg_retirementStaff_title => 'Staff departure';

  @override
  String get msg_retirementStaff_body => 'A staff member is leaving the club.';

  @override
  String get msg_retirementLeagueDigest_title => 'League retirements';

  @override
  String get msg_retirementLeagueDigest_body =>
      'League retirement information.';

  @override
  String get msg_rosterWarning_title => 'Roster problem';

  @override
  String get msg_rosterWarning_body => 'The roster needs attention.';

  @override
  String get msg_contractOffer_title => 'Contract offer';

  @override
  String get msg_contractOffer_body => 'A contract update is available.';

  @override
  String get msg_contractSigned_title => 'Contract signed';

  @override
  String get msg_contractSigned_body => 'The contract has been signed.';

  @override
  String get msg_contractOfferResponse_title => 'Contract offer response';

  @override
  String get msg_contractOfferResponse_body =>
      'The contract negotiation was updated.';

  @override
  String get msg_contractExpiring_title => 'Contract expiring';

  @override
  String msg_contractExpiring_body(Object playerName) {
    return '$playerName\'s contract expires after this season.';
  }

  @override
  String get msg_contractLostToRival_title => 'Lost target';

  @override
  String msg_contractLostToRival_body(Object rivalTeam, Object subjectName) {
    return '$subjectName signed with $rivalTeam.';
  }

  @override
  String get msg_contractExpired_title => 'Expired contract';

  @override
  String msg_contractExpired_body(Object playerName) {
    return '$playerName\'s contract has expired.';
  }

  @override
  String get msg_declineToExtend_title => 'No extension';

  @override
  String get msg_declineToExtend_body =>
      'The player does not want to extend the contract.';

  @override
  String get msg_rfaOfferSheet_title => 'Offer sheet';

  @override
  String get msg_rfaOfferSheet_body =>
      'An offer from another club has arrived.';

  @override
  String get msg_staffOfferResponse_title => 'Staff offer response';

  @override
  String get msg_staffOfferResponse_body =>
      'A staff contract negotiation was updated.';

  @override
  String get msg_staffSigned_title => 'Staff contract signed';

  @override
  String get msg_staffSigned_body => 'A staff member signed a new contract.';

  @override
  String get msg_staffGrowth_title => 'Staff growth';

  @override
  String get msg_staffGrowth_body => 'The staff improved its skills.';

  @override
  String get msg_staffHired_title => 'Staff member hired';

  @override
  String get msg_staffHired_body => 'A new staff member joined the club.';

  @override
  String get msg_staffFired_title => 'Staff contract ended';

  @override
  String get msg_staffFired_body => 'A staff member left the club.';

  @override
  String get msg_staffSlotEmpty_title => 'Empty staff slot';

  @override
  String get msg_staffSlotEmpty_body =>
      'An available staff slot needs to be filled.';

  @override
  String get msg_trade_title => 'Trade';

  @override
  String get msg_trade_body => 'A trade update is available.';

  @override
  String get msg_tradeOffer_title => 'Trade offer';

  @override
  String get msg_tradeOffer_body => 'A new trade offer has arrived.';

  @override
  String get msg_tradeWindowEvent_title => 'Trade window';

  @override
  String get msg_tradeWindowEvent_body =>
      'Trade window information was updated.';

  @override
  String get msg_lottery_title => 'Draft lottery';

  @override
  String get msg_lottery_body => 'Draft lottery results are available.';

  @override
  String get msg_scoutReport_title => 'Scout report';

  @override
  String get msg_scoutReport_body => 'New scouting information is available.';

  @override
  String get msg_combine_title => 'Combine results';

  @override
  String get msg_combine_body => 'Prospect testing results are available.';

  @override
  String get msg_mockDraft_title => 'Mock draft';

  @override
  String get msg_mockDraft_body => 'The draft projection was updated.';

  @override
  String get msg_draftPick_title => 'Draft pick';

  @override
  String get msg_draftPick_body => 'It is time to make a draft pick.';

  @override
  String get msg_draftPickLeague_title => 'Another team\'s pick';

  @override
  String get msg_draftPickLeague_body => 'Another team made a draft selection.';

  @override
  String get msg_draftedRightsReminder_title => 'Unsigned drafted player';

  @override
  String msg_draftedRightsReminder_body(Object playerName, Object rosterCount) {
    return 'You hold the rights to $playerName; roster: $rosterCount/30.';
  }

  @override
  String get msg_apronWarning_title => 'Apron exceeded';

  @override
  String get msg_apronWarning_body => 'Payroll is above the allowed level.';

  @override
  String get msg_capUpdateTv_title => 'Salary cap update';

  @override
  String get msg_capUpdateTv_body => 'The salary cap has been updated.';

  @override
  String get msg_staffCapViolation_title => 'Staff cap exceeded';

  @override
  String get msg_staffCapViolation_body => 'Staff payroll is above the limit.';

  @override
  String get msg_award_title => 'Award';

  @override
  String get msg_award_body => 'A season award was granted.';

  @override
  String get msg_award_mvp_title => 'Season MVP';

  @override
  String msg_award_mvp_body(String playerName) {
    return '$playerName won the MVP award.';
  }

  @override
  String get msg_award_roty_title => 'Rookie of the season';

  @override
  String msg_award_roty_body(String playerName) {
    return '$playerName was named rookie of the season.';
  }

  @override
  String get msg_award_dpoy_title => 'Defensive player of the season';

  @override
  String msg_award_dpoy_body(String playerName) {
    return '$playerName won the defensive player award.';
  }

  @override
  String get msg_award_coachOfYear_title => 'Coach of the season';

  @override
  String msg_award_coachOfYear_body(String teamName) {
    return '$teamName has the coach of the season.';
  }

  @override
  String get msg_award_topScorer_title => 'Top scorer';

  @override
  String msg_award_topScorer_body(String playerName) {
    return '$playerName finished as the top scorer.';
  }

  @override
  String get msg_award_topAssist_title => 'Top assist provider';

  @override
  String msg_award_topAssist_body(String playerName) {
    return '$playerName finished as the top assist provider.';
  }

  @override
  String get msg_award_bestGk_title => 'Best goalkeeper';

  @override
  String msg_award_bestGk_body(String playerName) {
    return '$playerName was named the season\'s best goalkeeper.';
  }

  @override
  String get msg_award_teamOfSeason_title => 'Team of the season';

  @override
  String msg_award_teamOfSeason_body(String playerName, String slot) {
    return '$playerName was selected for the $slot position.';
  }

  @override
  String get msg_award_champion_title => 'League champion';

  @override
  String msg_award_champion_body(String teamName) {
    return '$teamName won the league championship.';
  }

  @override
  String get msg_playoffSeeding_title => 'Playoff seeding';

  @override
  String msg_playoffSeeding_body(String conference) {
    return '$conference: playoff seeding has been set.';
  }

  @override
  String get msg_playInResult_title => 'Play-in result';

  @override
  String msg_playInResult_body(String conference) {
    return '$conference: the play-in winners are known.';
  }

  @override
  String get msg_atmosphere_title => 'Team atmosphere';

  @override
  String get msg_atmosphere_body => 'The club\'s atmosphere level changed.';

  @override
  String get msg_teamStatusChange_title => 'Team status changed';

  @override
  String get msg_teamStatusChange_body => 'The team\'s status was updated.';

  @override
  String get msg_seasonSummary_title => 'Season summary';

  @override
  String get msg_seasonSummary_body => 'The current season summary is ready.';

  @override
  String get msg_playoffMissed_title => 'Playoffs missed';

  @override
  String get msg_playoffMissed_body =>
      'The team did not qualify for the playoffs.';

  @override
  String get msg_calendar_title => 'Calendar';

  @override
  String get msg_calendar_body => 'A new calendar event is available.';

  @override
  String get msg_system_title => 'System message';

  @override
  String msg_system_body(String message) {
    return '$message';
  }

  @override
  String get msg_ovrDigest_title => 'OVR development';

  @override
  String get msg_ovrDigest_body => 'A summary of player development.';

  @override
  String get msg_playerEvent_plateau_title => 'Player plateau';

  @override
  String msg_playerEvent_plateau_body(Object playerName) {
    return '$playerName needs a training plan change.';
  }

  @override
  String get msg_playerEvent_coldStreak_title => 'Cold streak';

  @override
  String msg_playerEvent_coldStreak_body(Object playerName) {
    return '$playerName is going through a cold streak.';
  }

  @override
  String get msg_playerEvent_injuryComplication_title => 'Injury complication';

  @override
  String msg_playerEvent_injuryComplication_body(Object playerName) {
    return 'A decision is required about $playerName\'s return.';
  }

  @override
  String get msg_playerEvent_veteranMotivation_title =>
      'Veteran motivation drop';

  @override
  String msg_playerEvent_veteranMotivation_body(Object playerName) {
    return '$playerName needs support.';
  }

  @override
  String get msg_playerEvent_extraTraining_title => 'Extra training';

  @override
  String msg_playerEvent_extraTraining_body(Object playerName) {
    return '$playerName requests an extra session.';
  }

  @override
  String get msg_playerEvent_personalSupport_title => 'Player support';

  @override
  String msg_playerEvent_personalSupport_body(Object playerName) {
    return '$playerName needs club support.';
  }

  @override
  String get msg_playerEvent_breakthrough_title => 'Development breakthrough';

  @override
  String msg_playerEvent_breakthrough_body(Object playerName) {
    return '$playerName made a breakthrough.';
  }

  @override
  String get msg_playerEvent_personalProblems_title => 'Personal problems';

  @override
  String msg_playerEvent_personalProblems_body(Object playerName) {
    return '$playerName is dealing with personal problems.';
  }

  @override
  String get msg_playerEvent_lateBloomer_title => 'Late development';

  @override
  String msg_playerEvent_lateBloomer_body(Object playerName) {
    return '$playerName improved an attribute.';
  }

  @override
  String get msg_playerEvent_nationalTeam_title => 'National team call-up';

  @override
  String msg_playerEvent_nationalTeam_body(Object playerName) {
    return '$playerName received a national team call-up.';
  }

  @override
  String get msg_playerEvent_inspiredPerformance_title =>
      'Inspired performance';

  @override
  String msg_playerEvent_inspiredPerformance_body(Object playerName) {
    return '$playerName delivered a great performance.';
  }

  @override
  String get msg_teamEvent_moreMinutesRequest_title => 'Minutes request';

  @override
  String msg_teamEvent_moreMinutesRequest_body(Object playerName) {
    return '$playerName wants more playing time.';
  }

  @override
  String get msg_teamEvent_transferRequestI_title => 'Transfer request';

  @override
  String msg_teamEvent_transferRequestI_body(Object playerName) {
    return '$playerName wants to leave the club.';
  }

  @override
  String get msg_teamEvent_transferRequestII_title => 'Transfer demand';

  @override
  String msg_teamEvent_transferRequestII_body(Object playerName) {
    return '$playerName has renewed the transfer demand.';
  }

  @override
  String get msg_teamEvent_dressingRoomConflict_title =>
      'Dressing-room conflict';

  @override
  String get msg_teamEvent_dressingRoomConflict_body =>
      'A conflict has broken out in the dressing room.';

  @override
  String get msg_teamEvent_publicCriticism_title => 'Public criticism';

  @override
  String get msg_teamEvent_publicCriticism_body =>
      'A player publicly criticized the manager.';

  @override
  String get msg_teamEvent_declineToExtend_title => 'No extension';

  @override
  String get msg_teamEvent_declineToExtend_body =>
      'The player does not want to extend the contract.';

  @override
  String get msg_teamEvent_leaderSupport_title => 'Leader support';

  @override
  String get msg_teamEvent_leaderSupport_body =>
      'The team leader supported the squad.';

  @override
  String get msg_teamEvent_promiseBroken_title => 'Broken promise';

  @override
  String get msg_teamEvent_promiseBroken_body =>
      'A promise made to a player was not fulfilled.';

  @override
  String get msg_teamEvent_atmosphereShift_title => 'Atmosphere change';

  @override
  String get msg_teamEvent_atmosphereShift_body =>
      'The team\'s atmosphere has changed.';

  @override
  String get msg_contractOffer_accept_title => 'Offer accepted';

  @override
  String msg_contractOffer_accept_body(Object subjectName) {
    return 'The offer for $subjectName is waiting for finalization.';
  }

  @override
  String get msg_contractOffer_reject_title => 'Offer rejected';

  @override
  String get msg_contractOffer_reject_body =>
      'The contract offer was rejected.';

  @override
  String get msg_contractOffer_hardReject_title => 'Hard rejection';

  @override
  String get msg_contractOffer_hardReject_body =>
      'Negotiations have been blocked.';

  @override
  String get msg_contractOffer_waiting_title => 'Offer pending';

  @override
  String get msg_contractOffer_waiting_body =>
      'The player is considering the offer.';

  @override
  String get msg_contractOffer_counter_title => 'Counter offer';

  @override
  String get msg_contractOffer_counter_body =>
      'A contract counter offer has arrived.';

  @override
  String get msg_contractOffer_rfaQualifyingOffer_title =>
      'Qualifying offer required';

  @override
  String get msg_contractOffer_rfaQualifyingOffer_body =>
      'The deadline to submit the qualifying offer is approaching.';

  @override
  String get msg_contractOfferResponse_accept_title => 'Offer accepted';

  @override
  String msg_contractOfferResponse_accept_body(Object subjectName) {
    return 'The offer for $subjectName was accepted and awaits finalization.';
  }

  @override
  String get msg_contractOfferResponse_reject_title => 'Offer rejected';

  @override
  String msg_contractOfferResponse_reject_body(Object subjectName) {
    return 'The offer for $subjectName was rejected.';
  }

  @override
  String get msg_contractOfferResponse_hardReject_title => 'Hard rejection';

  @override
  String msg_contractOfferResponse_hardReject_body(Object subjectName) {
    return 'Negotiations for $subjectName have been blocked.';
  }

  @override
  String get msg_contractOfferResponse_waiting_title => 'Offer pending';

  @override
  String msg_contractOfferResponse_waiting_body(Object subjectName) {
    return '$subjectName is considering the offer.';
  }

  @override
  String get msg_contractOfferResponse_counter_title => 'Counter offer';

  @override
  String msg_contractOfferResponse_counter_body(
    Object salary,
    Object subjectName,
    Object years,
  ) {
    return '$subjectName returned a counter offer for $salary over $years years.';
  }

  @override
  String get msg_staffOfferResponse_accept_title => 'Staff offer accepted';

  @override
  String msg_staffOfferResponse_accept_body(Object subjectName) {
    return 'The offer for $subjectName was accepted and awaits finalization.';
  }

  @override
  String get msg_staffOfferResponse_reject_title => 'Staff offer rejected';

  @override
  String msg_staffOfferResponse_reject_body(Object subjectName) {
    return 'The offer for $subjectName was rejected.';
  }

  @override
  String get msg_staffOfferResponse_hardReject_title => 'Staff hard rejection';

  @override
  String msg_staffOfferResponse_hardReject_body(Object subjectName) {
    return 'Negotiations for $subjectName have been blocked.';
  }

  @override
  String get msg_staffOfferResponse_waiting_title => 'Staff offer pending';

  @override
  String msg_staffOfferResponse_waiting_body(Object subjectName) {
    return '$subjectName is considering the offer.';
  }

  @override
  String get msg_staffOfferResponse_counter_title => 'Staff counter offer';

  @override
  String msg_staffOfferResponse_counter_body(
    Object salary,
    Object subjectName,
    Object years,
  ) {
    return '$subjectName returned a counter offer for $salary over $years years.';
  }

  @override
  String get msg_staffOfferResponse_lostToRival_title => 'Staff target lost';

  @override
  String msg_staffOfferResponse_lostToRival_body(
    Object rivalTeam,
    Object subjectName,
  ) {
    return '$subjectName signed with $rivalTeam.';
  }

  @override
  String get msg_contractLostToRival_lostToRival_title => 'Lost target';

  @override
  String msg_contractLostToRival_lostToRival_body(
    Object rivalTeam,
    Object subjectName,
  ) {
    return '$subjectName signed with $rivalTeam.';
  }

  @override
  String get msg_contractExpiring_player_title => 'Player contract expiring';

  @override
  String msg_contractExpiring_player_body(Object playerName) {
    return '$playerName\'s contract expires after this season.';
  }

  @override
  String get msg_contractExpiring_staff_title => 'Staff contract expiring';

  @override
  String msg_contractExpiring_staff_body(Object staffName) {
    return '$staffName\'s contract expires after this season.';
  }

  @override
  String get msg_contractExpired_player_title => 'Player contract expired';

  @override
  String msg_contractExpired_player_body(Object playerName) {
    return '$playerName\'s contract has expired.';
  }

  @override
  String get msg_contractExpired_staff_title => 'Staff contract expired';

  @override
  String msg_contractExpired_staff_body(Object staffName) {
    return '$staffName\'s contract has expired.';
  }

  @override
  String get msg_trade_counter_title => 'Trade counter offer';

  @override
  String get msg_trade_counter_body =>
      'A counter offer has arrived from the partner.';

  @override
  String get msg_trade_accepted_title => 'Trade accepted';

  @override
  String get msg_trade_accepted_body => 'The trade has been completed.';

  @override
  String get msg_trade_rejected_title => 'Trade rejected';

  @override
  String get msg_trade_rejected_body =>
      'The partner rejected the trade proposal.';

  @override
  String get msg_trade_hardRejected_title => 'Trade blocked';

  @override
  String get msg_trade_hardRejected_body =>
      'Negotiations are blocked for 30 days.';

  @override
  String get msg_trade_ntcRefusal_title => 'NTC refusal';

  @override
  String get msg_trade_ntcRefusal_body =>
      'The player did not approve the transfer.';

  @override
  String get msg_trade_leagueDigest_title => 'League trades';

  @override
  String get msg_trade_leagueDigest_body => 'A summary of league trades.';

  @override
  String get msg_tradeWindowEvent_open_title => 'Trade window opened';

  @override
  String get msg_tradeWindowEvent_open_body => 'Trades can now be completed.';

  @override
  String get msg_tradeWindowEvent_deadline_title => 'Trade deadline';

  @override
  String get msg_tradeWindowEvent_deadline_body =>
      'The trade-window closing date is approaching.';

  @override
  String get msg_scoutReport_monthly_title => 'Monthly scout report';

  @override
  String get msg_scoutReport_monthly_body => 'A new scout report is available.';

  @override
  String get msg_scoutReport_event_title => 'Scout report — assign Combine';

  @override
  String get msg_scoutReport_event_body => 'Assign prospects to the Combine.';

  @override
  String get msg_mockDraft_initial_title => 'Initial mock draft';

  @override
  String get msg_mockDraft_initial_body =>
      'The initial draft projection is available.';

  @override
  String get msg_mockDraft_final_title => 'Final mock draft';

  @override
  String get msg_mockDraft_final_body =>
      'The final draft projection is available.';

  @override
  String get msg_draftPick_own_title => 'Your draft pick';

  @override
  String get msg_draftPick_own_body => 'It is your team\'s turn to pick.';

  @override
  String get msg_draftPickLeague_league_title => 'League draft pick';

  @override
  String get msg_draftPickLeague_league_body =>
      'Another team made a selection.';

  @override
  String get msg_playerEvent_action_accept => 'Accept';

  @override
  String get msg_playerEvent_action_decline => 'Decline';

  @override
  String get msg_playerEvent_action_cautious => 'Cautious return';

  @override
  String get msg_playerEvent_action_full => 'Full workload';

  @override
  String get msg_teamEvent_action_accept => 'Accept';

  @override
  String get msg_teamEvent_action_decline => 'Decline';

  @override
  String get msg_teamEvent_action_intervene => 'Intervene';

  @override
  String get msg_teamEvent_action_ignore => 'Ignore';

  @override
  String get msg_teamEvent_action_response => 'Respond publicly';

  @override
  String get msg_teamEvent_action_punish => 'Disciplinary action';

  @override
  String get msg_contractOffer_action_finalize => 'Finalize';

  @override
  String get msg_contractOffer_action_cancel => 'Cancel';

  @override
  String get msg_contractOffer_action_accept => 'Accept';

  @override
  String get msg_contractOffer_action_counter => 'Counter offer';

  @override
  String get msg_contractOffer_action_decline => 'Decline';

  @override
  String get msg_contractOffer_action_submit => 'Submit QO';

  @override
  String get msg_contractOfferResponse_action_accept => 'Accept';

  @override
  String get msg_contractOfferResponse_action_counter => 'Counter offer';

  @override
  String get msg_contractOfferResponse_action_decline => 'Decline';

  @override
  String get msg_staffOfferResponse_action_accept => 'Accept';

  @override
  String get msg_staffOfferResponse_action_counter => 'Counter offer';

  @override
  String get msg_staffOfferResponse_action_decline => 'Decline';

  @override
  String get msg_tradeOffer_action_accept => 'Accept';

  @override
  String get msg_tradeOffer_action_counter => 'Counter offer';

  @override
  String get msg_tradeOffer_action_reject => 'Reject';

  @override
  String get msg_trade_action_accept => 'Accept';

  @override
  String get msg_trade_action_counter => 'Counter offer';

  @override
  String get msg_trade_action_reject => 'Reject';

  @override
  String get msg_scoutReport_action_openWatchlist => 'Open watchlist';

  @override
  String get msg_draftPick_action_openDraft => 'Open draft';

  @override
  String get msg_retirementLeagueDigest_digest_title => 'League retirements';

  @override
  String msg_retirementLeagueDigest_digest_body(int count, int week) {
    return '$count players retired in week $week.';
  }

  @override
  String get msg_draftPickLeague_digest_title => 'Draft-round picks';

  @override
  String get msg_draftPickLeague_digest_body =>
      'A summary of other teams\' draft picks.';

  @override
  String get msg_staffGrowth_digest_title => 'Staff development';

  @override
  String get msg_staffGrowth_digest_body => 'A summary of staff changes.';

  @override
  String get msg_trade_digest_title => 'League trades';

  @override
  String msg_trade_digest_body(int week) {
    return 'A summary of trades in week $week.';
  }

  @override
  String get msg_ovrDigest_digest_title => 'OVR development';

  @override
  String msg_ovrDigest_digest_body(int count, int week) {
    return '$count players improved their OVR in week $week.';
  }

  @override
  String get msg_calendar_newWeek_title => 'New week';

  @override
  String msg_calendar_newWeek_body(Object week) {
    return 'Week $week has started.';
  }

  @override
  String get msg_contractSigned_fa_title => 'Contract signed';

  @override
  String get msg_contractSigned_fa_body =>
      'The player signed a contract with the club.';
}
