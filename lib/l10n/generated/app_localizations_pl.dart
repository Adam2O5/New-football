// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'New Football';

  @override
  String get common_cancel => 'Anuluj';

  @override
  String get common_save => 'Zapisz';

  @override
  String get stat_ovr => 'OVR';

  @override
  String get stat_form => 'Forma';

  @override
  String get stat_cond => 'Cond';

  @override
  String get stat_pv => 'PV';

  @override
  String get stat_pot => 'Pot.';

  @override
  String get stat_height => 'Wzrost';

  @override
  String money_million(String value) {
    return '$value mln';
  }

  @override
  String money_thousand(String value) {
    return '$value tys.';
  }

  @override
  String get day_mon => 'Pon';

  @override
  String get day_tue => 'Wt';

  @override
  String get day_wed => 'Śr';

  @override
  String get day_thu => 'Czw';

  @override
  String get day_fri => 'Pt';

  @override
  String get day_sat => 'Sob';

  @override
  String get day_sun => 'Nd';

  @override
  String get seasonPhase_preseason => 'Przedsezon';

  @override
  String get seasonPhase_regular => 'Sezon zasadniczy';

  @override
  String get seasonPhase_playIn => 'Play-in';

  @override
  String get seasonPhase_playoff => 'Playoffy';

  @override
  String get seasonPhase_draft => 'Draft';

  @override
  String get seasonPhase_offseason => 'Offseason';

  @override
  String get matchEvent_goal => 'Gol';

  @override
  String get matchEvent_yellowCard => 'Żółta kartka';

  @override
  String get matchEvent_redCard => 'Czerwona kartka';

  @override
  String get matchEvent_minorInjury => 'Drobna kontuzja';

  @override
  String get matchEvent_majorInjury => 'Poważna kontuzja';

  @override
  String get matchEvent_substitution => 'Zmiana';

  @override
  String get matchEvent_scoredPenalty => 'Wykorzystany karny';

  @override
  String get matchEvent_missedPenalty => 'Niewykorzystany karny';

  @override
  String get matchEvent_halfTime => 'Przerwa';

  @override
  String get matchEvent_fullTime => 'Koniec meczu';

  @override
  String get messageType_injury => 'Kontuzja';

  @override
  String get messageType_retirementPlayer => 'Zakończenie kariery zawodnika';

  @override
  String get messageType_retirementStaff => 'Odejście członka sztabu';

  @override
  String get messageType_staffGrowth => 'Rozwój sztabu';

  @override
  String get messageType_award => 'Nagroda';

  @override
  String get messageType_lottery => 'Loteria draftowa';

  @override
  String get messageType_scoutReport => 'Raport skautingowy';

  @override
  String get messageType_combine => 'Combine';

  @override
  String get messageType_mockDraft => 'Prognoza draftu';

  @override
  String get messageType_draftPick => 'Wybór w drafcie';

  @override
  String get messageType_contractOffer => 'Oferta kontraktu';

  @override
  String get messageType_contractSigned => 'Podpisany kontrakt';

  @override
  String get messageType_trade => 'Wymiana';

  @override
  String get messageType_walkover => 'Walkower';

  @override
  String get messageType_matchPreview => 'Zapowiedź meczu';

  @override
  String get messageType_matchResult => 'Wynik meczu';

  @override
  String get messageType_atmosphere => 'Atmosfera w drużynie';

  @override
  String get messageType_calendar => 'Kalendarz';

  @override
  String get messageType_system => 'System';

  @override
  String get notificationLevel_important => 'Ważne';

  @override
  String get notificationLevel_normal => 'Normalne';

  @override
  String get notificationLevel_muted => 'Wyciszone';

  @override
  String get tempo_slow => 'Wolne';

  @override
  String get tempo_balanced => 'Zbalansowane';

  @override
  String get tempo_fast => 'Szybkie';

  @override
  String get pressing_low => 'Niski';

  @override
  String get pressing_medium => 'Średni';

  @override
  String get pressing_high => 'Wysoki';

  @override
  String get pressing_gegenpressing => 'Gegenpressing';

  @override
  String get defensiveLine_deep => 'Głęboka';

  @override
  String get defensiveLine_normal => 'Standardowa';

  @override
  String get defensiveLine_high => 'Wysoka';

  @override
  String get attackWidth_narrow => 'Wąska';

  @override
  String get attackWidth_balanced => 'Zbalansowana';

  @override
  String get attackWidth_wide => 'Szeroka';

  @override
  String get mainMenu_subtitle => 'Menedżer ligi w stylu NBA';

  @override
  String get mainMenu_newGame => 'Nowa gra';

  @override
  String get mainMenu_loadGame => 'Wczytaj';

  @override
  String get mainMenu_settings => 'Ustawienia';

  @override
  String get mainMenu_exitGame => 'Opuść grę';

  @override
  String get settings_title => 'Ustawienia';

  @override
  String get settings_language => 'Język';

  @override
  String get settings_language_polish => 'Polski';

  @override
  String get settings_language_english => 'English';

  @override
  String get newGame_title => 'Nowa gra';

  @override
  String get newGame_defaultSaveName => 'Moja kariera';

  @override
  String get newGame_missingFields => 'Podaj nazwę zapisu i wybierz drużynę';

  @override
  String get newGame_createFailed => 'Nie udało się utworzyć gry';

  @override
  String get newGame_saveName => 'Nazwa zapisu';

  @override
  String get newGame_difficulty => 'Trudność';

  @override
  String get newGame_difficultyNormal => 'Normalna';

  @override
  String get newGame_difficultyHard => 'Trudna';

  @override
  String get newGame_chooseTeam => 'Wybierz drużynę';

  @override
  String get newGame_start => 'Rozpocznij karierę';

  @override
  String get loadGame_title => 'Wczytaj grę';

  @override
  String loadGame_error(String error) {
    return 'Błąd: $error';
  }

  @override
  String get loadGame_empty => 'Brak zapisów';

  @override
  String loadGame_subtitle(String teamName, int year, String phase) {
    return '$teamName · Sezon $year · $phase';
  }

  @override
  String get loadGame_loadFailed => 'Nie udało się wczytać zapisu';

  @override
  String loadGame_incompatibleOlder(Object currentVersion, Object version) {
    return 'Zapis pochodzi ze starszej wersji ($version), wymagane jest $currentVersion.';
  }

  @override
  String loadGame_incompatibleNewer(Object currentVersion, Object version) {
    return 'Zapis pochodzi z nowszej wersji ($version), obsługiwana jest wersja $currentVersion.';
  }

  @override
  String get loadGame_delete => 'Usuń';

  @override
  String get loadGame_deleteConfirmTitle => 'Usunąć zapis?';

  @override
  String loadGame_deleteConfirmMessage(String name) {
    return 'Zapis „$name” zostanie trwale usunięty.';
  }

  @override
  String get loadGame_deleteFailed => 'Nie udało się usunąć zapisu';

  @override
  String get shell_noActiveGame => 'Brak aktywnej gry';

  @override
  String get shell_mainMenu => 'Menu główne';

  @override
  String get shell_defaultCareerName => 'Kariera';

  @override
  String get shell_draftTooltip => 'Draft';

  @override
  String get shell_menuTooltip => 'Menu';

  @override
  String get shell_tab_calendar => 'Kalendarz';

  @override
  String get shell_tab_squad => 'Skład';

  @override
  String get shell_tab_tactics => 'Taktyka';

  @override
  String get shell_tab_standings => 'Tabela';

  @override
  String get shell_tab_finance => 'Finanse';

  @override
  String get shell_tab_inbox => 'Skrzynka';

  @override
  String get shell_tab_home => 'Start';

  @override
  String get shell_tab_other => 'Inne';

  @override
  String get shell_settingsTooltip => 'Ustawienia';

  @override
  String get shell_saveTooltip => 'Zapisz';

  @override
  String get other_title => 'Inne';

  @override
  String get other_workInProgress => 'W trakcie prac';

  @override
  String get other_tradeHistory => 'Historia wymian';

  @override
  String get other_teamOverview => 'Przegląd drużyny';

  @override
  String get other_finances => 'Finanse';

  @override
  String get teamOverview_title => 'Przegląd drużyny';

  @override
  String get teamOverview_noLeague => 'Brak aktywnej ligi';

  @override
  String get teamOverview_invalidTeam => 'Drużyna gracza jest niedostępna';

  @override
  String teamOverview_conference(Object conference) {
    return 'Konferencja: $conference';
  }

  @override
  String get teamOverview_conferenceEurope => 'Europa';

  @override
  String get teamOverview_conferenceRestOfWorld => 'Reszta świata';

  @override
  String get teamOverview_standings => 'Tabela';

  @override
  String get teamOverview_record => 'Bilans';

  @override
  String get teamOverview_conferenceRank => 'Miejsce w konferencji';

  @override
  String get teamOverview_overallRank => 'Miejsce w tabeli ogólnej';

  @override
  String get teamOverview_financials => 'Finanse';

  @override
  String get teamOverview_payroll => 'Payroll';

  @override
  String get teamOverview_cap => 'Salary cap';

  @override
  String get teamOverview_capSpace => 'Wolne miejsce pod capem';

  @override
  String get teamOverview_teamState => 'Stan drużyny';

  @override
  String get teamOverview_atmosphere => 'Atmosfera';

  @override
  String get teamOverview_chemistry => 'Chemia';

  @override
  String get teamOverview_roster => 'Skład';

  @override
  String get teamOverview_staff => 'Sztab';

  @override
  String get teamOverview_nextAction => 'Następna akcja';

  @override
  String get teamOverview_action => 'Akcja';

  @override
  String get teamOverview_nextMatch => 'Następny mecz';

  @override
  String get teamOverview_noNextAction => 'Brak nadchodzącej akcji';

  @override
  String get teamOverview_calendarPosition => 'Kalendarz';

  @override
  String teamOverview_weekDay(Object day, Object week) {
    return 'Tydzień $week, dzień $day';
  }

  @override
  String get teamOverview_navigation => 'Otwórz ekrany';

  @override
  String get teamOverview_viewSquad => 'Skład';

  @override
  String get teamOverview_viewStats => 'Statystyki';

  @override
  String get teamOverview_viewStaff => 'Sztab';

  @override
  String get teamOverview_viewFinance => 'Finanse';

  @override
  String get teamOverview_viewSearch => 'Szukaj';

  @override
  String get other_contracts => 'Kontrakty';

  @override
  String get other_freeAgency => 'Wolni agenci';

  @override
  String get other_prospects => 'Prospekci';

  @override
  String get other_staff => 'Sztab';

  @override
  String get other_development => 'Rozwój';

  @override
  String get other_playerStats => 'Statystyki zawodników';

  @override
  String get other_rewards => 'Nagrody';

  @override
  String get other_search => 'Szukaj';

  @override
  String get other_draftHistory => 'Historia draftu';

  @override
  String get other_rankings => 'Rankingi';

  @override
  String get other_watchlist => 'Lista obserwowanych';

  @override
  String get home_title => 'Start';

  @override
  String get home_next7days => 'Najbliższe 7 dni';

  @override
  String get home_conferenceRankLabel => 'Miejsce w konferencji';

  @override
  String get home_overallRankLabel => 'Miejsce w tabeli ogólnej';

  @override
  String get home_record => 'Bilans drużyny';

  @override
  String get home_lastMatchTitle => 'Poprzedni mecz';

  @override
  String get home_nextMatchTitle => 'Następny mecz';

  @override
  String get home_noPreviousMatch => 'Brak rozegranych meczów';

  @override
  String get home_noNextMatch => 'Brak zaplanowanych meczów';

  @override
  String get home_simulateUntilNextEvent => 'Do następnego wydarzenia';

  @override
  String get squad_noTeam => 'Brak drużyny gracza';

  @override
  String squad_sizeLabel(int size, int min, int max) {
    return 'Skład: $size / $min–$max';
  }

  @override
  String get squad_injury => 'KONTUZJA';

  @override
  String get squad_xiBadge => 'XI';

  @override
  String get squad_bench => 'Ławka';

  @override
  String get squad_reserves => 'Rezerwa';

  @override
  String get squad_tacticsTitle => 'Taktyka';

  @override
  String get squad_selectHint =>
      'Zaznacz zawodnika, potem kliknij drugiego, aby zamienić miejsca';

  @override
  String get squad_cannotFieldInjured =>
      'Kontuzjowany zawodnik nie może wejść do składu meczowego';

  @override
  String get squad_swappedPlaces => 'Zamieniono miejsca zawodników';

  @override
  String get squad_rosterTitle => 'Skład';

  @override
  String get squad_zoneXi => 'XI';

  @override
  String get squad_zoneBench => 'Ławka';

  @override
  String get squad_zoneReserves => 'Rezerwy';

  @override
  String get squad_sortOverall => 'Overall';

  @override
  String get squad_sortAssignedZone => 'Przypisanie';

  @override
  String get squad_sortForm => 'Forma';

  @override
  String get squad_sortPosition => 'Pozycja';

  @override
  String substitute_sheetTitle(String name) {
    return 'Zmiana za $name';
  }

  @override
  String get substitute_sheetSubtitle =>
      'Wybierz zawodnika do zamiany miejscami';

  @override
  String get substitute_sheetEmpty => 'Brak dostępnych zawodników do zmiany';

  @override
  String get standings_noLeague => 'Brak ligi';

  @override
  String get standings_tabEast => 'Europa';

  @override
  String get standings_tabWest => 'Reszta świata';

  @override
  String get standings_empty => 'Brak tabeli';

  @override
  String get standings_col_team => 'Drużyna';

  @override
  String get standings_col_record => 'W-R-P';

  @override
  String get standings_col_points => 'Pkt';

  @override
  String get standings_col_diff => '+/−';

  @override
  String get standings_tabPostseason => 'Faza pucharowa';

  @override
  String get standings_playIn => 'Play-in';

  @override
  String get standings_playoffs => 'Playoffy';

  @override
  String get standings_notStarted => 'Jeszcze się nie rozpoczęło';

  @override
  String get standings_noPostseasonData => 'Brak danych fazy pucharowej';

  @override
  String get standings_match7v8 => '7. vs 8. miejsce';

  @override
  String get standings_match9v10 => '9. vs 10. miejsce';

  @override
  String get standings_playInFinal => 'Finał play-in';

  @override
  String get standings_quarterFinals => 'Ćwierćfinały';

  @override
  String get standings_semiFinals => 'Półfinały';

  @override
  String get standings_conferenceFinals => 'Finał konferencji';

  @override
  String get standings_leagueFinal => 'Finał ligi';

  @override
  String get standings_seriesInProgress => 'Seria w toku';

  @override
  String standings_seriesWinner(String team) {
    return 'Zwycięzca: $team';
  }

  @override
  String standings_champion(String team) {
    return 'Mistrz: $team';
  }

  @override
  String get finance_noTeam => 'Brak drużyny gracza';

  @override
  String get finance_title => 'Finanse';

  @override
  String get finance_payroll => 'Payroll';

  @override
  String get finance_cap => 'Salary cap';

  @override
  String get finance_capSpace => 'Wolne miejsce';

  @override
  String get finance_firstApron => 'Pierwszy apron';

  @override
  String get finance_secondApron => 'Drugi apron';

  @override
  String get finance_tax => 'Podatek luksusowy';

  @override
  String get finance_cash => 'Gotówka';

  @override
  String get finance_status => 'Status';

  @override
  String get finance_capStatus_under => 'Pod capem';

  @override
  String get finance_capStatus_over => 'Powyżej capu';

  @override
  String get finance_trade => 'Wymiany (trade)';

  @override
  String get finance_contracts => 'Kontrakty / przedłużenia';

  @override
  String get finance_capWarning => 'Payroll przekracza salary cap';

  @override
  String get finance_capHealthy => 'Payroll mieści się w salary cap';

  @override
  String get freeAgency_title => 'Wolna agentura';

  @override
  String get freeAgency_noTeam => 'Brak drużyny gracza';

  @override
  String get freeAgency_search => 'Szukaj po nazwie';

  @override
  String get freeAgency_position => 'Pozycja';

  @override
  String get freeAgency_allPositions => 'Wszystkie pozycje';

  @override
  String get freeAgency_minOvr => 'Min. OVR';

  @override
  String get freeAgency_any => 'Dowolny';

  @override
  String get freeAgency_sort => 'Sortowanie';

  @override
  String get freeAgency_sortOvr => 'Overall';

  @override
  String get freeAgency_sortName => 'Nazwa';

  @override
  String freeAgency_poolCount(Object count) {
    return 'Dostępni wolni agenci: $count';
  }

  @override
  String freeAgency_rosterUsage(Object count) {
    return 'Skład: $count/30';
  }

  @override
  String get freeAgency_empty => 'Brak wolnych agentów pasujących do filtrów';

  @override
  String freeAgency_playerSubtitle(Object ovr, Object position, Object salary) {
    return '$position · OVR $ovr · Szacowana pensja: $salary';
  }

  @override
  String freeAgency_contractHeader(Object name) {
    return 'Oferta dla $name';
  }

  @override
  String freeAgency_marketDemand(Object salary) {
    return 'Szacowana pensja rynkowa: $salary';
  }

  @override
  String get freeAgency_offerSalary => 'Oferta pensji';

  @override
  String get freeAgency_offerYears => 'Lata kontraktu';

  @override
  String get freeAgency_submitOffer => 'Złóż ofertę';

  @override
  String get freeAgency_selectPlayer => 'Najpierw wybierz wolnego agenta';

  @override
  String get freeAgency_invalidOffer =>
      'Podaj prawidłową pensję i 1–5 lat kontraktu';

  @override
  String get freeAgency_accepted => 'Oferta przyjęta, zawodnik podpisany';

  @override
  String get freeAgency_rejected => 'Oferta odrzucona';

  @override
  String get freeAgency_waiting => 'Zawodnik rozważa ofertę';

  @override
  String freeAgency_counter(Object salary, Object years) {
    return 'Zawodnik złożył kontrofertę: $salary × $years lat';
  }

  @override
  String get freeAgency_rosterFull => 'Skład jest pełny';

  @override
  String get freeAgency_status => 'Status oferty';

  @override
  String freeAgency_capSpace(Object amount) {
    return 'Wolne miejsce pod capem: $amount';
  }

  @override
  String get tactics_noTeam => 'Brak drużyny gracza';

  @override
  String get tactics_formation => 'Formacja';

  @override
  String get tactics_tempo => 'Tempo';

  @override
  String get tactics_pressing => 'Pressing';

  @override
  String get tactics_defensiveLine => 'Linia obrony';

  @override
  String get tactics_attackWidth => 'Szerokość ataku';

  @override
  String get tactics_save => 'Zapisz taktykę';

  @override
  String get tactics_saved => 'Zapisano taktykę';

  @override
  String get inbox_title => 'Skrzynka';

  @override
  String get inbox_notifications => 'Powiadomienia';

  @override
  String get inbox_empty => 'Skrzynka pusta';

  @override
  String inbox_messageSubtitle(int week, String body) {
    return 'Tydzień $week\n$body';
  }

  @override
  String get inbox_settingsTitle => 'Poziomy powiadomień';

  @override
  String get draft_title => 'Draft';

  @override
  String get draft_notActive => 'Draft jeszcze nieaktywny';

  @override
  String get draft_finished => 'Draft zakończony';

  @override
  String draft_pickLabel(int number, int round) {
    return 'Pick #$number (R$round)';
  }

  @override
  String draft_teamLabel(String name) {
    return 'Drużyna: $name';
  }

  @override
  String get draft_yourTurn => 'Twoja kolej!';

  @override
  String draft_remainingProspects(int count) {
    return 'Pozostali prospecti ($count)';
  }

  @override
  String get draft_select => 'Wybierz';

  @override
  String draft_selected(String name) {
    return 'Wybrano: $name';
  }

  @override
  String get calendar_noLeague => 'Brak ligi';

  @override
  String calendar_weekDayHeader(int week, String dayName, int day) {
    return 'Tydzień $week · $dayName (dzień $day)';
  }

  @override
  String calendar_phaseLine(String phase, int year) {
    return 'Faza: $phase · Sezon $year';
  }

  @override
  String get calendar_homeLabel => 'Home';

  @override
  String get calendar_event_tradeDeadline => 'Deadline wymiany';

  @override
  String get calendar_event_awards => 'Nagrody';

  @override
  String get calendar_event_retirements => 'Emerytury';

  @override
  String get calendar_event_draftLottery => 'Loteria draftu';

  @override
  String get calendar_event_scoutReport => 'Raport skautingowy';

  @override
  String get calendar_event_combine => 'Draft Combine';

  @override
  String get calendar_event_mockDraft => 'Mock Draft (finalny)';

  @override
  String get calendar_event_draft => 'Draft';

  @override
  String get calendar_event_freeAgency => 'Wolna agentura';

  @override
  String get calendar_draft => 'Draft';

  @override
  String calendar_pickProgress(int current, int total) {
    return 'Pick $current/$total';
  }

  @override
  String get calendar_weekEvents => 'Wydarzenia tygodnia';

  @override
  String get calendar_noMatches => 'Brak meczów w tym tygodniu';

  @override
  String get calendar_simulateDay => 'Symuluj dzień';

  @override
  String get calendar_urgentMessage => 'Pilna wiadomość w skrzynce';

  @override
  String get calendar_fastForward => 'Szybka symulacja';

  @override
  String get calendar_simulateUntilNextMatch => 'Do następnego meczu';

  @override
  String get calendar_simulateUntilDate => 'Do wybranej daty';

  @override
  String get calendar_simulateUntilPhaseEnd => 'Do końca fazy';

  @override
  String get calendar_chooseDateTitle => 'Wybierz cel symulacji';

  @override
  String get calendar_weekLabel => 'Tydzień';

  @override
  String get calendar_dayLabel => 'Dzień';

  @override
  String get calendar_simulating => 'Symulowanie…';

  @override
  String calendar_daysSimulated(int count) {
    return 'Zasymulowano dni: $count';
  }

  @override
  String get calendar_cancel => 'Anuluj';

  @override
  String get calendar_stopReason_reachedTarget => 'Cel osiągnięty';

  @override
  String get calendar_stopReason_cancelled => 'Symulacja przerwana';

  @override
  String get calendar_stopReason_draftPick => 'Twoja tura draftu';

  @override
  String get calendar_stopReason_noSave => 'Brak zapisanej gry';

  @override
  String get calendar_selectedDay_title => 'Wybrany dzień';

  @override
  String get calendar_selectedDay_noEvent => 'Brak wydarzeń tego dnia';

  @override
  String calendar_selectedDay_matchUpcoming(String opponent) {
    return 'Nadchodzący mecz: $opponent';
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
    return 'Wydarzenie: $name';
  }

  @override
  String get trade_title => 'Wymiana';

  @override
  String get trade_noTeam => 'Brak drużyny';

  @override
  String get trade_yourPlayer => 'Twój zawodnik';

  @override
  String get trade_yourPick => 'Twój pick draftowy';

  @override
  String get trade_targetTeam => 'Drużyna docelowa';

  @override
  String get trade_theirPlayer => 'Ich zawodnik';

  @override
  String get trade_theirPick => 'Ich pick draftowy';

  @override
  String get trade_confirm => 'Zatwierdź wymianę';

  @override
  String get trade_fillAllFields => 'Uzupełnij wszystkie pola';

  @override
  String get trade_notAllowed => 'Wymiana niedozwolona';

  @override
  String get trade_aiRejected => 'Druga drużyna odrzuciła propozycję wymiany';

  @override
  String get trade_executeFailed => 'Nie udało się wykonać wymiany';

  @override
  String get trade_success => 'Wymiana zakończona sukcesem';

  @override
  String trade_playerOption(String name, String position, int pv) {
    return '$name ($position, PV $pv)';
  }

  @override
  String get contract_title => 'Kontrakty';

  @override
  String get contract_noTeam => 'Brak drużyny';

  @override
  String get contract_expiringHeader => 'Wygasające / do przedłużenia';

  @override
  String get contract_noExpiring => 'Brak zawodników do przedłużenia';

  @override
  String contract_playerSubtitle(
    String position,
    int ovr,
    int years,
    String salary,
  ) {
    return '$position · OVR $ovr · Lata: $years · $salary';
  }

  @override
  String get contract_freeAgentsHeader => 'Wolni agenci (lata = 0 w lidze)';

  @override
  String get contract_freeAgentsEmpty =>
      'Pula FA pusta / uproszczona — skup się na przedłużeniach.';

  @override
  String contract_freeAgentsCount(int count) {
    return '$count zawodników z yearsRemaining=0';
  }

  @override
  String get contract_offerSalary => 'Oferta pensji';

  @override
  String get contract_offerYears => 'Lata kontraktu';

  @override
  String get contract_submitOffer => 'Złóż ofertę przedłużenia';

  @override
  String get contract_selectPlayer => 'Wybierz zawodnika';

  @override
  String get contract_invalidOffer => 'Nieprawidłowa pensja lub lata';

  @override
  String get contract_accepted => 'Kontrakt przyjęty!';

  @override
  String get contract_rejected => 'Odrzucono ofertę';

  @override
  String get contract_waiting => 'Zawodnik rozważa ofertę…';

  @override
  String contract_counter(String salary, int years) {
    return 'Kontroferta: $salary × $years lat';
  }

  @override
  String get staff_title => 'Sztab';

  @override
  String get staff_noTeam => 'Brak drużyny';

  @override
  String get staffRole_headCoach => 'Trener główny';

  @override
  String get staffRole_youthCoach => 'Trener młodzieży';

  @override
  String get staffRole_scout => 'Scout';

  @override
  String get staffRole_physio => 'Fizjoterapeuta';

  @override
  String get staffRole_doctor => 'Lekarz';

  @override
  String get staffRole_cfo => 'CFO';

  @override
  String get staff_emptySlot => 'Slot wolny';

  @override
  String get staff_fire => 'Zwolnij';

  @override
  String get staff_candidatesHeader => 'Kandydaci do zatrudnienia';

  @override
  String get staff_noCandidates => 'Brak wolnych kandydatów na tę rolę';

  @override
  String staff_overallStars(String stars) {
    return '★ $stars';
  }

  @override
  String staff_memberSubtitle(int age, String stars, String salary) {
    return '$age lat · ★ $stars · $salary/rok';
  }

  @override
  String get staff_hire => 'Zatrudnij';

  @override
  String staff_hireAccepted(String name) {
    return 'Zatrudniono $name!';
  }

  @override
  String get staff_hireRejected =>
      'Kandydat odrzucił ofertę lub przekroczono staff cap';

  @override
  String get staff_capLabel => 'Staff cap';

  @override
  String staff_capUsage(String used, String cap) {
    return '$used / $cap';
  }

  @override
  String get scouting_watchlistTitle => 'Watchlista skauta';

  @override
  String scouting_watchlistLimit(int selected, int limit) {
    return 'Wybrano $selected / $limit';
  }

  @override
  String get scouting_cancel => 'Anuluj';

  @override
  String get scouting_save => 'Zapisz';

  @override
  String get scouting_slot_top1 => 'Typ: TOP 1';

  @override
  String get scouting_slot_top3 => 'Typ: TOP 3';

  @override
  String get scouting_slot_top5 => 'Typ: TOP 5';

  @override
  String get scouting_slot_top10 => 'Typ: TOP 10';

  @override
  String get scouting_slot_r1 => 'Typ: R1';

  @override
  String get scouting_slot_r2 => 'Typ: R2';

  @override
  String get scouting_slot_r3 => 'Typ: R3';

  @override
  String get scouting_slot_x => 'Typ: X';

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
    return 'Kontuzje $value/10';
  }

  @override
  String draft_determinationShort(int value) {
    return 'Determinacja $value/10';
  }

  @override
  String get contract_faCounter =>
      'Kontroferta na rynku FA — spróbuj ponownie z wyższą ofertą';

  @override
  String get playerDetail_title => 'Zawodnik';

  @override
  String get playerDetail_notFound => 'Nie znaleziono zawodnika';

  @override
  String playerDetail_headerLine(String position, String nationality, int age) {
    return '$position · $nationality · $age lat';
  }

  @override
  String get playerDetail_attributes => 'Atrybuty';

  @override
  String get playerDetail_contract => 'Kontrakt';

  @override
  String playerDetail_salaryLine(String salary) {
    return 'Pensja: $salary / rok';
  }

  @override
  String playerDetail_contractYears(int years) {
    return 'Lata: $years';
  }

  @override
  String get playerDetail_birdRights => 'Bird rights';

  @override
  String get playerDetail_noTradeClause => 'NTC';

  @override
  String playerDetail_personality(String personality) {
    return 'Osobowość: $personality';
  }

  @override
  String get matchday_defaultTitle => 'Mecz';

  @override
  String matchday_finishedSnackbar(int home, int away) {
    return 'Koniec: $home:$away';
  }

  @override
  String get matchday_resume => 'Wznów';

  @override
  String get matchday_pause => 'Pauza';

  @override
  String get matchday_toEnd => 'Do końca';

  @override
  String get router_noMatchData => 'Brak danych meczu';

  @override
  String get dev_title => 'Rozwój';

  @override
  String get dev_tabPlayers => 'Zawodnicy';

  @override
  String get dev_tabStaff => 'Sztab';

  @override
  String get dev_noTeam => 'Brak danych drużyny';

  @override
  String get dev_noPlayers => 'Brak zawodników';

  @override
  String get dev_vacant => 'Wakancja';

  @override
  String get dev_colName => 'Nazwa';

  @override
  String get dev_colAge => 'Wiek';

  @override
  String get dev_colPotential => 'Pot.';

  @override
  String get dev_colOvr => 'OVR';

  @override
  String get dev_colChange => '+/-';

  @override
  String get staffAttr_tactics => 'Taktyka';

  @override
  String get staffAttr_motivation => 'Motywacja';

  @override
  String get staffAttr_development => 'Rozwój';

  @override
  String get staffAttr_mentoring => 'Mentoring';

  @override
  String get staffAttr_coverage => 'Zasięg';

  @override
  String get staffAttr_evaluation => 'Ocena';

  @override
  String get staffAttr_rehabilitation => 'Rehabilitacja';

  @override
  String get staffAttr_regenaration => 'Regeneracja';

  @override
  String get staffAttr_prevention => 'Prewencja';

  @override
  String get staffAttr_care => 'Opieka';

  @override
  String get staffAttr_negotiation => 'Negocjacje';

  @override
  String get prospects_title => 'Prospekci';

  @override
  String get prospects_name => 'Nazwa';

  @override
  String get prospects_nationality => 'Narodowość';

  @override
  String get prospects_age => 'Wiek';

  @override
  String get prospects_positionShort => 'Poz.';

  @override
  String get prospects_combine => 'Combine';

  @override
  String get prospects_grade => 'Ocena';

  @override
  String get prospects_stars => 'Gwiazdy';

  @override
  String get prospects_injuryShort => 'Kontuzje';

  @override
  String get prospects_determinationShort => 'Det.';

  @override
  String get prospects_slot => 'Slot';

  @override
  String get prospects_noDraftClass => 'Brak dostępnej klasy draftowej';

  @override
  String get prospects_empty => 'Brak prospektów pasujących do filtrów';

  @override
  String get prospects_search => 'Szukaj po nazwie';

  @override
  String get prospects_position => 'Pozycja';

  @override
  String get prospects_allPositions => 'Wszystkie pozycje';

  @override
  String get prospects_watchOnly => 'Tylko obserwowani';

  @override
  String get prospects_sort => 'Sortowanie';

  @override
  String get prospects_sortName => 'Nazwa';

  @override
  String get prospects_sortOvr => 'Prognozowany OVR';

  @override
  String get prospects_sortGrade => 'Ocena skauta';

  @override
  String get prospects_sortPotential => 'Potencjał';

  @override
  String get prospects_watchlist => 'Watchlista';

  @override
  String get prospects_watched => 'Obserwowany';

  @override
  String get prospects_saveWatchlist => 'Zapisz watchlistę';

  @override
  String prospects_coverage(Object limit, Object selected, Object stars) {
    return 'Coverage: $stars★ · $selected/$limit';
  }

  @override
  String get prospects_scoutingData => 'Dane skautingowe';

  @override
  String get prospects_noScouting =>
      'Brak danych skautingowych. Dodaj prospekta do watchlisty.';

  @override
  String get prospects_combineScore => 'Wynik Combine';

  @override
  String get prospects_scoutGrade => 'Ocena skauta';

  @override
  String get prospects_potential => 'Potencjał';

  @override
  String get prospects_injuryProne => 'Podatność na kontuzje';

  @override
  String get prospects_determination => 'Determinacja';

  @override
  String get prospects_estimatedSlot => 'Szacowany slot';

  @override
  String get prospects_unknown => 'Nieznane';

  @override
  String get playerDetail_health => 'Zdrowie';

  @override
  String get playerDetail_available => 'Dostępny';

  @override
  String playerDetail_injury(Object type) {
    return 'Kontuzja: $type';
  }

  @override
  String playerDetail_injuryDays(Object days) {
    return 'Pozostało dni: $days';
  }

  @override
  String get playerDetail_roleTeam => 'Rola i drużyna';

  @override
  String playerDetail_currentRole(Object role) {
    return 'Aktualna rola: $role';
  }

  @override
  String playerDetail_optimalRole(Object role) {
    return 'Optymalna rola: $role';
  }

  @override
  String playerDetail_seasonsWithTeam(Object seasons) {
    return 'Sezony w drużynie: $seasons';
  }

  @override
  String get playerDetail_history => 'Historia sezonów';

  @override
  String get playerDetail_career => 'Suma kariery';

  @override
  String get playerDetail_season => 'Sezon';

  @override
  String get playerDetail_appearances => 'Występy';

  @override
  String get playerDetail_minutes => 'Minuty';

  @override
  String get playerDetail_goals => 'Gole';

  @override
  String get playerDetail_assists => 'Asysty';

  @override
  String get playerDetail_rating => 'Ocena';

  @override
  String get playerDetail_noHistory => 'Brak statystyk sezonowych';

  @override
  String get squad_filters => 'Filtry składu';

  @override
  String get squad_search => 'Szukaj po nazwie';

  @override
  String get squad_position => 'Pozycja';

  @override
  String get squad_allPositions => 'Wszystkie pozycje';

  @override
  String get squad_zone => 'Strefa';

  @override
  String get squad_allZones => 'Wszystkie strefy';

  @override
  String get squad_availability => 'Dostępność';

  @override
  String get squad_allPlayers => 'Wszyscy zawodnicy';

  @override
  String get squad_available => 'Dostępni';

  @override
  String get squad_injuredOnly => 'Kontuzjowani';

  @override
  String get squad_minOvr => 'Min. OVR';

  @override
  String get squad_minForm => 'Min. forma';

  @override
  String get squad_any => 'Dowolna';

  @override
  String get squad_clearFilters => 'Wyczyść filtry';

  @override
  String get squad_noPlayers => 'Brak zawodników pasujących do filtrów';

  @override
  String get squad_matchday => 'Skład meczowy';

  @override
  String squad_healthy(Object count) {
    return 'Zdrowi: $count';
  }

  @override
  String get squad_belowXi =>
      'Dostępnych jest mniej niż 11 zdrowych zawodników';

  @override
  String squad_xiCount(Object count) {
    return 'XI: $count';
  }

  @override
  String squad_benchCount(Object count) {
    return 'Ławka: $count';
  }

  @override
  String squad_reserveCount(Object count) {
    return 'Rezerwy: $count';
  }

  @override
  String get draftHistory_title => 'Historia draftu';

  @override
  String get draftHistory_noDraftData => 'Brak danych draftu';

  @override
  String get draftHistory_currentDraft => 'Bieżący draft';

  @override
  String draftHistory_season(Object year) {
    return 'Sezon $year';
  }

  @override
  String draftHistory_pick(Object number) {
    return 'Pick $number';
  }

  @override
  String draftHistory_round(Object round) {
    return 'Runda $round';
  }

  @override
  String get draftHistory_team => 'Drużyna';

  @override
  String get draftHistory_originalTeam => 'Pierwotna drużyna';

  @override
  String get draftHistory_player => 'Zawodnik';

  @override
  String get draftHistory_noPicks => 'Brak zakończonych wyborów';

  @override
  String get draftHistory_lottery => 'Wyniki loterii';

  @override
  String get draftHistory_noLottery => 'Brak wyników loterii dla tego sezonu';

  @override
  String get rankings_title => 'Rankingi';

  @override
  String get rankings_power => 'Ranking siły';

  @override
  String get rankings_expected => 'Przewidywane miejsce';

  @override
  String get rankings_assets => 'Aktywa transferowe';

  @override
  String get rankings_noStrength => 'Ranking siły nie został jeszcze obliczony';

  @override
  String get rankings_rank => 'Miejsce';

  @override
  String get rankings_team => 'Drużyna';

  @override
  String get rankings_powerValue => 'Siła';

  @override
  String get rankings_status => 'Status';

  @override
  String rankings_updated(Object day, Object week) {
    return 'Aktualizacja: tydzień $week, dzień $day';
  }

  @override
  String get rankings_expectedDisclaimer =>
      'Przewidywane miejsce odzwierciedla siłę składu, a nie symulację końcowej tabeli.';

  @override
  String get rankings_assetValue => 'Wartość';

  @override
  String get rankings_assetType => 'Typ';

  @override
  String get rankings_owner => 'Właściciel';

  @override
  String get rankings_noAssets => 'Brak dostępnych aktywów transferowych';

  @override
  String get rankings_playerAsset => 'Zawodnik';

  @override
  String get rankings_pickAsset => 'Pick draftowy';

  @override
  String get rankings_statusRebuild => 'Przebudowa';

  @override
  String get rankings_statusRetool => 'Retool';

  @override
  String get rankings_statusPretender => 'Pretendent';

  @override
  String get rankings_statusContender => 'Faworyt';

  @override
  String get rankings_statusElite => 'Elita';

  @override
  String get stats_title => 'Statystyki';

  @override
  String get stats_players => 'Statystyki zawodników';

  @override
  String get stats_teamOverview => 'Przegląd drużyn';

  @override
  String get stats_noStats => 'Brak zapisanych statystyk meczowych';

  @override
  String get stats_search => 'Szukaj zawodnika';

  @override
  String get stats_sort => 'Sortowanie';

  @override
  String get stats_sortOvr => 'OVR';

  @override
  String get stats_sortGoals => 'Gole';

  @override
  String get stats_sortAssists => 'Asysty';

  @override
  String get stats_sortRating => 'Ocena';

  @override
  String get stats_player => 'Zawodnik';

  @override
  String get stats_team => 'Drużyna';

  @override
  String get stats_appearances => 'Występy';

  @override
  String get stats_minutes => 'Minuty';

  @override
  String get stats_goals => 'Gole';

  @override
  String get stats_assists => 'Asysty';

  @override
  String get stats_rating => 'Ocena';

  @override
  String get stats_record => 'Bilans';

  @override
  String get stats_roster => 'Skład';

  @override
  String get stats_averageOvr => 'Średni OVR';

  @override
  String get stats_injured => 'Kontuzjowani';

  @override
  String get stats_payroll => 'Payroll';

  @override
  String get stats_atmosphere => 'Atmosfera';

  @override
  String get stats_chemistry => 'Chemia';

  @override
  String get stats_status => 'Status';

  @override
  String get stats_noStandings => 'Brak dostępnej tabeli';

  @override
  String get rewards_title => 'Nagrody';

  @override
  String get rewards_noAwards => 'Nagrody nie zostały jeszcze obliczone';

  @override
  String get rewards_notAwarded => 'Nie przyznano';

  @override
  String get rewards_mvp => 'MVP';

  @override
  String get rewards_roty => 'Debiutant roku';

  @override
  String get rewards_dpoy => 'Obrońca roku';

  @override
  String get rewards_topScorer => 'Najlepszy strzelec';

  @override
  String get rewards_topAssist => 'Najlepszy asystent';

  @override
  String get rewards_bestGk => 'Najlepszy bramkarz';

  @override
  String get rewards_coachOfYear => 'Trener roku';

  @override
  String get rewards_champion => 'Mistrz';

  @override
  String get rewards_teamOfSeason => 'Drużyna sezonu';

  @override
  String get search_title => 'Wyszukiwanie';

  @override
  String get search_hint => 'Szukaj drużyn, zawodników i prospektów';

  @override
  String get search_allTypes => 'Wszystkie typy';

  @override
  String get search_players => 'Zawodnicy';

  @override
  String get search_teams => 'Drużyny';

  @override
  String get search_prospects => 'Prospekci';

  @override
  String get search_freeAgents => 'Wolni agenci';

  @override
  String get search_noResults => 'Brak wyników';

  @override
  String get search_tradeAction => 'Wymień';

  @override
  String search_teamResult(Object conference) {
    return 'Drużyna · $conference';
  }

  @override
  String search_playerResult(Object position, Object team) {
    return 'Zawodnik · $team · $position';
  }

  @override
  String search_prospectResult(Object age, Object position) {
    return 'Prospekt · $position · wiek $age';
  }

  @override
  String search_freeAgentResult(Object ovr, Object position) {
    return 'Wolny agent · $position · OVR $ovr';
  }
}
