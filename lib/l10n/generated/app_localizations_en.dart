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
  String get squad_noTeam => 'No player team';

  @override
  String squad_sizeLabel(int size, int min, int max) {
    return 'Squad: $size / $min–$max';
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
  String get standings_noLeague => 'No league';

  @override
  String get standings_tabEast => 'East';

  @override
  String get standings_tabWest => 'West';

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
  String get finance_noTeam => 'No player team';

  @override
  String get finance_title => 'Finance';

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
  String get trade_title => 'Trade';

  @override
  String get trade_noTeam => 'No team';

  @override
  String get trade_yourPlayer => 'Your player';

  @override
  String get trade_targetTeam => 'Target team';

  @override
  String get trade_theirPlayer => 'Their player';

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
  String get contract_rejected => 'Offer rejected';

  @override
  String get contract_waiting => 'Player is considering the offer…';

  @override
  String contract_counter(String salary, int years) {
    return 'Counter offer: $salary × $years years';
  }

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
    return 'Hired $name!';
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
  String get router_noMatchData => 'No match data';
}
