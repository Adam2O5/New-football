import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pl, this message translates to:
  /// **'New Football'**
  String get appTitle;

  /// No description provided for @common_cancel.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz'**
  String get common_save;

  /// No description provided for @stat_ovr.
  ///
  /// In pl, this message translates to:
  /// **'OVR'**
  String get stat_ovr;

  /// No description provided for @stat_form.
  ///
  /// In pl, this message translates to:
  /// **'Forma'**
  String get stat_form;

  /// No description provided for @stat_cond.
  ///
  /// In pl, this message translates to:
  /// **'Cond'**
  String get stat_cond;

  /// No description provided for @stat_pv.
  ///
  /// In pl, this message translates to:
  /// **'PV'**
  String get stat_pv;

  /// No description provided for @stat_pot.
  ///
  /// In pl, this message translates to:
  /// **'Pot.'**
  String get stat_pot;

  /// No description provided for @stat_height.
  ///
  /// In pl, this message translates to:
  /// **'Wzrost'**
  String get stat_height;

  /// No description provided for @money_million.
  ///
  /// In pl, this message translates to:
  /// **'{value} mln'**
  String money_million(String value);

  /// No description provided for @money_thousand.
  ///
  /// In pl, this message translates to:
  /// **'{value} tys.'**
  String money_thousand(String value);

  /// No description provided for @day_mon.
  ///
  /// In pl, this message translates to:
  /// **'Pon'**
  String get day_mon;

  /// No description provided for @day_tue.
  ///
  /// In pl, this message translates to:
  /// **'Wt'**
  String get day_tue;

  /// No description provided for @day_wed.
  ///
  /// In pl, this message translates to:
  /// **'Śr'**
  String get day_wed;

  /// No description provided for @day_thu.
  ///
  /// In pl, this message translates to:
  /// **'Czw'**
  String get day_thu;

  /// No description provided for @day_fri.
  ///
  /// In pl, this message translates to:
  /// **'Pt'**
  String get day_fri;

  /// No description provided for @day_sat.
  ///
  /// In pl, this message translates to:
  /// **'Sob'**
  String get day_sat;

  /// No description provided for @day_sun.
  ///
  /// In pl, this message translates to:
  /// **'Nd'**
  String get day_sun;

  /// No description provided for @seasonPhase_preseason.
  ///
  /// In pl, this message translates to:
  /// **'Przedsezon'**
  String get seasonPhase_preseason;

  /// No description provided for @seasonPhase_regular.
  ///
  /// In pl, this message translates to:
  /// **'Sezon zasadniczy'**
  String get seasonPhase_regular;

  /// No description provided for @seasonPhase_playIn.
  ///
  /// In pl, this message translates to:
  /// **'Play-in'**
  String get seasonPhase_playIn;

  /// No description provided for @seasonPhase_playoff.
  ///
  /// In pl, this message translates to:
  /// **'Playoffy'**
  String get seasonPhase_playoff;

  /// No description provided for @seasonPhase_draft.
  ///
  /// In pl, this message translates to:
  /// **'Draft'**
  String get seasonPhase_draft;

  /// No description provided for @seasonPhase_offseason.
  ///
  /// In pl, this message translates to:
  /// **'Offseason'**
  String get seasonPhase_offseason;

  /// No description provided for @matchEvent_goal.
  ///
  /// In pl, this message translates to:
  /// **'Gol'**
  String get matchEvent_goal;

  /// No description provided for @matchEvent_yellowCard.
  ///
  /// In pl, this message translates to:
  /// **'Żółta kartka'**
  String get matchEvent_yellowCard;

  /// No description provided for @matchEvent_redCard.
  ///
  /// In pl, this message translates to:
  /// **'Czerwona kartka'**
  String get matchEvent_redCard;

  /// No description provided for @matchEvent_minorInjury.
  ///
  /// In pl, this message translates to:
  /// **'Drobna kontuzja'**
  String get matchEvent_minorInjury;

  /// No description provided for @matchEvent_majorInjury.
  ///
  /// In pl, this message translates to:
  /// **'Poważna kontuzja'**
  String get matchEvent_majorInjury;

  /// No description provided for @matchEvent_substitution.
  ///
  /// In pl, this message translates to:
  /// **'Zmiana'**
  String get matchEvent_substitution;

  /// No description provided for @matchEvent_scoredPenalty.
  ///
  /// In pl, this message translates to:
  /// **'Wykorzystany karny'**
  String get matchEvent_scoredPenalty;

  /// No description provided for @matchEvent_missedPenalty.
  ///
  /// In pl, this message translates to:
  /// **'Niewykorzystany karny'**
  String get matchEvent_missedPenalty;

  /// No description provided for @matchEvent_halfTime.
  ///
  /// In pl, this message translates to:
  /// **'Przerwa'**
  String get matchEvent_halfTime;

  /// No description provided for @matchEvent_fullTime.
  ///
  /// In pl, this message translates to:
  /// **'Koniec meczu'**
  String get matchEvent_fullTime;

  /// No description provided for @messageType_injury.
  ///
  /// In pl, this message translates to:
  /// **'Kontuzja'**
  String get messageType_injury;

  /// No description provided for @messageType_retirementPlayer.
  ///
  /// In pl, this message translates to:
  /// **'Zakończenie kariery zawodnika'**
  String get messageType_retirementPlayer;

  /// No description provided for @messageType_retirementStaff.
  ///
  /// In pl, this message translates to:
  /// **'Odejście członka sztabu'**
  String get messageType_retirementStaff;

  /// No description provided for @messageType_staffGrowth.
  ///
  /// In pl, this message translates to:
  /// **'Rozwój sztabu'**
  String get messageType_staffGrowth;

  /// No description provided for @messageType_award.
  ///
  /// In pl, this message translates to:
  /// **'Nagroda'**
  String get messageType_award;

  /// No description provided for @messageType_lottery.
  ///
  /// In pl, this message translates to:
  /// **'Loteria draftowa'**
  String get messageType_lottery;

  /// No description provided for @messageType_scoutReport.
  ///
  /// In pl, this message translates to:
  /// **'Raport skautingowy'**
  String get messageType_scoutReport;

  /// No description provided for @messageType_combine.
  ///
  /// In pl, this message translates to:
  /// **'Combine'**
  String get messageType_combine;

  /// No description provided for @messageType_mockDraft.
  ///
  /// In pl, this message translates to:
  /// **'Prognoza draftu'**
  String get messageType_mockDraft;

  /// No description provided for @messageType_draftPick.
  ///
  /// In pl, this message translates to:
  /// **'Wybór w drafcie'**
  String get messageType_draftPick;

  /// No description provided for @messageType_contractOffer.
  ///
  /// In pl, this message translates to:
  /// **'Oferta kontraktu'**
  String get messageType_contractOffer;

  /// No description provided for @messageType_contractSigned.
  ///
  /// In pl, this message translates to:
  /// **'Podpisany kontrakt'**
  String get messageType_contractSigned;

  /// No description provided for @messageType_trade.
  ///
  /// In pl, this message translates to:
  /// **'Wymiana'**
  String get messageType_trade;

  /// No description provided for @messageType_walkover.
  ///
  /// In pl, this message translates to:
  /// **'Walkower'**
  String get messageType_walkover;

  /// No description provided for @messageType_matchPreview.
  ///
  /// In pl, this message translates to:
  /// **'Zapowiedź meczu'**
  String get messageType_matchPreview;

  /// No description provided for @messageType_matchResult.
  ///
  /// In pl, this message translates to:
  /// **'Wynik meczu'**
  String get messageType_matchResult;

  /// No description provided for @messageType_atmosphere.
  ///
  /// In pl, this message translates to:
  /// **'Atmosfera w drużynie'**
  String get messageType_atmosphere;

  /// No description provided for @messageType_calendar.
  ///
  /// In pl, this message translates to:
  /// **'Kalendarz'**
  String get messageType_calendar;

  /// No description provided for @messageType_system.
  ///
  /// In pl, this message translates to:
  /// **'System'**
  String get messageType_system;

  /// No description provided for @notificationLevel_important.
  ///
  /// In pl, this message translates to:
  /// **'Ważne'**
  String get notificationLevel_important;

  /// No description provided for @notificationLevel_normal.
  ///
  /// In pl, this message translates to:
  /// **'Normalne'**
  String get notificationLevel_normal;

  /// No description provided for @notificationLevel_muted.
  ///
  /// In pl, this message translates to:
  /// **'Wyciszone'**
  String get notificationLevel_muted;

  /// No description provided for @tempo_slow.
  ///
  /// In pl, this message translates to:
  /// **'Wolne'**
  String get tempo_slow;

  /// No description provided for @tempo_balanced.
  ///
  /// In pl, this message translates to:
  /// **'Zbalansowane'**
  String get tempo_balanced;

  /// No description provided for @tempo_fast.
  ///
  /// In pl, this message translates to:
  /// **'Szybkie'**
  String get tempo_fast;

  /// No description provided for @pressing_low.
  ///
  /// In pl, this message translates to:
  /// **'Niski'**
  String get pressing_low;

  /// No description provided for @pressing_medium.
  ///
  /// In pl, this message translates to:
  /// **'Średni'**
  String get pressing_medium;

  /// No description provided for @pressing_high.
  ///
  /// In pl, this message translates to:
  /// **'Wysoki'**
  String get pressing_high;

  /// No description provided for @pressing_gegenpressing.
  ///
  /// In pl, this message translates to:
  /// **'Gegenpressing'**
  String get pressing_gegenpressing;

  /// No description provided for @defensiveLine_deep.
  ///
  /// In pl, this message translates to:
  /// **'Głęboka'**
  String get defensiveLine_deep;

  /// No description provided for @defensiveLine_normal.
  ///
  /// In pl, this message translates to:
  /// **'Standardowa'**
  String get defensiveLine_normal;

  /// No description provided for @defensiveLine_high.
  ///
  /// In pl, this message translates to:
  /// **'Wysoka'**
  String get defensiveLine_high;

  /// No description provided for @attackWidth_narrow.
  ///
  /// In pl, this message translates to:
  /// **'Wąska'**
  String get attackWidth_narrow;

  /// No description provided for @attackWidth_balanced.
  ///
  /// In pl, this message translates to:
  /// **'Zbalansowana'**
  String get attackWidth_balanced;

  /// No description provided for @attackWidth_wide.
  ///
  /// In pl, this message translates to:
  /// **'Szeroka'**
  String get attackWidth_wide;

  /// No description provided for @mainMenu_subtitle.
  ///
  /// In pl, this message translates to:
  /// **'Menedżer ligi w stylu NBA'**
  String get mainMenu_subtitle;

  /// No description provided for @mainMenu_newGame.
  ///
  /// In pl, this message translates to:
  /// **'Nowa gra'**
  String get mainMenu_newGame;

  /// No description provided for @mainMenu_loadGame.
  ///
  /// In pl, this message translates to:
  /// **'Wczytaj'**
  String get mainMenu_loadGame;

  /// No description provided for @mainMenu_settings.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia'**
  String get mainMenu_settings;

  /// No description provided for @settings_title.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia'**
  String get settings_title;

  /// No description provided for @settings_language.
  ///
  /// In pl, this message translates to:
  /// **'Język'**
  String get settings_language;

  /// No description provided for @settings_language_polish.
  ///
  /// In pl, this message translates to:
  /// **'Polski'**
  String get settings_language_polish;

  /// No description provided for @settings_language_english.
  ///
  /// In pl, this message translates to:
  /// **'English'**
  String get settings_language_english;

  /// No description provided for @newGame_title.
  ///
  /// In pl, this message translates to:
  /// **'Nowa gra'**
  String get newGame_title;

  /// No description provided for @newGame_defaultSaveName.
  ///
  /// In pl, this message translates to:
  /// **'Moja kariera'**
  String get newGame_defaultSaveName;

  /// No description provided for @newGame_missingFields.
  ///
  /// In pl, this message translates to:
  /// **'Podaj nazwę zapisu i wybierz drużynę'**
  String get newGame_missingFields;

  /// No description provided for @newGame_createFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się utworzyć gry'**
  String get newGame_createFailed;

  /// No description provided for @newGame_saveName.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa zapisu'**
  String get newGame_saveName;

  /// No description provided for @newGame_difficulty.
  ///
  /// In pl, this message translates to:
  /// **'Trudność'**
  String get newGame_difficulty;

  /// No description provided for @newGame_difficultyNormal.
  ///
  /// In pl, this message translates to:
  /// **'Normalna'**
  String get newGame_difficultyNormal;

  /// No description provided for @newGame_difficultyHard.
  ///
  /// In pl, this message translates to:
  /// **'Trudna'**
  String get newGame_difficultyHard;

  /// No description provided for @newGame_chooseTeam.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz drużynę'**
  String get newGame_chooseTeam;

  /// No description provided for @newGame_start.
  ///
  /// In pl, this message translates to:
  /// **'Rozpocznij karierę'**
  String get newGame_start;

  /// No description provided for @loadGame_title.
  ///
  /// In pl, this message translates to:
  /// **'Wczytaj grę'**
  String get loadGame_title;

  /// No description provided for @loadGame_error.
  ///
  /// In pl, this message translates to:
  /// **'Błąd: {error}'**
  String loadGame_error(String error);

  /// No description provided for @loadGame_empty.
  ///
  /// In pl, this message translates to:
  /// **'Brak zapisów'**
  String get loadGame_empty;

  /// No description provided for @loadGame_subtitle.
  ///
  /// In pl, this message translates to:
  /// **'{teamName} · Sezon {year} · {phase}'**
  String loadGame_subtitle(String teamName, int year, String phase);

  /// No description provided for @loadGame_loadFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać zapisu'**
  String get loadGame_loadFailed;

  /// No description provided for @loadGame_delete.
  ///
  /// In pl, this message translates to:
  /// **'Usuń'**
  String get loadGame_delete;

  /// No description provided for @loadGame_deleteConfirmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usunąć zapis?'**
  String get loadGame_deleteConfirmTitle;

  /// No description provided for @loadGame_deleteConfirmMessage.
  ///
  /// In pl, this message translates to:
  /// **'Zapis „{name}” zostanie trwale usunięty.'**
  String loadGame_deleteConfirmMessage(String name);

  /// No description provided for @loadGame_deleteFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się usunąć zapisu'**
  String get loadGame_deleteFailed;

  /// No description provided for @shell_noActiveGame.
  ///
  /// In pl, this message translates to:
  /// **'Brak aktywnej gry'**
  String get shell_noActiveGame;

  /// No description provided for @shell_mainMenu.
  ///
  /// In pl, this message translates to:
  /// **'Menu główne'**
  String get shell_mainMenu;

  /// No description provided for @shell_defaultCareerName.
  ///
  /// In pl, this message translates to:
  /// **'Kariera'**
  String get shell_defaultCareerName;

  /// No description provided for @shell_draftTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Draft'**
  String get shell_draftTooltip;

  /// No description provided for @shell_menuTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Menu'**
  String get shell_menuTooltip;

  /// No description provided for @shell_tab_calendar.
  ///
  /// In pl, this message translates to:
  /// **'Kalendarz'**
  String get shell_tab_calendar;

  /// No description provided for @shell_tab_squad.
  ///
  /// In pl, this message translates to:
  /// **'Skład'**
  String get shell_tab_squad;

  /// No description provided for @shell_tab_tactics.
  ///
  /// In pl, this message translates to:
  /// **'Taktyka'**
  String get shell_tab_tactics;

  /// No description provided for @shell_tab_standings.
  ///
  /// In pl, this message translates to:
  /// **'Tabela'**
  String get shell_tab_standings;

  /// No description provided for @shell_tab_finance.
  ///
  /// In pl, this message translates to:
  /// **'Finanse'**
  String get shell_tab_finance;

  /// No description provided for @shell_tab_inbox.
  ///
  /// In pl, this message translates to:
  /// **'Skrzynka'**
  String get shell_tab_inbox;

  /// No description provided for @shell_tab_home.
  ///
  /// In pl, this message translates to:
  /// **'Start'**
  String get shell_tab_home;

  /// No description provided for @home_title.
  ///
  /// In pl, this message translates to:
  /// **'Start'**
  String get home_title;

  /// No description provided for @home_next7days.
  ///
  /// In pl, this message translates to:
  /// **'Najbliższe 7 dni'**
  String get home_next7days;

  /// No description provided for @home_conferenceRankLabel.
  ///
  /// In pl, this message translates to:
  /// **'Miejsce w konferencji'**
  String get home_conferenceRankLabel;

  /// No description provided for @home_overallRankLabel.
  ///
  /// In pl, this message translates to:
  /// **'Miejsce w tabeli ogólnej'**
  String get home_overallRankLabel;

  /// No description provided for @home_record.
  ///
  /// In pl, this message translates to:
  /// **'Bilans drużyny'**
  String get home_record;

  /// No description provided for @home_lastMatchTitle.
  ///
  /// In pl, this message translates to:
  /// **'Poprzedni mecz'**
  String get home_lastMatchTitle;

  /// No description provided for @home_nextMatchTitle.
  ///
  /// In pl, this message translates to:
  /// **'Następny mecz'**
  String get home_nextMatchTitle;

  /// No description provided for @home_noPreviousMatch.
  ///
  /// In pl, this message translates to:
  /// **'Brak rozegranych meczów'**
  String get home_noPreviousMatch;

  /// No description provided for @home_noNextMatch.
  ///
  /// In pl, this message translates to:
  /// **'Brak zaplanowanych meczów'**
  String get home_noNextMatch;

  /// No description provided for @home_simulateUntilNextEvent.
  ///
  /// In pl, this message translates to:
  /// **'Do następnego wydarzenia'**
  String get home_simulateUntilNextEvent;

  /// No description provided for @squad_noTeam.
  ///
  /// In pl, this message translates to:
  /// **'Brak drużyny gracza'**
  String get squad_noTeam;

  /// No description provided for @squad_sizeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Skład: {size} / {min}–{max}'**
  String squad_sizeLabel(int size, int min, int max);

  /// No description provided for @squad_injury.
  ///
  /// In pl, this message translates to:
  /// **'KONTUZJA'**
  String get squad_injury;

  /// No description provided for @squad_xiBadge.
  ///
  /// In pl, this message translates to:
  /// **'XI'**
  String get squad_xiBadge;

  /// No description provided for @squad_bench.
  ///
  /// In pl, this message translates to:
  /// **'Ławka'**
  String get squad_bench;

  /// No description provided for @squad_reserves.
  ///
  /// In pl, this message translates to:
  /// **'Rezerwa'**
  String get squad_reserves;

  /// No description provided for @squad_tacticsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Taktyka'**
  String get squad_tacticsTitle;

  /// No description provided for @squad_selectHint.
  ///
  /// In pl, this message translates to:
  /// **'Zaznacz zawodnika, potem kliknij drugiego, aby zamienić miejsca'**
  String get squad_selectHint;

  /// No description provided for @squad_cannotFieldInjured.
  ///
  /// In pl, this message translates to:
  /// **'Kontuzjowany zawodnik nie może wejść do składu meczowego'**
  String get squad_cannotFieldInjured;

  /// No description provided for @squad_swappedPlaces.
  ///
  /// In pl, this message translates to:
  /// **'Zamieniono miejsca zawodników'**
  String get squad_swappedPlaces;

  /// Tytuł sekcji z pełną listą zawodników na ekranie składu.
  ///
  /// In pl, this message translates to:
  /// **'Skład'**
  String get squad_rosterTitle;

  /// Etykieta pokazywana przy zawodniku przypisanym do wyjściowej jedenastki.
  ///
  /// In pl, this message translates to:
  /// **'XI'**
  String get squad_zoneXi;

  /// Etykieta pokazywana przy zawodniku przypisanym do ławki rezerwowych.
  ///
  /// In pl, this message translates to:
  /// **'Ławka'**
  String get squad_zoneBench;

  /// Etykieta pokazywana przy zawodniku przypisanym do rezerw.
  ///
  /// In pl, this message translates to:
  /// **'Rezerwy'**
  String get squad_zoneReserves;

  /// Opcja sortowania składu: po ocenie overall, malejąco.
  ///
  /// In pl, this message translates to:
  /// **'Overall'**
  String get squad_sortOverall;

  /// Opcja sortowania składu: po strefie (XI, ławka, rezerwa), a w jej obrębie po pozycji.
  ///
  /// In pl, this message translates to:
  /// **'Przypisanie'**
  String get squad_sortAssignedZone;

  /// Opcja sortowania składu: po aktualnej formie, malejąco.
  ///
  /// In pl, this message translates to:
  /// **'Forma'**
  String get squad_sortForm;

  /// Opcja sortowania składu: wyłącznie po pozycji, z pominięciem strefy przypisania.
  ///
  /// In pl, this message translates to:
  /// **'Pozycja'**
  String get squad_sortPosition;

  /// Title of the bottom sheet opened when tapping a slot on the pitch, showing the name of the player being substituted.
  ///
  /// In pl, this message translates to:
  /// **'Zmiana za {name}'**
  String substitute_sheetTitle(String name);

  /// Subtitle/hint shown below the title in the substitute bottom sheet.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz zawodnika do zamiany miejscami'**
  String get substitute_sheetSubtitle;

  /// No description provided for @standings_noLeague.
  ///
  /// In pl, this message translates to:
  /// **'Brak ligi'**
  String get standings_noLeague;

  /// No description provided for @standings_tabEast.
  ///
  /// In pl, this message translates to:
  /// **'Wschód'**
  String get standings_tabEast;

  /// No description provided for @standings_tabWest.
  ///
  /// In pl, this message translates to:
  /// **'Zachód'**
  String get standings_tabWest;

  /// No description provided for @standings_empty.
  ///
  /// In pl, this message translates to:
  /// **'Brak tabeli'**
  String get standings_empty;

  /// No description provided for @standings_col_team.
  ///
  /// In pl, this message translates to:
  /// **'Drużyna'**
  String get standings_col_team;

  /// No description provided for @standings_col_record.
  ///
  /// In pl, this message translates to:
  /// **'W-R-P'**
  String get standings_col_record;

  /// No description provided for @standings_col_points.
  ///
  /// In pl, this message translates to:
  /// **'Pkt'**
  String get standings_col_points;

  /// No description provided for @standings_col_diff.
  ///
  /// In pl, this message translates to:
  /// **'+/−'**
  String get standings_col_diff;

  /// No description provided for @finance_noTeam.
  ///
  /// In pl, this message translates to:
  /// **'Brak drużyny gracza'**
  String get finance_noTeam;

  /// No description provided for @finance_title.
  ///
  /// In pl, this message translates to:
  /// **'Finanse'**
  String get finance_title;

  /// No description provided for @finance_payroll.
  ///
  /// In pl, this message translates to:
  /// **'Payroll'**
  String get finance_payroll;

  /// No description provided for @finance_cap.
  ///
  /// In pl, this message translates to:
  /// **'Salary cap'**
  String get finance_cap;

  /// No description provided for @finance_capSpace.
  ///
  /// In pl, this message translates to:
  /// **'Wolne miejsce'**
  String get finance_capSpace;

  /// No description provided for @finance_firstApron.
  ///
  /// In pl, this message translates to:
  /// **'Pierwszy apron'**
  String get finance_firstApron;

  /// No description provided for @finance_secondApron.
  ///
  /// In pl, this message translates to:
  /// **'Drugi apron'**
  String get finance_secondApron;

  /// No description provided for @finance_tax.
  ///
  /// In pl, this message translates to:
  /// **'Podatek luksusowy'**
  String get finance_tax;

  /// No description provided for @finance_cash.
  ///
  /// In pl, this message translates to:
  /// **'Gotówka'**
  String get finance_cash;

  /// No description provided for @finance_status.
  ///
  /// In pl, this message translates to:
  /// **'Status'**
  String get finance_status;

  /// No description provided for @finance_capStatus_under.
  ///
  /// In pl, this message translates to:
  /// **'Pod capem'**
  String get finance_capStatus_under;

  /// No description provided for @finance_capStatus_over.
  ///
  /// In pl, this message translates to:
  /// **'Powyżej capu'**
  String get finance_capStatus_over;

  /// No description provided for @finance_trade.
  ///
  /// In pl, this message translates to:
  /// **'Wymiany (trade)'**
  String get finance_trade;

  /// No description provided for @finance_contracts.
  ///
  /// In pl, this message translates to:
  /// **'Kontrakty / przedłużenia'**
  String get finance_contracts;

  /// No description provided for @tactics_noTeam.
  ///
  /// In pl, this message translates to:
  /// **'Brak drużyny gracza'**
  String get tactics_noTeam;

  /// No description provided for @tactics_formation.
  ///
  /// In pl, this message translates to:
  /// **'Formacja'**
  String get tactics_formation;

  /// No description provided for @tactics_tempo.
  ///
  /// In pl, this message translates to:
  /// **'Tempo'**
  String get tactics_tempo;

  /// No description provided for @tactics_pressing.
  ///
  /// In pl, this message translates to:
  /// **'Pressing'**
  String get tactics_pressing;

  /// No description provided for @tactics_defensiveLine.
  ///
  /// In pl, this message translates to:
  /// **'Linia obrony'**
  String get tactics_defensiveLine;

  /// No description provided for @tactics_attackWidth.
  ///
  /// In pl, this message translates to:
  /// **'Szerokość ataku'**
  String get tactics_attackWidth;

  /// No description provided for @tactics_save.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz taktykę'**
  String get tactics_save;

  /// No description provided for @tactics_saved.
  ///
  /// In pl, this message translates to:
  /// **'Zapisano taktykę'**
  String get tactics_saved;

  /// No description provided for @inbox_title.
  ///
  /// In pl, this message translates to:
  /// **'Skrzynka'**
  String get inbox_title;

  /// No description provided for @inbox_notifications.
  ///
  /// In pl, this message translates to:
  /// **'Powiadomienia'**
  String get inbox_notifications;

  /// No description provided for @inbox_empty.
  ///
  /// In pl, this message translates to:
  /// **'Skrzynka pusta'**
  String get inbox_empty;

  /// No description provided for @inbox_messageSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Tydzień {week}\n{body}'**
  String inbox_messageSubtitle(int week, String body);

  /// No description provided for @inbox_settingsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Poziomy powiadomień'**
  String get inbox_settingsTitle;

  /// No description provided for @draft_title.
  ///
  /// In pl, this message translates to:
  /// **'Draft'**
  String get draft_title;

  /// No description provided for @draft_notActive.
  ///
  /// In pl, this message translates to:
  /// **'Draft jeszcze nieaktywny'**
  String get draft_notActive;

  /// No description provided for @draft_finished.
  ///
  /// In pl, this message translates to:
  /// **'Draft zakończony'**
  String get draft_finished;

  /// No description provided for @draft_pickLabel.
  ///
  /// In pl, this message translates to:
  /// **'Pick #{number} (R{round})'**
  String draft_pickLabel(int number, int round);

  /// No description provided for @draft_teamLabel.
  ///
  /// In pl, this message translates to:
  /// **'Drużyna: {name}'**
  String draft_teamLabel(String name);

  /// No description provided for @draft_yourTurn.
  ///
  /// In pl, this message translates to:
  /// **'Twoja kolej!'**
  String get draft_yourTurn;

  /// No description provided for @draft_remainingProspects.
  ///
  /// In pl, this message translates to:
  /// **'Pozostali prospecti ({count})'**
  String draft_remainingProspects(int count);

  /// No description provided for @draft_select.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz'**
  String get draft_select;

  /// No description provided for @draft_selected.
  ///
  /// In pl, this message translates to:
  /// **'Wybrano: {name}'**
  String draft_selected(String name);

  /// No description provided for @calendar_noLeague.
  ///
  /// In pl, this message translates to:
  /// **'Brak ligi'**
  String get calendar_noLeague;

  /// No description provided for @calendar_weekDayHeader.
  ///
  /// In pl, this message translates to:
  /// **'Tydzień {week} · {dayName} (dzień {day})'**
  String calendar_weekDayHeader(int week, String dayName, int day);

  /// No description provided for @calendar_phaseLine.
  ///
  /// In pl, this message translates to:
  /// **'Faza: {phase} · Sezon {year}'**
  String calendar_phaseLine(String phase, int year);

  /// No description provided for @calendar_homeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Home'**
  String get calendar_homeLabel;

  /// No description provided for @calendar_event_tradeDeadline.
  ///
  /// In pl, this message translates to:
  /// **'Deadline wymiany'**
  String get calendar_event_tradeDeadline;

  /// No description provided for @calendar_event_awards.
  ///
  /// In pl, this message translates to:
  /// **'Nagrody'**
  String get calendar_event_awards;

  /// No description provided for @calendar_event_retirements.
  ///
  /// In pl, this message translates to:
  /// **'Emerytury'**
  String get calendar_event_retirements;

  /// No description provided for @calendar_event_draftLottery.
  ///
  /// In pl, this message translates to:
  /// **'Loteria draftu'**
  String get calendar_event_draftLottery;

  /// No description provided for @calendar_event_scoutReport.
  ///
  /// In pl, this message translates to:
  /// **'Raport skautingowy'**
  String get calendar_event_scoutReport;

  /// No description provided for @calendar_event_combine.
  ///
  /// In pl, this message translates to:
  /// **'Draft Combine'**
  String get calendar_event_combine;

  /// No description provided for @calendar_event_mockDraft.
  ///
  /// In pl, this message translates to:
  /// **'Mock Draft (finalny)'**
  String get calendar_event_mockDraft;

  /// No description provided for @calendar_event_draft.
  ///
  /// In pl, this message translates to:
  /// **'Draft'**
  String get calendar_event_draft;

  /// No description provided for @calendar_event_freeAgency.
  ///
  /// In pl, this message translates to:
  /// **'Wolna agentura'**
  String get calendar_event_freeAgency;

  /// No description provided for @calendar_draft.
  ///
  /// In pl, this message translates to:
  /// **'Draft'**
  String get calendar_draft;

  /// No description provided for @calendar_pickProgress.
  ///
  /// In pl, this message translates to:
  /// **'Pick {current}/{total}'**
  String calendar_pickProgress(int current, int total);

  /// No description provided for @calendar_weekEvents.
  ///
  /// In pl, this message translates to:
  /// **'Wydarzenia tygodnia'**
  String get calendar_weekEvents;

  /// No description provided for @calendar_noMatches.
  ///
  /// In pl, this message translates to:
  /// **'Brak meczów w tym tygodniu'**
  String get calendar_noMatches;

  /// No description provided for @calendar_simulateDay.
  ///
  /// In pl, this message translates to:
  /// **'Symuluj dzień'**
  String get calendar_simulateDay;

  /// No description provided for @calendar_urgentMessage.
  ///
  /// In pl, this message translates to:
  /// **'Pilna wiadomość w skrzynce'**
  String get calendar_urgentMessage;

  /// No description provided for @calendar_fastForward.
  ///
  /// In pl, this message translates to:
  /// **'Szybka symulacja'**
  String get calendar_fastForward;

  /// No description provided for @calendar_simulateUntilNextMatch.
  ///
  /// In pl, this message translates to:
  /// **'Do następnego meczu'**
  String get calendar_simulateUntilNextMatch;

  /// No description provided for @calendar_simulateUntilDate.
  ///
  /// In pl, this message translates to:
  /// **'Do wybranej daty'**
  String get calendar_simulateUntilDate;

  /// No description provided for @calendar_simulateUntilPhaseEnd.
  ///
  /// In pl, this message translates to:
  /// **'Do końca fazy'**
  String get calendar_simulateUntilPhaseEnd;

  /// No description provided for @calendar_chooseDateTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz cel symulacji'**
  String get calendar_chooseDateTitle;

  /// No description provided for @calendar_weekLabel.
  ///
  /// In pl, this message translates to:
  /// **'Tydzień'**
  String get calendar_weekLabel;

  /// No description provided for @calendar_dayLabel.
  ///
  /// In pl, this message translates to:
  /// **'Dzień'**
  String get calendar_dayLabel;

  /// No description provided for @calendar_simulating.
  ///
  /// In pl, this message translates to:
  /// **'Symulowanie…'**
  String get calendar_simulating;

  /// No description provided for @calendar_daysSimulated.
  ///
  /// In pl, this message translates to:
  /// **'Zasymulowano dni: {count}'**
  String calendar_daysSimulated(int count);

  /// No description provided for @calendar_cancel.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get calendar_cancel;

  /// No description provided for @calendar_stopReason_reachedTarget.
  ///
  /// In pl, this message translates to:
  /// **'Cel osiągnięty'**
  String get calendar_stopReason_reachedTarget;

  /// No description provided for @calendar_stopReason_cancelled.
  ///
  /// In pl, this message translates to:
  /// **'Symulacja przerwana'**
  String get calendar_stopReason_cancelled;

  /// No description provided for @calendar_stopReason_draftPick.
  ///
  /// In pl, this message translates to:
  /// **'Twoja tura draftu'**
  String get calendar_stopReason_draftPick;

  /// No description provided for @calendar_stopReason_noSave.
  ///
  /// In pl, this message translates to:
  /// **'Brak zapisanej gry'**
  String get calendar_stopReason_noSave;

  /// No description provided for @calendar_selectedDay_title.
  ///
  /// In pl, this message translates to:
  /// **'Wybrany dzień'**
  String get calendar_selectedDay_title;

  /// No description provided for @calendar_selectedDay_noEvent.
  ///
  /// In pl, this message translates to:
  /// **'Brak wydarzeń tego dnia'**
  String get calendar_selectedDay_noEvent;

  /// No description provided for @calendar_selectedDay_matchUpcoming.
  ///
  /// In pl, this message translates to:
  /// **'Nadchodzący mecz: {opponent}'**
  String calendar_selectedDay_matchUpcoming(String opponent);

  /// No description provided for @calendar_selectedDay_matchResult.
  ///
  /// In pl, this message translates to:
  /// **'{home} {homeGoals}:{awayGoals} {away}'**
  String calendar_selectedDay_matchResult(
    String home,
    String away,
    int homeGoals,
    int awayGoals,
  );

  /// No description provided for @calendar_selectedDay_offseasonEvent.
  ///
  /// In pl, this message translates to:
  /// **'Wydarzenie: {name}'**
  String calendar_selectedDay_offseasonEvent(String name);

  /// No description provided for @trade_title.
  ///
  /// In pl, this message translates to:
  /// **'Wymiana'**
  String get trade_title;

  /// No description provided for @trade_noTeam.
  ///
  /// In pl, this message translates to:
  /// **'Brak drużyny'**
  String get trade_noTeam;

  /// No description provided for @trade_yourPlayer.
  ///
  /// In pl, this message translates to:
  /// **'Twój zawodnik'**
  String get trade_yourPlayer;

  /// No description provided for @trade_targetTeam.
  ///
  /// In pl, this message translates to:
  /// **'Drużyna docelowa'**
  String get trade_targetTeam;

  /// No description provided for @trade_theirPlayer.
  ///
  /// In pl, this message translates to:
  /// **'Ich zawodnik'**
  String get trade_theirPlayer;

  /// No description provided for @trade_confirm.
  ///
  /// In pl, this message translates to:
  /// **'Zatwierdź wymianę'**
  String get trade_confirm;

  /// No description provided for @trade_fillAllFields.
  ///
  /// In pl, this message translates to:
  /// **'Uzupełnij wszystkie pola'**
  String get trade_fillAllFields;

  /// No description provided for @trade_notAllowed.
  ///
  /// In pl, this message translates to:
  /// **'Wymiana niedozwolona'**
  String get trade_notAllowed;

  /// No description provided for @trade_aiRejected.
  ///
  /// In pl, this message translates to:
  /// **'Druga drużyna odrzuciła propozycję wymiany'**
  String get trade_aiRejected;

  /// No description provided for @trade_executeFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wykonać wymiany'**
  String get trade_executeFailed;

  /// No description provided for @trade_success.
  ///
  /// In pl, this message translates to:
  /// **'Wymiana zakończona sukcesem'**
  String get trade_success;

  /// No description provided for @trade_playerOption.
  ///
  /// In pl, this message translates to:
  /// **'{name} ({position}, PV {pv})'**
  String trade_playerOption(String name, String position, int pv);

  /// No description provided for @contract_title.
  ///
  /// In pl, this message translates to:
  /// **'Kontrakty'**
  String get contract_title;

  /// No description provided for @contract_noTeam.
  ///
  /// In pl, this message translates to:
  /// **'Brak drużyny'**
  String get contract_noTeam;

  /// No description provided for @contract_expiringHeader.
  ///
  /// In pl, this message translates to:
  /// **'Wygasające / do przedłużenia'**
  String get contract_expiringHeader;

  /// No description provided for @contract_noExpiring.
  ///
  /// In pl, this message translates to:
  /// **'Brak zawodników do przedłużenia'**
  String get contract_noExpiring;

  /// No description provided for @contract_playerSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'{position} · OVR {ovr} · Lata: {years} · {salary}'**
  String contract_playerSubtitle(
    String position,
    int ovr,
    int years,
    String salary,
  );

  /// No description provided for @contract_freeAgentsHeader.
  ///
  /// In pl, this message translates to:
  /// **'Wolni agenci (lata = 0 w lidze)'**
  String get contract_freeAgentsHeader;

  /// No description provided for @contract_freeAgentsEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Pula FA pusta / uproszczona — skup się na przedłużeniach.'**
  String get contract_freeAgentsEmpty;

  /// No description provided for @contract_freeAgentsCount.
  ///
  /// In pl, this message translates to:
  /// **'{count} zawodników z yearsRemaining=0'**
  String contract_freeAgentsCount(int count);

  /// No description provided for @contract_offerSalary.
  ///
  /// In pl, this message translates to:
  /// **'Oferta pensji'**
  String get contract_offerSalary;

  /// No description provided for @contract_offerYears.
  ///
  /// In pl, this message translates to:
  /// **'Lata kontraktu'**
  String get contract_offerYears;

  /// No description provided for @contract_submitOffer.
  ///
  /// In pl, this message translates to:
  /// **'Złóż ofertę przedłużenia'**
  String get contract_submitOffer;

  /// No description provided for @contract_selectPlayer.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz zawodnika'**
  String get contract_selectPlayer;

  /// No description provided for @contract_invalidOffer.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowa pensja lub lata'**
  String get contract_invalidOffer;

  /// No description provided for @contract_accepted.
  ///
  /// In pl, this message translates to:
  /// **'Kontrakt przyjęty!'**
  String get contract_accepted;

  /// No description provided for @contract_rejected.
  ///
  /// In pl, this message translates to:
  /// **'Odrzucono ofertę'**
  String get contract_rejected;

  /// No description provided for @contract_waiting.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnik rozważa ofertę…'**
  String get contract_waiting;

  /// No description provided for @contract_counter.
  ///
  /// In pl, this message translates to:
  /// **'Kontroferta: {salary} × {years} lat'**
  String contract_counter(String salary, int years);

  /// No description provided for @staff_title.
  ///
  /// In pl, this message translates to:
  /// **'Sztab'**
  String get staff_title;

  /// No description provided for @staff_noTeam.
  ///
  /// In pl, this message translates to:
  /// **'Brak drużyny'**
  String get staff_noTeam;

  /// No description provided for @staffRole_headCoach.
  ///
  /// In pl, this message translates to:
  /// **'Trener główny'**
  String get staffRole_headCoach;

  /// No description provided for @staffRole_youthCoach.
  ///
  /// In pl, this message translates to:
  /// **'Trener młodzieży'**
  String get staffRole_youthCoach;

  /// No description provided for @staffRole_scout.
  ///
  /// In pl, this message translates to:
  /// **'Scout'**
  String get staffRole_scout;

  /// No description provided for @staffRole_physio.
  ///
  /// In pl, this message translates to:
  /// **'Fizjoterapeuta'**
  String get staffRole_physio;

  /// No description provided for @staffRole_doctor.
  ///
  /// In pl, this message translates to:
  /// **'Lekarz'**
  String get staffRole_doctor;

  /// No description provided for @staffRole_cfo.
  ///
  /// In pl, this message translates to:
  /// **'CFO'**
  String get staffRole_cfo;

  /// No description provided for @staff_emptySlot.
  ///
  /// In pl, this message translates to:
  /// **'Slot wolny'**
  String get staff_emptySlot;

  /// No description provided for @staff_fire.
  ///
  /// In pl, this message translates to:
  /// **'Zwolnij'**
  String get staff_fire;

  /// No description provided for @staff_candidatesHeader.
  ///
  /// In pl, this message translates to:
  /// **'Kandydaci do zatrudnienia'**
  String get staff_candidatesHeader;

  /// No description provided for @staff_noCandidates.
  ///
  /// In pl, this message translates to:
  /// **'Brak wolnych kandydatów na tę rolę'**
  String get staff_noCandidates;

  /// No description provided for @staff_overallStars.
  ///
  /// In pl, this message translates to:
  /// **'★ {stars}'**
  String staff_overallStars(String stars);

  /// No description provided for @staff_memberSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'{age} lat · ★ {stars} · {salary}/rok'**
  String staff_memberSubtitle(int age, String stars, String salary);

  /// No description provided for @staff_hire.
  ///
  /// In pl, this message translates to:
  /// **'Zatrudnij'**
  String get staff_hire;

  /// No description provided for @staff_hireAccepted.
  ///
  /// In pl, this message translates to:
  /// **'Zatrudniono {name}!'**
  String staff_hireAccepted(String name);

  /// No description provided for @staff_hireRejected.
  ///
  /// In pl, this message translates to:
  /// **'Kandydat odrzucił ofertę lub przekroczono staff cap'**
  String get staff_hireRejected;

  /// No description provided for @staff_capLabel.
  ///
  /// In pl, this message translates to:
  /// **'Staff cap'**
  String get staff_capLabel;

  /// No description provided for @staff_capUsage.
  ///
  /// In pl, this message translates to:
  /// **'{used} / {cap}'**
  String staff_capUsage(String used, String cap);

  /// No description provided for @scouting_watchlistTitle.
  ///
  /// In pl, this message translates to:
  /// **'Watchlista skauta'**
  String get scouting_watchlistTitle;

  /// No description provided for @scouting_watchlistLimit.
  ///
  /// In pl, this message translates to:
  /// **'Wybrano {selected} / {limit}'**
  String scouting_watchlistLimit(int selected, int limit);

  /// No description provided for @scouting_cancel.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get scouting_cancel;

  /// No description provided for @scouting_save.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz'**
  String get scouting_save;

  /// No description provided for @scouting_slot_top1.
  ///
  /// In pl, this message translates to:
  /// **'Typ: TOP 1'**
  String get scouting_slot_top1;

  /// No description provided for @scouting_slot_top3.
  ///
  /// In pl, this message translates to:
  /// **'Typ: TOP 3'**
  String get scouting_slot_top3;

  /// No description provided for @scouting_slot_top5.
  ///
  /// In pl, this message translates to:
  /// **'Typ: TOP 5'**
  String get scouting_slot_top5;

  /// No description provided for @scouting_slot_top10.
  ///
  /// In pl, this message translates to:
  /// **'Typ: TOP 10'**
  String get scouting_slot_top10;

  /// No description provided for @scouting_slot_r1.
  ///
  /// In pl, this message translates to:
  /// **'Typ: R1'**
  String get scouting_slot_r1;

  /// No description provided for @scouting_slot_r2.
  ///
  /// In pl, this message translates to:
  /// **'Typ: R2'**
  String get scouting_slot_r2;

  /// No description provided for @scouting_slot_r3.
  ///
  /// In pl, this message translates to:
  /// **'Typ: R3'**
  String get scouting_slot_r3;

  /// No description provided for @scouting_slot_x.
  ///
  /// In pl, this message translates to:
  /// **'Typ: X'**
  String get scouting_slot_x;

  /// No description provided for @draft_scoutGradeShort.
  ///
  /// In pl, this message translates to:
  /// **'Scout {grade}'**
  String draft_scoutGradeShort(int grade);

  /// No description provided for @draft_potentialShort.
  ///
  /// In pl, this message translates to:
  /// **'Pot. {stars}'**
  String draft_potentialShort(String stars);

  /// No description provided for @draft_injuryProneShort.
  ///
  /// In pl, this message translates to:
  /// **'Kontuzje {value}/10'**
  String draft_injuryProneShort(int value);

  /// No description provided for @draft_determinationShort.
  ///
  /// In pl, this message translates to:
  /// **'Determinacja {value}/10'**
  String draft_determinationShort(int value);

  /// No description provided for @contract_faCounter.
  ///
  /// In pl, this message translates to:
  /// **'Kontroferta na rynku FA — spróbuj ponownie z wyższą ofertą'**
  String get contract_faCounter;

  /// No description provided for @playerDetail_title.
  ///
  /// In pl, this message translates to:
  /// **'Zawodnik'**
  String get playerDetail_title;

  /// No description provided for @playerDetail_notFound.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono zawodnika'**
  String get playerDetail_notFound;

  /// No description provided for @playerDetail_headerLine.
  ///
  /// In pl, this message translates to:
  /// **'{position} · {nationality} · {age} lat'**
  String playerDetail_headerLine(String position, String nationality, int age);

  /// No description provided for @playerDetail_attributes.
  ///
  /// In pl, this message translates to:
  /// **'Atrybuty'**
  String get playerDetail_attributes;

  /// No description provided for @playerDetail_contract.
  ///
  /// In pl, this message translates to:
  /// **'Kontrakt'**
  String get playerDetail_contract;

  /// No description provided for @playerDetail_salaryLine.
  ///
  /// In pl, this message translates to:
  /// **'Pensja: {salary} / rok'**
  String playerDetail_salaryLine(String salary);

  /// No description provided for @playerDetail_contractYears.
  ///
  /// In pl, this message translates to:
  /// **'Lata: {years}'**
  String playerDetail_contractYears(int years);

  /// No description provided for @playerDetail_birdRights.
  ///
  /// In pl, this message translates to:
  /// **'Bird rights'**
  String get playerDetail_birdRights;

  /// No description provided for @playerDetail_noTradeClause.
  ///
  /// In pl, this message translates to:
  /// **'NTC'**
  String get playerDetail_noTradeClause;

  /// No description provided for @playerDetail_personality.
  ///
  /// In pl, this message translates to:
  /// **'Osobowość: {personality}'**
  String playerDetail_personality(String personality);

  /// No description provided for @matchday_defaultTitle.
  ///
  /// In pl, this message translates to:
  /// **'Mecz'**
  String get matchday_defaultTitle;

  /// No description provided for @matchday_finishedSnackbar.
  ///
  /// In pl, this message translates to:
  /// **'Koniec: {home}:{away}'**
  String matchday_finishedSnackbar(int home, int away);

  /// No description provided for @matchday_resume.
  ///
  /// In pl, this message translates to:
  /// **'Wznów'**
  String get matchday_resume;

  /// No description provided for @matchday_pause.
  ///
  /// In pl, this message translates to:
  /// **'Pauza'**
  String get matchday_pause;

  /// No description provided for @matchday_toEnd.
  ///
  /// In pl, this message translates to:
  /// **'Do końca'**
  String get matchday_toEnd;

  /// No description provided for @router_noMatchData.
  ///
  /// In pl, this message translates to:
  /// **'Brak danych meczu'**
  String get router_noMatchData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
