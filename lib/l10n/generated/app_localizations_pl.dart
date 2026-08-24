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
  String get matchEvent_foul => 'Faul';

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
  String get notificationLevel_auto => 'Automatyczne';

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
  String get newGame_teamSelected => 'Zaznaczona';

  @override
  String get newGame_teamNotSelected => 'Niezaznaczona';

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
  String get loadGame_load => 'Wczytaj';

  @override
  String get loadGame_loadTooltip => 'Wczytaj zapis';

  @override
  String get loadGame_deleteTooltip => 'Usuń zapis';

  @override
  String get loadGame_duplicate => 'Duplikuj';

  @override
  String get loadGame_duplicateTooltip => 'Utwórz kopię zapisu';

  @override
  String get loadGame_rename => 'Zmień nazwę';

  @override
  String get loadGame_renameTooltip => 'Zmień nazwę zapisu';

  @override
  String get loadGame_renameTitle => 'Zmień nazwę zapisu';

  @override
  String loadGame_renameMessage(String name) {
    return 'Podaj nową nazwę zapisu „$name”.';
  }

  @override
  String get loadGame_renameLabel => 'Nazwa zapisu';

  @override
  String get loadGame_renameHint => 'Wpisz nazwę';

  @override
  String get loadGame_renameConfirm => 'Zmień nazwę';

  @override
  String get loadGame_nameEmpty => 'Nazwa zapisu nie może być pusta.';

  @override
  String get loadGame_nameTaken => 'Ta nazwa jest już zajęta.';

  @override
  String get loadGame_nameSame => 'Wybierz inną nazwę niż obecna.';

  @override
  String loadGame_duplicateSuccess(String name) {
    return 'Utworzono kopię zapisu „$name”.';
  }

  @override
  String loadGame_renameSuccess(String name) {
    return 'Zmieniono nazwę zapisu na „$name”.';
  }

  @override
  String get loadGame_duplicateFailed => 'Nie udało się utworzyć kopii zapisu.';

  @override
  String get loadGame_renameFailed => 'Nie udało się zmienić nazwy zapisu.';

  @override
  String get loadGame_readFailed =>
      'Nie udało się odczytać zapisów. Spróbuj ponownie.';

  @override
  String get loadGame_indexReadFailed =>
      'Nie udało się odczytać listy zapisów. Spróbuj ponownie.';

  @override
  String get loadGame_sourceUnavailable => 'Plik zapisu jest niedostępny.';

  @override
  String get loadGame_invalidSerializedSave =>
      'Plik zapisu jest nieprawidłowy.';

  @override
  String get loadGame_writeFailed => 'Nie udało się zapisać zmian.';

  @override
  String get loadGame_sizeUnavailable => 'Rozmiar niedostępny';

  @override
  String get loadGame_ambiguousWrite =>
      'Nie można potwierdzić wyniku operacji. Sprawdź listę zapisów i spróbuj ponownie.';

  @override
  String get loadGame_lastSaveDate => 'Ostatni zapis';

  @override
  String get loadGame_saveSize => 'Rozmiar zapisu';

  @override
  String get loadGame_schemaCompatible => 'Zgodny ze schematem';

  @override
  String get loadGame_schemaOlder => 'Starsza wersja schematu';

  @override
  String get loadGame_schemaNewer => 'Nowsza wersja schematu';

  @override
  String loadGame_loadSemantics(String name) {
    return 'Wczytaj zapis „$name”';
  }

  @override
  String loadGame_deleteSemantics(String name) {
    return 'Usuń zapis „$name”';
  }

  @override
  String loadGame_duplicateSemantics(String name) {
    return 'Utwórz kopię zapisu „$name”';
  }

  @override
  String loadGame_renameSemantics(String name) {
    return 'Zmień nazwę zapisu „$name”';
  }

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
  String get tradeHistory_title => 'Historia wymian';

  @override
  String get tradeHistory_noLeague => 'Brak aktywnej ligi';

  @override
  String get tradeHistory_empty => 'Brak zapisanej historii wymian.';

  @override
  String get tradeHistory_noMatches => 'Brak wymian dla wybranego filtra.';

  @override
  String get tradeHistory_filter => 'Filtr wyniku';

  @override
  String get tradeHistory_allOutcomes => 'Wszystkie wyniki';

  @override
  String get tradeHistory_outcomeAccepted => 'Zaakceptowana';

  @override
  String get tradeHistory_outcomeRejected => 'Odrzucona';

  @override
  String get tradeHistory_outcomeHardRejected => 'Zablokowana';

  @override
  String get tradeHistory_outcomeExpired => 'Wygasła';

  @override
  String get tradeHistory_outcomeNtcRefused => 'Odrzucona przez NTC';

  @override
  String get tradeHistory_outcomeCancelled => 'Anulowana';

  @override
  String tradeHistory_date(int season, int week, int day) {
    return 'Sezon $season, tydzień $week, dzień $day';
  }

  @override
  String tradeHistory_round(int round) {
    return 'Runda $round';
  }

  @override
  String get tradeHistory_reason => 'Powód';

  @override
  String get tradeHistory_ntcProbability => 'Prawdopodobieństwo zgody NTC';

  @override
  String tradeHistory_sentBy(String team) {
    return 'Aktywa od $team';
  }

  @override
  String get tradeHistory_noAssets => 'Brak aktywów';

  @override
  String tradeHistory_player(String name) {
    return 'Zawodnik: $name';
  }

  @override
  String tradeHistory_pick(int year, int round) {
    return 'Pick: $year, runda $round';
  }

  @override
  String tradeHistory_rights(String name) {
    return 'Prawa draftowe: $name';
  }

  @override
  String tradeHistory_unknownAsset(String type) {
    return 'Aktyw: $type';
  }

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
  String get teamOverview_atmosphereMult => 'Mnożnik atmosfery';

  @override
  String get teamOverview_chemistryMult => 'Mnożnik chemii';

  @override
  String get teamOverview_teamPower => 'Siła drużyny';

  @override
  String get teamOverview_expectedRank => 'Oczekiwane miejsce';

  @override
  String get teamOverview_status => 'Status';

  @override
  String get teamOverview_weeklyHistory => 'Historia tygodniowa';

  @override
  String get teamOverview_noHistory => 'Brak zapisanej historii';

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
  String get home_nextActionTitle => 'Najbliższa akcja';

  @override
  String get home_nextEvent => 'wydarzenia';

  @override
  String get home_readUrgent => 'Odczytaj pilną wiadomość';

  @override
  String home_simulateHour(int hour) {
    return 'Symuluj godzinę · $hour/10';
  }

  @override
  String get home_simulateToNextMatch => 'Symuluj do następnego meczu';

  @override
  String get home_simulateUntilEvent => 'Symuluj do wydarzenia';

  @override
  String home_simulateToEvent(String label) {
    return 'Symuluj do: $label';
  }

  @override
  String get home_simulateDay => 'Symuluj dzień';

  @override
  String get home_simulateMatch => 'Symuluj mecz';

  @override
  String home_goToEvent(String label) {
    return 'Przejdź do: $label';
  }

  @override
  String home_simulateEvent(String label) {
    return 'Symuluj: $label';
  }

  @override
  String home_actionExecuted(String label) {
    return 'Wykonano: $label';
  }

  @override
  String home_context(int season, String phase, int week, int day) {
    return 'Sezon $season · $phase · Tydzień $week, dzień $day';
  }

  @override
  String get squad_noTeam => 'Brak drużyny gracza';

  @override
  String squad_sizeLabel(int size, int min, int max) {
    return 'Skład: $size / $min–$max';
  }

  @override
  String squad_rosterCount(int count) {
    return 'Liczba zawodników: $count';
  }

  @override
  String squad_rosterMinimum(int minimum) {
    return 'Minimum: $minimum';
  }

  @override
  String squad_rosterMaximum(int maximum) {
    return 'Maksimum: $maximum';
  }

  @override
  String get squad_rosterStateInRange => 'W zakresie';

  @override
  String get squad_rosterStateOutOfRange => 'Poza zakresem';

  @override
  String squad_rosterSizeSemantics(
    int count,
    int minimum,
    int maximum,
    String state,
  ) {
    return 'Liczba zawodników: $count; minimum: $minimum; maksimum: $maximum; stan: $state.';
  }

  @override
  String get squad_emptyRoster => 'Brak zawodników w składzie.';

  @override
  String get squad_statusInjury => 'Aktywna kontuzja';

  @override
  String get squad_statusSuspension => 'Aktywne zawieszenie';

  @override
  String get squad_positionMismatch => 'Niezgodność pozycji';

  @override
  String squad_playerRowSemantics(
    String name,
    String position,
    int ovr,
    String form,
    String zone,
  ) {
    return '$name, pozycja $position, OVR $ovr, forma $form na 10, strefa $zone';
  }

  @override
  String squad_playerMarkerSemantics(
    String name,
    String position,
    String status,
  ) {
    return '$name, pozycja $position. $status';
  }

  @override
  String squad_zoneFrameSemantics(String zone) {
    return 'Strefa: $zone';
  }

  @override
  String squad_positionBadgeSemantics(String position) {
    return 'Pozycja: $position';
  }

  @override
  String squad_ovrBadgeSemantics(int ovr) {
    return 'OVR: $ovr';
  }

  @override
  String squad_formIndicatorSemantics(String form) {
    return 'Forma: $form na 10';
  }

  @override
  String squad_profileAction(String name) {
    return 'Otwórz profil zawodnika $name';
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
  String get standings_extraTime => ' (dogrywka)';

  @override
  String standings_shootout(int home, int away) {
    return ' (karne $home-$away)';
  }

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
  String get finance_dashboardSubtitle =>
      'Podsumowanie salary cap i dostępnych środków';

  @override
  String get finance_capOverview => 'Salary cap i payroll';

  @override
  String get finance_apronsOverview => 'Aprony';

  @override
  String get finance_cashOverview => 'Gotówka klubu';

  @override
  String finance_apronHeadroom(String first, String second) {
    return 'Do pierwszego apronu: $first; do drugiego: $second';
  }

  @override
  String get finance_financialHealth => 'Kondycja finansowa';

  @override
  String get finance_actions => 'Akcje finansowe';

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
  String get freeAgency_accepted => 'Oferta przyjęta — potwierdź finalizację';

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
  String get market_status => 'Rynek kontraktów';

  @override
  String get market_negotiations => 'Negocjacje';

  @override
  String get market_noNegotiations => 'Brak zapisanych negocjacji.';

  @override
  String get market_offerPreview => 'Podgląd oferty';

  @override
  String get market_currentOffer => 'Bieżąca oferta';

  @override
  String get market_advanceHour => 'Przejdź o godzinę';

  @override
  String get market_hourAdvanced => 'Przesunięto rynek o godzinę.';

  @override
  String get market_statusActive => 'Aktywna';

  @override
  String get market_statusCounter => 'Oczekuje na odpowiedź na kontrofertę';

  @override
  String get market_statusHardRejected => 'Odrzucona i zablokowana';

  @override
  String get market_statusCompleted => 'Zakończona';

  @override
  String get market_statusCancelled => 'Anulowana';

  @override
  String get market_statusExpired => 'Termin negocjacji minął';

  @override
  String get market_closed => 'Zamknięty';

  @override
  String get market_extensions => 'Przedłużenia';

  @override
  String get market_phaseI => 'Wolna agentura — faza I';

  @override
  String get market_phaseII => 'Wolna agentura — faza II';

  @override
  String market_date(Object day, Object week) {
    return 'Tydzień $week · dzień $day';
  }

  @override
  String market_hour(Object hour, Object total) {
    return 'Godzina ofert: $hour/$total';
  }

  @override
  String market_round(Object round) {
    return 'Runda $round';
  }

  @override
  String market_deadline(Object day, Object hour, Object week) {
    return 'Termin: tydz. $week, dzień $day, godz. $hour';
  }

  @override
  String market_score(Object score) {
    return 'Wynik oferty: $score';
  }

  @override
  String market_expectedSalary(Object salary) {
    return 'Oczekiwana pensja: $salary';
  }

  @override
  String market_expectedLength(Object years) {
    return 'Oczekiwana długość: $years lat';
  }

  @override
  String get market_staffCandidates => 'Dostępny sztab';

  @override
  String get market_staffOffer => 'Złóż ofertę sztabowi';

  @override
  String get market_qo => 'Qualifying Offers';

  @override
  String get market_qoEligible => 'Kandydaci do QO';

  @override
  String get market_qoSubmitted => 'Aktywne QO';

  @override
  String market_qoMinimum(Object salary) {
    return 'Minimalna QO: $salary';
  }

  @override
  String market_offerSheetFrom(Object team) {
    return 'Oferta od: $team';
  }

  @override
  String get market_submitQO => 'Złóż QO';

  @override
  String get market_offerSheets => 'Offer sheets RFA';

  @override
  String get market_match => 'Wyrównaj';

  @override
  String get market_release => 'Odrzuć';

  @override
  String get market_draftedRights => 'Prawa do draftowanych';

  @override
  String get market_signRights => 'Podpisz prawa';

  @override
  String get market_rosterFull => 'Brak miejsca w rosterze';

  @override
  String get market_noWindow => 'Dziś nie jest otwarte żadne okno kontraktowe.';

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
  String get tactics_autosaving => 'Zapisywanie taktyki…';

  @override
  String get tactics_autosaved => 'Taktyka zapisana automatycznie';

  @override
  String get tactics_autosaveHint => 'Zmiany zapisują się automatycznie';

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
  String get inbox_tabInbox => 'Skrzynka';

  @override
  String get inbox_tabArchive => 'Archiwum';

  @override
  String get inbox_filterAll => 'Wszystkie';

  @override
  String get inbox_sectionUrgent => 'Pilne';

  @override
  String get inbox_sectionUnread => 'Nieprzeczytane';

  @override
  String get inbox_sectionRead => 'Przeczytane';

  @override
  String get inbox_emptyArchive => 'Archiwum jest puste';

  @override
  String get inbox_detailTitle => 'Szczegóły wiadomości';

  @override
  String inbox_bodyFallback(String type) {
    return 'Nowa informacja dotycząca: $type.';
  }

  @override
  String inbox_metadata(int week, int day, String domain) {
    return 'Tydzień $week · dzień $day · $domain';
  }

  @override
  String inbox_deadline(String value) {
    return 'Termin: $value';
  }

  @override
  String inbox_defaultOnExpiry(String value) {
    return 'Po terminie: $value';
  }

  @override
  String get inbox_decisionOptions => 'Wybierz opcję';

  @override
  String get inbox_actions => 'Akcje';

  @override
  String get inbox_acknowledge => 'Potwierdź';

  @override
  String get inbox_operationSaving => 'Zapisywanie potwierdzenia…';

  @override
  String get inbox_confirmationError =>
      'Nie udało się potwierdzić wiadomości. Spróbuj ponownie.';

  @override
  String get inbox_markReadError =>
      'Nie udało się otworzyć wiadomości. Spróbuj ponownie.';

  @override
  String get inbox_actionError =>
      'Nie udało się wykonać akcji. Spróbuj ponownie.';

  @override
  String get inbox_retry => 'Spróbuj ponownie';

  @override
  String get inbox_saveUncertain =>
      'Nie można potwierdzić wyniku zapisu. Spróbuj ponownie.';

  @override
  String get inbox_close => 'Zamknij';

  @override
  String inbox_digestMembers(int count) {
    return 'Wiadomości składowe ($count)';
  }

  @override
  String get inbox_actionAccept => 'Akceptuj';

  @override
  String get inbox_actionDecline => 'Odrzuć';

  @override
  String get inbox_actionCounter => 'Kontroferta';

  @override
  String get inbox_actionReject => 'Odrzuć';

  @override
  String get inbox_actionOpen => 'Otwórz';

  @override
  String get inbox_actionFallback => 'Wykonaj akcję';

  @override
  String get inbox_settingsDomain => 'Ustawienia domen';

  @override
  String get inbox_settingsType => 'Ustawienia typów';

  @override
  String get inbox_settingsDecisionMuted =>
      'Typów decyzyjnych nie można wyciszyć.';

  @override
  String get inbox_settingsDomainDecisionMuted =>
      'Domena zawiera decyzje i nie może być wyciszona.';

  @override
  String get messageDomain_matchday => 'Mecze';

  @override
  String get messageDomain_health => 'Zdrowie';

  @override
  String get messageDomain_playerEvent => 'Zawodnicy';

  @override
  String get messageDomain_teamEvent => 'Zespół';

  @override
  String get messageDomain_roster => 'Skład';

  @override
  String get messageDomain_contracts => 'Kontrakty';

  @override
  String get messageDomain_staff => 'Sztab';

  @override
  String get messageDomain_trades => 'Wymiany';

  @override
  String get messageDomain_draft => 'Draft i scouting';

  @override
  String get messageDomain_finance => 'Finanse';

  @override
  String get messageDomain_season => 'Sezon';

  @override
  String get messageDomain_system => 'System';

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
  String get calendar_event_tradeWindowOpen => 'Otwarcie okna wymian';

  @override
  String get calendar_event_contractExtensions => 'Przedłużenia kontraktów';

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
  String calendar_simulationResults_title(int week, int day) {
    return 'Wyniki meczów · tydzień $week, dzień $day';
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
  String get trade_title => 'Wymiana';

  @override
  String get trade_noTeam => 'Brak drużyny';

  @override
  String get trade_yourPlayer => 'Twój zawodnik';

  @override
  String get trade_yourPick => 'Twój pick draftowy';

  @override
  String get trade_yourRights => 'Twoje prawa draftowe';

  @override
  String get trade_targetTeam => 'Drużyna docelowa';

  @override
  String get trade_theirPlayer => 'Ich zawodnik';

  @override
  String get trade_theirPick => 'Ich pick draftowy';

  @override
  String get trade_theirRights => 'Ich prawa draftowe';

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
  String get contract_pendingFinalization =>
      'Oferta przyjęta — potwierdź finalizację';

  @override
  String get contract_finalize => 'Potwierdź i podpisz';

  @override
  String get contract_finalizationFailed =>
      'Nie udało się sfinalizować kontraktu';

  @override
  String get contract_rejected => 'Odrzucono ofertę';

  @override
  String get contract_waiting => 'Zawodnik rozważa ofertę…';

  @override
  String contract_counter(String salary, int years) {
    return 'Kontroferta: $salary × $years lat';
  }

  @override
  String get contract_counterEdit => 'Edytuj';

  @override
  String get contract_editCounterTitle => 'Edytuj kontrofertę';

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
  String get staff_fireConfirmTitle => 'Zwolnić członka sztabu?';

  @override
  String staff_fireConfirm(String name) {
    return 'Czy na pewno zwolnić $name?';
  }

  @override
  String staff_fireSuccess(String name) {
    return 'Zwolniono: $name';
  }

  @override
  String get staff_fireFailed => 'Nie udało się zwolnić członka sztabu.';

  @override
  String staff_contractRemaining(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: 'Kontrakt: # lat',
      many: 'Kontrakt: # lat',
      few: 'Kontrakt: # lata',
      one: 'Kontrakt: # rok',
    );
    return '$_temp0';
  }

  @override
  String get staff_contractExpired => 'Kontrakt wygasł';

  @override
  String staff_salaryRange(String min, String max) {
    return 'Pensja musi mieścić się w zakresie $min–$max';
  }

  @override
  String get staff_yearsRange => 'Długość kontraktu musi wynosić od 1 do 4 lat';

  @override
  String get staff_capExceeded => 'Oferta przekracza dostępny staff cap';

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
    return 'Oferta zaakceptowana: $name — potwierdź finalizację';
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
  String get staff_fireDisabled =>
      'Aktywnego kontraktu nie można jeszcze zwolnić';

  @override
  String get staff_offerPreview => 'Podgląd oferty';

  @override
  String staff_profileLine(String role, int age, String nationality) {
    return '$role · $age lat · $nationality';
  }

  @override
  String get staff_attributes => 'Atrybuty';

  @override
  String staff_expectedSalary(String salary) {
    return 'Oczekiwana pensja: $salary';
  }

  @override
  String staff_expectedLength(int years) {
    return 'Oczekiwana długość: $years lat';
  }

  @override
  String staff_offerScore(String score) {
    return 'Wynik oferty: $score';
  }

  @override
  String get staff_negotiations => 'Negocjacje sztabu';

  @override
  String get staff_noNegotiations => 'Brak zapisanych negocjacji sztabu.';

  @override
  String get staff_editCounterTitle => 'Edytuj kontrofertę sztabu';

  @override
  String get staff_attrTactics => 'Taktyka';

  @override
  String get staff_attrMotivation => 'Motywacja';

  @override
  String get staff_attrDevelopment => 'Rozwój';

  @override
  String get staff_attrMentoring => 'Mentoring';

  @override
  String get staff_attrCoverage => 'Zasięg';

  @override
  String get staff_attrEvaluation => 'Ocena';

  @override
  String get staff_attrRehabilitation => 'Rehabilitacja';

  @override
  String get staff_attrRegeneration => 'Regeneracja';

  @override
  String get staff_attrPrevention => 'Prewencja';

  @override
  String get staff_attrCare => 'Opieka';

  @override
  String get staff_attrNegotiation => 'Negocjacje';

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
  String get scouting_combineTitle => 'Draft Combine';

  @override
  String get scouting_combineColumn => 'Combine';

  @override
  String scouting_combineDescription(int limit) {
    return 'Wybierz obserwowanych prospektów na Combine. Limit: $limit.';
  }

  @override
  String scouting_combineSelected(int selected, int limit) {
    return 'Przydzielono na Combine: $selected / $limit';
  }

  @override
  String get scouting_combineAssign => 'Wybierz cele Combine';

  @override
  String get scouting_combineSave => 'Zapisz przydziały Combine';

  @override
  String get scouting_combineSaved => 'Przydziały Combine zapisane.';

  @override
  String get scouting_combineClosed =>
      'Combine zakończony — wyniki są tylko do odczytu.';

  @override
  String get scouting_combineRole => 'Optymalna rola';

  @override
  String get scouting_combineOpen => 'Otwórz wybór celów Combine';

  @override
  String get scouting_combineNoWatchlist =>
      'Najpierw dodaj prospekty do watchlisty.';

  @override
  String get scouting_role_standard => 'Standardowa';

  @override
  String get scouting_role_sweeperKeeper => 'Bramkarz-libero';

  @override
  String get scouting_role_ballPlayingDefender => 'Obrońca rozgrywający';

  @override
  String get scouting_role_noNonsenseCentreBack => 'Obrońca bezkompromisowy';

  @override
  String get scouting_role_defensiveFullBack => 'Boczny obrońca defensywny';

  @override
  String get scouting_role_attackingFullBack => 'Boczny obrońca ofensywny';

  @override
  String get scouting_role_wingBack => 'Wahadłowy';

  @override
  String get scouting_role_invertedWingBack => 'Wahadłowy schodzący do środka';

  @override
  String get scouting_role_regista => 'Regista';

  @override
  String get scouting_role_deepLyingPlaymaker =>
      'Głęboko ustawiony rozgrywający';

  @override
  String get scouting_role_anchorMan => 'Kotwica';

  @override
  String get scouting_role_ballWinning => 'Pomocnik odbierający piłkę';

  @override
  String get scouting_role_playmaker => 'Rozgrywający';

  @override
  String get scouting_role_boxToBox => 'Pomocnik box-to-box';

  @override
  String get scouting_role_mezzala => 'Mezzala';

  @override
  String get scouting_role_shadowStriker => 'Cień napastnika';

  @override
  String get scouting_role_invertedWinger => 'Skrzydłowy schodzący do środka';

  @override
  String get scouting_role_winger => 'Skrzydłowy';

  @override
  String get scouting_role_falseNine => 'Fałszywa dziewiątka';

  @override
  String get scouting_role_deepLyingForward => 'Cofnięty napastnik';

  @override
  String get scouting_role_pressingForward => 'Napastnik pressingujący';

  @override
  String get scouting_role_completeForward => 'Napastnik kompletny';

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
  String get matchday_weather => 'Pogoda';

  @override
  String get matchday_weather_clear => 'Bezchmurnie';

  @override
  String get matchday_weather_overcast => 'Pochmurno';

  @override
  String get matchday_weather_rain => 'Deszcz';

  @override
  String get matchday_weather_heavyRain => 'Ulewa';

  @override
  String get matchday_weather_wind => 'Wiatr';

  @override
  String get matchday_weather_snow => 'Śnieg';

  @override
  String get matchday_weather_heat => 'Upał';

  @override
  String get matchday_weather_cold => 'Zimno';

  @override
  String matchday_temperature(int value) {
    return '$value°C';
  }

  @override
  String get matchday_liveStats => 'Statystyki na żywo';

  @override
  String get matchday_eventFeed => 'Przebieg meczu';

  @override
  String get matchday_noEvents => 'Brak zdarzeń';

  @override
  String get matchday_derby => 'Derby';

  @override
  String get matchday_possession => 'Posiadanie';

  @override
  String get matchday_shots => 'Strzały';

  @override
  String get matchday_xg => 'xG';

  @override
  String matchday_onTarget(int value) {
    return '$value cel.';
  }

  @override
  String get matchday_lineup => 'Wyjściowa jedenastka';

  @override
  String get matchday_bench => 'Ławka';

  @override
  String get matchday_noPlayers => 'Brak zawodników';

  @override
  String get matchday_substitutions => 'Zmiany';

  @override
  String get matchday_tactics => 'Taktyka meczowa';

  @override
  String get matchday_autoPause => 'Auto-pauza';

  @override
  String get matchday_autoPauseTitle => 'Ustawienia auto-pauzy';

  @override
  String get matchday_autoPauseInjury => 'Kontuzja mojego zawodnika';

  @override
  String get matchday_autoPauseRed => 'Czerwona kartka mojego zawodnika';

  @override
  String get matchday_autoPauseHalfTime => 'Przerwa';

  @override
  String get matchday_autoPausePenalty => 'Rzut karny dla mojej drużyny';

  @override
  String get matchday_penaltyPauseUnavailable =>
      'W tym silniku nie ma jeszcze zdarzenia przyznania rzutu karnego.';

  @override
  String get matchday_speed => 'Prędkość';

  @override
  String get matchday_speed1 => '×1';

  @override
  String get matchday_speed2 => '×2';

  @override
  String get matchday_speed4 => '×4';

  @override
  String matchday_subsUsed(int used) {
    return 'Zmiany: $used';
  }

  @override
  String matchday_playerMeta(String position, int ovr, int condition) {
    return '$position · OVR $ovr · Cond $condition';
  }

  @override
  String get matchday_injured => 'Kontuzja';

  @override
  String get matchday_sentOff => 'Wyrzucony';

  @override
  String get matchday_suspended => 'Zawieszony';

  @override
  String get matchday_yellowCard => 'Żółta kartka';

  @override
  String get matchday_attention => 'Wymaga uwagi';

  @override
  String get matchday_available => 'Dostępny';

  @override
  String get matchday_formationLocked =>
      'Formację można zmienić tylko w przerwie';

  @override
  String get matchday_changesHint =>
      'Wybierz zawodnika schodzącego i rezerwowego';

  @override
  String get matchday_tacticsHint =>
      'Zmiana taktyki poza formacją jest dostępna w trakcie gry';

  @override
  String get matchday_selectOutgoing => 'Zawodnik schodzący';

  @override
  String get matchday_selectIncoming => 'Zawodnik wchodzący';

  @override
  String get matchday_confirmSubstitution => 'Wykonaj zmianę';

  @override
  String get matchday_substitutionSuccess => 'Zmiana wykonana';

  @override
  String get matchday_tacticsSuccess => 'Taktyka zaktualizowana';

  @override
  String get matchday_actionRejected => 'Nie można wykonać tej akcji';

  @override
  String get matchday_failureMatchFinished => 'Mecz został zakończony';

  @override
  String get matchday_failurePlayerNotOnPitch => 'Zawodnik nie jest na boisku';

  @override
  String get matchday_failurePlayerNotOnBench => 'Zawodnik nie jest na ławce';

  @override
  String get matchday_failurePlayerUnavailable => 'Zawodnik jest niedostępny';

  @override
  String get matchday_failurePlayerCannotReenter =>
      'Ten zawodnik nie może wrócić na boisko';

  @override
  String get matchday_failureSubstitutionsLimit => 'Wykorzystano limit zmian';

  @override
  String get matchday_failureSubstitutionWindowsLimit =>
      'Wykorzystano limit okien zmian';

  @override
  String get matchday_failureFormationOutsideHalfTime =>
      'Formację można zmienić tylko w przerwie';

  @override
  String get matchday_failureInvalidHalfTime =>
      'Akcja jest dostępna tylko w przerwie';

  @override
  String get matchday_failureNoAvailableSubstitute =>
      'Brak dostępnego rezerwowego';

  @override
  String matchday_autoPaused(String reason) {
    return 'Auto-pauza: $reason';
  }

  @override
  String matchday_matchProgress(int minute) {
    return 'Symulacja: $minute\'';
  }

  @override
  String get matchday_summaryTitle => 'Podsumowanie meczu';

  @override
  String get matchday_summaryTeamStats => 'Statystyki drużyn';

  @override
  String get matchday_summaryPlayerStats => 'Statystyki zawodników';

  @override
  String get matchday_summaryMOTM => 'Zawodnik meczu';

  @override
  String get matchday_summaryInspired => 'Inspirujący występ';

  @override
  String get matchday_summaryNone => 'Brak';

  @override
  String get matchday_summaryClose => 'Zamknij podsumowanie';

  @override
  String get matchday_summaryNoPlayerStats => 'Brak statystyk zawodników';

  @override
  String get matchday_summaryRating => 'Ocena';

  @override
  String get matchday_summaryStamina => 'Kondycja';

  @override
  String get matchday_summaryStatus => 'Status';

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
  String get dev_progress => 'Postęp';

  @override
  String get dev_growth => 'Tempo';

  @override
  String get dev_weeklyOvr => 'OVR tyg.';

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
  String get rankings_rightsAsset => 'Prawa draftowe';

  @override
  String get rankings_aiValuationTeam => 'Wycena oczami drużyny';

  @override
  String rankings_aiValuationDisclaimer(String team) {
    return 'Wartości aktywów są liczone z perspektywy: $team.';
  }

  @override
  String get rankings_openPlayer => 'Otwórz profil zawodnika';

  @override
  String get rankings_aiBaseValue => 'Baza pointValue';

  @override
  String get rankings_aiStatusAge => 'Mnożnik status/wiek';

  @override
  String get rankings_aiNeedMultiplier => 'Mnożnik potrzeby';

  @override
  String get rankings_aiContextMultiplier => 'Mnożnik kontekstu';

  @override
  String get rankings_aiProjectedSlot => 'Projektowany slot';

  @override
  String get rankings_aiFutureDiscount => 'Dyskonto przyszłości';

  @override
  String get rankings_aiUncertainty => 'Niepewność';

  @override
  String get rankings_aiRightsMultiplier => 'Mnożnik praw';

  @override
  String get rankings_aiContractDrag => 'contractDrag';

  @override
  String get rankings_aiFactors => 'Aktywne czynniki';

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
  String get stats_boxScore => 'Pełny box score';

  @override
  String get stats_shots => 'Strzały';

  @override
  String get stats_shotsOnTarget => 'Strzały celne';

  @override
  String get stats_xg => 'xG';

  @override
  String get stats_passes => 'Podania';

  @override
  String get stats_passAccuracy => 'Celność podań';

  @override
  String get stats_duelsWon => 'Wygrane pojedynki';

  @override
  String get stats_offsides => 'Spalone';

  @override
  String get stats_corners => 'Rzuty rożne';

  @override
  String get stats_fouls => 'Faule';

  @override
  String get stats_yellowCards => 'Żółte kartki';

  @override
  String get stats_redCards => 'Czerwone kartki';

  @override
  String get stats_tackles => 'Odbiory';

  @override
  String get stats_interceptions => 'Przechwyty';

  @override
  String get stats_cleanSheets => 'Czyste konta';

  @override
  String get stats_saves => 'Obrony';

  @override
  String get stats_shotsFaced => 'Strzały przeciwko';

  @override
  String get stats_possession => 'Posiadanie';

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

  @override
  String get msg_matchPreview_title => 'Zapowiedź meczu';

  @override
  String get msg_matchPreview_body => 'Nadchodzący mecz drużyn ligowych.';

  @override
  String get msg_matchResult_title => 'Wynik meczu';

  @override
  String msg_matchResult_body(
    String homeTeam,
    int homeGoals,
    int awayGoals,
    String awayTeam,
  ) {
    return 'Mecz zakończył się wynikiem $homeTeam $homeGoals:$awayGoals $awayTeam.';
  }

  @override
  String get msg_walkover_title => 'Walkower';

  @override
  String msg_walkover_body(Object reason) {
    return 'Mecz zakończony walkowerem. Powód: $reason.';
  }

  @override
  String get msg_lineupNoGk_title => 'Brak bramkarza w XI';

  @override
  String get msg_lineupNoGk_body =>
      'Drużyna nie ma bramkarza w wyjściowym składzie.';

  @override
  String get msg_benchIncomplete_title => 'Niepełna ławka';

  @override
  String msg_benchIncomplete_body(Object missingCount) {
    return 'Na ławce brakuje $missingCount zawodników.';
  }

  @override
  String get msg_suspensionStart_title => 'Początek zawieszenia';

  @override
  String msg_suspensionStart_body(Object games, Object playerName) {
    return '$playerName pauzuje przez $games meczów.';
  }

  @override
  String get msg_suspensionEnd_title => 'Koniec zawieszenia';

  @override
  String msg_suspensionEnd_body(Object playerName) {
    return '$playerName wraca do dyspozycji.';
  }

  @override
  String get msg_injury_title => 'Kontuzja';

  @override
  String msg_injury_body(
    Object days,
    Object injuryName,
    Object injuryType,
    Object playerName,
  ) {
    return '$playerName: $injuryName ($injuryType), absencja potrwa około $days dni.';
  }

  @override
  String get msg_injuryReturn_title => 'Powrót po kontuzji';

  @override
  String msg_injuryReturn_body(Object injuryName, Object playerName) {
    return '$playerName wraca po kontuzji $injuryName.';
  }

  @override
  String get msg_injuryRecurrence_title => 'Nawrót kontuzji';

  @override
  String msg_injuryRecurrence_body(Object injuryName, Object playerName) {
    return '$playerName ponownie odczuwa uraz $injuryName.';
  }

  @override
  String get msg_potentialLoss_title => 'Spadek potencjału';

  @override
  String get msg_potentialLoss_body => 'Potencjał zawodnika został obniżony.';

  @override
  String get msg_playerEvent_title => 'Wydarzenie zawodnika';

  @override
  String get msg_playerEvent_body => 'Wymagana jest uwaga menedżera.';

  @override
  String get msg_teamEvent_title => 'Wydarzenie zespołu';

  @override
  String get msg_teamEvent_body => 'Wystąpiło wydarzenie dotyczące zespołu.';

  @override
  String get msg_retirementPlayer_title => 'Emerytura zawodnika';

  @override
  String msg_retirementPlayer_body(Object playerName) {
    return '$playerName kończy karierę.';
  }

  @override
  String get msg_retirementStaff_title => 'Odejście członka sztabu';

  @override
  String get msg_retirementStaff_body => 'Członek sztabu opuszcza klub.';

  @override
  String get msg_retirementLeagueDigest_title => 'Emerytury w lidze';

  @override
  String get msg_retirementLeagueDigest_body =>
      'Podsumowanie emerytur ligowych.';

  @override
  String get msg_rosterWarning_title => 'Problem ze składem';

  @override
  String get msg_rosterWarning_body => 'Skład wymaga uzupełnienia.';

  @override
  String get msg_contractOffer_title => 'Oferta kontraktu';

  @override
  String get msg_contractOffer_body =>
      'Otrzymano informację dotyczącą kontraktu.';

  @override
  String get msg_contractSigned_title => 'Podpisany kontrakt';

  @override
  String get msg_contractSigned_body => 'Kontrakt został podpisany.';

  @override
  String get msg_contractOfferResponse_title => 'Odpowiedź na ofertę kontraktu';

  @override
  String get msg_contractOfferResponse_body =>
      'Zaktualizowano negocjacje kontraktu.';

  @override
  String get msg_contractExpiring_title => 'Wygasający kontrakt';

  @override
  String msg_contractExpiring_body(Object playerName) {
    return 'Kontrakt $playerName wygasa po tym sezonie.';
  }

  @override
  String get msg_contractLostToRival_title => 'Utracony cel';

  @override
  String msg_contractLostToRival_body(Object rivalTeam, Object subjectName) {
    return '$subjectName podpisał kontrakt z $rivalTeam.';
  }

  @override
  String get msg_contractExpired_title => 'Wygasły kontrakt';

  @override
  String msg_contractExpired_body(Object playerName) {
    return 'Kontrakt $playerName wygasł.';
  }

  @override
  String get msg_declineToExtend_title => 'Brak przedłużenia';

  @override
  String get msg_declineToExtend_body => 'Zawodnik nie chce przedłużyć umowy.';

  @override
  String get msg_rfaOfferSheet_title => 'Offer sheet';

  @override
  String get msg_rfaOfferSheet_body => 'Otrzymano ofertę od innego klubu.';

  @override
  String get msg_staffOfferResponse_title => 'Odpowiedź sztabu';

  @override
  String get msg_staffOfferResponse_body =>
      'Zaktualizowano negocjacje kontraktu sztabu.';

  @override
  String get msg_staffSigned_title => 'Podpisany kontrakt sztabu';

  @override
  String get msg_staffSigned_body => 'Członek sztabu podpisał nowy kontrakt.';

  @override
  String get msg_staffGrowth_title => 'Rozwój sztabu';

  @override
  String get msg_staffGrowth_body => 'Sztab poprawił swoje umiejętności.';

  @override
  String get msg_staffHired_title => 'Zatrudniono członka sztabu';

  @override
  String get msg_staffHired_body => 'Nowy członek sztabu dołączył do klubu.';

  @override
  String get msg_staffFired_title => 'Rozwiązano umowę sztabu';

  @override
  String get msg_staffFired_body => 'Członek sztabu opuścił klub.';

  @override
  String get msg_staffSlotEmpty_title => 'Pusty slot sztabu';

  @override
  String get msg_staffSlotEmpty_body => 'Slot sztabu wymaga obsadzenia.';

  @override
  String get msg_trade_title => 'Wymiana';

  @override
  String get msg_trade_body => 'Aktualizacja dotycząca wymiany.';

  @override
  String get msg_tradeOffer_title => 'Oferta wymiany';

  @override
  String get msg_tradeOffer_body => 'Otrzymano nową ofertę wymiany.';

  @override
  String get msg_tradeWindowEvent_title => 'Okno wymian';

  @override
  String get msg_tradeWindowEvent_body =>
      'Zaktualizowano informacje o oknie wymian.';

  @override
  String get msg_lottery_title => 'Loteria draftowa';

  @override
  String get msg_lottery_body => 'Wyniki loterii draftowej są dostępne.';

  @override
  String get msg_scoutReport_title => 'Raport skautingowy';

  @override
  String get msg_scoutReport_body => 'Nowe informacje skautingowe są dostępne.';

  @override
  String get msg_combine_title => 'Wyniki Combine';

  @override
  String get msg_combine_body => 'Wyniki testów prospektów są dostępne.';

  @override
  String get msg_mockDraft_title => 'Mock draft';

  @override
  String get msg_mockDraft_body => 'Zaktualizowano prognozę draftu.';

  @override
  String get msg_draftPick_title => 'Wybór w drafcie';

  @override
  String get msg_draftPick_body => 'Nadeszła kolej wyboru w drafcie.';

  @override
  String get msg_draftPickLeague_title => 'Wybór innej drużyny';

  @override
  String get msg_draftPickLeague_body =>
      'Inna drużyna dokonała wyboru w drafcie.';

  @override
  String get msg_draftedRightsReminder_title => 'Niepodpisany draftowany';

  @override
  String msg_draftedRightsReminder_body(Object playerName, Object rosterCount) {
    return 'Masz prawa do $playerName; roster: $rosterCount/30.';
  }

  @override
  String get msg_apronWarning_title => 'Przekroczenie apronu';

  @override
  String get msg_apronWarning_body => 'Payroll przekracza dozwolony poziom.';

  @override
  String get msg_capUpdateTv_title => 'Aktualizacja salary cap';

  @override
  String get msg_capUpdateTv_body => 'Salary cap został zaktualizowany.';

  @override
  String get msg_staffCapViolation_title => 'Przekroczenie staff cap';

  @override
  String get msg_staffCapViolation_body => 'Payroll sztabu przekracza limit.';

  @override
  String get msg_award_title => 'Nagroda';

  @override
  String get msg_award_body => 'Przyznano nagrodę sezonową.';

  @override
  String get msg_award_mvp_title => 'MVP sezonu';

  @override
  String msg_award_mvp_body(String playerName) {
    return '$playerName otrzymał nagrodę MVP.';
  }

  @override
  String get msg_award_roty_title => 'Debiutant sezonu';

  @override
  String msg_award_roty_body(String playerName) {
    return '$playerName został debiutantem sezonu.';
  }

  @override
  String get msg_award_dpoy_title => 'Obrońca sezonu';

  @override
  String msg_award_dpoy_body(String playerName) {
    return '$playerName otrzymał nagrodę dla obrońcy sezonu.';
  }

  @override
  String get msg_award_coachOfYear_title => 'Trener sezonu';

  @override
  String msg_award_coachOfYear_body(String teamName) {
    return '$teamName ma najlepszego trenera sezonu.';
  }

  @override
  String get msg_award_topScorer_title => 'Król strzelców';

  @override
  String msg_award_topScorer_body(String playerName) {
    return '$playerName został królem strzelców.';
  }

  @override
  String get msg_award_topAssist_title => 'Król asyst';

  @override
  String msg_award_topAssist_body(String playerName) {
    return '$playerName został królem asyst.';
  }

  @override
  String get msg_award_bestGk_title => 'Najlepszy bramkarz';

  @override
  String msg_award_bestGk_body(String playerName) {
    return '$playerName został najlepszym bramkarzem sezonu.';
  }

  @override
  String get msg_award_teamOfSeason_title => 'Drużyna sezonu';

  @override
  String msg_award_teamOfSeason_body(String playerName, String slot) {
    return '$playerName został wybrany na pozycję $slot.';
  }

  @override
  String get msg_award_champion_title => 'Mistrz ligi';

  @override
  String msg_award_champion_body(String teamName) {
    return '$teamName zdobył mistrzostwo ligi.';
  }

  @override
  String get msg_playoffSeeding_title => 'Rozstawienie playoff';

  @override
  String msg_playoffSeeding_body(String conference) {
    return 'Konferencja $conference: rozstawienie playoff zostało ustalone.';
  }

  @override
  String get msg_playInResult_title => 'Wynik play-in';

  @override
  String msg_playInResult_body(String conference) {
    return 'Konferencja $conference: zwycięzcy play-in są znani.';
  }

  @override
  String get msg_atmosphere_title => 'Atmosfera zespołu';

  @override
  String get msg_atmosphere_body => 'Zmieniono poziom atmosfery w klubie.';

  @override
  String get msg_teamStatusChange_title => 'Zmiana statusu zespołu';

  @override
  String get msg_teamStatusChange_body =>
      'Status zespołu został zaktualizowany.';

  @override
  String get msg_seasonSummary_title => 'Podsumowanie sezonu';

  @override
  String get msg_seasonSummary_body =>
      'Podsumowanie bieżącego sezonu jest gotowe.';

  @override
  String get msg_playoffMissed_title => 'Brak awansu do playoffów';

  @override
  String get msg_playoffMissed_body => 'Zespół nie awansował do fazy playoff.';

  @override
  String get msg_calendar_title => 'Kalendarz';

  @override
  String get msg_calendar_body => 'Nowe wydarzenie w kalendarzu.';

  @override
  String get msg_system_title => 'Komunikat systemowy';

  @override
  String msg_system_body(String message) {
    return '$message';
  }

  @override
  String get msg_ovrDigest_title => 'Rozwój OVR';

  @override
  String get msg_ovrDigest_body => 'Podsumowanie rozwoju zawodników.';

  @override
  String get msg_playerEvent_plateau_title => 'Plateau zawodnika';

  @override
  String msg_playerEvent_plateau_body(Object playerName) {
    return '$playerName potrzebuje zmiany programu treningowego.';
  }

  @override
  String get msg_playerEvent_coldStreak_title => 'Kryzys formy';

  @override
  String msg_playerEvent_coldStreak_body(Object playerName) {
    return '$playerName przechodzi kryzys formy.';
  }

  @override
  String get msg_playerEvent_injuryComplication_title => 'Komplikacje kontuzji';

  @override
  String msg_playerEvent_injuryComplication_body(Object playerName) {
    return 'Powrót $playerName wymaga decyzji.';
  }

  @override
  String get msg_playerEvent_veteranMotivation_title =>
      'Spadek motywacji weterana';

  @override
  String msg_playerEvent_veteranMotivation_body(Object playerName) {
    return '$playerName potrzebuje wsparcia.';
  }

  @override
  String get msg_playerEvent_extraTraining_title => 'Dodatkowy trening';

  @override
  String msg_playerEvent_extraTraining_body(Object playerName) {
    return '$playerName prosi o dodatkową sesję.';
  }

  @override
  String get msg_playerEvent_personalSupport_title => 'Wsparcie zawodnika';

  @override
  String msg_playerEvent_personalSupport_body(Object playerName) {
    return '$playerName potrzebuje wsparcia klubu.';
  }

  @override
  String get msg_playerEvent_breakthrough_title => 'Przełom rozwojowy';

  @override
  String msg_playerEvent_breakthrough_body(Object playerName) {
    return '$playerName zanotował przełom.';
  }

  @override
  String get msg_playerEvent_personalProblems_title => 'Problemy osobiste';

  @override
  String msg_playerEvent_personalProblems_body(Object playerName) {
    return '$playerName ma problemy osobiste.';
  }

  @override
  String get msg_playerEvent_lateBloomer_title => 'Późny rozwój';

  @override
  String msg_playerEvent_lateBloomer_body(Object playerName) {
    return '$playerName poprawił swój atrybut.';
  }

  @override
  String get msg_playerEvent_nationalTeam_title => 'Powołanie do kadry';

  @override
  String msg_playerEvent_nationalTeam_body(Object playerName) {
    return '$playerName otrzymał powołanie.';
  }

  @override
  String get msg_playerEvent_inspiredPerformance_title => 'Inspirujący występ';

  @override
  String msg_playerEvent_inspiredPerformance_body(Object playerName) {
    return '$playerName zanotował świetny występ.';
  }

  @override
  String get msg_teamEvent_moreMinutesRequest_title => 'Prośba o minuty';

  @override
  String msg_teamEvent_moreMinutesRequest_body(Object playerName) {
    return '$playerName prosi o więcej minut.';
  }

  @override
  String get msg_teamEvent_transferRequestI_title => 'Prośba o transfer';

  @override
  String msg_teamEvent_transferRequestI_body(Object playerName) {
    return '$playerName chce odejść z klubu.';
  }

  @override
  String get msg_teamEvent_transferRequestII_title => 'Żądanie transferu';

  @override
  String msg_teamEvent_transferRequestII_body(Object playerName) {
    return '$playerName ponawia żądanie transferu.';
  }

  @override
  String get msg_teamEvent_dressingRoomConflict_title => 'Konflikt w szatni';

  @override
  String get msg_teamEvent_dressingRoomConflict_body =>
      'W szatni wybuchł konflikt.';

  @override
  String get msg_teamEvent_publicCriticism_title => 'Publiczna krytyka';

  @override
  String get msg_teamEvent_publicCriticism_body =>
      'Zawodnik publicznie skrytykował menedżera.';

  @override
  String get msg_teamEvent_declineToExtend_title => 'Brak przedłużenia';

  @override
  String get msg_teamEvent_declineToExtend_body =>
      'Zawodnik nie chce przedłużyć umowy.';

  @override
  String get msg_teamEvent_leaderSupport_title => 'Wsparcie lidera';

  @override
  String get msg_teamEvent_leaderSupport_body =>
      'Lider zespołu wsparł drużynę.';

  @override
  String get msg_teamEvent_promiseBroken_title => 'Złamana obietnica';

  @override
  String get msg_teamEvent_promiseBroken_body =>
      'Nie zrealizowano obietnicy złożonej zawodnikowi.';

  @override
  String get msg_teamEvent_atmosphereShift_title => 'Zmiana atmosfery';

  @override
  String get msg_teamEvent_atmosphereShift_body =>
      'Atmosfera zespołu uległa zmianie.';

  @override
  String get msg_contractOffer_accept_title => 'Akceptacja oferty';

  @override
  String msg_contractOffer_accept_body(Object subjectName) {
    return 'Oferta dla $subjectName czeka na finalizację.';
  }

  @override
  String get msg_contractOffer_reject_title => 'Odrzucenie oferty';

  @override
  String get msg_contractOffer_reject_body =>
      'Oferta kontraktu została odrzucona.';

  @override
  String get msg_contractOffer_hardReject_title => 'Twarde odrzucenie';

  @override
  String get msg_contractOffer_hardReject_body =>
      'Negocjacje zostały zablokowane.';

  @override
  String get msg_contractOffer_waiting_title => 'Oferta w toku';

  @override
  String get msg_contractOffer_waiting_body => 'Zawodnik rozważa ofertę.';

  @override
  String get msg_contractOffer_counter_title => 'Kontroferta';

  @override
  String get msg_contractOffer_counter_body =>
      'Otrzymano kontrofertę kontraktu.';

  @override
  String get msg_contractOffer_rfaQualifyingOffer_title => 'QO do złożenia';

  @override
  String get msg_contractOffer_rfaQualifyingOffer_body =>
      'Zbliża się termin złożenia Qualifying Offer.';

  @override
  String get msg_contractOfferResponse_accept_title => 'Oferta zaakceptowana';

  @override
  String msg_contractOfferResponse_accept_body(Object subjectName) {
    return 'Oferta dla $subjectName została zaakceptowana i czeka na finalizację.';
  }

  @override
  String get msg_contractOfferResponse_reject_title => 'Oferta odrzucona';

  @override
  String msg_contractOfferResponse_reject_body(Object subjectName) {
    return 'Oferta dla $subjectName została odrzucona.';
  }

  @override
  String get msg_contractOfferResponse_hardReject_title => 'Twarde odrzucenie';

  @override
  String msg_contractOfferResponse_hardReject_body(Object subjectName) {
    return 'Negocjacje z $subjectName zostały zablokowane.';
  }

  @override
  String get msg_contractOfferResponse_waiting_title => 'Oferta w toku';

  @override
  String msg_contractOfferResponse_waiting_body(Object subjectName) {
    return '$subjectName rozważa ofertę.';
  }

  @override
  String get msg_contractOfferResponse_counter_title => 'Kontroferta';

  @override
  String msg_contractOfferResponse_counter_body(
    Object salary,
    Object subjectName,
    Object years,
  ) {
    return '$subjectName złożył kontrofertę: $salary na $years lat.';
  }

  @override
  String get msg_staffOfferResponse_accept_title =>
      'Oferta sztabu zaakceptowana';

  @override
  String msg_staffOfferResponse_accept_body(Object subjectName) {
    return 'Oferta dla $subjectName została zaakceptowana i czeka na finalizację.';
  }

  @override
  String get msg_staffOfferResponse_reject_title => 'Oferta sztabu odrzucona';

  @override
  String msg_staffOfferResponse_reject_body(Object subjectName) {
    return 'Oferta dla $subjectName została odrzucona.';
  }

  @override
  String get msg_staffOfferResponse_hardReject_title =>
      'Twarde odrzucenie sztabu';

  @override
  String msg_staffOfferResponse_hardReject_body(Object subjectName) {
    return 'Negocjacje z $subjectName zostały zablokowane.';
  }

  @override
  String get msg_staffOfferResponse_waiting_title => 'Oferta sztabu w toku';

  @override
  String msg_staffOfferResponse_waiting_body(Object subjectName) {
    return '$subjectName rozważa ofertę.';
  }

  @override
  String get msg_staffOfferResponse_counter_title => 'Kontroferta sztabu';

  @override
  String msg_staffOfferResponse_counter_body(
    Object salary,
    Object subjectName,
    Object years,
  ) {
    return '$subjectName złożył kontrofertę: $salary na $years lat.';
  }

  @override
  String get msg_staffOfferResponse_lostToRival_title => 'Utracony cel sztabu';

  @override
  String msg_staffOfferResponse_lostToRival_body(
    Object rivalTeam,
    Object subjectName,
  ) {
    return '$subjectName podpisał kontrakt z $rivalTeam.';
  }

  @override
  String get msg_contractLostToRival_lostToRival_title => 'Utracony cel';

  @override
  String msg_contractLostToRival_lostToRival_body(
    Object rivalTeam,
    Object subjectName,
  ) {
    return '$subjectName podpisał kontrakt z $rivalTeam.';
  }

  @override
  String get msg_contractExpiring_player_title =>
      'Wygasający kontrakt zawodnika';

  @override
  String msg_contractExpiring_player_body(Object playerName) {
    return 'Kontrakt $playerName wygasa po tym sezonie.';
  }

  @override
  String get msg_contractExpiring_staff_title => 'Wygasający kontrakt sztabu';

  @override
  String msg_contractExpiring_staff_body(Object staffName) {
    return 'Kontrakt $staffName wygasa po tym sezonie.';
  }

  @override
  String get msg_contractExpired_player_title => 'Wygasły kontrakt zawodnika';

  @override
  String msg_contractExpired_player_body(Object playerName) {
    return 'Kontrakt $playerName wygasł.';
  }

  @override
  String get msg_contractExpired_staff_title => 'Wygasły kontrakt sztabu';

  @override
  String msg_contractExpired_staff_body(Object staffName) {
    return 'Kontrakt $staffName wygasł.';
  }

  @override
  String get msg_trade_counter_title => 'Kontroferta wymiany';

  @override
  String get msg_trade_counter_body => 'Otrzymano kontrofertę od partnera.';

  @override
  String get msg_trade_accepted_title => 'Wymiana zaakceptowana';

  @override
  String get msg_trade_accepted_body => 'Wymiana została wykonana.';

  @override
  String get msg_trade_rejected_title => 'Wymiana odrzucona';

  @override
  String get msg_trade_rejected_body => 'Partner odrzucił propozycję wymiany.';

  @override
  String get msg_trade_hardRejected_title => 'Blokada wymiany';

  @override
  String get msg_trade_hardRejected_body =>
      'Negocjacje są zablokowane przez 30 dni.';

  @override
  String get msg_trade_ntcRefusal_title => 'Odmowa NTC';

  @override
  String get msg_trade_ntcRefusal_body =>
      'Zawodnik nie wyraził zgody na transfer.';

  @override
  String get msg_trade_leagueDigest_title => 'Wymiany w lidze';

  @override
  String get msg_trade_leagueDigest_body => 'Podsumowanie wymian ligowych.';

  @override
  String get msg_tradeWindowEvent_open_title => 'Otwarcie okna wymian';

  @override
  String get msg_tradeWindowEvent_open_body =>
      'Od dziś można wykonywać wymiany.';

  @override
  String get msg_tradeWindowEvent_deadline_title => 'Trade deadline';

  @override
  String get msg_tradeWindowEvent_deadline_body =>
      'Zbliża się termin zamknięcia okna wymian.';

  @override
  String get msg_scoutReport_monthly_title => 'Miesięczny raport scouta';

  @override
  String get msg_scoutReport_monthly_body =>
      'Dostępny jest nowy raport scouta.';

  @override
  String get msg_scoutReport_event_title => 'Scout Report — przydziel Combine';

  @override
  String get msg_scoutReport_event_body => 'Przypisz prospektów do Combine.';

  @override
  String get msg_mockDraft_initial_title => 'Wstępny mock draft';

  @override
  String get msg_mockDraft_initial_body =>
      'Dostępna jest wstępna prognoza draftu.';

  @override
  String get msg_mockDraft_final_title => 'Finalny mock draft';

  @override
  String get msg_mockDraft_final_body =>
      'Dostępna jest finalna prognoza draftu.';

  @override
  String get msg_draftPick_own_title => 'Twój wybór w drafcie';

  @override
  String get msg_draftPick_own_body => 'Nadeszła kolej Twojej drużyny.';

  @override
  String get msg_draftPickLeague_league_title => 'Wybór ligowy';

  @override
  String get msg_draftPickLeague_league_body => 'Inna drużyna dokonała wyboru.';

  @override
  String get msg_playerEvent_action_accept => 'Akceptuj';

  @override
  String get msg_playerEvent_action_decline => 'Odrzuć';

  @override
  String get msg_playerEvent_action_cautious => 'Ostrożny powrót';

  @override
  String get msg_playerEvent_action_full => 'Pełne obciążenie';

  @override
  String get msg_teamEvent_action_accept => 'Akceptuj';

  @override
  String get msg_teamEvent_action_decline => 'Odrzuć';

  @override
  String get msg_teamEvent_action_intervene => 'Interweniuj';

  @override
  String get msg_teamEvent_action_ignore => 'Zignoruj';

  @override
  String get msg_teamEvent_action_response => 'Odpowiedz publicznie';

  @override
  String get msg_teamEvent_action_punish => 'Kara dyscyplinarna';

  @override
  String get msg_contractOffer_action_finalize => 'Finalizuj';

  @override
  String get msg_contractOffer_action_cancel => 'Anuluj';

  @override
  String get msg_contractOffer_action_accept => 'Akceptuj';

  @override
  String get msg_contractOffer_action_counter => 'Złóż kontrofertę';

  @override
  String get msg_contractOffer_action_decline => 'Odrzuć';

  @override
  String get msg_contractOffer_action_submit => 'Złóż QO';

  @override
  String get msg_contractOfferResponse_action_accept => 'Akceptuj';

  @override
  String get msg_contractOfferResponse_action_counter => 'Złóż kontrofertę';

  @override
  String get msg_contractOfferResponse_action_decline => 'Odrzuć';

  @override
  String get msg_staffOfferResponse_action_accept => 'Akceptuj';

  @override
  String get msg_staffOfferResponse_action_counter => 'Złóż kontrofertę';

  @override
  String get msg_staffOfferResponse_action_decline => 'Odrzuć';

  @override
  String get msg_tradeOffer_action_accept => 'Akceptuj';

  @override
  String get msg_tradeOffer_action_counter => 'Kontroferta';

  @override
  String get msg_tradeOffer_action_reject => 'Odrzuć';

  @override
  String get msg_trade_action_accept => 'Akceptuj';

  @override
  String get msg_trade_action_counter => 'Kontroferta';

  @override
  String get msg_trade_action_reject => 'Odrzuć';

  @override
  String get msg_scoutReport_action_openWatchlist => 'Otwórz watchlistę';

  @override
  String get msg_draftPick_action_openDraft => 'Otwórz draft';

  @override
  String get msg_retirementLeagueDigest_digest_title => 'Emerytury ligowe';

  @override
  String msg_retirementLeagueDigest_digest_body(int count, int week) {
    return '$count zawodników zakończyło karierę w tygodniu $week.';
  }

  @override
  String get msg_draftPickLeague_digest_title => 'Wybory w rundzie draftu';

  @override
  String get msg_draftPickLeague_digest_body =>
      'Podsumowanie wyborów innych drużyn.';

  @override
  String get msg_staffGrowth_digest_title => 'Rozwój sztabu';

  @override
  String get msg_staffGrowth_digest_body => 'Podsumowanie zmian w sztabie.';

  @override
  String get msg_trade_digest_title => 'Wymiany w lidze';

  @override
  String msg_trade_digest_body(int week) {
    return 'Podsumowanie wymian w tygodniu $week.';
  }

  @override
  String get msg_ovrDigest_digest_title => 'Rozwój OVR';

  @override
  String msg_ovrDigest_digest_body(int count, int week) {
    return '$count zawodników poprawiło OVR w tygodniu $week.';
  }

  @override
  String get msg_calendar_newWeek_title => 'Nowy tydzień';

  @override
  String msg_calendar_newWeek_body(Object week) {
    return 'Rozpoczął się tydzień $week.';
  }

  @override
  String get msg_contractSigned_fa_title => 'Kontrakt podpisany';

  @override
  String get msg_contractSigned_fa_body =>
      'Zawodnik podpisał kontrakt z klubem.';
}
