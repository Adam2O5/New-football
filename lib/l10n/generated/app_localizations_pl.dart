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
  String get squad_swapped => 'Zamieniono miejsca';

  @override
  String get standings_noLeague => 'Brak ligi';

  @override
  String get standings_tabEast => 'Wschód';

  @override
  String get standings_tabWest => 'Zachód';

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
  String get trade_title => 'Wymiana';

  @override
  String get trade_noTeam => 'Brak drużyny';

  @override
  String get trade_yourPlayer => 'Twój zawodnik';

  @override
  String get trade_targetTeam => 'Drużyna docelowa';

  @override
  String get trade_theirPlayer => 'Ich zawodnik';

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
}
